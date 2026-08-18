-- ============================================================================
-- HARDEN PROFILE EDIT LOCKS
-- ============================================================================
-- Evoluzione incrementale della baseline S019.
-- I lock esistenti rappresentano stato tecnico temporaneo e vengono invalidati
-- prima dell'introduzione del nuovo protocollo di sicurezza.

delete from public.profile_edit_locks;

alter table public.profile_edit_locks
  drop constraint profile_edit_locks_takeover_consistency_check,
  drop constraint profile_edit_locks_takeover_not_holder_check,
  drop constraint profile_edit_locks_client_label_not_blank_check,
  drop constraint profile_edit_locks_client_label_length_check,
  drop constraint profile_edit_locks_takeover_client_label_not_blank_check,
  drop constraint profile_edit_locks_takeover_client_label_length_check;

alter table public.profile_edit_locks
  drop column client_label,
  drop column takeover_requested_client_label;

alter table public.profile_edit_locks
  add column holder_session_id uuid not null,
  add column lock_token_hash bytea not null,
  add column takeover_requested_by_session_id uuid null,
  add column takeover_silenced_until timestamptz null;

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_consistency_check
  check (
    (
      takeover_requested_by_auth_user_id is null
      and takeover_requested_by_client_id is null
      and takeover_requested_by_session_id is null
      and takeover_requested_at is null
    )
    or
    (
      takeover_requested_by_auth_user_id is not null
      and takeover_requested_by_client_id is not null
      and takeover_requested_by_session_id is not null
      and takeover_requested_at is not null
    )
  );

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_not_holder_check
  check (
    takeover_requested_by_auth_user_id is null
    or takeover_requested_by_client_id is null
    or takeover_requested_by_session_id is null
    or holder_auth_user_id <> takeover_requested_by_auth_user_id
    or client_instance_id <> takeover_requested_by_client_id
    or holder_session_id <> takeover_requested_by_session_id
  );

alter table public.profile_edit_locks
  add constraint profile_edit_locks_lock_token_hash_length_check
  check (octet_length(lock_token_hash) = 32);

alter table public.profile_edit_locks
  add constraint profile_edit_locks_takeover_silence_check
  check (
    takeover_silenced_until is null
    or takeover_silenced_until >= acquired_at
  );
