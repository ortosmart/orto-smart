# DB-WA-004 - Acquisizione e rilascio del lock

## 1. Identificazione
- Versione: 1.0.
- Sessione: S046.
- Data verifica: 26/11/2026.
- Baseline Git: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Ambiente: PostgreSQL locale, supabase_db_orto_app.
- Evidenza: E3, analisi strutturale delle funzioni installate.
- Riconciliazione: RC02, controlli 03.2-03.4.
- Classificazione: RIUTILIZZARE, con verifiche residue.

## 2. Fonti e dipendenze
- Migrazione 20260819215412_add_secure_profile_edit_lock_rpcs.sql.
- Migrazione 20260823111048_add_profile_write_authority.sql.
- Tabella public.profile_edit_locks.
- Helper private.is_profile_owner.
- Helper private.is_profile_auth_user_owner.
- Helper private.profile_edit_lock_token_hash.
- Definizioni effettive acquisite mediante pg_get_functiondef.

## 3. Contratto acquire_profile_edit_lock
- Firma: public.acquire_profile_edit_lock(uuid,uuid,uuid).
- Parametri: target_profile_id, target_client_id, target_session_id.
- Restituzione: jsonb.
- SECURITY DEFINER, search_path vuoto.
- Esecuzione consentita ad authenticated, non ad anon.
- Autenticazione e appartenenza owner attiva obbligatorie.
- UUID nulli o zero rifiutati.
- Token generato dal server mediante gen_random_bytes(32).
- Token esadecimale di 64 caratteri, 256 bit casuali.
- Nel record viene conservato esclusivamente hash SHA-256.

## 4. Acquisizione e riciclo
- INSERT atomico con ON CONFLICT sul profilo.
- Nuovo record: row_version = 1.
- acquired_at e heartbeat_at impostati al tempo server.
- expires_at impostato al tempo server piu 120 secondi.
- Riciclo consentito se lease scaduto oppure holder non piu owner attivo.
- Riciclo: nuova identita holder, nuovo token e nuovi riferimenti temporali.
- Riciclo: azzeramento richiesta, concessione e silenziamento.
- Riciclo: incremento row_version.
- Nessuna acquisizione concorrente ordinaria su lease valido di owner autorizzato.
- Il tempo server viene acquisito mediante now() prima della decisione concorrente.

## 5. Risultati acquire
| Status | Significato |
|---|---|
| acquired | Acquisizione riuscita; restituisce token, scadenza e versione |
| already_held | Identita chiamante gia titolare; nessun nuovo token |
| busy | Lock detenuto da altra sessione |
| forbidden | Autorizzazione insufficiente |
| invalid_input | Parametri UUID non validi |

Il risultato already_held non rinnova automaticamente il lease e non restituisce il token precedente.

## 6. Contratto release_profile_edit_lock
- Firma: public.release_profile_edit_lock(uuid,uuid,uuid,text).
- Parametri: profilo, client, sessione, lock_token.
- Restituzione: jsonb.
- SECURITY DEFINER, search_path vuoto.
- Esecuzione consentita ad authenticated, non ad anon.
- Autenticazione e owner attivo obbligatori.
- Parametri mancanti gestiti senza divulgare dettagli del lock.

## 7. Rilascio autoritativo
- SELECT FOR UPDATE sulla riga del profilo.
- clock_timestamp() acquisito dopo eventuale attesa.
- Verifica identita utente, client, sessione e hash token.
- Verifica lease non scaduto.
- Grant valido di 60 secondi impedisce il rilascio.
- DELETE del record soltanto dopo le verifiche.
- Controllo effettiva eliminazione mediante RETURNING.
- Il rilascio elimina anche lo stato takeover associato al record.

## 8. Risultati release
| Status | Significato |
|---|---|
| released | Record eliminato |
| forbidden | Autorizzazione insufficiente |
| not_holder | Identita, token, lease o record non validi |
| transfer_pending | Handoff valido, rilascio impedito |

## 9. Helper owner esplicito
- private.is_profile_auth_user_owner(uuid,uuid).
- SQL STABLE, SECURITY DEFINER, search_path vuoto.
- Verifica profile_id, auth_user_id, role owner e is_enabled true.
- Non eseguibile direttamente da authenticated o anon.
- Il chiamante interno deve fornire una identita autenticata attendibile.

## 10. Verifiche residue
- ACQ-V01: riferimento now() rispetto a clock_timestamp().
- ACQ-V02: acquisizioni concorrenti e attesa sul record.
- ACQ-V03: risposta acquired perduta e recupero token.
- ACQ-V04: interazione acquisizione e concessione takeover.
- ACQ-V05: variazione membership concorrente.
- ACQ-V06: distinzione client ID e session ID.
- REL-V01: rivalidazione membership dopo attesa.
- REL-V02: perdita risposta released e ripetizione.
- REL-V03: concorrenza con heartbeat.
- REL-V04: concorrenza con takeover.
- REL-V05: rilascio con lease scaduto.
- REL-V06: versione dopo eliminazione e nuova acquisizione.
- REL-V07: gestione Flutter di transfer_pending.

## 11. Limiti delle evidenze
- Acquisizione: 17/17 controlli strutturali verificati.
- Rilascio: 16/16 controlli strutturali verificati.
- Non equivalgono a collaudi funzionali eseguiti.
- Nessuna verifica remota delle definizioni.
- Nessuna modifica applicativa o al database durante la ricognizione.
- Nessuna variazione quantitativa PERT approvata.

## 12. Riferimenti
- [Inventario RPC](DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Struttura Edit Lock](DB-WA-002_Struttura_Edit_Lock.md)
- [Helper autorita di scrittura](DB-WA-003_Helper_Autorita_Scrittura.md)
- [Heartbeat e stato](DB-WA-005_Heartbeat_Stato_Lock.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- Evidenze associate: OBS-RC02-042 fino a OBS-RC02-078.
