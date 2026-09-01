-- ============================================================================
-- VARIAZIONE AUTORITATIVA DELLA GEOMETRIA DELL'AIUOLA
-- ============================================================================
-- Sessione S024.
-- Registra una variazione fisica dalla data indicata.
-- Preserva l'identità dell'aiuola e le configurazioni successive.
-- Le rettifiche storiche sono riservate a una RPC separata.

create or replace function public.change_bed_geometry(
  target_profile_id uuid,
  target_bed_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

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

  v_garden_id uuid;
  v_garden_timezone text;
  v_today date;

  v_current_bed_row_version bigint;
  v_current_bed_updated_at timestamptz;

  v_current_geometry_id uuid;
  v_current_width_cm integer;
  v_current_length_cm integer;
  v_current_valid_from date;
  v_current_valid_to date;
  v_current_geometry_row_version bigint;
  v_current_geometry_updated_at timestamptz;

  v_closed_geometry_row_version bigint;
  v_closed_geometry_updated_at timestamptz;

  v_new_geometry_id uuid;
  v_new_geometry_row_version bigint;
  v_new_geometry_created_at timestamptz;

  v_bed_row_version bigint;
  v_bed_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_bed_id is null
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

  if expected_row_version is null
     or expected_row_version < 1
  then
    return jsonb_build_object(
      'status', 'invalid_input'
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
  -- 3. LETTURA AIUOLA E VERIFICA OWNERSHIP
  -- --------------------------------------------------------------------------

  select
    b.garden_id,
    g.timezone,
    b.row_version,
    b.updated_at
  into
    v_garden_id,
    v_garden_timezone,
    v_current_bed_row_version,
    v_current_bed_updated_at
  from public.beds b
  join public.gardens g
    on g.id = b.garden_id
  where b.id = target_bed_id
    and g.profile_id = target_profile_id
  for update of b;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock dell'aiuola.

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
  -- 4. CONTROLLO OTTIMISTICO DELLA VERSIONE DELL'AIUOLA
  -- --------------------------------------------------------------------------

  if v_current_bed_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'bed_id', target_bed_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5. VALIDAZIONE DIMENSIONI E DATA EFFETTIVA
  -- --------------------------------------------------------------------------

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  if geometry_width_cm is null
     or geometry_width_cm <= 0
     or geometry_length_cm is null
     or geometry_length_cm <= 0
     or geometry_valid_from is null
     or not isfinite(geometry_valid_from)
     or geometry_valid_from > v_today
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 6. GEOMETRIA VALIDA ALLA DATA EFFETTIVA
  -- --------------------------------------------------------------------------

  select
    bg.id,
    bg.width_cm,
    bg.length_cm,
    bg.valid_from,
    bg.valid_to,
    bg.row_version,
    bg.updated_at
  into
    v_current_geometry_id,
    v_current_width_cm,
    v_current_length_cm,
    v_current_valid_from,
    v_current_valid_to,
    v_current_geometry_row_version,
    v_current_geometry_updated_at
  from public.bed_geometries bg
  where bg.bed_id = target_bed_id
    and bg.valid_from <= geometry_valid_from
    and (
      bg.valid_to is null
      or geometry_valid_from < bg.valid_to
    )
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della geometria.

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
  -- 7. DIMENSIONI INVARIATE
  -- --------------------------------------------------------------------------

  if v_current_width_cm = geometry_width_cm
     and v_current_length_cm = geometry_length_cm
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,
      'geometry_id', v_current_geometry_id,
      'geometry_row_version', v_current_geometry_row_version,
      'geometry_updated_at', v_current_geometry_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. MODIFICA SUL CONFINE INIZIALE: RETTIFICA NECESSARIA
  -- --------------------------------------------------------------------------
  -- Le dimensioni sono diverse, ma la data coincide con l'inizio
  -- della configurazione registrata: non sovrascriverla implicitamente.

  if geometry_valid_from = v_current_valid_from
  then
    return jsonb_build_object(
      'status', 'correction_required',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,
      'geometry_id', v_current_geometry_id,
      'geometry_row_version', v_current_geometry_row_version,
      'geometry_updated_at', v_current_geometry_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. DIVISIONE DELL'INTERVALLO E NUOVA GEOMETRIA
  -- --------------------------------------------------------------------------
  -- La data è strettamente interna all'intervallo selezionato.
  -- Prima accorcia l'intervallo precedente, poi inserisce quello nuovo.
  -- Non è necessario differire il vincolo di esclusione.

  update public.bed_geometries
  set valid_to = geometry_valid_from
  where id = v_current_geometry_id
    and bed_id = target_bed_id
    and row_version = v_current_geometry_row_version
  returning
    row_version,
    updated_at
  into
    v_closed_geometry_row_version,
    v_closed_geometry_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while closing bed geometry';
  end if;

  insert into public.bed_geometries (
    bed_id,
    width_cm,
    length_cm,
    valid_from,
    valid_to
  )
  values (
    target_bed_id,
    geometry_width_cm,
    geometry_length_cm,
    geometry_valid_from,
    v_current_valid_to
  )
  returning
    id,
    row_version,
    created_at
  into
    v_new_geometry_id,
    v_new_geometry_row_version,
    v_new_geometry_created_at;

  -- --------------------------------------------------------------------------
  -- 10. INCREMENTO DELLA VERSIONE AGGREGATA DELL'AIUOLA
  -- --------------------------------------------------------------------------
  -- L'assegnazione invariata attiva il trigger metadata.
  -- Il trigger incrementa beds.row_version una sola volta.

  update public.beds
  set row_version = row_version
  where id = target_bed_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_bed_row_version,
    v_bed_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while updating bed geometry version';
  end if;

  -- --------------------------------------------------------------------------
  -- 11. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'changed',
    'bed_id', target_bed_id,
    'garden_id', v_garden_id,
    'row_version', v_bed_row_version,
    'updated_at', v_bed_updated_at,

    'geometry_id', v_new_geometry_id,
    'width_cm', geometry_width_cm,
    'length_cm', geometry_length_cm,
    'valid_from', geometry_valid_from,
    'valid_to', v_current_valid_to,
    'geometry_row_version', v_new_geometry_row_version,
    'geometry_created_at', v_new_geometry_created_at,

    'previous_geometry_id', v_current_geometry_id,
    'previous_geometry_valid_to', geometry_valid_from,
    'previous_geometry_row_version', v_closed_geometry_row_version,
    'previous_geometry_updated_at', v_closed_geometry_updated_at
  );
end;
$$;

-- ============================================================================
-- 12. PRIVILEGI CHANGE_BED_GEOMETRY
-- ============================================================================

revoke all
  on function public.change_bed_geometry(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date
  )
  from public, anon, authenticated;

grant execute
  on function public.change_bed_geometry(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date
  )
  to authenticated;
