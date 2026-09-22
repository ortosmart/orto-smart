-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 6 - WORKFLOW EDITORIALE
-- ============================================================================
--
-- Candidate, Evidence, Submission immutabili e Review.
-- Nessuna RPC e nessun dato iniziale.
--
-- La FK verso agronomic_assertions e i controlli sul target saranno completati
-- nelle Tranche 7-8, prima dell'attivazione dei Write Path.
-- La publication resta bloccata fino alla relativa implementazione.
-- ============================================================================


-- ============================================================================
-- 1. AGRONOMIC CANDIDATES
-- ============================================================================

create table public.agronomic_candidates (
  id uuid primary key default gen_random_uuid(),

  action text not null,
  status text not null default 'DRAFT',
  target_assertion_id uuid null,

  kind text not null,
  parameter_id uuid not null,
  crop_id uuid not null,
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

  editorial_reason text not null,

  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  row_version bigint not null default 1,

  withdrawn_by uuid null,
  withdrawn_at timestamptz null,
  withdrawn_reason text null,

  published_by uuid null,
  published_at timestamptz null,

  constraint agronomic_candidates_parameter_id_fkey
    foreign key (parameter_id)
    references public.agronomic_parameters(id)
    on delete restrict,

  constraint agronomic_candidates_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint agronomic_candidates_cultivar_crop_fkey
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars(id, crop_id)
    on delete restrict,

  constraint agronomic_candidates_production_context_id_fkey
    foreign key (production_context_id)
    references public.production_contexts(id)
    on delete restrict,

  constraint agronomic_candidates_protection_context_id_fkey
    foreign key (protection_context_id)
    references public.protection_contexts(id)
    on delete restrict,

  constraint agronomic_candidates_training_context_id_fkey
    foreign key (training_context_id)
    references public.training_contexts(id)
    on delete restrict,

  constraint agronomic_candidates_harvest_purpose_id_fkey
    foreign key (harvest_purpose_id)
    references public.harvest_purposes(id)
    on delete restrict,

  constraint agronomic_candidates_enum_value_parameter_fkey
    foreign key (enum_value_id, parameter_id)
    references public.parameter_enum_values(id, parameter_id)
    on delete restrict,

  constraint agronomic_candidates_unit_id_fkey
    foreign key (unit_id)
    references public.measurement_units(id)
    on delete restrict,

  constraint agronomic_candidates_created_by_fkey
    foreign key (created_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_candidates_withdrawn_by_fkey
    foreign key (withdrawn_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_candidates_published_by_fkey
    foreign key (published_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_candidates_action_check
    check (action in ('CREATE', 'REPLACE', 'WITHDRAW')),

  constraint agronomic_candidates_status_check
    check (
      status in (
        'DRAFT',
        'IN_REVIEW',
        'ACCEPTED',
        'PUBLISHED',
        'REJECTED',
        'WITHDRAWN'
      )
    ),

  constraint agronomic_candidates_action_target_check
    check (
      (action = 'CREATE' and target_assertion_id is null)
      or
      (
        action in ('REPLACE', 'WITHDRAW')
        and target_assertion_id is not null
      )
    ),

  constraint agronomic_candidates_kind_check
    check (kind in ('VALUE', 'NOT_APPLICABLE')),

  constraint agronomic_candidates_numeric_values_check
    check (
      (
        numeric_value is null
        or numeric_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_min_value is null
        or numeric_min_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_max_value is null
        or numeric_max_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_min_value is null
        or numeric_max_value is null
        or numeric_min_value <= numeric_max_value
      )
    ),

  constraint agronomic_candidates_not_applicable_payload_check
    check (
      kind <> 'NOT_APPLICABLE'
      or (
        numeric_value is null
        and numeric_min_value is null
        and numeric_max_value is null
        and boolean_value is null
        and enum_value_id is null
        and unit_id is null
      )
    ),

  constraint agronomic_candidates_editorial_reason_check
    check (
      private.normalize_catalog_text(editorial_reason) <> ''
      and char_length(editorial_reason) <= 4000
    ),

  constraint agronomic_candidates_withdrawal_audit_check
    check (
      (
        status = 'WITHDRAWN'
        and withdrawn_by is not null
        and withdrawn_at is not null
        and withdrawn_at >= created_at
        and withdrawn_reason is not null
        and private.normalize_catalog_text(withdrawn_reason) <> ''
        and char_length(withdrawn_reason) <= 4000
      )
      or
      (
        status <> 'WITHDRAWN'
        and withdrawn_by is null
        and withdrawn_at is null
        and withdrawn_reason is null
      )
    ),

  constraint agronomic_candidates_publication_audit_check
    check (
      (
        status = 'PUBLISHED'
        and published_by is not null
        and published_at is not null
        and published_at >= created_at
      )
      or
      (
        status <> 'PUBLISHED'
        and published_by is null
        and published_at is null
      )
    ),

  constraint agronomic_candidates_row_version_check
    check (row_version >= 1)
);

create index agronomic_candidates_status_idx
  on public.agronomic_candidates(status);

create index agronomic_candidates_parameter_id_idx
  on public.agronomic_candidates(parameter_id);

create index agronomic_candidates_crop_id_idx
  on public.agronomic_candidates(crop_id);

create index agronomic_candidates_cultivar_id_idx
  on public.agronomic_candidates(cultivar_id)
  where cultivar_id is not null;

create index agronomic_candidates_target_assertion_id_idx
  on public.agronomic_candidates(target_assertion_id)
  where target_assertion_id is not null;

alter table public.agronomic_candidates
  enable row level security;

revoke all privileges
  on table public.agronomic_candidates
  from public, anon, authenticated;

grant select
  on table public.agronomic_candidates
  to authenticated;

create policy agronomic_candidates_select_authenticated
  on public.agronomic_candidates
  for select
  to authenticated
  using (true);

comment on table public.agronomic_candidates is
  'Proposte editoriali del Catalogo; non costituiscono Knowledge canonica.';

comment on column public.agronomic_candidates.action is
  'Operazione proposta: CREATE, REPLACE oppure WITHDRAW; immutabile dopo la creazione.';

comment on column public.agronomic_candidates.target_assertion_id is
  'Target per REPLACE e WITHDRAW; FK e controlli completati nelle Tranche 7-8.';

comment on column public.agronomic_candidates.unit_id is
  'Unita editoriale del valore numerico, dimensionalmente compatibile ma non necessariamente canonica.';

comment on column public.agronomic_candidates.row_version is
  'Versione della proposta, incrementata anche dalle modifiche alle Evidence.';

comment on column public.agronomic_candidates.withdrawn_reason is
  'Motivazione del ritiro della proposta stessa, distinto dalla action WITHDRAW.';

-- ============================================================================
-- 2. CANDIDATE EVIDENCE
-- ============================================================================

create table public.candidate_evidence (
  id uuid primary key default gen_random_uuid(),

  candidate_id uuid not null,
  observation_id uuid not null,

  evidence_role text not null,
  editorial_note text null,

  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  row_version bigint not null default 1,

  constraint candidate_evidence_candidate_id_fkey
    foreign key (candidate_id)
    references public.agronomic_candidates(id)
    on delete restrict,

  constraint candidate_evidence_observation_id_fkey
    foreign key (observation_id)
    references public.agronomic_observations(id)
    on delete restrict,

  constraint candidate_evidence_created_by_fkey
    foreign key (created_by)
    references auth.users(id)
    on delete restrict,

  constraint candidate_evidence_candidate_observation_unique
    unique (candidate_id, observation_id),

  constraint candidate_evidence_role_check
    check (
      evidence_role in (
        'SUPPORTING',
        'CONFLICTING',
        'CONTEXTUAL'
      )
    ),

  constraint candidate_evidence_editorial_note_check
    check (
      editorial_note is null
      or (
        private.normalize_catalog_text(editorial_note) <> ''
        and char_length(editorial_note) <= 4000
      )
    ),

  constraint candidate_evidence_role_note_check
    check (
      evidence_role = 'SUPPORTING'
      or editorial_note is not null
    ),

  constraint candidate_evidence_row_version_check
    check (row_version >= 1)
);

create index candidate_evidence_observation_id_idx
  on public.candidate_evidence(observation_id);

alter table public.candidate_evidence
  enable row level security;

revoke all privileges
  on table public.candidate_evidence
  from public, anon, authenticated;

grant select
  on table public.candidate_evidence
  to authenticated;

create policy candidate_evidence_select_authenticated
  on public.candidate_evidence
  for select
  to authenticated
  using (true);

comment on table public.candidate_evidence is
  'Collegamenti editoriali di lavoro tra Candidate e Observations; modificabili solo in DRAFT.';

comment on column public.candidate_evidence.observation_id is
  'Observation terminale: NORMALIZED oppure NOT_MAPPABLE, secondo il ruolo ammesso.';

comment on column public.candidate_evidence.evidence_role is
  'Ruolo editoriale: SUPPORTING, CONFLICTING oppure CONTEXTUAL.';

comment on column public.candidate_evidence.editorial_note is
  'Nota obbligatoria per CONFLICTING, CONTEXTUAL e per ogni Evidence di Candidate action WITHDRAW.';

-- ============================================================================
-- 3. CANDIDATE SUBMISSIONS
-- ============================================================================

create table public.candidate_submissions (
  id uuid primary key default gen_random_uuid(),

  candidate_id uuid not null,
  submission_no integer not null,
  candidate_row_version bigint not null,

  creation_transaction_id xid8 not null
    default pg_catalog.pg_current_xact_id(),

  action text not null,
  target_assertion_id uuid null,

  kind text not null,
  parameter_id uuid not null,
  crop_id uuid not null,
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

  editorial_reason text not null,

  submitted_by uuid not null,
  submitted_at timestamptz not null default now(),

  constraint candidate_submissions_candidate_id_fkey
    foreign key (candidate_id)
    references public.agronomic_candidates(id)
    on delete restrict,

  constraint candidate_submissions_candidate_number_unique
    unique (candidate_id, submission_no),

  constraint candidate_submissions_parameter_id_fkey
    foreign key (parameter_id)
    references public.agronomic_parameters(id)
    on delete restrict,

  constraint candidate_submissions_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint candidate_submissions_cultivar_crop_fkey
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars(id, crop_id)
    on delete restrict,

  constraint candidate_submissions_production_context_id_fkey
    foreign key (production_context_id)
    references public.production_contexts(id)
    on delete restrict,

  constraint candidate_submissions_protection_context_id_fkey
    foreign key (protection_context_id)
    references public.protection_contexts(id)
    on delete restrict,

  constraint candidate_submissions_training_context_id_fkey
    foreign key (training_context_id)
    references public.training_contexts(id)
    on delete restrict,

  constraint candidate_submissions_harvest_purpose_id_fkey
    foreign key (harvest_purpose_id)
    references public.harvest_purposes(id)
    on delete restrict,

  constraint candidate_submissions_enum_value_parameter_fkey
    foreign key (enum_value_id, parameter_id)
    references public.parameter_enum_values(id, parameter_id)
    on delete restrict,

  constraint candidate_submissions_unit_id_fkey
    foreign key (unit_id)
    references public.measurement_units(id)
    on delete restrict,

  constraint candidate_submissions_submitted_by_fkey
    foreign key (submitted_by)
    references auth.users(id)
    on delete restrict,

  constraint candidate_submissions_number_check
    check (submission_no >= 1),

  constraint candidate_submissions_candidate_version_check
    check (candidate_row_version >= 1),

  constraint candidate_submissions_action_check
    check (action in ('CREATE', 'REPLACE', 'WITHDRAW')),

  constraint candidate_submissions_action_target_check
    check (
      (action = 'CREATE' and target_assertion_id is null)
      or
      (
        action in ('REPLACE', 'WITHDRAW')
        and target_assertion_id is not null
      )
    ),

  constraint candidate_submissions_kind_check
    check (kind in ('VALUE', 'NOT_APPLICABLE')),

  constraint candidate_submissions_numeric_values_check
    check (
      (
        numeric_value is null
        or numeric_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_min_value is null
        or numeric_min_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_max_value is null
        or numeric_max_value not in (
          'NaN'::numeric,
          'Infinity'::numeric,
          '-Infinity'::numeric
        )
      )
      and
      (
        numeric_min_value is null
        or numeric_max_value is null
        or numeric_min_value <= numeric_max_value
      )
    ),

  constraint candidate_submissions_not_applicable_payload_check
    check (
      kind <> 'NOT_APPLICABLE'
      or (
        numeric_value is null
        and numeric_min_value is null
        and numeric_max_value is null
        and boolean_value is null
        and enum_value_id is null
        and unit_id is null
      )
    ),

  constraint candidate_submissions_editorial_reason_check
    check (
      private.normalize_catalog_text(editorial_reason) <> ''
      and char_length(editorial_reason) <= 4000
    )
);

alter table public.candidate_submissions
  enable row level security;

revoke all privileges
  on table public.candidate_submissions
  from public, anon, authenticated;

grant select
  on table public.candidate_submissions
  to authenticated;

create policy candidate_submissions_select_authenticated
  on public.candidate_submissions
  for select
  to authenticated
  using (true);

comment on table public.candidate_submissions is
  'Snapshot editoriali immutabili prodotti a ogni submit della Candidate.';

comment on column public.candidate_submissions.submission_no is
  'Numero progressivo del submit all interno della Candidate, assegnato sotto lock.';

comment on column public.candidate_submissions.candidate_row_version is
  'Versione della Candidate fotografata prima del passaggio da DRAFT a IN_REVIEW.';

comment on column public.candidate_submissions.creation_transaction_id is
  'Identificatore tecnico della transazione di creazione; limita la copia delle Evidence alla stessa transazione.';

comment on column public.candidate_submissions.target_assertion_id is
  'Target fotografato; FK e verifiche verso Assertion completate nelle Tranche 7-8.';

comment on column public.candidate_submissions.unit_id is
  'Unita editoriale fotografata; puo differire dall unita canonica del Parameter.';

comment on column public.candidate_submissions.submitted_by is
  'Attore del submit, derivato da auth.uid() nel futuro Write Path autoritativo.';

-- ============================================================================
-- 4. CANDIDATE SUBMISSION EVIDENCE
-- ============================================================================

create table public.candidate_submission_evidence (
  id uuid primary key default gen_random_uuid(),

  submission_id uuid not null,
  observation_id uuid not null,

  evidence_role text not null,
  editorial_note text null,

  constraint candidate_submission_evidence_submission_id_fkey
    foreign key (submission_id)
    references public.candidate_submissions(id)
    on delete restrict,

  constraint candidate_submission_evidence_observation_id_fkey
    foreign key (observation_id)
    references public.agronomic_observations(id)
    on delete restrict,

  constraint candidate_submission_evidence_submission_observation_unique
    unique (submission_id, observation_id),

  constraint candidate_submission_evidence_role_check
    check (
      evidence_role in (
        'SUPPORTING',
        'CONFLICTING',
        'CONTEXTUAL'
      )
    ),

  constraint candidate_submission_evidence_editorial_note_check
    check (
      editorial_note is null
      or (
        private.normalize_catalog_text(editorial_note) <> ''
        and char_length(editorial_note) <= 4000
      )
    ),

  constraint candidate_submission_evidence_role_note_check
    check (
      evidence_role = 'SUPPORTING'
      or editorial_note is not null
    )
);

create index candidate_submission_evidence_observation_id_idx
  on public.candidate_submission_evidence(observation_id);

alter table public.candidate_submission_evidence
  enable row level security;

revoke all privileges
  on table public.candidate_submission_evidence
  from public, anon, authenticated;

grant select
  on table public.candidate_submission_evidence
  to authenticated;

create policy candidate_submission_evidence_select_authenticated
  on public.candidate_submission_evidence
  for select
  to authenticated
  using (true);

comment on table public.candidate_submission_evidence is
  'Fotografia immutabile delle Evidence associate a una Submission.';

comment on column public.candidate_submission_evidence.observation_id is
  'Observation terminale e immutabile; nessuna dipendenza dalle Evidence di lavoro modificabili.';

comment on column public.candidate_submission_evidence.editorial_note is
  'Nota editoriale fotografata al submit; non segue modifiche successive della Candidate.';


-- ============================================================================
-- 5. CANDIDATE REVIEWS
-- ============================================================================

create table public.candidate_reviews (
  id uuid primary key default gen_random_uuid(),

  submission_id uuid not null,
  decision text not null,
  confidence text null,
  reason text not null,

  reviewed_by uuid not null,
  reviewed_at timestamptz not null default now(),

  constraint candidate_reviews_submission_id_fkey
    foreign key (submission_id)
    references public.candidate_submissions(id)
    on delete restrict,

  constraint candidate_reviews_reviewed_by_fkey
    foreign key (reviewed_by)
    references auth.users(id)
    on delete restrict,

  constraint candidate_reviews_submission_id_key
    unique (submission_id),

  constraint candidate_reviews_decision_check
    check (
      decision in (
        'ACCEPT',
        'REJECT',
        'RETURN_TO_DRAFT'
      )
    ),

  constraint candidate_reviews_confidence_check
    check (
      confidence is null
      or confidence in ('LOW', 'MEDIUM', 'HIGH')
    ),

  constraint candidate_reviews_reason_check
    check (
      private.normalize_catalog_text(reason) <> ''
      and char_length(reason) <= 4000
    )
);

alter table public.candidate_reviews
  enable row level security;

revoke all privileges
  on table public.candidate_reviews
  from public, anon, authenticated;

grant select
  on table public.candidate_reviews
  to authenticated;

create policy candidate_reviews_select_authenticated
  on public.candidate_reviews
  for select
  to authenticated
  using (true);

comment on table public.candidate_reviews is
  'Decisioni editoriali immutabili su specifiche Submission; al massimo una Review per Submission.';

comment on column public.candidate_reviews.decision is
  'Decisione ACCEPT, REJECT o RETURN_TO_DRAFT; ACCEPT non pubblica Knowledge.';

comment on column public.candidate_reviews.confidence is
  'Valutazione editoriale facoltativa, non uno score utilizzabile dal Resolver.';

comment on column public.candidate_reviews.reviewed_by is
  'Attore della Review, derivato da auth.uid() nel futuro Write Path autoritativo.';

-- ============================================================================
-- 6. CANDIDATE PAYLOAD VALIDATION
-- ============================================================================

create function private.validate_candidate_payload(
  candidate_row public.agronomic_candidates
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_parameter public.agronomic_parameters%rowtype;
  v_unit_quantity_kind text;
begin
  select p.*
  into v_parameter
  from public.agronomic_parameters p
  where p.id = candidate_row.parameter_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate parameter not found';
  end if;

  if candidate_row.cultivar_id is null then
    if v_parameter.allows_crop is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow crop-level candidates';
    end if;
  else
    if v_parameter.allows_cultivar is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow cultivar-level candidates';
    end if;

    perform 1
    from public.crop_cultivars cv
    where cv.id = candidate_row.cultivar_id
      and cv.crop_id = candidate_row.crop_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate cultivar does not belong to the crop';
    end if;
  end if;

  if v_parameter.knowledge_scope = 'INTRINSIC'
    and (
      candidate_row.production_context_id is not null
      or candidate_row.protection_context_id is not null
      or candidate_row.training_context_id is not null
      or candidate_row.harvest_purpose_id is not null
    ) then
    raise exception using
      errcode = '23514',
      message = 'Intrinsic candidate parameter cannot use contexts';
  end if;

  if (
    candidate_row.production_context_id is not null
    and v_parameter.allows_production_context is not true
  ) or (
    candidate_row.protection_context_id is not null
    and v_parameter.allows_protection_context is not true
  ) or (
    candidate_row.training_context_id is not null
    and v_parameter.allows_training_context is not true
  ) or (
    candidate_row.harvest_purpose_id is not null
    and v_parameter.allows_harvest_purpose is not true
  ) then
    raise exception using
      errcode = '23514',
      message = 'Candidate uses a context not allowed by its parameter';
  end if;

  if candidate_row.kind = 'NOT_APPLICABLE' then
    if candidate_row.numeric_value is not null
      or candidate_row.numeric_min_value is not null
      or candidate_row.numeric_max_value is not null
      or candidate_row.boolean_value is not null
      or candidate_row.enum_value_id is not null
      or candidate_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'NOT_APPLICABLE candidate cannot carry values or unit';
    end if;

    return;
  end if;

  if candidate_row.kind is distinct from 'VALUE' then
    raise exception using
      errcode = '23514',
      message = 'Invalid candidate kind';
  end if;

  if v_parameter.value_schema = 'NUMERIC_SCALAR' then
    if candidate_row.numeric_value is null
      or candidate_row.numeric_min_value is not null
      or candidate_row.numeric_max_value is not null
      or candidate_row.boolean_value is not null
      or candidate_row.enum_value_id is not null
      or candidate_row.unit_id is null then
      raise exception using
        errcode = '23514',
        message = 'Candidate payload does not match NUMERIC_SCALAR';
    end if;

  elsif v_parameter.value_schema = 'NUMERIC_RANGE' then
    if candidate_row.numeric_value is not null
      or candidate_row.numeric_min_value is null
      or candidate_row.numeric_max_value is null
      or candidate_row.boolean_value is not null
      or candidate_row.enum_value_id is not null
      or candidate_row.unit_id is null then
      raise exception using
        errcode = '23514',
        message = 'Candidate payload does not match NUMERIC_RANGE';
    end if;

  elsif v_parameter.value_schema = 'BOOLEAN' then
    if candidate_row.numeric_value is not null
      or candidate_row.numeric_min_value is not null
      or candidate_row.numeric_max_value is not null
      or candidate_row.boolean_value is null
      or candidate_row.enum_value_id is not null
      or candidate_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'Candidate payload does not match BOOLEAN';
    end if;

  elsif v_parameter.value_schema = 'ENUM' then
    if candidate_row.numeric_value is not null
      or candidate_row.numeric_min_value is not null
      or candidate_row.numeric_max_value is not null
      or candidate_row.boolean_value is not null
      or candidate_row.enum_value_id is null
      or candidate_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'Candidate payload does not match ENUM';
    end if;

    perform 1
    from public.parameter_enum_values ev
    where ev.id = candidate_row.enum_value_id
      and ev.parameter_id = candidate_row.parameter_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate enum value does not belong to its parameter';
    end if;

  else
    raise exception using
      errcode = '23514',
      message = 'Unsupported candidate parameter value schema';
  end if;

  if v_parameter.value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
    select u.quantity_kind
    into v_unit_quantity_kind
    from public.measurement_units u
    where u.id = candidate_row.unit_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate measurement unit not found';
    end if;

    if v_unit_quantity_kind is distinct from v_parameter.quantity_kind then
      raise exception using
        errcode = '23514',
        message = 'Candidate unit is dimensionally incompatible';
    end if;

    if candidate_row.numeric_value in (
      'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
    ) or candidate_row.numeric_min_value in (
      'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
    ) or candidate_row.numeric_max_value in (
      'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric
    ) then
      raise exception using
        errcode = '23514',
        message = 'Candidate numeric values must be finite';
    end if;

    if candidate_row.numeric_min_value > candidate_row.numeric_max_value then
      raise exception using
        errcode = '23514',
        message = 'Candidate range minimum exceeds maximum';
    end if;
  end if;
end;
$function$;

revoke all
  on function private.validate_candidate_payload(public.agronomic_candidates)
  from public, anon, authenticated;

comment on function private.validate_candidate_payload(public.agronomic_candidates) is
  'Validazione condivisa del payload editoriale: target, contesti, schema del valore e compatibilita dimensionale.';

-- ============================================================================
-- 7. CANDIDATE LIFECYCLE GUARD
-- ============================================================================

create function private.enforce_agronomic_candidate()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_old_payload jsonb;
  v_new_payload jsonb;
begin
  if tg_op = 'DELETE' then
    raise exception using
      errcode = '23514',
      message = 'Agronomic candidates cannot be deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to mutate an agronomic candidate';
  end if;

  if tg_op = 'INSERT' then
    if new.status <> 'DRAFT' then
      raise exception using
        errcode = '23514',
        message = 'A new agronomic candidate must start in DRAFT status';
    end if;

    if new.created_by is distinct from v_auth_user_id then
      raise exception using
        errcode = '42501',
        message = 'Candidate creator must match auth.uid()';
    end if;

    if new.withdrawn_by is not null
       or new.withdrawn_at is not null
       or new.withdrawn_reason is not null
       or new.published_by is not null
       or new.published_at is not null then
      raise exception using
        errcode = '23514',
        message = 'A new candidate cannot contain withdrawal or publication audit data';
    end if;

    perform private.validate_candidate_payload(new);

    return new;
  end if;

  if new.id is distinct from old.id
     or new.created_by is distinct from old.created_by
     or new.created_at is distinct from old.created_at then
    raise exception using
      errcode = '23514',
      message = 'Candidate identity and creation audit are immutable';
  end if;

  if new.action is distinct from old.action
     or new.target_assertion_id is distinct from old.target_assertion_id then
    raise exception using
      errcode = '23514',
      message = 'Candidate action and target assertion are immutable';
  end if;

  if new.status is distinct from old.status
     and not (
       (old.status = 'DRAFT'
        and new.status in ('IN_REVIEW', 'WITHDRAWN'))
       or
       (old.status = 'IN_REVIEW'
        and new.status in (
          'DRAFT',
          'ACCEPTED',
          'REJECTED',
          'WITHDRAWN'
        ))
       or
       (old.status = 'ACCEPTED'
        and new.status in ('PUBLISHED', 'WITHDRAWN'))
     ) then
    raise exception using
      errcode = '23514',
      message = format(
        'Invalid agronomic candidate status transition: %s -> %s',
        old.status,
        new.status
      );
  end if;

  v_old_payload :=
    to_jsonb(old) - array[
      'status',
      'withdrawn_by',
      'withdrawn_at',
      'withdrawn_reason',
      'published_by',
      'published_at',
      'updated_at',
      'row_version'
    ];

  v_new_payload :=
    to_jsonb(new) - array[
      'status',
      'withdrawn_by',
      'withdrawn_at',
      'withdrawn_reason',
      'published_by',
      'published_at',
      'updated_at',
      'row_version'
    ];

  if v_new_payload is distinct from v_old_payload
     and not (
       old.status = 'DRAFT'
       and new.status = 'DRAFT'
     ) then
    raise exception using
      errcode = '23514',
      message = 'Candidate editorial payload is mutable only while remaining in DRAFT';
  end if;

  if new.status = 'WITHDRAWN'
     and old.status <> 'WITHDRAWN' then
    if new.withdrawn_reason is null
       or private.normalize_catalog_text(new.withdrawn_reason) = '' then
      raise exception using
        errcode = '23514',
        message = 'Candidate withdrawal requires a reason';
    end if;

    new.withdrawn_by := v_auth_user_id;
    new.withdrawn_at := now();
  elsif old.status = 'WITHDRAWN' then
    if new.withdrawn_by is distinct from old.withdrawn_by
       or new.withdrawn_at is distinct from old.withdrawn_at
       or new.withdrawn_reason is distinct from old.withdrawn_reason then
      raise exception using
        errcode = '23514',
        message = 'Candidate withdrawal audit is immutable';
    end if;
  elsif new.withdrawn_by is not null
        or new.withdrawn_at is not null
        or new.withdrawn_reason is not null then
    raise exception using
      errcode = '23514',
      message = 'Withdrawal audit is allowed only for a WITHDRAWN candidate';
  end if;

  if new.status = 'PUBLISHED'
     and old.status <> 'PUBLISHED' then
    new.published_by := v_auth_user_id;
    new.published_at := now();
  elsif old.status = 'PUBLISHED' then
    if new.published_by is distinct from old.published_by
       or new.published_at is distinct from old.published_at then
      raise exception using
        errcode = '23514',
        message = 'Candidate publication audit is immutable';
    end if;
  elsif new.published_by is not null
        or new.published_at is not null then
    raise exception using
      errcode = '23514',
      message = 'Publication audit is allowed only for a PUBLISHED candidate';
  end if;

  perform private.validate_candidate_payload(new);

  return new;
end;
$function$;

revoke all
  on function private.enforce_agronomic_candidate()
  from public, anon, authenticated;

create trigger agronomic_candidates_enforce_lifecycle
before insert or update or delete
on public.agronomic_candidates
for each row
execute function private.enforce_agronomic_candidate();

create trigger agronomic_candidates_set_updated_at_and_row_version
before update
on public.agronomic_candidates
for each row
execute function public.set_updated_at_and_row_version();

comment on function private.enforce_agronomic_candidate() is
  'Protegge identita, payload editoriale, transizioni di stato e audit delle Candidate.';

-- ============================================================================
-- 8. CANDIDATE EVIDENCE GUARD
-- ============================================================================

create function private.enforce_candidate_evidence()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_candidate_id uuid;
  v_candidate public.agronomic_candidates%rowtype;
  v_observation public.agronomic_observations%rowtype;
begin
  -- Il trigger AFTER aggiorna la row_version della Candidate.
  if tg_when = 'AFTER' then
    if tg_op = 'DELETE' then
      v_candidate_id := old.candidate_id;
    else
      v_candidate_id := new.candidate_id;
    end if;

    update public.agronomic_candidates
    set row_version = row_version
    where id = v_candidate_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Candidate referenced by evidence does not exist';
    end if;

    if tg_op = 'DELETE' then
      return old;
    end if;

    return new;
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to mutate candidate evidence';
  end if;

  if tg_op = 'UPDATE' then
    if new.id is distinct from old.id
       or new.candidate_id is distinct from old.candidate_id
       or new.observation_id is distinct from old.observation_id
       or new.created_by is distinct from old.created_by
       or new.created_at is distinct from old.created_at then
      raise exception using
        errcode = '23514',
        message = 'Candidate evidence identity, references and creation audit are immutable';
    end if;
  end if;

  if tg_op = 'DELETE' then
    v_candidate_id := old.candidate_id;
  else
    v_candidate_id := new.candidate_id;
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = v_candidate_id
  for update;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate referenced by evidence does not exist';
  end if;

  if v_candidate.status <> 'DRAFT' then
    raise exception using
      errcode = '23514',
      message = 'Candidate evidence is mutable only while the Candidate is in DRAFT';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  if tg_op = 'INSERT'
     and new.created_by is distinct from v_auth_user_id then
    raise exception using
      errcode = '42501',
      message = 'Candidate evidence creator must match auth.uid()';
  end if;

  select o.*
  into v_observation
  from public.agronomic_observations o
  where o.id = new.observation_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Observation referenced by candidate evidence does not exist';
  end if;

  if v_observation.status not in ('NORMALIZED', 'NOT_MAPPABLE') then
    raise exception using
      errcode = '23514',
      message = 'Only NORMALIZED or NOT_MAPPABLE observations can be candidate evidence';
  end if;

  if v_observation.status = 'NOT_MAPPABLE'
     and new.evidence_role = 'SUPPORTING' then
    raise exception using
      errcode = '23514',
      message = 'A NOT_MAPPABLE observation cannot be SUPPORTING evidence';
  end if;

  if new.evidence_role = 'SUPPORTING' then
    if v_observation.status <> 'NORMALIZED' then
      raise exception using
        errcode = '23514',
        message = 'SUPPORTING evidence must reference a NORMALIZED observation';
    end if;

    if v_observation.parameter_id is distinct from v_candidate.parameter_id
       or v_observation.crop_id is distinct from v_candidate.crop_id
       or v_observation.cultivar_id is distinct from v_candidate.cultivar_id
       or v_observation.production_context_id
            is distinct from v_candidate.production_context_id
       or v_observation.protection_context_id
            is distinct from v_candidate.protection_context_id
       or v_observation.training_context_id
            is distinct from v_candidate.training_context_id
       or v_observation.harvest_purpose_id
            is distinct from v_candidate.harvest_purpose_id then
      raise exception using
        errcode = '23514',
        message = 'SUPPORTING evidence must match the Candidate logical key';
    end if;
  end if;

  if (
       new.evidence_role in ('CONFLICTING', 'CONTEXTUAL')
       or v_candidate.action = 'WITHDRAW'
     )
     and (
       new.editorial_note is null
       or private.normalize_catalog_text(new.editorial_note) = ''
     ) then
    raise exception using
      errcode = '23514',
      message = 'This candidate evidence requires an editorial note';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_candidate_evidence()
  from public, anon, authenticated;

create trigger candidate_evidence_enforce_lifecycle
before insert or update or delete
on public.candidate_evidence
for each row
execute function private.enforce_candidate_evidence();

create trigger candidate_evidence_set_updated_at_and_row_version
before update
on public.candidate_evidence
for each row
execute function public.set_updated_at_and_row_version();

create trigger candidate_evidence_touch_candidate
after insert or update or delete
on public.candidate_evidence
for each row
execute function private.enforce_candidate_evidence();

comment on function private.enforce_candidate_evidence() is
  'Valida stato, ruolo e compatibilita delle Evidence e aggiorna la row_version della Candidate.';

-- ============================================================================
-- 9. CANDIDATE SUBMISSION GUARD
-- ============================================================================

create function private.enforce_candidate_submission()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_candidate public.agronomic_candidates%rowtype;
  v_expected_submission_no integer;
begin
  if tg_op <> 'INSERT' then
    raise exception using
      errcode = '23514',
      message = 'Candidate submissions are immutable and cannot be updated or deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to create a candidate submission';
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = new.candidate_id
  for update;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate referenced by submission does not exist';
  end if;

  if v_candidate.status <> 'DRAFT' then
    raise exception using
      errcode = '23514',
      message = 'Only a DRAFT Candidate can be submitted';
  end if;

  if new.submitted_by is distinct from v_auth_user_id then
    raise exception using
      errcode = '42501',
      message = 'Submission actor must match auth.uid()';
  end if;

  if new.creation_transaction_id
       is distinct from pg_catalog.pg_current_xact_id() then
    raise exception using
      errcode = '23514',
      message = 'Submission transaction identifier must match the current transaction';
  end if;

  if new.candidate_row_version
       is distinct from v_candidate.row_version then
    raise exception using
      errcode = '40001',
      message = 'Candidate row version changed before submission';
  end if;

  select coalesce(max(s.submission_no), 0) + 1
  into v_expected_submission_no
  from public.candidate_submissions s
  where s.candidate_id = new.candidate_id;

  if new.submission_no <> v_expected_submission_no then
    raise exception using
      errcode = '23514',
      message = format(
        'Invalid submission number: expected %s, received %s',
        v_expected_submission_no,
        new.submission_no
      );
  end if;

  if row(
       new.action,
       new.target_assertion_id,
       new.kind,
       new.parameter_id,
       new.crop_id,
       new.cultivar_id,
       new.production_context_id,
       new.protection_context_id,
       new.training_context_id,
       new.harvest_purpose_id,
       new.numeric_value,
       new.numeric_min_value,
       new.numeric_max_value,
       new.boolean_value,
       new.enum_value_id,
       new.unit_id,
       new.editorial_reason
     )
     is distinct from
     row(
       v_candidate.action,
       v_candidate.target_assertion_id,
       v_candidate.kind,
       v_candidate.parameter_id,
       v_candidate.crop_id,
       v_candidate.cultivar_id,
       v_candidate.production_context_id,
       v_candidate.protection_context_id,
       v_candidate.training_context_id,
       v_candidate.harvest_purpose_id,
       v_candidate.numeric_value,
       v_candidate.numeric_min_value,
       v_candidate.numeric_max_value,
       v_candidate.boolean_value,
       v_candidate.enum_value_id,
       v_candidate.unit_id,
       v_candidate.editorial_reason
     ) then
    raise exception using
      errcode = '23514',
      message = 'Candidate submission must be an exact snapshot of the Candidate';
  end if;

  perform private.validate_candidate_payload(v_candidate);

  if v_candidate.action in ('CREATE', 'REPLACE')
     and not exists (
       select 1
       from public.candidate_evidence ce
       where ce.candidate_id = v_candidate.id
         and ce.evidence_role = 'SUPPORTING'
     ) then
    raise exception using
      errcode = '23514',
      message = 'CREATE and REPLACE submissions require at least one SUPPORTING evidence';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_candidate_submission()
  from public, anon, authenticated;

create trigger candidate_submissions_enforce_lifecycle
before insert or update or delete
on public.candidate_submissions
for each row
execute function private.enforce_candidate_submission();

comment on function private.enforce_candidate_submission() is
  'Impedisce mutazioni delle Submission e verifica numerazione, versione, attore e snapshot completo della Candidate.';

-- ============================================================================
-- 10. CANDIDATE SUBMISSION EVIDENCE GUARD
-- ============================================================================

create function private.enforce_candidate_submission_evidence()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_submission public.candidate_submissions%rowtype;
begin
  if tg_op <> 'INSERT' then
    raise exception using
      errcode = '23514',
      message = 'Candidate submission evidence is immutable and cannot be updated or deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to create candidate submission evidence';
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = new.submission_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Submission referenced by snapshot evidence does not exist';
  end if;

  if v_submission.creation_transaction_id
       is distinct from pg_catalog.pg_current_xact_id() then
    raise exception using
      errcode = '23514',
      message = 'Submission evidence can only be copied in the Submission creation transaction';
  end if;

  if not exists (
    select 1
    from public.candidate_evidence ce
    where ce.candidate_id = v_submission.candidate_id
      and ce.observation_id = new.observation_id
      and ce.evidence_role = new.evidence_role
      and ce.editorial_note is not distinct from new.editorial_note
  ) then
    raise exception using
      errcode = '23514',
      message = 'Submission evidence must exactly match current Candidate evidence';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_candidate_submission_evidence()
  from public, anon, authenticated;

create trigger candidate_submission_evidence_enforce_immutability
before insert or update or delete
on public.candidate_submission_evidence
for each row
execute function private.enforce_candidate_submission_evidence();

comment on function private.enforce_candidate_submission_evidence() is
  'Consente la copia immutabile delle Evidence soltanto nella transazione che crea la Submission.';

-- ============================================================================
-- 11. CANDIDATE REVIEW GUARD
-- ============================================================================

create function private.enforce_candidate_review()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_submission public.candidate_submissions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
  v_target_status text;
begin
  -- Dopo l'inserimento applica deterministicamente la decisione.
  if tg_when = 'AFTER' then
    select s.*
    into v_submission
    from public.candidate_submissions s
    where s.id = new.submission_id;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Submission referenced by Review does not exist';
    end if;

    v_target_status :=
      case new.decision
        when 'ACCEPT' then 'ACCEPTED'
        when 'REJECT' then 'REJECTED'
        when 'RETURN_TO_DRAFT' then 'DRAFT'
      end;

    update public.agronomic_candidates
    set status = v_target_status
    where id = v_submission.candidate_id
      and status = 'IN_REVIEW';

    if not found then
      raise exception using
        errcode = '40001',
        message = 'Candidate is no longer available for this Review decision';
    end if;

    return new;
  end if;

  if tg_op <> 'INSERT' then
    raise exception using
      errcode = '23514',
      message = 'Candidate Reviews are immutable and cannot be updated or deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to create a Candidate Review';
  end if;

  if not private.can_review_catalog() then
    raise exception using
      errcode = '42501',
      message = 'Catalog review capability is required';
  end if;

  if new.reviewed_by is distinct from v_auth_user_id then
    raise exception using
      errcode = '42501',
      message = 'Review actor must match auth.uid()';
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = new.submission_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Submission referenced by Review does not exist';
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = v_submission.candidate_id
  for update;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate referenced by reviewed Submission does not exist';
  end if;

  if v_candidate.status <> 'IN_REVIEW' then
    raise exception using
      errcode = '23514',
      message = 'Only an IN_REVIEW Candidate can receive a Review';
  end if;

  if exists (
    select 1
    from public.candidate_submissions later_submission
    where later_submission.candidate_id = v_submission.candidate_id
      and later_submission.submission_no > v_submission.submission_no
  ) then
    raise exception using
      errcode = '23514',
      message = 'Only the latest Candidate Submission can be reviewed';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_candidate_review()
  from public, anon, authenticated;

create trigger candidate_reviews_enforce_lifecycle
before insert or update or delete
on public.candidate_reviews
for each row
execute function private.enforce_candidate_review();

create trigger candidate_reviews_apply_decision
after insert
on public.candidate_reviews
for each row
execute function private.enforce_candidate_review();

comment on function private.enforce_candidate_review() is
  'Protegge le Review immutabili e applica ACCEPT, REJECT o RETURN_TO_DRAFT alla Candidate.';

-- ============================================================================
-- 12. DEFERRED SUBMISSION COMPLETENESS
-- ============================================================================

create function private.check_candidate_submission_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_submission_id uuid;
  v_submission public.candidate_submissions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
  v_review public.candidate_reviews%rowtype;
  v_has_review boolean;
  v_expected_candidate_status text;
  v_expected_row_version bigint;
begin
  if tg_table_name = 'candidate_submissions' then
    v_submission_id := new.id;
  else
    v_submission_id := new.submission_id;
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = v_submission_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate Submission disappeared before deferred validation';
  end if;

  if v_submission.creation_transaction_id
       is distinct from pg_catalog.pg_current_xact_id() then
    raise exception using
      errcode = '23514',
      message = 'Deferred Submission validation must run in its creation transaction';
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = v_submission.candidate_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate referenced by Submission does not exist';
  end if;

  if exists (
    select 1
    from public.candidate_submissions later_submission
    where later_submission.candidate_id = v_submission.candidate_id
      and later_submission.submission_no > v_submission.submission_no
  ) then
    raise exception using
      errcode = '23514',
      message = 'A newly created Submission must be the latest Candidate Submission';
  end if;

  -- Lo snapshot deve contenere esattamente tutte le Evidence di lavoro.
  if exists (
    (
      select
        ce.observation_id,
        ce.evidence_role,
        ce.editorial_note
      from public.candidate_evidence ce
      where ce.candidate_id = v_submission.candidate_id
    )
    except
    (
      select
        cse.observation_id,
        cse.evidence_role,
        cse.editorial_note
      from public.candidate_submission_evidence cse
      where cse.submission_id = v_submission.id
    )
  )
  or exists (
    (
      select
        cse.observation_id,
        cse.evidence_role,
        cse.editorial_note
      from public.candidate_submission_evidence cse
      where cse.submission_id = v_submission.id
    )
    except
    (
      select
        ce.observation_id,
        ce.evidence_role,
        ce.editorial_note
      from public.candidate_evidence ce
      where ce.candidate_id = v_submission.candidate_id
    )
  ) then
    raise exception using
      errcode = '23514',
      message = 'Submission Evidence snapshot is incomplete or differs from Candidate Evidence';
  end if;

  if v_submission.action in ('CREATE', 'REPLACE')
     and not exists (
       select 1
       from public.candidate_submission_evidence cse
       where cse.submission_id = v_submission.id
         and cse.evidence_role = 'SUPPORTING'
     ) then
    raise exception using
      errcode = '23514',
      message = 'CREATE and REPLACE Submission snapshots require SUPPORTING evidence';
  end if;

  select r.*
  into v_review
  from public.candidate_reviews r
  where r.submission_id = v_submission.id;

  v_has_review := found;

  if v_has_review then
    v_expected_candidate_status :=
      case v_review.decision
        when 'ACCEPT' then 'ACCEPTED'
        when 'REJECT' then 'REJECTED'
        when 'RETURN_TO_DRAFT' then 'DRAFT'
      end;

    v_expected_row_version :=
      v_submission.candidate_row_version + 2;
  else
    v_expected_candidate_status := 'IN_REVIEW';

    v_expected_row_version :=
      v_submission.candidate_row_version + 1;
  end if;

  if v_candidate.status <> v_expected_candidate_status then
    raise exception using
      errcode = '23514',
      message = format(
        'Incomplete Candidate lifecycle during submit: expected status %s, found %s',
        v_expected_candidate_status,
        v_candidate.status
      );
  end if;

  if v_candidate.row_version <> v_expected_row_version then
    raise exception using
      errcode = '40001',
      message = format(
        'Candidate changed during submit: expected row_version %s, found %s',
        v_expected_row_version,
        v_candidate.row_version
      );
  end if;

  return null;
end;
$function$;

revoke all
  on function private.check_candidate_submission_complete()
  from public, anon, authenticated;

create constraint trigger candidate_submissions_check_complete
after insert
on public.candidate_submissions
deferrable initially deferred
for each row
execute function private.check_candidate_submission_complete();

create constraint trigger candidate_submission_evidence_check_complete
after insert
on public.candidate_submission_evidence
deferrable initially deferred
for each row
execute function private.check_candidate_submission_complete();

comment on function private.check_candidate_submission_complete() is
  'Verifica a fine transazione snapshot Evidence, stato e row_version della Candidate sottoposta.';
