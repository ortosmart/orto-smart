-- ============================================================================
-- HARDEN GARDENS WRITE PATH
-- ============================================================================
-- Rafforza la struttura di public.gardens secondo il contratto V1.
-- Le scritture applicative verranno successivamente esposte esclusivamente
-- tramite RPC autoritative protette dal Profile Write Authority.

-- ============================================================================
-- NUOVI DATI GEOGRAFICI
-- ============================================================================

alter table public.gardens
  add column elevation_m integer not null,
  add column country_code text not null,
  add column municipality text,
  add column locality text,
  add column street_address text;

-- ============================================================================
-- NAME
-- ============================================================================
-- Il Write Path deve persistere il nome già normalizzato:
-- trim esterno, un solo spazio tra le parole, tutto minuscolo salvo
-- la prima lettera dell'intero nome.

alter table public.gardens
  drop constraint gardens_name_not_blank_check;

alter table public.gardens
  add constraint gardens_name_normalized_check
  check (
    char_length(name) between 1 and 40
    and name =
      upper(
        left(
          lower(
            regexp_replace(
              btrim(name),
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
            btrim(name),
            '[[:space:]]+',
            ' ',
            'g'
          )
        ),
        2
      )
  );

-- gardens_profile_name_unique viene mantenuto:
-- poiché name è sempre memorizzato già normalizzato,
-- UNIQUE(profile_id, name) garantisce l'unicità del nome nel Profile.

-- ============================================================================
-- DESCRIPTION
-- ============================================================================

alter table public.gardens
  add constraint gardens_description_normalized_check
  check (
    description is null
    or (
      description = btrim(description)
      and char_length(description) between 1 and 500
    )
  );

-- ============================================================================
-- ELEVATION
-- ============================================================================

alter table public.gardens
  add constraint gardens_elevation_m_check
  check (
    elevation_m between -100 and 5000
  );

-- ============================================================================
-- TIMEZONE
-- ============================================================================

alter table public.gardens
  drop constraint gardens_timezone_not_blank_check;

alter table public.gardens
  add constraint gardens_timezone_normalized_check
  check (
    timezone = btrim(timezone)
    and char_length(timezone) between 1 and 100
  );

-- La validità IANA effettiva verrà verificata server-side nel Write Path.

-- ============================================================================
-- COUNTRY CODE
-- ============================================================================

alter table public.gardens
  add constraint gardens_country_code_format_check
  check (
    country_code ~ '^[A-Z]{2}$'
  );

-- L'appartenenza all'elenco ISO 3166-1 alpha-2 ufficialmente assegnato
-- verrà verificata tramite helper privato nel Write Path.

-- ============================================================================
-- LOCALIZZAZIONE LEGGIBILE
-- ============================================================================

alter table public.gardens
  add constraint gardens_municipality_normalized_check
  check (
    municipality is null
    or (
      municipality = btrim(municipality)
      and char_length(municipality) between 1 and 100
    )
  );

alter table public.gardens
  add constraint gardens_locality_normalized_check
  check (
    locality is null
    or (
      locality = btrim(locality)
      and char_length(locality) between 1 and 100
    )
  );

alter table public.gardens
  add constraint gardens_street_address_normalized_check
  check (
    street_address is null
    or (
      street_address = btrim(street_address)
      and char_length(street_address) between 1 and 150
    )
  );

-- ============================================================================
-- ISO 3166-1 ALPHA-2
-- ============================================================================
-- Valida esclusivamente i codici alpha-2 ufficialmente assegnati.
-- Baseline verificata il 2026-08-23.
-- I codici user-assigned (AA, QM-QZ, XA-XZ, ZZ) non sono ammessi.
-- Eventuali aggiornamenti futuri devono avvenire tramite migration versionata.

create or replace function private.is_valid_country_code(
  country_code text
)
returns boolean
language sql
immutable
security invoker
set search_path = ''
as $$
  select country_code = any (
    array[
      'AD','AE','AF','AG','AI','AL','AM','AO','AQ','AR','AS','AT','AU','AW','AX','AZ',
      'BA','BB','BD','BE','BF','BG','BH','BI','BJ','BL','BM','BN','BO','BQ','BR','BS',
      'BT','BV','BW','BY','BZ',
      'CA','CC','CD','CF','CG','CH','CI','CK','CL','CM','CN','CO','CR','CU','CV','CW',
      'CX','CY','CZ',
      'DE','DJ','DK','DM','DO','DZ',
      'EC','EE','EG','EH','ER','ES','ET',
      'FI','FJ','FK','FM','FO','FR',
      'GA','GB','GD','GE','GF','GG','GH','GI','GL','GM','GN','GP','GQ','GR','GS','GT',
      'GU','GW','GY',
      'HK','HM','HN','HR','HT','HU',
      'ID','IE','IL','IM','IN','IO','IQ','IR','IS','IT',
      'JE','JM','JO','JP',
      'KE','KG','KH','KI','KM','KN','KP','KR','KW','KY','KZ',
      'LA','LB','LC','LI','LK','LR','LS','LT','LU','LV','LY',
      'MA','MC','MD','ME','MF','MG','MH','MK','ML','MM','MN','MO','MP','MQ','MR','MS',
      'MT','MU','MV','MW','MX','MY','MZ',
      'NA','NC','NE','NF','NG','NI','NL','NO','NP','NR','NU','NZ',
      'OM',
      'PA','PE','PF','PG','PH','PK','PL','PM','PN','PR','PS','PT','PW','PY',
      'QA',
      'RE','RO','RS','RU','RW',
      'SA','SB','SC','SD','SE','SG','SH','SI','SJ','SK','SL','SM','SN','SO','SR','SS',
      'ST','SV','SX','SY','SZ',
      'TC','TD','TF','TG','TH','TJ','TK','TL','TM','TN','TO','TR','TT','TV','TW','TZ',
      'UA','UG','UM','US','UY','UZ',
      'VA','VC','VE','VG','VI','VN','VU',
      'WF','WS',
      'YE','YT',
      'ZA','ZM','ZW'
    ]::text[]
  );
$$;

revoke all
  on function private.is_valid_country_code(text)
  from public;

revoke all
  on function private.is_valid_country_code(text)
  from authenticated;

revoke all
  on function private.is_valid_country_code(text)
  from anon;

-- ============================================================================
-- GARDENS WRITE-PATH HARDENING
-- ============================================================================
-- Le letture dirette restano consentite ai membri attivi tramite RLS.
-- Le scritture applicative non devono invece poter raggiungere direttamente
-- public.gardens: saranno esposte esclusivamente tramite RPC autoritative.

drop policy if exists gardens_insert_for_owner
  on public.gardens;

drop policy if exists gardens_update_for_owner
  on public.gardens;

-- authenticated mantiene esclusivamente il privilegio necessario alla lettura.
revoke insert, update, delete
  on table public.gardens
  from authenticated;

grant select
  on table public.gardens
  to authenticated;

-- ============================================================================
-- CREATE GARDEN
-- ============================================================================
-- Crea un Garden esclusivamente tramite Write Path autoritativo.
-- L'identità applicativa deriva sempre da auth.uid().
-- Solo l'owner attivo del Profile con Profile Write Authority valida
-- può completare la creazione.

create or replace function public.create_garden(
  target_profile_id uuid,
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
  garden_street_address text
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

  v_garden_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;

  v_constraint_name text;
begin
  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
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
  -- 3. NORMALIZZAZIONE
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
  -- 4. VALIDAZIONE INPUT OBBLIGATORI
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
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5. VALIDAZIONE INPUT OPZIONALI
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
  -- 6. VALIDAZIONE ISO 3166-1 ALPHA-2
  -- --------------------------------------------------------------------------

  if not private.is_valid_country_code(v_country_code)
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. VALIDAZIONE TIMEZONE IANA
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
  -- 8. PRE-CHECK NOME DUPLICATO
  -- --------------------------------------------------------------------------

  if exists (
    select 1
    from public.gardens g
    where g.profile_id = target_profile_id
      and g.name = v_name
  )
  then
    return jsonb_build_object(
      'status', 'duplicate_name'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. INSERT ATOMICO
  -- --------------------------------------------------------------------------

  begin
    insert into public.gardens (
      profile_id,
      name,
      description,
      latitude,
      longitude,
      elevation_m,
      timezone,
      country_code,
      municipality,
      locality,
      street_address
    )
    values (
      target_profile_id,
      v_name,
      v_description,
      garden_latitude,
      garden_longitude,
      garden_elevation_m,
      v_timezone,
      v_country_code,
      v_municipality,
      v_locality,
      v_street_address
    )
    returning
      id,
      row_version,
      created_at
    into
      v_garden_id,
      v_row_version,
      v_created_at;

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

      -- Non mascherare altre violazioni UNIQUE inattese.
      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 10. ESITO AUTORITATIVO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',
    'garden_id', v_garden_id,
    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$$;

revoke all
  on function public.create_garden(
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
    text
  )
  from public;

revoke all
  on function public.create_garden(
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
    text
  )
  from anon;

grant execute
  on function public.create_garden(
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
    text
  )
  to authenticated;
