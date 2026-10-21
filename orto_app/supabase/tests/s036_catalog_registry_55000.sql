-- Orto Smart - S036
-- Collaudo locale della gestione SQLSTATE 55000
-- Migrazione di riferimento:
-- 20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
--
-- ATTENZIONE:
-- Script di collaudo, NON migrazione Supabase.
-- Non eseguire fino ad approvazione esplicita.
-- Non utilizzare su database remoto o di produzione.
-- Nessun COMMIT consentito.

\set ON_ERROR_STOP on

BEGIN;

DO $s036_safety$
BEGIN
  IF current_database() <> 'postgres' THEN
    RAISE EXCEPTION
      'S036: database inatteso: %', current_database();
  END IF;

  IF current_user <> 'postgres' THEN
    RAISE EXCEPTION
      'S036: utente SQL inatteso: %', current_user;
  END IF;

  IF pg_is_in_recovery() THEN
    RAISE EXCEPTION
      'S036: server in recovery';
  END IF;

  IF current_setting('transaction_read_only') <> 'off' THEN
    RAISE EXCEPTION
      'S036: transazione in sola lettura';
  END IF;

  RAISE NOTICE
    'S036: controlli preliminari superati';
END;
$s036_safety$;

-- Collaudo composto da sei verifiche:
-- MU-01 / MU-02, AP-01 / AP-02, EV-01 / EV-02.
--
-- Esecuzione consentita esclusivamente dopo
-- revisione tecnica e autorizzazione esplicita.
-- Tutte le modifiche sono soggette al ROLLBACK finale.


-- ============================================================
-- S036 - Identita' autorizzata per il collaudo locale
-- ============================================================

DO $s036_identity$
DECLARE
  v_authority_id uuid;
  v_authority_count integer;
BEGIN
SELECT count(*)
  INTO v_authority_count
FROM public.catalog_authorities
WHERE can_manage_identity IS TRUE;

IF v_authority_count <> 1 THEN
  RAISE EXCEPTION
    'S036: attesa una sola Catalog Authority abilitata; trovate %',
    v_authority_count;
END IF;

SELECT auth_user_id
  INTO STRICT v_authority_id
FROM public.catalog_authorities
WHERE can_manage_identity IS TRUE;

  IF NOT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = v_authority_id
  ) THEN
    RAISE EXCEPTION
      'S036: Catalog Authority senza utente Auth corrispondente';
  END IF;

  PERFORM set_config(
    'request.jwt.claim.sub',
    v_authority_id::text,
    true
  );

  IF auth.uid() IS DISTINCT FROM v_authority_id THEN
    RAISE EXCEPTION
      'S036: simulazione identita'' non riuscita';
  END IF;

  IF NOT private.can_manage_catalog_identity() THEN
    RAISE EXCEPTION
      'S036: autorizzazione Catalog Authority non riconosciuta';
  END IF;

  RAISE NOTICE
    'S036: identita'' e autorizzazione verificate';
END;
$s036_identity$;


-- ============================================================
-- S036 - Preparazione dei tre record di collaudo
-- ============================================================

DO $s036_fixture$
DECLARE
  v_unit_id uuid;
  v_parameter_id uuid;
  v_enum_value_id uuid;
BEGIN
  -- Identificativi generati per questa esecuzione.
  v_unit_id := gen_random_uuid();
  v_parameter_id := gen_random_uuid();
  v_enum_value_id := gen_random_uuid();

  -- Unita' di misura.
  INSERT INTO public.measurement_units (
    id,
    code,
    name,
    symbol,
    quantity_kind,
    to_base_factor,
    to_base_offset
  )
  VALUES (
    v_unit_id,
    'S036_TEST_UNIT',
    'S036 Test Unit',
    's036u',
    'LENGTH',
    1,
    0
  );

  -- Parametro agronomico ENUM intrinseco.
  INSERT INTO public.agronomic_parameters (
    id,
    code,
    name,
    value_schema,
    knowledge_scope,
    allows_crop
  )
  VALUES (
    v_parameter_id,
    'S036_TEST_PARAMETER',
    'S036 Test Parameter',
    'ENUM',
    'INTRINSIC',
    true
  );

  -- Valore ENUM associato al parametro.
  INSERT INTO public.parameter_enum_values (
    id,
    parameter_id,
    code,
    name,
    sort_order
  )
  VALUES (
    v_enum_value_id,
    v_parameter_id,
    'S036_TEST_ENUM',
    'S036 Test Enum',
    0
  );

  -- Verifica delle tre righe inserite.
  IF NOT EXISTS (
    SELECT 1
    FROM public.measurement_units
    WHERE id = v_unit_id
  ) THEN
    RAISE EXCEPTION 'S036: unita'' di misura non creata';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.agronomic_parameters
    WHERE id = v_parameter_id
      AND value_schema = 'ENUM'
      AND knowledge_scope = 'INTRINSIC'
  ) THEN
    RAISE EXCEPTION 'S036: parametro agronomico non creato';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.parameter_enum_values
    WHERE id = v_enum_value_id
      AND parameter_id = v_parameter_id
  ) THEN
    RAISE EXCEPTION 'S036: valore ENUM non creato';
  END IF;

  RAISE NOTICE
    'S036: tre record di collaudo creati e verificati';
END;
$s036_fixture$;


-- ============================================================
-- S036 - Simulazione controllata dell'eccezione SQLSTATE 55000
-- ============================================================
--
-- Funzione e trigger creati nella transazione di collaudo.
-- Il ROLLBACK finale ne annullera' la creazione.
--
-- I trigger hanno il prefisso a_s036_ per essere eseguiti
-- prima dei trigger applicativi esistenti, a parita'
-- di evento e momento di attivazione.

CREATE FUNCTION private.s036_test_raise_55000()
RETURNS trigger
LANGUAGE plpgsql
AS $s036_trigger$
DECLARE
  v_message text;
BEGIN
  v_message := current_setting(
    'ortosmart.s036_test_55000_message',
    true
  );

  IF v_message IS NULL OR v_message = '' THEN
    RAISE EXCEPTION
      'S036: messaggio di simulazione non configurato';
  END IF;

  RAISE EXCEPTION USING
    ERRCODE = '55000',
    MESSAGE = v_message;
END;
$s036_trigger$;

CREATE TRIGGER a_s036_test_55000
BEFORE UPDATE ON public.measurement_units
FOR EACH ROW
EXECUTE FUNCTION private.s036_test_raise_55000();

CREATE TRIGGER a_s036_test_55000
BEFORE UPDATE ON public.agronomic_parameters
FOR EACH ROW
EXECUTE FUNCTION private.s036_test_raise_55000();

CREATE TRIGGER a_s036_test_55000
BEFORE UPDATE ON public.parameter_enum_values
FOR EACH ROW
EXECUTE FUNCTION private.s036_test_raise_55000();

-- Verifica che i tre trigger siano presenti e attivi.
DO $s036_trigger_check$
DECLARE
  v_trigger_count integer;
BEGIN
  SELECT count(*)
    INTO v_trigger_count
  FROM pg_trigger t
  JOIN pg_class c ON c.oid = t.tgrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname IN (
      'measurement_units',
      'agronomic_parameters',
      'parameter_enum_values'
    )
    AND t.tgname = 'a_s036_test_55000'
    AND t.tgenabled = 'O'
    AND (t.tgtype & 2) <> 0
    AND (t.tgtype & 1) <> 0;

  IF v_trigger_count <> 3 THEN
    RAISE EXCEPTION
      'S036: attesi 3 trigger di simulazione, trovati %',
      v_trigger_count;
  END IF;

  RAISE NOTICE
    'S036: tre trigger di simulazione presenti e attivi';
END;
$s036_trigger_check$;


-- ============================================================
-- S036 - MU-01 / MU-02
-- Collaudo update_measurement_unit
-- ============================================================

DO $s036_test_measurement_unit$
DECLARE
  v_unit public.measurement_units%ROWTYPE;
  v_result jsonb;
  v_expected_message text :=
    'Measurement Unit semantic fields are frozen by immutable Knowledge artifacts';
  v_other_message text :=
    'S036_TEST: unrelated SQLSTATE 55000 for measurement unit';
  v_error_state text;
  v_error_message text;
  v_exception_received boolean := false;
BEGIN
  SELECT *
    INTO STRICT v_unit
  FROM public.measurement_units
  WHERE code = 'S036_TEST_UNIT';

  IF v_unit.name <> 'S036 Test Unit' THEN
    RAISE EXCEPTION 'S036 MU: nome iniziale inatteso';
  END IF;

  IF private.is_measurement_unit_semantically_frozen(v_unit.id) THEN
    RAISE EXCEPTION 'S036 MU: record gia'' congelato';
  END IF;

  -- MU-01: messaggio esatto, atteso semantics_frozen.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_expected_message,
    true
  );

  v_result := public.update_measurement_unit(
    v_unit.id,
    v_unit.row_version,
    v_unit.code,
    'S036 Test Unit Updated',
    v_unit.symbol,
    v_unit.quantity_kind,
    v_unit.to_base_factor,
    v_unit.to_base_offset,
    v_unit.description
  );

  IF v_result ->> 'status' IS DISTINCT FROM 'semantics_frozen' THEN
    RAISE EXCEPTION
      'S036 MU-01 FAILED: risultato %', v_result;
  END IF;

  RAISE NOTICE 'S036 MU-01 PASSED';

  -- MU-02: messaggio differente, attesa propagazione.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_other_message,
    true
  );

  BEGIN
    v_result := public.update_measurement_unit(
      v_unit.id,
      v_unit.row_version,
      v_unit.code,
      'S036 Test Unit Updated',
      v_unit.symbol,
      v_unit.quantity_kind,
      v_unit.to_base_factor,
      v_unit.to_base_offset,
      v_unit.description
    );
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS
      v_error_state = RETURNED_SQLSTATE,
      v_error_message = MESSAGE_TEXT;

    IF v_error_state IS DISTINCT FROM '55000'
       OR v_error_message IS DISTINCT FROM v_other_message THEN
      RAISE EXCEPTION
        'S036 MU-02 FAILED: SQLSTATE %, messaggio %',
        v_error_state, v_error_message;
    END IF;

    v_exception_received := true;
  END;

  IF NOT v_exception_received THEN
    RAISE EXCEPTION
      'S036 MU-02 FAILED: eccezione non propagata; risultato %',
      v_result;
  END IF;

  RAISE NOTICE 'S036 MU-02 PASSED';
END;
$s036_test_measurement_unit$;


-- ============================================================
-- S036 - AP-01 / AP-02
-- Collaudo update_agronomic_parameter
-- ============================================================

DO $s036_test_agronomic_parameter$
DECLARE
  v_parameter public.agronomic_parameters%ROWTYPE;
  v_result jsonb;

  v_expected_message text :=
    'Agronomic Parameter semantic fields are frozen by immutable Knowledge artifacts';

  v_other_message text :=
    'S036_TEST: unrelated SQLSTATE 55000 for agronomic parameter';

  v_error_state text;
  v_error_message text;
  v_exception_received boolean := false;
BEGIN
  SELECT *
    INTO STRICT v_parameter
  FROM public.agronomic_parameters
  WHERE code = 'S036_TEST_PARAMETER';

  IF v_parameter.name <> 'S036 Test Parameter'
     OR v_parameter.value_schema <> 'ENUM'
     OR v_parameter.knowledge_scope <> 'INTRINSIC' THEN
    RAISE EXCEPTION
      'S036 AP: configurazione iniziale inattesa';
  END IF;

  IF private.is_agronomic_parameter_semantically_frozen(
    v_parameter.id
  ) THEN
    RAISE EXCEPTION
      'S036 AP: record gia'' congelato';
  END IF;

  -- AP-01: messaggio esatto.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_expected_message,
    true
  );

  v_result := public.update_agronomic_parameter(
    v_parameter.id,
    v_parameter.row_version,
    v_parameter.code,
    'S036 Test Parameter Updated',
    v_parameter.description,
    v_parameter.value_schema,
    v_parameter.knowledge_scope,
    v_parameter.quantity_kind,
    v_parameter.canonical_unit_id,
    v_parameter.allows_crop,
    v_parameter.allows_cultivar,
    v_parameter.allows_production_context,
    v_parameter.allows_protection_context,
    v_parameter.allows_training_context,
    v_parameter.allows_harvest_purpose
  );

  IF v_result ->> 'status' IS DISTINCT FROM 'semantics_frozen' THEN
    RAISE EXCEPTION
      'S036 AP-01 FAILED: risultato %',
      v_result;
  END IF;

  RAISE NOTICE 'S036 AP-01 PASSED';

  -- AP-02: messaggio differente.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_other_message,
    true
  );

  BEGIN
    v_result := public.update_agronomic_parameter(
      v_parameter.id,
      v_parameter.row_version,
      v_parameter.code,
      'S036 Test Parameter Updated',
      v_parameter.description,
      v_parameter.value_schema,
      v_parameter.knowledge_scope,
      v_parameter.quantity_kind,
      v_parameter.canonical_unit_id,
      v_parameter.allows_crop,
      v_parameter.allows_cultivar,
      v_parameter.allows_production_context,
      v_parameter.allows_protection_context,
      v_parameter.allows_training_context,
      v_parameter.allows_harvest_purpose
    );
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS
      v_error_state = RETURNED_SQLSTATE,
      v_error_message = MESSAGE_TEXT;

    IF v_error_state IS DISTINCT FROM '55000'
       OR v_error_message IS DISTINCT FROM v_other_message THEN
      RAISE EXCEPTION
        'S036 AP-02 FAILED: SQLSTATE %, messaggio %',
        v_error_state,
        v_error_message;
    END IF;

    v_exception_received := true;
  END;

  IF NOT v_exception_received THEN
    RAISE EXCEPTION
      'S036 AP-02 FAILED: eccezione non propagata; risultato %',
      v_result;
  END IF;

  RAISE NOTICE 'S036 AP-02 PASSED';
END;
$s036_test_agronomic_parameter$;


-- ============================================================
-- S036 - EV-01 / EV-02
-- Collaudo update_parameter_enum_value
-- ============================================================

DO $s036_test_parameter_enum_value$
DECLARE
  v_enum public.parameter_enum_values%ROWTYPE;
  v_result jsonb;

  v_expected_message text :=
    'Parameter Enum Value semantic fields are frozen by immutable Knowledge artifacts';

  v_other_message text :=
    'S036_TEST: unrelated SQLSTATE 55000 for enum value';

  v_error_state text;
  v_error_message text;
  v_exception_received boolean := false;
BEGIN
  SELECT *
    INTO STRICT v_enum
  FROM public.parameter_enum_values
  WHERE code = 'S036_TEST_ENUM';

  IF v_enum.name <> 'S036 Test Enum' THEN
    RAISE EXCEPTION
      'S036 EV: nome iniziale inatteso';
  END IF;

  IF private.is_parameter_enum_value_semantically_frozen(
    v_enum.id
  ) THEN
    RAISE EXCEPTION
      'S036 EV: record gia'' congelato';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.agronomic_parameters
    WHERE id = v_enum.parameter_id
      AND value_schema = 'ENUM'
      AND is_active IS TRUE
  ) THEN
    RAISE EXCEPTION
      'S036 EV: parametro ENUM non valido o inattivo';
  END IF;

  -- EV-01: messaggio esatto.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_expected_message,
    true
  );

  v_result := public.update_parameter_enum_value(
    v_enum.id,
    v_enum.row_version,
    v_enum.parameter_id,
    v_enum.code,
    'S036 Test Enum Updated',
    v_enum.description,
    v_enum.sort_order
  );

  IF v_result ->> 'status' IS DISTINCT FROM 'semantics_frozen' THEN
    RAISE EXCEPTION
      'S036 EV-01 FAILED: risultato %',
      v_result;
  END IF;

  RAISE NOTICE 'S036 EV-01 PASSED';

  -- EV-02: messaggio differente.
  PERFORM set_config(
    'ortosmart.s036_test_55000_message',
    v_other_message,
    true
  );

  BEGIN
    v_result := public.update_parameter_enum_value(
      v_enum.id,
      v_enum.row_version,
      v_enum.parameter_id,
      v_enum.code,
      'S036 Test Enum Updated',
      v_enum.description,
      v_enum.sort_order
    );
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS
      v_error_state = RETURNED_SQLSTATE,
      v_error_message = MESSAGE_TEXT;

    IF v_error_state IS DISTINCT FROM '55000'
       OR v_error_message IS DISTINCT FROM v_other_message THEN
      RAISE EXCEPTION
        'S036 EV-02 FAILED: SQLSTATE %, messaggio %',
        v_error_state,
        v_error_message;
    END IF;

    v_exception_received := true;
  END;

  IF NOT v_exception_received THEN
    RAISE EXCEPTION
      'S036 EV-02 FAILED: eccezione non propagata; risultato %',
      v_result;
  END IF;

  RAISE NOTICE 'S036 EV-02 PASSED';
END;
$s036_test_parameter_enum_value$;


ROLLBACK;
