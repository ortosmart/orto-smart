create function public.get_seasonal_planning_mutation_receipt(
  target_profile_id uuid,
  target_operation_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  recorded private.mutation_operations%rowtype;
begin
  if auth.uid() is null or private.is_profile_owner(target_profile_id) is not true then
    return jsonb_build_object('status', 'forbidden');
  end if;

  select m.* into recorded
  from private.mutation_operations as m
  where m.profile_id = target_profile_id
    and m.operation_id = target_operation_id
    and m.operation_domain = 'seasonal_planning';

  if not found then
    return jsonb_build_object('status', 'intent_not_registered');
  end if;

  return jsonb_build_object(
    'status', recorded.operation_status,
    'profile_id', recorded.profile_id,
    'operation_id', recorded.operation_id,
    'operation_domain', recorded.operation_domain,
    'operation_type', recorded.operation_type,
    'request_schema_version', recorded.request_schema_version,
    'request_fingerprint', pg_catalog.encode(recorded.request_fingerprint, 'hex'),
    'recovery_generation', recorded.recovery_generation,
    'domain_generation', recorded.domain_generation,
    'receipt_schema_version', recorded.receipt_schema_version,
    'outcome', recorded.outcome,
    'result_status', recorded.result_status,
    'result_payload', recorded.result_payload
  );
end;
$function$;

revoke all on function public.get_seasonal_planning_mutation_receipt(uuid, uuid)
  from public, anon, authenticated, service_role;
grant execute on function public.get_seasonal_planning_mutation_receipt(uuid, uuid)
  to authenticated;

create function public.close_seasonal_planning_mutation_intent(
  target_profile_id uuid,
  target_operation_id uuid,
  target_operation_type text,
  target_request_schema_version integer,
  target_recovery_generation uuid,
  target_domain_generation uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language sql
volatile
security definer
set search_path = ''
as $function$
  select pg_catalog.jsonb_build_object(
    'status', private.close_mutation_intent(
      target_profile_id, target_operation_id, 'seasonal_planning',
      target_operation_type, target_request_schema_version,
      target_recovery_generation, target_domain_generation,
      target_client_id, target_session_id, lock_token
    )
  );
$function$;

revoke all on function public.close_seasonal_planning_mutation_intent(
  uuid, uuid, text, integer, uuid, uuid, uuid, uuid, text
) from public, anon, authenticated, service_role;
grant execute on function public.close_seasonal_planning_mutation_intent(
  uuid, uuid, text, integer, uuid, uuid, uuid, uuid, text
) to authenticated;
