# DB-WA-005 - Heartbeat e consultazione stato del lock

## 1. Identificazione
- Versione: 1.0.
- Sessione: S046.
- Data verifica: 26/11/2026.
- Baseline Git: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Ambiente: PostgreSQL locale, supabase_db_orto_app.
- Evidenza: E3, analisi strutturale delle funzioni installate.
- Riconciliazione: RC02, controlli 04.1-04.2.
- Classificazione: RIUTILIZZARE, con verifiche residue.

## 2. Fonti e dipendenze
- Migrazione 20260819215412_add_secure_profile_edit_lock_rpcs.sql.
- Tabella public.profile_edit_locks.
- Helper private.is_profile_owner.
- Helper private.is_profile_member.
- Helper private.is_profile_auth_user_owner.
- Helper private.profile_edit_lock_token_hash.
- Definizioni effettive acquisite mediante pg_get_functiondef.

## 3. Contratto heartbeat_profile_edit_lock
- Firma: public.heartbeat_profile_edit_lock(uuid,uuid,uuid,text).
- Parametri: profilo, client, sessione, lock_token.
- Restituzione: jsonb.
- SECURITY DEFINER, search_path vuoto.
- Esecuzione consentita ad authenticated, non ad anon.
- Autenticazione e owner attivo obbligatori.
- Parametri mancanti: not_holder dopo verifica autorizzazione.

## 4. Rinnovo autoritativo
- SELECT FOR UPDATE sulla riga del profilo.
- clock_timestamp() acquisito dopo eventuale attesa.
- Verifica identita utente, client, sessione e hash token.
- Lease scaduto non rinnovabile.
- UPDATE di heartbeat_at, expires_at e row_version.
- Nuova scadenza: tempo server piu 120 secondi.
- Incremento row_version di una unita.
- Token, acquired_at e identita holder invariati.
- Richiesta, concessione e silenziamento invariati.
- Il rinnovo non verifica direttamente la presenza di grant valido.
- Il rinnovo del lease non equivale al permesso di mutare durante handoff.

## 5. Risultati heartbeat
| Status | Significato |
|---|---|
| renewed | Rinnovo riuscito; restituisce expires_at e row_version |
| forbidden | Autorizzazione insufficiente |
| not_holder | Record, identita, token o lease non validi |

## 6. Contratto get_profile_edit_lock_state
- Firma: public.get_profile_edit_lock_state(uuid,uuid,uuid).
- Parametri: profilo, client, sessione.
- Restituzione: jsonb.
- SECURITY DEFINER, search_path vuoto.
- Accesso riservato ai membri attivi del profilo.
- Owner, worker e viewer possono consultare lo stato se autorizzati.
- Non richiede lock_token.
- SELECT singola, senza FOR UPDATE.
- Nessuna mutazione del record.
- Riferimento temporale now().

## 7. Ordine decisionale dello stato
| Priorita | Condizione | Status |
|---|---|---|
| 1 | Parametri nulli | invalid_request |
| 2 | Utente non autenticato o non membro attivo | forbidden |
| 3 | Record assente | available |
| 4 | Lease scaduto o holder non piu owner attivo | available |
| 5 | Grant valido destinato al chiamante | transfer_granted_to_me |
| 6 | Grant valido destinato ad altra sessione | transfer_pending |
| 7 | Identita holder coincidente | held_by_me |
| 8 | Richiesta valida appartenente al chiamante | takeover_requested_by_me |
| 9 | Silenziamento valido | silenced |
| 10 | Richiesta valida di altra sessione | takeover_pending |
| 11 | Lock occupato senza altre condizioni | busy |

## 8. Contratto informativo
- Dieci status distinti.
- row_version presente nelle risposte.
- Versione nulla per invalid_request, forbidden e record assente.
- Versione corrente negli altri casi.
- expires_in_seconds per stati temporali di lease, richiesta e concessione.
- retry_after_seconds per silenziamento.
- Contatori calcolati mediante arrotondamento superiore e minimo zero.
- Nessun token, hash token o identificativo di altre sessioni restituito.
- La SELECT diretta della tabella presenta una superficie informativa piu ampia.

## 9. Durate e priorita
- Lease ordinario: 120 secondi.
- Richiesta takeover: 600 secondi.
- Concessione takeover: 60 secondi.
- Scadenza lease e autorizzazione holder precedono la valutazione grant.
- Grant estende il lease almeno fino alla fine della finestra handoff.
- held_by_me precede la valutazione della richiesta pendente.
- Il meccanismo Flutter di rilevamento richiesta entrante resta da verificare.

## 10. Distinzione stato e autorita
- held_by_me non dimostra il possesso del token.
- available non costituisce acquisizione del lock.
- get_state non sostituisce la validazione autoritativa delle mutazioni.
- Le mutazioni protette devono utilizzare il controllo server appropriato.
- Durante handoff valido il lease puo essere rinnovato senza autorizzare mutazioni protette.

## 11. Verifiche residue
- HBT-V01: rinnovo durante handoff.
- HBT-V02: variazione membership concorrente.
- HBT-V03: perdita risposta renewed.
- HBT-V04: heartbeat concorrenti.
- HBT-V05: concorrenza con release.
- HBT-V06: concorrenza con takeover.
- HBT-V07: frequenza scheduler Flutter.
- HBT-V08: scadenza locale e comportamento fail-closed.
- STA-V01: riferimento temporale now().
- STA-V02: distinzione stato e autorita.
- STA-V03: available per holder non piu autorizzato.
- STA-V04: priorita scadenza lease rispetto al grant.
- STA-V05: rilevamento richiesta entrante da parte del titolare.
- STA-V06: letture concorrenti alle transizioni.
- STA-V07: versione dopo riciclo o nuova acquisizione.
- STA-V08: necessita e minimizzazione SELECT diretta.
- STA-V09: gestione Flutter dei dieci status.
- STA-V10: validazione esplicita UUID zero.

## 12. Limiti delle evidenze
- Heartbeat: 17/17 controlli strutturali verificati.
- Get state: 20/20 controlli strutturali verificati.
- Non equivalgono a collaudi funzionali eseguiti.
- Nessuna verifica remota delle definizioni.
- Nessuna modifica applicativa o al database durante la ricognizione.
- Nessuna variazione quantitativa PERT approvata.

## 13. Riferimenti
- [Inventario RPC](DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Struttura Edit Lock](DB-WA-002_Struttura_Edit_Lock.md)
- [Helper autorita di scrittura](DB-WA-003_Helper_Autorita_Scrittura.md)
- [Acquisizione e rilascio](DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- Evidenze associate: OBS-RC02-079 fino a OBS-RC02-115.
