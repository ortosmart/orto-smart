-- ============================================================================
-- BEDS E STORICO DELLE GEOMETRIE
-- ============================================================================
-- Sessione S024.
-- Nessuna importazione dei dati legacy di prova.
-- Le scritture applicative saranno esposte esclusivamente tramite RPC.

-- ============================================================================
-- 1. ESTENSIONE PER I VINCOLI TEMPORALI
-- ============================================================================

create schema if not exists extensions;

create extension if not exists btree_gist
  with schema extensions;

-- ============================================================================
-- 2. IDENTITÀ STABILE DELLE AIUOLE
-- ============================================================================

create table public.beds (
  id uuid primary key default gen_random_uuid(),

  garden_id uuid not null
    references public.gardens(id)
    on delete restrict,

  number integer not null,
  name text null,
  notes text null,

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint beds_garden_number_unique
    unique (garden_id, number),

  constraint beds_number_positive_check
    check (number > 0),

  constraint beds_name_not_blank_check
    check (name is null or btrim(name) <> ''),

  constraint beds_notes_not_blank_check
    check (notes is null or btrim(notes) <> ''),

  constraint beds_row_version_check
    check (row_version >= 1)
);

-- Il numero resta riservato anche quando l'aiuola è disabilitata.
-- Codice visualizzato, dimensioni e area non sono duplicati in questa tabella.

create trigger beds_set_updated_at_and_row_version
before update on public.beds
for each row
execute function public.set_updated_at_and_row_version();

-- ============================================================================
-- 3. SICUREZZA BEDS
-- ============================================================================

alter table public.beds enable row level security;

revoke all privileges
  on table public.beds
  from public, anon, authenticated;

grant select
  on table public.beds
  to authenticated;

create policy beds_select_member
  on public.beds
  for select
  to authenticated
  using (
    private.can_access_garden(garden_id)
  );

-- Nessuna policy di scrittura e nessun privilegio diretto INSERT/UPDATE/DELETE
-- per authenticated. Le future RPC applicheranno la Profile Write Authority.

-- ============================================================================
-- 4. GEOMETRIE DELLE AIUOLE VALIDE NEL TEMPO
-- ============================================================================

create table public.bed_geometries (
  id uuid primary key default gen_random_uuid(),

  bed_id uuid not null
    references public.beds(id)
    on delete restrict,

  width_cm integer not null,
  length_cm integer not null,

  valid_from date not null,
  valid_to date null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  row_version bigint not null default 1,

  constraint bed_geometries_width_positive_check
    check (width_cm > 0),

  constraint bed_geometries_length_positive_check
    check (length_cm > 0),

  constraint bed_geometries_finite_dates_check
    check (
      isfinite(valid_from)
      and (valid_to is null or isfinite(valid_to))
    ),

  constraint bed_geometries_valid_interval_check
    check (
      valid_to is null
      or valid_to > valid_from
    ),

  constraint bed_geometries_row_version_check
    check (row_version >= 1),

  constraint bed_geometries_no_overlap
    exclude using gist (
      bed_id extensions.gist_uuid_ops with =,
      (daterange(valid_from, valid_to, '[)')) with &&
    )
    deferrable initially immediate
);

-- Il vincolo di esclusione impedisce anche la presenza di due intervalli
-- aperti per la stessa aiuola: entrambi si sovrapporrebbero.
--
-- La differibilità permette alle future RPC di rettifica di modificare
-- atomicamente più intervalli, verificando il risultato prima del commit.
--
-- Continuità della sequenza e divieto di date iniziali future saranno
-- verificati dalle RPC secondo la timezone del Garden.

create trigger bed_geometries_set_updated_at_and_row_version
before update on public.bed_geometries
for each row
execute function public.set_updated_at_and_row_version();

-- ============================================================================
-- 5. SICUREZZA BED_GEOMETRIES
-- ============================================================================

alter table public.bed_geometries enable row level security;

revoke all privileges
  on table public.bed_geometries
  from public, anon, authenticated;

grant select
  on table public.bed_geometries
  to authenticated;

create policy bed_geometries_select_member
  on public.bed_geometries
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.beds b
      where b.id = bed_geometries.bed_id
    )
  );

-- La lettura attraversa public.beds e la relativa policy RLS:
-- una geometria è visibile soltanto se lo è l'aiuola di appartenenza.
--
-- Nessuna scrittura diretta consentita al client.
-- Le future RPC aggiorneranno anche beds.row_version nella stessa transazione.

-- ============================================================================
-- 6. REGISTRO TECNICO DELLE RETTIFICHE GEOMETRICHE
-- ============================================================================
-- Un record per operazione di rettifica, anche quando coinvolge più geometrie.
-- Snapshot, autore e versioni saranno determinati dalla RPC server-side.

create table public.bed_geometry_corrections (
  id uuid primary key default gen_random_uuid(),

  bed_id uuid not null
    references public.beds(id)
    on delete restrict,

  -- Identificativo storico dell'autore, ricavato dalla RPC tramite auth.uid().
  -- Non viene eliminato se l'account viene successivamente rimosso.
  actor_auth_user_id uuid not null,

  created_at timestamptz not null default clock_timestamp(),

  reason text not null,

  before_state jsonb not null,
  after_state jsonb not null,

  bed_version_before bigint not null,
  bed_version_after bigint not null,

  constraint bed_geometry_corrections_reason_not_blank_check
    check (btrim(reason) <> ''),

  constraint bed_geometry_corrections_before_state_check
    check (
      jsonb_typeof(before_state) = 'array'
      and before_state <> '[]'::jsonb
    ),

  constraint bed_geometry_corrections_after_state_check
    check (
      jsonb_typeof(after_state) = 'array'
      and after_state <> '[]'::jsonb
    ),

  constraint bed_geometry_corrections_state_changed_check
    check (before_state <> after_state),

  constraint bed_geometry_corrections_versions_check
    check (
      bed_version_before >= 1
      and bed_version_after = bed_version_before + 1
    ),

  constraint bed_geometry_corrections_bed_version_unique
    unique (bed_id, bed_version_after)
);

-- Nessun trigger metadata di aggiornamento:
-- una rettifica registrata non deve essere modificata.
--
-- Gli snapshot contengono soltanto le geometrie coinvolte.
-- La loro struttura interna sarà costruita e verificata dalla RPC.

-- ============================================================================
-- 7. SICUREZZA BED_GEOMETRY_CORRECTIONS
-- ============================================================================

alter table public.bed_geometry_corrections enable row level security;

revoke all privileges
  on table public.bed_geometry_corrections
  from public, anon, authenticated;

grant select
  on table public.bed_geometry_corrections
  to authenticated;

create policy bed_geometry_corrections_select_member
  on public.bed_geometry_corrections
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.beds b
      where b.id = bed_geometry_corrections.bed_id
    )
  );

-- La consultazione segue l'accessibilità dell'aiuola tramite RLS.
-- Eseguire rettifiche sarà invece riservato all'owner attivo del Profile,
-- attraverso una RPC con Profile Write Authority valida.
--
-- Nessun INSERT, UPDATE o DELETE diretto è concesso al client,
-- nemmeno quando l'utente autenticato è owner del Profile.

-- ============================================================================
-- 8. PROTEZIONE APPEND-ONLY DEL REGISTRO DELLE RETTIFICHE
-- ============================================================================
-- Una rettifica errata si corregge mediante una nuova operazione tracciata.
-- I record di audit già registrati non vengono aggiornati o rimossi.

create or replace function private.prevent_bed_geometry_correction_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception
    'bed_geometry_corrections is append-only'
    using errcode = '55000';
end;
$$;

revoke all
  on function private.prevent_bed_geometry_correction_mutation()
  from public, anon, authenticated;

create trigger bed_geometry_corrections_reject_update_delete
before update or delete on public.bed_geometry_corrections
for each row
execute function private.prevent_bed_geometry_correction_mutation();

create trigger bed_geometry_corrections_reject_truncate
before truncate on public.bed_geometry_corrections
for each statement
execute function private.prevent_bed_geometry_correction_mutation();

-- ============================================================================
-- FINE INCREMENTO STRUTTURALE
-- ============================================================================
-- Le RPC autoritative saranno introdotte in un incremento successivo.
-- In questa fase tutte le scritture applicative sulle nuove tabelle sono negate.
