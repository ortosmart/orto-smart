-- ORTO SMART - S040
-- Collaudo SQL del lifecycle delle pianificazioni
-- SOLO DATABASE LOCALE - ESECUZIONE SOLO CON AUTORIZZAZIONE ESPLICITA.
-- Script in preparazione: NON ANCORA ESEGUIBILE COME COLLAUDO COMPLETO.

\set ON_ERROR_STOP on

BEGIN;

DO $s040_safety$
BEGIN
  IF current_database() <> 'postgres' THEN
    RAISE EXCEPTION 'S040: database non autorizzato';
  END IF;

  IF current_user <> 'postgres' THEN
    RAISE EXCEPTION 'S040: ruolo SQL non autorizzato';
  END IF;

  IF pg_is_in_recovery() THEN
    RAISE EXCEPTION 'S040: database in recovery';
  END IF;

  IF current_setting('transaction_read_only') <> 'off' THEN
    RAISE EXCEPTION 'S040: transazione read-only';
  END IF;
END;
$s040_safety$;

-- S040.1 - Identita' del proprietario locale.
DO $s040_identity$
DECLARE
  v_profile_id uuid;
BEGIN
  IF (SELECT count(*) FROM public.profiles) <> 1 THEN
    RAISE EXCEPTION 'S040: atteso esattamente un profilo locale';
  END IF;

  SELECT id INTO STRICT v_profile_id
  FROM public.profiles;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profile_memberships pm
    WHERE pm.profile_id = v_profile_id
      AND pm.auth_user_id = v_profile_id
      AND pm.role = 'owner'
      AND pm.is_enabled
  ) THEN
    RAISE EXCEPTION 'S040: proprietario locale non valido';
  END IF;

  PERFORM set_config(
    'ortosmart.s040_profile_id',
    v_profile_id::text,
    true
  );
END;
$s040_identity$;
-- S040.2 - Simulazione dell'identita' autenticata.
SELECT set_config(
  'request.jwt.claim.sub',
  current_setting('ortosmart.s040_profile_id'),
  true
);

DO $s040_auth$
BEGIN
  IF auth.uid() IS DISTINCT FROM
     current_setting('ortosmart.s040_profile_id')::uuid
  THEN
    RAISE EXCEPTION 'S040: identita JWT non coerente';
  END IF;
END;
$s040_auth$;
-- S040.3 - Acquisizione temporanea della Write Authority.
DO $s040_lock$
DECLARE
  v_profile_id uuid :=
    current_setting('ortosmart.s040_profile_id')::uuid;
  v_client_id uuid := gen_random_uuid();
  v_session_id uuid := gen_random_uuid();
  v_result jsonb;
BEGIN
  v_result := public.acquire_profile_edit_lock(
    v_profile_id,
    v_client_id,
    v_session_id
  );

  IF v_result->>'status' IS DISTINCT FROM 'acquired'
     OR v_result->>'lock_token' IS NULL
  THEN
    RAISE EXCEPTION
      'S040: acquisizione lock fallita: %',
      v_result->>'status';
  END IF;

  PERFORM set_config(
    'ortosmart.s040_client_id',
    v_client_id::text,
    true
  );

  PERFORM set_config(
    'ortosmart.s040_session_id',
    v_session_id::text,
    true
  );

  PERFORM set_config(
    'ortosmart.s040_lock_token',
    v_result->>'lock_token',
    true
  );
END;
$s040_lock$;
-- S040.4 - Preparazione dei dati tecnici: orto e stagione.
DO $s040_fixture_garden$
DECLARE
  v_profile_id uuid :=
    current_setting('ortosmart.s040_profile_id')::uuid;
  v_garden_id uuid;
  v_season_id uuid;
BEGIN
  INSERT INTO public.gardens (
    profile_id,
    name,
    latitude,
    longitude,
    elevation_m,
    timezone,
    country_code
  )
  VALUES (
    v_profile_id,
    'Collaudo s040',
    45.0,
    12.0,
    50,
    'Europe/Rome',
    'IT'
  )
  RETURNING id INTO v_garden_id;

  INSERT INTO public.seasons (
    garden_id,
    year,
    name,
    start_date,
    end_date,
    is_active
  )
  VALUES (
    v_garden_id,
    2026,
    'Collaudo S040',
    DATE '2026-01-01',
    DATE '2026-12-31',
    true
  )
  RETURNING id INTO v_season_id;

  PERFORM set_config(
    'ortosmart.s040_garden_id',
    v_garden_id::text,
    true
  );

  PERFORM set_config(
    'ortosmart.s040_season_id',
    v_season_id::text,
    true
  );
END;
$s040_fixture_garden$;
-- S040.5 - Preparazione dell'aiuola e della geometria.
DO $s040_fixture_bed$
DECLARE
  v_garden_id uuid :=
    current_setting('ortosmart.s040_garden_id')::uuid;
  v_bed_id uuid;
BEGIN
  INSERT INTO public.beds (
    garden_id,
    number,
    name,
    is_active
  )
  VALUES (
    v_garden_id,
    1,
    'Aiuola collaudo S040',
    true
  )
  RETURNING id INTO v_bed_id;

  INSERT INTO public.bed_geometries (
    bed_id,
    width_cm,
    length_cm,
    valid_from,
    valid_to
  )
  VALUES (
    v_bed_id,
    90,
    700,
    DATE '2026-01-01',
    NULL
  );

  PERFORM set_config(
    'ortosmart.s040_bed_id',
    v_bed_id::text,
    true
  );
END;
$s040_fixture_bed$;
-- S040.6 - Preparazione del catalogo botanico temporaneo.
DO $s040_fixture_crop$
DECLARE
  v_taxon_id uuid;
  v_crop_id uuid;
  v_name text := 'Species collaudus s040';
  v_crop_name text := 'Coltura tecnica S040';
BEGIN
INSERT INTO public.botanical_taxa (
  rank,
  scientific_name
)
VALUES (
  'SPECIES',
  v_name
)
RETURNING id INTO v_taxon_id;

INSERT INTO public.crops (
  taxon_id,
  canonical_name,
  is_active
)
VALUES (
  v_taxon_id,
  v_crop_name,
  true
)
RETURNING id INTO v_crop_id;

  PERFORM set_config(
    'ortosmart.s040_crop_id',
    v_crop_id::text,
    true
  );
END;
$s040_fixture_crop$;
-- S040.7 - Creazione di una pianificazione in bozza.
SET LOCAL ROLE authenticated;

DO $s040_create_draft$
DECLARE
  v_result jsonb;
  v_planned_id uuid;
BEGIN
  v_result := public.create_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_garden_id :=
      current_setting('ortosmart.s040_garden_id')::uuid,
    target_season_id :=
      current_setting('ortosmart.s040_season_id')::uuid,
    target_bed_id :=
      current_setting('ortosmart.s040_bed_id')::uuid,
    target_crop_id :=
      current_setting('ortosmart.s040_crop_id')::uuid,
    target_cultivar_id := NULL::uuid,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    planting_start_method := 'direct_rows',
    planting_start_date := DATE '2026-11-06',
    planting_end_date := DATE '2026-12-15',
    planting_start_position_cm := 0,
    planting_length_cm := 100,
    planting_occupied_width_cm := 40,
    planting_plant_spacing_cm := NULL::integer,
    planting_row_spacing_cm := NULL::integer,
    planting_rows_count := NULL::integer,
    planting_plants_count := NULL::integer,
    planting_seed_quantity_g := NULL::numeric,
    planting_notes := 'Collaudo transazionale S040'
  );

  IF v_result->>'status' IS DISTINCT FROM 'created'
     OR v_result->>'row_version' IS DISTINCT FROM '1'
     OR NULLIF(v_result->>'planned_planting_id', '') IS NULL
  THEN
    RAISE EXCEPTION
      'S040: creazione draft fallita: %',
      v_result;
  END IF;

  v_planned_id :=
    (v_result->>'planned_planting_id')::uuid;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'draft'
      AND pp.row_version = 1
  ) THEN
    RAISE EXCEPTION
      'S040: draft non trovato o stato/versione errati';
  END IF;

  PERFORM set_config(
    'ortosmart.s040_planned_id',
    v_planned_id::text,
    true
  );
END;
$s040_create_draft$;

RESET ROLE;
-- S040.8 - Aggiornamento della pianificazione draft.
SET LOCAL ROLE authenticated;

DO $s040_update_draft$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_result jsonb;
BEGIN
  v_result := public.update_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 1::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    planting_bed_id :=
      current_setting('ortosmart.s040_bed_id')::uuid,
    planting_crop_id :=
      current_setting('ortosmart.s040_crop_id')::uuid,
    planting_cultivar_id := NULL::uuid,
    planting_start_method := 'direct_rows',
    planting_start_date := DATE '2026-11-06',
    planting_end_date := DATE '2026-12-15',
    planting_start_position_cm := 0,
    planting_length_cm := 120,
    planting_occupied_width_cm := 40,
    planting_plant_spacing_cm := NULL::integer,
    planting_row_spacing_cm := 30,
    planting_rows_count := 2,
    planting_plants_count := NULL::integer,
    planting_seed_quantity_g := NULL::numeric,
    planting_notes := 'Draft aggiornato S040'
  );

  IF v_result->>'status' IS DISTINCT FROM 'updated'
     OR v_result->>'row_version' IS DISTINCT FROM '2'
     OR v_result->>'planned_planting_id'
        IS DISTINCT FROM v_planned_id::text
  THEN
    RAISE EXCEPTION
      'S040: aggiornamento draft fallito: %',
      v_result;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'draft'
      AND pp.row_version = 2
      AND pp.length_cm = 120
  ) THEN
    RAISE EXCEPTION
      'S040: dati del draft aggiornato non coerenti';
  END IF;
END;
$s040_update_draft$;

RESET ROLE;
-- S040.9 - Conferma della pianificazione.
SET LOCAL ROLE authenticated;

DO $s040_confirm$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_result jsonb;
BEGIN
  v_result := public.confirm_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 2::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token')
  );

  IF v_result->>'status' IS DISTINCT FROM 'confirmed'
     OR v_result->>'row_version' IS DISTINCT FROM '3'
     OR v_result->>'planned_planting_id'
        IS DISTINCT FROM v_planned_id::text
  THEN
    RAISE EXCEPTION
      'S040: conferma pianificazione fallita: %',
      v_result;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'confirmed'
      AND pp.row_version = 3
      AND pp.length_cm = 120
  ) THEN
    RAISE EXCEPTION
      'S040: pianificazione confermata non coerente';
  END IF;
END;
$s040_confirm$;

RESET ROLE;
-- S040.10 - Creazione e annullamento di un secondo draft.
SET LOCAL ROLE authenticated;

DO $s040_cancel_draft$
DECLARE
  v_result jsonb;
  v_planned_id uuid;
BEGIN
  -- Crea una seconda pianificazione indipendente.
  v_result := public.create_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_garden_id :=
      current_setting('ortosmart.s040_garden_id')::uuid,
    target_season_id :=
      current_setting('ortosmart.s040_season_id')::uuid,
    target_bed_id :=
      current_setting('ortosmart.s040_bed_id')::uuid,
    target_crop_id :=
      current_setting('ortosmart.s040_crop_id')::uuid,
    target_cultivar_id := NULL::uuid,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    planting_start_method := 'direct_rows',
    planting_start_date := DATE '2026-11-06',
    planting_end_date := DATE '2026-12-15',
    planting_start_position_cm := 200,
    planting_length_cm := 100,
    planting_occupied_width_cm := 40,
    planting_plant_spacing_cm := NULL::integer,
    planting_row_spacing_cm := NULL::integer,
    planting_rows_count := NULL::integer,
    planting_plants_count := NULL::integer,
    planting_seed_quantity_g := NULL::numeric,
    planting_notes := 'Draft da annullare S040'
  );

  IF v_result->>'status' IS DISTINCT FROM 'created'
     OR v_result->>'row_version' IS DISTINCT FROM '1'
     OR NULLIF(v_result->>'planned_planting_id', '') IS NULL
  THEN
    RAISE EXCEPTION
      'S040: creazione secondo draft fallita: %',
      v_result;
  END IF;

  v_planned_id :=
    (v_result->>'planned_planting_id')::uuid;

  -- Annulla il secondo draft.
  v_result := public.cancel_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 1::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token')
  );

  IF v_result->>'status' IS DISTINCT FROM 'cancelled'
     OR v_result->>'row_version' IS DISTINCT FROM '2'
     OR v_result->>'planned_planting_id'
        IS DISTINCT FROM v_planned_id::text
  THEN
    RAISE EXCEPTION
      'S040: annullamento draft fallito: %',
      v_result;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'cancelled'
      AND pp.row_version = 2
  ) THEN
    RAISE EXCEPTION
      'S040: stato del draft annullato non coerente';
  END IF;

  -- Verifica che non sia possibile annullarlo nuovamente.
  v_result := public.cancel_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 2::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token')
  );

  IF v_result->>'status'
     IS DISTINCT FROM 'blocked_by_lifecycle'
  THEN
    RAISE EXCEPTION
      'S040: secondo annullamento non bloccato: %',
      v_result;
  END IF;
END;
$s040_cancel_draft$;

RESET ROLE;
-- S040.11 - Esecuzione della pianificazione confermata.
SET LOCAL ROLE authenticated;

DO $s040_execute$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_result jsonb;
  v_planting_id uuid;
BEGIN
  v_result := public.execute_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 3::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    effective_start_date := DATE '2026-11-06'
  );

  IF v_result->>'status' IS DISTINCT FROM 'executed'
     OR v_result->>'row_version' IS DISTINCT FROM '4'
     OR v_result->>'planned_planting_id'
        IS DISTINCT FROM v_planned_id::text
     OR v_result->>'effective_start_date'
        IS DISTINCT FROM '2026-11-06'
     OR NULLIF(v_result->>'planting_id', '') IS NULL
  THEN
    RAISE EXCEPTION
      'S040: esecuzione pianificazione fallita: %',
      v_result;
  END IF;

  v_planting_id := (v_result->>'planting_id')::uuid;

  PERFORM set_config(
    'ortosmart.s040_executed_planting_id',
    v_planting_id::text,
    true
  );

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'executed'
      AND pp.row_version = 4
      AND pp.executed_planting_id = v_planting_id
  ) THEN
    RAISE EXCEPTION
      'S040: collegamento pianificazione-coltivazione non coerente';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.plantings p
    WHERE p.id = v_planting_id
      AND p.profile_id =
        current_setting('ortosmart.s040_profile_id')::uuid
      AND p.bed_id =
        current_setting('ortosmart.s040_bed_id')::uuid
      AND p.crop_id =
        current_setting('ortosmart.s040_crop_id')::uuid
      AND p.start_method = 'direct_rows'
      AND p.start_date = DATE '2026-11-06'
      AND p.start_position_cm = 0
      AND p.length_cm = 120
      AND p.occupied_width_cm = 40
      AND p.rows_count = 2
      AND p.row_spacing_cm = 30
      AND p.status = 'sown'
  ) THEN
    RAISE EXCEPTION
      'S040: coltivazione reale non coerente con la pianificazione';
  END IF;
END;
$s040_execute$;

RESET ROLE;
-- S040.12 - Versione obsoleta e assenza di duplicazioni.
SET LOCAL ROLE authenticated;

DO $s040_version_conflict$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_planting_id uuid :=
    current_setting('ortosmart.s040_executed_planting_id')::uuid;
  v_result jsonb;
  v_count_before bigint;
  v_count_after bigint;
BEGIN
  SELECT count(*)
    INTO v_count_before
  FROM public.plantings p
  WHERE p.bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  v_result := public.execute_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 3::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    effective_start_date := DATE '2026-11-06'
  );

  IF v_result->>'status' IS DISTINCT FROM 'version_conflict'
     OR v_result->>'current_row_version' IS DISTINCT FROM '4'
  THEN
    RAISE EXCEPTION
      'S040: versione obsoleta non respinta: %',
      v_result;
  END IF;

  SELECT count(*)
    INTO v_count_after
  FROM public.plantings p
  WHERE p.bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  IF v_count_after <> v_count_before THEN
    RAISE EXCEPTION
      'S040: numero coltivazioni modificato dopo conflitto';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'executed'
      AND pp.row_version = 4
      AND pp.executed_planting_id = v_planting_id
  ) THEN
    RAISE EXCEPTION
      'S040: pianificazione alterata dopo conflitto';
  END IF;
END;
$s040_version_conflict$;

RESET ROLE;
-- S040.13 - Blocco della seconda esecuzione.
SET LOCAL ROLE authenticated;

DO $s040_second_execution$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_planting_id uuid :=
    current_setting('ortosmart.s040_executed_planting_id')::uuid;
  v_result jsonb;
  v_count_before bigint;
  v_count_after bigint;
BEGIN
  SELECT count(*)
    INTO v_count_before
  FROM public.plantings
  WHERE bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  v_result := public.execute_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 4::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token :=
      current_setting('ortosmart.s040_lock_token'),
    effective_start_date := DATE '2026-11-06'
  );

  IF v_result->>'status'
     IS DISTINCT FROM 'blocked_by_lifecycle'
  THEN
    RAISE EXCEPTION
      'S040: seconda esecuzione non bloccata: %',
      v_result;
  END IF;

  SELECT count(*)
    INTO v_count_after
  FROM public.plantings
  WHERE bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  IF v_count_after <> v_count_before THEN
    RAISE EXCEPTION
      'S040: seconda esecuzione ha modificato il numero di coltivazioni';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'executed'
      AND pp.row_version = 4
      AND pp.executed_planting_id = v_planting_id
  ) THEN
    RAISE EXCEPTION
      'S040: pianificazione modificata dopo seconda esecuzione';
  END IF;
END;
$s040_second_execution$;

RESET ROLE;
-- S040.14 - Rifiuto di una Write Authority non valida.
SET LOCAL ROLE authenticated;

DO $s040_invalid_authority$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_planting_id uuid :=
    current_setting('ortosmart.s040_executed_planting_id')::uuid;
  v_result jsonb;
  v_count_before bigint;
  v_count_after bigint;
BEGIN
  SELECT count(*)
    INTO v_count_before
  FROM public.plantings
  WHERE bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  v_result := public.execute_planned_planting(
    target_profile_id :=
      current_setting('ortosmart.s040_profile_id')::uuid,
    target_planned_planting_id := v_planned_id,
    expected_row_version := 4::bigint,
    target_client_id :=
      current_setting('ortosmart.s040_client_id')::uuid,
    target_session_id :=
      current_setting('ortosmart.s040_session_id')::uuid,
    lock_token := 's040_invalid_lock_token',
    effective_start_date := DATE '2026-11-06'
  );

  IF v_result->>'status' IS DISTINCT FROM 'write_forbidden'
  THEN
    RAISE EXCEPTION
      'S040: Write Authority non valida non respinta: %',
      v_result;
  END IF;

  SELECT count(*)
    INTO v_count_after
  FROM public.plantings
  WHERE bed_id =
    current_setting('ortosmart.s040_bed_id')::uuid;

  IF v_count_after <> v_count_before THEN
    RAISE EXCEPTION
      'S040: coltivazioni modificate dopo rifiuto Write Authority';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'executed'
      AND pp.row_version = 4
      AND pp.executed_planting_id = v_planting_id
  ) THEN
    RAISE EXCEPTION
      'S040: pianificazione alterata dopo rifiuto Write Authority';
  END IF;
END;
$s040_invalid_authority$;

RESET ROLE;
-- S040.15 - Blocco della modifica diretta alla pianificazione.
SET LOCAL ROLE authenticated;

DO $s040_direct_update$
DECLARE
  v_planned_id uuid :=
    current_setting('ortosmart.s040_planned_id')::uuid;
  v_planting_id uuid :=
    current_setting('ortosmart.s040_executed_planting_id')::uuid;
  v_original_notes text;
  v_sqlstate text;
  v_rejected boolean := false;
BEGIN
  SELECT notes
    INTO STRICT v_original_notes
  FROM public.planned_plantings
  WHERE id = v_planned_id;

  BEGIN
    UPDATE public.planned_plantings
    SET notes = 'Modifica diretta vietata S040'
    WHERE id = v_planned_id;

  EXCEPTION WHEN insufficient_privilege THEN
    GET STACKED DIAGNOSTICS v_sqlstate = RETURNED_SQLSTATE;
    IF v_sqlstate = '42501' THEN
      v_rejected := true;
    END IF;
  END;

  IF NOT v_rejected THEN
    RAISE EXCEPTION
      'S040: UPDATE diretto non respinto con SQLSTATE 42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.planned_plantings pp
    WHERE pp.id = v_planned_id
      AND pp.status = 'executed'
      AND pp.row_version = 4
      AND pp.executed_planting_id = v_planting_id
      AND pp.notes IS NOT DISTINCT FROM v_original_notes
  ) THEN
    RAISE EXCEPTION
      'S040: pianificazione alterata dopo UPDATE diretto';
  END IF;
END;
$s040_direct_update$;

RESET ROLE;

ROLLBACK;
