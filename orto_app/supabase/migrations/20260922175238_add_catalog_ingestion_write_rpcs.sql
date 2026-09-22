-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 9C - WRITE PATH AUTORITATIVO PER INGESTION
-- ============================================================================
--
-- Introduce il Write Path per:
-- - fonti e documenti sorgente;
-- - acquisizioni e revisioni immutabili;
-- - creazione, correzione e finalizzazione delle Observations.
--
-- Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. INVARIANTE: UNA SOLA ACQUISIZIONE APERTA PER DOCUMENTO
-- ============================================================================

create unique index acquisition_runs_one_started_per_document
  on public.acquisition_runs(document_id)
  where status = 'STARTED';


-- ============================================================================
-- 2. AGRONOMIC SOURCES
-- ============================================================================

create function public.create_agronomic_source(
  source_code text,
  source_name text,
  source_description text default null,
  source_base_url text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_source public.agronomic_sources%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  insert into public.agronomic_sources (
    code, name, description, base_url
  ) values (
    source_code,
    source_name,
    nullif(btrim(source_description), ''),
    nullif(btrim(source_base_url), '')
  )
  returning * into v_source;

  return jsonb_build_object(
    'status', 'created',
    'agronomic_source_id', v_source.id,
    'row_version', v_source.row_version
  );
exception
  when unique_violation then
    return jsonb_build_object('status', 'duplicate_code');
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.update_agronomic_source(
  target_source_id uuid,
  expected_row_version bigint,
  source_name text,
  source_description text default null,
  source_base_url text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_source public.agronomic_sources%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_source
  from public.agronomic_sources
  where id = target_source_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_source.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_source.row_version
    );
  end if;

  if v_source.name is not distinct from source_name
     and v_source.description is not distinct from nullif(btrim(source_description), '')
     and v_source.base_url is not distinct from nullif(btrim(source_base_url), '') then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_source_id', v_source.id,
      'row_version', v_source.row_version
    );
  end if;

  update public.agronomic_sources
  set name = source_name,
      description = nullif(btrim(source_description), ''),
      base_url = nullif(btrim(source_base_url), '')
  where id = target_source_id
  returning * into v_source;

  return jsonb_build_object(
    'status', 'updated',
    'agronomic_source_id', v_source.id,
    'row_version', v_source.row_version
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.set_agronomic_source_active(
  target_source_id uuid,
  expected_row_version bigint,
  source_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_source public.agronomic_sources%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if source_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select * into v_source
  from public.agronomic_sources
  where id = target_source_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_source.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_source.row_version
    );
  end if;

  if v_source.is_active = source_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_source_id', v_source.id,
      'row_version', v_source.row_version,
      'is_active', v_source.is_active
    );
  end if;

  if not source_is_active and exists (
    select 1
    from public.source_documents d
    where d.source_id = target_source_id
      and d.is_active
  ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.agronomic_sources
  set is_active = source_is_active
  where id = target_source_id
  returning * into v_source;

  return jsonb_build_object(
    'status', 'active_changed',
    'agronomic_source_id', v_source.id,
    'row_version', v_source.row_version,
    'is_active', v_source.is_active
  );
end;
$function$;


-- ============================================================================
-- 3. SOURCE DOCUMENTS
-- ============================================================================

create function public.create_source_document(
  target_source_id uuid,
  document_key text,
  document_title text,
  document_canonical_locator text default null,
  document_description text default null,
  document_language_code text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_source public.agronomic_sources%rowtype;
  v_document public.source_documents%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_source
  from public.agronomic_sources
  where id = target_source_id
  for key share;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not v_source.is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  insert into public.source_documents (
    source_id, document_key, title, canonical_locator, description, language_code
  ) values (
    target_source_id,
    document_key,
    document_title,
    nullif(btrim(document_canonical_locator), ''),
    nullif(btrim(document_description), ''),
    nullif(btrim(document_language_code), '')
  )
  returning * into v_document;

  return jsonb_build_object(
    'status', 'created',
    'source_document_id', v_document.id,
    'row_version', v_document.row_version
  );
exception
  when unique_violation then
    return jsonb_build_object('status', 'duplicate_document_key');
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.update_source_document(
  target_document_id uuid,
  expected_row_version bigint,
  document_title text,
  document_canonical_locator text default null,
  document_description text default null,
  document_language_code text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_document public.source_documents%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_document
  from public.source_documents
  where id = target_document_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_document.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_document.row_version
    );
  end if;

  if v_document.title is not distinct from document_title
     and v_document.canonical_locator is not distinct from nullif(btrim(document_canonical_locator), '')
     and v_document.description is not distinct from nullif(btrim(document_description), '')
     and v_document.language_code is not distinct from nullif(btrim(document_language_code), '') then
    return jsonb_build_object(
      'status', 'unchanged',
      'source_document_id', v_document.id,
      'row_version', v_document.row_version
    );
  end if;

  update public.source_documents
  set title = document_title,
      canonical_locator = nullif(btrim(document_canonical_locator), ''),
      description = nullif(btrim(document_description), ''),
      language_code = nullif(btrim(document_language_code), '')
  where id = target_document_id
  returning * into v_document;

  return jsonb_build_object(
    'status', 'updated',
    'source_document_id', v_document.id,
    'row_version', v_document.row_version
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.set_source_document_active(
  target_document_id uuid,
  expected_row_version bigint,
  document_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_document public.source_documents%rowtype;
  v_source_active boolean;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if document_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select * into v_document
  from public.source_documents
  where id = target_document_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_document.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_document.row_version
    );
  end if;

  if v_document.is_active = document_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'source_document_id', v_document.id,
      'row_version', v_document.row_version,
      'is_active', v_document.is_active
    );
  end if;

  if document_is_active then
    select is_active into v_source_active
    from public.agronomic_sources
    where id = v_document.source_id
    for key share;

    if v_source_active is not true then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  elsif exists (
    select 1
    from public.acquisition_runs ar
    where ar.document_id = target_document_id
      and ar.status = 'STARTED'
  ) then
    return jsonb_build_object('status', 'active_dependents');
  end if;

  update public.source_documents
  set is_active = document_is_active
  where id = target_document_id
  returning * into v_document;

  return jsonb_build_object(
    'status', 'active_changed',
    'source_document_id', v_document.id,
    'row_version', v_document.row_version,
    'is_active', v_document.is_active
  );
end;
$function$;


-- ============================================================================
-- 4. ACQUISITION RUNS E SOURCE REVISIONS
-- ============================================================================

create function public.start_acquisition_run(
  target_document_id uuid,
  acquisition_method text,
  acquisition_effective_locator text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_document public.source_documents%rowtype;
  v_run public.acquisition_runs%rowtype;
  v_source_active boolean;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_document
  from public.source_documents
  where id = target_document_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  select is_active into v_source_active
  from public.agronomic_sources
  where id = v_document.source_id;

  if not v_document.is_active or v_source_active is not true then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  select * into v_run
  from public.acquisition_runs
  where document_id = target_document_id
    and status = 'STARTED';

  if found then
    return jsonb_build_object(
      'status', 'acquisition_in_progress',
      'acquisition_run_id', v_run.id,
      'started_at', v_run.started_at
    );
  end if;

  insert into public.acquisition_runs (
    document_id, method, effective_locator, started_by
  ) values (
    target_document_id,
    acquisition_method,
    nullif(btrim(acquisition_effective_locator), ''),
    v_auth_user_id
  )
  returning * into v_run;

  return jsonb_build_object(
    'status', 'started',
    'acquisition_run_id', v_run.id,
    'started_at', v_run.started_at
  );
exception
  when unique_violation then
    select * into v_run
    from public.acquisition_runs
    where document_id = target_document_id
      and status = 'STARTED';

    return jsonb_build_object(
      'status', 'acquisition_in_progress',
      'acquisition_run_id', v_run.id,
      'started_at', v_run.started_at
    );
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.complete_acquisition_run(
  target_acquisition_run_id uuid,
  revision_content_hash text,
  revision_content_type text,
  revision_content_size_bytes bigint default null,
  revision_storage_path text default null,
  revision_source_version_label text default null,
  revision_source_published_at timestamptz default null,
  acquisition_http_status_code integer default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_run public.acquisition_runs%rowtype;
  v_revision public.source_revisions%rowtype;
  v_created boolean := false;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_run
  from public.acquisition_runs
  where id = target_acquisition_run_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_run.status <> 'STARTED' then
    return jsonb_build_object(
      'status', 'already_finalized',
      'acquisition_status', v_run.status,
      'source_revision_id', v_run.source_revision_id
    );
  end if;

  select * into v_revision
  from public.source_revisions
  where document_id = v_run.document_id
    and content_hash = revision_content_hash;

  if found then
    if v_revision.content_type is distinct from revision_content_type
       or (
         v_revision.content_size_bytes is not null
         and revision_content_size_bytes is not null
         and v_revision.content_size_bytes is distinct from revision_content_size_bytes
       ) then
      return jsonb_build_object(
        'status', 'revision_metadata_conflict',
        'source_revision_id', v_revision.id
      );
    end if;
  else
    insert into public.source_revisions (
      document_id,
      content_hash,
      content_type,
      content_size_bytes,
      storage_path,
      source_version_label,
      source_published_at
    ) values (
      v_run.document_id,
      revision_content_hash,
      revision_content_type,
      revision_content_size_bytes,
      nullif(btrim(revision_storage_path), ''),
      nullif(btrim(revision_source_version_label), ''),
      revision_source_published_at
    )
    returning * into v_revision;

    v_created := true;
  end if;

  update public.acquisition_runs
  set source_revision_id = v_revision.id,
      status = case when v_created then 'SUCCEEDED' else 'UNCHANGED' end,
      http_status_code = acquisition_http_status_code,
      error_message = null,
      finalized_by = v_auth_user_id,
      finalized_at = now()
  where id = v_run.id
  returning * into v_run;

  return jsonb_build_object(
    'status', case when v_created then 'succeeded' else 'unchanged' end,
    'acquisition_run_id', v_run.id,
    'acquisition_status', v_run.status,
    'source_revision_id', v_revision.id
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.fail_acquisition_run(
  target_acquisition_run_id uuid,
  acquisition_error_message text,
  acquisition_http_status_code integer default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_run public.acquisition_runs%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_run
  from public.acquisition_runs
  where id = target_acquisition_run_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_run.status <> 'STARTED' then
    return jsonb_build_object(
      'status', 'already_finalized',
      'acquisition_status', v_run.status,
      'source_revision_id', v_run.source_revision_id
    );
  end if;

  update public.acquisition_runs
  set status = 'FAILED',
      http_status_code = acquisition_http_status_code,
      error_message = acquisition_error_message,
      finalized_by = v_auth_user_id,
      finalized_at = now()
  where id = v_run.id
  returning * into v_run;

  return jsonb_build_object(
    'status', 'failed',
    'acquisition_run_id', v_run.id,
    'acquisition_status', v_run.status,
    'source_revision_id', null
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 5. AGRONOMIC OBSERVATIONS
-- ============================================================================

create function public.create_agronomic_observation(
  target_source_revision_id uuid,
  observation_original_value_text text,
  observation_original_subject_text text default null,
  observation_original_parameter_text text default null,
  observation_original_unit_text text default null,
  observation_evidence_locator text default null,
  observation_evidence_excerpt text default null,
  observation_evidence_context_json jsonb default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
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

  if not exists (
    select 1 from public.source_revisions
    where id = target_source_revision_id
  ) then
    return jsonb_build_object('status', 'source_revision_not_found');
  end if;

  insert into public.agronomic_observations (
    source_revision_id,
    original_subject_text,
    original_parameter_text,
    original_value_text,
    original_unit_text,
    evidence_locator,
    evidence_excerpt,
    evidence_context_json,
    created_by
  ) values (
    target_source_revision_id,
    nullif(btrim(observation_original_subject_text), ''),
    nullif(btrim(observation_original_parameter_text), ''),
    observation_original_value_text,
    nullif(btrim(observation_original_unit_text), ''),
    nullif(btrim(observation_evidence_locator), ''),
    nullif(btrim(observation_evidence_excerpt), ''),
    observation_evidence_context_json,
    v_auth_user_id
  )
  returning * into v_observation;

  return jsonb_build_object(
    'status', 'created',
    'agronomic_observation_id', v_observation.id,
    'row_version', v_observation.row_version
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.update_pending_agronomic_observation(
  target_observation_id uuid,
  expected_row_version bigint,
  observation_original_value_text text,
  observation_original_subject_text text default null,
  observation_original_parameter_text text default null,
  observation_original_unit_text text default null,
  observation_evidence_locator text default null,
  observation_evidence_excerpt text default null,
  observation_evidence_context_json jsonb default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_observation public.agronomic_observations%rowtype;
begin
  if auth.uid() is null then
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

  if v_observation.original_value_text is not distinct from observation_original_value_text
     and v_observation.original_subject_text is not distinct from nullif(btrim(observation_original_subject_text), '')
     and v_observation.original_parameter_text is not distinct from nullif(btrim(observation_original_parameter_text), '')
     and v_observation.original_unit_text is not distinct from nullif(btrim(observation_original_unit_text), '')
     and v_observation.evidence_locator is not distinct from nullif(btrim(observation_evidence_locator), '')
     and v_observation.evidence_excerpt is not distinct from nullif(btrim(observation_evidence_excerpt), '')
     and v_observation.evidence_context_json is not distinct from observation_evidence_context_json then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_observation_id', v_observation.id,
      'row_version', v_observation.row_version
    );
  end if;

  update public.agronomic_observations
  set original_subject_text = nullif(btrim(observation_original_subject_text), ''),
      original_parameter_text = nullif(btrim(observation_original_parameter_text), ''),
      original_value_text = observation_original_value_text,
      original_unit_text = nullif(btrim(observation_original_unit_text), ''),
      evidence_locator = nullif(btrim(observation_evidence_locator), ''),
      evidence_excerpt = nullif(btrim(observation_evidence_excerpt), ''),
      evidence_context_json = observation_evidence_context_json
  where id = target_observation_id
  returning * into v_observation;

  return jsonb_build_object(
    'status', 'updated',
    'agronomic_observation_id', v_observation.id,
    'row_version', v_observation.row_version
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.normalize_agronomic_observation(
  target_observation_id uuid,
  expected_row_version bigint,
  observation_kind text,
  observation_parameter_id uuid,
  observation_crop_id uuid,
  observation_cultivar_id uuid default null,
  observation_production_context_id uuid default null,
  observation_protection_context_id uuid default null,
  observation_training_context_id uuid default null,
  observation_harvest_purpose_id uuid default null,
  observation_numeric_value numeric default null,
  observation_numeric_min_value numeric default null,
  observation_numeric_max_value numeric default null,
  observation_boolean_value boolean default null,
  observation_enum_value_id uuid default null,
  observation_unit_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
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
    select 1 from public.catalog_crops_s030
    where id = observation_crop_id
  ) then
    return jsonb_build_object('status', 'identity_not_found');
  end if;

  if not exists (
    select 1 from public.catalog_crops_s030
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
$function$;

create function public.mark_agronomic_observation_not_mappable(
  target_observation_id uuid,
  expected_row_version bigint,
  observation_finalization_reason text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
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

  update public.agronomic_observations
  set status = 'NOT_MAPPABLE',
      kind = null,
      parameter_id = null,
      crop_id = null,
      cultivar_id = null,
      production_context_id = null,
      protection_context_id = null,
      training_context_id = null,
      harvest_purpose_id = null,
      numeric_value = null,
      numeric_min_value = null,
      numeric_max_value = null,
      boolean_value = null,
      enum_value_id = null,
      unit_id = null,
      finalization_reason = observation_finalization_reason,
      finalized_by = v_auth_user_id,
      finalized_at = now()
  where id = target_observation_id
  returning * into v_observation;

  return jsonb_build_object(
    'status', 'not_mappable',
    'agronomic_observation_id', v_observation.id,
    'row_version', v_observation.row_version,
    'observation_status', v_observation.status
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;

create function public.reject_agronomic_observation(
  target_observation_id uuid,
  expected_row_version bigint,
  observation_finalization_reason text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
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

  update public.agronomic_observations
  set status = 'REJECTED',
      kind = null,
      parameter_id = null,
      crop_id = null,
      cultivar_id = null,
      production_context_id = null,
      protection_context_id = null,
      training_context_id = null,
      harvest_purpose_id = null,
      numeric_value = null,
      numeric_min_value = null,
      numeric_max_value = null,
      boolean_value = null,
      enum_value_id = null,
      unit_id = null,
      finalization_reason = observation_finalization_reason,
      finalized_by = v_auth_user_id,
      finalized_at = now()
  where id = target_observation_id
  returning * into v_observation;

  return jsonb_build_object(
    'status', 'rejected',
    'agronomic_observation_id', v_observation.id,
    'row_version', v_observation.row_version,
    'observation_status', v_observation.status
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 6. FUNCTION PRIVILEGES
-- ============================================================================

revoke all on function public.create_agronomic_source(text, text, text, text)
  from public, anon, authenticated;
revoke all on function public.update_agronomic_source(uuid, bigint, text, text, text)
  from public, anon, authenticated;
revoke all on function public.set_agronomic_source_active(uuid, bigint, boolean)
  from public, anon, authenticated;
revoke all on function public.create_source_document(uuid, text, text, text, text, text)
  from public, anon, authenticated;
revoke all on function public.update_source_document(uuid, bigint, text, text, text, text)
  from public, anon, authenticated;
revoke all on function public.set_source_document_active(uuid, bigint, boolean)
  from public, anon, authenticated;
revoke all on function public.start_acquisition_run(uuid, text, text)
  from public, anon, authenticated;
revoke all on function public.complete_acquisition_run(uuid, text, text, bigint, text, text, timestamptz, integer)
  from public, anon, authenticated;
revoke all on function public.fail_acquisition_run(uuid, text, integer)
  from public, anon, authenticated;
revoke all on function public.create_agronomic_observation(uuid, text, text, text, text, text, text, jsonb)
  from public, anon, authenticated;
revoke all on function public.update_pending_agronomic_observation(uuid, bigint, text, text, text, text, text, text, jsonb)
  from public, anon, authenticated;
revoke all on function public.normalize_agronomic_observation(uuid, bigint, text, uuid, uuid, uuid, uuid, uuid, uuid, uuid, numeric, numeric, numeric, boolean, uuid, uuid)
  from public, anon, authenticated;
revoke all on function public.mark_agronomic_observation_not_mappable(uuid, bigint, text)
  from public, anon, authenticated;
revoke all on function public.reject_agronomic_observation(uuid, bigint, text)
  from public, anon, authenticated;

grant execute on function public.create_agronomic_source(text, text, text, text)
  to authenticated;
grant execute on function public.update_agronomic_source(uuid, bigint, text, text, text)
  to authenticated;
grant execute on function public.set_agronomic_source_active(uuid, bigint, boolean)
  to authenticated;
grant execute on function public.create_source_document(uuid, text, text, text, text, text)
  to authenticated;
grant execute on function public.update_source_document(uuid, bigint, text, text, text, text)
  to authenticated;
grant execute on function public.set_source_document_active(uuid, bigint, boolean)
  to authenticated;
grant execute on function public.start_acquisition_run(uuid, text, text)
  to authenticated;
grant execute on function public.complete_acquisition_run(uuid, text, text, bigint, text, text, timestamptz, integer)
  to authenticated;
grant execute on function public.fail_acquisition_run(uuid, text, integer)
  to authenticated;
grant execute on function public.create_agronomic_observation(uuid, text, text, text, text, text, text, jsonb)
  to authenticated;
grant execute on function public.update_pending_agronomic_observation(uuid, bigint, text, text, text, text, text, text, jsonb)
  to authenticated;
grant execute on function public.normalize_agronomic_observation(uuid, bigint, text, uuid, uuid, uuid, uuid, uuid, uuid, uuid, numeric, numeric, numeric, boolean, uuid, uuid)
  to authenticated;
grant execute on function public.mark_agronomic_observation_not_mappable(uuid, bigint, text)
  to authenticated;
grant execute on function public.reject_agronomic_observation(uuid, bigint, text)
  to authenticated;
