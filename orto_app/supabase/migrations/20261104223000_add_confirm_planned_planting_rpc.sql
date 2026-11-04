
-- ============================================================================
-- ORTO SMART - S039
-- RPC CONFIRM PLANNED PLANTING
-- ============================================================================

create or replace function public.confirm_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_lot public.planned_plantings%rowtype;
  v_initial_garden_id uuid;
  v_initial_season_id uuid;

  v_garden_active boolean;
  v_bed_active boolean;
  v_season_start date;
  v_season_end date;

  v_period daterange;
  v_covered_period datemultirange;
  v_new_version bigint;
begin
  -- 1. Identita' e autorizzazione del proprietario.
  if auth.uid() is null
     or target_profile_id is null
     or target_planned_planting_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- 2. Write Authority.
  if target_client_id is null
     or target_session_id is null
     or lock_token is null
     or not private.lock_profile_write_authority(
       target_profile_id,
       target_client_id,
       target_session_id,
       lock_token
     )
  then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 3. Lettura preliminare del lotto.
  select *
    into v_lot
  from public.planned_plantings
  where id = target_planned_planting_id
    and profile_id = target_profile_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  v_initial_garden_id := v_lot.garden_id;
  v_initial_season_id := v_lot.season_id;

  if v_lot.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  -- 4. Blocco dell'orto.
  select g.is_active
    into v_garden_active
  from public.gardens g
  where g.id = v_initial_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_garden_active then
    return jsonb_build_object('status', 'inactive_garden');
  end if;

  -- 5. Blocco della stagione.
  select s.start_date, s.end_date
    into v_season_start, v_season_end
  from public.seasons s
  where s.id = v_initial_season_id
    and s.garden_id = v_initial_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 6. Blocco dell'aiuola.
  select b.is_active
    into v_bed_active
  from public.beds b
  where b.id = v_lot.bed_id
    and b.garden_id = v_initial_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_bed_active then
    return jsonb_build_object('status', 'inactive_bed');
  end if;

  -- 7. Blocco autoritativo del lotto.
  select *
    into v_lot
  from public.planned_plantings
  where id = target_planned_planting_id
    and profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if v_lot.garden_id is distinct from v_initial_garden_id
     or v_lot.season_id is distinct from v_initial_season_id
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  if v_lot.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  if v_lot.status <> 'draft' then
    return jsonb_build_object('status', 'blocked_by_lifecycle');
  end if;

  -- 8. Intervallo di occupazione.
  -- planned_end_date e' inclusiva.
  -- NULL significa occupazione senza fine definita.
  v_period := daterange(
    v_lot.planned_start_date,
    case
      when v_lot.planned_end_date is null then null
      else v_lot.planned_end_date + 1
    end,
    '[)'
  );

  -- 9. Copertura continua delle geometrie dell'aiuola.
  select range_agg(
    daterange(bg.valid_from, bg.valid_to, '[)')
  )
    into v_covered_period
  from public.bed_geometries bg
  where bg.bed_id = v_lot.bed_id
    and daterange(bg.valid_from, bg.valid_to, '[)') && v_period;

  if v_covered_period is null
     or not (v_covered_period @> v_period)
  then
    return jsonb_build_object('status', 'missing_bed_geometry');
  end if;

  -- 10. Compatibilita' dimensionale con tutte le geometrie.
  if exists (
    select 1
    from public.bed_geometries bg
    where bg.bed_id = v_lot.bed_id
      and daterange(bg.valid_from, bg.valid_to, '[)') && v_period
      and (
        v_lot.start_position_cm::bigint
          + v_lot.length_cm::bigint > bg.length_cm::bigint
        or v_lot.occupied_width_cm > bg.width_cm
      )
  ) then
    return jsonb_build_object(
      'status', 'outside_bed_geometry',
      'bed_id', v_lot.bed_id
    );
  end if;

  -- 11. Conflitti con coltivazioni reali.
  -- plantings.end_date e' esclusiva.
  if exists (
    select 1
    from public.plantings p
    where p.bed_id = v_lot.bed_id
      and daterange(
        p.start_date,
        p.end_date,
        '[)'
      ) && v_period
      and p.start_position_cm::bigint
        < v_lot.start_position_cm::bigint
          + v_lot.length_cm::bigint
      and v_lot.start_position_cm::bigint
        < p.start_position_cm::bigint
          + p.length_cm::bigint
  ) then
    return jsonb_build_object(
      'status', 'overlap',
      'bed_id', v_lot.bed_id
    );
  end if;

  -- 12. Conflitti con altre pianificazioni confermate.
  if exists (
    select 1
    from public.planned_plantings pp
    where pp.bed_id = v_lot.bed_id
      and pp.id <> v_lot.id
      and pp.status = 'confirmed'
      and daterange(
        pp.planned_start_date,
        case
          when pp.planned_end_date is null then null
          else pp.planned_end_date + 1
        end,
        '[)'
      ) && v_period
      and pp.start_position_cm::bigint
        < v_lot.start_position_cm::bigint
          + v_lot.length_cm::bigint
      and v_lot.start_position_cm::bigint
        < pp.start_position_cm::bigint
          + pp.length_cm::bigint
  ) then
    return jsonb_build_object(
      'status', 'overlap',
      'bed_id', v_lot.bed_id
    );
  end if;

  -- 13. Ultima verifica della Write Authority.
  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 14. Conferma atomica.
  update public.planned_plantings
  set status = 'confirmed',
      updated_at = now(),
      row_version = row_version + 1
  where id = target_planned_planting_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
    and status = 'draft'
  returning row_version into v_new_version;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'confirmed',
    'planned_planting_id', target_planned_planting_id,
    'row_version', v_new_version
  );
end;
$$;

revoke all on function public.confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text
) from public, anon;

grant execute on function public.confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text
) to authenticated;
