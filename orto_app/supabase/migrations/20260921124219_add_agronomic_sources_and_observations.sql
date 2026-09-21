-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 4 - FONTI, ACQUISIZIONI E OBSERVATIONS
-- ============================================================================
--
-- Introduce:
-- - fonti agronomiche globali;
-- - documenti logici delle fonti;
-- - revisioni immutabili dei documenti;
-- - storico dei tentativi di acquisizione;
-- - observations tipizzate con provenance esplicita.
--
-- Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. AGRONOMIC SOURCES
-- ============================================================================

create table public.agronomic_sources (
  id uuid
    constraint agronomic_sources_pkey
    primary key
    default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,
  base_url text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint agronomic_sources_code_key
    unique (code),

  constraint agronomic_sources_code_check
    check (code ~ '^[A-Z][A-Z0-9_]{0,79}$'),

  constraint agronomic_sources_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 200
    ),

  constraint agronomic_sources_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 2000
      )
    ),

  constraint agronomic_sources_base_url_check
    check (
      base_url is null
      or (
        private.normalize_catalog_text(base_url) <> ''
        and char_length(base_url) <= 2048
      )
    ),

  constraint agronomic_sources_row_version_check
    check (row_version >= 1)
);

create trigger agronomic_sources_set_updated_at_and_row_version
before update on public.agronomic_sources
for each row
execute function public.set_updated_at_and_row_version();

alter table public.agronomic_sources
  enable row level security;

revoke all privileges
  on table public.agronomic_sources
  from public, anon, authenticated;

grant select
  on table public.agronomic_sources
  to authenticated;

create policy agronomic_sources_select_authenticated
  on public.agronomic_sources
  for select
  to authenticated
  using (true);

comment on table public.agronomic_sources is
  'Enti, autori, editori o raccolte responsabili delle fonti agronomiche.';

comment on column public.agronomic_sources.code is
  'Codice tecnico stabile e univoco della fonte.';

comment on column public.agronomic_sources.base_url is
  'Indirizzo principale facoltativo della fonte; non partecipa alla sua identita.';


-- ============================================================================
-- 2. SOURCE DOCUMENTS
-- ============================================================================

create table public.source_documents (
  id uuid
    constraint source_documents_pkey
    primary key
    default gen_random_uuid(),

  source_id uuid not null,

  document_key text not null,
  title text not null,
  canonical_locator text null,
  description text null,
  language_code text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint source_documents_source_id_fkey
    foreign key (source_id)
    references public.agronomic_sources(id)
    on delete restrict,

  constraint source_documents_source_key_unique
    unique (source_id, document_key),

  constraint source_documents_document_key_check
    check (document_key ~ '^[A-Z][A-Z0-9_]{0,119}$'),

  constraint source_documents_title_check
    check (
      private.normalize_catalog_text(title) <> ''
      and char_length(title) <= 500
    ),

  constraint source_documents_canonical_locator_check
    check (
      canonical_locator is null
      or (
        private.normalize_catalog_text(canonical_locator) <> ''
        and char_length(canonical_locator) <= 2048
      )
    ),

  constraint source_documents_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 2000
      )
    ),

  constraint source_documents_language_code_check
    check (
      language_code is null
      or (
        char_length(language_code) <= 35
        and language_code ~ '^[A-Za-z]{2,8}(-[A-Za-z0-9]{1,8})*$'
      )
    ),

  constraint source_documents_row_version_check
    check (row_version >= 1)
);

create trigger source_documents_set_updated_at_and_row_version
before update on public.source_documents
for each row
execute function public.set_updated_at_and_row_version();

alter table public.source_documents
  enable row level security;

revoke all privileges
  on table public.source_documents
  from public, anon, authenticated;

grant select
  on table public.source_documents
  to authenticated;

create policy source_documents_select_authenticated
  on public.source_documents
  for select
  to authenticated
  using (true);

comment on table public.source_documents is
  'Risorse logiche stabili appartenenti alle fonti agronomiche.';

comment on column public.source_documents.document_key is
  'Chiave tecnica stabile del documento all interno della fonte.';

comment on column public.source_documents.canonical_locator is
  'URL, DOI, ISBN, identificatore API o altro riferimento logico non identitario.';


-- ============================================================================
-- 3. SOURCE REVISIONS
-- ============================================================================

create table public.source_revisions (
  id uuid
    constraint source_revisions_pkey
    primary key
    default gen_random_uuid(),

  document_id uuid not null,

  content_hash text not null,
  content_type text not null,
  content_size_bytes bigint null,
  storage_path text null,
  source_version_label text null,
  source_published_at timestamptz null,

  created_at timestamptz not null default now(),

  constraint source_revisions_document_id_fkey
    foreign key (document_id)
    references public.source_documents(id)
    on delete restrict,

  constraint source_revisions_document_hash_key
    unique (document_id, content_hash),

  constraint source_revisions_id_document_unique
    unique (id, document_id),

  constraint source_revisions_content_hash_check
    check (content_hash ~ '^[0-9a-f]{64}$'),

  constraint source_revisions_content_type_check
    check (
      private.normalize_catalog_text(content_type) <> ''
      and char_length(content_type) <= 255
    ),

  constraint source_revisions_content_size_check
    check (
      content_size_bytes is null
      or content_size_bytes >= 0
    ),

  constraint source_revisions_storage_path_check
    check (
      storage_path is null
      or (
        private.normalize_catalog_text(storage_path) <> ''
        and char_length(storage_path) <= 1024
      )
    ),

  constraint source_revisions_version_label_check
    check (
      source_version_label is null
      or (
        private.normalize_catalog_text(source_version_label) <> ''
        and char_length(source_version_label) <= 500
      )
    )
);

create function private.prevent_source_revision_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  raise exception using
    errcode = '55000',
    message = 'Source revisions are immutable';
end;
$function$;

revoke all
  on function private.prevent_source_revision_mutation()
  from public, anon, authenticated;

create trigger source_revisions_prevent_mutation
before update or delete on public.source_revisions
for each row
execute function private.prevent_source_revision_mutation();

alter table public.source_revisions
  enable row level security;

revoke all privileges
  on table public.source_revisions
  from public, anon, authenticated;

grant select
  on table public.source_revisions
  to authenticated;

create policy source_revisions_select_authenticated
  on public.source_revisions
  for select
  to authenticated
  using (true);

comment on table public.source_revisions is
  'Fotografie immutabili dei contenuti dei documenti sorgente.';

comment on column public.source_revisions.content_hash is
  'Hash SHA-256 minuscolo del contenuto della revisione.';

comment on column public.source_revisions.storage_path is
  'Riferimento interno facoltativo allo snapshot archiviato.';


-- ============================================================================
-- 4. ACQUISITION RUNS
-- ============================================================================

create table public.acquisition_runs (
  id uuid
    constraint acquisition_runs_pkey
    primary key
    default gen_random_uuid(),

  document_id uuid not null,
  source_revision_id uuid null,

  method text not null,
  status text not null default 'STARTED',

  effective_locator text null,
  http_status_code integer null,
  error_message text null,

  started_by uuid not null,
  started_at timestamptz not null default now(),
  finalized_by uuid null,
  finalized_at timestamptz null,

  constraint acquisition_runs_document_id_fkey
    foreign key (document_id)
    references public.source_documents(id)
    on delete restrict,

  constraint acquisition_runs_revision_document_fkey
    foreign key (source_revision_id, document_id)
    references public.source_revisions(id, document_id)
    on delete restrict,

  constraint acquisition_runs_started_by_fkey
    foreign key (started_by)
    references auth.users(id)
    on delete restrict,

  constraint acquisition_runs_finalized_by_fkey
    foreign key (finalized_by)
    references auth.users(id)
    on delete restrict,

  constraint acquisition_runs_method_check
    check (method in ('MANUAL', 'HTML', 'PDF', 'API')),

  constraint acquisition_runs_status_check
    check (status in ('STARTED', 'SUCCEEDED', 'UNCHANGED', 'FAILED')),

  constraint acquisition_runs_state_revision_check
    check (
      (status in ('SUCCEEDED', 'UNCHANGED') and source_revision_id is not null)
      or
      (status in ('STARTED', 'FAILED') and source_revision_id is null)
    ),

  constraint acquisition_runs_finalization_check
    check (
      (
        status = 'STARTED'
        and finalized_by is null
        and finalized_at is null
      )
      or
      (
        status in ('SUCCEEDED', 'UNCHANGED', 'FAILED')
        and finalized_by is not null
        and finalized_at is not null
        and finalized_at >= started_at
      )
    ),

  constraint acquisition_runs_error_check
    check (
      (
        status = 'FAILED'
        and error_message is not null
        and private.normalize_catalog_text(error_message) <> ''
        and char_length(error_message) <= 4000
      )
      or
      (
        status <> 'FAILED'
        and error_message is null
      )
    ),

  constraint acquisition_runs_effective_locator_check
    check (
      effective_locator is null
      or (
        private.normalize_catalog_text(effective_locator) <> ''
        and char_length(effective_locator) <= 2048
      )
    ),

  constraint acquisition_runs_http_status_check
    check (
      http_status_code is null
      or http_status_code between 100 and 599
    )
);

create index acquisition_runs_document_started_at_idx
  on public.acquisition_runs(document_id, started_at desc);

create index acquisition_runs_source_revision_id_idx
  on public.acquisition_runs(source_revision_id)
  where source_revision_id is not null;

create function private.enforce_acquisition_run_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if tg_op = 'DELETE' then
    raise exception using
      errcode = '55000',
      message = 'Acquisition runs cannot be deleted';
  end if;

  if old.status <> 'STARTED' then
    raise exception using
      errcode = '55000',
      message = 'Terminal acquisition runs are immutable';
  end if;

  if new.status not in ('SUCCEEDED', 'UNCHANGED', 'FAILED') then
    raise exception using
      errcode = '55000',
      message = 'An acquisition run can only transition from STARTED to a terminal status';
  end if;

  if new.id is distinct from old.id
    or new.document_id is distinct from old.document_id
    or new.method is distinct from old.method
    or new.started_by is distinct from old.started_by
    or new.started_at is distinct from old.started_at then
    raise exception using
      errcode = '55000',
      message = 'Acquisition run identity and start data are immutable';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_acquisition_run_mutation()
  from public, anon, authenticated;

create trigger acquisition_runs_enforce_mutation
before update or delete on public.acquisition_runs
for each row
execute function private.enforce_acquisition_run_mutation();

alter table public.acquisition_runs
  enable row level security;

revoke all privileges
  on table public.acquisition_runs
  from public, anon, authenticated;

grant select
  on table public.acquisition_runs
  to authenticated;

create policy acquisition_runs_select_authenticated
  on public.acquisition_runs
  for select
  to authenticated
  using (true);

comment on table public.acquisition_runs is
  'Storico immutabile a terminalizzazione avvenuta dei tentativi di acquisizione.';

comment on column public.acquisition_runs.source_revision_id is
  'Nuova revisione per SUCCEEDED o revisione gia esistente per UNCHANGED.';


-- ============================================================================
-- 5. AGRONOMIC OBSERVATIONS
-- ============================================================================

create table public.agronomic_observations (
  id uuid
    constraint agronomic_observations_pkey
    primary key
    default gen_random_uuid(),

  source_revision_id uuid not null,

  status text not null default 'PENDING',
  kind text null,

  original_subject_text text null,
  original_parameter_text text null,
  original_value_text text not null,
  original_unit_text text null,
  evidence_locator text null,
  evidence_excerpt text null,
  evidence_context_json jsonb null,

  parameter_id uuid null,
  crop_id uuid null,
  cultivar_id uuid null,

  production_context_id uuid null,
  protection_context_id uuid null,
  training_context_id uuid null,
  harvest_purpose_id uuid null,

  numeric_value numeric null,
  numeric_min_value numeric null,
  numeric_max_value numeric null,
  boolean_value boolean null,
  enum_value_id uuid null,
  unit_id uuid null,

  finalization_reason text null,
  finalized_by uuid null,
  finalized_at timestamptz null,

  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  row_version bigint not null default 1,

  constraint agronomic_observations_source_revision_id_fkey
    foreign key (source_revision_id)
    references public.source_revisions(id)
    on delete restrict,

  constraint agronomic_observations_parameter_id_fkey
    foreign key (parameter_id)
    references public.agronomic_parameters(id)
    on delete restrict,

  constraint agronomic_observations_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint agronomic_observations_cultivar_crop_fkey
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars(id, crop_id)
    on delete restrict,

  constraint agronomic_observations_production_context_id_fkey
    foreign key (production_context_id)
    references public.production_contexts(id)
    on delete restrict,

  constraint agronomic_observations_protection_context_id_fkey
    foreign key (protection_context_id)
    references public.protection_contexts(id)
    on delete restrict,

  constraint agronomic_observations_training_context_id_fkey
    foreign key (training_context_id)
    references public.training_contexts(id)
    on delete restrict,

  constraint agronomic_observations_harvest_purpose_id_fkey
    foreign key (harvest_purpose_id)
    references public.harvest_purposes(id)
    on delete restrict,

  constraint agronomic_observations_enum_value_parameter_fkey
    foreign key (enum_value_id, parameter_id)
    references public.parameter_enum_values(id, parameter_id)
    on delete restrict,

  constraint agronomic_observations_unit_id_fkey
    foreign key (unit_id)
    references public.measurement_units(id)
    on delete restrict,

  constraint agronomic_observations_finalized_by_fkey
    foreign key (finalized_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_observations_created_by_fkey
    foreign key (created_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_observations_status_check
    check (status in ('PENDING', 'NORMALIZED', 'NOT_MAPPABLE', 'REJECTED')),

  constraint agronomic_observations_kind_check
    check (kind is null or kind in ('VALUE', 'NOT_APPLICABLE')),

  constraint agronomic_observations_original_subject_check
    check (
      original_subject_text is null
      or (
        private.normalize_catalog_text(original_subject_text) <> ''
        and char_length(original_subject_text) <= 500
      )
    ),

  constraint agronomic_observations_original_parameter_check
    check (
      original_parameter_text is null
      or (
        private.normalize_catalog_text(original_parameter_text) <> ''
        and char_length(original_parameter_text) <= 500
      )
    ),

  constraint agronomic_observations_original_value_check
    check (
      private.normalize_catalog_text(original_value_text) <> ''
      and char_length(original_value_text) <= 2000
    ),

  constraint agronomic_observations_original_unit_check
    check (
      original_unit_text is null
      or (
        private.normalize_catalog_text(original_unit_text) <> ''
        and char_length(original_unit_text) <= 500
      )
    ),

  constraint agronomic_observations_evidence_locator_check
    check (
      evidence_locator is null
      or (
        private.normalize_catalog_text(evidence_locator) <> ''
        and char_length(evidence_locator) <= 1000
      )
    ),

  constraint agronomic_observations_evidence_excerpt_check
    check (
      evidence_excerpt is null
      or (
        private.normalize_catalog_text(evidence_excerpt) <> ''
        and char_length(evidence_excerpt) <= 8000
      )
    ),

  constraint agronomic_observations_evidence_context_check
    check (
      evidence_context_json is null
      or jsonb_typeof(evidence_context_json) = 'object'
    ),

  constraint agronomic_observations_numeric_values_check
    check (
      (numeric_value is null or numeric_value not in ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric))
      and (numeric_min_value is null or numeric_min_value not in ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric))
      and (numeric_max_value is null or numeric_max_value not in ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric))
      and (
        numeric_min_value is null
        or numeric_max_value is null
        or numeric_min_value <= numeric_max_value
      )
    ),

  constraint agronomic_observations_finalization_check
    check (
      (
        status = 'PENDING'
        and finalized_by is null
        and finalized_at is null
      )
      or
      (
        status in ('NORMALIZED', 'NOT_MAPPABLE', 'REJECTED')
        and finalized_by is not null
        and finalized_at is not null
        and finalized_at >= created_at
      )
    ),

  constraint agronomic_observations_reason_check
    check (
      (
        status in ('NOT_MAPPABLE', 'REJECTED')
        and finalization_reason is not null
        and private.normalize_catalog_text(finalization_reason) <> ''
        and char_length(finalization_reason) <= 4000
      )
      or
      (
        status in ('PENDING', 'NORMALIZED')
        and finalization_reason is null
      )
    ),

  constraint agronomic_observations_unmapped_payload_check
    check (
      status not in ('NOT_MAPPABLE', 'REJECTED')
      or (
        kind is null
        and parameter_id is null
        and crop_id is null
        and cultivar_id is null
        and production_context_id is null
        and protection_context_id is null
        and training_context_id is null
        and harvest_purpose_id is null
        and numeric_value is null
        and numeric_min_value is null
        and numeric_max_value is null
        and boolean_value is null
        and enum_value_id is null
        and unit_id is null
      )
    ),

  constraint agronomic_observations_row_version_check
    check (row_version >= 1)
);

create index agronomic_observations_source_revision_id_idx
  on public.agronomic_observations(source_revision_id);

create index agronomic_observations_status_idx
  on public.agronomic_observations(status);

create index agronomic_observations_parameter_id_idx
  on public.agronomic_observations(parameter_id)
  where parameter_id is not null;

create index agronomic_observations_crop_id_idx
  on public.agronomic_observations(crop_id)
  where crop_id is not null;

create index agronomic_observations_cultivar_id_idx
  on public.agronomic_observations(cultivar_id)
  where cultivar_id is not null;

create function private.enforce_agronomic_observation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_parameter public.agronomic_parameters%rowtype;
begin
  if tg_op = 'DELETE' then
    raise exception using
      errcode = '55000',
      message = 'Agronomic observations cannot be deleted';
  end if;

  if tg_op = 'UPDATE' then
    if old.status <> 'PENDING' then
      raise exception using
        errcode = '55000',
        message = 'Terminal agronomic observations are immutable';
    end if;

    if new.id is distinct from old.id
      or new.source_revision_id is distinct from old.source_revision_id
      or new.created_by is distinct from old.created_by
      or new.created_at is distinct from old.created_at then
      raise exception using
        errcode = '55000',
        message = 'Agronomic observation identity and provenance are immutable';
    end if;
  end if;

  if new.status = 'NORMALIZED' then
    if new.kind is null
      or new.parameter_id is null
      or new.crop_id is null then
      raise exception using
        errcode = '23514',
        message = 'A normalized observation requires kind, parameter and crop';
    end if;

    select p.*
    into v_parameter
    from public.agronomic_parameters p
    where p.id = new.parameter_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Agronomic parameter not found';
    end if;

    if v_parameter.is_active is not true then
      raise exception using
        errcode = '23514',
        message = 'A normalized observation cannot use an inactive parameter';
    end if;

    if new.cultivar_id is null and v_parameter.allows_crop is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow crop-level observations';
    end if;

    if new.cultivar_id is not null and v_parameter.allows_cultivar is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow cultivar-level observations';
    end if;

    if v_parameter.knowledge_scope = 'INTRINSIC'
      and (
        new.production_context_id is not null
        or new.protection_context_id is not null
        or new.training_context_id is not null
        or new.harvest_purpose_id is not null
      ) then
      raise exception using
        errcode = '23514',
        message = 'Intrinsic parameters cannot use operational contexts';
    end if;

    if new.production_context_id is not null
      and v_parameter.allows_production_context is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow production context';
    end if;

    if new.protection_context_id is not null
      and v_parameter.allows_protection_context is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow protection context';
    end if;

    if new.training_context_id is not null
      and v_parameter.allows_training_context is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow training context';
    end if;

    if new.harvest_purpose_id is not null
      and v_parameter.allows_harvest_purpose is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow harvest purpose';
    end if;

    if new.kind = 'NOT_APPLICABLE' then
      if new.numeric_value is not null
        or new.numeric_min_value is not null
        or new.numeric_max_value is not null
        or new.boolean_value is not null
        or new.enum_value_id is not null
        or new.unit_id is not null then
        raise exception using
          errcode = '23514',
          message = 'NOT_APPLICABLE observations cannot carry a value or unit';
      end if;
    elsif v_parameter.value_schema = 'NUMERIC_SCALAR' then
      if new.numeric_value is null
        or new.numeric_min_value is not null
        or new.numeric_max_value is not null
        or new.boolean_value is not null
        or new.enum_value_id is not null
        or new.unit_id is distinct from v_parameter.canonical_unit_id then
        raise exception using
          errcode = '23514',
          message = 'Observation payload does not match NUMERIC_SCALAR parameter';
      end if;
    elsif v_parameter.value_schema = 'NUMERIC_RANGE' then
      if new.numeric_value is not null
        or new.numeric_min_value is null
        or new.numeric_max_value is null
        or new.boolean_value is not null
        or new.enum_value_id is not null
        or new.unit_id is distinct from v_parameter.canonical_unit_id then
        raise exception using
          errcode = '23514',
          message = 'Observation payload does not match NUMERIC_RANGE parameter';
      end if;
    elsif v_parameter.value_schema = 'BOOLEAN' then
      if new.numeric_value is not null
        or new.numeric_min_value is not null
        or new.numeric_max_value is not null
        or new.boolean_value is null
        or new.enum_value_id is not null
        or new.unit_id is not null then
        raise exception using
          errcode = '23514',
          message = 'Observation payload does not match BOOLEAN parameter';
      end if;
    elsif v_parameter.value_schema = 'ENUM' then
      if new.numeric_value is not null
        or new.numeric_min_value is not null
        or new.numeric_max_value is not null
        or new.boolean_value is not null
        or new.enum_value_id is null
        or new.unit_id is not null then
        raise exception using
          errcode = '23514',
          message = 'Observation payload does not match ENUM parameter';
      end if;
    else
      raise exception using
        errcode = '23514',
        message = 'Unsupported agronomic parameter value schema';
    end if;
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_agronomic_observation()
  from public, anon, authenticated;

create trigger agronomic_observations_enforce_lifecycle
before insert or update or delete on public.agronomic_observations
for each row
execute function private.enforce_agronomic_observation();

create trigger agronomic_observations_set_updated_at_and_row_version
before update on public.agronomic_observations
for each row
execute function public.set_updated_at_and_row_version();

alter table public.agronomic_observations
  enable row level security;

revoke all privileges
  on table public.agronomic_observations
  from public, anon, authenticated;

grant select
  on table public.agronomic_observations
  to authenticated;

create policy agronomic_observations_select_authenticated
  on public.agronomic_observations
  for select
  to authenticated
  using (true);

comment on table public.agronomic_observations is
  'Fatti estratti dalle revisioni sorgente prima della pubblicazione nella Knowledge canonica.';

comment on column public.agronomic_observations.original_value_text is
  'Valore originale espresso dalla fonte, conservato separatamente dalla normalizzazione.';

comment on column public.agronomic_observations.evidence_context_json is
  'Contesto eterogeneo della fonte; non rappresenta Applicability Context canonico.';

comment on column public.agronomic_observations.unit_id is
  'Unita canonica del Parameter per Observation numeriche NORMALIZED.';
