-- ============================================================================
-- Orto Smart - Database V1
-- Baseline migration
-- Sessione S019
-- ============================================================================

-- ============================================================================
-- 1. TIPI
-- ============================================================================

create type public.profile_member_role as enum (
  'owner',
  'worker',
  'viewer'
);

-- ============================================================================
-- 2. PROFILES
-- ============================================================================

create table public.profiles (
  id uuid primary key
    references auth.users(id)
    on delete restrict,

  display_name text not null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint profiles_row_version_check
    check (row_version >= 1),

  constraint profiles_display_name_not_blank_check
    check (btrim(display_name) <> '')
);

-- ============================================================================
-- 3. PROFILE MEMBERSHIPS
-- ============================================================================

create table public.profile_memberships (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  auth_user_id uuid not null
    references auth.users(id)
    on delete restrict,

  role public.profile_member_role not null,

  is_enabled boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint profile_memberships_profile_user_unique
    unique (profile_id, auth_user_id),

  constraint profile_memberships_row_version_check
    check (row_version >= 1),

  constraint profile_memberships_owner_matches_profile_check
    check (role <> 'owner' or auth_user_id = profile_id),

  constraint profile_memberships_owner_enabled_check
    check (role <> 'owner' or is_enabled = true)
);

-- Un Profile può avere al massimo un owner.
create unique index profile_memberships_one_owner_per_profile_idx
  on public.profile_memberships (profile_id)
  where role = 'owner';

-- ============================================================================
-- 4. GARDENS
-- ============================================================================

create table public.gardens (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  name text not null,
  description text null,

  latitude double precision not null,
  longitude double precision not null,
  timezone text not null,

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint gardens_profile_name_unique
    unique (profile_id, name),

  constraint gardens_latitude_check
    check (latitude >= -90 and latitude <= 90),

  constraint gardens_longitude_check
    check (longitude >= -180 and longitude <= 180),

  constraint gardens_row_version_check
    check (row_version >= 1),

  constraint gardens_name_not_blank_check
    check (btrim(name) <> ''),

  constraint gardens_timezone_not_blank_check
    check (btrim(timezone) <> '')
);

-- ============================================================================
-- 5. WORKERS
-- ============================================================================

create table public.workers (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  display_name text not null,
  notes text null,

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint workers_row_version_check
    check (row_version >= 1),

  constraint workers_display_name_not_blank_check
    check (btrim(display_name) <> '')
);

-- ============================================================================
-- 6. SEASONS
-- ============================================================================

create table public.seasons (
  id uuid primary key default gen_random_uuid(),

  garden_id uuid not null
    references public.gardens(id)
    on delete restrict,

  year integer not null,
  name text not null,

  start_date date not null,
  end_date date null,

  is_active boolean not null default false,

  notes text null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint seasons_garden_year_unique
    unique (garden_id, year),

  constraint seasons_dates_check
    check (end_date is null or end_date >= start_date),

  constraint seasons_row_version_check
    check (row_version >= 1),

  constraint seasons_name_not_blank_check
    check (btrim(name) <> '')
);

-- Un Garden può avere al massimo una Season attiva.
create unique index seasons_one_active_per_garden_idx
  on public.seasons (garden_id)
  where is_active = true;

-- ============================================================================
-- 7. PROFILE EDIT LOCKS
-- ============================================================================

create table public.profile_edit_locks (
  profile_id uuid primary key
    references public.profiles(id)
    on delete restrict,

  holder_auth_user_id uuid not null
    references auth.users(id)
    on delete restrict,

  client_instance_id uuid not null,
  client_label text null,

  acquired_at timestamptz not null,
  heartbeat_at timestamptz not null,
  expires_at timestamptz not null,

  takeover_requested_by_auth_user_id uuid null
    references auth.users(id)
    on delete restrict,

  takeover_requested_by_client_id uuid null,
  takeover_requested_client_label text null,
  takeover_requested_at timestamptz null,

  row_version bigint not null default 1,

  constraint profile_edit_locks_row_version_check
    check (row_version >= 1),

  constraint profile_edit_locks_heartbeat_check
    check (heartbeat_at >= acquired_at),

  constraint profile_edit_locks_expiry_check
    check (expires_at > heartbeat_at),

  constraint profile_edit_locks_takeover_consistency_check
    check (
      (
        takeover_requested_by_auth_user_id is null
        and takeover_requested_by_client_id is null
        and takeover_requested_client_label is null
        and takeover_requested_at is null
      )
      or
      (
        takeover_requested_by_auth_user_id is not null
        and takeover_requested_by_client_id is not null
        and takeover_requested_at is not null
      )
    ),

  constraint profile_edit_locks_takeover_not_holder_check
    check (
      takeover_requested_by_auth_user_id is null
      or takeover_requested_by_client_id is null
      or holder_auth_user_id <> takeover_requested_by_auth_user_id
      or client_instance_id <> takeover_requested_by_client_id
    ),

  constraint profile_edit_locks_client_label_not_blank_check
    check (
      client_label is null
      or btrim(client_label) <> ''
    ),

  constraint profile_edit_locks_client_label_length_check
    check (
      client_label is null
      or char_length(client_label) <= 80
    ),

  constraint profile_edit_locks_takeover_client_label_not_blank_check
    check (
      takeover_requested_client_label is null
      or btrim(takeover_requested_client_label) <> ''
    ),

  constraint profile_edit_locks_takeover_client_label_length_check
    check (
      takeover_requested_client_label is null
      or char_length(takeover_requested_client_label) <= 80
    )
);

-- ============================================================================
-- 8. COMMON UPDATE METADATA
-- ============================================================================

create or replace function public.set_updated_at_and_row_version()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  new.row_version = old.row_version + 1;

  return new;
end;
$$;

create trigger profiles_set_updated_at_and_row_version
before update on public.profiles
for each row
execute function public.set_updated_at_and_row_version();

create trigger profile_memberships_set_updated_at_and_row_version
before update on public.profile_memberships
for each row
execute function public.set_updated_at_and_row_version();

create trigger gardens_set_updated_at_and_row_version
before update on public.gardens
for each row
execute function public.set_updated_at_and_row_version();

create trigger workers_set_updated_at_and_row_version
before update on public.workers
for each row
execute function public.set_updated_at_and_row_version();

create trigger seasons_set_updated_at_and_row_version
before update on public.seasons
for each row
execute function public.set_updated_at_and_row_version();

-- ============================================================================
-- 9. AUTHORIZATION HELPERS
-- ============================================================================

-- Schema non esposto dalla Data API.
create schema if not exists private;

-- Nessun accesso implicito allo schema privato.
revoke all on schema private from public;

-- Gli utenti autenticati possono utilizzare esclusivamente
-- le funzioni che verranno esplicitamente concesse.
grant usage on schema private to authenticated;

-- ----------------------------------------------------------------------------
-- 9.1 IS PROFILE MEMBER
-- ----------------------------------------------------------------------------

create or replace function private.is_profile_member(
  target_profile_id uuid
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
      and pm.auth_user_id = auth.uid()
      and pm.is_enabled = true
  );
$$;

-- ----------------------------------------------------------------------------
-- 9.2 IS PROFILE OWNER
-- ----------------------------------------------------------------------------

create or replace function private.is_profile_owner(
  target_profile_id uuid
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
      and pm.auth_user_id = auth.uid()
      and pm.role = 'owner'::public.profile_member_role
      and pm.is_enabled = true
  );
$$;

-- ----------------------------------------------------------------------------
-- 9.3 CAN ACCESS GARDEN
-- ----------------------------------------------------------------------------

create or replace function private.can_access_garden(
  target_garden_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.gardens g
    join public.profile_memberships pm
      on pm.profile_id = g.profile_id
    where g.id = target_garden_id
      and pm.auth_user_id = auth.uid()
      and pm.is_enabled = true
  );
$$;

-- ----------------------------------------------------------------------------
-- 9.4 FUNCTION PRIVILEGES
-- ----------------------------------------------------------------------------

-- SECURITY DEFINER non deve avere EXECUTE aperto indiscriminatamente.
revoke all on function private.is_profile_member(uuid) from public;
revoke all on function private.is_profile_owner(uuid) from public;
revoke all on function private.can_access_garden(uuid) from public;

grant execute
  on function private.is_profile_member(uuid)
  to authenticated;

grant execute
  on function private.is_profile_owner(uuid)
  to authenticated;

grant execute
  on function private.can_access_garden(uuid)
  to authenticated;

-- ============================================================================
-- 10. ROW LEVEL SECURITY
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 10.1 PROFILES
-- ----------------------------------------------------------------------------

alter table public.profiles
  enable row level security;

revoke all
  on table public.profiles
  from anon, authenticated;

grant select
  on table public.profiles
  to authenticated;

grant update (display_name)
  on table public.profiles
  to authenticated;

create policy profiles_select_for_active_members
  on public.profiles
  for select
  to authenticated
  using (
    private.is_profile_member(id)
  );

create policy profiles_update_for_owner
  on public.profiles
  for update
  to authenticated
  using (
    private.is_profile_owner(id)
  )
  with check (
    private.is_profile_owner(id)
  );

-- ----------------------------------------------------------------------------
-- 10.2 PROFILE MEMBERSHIPS
-- ----------------------------------------------------------------------------

alter table public.profile_memberships
  enable row level security;

revoke all
  on table public.profile_memberships
  from anon, authenticated;

grant select
  on table public.profile_memberships
  to authenticated;

create policy profile_memberships_select_for_members
  on public.profile_memberships
  for select
  to authenticated
  using (
    private.is_profile_owner(profile_id)
    or (
      auth_user_id = auth.uid()
      and is_enabled = true
    )
  );

-- ----------------------------------------------------------------------------
-- 10.3 GARDENS
-- ----------------------------------------------------------------------------

alter table public.gardens
  enable row level security;

revoke all
  on table public.gardens
  from anon, authenticated;

grant select
  on table public.gardens
  to authenticated;

grant insert
  on table public.gardens
  to authenticated;

grant update (
  name,
  description,
  latitude,
  longitude,
  timezone,
  is_active
)
  on table public.gardens
  to authenticated;

create policy gardens_select_for_active_members
  on public.gardens
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );

create policy gardens_insert_for_owner
  on public.gardens
  for insert
  to authenticated
  with check (
    private.is_profile_owner(profile_id)
  );

create policy gardens_update_for_owner
  on public.gardens
  for update
  to authenticated
  using (
    private.is_profile_owner(profile_id)
  )
  with check (
    private.is_profile_owner(profile_id)
  );

-- ----------------------------------------------------------------------------
-- 10.4 WORKERS
-- ----------------------------------------------------------------------------

alter table public.workers
  enable row level security;

revoke all
  on table public.workers
  from anon, authenticated;

grant select
  on table public.workers
  to authenticated;

grant insert
  on table public.workers
  to authenticated;

grant update (
  display_name,
  notes,
  is_active
)
  on table public.workers
  to authenticated;

create policy workers_select_for_active_members
  on public.workers
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );

create policy workers_insert_for_owner
  on public.workers
  for insert
  to authenticated
  with check (
    private.is_profile_owner(profile_id)
  );

create policy workers_update_for_owner
  on public.workers
  for update
  to authenticated
  using (
    private.is_profile_owner(profile_id)
  )
  with check (
    private.is_profile_owner(profile_id)
  );

-- ----------------------------------------------------------------------------
-- 10.5 SEASONS
-- ----------------------------------------------------------------------------

alter table public.seasons
  enable row level security;

revoke all
  on table public.seasons
  from anon, authenticated;

grant select
  on table public.seasons
  to authenticated;

grant insert
  on table public.seasons
  to authenticated;

grant update (
  year,
  name,
  start_date,
  end_date,
  is_active,
  notes
)
  on table public.seasons
  to authenticated;

create policy seasons_select_for_active_members
  on public.seasons
  for select
  to authenticated
  using (
    private.can_access_garden(garden_id)
  );

create policy seasons_insert_for_owner
  on public.seasons
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.gardens g
      where g.id = garden_id
        and private.is_profile_owner(g.profile_id)
    )
  );

create policy seasons_update_for_owner
  on public.seasons
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.gardens g
      where g.id = garden_id
        and private.is_profile_owner(g.profile_id)
    )
  )
  with check (
    exists (
      select 1
      from public.gardens g
      where g.id = garden_id
        and private.is_profile_owner(g.profile_id)
    )
  );

-- ----------------------------------------------------------------------------
-- 10.6 PROFILE EDIT LOCKS
-- ----------------------------------------------------------------------------

alter table public.profile_edit_locks
  enable row level security;

revoke all
  on table public.profile_edit_locks
  from anon, authenticated;

grant select
  on table public.profile_edit_locks
  to authenticated;

create policy profile_edit_locks_select_for_active_members
  on public.profile_edit_locks
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );