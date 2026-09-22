-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 8 - FK CIRCOLARI, HARDENING E SEMANTIC FREEZE
-- ============================================================================
--
-- Completa:
-- - FK dei target REPLACE e WITHDRAW verso la Knowledge canonica;
-- - coerenza del target e snapshot read-only delle Candidate WITHDRAW;
-- - freeze semantico di Parameter, Unit ed Enum Value;
-- - completezza transazionale delle publication CREATE, REPLACE e WITHDRAW.
--
-- Nessuna tabella e nessun dato vengono aggiunti.
-- ============================================================================


-- ============================================================================
-- 1. FOREIGN KEY DEI TARGET CANONICI
-- ============================================================================

alter table public.agronomic_candidates
  add constraint agronomic_candidates_target_assertion_id_fkey
  foreign key (target_assertion_id)
  references public.agronomic_assertions(id)
  on delete restrict;

alter table public.candidate_submissions
  add constraint candidate_submissions_target_assertion_id_fkey
  foreign key (target_assertion_id)
  references public.agronomic_assertions(id)
  on delete restrict;

create unique index agronomic_candidates_one_published_target
  on public.agronomic_candidates(target_assertion_id)
  where status = 'PUBLISHED'
    and target_assertion_id is not null;

comment on column public.agronomic_candidates.target_assertion_id is
  'Assertion canonica target di REPLACE o WITHDRAW; obbligatoriamente esistente e coerente con la Candidate.';

comment on column public.candidate_submissions.target_assertion_id is
  'Assertion canonica target fotografata dalla Candidate per REPLACE o WITHDRAW.';

comment on index public.agronomic_candidates_one_published_target is
  'Una revisione canonica puo essere oggetto di una sola operazione editoriale pubblicata.';


-- ============================================================================
-- 2. VALIDAZIONE DEL TARGET REPLACE / WITHDRAW
-- ============================================================================

create function private.validate_candidate_target(
  candidate_row public.agronomic_candidates
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_target public.agronomic_assertions%rowtype;
begin
  if candidate_row.action = 'CREATE' then
    if candidate_row.target_assertion_id is not null then
      raise exception using
        errcode = '23514',
        message = 'CREATE Candidate cannot target an Assertion';
    end if;

    return;
  end if;

  if candidate_row.action not in ('REPLACE', 'WITHDRAW')
     or candidate_row.target_assertion_id is null then
    raise exception using
      errcode = '23514',
      message = 'REPLACE and WITHDRAW Candidate require a target Assertion';
  end if;

  select a.*
  into v_target
  from public.agronomic_assertions a
  where a.id = candidate_row.target_assertion_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate target Assertion not found';
  end if;

  if row(
       candidate_row.parameter_id,
       candidate_row.crop_id,
       candidate_row.cultivar_id,
       candidate_row.production_context_id,
       candidate_row.protection_context_id,
       candidate_row.training_context_id,
       candidate_row.harvest_purpose_id
     )
     is distinct from
     row(
       v_target.parameter_id,
       v_target.crop_id,
       v_target.cultivar_id,
       v_target.production_context_id,
       v_target.protection_context_id,
       v_target.training_context_id,
       v_target.harvest_purpose_id
     ) then
    raise exception using
      errcode = '23514',
      message = 'Candidate logical key differs from its target Assertion';
  end if;

  if candidate_row.action = 'WITHDRAW'
     and row(
       candidate_row.kind,
       candidate_row.numeric_value,
       candidate_row.numeric_min_value,
       candidate_row.numeric_max_value,
       candidate_row.boolean_value,
       candidate_row.enum_value_id,
       candidate_row.unit_id
     )
     is distinct from
     row(
       v_target.kind,
       v_target.numeric_value,
       v_target.numeric_min_value,
       v_target.numeric_max_value,
       v_target.boolean_value,
       v_target.enum_value_id,
       v_target.unit_id
     ) then
    raise exception using
      errcode = '23514',
      message = 'WITHDRAW Candidate must exactly snapshot its target Assertion';
  end if;

  if candidate_row.status in ('DRAFT', 'IN_REVIEW', 'ACCEPTED') then
    if v_target.status <> 'APPROVED' then
      raise exception using
        errcode = '23514',
        message = 'An active REPLACE or WITHDRAW Candidate requires an APPROVED target Assertion';
    end if;

  elsif candidate_row.status = 'PUBLISHED' then
    if candidate_row.action = 'REPLACE'
       and v_target.status <> 'SUPERSEDED' then
      raise exception using
        errcode = '23514',
        message = 'A published REPLACE Candidate requires a SUPERSEDED target Assertion';
    end if;

    if candidate_row.action = 'WITHDRAW'
       and v_target.status <> 'WITHDRAWN' then
      raise exception using
        errcode = '23514',
        message = 'A published WITHDRAW Candidate requires a WITHDRAWN target Assertion';
    end if;
  end if;
end;
$function$;

revoke all
  on function private.validate_candidate_target(
    public.agronomic_candidates
  )
  from public, anon, authenticated;

comment on function private.validate_candidate_target(
  public.agronomic_candidates
) is
  'Valida FK semantica, logical key, stato e snapshot canonico dei target REPLACE e WITHDRAW.';

create function private.enforce_candidate_target()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if tg_op = 'DELETE' then
    return old;
  end if;

  perform private.validate_candidate_target(new);

  return new;
end;
$function$;

revoke all
  on function private.enforce_candidate_target()
  from public, anon, authenticated;

create trigger agronomic_candidates_validate_target
before insert or update
on public.agronomic_candidates
for each row
execute function private.enforce_candidate_target();

comment on function private.enforce_candidate_target() is
  'Applica la validazione del target a ogni versione persistita della Candidate.';

create function private.enforce_submission_target()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_candidate public.agronomic_candidates%rowtype;
begin
  if tg_op <> 'INSERT' then
    return new;
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = new.candidate_id
  for share;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Candidate Submission parent Candidate not found';
  end if;

  perform private.validate_candidate_target(v_candidate);

  return new;
end;
$function$;

revoke all
  on function private.enforce_submission_target()
  from public, anon, authenticated;

create trigger candidate_submissions_validate_target
before insert
on public.candidate_submissions
for each row
execute function private.enforce_submission_target();

comment on function private.enforce_submission_target() is
  'Rivalida il target canonico nella transazione che crea la Submission immutabile.';


-- ============================================================================
-- 3. SEMANTIC FREEZE DEL PARAMETER REGISTRY
-- ============================================================================

create function private.is_agronomic_parameter_semantically_frozen(
  target_parameter_id uuid
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
      from public.agronomic_observations o
      where o.parameter_id = target_parameter_id
        and o.status = 'NORMALIZED'
    )
    or exists (
      select 1
      from public.candidate_submissions s
      where s.parameter_id = target_parameter_id
    )
    or exists (
      select 1
      from public.agronomic_assertions a
      where a.parameter_id = target_parameter_id
    );
$function$;

revoke all
  on function private.is_agronomic_parameter_semantically_frozen(uuid)
  from public, anon, authenticated;

comment on function private.is_agronomic_parameter_semantically_frozen(uuid) is
  'Indica se un Parameter e gia referenziato da una Observation NORMALIZED, Submission o Assertion immutabile.';

create function private.enforce_agronomic_parameter_semantic_freeze()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if row(
       new.code,
       new.value_schema,
       new.quantity_kind,
       new.canonical_unit_id,
       new.knowledge_scope,
       new.allows_crop,
       new.allows_cultivar,
       new.allows_production_context,
       new.allows_protection_context,
       new.allows_training_context,
       new.allows_harvest_purpose
     )
     is distinct from
     row(
       old.code,
       old.value_schema,
       old.quantity_kind,
       old.canonical_unit_id,
       old.knowledge_scope,
       old.allows_crop,
       old.allows_cultivar,
       old.allows_production_context,
       old.allows_protection_context,
       old.allows_training_context,
       old.allows_harvest_purpose
     )
     and private.is_agronomic_parameter_semantically_frozen(old.id) then
    raise exception using
      errcode = '55000',
      message = 'Agronomic Parameter semantic fields are frozen by immutable Knowledge artifacts';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_agronomic_parameter_semantic_freeze()
  from public, anon, authenticated;

create trigger agronomic_parameters_enforce_semantic_freeze
before update
on public.agronomic_parameters
for each row
execute function private.enforce_agronomic_parameter_semantic_freeze();

comment on function private.enforce_agronomic_parameter_semantic_freeze() is
  'Congela i campi semantici del Parameter dal primo riferimento immutabile.';

create function private.enforce_measurement_unit_semantic_freeze()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_is_frozen boolean;
begin
  if row(
       new.code,
       new.quantity_kind,
       new.to_base_factor,
       new.to_base_offset
     )
     is not distinct from
     row(
       old.code,
       old.quantity_kind,
       old.to_base_factor,
       old.to_base_offset
     ) then
    return new;
  end if;

  select
    exists (
      select 1
      from public.agronomic_observations o
      where o.unit_id = old.id
        and o.status = 'NORMALIZED'
    )
    or exists (
      select 1
      from public.candidate_submissions s
      where s.unit_id = old.id
    )
    or exists (
      select 1
      from public.agronomic_assertions a
      where a.unit_id = old.id
    )
    or exists (
      select 1
      from public.agronomic_parameters p
      where p.canonical_unit_id = old.id
        and private.is_agronomic_parameter_semantically_frozen(p.id)
    )
  into v_is_frozen;

  if v_is_frozen then
    raise exception using
      errcode = '55000',
      message = 'Measurement Unit semantic fields are frozen by immutable Knowledge artifacts';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_measurement_unit_semantic_freeze()
  from public, anon, authenticated;

create trigger measurement_units_enforce_semantic_freeze
before update
on public.measurement_units
for each row
execute function private.enforce_measurement_unit_semantic_freeze();

comment on function private.enforce_measurement_unit_semantic_freeze() is
  'Congela codice, dimensione e conversione della Unit dal primo riferimento immutabile diretto o canonico.';

create function private.enforce_parameter_enum_value_semantic_freeze()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_is_frozen boolean;
begin
  if row(new.parameter_id, new.code)
     is not distinct from
     row(old.parameter_id, old.code) then
    return new;
  end if;

  select
    exists (
      select 1
      from public.agronomic_observations o
      where o.enum_value_id = old.id
        and o.status = 'NORMALIZED'
    )
    or exists (
      select 1
      from public.candidate_submissions s
      where s.enum_value_id = old.id
    )
    or exists (
      select 1
      from public.agronomic_assertions a
      where a.enum_value_id = old.id
    )
  into v_is_frozen;

  if v_is_frozen then
    raise exception using
      errcode = '55000',
      message = 'Parameter Enum Value semantic fields are frozen by immutable Knowledge artifacts';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.enforce_parameter_enum_value_semantic_freeze()
  from public, anon, authenticated;

create trigger parameter_enum_values_enforce_semantic_freeze
before update
on public.parameter_enum_values
for each row
execute function private.enforce_parameter_enum_value_semantic_freeze();

comment on function private.enforce_parameter_enum_value_semantic_freeze() is
  'Congela parent Parameter e codice della Enum Value dal primo riferimento immutabile.';


-- ============================================================================
-- 4. COMPLETEZZA TRANSAZIONALE DELLA PUBLICATION
-- ============================================================================

create function private.check_candidate_publication_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_submission public.candidate_submissions%rowtype;
  v_assertion public.agronomic_assertions%rowtype;
  v_target_status text;
begin
  if new.status <> 'PUBLISHED'
     or old.status = 'PUBLISHED' then
    return null;
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.candidate_id = new.id
  order by s.submission_no desc
  limit 1;

  if not found then
    raise exception using
      errcode = '23514',
      message = 'Published Candidate requires a Submission';
  end if;

  if v_submission.action is distinct from new.action
     or v_submission.target_assertion_id
          is distinct from new.target_assertion_id then
    raise exception using
      errcode = '23514',
      message = 'Published Candidate differs from its latest Submission';
  end if;

  if not exists (
    select 1
    from public.candidate_reviews r
    where r.submission_id = v_submission.id
      and r.decision = 'ACCEPT'
  ) then
    raise exception using
      errcode = '23514',
      message = 'Published Candidate requires an ACCEPT Review on its latest Submission';
  end if;

  if new.action in ('CREATE', 'REPLACE') then
    select a.*
    into v_assertion
    from public.agronomic_assertions a
    where a.source_submission_id = v_submission.id;

    if not found or v_assertion.status <> 'APPROVED' then
      raise exception using
        errcode = '23514',
        message = 'Published CREATE or REPLACE Candidate requires its APPROVED Assertion';
    end if;

    if new.action = 'CREATE' then
      if new.target_assertion_id is not null then
        raise exception using
          errcode = '23514',
          message = 'Published CREATE Candidate cannot have a target Assertion';
      end if;

    else
      if v_assertion.previous_revision_id
           is distinct from new.target_assertion_id then
        raise exception using
          errcode = '23514',
          message = 'Published REPLACE Assertion must immediately follow its target';
      end if;

      select a.status
      into v_target_status
      from public.agronomic_assertions a
      where a.id = new.target_assertion_id;

      if not found or v_target_status <> 'SUPERSEDED' then
        raise exception using
          errcode = '23514',
          message = 'Published REPLACE Candidate requires a SUPERSEDED target';
      end if;
    end if;

  elsif new.action = 'WITHDRAW' then
    if exists (
      select 1
      from public.agronomic_assertions a
      where a.source_submission_id = v_submission.id
    ) then
      raise exception using
        errcode = '23514',
        message = 'Published WITHDRAW Candidate cannot create an Assertion';
    end if;

    select a.status
    into v_target_status
    from public.agronomic_assertions a
    where a.id = new.target_assertion_id;

    if not found or v_target_status <> 'WITHDRAWN' then
      raise exception using
        errcode = '23514',
        message = 'Published WITHDRAW Candidate requires a WITHDRAWN target';
    end if;

  else
    raise exception using
      errcode = '23514',
      message = 'Unsupported published Candidate action';
  end if;

  return null;
end;
$function$;

revoke all
  on function private.check_candidate_publication_complete()
  from public, anon, authenticated;

create constraint trigger agronomic_candidates_check_publication_complete
after update
on public.agronomic_candidates
deferrable initially deferred
for each row
execute function private.check_candidate_publication_complete();

comment on function private.check_candidate_publication_complete() is
  'Verifica a fine transazione che ogni Candidate PUBLISHED abbia completato CREATE, REPLACE o WITHDRAW.';

create function private.check_assertion_transition_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if new.status is not distinct from old.status
     or new.status not in ('SUPERSEDED', 'WITHDRAWN') then
    return null;
  end if;

  if new.status = 'SUPERSEDED' then
    if not exists (
      select 1
      from public.agronomic_assertions successor
      join public.candidate_submissions s
        on s.id = successor.source_submission_id
      join public.agronomic_candidates c
        on c.id = s.candidate_id
      join public.candidate_reviews r
        on r.submission_id = s.id
       and r.decision = 'ACCEPT'
      where successor.previous_revision_id = new.id
        and successor.status = 'APPROVED'
        and s.action = 'REPLACE'
        and s.target_assertion_id = new.id
        and c.status = 'PUBLISHED'
        and c.action = 'REPLACE'
        and c.target_assertion_id = new.id
        and not exists (
          select 1
          from public.candidate_submissions later_submission
          where later_submission.candidate_id = c.id
            and later_submission.submission_no > s.submission_no
        )
    ) then
      raise exception using
        errcode = '23514',
        message = 'SUPERSEDED Assertion requires a complete published REPLACE successor';
    end if;

  else
    if not exists (
      select 1
      from public.agronomic_candidates c
      join public.candidate_submissions s
        on s.candidate_id = c.id
      join public.candidate_reviews r
        on r.submission_id = s.id
       and r.decision = 'ACCEPT'
      where c.status = 'PUBLISHED'
        and c.action = 'WITHDRAW'
        and c.target_assertion_id = new.id
        and s.action = 'WITHDRAW'
        and s.target_assertion_id = new.id
        and not exists (
          select 1
          from public.candidate_submissions later_submission
          where later_submission.candidate_id = c.id
            and later_submission.submission_no > s.submission_no
        )
    ) then
      raise exception using
        errcode = '23514',
        message = 'WITHDRAWN Assertion requires a complete published WITHDRAW workflow';
    end if;
  end if;

  return null;
end;
$function$;

revoke all
  on function private.check_assertion_transition_complete()
  from public, anon, authenticated;

create constraint trigger agronomic_assertions_check_transition_complete
after update
on public.agronomic_assertions
deferrable initially deferred
for each row
execute function private.check_assertion_transition_complete();

comment on function private.check_assertion_transition_complete() is
  'Impedisce a fine transazione Assertion SUPERSEDED o WITHDRAWN prive del workflow pubblicato corrispondente.';
