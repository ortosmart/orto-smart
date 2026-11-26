create table private.mutation_operations (
  profile_id uuid not null,
  operation_id uuid not null,
  operation_domain text not null,
  operation_type text not null,
  request_schema_version integer not null,
  request_fingerprint bytea,
  operation_status text not null,
  recovery_generation uuid not null,
  domain_generation uuid not null,
  entity_id uuid,
  registered_at timestamptz,
  completed_at timestamptz,
  receipt_schema_version integer,
  outcome text,
  result_status text,
  result_payload jsonb,

  constraint mutation_operations_pkey
    primary key (profile_id, operation_id),

  constraint mutation_operations_identity_check check (
    profile_id <> '00000000-0000-0000-0000-000000000000'::uuid
    and operation_id <> '00000000-0000-0000-0000-000000000000'::uuid
    and recovery_generation <> '00000000-0000-0000-0000-000000000000'::uuid
    and domain_generation <> '00000000-0000-0000-0000-000000000000'::uuid
    and request_schema_version > 0
    and operation_domain = 'seasonal_planning'
    and operation_type in (
      'create_planned_planting', 'update_planned_planting',
      'confirm_planned_planting', 'cancel_planned_planting',
      'execute_planned_planting'
    )
  ),

  constraint mutation_operations_registration_check check (
    (registered_at is null) = (request_fingerprint is null)
    and (request_fingerprint is null or octet_length(request_fingerprint) = 32)
    and (operation_status = 'CLOSED' or registered_at is not null)
  ),

  constraint mutation_operations_state_check check ((
    case operation_status
      when 'PENDING' then
        completed_at is null and receipt_schema_version is null
        and outcome is null and result_status is null and result_payload is null
      when 'COMPLETED' then
        outcome in ('succeeded', 'rejected')
      when 'CLOSED' then
        outcome = 'neutralized'
      else false
    end
    and (
      operation_status = 'PENDING'
      or (
        completed_at is not null and receipt_schema_version > 0
        and result_status <> '' and result_status = btrim(result_status)
        and jsonb_typeof(result_payload) = 'object'
      )
    )
  ) is true)
);

create unique index mutation_operations_one_pending_per_domain
  on private.mutation_operations (profile_id, operation_domain)
  where operation_status = 'PENDING';

alter table private.mutation_operations enable row level security;

revoke all privileges on table private.mutation_operations
  from public, anon, authenticated, service_role;

create function private.enforce_mutation_operation_transition()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  if tg_op in ('DELETE', 'TRUNCATE') then
    raise exception using
      errcode = '55000', message = 'Mutation operations cannot be removed';
  end if;

  if tg_op = 'INSERT' then
    if new.operation_status = 'PENDING'
       or (new.operation_status = 'CLOSED' and new.registered_at is null)
    then
      return new;
    end if;

    raise exception using
      errcode = '55000', message = 'Invalid initial mutation operation state';
  end if;

  if old.operation_status <> 'PENDING'
     or new.operation_status not in ('COMPLETED', 'CLOSED')
     or row(
       new.profile_id, new.operation_id, new.operation_domain,
       new.operation_type, new.request_schema_version, new.request_fingerprint,
       new.recovery_generation, new.domain_generation, new.registered_at
     ) is distinct from row(
       old.profile_id, old.operation_id, old.operation_domain,
       old.operation_type, old.request_schema_version, old.request_fingerprint,
       old.recovery_generation, old.domain_generation, old.registered_at
     )
  then
    raise exception using
      errcode = '55000', message = 'Invalid mutation operation transition';
  end if;

  return new;
end;
$function$;

revoke all on function private.enforce_mutation_operation_transition()
  from public, anon, authenticated, service_role;

create trigger mutation_operations_enforce_transition
  before insert or update or delete on private.mutation_operations
  for each row execute function private.enforce_mutation_operation_transition();

create trigger mutation_operations_prevent_truncate
  before truncate on private.mutation_operations
  for each statement execute function private.enforce_mutation_operation_transition();
-- The singleton is initialized once when this migration is applied.
create table private.recovery_control (
  control_id boolean primary key default true check (control_id),
  recovery_generation uuid not null default gen_random_uuid()
    check (recovery_generation <> '00000000-0000-0000-0000-000000000000'::uuid),
  recovery_state text not null
    check (recovery_state in ('NORMAL', 'RECOVERY', 'VALIDATING')),
  generation_created_at timestamptz not null default clock_timestamp()
);

alter table private.recovery_control enable row level security;

revoke all privileges on table private.recovery_control
  from public, anon, authenticated, service_role;

insert into private.recovery_control (recovery_state)
values ('NORMAL');

-- Current admission generation. Historical values remain in the registry.
create table private.mutation_domain_generations (
  profile_id uuid not null
    check (profile_id <> '00000000-0000-0000-0000-000000000000'::uuid),
  operation_domain text not null check (operation_domain = 'seasonal_planning'),
  domain_generation uuid not null default gen_random_uuid()
    check (domain_generation <> '00000000-0000-0000-0000-000000000000'::uuid),

  constraint mutation_domain_generations_pkey
    primary key (profile_id, operation_domain)
);

alter table private.mutation_domain_generations enable row level security;

revoke all privileges on table private.mutation_domain_generations
  from public, anon, authenticated, service_role;

-- Acquire before Write Authority and before reading the registry.
-- Recovery procedures must acquire an exclusive lock on the control row.
create function private.lock_mutation_operation_scope(
  target_profile_id uuid,
  target_operation_domain text
)
returns uuid
language plpgsql
volatile
set search_path = ''
as $function$
declare
  current_recovery_generation uuid;
begin
  if target_profile_id is null
     or target_profile_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_operation_domain is distinct from 'seasonal_planning'
  then
    return null;
  end if;

  select control.recovery_generation
    into current_recovery_generation
  from private.recovery_control as control
  where control.control_id
    and control.recovery_state = 'NORMAL'
  for share;

  if not found then
    return null;
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'orto_smart:mutation_scope:' || target_operation_domain || ':' || target_profile_id::text,
      0
    )
  );

  return current_recovery_generation;
end;
$function$;

revoke all on function private.lock_mutation_operation_scope(uuid, text)
  from public, anon, authenticated, service_role;

create function private.get_or_initialize_mutation_generations(
  target_profile_id uuid,
  target_operation_domain text,
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
begin
  if auth.uid() is null
     or private.is_profile_owner(target_profile_id) is not true
  then
    return null;
  end if;

  current_recovery_generation := private.lock_mutation_operation_scope(
    target_profile_id, target_operation_domain
  );
  if current_recovery_generation is null
     or private.lock_profile_write_authority(
       target_profile_id, target_client_id, target_session_id, lock_token
     ) is not true
  then
    return null;
  end if;

  select generations.domain_generation into current_domain_generation
  from private.mutation_domain_generations as generations
  where generations.profile_id = target_profile_id
    and generations.operation_domain = target_operation_domain;

  if not found then
    insert into private.mutation_domain_generations (profile_id, operation_domain)
    values (target_profile_id, target_operation_domain)
    returning domain_generation into current_domain_generation;
  end if;

  return jsonb_build_object(
    'recovery_generation', current_recovery_generation,
    'domain_generation', current_domain_generation
  );
end;
$function$;

revoke all on function private.get_or_initialize_mutation_generations(uuid, text, uuid, uuid, text)
  from public, anon, authenticated, service_role;

create function private.register_mutation_intent(
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
returns text
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
    return 'write_forbidden';
  end if;

  if target_operation_id is null
     or target_operation_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_operation_domain is distinct from 'seasonal_planning'
     or target_operation_type is null
     or target_operation_type not in (
       'create_planned_planting', 'update_planned_planting',
       'confirm_planned_planting', 'cancel_planned_planting',
       'execute_planned_planting'
     )
     or target_request_schema_version is distinct from 1
     or octet_length(target_request_fingerprint) is distinct from 32
  then
    return 'invalid_request';
  end if;

  current_recovery_generation := private.lock_mutation_operation_scope(
    target_profile_id, target_operation_domain
  );
  if current_recovery_generation is null then
    return 'registry_unavailable';
  end if;

  if private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) is not true then
    return 'write_forbidden';
  end if;

  select g.domain_generation into current_domain_generation
  from private.mutation_domain_generations as g
  where g.profile_id = target_profile_id
    and g.operation_domain = target_operation_domain;

  if current_domain_generation is null
     or current_recovery_generation is distinct from target_recovery_generation
     or current_domain_generation is distinct from target_domain_generation
  then
    return 'generation_mismatch';
  end if;

  select operation.* into existing_operation
  from private.mutation_operations as operation
  where operation.profile_id = target_profile_id
    and operation.operation_id = target_operation_id;

  if found then
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
      return 'operation_conflict';
    end if;

    return existing_operation.operation_status;
  end if;

  if exists (
    select 1 from private.mutation_operations as operation
    where operation.profile_id = target_profile_id
      and operation.operation_domain = target_operation_domain
      and operation.operation_status = 'PENDING'
  ) then
    return 'pending_operation_exists';
  end if;

  insert into private.mutation_operations (
    profile_id, operation_id, operation_domain, operation_type,
    request_schema_version, request_fingerprint, operation_status,
    recovery_generation, domain_generation, registered_at
  ) values (
    target_profile_id, target_operation_id, target_operation_domain, target_operation_type,
    target_request_schema_version, target_request_fingerprint, 'PENDING',
    target_recovery_generation, target_domain_generation, clock_timestamp()
  );

  return 'PENDING';
end;
$function$;

revoke all on function private.register_mutation_intent(
  uuid, uuid, text, text, integer, bytea, uuid, uuid, uuid, uuid, text
) from public, anon, authenticated, service_role;

-- Caller must hold the scope lock and validate Write Authority and generations.
-- Execute in the same transaction as the domain mutation.
create function private.complete_mutation_intent(
  target_profile_id uuid,
  target_operation_id uuid,
  target_operation_domain text,
  target_operation_type text,
  target_request_schema_version integer,
  target_request_fingerprint bytea,
  target_recovery_generation uuid,
  target_domain_generation uuid,
  target_entity_id uuid,
  target_outcome text,
  target_result_status text,
  target_result_payload jsonb
)
returns void
language plpgsql
volatile
set search_path = ''
as $function$
begin
  update private.mutation_operations as operation
  set operation_status = 'COMPLETED',
      entity_id = target_entity_id,
      completed_at = clock_timestamp(),
      receipt_schema_version = 1,
      outcome = target_outcome,
      result_status = target_result_status,
      result_payload = target_result_payload
  where operation.profile_id = target_profile_id
    and operation.operation_id = target_operation_id
    and operation.operation_domain = target_operation_domain
    and operation.operation_type = target_operation_type
    and operation.request_schema_version = target_request_schema_version
    and operation.request_fingerprint = target_request_fingerprint
    and operation.recovery_generation = target_recovery_generation
    and operation.domain_generation = target_domain_generation
    and operation.operation_status = 'PENDING';

  if not found then
    raise exception using
      errcode = '55000', message = 'Matching pending mutation intent not found';
  end if;
end;
$function$;

revoke all on function private.complete_mutation_intent(
  uuid, uuid, text, text, integer, bytea, uuid, uuid, uuid, text, text, jsonb
) from public, anon, authenticated, service_role;

create function private.close_mutation_intent(
  target_profile_id uuid,
  target_operation_id uuid,
  target_operation_domain text,
  target_operation_type text,
  target_request_schema_version integer,
  target_recovery_generation uuid,
  target_domain_generation uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns text
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
    return 'write_forbidden';
  end if;

  if target_operation_id is null
     or target_operation_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_operation_domain is distinct from 'seasonal_planning'
     or target_operation_type is null
     or target_operation_type not in (
       'create_planned_planting', 'update_planned_planting',
       'confirm_planned_planting', 'cancel_planned_planting',
       'execute_planned_planting'
     )
     or target_request_schema_version is distinct from 1
  then
    return 'invalid_request';
  end if;

  current_recovery_generation := private.lock_mutation_operation_scope(
    target_profile_id, target_operation_domain
  );
  if current_recovery_generation is null then
    return 'registry_unavailable';
  end if;

  if private.lock_profile_write_authority(
    target_profile_id, target_client_id, target_session_id, lock_token
  ) is not true then
    return 'write_forbidden';
  end if;

  select g.domain_generation into current_domain_generation
  from private.mutation_domain_generations as g
  where g.profile_id = target_profile_id
    and g.operation_domain = target_operation_domain;

  if current_domain_generation is null
     or current_recovery_generation is distinct from target_recovery_generation
     or current_domain_generation is distinct from target_domain_generation
  then
    return 'generation_mismatch';
  end if;

  select operation.* into existing_operation
  from private.mutation_operations as operation
  where operation.profile_id = target_profile_id
    and operation.operation_id = target_operation_id;

  if found then
    if row(
      existing_operation.operation_domain, existing_operation.operation_type,
      existing_operation.request_schema_version,
      existing_operation.recovery_generation, existing_operation.domain_generation
    ) is distinct from row(
      target_operation_domain, target_operation_type, target_request_schema_version,
      target_recovery_generation, target_domain_generation
    ) then
      return 'operation_conflict';
    end if;

    if existing_operation.operation_status <> 'PENDING' then
      return existing_operation.operation_status;
    end if;

    update private.mutation_operations
    set operation_status = 'CLOSED',
        completed_at = clock_timestamp(),
        receipt_schema_version = 1,
        outcome = 'neutralized',
        result_status = 'neutralized',
        result_payload = jsonb_build_object()
    where profile_id = target_profile_id
      and operation_id = target_operation_id;
  else
    insert into private.mutation_operations (
      profile_id, operation_id, operation_domain, operation_type,
      request_schema_version, operation_status, recovery_generation,
      domain_generation, completed_at, receipt_schema_version,
      outcome, result_status, result_payload
    ) values (
      target_profile_id, target_operation_id, target_operation_domain,
      target_operation_type, target_request_schema_version, 'CLOSED',
      target_recovery_generation, target_domain_generation, clock_timestamp(),
      1, 'neutralized', 'neutralized', jsonb_build_object()
    );
  end if;

  return 'CLOSED';
end;
$function$;

revoke all on function private.close_mutation_intent(
  uuid, uuid, text, text, integer, uuid, uuid, uuid, uuid, text
) from public, anon, authenticated, service_role;
