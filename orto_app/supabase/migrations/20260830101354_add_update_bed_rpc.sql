-- ============================================================================
-- UPDATE BED AUTORITATIVO
-- ============================================================================
-- Sessione S024.
-- Modifica numero, nome e note dell'aiuola.
-- Identità, Garden, stato di abilitazione e geometrie restano invariati.

create or replace function public.update_bed(
  target_profile_id uuid,
  target_bed_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  bed_number integer,
  bed_name text,
  bed_notes text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_name text;
  v_notes text;

  v_garden_id uuid;
  v_current_number integer;
  v_current_name text;
  v_current_notes text;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
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
    b.number,
    b.name,
    b.notes,
    b.row_version,
    b.updated_at
  into
    v_garden_id,
    v_current_number,
    v_current_name,
    v_current_notes,
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

  -- Il lock sull'aiuola potrebbe aver richiesto un'attesa.
  -- Rivalida il lease prima di proseguire.

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
  -- 5. NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    nullif(
      regexp_replace(
        btrim(bed_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_notes :=
    nullif(btrim(bed_notes), '');

  -- --------------------------------------------------------------------------
  -- 6. VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if bed_number is null
     or bed_number <= 0
     or (
       v_name is not null
       and char_length(v_name) > 80
     )
     or (
       v_notes is not null
       and char_length(v_notes) > 1000
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current_number = bed_number
     and v_current_name is not distinct from v_name
     and v_current_notes is not distinct from v_notes
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 8. AGGIORNAMENTO AIUOLA
  -- --------------------------------------------------------------------------
  -- Il trigger metadata incrementa la versione una sola volta.
  -- Nessuna modifica a Garden, stato di abilitazione o geometrie.

  begin
    update public.beds
    set
      number = bed_number,
      name = v_name,
      notes = v_notes
    where id = target_bed_id
      and row_version = expected_row_version
    returning
      row_version,
      updated_at
    into
      v_row_version,
      v_updated_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'beds_garden_number_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_number'
        );
      end if;

      raise;
  end;

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
  -- 9. RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'bed_id', target_bed_id,
    'garden_id', v_garden_id,
    'number', bed_number,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 10. PRIVILEGI UPDATE_BED
-- ============================================================================

revoke all
  on function public.update_bed(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    text,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_bed(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    text,
    text
  )
  to authenticated;
