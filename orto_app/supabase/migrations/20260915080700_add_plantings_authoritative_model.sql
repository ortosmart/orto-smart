-- ============================================================================
-- ORTO SMART
-- S028 - MODELLO AUTORITATIVO PLANTINGS
-- ============================================================================
--
-- Introduce:
-- - chiavi composite di supporto all'integrita referenziale;
-- - tabella public.plantings;
-- - vincoli agronomici e geometrici locali;
-- - row_version / updated_at;
-- - RLS in sola lettura per i membri autorizzati;
-- - blocco delle scritture dirette applicative.
--
-- Le scritture saranno abilitate esclusivamente tramite RPC autoritative
-- dedicate in una migration successiva.
-- ============================================================================


-- ============================================================================
-- 1. CHIAVI COMPOSITE DI SUPPORTO
-- ============================================================================

alter table public.gardens
  add constraint gardens_id_profile_unique
  unique (id, profile_id);

alter table public.seasons
  add constraint seasons_id_garden_unique
  unique (id, garden_id);

alter table public.beds
  add constraint beds_id_garden_unique
  unique (id, garden_id);

alter table public.crop_varieties
  add constraint crop_varieties_id_crop_profile_unique
  unique (id, crop_id, profile_id);


-- ============================================================================
-- 2. PLANTINGS
-- ============================================================================

create table public.plantings (
  id uuid primary key default gen_random_uuid(),

  profile_id uuid not null,
  garden_id uuid not null,
  season_id uuid not null,
  bed_id uuid not null,

  crop_id uuid not null,
  variety_id uuid null,

  start_method text not null,

  start_date date not null,
  end_date date null,

  start_position_cm integer not null,
  length_cm integer not null,

  plant_spacing_cm integer null,
  row_spacing_cm integer null,
  rows_count integer null,
  occupied_width_cm integer not null,

  plants_count integer null,
  seed_quantity_g numeric null,

  status text not null,

  notes text null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  -- --------------------------------------------------------------------------
  -- 2.1 RELAZIONI AUTORITATIVE
  -- --------------------------------------------------------------------------

  constraint plantings_garden_profile_fk
    foreign key (
      garden_id,
      profile_id
    )
    references public.gardens (
      id,
      profile_id
    )
    on delete restrict,

  constraint plantings_season_garden_fk
    foreign key (
      season_id,
      garden_id
    )
    references public.seasons (
      id,
      garden_id
    )
    on delete restrict,

  constraint plantings_bed_garden_fk
    foreign key (
      bed_id,
      garden_id
    )
    references public.beds (
      id,
      garden_id
    )
    on delete restrict,

  constraint plantings_crop_profile_fk
    foreign key (
      crop_id,
      profile_id
    )
    references public.crops (
      id,
      profile_id
    )
    on delete restrict,

  constraint plantings_variety_crop_profile_fk
    foreign key (
      variety_id,
      crop_id,
      profile_id
    )
    references public.crop_varieties (
      id,
      crop_id,
      profile_id
    )
    on delete restrict,

  -- --------------------------------------------------------------------------
  -- 2.2 METODO DI AVVIO
  -- --------------------------------------------------------------------------

  constraint plantings_start_method_check
    check (
      start_method in (
        'purchased_seedlings',
        'nursery_then_transplant',
        'direct_rows',
        'direct_broadcast'
      )
    ),

  -- --------------------------------------------------------------------------
  -- 2.3 STATO
  -- --------------------------------------------------------------------------

  constraint plantings_status_check
    check (
      status in (
        'sown',
        'growing',
        'harvest_ready',
        'harvested',
        'finished',
        'removed'
      )
    ),

  -- --------------------------------------------------------------------------
  -- 2.4 PERIODO DI OCCUPAZIONE DELL'AIUOLA
  -- --------------------------------------------------------------------------

  constraint plantings_dates_check
    check (
      end_date is null
      or end_date >= start_date
    ),

  constraint plantings_status_end_date_check
    check (
      (
        status in (
          'sown',
          'growing',
          'harvest_ready',
          'harvested'
        )
        and end_date is null
      )
      or
      (
        status in (
          'finished',
          'removed'
        )
        and end_date is not null
      )
    ),

  -- --------------------------------------------------------------------------
  -- 2.5 GEOMETRIA E QUANTITA
  -- --------------------------------------------------------------------------

  constraint plantings_start_position_check
    check (start_position_cm >= 0),

  constraint plantings_length_check
    check (length_cm > 0),

  constraint plantings_occupied_width_check
    check (occupied_width_cm > 0),

  constraint plantings_plant_spacing_check
    check (
      plant_spacing_cm is null
      or plant_spacing_cm > 0
    ),

  constraint plantings_row_spacing_check
    check (
      row_spacing_cm is null
      or row_spacing_cm > 0
    ),

  constraint plantings_rows_count_check
    check (
      rows_count is null
      or rows_count > 0
    ),

  constraint plantings_plants_count_check
    check (
      plants_count is null
      or plants_count > 0
    ),

  constraint plantings_seed_quantity_check
    check (
      seed_quantity_g is null
      or seed_quantity_g > 0
    ),

  constraint plantings_notes_check
    check (
      notes is null
      or (
        btrim(notes) <> ''
        and char_length(notes) <= 1000
      )
    ),

  constraint plantings_rows_fit_width_check
    check (
      rows_count is null
      or row_spacing_cm is null
      or ((rows_count - 1) * row_spacing_cm) <= occupied_width_cm
    ),

  constraint plantings_plants_fit_length_check
    check (
      plants_count is null
      or plant_spacing_cm is null
      or ((plants_count - 1) * plant_spacing_cm) <= length_cm
    ),

  -- --------------------------------------------------------------------------
  -- 2.6 COERENZA DEI DATI CON IL METODO DI AVVIO
  -- --------------------------------------------------------------------------

  constraint plantings_start_method_data_check
    check (
      (
        start_method in (
          'purchased_seedlings',
          'nursery_then_transplant'
        )
        and plants_count is not null
        and plant_spacing_cm is not null
        and seed_quantity_g is null
        and (
          (
            rows_count is null
            and row_spacing_cm is null
          )
          or
          (
            rows_count is not null
            and row_spacing_cm is not null
          )
        )
      )
      or
      (
        start_method = 'direct_rows'
        and rows_count is not null
        and row_spacing_cm is not null
      )
      or
      (
        start_method = 'direct_broadcast'
        and rows_count is null
        and row_spacing_cm is null
        and plant_spacing_cm is null
        and plants_count is null
        and seed_quantity_g is not null
      )
    ),

  constraint plantings_row_version_check
    check (row_version >= 1)
);


-- ============================================================================
-- 3. TRIGGER UPDATED_AT / ROW_VERSION
-- ============================================================================

create trigger plantings_set_updated_at_and_row_version
before update on public.plantings
for each row
execute function public.set_updated_at_and_row_version();


-- ============================================================================
-- 4. INDICI
-- ============================================================================

create index plantings_garden_id_idx
  on public.plantings (garden_id);

create index plantings_season_id_idx
  on public.plantings (season_id);

create index plantings_bed_id_idx
  on public.plantings (bed_id);

create index plantings_crop_id_idx
  on public.plantings (crop_id);

create index plantings_variety_id_idx
  on public.plantings (variety_id)
  where variety_id is not null;

create index plantings_bed_active_period_idx
  on public.plantings (
    bed_id,
    start_date,
    end_date
  );


-- ============================================================================
-- 5. ROW LEVEL SECURITY
-- ============================================================================

alter table public.plantings
  enable row level security;

revoke all privileges
  on table public.plantings
  from public, anon, authenticated;

grant select
  on table public.plantings
  to authenticated;

create policy plantings_select_member
  on public.plantings
  for select
  to authenticated
  using (
    private.can_access_garden(garden_id)
  );


-- ============================================================================
-- 6. WRITE PATH
-- ============================================================================
--
-- Nessuna policy INSERT / UPDATE / DELETE.
-- Nessun privilegio diretto di scrittura per authenticated.
--
-- Le scritture applicative passeranno esclusivamente attraverso RPC
-- autoritative dedicate con Profile Write Authority.
--
-- I controlli che dipendono da altre righe/tabelle, in particolare:
--
--   start_position_cm + length_cm <= lunghezza della geometria valida;
--   occupied_width_cm <= larghezza della geometria valida;
--   compatibilita temporale con bed_geometries;
--   assenza di sovrapposizioni con planting che occupano realmente spazio;
--   stato iniziale coerente con start_method;
--
-- saranno applicati nel Write Path autoritativo e non tramite CHECK locali.
--
-- Hard delete: FUTURE. Non appartiene al normale flusso applicativo.
-- ============================================================================
