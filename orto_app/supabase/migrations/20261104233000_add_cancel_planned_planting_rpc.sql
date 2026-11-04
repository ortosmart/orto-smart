-- S039 - Annullamento autoritativo di un lotto pianificato.
--
-- Transizioni consentite:
--   draft     -> cancelled
--   confirmed -> cancelled
--
-- Gli stati executed e cancelled non possono essere annullati.
-- Il record viene conservato per tracciabilita'.

create or replace function public.cancel_planned_planting(
  target_profile_id uuid,
  target_planned_planting_id uuid,
  expected_row_version bigint,
  target_client_id uuid,
  target_session_id uuid,
  lock_token text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_lot public.planned_plantings%rowtype;
  v_initial_garden_id uuid;
  v_initial_season_id uuid;
  v_initial_bed_id uuid;
  v_new_version bigint;
begin
  -- 1. Identita' e autorizzazione.
  if auth.uid() is null
     or target_profile_id is null
     or target_planned_planting_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- 2. Write Authority iniziale.
  if target_client_id is null
     or target_session_id is null
     or lock_token is null
     or not private.lock_profile_write_authority(
       target_profile_id,
       target_client_id,
       target_session_id,
       lock_token
     )
  then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 3. Lettura preliminare del lotto.
  select *
    into v_lot
  from public.planned_plantings
  where id = target_planned_planting_id
    and profile_id = target_profile_id;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  v_initial_garden_id := v_lot.garden_id;
  v_initial_season_id := v_lot.season_id;
  v_initial_bed_id := v_lot.bed_id;

  if v_lot.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  -- 4. Lock dell'orto.
  perform 1
  from public.gardens g
  where g.id = v_initial_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 5. Lock della stagione.
  perform 1
  from public.seasons s
  where s.id = v_initial_season_id
    and s.garden_id = v_initial_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 6. Lock dell'aiuola.
  perform 1
  from public.beds b
  where b.id = v_initial_bed_id
    and b.garden_id = v_initial_garden_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 7. Lock autoritativo del lotto.
  select *
    into v_lot
  from public.planned_plantings
  where id = target_planned_planting_id
    and profile_id = target_profile_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 8. Rivalidazione dell'identita' del lotto.
  if v_lot.garden_id is distinct from v_initial_garden_id
     or v_lot.season_id is distinct from v_initial_season_id
     or v_lot.bed_id is distinct from v_initial_bed_id
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  if v_lot.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'current_row_version', v_lot.row_version
    );
  end if;

  -- 9. Controllo del lifecycle.
  if v_lot.status not in ('draft', 'confirmed') then
    return jsonb_build_object('status', 'blocked_by_lifecycle');
  end if;

  -- 10. Ultima verifica della Write Authority.
  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  ) then
    return jsonb_build_object('status', 'write_forbidden');
  end if;

  -- 11. Annullamento atomico con controllo ottimistico.
  update public.planned_plantings
  set status = 'cancelled',
      updated_at = now(),
      row_version = row_version + 1
  where id = target_planned_planting_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
    and status in ('draft', 'confirmed')
  returning row_version into v_new_version;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'cancelled',
    'planned_planting_id', target_planned_planting_id,
    'row_version', v_new_version
  );
end;
$function$;

revoke all on function public.cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text
) from public, anon;

grant execute on function public.cancel_planned_planting(
  uuid, uuid, bigint, uuid, uuid, text
) to authenticated;