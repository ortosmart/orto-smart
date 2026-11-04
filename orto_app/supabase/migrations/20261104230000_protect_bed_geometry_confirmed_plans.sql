CREATE OR REPLACE FUNCTION public.change_bed_geometry(target_profile_id uuid, target_bed_id uuid, expected_row_version bigint, target_client_id uuid, target_session_id uuid, lock_token text, geometry_width_cm integer, geometry_length_cm integer, geometry_valid_from date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
  -- 1. IDENTIT├Ç E AUTORIZZAZIONE OWNER
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
  -- 9. COMPATIBILITA CON I PLANTING NEL PERIODO
  -- --------------------------------------------------------------------------
  -- La nuova geometria deve essere compatibile con tutti i Planting
  -- il cui intervallo di occupazione [start_date, end_date) si sovrappone
  -- all'intervallo della nuova geometria
  -- [geometry_valid_from, v_current_valid_to).
  --
  -- Il controllo comprende anche Planting oggi conclusi: se erano presenti
  -- nel periodo storico interessato, la nuova geometria non puo rendere
  -- fisicamente impossibile la loro occupazione registrata.

  if exists (
    select 1
    from public.plantings p
    where p.bed_id = target_bed_id
      and (
        v_current_valid_to is null
        or p.start_date < v_current_valid_to
      )
      and (
        p.end_date is null
        or geometry_valid_from < p.end_date
      )
      and (
        p.start_position_cm + p.length_cm > geometry_length_cm
        or p.occupied_width_cm > geometry_width_cm
      )
  )
  then
    return jsonb_build_object(
      'status', 'blocked_by_plantings',
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
  -- 9B. COMPATIBILITA CON LE PIANIFICAZIONI CONFERMATE
  -- --------------------------------------------------------------------------
  -- Solo i lotti confirmed riservano spazio.
  -- Le date delle pianificazioni sono inclusive.
  -- Il termine di validita della geometria e esclusivo.

  if exists (
    select 1
    from public.planned_plantings pp
    where pp.bed_id = target_bed_id
      and pp.status = 'confirmed'
      and (
        v_current_valid_to is null
        or pp.planned_start_date < v_current_valid_to
      )
      and (
        pp.planned_end_date is null
        or geometry_valid_from <= pp.planned_end_date
      )
      and (
        pp.start_position_cm + pp.length_cm > geometry_length_cm
        or pp.occupied_width_cm > geometry_width_cm
      )
  )
  then
    return jsonb_build_object(
      'status', 'blocked_by_confirmed_plans',
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
  -- 10. DIVISIONE DELL'INTERVALLO E NUOVA GEOMETRIA
  -- --------------------------------------------------------------------------
  -- La data ├¿ strettamente interna all'intervallo selezionato.
  -- Prima accorcia l'intervallo precedente, poi inserisce quello nuovo.
  -- Non ├¿ necessario differire il vincolo di esclusione.

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
  -- 11. INCREMENTO DELLA VERSIONE AGGREGATA DELL'AIUOLA
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
  -- 12. RISULTATO
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
$function$
