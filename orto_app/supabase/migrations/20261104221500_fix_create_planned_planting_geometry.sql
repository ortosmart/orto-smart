
-- ============================================================================
-- ORTO SMART - S039
-- RPC PIANIFICAZIONE STAGIONALE V1
-- ============================================================================

create or replace function public.create_planned_planting(
  target_profile_id uuid,
  target_garden_id uuid,
  target_season_id uuid,
  target_bed_id uuid,
  target_crop_id uuid,
  target_cultivar_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  planting_start_method text,
  planting_start_date date,
  planting_end_date date,
  planting_start_position_cm integer,
  planting_length_cm integer,
  planting_occupied_width_cm integer,
  planting_plant_spacing_cm integer,
  planting_row_spacing_cm integer,
  planting_rows_count integer,
  planting_plants_count integer,
  planting_seed_quantity_g numeric,
  planting_notes text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan_id uuid;
  v_planting_id uuid;
  v_garden_active boolean;
  v_season_start date;
  v_season_end date;
  v_bed_active boolean;
  v_crop_active boolean;
  v_cultivar_active boolean;
  v_notes text;
  v_period daterange;
  v_covered_period datemultirange;
begin
  -- 1. Identita' e proprietario.
  if auth.uid() is null
     or target_profile_id is null
     or target_garden_id is null
     or target_season_id is null
     or target_bed_id is null
     or target_crop_id is null
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

  -- 3. Orto.
  select g.is_active
    into v_garden_active
  from public.gardens g
  where g.id = target_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_garden_active then
    return jsonb_build_object('status', 'blocked_by_inactive_garden');
  end if;

  -- 4. Stagione.
  select s.start_date, s.end_date
    into v_season_start, v_season_end
  from public.seasons s
  where s.id = target_season_id
    and s.garden_id = target_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 5. Validazione dei dati di pianificazione.
  v_notes := nullif(btrim(planting_notes), '');

  if planting_start_method is null
     or planting_start_method not in (
       'purchased_seedlings',
       'nursery_then_transplant',
       'direct_rows',
       'direct_broadcast'
     )
     or planting_start_date is null
     or not isfinite(planting_start_date)
     or planting_start_date < v_season_start
     or (
       v_season_end is not null
       and planting_start_date > v_season_end
     )
     or (
       planting_end_date is not null
       and (
         not isfinite(planting_end_date)
         or planting_end_date < planting_start_date
         or (
           v_season_end is not null
           and planting_end_date > v_season_end
         )
       )
     )
     or planting_start_position_cm is null
     or planting_start_position_cm < 0
     or planting_length_cm is null
     or planting_length_cm <= 0
     or planting_occupied_width_cm is null
     or planting_occupied_width_cm <= 0
     or (
       planting_plant_spacing_cm is not null
       and planting_plant_spacing_cm <= 0
     )
     or (
       planting_row_spacing_cm is not null
       and planting_row_spacing_cm <= 0
     )
     or (
       planting_rows_count is not null
       and planting_rows_count <= 0
     )
     or (
       planting_plants_count is not null
       and planting_plants_count <= 0
     )
     or (
       planting_seed_quantity_g is not null
       and planting_seed_quantity_g <= 0
     )
     or (
       v_notes is not null
       and char_length(v_notes) > 1000
     )
  then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  -- 6. Aiuola.
  select b.is_active
    into v_bed_active
  from public.beds b
  where b.id = target_bed_id
    and b.garden_id = target_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_bed_active then
    return jsonb_build_object('status', 'blocked_by_inactive_bed');
  end if;

  -- 7. Coltura.
  select c.is_active
    into v_crop_active
  from public.crops c
  where c.id = target_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_crop_active then
    return jsonb_build_object('status', 'blocked_by_inactive_crop');
  end if;

  -- 8. Varieta' facoltativa.
  if target_cultivar_id is not null then
    select cv.is_active
      into v_cultivar_active
    from public.crop_cultivars cv
    where cv.id = target_cultivar_id
      and cv.crop_id = target_crop_id
    for update;

    if not found then
      return jsonb_build_object('status', 'not_found');
    end if;

    if not private.lock_profile_write_authority(
      target_profile_id, target_client_id, target_session_id, lock_token
    ) then
      return jsonb_build_object('status', 'write_forbidden');
    end if;

    if not v_cultivar_active then
      return jsonb_build_object('status', 'blocked_by_inactive_cultivar');
    end if;
  end if;

  -- 9. Verifica della geometria nel periodo pianificato.
  -- La data finale pianificata è inclusiva.
  -- La data valid_to delle geometrie è esclusiva.
  v_period := daterange(
    planting_start_date,
    case
      when planting_end_date is null then null
      else planting_end_date + 1
    end,
    '[)'
  );

  -- Verifica che le geometrie coprano senza interruzioni
  -- l'intero periodo pianificato.
  select range_agg(
    daterange(bg.valid_from, bg.valid_to, '[)')
  )
  into v_covered_period
  from public.bed_geometries bg
  where bg.bed_id = target_bed_id
    and daterange(bg.valid_from, bg.valid_to, '[)') && v_period;

  if v_covered_period is null
     or not (v_covered_period @> v_period) then
    return jsonb_build_object(
      'status', 'missing_bed_geometry'
    );
  end if;

  -- Verifica che la coltivazione rientri nelle dimensioni
  -- di tutte le geometrie interessate dal periodo.
  if exists (
    select 1
    from public.bed_geometries bg
    where bg.bed_id = target_bed_id
      and daterange(bg.valid_from, bg.valid_to, '[)') && v_period
      and (
        planting_start_position_cm::bigint
          + planting_length_cm::bigint > bg.length_cm::bigint
        or planting_occupied_width_cm > bg.width_cm
      )
  ) then
    return jsonb_build_object(
      'status', 'outside_bed_geometry',
      'bed_id', target_bed_id
    );
  end if;

  -- 10. Rivalidazione finale del lock.
  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 11. Piano stagionale: recupero o creazione atomica.
  insert into public.season_plans (
    profile_id, garden_id, season_id
  )
  values (
    target_profile_id, target_garden_id, target_season_id
  )
  on conflict (season_id)
  do nothing;

  select sp.id
    into v_plan_id
  from public.season_plans sp
  where sp.season_id = target_season_id
    and sp.garden_id = target_garden_id
    and sp.profile_id = target_profile_id
  for update;

    if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  -- Rivalidazione della Write Authority dopo il lock del piano.
  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 12. Creazione del lotto in bozza.
  insert into public.planned_plantings (
    season_plan_id,
    profile_id,
    garden_id,
    season_id,
    bed_id,
    crop_id,
    cultivar_id,
    start_method,
    planned_start_date,
    planned_end_date,
    start_position_cm,
    length_cm,
    occupied_width_cm,
    plant_spacing_cm,
    row_spacing_cm,
    rows_count,
    plants_count,
    seed_quantity_g,
    status,
    notes
  )
  values (
    v_plan_id,
    target_profile_id,
    target_garden_id,
    target_season_id,
    target_bed_id,
    target_crop_id,
    target_cultivar_id,
    planting_start_method,
    planting_start_date,
    planting_end_date,
    planting_start_position_cm,
    planting_length_cm,
    planting_occupied_width_cm,
    planting_plant_spacing_cm,
    planting_row_spacing_cm,
    planting_rows_count,
    planting_plants_count,
    planting_seed_quantity_g,
    'draft',
    v_notes
  )
  returning id into v_planting_id;

  return jsonb_build_object(
    'status', 'created',
    'season_plan_id', v_plan_id,
    'planned_planting_id', v_planting_id,
    'row_version', 1
  );
end;
$$;

revoke all on function public.create_planned_planting(
  uuid, uuid, uuid, uuid, uuid, uuid,
  uuid, uuid, text, text, date, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) from public, anon;

grant execute on function public.create_planned_planting(
  uuid, uuid, uuid, uuid, uuid, uuid,
  uuid, uuid, text, text, date, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) to authenticated;
