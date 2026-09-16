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
  -- 10. DIVISIONE DELL'INTERVALLO E NUOVA GEOMETRIA
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
$$;

-- ============================================================================
-- PRIVILEGI CHANGE_BED_GEOMETRY
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

-- ============================================================================
-- CREATE PLANTING
-- ============================================================================
-- Crea un'occupazione reale dell'aiuola.
-- La pianificazione futura appartiene a un dominio separato:
-- planting_start_date non puo essere futura.
--
-- Lo stato iniziale viene determinato server-side:
--
--   purchased_seedlings        -> growing
--   nursery_then_transplant    -> growing
--   direct_rows                -> sown
--   direct_broadcast           -> sown
--
-- end_date nasce sempre NULL.
-- ============================================================================

create or replace function public.create_planting(
  target_profile_id uuid,
  target_garden_id uuid,
  target_season_id uuid,
  target_bed_id uuid,
  target_crop_id uuid,
  target_variety_id uuid,

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
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_timezone text;
  v_garden_is_active boolean;
  v_today date;

  v_season_start_date date;
  v_season_end_date date;

  v_bed_is_active boolean;

  v_crop_is_active boolean;

  v_variety_is_active boolean;

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
    and c.profile_id = target_profile_id
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
  -- 9. VARIETY
  -- --------------------------------------------------------------------------

  if target_variety_id is not null
  then
    select
      cv.is_active
    into
      v_variety_is_active
    from public.crop_varieties cv
    where cv.id = target_variety_id
      and cv.crop_id = target_crop_id
      and cv.profile_id = target_profile_id
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

    if v_variety_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_variety',
        'crop_id', target_crop_id,
        'variety_id', target_variety_id
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
    variety_id,

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
    target_variety_id,

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
    'variety_id', target_variety_id,

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
$$;


-- ============================================================================
-- PRIVILEGI CREATE_PLANTING
-- ============================================================================

revoke all
  on function public.create_planting(
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,

    uuid,
    uuid,
    text,

    text,
    date,

    integer,
    integer,

    integer,
    integer,
    integer,
    integer,

    integer,
    numeric,

    text
  )
  from public, anon, authenticated;

grant execute
  on function public.create_planting(
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,

    uuid,
    uuid,
    text,

    text,
    date,

    integer,
    integer,

    integer,
    integer,
    integer,
    integer,

    integer,
    numeric,

    text
  )
  to authenticated;
-- ============================================================================
-- RETTIFICA AUTORITATIVA DELLA GEOMETRIA DELL'AIUOLA
-- ============================================================================
-- Sessione S024.
-- Riservata all'owner con Profile Write Authority valida.
-- Rettifica dimensioni e data iniziale della geometria identificata.
-- Preserva la fine dell'intervallo e adegua, quando necessario,
-- la fine della geometria precedente.
-- Registra motivazione e snapshot server-side prima/dopo.

create or replace function public.correct_bed_geometry(
  target_profile_id uuid,
  target_bed_id uuid,
  target_geometry_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  geometry_width_cm integer,
  geometry_length_cm integer,
  geometry_valid_from date,
  correction_reason text
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
  v_reason text;

  v_current_bed_row_version bigint;
  v_current_bed_updated_at timestamptz;

  v_target_geometry public.bed_geometries%rowtype;
  v_previous_geometry public.bed_geometries%rowtype;
  v_has_previous boolean := false;
  v_adjust_previous boolean := false;

  v_before_state jsonb;
  v_after_state jsonb;

  v_geometry_row_version bigint;
  v_geometry_updated_at timestamptz;
  v_previous_row_version bigint;
  v_previous_updated_at timestamptz;

  v_bed_row_version bigint;
  v_bed_updated_at timestamptz;

  v_correction_id uuid;
  v_correction_created_at timestamptz;

  v_result jsonb;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_bed_id is null
     or target_geometry_id is null
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
  -- 5. LETTURA DELLA GEOMETRIA DA RETTIFICARE
  -- --------------------------------------------------------------------------

  select bg.*
  into v_target_geometry
  from public.bed_geometries bg
  where bg.id = target_geometry_id
    and bg.bed_id = target_bed_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
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
  -- 6. VALIDAZIONE DEI DATI DI RETTIFICA
  -- --------------------------------------------------------------------------

  v_reason :=
    nullif(btrim(correction_reason), '');

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  if geometry_width_cm is null
     or geometry_width_cm <= 0
     or geometry_length_cm is null
     or geometry_length_cm <= 0
     or geometry_valid_from is null
     or not isfinite(geometry_valid_from)
     or geometry_valid_from > v_today
     or v_reason is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- La fine della geometria target resta invariata.
  -- La nuova data iniziale non deve svuotare o invertire l'intervallo.

  if v_target_geometry.valid_to is not null
     and geometry_valid_from >= v_target_geometry.valid_to
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. GEOMETRIA PRECEDENTE E COERENZA TEMPORALE
  -- --------------------------------------------------------------------------

  select bg.*
  into v_previous_geometry
  from public.bed_geometries bg
  where bg.bed_id = target_bed_id
    and bg.valid_from < v_target_geometry.valid_from
  order by bg.valid_from desc
  limit 1
  for update;

  v_has_previous := found;

  -- Rivalida il lease dopo l'eventuale attesa sul lock precedente.

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

  if v_has_previous
  then
    -- Una storia discontinua non viene riparata implicitamente.
    if v_previous_geometry.valid_to
       is distinct from v_target_geometry.valid_from
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    -- Il nuovo confine deve lasciare non vuoto l'intervallo precedente.
    if geometry_valid_from <= v_previous_geometry.valid_from
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  v_adjust_previous :=
    v_has_previous
    and geometry_valid_from <> v_target_geometry.valid_from;

  -- --------------------------------------------------------------------------
  -- 8. CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_target_geometry.width_cm = geometry_width_cm
     and v_target_geometry.length_cm = geometry_length_cm
     and v_target_geometry.valid_from = geometry_valid_from
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,
      'geometry_id', v_target_geometry.id,
      'geometry_row_version', v_target_geometry.row_version,
      'geometry_updated_at', v_target_geometry.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. COMPATIBILITA CON I PLANTING NEL PERIODO
  -- --------------------------------------------------------------------------
  -- Una rettifica puo modificare:
  --
  --   1. l'intervallo della geometria precedente, quando valid_from cambia;
  --   2. l'intervallo e le dimensioni della geometria target.
  --
  -- Entrambe le geometrie risultanti devono restare compatibili con tutti
  -- i Planting il cui intervallo di occupazione [start_date, end_date)
  -- si sovrappone al rispettivo intervallo geometrico.

  -- --------------------------------------------------------------------------
  -- 9.1 GEOMETRIA PRECEDENTE RISULTANTE
  -- --------------------------------------------------------------------------
  -- Quando il confine viene spostato, la geometria precedente diventera:
  --
  --   [v_previous_geometry.valid_from, geometry_valid_from)
  --
  -- Le sue dimensioni non cambiano, ma cambia il periodo nel quale devono
  -- essere compatibili con i Planting storici.

  if v_adjust_previous
     and exists (
       select 1
       from public.plantings p
       where p.bed_id = target_bed_id

         -- Sovrapposizione temporale:
         -- [p.start_date, p.end_date)
         -- con
         -- [v_previous_geometry.valid_from, geometry_valid_from)

         and p.start_date < geometry_valid_from

         and (
           p.end_date is null
           or v_previous_geometry.valid_from < p.end_date
         )

         -- Compatibilita spaziale con la geometria precedente.

         and (
           p.start_position_cm::bigint
             + p.length_cm::bigint
               > v_previous_geometry.length_cm::bigint

           or p.occupied_width_cm
                > v_previous_geometry.width_cm
         )
     )
  then
    return jsonb_build_object(
      'status', 'blocked_by_plantings',

      'bed_id', target_bed_id,
      'garden_id', v_garden_id,

      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,

      'geometry_id', v_previous_geometry.id,
      'geometry_row_version', v_previous_geometry.row_version,
      'geometry_updated_at', v_previous_geometry.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.2 GEOMETRIA TARGET RISULTANTE
  -- --------------------------------------------------------------------------
  -- Dopo la rettifica la geometria target sara:
  --
  --   [geometry_valid_from, v_target_geometry.valid_to)
  --
  -- con le nuove width_cm e length_cm.

  if exists (
    select 1
    from public.plantings p
    where p.bed_id = target_bed_id

      -- Sovrapposizione temporale:
      -- [p.start_date, p.end_date)
      -- con
      -- [geometry_valid_from, v_target_geometry.valid_to)

      and (
        v_target_geometry.valid_to is null
        or p.start_date < v_target_geometry.valid_to
      )

      and (
        p.end_date is null
        or geometry_valid_from < p.end_date
      )

      -- Compatibilita spaziale con la nuova geometria target.

      and (
        p.start_position_cm::bigint
          + p.length_cm::bigint
            > geometry_length_cm::bigint

        or p.occupied_width_cm
             > geometry_width_cm
      )
  )
  then
    return jsonb_build_object(
      'status', 'blocked_by_plantings',

      'bed_id', target_bed_id,
      'garden_id', v_garden_id,

      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,

      'geometry_id', v_target_geometry.id,
      'geometry_row_version', v_target_geometry.row_version,
      'geometry_updated_at', v_target_geometry.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 10. SNAPSHOT SERVER-SIDE PRIMA DELLA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Include soltanto le geometrie che saranno effettivamente modificate.
  -- Ordine cronologico: precedente, quando coinvolta, poi target.

  if v_adjust_previous
  then
    v_before_state := jsonb_build_array(
      to_jsonb(v_previous_geometry),
      to_jsonb(v_target_geometry)
    );
  else
    v_before_state := jsonb_build_array(
      to_jsonb(v_target_geometry)
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11. RETTIFICA DELLE GEOMETRIE COINVOLTE
  -- --------------------------------------------------------------------------

  if v_adjust_previous
  then
    set constraints public.bed_geometries_no_overlap deferred;

    update public.bed_geometries
    set valid_to = geometry_valid_from
    where id = v_previous_geometry.id
      and bed_id = target_bed_id
      and row_version = v_previous_geometry.row_version
    returning
      row_version,
      updated_at
    into
      v_previous_row_version,
      v_previous_updated_at;

    if not found
    then
      raise exception
        'Concurrent modification while correcting previous bed geometry';
    end if;
  end if;

  update public.bed_geometries
  set
    width_cm = geometry_width_cm,
    length_cm = geometry_length_cm,
    valid_from = geometry_valid_from
  where id = v_target_geometry.id
    and bed_id = target_bed_id
    and row_version = v_target_geometry.row_version
  returning
    row_version,
    updated_at
  into
    v_geometry_row_version,
    v_geometry_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while correcting target bed geometry';
  end if;

  if v_adjust_previous
  then
    -- Verifica ora il risultato finale, prima di registrare la rettifica.
    set constraints public.bed_geometries_no_overlap immediate;
  end if;

  -- --------------------------------------------------------------------------
  -- 12. INCREMENTO DELLA VERSIONE AGGREGATA DELL'AIUOLA
  -- --------------------------------------------------------------------------

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
      'Concurrent modification while updating corrected bed version';
  end if;

  -- --------------------------------------------------------------------------
  -- 13. SNAPSHOT SERVER-SIDE DOPO LA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Rilegge le righe aggiornate, inclusi i metadati prodotti dai trigger.

  if v_adjust_previous
  then
    select jsonb_build_array(
      to_jsonb(previous_geometry),
      to_jsonb(target_geometry)
    )
    into v_after_state
    from public.bed_geometries previous_geometry
    cross join public.bed_geometries target_geometry
    where previous_geometry.id = v_previous_geometry.id
      and previous_geometry.bed_id = target_bed_id
      and target_geometry.id = v_target_geometry.id
      and target_geometry.bed_id = target_bed_id;
  else
    select jsonb_build_array(
      to_jsonb(target_geometry)
    )
    into v_after_state
    from public.bed_geometries target_geometry
    where target_geometry.id = v_target_geometry.id
      and target_geometry.bed_id = target_bed_id;
  end if;

  if v_after_state is null
  then
    raise exception
      'Missing geometry snapshot after bed correction';
  end if;

  -- --------------------------------------------------------------------------
  -- 14. REGISTRAZIONE ATOMICA DELLA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Un solo record per operazione, anche quando coinvolge due geometrie.
  -- Autore, snapshot, versioni e timestamp sono determinati server-side.

  insert into public.bed_geometry_corrections (
    bed_id,
    actor_auth_user_id,
    reason,
    before_state,
    after_state,
    bed_version_before,
    bed_version_after
  )
  values (
    target_bed_id,
    v_auth_user_id,
    v_reason,
    v_before_state,
    v_after_state,
    v_current_bed_row_version,
    v_bed_row_version
  )
  returning
    id,
    created_at
  into
    v_correction_id,
    v_correction_created_at;

  -- --------------------------------------------------------------------------
  -- 15. RISULTATO
  -- --------------------------------------------------------------------------

  v_result := jsonb_build_object(
    'status', 'corrected',
    'bed_id', target_bed_id,
    'garden_id', v_garden_id,
    'row_version', v_bed_row_version,
    'updated_at', v_bed_updated_at,

    'geometry_id', v_target_geometry.id,
    'width_cm', geometry_width_cm,
    'length_cm', geometry_length_cm,
    'valid_from', geometry_valid_from,
    'valid_to', v_target_geometry.valid_to,
    'geometry_row_version', v_geometry_row_version,
    'geometry_updated_at', v_geometry_updated_at,

    'correction_id', v_correction_id,
    'correction_created_at', v_correction_created_at
  );

  if v_adjust_previous
  then
    v_result := v_result || jsonb_build_object(
      'previous_geometry_id', v_previous_geometry.id,
      'previous_geometry_valid_to', geometry_valid_from,
      'previous_geometry_row_version', v_previous_row_version,
      'previous_geometry_updated_at', v_previous_updated_at
    );
  end if;

  return v_result;
end;
$$;

-- ============================================================================
-- PRIVILEGI CORRECT_BED_GEOMETRY
-- ============================================================================

revoke all
  on function public.correct_bed_geometry(
    uuid,
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.correct_bed_geometry(
    uuid,
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date,
    text
  )
  to authenticated;
create or replace function public.request_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz;
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_expires_at timestamptz;

  current_takeover_requested_at timestamptz;

  current_takeover_silenced_until timestamptz;
  current_takeover_granted_at timestamptz;
begin
  -- Solo l'owner attivo del profilo può richiedere un takeover.
  if current_auth_user_id is null
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Parametri minimi obbligatori.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or target_profile_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_client_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_session_id = '00000000-0000-0000-0000-000000000000'::uuid
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Serializza tutte le decisioni sulla riga del lock.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.expires_at,
    pel.takeover_requested_at,
    pel.takeover_silenced_until,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_expires_at,
    current_takeover_requested_at,
    current_takeover_silenced_until,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  -- Il tempo deve essere acquisito dopo l'eventuale attesa sul row lock.
  server_now := clock_timestamp();

  -- Nessun lock esistente oppure lock ormai scaduto:
  -- il client deve usare la normale acquisizione.
  if not found
     or current_expires_at <= server_now
  then
    return jsonb_build_object('status', 'available');
  end if;

  -- Il chiamante è già l'holder corrente: non ha senso chiedere takeover.
  if current_holder_auth_user_id = current_auth_user_id
     and current_client_id = target_client_id
     and current_session_id = target_session_id
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Un grant valido blocca nuove richieste takeover.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return jsonb_build_object('status', 'transfer_pending');
  end if;

  -- Un silenziamento valido blocca nuove richieste.
  if current_takeover_silenced_until is not null
     and current_takeover_silenced_until > server_now
  then
    return jsonb_build_object('status', 'silenced');
  end if;

  -- Una richiesta takeover ancora valida è già pendente.
  if current_takeover_requested_at is not null
     and current_takeover_requested_at + interval '10 minutes' > server_now
  then
    return jsonb_build_object('status', 'request_pending');
  end if;

  -- Crea o sostituisce una richiesta scaduta.
  update public.profile_edit_locks pel
  set
    takeover_requested_by_auth_user_id = current_auth_user_id,
    takeover_requested_by_client_id = target_client_id,
    takeover_requested_by_session_id = target_session_id,
    takeover_requested_at = server_now,
    takeover_granted_to_auth_user_id = null,
    takeover_granted_to_client_id = null,
    takeover_granted_to_session_id = null,
    takeover_granted_at = null,
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id;

  return jsonb_build_object('status', 'requested');
end;
$$;

revoke all
  on function public.request_profile_edit_takeover(uuid, uuid, uuid)
  from public;

grant execute
  on function public.request_profile_edit_takeover(uuid, uuid, uuid)
  to authenticated;

-- ============================================================================
-- UPDATE PLANTING
-- ============================================================================
-- Modifica i dati agronomici e spaziali di un Planting esistente.
--
-- Restano immutabili:
--
--   profile_id
--   garden_id
--   bed_id
--
-- status ed end_date non vengono gestiti da questa RPC.
-- Il lifecycle e' demandato a set_planting_status.
-- ============================================================================

create or replace function public.update_planting(
  target_profile_id uuid,
  target_planting_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  planting_season_id uuid,
  planting_crop_id uuid,
  planting_variety_id uuid,

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
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_id uuid;
  v_bed_id uuid;
  v_garden_timezone text;
  v_today date;

  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_current_season_id uuid;
  v_current_crop_id uuid;
  v_current_variety_id uuid;

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
  v_variety_is_active boolean;

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
    p.variety_id,

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
    v_current_variety_id,

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
  -- 9. CROP
  -- --------------------------------------------------------------------------

  select
    c.is_active
  into
    v_crop_is_active
  from public.crops c
  where c.id = planting_crop_id
    and c.profile_id = target_profile_id
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
  -- 10. VARIETY
  -- --------------------------------------------------------------------------

  if planting_variety_id is not null
  then
    select
      cv.is_active
    into
      v_variety_is_active
    from public.crop_varieties cv
    where cv.id = planting_variety_id
      and cv.crop_id = planting_crop_id
      and cv.profile_id = target_profile_id
    for update;

    if not found
    then
      return jsonb_build_object(
        'status', 'not_found'
      );
    end if;

    if v_variety_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_variety',
        'crop_id', planting_crop_id,
        'variety_id', planting_variety_id
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
  -- 13. DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current_season_id = planting_season_id
     and v_current_crop_id = planting_crop_id
     and v_current_variety_id is not distinct from planting_variety_id

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
    variety_id = planting_variety_id,

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
    'variety_id', planting_variety_id,

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
$$;


-- ============================================================================
-- PRIVILEGI UPDATE_PLANTING
-- ============================================================================

revoke all
  on function public.update_planting(
    uuid,
    uuid,
    bigint,

    uuid,
    uuid,
    text,

    uuid,
    uuid,
    uuid,

    text,
    date,

    integer,
    integer,

    integer,
    integer,
    integer,
    integer,

    integer,
    numeric,

    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_planting(
    uuid,
    uuid,
    bigint,

    uuid,
    uuid,
    text,

    uuid,
    uuid,
    uuid,

    text,
    date,

    integer,
    integer,

    integer,
    integer,
    integer,
    integer,

    integer,
    numeric,

    text
  )
  to authenticated;

-- ============================================================================
-- SET PLANTING STATUS
-- ============================================================================
-- Gestisce esclusivamente il lifecycle del Planting.
--
-- Transizioni consentite:
--
--   sown          -> growing
--   sown          -> removed
--
--   growing       -> harvest_ready
--   growing       -> removed
--
--   harvest_ready -> harvested
--   harvest_ready -> removed
--
--   harvested     -> finished
--   harvested     -> removed
--
--   finished      -> nessuna
--   removed       -> nessuna
--
-- end_date:
--
--   deve essere NULL per growing / harvest_ready / harvested
--   e' obbligatoria per finished / removed
-- ============================================================================

create or replace function public.set_planting_status(
  target_profile_id uuid,
  target_planting_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  target_status text,
  target_end_date date
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

  v_current_status text;
  v_current_start_date date;
  v_current_end_date date;

  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_today date;

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
  -- 3. LETTURA PLANTING
  -- --------------------------------------------------------------------------

  select
    p.garden_id,
    g.timezone,

    p.status,
    p.start_date,
    p.end_date,

    p.row_version,
    p.updated_at
  into
    v_garden_id,
    v_garden_timezone,

    v_current_status,
    v_current_start_date,
    v_current_end_date,

    v_current_row_version,
    v_current_updated_at
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
  -- 5. VALIDAZIONE STATO DESTINAZIONE
  -- --------------------------------------------------------------------------

  if target_status is null
     or target_status not in (
       'growing',
       'harvest_ready',
       'harvested',
       'finished',
       'removed'
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  -- --------------------------------------------------------------------------
  -- 6. DATI INVARIATI
  -- --------------------------------------------------------------------------

  if target_status = v_current_status
     and target_end_date is not distinct from v_current_end_date
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'planting_id', target_planting_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. MATRICE DELLE TRANSIZIONI
  -- --------------------------------------------------------------------------

  if not (
       (v_current_status = 'sown'
        and target_status in (
          'growing',
          'removed'
        ))

    or (v_current_status = 'growing'
        and target_status in (
          'harvest_ready',
          'removed'
        ))

    or (v_current_status = 'harvest_ready'
        and target_status in (
          'harvested',
          'removed'
        ))

    or (v_current_status = 'harvested'
        and target_status in (
          'finished',
          'removed'
        ))
  )
  then
    return jsonb_build_object(
      'status', 'invalid_transition',
      'planting_id', target_planting_id,
      'current_status', v_current_status,
      'target_status', target_status
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. VALIDAZIONE END_DATE
  -- --------------------------------------------------------------------------

  if target_status in (
       'finished',
       'removed'
     )
  then
    if target_end_date is null
       or not isfinite(target_end_date)
       or target_end_date < v_current_start_date
       or target_end_date > v_today
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

  else
    if target_end_date is not null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 9. RIVALIDAZIONE FINALE DELLA WRITE AUTHORITY
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
  -- 10. UPDATE
  -- --------------------------------------------------------------------------

  update public.plantings
  set
    status = target_status,
    end_date = case
      when target_status in (
        'finished',
        'removed'
      )
      then target_end_date
      else null
    end
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
      'Concurrent modification while updating planting status';
  end if;

  -- --------------------------------------------------------------------------
  -- 11. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',

    'planting_id', target_planting_id,
    'garden_id', v_garden_id,

    'previous_status', v_current_status,
    'status_value', target_status,

    'start_date', v_current_start_date,
    'end_date', case
      when target_status in (
        'finished',
        'removed'
      )
      then target_end_date
      else null
    end,

    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;


-- ============================================================================
-- PRIVILEGI SET_PLANTING_STATUS
-- ============================================================================

revoke all
  on function public.set_planting_status(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    date
  )
  from public, anon, authenticated;

grant execute
  on function public.set_planting_status(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    date
  )
  to authenticated;
