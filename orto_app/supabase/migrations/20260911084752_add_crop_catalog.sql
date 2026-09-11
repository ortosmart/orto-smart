-- ============================================================================
-- Orto Smart - Catalogo colture
-- Sessione S026
-- ============================================================================

-- ============================================================================
-- 1. FAMIGLIE BOTANICHE
-- ============================================================================

create table public.botanical_families (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  name text not null,
  scientific_name text,
  description text,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint botanical_families_id_profile_unique
    unique (id, profile_id),

  constraint botanical_families_name_check
    check (
      btrim(name) <> ''
      and char_length(name) <= 80
    ),

  constraint botanical_families_scientific_name_check
    check (
      scientific_name is null
      or (
        btrim(scientific_name) <> ''
        and char_length(scientific_name) <= 120
      )
    ),

  constraint botanical_families_description_check
    check (
      description is null
      or (
        btrim(description) <> ''
        and char_length(description) <= 300
      )
    ),

  constraint botanical_families_row_version_check
    check (row_version >= 1)
);

-- ----------------------------------------------------------------------------
-- 1.1 UNICITÀ
-- ----------------------------------------------------------------------------
-- I nomi sono univoci nel Profile senza distinzione tra maiuscole/minuscole.
-- Il nome scientifico è facoltativo, ma quando presente è anch'esso univoco
-- nel Profile senza distinzione tra maiuscole/minuscole.

create unique index botanical_families_profile_name_unique
  on public.botanical_families (
    profile_id,
    lower(name)
  );

create unique index botanical_families_profile_scientific_name_unique
  on public.botanical_families (
    profile_id,
    lower(scientific_name)
  )
  where scientific_name is not null;

-- ----------------------------------------------------------------------------
-- 1.2 METADATA
-- ----------------------------------------------------------------------------

create trigger botanical_families_set_updated_at_and_row_version
before update on public.botanical_families
for each row
execute function public.set_updated_at_and_row_version();

-- ----------------------------------------------------------------------------
-- 1.3 RLS E PRIVILEGI
-- ----------------------------------------------------------------------------

alter table public.botanical_families
  enable row level security;

revoke all privileges
  on table public.botanical_families
  from public, anon, authenticated;

grant select
  on table public.botanical_families
  to authenticated;

create policy botanical_families_select_member
  on public.botanical_families
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );

-- Nessuna policy di scrittura e nessun privilegio diretto
-- INSERT/UPDATE/DELETE per authenticated.
-- Le scritture applicative passeranno esclusivamente
-- attraverso le RPC autoritative dedicate.
-- ============================================================================
-- 2. COLTURE
-- ============================================================================

create table public.crops (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  botanical_family_id uuid not null,

  name text not null,
  scientific_name text,
  description text,

  default_start_method text,

  row_spacing_cm integer,
  plant_spacing_cm integer,
  sowing_depth_cm numeric,
  germination_days integer,
  harvest_days integer,

  min_temperature integer,
  optimal_temperature integer,

  rotation_seasons integer,

  water_requirement text,
  water_requirement_value numeric,
  water_requirement_basis text,
  water_interval_days integer,

  productivity text,

  expected_yield_min numeric,
  expected_yield_avg numeric,
  expected_yield_max numeric,
  expected_yield_unit text,

  yield_source_name text,
  yield_source_url text,
  yield_source_year integer,
  yield_notes text,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint crops_id_profile_unique
    unique (id, profile_id),

  constraint crops_botanical_family_profile_fk
    foreign key (
      botanical_family_id,
      profile_id
    )
    references public.botanical_families (
      id,
      profile_id
    )
    on delete restrict,

  constraint crops_name_check
    check (
      btrim(name) <> ''
      and char_length(name) <= 80
    ),

  constraint crops_scientific_name_check
    check (
      scientific_name is null
      or (
        btrim(scientific_name) <> ''
        and char_length(scientific_name) <= 120
      )
    ),

  constraint crops_description_check
    check (
      description is null
      or (
        btrim(description) <> ''
        and char_length(description) <= 300
      )
    ),

  constraint crops_default_start_method_check
    check (
      default_start_method is null
      or default_start_method in (
        'purchased_seedlings',
        'nursery_then_transplant',
        'direct_rows',
        'direct_broadcast'
      )
    ),

  constraint crops_row_spacing_check
    check (
      row_spacing_cm is null
      or row_spacing_cm > 0
    ),

  constraint crops_plant_spacing_check
    check (
      plant_spacing_cm is null
      or plant_spacing_cm > 0
    ),

  constraint crops_sowing_depth_check
    check (
      sowing_depth_cm is null
      or sowing_depth_cm > 0
    ),

  constraint crops_germination_days_check
    check (
      germination_days is null
      or germination_days > 0
    ),

  constraint crops_harvest_days_check
    check (
      harvest_days is null
      or harvest_days > 0
    ),

  constraint crops_temperature_order_check
    check (
      min_temperature is null
      or optimal_temperature is null
      or min_temperature <= optimal_temperature
    ),

  constraint crops_rotation_seasons_check
    check (
      rotation_seasons is null
      or rotation_seasons > 0
    ),

  constraint crops_water_requirement_check
    check (
      water_requirement is null
      or (
        btrim(water_requirement) <> ''
        and char_length(water_requirement) <= 180
      )
    ),

  constraint crops_productivity_check
    check (
      productivity is null
      or (
        btrim(productivity) <> ''
        and char_length(productivity) <= 180
      )
    ),

  constraint crops_water_group_check
    check (
      (
        water_requirement_value is null
        and water_requirement_basis is null
        and water_interval_days is null
      )
      or
      (
        water_requirement_value is not null
        and water_requirement_value > 0
        and water_requirement_basis in (
          'per_plant',
          'per_m2'
        )
        and water_interval_days is not null
        and water_interval_days > 0
      )
    ),

  constraint crops_expected_yield_min_check
    check (
      expected_yield_min is null
      or expected_yield_min >= 0
    ),

  constraint crops_expected_yield_avg_check
    check (
      expected_yield_avg is null
      or expected_yield_avg >= 0
    ),

  constraint crops_expected_yield_max_check
    check (
      expected_yield_max is null
      or expected_yield_max >= 0
    ),

  constraint crops_expected_yield_order_check
    check (
      (
        expected_yield_min is null
        or expected_yield_avg is null
        or expected_yield_min <= expected_yield_avg
      )
      and
      (
        expected_yield_avg is null
        or expected_yield_max is null
        or expected_yield_avg <= expected_yield_max
      )
      and
      (
        expected_yield_min is null
        or expected_yield_max is null
        or expected_yield_min <= expected_yield_max
      )
    ),

  constraint crops_expected_yield_unit_check
    check (
      (
        expected_yield_min is null
        and expected_yield_avg is null
        and expected_yield_max is null
        and expected_yield_unit is null
      )
      or
      (
        (
          expected_yield_min is not null
          or expected_yield_avg is not null
          or expected_yield_max is not null
        )
        and expected_yield_unit in (
          'kg_per_m2',
          'kg_per_plant',
          'g_per_m2',
          'g_per_plant',
          'pieces_per_m2',
          'pieces_per_plant'
        )
      )
    ),

  constraint crops_yield_source_name_check
    check (
      yield_source_name is null
      or (
        btrim(yield_source_name) <> ''
        and char_length(yield_source_name) <= 150
      )
    ),

  constraint crops_yield_source_url_check
    check (
      yield_source_url is null
      or (
        btrim(yield_source_url) <> ''
        and char_length(yield_source_url) <= 300
      )
    ),

  constraint crops_yield_source_year_check
    check (
      yield_source_year is null
      or yield_source_year >= 1800
    ),

  constraint crops_yield_notes_check
    check (
      yield_notes is null
      or (
        btrim(yield_notes) <> ''
        and char_length(yield_notes) <= 300
      )
    ),

  constraint crops_yield_source_requires_yield_check
    check (
      expected_yield_min is not null
      or expected_yield_avg is not null
      or expected_yield_max is not null
      or (
        yield_source_name is null
        and yield_source_url is null
        and yield_source_year is null
        and yield_notes is null
      )
    ),

  constraint crops_row_version_check
    check (row_version >= 1)
);

-- ----------------------------------------------------------------------------
-- 2.1 UNICITÀ
-- ----------------------------------------------------------------------------

create unique index crops_profile_name_unique
  on public.crops (
    profile_id,
    lower(name)
  );

create unique index crops_profile_scientific_name_unique
  on public.crops (
    profile_id,
    lower(scientific_name)
  )
  where scientific_name is not null;

-- ----------------------------------------------------------------------------
-- 2.2 METADATA
-- ----------------------------------------------------------------------------

create trigger crops_set_updated_at_and_row_version
before update on public.crops
for each row
execute function public.set_updated_at_and_row_version();

-- ----------------------------------------------------------------------------
-- 2.3 RLS E PRIVILEGI
-- ----------------------------------------------------------------------------

alter table public.crops
  enable row level security;

revoke all privileges
  on table public.crops
  from public, anon, authenticated;

grant select
  on table public.crops
  to authenticated;

create policy crops_select_member
  on public.crops
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );

-- Nessuna policy di scrittura e nessun privilegio diretto
-- INSERT/UPDATE/DELETE per authenticated.
-- Le scritture applicative passeranno esclusivamente
-- attraverso le RPC autoritative dedicate.
-- ============================================================================
-- 3. VARIETÀ DELLE COLTURE
-- ============================================================================

create table public.crop_varieties (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null
    references public.profiles(id)
    on delete restrict,

  crop_id uuid not null,

  name text not null,
  scientific_name text,
  description text,

  default_start_method text,

  row_spacing_cm integer,
  plant_spacing_cm integer,
  sowing_depth_cm numeric,
  germination_days integer,
  harvest_days integer,

  min_temperature integer,
  optimal_temperature integer,

  water_requirement text,
  water_requirement_value numeric,
  water_requirement_basis text,
  water_interval_days integer,

  productivity text,

  expected_yield_min numeric,
  expected_yield_avg numeric,
  expected_yield_max numeric,
  expected_yield_unit text,

  yield_source_name text,
  yield_source_url text,
  yield_source_year integer,
  yield_notes text,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint crop_varieties_id_profile_unique
    unique (id, profile_id),

  constraint crop_varieties_crop_profile_fk
    foreign key (
      crop_id,
      profile_id
    )
    references public.crops (
      id,
      profile_id
    )
    on delete restrict,

  constraint crop_varieties_name_check
    check (
      btrim(name) <> ''
      and char_length(name) <= 80
    ),

  constraint crop_varieties_scientific_name_check
    check (
      scientific_name is null
      or (
        btrim(scientific_name) <> ''
        and char_length(scientific_name) <= 120
      )
    ),

  constraint crop_varieties_description_check
    check (
      description is null
      or (
        btrim(description) <> ''
        and char_length(description) <= 300
      )
    ),

  constraint crop_varieties_default_start_method_check
    check (
      default_start_method is null
      or default_start_method in (
        'purchased_seedlings',
        'nursery_then_transplant',
        'direct_rows',
        'direct_broadcast'
      )
    ),

  constraint crop_varieties_row_spacing_check
    check (
      row_spacing_cm is null
      or row_spacing_cm > 0
    ),

  constraint crop_varieties_plant_spacing_check
    check (
      plant_spacing_cm is null
      or plant_spacing_cm > 0
    ),

  constraint crop_varieties_sowing_depth_check
    check (
      sowing_depth_cm is null
      or sowing_depth_cm > 0
    ),

  constraint crop_varieties_germination_days_check
    check (
      germination_days is null
      or germination_days > 0
    ),

  constraint crop_varieties_harvest_days_check
    check (
      harvest_days is null
      or harvest_days > 0
    ),

  constraint crop_varieties_temperature_order_check
    check (
      min_temperature is null
      or optimal_temperature is null
      or min_temperature <= optimal_temperature
    ),

  constraint crop_varieties_water_requirement_check
    check (
      water_requirement is null
      or (
        btrim(water_requirement) <> ''
        and char_length(water_requirement) <= 180
      )
    ),

  constraint crop_varieties_productivity_check
    check (
      productivity is null
      or (
        btrim(productivity) <> ''
        and char_length(productivity) <= 180
      )
    ),

  constraint crop_varieties_water_group_check
    check (
      (
        water_requirement_value is null
        and water_requirement_basis is null
        and water_interval_days is null
      )
      or
      (
        water_requirement_value is not null
        and water_requirement_value > 0
        and water_requirement_basis in (
          'per_plant',
          'per_m2'
        )
        and water_interval_days is not null
        and water_interval_days > 0
      )
    ),

  constraint crop_varieties_expected_yield_min_check
    check (
      expected_yield_min is null
      or expected_yield_min >= 0
    ),

  constraint crop_varieties_expected_yield_avg_check
    check (
      expected_yield_avg is null
      or expected_yield_avg >= 0
    ),

  constraint crop_varieties_expected_yield_max_check
    check (
      expected_yield_max is null
      or expected_yield_max >= 0
    ),

  constraint crop_varieties_expected_yield_order_check
    check (
      (
        expected_yield_min is null
        or expected_yield_avg is null
        or expected_yield_min <= expected_yield_avg
      )
      and
      (
        expected_yield_avg is null
        or expected_yield_max is null
        or expected_yield_avg <= expected_yield_max
      )
      and
      (
        expected_yield_min is null
        or expected_yield_max is null
        or expected_yield_min <= expected_yield_max
      )
    ),

  constraint crop_varieties_expected_yield_unit_check
    check (
      (
        expected_yield_min is null
        and expected_yield_avg is null
        and expected_yield_max is null
        and expected_yield_unit is null
      )
      or
      (
        (
          expected_yield_min is not null
          or expected_yield_avg is not null
          or expected_yield_max is not null
        )
        and expected_yield_unit in (
          'kg_per_m2',
          'kg_per_plant',
          'g_per_m2',
          'g_per_plant',
          'pieces_per_m2',
          'pieces_per_plant'
        )
      )
    ),

  constraint crop_varieties_yield_source_name_check
    check (
      yield_source_name is null
      or (
        btrim(yield_source_name) <> ''
        and char_length(yield_source_name) <= 150
      )
    ),

  constraint crop_varieties_yield_source_url_check
    check (
      yield_source_url is null
      or (
        btrim(yield_source_url) <> ''
        and char_length(yield_source_url) <= 300
      )
    ),

  constraint crop_varieties_yield_source_year_check
    check (
      yield_source_year is null
      or yield_source_year >= 1800
    ),

  constraint crop_varieties_yield_notes_check
    check (
      yield_notes is null
      or (
        btrim(yield_notes) <> ''
        and char_length(yield_notes) <= 300
      )
    ),

  constraint crop_varieties_yield_source_requires_yield_check
    check (
      expected_yield_min is not null
      or expected_yield_avg is not null
      or expected_yield_max is not null
      or (
        yield_source_name is null
        and yield_source_url is null
        and yield_source_year is null
        and yield_notes is null
      )
    ),

  constraint crop_varieties_row_version_check
    check (row_version >= 1)
);

-- ----------------------------------------------------------------------------
-- 3.1 UNICITÀ
-- ----------------------------------------------------------------------------
-- Il nome della varietà è univoco all'interno della stessa coltura
-- senza distinzione tra maiuscole/minuscole.
-- scientific_name è intenzionalmente non UNIQUE.

create unique index crop_varieties_crop_name_unique
  on public.crop_varieties (
    crop_id,
    lower(name)
  );

-- ----------------------------------------------------------------------------
-- 3.2 METADATA
-- ----------------------------------------------------------------------------

create trigger crop_varieties_set_updated_at_and_row_version
before update on public.crop_varieties
for each row
execute function public.set_updated_at_and_row_version();

-- ----------------------------------------------------------------------------
-- 3.3 RLS E PRIVILEGI
-- ----------------------------------------------------------------------------

alter table public.crop_varieties
  enable row level security;

revoke all privileges
  on table public.crop_varieties
  from public, anon, authenticated;

grant select
  on table public.crop_varieties
  to authenticated;

create policy crop_varieties_select_member
  on public.crop_varieties
  for select
  to authenticated
  using (
    private.is_profile_member(profile_id)
  );

-- Nessuna policy di scrittura e nessun privilegio diretto
-- INSERT/UPDATE/DELETE per authenticated.
-- Le scritture applicative passeranno esclusivamente
-- attraverso le RPC autoritative dedicate.
