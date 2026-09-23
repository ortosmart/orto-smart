-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 11 - CUTOVER ATOMICO DEL CATALOGO GLOBALE
-- ============================================================================
--
-- Finalizza il nome pubblico della Crop globale, ritira il Catalogo S026
-- profilato, collega Planting a Crop/Cultivar globali e introduce read model e
-- bootstrap tardivo della Catalog Authority.
--
-- La migrazione e intenzionalmente fail-closed:
-- - non migra per euristica dati legacy;
-- - rifiuta il cutover se Catalogo S026 o Planting contengono righe;
-- - non usa DROP ... CASCADE;
-- - verifica a fine transazione l'assenza degli oggetti temporanei/legacy.
-- ============================================================================

begin;

lock table
  public.botanical_families,
  public.crops,
  public.crop_varieties,
  public.plantings,
  public.catalog_crops_s030,
  public.crop_cultivars,
  public.catalog_authorities
in access exclusive mode;

do $preconditions$
begin
  if exists (select 1 from public.botanical_families limit 1) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 cutover aborted: public.botanical_families is not empty';
  end if;

  if exists (select 1 from public.crops limit 1) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 cutover aborted: legacy public.crops is not empty';
  end if;

  if exists (select 1 from public.crop_varieties limit 1) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 cutover aborted: public.crop_varieties is not empty';
  end if;

  if exists (select 1 from public.plantings limit 1) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 cutover aborted: public.plantings is not empty';
  end if;
end;
$preconditions$;

-- ---------------------------------------------------------------------------
-- 1. RITIRO ESPLICITO DEL WRITE PATH S026 E DELLE RPC PLANTING DA RICREARE
-- ---------------------------------------------------------------------------

do $drop_legacy_functions$
declare
  function_row record;
  function_count integer;
begin
  select count(*)::integer
  into function_count
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.proname = any (array[
      'create_botanical_family',
      'update_botanical_family',
      'set_botanical_family_active',
      'create_crop',
      'update_crop',
      'set_crop_active',
      'create_crop_variety',
      'update_crop_variety',
      'set_crop_variety_active'
    ]);

  if function_count <> 9 then
    raise exception using
      errcode = 'P0001',
      message = format(
        'Tranche 11 cutover aborted: expected 9 legacy functions, found %s',
        function_count
      );
  end if;

  for function_row in
    select p.oid::regprocedure as identity
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = any (array[
        'create_botanical_family',
        'update_botanical_family',
        'set_botanical_family_active',
        'create_crop',
        'update_crop',
        'set_crop_active',
        'create_crop_variety',
        'update_crop_variety',
        'set_crop_variety_active'
      ])
  loop
    execute format('drop function %s', function_row.identity);
  end loop;

  select count(*)::integer
  into function_count
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.proname in ('create_planting', 'update_planting');

  if function_count <> 2 then
    raise exception using
      errcode = 'P0001',
      message = format(
        'Tranche 11 cutover aborted: expected 2 Planting functions, found %s',
        function_count
      );
  end if;

  for function_row in
    select p.oid::regprocedure as identity
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('create_planting', 'update_planting')
  loop
    execute format('drop function %s', function_row.identity);
  end loop;
end;
$drop_legacy_functions$;

-- ---------------------------------------------------------------------------
-- 2. RITIRO DELLE IDENTITA LEGACY E PROMOZIONE DELLA CROP GLOBALE
-- ---------------------------------------------------------------------------

alter table public.plantings
  drop constraint plantings_variety_crop_profile_fk,
  drop constraint plantings_crop_profile_fk;

drop table public.crop_varieties;
drop table public.crops;
drop table public.botanical_families;

alter table public.catalog_crops_s030 rename to crops;

alter table public.crops
  rename constraint catalog_crops_s030_pkey to crops_pkey;
alter table public.crops
  rename constraint catalog_crops_s030_taxon_id_fkey to crops_taxon_id_fkey;
alter table public.crops
  rename constraint catalog_crops_s030_canonical_name_check to crops_canonical_name_check;
alter table public.crops
  rename constraint catalog_crops_s030_description_check to crops_description_check;
alter table public.crops
  rename constraint catalog_crops_s030_row_version_check to crops_row_version_check;
alter table public.crops
  rename constraint catalog_crops_s030_normalized_canonical_name_key
  to crops_normalized_canonical_name_key;

alter index public.catalog_crops_s030_taxon_id_idx
  rename to crops_taxon_id_idx;

alter trigger catalog_crops_s030_set_updated_at_and_row_version
  on public.crops
  rename to crops_set_updated_at_and_row_version;

alter policy catalog_crops_s030_select_authenticated
  on public.crops
  rename to crops_select_authenticated;

comment on table public.crops is
  'Identita agronomiche Crop globali del Catalogo Agronomico.';
comment on column public.crop_aliases.crop_id is
  'Crop globale a cui appartiene l alias.';

-- ---------------------------------------------------------------------------
-- 3. CUTOVER PLANTING: VARIETY -> CULTIVAR
-- ---------------------------------------------------------------------------

alter table public.plantings
  rename column variety_id to cultivar_id;

alter index public.plantings_variety_id_idx
  rename to plantings_cultivar_id_idx;

alter table public.plantings
  add constraint plantings_crop_id_fkey
    foreign key (crop_id)
    references public.crops(id)
    on delete restrict,
  add constraint plantings_cultivar_crop_fkey
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars(id, crop_id)
    on delete restrict;

comment on column public.plantings.crop_id is
  'Identita globale della Crop coltivata.';
comment on column public.plantings.cultivar_id is
  'Cultivar globale facoltativa, coerente con crop_id.';

-- ---------------------------------------------------------------------------
-- 4. FUNZIONI S030 RICREATE CONTRO public.crops
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION private.validate_active_candidate_dependencies(candidate_row public.agronomic_candidates) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_is_active boolean;
begin
  -- WITHDRAW deve restare possibile anche dopo il retirement delle entita
  -- referenziate dall Assertion canonica.
  if candidate_row.action = 'WITHDRAW' then
    return;
  end if;

  select p.is_active
  into v_is_active
  from public.agronomic_parameters p
  where p.id = candidate_row.parameter_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate parameter not found';
  end if;

  if not v_is_active then
    raise exception using
      errcode = 'P0001',
      message = 'candidate_dependency_inactive';
  end if;

  select c.is_active
  into v_is_active
  from public.crops c
  where c.id = candidate_row.crop_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate crop not found';
  end if;

  if not v_is_active then
    raise exception using
      errcode = 'P0001',
      message = 'candidate_dependency_inactive';
  end if;

  if candidate_row.cultivar_id is not null then
    select cv.is_active
    into v_is_active
    from public.crop_cultivars cv
    where cv.id = candidate_row.cultivar_id
      and cv.crop_id = candidate_row.crop_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate cultivar not found for crop';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.production_context_id is not null then
    select pc.is_active
    into v_is_active
    from public.production_contexts pc
    where pc.id = candidate_row.production_context_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate production context not found';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.protection_context_id is not null then
    select pc.is_active
    into v_is_active
    from public.protection_contexts pc
    where pc.id = candidate_row.protection_context_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate protection context not found';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.training_context_id is not null then
    select tc.is_active
    into v_is_active
    from public.training_contexts tc
    where tc.id = candidate_row.training_context_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate training context not found';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.harvest_purpose_id is not null then
    select hp.is_active
    into v_is_active
    from public.harvest_purposes hp
    where hp.id = candidate_row.harvest_purpose_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate harvest purpose not found';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.enum_value_id is not null then
    select ev.is_active
    into v_is_active
    from public.parameter_enum_values ev
    where ev.id = candidate_row.enum_value_id
      and ev.parameter_id = candidate_row.parameter_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate enum value not found for parameter';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;

  if candidate_row.unit_id is not null then
    select u.is_active
    into v_is_active
    from public.measurement_units u
    where u.id = candidate_row.unit_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate measurement unit not found';
    end if;

    if not v_is_active then
      raise exception using
        errcode = 'P0001',
        message = 'candidate_dependency_inactive';
    end if;
  end if;
end;
$$;

CREATE OR REPLACE FUNCTION public.create_catalog_crop(target_taxon_id uuid, crop_canonical_name text, crop_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_description text;
  v_taxon_is_active boolean;
  v_crop_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_canonical_name := private.clean_catalog_display_text(crop_canonical_name);
  v_description := nullif(
    private.clean_catalog_description(crop_description),
    ''
  );

  if target_taxon_id is null
     or v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_taxon_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_taxon_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.crops (
      taxon_id,
      canonical_name,
      description
    )
    values (
      target_taxon_id,
      v_canonical_name,
      v_description
    )
    returning id, row_version, created_at, updated_at
    into v_crop_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crops_normalized_canonical_name_key' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'catalog_crop_id', v_crop_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.create_crop_alias(target_crop_id uuid, alias_value text, alias_type text, alias_language_code text, alias_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_alias_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if target_crop_id is null
     or v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_entity_is_active
  from public.crops c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_entity_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.crop_aliases (
      crop_id, alias, alias_type, language_code, description
    )
    values (
      target_crop_id, v_alias, v_alias_type, v_language_code, v_description
    )
    returning id, row_version, created_at, updated_at
    into v_alias_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'crop_alias_id', v_alias_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$_$;

CREATE OR REPLACE FUNCTION public.create_crop_cultivar(target_crop_id uuid, cultivar_canonical_name text, cultivar_verification_status text, cultivar_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_verification_status text;
  v_description text;
  v_crop_is_active boolean;
  v_cultivar_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_canonical_name := private.clean_catalog_display_text(cultivar_canonical_name);
  v_verification_status := pg_catalog.upper(
    pg_catalog.btrim(cultivar_verification_status)
  );
  v_description := nullif(
    private.clean_catalog_description(cultivar_description),
    ''
  );

  if target_crop_id is null
     or v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or v_verification_status is null
     or v_verification_status not in ('VERIFIED', 'PROVISIONAL', 'AMBIGUOUS')
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_crop_is_active
  from public.crops c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_crop_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.crop_cultivars (
      crop_id,
      canonical_name,
      verification_status,
      description
    )
    values (
      target_crop_id,
      v_canonical_name,
      v_verification_status,
      v_description
    )
    returning id, row_version, created_at, updated_at
    into v_cultivar_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_cultivars_crop_name_unique' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'crop_cultivar_id', v_cultivar_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.normalize_agronomic_observation(target_observation_id uuid, expected_row_version bigint, observation_kind text, observation_parameter_id uuid, observation_crop_id uuid, observation_cultivar_id uuid DEFAULT NULL::uuid, observation_production_context_id uuid DEFAULT NULL::uuid, observation_protection_context_id uuid DEFAULT NULL::uuid, observation_training_context_id uuid DEFAULT NULL::uuid, observation_harvest_purpose_id uuid DEFAULT NULL::uuid, observation_numeric_value numeric DEFAULT NULL::numeric, observation_numeric_min_value numeric DEFAULT NULL::numeric, observation_numeric_max_value numeric DEFAULT NULL::numeric, observation_boolean_value boolean DEFAULT NULL::boolean, observation_enum_value_id uuid DEFAULT NULL::uuid, observation_unit_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_observation public.agronomic_observations%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_observation
  from public.agronomic_observations
  where id = target_observation_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_observation.status <> 'PENDING' then
    return jsonb_build_object(
      'status', 'already_finalized',
      'observation_status', v_observation.status
    );
  end if;

  if v_observation.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_observation.row_version
    );
  end if;

  if not exists (
    select 1 from public.agronomic_parameters
    where id = observation_parameter_id
  ) then
    return jsonb_build_object('status', 'parameter_not_found');
  end if;

  if not exists (
    select 1 from public.agronomic_parameters
    where id = observation_parameter_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if not exists (
    select 1 from public.crops
    where id = observation_crop_id
  ) then
    return jsonb_build_object('status', 'identity_not_found');
  end if;

  if not exists (
    select 1 from public.crops
    where id = observation_crop_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_cultivar_id is not null and not exists (
    select 1 from public.crop_cultivars
    where id = observation_cultivar_id
      and crop_id = observation_crop_id
  ) then
    return jsonb_build_object('status', 'identity_not_found');
  end if;

  if observation_cultivar_id is not null and not exists (
    select 1 from public.crop_cultivars
    where id = observation_cultivar_id
      and crop_id = observation_crop_id
      and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_production_context_id is not null and not exists (
    select 1 from public.production_contexts
    where id = observation_production_context_id
  ) then
    return jsonb_build_object('status', 'context_not_found');
  end if;

  if observation_production_context_id is not null and not exists (
    select 1 from public.production_contexts
    where id = observation_production_context_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_protection_context_id is not null and not exists (
    select 1 from public.protection_contexts
    where id = observation_protection_context_id
  ) then
    return jsonb_build_object('status', 'context_not_found');
  end if;

  if observation_protection_context_id is not null and not exists (
    select 1 from public.protection_contexts
    where id = observation_protection_context_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_training_context_id is not null and not exists (
    select 1 from public.training_contexts
    where id = observation_training_context_id
  ) then
    return jsonb_build_object('status', 'context_not_found');
  end if;

  if observation_training_context_id is not null and not exists (
    select 1 from public.training_contexts
    where id = observation_training_context_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_harvest_purpose_id is not null and not exists (
    select 1 from public.harvest_purposes
    where id = observation_harvest_purpose_id
  ) then
    return jsonb_build_object('status', 'context_not_found');
  end if;

  if observation_harvest_purpose_id is not null and not exists (
    select 1 from public.harvest_purposes
    where id = observation_harvest_purpose_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_enum_value_id is not null and not exists (
    select 1 from public.parameter_enum_values
    where id = observation_enum_value_id
      and parameter_id = observation_parameter_id
  ) then
    return jsonb_build_object('status', 'enum_value_not_found');
  end if;

  if observation_enum_value_id is not null and not exists (
    select 1 from public.parameter_enum_values
    where id = observation_enum_value_id
      and parameter_id = observation_parameter_id
      and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if observation_unit_id is not null and not exists (
    select 1 from public.measurement_units
    where id = observation_unit_id
  ) then
    return jsonb_build_object('status', 'unit_not_found');
  end if;

  if observation_unit_id is not null and not exists (
    select 1 from public.measurement_units
    where id = observation_unit_id and is_active
  ) then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  update public.agronomic_observations
  set status = 'NORMALIZED',
      kind = observation_kind,
      parameter_id = observation_parameter_id,
      crop_id = observation_crop_id,
      cultivar_id = observation_cultivar_id,
      production_context_id = observation_production_context_id,
      protection_context_id = observation_protection_context_id,
      training_context_id = observation_training_context_id,
      harvest_purpose_id = observation_harvest_purpose_id,
      numeric_value = observation_numeric_value,
      numeric_min_value = observation_numeric_min_value,
      numeric_max_value = observation_numeric_max_value,
      boolean_value = observation_boolean_value,
      enum_value_id = observation_enum_value_id,
      unit_id = observation_unit_id,
      finalization_reason = null,
      finalized_by = v_auth_user_id,
      finalized_at = now()
  where id = target_observation_id
  returning * into v_observation;

  return jsonb_build_object(
    'status', 'normalized',
    'agronomic_observation_id', v_observation.id,
    'row_version', v_observation.row_version,
    'observation_status', v_observation.status
  );
exception
  when check_violation or not_null_violation or foreign_key_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$$;

CREATE OR REPLACE FUNCTION public.resolve_agronomic_knowledge(target_parameter_id uuid, target_crop_id uuid, target_cultivar_id uuid, target_production_context_id uuid, target_protection_context_id uuid, target_training_context_id uuid, target_harvest_purpose_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_parameter public.agronomic_parameters%rowtype;
  v_crop public.crops%rowtype;
  v_cultivar public.crop_cultivars%rowtype;
  v_assertion public.agronomic_assertions%rowtype;
  v_unit public.measurement_units%rowtype;
  v_enum_value public.parameter_enum_values%rowtype;
  v_is_active boolean;
  v_match_count bigint;
  v_base jsonb;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if target_parameter_id is null or target_crop_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select p.*
  into v_parameter
  from public.agronomic_parameters p
  where p.id = target_parameter_id;

  if not found then
    return jsonb_build_object('status', 'parameter_not_found');
  end if;

  if not v_parameter.is_active then
    return jsonb_build_object('status', 'parameter_inactive');
  end if;

  select c.*
  into v_crop
  from public.crops c
  where c.id = target_crop_id;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_crop.is_active then
    return jsonb_build_object('status', 'crop_inactive');
  end if;

  if target_cultivar_id is null then
    if not v_parameter.allows_crop then
      return jsonb_build_object(
        'status', 'invalid_target',
        'target_level', 'CROP'
      );
    end if;
  else
    select cv.*
    into v_cultivar
    from public.crop_cultivars cv
    where cv.id = target_cultivar_id;

    if not found then
      return jsonb_build_object('status', 'cultivar_not_found');
    end if;

    if v_cultivar.crop_id is distinct from target_crop_id then
      return jsonb_build_object('status', 'cultivar_crop_mismatch');
    end if;

    if not v_cultivar.is_active then
      return jsonb_build_object('status', 'cultivar_inactive');
    end if;

    if not v_parameter.allows_cultivar then
      return jsonb_build_object(
        'status', 'invalid_target',
        'target_level', 'CULTIVAR'
      );
    end if;
  end if;

  if target_production_context_id is not null then
    if not v_parameter.allows_production_context then
      return jsonb_build_object(
        'status', 'invalid_context',
        'context_type', 'PRODUCTION'
      );
    end if;

    select pc.is_active
    into v_is_active
    from public.production_contexts pc
    where pc.id = target_production_context_id;

    if not found then
      return jsonb_build_object('status', 'production_context_not_found');
    end if;

    if not v_is_active then
      return jsonb_build_object('status', 'production_context_inactive');
    end if;
  end if;

  if target_protection_context_id is not null then
    if not v_parameter.allows_protection_context then
      return jsonb_build_object(
        'status', 'invalid_context',
        'context_type', 'PROTECTION'
      );
    end if;

    select pc.is_active
    into v_is_active
    from public.protection_contexts pc
    where pc.id = target_protection_context_id;

    if not found then
      return jsonb_build_object('status', 'protection_context_not_found');
    end if;

    if not v_is_active then
      return jsonb_build_object('status', 'protection_context_inactive');
    end if;
  end if;

  if target_training_context_id is not null then
    if not v_parameter.allows_training_context then
      return jsonb_build_object(
        'status', 'invalid_context',
        'context_type', 'TRAINING'
      );
    end if;

    select tc.is_active
    into v_is_active
    from public.training_contexts tc
    where tc.id = target_training_context_id;

    if not found then
      return jsonb_build_object('status', 'training_context_not_found');
    end if;

    if not v_is_active then
      return jsonb_build_object('status', 'training_context_inactive');
    end if;
  end if;

  if target_harvest_purpose_id is not null then
    if not v_parameter.allows_harvest_purpose then
      return jsonb_build_object(
        'status', 'invalid_context',
        'context_type', 'HARVEST_PURPOSE'
      );
    end if;

    select hp.is_active
    into v_is_active
    from public.harvest_purposes hp
    where hp.id = target_harvest_purpose_id;

    if not found then
      return jsonb_build_object('status', 'harvest_purpose_not_found');
    end if;

    if not v_is_active then
      return jsonb_build_object('status', 'harvest_purpose_inactive');
    end if;
  end if;

  select count(*)
  into v_match_count
  from public.agronomic_assertions a
  where a.status = 'APPROVED'
    and a.parameter_id = target_parameter_id
    and a.crop_id = target_crop_id
    and a.cultivar_id is not distinct from target_cultivar_id
    and a.production_context_id
          is not distinct from target_production_context_id
    and a.protection_context_id
          is not distinct from target_protection_context_id
    and a.training_context_id
          is not distinct from target_training_context_id
    and a.harvest_purpose_id
          is not distinct from target_harvest_purpose_id;

  if v_match_count = 0 then
    return jsonb_build_object(
      'status', 'NO_APPROVED_VALUE',
      'parameter_id', target_parameter_id,
      'crop_id', target_crop_id,
      'cultivar_id', target_cultivar_id,
      'production_context_id', target_production_context_id,
      'protection_context_id', target_protection_context_id,
      'training_context_id', target_training_context_id,
      'harvest_purpose_id', target_harvest_purpose_id
    );
  end if;

  if v_match_count > 1 then
    return jsonb_build_object(
      'status', 'RESOLUTION_CONFLICT',
      'conflict_reason', 'MULTIPLE_APPROVED_ASSERTIONS'
    );
  end if;

  select a.*
  into v_assertion
  from public.agronomic_assertions a
  where a.status = 'APPROVED'
    and a.parameter_id = target_parameter_id
    and a.crop_id = target_crop_id
    and a.cultivar_id is not distinct from target_cultivar_id
    and a.production_context_id
          is not distinct from target_production_context_id
    and a.protection_context_id
          is not distinct from target_protection_context_id
    and a.training_context_id
          is not distinct from target_training_context_id
    and a.harvest_purpose_id
          is not distinct from target_harvest_purpose_id;

  v_base := jsonb_build_object(
    'assertion_id', v_assertion.id,
    'revision_no', v_assertion.revision_no,
    'parameter_id', v_assertion.parameter_id,
    'parameter_code', v_parameter.code,
    'crop_id', v_assertion.crop_id,
    'cultivar_id', v_assertion.cultivar_id,
    'production_context_id', v_assertion.production_context_id,
    'protection_context_id', v_assertion.protection_context_id,
    'training_context_id', v_assertion.training_context_id,
    'harvest_purpose_id', v_assertion.harvest_purpose_id,
    'kind', v_assertion.kind,
    'value_schema', v_parameter.value_schema
  );

  if v_assertion.kind = 'NOT_APPLICABLE' then
    return jsonb_build_object('status', 'NOT_APPLICABLE') || v_base;
  end if;

  if v_parameter.value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
    select u.*
    into v_unit
    from public.measurement_units u
    where u.id = v_assertion.unit_id;

    if not found or not v_unit.is_active then
      return jsonb_build_object(
        'status', 'RESOLUTION_CONFLICT',
        'conflict_reason', 'INACTIVE_CANONICAL_UNIT'
      ) || v_base;
    end if;

    if v_assertion.unit_id is distinct from v_parameter.canonical_unit_id then
      return jsonb_build_object(
        'status', 'RESOLUTION_CONFLICT',
        'conflict_reason', 'NON_CANONICAL_UNIT'
      ) || v_base;
    end if;

    if v_parameter.value_schema = 'NUMERIC_SCALAR' then
      return jsonb_build_object('status', 'RESOLVED')
        || v_base
        || jsonb_build_object(
          'value', jsonb_build_object(
            'type', 'NUMERIC_SCALAR',
            'numeric_value', v_assertion.numeric_value,
            'unit', jsonb_build_object(
              'id', v_unit.id,
              'code', v_unit.code,
              'name', v_unit.name,
              'symbol', v_unit.symbol,
              'quantity_kind', v_unit.quantity_kind
            )
          )
        );
    end if;

    return jsonb_build_object('status', 'RESOLVED')
      || v_base
      || jsonb_build_object(
        'value', jsonb_build_object(
          'type', 'NUMERIC_RANGE',
          'numeric_min_value', v_assertion.numeric_min_value,
          'numeric_max_value', v_assertion.numeric_max_value,
          'unit', jsonb_build_object(
            'id', v_unit.id,
            'code', v_unit.code,
            'name', v_unit.name,
            'symbol', v_unit.symbol,
            'quantity_kind', v_unit.quantity_kind
          )
        )
      );

  elsif v_parameter.value_schema = 'BOOLEAN' then
    return jsonb_build_object('status', 'RESOLVED')
      || v_base
      || jsonb_build_object(
        'value', jsonb_build_object(
          'type', 'BOOLEAN',
          'boolean_value', v_assertion.boolean_value
        )
      );

  elsif v_parameter.value_schema = 'ENUM' then
    select ev.*
    into v_enum_value
    from public.parameter_enum_values ev
    where ev.id = v_assertion.enum_value_id
      and ev.parameter_id = v_assertion.parameter_id;

    if not found or not v_enum_value.is_active then
      return jsonb_build_object(
        'status', 'RESOLUTION_CONFLICT',
        'conflict_reason', 'INACTIVE_ENUM_VALUE'
      ) || v_base;
    end if;

    return jsonb_build_object('status', 'RESOLVED')
      || v_base
      || jsonb_build_object(
        'value', jsonb_build_object(
          'type', 'ENUM',
          'enum_value', jsonb_build_object(
            'id', v_enum_value.id,
            'code', v_enum_value.code,
            'name', v_enum_value.name
          )
        )
      );
  end if;

  return jsonb_build_object(
    'status', 'RESOLUTION_CONFLICT',
    'conflict_reason', 'UNSUPPORTED_VALUE_SCHEMA'
  ) || v_base;
end;
$$;

CREATE OR REPLACE FUNCTION public.set_botanical_taxon_active(target_botanical_taxon_id uuid, expected_row_version bigint, taxon_is_active boolean) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.botanical_taxa%rowtype;
  v_parent_is_active boolean;
  v_active_child_taxa_count bigint;
  v_active_crops_count bigint;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_botanical_taxon_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or taxon_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.*
  into v_current
  from public.botanical_taxa bt
  where bt.id = target_botanical_taxon_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_taxon_id', target_botanical_taxon_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = taxon_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'botanical_taxon_id', target_botanical_taxon_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if taxon_is_active then
    if v_current.parent_taxon_id is not null then
      select bt.is_active
      into v_parent_is_active
      from public.botanical_taxa bt
      where bt.id = v_current.parent_taxon_id
      for share;

      if not coalesce(v_parent_is_active, false) then
        return jsonb_build_object('status', 'dependency_inactive');
      end if;
    end if;
  else
    select count(*)
    into v_active_child_taxa_count
    from public.botanical_taxa bt
    where bt.parent_taxon_id = target_botanical_taxon_id
      and bt.is_active = true;

    select count(*)
    into v_active_crops_count
    from public.crops c
    where c.taxon_id = target_botanical_taxon_id
      and c.is_active = true;

    if v_active_child_taxa_count > 0
       or v_active_crops_count > 0 then
      return jsonb_build_object(
        'status', 'active_dependents',
        'active_child_taxa_count', v_active_child_taxa_count,
        'active_crops_count', v_active_crops_count
      );
    end if;
  end if;

  update public.botanical_taxa
  set is_active = taxon_is_active
  where id = target_botanical_taxon_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'botanical_taxon_id', target_botanical_taxon_id,
    'is_active', taxon_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.set_catalog_crop_active(target_catalog_crop_id uuid, expected_row_version bigint, crop_is_active boolean) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.crops%rowtype;
  v_taxon_is_active boolean;
  v_active_cultivars_count bigint;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_catalog_crop_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or crop_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.*
  into v_current
  from public.crops c
  where c.id = target_catalog_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'catalog_crop_id', target_catalog_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = crop_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'catalog_crop_id', target_catalog_crop_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if crop_is_active then
    select bt.is_active
    into v_taxon_is_active
    from public.botanical_taxa bt
    where bt.id = v_current.taxon_id
    for share;

    if not coalesce(v_taxon_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  else
    select count(*)
    into v_active_cultivars_count
    from public.crop_cultivars cv
    where cv.crop_id = target_catalog_crop_id
      and cv.is_active = true;

    if v_active_cultivars_count > 0 then
      return jsonb_build_object(
        'status', 'active_dependents',
        'dependent_type', 'crop_cultivars',
        'dependent_count', v_active_cultivars_count
      );
    end if;
  end if;

  update public.crops
  set is_active = crop_is_active
  where id = target_catalog_crop_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'catalog_crop_id', target_catalog_crop_id,
    'is_active', crop_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.set_crop_alias_active(target_crop_alias_id uuid, expected_row_version bigint, alias_is_active boolean) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.crop_aliases%rowtype;
  v_entity_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or alias_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.crop_aliases ca
  where ca.id = target_crop_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_alias_id', target_crop_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = alias_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_alias_id', target_crop_alias_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if alias_is_active then
    select c.is_active
    into v_entity_is_active
    from public.crops c
    where c.id = v_current.crop_id
    for share;

    if not coalesce(v_entity_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.crop_aliases
  set is_active = alias_is_active
  where id = target_crop_alias_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'crop_alias_id', target_crop_alias_id,
    'is_active', alias_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.set_crop_cultivar_active(target_crop_cultivar_id uuid, expected_row_version bigint, cultivar_is_active boolean) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.crop_cultivars%rowtype;
  v_crop_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_cultivar_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or cultivar_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.*
  into v_current
  from public.crop_cultivars cv
  where cv.id = target_crop_cultivar_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_cultivar_id', target_crop_cultivar_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = cultivar_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_cultivar_id', target_crop_cultivar_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if cultivar_is_active then
    select c.is_active
    into v_crop_is_active
    from public.crops c
    where c.id = v_current.crop_id
    for share;

    if not coalesce(v_crop_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.crop_cultivars
  set is_active = cultivar_is_active
  where id = target_crop_cultivar_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'crop_cultivar_id', target_crop_cultivar_id,
    'is_active', cultivar_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.update_catalog_crop(target_catalog_crop_id uuid, expected_row_version bigint, target_taxon_id uuid, crop_canonical_name text, crop_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_description text;
  v_taxon_is_active boolean;
  v_current public.crops%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_catalog_crop_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_taxon_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.*
  into v_current
  from public.crops c
  where c.id = target_catalog_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'catalog_crop_id', target_catalog_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_canonical_name := private.clean_catalog_display_text(crop_canonical_name);
  v_description := nullif(
    private.clean_catalog_description(crop_description),
    ''
  );

  if v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_taxon_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_taxon_is_active
     and v_current.taxon_id is distinct from target_taxon_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.taxon_id = target_taxon_id
     and v_current.canonical_name = v_canonical_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'catalog_crop_id', target_catalog_crop_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.crops
    set
      taxon_id = target_taxon_id,
      canonical_name = v_canonical_name,
      description = v_description
    where id = target_catalog_crop_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crops_normalized_canonical_name_key' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'catalog_crop_id', target_catalog_crop_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

CREATE OR REPLACE FUNCTION public.update_crop_alias(target_crop_alias_id uuid, expected_row_version bigint, target_crop_id uuid, alias_value text, alias_type text, alias_language_code text, alias_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_current public.crop_aliases%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_crop_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.crop_aliases ca
  where ca.id = target_crop_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_alias_id', target_crop_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_entity_is_active
  from public.crops c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_entity_is_active
     and v_current.crop_id is distinct from target_crop_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.crop_id = target_crop_id
     and v_current.alias = v_alias
     and v_current.alias_type = v_alias_type
     and v_current.language_code is not distinct from v_language_code
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_alias_id', target_crop_alias_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.crop_aliases
    set
      crop_id = target_crop_id,
      alias = v_alias,
      alias_type = v_alias_type,
      language_code = v_language_code,
      description = v_description
    where id = target_crop_alias_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'crop_alias_id', target_crop_alias_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$_$;

CREATE OR REPLACE FUNCTION public.update_crop_cultivar(target_crop_cultivar_id uuid, expected_row_version bigint, target_crop_id uuid, cultivar_canonical_name text, cultivar_verification_status text, cultivar_description text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_verification_status text;
  v_description text;
  v_crop_is_active boolean;
  v_current public.crop_cultivars%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_cultivar_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_crop_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.*
  into v_current
  from public.crop_cultivars cv
  where cv.id = target_crop_cultivar_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_cultivar_id', target_crop_cultivar_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_canonical_name := private.clean_catalog_display_text(cultivar_canonical_name);
  v_verification_status := pg_catalog.upper(
    pg_catalog.btrim(cultivar_verification_status)
  );
  v_description := nullif(
    private.clean_catalog_description(cultivar_description),
    ''
  );

  if v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or v_verification_status is null
     or v_verification_status not in ('VERIFIED', 'PROVISIONAL', 'AMBIGUOUS')
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_crop_is_active
  from public.crops c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_crop_is_active
     and v_current.crop_id is distinct from target_crop_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.crop_id = target_crop_id
     and v_current.canonical_name = v_canonical_name
     and v_current.verification_status = v_verification_status
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_cultivar_id', target_crop_cultivar_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.crop_cultivars
    set
      crop_id = target_crop_id,
      canonical_name = v_canonical_name,
      verification_status = v_verification_status,
      description = v_description
    where id = target_crop_cultivar_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_cultivars_crop_name_unique' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;

    when foreign_key_violation then
      -- Le tabelle Knowledge usano la coppia (cultivar_id, crop_id).
      -- Una Cultivar gia referenziata non puo essere spostata tra Crop.
      return jsonb_build_object('status', 'identity_in_use');
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'crop_cultivar_id', target_crop_cultivar_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. RPC PLANTING RICREATE CON CROP/CULTIVAR GLOBALI
-- ---------------------------------------------------------------------------

CREATE FUNCTION public.create_planting(target_profile_id uuid, target_garden_id uuid, target_season_id uuid, target_bed_id uuid, target_crop_id uuid, target_cultivar_id uuid, target_client_id uuid, target_session_id uuid, lock_token text, planting_start_method text, planting_start_date date, planting_start_position_cm integer, planting_length_cm integer, planting_plant_spacing_cm integer, planting_row_spacing_cm integer, planting_rows_count integer, planting_occupied_width_cm integer, planting_plants_count integer, planting_seed_quantity_g numeric, planting_notes text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
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
$$;

CREATE FUNCTION public.update_planting(target_profile_id uuid, target_planting_id uuid, expected_row_version bigint, target_client_id uuid, target_session_id uuid, lock_token text, planting_season_id uuid, planting_crop_id uuid, planting_cultivar_id uuid, planting_start_method text, planting_start_date date, planting_start_position_cm integer, planting_length_cm integer, planting_plant_spacing_cm integer, planting_row_spacing_cm integer, planting_rows_count integer, planting_occupied_width_cm integer, planting_plants_count integer, planting_seed_quantity_g numeric, planting_notes text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
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
$$;

revoke all
  on function public.create_planting(
    uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date,
    integer, integer, integer, integer, integer, integer, integer, numeric, text
  )
  from public, anon, authenticated;
grant execute
  on function public.create_planting(
    uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date,
    integer, integer, integer, integer, integer, integer, integer, numeric, text
  )
  to authenticated;

revoke all
  on function public.update_planting(
    uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date,
    integer, integer, integer, integer, integer, integer, integer, numeric, text
  )
  from public, anon, authenticated;
grant execute
  on function public.update_planting(
    uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date,
    integer, integer, integer, integer, integer, integer, integer, numeric, text
  )
  to authenticated;

comment on function public.create_planting(
  uuid, uuid, uuid, uuid, uuid, uuid, uuid, uuid, text, text, date,
  integer, integer, integer, integer, integer, integer, integer, numeric, text
) is
  'Crea un Planting autorevole collegato a Crop e Cultivar globali.';

comment on function public.update_planting(
  uuid, uuid, bigint, uuid, uuid, text, uuid, uuid, uuid, text, date,
  integer, integer, integer, integer, integer, integer, integer, numeric, text
) is
  'Aggiorna un Planting autorevole collegato a Crop e Cultivar globali.';


-- ---------------------------------------------------------------------------
-- 6. CAPABILITY PUBBLICHE E BOOTSTRAP TARDIVO DELL AUTHORITY INIZIALE
-- ---------------------------------------------------------------------------

create function public.get_my_catalog_capabilities()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_authority public.catalog_authorities%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select ca.*
  into v_authority
  from public.catalog_authorities ca
  where ca.auth_user_id = v_auth_user_id;

  return jsonb_build_object(
    'status', 'ok',
    'can_manage_identity', coalesce(v_authority.can_manage_identity, false),
    'can_ingest', coalesce(v_authority.can_ingest, false),
    'can_review', coalesce(v_authority.can_review, false),
    'can_publish', coalesce(v_authority.can_publish, false),
    'row_version', v_authority.row_version
  );
end;
$function$;

revoke all
  on function public.get_my_catalog_capabilities()
  from public, anon, authenticated;
grant execute
  on function public.get_my_catalog_capabilities()
  to authenticated;

comment on function public.get_my_catalog_capabilities() is
  'Restituisce esclusivamente le capability Catalogo dell utente autenticato corrente.';

create function public.claim_initial_catalog_authority()
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_eligible_owner_count integer;
  v_eligible_owner_id uuid;
  v_authority public.catalog_authorities%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'forbidden');
  end if;

  lock table public.catalog_authorities in share row exclusive mode;

  select ca.*
  into v_authority
  from public.catalog_authorities ca
  where ca.auth_user_id = v_auth_user_id;

  if found then
    return jsonb_build_object(
      'status', 'already_initialized',
      'can_manage_identity', v_authority.can_manage_identity,
      'can_ingest', v_authority.can_ingest,
      'can_review', v_authority.can_review,
      'can_publish', v_authority.can_publish,
      'row_version', v_authority.row_version
    );
  end if;

  if exists (select 1 from public.catalog_authorities) then
    return jsonb_build_object('status', 'already_claimed');
  end if;

  select count(*)::integer, (array_agg(pm.auth_user_id))[1]
  into v_eligible_owner_count, v_eligible_owner_id
  from public.profile_memberships pm
  where pm.role = 'owner'::public.profile_member_role
    and pm.is_enabled = true
    and pm.auth_user_id = pm.profile_id;

  if v_eligible_owner_count <> 1
     or v_eligible_owner_id is distinct from v_auth_user_id
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  insert into public.catalog_authorities (
    auth_user_id,
    can_manage_identity,
    can_ingest,
    can_review,
    can_publish
  )
  values (
    v_auth_user_id,
    true,
    true,
    true,
    true
  )
  returning * into v_authority;

  return jsonb_build_object(
    'status', 'claimed',
    'can_manage_identity', v_authority.can_manage_identity,
    'can_ingest', v_authority.can_ingest,
    'can_review', v_authority.can_review,
    'can_publish', v_authority.can_publish,
    'row_version', v_authority.row_version
  );
end;
$function$;

revoke all
  on function public.claim_initial_catalog_authority()
  from public, anon, authenticated;
grant execute
  on function public.claim_initial_catalog_authority()
  to authenticated;

comment on function public.claim_initial_catalog_authority() is
  'Consente all unico owner idoneo di inizializzare una sola volta la Catalog Authority globale.';

-- ---------------------------------------------------------------------------
-- 7. READ MODEL GLOBALI
-- ---------------------------------------------------------------------------

create view public.crop_catalog_read
with (security_invoker = true)
as
with recursive taxon_lineage as (
  select
    c.id as crop_id,
    t.id as ancestor_taxon_id,
    t.parent_taxon_id,
    t.rank,
    t.scientific_name,
    0 as depth,
    array[t.id]::uuid[] as path
  from public.crops c
  join public.botanical_taxa t on t.id = c.taxon_id

  union all

  select
    lineage.crop_id,
    parent.id,
    parent.parent_taxon_id,
    parent.rank,
    parent.scientific_name,
    lineage.depth + 1,
    lineage.path || parent.id
  from taxon_lineage lineage
  join public.botanical_taxa parent
    on parent.id = lineage.parent_taxon_id
  where lineage.depth < 31
    and not parent.id = any(lineage.path)
),
resolved_family as (
  select distinct on (lineage.crop_id)
    lineage.crop_id,
    lineage.ancestor_taxon_id as family_taxon_id,
    lineage.scientific_name as family_scientific_name
  from taxon_lineage lineage
  where lineage.rank = 'FAMILY'
  order by lineage.crop_id, lineage.depth
)
select
  c.id as crop_id,
  c.canonical_name,
  c.description,
  c.is_active,
  c.row_version,
  c.created_at,
  c.updated_at,
  t.id as taxon_id,
  t.rank as taxon_rank,
  t.scientific_name as taxon_scientific_name,
  family.family_taxon_id,
  family.family_scientific_name
from public.crops c
join public.botanical_taxa t on t.id = c.taxon_id
left join resolved_family family on family.crop_id = c.id;

revoke all on table public.crop_catalog_read from public, anon, authenticated;
grant select on table public.crop_catalog_read to authenticated;

comment on view public.crop_catalog_read is
  'Read model globale Crop con Taxon diretto e famiglia botanica risolta ricorsivamente.';

create view public.crop_cultivar_catalog_read
with (security_invoker = true)
as
select
  cultivar.id as cultivar_id,
  cultivar.crop_id,
  crop.canonical_name as crop_canonical_name,
  cultivar.canonical_name,
  cultivar.verification_status,
  cultivar.description,
  cultivar.is_active,
  cultivar.row_version,
  cultivar.created_at,
  cultivar.updated_at
from public.crop_cultivars cultivar
join public.crops crop on crop.id = cultivar.crop_id;

revoke all
  on table public.crop_cultivar_catalog_read
  from public, anon, authenticated;
grant select
  on table public.crop_cultivar_catalog_read
  to authenticated;

comment on view public.crop_cultivar_catalog_read is
  'Read model globale delle Cultivar con identita della Crop di appartenenza.';

-- ---------------------------------------------------------------------------
-- 8. POSTCONDIZIONI FAIL-CLOSED
-- ---------------------------------------------------------------------------

do $postconditions$
declare
  v_stale_function_count integer;
begin
  if to_regclass('public.catalog_crops_s030') is not null
     or to_regclass('public.botanical_families') is not null
     or to_regclass('public.crop_varieties') is not null
  then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 postcondition failed: a temporary or legacy table still exists';
  end if;

  if to_regclass('public.crops') is null
     or to_regclass('public.crop_cultivars') is null
  then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 postcondition failed: a canonical identity table is missing';
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'plantings'
      and column_name = 'variety_id'
  ) or not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'plantings'
      and column_name = 'cultivar_id'
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 postcondition failed: Planting cultivar cutover is incomplete';
  end if;

  select count(*)::integer
  into v_stale_function_count
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('public', 'private')
    and p.prokind = 'f'
    and position('catalog_crops_s030' in pg_get_functiondef(p.oid)) > 0;

  if v_stale_function_count <> 0 then
    raise exception using
      errcode = 'P0001',
      message = format(
        'Tranche 11 postcondition failed: %s functions still reference catalog_crops_s030',
        v_stale_function_count
      );
  end if;

  if exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = any (array[
        'create_botanical_family',
        'update_botanical_family',
        'set_botanical_family_active',
        'create_crop',
        'update_crop',
        'set_crop_active',
        'create_crop_variety',
        'update_crop_variety',
        'set_crop_variety_active'
      ])
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'Tranche 11 postcondition failed: a legacy function still exists';
  end if;
end;
$postconditions$;

commit;
