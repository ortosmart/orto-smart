-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 7 - CANONICAL KNOWLEDGE
-- ============================================================================
--
-- Introduce:
-- - Assertion agronomiche canoniche revisionate;
-- - provenance verso la Submission accettata;
-- - Evidence canoniche collegate agli snapshot editoriali.
--
-- Nessuna RPC e nessun dato iniziale.
-- Publication e scritture dirette restano bloccate.
-- FK circolari e hardening incrociato saranno completati nella Tranche 8.
-- ============================================================================


-- ============================================================================
-- 1. AGRONOMIC ASSERTIONS
-- ============================================================================

create table public.agronomic_assertions (
  id uuid primary key default gen_random_uuid(),

  previous_revision_id uuid null,
  revision_no integer not null,

  status text not null,
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

  source_submission_id uuid not null,

  approved_by uuid not null,
  approved_at timestamptz not null default now(),

  constraint agronomic_assertions_previous_revision_id_fkey
    foreign key (previous_revision_id)
    references public.agronomic_assertions(id)
    on delete restrict,

  constraint agronomic_assertions_parameter_id_fkey
    foreign key (parameter_id)
    references public.agronomic_parameters(id)
    on delete restrict,

  constraint agronomic_assertions_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint agronomic_assertions_cultivar_crop_fkey
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars(id, crop_id)
    on delete restrict,

  constraint agronomic_assertions_production_context_id_fkey
    foreign key (production_context_id)
    references public.production_contexts(id)
    on delete restrict,

  constraint agronomic_assertions_protection_context_id_fkey
    foreign key (protection_context_id)
    references public.protection_contexts(id)
    on delete restrict,

  constraint agronomic_assertions_training_context_id_fkey
    foreign key (training_context_id)
    references public.training_contexts(id)
    on delete restrict,

  constraint agronomic_assertions_harvest_purpose_id_fkey
    foreign key (harvest_purpose_id)
    references public.harvest_purposes(id)
    on delete restrict,

  constraint agronomic_assertions_enum_value_parameter_fkey
    foreign key (enum_value_id, parameter_id)
    references public.parameter_enum_values(id, parameter_id)
    on delete restrict,

  constraint agronomic_assertions_unit_id_fkey
    foreign key (unit_id)
    references public.measurement_units(id)
    on delete restrict,

  constraint agronomic_assertions_source_submission_id_fkey
    foreign key (source_submission_id)
    references public.candidate_submissions(id)
    on delete restrict,

  constraint agronomic_assertions_approved_by_fkey
    foreign key (approved_by)
    references auth.users(id)
    on delete restrict,

  constraint agronomic_assertions_source_submission_id_key
    unique (source_submission_id),

  constraint agronomic_assertions_revision_no_check
    check (revision_no >= 1),

  constraint agronomic_assertions_status_check
    check (
      status in (
        'APPROVED',
        'SUPERSEDED',
        'WITHDRAWN'
      )
    ),

  constraint agronomic_assertions_kind_check
    check (
      kind in (
        'VALUE',
        'NOT_APPLICABLE'
      )
    ),

  constraint agronomic_assertions_numeric_values_check
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

  constraint agronomic_assertions_not_applicable_payload_check
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

  constraint agronomic_assertions_not_self_previous_check
    check (
      previous_revision_id is null
      or previous_revision_id <> id
    )
);

-- ============================================================================
-- 2. ASSERTION IDENTITY, REVISION CHAIN AND ACCESS
-- ============================================================================

create unique index agronomic_assertions_logical_revision_unique
  on public.agronomic_assertions (
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id,
    revision_no
  )
  nulls not distinct;

create unique index agronomic_assertions_one_approved_per_key
  on public.agronomic_assertions (
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id
  )
  nulls not distinct
  where status = 'APPROVED';

create unique index agronomic_assertions_previous_revision_unique
  on public.agronomic_assertions(previous_revision_id)
  where previous_revision_id is not null;

create index agronomic_assertions_status_idx
  on public.agronomic_assertions(status);

create index agronomic_assertions_parameter_id_idx
  on public.agronomic_assertions(parameter_id);

create index agronomic_assertions_crop_id_idx
  on public.agronomic_assertions(crop_id);

create index agronomic_assertions_cultivar_id_idx
  on public.agronomic_assertions(cultivar_id)
  where cultivar_id is not null;

alter table public.agronomic_assertions
  enable row level security;

revoke all privileges
  on table public.agronomic_assertions
  from public, anon, authenticated;

grant select
  on table public.agronomic_assertions
  to authenticated;

create policy agronomic_assertions_select_authenticated
  on public.agronomic_assertions
  for select
  to authenticated
  using (true);

comment on table public.agronomic_assertions is
  'Revisioni immutabili della Knowledge agronomica canonica.';

comment on column public.agronomic_assertions.previous_revision_id is
  'Revisione immediatamente precedente della stessa logical key.';

comment on column public.agronomic_assertions.revision_no is
  'Numero progressivo della revisione all interno della logical key.';

comment on column public.agronomic_assertions.status is
  'Stato canonico: APPROVED, SUPERSEDED oppure WITHDRAWN.';

comment on column public.agronomic_assertions.kind is
  'Tipo semantico della conoscenza: VALUE oppure NOT_APPLICABLE.';

comment on column public.agronomic_assertions.source_submission_id is
  'Submission accettata che ha prodotto questa Assertion; una Submission produce al massimo una Assertion.';

comment on column public.agronomic_assertions.unit_id is
  'Unita canonica del Parameter; obbligatoria esclusivamente per valori numerici.';

comment on column public.agronomic_assertions.approved_by is
  'Attore della pubblicazione, derivato da auth.uid() nel futuro Write Path autoritativo.';

comment on column public.agronomic_assertions.approved_at is
  'Istante di creazione della revisione approvata; non viene successivamente modificato.';

-- ============================================================================
-- 3. ASSERTION EVIDENCE
-- ============================================================================

create table public.assertion_evidence (
  id uuid primary key default gen_random_uuid(),

  assertion_id uuid not null,
  source_submission_evidence_id uuid not null,
  observation_id uuid not null,

  evidence_role text not null,
  editorial_note text null,

  constraint assertion_evidence_assertion_id_fkey
    foreign key (assertion_id)
    references public.agronomic_assertions(id)
    on delete restrict,

  constraint assertion_evidence_source_submission_evidence_id_fkey
    foreign key (source_submission_evidence_id)
    references public.candidate_submission_evidence(id)
    on delete restrict,

  constraint assertion_evidence_observation_id_fkey
    foreign key (observation_id)
    references public.agronomic_observations(id)
    on delete restrict,

  constraint assertion_evidence_assertion_observation_unique
    unique (assertion_id, observation_id),

  constraint assertion_evidence_source_submission_evidence_key
    unique (source_submission_evidence_id),

  constraint assertion_evidence_role_check
    check (
      evidence_role in (
        'SUPPORTING',
        'CONFLICTING',
        'CONTEXTUAL'
      )
    ),

  constraint assertion_evidence_editorial_note_check
    check (
      editorial_note is null
      or (
        private.normalize_catalog_text(editorial_note) <> ''
        and char_length(editorial_note) <= 4000
      )
    ),

  constraint assertion_evidence_role_note_check
    check (
      evidence_role = 'SUPPORTING'
      or editorial_note is not null
    )
);

create index assertion_evidence_observation_id_idx
  on public.assertion_evidence(observation_id);

alter table public.assertion_evidence
  enable row level security;

revoke all privileges
  on table public.assertion_evidence
  from public, anon, authenticated;

grant select
  on table public.assertion_evidence
  to authenticated;

create policy assertion_evidence_select_authenticated
  on public.assertion_evidence
  for select
  to authenticated
  using (true);

comment on table public.assertion_evidence is
  'Provenance immutabile delle Assertion canoniche, copiata dalla Submission accettata.';

comment on column public.assertion_evidence.source_submission_evidence_id is
  'Riga immutabile della Submission Evidence da cui deriva la Evidence canonica.';

comment on column public.assertion_evidence.observation_id is
  'Observation originale conservata anche come riferimento diretto per la provenance.';

comment on column public.assertion_evidence.evidence_role is
  'Ruolo pubblicato: SUPPORTING, CONFLICTING oppure CONTEXTUAL.';

comment on column public.assertion_evidence.editorial_note is
  'Nota editoriale pubblicata e immutabile.';

-- ============================================================================
-- 4. CANONICAL ASSERTION PAYLOAD VALIDATION
-- ============================================================================

create function private.validate_assertion_payload(
  assertion_row public.agronomic_assertions
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_parameter public.agronomic_parameters%rowtype;
begin
  select p.*
  into v_parameter
  from public.agronomic_parameters p
  where p.id = assertion_row.parameter_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion parameter not found';
  end if;

  if assertion_row.cultivar_id is null then
    if v_parameter.allows_crop is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow crop-level Assertions';
    end if;
  else
    if v_parameter.allows_cultivar is not true then
      raise exception using
        errcode = '23514',
        message = 'Parameter does not allow cultivar-level Assertions';
    end if;

    perform 1
    from public.crop_cultivars cv
    where cv.id = assertion_row.cultivar_id
      and cv.crop_id = assertion_row.crop_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Assertion cultivar does not belong to the Crop';
    end if;
  end if;

  if v_parameter.knowledge_scope = 'INTRINSIC'
     and (
       assertion_row.production_context_id is not null
       or assertion_row.protection_context_id is not null
       or assertion_row.training_context_id is not null
       or assertion_row.harvest_purpose_id is not null
     ) then
    raise exception using
      errcode = '23514',
      message = 'Intrinsic Assertion parameter cannot use contexts';
  end if;

  if (
       assertion_row.production_context_id is not null
       and v_parameter.allows_production_context is not true
     )
     or (
       assertion_row.protection_context_id is not null
       and v_parameter.allows_protection_context is not true
     )
     or (
       assertion_row.training_context_id is not null
       and v_parameter.allows_training_context is not true
     )
     or (
       assertion_row.harvest_purpose_id is not null
       and v_parameter.allows_harvest_purpose is not true
     ) then
    raise exception using
      errcode = '23514',
      message = 'Assertion uses a context not allowed by its Parameter';
  end if;

  if assertion_row.kind = 'NOT_APPLICABLE' then
    if assertion_row.numeric_value is not null
       or assertion_row.numeric_min_value is not null
       or assertion_row.numeric_max_value is not null
       or assertion_row.boolean_value is not null
       or assertion_row.enum_value_id is not null
       or assertion_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'NOT_APPLICABLE Assertion cannot carry values or unit';
    end if;

    return;
  end if;

  if assertion_row.kind is distinct from 'VALUE' then
    raise exception using
      errcode = '23514',
      message = 'Invalid Assertion kind';
  end if;

  if v_parameter.value_schema = 'NUMERIC_SCALAR' then
    if assertion_row.numeric_value is null
       or assertion_row.numeric_min_value is not null
       or assertion_row.numeric_max_value is not null
       or assertion_row.boolean_value is not null
       or assertion_row.enum_value_id is not null
       or assertion_row.unit_id is null then
      raise exception using
        errcode = '23514',
        message = 'Assertion payload does not match NUMERIC_SCALAR';
    end if;

  elsif v_parameter.value_schema = 'NUMERIC_RANGE' then
    if assertion_row.numeric_value is not null
       or assertion_row.numeric_min_value is null
       or assertion_row.numeric_max_value is null
       or assertion_row.boolean_value is not null
       or assertion_row.enum_value_id is not null
       or assertion_row.unit_id is null then
      raise exception using
        errcode = '23514',
        message = 'Assertion payload does not match NUMERIC_RANGE';
    end if;

  elsif v_parameter.value_schema = 'BOOLEAN' then
    if assertion_row.numeric_value is not null
       or assertion_row.numeric_min_value is not null
       or assertion_row.numeric_max_value is not null
       or assertion_row.boolean_value is null
       or assertion_row.enum_value_id is not null
       or assertion_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'Assertion payload does not match BOOLEAN';
    end if;

  elsif v_parameter.value_schema = 'ENUM' then
    if assertion_row.numeric_value is not null
       or assertion_row.numeric_min_value is not null
       or assertion_row.numeric_max_value is not null
       or assertion_row.boolean_value is not null
       or assertion_row.enum_value_id is null
       or assertion_row.unit_id is not null then
      raise exception using
        errcode = '23514',
        message = 'Assertion payload does not match ENUM';
    end if;

    perform 1
    from public.parameter_enum_values ev
    where ev.id = assertion_row.enum_value_id
      and ev.parameter_id = assertion_row.parameter_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Assertion enum value does not belong to its Parameter';
    end if;

  else
    raise exception using
      errcode = '23514',
      message = 'Unsupported Assertion Parameter value schema';
  end if;

  if v_parameter.value_schema in (
    'NUMERIC_SCALAR',
    'NUMERIC_RANGE'
  ) then
    if assertion_row.unit_id
         is distinct from v_parameter.canonical_unit_id then
      raise exception using
        errcode = '23514',
        message = 'Numeric Assertion must use the Parameter canonical unit';
    end if;

    if assertion_row.numeric_value in (
      'NaN'::numeric,
      'Infinity'::numeric,
      '-Infinity'::numeric
    )
    or assertion_row.numeric_min_value in (
      'NaN'::numeric,
      'Infinity'::numeric,
      '-Infinity'::numeric
    )
    or assertion_row.numeric_max_value in (
      'NaN'::numeric,
      'Infinity'::numeric,
      '-Infinity'::numeric
    ) then
      raise exception using
        errcode = '23514',
        message = 'Assertion numeric values must be finite';
    end if;

    if assertion_row.numeric_min_value
         > assertion_row.numeric_max_value then
      raise exception using
        errcode = '23514',
        message = 'Assertion range minimum exceeds maximum';
    end if;
  end if;
end;
$function$;

revoke all
  on function private.validate_assertion_payload(
    public.agronomic_assertions
  )
  from public, anon, authenticated;

comment on function private.validate_assertion_payload(
  public.agronomic_assertions
) is
  'Valida target, contesti, schema del valore e uso obbligatorio dell unita canonica.';

-- ============================================================================
-- 5. ASSERTION SOURCE SUBMISSION VALIDATION
-- ============================================================================

create function private.validate_assertion_source(
  assertion_row public.agronomic_assertions
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_submission public.candidate_submissions%rowtype;
  v_review public.candidate_reviews%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
  v_parameter public.agronomic_parameters%rowtype;
  v_source_unit public.measurement_units%rowtype;
  v_canonical_unit public.measurement_units%rowtype;

  v_expected_numeric_value numeric;
  v_expected_numeric_min_value numeric;
  v_expected_numeric_max_value numeric;
begin
  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = assertion_row.source_submission_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion source Submission not found';
  end if;

  if v_submission.action = 'WITHDRAW' then
    raise exception using
      errcode = '23514',
      message = 'A WITHDRAW Submission cannot create a new Assertion';
  end if;

  select r.*
  into v_review
  from public.candidate_reviews r
  where r.submission_id = v_submission.id
  for share;

  if not found or v_review.decision <> 'ACCEPT' then
    raise exception using
      errcode = '23514',
      message = 'Assertion source Submission must have an ACCEPT Review';
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = v_submission.candidate_id
  for update;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate referenced by Assertion source Submission not found';
  end if;

  if v_candidate.status <> 'ACCEPTED' then
    raise exception using
      errcode = '23514',
      message = 'Only an ACCEPTED Candidate can publish a new Assertion';
  end if;

  if exists (
    select 1
    from public.candidate_submissions later_submission
    where later_submission.candidate_id = v_submission.candidate_id
      and later_submission.submission_no > v_submission.submission_no
  ) then
    raise exception using
      errcode = '23514',
      message = 'Only the latest accepted Submission can publish an Assertion';
  end if;

  if assertion_row.approved_at < v_review.reviewed_at then
    raise exception using
      errcode = '23514',
      message = 'Assertion approval cannot precede its Review';
  end if;

  if row(
       assertion_row.kind,
       assertion_row.parameter_id,
       assertion_row.crop_id,
       assertion_row.cultivar_id,
       assertion_row.production_context_id,
       assertion_row.protection_context_id,
       assertion_row.training_context_id,
       assertion_row.harvest_purpose_id
     )
     is distinct from
     row(
       v_submission.kind,
       v_submission.parameter_id,
       v_submission.crop_id,
       v_submission.cultivar_id,
       v_submission.production_context_id,
       v_submission.protection_context_id,
       v_submission.training_context_id,
       v_submission.harvest_purpose_id
     ) then
    raise exception using
      errcode = '23514',
      message = 'Assertion logical key or kind differs from its source Submission';
  end if;

  if assertion_row.kind = 'NOT_APPLICABLE' then
    return;
  end if;

  select p.*
  into v_parameter
  from public.agronomic_parameters p
  where p.id = assertion_row.parameter_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion Parameter not found during source validation';
  end if;

  if v_parameter.value_schema in (
    'NUMERIC_SCALAR',
    'NUMERIC_RANGE'
  ) then
    select u.*
    into v_source_unit
    from public.measurement_units u
    where u.id = v_submission.unit_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Submission measurement unit not found';
    end if;

    select u.*
    into v_canonical_unit
    from public.measurement_units u
    where u.id = v_parameter.canonical_unit_id
    for share;

    if not found then
      raise exception using
        errcode = '23503',
        message = 'Parameter canonical unit not found';
    end if;

    if v_source_unit.quantity_kind
         is distinct from v_canonical_unit.quantity_kind then
      raise exception using
        errcode = '23514',
        message = 'Submission unit is incompatible with the canonical unit';
    end if;

    if v_parameter.value_schema = 'NUMERIC_SCALAR' then
      v_expected_numeric_value :=
        (
          v_submission.numeric_value
          * v_source_unit.to_base_factor
          + v_source_unit.to_base_offset
          - v_canonical_unit.to_base_offset
        )
        / v_canonical_unit.to_base_factor;

      if assertion_row.numeric_value
           is distinct from v_expected_numeric_value then
        raise exception using
          errcode = '23514',
          message = 'Assertion scalar value is not the canonical conversion of its Submission';
      end if;

    else
      v_expected_numeric_min_value :=
        (
          v_submission.numeric_min_value
          * v_source_unit.to_base_factor
          + v_source_unit.to_base_offset
          - v_canonical_unit.to_base_offset
        )
        / v_canonical_unit.to_base_factor;

      v_expected_numeric_max_value :=
        (
          v_submission.numeric_max_value
          * v_source_unit.to_base_factor
          + v_source_unit.to_base_offset
          - v_canonical_unit.to_base_offset
        )
        / v_canonical_unit.to_base_factor;

      if assertion_row.numeric_min_value
           is distinct from v_expected_numeric_min_value
         or assertion_row.numeric_max_value
           is distinct from v_expected_numeric_max_value then
        raise exception using
          errcode = '23514',
          message = 'Assertion range is not the canonical conversion of its Submission';
      end if;
    end if;

  elsif v_parameter.value_schema = 'BOOLEAN' then
    if assertion_row.boolean_value
         is distinct from v_submission.boolean_value then
      raise exception using
        errcode = '23514',
        message = 'Assertion boolean value differs from its source Submission';
    end if;

  elsif v_parameter.value_schema = 'ENUM' then
    if assertion_row.enum_value_id
         is distinct from v_submission.enum_value_id then
      raise exception using
        errcode = '23514',
        message = 'Assertion enum value differs from its source Submission';
    end if;
  end if;
end;
$function$;

revoke all
  on function private.validate_assertion_source(
    public.agronomic_assertions
  )
  from public, anon, authenticated;

comment on function private.validate_assertion_source(
  public.agronomic_assertions
) is
  'Verifica Submission accettata, latest submission e conversione esatta nell unita canonica.';

-- ============================================================================
-- 6. AGRONOMIC ASSERTION LIFECYCLE AND REVISION GUARD
-- ============================================================================

create function private.enforce_agronomic_assertion()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_submission public.candidate_submissions%rowtype;
  v_latest_revision public.agronomic_assertions%rowtype;
  v_has_latest_revision boolean;
begin
  if tg_op = 'DELETE' then
    raise exception using
      errcode = '23514',
      message = 'Agronomic Assertions cannot be deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to mutate an Agronomic Assertion';
  end if;

  if not private.can_publish_catalog() then
    raise exception using
      errcode = '42501',
      message = 'Catalog publication capability is required';
  end if;

  if tg_op = 'UPDATE' then
    if old.status <> 'APPROVED'
       or new.status not in ('SUPERSEDED', 'WITHDRAWN') then
      raise exception using
        errcode = '23514',
        message = 'Only APPROVED Assertions can transition to SUPERSEDED or WITHDRAWN';
    end if;

    if (
      to_jsonb(new) - 'status'
    ) is distinct from (
      to_jsonb(old) - 'status'
    ) then
      raise exception using
        errcode = '23514',
        message = 'Assertion semantic content and approval audit are immutable';
    end if;

    return new;
  end if;

  if new.status <> 'APPROVED' then
    raise exception using
      errcode = '23514',
      message = 'A new Assertion must start in APPROVED status';
  end if;

  if new.approved_by is distinct from v_auth_user_id then
    raise exception using
      errcode = '42501',
      message = 'Assertion approver must match auth.uid()';
  end if;

  perform private.validate_assertion_payload(new);
  perform private.validate_assertion_source(new);

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = new.source_submission_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion source Submission not found';
  end if;

  select a.*
  into v_latest_revision
  from public.agronomic_assertions a
  where a.parameter_id = new.parameter_id
    and a.crop_id = new.crop_id
    and a.cultivar_id is not distinct from new.cultivar_id
    and a.production_context_id
          is not distinct from new.production_context_id
    and a.protection_context_id
          is not distinct from new.protection_context_id
    and a.training_context_id
          is not distinct from new.training_context_id
    and a.harvest_purpose_id
          is not distinct from new.harvest_purpose_id
  order by a.revision_no desc
  limit 1
  for update;

  v_has_latest_revision := found;

  if not v_has_latest_revision then
    if v_submission.action <> 'CREATE' then
      raise exception using
        errcode = '23514',
        message = 'The first Assertion revision must originate from a CREATE Submission';
    end if;

    if new.previous_revision_id is not null
       or new.revision_no <> 1 then
      raise exception using
        errcode = '23514',
        message = 'The first Assertion revision must have revision_no 1 and no previous revision';
    end if;

  else
    if new.previous_revision_id
         is distinct from v_latest_revision.id then
      raise exception using
        errcode = '23514',
        message = 'previous_revision_id must reference the latest revision of the logical key';
    end if;

    if new.revision_no <> v_latest_revision.revision_no + 1 then
      raise exception using
        errcode = '23514',
        message = 'Assertion revision_no must continue the logical key history';
    end if;

    if v_submission.action = 'CREATE' then
      if v_latest_revision.status <> 'WITHDRAWN' then
        raise exception using
          errcode = '23514',
          message = 'CREATE can reintroduce only a previously WITHDRAWN logical key';
      end if;

    elsif v_submission.action = 'REPLACE' then
      if v_submission.target_assertion_id
           is distinct from v_latest_revision.id then
        raise exception using
          errcode = '23514',
          message = 'REPLACE must target the immediately previous Assertion revision';
      end if;

      if v_latest_revision.status <> 'SUPERSEDED' then
        raise exception using
          errcode = '23514',
          message = 'REPLACE requires the target Assertion to be SUPERSEDED before insertion';
      end if;

    else
      raise exception using
        errcode = '23514',
        message = 'WITHDRAW cannot create a new Assertion revision';
    end if;
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_agronomic_assertion()
  from public, anon, authenticated;

create trigger agronomic_assertions_enforce_lifecycle
before insert or update or delete
on public.agronomic_assertions
for each row
execute function private.enforce_agronomic_assertion();

comment on function private.enforce_agronomic_assertion() is
  'Protegge immutabilita, capability di publication e catena revisionale immediata delle Assertion.';

-- ============================================================================
-- 7. ASSERTION EVIDENCE GUARD
-- ============================================================================

create function private.enforce_assertion_evidence()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_assertion public.agronomic_assertions%rowtype;
  v_source_evidence public.candidate_submission_evidence%rowtype;
begin
  if tg_op <> 'INSERT' then
    raise exception using
      errcode = '23514',
      message = 'Assertion Evidence is immutable and cannot be updated or deleted';
  end if;

  if v_auth_user_id is null then
    raise exception using
      errcode = '42501',
      message = 'Authentication is required to create Assertion Evidence';
  end if;

  if not private.can_publish_catalog() then
    raise exception using
      errcode = '42501',
      message = 'Catalog publication capability is required';
  end if;

  select a.*
  into v_assertion
  from public.agronomic_assertions a
  where a.id = new.assertion_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion referenced by Evidence not found';
  end if;

  if v_assertion.status <> 'APPROVED' then
    raise exception using
      errcode = '23514',
      message = 'Evidence can only be copied to an APPROVED Assertion';
  end if;

  if v_assertion.approved_by is distinct from v_auth_user_id then
    raise exception using
      errcode = '42501',
      message = 'Assertion Evidence actor must match the Assertion approver';
  end if;

  select cse.*
  into v_source_evidence
  from public.candidate_submission_evidence cse
  where cse.id = new.source_submission_evidence_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Source Submission Evidence not found';
  end if;

  if v_source_evidence.submission_id
       is distinct from v_assertion.source_submission_id then
    raise exception using
      errcode = '23514',
      message = 'Assertion Evidence must originate from the Assertion source Submission';
  end if;

  if new.observation_id
       is distinct from v_source_evidence.observation_id
     or new.evidence_role
       is distinct from v_source_evidence.evidence_role
     or new.editorial_note
       is distinct from v_source_evidence.editorial_note then
    raise exception using
      errcode = '23514',
      message = 'Assertion Evidence must exactly copy its source Submission Evidence';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_assertion_evidence()
  from public, anon, authenticated;

create trigger assertion_evidence_enforce_immutability
before insert or update or delete
on public.assertion_evidence
for each row
execute function private.enforce_assertion_evidence();

comment on function private.enforce_assertion_evidence() is
  'Impone provenance esatta e immutabilita delle Evidence canoniche.';

-- ============================================================================
-- 8. DEFERRED ASSERTION COMPLETENESS
-- ============================================================================

create function private.check_assertion_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_assertion_id uuid;
  v_assertion public.agronomic_assertions%rowtype;
  v_submission public.candidate_submissions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
begin
  if tg_table_name = 'agronomic_assertions' then
    v_assertion_id := new.id;
  else
    v_assertion_id := new.assertion_id;
  end if;

  select a.*
  into v_assertion
  from public.agronomic_assertions a
  where a.id = v_assertion_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion disappeared before deferred validation';
  end if;

  if v_assertion.status <> 'APPROVED' then
    raise exception using
      errcode = '23514',
      message = 'A newly published Assertion must remain APPROVED at transaction end';
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.id = v_assertion.source_submission_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion source Submission not found during deferred validation';
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = v_submission.candidate_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Assertion source Candidate not found during deferred validation';
  end if;

  if v_candidate.status <> 'PUBLISHED' then
    raise exception using
      errcode = '23514',
      message = 'Assertion publication must leave its Candidate in PUBLISHED status';
  end if;

  if v_candidate.published_by
       is distinct from v_assertion.approved_by then
    raise exception using
      errcode = '23514',
      message = 'Candidate publisher must match the Assertion approver';
  end if;

  if v_candidate.published_at < v_assertion.approved_at then
    raise exception using
      errcode = '23514',
      message = 'Candidate publication cannot precede Assertion approval';
  end if;

  if exists (
    (
      select
        cse.id,
        cse.observation_id,
        cse.evidence_role,
        cse.editorial_note
      from public.candidate_submission_evidence cse
      where cse.submission_id = v_assertion.source_submission_id
    )
    except
    (
      select
        ae.source_submission_evidence_id,
        ae.observation_id,
        ae.evidence_role,
        ae.editorial_note
      from public.assertion_evidence ae
      where ae.assertion_id = v_assertion.id
    )
  )
  or exists (
    (
      select
        ae.source_submission_evidence_id,
        ae.observation_id,
        ae.evidence_role,
        ae.editorial_note
      from public.assertion_evidence ae
      where ae.assertion_id = v_assertion.id
    )
    except
    (
      select
        cse.id,
        cse.observation_id,
        cse.evidence_role,
        cse.editorial_note
      from public.candidate_submission_evidence cse
      where cse.submission_id = v_assertion.source_submission_id
    )
  ) then
    raise exception using
      errcode = '23514',
      message = 'Assertion Evidence is incomplete or differs from the accepted Submission';
  end if;

  if not exists (
    select 1
    from public.assertion_evidence ae
    where ae.assertion_id = v_assertion.id
      and ae.evidence_role = 'SUPPORTING'
  ) then
    raise exception using
      errcode = '23514',
      message = 'A published Assertion requires at least one SUPPORTING Evidence';
  end if;

  return null;
end;
$function$;

revoke all
  on function private.check_assertion_complete()
  from public, anon, authenticated;

create constraint trigger agronomic_assertions_check_complete
after insert
on public.agronomic_assertions
deferrable initially deferred
for each row
execute function private.check_assertion_complete();

create constraint trigger assertion_evidence_check_complete
after insert
on public.assertion_evidence
deferrable initially deferred
for each row
execute function private.check_assertion_complete();

comment on function private.check_assertion_complete() is
  'Verifica a fine transazione Candidate PUBLISHED e copia completa della Evidence accettata.';
