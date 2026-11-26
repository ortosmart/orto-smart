# DB-WA-007 - Lifecycle e contratti RPC Write Authority

## 1. Identificazione
- Versione: 1.0.
- Sessione: S046.
- Data verifica: 26/11/2026.
- Baseline Git: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Ambiente: PostgreSQL locale, supabase_db_orto_app.
- Evidenza: E3, riconciliazione strutturale SQL.
- Riconciliazione: RC02, controlli 01-05.
- Classificazione: RIUTILIZZARE, INTEGRARE e VERIFICARE secondo componente.

## 2. Principi autoritativi
- Un solo record Edit Lock per profilo.
- Un solo holder registrato per record.
- Identita holder composta da utente, client e sessione.
- Token generato dal server.
- Memorizzazione del solo hash SHA-256.
- Autorita subordinata a membership, identita, token e validita temporale.
- Autorita definitiva verificata dal server.
- Stato informativo distinto dal possesso effettivo del token.
- Nessuna scrittura diretta autorizzata sulla tabella Edit Lock.
- Le protezioni dei singoli domini devono essere verificate separatamente.

## 3. Inventario RPC
| RPC pubblica | Parametri | Analisi strutturale |
|---|---|---|
| acquire_profile_edit_lock | 3 UUID | PASS |
| release_profile_edit_lock | 3 UUID, text | PASS |
| heartbeat_profile_edit_lock | 3 UUID, text | PASS |
| get_profile_edit_lock_state | 3 UUID | PASS |
| request_profile_edit_takeover | 3 UUID | PASS |
| cancel_profile_edit_takeover | 3 UUID | PASS |
| reject_profile_edit_takeover | 3 UUID, text, integer | PASS |
| grant_profile_edit_takeover | 3 UUID, text | PASS |
| complete_profile_edit_takeover | 3 UUID | PASS |

Tutte restituiscono jsonb. Le nove implementazioni installate localmente sono state analizzate.

## 4. Parametri temporali
| Parametro | Durata |
|---|---:|
| Lease ordinario | 120 secondi |
| Validita richiesta takeover | 600 secondi |
| Validita concessione | 60 secondi |
| Silenziamento minimo | 5 minuti |
| Silenziamento intermedio | 15 minuti |
| Silenziamento massimo | 30 minuti |

Le durate sono ricavate dalle implementazioni SQL, non da simulazioni o ipotesi.

## 5. Lifecycle ordinario
1. Acquire crea o ricicla il record e restituisce il token.
2. Heartbeat rinnova il lease del titolare valido.
3. Get state consulta lo stato senza mutarlo.
4. Release elimina il record se il titolare e autorizzato e non esiste handoff valido.
5. Un lease scaduto puo essere riciclato mediante nuova acquisizione.
6. Un holder non piu owner attivo puo essere sostituito mediante acquisizione.

## 6. Lifecycle takeover
1. Una seconda sessione owner richiede il takeover.
2. Il titolare corrente conserva ordinariamente la propria autorita.
3. Il richiedente puo annullare la richiesta.
4. Il titolare puo rifiutare con silenziamento oppure concedere.
5. Grant registra il destinatario e protegge la finestra di 60 secondi.
6. Durante handoff valido le mutazioni protette sono impedite.
7. Complete verifica il destinatario e sostituisce identita e token.
8. Il nuovo holder riceve un lease di 120 secondi.
9. Il precedente token non soddisfa piu i controlli autoritativi.
10. Scadenza senza completamento e recupero client richiedono collaudo.

## 7. Matrice operazioni
| Operazione | Richiesta pendente | Handoff valido |
|---|---|---|
| Acquire | busy o already_held | busy o already_held |
| Heartbeat | Consentito al titolare valido | Consentito al titolare valido |
| Release | Consentito al titolare valido | Impedito |
| Request | request_pending | Impedito |
| Cancel | Consentito al richiedente | Impedito |
| Reject | Consentito al titolare valido | Impedito |
| Grant | Consentito al titolare valido | Impedito |
| Complete | no_grant in assenza di concessione | Consentito al destinatario valido |
| Mutazioni protette | Consentite al titolare valido | Impedite |

La matrice presuppone autorizzazioni valide, parametri corretti e lease non scaduto.
Le verifiche preliminari possono produrre altri status.
Una concessione residua scaduta puo produrre grant_expired.
Acquire puo riciclare il record se il precedente holder non e piu autorizzato.

## 8. Autorita e helper
- private.profile_edit_lock_token_hash: calcolo hash SHA-256.
- private.is_profile_edit_lock_holder: verifica holder senza serializzazione autoritativa.
- private.lock_profile_write_authority: row lock, tempo effettivo, membership, token, lease e protezione handoff.
- private.is_profile_auth_user_owner: verifica esplicita owner attivo.
- Gli helper non sono intercambiabili.
- Il controllo autoritativo deve operare nella stessa transazione della mutazione.
- Il chiamante deve rispettare il risultato del controllo.
- Le RPC dei domini devono essere riconciliate nel controllo RC02.07.

## 9. Contratti e recupero client
- already_held non restituisce il token precedente.
- held_by_me non dimostra il possesso del token.
- available non costituisce acquisizione.
- acquired e completed restituiscono il nuovo token.
- renewed restituisce nuova scadenza e versione, senza nuovo token.
- Perdita risposta acquire o complete: possibile holder registrato senza token disponibile al client.
- Perdita risposta heartbeat: possibile divergenza tra scadenza locale e server.
- Perdita risposta release: ripetizione potenzialmente not_holder.
- Recupero e comportamento fail-closed da verificare in Flutter.
- row_version non costituisce contatore permanente oltre eliminazione e ricreazione del record.

## 10. Famiglie trasversali di verifica
| ID | Famiglia | Priorita proposta |
|---|---|---|
| WA-V01 | Concorrenza acquisizioni e mutazioni | Alta |
| WA-V02 | Rivalidazione membership durante attesa | Alta |
| WA-V03 | Scadenze e riferimenti temporali | Alta |
| WA-V04 | Perdita risposta acquire/complete e recupero token | Alta |
| WA-V05 | Concorrenza request/cancel/reject/grant | Alta |
| WA-V06 | Protezione autorita durante handoff | Alta |
| WA-V07 | Handoff scaduto senza completamento | Alta |
| WA-V08 | Invalidazione precedente token | Alta |
| WA-V09 | Lifecycle silenziamento | Media |
| WA-V10 | Versionamento e riciclo record | Media |
| WA-V11 | Validazione uniforme parametri | Media |
| WA-V12 | Necessita e minimizzazione SELECT diretta | Da valutare |
| WA-V13 | Contratti RPC e riconciliazione Flutter | Alta |
| WA-V14 | Utilizzo corretto helper nei domini | Alta |
| WA-V15 | Collaudo integrato e ambiente remoto | Alta |

Le famiglie accorpano verifiche gia individuate.
Non rappresentano quindici nuove attivita da sommare alle stime.
Le priorita sono proposte tecniche, non autorizzazioni a modificare il progetto.

## 11. Classificazione riutilizzo
- RIUTILIZZARE: infrastruttura SQL esistente e contratti verificati strutturalmente.
- INTEGRARE: utilizzo nei domini che richiedono autorita di scrittura.
- VERIFICARE: concorrenza, recupero token, scadenze, Flutter e collaudi integrati.
- Nessuna riscrittura generale del protocollo giustificata dalle evidenze attuali.
- NC-RC01-001 rimane aperta e richiede analisi dedicata.
- La protezione della tabella Edit Lock non dimostra la protezione di tutti i domini.

## 12. Stato riconciliazione
- Controlli RC02.01-05 conclusi strutturalmente.
- Controlli RC02.06-10 ancora aperti.
- Avanzamento procedurale RC02: 5/10, pari al 50 percento.
- Tale percentuale non rappresenta maturita funzionale V1.
- Nessuna variazione quantitativa PERT approvata.
- Nessuna verifica remota delle definizioni SQL.
- Nessuna modifica applicativa o al database durante la ricognizione.

## 13. Riferimenti
- [Inventario RPC](DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Struttura Edit Lock](DB-WA-002_Struttura_Edit_Lock.md)
- [Helper autorita di scrittura](DB-WA-003_Helper_Autorita_Scrittura.md)
- [Acquisizione e rilascio](DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [Heartbeat e stato](DB-WA-005_Heartbeat_Stato_Lock.md)
- [Protocollo takeover](DB-WA-006_Protocollo_Takeover.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [Stato parziale RC02](../08_riutilizzo/RC02_Stato_Parziale.md)
