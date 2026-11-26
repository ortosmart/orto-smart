# RC02-OBS-001 - Osservazioni tecniche

## 1. Identificazione

- Versione: 1.2.
- Sessione originaria: S046.
- Sessione aggiornamento: S047.
- Data: 26/11/2026.
- Origine: RC02, controlli 01-05.
- Aggiornamento: RC02, controllo 06.
- Macroblocco principale: V1-02.
- Baseline Git originaria: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline Git aggiornamento: 39665b458221b69c469ebe1d16a686312af79320.
- Stato: PARZIALE - ricognizione controlli 01-06 acquisita; controlli 07-10 aperti.
- Ambiente verificato: codice Git, PostgreSQL locale e collaudi Flutter simulati.
- Evidenza complessiva: E3.
- Evidenze specifiche collaudate: E4.
- Collaudo integrato reale: NV.
- Ambiente remoto: NV.

### 1.1. Storico delle versioni

| Versione | Sessione | Contenuto |
|---|---|---|
| 1.1 | S046 | 253 osservazioni originarie e SQL |
| 1.2 | S047 | 107 osservazioni Flutter aggiuntive |

## 2. Osservazioni inventario

| ID | Osservazione |
|---|---|
| OBS01 | Individuate nove RPC pubbliche di gestione edit lock |
| OBS02 | Individuati tre helper privati nel perimetro iniziale |
| OBS03 | RPC request takeover ridefinita in migrazione successiva |
| OBS04 | Corrispondenza numerica 12/12 delle funzioni individuate |
| OBS05 | Firme e privilegi delle funzioni verificati |
| OBS06 | Integrazione effettiva nei domini ancora da verificare |
| OBS07 | Configurazione remota non verificata |
| OBS08 | Nessuna esecuzione delle nove RPC consentita ad anon |
| OBS09 | Nessuna esecuzione diretta dei tre helper consentita ad authenticated o anon |
| OBS10 | Validazioni interne delle RPC ancora da approfondire |

Riferimenti: INF-WA-001, DB-WA-001.

## 3. Osservazioni struttura edit lock

| ID | Osservazione |
|---|---|
| OBS11 | Al massimo un record edit lock per profilo |
| OBS12 | Identita distinte di utente, client e sessione |
| OBS13 | Hash del token vincolato a 32 byte |
| OBS14 | Vincoli temporali su acquisizione, heartbeat e scadenza |
| OBS15 | Coerenza delle colonne della richiesta takeover |
| OBS16 | Coerenza delle colonne del grant takeover |
| OBS17 | Richiesta e grant mutuamente esclusivi |
| OBS18 | Vincolo temporale sul periodo di silenzio |
| OBS19 | Presenza di row_version |
| OBS20 | Incrementi effettivi della versione nelle RPC da verificare |
| OBS21 | Protezione dei metadati verificata soltanto parzialmente |
| OBS22 | Utilizzo SHA-256 confermato |
| OBS23 | Dipendenze referenziali con eliminazione RESTRICT |
| OBS24 | RLS attiva |
| OBS25 | FORCE RLS non attiva |
| OBS26 | Nessuna scrittura diretta rilevata nei privilegi esaminati |
| OBS27 | Nessun accesso alla tabella consentito ad anon |
| OBS28 | SELECT consentito ad authenticated su tutte le 18 colonne |
| OBS29 | Hash del token leggibile dai membri autorizzati |
| OBS30 | Nessun privilegio INSERT o UPDATE sulle singole colonne per i ruoli esaminati |
| OBS31 | Necessita della lettura diretta di tutte le colonne da verificare |
| OBS32 | Minimizzazione dei privilegi SELECT da valutare |

Riferimento: DB-WA-002.

La lettura dell'hash non dimostra una compromissione del token.
Esposizione effettiva mediante Data API da verificare.
Nessuna modifica dei privilegi approvata.

## 4. Osservazioni helper autoritativi

| ID | Osservazione |
|---|---|
| OBS33 | Serializzazione mediante SELECT FOR UPDATE |
| OBS34 | Acquisizione clock_timestamp dopo attesa del blocco |
| OBS35 | Rivalutazione delle condizioni di autorita |
| OBS36 | Rifiuto dei parametri nulli |
| OBS37 | Controllo della finestra grant di 60 secondi |
| OBS38 | Helper di verifica titolare e helper autoritativo non intercambiabili |
| OBS39 | Dipendenza is_profile_auth_user_owner da esaminare |
| OBS40 | Generazione ed entropia del token da verificare |
| OBS41 | Utilizzo corretto degli helper nelle RPC di dominio da verificare |

Riferimento: DB-WA-003.

### 4.1. Helper owner esplicito

| ID | Osservazione |
|---|---|
| OBS42 | Helper private.is_profile_auth_user_owner installato localmente |
| OBS43 | Verifica congiunta profilo, utente autenticato, ruolo owner e membership attiva |
| OBS44 | Nessuna esecuzione diretta consentita ad authenticated o anon |
| OBS45 | Identita fornita dal chiamante interno da mantenere attendibile |
| OBS46 | Comportamento funzionale e concorrente ancora da verificare |

Riferimenti: DB-WA-003, DB-WA-004.

### 4.2. Acquisizione del lock

| ID | Osservazione |
|---|---|
| OBS47 | RPC acquire_profile_edit_lock installata localmente |
| OBS48 | Autenticazione obbligatoria e rifiuto UUID nulli o zero |
| OBS49 | Appartenenza owner attiva obbligatoria |
| OBS50 | Token generato dal server mediante gen_random_bytes(32) |
| OBS51 | Token di 256 bit casuali, rappresentazione esadecimale di 64 caratteri e memorizzazione del solo hash SHA-256 |
| OBS52 | Lease ordinario di 120 secondi |
| OBS53 | Acquisizione e riciclo mediante INSERT ON CONFLICT atomico |
| OBS54 | Riciclo consentito anche quando il precedente holder non e piu owner attivo |
| OBS55 | Versione iniziale pari a uno e incremento durante riciclo |
| OBS56 | Azzeramento richiesta, concessione e silenziamento durante riciclo |
| OBS57 | Cinque status: acquired, already_held, busy, forbidden, invalid_input |
| OBS58 | already_held non restituisce token e non rinnova implicitamente il lease |
| OBS59 | Riferimento now() acquisito prima della decisione concorrente; comportamento temporale da verificare |
| OBS60 | Perdita risposta acquired: possibile holder registrato senza token disponibile al client |
| OBS61 | Acquisizioni concorrenti e variazioni membership da verificare funzionalmente |
| OBS62 | Distinzione client ID e session ID non imposta esplicitamente dalla RPC acquire |

Riferimento: DB-WA-004.

### 4.3. Rilascio del lock

| ID | Osservazione |
|---|---|
| OBS63 | RPC release_profile_edit_lock installata localmente |
| OBS64 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS65 | Parametri mancanti gestiti dopo verifica autorizzazione |
| OBS66 | Serializzazione mediante SELECT FOR UPDATE |
| OBS67 | clock_timestamp acquisito dopo eventuale attesa |
| OBS68 | Verifica congiunta identita utente, client e sessione |
| OBS69 | Verifica hash del token fornito |
| OBS70 | Lease scaduto non rilasciabile mediante RPC ordinaria |
| OBS71 | Grant valido di 60 secondi impedisce il rilascio |
| OBS72 | Eliminazione del record dopo le verifiche e controllo mediante RETURNING |
| OBS73 | Quattro status: released, forbidden, not_holder, transfer_pending |
| OBS74 | Rivalidazione membership dopo attesa non esplicita nella RPC release |
| OBS75 | Perdita risposta released: successiva ripetizione potenzialmente not_holder |
| OBS76 | Eliminazione e nuova acquisizione possono riportare row_version a uno |
| OBS77 | Concorrenza con heartbeat e takeover da verificare funzionalmente |
| OBS78 | Gestione Flutter dello status transfer_pending da riconciliare |

Riferimenti: DB-WA-004, DB-WA-007.

### 4.4. Heartbeat e rinnovo del lease

| ID | Osservazione |
|---|---|
| OBS79 | RPC heartbeat_profile_edit_lock installata localmente |
| OBS80 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS81 | Parametri mancanti gestiti dopo verifica autorizzazione |
| OBS82 | Serializzazione mediante SELECT FOR UPDATE |
| OBS83 | clock_timestamp acquisito dopo eventuale attesa |
| OBS84 | Verifica congiunta identita utente, client, sessione e hash token |
| OBS85 | Lease scaduto non rinnovabile mediante heartbeat |
| OBS86 | Rinnovo della scadenza per 120 secondi dal tempo server |
| OBS87 | Incremento row_version di una unita |
| OBS88 | Token, identita holder e acquired_at conservati |
| OBS89 | Richiesta takeover, concessione e silenziamento conservati |
| OBS90 | Tre status: renewed, forbidden, not_holder |
| OBS91 | Heartbeat possibile durante handoff valido senza ripristinare autorita sulle mutazioni protette |
| OBS92 | Rivalidazione membership dopo attesa non esplicita nella RPC heartbeat |
| OBS93 | Perdita risposta renewed: possibile divergenza tra scadenza locale e server |
| OBS94 | Concorrenza con altri heartbeat, release e takeover da verificare funzionalmente |
| OBS95 | Frequenza scheduler, scadenza locale e comportamento fail-closed da riconciliare in Flutter |

Riferimenti: DB-WA-005, DB-WA-007.

### 4.5. Consultazione dello stato del lock

| ID | Osservazione |
|---|---|
| OBS96 | RPC get_profile_edit_lock_state installata localmente |
| OBS97 | Consultazione consentita ai membri attivi del profilo |
| OBS98 | Acquisizione dello stato mediante singola SELECT senza FOR UPDATE |
| OBS99 | Nessuna mutazione del record durante consultazione |
| OBS100 | Dieci status distinti: invalid_request, forbidden, available, transfer_granted_to_me, transfer_pending, held_by_me, takeover_requested_by_me, silenced, takeover_pending, busy |
| OBS101 | Stato available per record assente oppure lease scaduto |
| OBS102 | Stato available anche quando il precedente holder non e piu owner attivo |
| OBS103 | Grant valido valutato prima della titolarita ordinaria e delle richieste |
| OBS104 | Validita temporale della concessione pari a 60 secondi |
| OBS105 | Validita temporale della richiesta pari a 600 secondi |
| OBS106 | Silenziamento valutato dopo richiesta propria e prima di richiesta altrui |
| OBS107 | Contatori temporali arrotondati per eccesso e limitati inferiormente a zero |
| OBS108 | row_version restituita secondo presenza record e condizioni di accesso |
| OBS109 | Nessun token, hash token o identificativo delle altre sessioni restituito dalla RPC |
| OBS110 | Stato informativo distinto dal possesso effettivo del token e dall autorita di scrittura |
| OBS111 | Scadenza lease e autorizzazione holder valutate prima della concessione |
| OBS112 | held_by_me precede richiesta pendente; rilevamento richiesta entrante da riconciliare in Flutter |
| OBS113 | Necessita della SELECT diretta della tabella e minimizzazione informativa da verificare |
| OBS114 | Riferimento now(), aggiornamento temporale e letture concorrenti da verificare funzionalmente |
| OBS115 | Gestione Flutter dei dieci status e validazione UUID zero da riconciliare |

Riferimenti: DB-WA-005, DB-WA-007, TST-RC02-001.

### 4.6. Inventario RPC takeover

| ID | Osservazione |
|---|---|
| OBS116 | Cinque RPC pubbliche dedicate al protocollo takeover installate localmente |
| OBS117 | Denominazioni effettive e firme delle cinque RPC verificate |
| OBS118 | Distinzione tra parametri del richiedente e parametri del titolare, incluso lock_token |

Riferimenti: DB-WA-001, DB-WA-006.

### 4.7. Richiesta takeover

| ID | Osservazione |
|---|---|
| OBS119 | RPC request_profile_edit_takeover installata localmente |
| OBS120 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS121 | Parametri UUID nulli o zero rifiutati |
| OBS122 | Serializzazione mediante SELECT FOR UPDATE |
| OBS123 | clock_timestamp acquisito dopo eventuale attesa |
| OBS124 | Record assente o lease scaduto producono available |
| OBS125 | Richiesta effettuata dalla stessa identita holder rifiutata |
| OBS126 | Grant valido di 60 secondi impedisce nuova richiesta |
| OBS127 | Silenziamento valido impedisce nuova richiesta |
| OBS128 | Richiesta pendente ancora valida impedisce registrazione di altra richiesta |
| OBS129 | Validita temporale della richiesta pari a 600 secondi |
| OBS130 | Registrazione della completa identita richiedente e del timestamp server |
| OBS131 | Azzeramento dei campi relativi alla precedente concessione |
| OBS132 | Incremento row_version di una unita |
| OBS133 | Conservazione holder, token, heartbeat, scadenza e silenziamento |
| OBS134 | Sei status: requested, available, forbidden, transfer_pending, silenced, request_pending |
| OBS135 | Nessuna verifica esplicita della permanenza del ruolo owner del precedente holder nella RPC request |
| OBS136 | Ripetizione della stessa richiesta produce request_pending; get_state distingue il richiedente |
| OBS137 | Rivalidazione membership dopo attesa e concorrenza da verificare funzionalmente |
| OBS138 | Presenza di due definizioni storiche della RPC request da riconciliare |

Riferimenti: DB-WA-006, DB-WA-007.
La riconciliazione storica di OBS138 e documentata nelle successive osservazioni OBS230-OBS248.

### 4.8. Annullamento richiesta takeover

| ID | Osservazione |
|---|---|
| OBS139 | RPC cancel_profile_edit_takeover installata localmente |
| OBS140 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS141 | Parametri UUID nulli o zero rifiutati |
| OBS142 | Serializzazione mediante SELECT FOR UPDATE |
| OBS143 | clock_timestamp acquisito dopo eventuale attesa |
| OBS144 | Record assente produce no_pending_request |
| OBS145 | Grant valido di 60 secondi impedisce annullamento |
| OBS146 | Richiesta assente o scaduta produce no_pending_request; validita pari a 600 secondi |
| OBS147 | Annullamento subordinato alla corrispondenza completa dell identita richiedente |
| OBS148 | Azzeramento dei quattro campi relativi alla richiesta |
| OBS149 | Incremento row_version di una unita |
| OBS150 | Verifica effettivo aggiornamento mediante RETURNING |
| OBS151 | Conservazione holder, token, heartbeat, scadenza, concessione e silenziamento |
| OBS152 | Quattro status: cancelled, forbidden, no_pending_request, transfer_pending |
| OBS153 | Possibile annullamento di richiesta ancora valida anche con lease scaduto |
| OBS154 | Concorrenza con grant e reject da verificare funzionalmente |
| OBS155 | Perdita risposta cancelled e ripetizione della richiesta di annullamento da verificare |
| OBS156 | Rivalidazione membership durante attesa e gestione Flutter da riconciliare |

Riferimenti: DB-WA-006, DB-WA-007.

### 4.9. Rifiuto richiesta takeover

| ID | Osservazione |
|---|---|
| OBS157 | RPC reject_profile_edit_takeover installata localmente |
| OBS158 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS159 | Validazione esplicita del parametro silence_minutes |
| OBS160 | Durate di silenziamento ammesse: 5, 15 o 30 minuti |
| OBS161 | Parametri identificativi o token mancanti producono not_holder dopo verifica autorizzazione e durata |
| OBS162 | Serializzazione mediante SELECT FOR UPDATE |
| OBS163 | clock_timestamp acquisito dopo eventuale attesa |
| OBS164 | Record assente produce not_holder |
| OBS165 | Verifica completa dell identita holder |
| OBS166 | Verifica hash del token fornito |
| OBS167 | Lease scaduto impedisce il rifiuto autoritativo |
| OBS168 | Grant valido di 60 secondi impedisce rifiuto tardivo |
| OBS169 | Richiesta assente o scaduta produce no_pending_request; validita pari a 600 secondi |
| OBS170 | Azzeramento dei quattro campi relativi alla richiesta |
| OBS171 | Impostazione takeover_silenced_until al tempo server piu la durata selezionata |
| OBS172 | Incremento row_version di una unita |
| OBS173 | Verifica effettivo aggiornamento mediante RETURNING |
| OBS174 | Conservazione holder, token, heartbeat, scadenza e concessione |
| OBS175 | Sei status: rejected, forbidden, invalid_silence, not_holder, transfer_pending, no_pending_request |
| OBS176 | Silenziamento associato al record: conservato da heartbeat, eliminato da release e azzerato durante riciclo |
| OBS177 | Silenziamento applicabile alle sessioni richiedenti in generale e non soltanto al richiedente rifiutato |
| OBS178 | Lifecycle silenziamento, concorrenza, perdita risposta, membership, validazione UUID zero e gestione Flutter da verificare |

Riferimenti: DB-WA-006, DB-WA-007, TST-RC02-001.

### 4.10. Concessione takeover

| ID | Osservazione |
|---|---|
| OBS179 | RPC grant_profile_edit_takeover installata localmente |
| OBS180 | Autenticazione e appartenenza owner attiva obbligatorie |
| OBS181 | Parametri identificativi o token mancanti producono not_holder dopo verifica autorizzazione |
| OBS182 | Serializzazione mediante SELECT FOR UPDATE |
| OBS183 | clock_timestamp acquisito dopo eventuale attesa |
| OBS184 | Record assente produce not_holder |
| OBS185 | Verifica completa dell identita holder |
| OBS186 | Verifica hash del token fornito |
| OBS187 | Lease scaduto impedisce la concessione |
| OBS188 | Grant ancora valido produce transfer_pending |
| OBS189 | Ripetizione grant durante handoff valido non prolunga la concessione |
| OBS190 | Concessione subordinata alla presenza di una richiesta completa e valida |
| OBS191 | Validita temporale della richiesta pari a 600 secondi |
| OBS192 | Destinatario della concessione ricavato esclusivamente dalla richiesta registrata sul server |
| OBS193 | Registrazione completa dell identita destinataria della concessione |
| OBS194 | Timestamp concessione impostato al tempo server |
| OBS195 | Lease esteso almeno fino al termine della finestra handoff di 60 secondi |
| OBS196 | Eventuale scadenza ordinaria superiore conservata mediante greatest |
| OBS197 | Azzeramento dei quattro campi relativi alla richiesta |
| OBS198 | Incremento row_version di una unita |
| OBS199 | Verifica effettivo aggiornamento mediante RETURNING |
| OBS200 | Conservazione holder, token, heartbeat e silenziamento durante concessione |
| OBS201 | Cinque status: granted, forbidden, not_holder, transfer_pending, no_pending_request |
| OBS202 | Protezione handoff riconciliata strutturalmente; concorrenza, membership, scadenze, perdita risposta e gestione Flutter da verificare |

Riferimenti: DB-WA-006, DB-WA-007, TST-RC02-001.

### 4.11. Completamento takeover

| ID | Osservazione |
|---|---|
| OBS203 | RPC complete_profile_edit_takeover installata localmente |
| OBS204 | Identita autenticata acquisita mediante auth.uid |
| OBS205 | Appartenenza owner attiva obbligatoria |
| OBS206 | Parametri identificativi mancanti producono not_grantee dopo verifica autorizzazione |
| OBS207 | Serializzazione mediante SELECT FOR UPDATE |
| OBS208 | clock_timestamp acquisito dopo eventuale attesa |
| OBS209 | Record assente produce no_grant |
| OBS210 | Concessione incompleta o assente produce no_grant |
| OBS211 | Concessione scaduta dopo 60 secondi produce grant_expired |
| OBS212 | Verifica identita utente destinatario della concessione |
| OBS213 | Verifica client ID destinatario della concessione |
| OBS214 | Verifica session ID destinatario della concessione |
| OBS215 | Nuovo token generato esclusivamente dal server |
| OBS216 | Generazione di 32 byte casuali, pari a 256 bit |
| OBS217 | Rappresentazione esadecimale del token di 64 caratteri |
| OBS218 | Memorizzazione esclusiva del nuovo hash SHA-256 |
| OBS219 | Sostituzione dell identita utente holder con quella destinataria della concessione |
| OBS220 | Sostituzione delle identita client e sessione holder |
| OBS221 | Reimpostazione acquired_at al tempo server |
| OBS222 | Reimpostazione heartbeat_at al tempo server |
| OBS223 | Nuovo lease ordinario di 120 secondi |
| OBS224 | Azzeramento dei quattro campi relativi alla richiesta |
| OBS225 | Azzeramento dei quattro campi relativi alla concessione |
| OBS226 | Azzeramento del silenziamento |
| OBS227 | Incremento row_version di una unita |
| OBS228 | Verifica aggiornamento e restituzione completed con lock_token, expires_at e row_version; altri status forbidden, not_grantee, no_grant e grant_expired |
| OBS229 | Trasferimento atomico di identita e token; invalidazione precedente token, concorrenza, membership, perdita risposta e recupero Flutter da verificare funzionalmente |

Riferimenti: DB-WA-006, DB-WA-007, TST-RC02-001.

### 4.12. Riconciliazione storica RPC request

| ID | Osservazione |
|---|---|
| OBS230 | Definizione originaria individuata nella migrazione 20260819215412_add_secure_profile_edit_lock_rpcs.sql alla riga 503 |
| OBS231 | Ridefinizione individuata nella migrazione 20260915081444_add_plantings_write_rpcs.sql alla riga 1906 |
| OBS232 | Acquisizione integrale delle due definizioni storiche |
| OBS233 | Eliminazione di tre variabili locali inutilizzate relative alla precedente identita richiedente |
| OBS234 | Riduzione da dieci a sette dei campi SELECT e delle corrispondenti destinazioni INTO |
| OBS235 | Firma, condizioni decisionali, mutazioni e status strutturalmente preservati |
| OBS236 | Coerenza strutturale della definizione installata con la ridefinizione successiva |
| OBS237 | Nessuna duplicazione funzionale della RPC derivante dalle due definizioni storiche |
| OBS238 | Estrazione automatizzata delle definizioni per confronto ripetibile |

Nota di rettifica: il conteggio delle variabili locali e pari a 12 nella definizione originaria e 9 nella ridefinizione, anziche 13 e 10 come indicato inizialmente durante la ricognizione.
La differenza di tre variabili inutilizzate rimane confermata.
La rettifica riguarda esclusivamente il conteggio documentale.

Riferimenti: DB-WA-006, TST-RC02-001.

### 4.13. Riconciliazione testuale e SHA-256

| ID | Osservazione |
|---|---|
| OBS239 | Primo confronto testuale non identico: 3553 caratteri nel sorgente e 3558 nel corpo acquisito dal database |
| OBS240 | Analisi puntuale della differenza testuale per distinguere alterazioni SQL da problemi di codifica |
| OBS241 | Differenze circoscritte a tre righe di commento |
| OBS242 | Cinque caratteri accentati decodificati erroneamente: una o grave, due e gravi e due a gravi |
| OBS243 | Differenza di cinque caratteri spiegata dalla rappresentazione errata dei caratteri accentati |
| OBS244 | Nessuna differenza rilevata nelle istruzioni SQL durante il confronto |
| OBS245 | SHA-256 del corpo sorgente normalizzato calcolato utilizzando UTF-8 |
| OBS246 | SHA-256 del corpo installato calcolato direttamente in PostgreSQL utilizzando UTF-8 |
| OBS247 | Identita SHA-256 dei due corpi normalizzati confermata |
| OBS248 | Discrepanza testuale ricondotta alla codifica di acquisizione; nessuna modifica SQL necessaria |

Normalizzazione: terminazioni di riga e spazi bianchi alle estremita.

- SHA256Sorgente: 40f367bd5d3839643855ce387015048e0687c26283ca348cb64107929ee056f4.
- SHA256Database: 40f367bd5d3839643855ce387015048e0687c26283ca348cb64107929ee056f4.
- HashIdentici: True.

La verifica riguarda esclusivamente il corpo normalizzato della RPC request installata localmente.

Riferimenti: DB-WA-006, TST-RC02-001.

### 4.14. Riconciliazione lifecycle complessivo

| ID | Osservazione |
|---|---|
| OBS249 | Lifecycle ordinario e takeover riconciliati strutturalmente attraverso le nove RPC pubbliche e gli helper autoritativi |
| OBS250 | Durate SQL confermate: lease 120 secondi, richiesta 600 secondi, concessione 60 secondi, silenziamento 5, 15 o 30 minuti |
| OBS251 | Matrice delle operazioni durante richiesta pendente e handoff valido riconciliata con le condizioni SQL |
| OBS252 | Verifiche residue raggruppate nelle quindici famiglie trasversali WA-V01-WA-V15, senza duplicazione automatica delle attivita |
| OBS253 | Nove RPC pubbliche analizzate strutturalmente; controlli RC02.01-05 conclusi, controlli RC02.06-10 ancora aperti |

Riferimenti: DB-WA-004, DB-WA-005, DB-WA-006, DB-WA-007, TST-RC02-001.

La conclusione strutturale non equivale alla certificazione funzionale del protocollo.
Le verifiche residue e le priorita proposte non costituiscono nuove attivita approvate.
Nessuna variazione quantitativa PERT autorizzata.

## 5. Interpretazione delle osservazioni

Le osservazioni comprendono evidenze strutturali positive,
caratteristiche tecniche, limiti, dipendenze e possibili miglioramenti.

Non costituiscono 360 non conformita.
Non costituiscono 360 nuovi pacchetti di sviluppo.
Non attribuire automaticamente classificazioni P0-P3.
Le eventuali non conformita richiedono evidenze specifiche.

Le osservazioni OBS01-OBS253 conservano
lo storico della ricognizione S046.

Le osservazioni OBS254-OBS360 riguardano
la ricognizione Flutter S047.

E3 identifica le evidenze strutturali.
E4 identifica esclusivamente i comportamenti collaudati.
NV identifica le verifiche ancora da effettuare.

Il livello E4 di un singolo comportamento
non certifica integralmente il componente.

Le evidenze condivise con altre riconciliazioni
non devono generare duplicazioni di attivita o stime.

## 6. Collegamenti

- RC01, RC02, RC03, RC04, RC05.
- NC-RC01-001.
- [INF-WA-001](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md).
- [INF-WA-002](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md).
- [DB-WA-001](../03_database/DB-WA-001_Inventario_RPC_Write_Authority.md).
- [DB-WA-002](../03_database/DB-WA-002_Struttura_Edit_Lock.md).
- [DB-WA-003](../03_database/DB-WA-003_Helper_Autorita_Scrittura.md).
- [DB-WA-004](../03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md).
- [DB-WA-005](../03_database/DB-WA-005_Heartbeat_Stato_Lock.md).
- [DB-WA-006](../03_database/DB-WA-006_Protocollo_Takeover.md).
- [DB-WA-007](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md).
- [TST-RC02-001](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md).
- [TST-RC02-002](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md).

NC-RC01-001 rimane aperta e distinta dalle osservazioni RC02.

## 7. Stato quantitativo

### 7.1. Consuntivo storico S046

- Osservazioni consolidate: 253.
- Osservazioni originarie: 41.
- Osservazioni aggiunte durante CONS.03: 212.
- Controlli RC02 conclusi strutturalmente: 5/10.
- RPC pubbliche analizzate strutturalmente: 9/9.
- Controlli strutturali sulle nove RPC: 180.
- Famiglie trasversali di verifiche residue: 15.
- Nuovi collaudi funzionali durante il consolidamento S046: 0.

### 7.2. Aggiornamento S047

- Osservazioni storiche conservate: 253.
- Nuove osservazioni Flutter: 107.
- Osservazioni complessive: 360.
- RPC integrate nel repository Flutter: 3/9.
- Stati SQL complessivi: 48.
- Stati decodificati dal repository Flutter: 12.
- Stati non integrati: 36.
- Suite Flutter mirate: 7/7 PASS.
- Test Flutter mirati: 116/116 PASS.
- Baseline generale Flutter: 1956/1956 PASS.
- Nuovi test introdotti: 0.
- Verifiche specifiche residue C01-C09: 9.
- Famiglie trasversali residue: 15.
- Famiglie integralmente chiuse: 0.
- Controllo RC02.06: ricognizione acquisita, consolidamento finale da verificare.
- Nuove non conformita formalmente approvate: 0.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

I 116 test mirati non rappresentano necessariamente
scenari aggiuntivi rispetto alla baseline generale.

Nessuna variazione delle stime derivante dal numero di osservazioni.

## 8. Limiti del consolidamento

### 8.1. Consolidamento originario S046

Inventario sintetico ricostruito dalle evidenze gia acquisite.
Non costituisce trascrizione integrale degli output SQL originari.
Nessun nuovo collaudo eseguito durante il consolidamento S046.
Le evidenze SQL strutturali non equivalgono a collaudi funzionali superati.
La configurazione remota rimane non verificata.
Le osservazioni iniziali sono conservate come storico della ricognizione.
Le successive osservazioni possono risolvere verifiche precedentemente aperte.
Il consolidamento non determina automaticamente variazioni delle stime V1.
Versionamento originariamente previsto in CONS.05.

### 8.2. Aggiornamento S047

Le osservazioni Flutter derivano dall'esame
dei componenti e dei test esistenti.

Le sette suite mirate sono state rieseguite
utilizzando dipendenze simulate.

Le evidenze non certificano il comportamento
integrato reale Flutter-PostgreSQL.

Le ricerche testuali sono limitate
ai percorsi e ai filtri utilizzati.

Le verifiche residue non costituiscono
automaticamente non conformita accertate.

Nessuna modifica applicativa introdotta.
Nessuna modifica SQL introdotta.
Nessuna migrazione remota applicata.
Nessuna variazione quantitativa PERT.

## 9. Osservazioni infrastruttura Flutter S047

### 9.1. Modelli e contratti

| ID | Livello | Osservazione |
|---|---|---|
| OBS254 | E3 | Modello ProfileEditLockLease disponibile con profilo, identita, token, scadenza e versione |
| OBS255 | E3 | Rinnovo del lease conserva profilo, identita e token |
| OBS256 | E3 | AppSessionIdentity distingue clientInstanceId e sessionId |
| OBS257 | E3 | Risultati ordinari rappresentati mediante contratti tipizzati |
| OBS258 | E3 | Cinque risultati Acquire, tre Heartbeat e quattro Release |
| OBS259 | E3 | Rappresentazione testuale del lease non espone il token |
| OBS260 | NV | Validazione autonoma delle identita applicative da approfondire |
| OBS261 | NV | Contratti tipizzati Get State e Takeover non individuati nel perimetro esaminato |

Riferimenti: INF-WA-002, TST-RC02-002.

### 9.2. Repository Edit Lock

| ID | Livello | Osservazione |
|---|---|---|
| OBS262 | E3 | Repository con invocatore RPC sostituibile per i test |
| OBS263 | E3 | Invocatore ordinario collegato al client Supabase |
| OBS264 | E4 | Acquire trasmette i tre identificativi previsti dal contratto |
| OBS265 | E4 | Risposta acquired convertita in lease con scadenza UTC |
| OBS266 | E4 | Decodifica dei quattro risultati Acquire senza acquisizione |
| OBS267 | E4 | Risposta acquired priva di token rifiutata |
| OBS268 | E4 | Status Acquire sconosciuto rifiutato |
| OBS269 | E4 | Risposta Acquire non rappresentata da una mappa rifiutata |
| OBS270 | E4 | Heartbeat trasmette identita e token previsti |
| OBS271 | E4 | Heartbeat renewed conserva identita e token del lease |
| OBS272 | E4 | Heartbeat not_holder e forbidden decodificati |
| OBS273 | E4 | Risposta Heartbeat con data non valida e versione zero rifiutata |
| OBS274 | E4 | Release trasmette identita e token previsti |
| OBS275 | E4 | Quattro risultati Release decodificati, incluso transfer_pending |
| OBS276 | E4 | Status Release sconosciuto rifiutato |
| OBS277 | NV | Validazione isolata di row_version non dimostrata dal test combinato |
| OBS278 | NV | Uniformita della validazione UUID, token, scadenze e versioni da approfondire |
| OBS279 | NV | Risposte perse o tardive e anomalie di trasporto da verificare in integrazione |

Riferimenti: INF-WA-002, TST-RC02-002.
Collegamenti storici: OBS58, OBS60, OBS75, OBS78, OBS93.

### 9.3. Controller Write Authority

| ID | Livello | Osservazione |
|---|---|---|
| OBS280 | E3 | Controller articolato in undici stati applicativi |
| OBS281 | E4 | Membri senza diritto di scrittura mantenuti in sola lettura |
| OBS282 | E4 | Acquire riuscito abilita lo stato writer con lease valido |
| OBS283 | E4 | Disponibilita scrittura subordinata alla validita temporale del lease |
| OBS284 | E4 | Lease rinnovato con medesima identita e token riconosciuto |
| OBS285 | E4 | Token differente impedisce utilizzo del lease precedente |
| OBS286 | E4 | Identita client differente impedisce utilizzo del lease precedente |
| OBS287 | E4 | Identita sessione differente impedisce utilizzo del lease precedente |
| OBS288 | E4 | Profilo differente impedisce utilizzo del lease precedente |
| OBS289 | E4 | Verifica temporale del lease alla scadenza esatta senza mutazione dello stato |
| OBS290 | E4 | BedRepository richiede il lease per le operazioni protette esercitate |
| OBS291 | E4 | BedRepository non riutilizza un lease scaduto |
| OBS292 | E4 | Medesimo repository utilizza la nuova autorita dopo nuova acquisizione |
| OBS293 | E4 | Risultati Acquire negativi riconciliati negli stati applicativi previsti |
| OBS294 | E4 | Errore di trasporto Acquire conduce a recupero e nuovo tentativo |
| OBS295 | E4 | Heartbeat riuscito rinnova il lease |
| OBS296 | E4 | Errore Heartbeat conduce a recupero con scrittura sospesa |
| OBS297 | E4 | Errore Heartbeat dopo scadenza conduce a perdita del lease |
| OBS298 | E4 | Heartbeat not_holder conduce a perdita dell'autorita |
| OBS299 | E4 | Heartbeat forbidden conduce allo stato forbidden |
| OBS300 | E4 | Risposta Heartbeat malformata conduce a protocolError |
| OBS301 | E4 | Lease scaduto rifiutato da requireLeaseForWrite |
| OBS302 | E4 | Recupero dopo scadenza mediante nuovo tentativo esercitato |
| OBS303 | E4 | verifyNow riconcilia lo stato finale mediante Heartbeat |
| OBS304 | E4 | Release rimuove l'autorita locale |
| OBS305 | E4 | Errore Release non ripristina l'autorita locale |
| OBS306 | E4 | Risposta Acquire tardiva dopo cambio generazione sottoposta a rilascio simulato |
| OBS307 | E3 | Dispose del controller invalida generazione, lease e pianificazione locale |
| OBS308 | NV | Risposta Heartbeat positiva di generazione precedente da collaudare |
| OBS309 | NV | Interferenza del flag Heartbeat tra generazioni concorrenti da verificare |
| OBS310 | NV | Risposta Heartbeat positiva tardiva dopo scadenza e riacquisizione da verificare |
| OBS311 | NV | Stato intermedio durante verifyNow pendente da collaudare |
| OBS312 | NV | Reinizializzazione di controller con precedente lease attivo da approfondire |

Riferimenti: INF-WA-002, TST-RC02-002.
Verifiche specifiche: C01-C09.

### 9.4. Scheduler e scadenze

| ID | Livello | Osservazione |
|---|---|---|
| OBS313 | E3 | Scheduler ordinario basato su Timer a esecuzione singola |
| OBS314 | E3 | Heartbeat pianificato dopo 30 secondi e recupero dopo 10 secondi |
| OBS315 | E4 | Esecuzione del callback pianificato verificata |
| OBS316 | E4 | Annullamento del timer prima dell'esecuzione verificato |
| OBS317 | NV | Callback asincroni gia avviati e relative eccezioni da approfondire |
| OBS318 | NV | Sospensione browser, ritardi reali e ripresa applicativa da collaudare |

Riferimenti: INF-WA-002, TST-RC02-002.
Collegamenti storici: OBS95, OBS250.

### 9.5. Scope e propagazione

| ID | Livello | Osservazione |
|---|---|---|
| OBS319 | E3 | Scope implementato mediante InheritedNotifier |
| OBS320 | E3 | Accessi reattivi e non reattivi distinti |
| OBS321 | E4 | Accessi of e read restituiscono il controller condiviso |
| OBS322 | E4 | Accesso obbligatorio senza Scope produce errore |
| OBS323 | NV | Notifiche reattive, accesso opzionale e servizio mutazioni condiviso da approfondire |

Riferimenti: INF-WA-002, TST-RC02-002.

### 9.6. Disponibilita di scrittura delle route

| ID | Livello | Osservazione |
|---|---|---|
| OBS324 | E4 | Route senza autorita iniziale mantenuta in sola lettura |
| OBS325 | E4 | Route senza lease iniziale non acquisisce autorita tardivamente |
| OBS326 | E4 | Lease valido abilita disponibilita senza nuova RPC |
| OBS327 | E4 | Contesto applicativo non valido impedisce la scrittura |
| OBS328 | E4 | Eccezione nella verifica del contesto gestita fail-closed |
| OBS329 | E4 | Ripristino del contesto valido consente recupero della medesima autorita |
| OBS330 | E4 | Scadenza esatta del lease revoca disponibilita della route |
| OBS331 | E4 | Verifica temporale immediatamente precedente alla scadenza esercitata |
| OBS332 | E4 | Apertura alla scadenza esatta non pianifica timer utile |
| OBS333 | E4 | Timer anticipato riconciliato con durata residua |
| OBS334 | E4 | Rinnovo del lease ripianifica la scadenza |
| OBS335 | E4 | Callback temporale obsoleto non altera la nuova pianificazione |
| OBS336 | E4 | Recupero con medesimo token ripristina disponibilita |
| OBS337 | E4 | Nuovo token non riabilita una route associata al precedente lease |
| OBS338 | E4 | Release revoca sincronicamente la disponibilita prima della risposta RPC |
| OBS339 | E4 | Invalidazione permanente impedisce riattivazione mediante heartbeat o refresh |
| OBS340 | E4 | Invalidazione idempotente e annullamento delle risorse temporali esercitati |
| OBS341 | E4 | Dispose annulla timer e sottoscrizioni della route |
| OBS342 | E4 | Coerenza della singola valutazione temporale durante apertura e refresh esercitata |
| OBS343 | NV | Collegamento completo con lifecycle delle route effettive da verificare in RC02.07 |

Riferimenti: INF-WA-002, TST-RC02-002.

### 9.7. Get State e Takeover Flutter

| ID | Livello | Osservazione |
|---|---|---|
| OBS344 | E3 | Get State non integrato nel repository Flutter esaminato |
| OBS345 | E3 | Cinque RPC Takeover non integrate nel repository Flutter esaminato |
| OBS346 | E3 | Controller privo di stati dedicati al lifecycle Takeover nel perimetro esaminato |
| OBS347 | E3 | Release transfer_pending tipizzato ma privo di riconciliazione dedicata nel controller |
| OBS348 | NV | Rilevamento richiesta entrante e sospensione scrittura durante handoff da integrare e verificare |
| OBS349 | NV | Acquisizione del nuovo lease dopo Complete e invalidazione del precedente holder da collaudare |

Riferimenti: INF-WA-002, DB-WA-005, DB-WA-006.
Collegamenti storici: OBS78, OBS112, OBS115, OBS156, OBS178, OBS202, OBS229.

### 9.8. Widget pianificazioni stagionali

| ID | Livello | Osservazione |
|---|---|---|
| OBS350 | E4 | Creazione, aggiornamento e rifiuto delle mutazioni esercitati con RPC simulate |
| OBS351 | E4 | Recupero mediante ricevuta esercitato senza ripetizione della mutazione |
| OBS352 | E4 | Esecuzione subordinata alla selezione della data |
| OBS353 | E4 | Conferma e annullamento subordinati a disponibilita e stato delle operazioni |
| OBS354 | E4 | Widget senza autorita disponibile mantenuto in sola lettura |
| OBS355 | E4 | Revoca, scadenza e invalidazione della disponibilita propagate ai widget |
| OBS356 | E4 | Rimozione e sostituzione del notifier riconciliano le sottoscrizioni |

Riferimenti: INF-WA-002, TST-RC02-002.
Evidenze condivise con RC05, da non conteggiare due volte.

### 9.9. ProfileSessionGate e autenticazione

| ID | Livello | Osservazione |
|---|---|---|
| OBS357 | E3 | AuthGate collega la sessione autenticata al ProfileSessionGate |
| OBS358 | E4 | Inizializzazione ordinaria, recupero errore e attesa identita esercitati |
| OBS359 | E4 | Rimozione Gate invoca Release simulato; risoluzione profilo tardiva non inizializza la sessione rimossa |

Riferimenti: INF-WA-002, TST-RC02-002.
Evidenze condivise con RC01.
Rilascio remoto effettivo, logout e lifecycle applicativo rimangono da verificare.

### 9.10. Riconciliazione Flutter-PostgreSQL

| ID | Livello | Osservazione |
|---|---|---|
| OBS360 | E3 | Riconciliazione strutturale dei contratti ordinari completata: tre RPC integrate su nove e dodici stati decodificati su quarantotto; integrazione complessiva ancora parziale |

Riferimenti: INF-WA-002, TST-RC02-002, DB-WA-007.

La ricognizione Flutter conserva le nove verifiche
specifiche C01-C09 e le quindici famiglie
trasversali WA-V01-WA-V15.

Le verifiche gia registrate nelle osservazioni storiche
sono richiamate senza duplicazione automatica.

Il collaudo integrato reale rimane NV.
L'ambiente remoto rimane NV.
Nessuna famiglia residua integralmente chiusa.
Nessuna nuova non conformita formalmente approvata.
Nessuna variazione quantitativa PERT.
