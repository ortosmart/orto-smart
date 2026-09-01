-- ============================================================================
-- RETTIFICA AUTORITATIVA DELLA GEOMETRIA DELL'AIUOLA
-- ============================================================================
-- Sessione S024.
-- Riservata all'owner con Profile Write Authority valida.
-- Rettifica dimensioni e data iniziale della geometria identificata.
-- Preserva la fine dell'intervallo e adegua, quando necessario,
-- la fine della geometria precedente.
-- Registra motivazione e snapshot server-side prima/dopo.

create or replace function public.correct_bed_geometry(
  target_profile_id uuid,
  target_bed_id uuid,
  target_geometry_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  geometry_width_cm integer,
  geometry_length_cm integer,
  geometry_valid_from date,
  correction_reason text
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
  v_garden_timezone text;
  v_today date;
  v_reason text;

  v_current_bed_row_version bigint;
  v_current_bed_updated_at timestamptz;

  v_target_geometry public.bed_geometries%rowtype;
  v_previous_geometry public.bed_geometries%rowtype;
  v_has_previous boolean := false;
  v_adjust_previous boolean := false;

  v_before_state jsonb;
  v_after_state jsonb;

  v_geometry_row_version bigint;
  v_geometry_updated_at timestamptz;
  v_previous_row_version bigint;
  v_previous_updated_at timestamptz;

  v_bed_row_version bigint;
  v_bed_updated_at timestamptz;

  v_correction_id uuid;
  v_correction_created_at timestamptz;

  v_result jsonb;
begin

  -- --------------------------------------------------------------------------
  -- 1. IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_bed_id is null
     or target_geometry_id is null
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
    g.timezone,
    b.row_version,
    b.updated_at
  into
    v_garden_id,
    v_garden_timezone,
    v_current_bed_row_version,
    v_current_bed_updated_at
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
  -- 4. CONTROLLO OTTIMISTICO DELLA VERSIONE DELL'AIUOLA
  -- --------------------------------------------------------------------------

  if v_current_bed_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'bed_id', target_bed_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5. LETTURA DELLA GEOMETRIA DA RETTIFICARE
  -- --------------------------------------------------------------------------

  select bg.*
  into v_target_geometry
  from public.bed_geometries bg
  where bg.id = target_geometry_id
    and bg.bed_id = target_bed_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della geometria.

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
  -- 6. VALIDAZIONE DEI DATI DI RETTIFICA
  -- --------------------------------------------------------------------------

  v_reason :=
    nullif(btrim(correction_reason), '');

  v_today :=
    (clock_timestamp() at time zone v_garden_timezone)::date;

  if geometry_width_cm is null
     or geometry_width_cm <= 0
     or geometry_length_cm is null
     or geometry_length_cm <= 0
     or geometry_valid_from is null
     or not isfinite(geometry_valid_from)
     or geometry_valid_from > v_today
     or v_reason is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- La fine della geometria target resta invariata.
  -- La nuova data iniziale non deve svuotare o invertire l'intervallo.

  if v_target_geometry.valid_to is not null
     and geometry_valid_from >= v_target_geometry.valid_to
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7. GEOMETRIA PRECEDENTE E COERENZA TEMPORALE
  -- --------------------------------------------------------------------------

  select bg.*
  into v_previous_geometry
  from public.bed_geometries bg
  where bg.bed_id = target_bed_id
    and bg.valid_from < v_target_geometry.valid_from
  order by bg.valid_from desc
  limit 1
  for update;

  v_has_previous := found;

  -- Rivalida il lease dopo l'eventuale attesa sul lock precedente.

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

  if v_has_previous
  then
    -- Una storia discontinua non viene riparata implicitamente.
    if v_previous_geometry.valid_to
       is distinct from v_target_geometry.valid_from
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;

    -- Il nuovo confine deve lasciare non vuoto l'intervallo precedente.
    if geometry_valid_from <= v_previous_geometry.valid_from
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  v_adjust_previous :=
    v_has_previous
    and geometry_valid_from <> v_target_geometry.valid_from;

  -- --------------------------------------------------------------------------
  -- 8. CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_target_geometry.width_cm = geometry_width_cm
     and v_target_geometry.length_cm = geometry_length_cm
     and v_target_geometry.valid_from = geometry_valid_from
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'bed_id', target_bed_id,
      'garden_id', v_garden_id,
      'row_version', v_current_bed_row_version,
      'updated_at', v_current_bed_updated_at,
      'geometry_id', v_target_geometry.id,
      'geometry_row_version', v_target_geometry.row_version,
      'geometry_updated_at', v_target_geometry.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9. SNAPSHOT SERVER-SIDE PRIMA DELLA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Include soltanto le geometrie che saranno effettivamente modificate.
  -- Ordine cronologico: precedente, quando coinvolta, poi target.

  if v_adjust_previous
  then
    v_before_state := jsonb_build_array(
      to_jsonb(v_previous_geometry),
      to_jsonb(v_target_geometry)
    );
  else
    v_before_state := jsonb_build_array(
      to_jsonb(v_target_geometry)
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 10. RETTIFICA DELLE GEOMETRIE COINVOLTE
  -- --------------------------------------------------------------------------

  if v_adjust_previous
  then
    set constraints public.bed_geometries_no_overlap deferred;

    update public.bed_geometries
    set valid_to = geometry_valid_from
    where id = v_previous_geometry.id
      and bed_id = target_bed_id
      and row_version = v_previous_geometry.row_version
    returning
      row_version,
      updated_at
    into
      v_previous_row_version,
      v_previous_updated_at;

    if not found
    then
      raise exception
        'Concurrent modification while correcting previous bed geometry';
    end if;
  end if;

  update public.bed_geometries
  set
    width_cm = geometry_width_cm,
    length_cm = geometry_length_cm,
    valid_from = geometry_valid_from
  where id = v_target_geometry.id
    and bed_id = target_bed_id
    and row_version = v_target_geometry.row_version
  returning
    row_version,
    updated_at
  into
    v_geometry_row_version,
    v_geometry_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while correcting target bed geometry';
  end if;

  if v_adjust_previous
  then
    -- Verifica ora il risultato finale, prima di registrare la rettifica.
    set constraints public.bed_geometries_no_overlap immediate;
  end if;

  -- --------------------------------------------------------------------------
  -- 11. INCREMENTO DELLA VERSIONE AGGREGATA DELL'AIUOLA
  -- --------------------------------------------------------------------------

  update public.beds
  set row_version = row_version
  where id = target_bed_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_bed_row_version,
    v_bed_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while updating corrected bed version';
  end if;

  -- --------------------------------------------------------------------------
  -- 12. SNAPSHOT SERVER-SIDE DOPO LA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Rilegge le righe aggiornate, inclusi i metadati prodotti dai trigger.

  if v_adjust_previous
  then
    select jsonb_build_array(
      to_jsonb(previous_geometry),
      to_jsonb(target_geometry)
    )
    into v_after_state
    from public.bed_geometries previous_geometry
    cross join public.bed_geometries target_geometry
    where previous_geometry.id = v_previous_geometry.id
      and previous_geometry.bed_id = target_bed_id
      and target_geometry.id = v_target_geometry.id
      and target_geometry.bed_id = target_bed_id;
  else
    select jsonb_build_array(
      to_jsonb(target_geometry)
    )
    into v_after_state
    from public.bed_geometries target_geometry
    where target_geometry.id = v_target_geometry.id
      and target_geometry.bed_id = target_bed_id;
  end if;

  if v_after_state is null
  then
    raise exception
      'Missing geometry snapshot after bed correction';
  end if;

  -- --------------------------------------------------------------------------
  -- 13. REGISTRAZIONE ATOMICA DELLA RETTIFICA
  -- --------------------------------------------------------------------------
  -- Un solo record per operazione, anche quando coinvolge due geometrie.
  -- Autore, snapshot, versioni e timestamp sono determinati server-side.

  insert into public.bed_geometry_corrections (
    bed_id,
    actor_auth_user_id,
    reason,
    before_state,
    after_state,
    bed_version_before,
    bed_version_after
  )
  values (
    target_bed_id,
    v_auth_user_id,
    v_reason,
    v_before_state,
    v_after_state,
    v_current_bed_row_version,
    v_bed_row_version
  )
  returning
    id,
    created_at
  into
    v_correction_id,
    v_correction_created_at;

  -- --------------------------------------------------------------------------
  -- 14. RISULTATO
  -- --------------------------------------------------------------------------

  v_result := jsonb_build_object(
    'status', 'corrected',
    'bed_id', target_bed_id,
    'garden_id', v_garden_id,
    'row_version', v_bed_row_version,
    'updated_at', v_bed_updated_at,

    'geometry_id', v_target_geometry.id,
    'width_cm', geometry_width_cm,
    'length_cm', geometry_length_cm,
    'valid_from', geometry_valid_from,
    'valid_to', v_target_geometry.valid_to,
    'geometry_row_version', v_geometry_row_version,
    'geometry_updated_at', v_geometry_updated_at,

    'correction_id', v_correction_id,
    'correction_created_at', v_correction_created_at
  );

  if v_adjust_previous
  then
    v_result := v_result || jsonb_build_object(
      'previous_geometry_id', v_previous_geometry.id,
      'previous_geometry_valid_to', geometry_valid_from,
      'previous_geometry_row_version', v_previous_row_version,
      'previous_geometry_updated_at', v_previous_updated_at
    );
  end if;

  return v_result;
end;
$$;

-- ============================================================================
-- 15. PRIVILEGI CORRECT_BED_GEOMETRY
-- ============================================================================

revoke all
  on function public.correct_bed_geometry(
    uuid,
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.correct_bed_geometry(
    uuid,
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    integer,
    date,
    text
  )
  to authenticated;
