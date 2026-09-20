-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 3 - VOCABOLARI DI CONTESTO
-- ============================================================================
--
-- Introduce:
-- - contesti produttivi;
-- - contesti di protezione;
-- - contesti di allevamento;
-- - finalita della raccolta.
--
-- I quattro vocabolari restano separati perché rappresentano dimensioni
-- semantiche differenti.
--
-- Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. PRODUCTION CONTEXTS
-- ============================================================================

create table public.production_contexts (
  id uuid
    constraint production_contexts_pkey
    primary key
    default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint production_contexts_code_key
    unique (code),

  constraint production_contexts_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint production_contexts_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint production_contexts_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint production_contexts_row_version_check
    check (row_version >= 1)
);

create trigger production_contexts_set_updated_at_and_row_version
before update on public.production_contexts
for each row
execute function public.set_updated_at_and_row_version();

alter table public.production_contexts
  enable row level security;

revoke all privileges
  on table public.production_contexts
  from public, anon, authenticated;

grant select
  on table public.production_contexts
  to authenticated;

create policy production_contexts_select_authenticated
  on public.production_contexts
  for select
  to authenticated
  using (true);

comment on table public.production_contexts is
  'Vocabolario globale dei sistemi produttivi e delle modalita generali di coltivazione.';

comment on column public.production_contexts.code is
  'Codice tecnico stabile e univoco del contesto produttivo.';

comment on column public.production_contexts.name is
  'Nome editoriale del contesto produttivo.';

comment on column public.production_contexts.is_active is
  'Indica se il contesto e disponibile per nuovi utilizzi.';


-- ============================================================================
-- 2. PROTECTION CONTEXTS
-- ============================================================================

create table public.protection_contexts (
  id uuid
    constraint protection_contexts_pkey
    primary key
    default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint protection_contexts_code_key
    unique (code),

  constraint protection_contexts_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint protection_contexts_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint protection_contexts_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint protection_contexts_row_version_check
    check (row_version >= 1)
);

create trigger protection_contexts_set_updated_at_and_row_version
before update on public.protection_contexts
for each row
execute function public.set_updated_at_and_row_version();

alter table public.protection_contexts
  enable row level security;

revoke all privileges
  on table public.protection_contexts
  from public, anon, authenticated;

grant select
  on table public.protection_contexts
  to authenticated;

create policy protection_contexts_select_authenticated
  on public.protection_contexts
  for select
  to authenticated
  using (true);

comment on table public.protection_contexts is
  'Vocabolario globale degli ambienti e delle protezioni fisiche di coltivazione.';

comment on column public.protection_contexts.code is
  'Codice tecnico stabile e univoco del contesto di protezione.';

comment on column public.protection_contexts.name is
  'Nome editoriale del contesto di protezione.';

comment on column public.protection_contexts.is_active is
  'Indica se il contesto e disponibile per nuovi utilizzi.';


-- ============================================================================
-- 3. TRAINING CONTEXTS
-- ============================================================================

create table public.training_contexts (
  id uuid
    constraint training_contexts_pkey
    primary key
    default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint training_contexts_code_key
    unique (code),

  constraint training_contexts_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint training_contexts_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint training_contexts_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint training_contexts_row_version_check
    check (row_version >= 1)
);

create trigger training_contexts_set_updated_at_and_row_version
before update on public.training_contexts
for each row
execute function public.set_updated_at_and_row_version();

alter table public.training_contexts
  enable row level security;

revoke all privileges
  on table public.training_contexts
  from public, anon, authenticated;

grant select
  on table public.training_contexts
  to authenticated;

create policy training_contexts_select_authenticated
  on public.training_contexts
  for select
  to authenticated
  using (true);

comment on table public.training_contexts is
  'Vocabolario globale delle forme di allevamento e dei sostegni delle colture.';

comment on column public.training_contexts.code is
  'Codice tecnico stabile e univoco del contesto di allevamento.';

comment on column public.training_contexts.name is
  'Nome editoriale del contesto di allevamento.';

comment on column public.training_contexts.is_active is
  'Indica se il contesto e disponibile per nuovi utilizzi.';


-- ============================================================================
-- 4. HARVEST PURPOSES
-- ============================================================================

create table public.harvest_purposes (
  id uuid
    constraint harvest_purposes_pkey
    primary key
    default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint harvest_purposes_code_key
    unique (code),

  constraint harvest_purposes_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint harvest_purposes_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint harvest_purposes_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint harvest_purposes_row_version_check
    check (row_version >= 1)
);

create trigger harvest_purposes_set_updated_at_and_row_version
before update on public.harvest_purposes
for each row
execute function public.set_updated_at_and_row_version();

alter table public.harvest_purposes
  enable row level security;

revoke all privileges
  on table public.harvest_purposes
  from public, anon, authenticated;

grant select
  on table public.harvest_purposes
  to authenticated;

create policy harvest_purposes_select_authenticated
  on public.harvest_purposes
  for select
  to authenticated
  using (true);

comment on table public.harvest_purposes is
  'Vocabolario globale delle finalita agronomiche della raccolta.';

comment on column public.harvest_purposes.code is
  'Codice tecnico stabile e univoco della finalita di raccolta.';

comment on column public.harvest_purposes.name is
  'Nome editoriale della finalita di raccolta.';

comment on column public.harvest_purposes.is_active is
  'Indica se la finalita e disponibile per nuovi utilizzi.';
