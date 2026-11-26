# DB-WA-006 - Protocollo takeover

## 1. Identificazione
- Versione: 1.0.
- Sessione: S046.
- Data verifica: 26/11/2026.
- Baseline Git: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Ambiente: PostgreSQL locale, supabase_db_orto_app.
- Evidenza: E3, analisi strutturale delle funzioni installate.
- Riconciliazione: RC02, controllo 05.
- Classificazione: RIUTILIZZARE, con verifiche residue.

## 2. Fonti e dipendenze
- Migrazione 20260819215412_add_secure_profile_edit_lock_rpcs.sql.
- Migrazione 20260915081444_add_plantings_write_rpcs.sql.
- Tabella public.profile_edit_locks.
- Helper private.is_profile_owner.
- Helper private.profile_edit_lock_token_hash.
- Helper private.lock_profile_write_authority.
- Definizioni effettive acquisite mediante pg_get_functiondef.

## 3. Regole comuni
- Cinque RPC pubbliche dedicate al takeover.
- Restituzione jsonb.
- SECURITY DEFINER e search_path vuoto.
- Esecuzione consentita ad authenticated, non ad anon.
- Autenticazione e owner attivo obbligatori.
- Serializzazione mediante SELECT FOR UPDATE.
- Riferimento clock_timestamp() acquisito dopo eventuale attesa.
- Identita composta da utente autenticato, client e sessione.
- Nessuna scrittura diretta del client sulla tabella Edit Lock.

## 4. Request
- Firma: public.request_profile_edit_takeover(uuid,uuid,uuid).
- Rifiuta parametri UUID nulli o zero.
- Record assente o lease scaduto: available.
- Richiesta effettuata dal titolare corrente: forbidden.
- Grant valido: transfer_pending.
- Silenziamento valido: silenced.
- Richiesta ancora valida: request_pending.
- Validita richiesta: 600 secondi.
- Registra identita completa del richiedente e timestamp server.
- Azzera eventuali campi concessione precedenti.
- Conserva holder, token, heartbeat, scadenza e silenziamento.
- Incrementa row_version.
- Successo: requested.
- Sei status distinti, senza restituzione del token.

## 5. Cancel
- Firma: public.cancel_profile_edit_takeover(uuid,uuid,uuid).
- Parametri: target_profile_id, target_client_id, target_session_id.
- Autenticazione e owner attivo obbligatori.
- Parametri UUID nulli o zero: forbidden.
- SELECT FOR UPDATE sulla riga del profilo.
- clock_timestamp() acquisito dopo eventuale attesa.
- Record assente: no_pending_request.
- Grant valido di 60 secondi: transfer_pending.
- Richiesta assente o scaduta: no_pending_request.
- Validita della richiesta: 600 secondi.
- Verifica identita completa del richiedente.
- Identita non coincidente: no_pending_request.
- UPDATE con azzeramento dei quattro campi richiesta.
- Incremento row_version di una unita.
- Verifica effettivo aggiornamento mediante RETURNING.
- Conserva holder, token, heartbeat, scadenza, concessione e silenziamento.
- Successo: cancelled.
- Quattro status: forbidden, no_pending_request, transfer_pending, cancelled.
- Risposta contenente esclusivamente status.
- Non verifica direttamente la scadenza del lease.
- Una richiesta ancora valida puo essere annullata anche con lease scaduto.

### 5.1. Verifiche residue
- CAN-V01: annullamento con lease scaduto.
- CAN-V02: concorrenza con grant.
- CAN-V03: concorrenza con reject.
- CAN-V04: perdita risposta cancelled.
- CAN-V05: variazione membership durante attesa.
- CAN-V06: riconciliazione Flutter.
- CAN-V07: ripetizione annullamento.

## 6. Reject
- Firma: public.reject_profile_edit_takeover(uuid,uuid,uuid,text,integer).
- Parametri aggiuntivi: lock_token e silence_minutes.
- Autenticazione e owner attivo obbligatori.
- Durate ammesse: 5, 15 o 30 minuti.
- Durata nulla o non ammessa: invalid_silence.
- Parametri identificativi o token mancanti: not_holder.
- SELECT FOR UPDATE sulla riga del profilo.
- clock_timestamp() acquisito dopo eventuale attesa.
- Verifica esistenza record, identita holder e hash token.
- Lease scaduto: not_holder.
- Grant valido di 60 secondi: transfer_pending.
- Richiesta assente o scaduta: no_pending_request.
- Validita della richiesta: 600 secondi.
- UPDATE con azzeramento dei quattro campi richiesta.
- Imposta takeover_silenced_until al tempo server piu la durata selezionata.
- Incremento row_version di una unita.
- Verifica effettivo aggiornamento mediante RETURNING.
- Conserva holder, token, heartbeat, scadenza e concessione.
- Successo: rejected.
- Sei status: forbidden, invalid_silence, not_holder, transfer_pending, no_pending_request, rejected.
- Risposta contenente esclusivamente status.

### 6.1. Semantica del silenziamento
- Il silenziamento riguarda il record del profilo, non soltanto il richiedente rifiutato.
- Heartbeat conserva il silenziamento.
- Release elimina il record e il relativo silenziamento.
- Acquire con riciclo del record azzera il silenziamento.
- Il silenziamento non estende automaticamente il lease.

### 6.2. Verifiche residue
- REJ-V01: conservazione silenziamento durante heartbeat.
- REJ-V02: azzeramento durante riciclo.
- REJ-V03: applicazione a tutte le sessioni richiedenti.
- REJ-V04: concorrenza con cancel.
- REJ-V05: concorrenza con grant.
- REJ-V06: perdita risposta rejected.
- REJ-V07: variazione membership durante attesa.
- REJ-V08: durate disponibili in Flutter.
- REJ-V09: gestione invalid_silence.
- REJ-V10: validazione UUID zero.

## 7. Grant
- Firma: public.grant_profile_edit_takeover(uuid,uuid,uuid,text).
- Operazione riservata al titolare autorizzato con lease valido.
- Verifica identita e hash token.
- Richiede una richiesta completa e temporalmente valida.
- Grant gia valido: transfer_pending.
- Richiesta assente, incompleta o scaduta: no_pending_request.
- Destinatario ricavato esclusivamente dalla richiesta registrata.
- Validita concessione: 60 secondi.
- Registra identita destinatario e timestamp concessione.
- Estende expires_at mediante greatest(scadenza corrente, tempo server piu 60 secondi).
- Conserva eventuale scadenza superiore.
- Azzera i campi richiesta.
- Conserva holder, token, heartbeat e silenziamento.
- Incrementa row_version.
- Verifica effettivo aggiornamento.
- Successo: granted.
- Altri status: forbidden, not_holder, transfer_pending, no_pending_request.
- Risposta contenente esclusivamente status.
- Non genera un nuovo token.

## 8. Complete
- Firma: public.complete_profile_edit_takeover(uuid,uuid,uuid).
- Operazione riservata al destinatario della concessione.
- Verifica autenticazione e owner attivo.
- Verifica completezza e validita temporale della concessione.
- Verifica utente, client e sessione destinataria.
- Genera nuovo token mediante gen_random_bytes(32).
- Token esadecimale di 64 caratteri, 256 bit casuali.
- Memorizza esclusivamente hash SHA-256.
- Sostituisce identita holder e hash token mediante singolo UPDATE.
- Reimposta acquired_at e heartbeat_at.
- Nuovo lease: 120 secondi.
- Azzera richiesta, concessione e silenziamento.
- Incrementa row_version.
- Verifica effettivo aggiornamento.
- Successo: completed, con lock_token, expires_at e row_version.
- Altri status: forbidden, not_grantee, no_grant, grant_expired.
- Non verifica direttamente expires_at del precedente lease.
- La protezione temporale ordinaria deriva dalla RPC grant.

## 9. Protezione durante handoff
- Grant non trasferisce immediatamente la titolarita.
- Il precedente holder conserva il token fino al completamento.
- private.lock_profile_write_authority nega le mutazioni protette durante grant valido.
- Il destinatario non dispone ancora del nuovo token.
- Heartbeat del precedente holder puo rinnovare il lease.
- Release, nuove richieste, cancel, reject e nuovo grant sono impediti durante handoff valido, ferme le verifiche preliminari.
- Complete trasferisce identita e token atomicamente.
- Il token precedente non soddisfa piu i controlli autoritativi dopo il trasferimento.

## 10. Evoluzione della RPC request
- Definizione originaria: migrazione 20260819215412, riga 503.
- Ridefinizione: migrazione 20260915081444, riga 1906.
- Entrambe le definizioni estratte integralmente.
- Variabili locali: da 12 a 9, mediante eliminazione di tre variabili inutilizzate.
- Campi SELECT e INTO ridotti da dieci a sette.
- Firma, condizioni decisionali, aggiornamento e status invariati.
- Nessuna duplicazione funzionale della RPC.
- Primo confronto testuale: 3553 caratteri sorgente, 3558 database acquisito.
- Differenza circoscritta a cinque caratteri accentati in tre commenti.
- Anomalia riconducibile alla decodifica Docker/PowerShell.
- Verifica definitiva mediante SHA-256 del corpo normalizzato.
- Normalizzazione: terminazioni di riga e spazi bianchi alle estremita.
- SHA-256 sorgente e database: 40f367bd5d3839643855ce387015048e0687c26283ca348cb64107929ee056f4.
- HashIdentici: True.
- Nessuna correzione SQL necessaria per questa differenza.

## 11. Verifiche residue principali
- Rivalidazione membership durante attesa sul row lock.
- Richieste simultanee e ripetizione della stessa richiesta.
- Concorrenza tra cancel, reject, grant e complete.
- Perdita risposta delle RPC.
- Perdita del nuovo token dopo completamento riuscito.
- Gestione concessione scaduta senza completamento.
- Recupero autorita del precedente holder dopo handoff scaduto.
- Invalidazione effettiva del precedente token.
- Protezione temporale del lease durante concessione.
- Gestione del silenziamento.
- Validazione uniforme dei parametri.
- Riconciliazione dei contratti con Flutter.
- Famiglie trasversali WA-V01-WA-V15 definite in DB-WA-007.

## 12. Limiti delle evidenze
- Cinque RPC takeover analizzate strutturalmente.
- Request: 19/19 controlli strutturali.
- Cancel: 18/18 controlli strutturali.
- Reject: 22/22 controlli strutturali.
- Grant: 24/24 controlli strutturali.
- Complete: 27/27 controlli strutturali.
- Confronto strutturale delle due implementazioni request completato, senza attribuzione di un conteggio comparativo autonomo.
- Nessuno di questi conteggi equivale a collaudi funzionali eseguiti.
- Ambiente remoto non verificato per queste definizioni.
- Nessuna modifica applicativa, SQL o alle migrazioni.
- Nessuna variazione quantitativa PERT approvata.

## 13. Riferimenti
- [Inventario RPC](DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Struttura Edit Lock](DB-WA-002_Struttura_Edit_Lock.md)
- [Helper autorita di scrittura](DB-WA-003_Helper_Autorita_Scrittura.md)
- [Acquisizione e rilascio](DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [Heartbeat e stato](DB-WA-005_Heartbeat_Stato_Lock.md)
- [Lifecycle e contratti](DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- Evidenze associate: OBS-RC02-116 fino a OBS-RC02-253.
