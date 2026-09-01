-- ============================================================================
-- ABILITAZIONE E DISABILITAZIONE AUTORITATIVA AIUOLA
-- ============================================================================
-- Sessione S024.
-- Modifica soltanto is_active.
-- Identità, numero, dati descrittivi e geometrie restano invariati.

create or replace function public.set_bed_active(
  target_profile_id uuid,
  target_bed_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  bed_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_garden_id uuid;
  v_current_is_active boolean;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_row_version bigint;
  v_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_bed_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 2. PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3. LETTURA AIUOLA E VERIFICA OWNERSHIP
  -- --------------------------------------------------------------------------

  select
    b.garden_id,
    b.is_active,
    b.row_version,
    b.updated_at
  into
    v_garden_id,
    v_current_is_active,
    v_current_row_version,
    v_current_updated_at
  from public.beds b
  join public.gardens g
    on g.id = b.garden_id
  where b.id = target_bed_id
    and g.profile_id = target_profile_id
  for update of b;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock dell'aiuola.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 4. CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'bed_id', target_bed_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5. VALIDAZIONE DELLO STATO RICHIESTO
  -- --------------------------------------------------------------------------

  if bed_is_active is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 6. CONTROLLO STATO INVARIATO
  -- --------------------------------------------------------------------------

  if v_current_is_active = bed_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'is_active', v_current_is_active,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. AGGIORNAMENTO DELLO STATO
  -- --------------------------------------------------------------------------
  -- Il trigger metadata incrementa la versione una sola volta.
  -- Nessuna modifica alle geometrie o agli altri dati dell'aiuola.

  update public.beds
  set is_active = bed_is_active
  where id = target_bed_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_row_version,
    v_updated_at;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'bed_id', target_bed_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'bed_id', target_bed_id,
    'garden_id', v_garden_id,
    'is_active', bed_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 9. PRIVILEGI SET_BED_ACTIVE
-- ============================================================================

revoke all
  on function public.set_bed_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  from public, anon, authenticated;

grant execute
  on function public.set_bed_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  to authenticated;
