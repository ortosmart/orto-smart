-- ============================================================================
-- SECURE PROFILE EDIT LOCK RPCS
-- ============================================================================
-- Helper privati e RPC server-side per il protocollo sicuro di modifica profilo.

create or replace function private.profile_edit_lock_token_hash(
  lock_token text
)
returns bytea
language sql
immutable
security invoker
set search_path = ''
as $$
  select extensions.digest(lock_token, 'sha256');
$$;

create or replace function private.is_profile_edit_lock_holder(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profile_edit_locks pel
    where pel.profile_id = target_profile_id
      and pel.holder_auth_user_id = auth.uid()
      and pel.client_instance_id = target_client_id
      and pel.holder_session_id = target_session_id
      and pel.lock_token_hash =
        private.profile_edit_lock_token_hash(lock_token)
      and pel.expires_at > now()
      and private.is_profile_owner(target_profile_id)
  );
$$;

create or replace function private.is_profile_auth_user_owner(
  target_profile_id uuid,
  target_auth_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profile_memberships pm
    where pm.profile_id = target_profile_id
      and pm.auth_user_id = target_auth_user_id
      and pm.role = 'owner'::public.profile_member_role
      and pm.is_enabled = true
  );
$$;

create or replace function private.can_edit_profile(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    private.is_profile_edit_lock_holder(
      target_profile_id,
      target_client_id,
      target_session_id,
      lock_token
    )
    and not exists (
      select 1
      from public.profile_edit_locks pel
      where pel.profile_id = target_profile_id
        and pel.takeover_granted_at is not null
        and pel.takeover_granted_at + interval '60 seconds' > now()
    );
$$;

revoke all
  on function private.profile_edit_lock_token_hash(text)
  from public;

revoke all
  on function private.is_profile_edit_lock_holder(uuid, uuid, uuid, text)
  from public;

revoke all
  on function private.is_profile_auth_user_owner(uuid, uuid)
  from public;

revoke all
  on function private.can_edit_profile(uuid, uuid, uuid, text)
  from public;

-- ============================================================================
-- ACQUIRE PROFILE EDIT LOCK
-- ============================================================================

create or replace function public.acquire_profile_edit_lock(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_auth_user_id uuid := auth.uid();
  server_now timestamptz := now();

  generated_lock_token text;

  acquired_profile_id uuid;
  acquired_expires_at timestamptz;
  acquired_row_version bigint;

  existing_holder_auth_user_id uuid;
  existing_client_id uuid;
  existing_session_id uuid;
begin
  -- Richiede una sessione autenticata.
  if current_auth_user_id is null then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Rifiuta identificatori mancanti o UUID zero.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or target_profile_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_client_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_session_id = '00000000-0000-0000-0000-000000000000'::uuid
  then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  -- Solo l'owner attivo del profilo può acquisire l'edit lock.
  if not private.is_profile_owner(target_profile_id) then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Il token nasce esclusivamente lato server.
  generated_lock_token :=
    encode(extensions.gen_random_bytes(32), 'hex');

  -- Inserisce un nuovo lock oppure ricicla atomicamente quello esistente
  -- solo se è scaduto o se il vecchio holder non è più autorizzato.
  insert into public.profile_edit_locks (
    profile_id,
    holder_auth_user_id,
    client_instance_id,
    acquired_at,
    heartbeat_at,
    expires_at,
    takeover_requested_by_auth_user_id,
    takeover_requested_by_client_id,
    takeover_requested_at,
    row_version,
    holder_session_id,
    lock_token_hash,
    takeover_requested_by_session_id,
    takeover_silenced_until,
    takeover_granted_to_auth_user_id,
    takeover_granted_to_client_id,
    takeover_granted_to_session_id,
    takeover_granted_at
  )
  values (
    target_profile_id,
    current_auth_user_id,
    target_client_id,
    server_now,
    server_now,
    server_now + interval '2 minutes',
    null,
    null,
    null,
    1,
    target_session_id,
    private.profile_edit_lock_token_hash(generated_lock_token),
    null,
    null,
    null,
    null,
    null,
    null
  )
  on conflict (profile_id)
  do update
  set
    holder_auth_user_id = excluded.holder_auth_user_id,
    client_instance_id = excluded.client_instance_id,
    acquired_at = excluded.acquired_at,
    heartbeat_at = excluded.heartbeat_at,
    expires_at = excluded.expires_at,
    takeover_requested_by_auth_user_id = null,
    takeover_requested_by_client_id = null,
    takeover_requested_at = null,
    row_version = public.profile_edit_locks.row_version + 1,
    holder_session_id = excluded.holder_session_id,
    lock_token_hash = excluded.lock_token_hash,
    takeover_requested_by_session_id = null,
    takeover_silenced_until = null,
    takeover_granted_to_auth_user_id = null,
    takeover_granted_to_client_id = null,
    takeover_granted_to_session_id = null,
    takeover_granted_at = null
  where
    public.profile_edit_locks.expires_at <= server_now
    or not private.is_profile_auth_user_owner(
      public.profile_edit_locks.profile_id,
      public.profile_edit_locks.holder_auth_user_id
    )
  returning
    profile_id,
    expires_at,
    row_version
  into
    acquired_profile_id,
    acquired_expires_at,
    acquired_row_version;

  -- INSERT o riciclo riuscito.
  if acquired_profile_id is not null then
    return jsonb_build_object(
      'status', 'acquired',
      'lock_token', generated_lock_token,
      'expires_at', acquired_expires_at,
      'row_version', acquired_row_version
    );
  end if;

  -- Il conflitto riguardava un lock ancora valido.
  select
    holder_auth_user_id,
    client_instance_id,
    holder_session_id
  into
    existing_holder_auth_user_id,
    existing_client_id,
    existing_session_id
  from public.profile_edit_locks
  where profile_id = target_profile_id;

  -- Stessa sessione già holder:
  -- nessun nuovo token e soprattutto nessun rinnovo del lease.
  if existing_holder_auth_user_id = current_auth_user_id
     and existing_client_id = target_client_id
     and existing_session_id = target_session_id
  then
    return jsonb_build_object('status', 'already_held');
  end if;

  -- Nessun dettaglio sull'altro holder viene esposto.
  return jsonb_build_object('status', 'busy');
end;
$$;

revoke all
  on function public.acquire_profile_edit_lock(uuid, uuid, uuid)
  from public;

grant execute
  on function public.acquire_profile_edit_lock(uuid, uuid, uuid)
  to authenticated;

-- ============================================================================
-- HEARTBEAT PROFILE EDIT LOCK
-- ============================================================================

create or replace function public.heartbeat_profile_edit_lock(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  renewed_expires_at timestamptz;
  renewed_row_version bigint;
begin
  -- Solo l'owner attivo può mantenere il profile edit lock.
  if auth.uid() is null
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Identificatori obbligatori.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  update public.profile_edit_locks pel
  set
    heartbeat_at = server_now,
    expires_at = server_now + interval '2 minutes',
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id
    and pel.holder_auth_user_id = auth.uid()
    and pel.client_instance_id = target_client_id
    and pel.holder_session_id = target_session_id
    and pel.lock_token_hash =
      private.profile_edit_lock_token_hash(lock_token)
    and pel.expires_at > server_now
  returning
    pel.expires_at,
    pel.row_version
  into
    renewed_expires_at,
    renewed_row_version;

  if renewed_expires_at is null then
    return jsonb_build_object('status', 'not_holder');
  end if;

  return jsonb_build_object(
    'status', 'renewed',
    'expires_at', renewed_expires_at,
    'row_version', renewed_row_version
  );
end;
$$;

revoke all
  on function public.heartbeat_profile_edit_lock(uuid, uuid, uuid, text)
  from public;

grant execute
  on function public.heartbeat_profile_edit_lock(uuid, uuid, uuid, text)
  to authenticated;

-- ============================================================================
-- RELEASE PROFILE EDIT LOCK
-- ============================================================================

create or replace function public.release_profile_edit_lock(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  deleted_profile_id uuid;
begin
  -- Solo l'owner attivo può rilasciare il profile edit lock.
  if auth.uid() is null
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Parametri mancanti o non validi non devono rivelare dettagli.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  delete from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
    and pel.holder_auth_user_id = auth.uid()
    and pel.client_instance_id = target_client_id
    and pel.holder_session_id = target_session_id
    and pel.lock_token_hash =
      private.profile_edit_lock_token_hash(lock_token)
    and pel.expires_at > server_now
  returning pel.profile_id
  into deleted_profile_id;

  if deleted_profile_id is null then
    return jsonb_build_object('status', 'not_holder');
  end if;

  return jsonb_build_object('status', 'released');
end;
$$;

revoke all
  on function public.release_profile_edit_lock(uuid, uuid, uuid, text)
  from public;

grant execute
  on function public.release_profile_edit_lock(uuid, uuid, uuid, text)
  to authenticated;

-- ============================================================================
-- REQUEST PROFILE EDIT TAKEOVER
-- ============================================================================

create or replace function public.request_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_expires_at timestamptz;

  current_takeover_requested_by_auth_user_id uuid;
  current_takeover_requested_by_client_id uuid;
  current_takeover_requested_by_session_id uuid;
  current_takeover_requested_at timestamptz;

  current_takeover_silenced_until timestamptz;
  current_takeover_granted_at timestamptz;
begin
  -- Solo l'owner attivo del profilo può richiedere un takeover.
  if current_auth_user_id is null
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Parametri minimi obbligatori.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or target_profile_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_client_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_session_id = '00000000-0000-0000-0000-000000000000'::uuid
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Serializza tutte le decisioni sulla riga del lock.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.expires_at,
    pel.takeover_requested_by_auth_user_id,
    pel.takeover_requested_by_client_id,
    pel.takeover_requested_by_session_id,
    pel.takeover_requested_at,
    pel.takeover_silenced_until,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_expires_at,
    current_takeover_requested_by_auth_user_id,
    current_takeover_requested_by_client_id,
    current_takeover_requested_by_session_id,
    current_takeover_requested_at,
    current_takeover_silenced_until,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  -- Nessun lock esistente oppure lock ormai scaduto:
  -- il client deve usare la normale acquisizione.
  if not found
     or current_expires_at <= server_now
  then
    return jsonb_build_object('status', 'available');
  end if;

  -- Il chiamante è già l'holder corrente: non ha senso chiedere takeover.
  if current_holder_auth_user_id = current_auth_user_id
     and current_client_id = target_client_id
     and current_session_id = target_session_id
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Un grant valido blocca nuove richieste takeover.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return jsonb_build_object('status', 'transfer_pending');
  end if;

  -- Un silenziamento valido blocca nuove richieste.
  if current_takeover_silenced_until is not null
     and current_takeover_silenced_until > server_now
  then
    return jsonb_build_object('status', 'silenced');
  end if;

  -- Una richiesta takeover ancora valida è già pendente.
  if current_takeover_requested_at is not null
     and current_takeover_requested_at + interval '10 minutes' > server_now
  then
    return jsonb_build_object('status', 'request_pending');
  end if;

  -- Crea o sostituisce una richiesta scaduta.
  update public.profile_edit_locks pel
  set
    takeover_requested_by_auth_user_id = current_auth_user_id,
    takeover_requested_by_client_id = target_client_id,
    takeover_requested_by_session_id = target_session_id,
    takeover_requested_at = server_now,
    takeover_granted_to_auth_user_id = null,
    takeover_granted_to_client_id = null,
    takeover_granted_to_session_id = null,
    takeover_granted_at = null,
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id;

  return jsonb_build_object('status', 'requested');
end;
$$;

revoke all
  on function public.request_profile_edit_takeover(uuid, uuid, uuid)
  from public;

grant execute
  on function public.request_profile_edit_takeover(uuid, uuid, uuid)
  to authenticated;

-- ============================================================================
-- CANCEL PROFILE EDIT TAKEOVER
-- ============================================================================

create or replace function public.cancel_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_takeover_requested_by_auth_user_id uuid;
  current_takeover_requested_by_client_id uuid;
  current_takeover_requested_by_session_id uuid;
  current_takeover_requested_at timestamptz;

  current_takeover_granted_at timestamptz;
  updated_profile_id uuid;
begin
  -- Solo l'owner attivo del profilo può cancellare la propria richiesta takeover.
  if current_auth_user_id is null
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or target_profile_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_client_id = '00000000-0000-0000-0000-000000000000'::uuid
     or target_session_id = '00000000-0000-0000-0000-000000000000'::uuid
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Serializza la decisione sulla riga del lock.
  select
    pel.takeover_requested_by_auth_user_id,
    pel.takeover_requested_by_client_id,
    pel.takeover_requested_by_session_id,
    pel.takeover_requested_at,
    pel.takeover_granted_at
  into
    current_takeover_requested_by_auth_user_id,
    current_takeover_requested_by_client_id,
    current_takeover_requested_by_session_id,
    current_takeover_requested_at,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  -- Se l'handoff è già iniziato, la richiesta non è più cancellabile.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return jsonb_build_object('status', 'transfer_pending');
  end if;

  -- Nessuna richiesta valida corrispondente alla sessione chiamante.
  if current_takeover_requested_at is null
     or current_takeover_requested_at + interval '10 minutes' <= server_now
     or current_takeover_requested_by_auth_user_id <> current_auth_user_id
     or current_takeover_requested_by_client_id <> target_client_id
     or current_takeover_requested_by_session_id <> target_session_id
  then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  update public.profile_edit_locks pel
  set
    takeover_requested_by_auth_user_id = null,
    takeover_requested_by_client_id = null,
    takeover_requested_by_session_id = null,
    takeover_requested_at = null,
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id
  returning pel.profile_id
  into updated_profile_id;

  if updated_profile_id is null then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  return jsonb_build_object('status', 'cancelled');
end;
$$;

revoke all
  on function public.cancel_profile_edit_takeover(uuid, uuid, uuid)
  from public;

grant execute
  on function public.cancel_profile_edit_takeover(uuid, uuid, uuid)
  to authenticated;

-- ============================================================================
-- REJECT PROFILE EDIT TAKEOVER
-- ============================================================================

create or replace function public.reject_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text,
  silence_minutes integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_lock_token_hash bytea;
  current_expires_at timestamptz;

  current_takeover_requested_at timestamptz;
  current_takeover_granted_at timestamptz;

  updated_profile_id uuid;
begin
  -- Solo l'owner attivo del profilo può rifiutare una richiesta takeover.
  if current_auth_user_id is null
   or not private.is_profile_auth_user_owner(
     target_profile_id,
     current_auth_user_id
   )
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Sono ammesse esclusivamente le durate deliberate dal protocollo.
  if silence_minutes is null
   or silence_minutes not in (5, 15, 30)
  then
    return jsonb_build_object('status', 'invalid_silence');
  end if;

  -- Parametri mancanti non devono rivelare dettagli sul lock.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Serializza la decisione sulla riga del lock.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.lock_token_hash,
    pel.expires_at,
    pel.takeover_requested_at,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_lock_token_hash,
    current_expires_at,
    current_takeover_requested_at,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Il reject può essere eseguito solamente dall'holder corrente,
  -- con sessione valida, token valido e lease non scaduto.
  if current_holder_auth_user_id <> current_auth_user_id
     or current_client_id <> target_client_id
     or current_session_id <> target_session_id
     or current_lock_token_hash <>
       private.profile_edit_lock_token_hash(lock_token)
     or current_expires_at <= server_now
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Se l'handoff è già iniziato, non è più possibile rifiutarlo.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return jsonb_build_object('status', 'transfer_pending');
  end if;

  -- Non esiste una richiesta takeover valida da rifiutare.
  if current_takeover_requested_at is null
     or current_takeover_requested_at + interval '10 minutes' <= server_now
  then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  update public.profile_edit_locks pel
  set
    takeover_requested_by_auth_user_id = null,
    takeover_requested_by_client_id = null,
    takeover_requested_by_session_id = null,
    takeover_requested_at = null,
    takeover_silenced_until =
      server_now + make_interval(mins => silence_minutes),
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id
  returning pel.profile_id
  into updated_profile_id;

  if updated_profile_id is null then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  return jsonb_build_object('status', 'rejected');
end;
$$;

revoke all
  on function public.reject_profile_edit_takeover(
    uuid,
    uuid,
    uuid,
    text,
    integer
  )
  from public;

grant execute
  on function public.reject_profile_edit_takeover(
    uuid,
    uuid,
    uuid,
    text,
    integer
  )
  to authenticated;

-- ============================================================================
-- GRANT PROFILE EDIT TAKEOVER
-- ============================================================================

create or replace function public.grant_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_lock_token_hash bytea;
  current_expires_at timestamptz;

  current_takeover_requested_by_auth_user_id uuid;
  current_takeover_requested_by_client_id uuid;
  current_takeover_requested_by_session_id uuid;
  current_takeover_requested_at timestamptz;

  current_takeover_granted_at timestamptz;

  updated_profile_id uuid;
begin
  -- Solo l'owner attivo del profilo può concedere il takeover.
  if current_auth_user_id is null
     or not private.is_profile_auth_user_owner(
       target_profile_id,
       current_auth_user_id
     )
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Parametri mancanti non devono rivelare dettagli sul lock.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Serializza la decisione sulla riga del lock.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.lock_token_hash,
    pel.expires_at,
    pel.takeover_requested_by_auth_user_id,
    pel.takeover_requested_by_client_id,
    pel.takeover_requested_by_session_id,
    pel.takeover_requested_at,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_lock_token_hash,
    current_expires_at,
    current_takeover_requested_by_auth_user_id,
    current_takeover_requested_by_client_id,
    current_takeover_requested_by_session_id,
    current_takeover_requested_at,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Il grant può essere creato solamente dall'holder corrente,
  -- con sessione valida, token valido e lease non scaduto.
  if current_holder_auth_user_id <> current_auth_user_id
     or current_client_id <> target_client_id
     or current_session_id <> target_session_id
     or current_lock_token_hash <>
       private.profile_edit_lock_token_hash(lock_token)
     or current_expires_at <= server_now
  then
    return jsonb_build_object('status', 'not_holder');
  end if;

  -- Un grant ancora valido non può essere sovrascritto o prolungato.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return jsonb_build_object('status', 'transfer_pending');
  end if;

  -- Deve esistere una richiesta takeover completa e ancora valida.
  if current_takeover_requested_by_auth_user_id is null
     or current_takeover_requested_by_client_id is null
     or current_takeover_requested_by_session_id is null
     or current_takeover_requested_at is null
     or current_takeover_requested_at + interval '10 minutes' <= server_now
  then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  -- Il destinatario del grant deriva esclusivamente dalla richiesta
  -- pendente già registrata: il client non può sceglierlo.
  update public.profile_edit_locks pel
  set
    takeover_granted_to_auth_user_id =
      current_takeover_requested_by_auth_user_id,
    takeover_granted_to_client_id =
      current_takeover_requested_by_client_id,
    takeover_granted_to_session_id =
      current_takeover_requested_by_session_id,
    takeover_granted_at = server_now,
    takeover_requested_by_auth_user_id = null,
    takeover_requested_by_client_id = null,
    takeover_requested_by_session_id = null,
    takeover_requested_at = null,
    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id
  returning pel.profile_id
  into updated_profile_id;

  if updated_profile_id is null then
    return jsonb_build_object('status', 'no_pending_request');
  end if;

  return jsonb_build_object('status', 'granted');
end;
$$;

revoke all
  on function public.grant_profile_edit_takeover(
    uuid,
    uuid,
    uuid,
    text
  )
  from public;

grant execute
  on function public.grant_profile_edit_takeover(
    uuid,
    uuid,
    uuid,
    text
  )
  to authenticated;

-- ============================================================================
-- COMPLETE PROFILE EDIT TAKEOVER
-- ============================================================================

create or replace function public.complete_profile_edit_takeover(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_takeover_granted_to_auth_user_id uuid;
  current_takeover_granted_to_client_id uuid;
  current_takeover_granted_to_session_id uuid;
  current_takeover_granted_at timestamptz;

  generated_lock_token text;
  completed_expires_at timestamptz;
  completed_row_version bigint;
begin
  -- Richiede un owner attivo autenticato.
  if current_auth_user_id is null
     or not private.is_profile_auth_user_owner(
       target_profile_id,
       current_auth_user_id
     )
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Parametri mancanti non possono identificare il destinatario del grant.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
  then
    return jsonb_build_object('status', 'not_grantee');
  end if;

  -- Serializza il completamento sulla riga del lock.
  select
    pel.takeover_granted_to_auth_user_id,
    pel.takeover_granted_to_client_id,
    pel.takeover_granted_to_session_id,
    pel.takeover_granted_at
  into
    current_takeover_granted_to_auth_user_id,
    current_takeover_granted_to_client_id,
    current_takeover_granted_to_session_id,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'no_grant');
  end if;

  -- Deve esistere un grant completo.
  if current_takeover_granted_to_auth_user_id is null
     or current_takeover_granted_to_client_id is null
     or current_takeover_granted_to_session_id is null
     or current_takeover_granted_at is null
  then
    return jsonb_build_object('status', 'no_grant');
  end if;

  -- Un grant è utilizzabile esclusivamente entro 60 secondi.
  if current_takeover_granted_at + interval '60 seconds' <= server_now
  then
    return jsonb_build_object('status', 'grant_expired');
  end if;

  -- Solo l'esatto destinatario del grant può completare il takeover.
  if current_takeover_granted_to_auth_user_id <> current_auth_user_id
     or current_takeover_granted_to_client_id <> target_client_id
     or current_takeover_granted_to_session_id <> target_session_id
  then
    return jsonb_build_object('status', 'not_grantee');
  end if;

  -- Il nuovo holder riceve un token completamente nuovo, generato server-side.
  generated_lock_token :=
    encode(extensions.gen_random_bytes(32), 'hex');

  -- Trasferisce atomicamente il lock e azzera tutto lo stato takeover.
  update public.profile_edit_locks pel
  set
    holder_auth_user_id =
      current_takeover_granted_to_auth_user_id,
    client_instance_id =
      current_takeover_granted_to_client_id,
    holder_session_id =
      current_takeover_granted_to_session_id,

    acquired_at = server_now,
    heartbeat_at = server_now,
    expires_at = server_now + interval '2 minutes',

    lock_token_hash =
      private.profile_edit_lock_token_hash(generated_lock_token),

    takeover_requested_by_auth_user_id = null,
    takeover_requested_by_client_id = null,
    takeover_requested_by_session_id = null,
    takeover_requested_at = null,

    takeover_granted_to_auth_user_id = null,
    takeover_granted_to_client_id = null,
    takeover_granted_to_session_id = null,
    takeover_granted_at = null,

    takeover_silenced_until = null,

    row_version = pel.row_version + 1
  where pel.profile_id = target_profile_id
  returning
    pel.expires_at,
    pel.row_version
  into
    completed_expires_at,
    completed_row_version;

  if completed_row_version is null then
    return jsonb_build_object('status', 'no_grant');
  end if;

  return jsonb_build_object(
    'status', 'completed',
    'lock_token', generated_lock_token,
    'expires_at', completed_expires_at,
    'row_version', completed_row_version
  );
end;
$$;

revoke all
  on function public.complete_profile_edit_takeover(
    uuid,
    uuid,
    uuid
  )
  from public;

grant execute
  on function public.complete_profile_edit_takeover(
    uuid,
    uuid,
    uuid
  )
  to authenticated;

-- ============================================================================
-- GET PROFILE EDIT LOCK STATE
-- ============================================================================

create or replace function public.get_profile_edit_lock_state(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  server_now timestamptz := now();
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_expires_at timestamptz;
  current_row_version bigint;

  current_takeover_requested_by_auth_user_id uuid;
  current_takeover_requested_by_client_id uuid;
  current_takeover_requested_by_session_id uuid;
  current_takeover_requested_at timestamptz;

  current_takeover_silenced_until timestamptz;

  current_takeover_granted_to_auth_user_id uuid;
  current_takeover_granted_to_client_id uuid;
  current_takeover_granted_to_session_id uuid;
  current_takeover_granted_at timestamptz;

  remaining_seconds bigint;
begin
  -- Parametri obbligatori.
  if target_profile_id is null
     or target_client_id is null
     or target_session_id is null
  then
    return jsonb_build_object(
      'status', 'invalid_request',
      'row_version', null
    );
  end if;

  -- Solo un membro attivo autenticato del profilo può leggerne lo stato.
  if current_auth_user_id is null
     or not private.is_profile_member(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden',
      'row_version', null
    );
  end if;

  -- Una singola fotografia coerente della riga.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.expires_at,
    pel.row_version,

    pel.takeover_requested_by_auth_user_id,
    pel.takeover_requested_by_client_id,
    pel.takeover_requested_by_session_id,
    pel.takeover_requested_at,

    pel.takeover_silenced_until,

    pel.takeover_granted_to_auth_user_id,
    pel.takeover_granted_to_client_id,
    pel.takeover_granted_to_session_id,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_expires_at,
    current_row_version,

    current_takeover_requested_by_auth_user_id,
    current_takeover_requested_by_client_id,
    current_takeover_requested_by_session_id,
    current_takeover_requested_at,

    current_takeover_silenced_until,

    current_takeover_granted_to_auth_user_id,
    current_takeover_granted_to_client_id,
    current_takeover_granted_to_session_id,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id;

  -- Nessun lock presente.
  if not found then
    return jsonb_build_object(
      'status', 'available',
      'row_version', null
    );
  end if;

  -- Lock scaduto o holder non più autorizzato:
  -- per il client il profilo è disponibile.
  if current_expires_at <= server_now
     or not private.is_profile_auth_user_owner(
       target_profile_id,
       current_holder_auth_user_id
     )
  then
    return jsonb_build_object(
      'status', 'available',
      'row_version', current_row_version
    );
  end if;

  -- La sessione corrente è il vero holder.
  if current_holder_auth_user_id = current_auth_user_id
     and current_client_id = target_client_id
     and current_session_id = target_session_id
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(epoch from (current_expires_at - server_now))
        )::bigint
      );

    return jsonb_build_object(
      'status', 'held_by_me',
      'expires_in_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Grant valido destinato esattamente alla sessione corrente.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
     and current_takeover_granted_to_auth_user_id = current_auth_user_id
     and current_takeover_granted_to_client_id = target_client_id
     and current_takeover_granted_to_session_id = target_session_id
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(
            epoch from (
              current_takeover_granted_at
              + interval '60 seconds'
              - server_now
            )
          )
        )::bigint
      );

    return jsonb_build_object(
      'status', 'transfer_granted_to_me',
      'expires_in_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Richiesta takeover valida appartenente alla sessione corrente.
  if current_takeover_requested_at is not null
     and current_takeover_requested_at + interval '10 minutes' > server_now
     and current_takeover_requested_by_auth_user_id = current_auth_user_id
     and current_takeover_requested_by_client_id = target_client_id
     and current_takeover_requested_by_session_id = target_session_id
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(
            epoch from (
              current_takeover_requested_at
              + interval '10 minutes'
              - server_now
            )
          )
        )::bigint
      );

    return jsonb_build_object(
      'status', 'takeover_requested_by_me',
      'expires_in_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Silenziamento ancora attivo.
  if current_takeover_silenced_until is not null
     and current_takeover_silenced_until > server_now
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(
            epoch from (
              current_takeover_silenced_until - server_now
            )
          )
        )::bigint
      );

    return jsonb_build_object(
      'status', 'silenced',
      'retry_after_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Esiste un grant valido, ma destinato a un'altra sessione.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(
            epoch from (
              current_takeover_granted_at
              + interval '60 seconds'
              - server_now
            )
          )
        )::bigint
      );

    return jsonb_build_object(
      'status', 'transfer_pending',
      'expires_in_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Esiste una richiesta valida, ma appartiene a un'altra sessione.
  if current_takeover_requested_at is not null
     and current_takeover_requested_at + interval '10 minutes' > server_now
  then
    remaining_seconds :=
      greatest(
        0,
        ceil(
          extract(
            epoch from (
              current_takeover_requested_at
              + interval '10 minutes'
              - server_now
            )
          )
        )::bigint
      );

    return jsonb_build_object(
      'status', 'takeover_pending',
      'expires_in_seconds', remaining_seconds,
      'row_version', current_row_version
    );
  end if;

  -- Lock valido detenuto da un'altra sessione,
  -- senza stati takeover più specifici.
  return jsonb_build_object(
    'status', 'busy',
    'row_version', current_row_version
  );
end;
$$;

revoke all
  on function public.get_profile_edit_lock_state(
    uuid,
    uuid,
    uuid
  )
  from public;

grant execute
  on function public.get_profile_edit_lock_state(
    uuid,
    uuid,
    uuid
  )
  to authenticated;
