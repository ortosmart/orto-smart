
-- ============================================================================
-- ORTO SMART - S039
-- RPC UPDATE PLANNED PLANTING
-- ============================================================================

create or replace function public.update_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  planting_bed_id uuid,
  planting_crop_id uuid,
  planting_cultivar_id uuid,
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
  v_lot public.planned_plantings%rowtype;
  v_initial_garden_id uuid;
  v_initial_season_id uuid;
  v_initial_bed_id uuid;
  v_garden_active boolean;
  v_bed_active boolean;
  v_crop_active boolean;
  v_cultivar_active boolean;
  v_season_start date;
  v_season_end date;
  v_notes text;
  v_period daterange;
  v_covered_period datemultirange;
  v_new_version bigint;
  v_bed_lock_id uuid;

begin
  -- 1. Identita' e proprietario.
  if auth.uid() is null
     or target_profile_id is null
     or target_planned_planting_id is null
     or expected_row_version is null
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

  -- 3. Individuazione preliminare del lotto.
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
  v_initial_bed_id := v_lot.bed_id;

  -- Controllo preliminare della versione.
  -- La verifica autoritativa resta quella dopo FOR UPDATE.
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
  where g.id = v_lot.garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_garden_active then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_garden'
    );
  end if;

  -- 5. Stagione e limiti temporali.
  select s.start_date, s.end_date
    into v_season_start, v_season_end
  from public.seasons s
  where s.id = v_lot.season_id
    and s.garden_id = v_lot.garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 6. Validazione dei nuovi dati.
  v_notes := nullif(btrim(planting_notes), '');

  if planting_bed_id is null
     or planting_crop_id is null
     or planting_start_method is null
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

  -- 7. Blocco delle aiuole coinvolte.
  -- L'ordine deterministico per UUID riduce il rischio di deadlock.
  -- Il lotto puo' essere spostato tra aiuole dello stesso orto.
  for v_bed_lock_id in
  select distinct bed_id
  from (
    values (v_lot.bed_id), (planting_bed_id)
  ) as involved_beds(bed_id)
  where bed_id is not null
  order by bed_id
loop
  perform 1
  from public.beds b
  where b.id = v_bed_lock_id
    and b.garden_id = v_lot.garden_id
  for update;
end loop;

  -- Rivalida la Write Authority dopo l'attesa sui lock.
  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- Verifica autoritativa dell'aiuola di destinazione.
  select b.is_active
    into v_bed_active
  from public.beds b
  where b.id = planting_bed_id
    and b.garden_id = v_lot.garden_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not v_bed_active then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_bed'
    );
  end if;

  -- 8. Coltura.
  select c.is_active
    into v_crop_active
  from public.crops c
  where c.id = planting_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if not v_crop_active then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_crop'
    );
  end if;

  -- 9. Varieta' facoltativa.
  if planting_cultivar_id is not null then
    select cv.is_active
      into v_cultivar_active
    from public.crop_cultivars cv
    where cv.id = planting_cultivar_id
      and cv.crop_id = planting_crop_id
    for update;

    if not found then
      return jsonb_build_object('status', 'not_found');
    end if;

    if not private.lock_profile_write_authority(
      target_profile_id, target_client_id,
      target_session_id, lock_token
    ) then
      return jsonb_build_object(
        'status', 'write_forbidden'
      );
    end if;

    if not v_cultivar_active then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_cultivar'
      );
    end if;
  end if;

  -- 10. Copertura temporale delle geometrie.
  -- Il periodo e' chiuso a sinistra e aperto a destra.
  -- Una data finale uguale a quella iniziale viene
  -- interpretata come occupazione del solo giorno iniziale.
  v_period := daterange(
    planting_start_date,
    case
      when planting_end_date is null then null
      else planting_end_date + 1
    end,
    '[)'
  );

  select range_agg(
    daterange(bg.valid_from, bg.valid_to, '[)')
  )
    into v_covered_period
  from public.bed_geometries bg
  where bg.bed_id = planting_bed_id
    and daterange(
      bg.valid_from, bg.valid_to, '[)'
    ) && v_period;

  if v_covered_period is null
     or not (v_covered_period @> v_period)
  then
    return jsonb_build_object(
      'status', 'missing_bed_geometry'
    );
  end if;

  -- 11. Dimensioni per tutte le geometrie interessate.
  if exists (
    select 1
    from public.bed_geometries bg
    where bg.bed_id = planting_bed_id
      and daterange(
        bg.valid_from, bg.valid_to, '[)'
      ) && v_period
      and (
        planting_start_position_cm::bigint
          + planting_length_cm::bigint
            > bg.length_cm::bigint
        or planting_occupied_width_cm > bg.width_cm
      )
  ) then
    return jsonb_build_object(
      'status', 'outside_bed_geometry',
      'bed_id', planting_bed_id
    );
  end if;

  -- 12. Rivalidazione prima del blocco finale.
  if not private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 13. Blocco del lotto e nuova lettura autoritativa.
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
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- Verifica della coerenza con la lettura iniziale.
  if v_lot.garden_id is distinct from v_initial_garden_id
   or v_lot.season_id is distinct from v_initial_season_id
   or v_lot.bed_id is distinct from v_initial_bed_id
then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  if v_lot.status not in ('draft', 'confirmed') then
    return jsonb_build_object(
      'status', 'blocked_by_lifecycle'
    );
  end if;

  if v_lot.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;


  -- 14. Protezione dell'occupazione per i lotti confermati.
  -- I draft non riservano spazio e possono sovrapporsi.
  -- planned_end_date e' inclusiva; plantings.end_date e' esclusiva.
  if v_lot.status = 'confirmed' then

    v_period := daterange(
      planting_start_date,
      case
        when planting_end_date is null then null
        else planting_end_date + 1
      end,
      '[)'
    );

    -- Conflitti con coltivazioni reali.
    if exists (
      select 1
      from public.plantings p
      where p.bed_id = planting_bed_id
        and daterange(p.start_date, p.end_date, '[)') && v_period
        and p.start_position_cm::bigint
          < planting_start_position_cm::bigint
            + planting_length_cm::bigint
        and planting_start_position_cm::bigint
          < p.start_position_cm::bigint + p.length_cm::bigint
    ) then
      return jsonb_build_object(
        'status', 'overlap',
        'bed_id', planting_bed_id
      );
    end if;

    -- Conflitti con altri lotti confermati.
    if exists (
      select 1
      from public.planned_plantings pp
      where pp.bed_id = planting_bed_id
        and pp.id <> target_planned_planting_id
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
          < planting_start_position_cm::bigint
            + planting_length_cm::bigint
        and planting_start_position_cm::bigint
          < pp.start_position_cm::bigint + pp.length_cm::bigint
    ) then
      return jsonb_build_object(
        'status', 'overlap',
        'bed_id', planting_bed_id
      );
    end if;

  end if;

  -- 14. Aggiornamento atomico.
  update public.planned_plantings
  set bed_id = planting_bed_id,
      crop_id = planting_crop_id,
      cultivar_id = planting_cultivar_id,
      start_method = planting_start_method,
      planned_start_date = planting_start_date,
      planned_end_date = planting_end_date,
      start_position_cm = planting_start_position_cm,
      length_cm = planting_length_cm,
      occupied_width_cm = planting_occupied_width_cm,
      plant_spacing_cm = planting_plant_spacing_cm,
      row_spacing_cm = planting_row_spacing_cm,
      rows_count = planting_rows_count,
      plants_count = planting_plants_count,
      seed_quantity_g = planting_seed_quantity_g,
      notes = v_notes,
      updated_at = now(),
      row_version = row_version + 1
  where id = target_planned_planting_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
    and status in ('draft', 'confirmed')
  returning row_version into v_new_version;

  if not found then
    return jsonb_build_object(
      'status', 'version_conflict'
    );
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'planned_planting_id', target_planned_planting_id,
    'row_version', v_new_version
  );
end;
$$;

revoke all on function public.update_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text,
  uuid, uuid, uuid, text, date, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) from public, anon;

grant execute on function public.update_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text,
  uuid, uuid, uuid, text, date, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) to authenticated;
