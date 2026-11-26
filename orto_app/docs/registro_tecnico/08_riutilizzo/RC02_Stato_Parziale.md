# RC02 - Stato parziale della ricognizione

## 1. Identificazione

- Identificativo: RC02.
- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Stato tecnico: IN CORSO.
- Stato quantitativo: APERTO.
- Ambiente remoto: NV.

## 2. Oggetto

Write Authority, edit lock, single-writer e integrazione
con i percorsi autoritativi.

La ricognizione identifica le infrastrutture disponibili,
i relativi contratti e le verifiche ancora necessarie.

## 3. Piano dei controlli

| ID | Controllo | Stato |
|---|---|---|
| 01 | Inventario Flutter, SQL e test | Concluso |
| 02 | Struttura profile_edit_locks | Concluso |
| 03 | Helper, acquisizione e rilascio RPC | In corso |
| 04 | Heartbeat, scadenza e rinnovo | Da eseguire |
| 05 | Lifecycle takeover | Da eseguire |
| 06 | Controller, scheduler, scope e gate Flutter | Da eseguire |
| 07 | Integrazione nei domini | Da eseguire |
| 08 | Approfondimento NC-RC01-001 | Da eseguire |
| 09 | Test ed evidenze integrate | Da eseguire |
| 10 | Conclusione tecnica | Da eseguire |

Controlli principali conclusi: 2/10.
Avanzamento per numero di controlli: 20%.

Non costituisce percentuale di maturita della Write Authority.

## 4. Dettaglio delle verifiche eseguite

Controllo 01:

- 01.1: inventario dei file.
- 01.2: dichiarazioni SQL.
- 01.3: funzioni installate e privilegi.

Controllo 02:

- 02.1: struttura tabella edit lock.
- 02.2: RLS e privilegi tabella.
- 02.3: privilegi sulle colonne.

Controllo 03:

- 03.1: definizioni dei tre helper, concluso.
- 03.2: dipendenza owner, da eseguire.

Non ripetere i controlli conclusi se le condizioni
tecniche rimangono invariate.

## 5. Evidenze consolidate

| Scheda | Contenuto |
|---|---|
| INF-WA-001 | Inventario Flutter, migrazioni e test |
| DB-WA-001 | Inventario RPC e helper |
| DB-WA-002 | Struttura edit lock e privilegi |
| DB-WA-003 | Contratti degli helper privati |
| RC02-OBS-001 | Osservazioni tecniche |

Risultati principali:

- 40 file individuati nella ricerca iniziale.
- 13 dichiarazioni SQL.
- 12 funzioni distinte installate.
- 9 RPC pubbliche.
- 3 helper privati esaminati.
- 18 colonne della tabella edit lock.
- 10 vincoli CHECK.
- 41 osservazioni consolidate.

La dipendenza owner aggiuntiva non e' compresa
nel conteggio iniziale delle dodici funzioni.

## 6. Dipendenze

- INF-AUTH-001.
- INF-ID-001.
- FLT-PROF-001.
- DB-PROF-001.
- DB-SEC-001.
- DB-VER-001.
- RC01, RC03, RC04, RC05, RC07, RC17.

Non conformita collegata:
NC-RC01-001, P1, aperta.

## 7. Baseline quantitativa

Macroblocco V1-02:

- Maturita tecnica A: 85,65%.
- Maturita tecnica V1: 72,35%.
- Residuo A: 11:00.
- Residuo B: 24:55.
- Residuo complessivo: 35:55.

La baseline e' condivisa fra RC02, RC03, RC04 e RC05.
Non moltiplicare le ore per il numero di riconciliazioni.

Riconciliazione PERT originaria: aperta.
Riduzioni approvate: 0 minuti.
Incrementi approvati: 0 minuti.

## 8. Punto esatto di ripresa

Controllo RC02 03.2.

Verifica della funzione privata is_profile_auth_user_owner.

La funzione costituisce una dipendenza
di private.lock_profile_write_authority.

Verificare:

- Firma.
- Definizione effettiva.
- Condizioni di proprieta.
- Gestione della membership.
- Modalita di sicurezza.
- Privilegi di esecuzione.

Comando PowerShell di sola lettura:

    docker exec supabase_db_orto_app psql -U postgres -d postgres -P pager=off -x -c "SELECT p.oid::regprocedure AS function_name, pg_get_functiondef(p.oid) AS function_definition, has_function_privilege('authenticated', p.oid, 'EXECUTE') AS authenticated_execute, has_function_privilege('anon', p.oid, 'EXECUTE') AS anon_execute FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'private' AND p.proname = 'is_profile_auth_user_owner';"

Il comando non e' ancora stato eseguito.

## 9. Procedura successiva

Prima della ripresa:

- Concludere STEP 275.R.07.
- Verificare la persistenza del Registro.
- Controllare i file creati.
- Verificare lo stato Git.
- Ottenere le autorizzazioni pertinenti.

Dopo la ripresa:

- Eseguire il controllo 03.2.
- Esaminare il risultato.
- Aggiornare le evidenze.
- Proseguire con acquisizione e rilascio.
- Completare i controlli successivi.

Procedere un comando alla volta.

## 10. Limiti e stato conclusivo

La ricognizione RC02 non e' conclusa.
Il consolidamento documentale non aumenta
l'avanzamento tecnico.

Le evidenze locali non attestano
l'equivalenza dell'ambiente remoto.

Nessuna correzione autorizzata.
Nessuna variazione quantitativa introdotta.

Nessuna modifica tecnica introdotta.
