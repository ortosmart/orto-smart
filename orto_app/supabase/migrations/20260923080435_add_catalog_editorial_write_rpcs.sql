-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 9D - WRITE PATH AUTORITATIVO EDITORIALE
-- ============================================================================
--
-- Introduce il Write Path per:
-- - Candidate CREATE, REPLACE e WITHDRAW;
-- - Evidence editoriali di lavoro;
-- - Submission e relativi snapshot immutabili;
-- - Review ACCEPT, REJECT e RETURN_TO_DRAFT.
--
-- La pubblicazione della Knowledge canonica resta esclusa ed e demandata
-- alla Tranche 9E. Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. ACTIVE DEPENDENCY VALIDATION
-- ============================================================================

create function private.validate_active_candidate_dependencies(
  candidate_row public.agronomic_candidates
)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $function$
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
  from public.catalog_crops_s030 c
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
$function$;


-- ============================================================================
-- 2. ADD CANDIDATE EVIDENCE
-- ============================================================================

create function public.add_candidate_evidence(
  target_candidate_id uuid,
  expected_candidate_row_version bigint,
  target_observation_id uuid,
  evidence_role text,
  evidence_editorial_note text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_candidate public.agronomic_candidates%rowtype;
  v_evidence public.candidate_evidence%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = target_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status <> 'DRAFT' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_candidate_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_candidate.row_version
    );
  end if;

  if not exists (
    select 1
    from public.agronomic_observations o
    where o.id = target_observation_id
  ) then
    return jsonb_build_object('status', 'observation_not_found');
  end if;

  insert into public.candidate_evidence (
    candidate_id,
    observation_id,
    evidence_role,
    editorial_note,
    created_by
  ) values (
    target_candidate_id,
    target_observation_id,
    evidence_role,
    nullif(btrim(evidence_editorial_note), ''),
    v_auth_user_id
  )
  returning * into v_evidence;

  select * into v_candidate
  from public.agronomic_candidates
  where id = target_candidate_id;

  return jsonb_build_object(
    'status', 'evidence_added',
    'candidate_evidence_id', v_evidence.id,
    'evidence_row_version', v_evidence.row_version,
    'agronomic_candidate_id', v_candidate.id,
    'candidate_row_version', v_candidate.row_version
  );
exception
  when unique_violation then
    return jsonb_build_object('status', 'duplicate_evidence');
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 3. UPDATE CANDIDATE EVIDENCE
-- ============================================================================

create function public.update_candidate_evidence(
  target_evidence_id uuid,
  expected_candidate_row_version bigint,
  expected_evidence_row_version bigint,
  evidence_role text,
  evidence_editorial_note text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_candidate public.agronomic_candidates%rowtype;
  v_evidence public.candidate_evidence%rowtype;
  v_candidate_id uuid;
  v_evidence_role text := evidence_role;
  v_editorial_note text := nullif(btrim(evidence_editorial_note), '');
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select ce.candidate_id
  into v_candidate_id
  from public.candidate_evidence ce
  where ce.id = target_evidence_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  -- Ordine uniforme: Candidate prima, Evidence dopo.
  select * into v_candidate
  from public.agronomic_candidates
  where id = v_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status <> 'DRAFT' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_candidate_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  select * into v_evidence
  from public.candidate_evidence
  where id = target_evidence_id
    and candidate_id = v_candidate.id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_evidence.row_version <> expected_evidence_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_evidence_row_version', v_evidence.row_version,
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  if v_evidence.evidence_role is not distinct from v_evidence_role
     and v_evidence.editorial_note is not distinct from v_editorial_note then
    return jsonb_build_object(
      'status', 'unchanged',
      'candidate_evidence_id', v_evidence.id,
      'evidence_row_version', v_evidence.row_version,
      'agronomic_candidate_id', v_candidate.id,
      'candidate_row_version', v_candidate.row_version
    );
  end if;

  update public.candidate_evidence ce
  set evidence_role = v_evidence_role,
      editorial_note = v_editorial_note
  where ce.id = target_evidence_id
  returning * into v_evidence;

  select * into v_candidate
  from public.agronomic_candidates ac
  where ac.id = v_candidate_id;

  return jsonb_build_object(
    'status', 'evidence_updated',
    'candidate_evidence_id', v_evidence.id,
    'evidence_row_version', v_evidence.row_version,
    'agronomic_candidate_id', v_candidate.id,
    'candidate_row_version', v_candidate.row_version
  );
exception
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 4. REMOVE CANDIDATE EVIDENCE
-- ============================================================================

create function public.remove_candidate_evidence(
  target_evidence_id uuid,
  expected_candidate_row_version bigint,
  expected_evidence_row_version bigint
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_candidate public.agronomic_candidates%rowtype;
  v_evidence public.candidate_evidence%rowtype;
  v_candidate_id uuid;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select ce.candidate_id
  into v_candidate_id
  from public.candidate_evidence ce
  where ce.id = target_evidence_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = v_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status <> 'DRAFT' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_candidate_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  select * into v_evidence
  from public.candidate_evidence
  where id = target_evidence_id
    and candidate_id = v_candidate.id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_evidence.row_version <> expected_evidence_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_evidence_row_version', v_evidence.row_version,
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  delete from public.candidate_evidence
  where id = target_evidence_id;

  select * into v_candidate
  from public.agronomic_candidates
  where id = v_candidate.id;

  return jsonb_build_object(
    'status', 'evidence_removed',
    'candidate_evidence_id', target_evidence_id,
    'agronomic_candidate_id', v_candidate.id,
    'candidate_row_version', v_candidate.row_version
  );
end;
$function$;


-- ============================================================================
-- 5. SUBMIT CANDIDATE
-- ============================================================================

create function public.submit_agronomic_candidate(
  target_candidate_id uuid,
  expected_row_version bigint
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_candidate public.agronomic_candidates%rowtype;
  v_submission public.candidate_submissions%rowtype;
  v_submission_no integer;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = target_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status = 'IN_REVIEW' then
    select * into v_submission
    from public.candidate_submissions
    where candidate_id = v_candidate.id
    order by submission_no desc
    limit 1;

    if found
       and v_submission.candidate_row_version = expected_row_version then
      return jsonb_build_object(
        'status', 'already_submitted',
        'candidate_submission_id', v_submission.id,
        'submission_no', v_submission.submission_no,
        'agronomic_candidate_id', v_candidate.id,
        'candidate_status', v_candidate.status,
        'candidate_row_version', v_candidate.row_version
      );
    end if;

    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status,
      'current_row_version', v_candidate.row_version
    );
  end if;

  if v_candidate.status <> 'DRAFT' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_candidate.row_version
    );
  end if;

  perform private.validate_active_candidate_dependencies(v_candidate);
  perform private.validate_candidate_target(v_candidate);

  if v_candidate.action in ('CREATE', 'REPLACE')
     and not exists (
       select 1
       from public.candidate_evidence ce
       where ce.candidate_id = v_candidate.id
         and ce.evidence_role = 'SUPPORTING'
     ) then
    return jsonb_build_object('status', 'evidence_required');
  end if;

  select coalesce(max(s.submission_no), 0) + 1
  into v_submission_no
  from public.candidate_submissions s
  where s.candidate_id = v_candidate.id;

  insert into public.candidate_submissions (
    candidate_id,
    submission_no,
    candidate_row_version,
    action,
    target_assertion_id,
    kind,
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id,
    numeric_value,
    numeric_min_value,
    numeric_max_value,
    boolean_value,
    enum_value_id,
    unit_id,
    editorial_reason,
    submitted_by
  ) values (
    v_candidate.id,
    v_submission_no,
    v_candidate.row_version,
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
    v_candidate.editorial_reason,
    v_auth_user_id
  )
  returning * into v_submission;

  insert into public.candidate_submission_evidence (
    submission_id,
    observation_id,
    evidence_role,
    editorial_note
  )
  select
    v_submission.id,
    ce.observation_id,
    ce.evidence_role,
    ce.editorial_note
  from public.candidate_evidence ce
  where ce.candidate_id = v_candidate.id;

  update public.agronomic_candidates
  set status = 'IN_REVIEW'
  where id = v_candidate.id
  returning * into v_candidate;

  return jsonb_build_object(
    'status', 'submitted',
    'candidate_submission_id', v_submission.id,
    'submission_no', v_submission.submission_no,
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'candidate_row_version', v_candidate.row_version
  );
exception
  when sqlstate 'P0001' then
    if sqlerrm = 'candidate_dependency_inactive' then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
    raise;
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 6. REVIEW CANDIDATE SUBMISSION
-- ============================================================================

create function public.review_candidate_submission(
  target_submission_id uuid,
  expected_candidate_row_version bigint,
  review_decision text,
  review_reason text,
  review_confidence text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_submission public.candidate_submissions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
  v_review public.candidate_reviews%rowtype;
  v_result_status text;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_review_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_submission
  from public.candidate_submissions
  where id = target_submission_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = v_submission.candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  select * into v_review
  from public.candidate_reviews
  where submission_id = v_submission.id;

  if found then
    return jsonb_build_object(
      'status', 'already_reviewed',
      'candidate_review_id', v_review.id,
      'review_decision', v_review.decision,
      'agronomic_candidate_id', v_candidate.id,
      'candidate_status', v_candidate.status,
      'candidate_row_version', v_candidate.row_version
    );
  end if;

  if v_candidate.status <> 'IN_REVIEW' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_candidate_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  if exists (
    select 1
    from public.candidate_submissions later_submission
    where later_submission.candidate_id = v_candidate.id
      and later_submission.submission_no > v_submission.submission_no
  ) then
    return jsonb_build_object('status', 'invalid_state');
  end if;

  insert into public.candidate_reviews (
    submission_id,
    decision,
    confidence,
    reason,
    reviewed_by
  ) values (
    v_submission.id,
    review_decision,
    review_confidence,
    review_reason,
    v_auth_user_id
  )
  returning * into v_review;

  select * into v_candidate
  from public.agronomic_candidates
  where id = v_candidate.id;

  v_result_status :=
    case v_review.decision
      when 'ACCEPT' then 'accepted'
      when 'REJECT' then 'rejected'
      when 'RETURN_TO_DRAFT' then 'returned_to_draft'
    end;

  return jsonb_build_object(
    'status', v_result_status,
    'candidate_review_id', v_review.id,
    'review_decision', v_review.decision,
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'candidate_row_version', v_candidate.row_version
  );
exception
  when unique_violation then
    select * into v_review
    from public.candidate_reviews
    where submission_id = target_submission_id;

    return jsonb_build_object(
      'status', 'already_reviewed',
      'candidate_review_id', v_review.id,
      'review_decision', v_review.decision
    );
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


revoke all
  on function private.validate_active_candidate_dependencies(
    public.agronomic_candidates
  )
  from public, anon, authenticated;

comment on function private.validate_active_candidate_dependencies(
  public.agronomic_candidates
) is
  'Impedisce CREATE e REPLACE con dipendenze globali inattive; WITHDRAW resta sempre praticabile.';


-- ============================================================================
-- 7. CREATE CANDIDATE
-- ============================================================================

create function public.create_agronomic_candidate(
  candidate_parameter_id uuid,
  candidate_crop_id uuid,
  candidate_kind text,
  candidate_editorial_reason text,
  candidate_cultivar_id uuid default null,
  candidate_production_context_id uuid default null,
  candidate_protection_context_id uuid default null,
  candidate_training_context_id uuid default null,
  candidate_harvest_purpose_id uuid default null,
  candidate_numeric_value numeric default null,
  candidate_numeric_min_value numeric default null,
  candidate_numeric_max_value numeric default null,
  candidate_boolean_value boolean default null,
  candidate_enum_value_id uuid default null,
  candidate_unit_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_candidate public.agronomic_candidates%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  insert into public.agronomic_candidates (
    action,
    kind,
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id,
    numeric_value,
    numeric_min_value,
    numeric_max_value,
    boolean_value,
    enum_value_id,
    unit_id,
    editorial_reason,
    created_by
  ) values (
    'CREATE',
    candidate_kind,
    candidate_parameter_id,
    candidate_crop_id,
    candidate_cultivar_id,
    candidate_production_context_id,
    candidate_protection_context_id,
    candidate_training_context_id,
    candidate_harvest_purpose_id,
    candidate_numeric_value,
    candidate_numeric_min_value,
    candidate_numeric_max_value,
    candidate_boolean_value,
    candidate_enum_value_id,
    candidate_unit_id,
    candidate_editorial_reason,
    v_auth_user_id
  )
  returning * into v_candidate;

  perform private.validate_active_candidate_dependencies(v_candidate);

  return jsonb_build_object(
    'status', 'created',
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'row_version', v_candidate.row_version
  );
exception
  when sqlstate 'P0001' then
    if sqlerrm = 'candidate_dependency_inactive' then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
    raise;
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 8. CREATE REPLACEMENT CANDIDATE
-- ============================================================================

create function public.create_replacement_candidate(
  target_assertion_id uuid,
  candidate_kind text,
  candidate_editorial_reason text,
  candidate_numeric_value numeric default null,
  candidate_numeric_min_value numeric default null,
  candidate_numeric_max_value numeric default null,
  candidate_boolean_value boolean default null,
  candidate_enum_value_id uuid default null,
  candidate_unit_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_target public.agronomic_assertions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_target
  from public.agronomic_assertions
  where id = target_assertion_id
  for share;

  if not found then
    return jsonb_build_object('status', 'target_not_found');
  end if;

  if v_target.status <> 'APPROVED' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'target_status', v_target.status
    );
  end if;

  insert into public.agronomic_candidates (
    action,
    target_assertion_id,
    kind,
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id,
    numeric_value,
    numeric_min_value,
    numeric_max_value,
    boolean_value,
    enum_value_id,
    unit_id,
    editorial_reason,
    created_by
  ) values (
    'REPLACE',
    v_target.id,
    candidate_kind,
    v_target.parameter_id,
    v_target.crop_id,
    v_target.cultivar_id,
    v_target.production_context_id,
    v_target.protection_context_id,
    v_target.training_context_id,
    v_target.harvest_purpose_id,
    candidate_numeric_value,
    candidate_numeric_min_value,
    candidate_numeric_max_value,
    candidate_boolean_value,
    candidate_enum_value_id,
    candidate_unit_id,
    candidate_editorial_reason,
    v_auth_user_id
  )
  returning * into v_candidate;

  perform private.validate_active_candidate_dependencies(v_candidate);

  return jsonb_build_object(
    'status', 'created',
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'row_version', v_candidate.row_version
  );
exception
  when sqlstate 'P0001' then
    if sqlerrm = 'candidate_dependency_inactive' then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
    raise;
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 9. CREATE WITHDRAWAL CANDIDATE
-- ============================================================================

create function public.create_withdrawal_candidate(
  target_assertion_id uuid,
  candidate_editorial_reason text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_target public.agronomic_assertions%rowtype;
  v_candidate public.agronomic_candidates%rowtype;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_target
  from public.agronomic_assertions
  where id = target_assertion_id
  for share;

  if not found then
    return jsonb_build_object('status', 'target_not_found');
  end if;

  if v_target.status <> 'APPROVED' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'target_status', v_target.status
    );
  end if;

  insert into public.agronomic_candidates (
    action,
    target_assertion_id,
    kind,
    parameter_id,
    crop_id,
    cultivar_id,
    production_context_id,
    protection_context_id,
    training_context_id,
    harvest_purpose_id,
    numeric_value,
    numeric_min_value,
    numeric_max_value,
    boolean_value,
    enum_value_id,
    unit_id,
    editorial_reason,
    created_by
  ) values (
    'WITHDRAW',
    v_target.id,
    v_target.kind,
    v_target.parameter_id,
    v_target.crop_id,
    v_target.cultivar_id,
    v_target.production_context_id,
    v_target.protection_context_id,
    v_target.training_context_id,
    v_target.harvest_purpose_id,
    v_target.numeric_value,
    v_target.numeric_min_value,
    v_target.numeric_max_value,
    v_target.boolean_value,
    v_target.enum_value_id,
    v_target.unit_id,
    candidate_editorial_reason,
    v_auth_user_id
  )
  returning * into v_candidate;

  return jsonb_build_object(
    'status', 'created',
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'row_version', v_candidate.row_version
  );
exception
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 10. UPDATE DRAFT CANDIDATE
-- ============================================================================

create function public.update_draft_agronomic_candidate(
  target_candidate_id uuid,
  expected_row_version bigint,
  candidate_parameter_id uuid,
  candidate_crop_id uuid,
  candidate_kind text,
  candidate_editorial_reason text,
  candidate_cultivar_id uuid default null,
  candidate_production_context_id uuid default null,
  candidate_protection_context_id uuid default null,
  candidate_training_context_id uuid default null,
  candidate_harvest_purpose_id uuid default null,
  candidate_numeric_value numeric default null,
  candidate_numeric_min_value numeric default null,
  candidate_numeric_max_value numeric default null,
  candidate_boolean_value boolean default null,
  candidate_enum_value_id uuid default null,
  candidate_unit_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_candidate public.agronomic_candidates%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = target_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status <> 'DRAFT' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_candidate.row_version
    );
  end if;

  if row(
       v_candidate.parameter_id,
       v_candidate.crop_id,
       v_candidate.kind,
       v_candidate.editorial_reason,
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
       v_candidate.unit_id
     ) is not distinct from row(
       candidate_parameter_id,
       candidate_crop_id,
       candidate_kind,
       candidate_editorial_reason,
       candidate_cultivar_id,
       candidate_production_context_id,
       candidate_protection_context_id,
       candidate_training_context_id,
       candidate_harvest_purpose_id,
       candidate_numeric_value,
       candidate_numeric_min_value,
       candidate_numeric_max_value,
       candidate_boolean_value,
       candidate_enum_value_id,
       candidate_unit_id
     ) then
    return jsonb_build_object(
      'status', 'unchanged',
      'agronomic_candidate_id', v_candidate.id,
      'candidate_status', v_candidate.status,
      'row_version', v_candidate.row_version
    );
  end if;

  update public.agronomic_candidates
  set parameter_id = candidate_parameter_id,
      crop_id = candidate_crop_id,
      kind = candidate_kind,
      editorial_reason = candidate_editorial_reason,
      cultivar_id = candidate_cultivar_id,
      production_context_id = candidate_production_context_id,
      protection_context_id = candidate_protection_context_id,
      training_context_id = candidate_training_context_id,
      harvest_purpose_id = candidate_harvest_purpose_id,
      numeric_value = candidate_numeric_value,
      numeric_min_value = candidate_numeric_min_value,
      numeric_max_value = candidate_numeric_max_value,
      boolean_value = candidate_boolean_value,
      enum_value_id = candidate_enum_value_id,
      unit_id = candidate_unit_id
  where id = target_candidate_id
  returning * into v_candidate;

  perform private.validate_active_candidate_dependencies(v_candidate);

  return jsonb_build_object(
    'status', 'updated',
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'row_version', v_candidate.row_version
  );
exception
  when sqlstate 'P0001' then
    if sqlerrm = 'candidate_dependency_inactive' then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
    raise;
  when check_violation or foreign_key_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 11. WITHDRAW CANDIDATE PROPOSAL
-- ============================================================================

create function public.withdraw_agronomic_candidate(
  target_candidate_id uuid,
  expected_row_version bigint,
  withdrawal_reason text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_candidate public.agronomic_candidates%rowtype;
begin
  if auth.uid() is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_ingest_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select * into v_candidate
  from public.agronomic_candidates
  where id = target_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_candidate.status = 'WITHDRAWN' then
    return jsonb_build_object(
      'status', 'already_withdrawn',
      'agronomic_candidate_id', v_candidate.id,
      'candidate_status', v_candidate.status,
      'row_version', v_candidate.row_version
    );
  end if;

  if v_candidate.status not in ('DRAFT', 'IN_REVIEW', 'ACCEPTED') then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_candidate.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_candidate.row_version
    );
  end if;

  update public.agronomic_candidates
  set status = 'WITHDRAWN',
      withdrawn_reason = withdrawal_reason
  where id = target_candidate_id
  returning * into v_candidate;

  return jsonb_build_object(
    'status', 'candidate_withdrawn',
    'agronomic_candidate_id', v_candidate.id,
    'candidate_status', v_candidate.status,
    'row_version', v_candidate.row_version
  );
exception
  when check_violation or not_null_violation then
    return jsonb_build_object('status', 'invalid_input');
end;
$function$;


-- ============================================================================
-- 12. FUNCTION PRIVILEGES
-- ============================================================================

revoke all on function public.create_agronomic_candidate(
  uuid, uuid, text, text, uuid, uuid, uuid, uuid, uuid,
  numeric, numeric, numeric, boolean, uuid, uuid
) from public, anon, authenticated;

revoke all on function public.create_replacement_candidate(
  uuid, text, text, numeric, numeric, numeric, boolean, uuid, uuid
) from public, anon, authenticated;

revoke all on function public.create_withdrawal_candidate(uuid, text)
  from public, anon, authenticated;

revoke all on function public.update_draft_agronomic_candidate(
  uuid, bigint, uuid, uuid, text, text, uuid, uuid, uuid, uuid, uuid,
  numeric, numeric, numeric, boolean, uuid, uuid
) from public, anon, authenticated;

revoke all on function public.withdraw_agronomic_candidate(
  uuid, bigint, text
) from public, anon, authenticated;

revoke all on function public.add_candidate_evidence(
  uuid, bigint, uuid, text, text
) from public, anon, authenticated;

revoke all on function public.update_candidate_evidence(
  uuid, bigint, bigint, text, text
) from public, anon, authenticated;

revoke all on function public.remove_candidate_evidence(
  uuid, bigint, bigint
) from public, anon, authenticated;

revoke all on function public.submit_agronomic_candidate(uuid, bigint)
  from public, anon, authenticated;

revoke all on function public.review_candidate_submission(
  uuid, bigint, text, text, text
) from public, anon, authenticated;

grant execute on function public.create_agronomic_candidate(
  uuid, uuid, text, text, uuid, uuid, uuid, uuid, uuid,
  numeric, numeric, numeric, boolean, uuid, uuid
) to authenticated;

grant execute on function public.create_replacement_candidate(
  uuid, text, text, numeric, numeric, numeric, boolean, uuid, uuid
) to authenticated;

grant execute on function public.create_withdrawal_candidate(uuid, text)
  to authenticated;

grant execute on function public.update_draft_agronomic_candidate(
  uuid, bigint, uuid, uuid, text, text, uuid, uuid, uuid, uuid, uuid,
  numeric, numeric, numeric, boolean, uuid, uuid
) to authenticated;

grant execute on function public.withdraw_agronomic_candidate(
  uuid, bigint, text
) to authenticated;

grant execute on function public.add_candidate_evidence(
  uuid, bigint, uuid, text, text
) to authenticated;

grant execute on function public.update_candidate_evidence(
  uuid, bigint, bigint, text, text
) to authenticated;

grant execute on function public.remove_candidate_evidence(
  uuid, bigint, bigint
) to authenticated;

grant execute on function public.submit_agronomic_candidate(uuid, bigint)
  to authenticated;

grant execute on function public.review_candidate_submission(
  uuid, bigint, text, text, text
) to authenticated;
