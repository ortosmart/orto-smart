-- ============================================================================
-- UPDATE GARDEN
-- ============================================================================
-- Aggiorna un Garden esclusivamente tramite Write Path autoritativo.
-- L'identità applicativa deriva sempre da auth.uid().
-- Solo l'owner attivo del Profile con Profile Write Authority valida
-- può completare l'aggiornamento.
--
-- Esempio pratico:
-- un Garden "Orto principale" può diventare "Orto di casa" mantenendo
-- lo stesso garden_id; la modifica incrementa row_version.
-- Se i valori richiesti sono già identici a quelli presenti, l'esito è
-- "unchanged" e non viene generata una nuova versione.

create or replace function public.update_garden(
  target_profile_id uuid,
  target_garden_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  garden_name text,
  garden_description text,

  garden_latitude double precision,
  garden_longitude double precision,
  garden_elevation_m integer,
  garden_timezone text,

  garden_country_code text,
  garden_municipality text,
  garden_locality text,
  garden_street_address text,

  garden_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_name text;
  v_description text;
  v_timezone text;
  v_country_code text;
  v_municipality text;
  v_locality text;
  v_street_address text;

  v_current_name text;
  v_current_description text;
  v_current_latitude double precision;
  v_current_longitude double precision;
  v_current_elevation_m integer;
  v_current_timezone text;
  v_current_country_code text;
  v_current_municipality text;
  v_current_locality text;
  v_current_street_address text;
  v_current_is_active boolean;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_garden_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 2. PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3. LETTURA GARDEN E VERIFICA APPARTENENZA AL PROFILE
  -- --------------------------------------------------------------------------
  -- Il Garden viene cercato direttamente nel Profile indicato.
  -- Se non appartiene al Profile, non ne viene rivelata l'eventuale
  -- esistenza altrove.

  select
    g.name,
    g.description,
    g.latitude,
    g.longitude,
    g.elevation_m,
    g.timezone,
    g.country_code,
    g.municipality,
    g.locality,
    g.street_address,
    g.is_active,
    g.row_version,
    g.updated_at
  into
    v_current_name,
    v_current_description,
    v_current_latitude,
    v_current_longitude,
    v_current_elevation_m,
    v_current_timezone,
    v_current_country_code,
    v_current_municipality,
    v_current_locality,
    v_current_street_address,
    v_current_is_active,
    v_current_row_version,
    v_current_updated_at
  from public.gardens g
  where g.id = target_garden_id
    and g.profile_id = target_profile_id;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 4. NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    upper(
      left(
        lower(
          regexp_replace(
            btrim(garden_name),
            '[[:space:]]+',
            ' ',
            'g'
          )
        ),
        1
      )
    )
    ||
    substr(
      lower(
        regexp_replace(
          btrim(garden_name),
          '[[:space:]]+',
          ' ',
          'g'
        )
      ),
      2
    );

  v_description :=
    nullif(btrim(garden_description), '');

  v_timezone :=
    btrim(garden_timezone);

  v_country_code :=
    upper(btrim(garden_country_code));

  v_municipality :=
    nullif(btrim(garden_municipality), '');

  v_locality :=
    nullif(btrim(garden_locality), '');

  v_street_address :=
    nullif(btrim(garden_street_address), '');

  -- --------------------------------------------------------------------------
  -- 5. VALIDAZIONE INPUT OBBLIGATORI
  -- --------------------------------------------------------------------------

  if v_name is null
     or char_length(v_name) not between 1 and 40

     or garden_latitude is null
     or garden_latitude < -90
     or garden_latitude > 90

     or garden_longitude is null
     or garden_longitude < -180
     or garden_longitude > 180

     or garden_elevation_m is null
     or garden_elevation_m < -100
     or garden_elevation_m > 5000

     or v_timezone is null
     or char_length(v_timezone) not between 1 and 100

     or v_country_code is null
     or v_country_code !~ '^[A-Z]{2}$'

     or garden_is_active is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 6. VALIDAZIONE INPUT OPZIONALI
  -- --------------------------------------------------------------------------

  if (v_description is not null
      and char_length(v_description) > 500)

     or (v_municipality is not null
         and char_length(v_municipality) > 100)

     or (v_locality is not null
         and char_length(v_locality) > 100)

     or (v_street_address is not null
         and char_length(v_street_address) > 150)
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. VALIDAZIONE ISO 3166-1 ALPHA-2
  -- --------------------------------------------------------------------------

  if not private.is_valid_country_code(v_country_code)
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. VALIDAZIONE TIMEZONE IANA
  -- --------------------------------------------------------------------------

  if not exists (
    select 1
    from pg_catalog.pg_timezone_names tz
    where tz.name = v_timezone
  )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. PRE-CHECK NOME DUPLICATO
  -- --------------------------------------------------------------------------
  -- Il Garden corrente viene escluso dal controllo: mantenere il proprio
  -- nome è consentito. Viene invece bloccato il nome già utilizzato da
  -- un altro Garden dello stesso Profile.

  if exists (
    select 1
    from public.gardens g
    where g.profile_id = target_profile_id
      and g.name = v_name
      and g.id <> target_garden_id
  )
  then
    return jsonb_build_object(
      'status', 'duplicate_name'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 10. RILEVAMENTO NO-OP
  -- --------------------------------------------------------------------------
  -- Se tutti i valori modificabili risultano già uguali dopo la
  -- normalizzazione, non viene eseguito alcun UPDATE.
  -- row_version e updated_at rimangono invariati.

  if v_current_name = v_name
     and v_current_description is not distinct from v_description
     and v_current_latitude = garden_latitude
     and v_current_longitude = garden_longitude
     and v_current_elevation_m = garden_elevation_m
     and v_current_timezone = v_timezone
     and v_current_country_code = v_country_code
     and v_current_municipality is not distinct from v_municipality
     and v_current_locality is not distinct from v_locality
     and v_current_street_address is not distinct from v_street_address
     and v_current_is_active = garden_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'garden_id', target_garden_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11. UPDATE ATOMICO
  -- --------------------------------------------------------------------------
  -- Viene aggiornata esclusivamente la riga già verificata come appartenente
  -- al Profile autorizzato.
  --
  -- row_version e updated_at sono gestiti dal database.
  -- La nuova versione viene restituita direttamente dal RETURNING.

  begin
    update public.gardens
    set
      name = v_name,
      description = v_description,
      latitude = garden_latitude,
      longitude = garden_longitude,
      elevation_m = garden_elevation_m,
      timezone = v_timezone,
      country_code = v_country_code,
      municipality = v_municipality,
      locality = v_locality,
      street_address = v_street_address,
      is_active = garden_is_active,
      updated_at = clock_timestamp(),
      row_version = v_current_row_version + 1
    where id = target_garden_id
      and profile_id = target_profile_id
    returning
      row_version,
      updated_at
    into
      v_row_version,
      v_updated_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'gardens_profile_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 12. ESITO AUTORITATIVO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'garden_id', target_garden_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- PRIVILEGI RPC
-- ============================================================================
-- La funzione è esposta esclusivamente ai client autenticati.
-- anon e public non devono poterla eseguire direttamente.

revoke all
  on function public.update_garden(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    double precision,
    double precision,
    integer,
    text,
    text,
    text,
    text,
    text,
    boolean
  )
  from public;

revoke all
  on function public.update_garden(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    double precision,
    double precision,
    integer,
    text,
    text,
    text,
    text,
    text,
    boolean
  )
  from anon;

grant execute
  on function public.update_garden(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    double precision,
    double precision,
    integer,
    text,
    text,
    text,
    text,
    text,
    boolean
  )
  to authenticated;
