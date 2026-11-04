-- S039 STEP 3.230
-- Refactoring sicuro della creazione Planting e implementazione
-- dell'esecuzione atomica delle pianificazioni confermate.
--
-- La funzione interna e' SECURITY INVOKER e non e' eseguibile dai ruoli client.
-- Le RPC pubbliche SECURITY DEFINER, di proprieta' postgres, sono gli unici
-- percorsi applicativi autorizzati a richiamarla.

CREATE OR REPLACE FUNCTION private.create_planting_internal(target_profile_id uuid, target_garden_id uuid, target_season_id uuid, target_bed_id uuid, target_crop_id uuid, target_cultivar_id uuid, target_client_id uuid, target_session_id uuid, lock_token text, planting_start_method text, planting_start_date date, planting_start_position_cm integer, planting_length_cm integer, planting_plant_spacing_cm integer, planting_row_spacing_cm integer, planting_rows_count integer, planting_occupied_width_cm integer, planting_plants_count integer, planting_seed_quantity_g numeric, planting_notes text, excluded_planned_planting_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY INVOKER
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
      and (
        excluded_planned_planting_id is null
        or pp.id <> excluded_planned_planting_id
      )

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
$function$;

REVOKE ALL ON FUNCTION private.create_planting_internal(
  uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid,
  text, text, date,
  integer, integer, integer, integer, integer, integer, integer,
  numeric, text, uuid
) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.create_planting(
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
  planting_start_position_cm integer,
  planting_length_cm integer,
  planting_plant_spacing_cm integer,
  planting_row_spacing_cm integer,
  planting_rows_count integer,
  planting_occupied_width_cm integer,
  planting_plants_count integer,
  planting_seed_quantity_g numeric,
  planting_notes text
)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT private.create_planting_internal(
    target_profile_id,
    target_garden_id,
    target_season_id,
    target_bed_id,
    target_crop_id,
    target_cultivar_id,
    target_client_id,
    target_session_id,
    lock_token,
    planting_start_method,
    planting_start_date,
    planting_start_position_cm,
    planting_length_cm,
    planting_plant_spacing_cm,
    planting_row_spacing_cm,
    planting_rows_count,
    planting_occupied_width_cm,
    planting_plants_count,
    planting_seed_quantity_g,
    planting_notes,
    null::uuid
  );
$function$;

REVOKE ALL ON FUNCTION public.create_planting(
  uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid,
  text, text, date,
  integer, integer, integer, integer, integer, integer, integer,
  numeric, text
) FROM PUBLIC, anon, service_role;

GRANT EXECUTE ON FUNCTION public.create_planting(
  uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid,
  text, text, date,
  integer, integer, integer, integer, integer, integer, integer,
  numeric, text
) TO authenticated;


CREATE OR REPLACE FUNCTION public.execute_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  effective_start_date date
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  v_auth_user_id uuid := auth.uid();

  v_lot public.planned_plantings%rowtype;

  v_initial_garden_id uuid;
  v_initial_season_id uuid;
  v_initial_bed_id uuid;
  v_initial_crop_id uuid;
  v_initial_cultivar_id uuid;
  v_initial_row_version bigint;

  v_locked_id uuid;
  v_result jsonb;
  v_planting_id uuid;
  v_new_row_version bigint;
BEGIN
  -- 1. Identita' e autorizzazione del proprietario.
  IF v_auth_user_id IS NULL
     OR target_profile_id IS NULL
     OR target_planned_planting_id IS NULL
     OR expected_row_version IS NULL
     OR expected_row_version < 1
     OR NOT private.is_profile_owner(target_profile_id)
  THEN
    RETURN jsonb_build_object('status', 'forbidden');
  END IF;

  IF effective_start_date IS NULL
     OR NOT isfinite(effective_start_date)
  THEN
    RETURN jsonb_build_object('status', 'invalid_input');
  END IF;

  -- 2. Write Authority iniziale.
  IF target_client_id IS NULL
     OR target_session_id IS NULL
     OR lock_token IS NULL
     OR NOT private.lock_profile_write_authority(
       target_profile_id,
       target_client_id,
       target_session_id,
       lock_token
     )
  THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 3. Lettura preliminare non bloccante del lotto.
  SELECT *
    INTO v_lot
  FROM public.planned_plantings
  WHERE id = target_planned_planting_id
    AND profile_id = target_profile_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  v_initial_garden_id := v_lot.garden_id;
  v_initial_season_id := v_lot.season_id;
  v_initial_bed_id := v_lot.bed_id;
  v_initial_crop_id := v_lot.crop_id;
  v_initial_cultivar_id := v_lot.cultivar_id;
  v_initial_row_version := v_lot.row_version;

  IF v_initial_row_version <> expected_row_version THEN
    RETURN jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_initial_row_version
    );
  END IF;

  -- 4. Lock dell'orto.
  SELECT g.id
    INTO v_locked_id
  FROM public.gardens g
  WHERE g.id = v_initial_garden_id
    AND g.profile_id = target_profile_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  IF NOT private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 5. Lock della stagione.
  SELECT s.id
    INTO v_locked_id
  FROM public.seasons s
  WHERE s.id = v_initial_season_id
    AND s.garden_id = v_initial_garden_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  IF NOT private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 6. Lock dell'aiuola.
  SELECT b.id
    INTO v_locked_id
  FROM public.beds b
  WHERE b.id = v_initial_bed_id
    AND b.garden_id = v_initial_garden_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  IF NOT private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 7. Lock della coltura.
  SELECT c.id
    INTO v_locked_id
  FROM public.crops c
  WHERE c.id = v_initial_crop_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  IF NOT private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 8. Lock della varieta', se presente.
  IF v_initial_cultivar_id IS NOT NULL THEN
    SELECT cv.id
      INTO v_locked_id
    FROM public.crop_cultivars cv
    WHERE cv.id = v_initial_cultivar_id
      AND cv.crop_id = v_initial_crop_id
    FOR UPDATE;

    IF NOT FOUND THEN
      RETURN jsonb_build_object('status', 'not_found');
    END IF;

    IF NOT private.lock_profile_write_authority(
      target_profile_id, target_client_id,
      target_session_id, lock_token
    ) THEN
      RETURN jsonb_build_object('status', 'write_forbidden');
    END IF;
  END IF;

  -- 9. Lock autoritativo del lotto, sempre dopo le entita' dipendenti.
  SELECT *
    INTO v_lot
  FROM public.planned_plantings
  WHERE id = target_planned_planting_id
    AND profile_id = target_profile_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found');
  END IF;

  IF NOT private.lock_profile_write_authority(
    target_profile_id, target_client_id,
    target_session_id, lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 10. Rivalidazione dell'identita' e della versione.
  IF v_lot.garden_id IS DISTINCT FROM v_initial_garden_id
     OR v_lot.season_id IS DISTINCT FROM v_initial_season_id
     OR v_lot.bed_id IS DISTINCT FROM v_initial_bed_id
     OR v_lot.crop_id IS DISTINCT FROM v_initial_crop_id
     OR v_lot.cultivar_id IS DISTINCT FROM v_initial_cultivar_id
  THEN
    RETURN jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  END IF;

  IF v_lot.row_version <> expected_row_version THEN
    RETURN jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  END IF;

  IF v_lot.status <> 'confirmed' THEN
    RETURN jsonb_build_object('status', 'blocked_by_lifecycle');
  END IF;

  -- 11. Ultima verifica della Write Authority prima della creazione.
  IF NOT private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) THEN
    RETURN jsonb_build_object('status', 'write_forbidden');
  END IF;

  -- 12. Creazione della coltivazione reale.
  -- L'unica prenotazione esclusa e' il lotto confermato bloccato sopra.
  -- Tutte le altre prenotazioni confermate restano protette.
  v_result := private.create_planting_internal(
    target_profile_id,
    v_lot.garden_id,
    v_lot.season_id,
    v_lot.bed_id,
    v_lot.crop_id,
    v_lot.cultivar_id,
    target_client_id,
    target_session_id,
    lock_token,
    v_lot.start_method,
    effective_start_date,
    v_lot.start_position_cm,
    v_lot.length_cm,
    v_lot.plant_spacing_cm,
    v_lot.row_spacing_cm,
    v_lot.rows_count,
    v_lot.occupied_width_cm,
    v_lot.plants_count,
    v_lot.seed_quantity_g,
    v_lot.notes,
    target_planned_planting_id
  );

  IF v_result->>'status' IS DISTINCT FROM 'created' THEN
    RETURN v_result;
  END IF;

  v_planting_id := (v_result->>'planting_id')::uuid;

  IF v_planting_id IS NULL THEN
    RAISE EXCEPTION
      'execute_planned_planting: create_planting_internal returned created without planting_id';
  END IF;

  -- 13. Collegamento atomico del lotto alla coltivazione reale.
  UPDATE public.planned_plantings
  SET status = 'executed',
      executed_planting_id = v_planting_id,
      updated_at = now(),
      row_version = row_version + 1
  WHERE id = target_planned_planting_id
    AND profile_id = target_profile_id
    AND row_version = expected_row_version
    AND status = 'confirmed'
  RETURNING row_version INTO v_new_row_version;

  -- Non restituire un JSON di errore dopo l'INSERT: un'eccezione forza
  -- il rollback dell'intera transazione, inclusa la nuova coltivazione.
  IF NOT FOUND THEN
    RAISE EXCEPTION
      'execute_planned_planting: locked planned planting changed unexpectedly';
  END IF;

  RETURN jsonb_build_object(
    'status', 'executed',
    'planned_planting_id', target_planned_planting_id,
    'planting_id', v_planting_id,
    'effective_start_date', effective_start_date,
    'row_version', v_new_row_version
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date
) FROM PUBLIC, anon, service_role;

GRANT EXECUTE ON FUNCTION public.execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date
) TO authenticated;