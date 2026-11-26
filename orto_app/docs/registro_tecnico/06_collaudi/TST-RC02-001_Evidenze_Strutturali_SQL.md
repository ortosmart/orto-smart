# TST-RC02-001 - Evidenze strutturali SQL Write Authority

## 1. Identificazione
- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Baseline Git: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Ambiente: PostgreSQL locale, supabase_db_orto_app.
- Riconciliazione: RC02, controlli 01-05.
- Livello evidenza: E3.
- Ambiente remoto: NV.

## 2. Metodo di verifica
- Inventario dei sorgenti versionati mediante Git.
- Interrogazione dei cataloghi PostgreSQL.
- Verifica firme, tipi restituiti e privilegi di esecuzione.
- Verifica struttura, vincoli e privilegi della tabella Edit Lock.
- Acquisizione delle definizioni effettivamente installate.
- Analisi delle condizioni decisionali e delle mutazioni.
- Confronto delle definizioni storiche della RPC request.
- Confronto SHA-256 del corpo normalizzato della RPC request.
- Tutte le interrogazioni SQL della ricognizione sono state di lettura.

## 3. Inventario e autorizzazioni
| Elemento | Risultato |
|---|---|
| RPC pubbliche individuate | 9 |
| RPC pubbliche installate | 9/9 |
| Helper privati inventariati inizialmente | 3/3 |
| Helper owner esplicito verificato successivamente | 1 |
| RPC pubbliche SECURITY DEFINER | 9/9 |
| RPC pubbliche eseguibili da authenticated | 9/9 |
| RPC pubbliche eseguibili da anon | 0/9 |
| Helper privati direttamente eseguibili da authenticated | 0/4 |
| Helper privati direttamente eseguibili da anon | 0/4 |

Il riscontro numerico delle funzioni installate non equivale alla verifica di identita testuale di tutte le definizioni.

## 4. Struttura Edit Lock
| Elemento | Risultato |
|---|---|
| Colonne | 18 |
| Colonne obbligatorie | 9 |
| Colonne opzionali | 9 |
| Primary key | profile_id |
| Vincoli CHECK | 10 |
| Foreign key | 4 |
| RLS abilitata | True |
| RLS forzata | False |
| SELECT authenticated | 18/18 colonne |
| INSERT diretto authenticated | Non consentito |
| UPDATE diretto authenticated | Non consentito |
| DELETE diretto authenticated | Non consentito |
| TRUNCATE authenticated | Non consentito |
| Accesso anon | Non consentito |

La leggibilita diretta dell hash token da parte dei membri autorizzati richiede valutazione di necessita e minimizzazione.
Non costituisce da sola dimostrazione di vulnerabilita sfruttabile.

## 5. Helper verificati
- private.profile_edit_lock_token_hash.
- private.is_profile_edit_lock_holder.
- private.lock_profile_write_authority.
- private.is_profile_auth_user_owner.

Il controllo autoritativo lock_profile_write_authority serializza sulla riga, acquisisce il tempo dopo attesa, verifica membership, identita, token, lease e handoff.
Il corretto utilizzo nelle RPC dei domini resta oggetto di RC02.07.

## 6. Verifiche strutturali delle RPC
| RPC | Controlli strutturali | Esito |
|---|---:|---|
| acquire_profile_edit_lock | 17/17 | PASS |
| release_profile_edit_lock | 16/16 | PASS |
| heartbeat_profile_edit_lock | 17/17 | PASS |
| get_profile_edit_lock_state | 20/20 | PASS |
| request_profile_edit_takeover | 19/19 | PASS |
| cancel_profile_edit_takeover | 18/18 | PASS |
| reject_profile_edit_takeover | 22/22 | PASS |
| grant_profile_edit_takeover | 24/24 | PASS |
| complete_profile_edit_takeover | 27/27 | PASS |
| Totale | 180/180 | PASS strutturale |

I conteggi rappresentano punti di analisi strutturale, non test automatici indipendenti eseguiti.
Non devono essere sommati al numero dei test Flutter o SQL gia eseguiti.

## 7. Confronto storico RPC request
- Definizione originaria: 20260819215412_add_secure_profile_edit_lock_rpcs.sql.
- Ridefinizione: 20260915081444_add_plantings_write_rpcs.sql.
- Una definizione estratta da ciascuna migrazione.
- Variabili locali: da 12 a 9, mediante eliminazione di tre variabili inutilizzate.
- Campi SELECT e INTO ridotti da dieci a sette.
- Firma, condizioni decisionali, mutazioni e status invariati.
- Confronto strutturale completato; conteggio comparativo autonomo non attribuito.

## 8. Diagnosi differenza testuale
- Primo confronto: CorpoIdentico = False.
- Lunghezza sorgente normalizzato: 3553 caratteri.
- Lunghezza database acquisito: 3558 caratteri.
- Differenze circoscritte a tre righe di commento.
- Cinque caratteri accentati decodificati erroneamente.
- Nessuna differenza rilevata nelle istruzioni SQL.
- La verifica mediante hash ha risolto il dubbio sulla corrispondenza del corpo.

## 9. Verifica SHA-256
- Funzione: public.request_profile_edit_takeover.
- Sorgente: corpo della definizione nella migrazione 20260915081444.
- Database: pg_proc.prosrc.
- Normalizzazione: terminazioni di riga e spazi bianchi alle estremita.
- Codifica utilizzata per il calcolo: UTF-8.
- SHA256Sorgente: 40f367bd5d3839643855ce387015048e0687c26283ca348cb64107929ee056f4.
- SHA256Database: 40f367bd5d3839643855ce387015048e0687c26283ca348cb64107929ee056f4.
- HashIdentici: True.
- Esito: PASS.

La corrispondenza riguarda il corpo normalizzato della singola funzione request, non tutte le RPC e non il database remoto.

## 10. Evidenze funzionali e baseline
- Baseline Flutter S046: flutter analyze superato.
- Baseline Flutter S046: 1956/1956 test superati.
- Le evidenze Flutter specifiche Write Authority saranno riconciliate nei controlli 06 e 09.
- I collaudi SQL funzionali specifici Write Authority non sono stati rieseguiti durante i controlli 01-05.
- Concorrenza, perdita risposta, recupero token e scadenze richiedono riconciliazione delle evidenze funzionali.
- Nessun incremento del numero dei test automatici attribuito a questa ricognizione.

## 11. Verifiche residue
- Famiglie WA-V01-WA-V15 definite nella scheda DB-WA-007.
- Verificare copertura dei test esistenti prima di pianificare nuovi test.
- Distinguere test unitari, widget, SQL e integrati.
- Non duplicare collaudi gia validi senza motivazione.
- Non attribuire PASS funzionale sulla sola base di analisi strutturale.
- NC-RC01-001 rimane aperta.
- Nessuna variazione quantitativa PERT approvata.

## 12. Esito della ricognizione
- RC02.01-05 conclusi strutturalmente.
- RPC pubbliche analizzate: 9/9.
- Controlli strutturali delle RPC: 180/180.
- Confronto storico request: completato strutturalmente.
- Identita corpo normalizzato request: PASS.
- RC02.06-10 ancora aperti.
- Nessuna modifica applicativa, al database o alle migrazioni.
- Nessuna nuova non conformita funzionale dimostrata.

## 13. Riferimenti
- [Baseline collaudi S046](TST-S046-001_Baseline_Collaudi.md)
- [Inventario RPC](../03_database/DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Struttura Edit Lock](../03_database/DB-WA-002_Struttura_Edit_Lock.md)
- [Helper autorita](../03_database/DB-WA-003_Helper_Autorita_Scrittura.md)
- [Acquisizione e rilascio](../03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [Heartbeat e stato](../03_database/DB-WA-005_Heartbeat_Stato_Lock.md)
- [Protocollo takeover](../03_database/DB-WA-006_Protocollo_Takeover.md)
- [Lifecycle e contratti](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [Stato parziale RC02](../08_riutilizzo/RC02_Stato_Parziale.md)
