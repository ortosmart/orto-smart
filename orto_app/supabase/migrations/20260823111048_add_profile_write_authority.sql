-- ============================================================================
-- PROFILE WRITE AUTHORITY
-- ============================================================================
-- Helper privato autoritativo per il Write Path delle entità di Categoria A.
-- Serializza il profile edit lock e verifica fail-closed il diritto di scrittura
-- nella stessa transazione della futura RPC di dominio.

create or replace function private.lock_profile_write_authority(
  target_profile_id uuid,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns boolean
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  current_auth_user_id uuid := auth.uid();

  current_holder_auth_user_id uuid;
  current_client_id uuid;
  current_session_id uuid;
  current_lock_token_hash bytea;
  current_expires_at timestamptz;
  current_takeover_granted_at timestamptz;

  server_now timestamptz;
begin
  -- Fail-closed per richieste non autenticate o parametri mancanti.
  if current_auth_user_id is null
     or target_profile_id is null
     or target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return false;
  end if;

  -- Serializza l'autorità di scrittura sul lock tecnico del Profile.
  select
    pel.holder_auth_user_id,
    pel.client_instance_id,
    pel.holder_session_id,
    pel.lock_token_hash,
    pel.expires_at,
    pel.takeover_granted_at
  into
    current_holder_auth_user_id,
    current_client_id,
    current_session_id,
    current_lock_token_hash,
    current_expires_at,
    current_takeover_granted_at
  from public.profile_edit_locks pel
  where pel.profile_id = target_profile_id
  for update;

  if not found then
    return false;
  end if;

  -- Il tempo deve essere acquisito dopo l'eventuale attesa sul row lock.
  server_now := clock_timestamp();

  -- L'utente autenticato deve essere ancora owner attivo del Profile.
  if not private.is_profile_auth_user_owner(
    target_profile_id,
    current_auth_user_id
  )
  then
    return false;
  end if;

  -- Rivalida integralmente il possesso del lock e il lease.
  if current_holder_auth_user_id <> current_auth_user_id
     or current_client_id <> target_client_id
     or current_session_id <> target_session_id
     or current_lock_token_hash <>
       private.profile_edit_lock_token_hash(lock_token)
     or current_expires_at <= server_now
  then
    return false;
  end if;

  -- Durante un grant takeover ancora valido il vecchio holder
  -- non possiede più autorità per nuove scritture Categoria A.
  if current_takeover_granted_at is not null
     and current_takeover_granted_at + interval '60 seconds' > server_now
  then
    return false;
  end if;

  return true;
end;
$$;

revoke all
  on function private.lock_profile_write_authority(
    uuid, uuid, uuid, text
  )
  from public;
