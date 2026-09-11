-- ============================================================================
-- Orto Smart - Write Path autoritativo catalogo colture
-- Sessione S026
-- ============================================================================

-- ============================================================================
-- 1. CREATE BOTANICAL FAMILY
-- ============================================================================
-- Crea una famiglia botanica Profile-owned.
-- La nuova famiglia nasce sempre attiva.
-- Le scritture dirette sulla tabella sono vietate: questa RPC costituisce
-- il Write Path autoritativo applicativo.

create or replace function public.create_botanical_family(
  target_profile_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  family_name text,
  family_scientific_name text,
  family_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_name text;
  v_scientific_name text;
  v_description text;

  v_botanical_family_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 1.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 1.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 1.3 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(family_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(family_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(family_description),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 1.4 VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 1.5 CREAZIONE FAMIGLIA BOTANICA
  -- --------------------------------------------------------------------------

  begin
    insert into public.botanical_families (
      profile_id,
      name,
      scientific_name,
      description,
      is_active
    )
    values (
      target_profile_id,
      v_name,
      v_scientific_name,
      v_description,
      true
    )
    returning
      id,
      row_version,
      created_at
    into
      v_botanical_family_id,
      v_row_version,
      v_created_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'botanical_families_profile_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      if v_constraint_name =
         'botanical_families_profile_scientific_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_scientific_name'
        );
      end if;

      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 1.6 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',
    'botanical_family_id', v_botanical_family_id,
    'profile_id', target_profile_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'is_active', true,
    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$$;

-- ============================================================================
-- 2. PRIVILEGI CREATE_BOTANICAL_FAMILY
-- ============================================================================

revoke all
  on function public.create_botanical_family(
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.create_botanical_family(
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text
  )
  to authenticated;
-- ============================================================================
-- 3. UPDATE BOTANICAL FAMILY
-- ============================================================================

create or replace function public.update_botanical_family(
  target_profile_id uuid,
  target_botanical_family_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  family_name text,
  family_scientific_name text,
  family_description text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_name text;
  v_scientific_name text;
  v_description text;

  v_current_name text;
  v_current_scientific_name text;
  v_current_description text;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 3.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_botanical_family_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.3 LETTURA E LOCK DELLA FAMIGLIA
  -- --------------------------------------------------------------------------

  select
    bf.name,
    bf.scientific_name,
    bf.description,
    bf.row_version,
    bf.updated_at
  into
    v_current_name,
    v_current_scientific_name,
    v_current_description,
    v_current_row_version,
    v_current_updated_at
  from public.botanical_families bf
  where bf.id = target_botanical_family_id
    and bf.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della riga.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_family_id', target_botanical_family_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.5 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(family_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(family_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(family_description),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 3.6 VALIDAZIONE INPUT
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.7 CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current_name = v_name
     and v_current_scientific_name is not distinct from v_scientific_name
     and v_current_description is not distinct from v_description
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'botanical_family_id', target_botanical_family_id,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.8 AGGIORNAMENTO
  -- --------------------------------------------------------------------------

  begin
    update public.botanical_families
    set
      name = v_name,
      scientific_name = v_scientific_name,
      description = v_description
    where id = target_botanical_family_id
      and profile_id = target_profile_id
      and row_version = expected_row_version
    returning
      row_version,
      updated_at
    into
      v_row_version,
      v_updated_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'botanical_families_profile_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      if v_constraint_name =
         'botanical_families_profile_scientific_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_scientific_name'
        );
      end if;

      raise;
  end;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_family_id', target_botanical_family_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 3.9 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'botanical_family_id', target_botanical_family_id,
    'profile_id', target_profile_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 4. PRIVILEGI UPDATE_BOTANICAL_FAMILY
-- ============================================================================

revoke all
  on function public.update_botanical_family(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    text,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_botanical_family(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    text,
    text
  )
  to authenticated;
-- ============================================================================
-- 5. SET BOTANICAL FAMILY ACTIVE
-- ============================================================================

create or replace function public.set_botanical_family_active(
  target_profile_id uuid,
  target_botanical_family_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  family_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_current_is_active boolean;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_active_crops jsonb;

  v_row_version bigint;
  v_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 5.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_botanical_family_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
     or family_is_active is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.3 LETTURA E LOCK DELLA FAMIGLIA
  -- --------------------------------------------------------------------------

  select
    bf.is_active,
    bf.row_version,
    bf.updated_at
  into
    v_current_is_active,
    v_current_row_version,
    v_current_updated_at
  from public.botanical_families bf
  where bf.id = target_botanical_family_id
    and bf.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della riga.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_family_id', target_botanical_family_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.5 STATO INVARIATO
  -- --------------------------------------------------------------------------

  if v_current_is_active = family_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'botanical_family_id', target_botanical_family_id,
      'is_active', v_current_is_active,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.6 BLOCCO DISATTIVAZIONE CON CROPS ATTIVE
  -- --------------------------------------------------------------------------

  if family_is_active = false
  then
    select
      coalesce(
        jsonb_agg(
          jsonb_build_object(
            'crop_id', c.id,
            'name', c.name
          )
          order by lower(c.name), c.id
        ),
        '[]'::jsonb
      )
    into
      v_active_crops
    from public.crops c
    where c.profile_id = target_profile_id
      and c.botanical_family_id = target_botanical_family_id
      and c.is_active = true;

    if jsonb_array_length(v_active_crops) > 0
    then
      return jsonb_build_object(
        'status', 'blocked_by_active_crops',
        'botanical_family_id', target_botanical_family_id,
        'active_crops', v_active_crops
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 5.7 AGGIORNAMENTO STATO
  -- --------------------------------------------------------------------------

  update public.botanical_families
  set is_active = family_is_active
  where id = target_botanical_family_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_row_version,
    v_updated_at;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'botanical_family_id', target_botanical_family_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 5.8 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'botanical_family_id', target_botanical_family_id,
    'profile_id', target_profile_id,
    'is_active', family_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 6. PRIVILEGI SET_BOTANICAL_FAMILY_ACTIVE
-- ============================================================================

revoke all
  on function public.set_botanical_family_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  from public, anon, authenticated;

grant execute
  on function public.set_botanical_family_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  to authenticated;
-- ============================================================================
-- 7. CREATE CROP
-- ============================================================================
-- Crea una coltura Profile-owned collegata a una famiglia botanica.
-- La nuova coltura nasce sempre attiva.
-- La famiglia botanica deve appartenere allo stesso Profile ed essere attiva.
-- Le scritture dirette sulla tabella sono vietate: questa RPC costituisce
-- il Write Path autoritativo applicativo.

create or replace function public.create_crop(
  target_profile_id uuid,
  target_botanical_family_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  crop_name text,
  crop_scientific_name text,
  crop_description text,

  crop_default_start_method text,
  crop_row_spacing_cm integer,
  crop_plant_spacing_cm integer,
  crop_sowing_depth_cm numeric,
  crop_germination_days integer,
  crop_harvest_days integer,
  crop_min_temperature integer,
  crop_optimal_temperature integer,
  crop_rotation_seasons integer,

  crop_water_requirement text,
  crop_water_requirement_value numeric,
  crop_water_requirement_basis text,
  crop_water_interval_days integer,

  crop_productivity text,

  crop_expected_yield_min numeric,
  crop_expected_yield_avg numeric,
  crop_expected_yield_max numeric,
  crop_expected_yield_unit text,

  crop_yield_source_name text,
  crop_yield_source_url text,
  crop_yield_source_year integer,
  crop_yield_notes text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_family_name text;
  v_family_is_active boolean;

  v_name text;
  v_scientific_name text;
  v_description text;
  v_water_requirement text;
  v_productivity text;
  v_yield_source_name text;
  v_yield_source_url text;
  v_yield_notes text;

  v_crop_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 7.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_botanical_family_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.3 LETTURA E LOCK DELLA FAMIGLIA BOTANICA
  -- --------------------------------------------------------------------------
  -- Il lock del padre serializza la creazione della Crop rispetto
  -- all'eventuale disattivazione concorrente della Botanical Family.

  select
    bf.name,
    bf.is_active
  into
    v_family_name,
    v_family_is_active
  from public.botanical_families bf
  where bf.id = target_botanical_family_id
    and bf.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock del padre.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if v_family_is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_botanical_family',
      'botanical_family_id', target_botanical_family_id,
      'botanical_family_name', v_family_name
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.4 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(crop_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(crop_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(crop_description),
      ''
    );

  v_water_requirement :=
    nullif(
      btrim(crop_water_requirement),
      ''
    );

  v_productivity :=
    nullif(
      btrim(crop_productivity),
      ''
    );

  v_yield_source_name :=
    nullif(
      btrim(crop_yield_source_name),
      ''
    );

  v_yield_source_url :=
    nullif(
      btrim(crop_yield_source_url),
      ''
    );

  v_yield_notes :=
    nullif(
      btrim(crop_yield_notes),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 7.5 VALIDAZIONE TESTI
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
     or (
       v_water_requirement is not null
       and char_length(v_water_requirement) > 180
     )
     or (
       v_productivity is not null
       and char_length(v_productivity) > 180
     )
     or (
       v_yield_source_name is not null
       and char_length(v_yield_source_name) > 150
     )
     or (
       v_yield_source_url is not null
       and char_length(v_yield_source_url) > 300
     )
     or (
       v_yield_notes is not null
       and char_length(v_yield_notes) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.6 VALIDAZIONE METODO DI AVVIO
  -- --------------------------------------------------------------------------

  if crop_default_start_method is not null
     and crop_default_start_method not in (
       'purchased_seedlings',
       'nursery_then_transplant',
       'direct_rows',
       'direct_broadcast'
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.7 VALIDAZIONE PARAMETRI AGRONOMICI SEMPLICI
  -- --------------------------------------------------------------------------

  if (
       crop_row_spacing_cm is not null
       and crop_row_spacing_cm <= 0
     )
     or (
       crop_plant_spacing_cm is not null
       and crop_plant_spacing_cm <= 0
     )
     or (
       crop_sowing_depth_cm is not null
       and crop_sowing_depth_cm <= 0
     )
     or (
       crop_germination_days is not null
       and crop_germination_days <= 0
     )
     or (
       crop_harvest_days is not null
       and crop_harvest_days <= 0
     )
     or (
       crop_rotation_seasons is not null
       and crop_rotation_seasons <= 0
     )
     or (
       crop_min_temperature is not null
       and crop_optimal_temperature is not null
       and crop_min_temperature > crop_optimal_temperature
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.8 VALIDAZIONE GRUPPO ACQUA QUANTITATIVA
  -- --------------------------------------------------------------------------
  -- Il gruppo deve essere interamente assente oppure interamente valorizzato.

  if not (
    (
      crop_water_requirement_value is null
      and crop_water_requirement_basis is null
      and crop_water_interval_days is null
    )
    or
    (
      crop_water_requirement_value is not null
      and crop_water_requirement_value > 0
      and crop_water_requirement_basis in (
        'per_plant',
        'per_m2'
      )
      and crop_water_interval_days is not null
      and crop_water_interval_days > 0
    )
  )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.9 VALIDAZIONE RESA
  -- --------------------------------------------------------------------------

  if (
       crop_expected_yield_min is not null
       and crop_expected_yield_min < 0
     )
     or (
       crop_expected_yield_avg is not null
       and crop_expected_yield_avg < 0
     )
     or (
       crop_expected_yield_max is not null
       and crop_expected_yield_max < 0
     )
     or (
       crop_expected_yield_min is not null
       and crop_expected_yield_avg is not null
       and crop_expected_yield_min > crop_expected_yield_avg
     )
     or (
       crop_expected_yield_avg is not null
       and crop_expected_yield_max is not null
       and crop_expected_yield_avg > crop_expected_yield_max
     )
     or (
       crop_expected_yield_min is not null
       and crop_expected_yield_max is not null
       and crop_expected_yield_min > crop_expected_yield_max
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.10 VALIDAZIONE UNITÀ RESA E FONTE
  -- --------------------------------------------------------------------------

  if crop_expected_yield_min is null
     and crop_expected_yield_avg is null
     and crop_expected_yield_max is null
  then
    if crop_expected_yield_unit is not null
       or v_yield_source_name is not null
       or v_yield_source_url is not null
       or crop_yield_source_year is not null
       or v_yield_notes is not null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  else
    if crop_expected_yield_unit is null
       or crop_expected_yield_unit not in (
         'kg_per_m2',
         'kg_per_plant',
         'g_per_m2',
         'g_per_plant',
         'pieces_per_m2',
         'pieces_per_plant'
       )
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  if crop_yield_source_year is not null
     and crop_yield_source_year < 1800
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 7.11 CREAZIONE CROP
  -- --------------------------------------------------------------------------

  begin
    insert into public.crops (
      profile_id,
      botanical_family_id,

      name,
      scientific_name,
      description,

      default_start_method,
      row_spacing_cm,
      plant_spacing_cm,
      sowing_depth_cm,
      germination_days,
      harvest_days,
      min_temperature,
      optimal_temperature,
      rotation_seasons,

      water_requirement,
      water_requirement_value,
      water_requirement_basis,
      water_interval_days,

      productivity,

      expected_yield_min,
      expected_yield_avg,
      expected_yield_max,
      expected_yield_unit,

      yield_source_name,
      yield_source_url,
      yield_source_year,
      yield_notes,

      is_active
    )
    values (
      target_profile_id,
      target_botanical_family_id,

      v_name,
      v_scientific_name,
      v_description,

      crop_default_start_method,
      crop_row_spacing_cm,
      crop_plant_spacing_cm,
      crop_sowing_depth_cm,
      crop_germination_days,
      crop_harvest_days,
      crop_min_temperature,
      crop_optimal_temperature,
      crop_rotation_seasons,

      v_water_requirement,
      crop_water_requirement_value,
      crop_water_requirement_basis,
      crop_water_interval_days,

      v_productivity,

      crop_expected_yield_min,
      crop_expected_yield_avg,
      crop_expected_yield_max,
      crop_expected_yield_unit,

      v_yield_source_name,
      v_yield_source_url,
      crop_yield_source_year,
      v_yield_notes,

      true
    )
    returning
      id,
      row_version,
      created_at
    into
      v_crop_id,
      v_row_version,
      v_created_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'crops_profile_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      if v_constraint_name = 'crops_profile_scientific_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_scientific_name'
        );
      end if;

      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 7.12 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',
    'crop_id', v_crop_id,
    'profile_id', target_profile_id,
    'botanical_family_id', target_botanical_family_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'is_active', true,
    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$$;

-- ============================================================================
-- 8. PRIVILEGI CREATE_CROP
-- ============================================================================

revoke all
  on function public.create_crop(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.create_crop(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  to authenticated;
-- ============================================================================
-- 9. UPDATE CROP
-- ============================================================================
-- Aggiorna i dati di una coltura.
-- is_active non viene modificato da questa RPC.
-- La Crop può essere aggiornata anche quando è inattiva.
-- botanical_family_id può cambiare; in tal caso la nuova famiglia deve
-- appartenere allo stesso Profile ed essere attiva.

create or replace function public.update_crop(
  target_profile_id uuid,
  target_crop_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  target_botanical_family_id uuid,

  crop_name text,
  crop_scientific_name text,
  crop_description text,

  crop_default_start_method text,
  crop_row_spacing_cm integer,
  crop_plant_spacing_cm integer,
  crop_sowing_depth_cm numeric,
  crop_germination_days integer,
  crop_harvest_days integer,
  crop_min_temperature integer,
  crop_optimal_temperature integer,
  crop_rotation_seasons integer,

  crop_water_requirement text,
  crop_water_requirement_value numeric,
  crop_water_requirement_basis text,
  crop_water_interval_days integer,

  crop_productivity text,

  crop_expected_yield_min numeric,
  crop_expected_yield_avg numeric,
  crop_expected_yield_max numeric,
  crop_expected_yield_unit text,

  crop_yield_source_name text,
  crop_yield_source_url text,
  crop_yield_source_year integer,
  crop_yield_notes text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_current public.crops%rowtype;

  v_family_name text;
  v_family_is_active boolean;

  v_name text;
  v_scientific_name text;
  v_description text;
  v_water_requirement text;
  v_productivity text;
  v_yield_source_name text;
  v_yield_source_url text;
  v_yield_notes text;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 9.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_crop_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
     or target_botanical_family_id is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.3 LETTURA E LOCK DELLA CROP
  -- --------------------------------------------------------------------------

  select c.*
  into v_current
  from public.crops c
  where c.id = target_crop_id
    and c.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della Crop.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current.row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_id', target_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.5 EVENTUALE CAMBIO DI FAMIGLIA BOTANICA
  -- --------------------------------------------------------------------------
  -- Se la famiglia non cambia, la Crop può essere corretta anche quando
  -- la famiglia corrente è inattiva.
  -- Se invece cambia, la nuova famiglia deve esistere nello stesso Profile
  -- ed essere attiva.

  if target_botanical_family_id <> v_current.botanical_family_id
  then
    select
      bf.name,
      bf.is_active
    into
      v_family_name,
      v_family_is_active
    from public.botanical_families bf
    where bf.id = target_botanical_family_id
      and bf.profile_id = target_profile_id
    for update;

    if not found
    then
      return jsonb_build_object(
        'status', 'not_found'
      );
    end if;

    -- Rivalida nuovamente il lease dopo l'eventuale attesa sul lock
    -- della nuova famiglia botanica.

    if not private.lock_profile_write_authority(
      target_profile_id,
      target_client_id,
      target_session_id,
      lock_token
    )
    then
      return jsonb_build_object(
        'status', 'write_forbidden'
      );
    end if;

    if v_family_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_botanical_family',
        'botanical_family_id', target_botanical_family_id,
        'botanical_family_name', v_family_name
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 9.6 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(crop_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(crop_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(crop_description),
      ''
    );

  v_water_requirement :=
    nullif(
      btrim(crop_water_requirement),
      ''
    );

  v_productivity :=
    nullif(
      btrim(crop_productivity),
      ''
    );

  v_yield_source_name :=
    nullif(
      btrim(crop_yield_source_name),
      ''
    );

  v_yield_source_url :=
    nullif(
      btrim(crop_yield_source_url),
      ''
    );

  v_yield_notes :=
    nullif(
      btrim(crop_yield_notes),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 9.7 VALIDAZIONE TESTI
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
     or (
       v_water_requirement is not null
       and char_length(v_water_requirement) > 180
     )
     or (
       v_productivity is not null
       and char_length(v_productivity) > 180
     )
     or (
       v_yield_source_name is not null
       and char_length(v_yield_source_name) > 150
     )
     or (
       v_yield_source_url is not null
       and char_length(v_yield_source_url) > 300
     )
     or (
       v_yield_notes is not null
       and char_length(v_yield_notes) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.8 VALIDAZIONE METODO DI AVVIO
  -- --------------------------------------------------------------------------

  if crop_default_start_method is not null
     and crop_default_start_method not in (
       'purchased_seedlings',
       'nursery_then_transplant',
       'direct_rows',
       'direct_broadcast'
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.9 VALIDAZIONE PARAMETRI AGRONOMICI SEMPLICI
  -- --------------------------------------------------------------------------

  if (
       crop_row_spacing_cm is not null
       and crop_row_spacing_cm <= 0
     )
     or (
       crop_plant_spacing_cm is not null
       and crop_plant_spacing_cm <= 0
     )
     or (
       crop_sowing_depth_cm is not null
       and crop_sowing_depth_cm <= 0
     )
     or (
       crop_germination_days is not null
       and crop_germination_days <= 0
     )
     or (
       crop_harvest_days is not null
       and crop_harvest_days <= 0
     )
     or (
       crop_rotation_seasons is not null
       and crop_rotation_seasons <= 0
     )
     or (
       crop_min_temperature is not null
       and crop_optimal_temperature is not null
       and crop_min_temperature > crop_optimal_temperature
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.10 VALIDAZIONE GRUPPO ACQUA QUANTITATIVA
  -- --------------------------------------------------------------------------

  if not (
    (
      crop_water_requirement_value is null
      and crop_water_requirement_basis is null
      and crop_water_interval_days is null
    )
    or
    (
      crop_water_requirement_value is not null
      and crop_water_requirement_value > 0
      and crop_water_requirement_basis in (
        'per_plant',
        'per_m2'
      )
      and crop_water_interval_days is not null
      and crop_water_interval_days > 0
    )
  )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.11 VALIDAZIONE RESA
  -- --------------------------------------------------------------------------

  if (
       crop_expected_yield_min is not null
       and crop_expected_yield_min < 0
     )
     or (
       crop_expected_yield_avg is not null
       and crop_expected_yield_avg < 0
     )
     or (
       crop_expected_yield_max is not null
       and crop_expected_yield_max < 0
     )
     or (
       crop_expected_yield_min is not null
       and crop_expected_yield_avg is not null
       and crop_expected_yield_min > crop_expected_yield_avg
     )
     or (
       crop_expected_yield_avg is not null
       and crop_expected_yield_max is not null
       and crop_expected_yield_avg > crop_expected_yield_max
     )
     or (
       crop_expected_yield_min is not null
       and crop_expected_yield_max is not null
       and crop_expected_yield_min > crop_expected_yield_max
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.12 VALIDAZIONE UNITÀ RESA E FONTE
  -- --------------------------------------------------------------------------

  if crop_expected_yield_min is null
     and crop_expected_yield_avg is null
     and crop_expected_yield_max is null
  then
    if crop_expected_yield_unit is not null
       or v_yield_source_name is not null
       or v_yield_source_url is not null
       or crop_yield_source_year is not null
       or v_yield_notes is not null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  else
    if crop_expected_yield_unit is null
       or crop_expected_yield_unit not in (
         'kg_per_m2',
         'kg_per_plant',
         'g_per_m2',
         'g_per_plant',
         'pieces_per_m2',
         'pieces_per_plant'
       )
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  if crop_yield_source_year is not null
     and crop_yield_source_year < 1800
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.13 CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current.botanical_family_id = target_botanical_family_id
     and v_current.name = v_name
     and v_current.scientific_name is not distinct from v_scientific_name
     and v_current.description is not distinct from v_description
     and v_current.default_start_method
       is not distinct from crop_default_start_method
     and v_current.row_spacing_cm
       is not distinct from crop_row_spacing_cm
     and v_current.plant_spacing_cm
       is not distinct from crop_plant_spacing_cm
     and v_current.sowing_depth_cm
       is not distinct from crop_sowing_depth_cm
     and v_current.germination_days
       is not distinct from crop_germination_days
     and v_current.harvest_days
       is not distinct from crop_harvest_days
     and v_current.min_temperature
       is not distinct from crop_min_temperature
     and v_current.optimal_temperature
       is not distinct from crop_optimal_temperature
     and v_current.rotation_seasons
       is not distinct from crop_rotation_seasons
     and v_current.water_requirement
       is not distinct from v_water_requirement
     and v_current.water_requirement_value
       is not distinct from crop_water_requirement_value
     and v_current.water_requirement_basis
       is not distinct from crop_water_requirement_basis
     and v_current.water_interval_days
       is not distinct from crop_water_interval_days
     and v_current.productivity
       is not distinct from v_productivity
     and v_current.expected_yield_min
       is not distinct from crop_expected_yield_min
     and v_current.expected_yield_avg
       is not distinct from crop_expected_yield_avg
     and v_current.expected_yield_max
       is not distinct from crop_expected_yield_max
     and v_current.expected_yield_unit
       is not distinct from crop_expected_yield_unit
     and v_current.yield_source_name
       is not distinct from v_yield_source_name
     and v_current.yield_source_url
       is not distinct from v_yield_source_url
     and v_current.yield_source_year
       is not distinct from crop_yield_source_year
     and v_current.yield_notes
       is not distinct from v_yield_notes
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_id', target_crop_id,
      'botanical_family_id', v_current.botanical_family_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.14 AGGIORNAMENTO CROP
  -- --------------------------------------------------------------------------

  begin
    update public.crops
    set
      botanical_family_id = target_botanical_family_id,

      name = v_name,
      scientific_name = v_scientific_name,
      description = v_description,

      default_start_method = crop_default_start_method,
      row_spacing_cm = crop_row_spacing_cm,
      plant_spacing_cm = crop_plant_spacing_cm,
      sowing_depth_cm = crop_sowing_depth_cm,
      germination_days = crop_germination_days,
      harvest_days = crop_harvest_days,
      min_temperature = crop_min_temperature,
      optimal_temperature = crop_optimal_temperature,
      rotation_seasons = crop_rotation_seasons,

      water_requirement = v_water_requirement,
      water_requirement_value = crop_water_requirement_value,
      water_requirement_basis = crop_water_requirement_basis,
      water_interval_days = crop_water_interval_days,

      productivity = v_productivity,

      expected_yield_min = crop_expected_yield_min,
      expected_yield_avg = crop_expected_yield_avg,
      expected_yield_max = crop_expected_yield_max,
      expected_yield_unit = crop_expected_yield_unit,

      yield_source_name = v_yield_source_name,
      yield_source_url = v_yield_source_url,
      yield_source_year = crop_yield_source_year,
      yield_notes = v_yield_notes
    where id = target_crop_id
      and profile_id = target_profile_id
      and row_version = expected_row_version
    returning
      row_version,
      updated_at
    into
      v_row_version,
      v_updated_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'crops_profile_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      if v_constraint_name = 'crops_profile_scientific_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_scientific_name'
        );
      end if;

      raise;
  end;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_id', target_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 9.15 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'crop_id', target_crop_id,
    'profile_id', target_profile_id,
    'botanical_family_id', target_botanical_family_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 10. PRIVILEGI UPDATE_CROP
-- ============================================================================

revoke all
  on function public.update_crop(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    uuid,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_crop(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    uuid,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  to authenticated;
-- ============================================================================
-- 11. SET CROP ACTIVE
-- ============================================================================
-- Modifica esclusivamente is_active della Crop.
-- La disattivazione è vietata se esistono CropVarieties attive.
-- La riattivazione è consentita solo se la Botanical Family padre è attiva.

create or replace function public.set_crop_active(
  target_profile_id uuid,
  target_crop_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  crop_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_botanical_family_id uuid;

  v_current_is_active boolean;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_family_name text;
  v_family_is_active boolean;

  v_active_crop_varieties jsonb;

  v_row_version bigint;
  v_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 11.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_crop_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
     or crop_is_active is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.3 LETTURA E LOCK DELLA CROP
  -- --------------------------------------------------------------------------

  select
    c.botanical_family_id,
    c.is_active,
    c.row_version,
    c.updated_at
  into
    v_botanical_family_id,
    v_current_is_active,
    v_current_row_version,
    v_current_updated_at
  from public.crops c
  where c.id = target_crop_id
    and c.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della Crop.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_id', target_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.5 STATO INVARIATO
  -- --------------------------------------------------------------------------

  if v_current_is_active = crop_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_id', target_crop_id,
      'botanical_family_id', v_botanical_family_id,
      'is_active', v_current_is_active,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.6 RIATTIVAZIONE: FAMIGLIA BOTANICA DEVE ESSERE ATTIVA
  -- --------------------------------------------------------------------------
  -- Il lock del padre serializza la riattivazione della Crop rispetto
  -- all'eventuale disattivazione concorrente della Botanical Family.

  if crop_is_active = true
  then
    select
      bf.name,
      bf.is_active
    into
      v_family_name,
      v_family_is_active
    from public.botanical_families bf
    where bf.id = v_botanical_family_id
      and bf.profile_id = target_profile_id
    for update;

    if not found
    then
      return jsonb_build_object(
        'status', 'not_found'
      );
    end if;

    -- Rivalida il lease dopo l'eventuale attesa sul lock del padre.

    if not private.lock_profile_write_authority(
      target_profile_id,
      target_client_id,
      target_session_id,
      lock_token
    )
    then
      return jsonb_build_object(
        'status', 'write_forbidden'
      );
    end if;

    if v_family_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_botanical_family',
        'crop_id', target_crop_id,
        'botanical_family_id', v_botanical_family_id,
        'botanical_family_name', v_family_name
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 11.7 DISATTIVAZIONE: NESSUNA VARIETÀ ATTIVA
  -- --------------------------------------------------------------------------

  if crop_is_active = false
  then
    select
      coalesce(
        jsonb_agg(
          jsonb_build_object(
            'crop_variety_id', cv.id,
            'name', cv.name
          )
          order by lower(cv.name), cv.id
        ),
        '[]'::jsonb
      )
    into
      v_active_crop_varieties
    from public.crop_varieties cv
    where cv.profile_id = target_profile_id
      and cv.crop_id = target_crop_id
      and cv.is_active = true;

    if jsonb_array_length(v_active_crop_varieties) > 0
    then
      return jsonb_build_object(
        'status', 'blocked_by_active_crop_varieties',
        'crop_id', target_crop_id,
        'active_crop_varieties', v_active_crop_varieties
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 11.8 AGGIORNAMENTO STATO
  -- --------------------------------------------------------------------------

  update public.crops
  set is_active = crop_is_active
  where id = target_crop_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_row_version,
    v_updated_at;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_id', target_crop_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 11.9 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'crop_id', target_crop_id,
    'profile_id', target_profile_id,
    'botanical_family_id', v_botanical_family_id,
    'is_active', crop_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 12. PRIVILEGI SET_CROP_ACTIVE
-- ============================================================================

revoke all
  on function public.set_crop_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  from public, anon, authenticated;

grant execute
  on function public.set_crop_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  to authenticated;
-- ============================================================================
-- 13. CREATE CROP VARIETY
-- ============================================================================
-- Crea una varietà Profile-owned collegata a una Crop.
-- La nuova varietà nasce sempre attiva.
-- La Crop padre deve appartenere allo stesso Profile ed essere attiva.
-- I campi nullable della varietà rappresentano override dei valori della Crop.
-- Le validazioni che dipendono dal fallback vengono eseguite server-side.

create or replace function public.create_crop_variety(
  target_profile_id uuid,
  target_crop_id uuid,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  variety_name text,
  variety_scientific_name text,
  variety_description text,

  variety_default_start_method text,
  variety_row_spacing_cm integer,
  variety_plant_spacing_cm integer,
  variety_sowing_depth_cm numeric,
  variety_germination_days integer,
  variety_harvest_days integer,
  variety_min_temperature integer,
  variety_optimal_temperature integer,

  variety_water_requirement text,
  variety_water_requirement_value numeric,
  variety_water_requirement_basis text,
  variety_water_interval_days integer,

  variety_productivity text,

  variety_expected_yield_min numeric,
  variety_expected_yield_avg numeric,
  variety_expected_yield_max numeric,
  variety_expected_yield_unit text,

  variety_yield_source_name text,
  variety_yield_source_url text,
  variety_yield_source_year integer,
  variety_yield_notes text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_crop public.crops%rowtype;

  v_name text;
  v_scientific_name text;
  v_description text;
  v_water_requirement text;
  v_productivity text;
  v_yield_source_name text;
  v_yield_source_url text;
  v_yield_notes text;

  v_effective_min_temperature integer;
  v_effective_optimal_temperature integer;

  v_crop_variety_id uuid;
  v_row_version bigint;
  v_created_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 13.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_crop_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.3 LETTURA E LOCK DELLA CROP PADRE
  -- --------------------------------------------------------------------------
  -- Viene letta l'intera Crop perché i suoi valori servono anche per
  -- validare server-side il risultato effettivo dopo il fallback.
  -- Il lock serializza la CREATE rispetto a una disattivazione concorrente.

  select c.*
  into v_crop
  from public.crops c
  where c.id = target_crop_id
    and c.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della Crop.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if v_crop.is_active = false
  then
    return jsonb_build_object(
      'status', 'blocked_by_inactive_crop',
      'crop_id', target_crop_id,
      'crop_name', v_crop.name
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.4 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(variety_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(variety_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(variety_description),
      ''
    );

  v_water_requirement :=
    nullif(
      btrim(variety_water_requirement),
      ''
    );

  v_productivity :=
    nullif(
      btrim(variety_productivity),
      ''
    );

  v_yield_source_name :=
    nullif(
      btrim(variety_yield_source_name),
      ''
    );

  v_yield_source_url :=
    nullif(
      btrim(variety_yield_source_url),
      ''
    );

  v_yield_notes :=
    nullif(
      btrim(variety_yield_notes),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 13.5 VALIDAZIONE TESTI
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
     or (
       v_water_requirement is not null
       and char_length(v_water_requirement) > 180
     )
     or (
       v_productivity is not null
       and char_length(v_productivity) > 180
     )
     or (
       v_yield_source_name is not null
       and char_length(v_yield_source_name) > 150
     )
     or (
       v_yield_source_url is not null
       and char_length(v_yield_source_url) > 300
     )
     or (
       v_yield_notes is not null
       and char_length(v_yield_notes) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.6 VALIDAZIONE METODO DI AVVIO
  -- --------------------------------------------------------------------------

  if variety_default_start_method is not null
     and variety_default_start_method not in (
       'purchased_seedlings',
       'nursery_then_transplant',
       'direct_rows',
       'direct_broadcast'
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.7 VALIDAZIONE PARAMETRI AGRONOMICI LOCALI
  -- --------------------------------------------------------------------------

  if (
       variety_row_spacing_cm is not null
       and variety_row_spacing_cm <= 0
     )
     or (
       variety_plant_spacing_cm is not null
       and variety_plant_spacing_cm <= 0
     )
     or (
       variety_sowing_depth_cm is not null
       and variety_sowing_depth_cm <= 0
     )
     or (
       variety_germination_days is not null
       and variety_germination_days <= 0
     )
     or (
       variety_harvest_days is not null
       and variety_harvest_days <= 0
     )
     or (
       variety_min_temperature is not null
       and variety_optimal_temperature is not null
       and variety_min_temperature > variety_optimal_temperature
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.8 VALIDAZIONE RISULTATO EFFETTIVO DOPO FALLBACK
  -- --------------------------------------------------------------------------
  -- Gli override NULL ereditano il valore generale della Crop.
  -- In particolare la coppia di temperature deve rimanere coerente anche
  -- quando solo uno dei due valori è specificato dalla varietà.

  v_effective_min_temperature :=
    coalesce(
      variety_min_temperature,
      v_crop.min_temperature
    );

  v_effective_optimal_temperature :=
    coalesce(
      variety_optimal_temperature,
      v_crop.optimal_temperature
    );

  if v_effective_min_temperature is not null
     and v_effective_optimal_temperature is not null
     and v_effective_min_temperature > v_effective_optimal_temperature
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.9 VALIDAZIONE GRUPPO ACQUA QUANTITATIVA
  -- --------------------------------------------------------------------------
  -- Tutto NULL = fallback completo dalla Crop.
  -- Tutto valorizzato = override completo della varietà.
  -- Non è ammesso mescolare singoli campi del gruppo.

  if not (
    (
      variety_water_requirement_value is null
      and variety_water_requirement_basis is null
      and variety_water_interval_days is null
    )
    or
    (
      variety_water_requirement_value is not null
      and variety_water_requirement_value > 0
      and variety_water_requirement_basis in (
        'per_plant',
        'per_m2'
      )
      and variety_water_interval_days is not null
      and variety_water_interval_days > 0
    )
  )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.10 VALIDAZIONE RESA VARIETALE
  -- --------------------------------------------------------------------------
  -- Se almeno una resa è valorizzata, il gruppo diventa autonomo della
  -- varietà: non viene completato campo-per-campo usando la Crop.

  if (
       variety_expected_yield_min is not null
       and variety_expected_yield_min < 0
     )
     or (
       variety_expected_yield_avg is not null
       and variety_expected_yield_avg < 0
     )
     or (
       variety_expected_yield_max is not null
       and variety_expected_yield_max < 0
     )
     or (
       variety_expected_yield_min is not null
       and variety_expected_yield_avg is not null
       and variety_expected_yield_min > variety_expected_yield_avg
     )
     or (
       variety_expected_yield_avg is not null
       and variety_expected_yield_max is not null
       and variety_expected_yield_avg > variety_expected_yield_max
     )
     or (
       variety_expected_yield_min is not null
       and variety_expected_yield_max is not null
       and variety_expected_yield_min > variety_expected_yield_max
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.11 VALIDAZIONE UNITÀ RESA E FONTE
  -- --------------------------------------------------------------------------
  -- Nessuna resa varietale:
  --   unità e fonte devono essere NULL, quindi si eredita l'intero gruppo Crop.
  --
  -- Almeno una resa varietale:
  --   l'unità è obbligatoria e la fonte può essere assente o parziale.

  if variety_expected_yield_min is null
     and variety_expected_yield_avg is null
     and variety_expected_yield_max is null
  then
    if variety_expected_yield_unit is not null
       or v_yield_source_name is not null
       or v_yield_source_url is not null
       or variety_yield_source_year is not null
       or v_yield_notes is not null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  else
    if variety_expected_yield_unit is null
       or variety_expected_yield_unit not in (
         'kg_per_m2',
         'kg_per_plant',
         'g_per_m2',
         'g_per_plant',
         'pieces_per_m2',
         'pieces_per_plant'
       )
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  if variety_yield_source_year is not null
     and variety_yield_source_year < 1800
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 13.12 CREAZIONE VARIETÀ
  -- --------------------------------------------------------------------------

  begin
    insert into public.crop_varieties (
      profile_id,
      crop_id,

      name,
      scientific_name,
      description,

      default_start_method,
      row_spacing_cm,
      plant_spacing_cm,
      sowing_depth_cm,
      germination_days,
      harvest_days,
      min_temperature,
      optimal_temperature,

      water_requirement,
      water_requirement_value,
      water_requirement_basis,
      water_interval_days,

      productivity,

      expected_yield_min,
      expected_yield_avg,
      expected_yield_max,
      expected_yield_unit,

      yield_source_name,
      yield_source_url,
      yield_source_year,
      yield_notes,

      is_active
    )
    values (
      target_profile_id,
      target_crop_id,

      v_name,
      v_scientific_name,
      v_description,

      variety_default_start_method,
      variety_row_spacing_cm,
      variety_plant_spacing_cm,
      variety_sowing_depth_cm,
      variety_germination_days,
      variety_harvest_days,
      variety_min_temperature,
      variety_optimal_temperature,

      v_water_requirement,
      variety_water_requirement_value,
      variety_water_requirement_basis,
      variety_water_interval_days,

      v_productivity,

      variety_expected_yield_min,
      variety_expected_yield_avg,
      variety_expected_yield_max,
      variety_expected_yield_unit,

      v_yield_source_name,
      v_yield_source_url,
      variety_yield_source_year,
      v_yield_notes,

      true
    )
    returning
      id,
      row_version,
      created_at
    into
      v_crop_variety_id,
      v_row_version,
      v_created_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_varieties_crop_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      raise;
  end;

  -- --------------------------------------------------------------------------
  -- 13.13 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'created',
    'crop_variety_id', v_crop_variety_id,
    'profile_id', target_profile_id,
    'crop_id', target_crop_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'is_active', true,
    'row_version', v_row_version,
    'created_at', v_created_at
  );
end;
$$;

-- ============================================================================
-- 14. PRIVILEGI CREATE_CROP_VARIETY
-- ============================================================================

revoke all
  on function public.create_crop_variety(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.create_crop_variety(
    uuid,
    uuid,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  to authenticated;
-- ============================================================================
-- 15. UPDATE CROP VARIETY
-- ============================================================================
-- Aggiorna i dati di una varietà.
-- crop_id e is_active non vengono modificati da questa RPC.
-- La varietà può essere corretta anche quando essa o la Crop padre
-- sono inattive.
-- I campi nullable rappresentano override dei valori della Crop.
-- Le validazioni dipendenti dal fallback vengono eseguite server-side.

create or replace function public.update_crop_variety(
  target_profile_id uuid,
  target_crop_variety_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  variety_name text,
  variety_scientific_name text,
  variety_description text,

  variety_default_start_method text,
  variety_row_spacing_cm integer,
  variety_plant_spacing_cm integer,
  variety_sowing_depth_cm numeric,
  variety_germination_days integer,
  variety_harvest_days integer,
  variety_min_temperature integer,
  variety_optimal_temperature integer,

  variety_water_requirement text,
  variety_water_requirement_value numeric,
  variety_water_requirement_basis text,
  variety_water_interval_days integer,

  variety_productivity text,

  variety_expected_yield_min numeric,
  variety_expected_yield_avg numeric,
  variety_expected_yield_max numeric,
  variety_expected_yield_unit text,

  variety_yield_source_name text,
  variety_yield_source_url text,
  variety_yield_source_year integer,
  variety_yield_notes text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_current public.crop_varieties%rowtype;
  v_crop public.crops%rowtype;

  v_name text;
  v_scientific_name text;
  v_description text;
  v_water_requirement text;
  v_productivity text;
  v_yield_source_name text;
  v_yield_source_url text;
  v_yield_notes text;

  v_effective_min_temperature integer;
  v_effective_optimal_temperature integer;

  v_row_version bigint;
  v_updated_at timestamptz;

  v_constraint_name text;
begin

  -- --------------------------------------------------------------------------
  -- 15.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_crop_variety_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.3 LETTURA E LOCK DELLA VARIETÀ
  -- --------------------------------------------------------------------------

  select cv.*
  into v_current
  from public.crop_varieties cv
  where cv.id = target_crop_variety_id
    and cv.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della varietà.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current.row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_variety_id', target_crop_variety_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.5 LETTURA E LOCK DELLA CROP PADRE
  -- --------------------------------------------------------------------------
  -- crop_id è immutabile.
  -- La Crop viene letta server-side per determinare e validare i fallback.
  -- Non è richiesto che sia attiva per correggere una varietà esistente.

  select c.*
  into v_crop
  from public.crops c
  where c.id = v_current.crop_id
    and c.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della Crop.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.6 NORMALIZZAZIONE INPUT
  -- --------------------------------------------------------------------------

  v_name :=
    regexp_replace(
      btrim(variety_name),
      '[[:space:]]+',
      ' ',
      'g'
    );

  v_scientific_name :=
    nullif(
      regexp_replace(
        btrim(variety_scientific_name),
        '[[:space:]]+',
        ' ',
        'g'
      ),
      ''
    );

  v_description :=
    nullif(
      btrim(variety_description),
      ''
    );

  v_water_requirement :=
    nullif(
      btrim(variety_water_requirement),
      ''
    );

  v_productivity :=
    nullif(
      btrim(variety_productivity),
      ''
    );

  v_yield_source_name :=
    nullif(
      btrim(variety_yield_source_name),
      ''
    );

  v_yield_source_url :=
    nullif(
      btrim(variety_yield_source_url),
      ''
    );

  v_yield_notes :=
    nullif(
      btrim(variety_yield_notes),
      ''
    );

  -- --------------------------------------------------------------------------
  -- 15.7 VALIDAZIONE TESTI
  -- --------------------------------------------------------------------------

  if v_name is null
     or v_name = ''
     or char_length(v_name) > 80
     or (
       v_scientific_name is not null
       and char_length(v_scientific_name) > 120
     )
     or (
       v_description is not null
       and char_length(v_description) > 300
     )
     or (
       v_water_requirement is not null
       and char_length(v_water_requirement) > 180
     )
     or (
       v_productivity is not null
       and char_length(v_productivity) > 180
     )
     or (
       v_yield_source_name is not null
       and char_length(v_yield_source_name) > 150
     )
     or (
       v_yield_source_url is not null
       and char_length(v_yield_source_url) > 300
     )
     or (
       v_yield_notes is not null
       and char_length(v_yield_notes) > 300
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.8 VALIDAZIONE METODO DI AVVIO
  -- --------------------------------------------------------------------------

  if variety_default_start_method is not null
     and variety_default_start_method not in (
       'purchased_seedlings',
       'nursery_then_transplant',
       'direct_rows',
       'direct_broadcast'
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.9 VALIDAZIONE PARAMETRI AGRONOMICI LOCALI
  -- --------------------------------------------------------------------------

  if (
       variety_row_spacing_cm is not null
       and variety_row_spacing_cm <= 0
     )
     or (
       variety_plant_spacing_cm is not null
       and variety_plant_spacing_cm <= 0
     )
     or (
       variety_sowing_depth_cm is not null
       and variety_sowing_depth_cm <= 0
     )
     or (
       variety_germination_days is not null
       and variety_germination_days <= 0
     )
     or (
       variety_harvest_days is not null
       and variety_harvest_days <= 0
     )
     or (
       variety_min_temperature is not null
       and variety_optimal_temperature is not null
       and variety_min_temperature > variety_optimal_temperature
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.10 VALIDAZIONE RISULTATO EFFETTIVO DOPO FALLBACK
  -- --------------------------------------------------------------------------

  v_effective_min_temperature :=
    coalesce(
      variety_min_temperature,
      v_crop.min_temperature
    );

  v_effective_optimal_temperature :=
    coalesce(
      variety_optimal_temperature,
      v_crop.optimal_temperature
    );

  if v_effective_min_temperature is not null
     and v_effective_optimal_temperature is not null
     and v_effective_min_temperature > v_effective_optimal_temperature
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.11 VALIDAZIONE GRUPPO ACQUA QUANTITATIVA
  -- --------------------------------------------------------------------------
  -- Tutto NULL = fallback completo dalla Crop.
  -- Tutto valorizzato = override completo della varietà.

  if not (
    (
      variety_water_requirement_value is null
      and variety_water_requirement_basis is null
      and variety_water_interval_days is null
    )
    or
    (
      variety_water_requirement_value is not null
      and variety_water_requirement_value > 0
      and variety_water_requirement_basis in (
        'per_plant',
        'per_m2'
      )
      and variety_water_interval_days is not null
      and variety_water_interval_days > 0
    )
  )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.12 VALIDAZIONE RESA VARIETALE
  -- --------------------------------------------------------------------------

  if (
       variety_expected_yield_min is not null
       and variety_expected_yield_min < 0
     )
     or (
       variety_expected_yield_avg is not null
       and variety_expected_yield_avg < 0
     )
     or (
       variety_expected_yield_max is not null
       and variety_expected_yield_max < 0
     )
     or (
       variety_expected_yield_min is not null
       and variety_expected_yield_avg is not null
       and variety_expected_yield_min > variety_expected_yield_avg
     )
     or (
       variety_expected_yield_avg is not null
       and variety_expected_yield_max is not null
       and variety_expected_yield_avg > variety_expected_yield_max
     )
     or (
       variety_expected_yield_min is not null
       and variety_expected_yield_max is not null
       and variety_expected_yield_min > variety_expected_yield_max
     )
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.13 VALIDAZIONE UNITÀ RESA E FONTE
  -- --------------------------------------------------------------------------

  if variety_expected_yield_min is null
     and variety_expected_yield_avg is null
     and variety_expected_yield_max is null
  then
    if variety_expected_yield_unit is not null
       or v_yield_source_name is not null
       or v_yield_source_url is not null
       or variety_yield_source_year is not null
       or v_yield_notes is not null
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  else
    if variety_expected_yield_unit is null
       or variety_expected_yield_unit not in (
         'kg_per_m2',
         'kg_per_plant',
         'g_per_m2',
         'g_per_plant',
         'pieces_per_m2',
         'pieces_per_plant'
       )
    then
      return jsonb_build_object(
        'status', 'invalid_input'
      );
    end if;
  end if;

  if variety_yield_source_year is not null
     and variety_yield_source_year < 1800
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.14 CONTROLLO DATI INVARIATI
  -- --------------------------------------------------------------------------

  if v_current.name = v_name
     and v_current.scientific_name is not distinct from v_scientific_name
     and v_current.description is not distinct from v_description
     and v_current.default_start_method
       is not distinct from variety_default_start_method
     and v_current.row_spacing_cm
       is not distinct from variety_row_spacing_cm
     and v_current.plant_spacing_cm
       is not distinct from variety_plant_spacing_cm
     and v_current.sowing_depth_cm
       is not distinct from variety_sowing_depth_cm
     and v_current.germination_days
       is not distinct from variety_germination_days
     and v_current.harvest_days
       is not distinct from variety_harvest_days
     and v_current.min_temperature
       is not distinct from variety_min_temperature
     and v_current.optimal_temperature
       is not distinct from variety_optimal_temperature
     and v_current.water_requirement
       is not distinct from v_water_requirement
     and v_current.water_requirement_value
       is not distinct from variety_water_requirement_value
     and v_current.water_requirement_basis
       is not distinct from variety_water_requirement_basis
     and v_current.water_interval_days
       is not distinct from variety_water_interval_days
     and v_current.productivity
       is not distinct from v_productivity
     and v_current.expected_yield_min
       is not distinct from variety_expected_yield_min
     and v_current.expected_yield_avg
       is not distinct from variety_expected_yield_avg
     and v_current.expected_yield_max
       is not distinct from variety_expected_yield_max
     and v_current.expected_yield_unit
       is not distinct from variety_expected_yield_unit
     and v_current.yield_source_name
       is not distinct from v_yield_source_name
     and v_current.yield_source_url
       is not distinct from v_yield_source_url
     and v_current.yield_source_year
       is not distinct from variety_yield_source_year
     and v_current.yield_notes
       is not distinct from v_yield_notes
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_variety_id', target_crop_variety_id,
      'crop_id', v_current.crop_id,
      'row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.15 AGGIORNAMENTO VARIETÀ
  -- --------------------------------------------------------------------------

  begin
    update public.crop_varieties
    set
      name = v_name,
      scientific_name = v_scientific_name,
      description = v_description,

      default_start_method = variety_default_start_method,
      row_spacing_cm = variety_row_spacing_cm,
      plant_spacing_cm = variety_plant_spacing_cm,
      sowing_depth_cm = variety_sowing_depth_cm,
      germination_days = variety_germination_days,
      harvest_days = variety_harvest_days,
      min_temperature = variety_min_temperature,
      optimal_temperature = variety_optimal_temperature,

      water_requirement = v_water_requirement,
      water_requirement_value = variety_water_requirement_value,
      water_requirement_basis = variety_water_requirement_basis,
      water_interval_days = variety_water_interval_days,

      productivity = v_productivity,

      expected_yield_min = variety_expected_yield_min,
      expected_yield_avg = variety_expected_yield_avg,
      expected_yield_max = variety_expected_yield_max,
      expected_yield_unit = variety_expected_yield_unit,

      yield_source_name = v_yield_source_name,
      yield_source_url = v_yield_source_url,
      yield_source_year = variety_yield_source_year,
      yield_notes = v_yield_notes
    where id = target_crop_variety_id
      and profile_id = target_profile_id
      and row_version = expected_row_version
    returning
      row_version,
      updated_at
    into
      v_row_version,
      v_updated_at;

  exception
    when unique_violation then
      get stacked diagnostics
        v_constraint_name = constraint_name;

      if v_constraint_name = 'crop_varieties_crop_name_unique'
      then
        return jsonb_build_object(
          'status', 'duplicate_name'
        );
      end if;

      raise;
  end;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_variety_id', target_crop_variety_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current.row_version,
      'updated_at', v_current.updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 15.16 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'crop_variety_id', target_crop_variety_id,
    'profile_id', target_profile_id,
    'crop_id', v_current.crop_id,
    'name', v_name,
    'scientific_name', v_scientific_name,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 16. PRIVILEGI UPDATE_CROP_VARIETY
-- ============================================================================

revoke all
  on function public.update_crop_variety(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  from public, anon, authenticated;

grant execute
  on function public.update_crop_variety(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    text,
    text,
    text,
    text,
    integer,
    integer,
    numeric,
    integer,
    integer,
    integer,
    integer,
    text,
    numeric,
    text,
    integer,
    text,
    numeric,
    numeric,
    numeric,
    text,
    text,
    text,
    integer,
    text
  )
  to authenticated;
-- ============================================================================
-- 17. SET CROP VARIETY ACTIVE
-- ============================================================================
-- Modifica esclusivamente is_active della CropVariety.
-- La disattivazione è sempre consentita.
-- La riattivazione è consentita solo se la Crop padre è attiva.

create or replace function public.set_crop_variety_active(
  target_profile_id uuid,
  target_crop_variety_id uuid,
  expected_row_version bigint,

  target_client_id uuid,
  target_session_id uuid,
  lock_token text,

  variety_is_active boolean
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid := auth.uid();

  v_crop_id uuid;

  v_current_is_active boolean;
  v_current_row_version bigint;
  v_current_updated_at timestamptz;

  v_crop_name text;
  v_crop_is_active boolean;

  v_row_version bigint;
  v_updated_at timestamptz;
begin

  -- --------------------------------------------------------------------------
  -- 17.1 IDENTITÀ E AUTORIZZAZIONE OWNER
  -- --------------------------------------------------------------------------

  if v_auth_user_id is null
     or target_profile_id is null
     or target_crop_variety_id is null
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if not private.is_profile_owner(target_profile_id)
  then
    return jsonb_build_object(
      'status', 'forbidden'
    );
  end if;

  if expected_row_version is null
     or expected_row_version < 1
     or variety_is_active is null
  then
    return jsonb_build_object(
      'status', 'invalid_input'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.2 PROFILE WRITE AUTHORITY
  -- --------------------------------------------------------------------------

  if target_client_id is null
     or target_session_id is null
     or lock_token is null
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.3 LETTURA E LOCK DELLA VARIETÀ
  -- --------------------------------------------------------------------------

  select
    cv.crop_id,
    cv.is_active,
    cv.row_version,
    cv.updated_at
  into
    v_crop_id,
    v_current_is_active,
    v_current_row_version,
    v_current_updated_at
  from public.crop_varieties cv
  where cv.id = target_crop_variety_id
    and cv.profile_id = target_profile_id
  for update;

  if not found
  then
    return jsonb_build_object(
      'status', 'not_found'
    );
  end if;

  -- Rivalida il lease dopo l'eventuale attesa sul lock della varietà.

  if not private.lock_profile_write_authority(
    target_profile_id,
    target_client_id,
    target_session_id,
    lock_token
  )
  then
    return jsonb_build_object(
      'status', 'write_forbidden'
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.4 CONTROLLO OTTIMISTICO DELLA VERSIONE
  -- --------------------------------------------------------------------------

  if v_current_row_version <> expected_row_version
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_variety_id', target_crop_variety_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.5 STATO INVARIATO
  -- --------------------------------------------------------------------------

  if v_current_is_active = variety_is_active
  then
    return jsonb_build_object(
      'status', 'unchanged',
      'crop_variety_id', target_crop_variety_id,
      'crop_id', v_crop_id,
      'is_active', v_current_is_active,
      'row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.6 RIATTIVAZIONE: CROP PADRE DEVE ESSERE ATTIVA
  -- --------------------------------------------------------------------------
  -- Il lock della Crop padre serializza la riattivazione della varietà
  -- rispetto a un'eventuale disattivazione concorrente della Crop.

  if variety_is_active = true
  then
    select
      c.name,
      c.is_active
    into
      v_crop_name,
      v_crop_is_active
    from public.crops c
    where c.id = v_crop_id
      and c.profile_id = target_profile_id
    for update;

    if not found
    then
      return jsonb_build_object(
        'status', 'not_found'
      );
    end if;

    -- Rivalida il lease dopo l'eventuale attesa sul lock della Crop padre.

    if not private.lock_profile_write_authority(
      target_profile_id,
      target_client_id,
      target_session_id,
      lock_token
    )
    then
      return jsonb_build_object(
        'status', 'write_forbidden'
      );
    end if;

    if v_crop_is_active = false
    then
      return jsonb_build_object(
        'status', 'blocked_by_inactive_crop',
        'crop_variety_id', target_crop_variety_id,
        'crop_id', v_crop_id,
        'crop_name', v_crop_name
      );
    end if;
  end if;

  -- --------------------------------------------------------------------------
  -- 17.7 AGGIORNAMENTO STATO
  -- --------------------------------------------------------------------------

  update public.crop_varieties
  set is_active = variety_is_active
  where id = target_crop_variety_id
    and profile_id = target_profile_id
    and row_version = expected_row_version
  returning
    row_version,
    updated_at
  into
    v_row_version,
    v_updated_at;

  if not found
  then
    return jsonb_build_object(
      'status', 'version_conflict',
      'crop_variety_id', target_crop_variety_id,
      'expected_row_version', expected_row_version,
      'current_row_version', v_current_row_version,
      'updated_at', v_current_updated_at
    );
  end if;

  -- --------------------------------------------------------------------------
  -- 17.8 RISULTATO
  -- --------------------------------------------------------------------------

  return jsonb_build_object(
    'status', 'updated',
    'crop_variety_id', target_crop_variety_id,
    'profile_id', target_profile_id,
    'crop_id', v_crop_id,
    'is_active', variety_is_active,
    'row_version', v_row_version,
    'updated_at', v_updated_at
  );
end;
$$;

-- ============================================================================
-- 18. PRIVILEGI SET_CROP_VARIETY_ACTIVE
-- ============================================================================

revoke all
  on function public.set_crop_variety_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  from public, anon, authenticated;

grant execute
  on function public.set_crop_variety_active(
    uuid,
    uuid,
    bigint,
    uuid,
    uuid,
    text,
    boolean
  )
  to authenticated;
