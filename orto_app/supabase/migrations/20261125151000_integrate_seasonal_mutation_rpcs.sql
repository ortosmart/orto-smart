
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
  -- La data finale pianificata ├¿ inclusiva.
  -- La data valid_to delle geometrie ├¿ esclusiva.
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

  begin
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
      raise sqlstate 'P4501' using message = 'Season plan not found';
    end if;

    -- Rivalidazione della Write Authority dopo il lock del piano.
    if not private.lock_profile_write_authority(
      target_profile_id,
      target_client_id,
      target_session_id,
      lock_token
    ) then
      raise sqlstate 'P4502' using message = 'Write authority lost after season plan lock';
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
  exception
    when sqlstate 'P4501' then
      return jsonb_build_object('status', 'not_found');
    when sqlstate 'P4502' then
      return jsonb_build_object('status', 'write_forbidden');
  end;
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

-- V1 fingerprint shared by Create registration and execution.
create function private.create_planned_planting_fingerprint_v1(
  target_garden_id uuid,
  target_season_id uuid,
  target_bed_id uuid,
  target_crop_id uuid,
  target_cultivar_id uuid,
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
returns bytea
language sql
stable
set search_path = ''
as $function$
  select pg_catalog.sha256(pg_catalog.convert_to(
    pg_catalog.jsonb_build_array(
      'create_planned_planting', 1,
      target_garden_id, target_season_id, target_bed_id, target_crop_id,
      target_cultivar_id, planting_start_method, planting_start_date,
      planting_end_date, planting_start_position_cm, planting_length_cm,
      planting_occupied_width_cm, planting_plant_spacing_cm,
      planting_row_spacing_cm, planting_rows_count, planting_plants_count,
      pg_catalog.trim_scale(planting_seed_quantity_g),
      nullif(pg_catalog.btrim(planting_notes), '')
    )::text, 'UTF8'
  ));
$function$;

revoke all on function private.create_planned_planting_fingerprint_v1(
  uuid, uuid, uuid, uuid, uuid, text, date, date,
  integer, integer, integer, integer, integer, integer, integer, numeric, text
) from public, anon, authenticated, service_role;

-- Locks the scope and validates the intent before any domain write.
create function private.inspect_mutation_intent_for_execution(
  target_profile_id uuid,
  target_operation_id uuid,
  target_operation_domain text,
  target_operation_type text,
  target_request_schema_version integer,
  target_request_fingerprint bytea,
  target_recovery_generation uuid,
  target_domain_generation uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
volatile
set search_path = ''
as $function$
declare
  current_recovery_generation uuid;
  current_domain_generation uuid;
  existing_operation private.mutation_operations%rowtype;
begin
  if auth.uid() is null
     or private.is_profile_owner(target_profile_id) is not true
  then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  if target_operation_id is null
     or target_operation_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_operation_domain is distinct from 'seasonal_planning'
     or target_request_schema_version is distinct from 1
     or octet_length(target_request_fingerprint) is distinct from 32
  then
    return jsonb_build_object('status', 'invalid_request');
  end if;

  current_recovery_generation := private.lock_mutation_operation_scope(
    target_profile_id, target_operation_domain
  );
  if current_recovery_generation is null then
    return jsonb_build_object('status', 'registry_unavailable');
  end if;

  if private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) is not true then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  select g.domain_generation into current_domain_generation
  from private.mutation_domain_generations as g
  where g.profile_id = target_profile_id
    and g.operation_domain = target_operation_domain;

  if current_domain_generation is null
     or current_recovery_generation is distinct from target_recovery_generation
     or current_domain_generation is distinct from target_domain_generation
  then
    return jsonb_build_object('status', 'generation_mismatch');
  end if;

  select operation.* into existing_operation
  from private.mutation_operations as operation
  where operation.profile_id = target_profile_id
    and operation.operation_id = target_operation_id;

  if not found then
    return jsonb_build_object('status', 'intent_not_registered');
  end if;

  if row(
    existing_operation.operation_domain, existing_operation.operation_type,
    existing_operation.request_schema_version,
    existing_operation.recovery_generation, existing_operation.domain_generation
  ) is distinct from row(
    target_operation_domain, target_operation_type, target_request_schema_version,
    target_recovery_generation, target_domain_generation
  ) or (
    existing_operation.request_fingerprint is not null
    and existing_operation.request_fingerprint is distinct from target_request_fingerprint
  ) then
    return jsonb_build_object('status', 'operation_conflict');
  end if;

  if existing_operation.operation_status = 'COMPLETED' then
    return jsonb_build_object(
      'status', 'COMPLETED', 'result', existing_operation.result_payload
    );
  end if;

  return jsonb_build_object('status', existing_operation.operation_status);
end;
$function$;

revoke all on function private.inspect_mutation_intent_for_execution(
  uuid, uuid, text, text, integer, bytea, uuid, uuid, uuid, uuid, text
) from public, anon, authenticated, service_role;

create function public.register_create_planned_planting(
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
  planting_notes text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  registration_status text;
begin
  fingerprint := private.create_planned_planting_fingerprint_v1(
    target_garden_id, target_season_id, target_bed_id, target_crop_id,
    target_cultivar_id, planting_start_method, planting_start_date,
    planting_end_date, planting_start_position_cm, planting_length_cm,
    planting_occupied_width_cm, planting_plant_spacing_cm,
    planting_row_spacing_cm, planting_rows_count, planting_plants_count,
    planting_seed_quantity_g, planting_notes
  );

  registration_status := private.register_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'create_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );

  if registration_status = 'PENDING' then
    return jsonb_build_object(
      'status', registration_status,
      'request_fingerprint', pg_catalog.encode(fingerprint, 'hex')
    );
  end if;

  return jsonb_build_object('status', registration_status);
end;
$function$;

revoke all on function public.register_create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.register_create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  to authenticated;

alter function public.create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text) set schema private;
revoke all on function private.create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text)
  from public, anon, authenticated, service_role;

create function public.create_planned_planting(
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
  planting_notes text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  intent jsonb;
  domain_result jsonb;
  domain_status text;
  receipt_entity_id uuid;
  receipt_outcome text;
begin
  fingerprint := private.create_planned_planting_fingerprint_v1(
    target_garden_id, target_season_id, target_bed_id, target_crop_id,
    target_cultivar_id, planting_start_method, planting_start_date,
    planting_end_date, planting_start_position_cm, planting_length_cm,
    planting_occupied_width_cm, planting_plant_spacing_cm,
    planting_row_spacing_cm, planting_rows_count, planting_plants_count,
    planting_seed_quantity_g, planting_notes
  );

  intent := private.inspect_mutation_intent_for_execution(
    target_profile_id, operation_id, 'seasonal_planning',
    'create_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if intent->>'status' = 'COMPLETED' then
    return intent->'result';
  end if;
  if intent->>'status' is distinct from 'PENDING' then
    return intent;
  end if;

  domain_result := private.create_planned_planting(
    target_profile_id, target_garden_id, target_season_id, target_bed_id, target_crop_id, target_cultivar_id, target_client_id, target_session_id, lock_token, planting_start_method, planting_start_date, planting_end_date, planting_start_position_cm, planting_length_cm, planting_occupied_width_cm, planting_plant_spacing_cm, planting_row_spacing_cm, planting_rows_count, planting_plants_count, planting_seed_quantity_g, planting_notes
  );
  domain_status := domain_result->>'status';

  case domain_status
    when 'created' then
      receipt_entity_id := (domain_result->>'planned_planting_id')::uuid;
      if receipt_entity_id is null then
        raise exception 'Create result is missing its entity ID';
      end if;
      receipt_outcome := 'succeeded';
    when 'write_forbidden', 'forbidden' then
      return domain_result;
    when 'not_found', 'invalid_input', 'blocked_by_inactive_garden',
         'blocked_by_inactive_bed', 'blocked_by_inactive_crop',
         'blocked_by_inactive_cultivar', 'missing_bed_geometry',
         'outside_bed_geometry' then
      receipt_outcome := 'rejected';
    else
      raise exception 'Unexpected Create result status: %', domain_status;
  end case;

  perform private.complete_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'create_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, receipt_entity_id,
    receipt_outcome, domain_status, domain_result
  );

  return domain_result;
end;
$function$;

revoke all on function public.create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.create_planned_planting(uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  to authenticated;

create function private.update_planned_planting_fingerprint_v1(
  target_planned_planting_id uuid,
  expected_row_version bigint,
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
returns bytea
language sql
stable
set search_path = ''
as $function$
  select pg_catalog.sha256(pg_catalog.convert_to(
    pg_catalog.jsonb_build_array(
      'update_planned_planting', 1,
      target_planned_planting_id,
      expected_row_version,
      planting_bed_id,
      planting_crop_id,
      planting_cultivar_id,
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
      pg_catalog.trim_scale(planting_seed_quantity_g),
      nullif(pg_catalog.btrim(planting_notes), '')
    )::text, 'UTF8'
  ));
$function$;

revoke all on function private.update_planned_planting_fingerprint_v1(uuid, bigint, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text)
  from public, anon, authenticated, service_role;

create function public.register_update_planned_planting(
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
  planting_notes text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  registration_status text;
begin
  fingerprint := private.update_planned_planting_fingerprint_v1(
    target_planned_planting_id,
    expected_row_version,
    planting_bed_id,
    planting_crop_id,
    planting_cultivar_id,
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
    planting_notes
  );

  registration_status := private.register_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'update_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );

  if registration_status = 'PENDING' then
    return jsonb_build_object(
      'status', registration_status,
      'request_fingerprint', pg_catalog.encode(fingerprint, 'hex')
    );
  end if;

  return jsonb_build_object('status', registration_status);
end;
$function$;

revoke all on function public.register_update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.register_update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  to authenticated;

alter function public.update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text) set schema private;
revoke all on function private.update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text)
  from public, anon, authenticated, service_role;

create function public.update_planned_planting(
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
  planting_notes text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  intent jsonb;
  domain_result jsonb;
  domain_status text;
  receipt_outcome text;
begin
  fingerprint := private.update_planned_planting_fingerprint_v1(
    target_planned_planting_id,
    expected_row_version,
    planting_bed_id,
    planting_crop_id,
    planting_cultivar_id,
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
    planting_notes
  );
  intent := private.inspect_mutation_intent_for_execution(
    target_profile_id, operation_id, 'seasonal_planning',
    'update_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if intent->>'status' = 'COMPLETED' then
    return intent->'result';
  end if;
  if intent->>'status' is distinct from 'PENDING' then
    return intent;
  end if;

  domain_result := private.update_planned_planting(
    target_profile_id,
    target_planned_planting_id,
    expected_row_version,
    target_client_id,
    target_session_id,
    lock_token,
    planting_bed_id,
    planting_crop_id,
    planting_cultivar_id,
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
    planting_notes
  );
  domain_status := domain_result->>'status';
  case domain_status
    when 'updated' then
      if (domain_result->>'planned_planting_id')::uuid is distinct from target_planned_planting_id then
        raise exception 'Update result has an unexpected entity ID';
      end if;
      receipt_outcome := 'succeeded';
    when 'write_forbidden', 'forbidden' then
      return domain_result;
    when 'not_found', 'invalid_input', 'version_conflict',
         'blocked_by_lifecycle', 'blocked_by_inactive_garden',
         'blocked_by_inactive_bed', 'blocked_by_inactive_crop',
         'blocked_by_inactive_cultivar', 'missing_bed_geometry',
         'outside_bed_geometry', 'overlap' then
      receipt_outcome := 'rejected';
    else
      raise exception 'Unexpected Update result status: %', domain_status;
  end case;

  perform private.complete_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'update_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_planned_planting_id,
    receipt_outcome, domain_status, domain_result
  );
  return domain_result;
end;
$function$;

revoke all on function public.update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.update_planned_planting(uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date, date, integer, integer, integer, integer, integer, integer, integer, numeric, text, uuid, integer, uuid, uuid)
  to authenticated;

create function private.confirm_planned_planting_fingerprint_v1(
  target_planned_planting_id uuid,
  expected_row_version bigint
)
returns bytea
language sql
stable
set search_path = ''
as $function$
  select pg_catalog.sha256(pg_catalog.convert_to(
    pg_catalog.jsonb_build_array(
      'confirm_planned_planting', 1,
      target_planned_planting_id, expected_row_version
    )::text, 'UTF8'
  ));
$function$;

revoke all on function private.confirm_planned_planting_fingerprint_v1(uuid, bigint)
  from public, anon, authenticated, service_role;

create function public.register_confirm_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  registration_status text;
begin
  fingerprint := private.confirm_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version
  );
  registration_status := private.register_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'confirm_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if registration_status = 'PENDING' then
    return jsonb_build_object(
      'status', registration_status,
      'request_fingerprint', pg_catalog.encode(fingerprint, 'hex')
    );
  end if;
  return jsonb_build_object('status', registration_status);
end;
$function$;

revoke all on function public.register_confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.register_confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) to authenticated;

alter function public.confirm_planned_planting(uuid, uuid, bigint, uuid, uuid, text) set schema private;
revoke all on function private.confirm_planned_planting(uuid, uuid, bigint, uuid, uuid, text)
  from public, anon, authenticated, service_role;

create function public.confirm_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  intent jsonb;
  domain_result jsonb;
  domain_status text;
  receipt_outcome text;
begin
  fingerprint := private.confirm_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version
  );
  intent := private.inspect_mutation_intent_for_execution(
    target_profile_id, operation_id, 'seasonal_planning',
    'confirm_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if intent->>'status' = 'COMPLETED' then
    return intent->'result';
  end if;
  if intent->>'status' is distinct from 'PENDING' then
    return intent;
  end if;

  domain_result := private.confirm_planned_planting(
    target_profile_id, target_planned_planting_id, expected_row_version,
    target_client_id, target_session_id, lock_token
  );
  domain_status := domain_result->>'status';
  case domain_status
    when 'confirmed' then
      if (domain_result->>'planned_planting_id')::uuid is distinct from target_planned_planting_id then
        raise exception 'Confirm result has an unexpected entity ID';
      end if;
      receipt_outcome := 'succeeded';
    when 'write_forbidden', 'forbidden' then
      return domain_result;
    when 'not_found', 'version_conflict', 'blocked_by_lifecycle',
         'inactive_garden', 'inactive_bed', 'missing_bed_geometry',
         'outside_bed_geometry', 'overlap' then
      receipt_outcome := 'rejected';
    else
      raise exception 'Unexpected Confirm result status: %', domain_status;
  end case;

  perform private.complete_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'confirm_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_planned_planting_id,
    receipt_outcome, domain_status, domain_result
  );
  return domain_result;
end;
$function$;

revoke all on function public.confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.confirm_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) to authenticated;

create function private.cancel_planned_planting_fingerprint_v1(
  target_planned_planting_id uuid,
  expected_row_version bigint
)
returns bytea
language sql
stable
set search_path = ''
as $function$
  select pg_catalog.sha256(pg_catalog.convert_to(
    pg_catalog.jsonb_build_array(
      'cancel_planned_planting', 1,
      target_planned_planting_id, expected_row_version
    )::text, 'UTF8'
  ));
$function$;

revoke all on function private.cancel_planned_planting_fingerprint_v1(uuid, bigint)
  from public, anon, authenticated, service_role;

create function public.register_cancel_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  registration_status text;
begin
  fingerprint := private.cancel_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version
  );
  registration_status := private.register_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'cancel_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if registration_status = 'PENDING' then
    return jsonb_build_object(
      'status', registration_status,
      'request_fingerprint', pg_catalog.encode(fingerprint, 'hex')
    );
  end if;
  return jsonb_build_object('status', registration_status);
end;
$function$;

revoke all on function public.register_cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.register_cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) to authenticated;

alter function public.cancel_planned_planting(uuid, uuid, bigint, uuid, uuid, text) set schema private;
revoke all on function private.cancel_planned_planting(uuid, uuid, bigint, uuid, uuid, text)
  from public, anon, authenticated, service_role;

create function public.cancel_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  intent jsonb;
  domain_result jsonb;
  domain_status text;
  receipt_outcome text;
begin
  fingerprint := private.cancel_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version
  );
  intent := private.inspect_mutation_intent_for_execution(
    target_profile_id, operation_id, 'seasonal_planning',
    'cancel_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if intent->>'status' = 'COMPLETED' then
    return intent->'result';
  end if;
  if intent->>'status' is distinct from 'PENDING' then
    return intent;
  end if;

  domain_result := private.cancel_planned_planting(
    target_profile_id, target_planned_planting_id, expected_row_version,
    target_client_id, target_session_id, lock_token
  );
  domain_status := domain_result->>'status';
  case domain_status
    when 'cancelled' then
      if (domain_result->>'planned_planting_id')::uuid is distinct from target_planned_planting_id then
        raise exception 'Cancel result has an unexpected entity ID';
      end if;
      receipt_outcome := 'succeeded';
    when 'write_forbidden', 'forbidden' then
      return domain_result;
    when 'not_found', 'version_conflict', 'blocked_by_lifecycle' then
      receipt_outcome := 'rejected';
    else
      raise exception 'Unexpected Cancel result status: %', domain_status;
  end case;

  perform private.complete_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'cancel_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_planned_planting_id,
    receipt_outcome, domain_status, domain_result
  );
  return domain_result;
end;
$function$;

revoke all on function public.cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, integer, uuid, uuid
) to authenticated;

create function private.execute_planned_planting_fingerprint_v1(
  target_planned_planting_id uuid,
  expected_row_version bigint,
  effective_start_date date
)
returns bytea
language sql
stable
set search_path = ''
as $function$
  select pg_catalog.sha256(pg_catalog.convert_to(
    pg_catalog.jsonb_build_array(
      'execute_planned_planting', 1,
      target_planned_planting_id, expected_row_version, effective_start_date
    )::text, 'UTF8'
  ));
$function$;

revoke all on function private.execute_planned_planting_fingerprint_v1(uuid, bigint, date)
  from public, anon, authenticated, service_role;

create function public.register_execute_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  effective_start_date date,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  registration_status text;
begin
  fingerprint := private.execute_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version, effective_start_date
  );
  registration_status := private.register_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'execute_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if registration_status = 'PENDING' then
    return jsonb_build_object(
      'status', registration_status,
      'request_fingerprint', pg_catalog.encode(fingerprint, 'hex')
    );
  end if;
  return jsonb_build_object('status', registration_status);
end;
$function$;

revoke all on function public.register_execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.register_execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date, uuid, integer, uuid, uuid
) to authenticated;

alter function public.execute_planned_planting(uuid, uuid, bigint, uuid, uuid, text, date) set schema private;
revoke all on function private.execute_planned_planting(uuid, uuid, bigint, uuid, uuid, text, date)
  from public, anon, authenticated, service_role;

create function public.execute_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  effective_start_date date,
  operation_id uuid,
  request_schema_version integer,
  recovery_generation uuid,
  domain_generation uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  fingerprint bytea;
  intent jsonb;
  domain_result jsonb;
  domain_status text;
  receipt_outcome text;
begin
  fingerprint := private.execute_planned_planting_fingerprint_v1(
    target_planned_planting_id, expected_row_version, effective_start_date
  );
  intent := private.inspect_mutation_intent_for_execution(
    target_profile_id, operation_id, 'seasonal_planning',
    'execute_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_client_id,
    target_session_id, lock_token
  );
  if intent->>'status' = 'COMPLETED' then
    return intent->'result';
  end if;
  if intent->>'status' is distinct from 'PENDING' then
    return intent;
  end if;

  domain_result := private.execute_planned_planting(
    target_profile_id, target_planned_planting_id, expected_row_version,
    target_client_id, target_session_id, lock_token, effective_start_date
  );
  domain_status := domain_result->>'status';
  case domain_status
    when 'executed' then
      if (domain_result->>'planned_planting_id')::uuid is distinct from target_planned_planting_id
         or (domain_result->>'planting_id')::uuid is null then
        raise exception 'Execute result has missing or unexpected entity IDs';
      end if;
      receipt_outcome := 'succeeded';
    when 'forbidden', 'write_forbidden' then
      return domain_result;
    when 'invalid_input', 'not_found', 'version_conflict',
         'blocked_by_lifecycle', 'blocked_by_confirmed_plans',
         'blocked_by_inactive_bed', 'blocked_by_inactive_crop',
         'blocked_by_inactive_cultivar', 'blocked_by_inactive_garden',
         'outside_bed_geometry', 'overlap' then
      receipt_outcome := 'rejected';
    else
      raise exception 'Unexpected Execute result status: %', domain_status;
  end case;

  perform private.complete_mutation_intent(
    target_profile_id, operation_id, 'seasonal_planning',
    'execute_planned_planting', request_schema_version, fingerprint,
    recovery_generation, domain_generation, target_planned_planting_id,
    receipt_outcome, domain_status, domain_result
  );
  return domain_result;
end;
$function$;

revoke all on function public.execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date, uuid, integer, uuid, uuid
) from public, anon, authenticated, service_role;
grant execute on function public.execute_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text, date, uuid, integer, uuid, uuid
) to authenticated;

create function public.get_seasonal_planning_mutation_generations(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  generations jsonb;
begin
  generations := private.get_or_initialize_mutation_generations(
    target_profile_id, 'seasonal_planning', target_client_id,
    target_session_id, lock_token
  );
  if generations is null then
    return jsonb_build_object('status', 'registry_unavailable');
  end if;
  return generations || jsonb_build_object('status', 'ready');
end;
$function$;

revoke all on function public.get_seasonal_planning_mutation_generations(uuid, uuid, uuid, text)
  from public, anon, authenticated, service_role;
grant execute on function public.get_seasonal_planning_mutation_generations(uuid, uuid, uuid, text)
  to authenticated;
