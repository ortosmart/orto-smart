-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 2 - UNITS E PARAMETER REGISTRY
-- ============================================================================
--
-- Introduce:
-- - unita di misura dimensionalmente controllate;
-- - registry dei parametri agronomici;
-- - valori ammessi per parametri ENUM;
-- - integrita bidirezionale tra Parameter ed Enum Value.
--
-- Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. MEASUREMENT UNITS
-- ============================================================================

create table public.measurement_units (
  id uuid primary key default gen_random_uuid(),

  code text not null,
  name text not null,
  symbol text not null,

  quantity_kind text not null,

  to_base_factor numeric not null,
  to_base_offset numeric not null default 0,

  description text null,
  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint measurement_units_code_key
    unique (code),

  constraint measurement_units_id_quantity_kind_unique
    unique (
      id,
      quantity_kind
    ),

  constraint measurement_units_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,49}$'
    ),

  constraint measurement_units_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint measurement_units_symbol_check
    check (
      private.normalize_catalog_text(symbol) <> ''
      and char_length(symbol) <= 30
    ),

  constraint measurement_units_quantity_kind_check
    check (
      quantity_kind ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint measurement_units_factor_check
    check (
      to_base_factor > 0
      and to_base_factor not in (
        'NaN'::numeric,
        'Infinity'::numeric,
        '-Infinity'::numeric
      )
    ),

  constraint measurement_units_offset_check
    check (
      to_base_offset not in (
        'NaN'::numeric,
        'Infinity'::numeric,
        '-Infinity'::numeric
      )
    ),

  constraint measurement_units_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint measurement_units_row_version_check
    check (row_version >= 1)
);

create index measurement_units_quantity_kind_idx
  on public.measurement_units(quantity_kind);

create trigger measurement_units_set_updated_at_and_row_version
before update on public.measurement_units
for each row
execute function public.set_updated_at_and_row_version();

alter table public.measurement_units
  enable row level security;

revoke all privileges
  on table public.measurement_units
  from public, anon, authenticated;

grant select
  on table public.measurement_units
  to authenticated;

create policy measurement_units_select_authenticated
  on public.measurement_units
  for select
  to authenticated
  using (true);

comment on table public.measurement_units is
  'Unita di misura globali con conversione dimensionalmente sicura verso una base convenzionale.';

comment on column public.measurement_units.code is
  'Codice tecnico stabile e univoco dell unita.';

comment on column public.measurement_units.quantity_kind is
  'Dimensione fisica o agronomica utilizzata per impedire conversioni incompatibili.';

comment on column public.measurement_units.to_base_factor is
  'Fattore della formula base_value = value * to_base_factor + to_base_offset.';

comment on column public.measurement_units.to_base_offset is
  'Offset della formula base_value = value * to_base_factor + to_base_offset.';



-- ============================================================================
-- 2. AGRONOMIC PARAMETERS
-- ============================================================================

create table public.agronomic_parameters (
  id uuid primary key default gen_random_uuid(),

  code text not null,
  name text not null,
  description text null,

  value_schema text not null,
  knowledge_scope text not null,

  quantity_kind text null,
  canonical_unit_id uuid null,

  allows_crop boolean not null default true,
  allows_cultivar boolean not null default false,

  allows_production_context boolean not null default false,
  allows_protection_context boolean not null default false,
  allows_training_context boolean not null default false,
  allows_harvest_purpose boolean not null default false,

  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint agronomic_parameters_code_key
    unique (code),

  constraint agronomic_parameters_canonical_unit_fk
    foreign key (
      canonical_unit_id,
      quantity_kind
    )
    references public.measurement_units (
      id,
      quantity_kind
    )
    on delete restrict,

  constraint agronomic_parameters_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint agronomic_parameters_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint agronomic_parameters_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint agronomic_parameters_value_schema_check
    check (
      value_schema in (
        'NUMERIC_SCALAR',
        'NUMERIC_RANGE',
        'BOOLEAN',
        'ENUM'
      )
    ),

  constraint agronomic_parameters_knowledge_scope_check
    check (
      knowledge_scope in (
        'INTRINSIC',
        'CONTEXTUAL'
      )
    ),

  constraint agronomic_parameters_target_check
    check (
      allows_crop = true
      or allows_cultivar = true
    ),

  constraint agronomic_parameters_value_unit_check
    check (
      (
        value_schema in (
          'NUMERIC_SCALAR',
          'NUMERIC_RANGE'
        )
        and quantity_kind is not null
        and quantity_kind ~ '^[A-Z][A-Z0-9_]{0,79}$'
        and canonical_unit_id is not null
      )
      or
      (
        value_schema in (
          'BOOLEAN',
          'ENUM'
        )
        and quantity_kind is null
        and canonical_unit_id is null
      )
    ),

  constraint agronomic_parameters_context_scope_check
    check (
      (
        knowledge_scope = 'INTRINSIC'
        and allows_production_context = false
        and allows_protection_context = false
        and allows_training_context = false
        and allows_harvest_purpose = false
      )
      or
      (
        knowledge_scope = 'CONTEXTUAL'
        and (
          allows_production_context = true
          or allows_protection_context = true
          or allows_training_context = true
          or allows_harvest_purpose = true
        )
      )
    ),

  constraint agronomic_parameters_row_version_check
    check (row_version >= 1)
);

create index agronomic_parameters_canonical_unit_id_idx
  on public.agronomic_parameters(canonical_unit_id)
  where canonical_unit_id is not null;

create trigger agronomic_parameters_set_updated_at_and_row_version
before update on public.agronomic_parameters
for each row
execute function public.set_updated_at_and_row_version();

alter table public.agronomic_parameters
  enable row level security;

revoke all privileges
  on table public.agronomic_parameters
  from public, anon, authenticated;

grant select
  on table public.agronomic_parameters
  to authenticated;

create policy agronomic_parameters_select_authenticated
  on public.agronomic_parameters
  for select
  to authenticated
  using (true);

comment on table public.agronomic_parameters is
  'Registry controllato dei parametri della Knowledge agronomica.';

comment on column public.agronomic_parameters.code is
  'Codice tecnico stabile e univoco del parametro.';

comment on column public.agronomic_parameters.value_schema is
  'Schema del valore: NUMERIC_SCALAR, NUMERIC_RANGE, BOOLEAN o ENUM.';

comment on column public.agronomic_parameters.knowledge_scope is
  'Scope semantico: INTRINSIC oppure CONTEXTUAL.';

comment on column public.agronomic_parameters.quantity_kind is
  'Dimensione richiesta per i parametri numerici; NULL per BOOLEAN ed ENUM.';

comment on column public.agronomic_parameters.canonical_unit_id is
  'Unita canonica obbligatoria per i parametri numerici.';

comment on column public.agronomic_parameters.allows_crop is
  'Indica se il parametro puo essere applicato a un Crop.';

comment on column public.agronomic_parameters.allows_cultivar is
  'Indica se il parametro puo essere applicato a una Cultivar.';



-- ============================================================================
-- 3. PARAMETER ENUM VALUES
-- ============================================================================

create table public.parameter_enum_values (
  id uuid primary key default gen_random_uuid(),

  parameter_id uuid not null,

  code text not null,
  name text not null,
  description text null,

  sort_order integer not null default 0,
  is_active boolean not null default true,

  row_version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint parameter_enum_values_parameter_id_fkey
    foreign key (parameter_id)
    references public.agronomic_parameters(id)
    on delete restrict,

  constraint parameter_enum_values_parameter_code_unique
    unique (
      parameter_id,
      code
    ),

  constraint parameter_enum_values_id_parameter_unique
    unique (
      id,
      parameter_id
    ),

  constraint parameter_enum_values_code_check
    check (
      code ~ '^[A-Z][A-Z0-9_]{0,79}$'
    ),

  constraint parameter_enum_values_name_check
    check (
      private.normalize_catalog_text(name) <> ''
      and char_length(name) <= 120
    ),

  constraint parameter_enum_values_description_check
    check (
      description is null
      or (
        private.normalize_catalog_text(description) <> ''
        and char_length(description) <= 1000
      )
    ),

  constraint parameter_enum_values_sort_order_check
    check (sort_order >= 0),

  constraint parameter_enum_values_row_version_check
    check (row_version >= 1)
);

create trigger parameter_enum_values_set_updated_at_and_row_version
before update on public.parameter_enum_values
for each row
execute function public.set_updated_at_and_row_version();

alter table public.parameter_enum_values
  enable row level security;

revoke all privileges
  on table public.parameter_enum_values
  from public, anon, authenticated;

grant select
  on table public.parameter_enum_values
  to authenticated;

create policy parameter_enum_values_select_authenticated
  on public.parameter_enum_values
  for select
  to authenticated
  using (true);

comment on table public.parameter_enum_values is
  'Valori controllati dei parametri agronomici con value_schema ENUM.';

comment on column public.parameter_enum_values.parameter_id is
  'Parametro ENUM di appartenenza.';

comment on column public.parameter_enum_values.code is
  'Codice tecnico stabile e univoco nel parametro.';

comment on column public.parameter_enum_values.sort_order is
  'Ordine editoriale; si raccomandano intervalli di 10.';


-- ============================================================================
-- 4. INTEGRITA PARAMETER / ENUM VALUE
-- ============================================================================

create function private.enforce_parameter_enum_parent()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if not exists (
    select 1
    from public.agronomic_parameters ap
    where ap.id = new.parameter_id
      and ap.value_schema = 'ENUM'
  ) then
    raise exception using
      errcode = '23514',
      constraint = 'parameter_enum_values_parent_schema_check',
      message = 'Parameter Enum Value requires a parent Parameter with value_schema ENUM';
  end if;

  return new;
end;
$function$;

create trigger parameter_enum_values_enforce_parent
before insert or update of parameter_id
on public.parameter_enum_values
for each row
execute function private.enforce_parameter_enum_parent();

create function private.prevent_parameter_enum_schema_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if new.value_schema <> 'ENUM'
     and exists (
       select 1
       from public.parameter_enum_values pev
       where pev.parameter_id = old.id
     ) then
    raise exception using
      errcode = '23514',
      constraint = 'agronomic_parameters_enum_schema_change_check',
      message = 'Cannot change value_schema from ENUM while Enum Values exist';
  end if;

  return new;
end;
$function$;

create trigger agronomic_parameters_prevent_enum_schema_change
before update of value_schema
on public.agronomic_parameters
for each row
execute function private.prevent_parameter_enum_schema_change();

revoke all
  on function private.enforce_parameter_enum_parent()
  from public, anon, authenticated;

revoke all
  on function private.prevent_parameter_enum_schema_change()
  from public, anon, authenticated;

comment on function private.enforce_parameter_enum_parent() is
  'Impedisce di collegare Enum Value a Parameter con value_schema diverso da ENUM.';

comment on function private.prevent_parameter_enum_schema_change() is
  'Impedisce di abbandonare value_schema ENUM finche esistono Enum Value collegati.';
