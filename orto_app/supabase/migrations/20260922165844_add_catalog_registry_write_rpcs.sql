-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 9B - WRITE PATH REGISTRY E VOCABOLARI DI CONTESTO
-- ============================================================================
-- Revisione corretta dopo validazione locale della funzione NULLIF.
--
-- Introduce il Write Path autoritativo per:
-- - measurement_units;
-- - agronomic_parameters;
-- - parameter_enum_values;
-- - production_contexts;
-- - protection_contexts;
-- - training_contexts;
-- - harvest_purposes.
--
-- Le RPC derivano sempre l attore da auth.uid(), non usano Profile lock,
-- applicano optimistic concurrency e non inseriscono dati dimostrativi.
-- ============================================================================


-- ============================================================================
-- 1. HELPER PRIVATI
-- ============================================================================

create function private.clean_catalog_master_text(
  input_value text
)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $function$
  select pg_catalog.regexp_replace(
    pg_catalog.btrim(input_value),
    '[[:space:]]+',
    ' ',
    'g'
  );
$function$;

create function private.clean_catalog_master_description(
  input_value text
)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $function$
  select nullif(pg_catalog.btrim(input_value), '');
$function$;

create function private.is_measurement_unit_semantically_frozen(
  target_unit_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select
    exists (
      select 1
      from public.agronomic_observations ao
      where ao.status = 'NORMALIZED'
        and ao.unit_id = target_unit_id
    )
    or exists (
      select 1
      from public.candidate_submissions cs
      where cs.unit_id = target_unit_id
    )
    or exists (
      select 1
      from public.agronomic_assertions aa
      where aa.unit_id = target_unit_id
    )
    or exists (
      select 1
      from public.agronomic_parameters ap
      where ap.canonical_unit_id = target_unit_id
        and private.is_agronomic_parameter_semantically_frozen(ap.id)
    );
$function$;

create function private.is_parameter_enum_value_semantically_frozen(
  target_enum_value_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select
    exists (
      select 1
      from public.agronomic_observations ao
      where ao.status = 'NORMALIZED'
        and ao.enum_value_id = target_enum_value_id
    )
    or exists (
      select 1
      from public.candidate_submissions cs
      where cs.enum_value_id = target_enum_value_id
    )
    or exists (
      select 1
      from public.agronomic_assertions aa
      where aa.enum_value_id = target_enum_value_id
    );
$function$;

create function private.catalog_master_has_live_dependency(
  target_kind text,
  target_id uuid
)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  case target_kind
    when 'UNIT' then
      return
        exists (
          select 1
          from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.unit_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.unit_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.unit_id = target_id
        );

    when 'PARAMETER' then
      return
        exists (
          select 1
          from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.parameter_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.parameter_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.parameter_id = target_id
        );

    when 'ENUM_VALUE' then
      return
        exists (
          select 1
          from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.enum_value_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.enum_value_id = target_id
        )
        or exists (
          select 1
          from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.enum_value_id = target_id
        );

    when 'PRODUCTION_CONTEXT' then
      return
        exists (
          select 1 from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.production_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.production_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.production_context_id = target_id
        );

    when 'PROTECTION_CONTEXT' then
      return
        exists (
          select 1 from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.protection_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.protection_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.protection_context_id = target_id
        );

    when 'TRAINING_CONTEXT' then
      return
        exists (
          select 1 from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.training_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.training_context_id = target_id
        )
        or exists (
          select 1 from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.training_context_id = target_id
        );

    when 'HARVEST_PURPOSE' then
      return
        exists (
          select 1 from public.agronomic_observations ao
          where ao.status = 'PENDING'
            and ao.harvest_purpose_id = target_id
        )
        or exists (
          select 1 from public.agronomic_candidates ac
          where ac.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED')
            and ac.harvest_purpose_id = target_id
        )
        or exists (
          select 1 from public.agronomic_assertions aa
          where aa.status = 'APPROVED'
            and aa.harvest_purpose_id = target_id
        );

    else
      raise exception using
        errcode = '22023',
        message = 'Unknown Catalog master dependency kind';
  end case;
end;
$function$;

revoke all
  on function private.clean_catalog_master_text(text)
  from public, anon, authenticated;
revoke all
  on function private.clean_catalog_master_description(text)
  from public, anon, authenticated;
revoke all
  on function private.is_measurement_unit_semantically_frozen(uuid)
  from public, anon, authenticated;
revoke all
  on function private.is_parameter_enum_value_semantically_frozen(uuid)
  from public, anon, authenticated;
revoke all
  on function private.catalog_master_has_live_dependency(text, uuid)
  from public, anon, authenticated;


-- ============================================================================
-- 2. MEASUREMENT UNITS
-- ============================================================================

create function public.create_measurement_unit(
  unit_code text,
  unit_name text,
  unit_symbol text,
  unit_quantity_kind text,
  unit_to_base_factor numeric,
  unit_to_base_offset numeric,
  unit_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_symbol text;
  v_quantity_kind text;
  v_description text;
  v_row public.measurement_units;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(unit_code));
  v_name := private.clean_catalog_master_text(unit_name);
  v_symbol := private.clean_catalog_master_text(unit_symbol);
  v_quantity_kind :=
    pg_catalog.upper(pg_catalog.btrim(unit_quantity_kind));
  v_description :=
    private.clean_catalog_master_description(unit_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,49}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or v_symbol is null or v_symbol = '' or char_length(v_symbol) > 30
     or v_quantity_kind is null
     or v_quantity_kind !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or unit_to_base_factor is null
     or unit_to_base_factor <= 0
     or unit_to_base_factor in (
       'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
     )
     or unit_to_base_offset is null
     or unit_to_base_offset in (
       'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
     )
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  begin
    insert into public.measurement_units (
      code, name, symbol, quantity_kind,
      to_base_factor, to_base_offset, description, is_active
    )
    values (
      v_code, v_name, v_symbol, v_quantity_kind,
      unit_to_base_factor, unit_to_base_offset, v_description, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'measurement_unit_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_measurement_unit(
  target_measurement_unit_id uuid,
  expected_row_version bigint,
  unit_code text,
  unit_name text,
  unit_symbol text,
  unit_quantity_kind text,
  unit_to_base_factor numeric,
  unit_to_base_offset numeric,
  unit_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.measurement_units;
  v_row public.measurement_units;
  v_code text;
  v_name text;
  v_symbol text;
  v_quantity_kind text;
  v_description text;
  v_semantic_change boolean;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_measurement_unit_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(unit_code));
  v_name := private.clean_catalog_master_text(unit_name);
  v_symbol := private.clean_catalog_master_text(unit_symbol);
  v_quantity_kind :=
    pg_catalog.upper(pg_catalog.btrim(unit_quantity_kind));
  v_description :=
    private.clean_catalog_master_description(unit_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,49}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or v_symbol is null or v_symbol = '' or char_length(v_symbol) > 30
     or v_quantity_kind is null
     or v_quantity_kind !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or unit_to_base_factor is null
     or unit_to_base_factor <= 0
     or unit_to_base_factor in (
       'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
     )
     or unit_to_base_offset is null
     or unit_to_base_offset in (
       'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
     )
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.measurement_units mu
  where mu.id = target_measurement_unit_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.code = v_code
     and v_current.name = v_name
     and v_current.symbol = v_symbol
     and v_current.quantity_kind = v_quantity_kind
     and v_current.to_base_factor = unit_to_base_factor
     and v_current.to_base_offset = unit_to_base_offset
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'measurement_unit_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  v_semantic_change :=
    v_current.code is distinct from v_code
    or v_current.quantity_kind is distinct from v_quantity_kind
    or v_current.to_base_factor is distinct from unit_to_base_factor
    or v_current.to_base_offset is distinct from unit_to_base_offset;

  if v_semantic_change
     and private.is_measurement_unit_semantically_frozen(
       target_measurement_unit_id
     ) then
    return jsonb_build_object('status', 'semantics_frozen');
  end if;

  if v_current.quantity_kind is distinct from v_quantity_kind
     and exists (
       select 1
       from public.agronomic_parameters ap
       where ap.canonical_unit_id = target_measurement_unit_id
     ) then
    return jsonb_build_object('status', 'unit_in_use');
  end if;

  begin
    update public.measurement_units
    set
      code = v_code,
      name = v_name,
      symbol = v_symbol,
      quantity_kind = v_quantity_kind,
      to_base_factor = unit_to_base_factor,
      to_base_offset = unit_to_base_offset,
      description = v_description
    where id = target_measurement_unit_id
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
    when check_violation then
      return jsonb_build_object('status', 'semantics_frozen');
  end;

  return jsonb_build_object(
    'status', 'updated',
    'measurement_unit_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_measurement_unit_active(
  target_measurement_unit_id uuid,
  expected_row_version bigint,
  unit_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.measurement_units;
  v_row public.measurement_units;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_measurement_unit_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or unit_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.measurement_units mu
  where mu.id = target_measurement_unit_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = unit_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'measurement_unit_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if not unit_is_active
     and (
       exists (
         select 1
         from public.agronomic_parameters ap
         where ap.canonical_unit_id = target_measurement_unit_id
           and ap.is_active
       )
       or private.catalog_master_has_live_dependency(
         'UNIT',
         target_measurement_unit_id
       )
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.measurement_units
  set is_active = unit_is_active
  where id = target_measurement_unit_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'measurement_unit_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;


-- ============================================================================
-- 3. AGRONOMIC PARAMETERS
-- ============================================================================

create function public.create_agronomic_parameter(
  parameter_code text,
  parameter_name text,
  parameter_description text,
  parameter_value_schema text,
  parameter_knowledge_scope text,
  parameter_quantity_kind text,
  parameter_canonical_unit_id uuid,
  parameter_allows_crop boolean,
  parameter_allows_cultivar boolean,
  parameter_allows_production_context boolean,
  parameter_allows_protection_context boolean,
  parameter_allows_training_context boolean,
  parameter_allows_harvest_purpose boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_description text;
  v_value_schema text;
  v_knowledge_scope text;
  v_quantity_kind text;
  v_unit public.measurement_units;
  v_row public.agronomic_parameters;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(parameter_code));
  v_name := private.clean_catalog_master_text(parameter_name);
  v_description :=
    private.clean_catalog_master_description(parameter_description);
  v_value_schema :=
    pg_catalog.upper(pg_catalog.btrim(parameter_value_schema));
  v_knowledge_scope :=
    pg_catalog.upper(pg_catalog.btrim(parameter_knowledge_scope));
  v_quantity_kind := case
    when parameter_quantity_kind is null then null
    else pg_catalog.upper(pg_catalog.btrim(parameter_quantity_kind))
  end;

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     )
     or v_value_schema is null
     or v_value_schema not in (
       'NUMERIC_SCALAR', 'NUMERIC_RANGE', 'BOOLEAN', 'ENUM'
     )
     or v_knowledge_scope is null
     or v_knowledge_scope not in ('INTRINSIC', 'CONTEXTUAL')
     or parameter_allows_crop is null
     or parameter_allows_cultivar is null
     or parameter_allows_production_context is null
     or parameter_allows_protection_context is null
     or parameter_allows_training_context is null
     or parameter_allows_harvest_purpose is null
     or not (
       parameter_allows_crop
       or parameter_allows_cultivar
     )
     or (
       v_knowledge_scope = 'INTRINSIC'
       and (
         parameter_allows_production_context
         or parameter_allows_protection_context
         or parameter_allows_training_context
         or parameter_allows_harvest_purpose
       )
     )
     or (
       v_knowledge_scope = 'CONTEXTUAL'
       and not (
         parameter_allows_production_context
         or parameter_allows_protection_context
         or parameter_allows_training_context
         or parameter_allows_harvest_purpose
       )
     )
     or (
       v_value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE')
       and (
         v_quantity_kind is null
         or v_quantity_kind !~ '^[A-Z][A-Z0-9_]{0,79}$'
         or parameter_canonical_unit_id is null
       )
     )
     or (
       v_value_schema in ('BOOLEAN', 'ENUM')
       and (
         v_quantity_kind is not null
         or parameter_canonical_unit_id is not null
       )
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  if v_value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
    select *
    into v_unit
    from public.measurement_units mu
    where mu.id = parameter_canonical_unit_id
    for share;

    if not found then
      return jsonb_build_object('status', 'unit_not_found');
    end if;

    if not v_unit.is_active
       or v_unit.quantity_kind <> v_quantity_kind then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  begin
    insert into public.agronomic_parameters (
      code, name, description,
      value_schema, knowledge_scope,
      quantity_kind, canonical_unit_id,
      allows_crop, allows_cultivar,
      allows_production_context, allows_protection_context,
      allows_training_context, allows_harvest_purpose,
      is_active
    )
    values (
      v_code, v_name, v_description,
      v_value_schema, v_knowledge_scope,
      v_quantity_kind, parameter_canonical_unit_id,
      parameter_allows_crop, parameter_allows_cultivar,
      parameter_allows_production_context,
      parameter_allows_protection_context,
      parameter_allows_training_context,
      parameter_allows_harvest_purpose,
      true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'agronomic_parameter_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_agronomic_parameter(
  target_agronomic_parameter_id uuid,
  expected_row_version bigint,
  parameter_code text,
  parameter_name text,
  parameter_description text,
  parameter_value_schema text,
  parameter_knowledge_scope text,
  parameter_quantity_kind text,
  parameter_canonical_unit_id uuid,
  parameter_allows_crop boolean,
  parameter_allows_cultivar boolean,
  parameter_allows_production_context boolean,
  parameter_allows_protection_context boolean,
  parameter_allows_training_context boolean,
  parameter_allows_harvest_purpose boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.agronomic_parameters;
  v_row public.agronomic_parameters;
  v_unit public.measurement_units;
  v_code text;
  v_name text;
  v_description text;
  v_value_schema text;
  v_knowledge_scope text;
  v_quantity_kind text;
  v_semantic_change boolean;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_agronomic_parameter_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(parameter_code));
  v_name := private.clean_catalog_master_text(parameter_name);
  v_description :=
    private.clean_catalog_master_description(parameter_description);
  v_value_schema :=
    pg_catalog.upper(pg_catalog.btrim(parameter_value_schema));
  v_knowledge_scope :=
    pg_catalog.upper(pg_catalog.btrim(parameter_knowledge_scope));
  v_quantity_kind := case
    when parameter_quantity_kind is null then null
    else pg_catalog.upper(pg_catalog.btrim(parameter_quantity_kind))
  end;

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     )
     or v_value_schema is null
     or v_value_schema not in (
       'NUMERIC_SCALAR', 'NUMERIC_RANGE', 'BOOLEAN', 'ENUM'
     )
     or v_knowledge_scope is null
     or v_knowledge_scope not in ('INTRINSIC', 'CONTEXTUAL')
     or parameter_allows_crop is null
     or parameter_allows_cultivar is null
     or parameter_allows_production_context is null
     or parameter_allows_protection_context is null
     or parameter_allows_training_context is null
     or parameter_allows_harvest_purpose is null
     or not (
       parameter_allows_crop
       or parameter_allows_cultivar
     )
     or (
       v_knowledge_scope = 'INTRINSIC'
       and (
         parameter_allows_production_context
         or parameter_allows_protection_context
         or parameter_allows_training_context
         or parameter_allows_harvest_purpose
       )
     )
     or (
       v_knowledge_scope = 'CONTEXTUAL'
       and not (
         parameter_allows_production_context
         or parameter_allows_protection_context
         or parameter_allows_training_context
         or parameter_allows_harvest_purpose
       )
     )
     or (
       v_value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE')
       and (
         v_quantity_kind is null
         or v_quantity_kind !~ '^[A-Z][A-Z0-9_]{0,79}$'
         or parameter_canonical_unit_id is null
       )
     )
     or (
       v_value_schema in ('BOOLEAN', 'ENUM')
       and (
         v_quantity_kind is not null
         or parameter_canonical_unit_id is not null
       )
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.agronomic_parameters ap
  where ap.id = target_agronomic_parameter_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
    select *
    into v_unit
    from public.measurement_units mu
    where mu.id = parameter_canonical_unit_id
    for share;

    if not found then
      return jsonb_build_object('status', 'unit_not_found');
    end if;

    if not v_unit.is_active
       or v_unit.quantity_kind <> v_quantity_kind then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  if v_current.code = v_code
     and v_current.name = v_name
     and v_current.description is not distinct from v_description
     and v_current.value_schema = v_value_schema
     and v_current.knowledge_scope = v_knowledge_scope
     and v_current.quantity_kind is not distinct from v_quantity_kind
     and v_current.canonical_unit_id
           is not distinct from parameter_canonical_unit_id
     and v_current.allows_crop = parameter_allows_crop
     and v_current.allows_cultivar = parameter_allows_cultivar
     and v_current.allows_production_context =
           parameter_allows_production_context
     and v_current.allows_protection_context =
           parameter_allows_protection_context
     and v_current.allows_training_context =
           parameter_allows_training_context
     and v_current.allows_harvest_purpose =
           parameter_allows_harvest_purpose then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_parameter_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  v_semantic_change :=
    v_current.code is distinct from v_code
    or v_current.value_schema is distinct from v_value_schema
    or v_current.quantity_kind is distinct from v_quantity_kind
    or v_current.canonical_unit_id
         is distinct from parameter_canonical_unit_id
    or v_current.knowledge_scope is distinct from v_knowledge_scope
    or v_current.allows_crop is distinct from parameter_allows_crop
    or v_current.allows_cultivar is distinct from parameter_allows_cultivar
    or v_current.allows_production_context
         is distinct from parameter_allows_production_context
    or v_current.allows_protection_context
         is distinct from parameter_allows_protection_context
    or v_current.allows_training_context
         is distinct from parameter_allows_training_context
    or v_current.allows_harvest_purpose
         is distinct from parameter_allows_harvest_purpose;

  if v_semantic_change
     and private.is_agronomic_parameter_semantically_frozen(
       target_agronomic_parameter_id
     ) then
    return jsonb_build_object('status', 'semantics_frozen');
  end if;

  if v_current.value_schema = 'ENUM'
     and v_value_schema <> 'ENUM'
     and exists (
       select 1
       from public.parameter_enum_values pev
       where pev.parameter_id = target_agronomic_parameter_id
     ) then
    return jsonb_build_object('status', 'enum_values_exist');
  end if;

  begin
    update public.agronomic_parameters
    set
      code = v_code,
      name = v_name,
      description = v_description,
      value_schema = v_value_schema,
      knowledge_scope = v_knowledge_scope,
      quantity_kind = v_quantity_kind,
      canonical_unit_id = parameter_canonical_unit_id,
      allows_crop = parameter_allows_crop,
      allows_cultivar = parameter_allows_cultivar,
      allows_production_context =
        parameter_allows_production_context,
      allows_protection_context =
        parameter_allows_protection_context,
      allows_training_context =
        parameter_allows_training_context,
      allows_harvest_purpose =
        parameter_allows_harvest_purpose
    where id = target_agronomic_parameter_id
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
    when check_violation then
      return jsonb_build_object('status', 'semantics_frozen');
  end;

  return jsonb_build_object(
    'status', 'updated',
    'agronomic_parameter_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_agronomic_parameter_active(
  target_agronomic_parameter_id uuid,
  expected_row_version bigint,
  parameter_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.agronomic_parameters;
  v_unit public.measurement_units;
  v_row public.agronomic_parameters;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_agronomic_parameter_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or parameter_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.agronomic_parameters ap
  where ap.id = target_agronomic_parameter_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = parameter_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_parameter_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if parameter_is_active
     and v_current.value_schema in (
       'NUMERIC_SCALAR', 'NUMERIC_RANGE'
     ) then
    select *
    into v_unit
    from public.measurement_units mu
    where mu.id = v_current.canonical_unit_id
    for share;

    if not found
       or not v_unit.is_active
       or v_unit.quantity_kind <> v_current.quantity_kind then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  if not parameter_is_active
     and (
       exists (
         select 1
         from public.parameter_enum_values pev
         where pev.parameter_id = target_agronomic_parameter_id
           and pev.is_active
       )
       or private.catalog_master_has_live_dependency(
         'PARAMETER',
         target_agronomic_parameter_id
       )
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.agronomic_parameters
  set is_active = parameter_is_active
  where id = target_agronomic_parameter_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'agronomic_parameter_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;


-- ============================================================================
-- 4. PARAMETER ENUM VALUES
-- ============================================================================

create function public.create_parameter_enum_value(
  target_parameter_id uuid,
  enum_code text,
  enum_name text,
  enum_description text,
  enum_sort_order integer
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_parameter public.agronomic_parameters;
  v_code text;
  v_name text;
  v_description text;
  v_row public.parameter_enum_values;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(enum_code));
  v_name := private.clean_catalog_master_text(enum_name);
  v_description :=
    private.clean_catalog_master_description(enum_description);

  if target_parameter_id is null
     or v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     )
     or enum_sort_order is null
     or enum_sort_order < 0 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_parameter
  from public.agronomic_parameters ap
  where ap.id = target_parameter_id
  for share;

  if not found then
    return jsonb_build_object('status', 'parameter_not_found');
  end if;

  if v_parameter.value_schema <> 'ENUM' then
    return jsonb_build_object('status', 'parameter_not_enum');
  end if;

  if not v_parameter.is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.parameter_enum_values (
      parameter_id, code, name, description,
      sort_order, is_active
    )
    values (
      target_parameter_id, v_code, v_name, v_description,
      enum_sort_order, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'parameter_enum_value_id', v_row.id,
    'parameter_id', v_row.parameter_id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_parameter_enum_value(
  target_parameter_enum_value_id uuid,
  expected_row_version bigint,
  target_parameter_id uuid,
  enum_code text,
  enum_name text,
  enum_description text,
  enum_sort_order integer
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.parameter_enum_values;
  v_parameter public.agronomic_parameters;
  v_row public.parameter_enum_values;
  v_code text;
  v_name text;
  v_description text;
  v_semantic_change boolean;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_parameter_enum_value_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_parameter_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(enum_code));
  v_name := private.clean_catalog_master_text(enum_name);
  v_description :=
    private.clean_catalog_master_description(enum_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     )
     or enum_sort_order is null
     or enum_sort_order < 0 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.parameter_enum_values pev
  where pev.id = target_parameter_enum_value_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  select *
  into v_parameter
  from public.agronomic_parameters ap
  where ap.id = target_parameter_id
  for share;

  if not found then
    return jsonb_build_object('status', 'parameter_not_found');
  end if;

  if v_parameter.value_schema <> 'ENUM' then
    return jsonb_build_object('status', 'parameter_not_enum');
  end if;

  if not v_parameter.is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.parameter_id = target_parameter_id
     and v_current.code = v_code
     and v_current.name = v_name
     and v_current.description is not distinct from v_description
     and v_current.sort_order = enum_sort_order then
    return jsonb_build_object(
      'status', 'unchanged',
      'parameter_enum_value_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  v_semantic_change :=
    v_current.parameter_id is distinct from target_parameter_id
    or v_current.code is distinct from v_code;

  if v_semantic_change
     and private.is_parameter_enum_value_semantically_frozen(
       target_parameter_enum_value_id
     ) then
    return jsonb_build_object('status', 'semantics_frozen');
  end if;

  if v_current.parameter_id is distinct from target_parameter_id
     and (
       exists (
         select 1 from public.agronomic_observations ao
         where ao.enum_value_id = target_parameter_enum_value_id
       )
       or exists (
         select 1 from public.agronomic_candidates ac
         where ac.enum_value_id = target_parameter_enum_value_id
       )
       or exists (
         select 1 from public.candidate_submissions cs
         where cs.enum_value_id = target_parameter_enum_value_id
       )
       or exists (
         select 1 from public.agronomic_assertions aa
         where aa.enum_value_id = target_parameter_enum_value_id
       )
     ) then
    return jsonb_build_object('status', 'enum_value_in_use');
  end if;

  begin
    update public.parameter_enum_values
    set
      parameter_id = target_parameter_id,
      code = v_code,
      name = v_name,
      description = v_description,
      sort_order = enum_sort_order
    where id = target_parameter_enum_value_id
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
    when foreign_key_violation then
      return jsonb_build_object('status', 'enum_value_in_use');
    when check_violation then
      return jsonb_build_object('status', 'semantics_frozen');
  end;

  return jsonb_build_object(
    'status', 'updated',
    'parameter_enum_value_id', v_row.id,
    'parameter_id', v_row.parameter_id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_parameter_enum_value_active(
  target_parameter_enum_value_id uuid,
  expected_row_version bigint,
  enum_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.parameter_enum_values;
  v_parameter public.agronomic_parameters;
  v_row public.parameter_enum_values;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_parameter_enum_value_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or enum_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.parameter_enum_values pev
  where pev.id = target_parameter_enum_value_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = enum_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'parameter_enum_value_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if enum_is_active then
    select *
    into v_parameter
    from public.agronomic_parameters ap
    where ap.id = v_current.parameter_id
    for share;

    if not found then
      return jsonb_build_object('status', 'parameter_not_found');
    end if;

    if not v_parameter.is_active then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;

    if v_parameter.value_schema <> 'ENUM' then
      return jsonb_build_object('status', 'parameter_not_enum');
    end if;
  end if;

  if not enum_is_active
     and private.catalog_master_has_live_dependency(
       'ENUM_VALUE',
       target_parameter_enum_value_id
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.parameter_enum_values
  set is_active = enum_is_active
  where id = target_parameter_enum_value_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'parameter_enum_value_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;


-- ============================================================================
-- 5. PRODUCTION CONTEXTS
-- ============================================================================

create function public.create_production_context(
  context_code text,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_description text;
  v_row public.production_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(context_code));
  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  begin
    insert into public.production_contexts (
      code, name, description, is_active
    )
    values (
      v_code, v_name, v_description, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'production_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_production_context(
  target_production_context_id uuid,
  expected_row_version bigint,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.production_contexts;
  v_row public.production_contexts;
  v_name text;
  v_description text;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_production_context_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.production_contexts item
  where item.id = target_production_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.name = v_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'production_context_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  update public.production_contexts
  set
    name = v_name,
    description = v_description
  where id = target_production_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'updated',
    'production_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_production_context_active(
  target_production_context_id uuid,
  expected_row_version bigint,
  context_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.production_contexts;
  v_row public.production_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_production_context_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or context_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.production_contexts item
  where item.id = target_production_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = context_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'production_context_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if not context_is_active
     and private.catalog_master_has_live_dependency(
       'PRODUCTION_CONTEXT',
       target_production_context_id
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.production_contexts
  set is_active = context_is_active
  where id = target_production_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'production_context_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

-- ============================================================================
-- 6. PROTECTION CONTEXTS
-- ============================================================================

create function public.create_protection_context(
  context_code text,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_description text;
  v_row public.protection_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(context_code));
  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  begin
    insert into public.protection_contexts (
      code, name, description, is_active
    )
    values (
      v_code, v_name, v_description, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'protection_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_protection_context(
  target_protection_context_id uuid,
  expected_row_version bigint,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.protection_contexts;
  v_row public.protection_contexts;
  v_name text;
  v_description text;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_protection_context_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.protection_contexts item
  where item.id = target_protection_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.name = v_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'protection_context_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  update public.protection_contexts
  set
    name = v_name,
    description = v_description
  where id = target_protection_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'updated',
    'protection_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_protection_context_active(
  target_protection_context_id uuid,
  expected_row_version bigint,
  context_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.protection_contexts;
  v_row public.protection_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_protection_context_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or context_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.protection_contexts item
  where item.id = target_protection_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = context_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'protection_context_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if not context_is_active
     and private.catalog_master_has_live_dependency(
       'PROTECTION_CONTEXT',
       target_protection_context_id
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.protection_contexts
  set is_active = context_is_active
  where id = target_protection_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'protection_context_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

-- ============================================================================
-- 7. TRAINING CONTEXTS
-- ============================================================================

create function public.create_training_context(
  context_code text,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_description text;
  v_row public.training_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(context_code));
  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  begin
    insert into public.training_contexts (
      code, name, description, is_active
    )
    values (
      v_code, v_name, v_description, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'training_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_training_context(
  target_training_context_id uuid,
  expected_row_version bigint,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.training_contexts;
  v_row public.training_contexts;
  v_name text;
  v_description text;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_training_context_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.training_contexts item
  where item.id = target_training_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.name = v_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'training_context_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  update public.training_contexts
  set
    name = v_name,
    description = v_description
  where id = target_training_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'updated',
    'training_context_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_training_context_active(
  target_training_context_id uuid,
  expected_row_version bigint,
  context_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.training_contexts;
  v_row public.training_contexts;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_training_context_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or context_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.training_contexts item
  where item.id = target_training_context_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = context_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'training_context_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if not context_is_active
     and private.catalog_master_has_live_dependency(
       'TRAINING_CONTEXT',
       target_training_context_id
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.training_contexts
  set is_active = context_is_active
  where id = target_training_context_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'training_context_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

-- ============================================================================
-- 8. HARVEST PURPOSES
-- ============================================================================

create function public.create_harvest_purpose(
  context_code text,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_code text;
  v_name text;
  v_description text;
  v_row public.harvest_purposes;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_code := pg_catalog.upper(pg_catalog.btrim(context_code));
  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_code is null
     or v_code !~ '^[A-Z][A-Z0-9_]{0,79}$'
     or v_name is null or v_name = '' or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  begin
    insert into public.harvest_purposes (
      code, name, description, is_active
    )
    values (
      v_code, v_name, v_description, true
    )
    returning * into v_row;
  exception
    when unique_violation then
      return jsonb_build_object('status', 'duplicate_code');
  end;

  return jsonb_build_object(
    'status', 'created',
    'harvest_purpose_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'created_at', v_row.created_at
  );
end;
$function$;

create function public.update_harvest_purpose(
  target_harvest_purpose_id uuid,
  expected_row_version bigint,
  context_name text,
  context_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.harvest_purposes;
  v_row public.harvest_purposes;
  v_name text;
  v_description text;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_harvest_purpose_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  v_name := private.clean_catalog_master_text(context_name);
  v_description :=
    private.clean_catalog_master_description(context_description);

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 120
     or (
       v_description is not null
       and char_length(v_description) > 1000
     ) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.harvest_purposes item
  where item.id = target_harvest_purpose_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.name = v_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'harvest_purpose_id', v_current.id,
      'row_version', v_current.row_version
    );
  end if;

  update public.harvest_purposes
  set
    name = v_name,
    description = v_description
  where id = target_harvest_purpose_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'updated',
    'harvest_purpose_id', v_row.id,
    'code', v_row.code,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

create function public.set_harvest_purpose_active(
  target_harvest_purpose_id uuid,
  expected_row_version bigint,
  context_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_current public.harvest_purposes;
  v_row public.harvest_purposes;
begin
  if v_actor is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_harvest_purpose_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or context_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select *
  into v_current
  from public.harvest_purposes item
  where item.id = target_harvest_purpose_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'row_version', v_current.row_version
    );
  end if;

  if v_current.is_active = context_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'harvest_purpose_id', v_current.id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version
    );
  end if;

  if not context_is_active
     and private.catalog_master_has_live_dependency(
       'HARVEST_PURPOSE',
       target_harvest_purpose_id
     ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.harvest_purposes
  set is_active = context_is_active
  where id = target_harvest_purpose_id
  returning * into v_row;

  return jsonb_build_object(
    'status', 'active_changed',
    'harvest_purpose_id', v_row.id,
    'is_active', v_row.is_active,
    'row_version', v_row.row_version,
    'updated_at', v_row.updated_at
  );
end;
$function$;

-- ============================================================================
-- 9. PRIVILEGI DELLE RPC
-- ============================================================================

revoke all
  on function public.create_measurement_unit(text, text, text, text, numeric, numeric, text)
  from public, anon, authenticated;

grant execute
  on function public.create_measurement_unit(text, text, text, text, numeric, numeric, text)
  to authenticated;

revoke all
  on function public.update_measurement_unit(uuid, bigint, text, text, text, text, numeric, numeric, text)
  from public, anon, authenticated;

grant execute
  on function public.update_measurement_unit(uuid, bigint, text, text, text, text, numeric, numeric, text)
  to authenticated;

revoke all
  on function public.set_measurement_unit_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_measurement_unit_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_agronomic_parameter(text, text, text, text, text, text, uuid, boolean, boolean, boolean, boolean, boolean, boolean)
  from public, anon, authenticated;

grant execute
  on function public.create_agronomic_parameter(text, text, text, text, text, text, uuid, boolean, boolean, boolean, boolean, boolean, boolean)
  to authenticated;

revoke all
  on function public.update_agronomic_parameter(uuid, bigint, text, text, text, text, text, text, uuid, boolean, boolean, boolean, boolean, boolean, boolean)
  from public, anon, authenticated;

grant execute
  on function public.update_agronomic_parameter(uuid, bigint, text, text, text, text, text, text, uuid, boolean, boolean, boolean, boolean, boolean, boolean)
  to authenticated;

revoke all
  on function public.set_agronomic_parameter_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_agronomic_parameter_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_parameter_enum_value(uuid, text, text, text, integer)
  from public, anon, authenticated;

grant execute
  on function public.create_parameter_enum_value(uuid, text, text, text, integer)
  to authenticated;

revoke all
  on function public.update_parameter_enum_value(uuid, bigint, uuid, text, text, text, integer)
  from public, anon, authenticated;

grant execute
  on function public.update_parameter_enum_value(uuid, bigint, uuid, text, text, text, integer)
  to authenticated;

revoke all
  on function public.set_parameter_enum_value_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_parameter_enum_value_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_production_context(text, text, text)
  from public, anon, authenticated;

grant execute
  on function public.create_production_context(text, text, text)
  to authenticated;

revoke all
  on function public.update_production_context(uuid, bigint, text, text)
  from public, anon, authenticated;

grant execute
  on function public.update_production_context(uuid, bigint, text, text)
  to authenticated;

revoke all
  on function public.set_production_context_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_production_context_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_protection_context(text, text, text)
  from public, anon, authenticated;

grant execute
  on function public.create_protection_context(text, text, text)
  to authenticated;

revoke all
  on function public.update_protection_context(uuid, bigint, text, text)
  from public, anon, authenticated;

grant execute
  on function public.update_protection_context(uuid, bigint, text, text)
  to authenticated;

revoke all
  on function public.set_protection_context_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_protection_context_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_training_context(text, text, text)
  from public, anon, authenticated;

grant execute
  on function public.create_training_context(text, text, text)
  to authenticated;

revoke all
  on function public.update_training_context(uuid, bigint, text, text)
  from public, anon, authenticated;

grant execute
  on function public.update_training_context(uuid, bigint, text, text)
  to authenticated;

revoke all
  on function public.set_training_context_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_training_context_active(uuid, bigint, boolean)
  to authenticated;

revoke all
  on function public.create_harvest_purpose(text, text, text)
  from public, anon, authenticated;

grant execute
  on function public.create_harvest_purpose(text, text, text)
  to authenticated;

revoke all
  on function public.update_harvest_purpose(uuid, bigint, text, text)
  from public, anon, authenticated;

grant execute
  on function public.update_harvest_purpose(uuid, bigint, text, text)
  to authenticated;

revoke all
  on function public.set_harvest_purpose_active(uuid, bigint, boolean)
  from public, anon, authenticated;

grant execute
  on function public.set_harvest_purpose_active(uuid, bigint, boolean)
  to authenticated;

-- ============================================================================
-- 10. COMMENTI E SEMANTICA DELLA CAPABILITY
-- ============================================================================

comment on column public.catalog_authorities.can_manage_identity is
  'Consente la gestione dei master data globali del Catalogo: identita, alias, unita, parametri, valori ENUM e vocabolari di contesto.';

comment on function private.catalog_master_has_live_dependency(text, uuid) is
  'Rileva dipendenze operative correnti: Observation PENDING, Candidate DRAFT/IN_REVIEW/ACCEPTED e Assertion APPROVED.';

comment on function private.is_measurement_unit_semantically_frozen(uuid) is
  'Rileva il freeze semantico di una Unit dal primo artefatto immutabile o da un Parameter gia congelato.';

comment on function private.is_parameter_enum_value_semantically_frozen(uuid) is
  'Rileva il freeze semantico di un Enum Value dal primo artefatto immutabile.';

-- Nessun dato iniziale o dimostrativo viene inserito.
