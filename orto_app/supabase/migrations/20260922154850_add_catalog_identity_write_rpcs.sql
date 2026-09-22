-- ============================================================================
-- ORTO SMART
-- S030 - CATALOGO AGRONOMICO V1
-- TRANCHE 9A - WRITE PATH AUTORITATIVO PER IDENTITA E ALIAS
-- ============================================================================
--
-- Introduce:
-- - pulizia editoriale coerente degli input testuali;
-- - protezione fisica contro cicli nella gerarchia botanica;
-- - RPC autoritative per Taxon, Crop, Cultivar e relativi Alias;
-- - optimistic concurrency tramite row_version;
-- - dipendenze attive coerenti durante creazione, spostamento e riattivazione.
--
-- Nessuna RPC usa Profile, profile_edit_lock, client_id o session_id.
-- L'attore e sempre auth.uid() e deve possedere can_manage_identity.
-- Nessun dato iniziale o dimostrativo viene inserito.
-- ============================================================================


-- ============================================================================
-- 1. NORMALIZZAZIONE EDITORIALE
-- ============================================================================

create function private.clean_catalog_display_text(
  input_value text
)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $function$
  select pg_catalog.regexp_replace(
    pg_catalog.btrim(
      normalize(input_value, NFC)
    ),
    '[[:space:]]+',
    ' ',
    'g'
  );
$function$;

comment on function private.clean_catalog_display_text(text) is
  'Normalizza testi brevi editoriali: Unicode NFC, trim e spazi interni singoli, preservando le maiuscole.';

revoke all
  on function private.clean_catalog_display_text(text)
  from public, anon, authenticated;


create function private.clean_catalog_description(
  input_value text
)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $function$
  select pg_catalog.btrim(
    normalize(input_value, NFC)
  );
$function$;

comment on function private.clean_catalog_description(text) is
  'Normalizza descrizioni editoriali: Unicode NFC e trim, preservando spazi interni e paragrafi.';

revoke all
  on function private.clean_catalog_description(text)
  from public, anon, authenticated;


-- ============================================================================
-- 2. CATALOG CROPS RPC
-- ============================================================================

create function public.create_catalog_crop(
  target_taxon_id uuid,
  crop_canonical_name text,
  crop_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_description text;
  v_taxon_is_active boolean;
  v_crop_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_canonical_name := private.clean_catalog_display_text(crop_canonical_name);
  v_description := nullif(
    private.clean_catalog_description(crop_description),
    ''
  );

  if target_taxon_id is null
     or v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_taxon_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_taxon_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.catalog_crops_s030 (
      taxon_id,
      canonical_name,
      description
    )
    values (
      target_taxon_id,
      v_canonical_name,
      v_description
    )
    returning id, row_version, created_at, updated_at
    into v_crop_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'catalog_crops_s030_normalized_canonical_name_key' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'catalog_crop_id', v_crop_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_catalog_crop(
  target_catalog_crop_id uuid,
  expected_row_version bigint,
  target_taxon_id uuid,
  crop_canonical_name text,
  crop_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_description text;
  v_taxon_is_active boolean;
  v_current public.catalog_crops_s030%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_catalog_crop_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_taxon_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.*
  into v_current
  from public.catalog_crops_s030 c
  where c.id = target_catalog_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'catalog_crop_id', target_catalog_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_canonical_name := private.clean_catalog_display_text(crop_canonical_name);
  v_description := nullif(
    private.clean_catalog_description(crop_description),
    ''
  );

  if v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_taxon_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_taxon_is_active
     and v_current.taxon_id is distinct from target_taxon_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.taxon_id = target_taxon_id
     and v_current.canonical_name = v_canonical_name
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'catalog_crop_id', target_catalog_crop_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.catalog_crops_s030
    set
      taxon_id = target_taxon_id,
      canonical_name = v_canonical_name,
      description = v_description
    where id = target_catalog_crop_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'catalog_crops_s030_normalized_canonical_name_key' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'catalog_crop_id', target_catalog_crop_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_catalog_crop_active(
  target_catalog_crop_id uuid,
  expected_row_version bigint,
  crop_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.catalog_crops_s030%rowtype;
  v_taxon_is_active boolean;
  v_active_cultivars_count bigint;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_catalog_crop_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or crop_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.*
  into v_current
  from public.catalog_crops_s030 c
  where c.id = target_catalog_crop_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'catalog_crop_id', target_catalog_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = crop_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'catalog_crop_id', target_catalog_crop_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if crop_is_active then
    select bt.is_active
    into v_taxon_is_active
    from public.botanical_taxa bt
    where bt.id = v_current.taxon_id
    for share;

    if not coalesce(v_taxon_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  else
    select count(*)
    into v_active_cultivars_count
    from public.crop_cultivars cv
    where cv.crop_id = target_catalog_crop_id
      and cv.is_active = true;

    if v_active_cultivars_count > 0 then
      return jsonb_build_object(
        'status', 'active_dependents',
        'dependent_type', 'crop_cultivars',
        'dependent_count', v_active_cultivars_count
      );
    end if;
  end if;

  update public.catalog_crops_s030
  set is_active = crop_is_active
  where id = target_catalog_crop_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'catalog_crop_id', target_catalog_crop_id,
    'is_active', crop_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


-- ============================================================================
-- 3. CROP CULTIVARS RPC
-- ============================================================================

create function public.create_crop_cultivar(
  target_crop_id uuid,
  cultivar_canonical_name text,
  cultivar_verification_status text,
  cultivar_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_verification_status text;
  v_description text;
  v_crop_is_active boolean;
  v_cultivar_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_canonical_name := private.clean_catalog_display_text(cultivar_canonical_name);
  v_verification_status := pg_catalog.upper(
    pg_catalog.btrim(cultivar_verification_status)
  );
  v_description := nullif(
    private.clean_catalog_description(cultivar_description),
    ''
  );

  if target_crop_id is null
     or v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or v_verification_status is null
     or v_verification_status not in ('VERIFIED', 'PROVISIONAL', 'AMBIGUOUS')
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_crop_is_active
  from public.catalog_crops_s030 c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_crop_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.crop_cultivars (
      crop_id,
      canonical_name,
      verification_status,
      description
    )
    values (
      target_crop_id,
      v_canonical_name,
      v_verification_status,
      v_description
    )
    returning id, row_version, created_at, updated_at
    into v_cultivar_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_cultivars_crop_name_unique' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'crop_cultivar_id', v_cultivar_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_crop_cultivar(
  target_crop_cultivar_id uuid,
  expected_row_version bigint,
  target_crop_id uuid,
  cultivar_canonical_name text,
  cultivar_verification_status text,
  cultivar_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_canonical_name text;
  v_verification_status text;
  v_description text;
  v_crop_is_active boolean;
  v_current public.crop_cultivars%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_cultivar_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_crop_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.*
  into v_current
  from public.crop_cultivars cv
  where cv.id = target_crop_cultivar_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_cultivar_id', target_crop_cultivar_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_canonical_name := private.clean_catalog_display_text(cultivar_canonical_name);
  v_verification_status := pg_catalog.upper(
    pg_catalog.btrim(cultivar_verification_status)
  );
  v_description := nullif(
    private.clean_catalog_description(cultivar_description),
    ''
  );

  if v_canonical_name is null
     or v_canonical_name = ''
     or char_length(v_canonical_name) > 120
     or v_verification_status is null
     or v_verification_status not in ('VERIFIED', 'PROVISIONAL', 'AMBIGUOUS')
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_crop_is_active
  from public.catalog_crops_s030 c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_crop_is_active
     and v_current.crop_id is distinct from target_crop_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.crop_id = target_crop_id
     and v_current.canonical_name = v_canonical_name
     and v_current.verification_status = v_verification_status
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_cultivar_id', target_crop_cultivar_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.crop_cultivars
    set
      crop_id = target_crop_id,
      canonical_name = v_canonical_name,
      verification_status = v_verification_status,
      description = v_description
    where id = target_crop_cultivar_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_cultivars_crop_name_unique' then
        return jsonb_build_object('status', 'duplicate_canonical_name');
      end if;

      raise;

    when foreign_key_violation then
      -- Le tabelle Knowledge usano la coppia (cultivar_id, crop_id).
      -- Una Cultivar gia referenziata non puo essere spostata tra Crop.
      return jsonb_build_object('status', 'identity_in_use');
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'crop_cultivar_id', target_crop_cultivar_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_crop_cultivar_active(
  target_crop_cultivar_id uuid,
  expected_row_version bigint,
  cultivar_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.crop_cultivars%rowtype;
  v_crop_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_cultivar_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or cultivar_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.*
  into v_current
  from public.crop_cultivars cv
  where cv.id = target_crop_cultivar_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_cultivar_id', target_crop_cultivar_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = cultivar_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_cultivar_id', target_crop_cultivar_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if cultivar_is_active then
    select c.is_active
    into v_crop_is_active
    from public.catalog_crops_s030 c
    where c.id = v_current.crop_id
    for share;

    if not coalesce(v_crop_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.crop_cultivars
  set is_active = cultivar_is_active
  where id = target_crop_cultivar_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'crop_cultivar_id', target_crop_cultivar_id,
    'is_active', cultivar_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;

-- ============================================================================
-- 4. INVARIANTE GERARCHICO DEI TAXON
-- ============================================================================

create function private.prevent_botanical_taxon_cycle()
returns trigger
language plpgsql
volatile
security definer
set search_path = ''
as $function$
begin
  -- Serializza le mutazioni gerarchiche, includendo eventuali scritture
  -- amministrative esterne alle RPC autoritative.
  perform pg_catalog.pg_advisory_xact_lock(3030, 1);

  if new.parent_taxon_id is null then
    return new;
  end if;

  if new.parent_taxon_id = new.id then
    raise exception using
      errcode = '23514',
      message = 'A botanical taxon cannot be its own parent';
  end if;

  if exists (
    with recursive ancestors as (
      select
        bt.id,
        bt.parent_taxon_id
      from public.botanical_taxa bt
      where bt.id = new.parent_taxon_id

      union

      select
        parent_bt.id,
        parent_bt.parent_taxon_id
      from public.botanical_taxa parent_bt
      join ancestors a
        on parent_bt.id = a.parent_taxon_id
    )
    select 1
    from ancestors a
    where a.id = new.id
  ) then
    raise exception using
      errcode = '23514',
      message = 'Botanical taxon parent would create a hierarchy cycle';
  end if;

  return new;
end;
$function$;

revoke all
  on function private.prevent_botanical_taxon_cycle()
  from public, anon, authenticated;

create trigger botanical_taxa_prevent_parent_cycle
before insert or update of parent_taxon_id
on public.botanical_taxa
for each row
execute function private.prevent_botanical_taxon_cycle();

comment on function private.prevent_botanical_taxon_cycle() is
  'Impedisce auto-parent e cicli nella gerarchia globale dei Taxon.';


-- ============================================================================
-- 5. BOTANICAL TAXA RPC
-- ============================================================================

create function public.create_botanical_taxon(
  target_parent_taxon_id uuid,
  taxon_rank text,
  taxon_scientific_name text,
  taxon_authorship text,
  taxon_is_hybrid boolean,
  taxon_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_rank text;
  v_scientific_name text;
  v_authorship text;
  v_description text;
  v_parent_is_active boolean;
  v_taxon_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_rank := pg_catalog.upper(pg_catalog.btrim(taxon_rank));
  v_scientific_name := private.clean_catalog_display_text(taxon_scientific_name);
  v_authorship := nullif(
    private.clean_catalog_display_text(taxon_authorship),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(taxon_description),
    ''
  );

  if v_rank is null
     or v_rank not in (
       'ORDER', 'FAMILY', 'GENUS', 'SPECIES',
       'SUBSPECIES', 'VARIETY', 'FORMA', 'UNRANKED'
     )
     or v_scientific_name is null
     or v_scientific_name = ''
     or char_length(v_scientific_name) > 200
     or (v_authorship is not null and char_length(v_authorship) > 200)
     or (v_description is not null and char_length(v_description) > 1000)
     or taxon_is_hybrid is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  if target_parent_taxon_id is not null then
    select bt.is_active
    into v_parent_is_active
    from public.botanical_taxa bt
    where bt.id = target_parent_taxon_id
    for share;

    if not found then
      return jsonb_build_object('status', 'parent_not_found');
    end if;

    if not v_parent_is_active then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  begin
    insert into public.botanical_taxa (
      parent_taxon_id,
      rank,
      scientific_name,
      authorship,
      is_hybrid,
      description
    )
    values (
      target_parent_taxon_id,
      v_rank,
      v_scientific_name,
      v_authorship,
      taxon_is_hybrid,
      v_description
    )
    returning id, row_version, created_at, updated_at
    into v_taxon_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'botanical_taxa_identity_unique' then
        return jsonb_build_object('status', 'duplicate_identity');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'botanical_taxon_id', v_taxon_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_botanical_taxon(
  target_botanical_taxon_id uuid,
  expected_row_version bigint,
  target_parent_taxon_id uuid,
  taxon_rank text,
  taxon_scientific_name text,
  taxon_authorship text,
  taxon_is_hybrid boolean,
  taxon_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_rank text;
  v_scientific_name text;
  v_authorship text;
  v_description text;
  v_parent_is_active boolean;
  v_current public.botanical_taxa%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_botanical_taxon_id is null
     or expected_row_version is null
     or expected_row_version < 1 then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.*
  into v_current
  from public.botanical_taxa bt
  where bt.id = target_botanical_taxon_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_taxon_id', target_botanical_taxon_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_rank := pg_catalog.upper(pg_catalog.btrim(taxon_rank));
  v_scientific_name := private.clean_catalog_display_text(taxon_scientific_name);
  v_authorship := nullif(
    private.clean_catalog_display_text(taxon_authorship),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(taxon_description),
    ''
  );

  if v_rank is null
     or v_rank not in (
       'ORDER', 'FAMILY', 'GENUS', 'SPECIES',
       'SUBSPECIES', 'VARIETY', 'FORMA', 'UNRANKED'
     )
     or v_scientific_name is null
     or v_scientific_name = ''
     or char_length(v_scientific_name) > 200
     or (v_authorship is not null and char_length(v_authorship) > 200)
     or (v_description is not null and char_length(v_description) > 1000)
     or taxon_is_hybrid is null
     or target_parent_taxon_id = target_botanical_taxon_id then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  if target_parent_taxon_id is not null then
    select bt.is_active
    into v_parent_is_active
    from public.botanical_taxa bt
    where bt.id = target_parent_taxon_id
    for share;

    if not found then
      return jsonb_build_object('status', 'parent_not_found');
    end if;

    if not v_parent_is_active
       and v_current.parent_taxon_id is distinct from target_parent_taxon_id then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;

    if exists (
      with recursive ancestors as (
        select bt.id, bt.parent_taxon_id
        from public.botanical_taxa bt
        where bt.id = target_parent_taxon_id

        union

        select parent_bt.id, parent_bt.parent_taxon_id
        from public.botanical_taxa parent_bt
        join ancestors a
          on parent_bt.id = a.parent_taxon_id
      )
      select 1
      from ancestors a
      where a.id = target_botanical_taxon_id
    ) then
      return jsonb_build_object('status', 'invalid_input');
    end if;
  end if;

  if v_current.parent_taxon_id is not distinct from target_parent_taxon_id
     and v_current.rank = v_rank
     and v_current.scientific_name = v_scientific_name
     and v_current.authorship is not distinct from v_authorship
     and v_current.is_hybrid = taxon_is_hybrid
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'botanical_taxon_id', target_botanical_taxon_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.botanical_taxa
    set
      parent_taxon_id = target_parent_taxon_id,
      rank = v_rank,
      scientific_name = v_scientific_name,
      authorship = v_authorship,
      is_hybrid = taxon_is_hybrid,
      description = v_description
    where id = target_botanical_taxon_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'botanical_taxa_identity_unique' then
        return jsonb_build_object('status', 'duplicate_identity');
      end if;

      raise;
  end;

  if not found then
    select bt.row_version, bt.updated_at
    into v_row_version, v_updated_at
    from public.botanical_taxa bt
    where bt.id = target_botanical_taxon_id;

    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_taxon_id', target_botanical_taxon_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_row_version,
      'updated_at', v_updated_at
    );
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'botanical_taxon_id', target_botanical_taxon_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_botanical_taxon_active(
  target_botanical_taxon_id uuid,
  expected_row_version bigint,
  taxon_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.botanical_taxa%rowtype;
  v_parent_is_active boolean;
  v_active_child_taxa_count bigint;
  v_active_crops_count bigint;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_botanical_taxon_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or taxon_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.*
  into v_current
  from public.botanical_taxa bt
  where bt.id = target_botanical_taxon_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_taxon_id', target_botanical_taxon_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = taxon_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'botanical_taxon_id', target_botanical_taxon_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if taxon_is_active then
    if v_current.parent_taxon_id is not null then
      select bt.is_active
      into v_parent_is_active
      from public.botanical_taxa bt
      where bt.id = v_current.parent_taxon_id
      for share;

      if not coalesce(v_parent_is_active, false) then
        return jsonb_build_object('status', 'dependency_inactive');
      end if;
    end if;
  else
    select count(*)
    into v_active_child_taxa_count
    from public.botanical_taxa bt
    where bt.parent_taxon_id = target_botanical_taxon_id
      and bt.is_active = true;

    select count(*)
    into v_active_crops_count
    from public.catalog_crops_s030 c
    where c.taxon_id = target_botanical_taxon_id
      and c.is_active = true;

    if v_active_child_taxa_count > 0
       or v_active_crops_count > 0 then
      return jsonb_build_object(
        'status', 'active_dependents',
        'active_child_taxa_count', v_active_child_taxa_count,
        'active_crops_count', v_active_crops_count
      );
    end if;
  end if;

  update public.botanical_taxa
  set is_active = taxon_is_active
  where id = target_botanical_taxon_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'botanical_taxon_id', target_botanical_taxon_id,
    'is_active', taxon_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


-- ============================================================================
-- 6. TAXON ALIASES RPC
-- ============================================================================

create function public.create_taxon_alias(
  target_taxon_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_alias_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if target_taxon_id is null
     or v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_entity_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_entity_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.taxon_aliases (
      taxon_id, alias, alias_type, language_code, description
    )
    values (
      target_taxon_id, v_alias, v_alias_type, v_language_code, v_description
    )
    returning id, row_version, created_at, updated_at
    into v_alias_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'taxon_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'taxon_alias_id', v_alias_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_taxon_alias(
  target_taxon_alias_id uuid,
  expected_row_version bigint,
  target_taxon_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_current public.taxon_aliases%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_taxon_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_taxon_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ta.*
  into v_current
  from public.taxon_aliases ta
  where ta.id = target_taxon_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'taxon_alias_id', target_taxon_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select bt.is_active
  into v_entity_is_active
  from public.botanical_taxa bt
  where bt.id = target_taxon_id
  for share;

  if not found then
    return jsonb_build_object('status', 'taxon_not_found');
  end if;

  if not v_entity_is_active
     and v_current.taxon_id is distinct from target_taxon_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.taxon_id = target_taxon_id
     and v_current.alias = v_alias
     and v_current.alias_type = v_alias_type
     and v_current.language_code is not distinct from v_language_code
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'taxon_alias_id', target_taxon_alias_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.taxon_aliases
    set
      taxon_id = target_taxon_id,
      alias = v_alias,
      alias_type = v_alias_type,
      language_code = v_language_code,
      description = v_description
    where id = target_taxon_alias_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'taxon_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'taxon_alias_id', target_taxon_alias_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_taxon_alias_active(
  target_taxon_alias_id uuid,
  expected_row_version bigint,
  alias_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.taxon_aliases%rowtype;
  v_entity_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_taxon_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or alias_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ta.*
  into v_current
  from public.taxon_aliases ta
  where ta.id = target_taxon_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'taxon_alias_id', target_taxon_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = alias_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'taxon_alias_id', target_taxon_alias_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if alias_is_active then
    select bt.is_active
    into v_entity_is_active
    from public.botanical_taxa bt
    where bt.id = v_current.taxon_id
    for share;

    if not coalesce(v_entity_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.taxon_aliases
  set is_active = alias_is_active
  where id = target_taxon_alias_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'taxon_alias_id', target_taxon_alias_id,
    'is_active', alias_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


-- ============================================================================
-- 7. CROP ALIASES RPC
-- ============================================================================

create function public.create_crop_alias(
  target_crop_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_alias_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if target_crop_id is null
     or v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_entity_is_active
  from public.catalog_crops_s030 c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_entity_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.crop_aliases (
      crop_id, alias, alias_type, language_code, description
    )
    values (
      target_crop_id, v_alias, v_alias_type, v_language_code, v_description
    )
    returning id, row_version, created_at, updated_at
    into v_alias_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'crop_alias_id', v_alias_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_crop_alias(
  target_crop_alias_id uuid,
  expected_row_version bigint,
  target_crop_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_current public.crop_aliases%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_crop_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.crop_aliases ca
  where ca.id = target_crop_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_alias_id', target_crop_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select c.is_active
  into v_entity_is_active
  from public.catalog_crops_s030 c
  where c.id = target_crop_id
  for share;

  if not found then
    return jsonb_build_object('status', 'crop_not_found');
  end if;

  if not v_entity_is_active
     and v_current.crop_id is distinct from target_crop_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.crop_id = target_crop_id
     and v_current.alias = v_alias
     and v_current.alias_type = v_alias_type
     and v_current.language_code is not distinct from v_language_code
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_alias_id', target_crop_alias_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.crop_aliases
    set
      crop_id = target_crop_id,
      alias = v_alias,
      alias_type = v_alias_type,
      language_code = v_language_code,
      description = v_description
    where id = target_crop_alias_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'crop_alias_id', target_crop_alias_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_crop_alias_active(
  target_crop_alias_id uuid,
  expected_row_version bigint,
  alias_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.crop_aliases%rowtype;
  v_entity_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_crop_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or alias_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.crop_aliases ca
  where ca.id = target_crop_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_alias_id', target_crop_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = alias_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_alias_id', target_crop_alias_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if alias_is_active then
    select c.is_active
    into v_entity_is_active
    from public.catalog_crops_s030 c
    where c.id = v_current.crop_id
    for share;

    if not coalesce(v_entity_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.crop_aliases
  set is_active = alias_is_active
  where id = target_crop_alias_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'crop_alias_id', target_crop_alias_id,
    'is_active', alias_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


-- ============================================================================
-- 8. CULTIVAR ALIASES RPC
-- ============================================================================

create function public.create_cultivar_alias(
  target_cultivar_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_alias_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if target_cultivar_id is null
     or v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.is_active
  into v_entity_is_active
  from public.crop_cultivars cv
  where cv.id = target_cultivar_id
  for share;

  if not found then
    return jsonb_build_object('status', 'cultivar_not_found');
  end if;

  if not v_entity_is_active then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  begin
    insert into public.cultivar_aliases (
      cultivar_id, alias, alias_type, language_code, description
    )
    values (
      target_cultivar_id, v_alias, v_alias_type, v_language_code, v_description
    )
    returning id, row_version, created_at, updated_at
    into v_alias_id, v_row_version, v_created_at, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'cultivar_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  return jsonb_build_object(
    'status', 'created',
    'cultivar_alias_id', v_alias_id,
    'row_version', v_row_version,
    'created_at', v_created_at,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.update_cultivar_alias(
  target_cultivar_alias_id uuid,
  expected_row_version bigint,
  target_cultivar_id uuid,
  alias_value text,
  alias_type text,
  alias_language_code text,
  alias_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_alias text;
  v_alias_type text;
  v_language_code text;
  v_description text;
  v_entity_is_active boolean;
  v_current public.cultivar_aliases%rowtype;
  v_row_version bigint;
  v_updated_at timestamptz;
  v_constraint_name text;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_cultivar_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or target_cultivar_id is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.cultivar_aliases ca
  where ca.id = target_cultivar_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'cultivar_alias_id', target_cultivar_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  v_alias := private.clean_catalog_display_text(alias_value);
  v_alias_type := pg_catalog.upper(pg_catalog.btrim(alias_type));
  v_language_code := nullif(
    pg_catalog.lower(pg_catalog.btrim(alias_language_code)),
    ''
  );
  v_description := nullif(
    private.clean_catalog_description(alias_description),
    ''
  );

  if v_alias is null
     or v_alias = ''
     or char_length(v_alias) > 200
     or v_alias_type is null
     or v_alias_type not in (
       'COMMON_NAME', 'SYNONYM', 'HISTORICAL_NAME', 'LOCAL_NAME'
     )
     or (
       v_language_code is not null
       and (
         char_length(v_language_code) > 35
         or v_language_code !~ '^[a-z]{2,8}(-[a-z0-9]{1,8})*$'
       )
     )
     or (v_description is not null and char_length(v_description) > 1000) then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select cv.is_active
  into v_entity_is_active
  from public.crop_cultivars cv
  where cv.id = target_cultivar_id
  for share;

  if not found then
    return jsonb_build_object('status', 'cultivar_not_found');
  end if;

  if not v_entity_is_active
     and v_current.cultivar_id is distinct from target_cultivar_id then
    return jsonb_build_object('status', 'dependency_inactive');
  end if;

  if v_current.cultivar_id = target_cultivar_id
     and v_current.alias = v_alias
     and v_current.alias_type = v_alias_type
     and v_current.language_code is not distinct from v_language_code
     and v_current.description is not distinct from v_description then
    return jsonb_build_object(
      'status', 'unchanged',
      'cultivar_alias_id', target_cultivar_alias_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  begin
    update public.cultivar_aliases
    set
      cultivar_id = target_cultivar_id,
      alias = v_alias,
      alias_type = v_alias_type,
      language_code = v_language_code,
      description = v_description
    where id = target_cultivar_alias_id
      and row_version = expected_row_version
    returning row_version, updated_at
    into v_row_version, v_updated_at;
  exception
    when unique_violation then
      get stacked diagnostics v_constraint_name = constraint_name;

      if v_constraint_name = 'cultivar_aliases_identity_unique' then
        return jsonb_build_object('status', 'duplicate_alias');
      end if;

      raise;
  end;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'updated',
    'cultivar_alias_id', target_cultivar_alias_id,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


create function public.set_cultivar_alias_active(
  target_cultivar_alias_id uuid,
  expected_row_version bigint,
  alias_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  v_auth_user_id uuid := auth.uid();
  v_current public.cultivar_aliases%rowtype;
  v_entity_is_active boolean;
  v_row_version bigint;
  v_updated_at timestamptz;
begin
  if v_auth_user_id is null
     or not private.can_manage_catalog_identity() then
    return jsonb_build_object('status', 'forbidden');
  end if;

  if target_cultivar_alias_id is null
     or expected_row_version is null
     or expected_row_version < 1
     or alias_is_active is null then
    return jsonb_build_object('status', 'invalid_input');
  end if;

  select ca.*
  into v_current
  from public.cultivar_aliases ca
  where ca.id = target_cultivar_alias_id
  for update;

  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_current.row_version <> expected_row_version then
    return jsonb_build_object(
      'status', 'version_conflict',
      'cultivar_alias_id', target_cultivar_alias_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if v_current.is_active = alias_is_active then
    return jsonb_build_object(
      'status', 'unchanged',
      'cultivar_alias_id', target_cultivar_alias_id,
      'is_active', v_current.is_active,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  if alias_is_active then
    select cv.is_active
    into v_entity_is_active
    from public.crop_cultivars cv
    where cv.id = v_current.cultivar_id
    for share;

    if not coalesce(v_entity_is_active, false) then
      return jsonb_build_object('status', 'dependency_inactive');
    end if;
  end if;

  update public.cultivar_aliases
  set is_active = alias_is_active
  where id = target_cultivar_alias_id
    and row_version = expected_row_version
  returning row_version, updated_at
  into v_row_version, v_updated_at;

  if not found then
    return jsonb_build_object('status', 'version_conflict');
  end if;

  return jsonb_build_object(
    'status', 'active_changed',
    'cultivar_alias_id', target_cultivar_alias_id,
    'is_active', alias_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$function$;


-- ============================================================================
-- 9. PRIVILEGI RPC
-- ============================================================================

revoke all on function public.create_botanical_taxon(uuid, text, text, text, boolean, text) from public, anon, authenticated;
revoke all on function public.update_botanical_taxon(uuid, bigint, uuid, text, text, text, boolean, text) from public, anon, authenticated;
revoke all on function public.set_botanical_taxon_active(uuid, bigint, boolean) from public, anon, authenticated;

revoke all on function public.create_catalog_crop(uuid, text, text) from public, anon, authenticated;
revoke all on function public.update_catalog_crop(uuid, bigint, uuid, text, text) from public, anon, authenticated;
revoke all on function public.set_catalog_crop_active(uuid, bigint, boolean) from public, anon, authenticated;

revoke all on function public.create_crop_cultivar(uuid, text, text, text) from public, anon, authenticated;
revoke all on function public.update_crop_cultivar(uuid, bigint, uuid, text, text, text) from public, anon, authenticated;
revoke all on function public.set_crop_cultivar_active(uuid, bigint, boolean) from public, anon, authenticated;

revoke all on function public.create_taxon_alias(uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.update_taxon_alias(uuid, bigint, uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.set_taxon_alias_active(uuid, bigint, boolean) from public, anon, authenticated;

revoke all on function public.create_crop_alias(uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.update_crop_alias(uuid, bigint, uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.set_crop_alias_active(uuid, bigint, boolean) from public, anon, authenticated;

revoke all on function public.create_cultivar_alias(uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.update_cultivar_alias(uuid, bigint, uuid, text, text, text, text) from public, anon, authenticated;
revoke all on function public.set_cultivar_alias_active(uuid, bigint, boolean) from public, anon, authenticated;


grant execute on function public.create_botanical_taxon(uuid, text, text, text, boolean, text) to authenticated;
grant execute on function public.update_botanical_taxon(uuid, bigint, uuid, text, text, text, boolean, text) to authenticated;
grant execute on function public.set_botanical_taxon_active(uuid, bigint, boolean) to authenticated;

grant execute on function public.create_catalog_crop(uuid, text, text) to authenticated;
grant execute on function public.update_catalog_crop(uuid, bigint, uuid, text, text) to authenticated;
grant execute on function public.set_catalog_crop_active(uuid, bigint, boolean) to authenticated;

grant execute on function public.create_crop_cultivar(uuid, text, text, text) to authenticated;
grant execute on function public.update_crop_cultivar(uuid, bigint, uuid, text, text, text) to authenticated;
grant execute on function public.set_crop_cultivar_active(uuid, bigint, boolean) to authenticated;

grant execute on function public.create_taxon_alias(uuid, text, text, text, text) to authenticated;
grant execute on function public.update_taxon_alias(uuid, bigint, uuid, text, text, text, text) to authenticated;
grant execute on function public.set_taxon_alias_active(uuid, bigint, boolean) to authenticated;

grant execute on function public.create_crop_alias(uuid, text, text, text, text) to authenticated;
grant execute on function public.update_crop_alias(uuid, bigint, uuid, text, text, text, text) to authenticated;
grant execute on function public.set_crop_alias_active(uuid, bigint, boolean) to authenticated;

grant execute on function public.create_cultivar_alias(uuid, text, text, text, text) to authenticated;
grant execute on function public.update_cultivar_alias(uuid, bigint, uuid, text, text, text, text) to authenticated;
grant execute on function public.set_cultivar_alias_active(uuid, bigint, boolean) to authenticated;


-- ============================================================================
-- 10. DOCUMENTAZIONE RPC
-- ============================================================================

comment on function public.create_botanical_taxon(uuid, text, text, text, boolean, text) is
  'Crea un Taxon globale sotto Catalog Authority; il parent facoltativo deve essere attivo.';
comment on function public.update_botanical_taxon(uuid, bigint, uuid, text, text, text, boolean, text) is
  'Aggiorna un Taxon globale con optimistic concurrency e protezione dai cicli.';
comment on function public.set_botanical_taxon_active(uuid, bigint, boolean) is
  'Attiva o disattiva un Taxon rispettando parent e dipendenze attive.';

comment on function public.create_catalog_crop(uuid, text, text) is
  'Crea una identita Crop globale collegata a un Taxon attivo.';
comment on function public.update_catalog_crop(uuid, bigint, uuid, text, text) is
  'Aggiorna una identita Crop globale con optimistic concurrency.';
comment on function public.set_catalog_crop_active(uuid, bigint, boolean) is
  'Attiva o disattiva un Crop rispettando Taxon e Cultivar attive.';

comment on function public.create_crop_cultivar(uuid, text, text, text) is
  'Crea una Cultivar globale collegata a un Crop attivo.';
comment on function public.update_crop_cultivar(uuid, bigint, uuid, text, text, text) is
  'Aggiorna una Cultivar globale con optimistic concurrency.';
comment on function public.set_crop_cultivar_active(uuid, bigint, boolean) is
  'Attiva o disattiva una Cultivar rispettando lo stato del Crop.';

comment on function public.create_taxon_alias(uuid, text, text, text, text) is
  'Crea un Alias per un Taxon globale attivo.';
comment on function public.update_taxon_alias(uuid, bigint, uuid, text, text, text, text) is
  'Aggiorna un Alias di Taxon con optimistic concurrency.';
comment on function public.set_taxon_alias_active(uuid, bigint, boolean) is
  'Attiva o disattiva un Alias di Taxon.';

comment on function public.create_crop_alias(uuid, text, text, text, text) is
  'Crea un Alias per un Crop globale attivo.';
comment on function public.update_crop_alias(uuid, bigint, uuid, text, text, text, text) is
  'Aggiorna un Alias di Crop con optimistic concurrency.';
comment on function public.set_crop_alias_active(uuid, bigint, boolean) is
  'Attiva o disattiva un Alias di Crop.';

comment on function public.create_cultivar_alias(uuid, text, text, text, text) is
  'Crea un Alias per una Cultivar globale attiva.';
comment on function public.update_cultivar_alias(uuid, bigint, uuid, text, text, text, text) is
  'Aggiorna un Alias di Cultivar con optimistic concurrency.';
comment on function public.set_cultivar_alias_active(uuid, bigint, boolean) is
  'Attiva o disattiva un Alias di Cultivar.';
