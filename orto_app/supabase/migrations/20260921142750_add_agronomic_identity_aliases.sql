-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 5 - ALIAS DELLE IDENTITA AGRONOMICHE
-- ============================================================================
--
-- Tre tabelle specifiche: Taxon, Crop e Cultivar.
-- Alias = nome verificato della medesima identita.
-- Nessuna risoluzione automatica delle ambiguita.
-- Nessun dato iniziale o dimostrativo.
-- ============================================================================


-- ============================================================================
-- 1. TAXON ALIASES
-- ============================================================================

create table public.taxon_aliases (
  id uuid primary key default gen_random_uuid(),

  taxon_id uuid not null,

  alias text not null,

  normalized_alias text
    generated always as (
      private.normalize_catalog_text(alias)
    ) stored not null,

  alias_type text not null,
  language_code text null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint taxon_aliases_taxon_id_fkey
    foreign key (taxon_id)
    references public.botanical_taxa(id)
    on delete restrict,

  constraint taxon_aliases_identity_unique
    unique nulls not distinct (
      taxon_id,
      normalized_alias,
      language_code
    ),

  constraint taxon_aliases_alias_check
    check (
      normalized_alias <> ''
      and char_length(alias) <= 200
    ),

  constraint taxon_aliases_alias_type_check
    check (
      alias_type in (
        'COMMON_NAME',
        'SYNONYM',
        'HISTORICAL_NAME',
        'LOCAL_NAME'
      )
    ),

  constraint taxon_aliases_language_code_check
    check (
      language_code is null
      or (
        char_length(language_code) <= 35
        and language_code ~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
      )
    ),

  constraint taxon_aliases_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint taxon_aliases_row_version_check
    check (row_version >= 1)
);

create index taxon_aliases_normalized_alias_idx
  on public.taxon_aliases(normalized_alias);

create trigger taxon_aliases_set_updated_at_and_row_version
before update on public.taxon_aliases
for each row
execute function public.set_updated_at_and_row_version();

alter table public.taxon_aliases
  enable row level security;

revoke all privileges
  on table public.taxon_aliases
  from public, anon, authenticated;

grant select
  on table public.taxon_aliases
  to authenticated;

create policy taxon_aliases_select_authenticated
  on public.taxon_aliases
  for select
  to authenticated
  using (true);

comment on table public.taxon_aliases is
  'Nomi alternativi verificati delle identita botaniche globali.';

comment on column public.taxon_aliases.normalized_alias is
  'Chiave normalizzata generata dal database per unicita e ricerca esatta.';

comment on column public.taxon_aliases.language_code is
  'Codice linguistico semplificato in minuscolo; NULL indica lingua non specificata.';

comment on column public.taxon_aliases.is_active is
  'Disponibilita per nuovi utilizzi; la disattivazione non libera la chiave univoca.';


-- ============================================================================
-- 2. CROP ALIASES
-- ============================================================================

create table public.crop_aliases (
  id uuid primary key default gen_random_uuid(),

  crop_id uuid not null,

  alias text not null,

  normalized_alias text
    generated always as (
      private.normalize_catalog_text(alias)
    ) stored not null,

  alias_type text not null,
  language_code text null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint crop_aliases_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint crop_aliases_identity_unique
    unique nulls not distinct (
      crop_id,
      normalized_alias,
      language_code
    ),

  constraint crop_aliases_alias_check
    check (
      normalized_alias <> ''
      and char_length(alias) <= 200
    ),

  constraint crop_aliases_alias_type_check
    check (
      alias_type in (
        'COMMON_NAME',
        'SYNONYM',
        'HISTORICAL_NAME',
        'LOCAL_NAME'
      )
    ),

  constraint crop_aliases_language_code_check
    check (
      language_code is null
      or (
        char_length(language_code) <= 35
        and language_code ~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
      )
    ),

  constraint crop_aliases_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint crop_aliases_row_version_check
    check (row_version >= 1)
);

create index crop_aliases_normalized_alias_idx
  on public.crop_aliases(normalized_alias);

create trigger crop_aliases_set_updated_at_and_row_version
before update on public.crop_aliases
for each row
execute function public.set_updated_at_and_row_version();

alter table public.crop_aliases
  enable row level security;

revoke all privileges
  on table public.crop_aliases
  from public, anon, authenticated;

grant select
  on table public.crop_aliases
  to authenticated;

create policy crop_aliases_select_authenticated
  on public.crop_aliases
  for select
  to authenticated
  using (true);

comment on table public.crop_aliases is
  'Nomi alternativi verificati delle identita agronomiche Crop globali.';

comment on column public.crop_aliases.crop_id is
  'Crop globale; riferimento tecnico catalog_crops_s030 fino al cutover della Tranche 11.';

comment on column public.crop_aliases.normalized_alias is
  'Chiave normalizzata generata dal database; lo stesso alias puo riferirsi a Crop differenti.';

comment on column public.crop_aliases.language_code is
  'Codice linguistico semplificato in minuscolo; NULL indica lingua non specificata.';

comment on column public.crop_aliases.is_active is
  'Disponibilita per nuovi utilizzi; la disattivazione non libera la chiave univoca.';


-- ============================================================================
-- 3. CULTIVAR ALIASES
-- ============================================================================

create table public.cultivar_aliases (
  id uuid primary key default gen_random_uuid(),

  cultivar_id uuid not null,

  alias text not null,

  normalized_alias text
    generated always as (
      private.normalize_catalog_text(alias)
    ) stored not null,

  alias_type text not null,
  language_code text null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint cultivar_aliases_cultivar_id_fkey
    foreign key (cultivar_id)
    references public.crop_cultivars(id)
    on delete restrict,

  constraint cultivar_aliases_identity_unique
    unique nulls not distinct (
      cultivar_id,
      normalized_alias,
      language_code
    ),

  constraint cultivar_aliases_alias_check
    check (
      normalized_alias <> ''
      and char_length(alias) <= 200
    ),

  constraint cultivar_aliases_alias_type_check
    check (
      alias_type in (
        'COMMON_NAME',
        'SYNONYM',
        'HISTORICAL_NAME',
        'LOCAL_NAME'
      )
    ),

  constraint cultivar_aliases_language_code_check
    check (
      language_code is null
      or (
        char_length(language_code) <= 35
        and language_code ~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
      )
    ),

  constraint cultivar_aliases_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint cultivar_aliases_row_version_check
    check (row_version >= 1)
);

create index cultivar_aliases_normalized_alias_idx
  on public.cultivar_aliases(normalized_alias);

create trigger cultivar_aliases_set_updated_at_and_row_version
before update on public.cultivar_aliases
for each row
execute function public.set_updated_at_and_row_version();

alter table public.cultivar_aliases
  enable row level security;

revoke all privileges
  on table public.cultivar_aliases
  from public, anon, authenticated;

grant select
  on table public.cultivar_aliases
  to authenticated;

create policy cultivar_aliases_select_authenticated
  on public.cultivar_aliases
  for select
  to authenticated
  using (true);

comment on table public.cultivar_aliases is
  'Nomi alternativi verificati delle Cultivar; non rappresentano offerte commerciali.';

comment on column public.cultivar_aliases.normalized_alias is
  'Chiave normalizzata generata dal database per unicita e ricerca esatta.';

comment on column public.cultivar_aliases.language_code is
  'Codice linguistico semplificato in minuscolo; NULL indica lingua non specificata.';

comment on column public.cultivar_aliases.is_active is
  'Disponibilita per nuovi utilizzi; la disattivazione non libera la chiave univoca.';
