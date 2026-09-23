-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 10 - PUBBLICAZIONE E RISOLUZIONE DELLA KNOWLEDGE CANONICA
-- ============================================================================
--
-- Introduce:
-- - il Write Path autoritativo e atomico per pubblicare Candidate accettate;
-- - il Resolver esatto e current-only della Knowledge canonica.
--
-- La publication indicata storicamente come Tranche 9E viene consolidata qui:
-- non esiste una Tranche 9E separata. La Tranche 9 resta composta da 9A-9D.
--
-- Nessun dato iniziale o dimostrativo viene inserito.
-- Nessun fallback tra Crop e Cultivar o tra contesti viene applicato.
-- ============================================================================


-- ============================================================================
-- 1. PUBLICATION WRITE PATH
-- ============================================================================

create function public.publish_agronomic_candidate(
  target_candidate_id uuid,
  expected_candidate_row_version bigint
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
  v_parameter public.agronomic_parameters%rowtype;
  v_source_unit public.measurement_units%rowtype;
  v_canonical_unit public.measurement_units%rowtype;
  v_target public.agronomic_assertions%rowtype;
  v_latest_revision public.agronomic_assertions%rowtype;
  v_assertion public.agronomic_assertions%rowtype;
  v_published_candidate public.agronomic_candidates%rowtype;

  v_previous_revision_id uuid;
  v_revision_no integer;
  v_numeric_value numeric;
  v_numeric_min_value numeric;
  v_numeric_max_value numeric;
  v_boolean_value boolean;
  v_enum_value_id uuid;
  v_unit_id uuid;

  v_constraint_name text;
begin
  if v_auth_user_id is null then
    return jsonb_build_object('status', 'unauthenticated');
  end if;

  if not private.can_publish_catalog() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_candidate_id is null
     or expected_candidate_row_version is null
     or expected_candidate_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.*
  into v_candidate
  from public.agronomic_candidates c
  where c.id = target_candidate_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  -- Un retry successivo al commit non deve creare revisioni o Evidence duplicate.
  if v_candidate.status = 'PUBLISHED' then
    select s.*
    into v_submission
    from public.candidate_submissions s
    where s.candidate_id = v_candidate.id
    order by s.submission_no desc
    limit 1;

    if v_candidate.action in ('CREATE', 'REPLACE') then
      select a.*
      into v_assertion
      from public.agronomic_assertions a
      where a.source_submission_id = v_submission.id;
    else
      select a.*
      into v_assertion
      from public.agronomic_assertions a
      where a.id = v_candidate.target_assertion_id;
    end if;

    return jsonb_build_object(
      'status', 'already_published',
      'action', v_candidate.action,
      'candidate_id', v_candidate.id,
      'candidate_status', v_candidate.status,
      'candidate_row_version', v_candidate.row_version,
      'assertion_id', v_assertion.id,
      'assertion_status', v_assertion.status,
      'revision_no', v_assertion.revision_no
    );
  end if;

  if v_candidate.status <> 'ACCEPTED' then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status,
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  if v_candidate.row_version <> expected_candidate_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_candidate_row_version', v_candidate.row_version
    );
  end if;

  select s.*
  into v_submission
  from public.candidate_submissions s
  where s.candidate_id = v_candidate.id
  order by s.submission_no desc
  limit 1
  for share;

  if not found
     or not exists (
       select 1
       from public.candidate_reviews r
       where r.submission_id = v_submission.id
         and r.decision = 'ACCEPT'
     ) then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  if v_submission.action is distinct from v_candidate.action
     or v_submission.target_assertion_id
          is distinct from v_candidate.target_assertion_id then
    return jsonb_build_object(
      'status', 'invalid_state',
      'candidate_status', v_candidate.status
    );
  end if;

  -- CREATE e REPLACE devono rivalidare le dipendenze attive al momento esatto
  -- della publication. L helper esistente esclude intenzionalmente WITHDRAW.
  begin
    perform private.validate_active_candidate_dependencies(v_candidate);
  exception
    when raise_exception then
      if sqlerrm = 'candidate_dependency_inactive' then
        return jsonb_build_object('status', 'dependency_inactive');
      end if;
      raise;
  end;

  if v_candidate.action in ('CREATE', 'REPLACE') then
    select p.*
    into v_parameter
    from public.agronomic_parameters p
    where p.id = v_submission.parameter_id
    for share;

    if not found then
      return jsonb_build_object('status', 'invalid_input');
    end if;

    -- Anche l unita canonica e una dipendenza di publication. Il normale Write
    -- Path ne impedisce il retirement finche il Parameter e attivo; il controllo
    -- resta esplicito contro alterazioni amministrative anomale.
    if v_parameter.value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
      select u.*
      into v_canonical_unit
      from public.measurement_units u
      where u.id = v_parameter.canonical_unit_id
      for share;

      if not found or not v_canonical_unit.is_active then
        return jsonb_build_object('status', 'dependency_inactive');
      end if;
    end if;

    v_numeric_value := null;
    v_numeric_min_value := null;
    v_numeric_max_value := null;
    v_boolean_value := null;
    v_enum_value_id := null;
    v_unit_id := null;

    if v_submission.kind = 'VALUE' then
      if v_parameter.value_schema in ('NUMERIC_SCALAR', 'NUMERIC_RANGE') then
        select u.*
        into v_source_unit
        from public.measurement_units u
        where u.id = v_submission.unit_id
        for share;

        if not found or not v_source_unit.is_active then
          return jsonb_build_object('status', 'dependency_inactive');
        end if;

        if v_source_unit.quantity_kind
             is distinct from v_canonical_unit.quantity_kind then
          return jsonb_build_object('status', 'invalid_input');
        end if;

        v_unit_id := v_canonical_unit.id;

        if v_parameter.value_schema = 'NUMERIC_SCALAR' then
          v_numeric_value :=
            (
              v_submission.numeric_value
              * v_source_unit.to_base_factor
              + v_source_unit.to_base_offset
              - v_canonical_unit.to_base_offset
            )
            / v_canonical_unit.to_base_factor;
        else
          v_numeric_min_value :=
            (
              v_submission.numeric_min_value
              * v_source_unit.to_base_factor
              + v_source_unit.to_base_offset
              - v_canonical_unit.to_base_offset
            )
            / v_canonical_unit.to_base_factor;

          v_numeric_max_value :=
            (
              v_submission.numeric_max_value
              * v_source_unit.to_base_factor
              + v_source_unit.to_base_offset
              - v_canonical_unit.to_base_offset
            )
            / v_canonical_unit.to_base_factor;
        end if;

      elsif v_parameter.value_schema = 'BOOLEAN' then
        v_boolean_value := v_submission.boolean_value;

      elsif v_parameter.value_schema = 'ENUM' then
        v_enum_value_id := v_submission.enum_value_id;

      else
        return jsonb_build_object('status', 'invalid_input');
      end if;
    end if;
  end if;

  if v_candidate.action = 'CREATE' then
    select a.*
    into v_latest_revision
    from public.agronomic_assertions a
    where a.parameter_id = v_submission.parameter_id
      and a.crop_id = v_submission.crop_id
      and a.cultivar_id is not distinct from v_submission.cultivar_id
      and a.production_context_id
            is not distinct from v_submission.production_context_id
      and a.protection_context_id
            is not distinct from v_submission.protection_context_id
      and a.training_context_id
            is not distinct from v_submission.training_context_id
      and a.harvest_purpose_id
            is not distinct from v_submission.harvest_purpose_id
    order by a.revision_no desc
    limit 1
    for update;

    if found then
      if v_latest_revision.status = 'APPROVED' then
        return jsonb_build_object(
          'status', 'approved_value_already_exists',
          'assertion_id', v_latest_revision.id,
          'revision_no', v_latest_revision.revision_no
        );
      end if;

      if v_latest_revision.status <> 'WITHDRAWN' then
        return jsonb_build_object(
          'status', 'invalid_state',
          'assertion_id', v_latest_revision.id,
          'assertion_status', v_latest_revision.status
        );
      end if;

      v_previous_revision_id := v_latest_revision.id;
      v_revision_no := v_latest_revision.revision_no + 1;
    else
      v_previous_revision_id := null;
      v_revision_no := 1;
    end if;

  elsif v_candidate.action in ('REPLACE', 'WITHDRAW') then
    select a.*
    into v_target
    from public.agronomic_assertions a
    where a.id = v_submission.target_assertion_id
    for update;

    if not found or v_target.status <> 'APPROVED' then
      return jsonb_build_object(
        'status', 'target_not_current',
        'target_assertion_id', v_submission.target_assertion_id,
        'target_status', case when found then v_target.status else null end
      );
    end if;

    if v_candidate.action = 'REPLACE' then
      update public.agronomic_assertions
      set status = 'SUPERSEDED'
      where id = v_target.id
        and status = 'APPROVED';

      if not found then
        return jsonb_build_object('status', 'target_not_current');
      end if;

      v_previous_revision_id := v_target.id;
      v_revision_no := v_target.revision_no + 1;
    else
      update public.agronomic_assertions
      set status = 'WITHDRAWN'
      where id = v_target.id
        and status = 'APPROVED';

      if not found then
        return jsonb_build_object('status', 'target_not_current');
      end if;
    end if;

  else
    return jsonb_build_object('status', 'invalid_input');
  end if;

  if v_candidate.action in ('CREATE', 'REPLACE') then
    insert into public.agronomic_assertions (
      previous_revision_id,
      revision_no,
      status,
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
      source_submission_id,
      approved_by,
      approved_at
    ) values (
      v_previous_revision_id,
      v_revision_no,
      'APPROVED',
      v_submission.kind,
      v_submission.parameter_id,
      v_submission.crop_id,
      v_submission.cultivar_id,
      v_submission.production_context_id,
      v_submission.protection_context_id,
      v_submission.training_context_id,
      v_submission.harvest_purpose_id,
      v_numeric_value,
      v_numeric_min_value,
      v_numeric_max_value,
      v_boolean_value,
      v_enum_value_id,
      v_unit_id,
      v_submission.id,
      v_auth_user_id,
      now()
    )
    returning * into v_assertion;

    insert into public.assertion_evidence (
      assertion_id,
      source_submission_evidence_id,
      observation_id,
      evidence_role,
      editorial_note
    )
    select
      v_assertion.id,
      cse.id,
      cse.observation_id,
      cse.evidence_role,
      cse.editorial_note
    from public.candidate_submission_evidence cse
    where cse.submission_id = v_submission.id;
  else
    v_assertion := v_target;
    v_assertion.status := 'WITHDRAWN';
  end if;

  update public.agronomic_candidates
  set status = 'PUBLISHED'
  where id = v_candidate.id
    and status = 'ACCEPTED'
    and row_version = expected_candidate_row_version
  returning * into v_published_candidate;

  if not found then
    -- Dopo le mutazioni canoniche non si puo uscire con un normale RETURN:
    -- l eccezione forza il rollback del blocco prima della risposta controllata.
    raise exception using
      errcode = '40001',
      message = 'candidate_changed_during_publication';
  end if;

  return jsonb_build_object(
    'status', 'published',
    'action', v_published_candidate.action,
    'candidate_id', v_published_candidate.id,
    'candidate_status', v_published_candidate.status,
    'candidate_row_version', v_published_candidate.row_version,
    'assertion_id', v_assertion.id,
    'assertion_status', v_assertion.status,
    'revision_no', v_assertion.revision_no
  );

exception
  when unique_violation then
    get stacked diagnostics v_constraint_name = constraint_name;

    if v_constraint_name in (
      'agronomic_assertions_one_approved_per_key',
      'agronomic_assertions_logical_revision_unique'
    ) then
      return jsonb_build_object(
        'status', 'approved_value_already_exists'
      );
    end if;

    return jsonb_build_object('status', 'invalid_input');

  when check_violation
    or foreign_key_violation
    or not_null_violation
    or invalid_parameter_value
    or numeric_value_out_of_range then
    return jsonb_build_object('status', 'invalid_input');

  when serialization_failure then
    return jsonb_build_object('status', 'version_conflict');
end;
$function$;

revoke all
  on function public.publish_agronomic_candidate(uuid, bigint)
  from public, anon, authenticated;

grant execute
  on function public.publish_agronomic_candidate(uuid, bigint)
  to authenticated;

comment on function public.publish_agronomic_candidate(uuid, bigint) is
  'Pubblica atomicamente una Candidate ACCEPTED: CREATE, REPLACE o WITHDRAW con conversione canonica, Evidence e retry idempotente.';


-- ============================================================================
-- 2. EXACT CURRENT-ONLY CATALOG RESOLVER
-- ============================================================================

create function public.resolve_agronomic_knowledge(
  target_parameter_id uuid,
  target_crop_id uuid,
  target_cultivar_id uuid,
  target_production_context_id uuid,
  target_protection_context_id uuid,
  target_training_context_id uuid,
  target_harvest_purpose_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_parameter public.agronomic_parameters%rowtype;
  v_crop public.catalog_crops_s030%rowtype;
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
  from public.catalog_crops_s030 c
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
$function$;

revoke all
  on function public.resolve_agronomic_knowledge(
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid
  )
  from public, anon, authenticated;

grant execute
  on function public.resolve_agronomic_knowledge(
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid,
    uuid
  )
  to authenticated;

comment on function public.resolve_agronomic_knowledge(
  uuid,
  uuid,
  uuid,
  uuid,
  uuid,
  uuid,
  uuid
) is
  'Risolve una sola logical key esatta, current-only e senza fallback, restituendo un payload tipizzato in unita canonica.';
