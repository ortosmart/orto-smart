
-- ============================================================================
-- ORTO SMART - S039
-- PIANIFICAZIONE STAGIONALE V1
-- Migrazione: 20261104190000_add_seasonal_planting_plans.sql
-- ============================================================================

-- ============================================================================
-- 0. INTEGRITA' DEL COLLEGAMENTO ALLA COLTIVAZIONE REALE
-- ============================================================================

alter table public.plantings
  add constraint plantings_execution_identity_unique
  unique (
    id,
    profile_id,
    garden_id,
    season_id,
    bed_id
  );

-- ============================================================================
-- 1. SEASON PLANS
-- ============================================================================

create table public.season_plans (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null,
  garden_id uuid not null,
  season_id uuid not null,

  notes text null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint season_plans_garden_profile_fk
    foreign key (garden_id, profile_id)
    references public.gardens (id, profile_id)
    on delete restrict,

  constraint season_plans_season_garden_fk
    foreign key (season_id, garden_id)
    references public.seasons (id, garden_id)
    on delete restrict,

  constraint season_plans_season_unique
    unique (season_id),

  constraint season_plans_identity_unique
    unique (id, profile_id, garden_id, season_id),


  constraint season_plans_row_version_check
    check (row_version >= 1)
);

comment on table public.season_plans is
  'Piano persistente della stagione, separato dalle coltivazioni reali.';

-- ============================================================================
-- 2. PLANNED PLANTINGS
-- ============================================================================

create table public.planned_plantings (
  id uuid primary key default gen_random_uuid(),

  season_plan_id uuid not null,
  profile_id uuid not null,
  garden_id uuid not null,
  season_id uuid not null,
  bed_id uuid not null,

  crop_id uuid not null,
  cultivar_id uuid null,

  start_method text not null,

  planned_start_date date not null,
  planned_end_date date null,

  start_position_cm integer not null,
  length_cm integer not null,
  occupied_width_cm integer not null,

  plant_spacing_cm integer null,
  row_spacing_cm integer null,
  rows_count integer null,

  plants_count integer null,
  seed_quantity_g numeric null,

  status text not null default 'draft',

  executed_planting_id uuid null,

  notes text null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,


  constraint planned_plantings_plan_fk
    foreign key (
      season_plan_id,
      profile_id,
      garden_id,
      season_id
    )
    references public.season_plans (
      id,
      profile_id,
      garden_id,
      season_id
    )
    on delete restrict,


  constraint planned_plantings_garden_profile_fk
    foreign key (garden_id, profile_id)
    references public.gardens (id, profile_id)
    on delete restrict,

  constraint planned_plantings_season_garden_fk
    foreign key (season_id, garden_id)
    references public.seasons (id, garden_id)
    on delete restrict,

  constraint planned_plantings_bed_garden_fk
    foreign key (bed_id, garden_id)
    references public.beds (id, garden_id)
    on delete restrict,

  constraint planned_plantings_crop_fk
    foreign key (crop_id)
    references public.crops (id)
    on delete restrict,

  constraint planned_plantings_cultivar_crop_fk
    foreign key (cultivar_id, crop_id)
    references public.crop_cultivars (id, crop_id)
    on delete restrict,


  constraint planned_plantings_executed_planting_fk
    foreign key (
      executed_planting_id,
      profile_id,
      garden_id,
      season_id,
      bed_id
    )
    references public.plantings (
      id,
      profile_id,
      garden_id,
      season_id,
      bed_id
    )
    on delete restrict,

  constraint planned_plantings_executed_planting_unique
    unique (executed_planting_id),

  constraint planned_plantings_start_method_check
    check (
      start_method in (
        'purchased_seedlings',
        'nursery_then_transplant',
        'direct_rows',
        'direct_broadcast'
      )
    ),

  constraint planned_plantings_status_check
    check (
      status in (
        'draft',
        'confirmed',
        'executed',
        'cancelled'
      )
    ),

  constraint planned_plantings_dates_check
    check (
      planned_end_date is null
      or planned_end_date >= planned_start_date
    ),

  constraint planned_plantings_geometry_check
    check (
      start_position_cm >= 0
      and length_cm > 0
      and occupied_width_cm > 0
    ),

  constraint planned_plantings_quantities_check
    check (
      (plants_count is null or plants_count > 0)
      and (seed_quantity_g is null or seed_quantity_g > 0)
    ),

  constraint planned_plantings_execution_state_check
    check (
      (status = 'executed' and executed_planting_id is not null)
      or
      (status <> 'executed' and executed_planting_id is null)
    ),

  constraint planned_plantings_row_version_check
    check (row_version >= 1)
);

comment on table public.planned_plantings is
  'Lotti di coltivazione pianificati, distinti dalle coltivazioni reali.';


-- ============================================================================
-- 3. ROW LEVEL SECURITY
-- ============================================================================

alter table public.season_plans
  enable row level security;

alter table public.planned_plantings
  enable row level security;

-- Nessun privilegio diretto iniziale.
revoke all privileges
  on table public.season_plans
  from public, anon, authenticated;

revoke all privileges
  on table public.planned_plantings
  from public, anon, authenticated;

-- Lettura consentita agli utenti autenticati autorizzati.
grant select
  on table public.season_plans
  to authenticated;

grant select
  on table public.planned_plantings
  to authenticated;

create policy season_plans_select_member
  on public.season_plans
  for select
  to authenticated
  using (
    private.can_access_garden(garden_id)
  );

create policy planned_plantings_select_member
  on public.planned_plantings
  for select
  to authenticated
  using (
    private.can_access_garden(garden_id)
  );

-- ============================================================================
-- 4. WRITE PATH
-- ============================================================================
--
-- Nessuna policy INSERT / UPDATE / DELETE.
-- Nessun privilegio diretto di scrittura per authenticated.
--
-- Le modifiche saranno consentite esclusivamente attraverso RPC
-- autoritative con Profile Write Authority e controllo row_version.
--
-- La verifica della geometria, delle sovrapposizioni temporali,
-- della coerenza dell'esecuzione e della conversione atomica
-- sara' responsabilita' delle RPC dedicate.
--
-- Nessuna esecuzione automatica delle coltivazioni pianificate.
-- ============================================================================
