-- ============================================================================
-- ADD TAKEOVER GRANT STATE
-- ============================================================================
-- Introduce lo stato temporaneo e monouso necessario per completare
-- in sicurezza il takeover senza trasferire il lock_token tra client.

alter table public.profile_edit_locks
  add column takeover_granted_to_auth_user_id uuid null
    references auth.users(id)
    on delete restrict,
  add column takeover_granted_to_client_id uuid null,
  add column takeover_granted_to_session_id uuid null,
  add column takeover_granted_at timestamptz null;

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_grant_consistency_check
  check (
    (
      takeover_granted_to_auth_user_id is null
      and takeover_granted_to_client_id is null
      and takeover_granted_to_session_id is null
      and takeover_granted_at is null
    )
    or
    (
      takeover_granted_to_auth_user_id is not null
      and takeover_granted_to_client_id is not null
      and takeover_granted_to_session_id is not null
      and takeover_granted_at is not null
    )
  );

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_request_or_grant_check
  check (
    takeover_granted_at is null
    or (
      takeover_requested_by_auth_user_id is null
      and takeover_requested_by_client_id is null
      and takeover_requested_by_session_id is null
      and takeover_requested_at is null
    )
  );

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_grant_not_holder_check
  check (
    takeover_granted_to_auth_user_id is null
    or takeover_granted_to_client_id is null
    or takeover_granted_to_session_id is null
    or holder_auth_user_id <> takeover_granted_to_auth_user_id
    or client_instance_id <> takeover_granted_to_client_id
    or holder_session_id <> takeover_granted_to_session_id
  );
