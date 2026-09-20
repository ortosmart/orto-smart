-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 1 - AUTHORITY E IDENTITA GLOBALI
-- ============================================================================
--
-- Introduce:
-- - normalizzazione canonica dei testi del Catalogo;
-- - Catalog Authority indipendente dai Profile;
-- - tassonomia botanica globale;
-- - identita agronomiche globali Crop e Cultivar.
--
-- Il Catalogo S026 resta temporaneamente invariato.
-- La nuova tabella Crop usa il nome tecnico catalog_crops_s030
-- fino al cutover atomico previsto nella Tranche 11.
-- ============================================================================


-- ============================================================================
-- 1. NORMALIZZAZIONE CANONICA
-- ============================================================================

create function private.normalize_catalog_text(
  input_value text
)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $function$
  select pg_catalog.lower(
    pg_catalog.btrim(
      pg_catalog.regexp_replace(
        normalize(input_value, NFC),
        '[[:space:]]+',
        ' ',
        'g'
      )
    )
  );
$function$;

comment on function private.normalize_catalog_text(text) is
  'Normalizza le chiavi testuali del Catalogo: Unicode NFC, trim, spazi interni singoli e minuscolo.';

revoke all
  on function private.normalize_catalog_text(text)
  from public, anon, authenticated;



-- ============================================================================
-- 2. CATALOG AUTHORITIES
-- ============================================================================

create table public.catalog_authorities (
  auth_user_id uuid primary key
    references auth.users(id)
    on delete restrict,

  can_manage_identity boolean not null default false,
  can_ingest boolean not null default false,
  can_review boolean not null default false,
  can_publish boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint catalog_authorities_row_version_check
    check (row_version >= 1)
);

create trigger catalog_authorities_set_updated_at_and_row_version
before update on public.catalog_authorities
for each row
execute function public.set_updated_at_and_row_version();

alter table public.catalog_authorities
  enable row level security;

revoke all privileges
  on table public.catalog_authorities
  from public, anon, authenticated;

-- Nessuna policy diretta.
-- L'accesso avviene esclusivamente attraverso helper SECURITY DEFINER
-- e futuri Write Path autoritativi.


-- ============================================================================
-- 3. BOOTSTRAP INIZIALE CATALOG AUTHORITY
-- ============================================================================

do $bootstrap$
declare
  v_eligible_owner_count integer;
  v_owner_auth_user_id uuid;
begin
  select count(*)::integer
  into v_eligible_owner_count
  from public.profile_memberships pm
  where pm.role = 'owner'::public.profile_member_role
    and pm.is_enabled = true
    and pm.auth_user_id = pm.profile_id;

  if v_eligible_owner_count > 1 then
    raise exception using
      errcode = 'P0001',
      message = 'Catalog Authority bootstrap aborted: multiple eligible owners';
  end if;

  if v_eligible_owner_count = 1 then
    select pm.auth_user_id
    into v_owner_auth_user_id
    from public.profile_memberships pm
    where pm.role = 'owner'::public.profile_member_role
      and pm.is_enabled = true
      and pm.auth_user_id = pm.profile_id;

    insert into public.catalog_authorities (
      auth_user_id,
      can_manage_identity,
      can_ingest,
      can_review,
      can_publish
    )
    values (
      v_owner_auth_user_id,
      true,
      true,
      true,
      true
    );
  end if;
end;
$bootstrap$;

comment on table public.catalog_authorities is
  'Capability autoritative globali del Catalogo Agronomico, indipendenti da Profile e profile_edit_locks.';

comment on column public.catalog_authorities.auth_user_id is
  'Utente autenticato a cui sono assegnate le capability globali del Catalogo.';

comment on column public.catalog_authorities.can_manage_identity is
  'Consente la gestione delle identita botaniche, Crop, Cultivar e alias.';

comment on column public.catalog_authorities.can_ingest is
  'Consente acquisizione delle fonti e gestione delle observations.';

comment on column public.catalog_authorities.can_review is
  'Consente la revisione editoriale delle submissions.';

comment on column public.catalog_authorities.can_publish is
  'Consente la pubblicazione della Knowledge canonica.';



-- ============================================================================
-- 4. CATALOG AUTHORITY HELPERS
-- ============================================================================

create function private.can_manage_catalog_identity()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.catalog_authorities ca
    where ca.auth_user_id = auth.uid()
      and ca.can_manage_identity = true
  );
$function$;

create function private.can_ingest_catalog()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.catalog_authorities ca
    where ca.auth_user_id = auth.uid()
      and ca.can_ingest = true
  );
$function$;

create function private.can_review_catalog()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.catalog_authorities ca
    where ca.auth_user_id = auth.uid()
      and ca.can_review = true
  );
$function$;

create function private.can_publish_catalog()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.catalog_authorities ca
    where ca.auth_user_id = auth.uid()
      and ca.can_publish = true
  );
$function$;

revoke all
  on function private.can_manage_catalog_identity()
  from public, anon, authenticated;

revoke all
  on function private.can_ingest_catalog()
  from public, anon, authenticated;

revoke all
  on function private.can_review_catalog()
  from public, anon, authenticated;

revoke all
  on function private.can_publish_catalog()
  from public, anon, authenticated;

grant execute
  on function private.can_manage_catalog_identity()
  to authenticated;

grant execute
  on function private.can_ingest_catalog()
  to authenticated;

grant execute
  on function private.can_review_catalog()
  to authenticated;

grant execute
  on function private.can_publish_catalog()
  to authenticated;

comment on function private.can_manage_catalog_identity() is
  'Restituisce true se auth.uid() puo gestire le identita globali del Catalogo.';

comment on function private.can_ingest_catalog() is
  'Restituisce true se auth.uid() puo acquisire fonti e observations del Catalogo.';

comment on function private.can_review_catalog() is
  'Restituisce true se auth.uid() puo revisionare le submissions del Catalogo.';

comment on function private.can_publish_catalog() is
  'Restituisce true se auth.uid() puo pubblicare la Knowledge canonica.';



-- ============================================================================
-- 5. BOTANICAL TAXA
-- ============================================================================

create table public.botanical_taxa (
  id uuid primary key default gen_random_uuid(),

  parent_taxon_id uuid null,

  rank text not null,
  scientific_name text not null,
  authorship text null,

  normalized_scientific_name text
    generated always as (
      private.normalize_catalog_text(scientific_name)
    ) stored not null,

  normalized_authorship text
    generated always as (
      private.normalize_catalog_text(authorship)
    ) stored,

  is_hybrid boolean not null default false,

  description text null,
  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint botanical_taxa_parent_taxon_id_fkey
    foreign key (parent_taxon_id)
    references public.botanical_taxa(id)
    on delete restrict,

  constraint botanical_taxa_rank_check
    check (
      rank in (
        'ORDER',
        'FAMILY',
        'GENUS',
        'SPECIES',
        'SUBSPECIES',
        'VARIETY',
        'FORMA',
        'UNRANKED'
      )
    ),

  constraint botanical_taxa_not_self_parent_check
    check (
      parent_taxon_id is null
      or parent_taxon_id <> id
    ),

  constraint botanical_taxa_scientific_name_check
    check (
      normalized_scientific_name <> ''
      and char_length(scientific_name) <= 200
    ),

  constraint botanical_taxa_authorship_check
    check (
      authorship is null
      or (
        normalized_authorship <> ''
        and char_length(authorship) <= 200
      )
    ),

  constraint botanical_taxa_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint botanical_taxa_row_version_check
    check (row_version >= 1),

  constraint botanical_taxa_identity_unique
    unique nulls not distinct (
      rank,
      normalized_scientific_name,
      normalized_authorship
    )
);

create index botanical_taxa_parent_taxon_id_idx
  on public.botanical_taxa(parent_taxon_id)
  where parent_taxon_id is not null;

create trigger botanical_taxa_set_updated_at_and_row_version
before update on public.botanical_taxa
for each row
execute function public.set_updated_at_and_row_version();

alter table public.botanical_taxa
  enable row level security;

revoke all privileges
  on table public.botanical_taxa
  from public, anon, authenticated;

grant select
  on table public.botanical_taxa
  to authenticated;

create policy botanical_taxa_select_authenticated
  on public.botanical_taxa
  for select
  to authenticated
  using (true);

comment on table public.botanical_taxa is
  'Tassonomia botanica globale del Catalogo Agronomico.';

comment on column public.botanical_taxa.parent_taxon_id is
  'Taxon superiore piu vicino presente nel Catalogo, non necessariamente il rango scientifico immediatamente precedente.';

comment on column public.botanical_taxa.rank is
  'Rango botanico V1; HYBRID non e un rango.';

comment on column public.botanical_taxa.scientific_name is
  'Nome scientifico conservato nella forma editoriale canonica.';

comment on column public.botanical_taxa.authorship is
  'Autore botanico facoltativo, separato dal nome scientifico.';

comment on column public.botanical_taxa.normalized_scientific_name is
  'Chiave normalizzata generata dal database per identita e unicita.';

comment on column public.botanical_taxa.normalized_authorship is
  'Authorship normalizzata generata dal database; NULL resta semanticamente significativo.';

comment on column public.botanical_taxa.is_hybrid is
  'Indica natura ibrida del taxon senza introdurre HYBRID come rango.';



-- ============================================================================
-- 6. GLOBAL CROPS - NOME TECNICO TEMPORANEO S030
-- ============================================================================

create table public.catalog_crops_s030 (
  id uuid primary key default gen_random_uuid(),

  taxon_id uuid not null,

  canonical_name text not null,

  normalized_canonical_name text
    generated always as (
      private.normalize_catalog_text(canonical_name)
    ) stored not null,

  description text null,
  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint catalog_crops_s030_taxon_id_fkey
    foreign key (taxon_id)
    references public.botanical_taxa(id)
    on delete restrict,

  constraint catalog_crops_s030_canonical_name_check
    check (
      normalized_canonical_name <> ''
      and char_length(canonical_name) <= 120
    ),

  constraint catalog_crops_s030_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint catalog_crops_s030_row_version_check
    check (row_version >= 1),

  constraint catalog_crops_s030_normalized_canonical_name_key
    unique (normalized_canonical_name)
);

create index catalog_crops_s030_taxon_id_idx
  on public.catalog_crops_s030(taxon_id);

create trigger catalog_crops_s030_set_updated_at_and_row_version
before update on public.catalog_crops_s030
for each row
execute function public.set_updated_at_and_row_version();

alter table public.catalog_crops_s030
  enable row level security;

revoke all privileges
  on table public.catalog_crops_s030
  from public, anon, authenticated;

grant select
  on table public.catalog_crops_s030
  to authenticated;

create policy catalog_crops_s030_select_authenticated
  on public.catalog_crops_s030
  for select
  to authenticated
  using (true);

comment on table public.catalog_crops_s030 is
  'Identita agronomiche Crop globali. Nome tecnico temporaneo fino al cutover S030 Tranche 11.';

comment on column public.catalog_crops_s030.taxon_id is
  'Taxon botanico di riferimento; uno stesso taxon puo supportare piu Crop.';

comment on column public.catalog_crops_s030.canonical_name is
  'Nome agronomico canonico globale del Crop.';

comment on column public.catalog_crops_s030.normalized_canonical_name is
  'Chiave normalizzata generata dal database e univoca globalmente.';



-- ============================================================================
-- 7. CROP CULTIVARS
-- ============================================================================

create table public.crop_cultivars (
  id uuid primary key default gen_random_uuid(),

  crop_id uuid not null,

  canonical_name text not null,

  normalized_canonical_name text
    generated always as (
      private.normalize_catalog_text(canonical_name)
    ) stored not null,

  verification_status text not null default 'PROVISIONAL',

  description text null,
  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint crop_cultivars_crop_id_fkey
    foreign key (crop_id)
    references public.catalog_crops_s030(id)
    on delete restrict,

  constraint crop_cultivars_verification_status_check
    check (
      verification_status in (
        'VERIFIED',
        'PROVISIONAL',
        'AMBIGUOUS'
      )
    ),

  constraint crop_cultivars_canonical_name_check
    check (
      normalized_canonical_name <> ''
      and char_length(canonical_name) <= 120
    ),

  constraint crop_cultivars_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint crop_cultivars_row_version_check
    check (row_version >= 1),

  constraint crop_cultivars_crop_name_unique
    unique (
      crop_id,
      normalized_canonical_name
    ),

  constraint crop_cultivars_id_crop_unique
    unique (
      id,
      crop_id
    )
);

create trigger crop_cultivars_set_updated_at_and_row_version
before update on public.crop_cultivars
for each row
execute function public.set_updated_at_and_row_version();

alter table public.crop_cultivars
  enable row level security;

revoke all privileges
  on table public.crop_cultivars
  from public, anon, authenticated;

grant select
  on table public.crop_cultivars
  to authenticated;

create policy crop_cultivars_select_authenticated
  on public.crop_cultivars
  for select
  to authenticated
  using (true);

comment on table public.crop_cultivars is
  'Cultivar globali collegate alle identita agronomiche Crop.';

comment on column public.crop_cultivars.crop_id is
  'Crop globale di appartenenza della Cultivar.';

comment on column public.crop_cultivars.canonical_name is
  'Nome canonico della Cultivar nel relativo Crop.';

comment on column public.crop_cultivars.normalized_canonical_name is
  'Chiave normalizzata generata dal database e univoca nel Crop.';

comment on column public.crop_cultivars.verification_status is
  'Stato identitario della Cultivar: VERIFIED, PROVISIONAL o AMBIGUOUS.';
