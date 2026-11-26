# RC02-OBS-001 - Osservazioni tecniche

## 1. Identificazione

- Versione: 1.1.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controlli 01-05.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Stato: PARZIALE - controlli strutturali 01-05 conclusi; controlli 06-10 aperti.
- Ambiente verificato: codice Git e PostgreSQL locale.
- Ambiente remoto: NV.

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

Non costituiscono 253 non conformita.
Non costituiscono 253 nuovi pacchetti di sviluppo.
Non attribuire automaticamente classificazioni P0-P3.
Le eventuali non conformita richiedono evidenze specifiche.

## 6. Collegamenti

- RC01, RC02, RC03, RC04, RC05.
- NC-RC01-001.
- INF-WA-001.
- DB-WA-001.
- DB-WA-002.
- DB-WA-003.
- DB-WA-004.
- DB-WA-005.
- DB-WA-006.
- DB-WA-007.
- TST-RC02-001.

NC-RC01-001 rimane aperta e distinta dalle osservazioni RC02.

## 7. Stato quantitativo

- Osservazioni consolidate localmente: 253.
- Osservazioni originarie: 41.
- Osservazioni aggiunte durante CONS.03: 212.
- Controlli RC02 conclusi strutturalmente: 5/10.
- RPC pubbliche analizzate strutturalmente: 9/9.
- Controlli strutturali sulle nove RPC: 180.
- Famiglie trasversali di verifiche residue: 15.
- Nuovi collaudi funzionali eseguiti durante il consolidamento: 0.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

Nessuna variazione delle stime derivante dal numero di osservazioni.

## 8. Limiti del consolidamento

Inventario sintetico ricostruito dalle evidenze gia acquisite.
Non costituisce trascrizione integrale degli output SQL originari.
Nessun nuovo collaudo eseguito durante il consolidamento.
Le evidenze SQL strutturali non equivalgono a collaudi funzionali superati.
La configurazione remota rimane non verificata.
Le osservazioni iniziali sono conservate come storico della ricognizione.
Le successive osservazioni possono risolvere verifiche precedentemente aperte.
Il consolidamento non determina automaticamente variazioni delle stime V1.
Versionamento delle nuove evidenze previsto in CONS.05.

Nessuna modifica tecnica introdotta.
