-- ============================================================================
-- WRITE PATH AUTORITATIVO BEDS
-- ============================================================================
-- Sessione S024.
-- Creazione atomica dell'aiuola e della geometria iniziale.
-- Nessuna importazione dei dati legacy di prova.

-- ============================================================================
-- 1. CREATE BED
-- ============================================================================

create or replace function public.create_bed(
  target_profile_id uuid,
  target_garden_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  bed_number integer,
  bed_name text,
  bed_notes text,

  geometry_width_cm integer,
  geometry_length_cm integer,
  geometry_valid_from date
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_timezone text;
  v_today date;
  v_valid_from date;

  v_name text;
  v_notes text;

  v_bed_id uuid;
  v_bed_row_version bigint;
  v_bed_created_at timestamptz;

  v_geometry_id uuid;
  v_geometry_row_version bigint;
  v_geometry_created_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 1.1 IDENTITÀ E AUTORIZZAZIONE OWNER
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
  -- 1.2 PROFILE WRITE AUTHORITY
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
  -- 1.3 GARDEN AUTORIZZATO
  -- --------------------------------------------------------------------------

  select g.timezone
  into v_garden_timezone
  from public.gardens g
  where g.id = target_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Il Garden lock potrebbe aver richiesto un'attesa.
  -- Rivalida l'autorità prima di procedere.

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
  -- 1.4 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    nullif(
      regexp_replace(
        btrim(bed_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_notes :=
    nullif(btrim(bed_notes), '');

  -- Data civile del Garden, calcolata dopo le eventuali attese sui lock.
  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  v_valid_from :=
    coalesce(geometry_valid_from, v_today);

  -- --------------------------------------------------------------------------
  -- 1.5 VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if bed_number is null
     or bed_number <= 0
     or geometry_width_cm is null
     or geometry_width_cm <= 0
     or geometry_length_cm is null
     or geometry_length_cm <= 0
     or not isfinite(v_valid_from)
     or v_valid_from > v_today
     or (
       v_name is not null
       and char_length(v_name) > 80
     )
     or (
       v_notes is not null
       and char_length(v_notes) > 1000
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 1.6 CREAZIONE ATOMICA DI AIUOLA E GEOMETRIA INIZIALE
  -- --------------------------------------------------------------------------

  begin
    insert into public.beds (
      garden_id,
      number,
      name,
      notes,
      is_active
    )
    values (
      target_garden_id,
      bed_number,
      v_name,
      v_notes,
      true
    )
    returning
      id,
      row_version,
      created_at
    into
      v_bed_id,
      v_bed_row_version,
      v_bed_created_at;

    insert into public.bed_geometries (
      bed_id,
      width_cm,
      length_cm,
      valid_from,
      valid_to
    )
    values (
      v_bed_id,
      geometry_width_cm,
      geometry_length_cm,
      v_valid_from,
      null
    )
    returning
      id,
      row_version,
      created_at
    into
      v_geometry_id,
      v_geometry_row_version,
      v_geometry_created_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'beds_garden_number_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_number'
        );
      end if;

      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 1.7 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',
    'bed_id', v_bed_id,
    'garden_id', target_garden_id,
    'number', bed_number,
    'is_active', true,
    'row_version', v_bed_row_version,
    'created_at', v_bed_created_at,
    'geometry_id', v_geometry_id,
    'width_cm', geometry_width_cm,
    'length_cm', geometry_length_cm,
    'valid_from', v_valid_from,
    'valid_to', null,
    'geometry_row_version', v_geometry_row_version,
    'geometry_created_at', v_geometry_created_at
  );
end;
$$;

-- ============================================================================
-- 1.8 PRIVILEGI CREATE_BED
-- ============================================================================

revoke all
  on function public.create_bed(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    integer,
    text,
    text,
    integer,
    integer,
    date
  )
  from public, anon, authenticated;

grant execute
  on function public.create_bed(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    integer,
    text,
    text,
    integer,
    integer,
    date
  )
  to authenticated;
