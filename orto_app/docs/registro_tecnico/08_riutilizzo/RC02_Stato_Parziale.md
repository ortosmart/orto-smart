# RC02 - Stato parziale della ricognizione

## 1. Identificazione

- Identificativo: RC02.
- Versione: 1.1.
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
| 02 | Struttura profile_edit_locks | Concluso strutturalmente |
| 03 | Helper, acquisizione e rilascio RPC | Concluso strutturalmente |
| 04 | Heartbeat, scadenza e rinnovo | Concluso strutturalmente |
| 05 | Lifecycle takeover | Concluso strutturalmente |
| 06 | Controller, scheduler, scope e gate Flutter | Da eseguire |
| 07 | Integrazione nei domini | Da eseguire |
| 08 | Approfondimento NC-RC01-001 | Da eseguire |
| 09 | Test ed evidenze integrate | Da eseguire |
| 10 | Conclusione tecnica | Da eseguire |

Controlli principali conclusi: 5/10.
Avanzamento per numero di controlli: 50%.

Non costituisce percentuale di maturita della Write Authority.

La conclusione strutturale dei controlli 01-05
non equivale al superamento dei collaudi funzionali.

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

- 03.1: definizioni dei tre helper iniziali.
- 03.2: dipendenza owner esplicita.
- 03.3: acquisizione del lock.
- 03.4: rilascio del lock.

Controllo 04:

- 04.1: heartbeat e rinnovo.
- 04.2: consultazione dello stato del lock.

Controllo 05:

- 05.1: richiesta takeover.
- 05.2: annullamento richiesta.
- 05.3: rifiuto richiesta e silenziamento.
- 05.4: concessione takeover.
- 05.5: completamento takeover.
- 05.6: confronto storico request e riconciliazione lifecycle.

Tutti i controlli sopra elencati
sono conclusi nel rispettivo perimetro strutturale.

Non ripetere i controlli conclusi se le condizioni
tecniche rimangono invariate.

Le verifiche funzionali residue devono essere
riconciliate con le evidenze di collaudo esistenti.

## 5. Evidenze consolidate

| Scheda | Contenuto |
|---|---|
| INF-WA-001 | Inventario Flutter, migrazioni e test |
| DB-WA-001 | Inventario RPC e helper |
| DB-WA-002 | Struttura edit lock e privilegi |
| DB-WA-003 | Contratti dei quattro helper esaminati |
| DB-WA-004 | Acquisizione e rilascio lock |
| DB-WA-005 | Heartbeat e stato lock |
| DB-WA-006 | Protocollo takeover |
| DB-WA-007 | Lifecycle e contratti RPC |
| TST-RC02-001 | Evidenze strutturali SQL |
| RC02-OBS-001 | Osservazioni tecniche |

Risultati principali:

- 40 file individuati nella ricerca iniziale.
- 13 dichiarazioni SQL inizialmente individuate.
- 12 funzioni distinte installate nel perimetro iniziale.
- 9 RPC pubbliche analizzate strutturalmente.
- 3 helper privati del perimetro iniziale.
- 1 helper owner aggiuntivo esaminato.
- 4 helper privati complessivamente esaminati.
- 18 colonne della tabella edit lock.
- 10 vincoli CHECK.
- 253 osservazioni consolidate localmente.
- 180 controlli strutturali sulle nove RPC.
- 15 famiglie trasversali di verifiche residue.

La dipendenza owner aggiuntiva non e compresa
nel conteggio iniziale delle dodici funzioni.

### 5.1. Evidenze del lifecycle

- Lease ordinario: 120 secondi.
- Richiesta takeover: 600 secondi.
- Concessione takeover: 60 secondi.
- Silenziamento: 5, 15 o 30 minuti.
- Token generato dal server mediante 32 byte casuali.
- Memorizzazione del solo hash SHA-256.
- Serializzazione delle mutazioni protette mediante helper autoritativo.
- Sospensione delle mutazioni protette durante il grant valido.
- Sostituzione del token al completamento takeover.

### 5.2. Livello delle evidenze

Le definizioni SQL esaminate costituiscono
evidenze strutturali E3.

Il confronto storico della RPC request
e stato consolidato in DB-WA-006 e TST-RC02-001.

Le 15 famiglie WA-V01-WA-V15
sono documentate in DB-WA-007.

Non costituiscono automaticamente
15 nuovi pacchetti di sviluppo.

Nessun nuovo collaudo funzionale
eseguito durante il consolidamento.

Ambiente remoto: NV.

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

Controllo RC02.06.

Controller, scheduler, scope e gate Flutter.

Obiettivo:

Verificare la corrispondenza fra i contratti
SQL gia acquisiti e il comportamento
delle infrastrutture Flutter esistenti.

Componenti iniziali da consultare:

- profile_edit_lock.dart.
- profile_edit_lock_repository.dart.
- profile_write_authority_controller.dart.
- write_authority_scheduler.dart.
- profile_write_authority_scope.dart.
- ProfileSessionGate.
- route_write_availability.dart.
- planning_route_lifetime.dart.

Utilizzare INF-WA-001 per individuare
i percorsi sorgente gia inventariati.

Consultare DB-WA-004, DB-WA-005,
DB-WA-006 e DB-WA-007 per i contratti SQL.

Verificare progressivamente:

- Modelli e decodifica delle risposte RPC.
- Gestione degli stati del lock.
- Conservazione e invalidazione del token.
- Acquisizione, heartbeat e rilascio.
- Gestione delle scadenze locali.
- Richiesta, rifiuto e concessione takeover.
- Completamento del trasferimento.
- Sospensione delle scritture durante il grant.
- Recupero dopo perdita della risposta.
- Comportamento fail-closed.
- Lifecycle delle sessioni e delle route.
- Collegamento con i test esistenti.

Non assumere che questi comportamenti
siano gia verificati soltanto perche
le relative infrastrutture esistono.

Il primo comando di ispezione Flutter
deve essere definito alla ripresa effettiva
dopo la verifica dello stato Git.

Non ripetere il precedente controllo 03.2:
la definizione installata dell helper owner
e gia stata acquisita e consolidata.

## 9. Procedura successiva

Prima della ripresa:

- Concludere CONS.04.
- Completare CONS.05.
- Verificare integrita e persistenza del Registro.
- Ottenere autorizzazione al commit e al push.
- Verificare la baseline Git risultante.

Dopo la ripresa:

- Consultare le schede tecniche pertinenti.
- Avviare il controllo RC02.06.
- Acquisire le evidenze Flutter.
- Riconciliare i contratti Flutter con quelli SQL.
- Aggiornare progressivamente il Registro.
- Proseguire con RC02.07-10.
- Sottoporre la conclusione tecnica ad approvazione.
- Riconciliare separatamente la baseline quantitativa.

Procedere un comando alla volta.

Non introdurre correzioni applicative
senza la relativa autorizzazione.

Non applicare migrazioni remote
senza autorizzazione esplicita.

## 10. Limiti e stato conclusivo

La ricognizione RC02 non e' conclusa.
Il consolidamento documentale non aumenta
l'avanzamento tecnico.

Le evidenze locali non attestano
l'equivalenza dell'ambiente remoto.

Nessuna correzione autorizzata.
Nessuna variazione quantitativa introdotta.

Nessuna modifica tecnica introdotta.
