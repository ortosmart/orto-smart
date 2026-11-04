CREATE OR REPLACE FUNCTION public.update_planting(target_profile_id uuid, target_planting_id uuid, expected_row_version bigint, target_client_id uuid, target_session_id uuid, lock_token text, planting_season_id uuid, planting_crop_id uuid, planting_cultivar_id uuid, planting_start_method text, planting_start_date date, planting_start_position_cm integer, planting_length_cm integer, planting_plant_spacing_cm integer, planting_row_spacing_cm integer, planting_rows_count integer, planting_occupied_width_cm integer, planting_plants_count integer, planting_seed_quantity_g numeric, planting_notes text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_id uuid;
  v_bed_id uuid;
  v_locked_bed_id uuid;
  v_garden_timezone text;
  v_today date;

  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_current_season_id uuid;
  v_current_crop_id uuid;
  v_current_cultivar_id uuid;

  v_current_start_method text;
  v_current_start_date date;

  v_current_start_position_cm integer;
  v_current_length_cm integer;

  v_current_plant_spacing_cm integer;
  v_current_row_spacing_cm integer;
  v_current_rows_count integer;
  v_current_occupied_width_cm integer;

  v_current_plants_count integer;
  v_current_seed_quantity_g numeric;

  v_current_status text;
  v_current_notes text;

  v_season_start_date date;
  v_season_end_date date;

  v_crop_is_active boolean;
  v_cultivar_is_active boolean;

  v_new_status text;
  v_notes text;

  v_row_version bigint;
  v_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITA E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_planting_id is null
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
  -- 3. LETTURA PLANTING E CONTESTO AUTORITATIVO
  -- --------------------------------------------------------------------------

  select
    p.garden_id,
    p.bed_id,

    g.timezone,

    p.row_version,
    p.updated_at,

    p.season_id,
    p.crop_id,
    p.cultivar_id,

    p.start_method,
    p.start_date,

    p.start_position_cm,
    p.length_cm,

    p.plant_spacing_cm,
    p.row_spacing_cm,
    p.rows_count,
    p.occupied_width_cm,

    p.plants_count,
    p.seed_quantity_g,

    p.status,
    p.notes
  into
    v_garden_id,
    v_bed_id,

    v_garden_timezone,

    v_current_row_version,
    v_current_updated_at,

    v_current_season_id,
    v_current_crop_id,
    v_current_cultivar_id,

    v_current_start_method,
    v_current_start_date,

    v_current_start_position_cm,
    v_current_length_cm,

    v_current_plant_spacing_cm,
    v_current_row_spacing_cm,
    v_current_rows_count,
    v_current_occupied_width_cm,

    v_current_plants_count,
    v_current_seed_quantity_g,

    v_current_status,
    v_current_notes
  from public.plantings p
  join public.gardens g
    on g.id = p.garden_id
  where p.id = target_planting_id
    and p.profile_id = target_profile_id
  for update of p;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
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
  -- 4. CONTROLLO OTTIMISTICO
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'planting_id', target_planting_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5. VALIDAZIONE INPUT DI BASE
  -- --------------------------------------------------------------------------

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  v_notes :=
    nullif(
      btrim(planting_notes),
      ''
    );

  if planting_season_id is null
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
     or planting_start_date > v_today

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
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 6. VINCOLI DI MODIFICA STORICA
  -- --------------------------------------------------------------------------

  if planting_start_method <> v_current_start_method
     and v_current_status not in (
       'sown',
       'growing'
     )
  then
    return jsonb_build_object(
      'status', 'start_method_locked',
      'planting_id', target_planting_id
    );
  end if;

  if planting_start_date <> v_current_start_date
     and v_current_status not in (
       'sown',
       'growing'
     )
  then
    return jsonb_build_object(
      'status', 'start_date_locked',
      'planting_id', target_planting_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. VALIDAZIONE DATI DIPENDENTI DAL METODO
  -- --------------------------------------------------------------------------

  if planting_start_method in (
       'purchased_seedlings',
       'nursery_then_transplant'
     )
  then
    if planting_plants_count is null
       or planting_plant_spacing_cm is null
       or planting_seed_quantity_g is not null
       or not (
         (
           planting_rows_count is null
           and planting_row_spacing_cm is null
         )
         or
         (
           planting_rows_count is not null
           and planting_row_spacing_cm is not null
         )
       )
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    if planting_start_method <> v_current_start_method
    then
      v_new_status := 'growing';
    else
      v_new_status := v_current_status;
    end if;

  elsif planting_start_method = 'direct_rows'
  then
    if planting_rows_count is null
       or planting_row_spacing_cm is null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    if planting_start_method <> v_current_start_method
    then
      v_new_status := 'sown';
    else
      v_new_status := v_current_status;
    end if;

  else
    -- direct_broadcast

    if planting_rows_count is not null
       or planting_row_spacing_cm is not null
       or planting_plant_spacing_cm is not null
       or planting_plants_count is not null
       or planting_seed_quantity_g is null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    if planting_start_method <> v_current_start_method
    then
      v_new_status := 'sown';
    else
      v_new_status := v_current_status;
    end if;
  end if;

  if planting_rows_count is not null
     and planting_row_spacing_cm is not null
     and (
       (planting_rows_count - 1)::bigint
       * planting_row_spacing_cm::bigint
     ) > planting_occupied_width_cm::bigint
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  if planting_plants_count is not null
     and planting_plant_spacing_cm is not null
     and (
       (planting_plants_count - 1)::bigint
       * planting_plant_spacing_cm::bigint
     ) > planting_length_cm::bigint
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. SEASON
  -- --------------------------------------------------------------------------

  select
    s.start_date,
    s.end_date
  into
    v_season_start_date,
    v_season_end_date
  from public.seasons s
  where s.id = planting_season_id
    and s.garden_id = v_garden_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  if planting_start_date < v_season_start_date
     or (
       v_season_end_date is not null
       and planting_start_date > v_season_end_date
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

    -- --------------------------------------------------------------------------
  -- 8A. BLOCCO AUTORITATIVO DELL'AIUOLA
  -- --------------------------------------------------------------------------

  select b.id
    into v_locked_bed_id
  from public.beds b
  where b.id = v_bed_id
    and b.garden_id = v_garden_id
  for update;

  if not found then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalidazione della Write Authority dopo l'attesa sul lock.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. CROP
  -- --------------------------------------------------------------------------

  select
    c.is_active
  into
    v_crop_is_active
  from public.crops c
  where c.id = planting_crop_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  if v_crop_is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_crop',
      'crop_id', planting_crop_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 10. CULTIVAR
  -- --------------------------------------------------------------------------

  if planting_cultivar_id is not null
  then
    select
      cv.is_active
    into
      v_cultivar_is_active
    from public.crop_cultivars cv
    where cv.id = planting_cultivar_id
      and cv.crop_id = planting_crop_id
    for update;

    if not found
    then
      return jsonb_build_object(
        'status', 'not_found'
      );
    end if;

    if v_cultivar_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_cultivar',
        'crop_id', planting_crop_id,
        'cultivar_id', planting_cultivar_id
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 11. COMPATIBILITA CON LE GEOMETRIE
  -- --------------------------------------------------------------------------
  -- Poiche update_planting non modifica end_date, il periodo di occupazione
  -- resta quello gia registrato:
  --
  --   [planting_start_date, p.end_date)
  --
  -- Per gli stati attivi end_date e' NULL.

  if not exists (
    select 1
    from public.bed_geometries bg
    where bg.bed_id = v_bed_id
      and bg.valid_from <= planting_start_date
      and (
        bg.valid_to is null
        or planting_start_date < bg.valid_to
      )
  )
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  if exists (
    select 1
    from public.bed_geometries bg
    join public.plantings current_p
      on current_p.id = target_planting_id
    where bg.bed_id = v_bed_id

      and (
        current_p.end_date is null
        or bg.valid_from < current_p.end_date
      )

      and (
        bg.valid_to is null
        or planting_start_date < bg.valid_to
      )

      and (
        planting_start_position_cm::bigint
          + planting_length_cm::bigint
            > bg.length_cm::bigint

        or planting_occupied_width_cm
             > bg.width_cm
      )
  )
  then
    return jsonb_build_object(
      'status', 'outside_bed_geometry',
      'bed_id', v_bed_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 12. SOVRAPPOSIZIONE CON ALTRI PLANTING
  -- --------------------------------------------------------------------------

  if exists (
    select 1
    from public.plantings p
    join public.plantings current_p
      on current_p.id = target_planting_id
    where p.bed_id = v_bed_id
      and p.id <> target_planting_id

      and (
        current_p.end_date is null
        or p.start_date < current_p.end_date
      )

      and (
        p.end_date is null
        or planting_start_date < p.end_date
      )

      and p.start_position_cm::bigint
          <
          (
            planting_start_position_cm::bigint
            + planting_length_cm::bigint
          )

      and planting_start_position_cm::bigint
          <
          (
            p.start_position_cm::bigint
            + p.length_cm::bigint
          )
  )
  then
    return jsonb_build_object(
      'status', 'overlap',
      'bed_id', v_bed_id
    );
  end if;

    -- --------------------------------------------------------------------------
  -- 12A. PROTEZIONE DELLE PRENOTAZIONI CONFERMATE
  -- --------------------------------------------------------------------------
  -- Una coltivazione reale non puo' occupare spazio gia' riservato
  -- da un lotto pianificato in stato confirmed.
  --
  -- Planting:
  --   [planting_start_date, current_p.end_date)
  --
  -- Pianificazione:
  --   [planned_start_date, planned_end_date + 1)
  --
  -- planned_end_date e' inclusiva.
  -- plantings.end_date e' esclusiva.
  --
  -- Il lock sull'aiuola serializza le operazioni concorrenti
  -- che rispettano la Write Authority e il protocollo dei lock.

  if exists (
    select 1
    from public.planned_plantings pp
    join public.plantings current_p
      on current_p.id = target_planting_id
    where pp.bed_id = v_bed_id
      and pp.status = 'confirmed'

      -- Sovrapposizione temporale.
      and (
        current_p.end_date is null
        or pp.planned_start_date < current_p.end_date
      )

      and (
        pp.planned_end_date is null
        or planting_start_date <= pp.planned_end_date
      )

      -- Sovrapposizione longitudinale.
      and pp.start_position_cm::bigint
          <
          (
            planting_start_position_cm::bigint
            + planting_length_cm::bigint
          )

      and planting_start_position_cm::bigint
          <
          (
            pp.start_position_cm::bigint
            + pp.length_cm::bigint
          )
  )
  then
    return jsonb_build_object(
      'status', 'blocked_by_confirmed_plans',
      'bed_id', v_bed_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13. DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current_season_id = planting_season_id
     and v_current_crop_id = planting_crop_id
     and v_current_cultivar_id is not distinct from planting_cultivar_id

     and v_current_start_method = planting_start_method
     and v_current_start_date = planting_start_date

     and v_current_start_position_cm = planting_start_position_cm
     and v_current_length_cm = planting_length_cm

     and v_current_plant_spacing_cm is not distinct from planting_plant_spacing_cm
     and v_current_row_spacing_cm is not distinct from planting_row_spacing_cm
     and v_current_rows_count is not distinct from planting_rows_count
     and v_current_occupied_width_cm = planting_occupied_width_cm

     and v_current_plants_count is not distinct from planting_plants_count
     and v_current_seed_quantity_g is not distinct from planting_seed_quantity_g

     and v_current_notes is not distinct from v_notes
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'planting_id', target_planting_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 14. RIVALIDAZIONE FINALE DELLA WRITE AUTHORITY
  -- --------------------------------------------------------------------------

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
  -- 15. UPDATE
  -- --------------------------------------------------------------------------

  update public.plantings
  set
    season_id = planting_season_id,
    crop_id = planting_crop_id,
    cultivar_id = planting_cultivar_id,

    start_method = planting_start_method,
    start_date = planting_start_date,

    start_position_cm = planting_start_position_cm,
    length_cm = planting_length_cm,

    plant_spacing_cm = planting_plant_spacing_cm,
    row_spacing_cm = planting_row_spacing_cm,
    rows_count = planting_rows_count,
    occupied_width_cm = planting_occupied_width_cm,

    plants_count = planting_plants_count,
    seed_quantity_g = planting_seed_quantity_g,

    status = v_new_status,
    notes = v_notes
  where id = target_planting_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_row_version,
    v_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while updating planting';
  end if;

  -- --------------------------------------------------------------------------
  -- 16. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',

    'planting_id', target_planting_id,

    'garden_id', v_garden_id,
    'bed_id', v_bed_id,

    'season_id', planting_season_id,
    'crop_id', planting_crop_id,
    'cultivar_id', planting_cultivar_id,

    'start_method', planting_start_method,
    'start_date', planting_start_date,

    'start_position_cm', planting_start_position_cm,
    'length_cm', planting_length_cm,
    'occupied_width_cm', planting_occupied_width_cm,

    'status_value', v_new_status,

    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


REVOKE ALL ON FUNCTION public.update_planting(
  uuid, uuid, bigint, uuid, uuid, text,
  uuid, uuid, uuid, text, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) FROM PUBLIC, anon, service_role;

GRANT EXECUTE ON FUNCTION public.update_planting(
  uuid, uuid, bigint, uuid, uuid, text,
  uuid, uuid, uuid, text, date,
  integer, integer, integer, integer,
  integer, integer, integer, numeric, text
) TO authenticated;
