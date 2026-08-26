-- ============================================================================
-- Orto Smart - Write Path autoritativo per seasons
-- Sessione S023
-- ============================================================================

-- ============================================================================
-- 1. HARDENING DEI DATI
-- ============================================================================

alter table public.seasons
  add constraint seasons_year_range_check
    check (year between 1900 and 9999),

  add constraint seasons_name_length_check
    check (char_length(name) <= 80),

  add constraint seasons_notes_length_check
    check (notes is null or char_length(notes) <= 1000);

-- ============================================================================
-- 2. BLOCCO DELLE SCRITTURE DIRETTE
-- ============================================================================
-- Le letture dirette restano consentite ai membri attivi tramite RLS.
-- Le scritture applicative devono invece passare esclusivamente
-- attraverso le RPC autoritative dedicate alle Season.

drop policy if exists seasons_insert_for_owner
  on public.seasons;

drop policy if exists seasons_update_for_owner
  on public.seasons;

revoke insert, update, delete
  on table public.seasons
  from authenticated;

grant select
  on table public.seasons
  to authenticated;

-- ============================================================================
-- 3. CREATE SEASON
-- ============================================================================
-- Crea una Season tramite il Write Path autoritativo.
-- La nuova Season nasce sempre con is_active = false.
-- L'attivazione è riservata alla RPC activate_season.

create or replace function public.create_season(
  target_profile_id uuid,
  target_garden_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  season_year integer,
  season_name text,
  season_start_date date,
  season_end_date date,
  season_notes text
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

  v_season_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 3.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_garden_id is null
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

  -- --------------------------------------------------------------------------
  -- 3.2 PROFILE WRITE AUTHORITY
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
  -- 3.3 GARDEN AUTORIZZATO
  -- --------------------------------------------------------------------------
  -- Il Garden viene individuato server-side e bloccato per serializzare
  -- le operazioni concorrenti sulle relative Season.

  perform 1
  from public.gardens g
  where g.id = target_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.4 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(season_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_notes :=
    nullif(btrim(season_notes), '');

  -- --------------------------------------------------------------------------
  -- 3.5 VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if season_year is null
     or season_year < 1900
     or season_year > 9999
     or v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or season_start_date is null
     or (
       season_end_date is not null
       and season_end_date < season_start_date
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
  -- 3.6 CREAZIONE SEASON
  -- --------------------------------------------------------------------------

  begin
    insert into public.seasons (
      garden_id,
      year,
      name,
      start_date,
      end_date,
      is_active,
      notes
    )
    values (
      target_garden_id,
      season_year,
      v_name,
      season_start_date,
      season_end_date,
      false,
      v_notes
    )
    returning
      id,
      row_version,
      created_at
    into
      v_season_id,
      v_row_version,
      v_created_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'seasons_garden_year_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_year'
        );
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'season_id', v_season_id,
    'garden_id', target_garden_id,
    'year', season_year,
    'is_active', false,
    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$$;

revoke all
  on function public.create_season(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    integer,
    text,
    date,
    date,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.create_season(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    integer,
    text,
    date,
    date,
    text
  )
  to authenticated;

-- ============================================================================
-- 4. UPDATE SEASON
-- ============================================================================
-- Aggiorna i dati descrittivi e temporali di una Season.
-- garden_id è immutabile.
-- is_active può essere modificato soltanto tramite activate_season.

create or replace function public.update_season(
  target_profile_id uuid,
  target_season_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  season_year integer,
  season_name text,
  season_start_date date,
  season_end_date date,
  season_notes text
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
  v_current_year integer;
  v_current_name text;
  v_current_start_date date;
  v_current_end_date date;
  v_current_notes text;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 4.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_season_id is null
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
  -- 4.2 PROFILE WRITE AUTHORITY
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
  -- 4.3 LETTURA SEASON E VERIFICA OWNERSHIP
  -- --------------------------------------------------------------------------

  select
    s.garden_id,
    s.year,
    s.name,
    s.start_date,
    s.end_date,
    s.notes,
    s.row_version,
    s.updated_at
  into
    v_garden_id,
    v_current_year,
    v_current_name,
    v_current_start_date,
    v_current_end_date,
    v_current_notes,
    v_current_row_version,
    v_current_updated_at
  from public.seasons s
  join public.gardens g
    on g.id = s.garden_id
  where s.id = target_season_id
    and g.profile_id = target_profile_id
  for update of s;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 4.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'season_id', target_season_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 4.5 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(season_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_notes :=
    nullif(btrim(season_notes), '');

  -- --------------------------------------------------------------------------
  -- 4.6 VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if season_year is null
     or season_year < 1900
     or season_year > 9999
     or v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or season_start_date is null
     or (
       season_end_date is not null
       and season_end_date < season_start_date
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
  -- 4.7 CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current_year = season_year
     and v_current_name = v_name
     and v_current_start_date = season_start_date
     and v_current_end_date is not distinct from season_end_date
     and v_current_notes is not distinct from v_notes
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'season_id', target_season_id,
      'garden_id', v_garden_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 4.8 AGGIORNAMENTO SEASON
  -- --------------------------------------------------------------------------
  -- Il trigger metadata della baseline aggiorna updated_at e incrementa
  -- row_version. La condizione sulla versione mantiene il controllo fail-closed.

  begin
    update public.seasons
    set
      year = season_year,
      name = v_name,
      start_date = season_start_date,
      end_date = season_end_date,
      notes = v_notes
    where id = target_season_id
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

      if v_constraint_name = 'seasons_garden_year_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_year'
        );
      end if;

      raise;
  end;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'season_id', target_season_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'season_id', target_season_id,
    'garden_id', v_garden_id,
    'year', season_year,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

revoke all
  on function public.update_season(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    text,
    date,
    date,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_season(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    integer,
    text,
    date,
    date,
    text
  )
  to authenticated;

-- ============================================================================
-- 5. ACTIVATE SEASON
-- ============================================================================
-- Attiva una Season e disattiva atomicamente l'eventuale Season già attiva
-- nello stesso Garden. Non è mai visibile uno stato intermedio.

create or replace function public.activate_season(
  target_profile_id uuid,
  target_season_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text
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
  v_target_is_active boolean;
  v_target_row_version bigint;
  v_target_updated_at timestamptz;

  v_previous_season_id uuid;
  v_previous_row_version bigint;
  v_previous_updated_at timestamptz;

  v_activated_row_version bigint;
  v_activated_updated_at timestamptz;

  v_result jsonb;
begin

  -- --------------------------------------------------------------------------
  -- 5.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_season_id is null
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
  -- 5.2 PROFILE WRITE AUTHORITY
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
  -- 5.3 INDIVIDUAZIONE E BLOCCO DEL GARDEN
  -- --------------------------------------------------------------------------

  select s.garden_id
  into v_garden_id
  from public.seasons s
  join public.gardens g
    on g.id = s.garden_id
  where s.id = target_season_id
    and g.profile_id = target_profile_id;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  perform 1
  from public.gardens g
  where g.id = v_garden_id
    and g.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.4 LETTURA E BLOCCO DELLA SEASON TARGET
  -- --------------------------------------------------------------------------

  select
    s.is_active,
    s.row_version,
    s.updated_at
  into
    v_target_is_active,
    v_target_row_version,
    v_target_updated_at
  from public.seasons s
  where s.id = target_season_id
    and s.garden_id = v_garden_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.5 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_target_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'season_id', target_season_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_target_row_version,
      'updated_at', v_target_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.6 TARGET GIÀ ATTIVO
  -- --------------------------------------------------------------------------

  if v_target_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'season_id', target_season_id,
      'garden_id', v_garden_id,
      'row_version', v_target_row_version,
      'updated_at', v_target_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.7 LETTURA E DISATTIVAZIONE DELLA SEASON PRECEDENTE
  -- --------------------------------------------------------------------------

  select
    s.id,
    s.row_version,
    s.updated_at
  into
    v_previous_season_id,
    v_previous_row_version,
    v_previous_updated_at
  from public.seasons s
  where s.garden_id = v_garden_id
    and s.is_active = true
    and s.id <> target_season_id
  for update;

  if v_previous_season_id is not null
  then
    update public.seasons
    set is_active = false
    where id = v_previous_season_id
      and row_version = v_previous_row_version
      and is_active = true
    returning
      row_version,
      updated_at
    into
      v_previous_row_version,
      v_previous_updated_at;

    if not found
    then
      raise exception
        'Concurrent modification while deactivating Season %',
        v_previous_season_id;
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 5.8 ATTIVAZIONE DELLA SEASON TARGET
  -- --------------------------------------------------------------------------

  update public.seasons
  set is_active = true
  where id = target_season_id
    and row_version = expected_row_version
    and is_active = false
  returning
    row_version,
    updated_at
  into
    v_activated_row_version,
    v_activated_updated_at;

  if not found
  then
    raise exception
      'Concurrent modification while activating Season %',
      target_season_id;
  end if;

  v_result := jsonb_build_object(
    'status', 'activated',
    'season_id', target_season_id,
    'garden_id', v_garden_id,
    'row_version', v_activated_row_version,
    'updated_at', v_activated_updated_at
  );

  if v_previous_season_id is not null
  then
    v_result :=
      v_result
      ||
      jsonb_build_object(
        'deactivated_season_id', v_previous_season_id,
        'deactivated_row_version', v_previous_row_version,
        'deactivated_updated_at', v_previous_updated_at
      );
  end if;

  return v_result;
end;
$$;

revoke all
  on function public.activate_season(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.activate_season(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text
  )
  to authenticated;
