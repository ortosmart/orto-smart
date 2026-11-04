CREATE OR REPLACE FUNCTION public.create_planting(target_profile_id uuid, target_garden_id uuid, target_season_id uuid, target_bed_id uuid, target_crop_id uuid, target_cultivar_id uuid, target_client_id uuid, target_session_id uuid, lock_token text, planting_start_method text, planting_start_date date, planting_start_position_cm integer, planting_length_cm integer, planting_plant_spacing_cm integer, planting_row_spacing_cm integer, planting_rows_count integer, planting_occupied_width_cm integer, planting_plants_count integer, planting_seed_quantity_g numeric, planting_notes text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_timezone text;
  v_garden_is_active boolean;
  v_today date;

  v_season_start_date date;
  v_season_end_date date;

  v_bed_is_active boolean;

  v_crop_is_active boolean;

  v_cultivar_is_active boolean;

  v_status text;
  v_notes text;

  v_planting_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITA E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_garden_id is null
     or target_season_id is null
     or target_bed_id is null
     or target_crop_id is null
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
  -- 3. GARDEN
  -- --------------------------------------------------------------------------
  -- Il lock serializza la creazione rispetto a modifiche concorrenti
  -- del Garden.

  select
    g.timezone,
    g.is_active
  into
    v_garden_timezone,
    v_garden_is_active
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

  if v_garden_is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_garden',
      'garden_id', target_garden_id
    );
  end if;

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  -- --------------------------------------------------------------------------
  -- 4. VALIDAZIONE INPUT DI BASE
  -- --------------------------------------------------------------------------

  v_notes :=
    nullif(
      btrim(planting_notes),
      ''
    );

  if planting_start_method is null
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
  -- 5. VALIDAZIONE DATI DIPENDENTI DAL METODO
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

    v_status := 'growing';

  elsif planting_start_method = 'direct_rows'
  then
    if planting_rows_count is null
       or planting_row_spacing_cm is null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    v_status := 'sown';

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

    v_status := 'sown';
  end if;

  -- Le file devono rientrare nella larghezza assegnata.

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

  -- Le piante devono rientrare nella lunghezza assegnata.

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
  -- 6. SEASON
  -- --------------------------------------------------------------------------

  select
    s.start_date,
    s.end_date
  into
    v_season_start_date,
    v_season_end_date
  from public.seasons s
  where s.id = target_season_id
    and s.garden_id = target_garden_id
  for update;

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
  -- 7. BED
  -- --------------------------------------------------------------------------

  select
    b.is_active
  into
    v_bed_is_active
  from public.beds b
  where b.id = target_bed_id
    and b.garden_id = target_garden_id
  for update;

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

  if v_bed_is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_bed',
      'bed_id', target_bed_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. CROP
  -- --------------------------------------------------------------------------

  select
    c.is_active
  into
    v_crop_is_active
  from public.crops c
  where c.id = target_crop_id
  for update;

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

  if v_crop_is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_crop',
      'crop_id', target_crop_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. CULTIVAR
  -- --------------------------------------------------------------------------

  if target_cultivar_id is not null
  then
    select
      cv.is_active
    into
      v_cultivar_is_active
    from public.crop_cultivars cv
    where cv.id = target_cultivar_id
      and cv.crop_id = target_crop_id
    for update;

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

    if v_cultivar_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_cultivar',
        'crop_id', target_crop_id,
        'cultivar_id', target_cultivar_id
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 10. COMPATIBILITA CON LE GEOMETRIE NEL PERIODO
  -- --------------------------------------------------------------------------
  -- Il nuovo Planting occupa:
  --
  --   [planting_start_date, infinito)
  --
  -- Deve quindi risultare compatibile con tutte le geometrie dell'aiuola
  -- il cui intervallo [valid_from, valid_to) si sovrappone al periodo
  -- di occupazione del Planting.
  --
  -- Non basta verificare soltanto la geometria valida alla start_date:
  -- una geometria successiva gia presente nella storia potrebbe avere
  -- dimensioni inferiori e rendere impossibile l'occupazione registrata.

  if not exists (
    select 1
    from public.bed_geometries bg
    where bg.bed_id = target_bed_id
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
    where bg.bed_id = target_bed_id

      -- Sovrapposizione temporale tra:
      --
      --   Planting:  [planting_start_date, infinito)
      --   Geometria: [bg.valid_from, bg.valid_to)
      --
      -- Poiche il Planting non ha ancora end_date, e sufficiente che
      -- la geometria termini dopo la start_date oppure sia aperta.

      and (
        bg.valid_to is null
        or planting_start_date < bg.valid_to
      )

      -- Compatibilita spaziale con ciascuna geometria sovrapposta.

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
      'bed_id', target_bed_id
    );
  end if;

  -- Rivalida il lease dopo le verifiche sulle geometrie.

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
  -- 11. SOVRAPPOSIZIONE SPAZIALE E TEMPORALE
  -- --------------------------------------------------------------------------
  -- Il nuovo Planting occupa [planting_start_date, infinito).
  --
  -- Due Planting sono incompatibili solo se:
  --
  --   1. i loro periodi di occupazione si sovrappongono;
  --   2. i loro intervalli longitudinali si sovrappongono.
  --
  -- Gli intervalli sono trattati come semichiusi [inizio, fine).

  if exists (
    select 1
    from public.plantings p
    where p.bed_id = target_bed_id

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
      'bed_id', target_bed_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11B. SOVRAPPOSIZIONE CON PIANIFICAZIONI CONFERMATE
  -- --------------------------------------------------------------------------
  -- Le pianificazioni confirmed riservano lo spazio nell'aiuola.
  -- La nuova coltivazione occupa [planting_start_date, infinito).
  -- La data finale della pianificazione e inclusiva.
  --
  -- Le pianificazioni draft, cancelled ed executed non riservano spazio.

  if exists (
    select 1
    from public.planned_plantings pp
    where pp.bed_id = target_bed_id
      and pp.status = 'confirmed'

      -- Sovrapposizione temporale.
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
      'bed_id', target_bed_id
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 12. RIVALIDAZIONE FINALE DELLA WRITE AUTHORITY
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
  -- 13. CREAZIONE
  -- --------------------------------------------------------------------------

  insert into public.plantings (
    profile_id,
    garden_id,
    season_id,
    bed_id,

    crop_id,
    cultivar_id,

    start_method,
    start_date,
    end_date,

    start_position_cm,
    length_cm,

    plant_spacing_cm,
    row_spacing_cm,
    rows_count,
    occupied_width_cm,

    plants_count,
    seed_quantity_g,

    status,
    notes
  )
  values (
    target_profile_id,
    target_garden_id,
    target_season_id,
    target_bed_id,

    target_crop_id,
    target_cultivar_id,

    planting_start_method,
    planting_start_date,
    null,

    planting_start_position_cm,
    planting_length_cm,

    planting_plant_spacing_cm,
    planting_row_spacing_cm,
    planting_rows_count,
    planting_occupied_width_cm,

    planting_plants_count,
    planting_seed_quantity_g,

    v_status,
    v_notes
  )
  returning
    id,
    row_version,
    created_at
  into
    v_planting_id,
    v_row_version,
    v_created_at;

  -- --------------------------------------------------------------------------
  -- 14. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',

    'planting_id', v_planting_id,

    'profile_id', target_profile_id,
    'garden_id', target_garden_id,
    'season_id', target_season_id,
    'bed_id', target_bed_id,

    'crop_id', target_crop_id,
    'cultivar_id', target_cultivar_id,

    'start_method', planting_start_method,
    'start_date', planting_start_date,
    'end_date', null,

    'start_position_cm', planting_start_position_cm,
    'length_cm', planting_length_cm,
    'occupied_width_cm', planting_occupied_width_cm,

    'status_value', v_status,

    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$function$
