# INF-WA-001 - Inventario Write Authority

## 1. Identificazione

- Versione: 1.1.
- Sessione originaria: S046.
- Sessione aggiornamento: S047.
- Data: 26/11/2026.
- Origine: RC02, controllo 01.
- Aggiornamento: RC02, controllo 06.
- Macroblocco principale: V1-02.
- Baseline Git originaria: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline Git aggiornamento: 39665b458221b69c469ebe1d16a686312af79320.
- Stato della ricognizione RC02: PARZIALE.
- Evidenza strutturale complessiva: E3.
- Evidenze specifiche collaudate: E4.
- Collaudo integrato reale Flutter-PostgreSQL: NV.
- Ambiente remoto: NV.

### 1.1. Storico delle versioni

| Versione | Sessione | Data | Contenuto |
|---|---|---|---|
| 1.0 | S046 | 26/11/2026 | Inventario originario Write Authority |
| 1.1 | S047 | 26/11/2026 | Collegamento evidenze Flutter e correzione documentale RPC |

## 2. Finalita

Conservare l'inventario delle infrastrutture
di Write Authority gia individuate.

Consentire la consultazione dei componenti
senza ripetere la ricerca generale.

La presenza di un componente non attesta
la completezza del suo comportamento.

Il presente documento mantiene
la funzione di inventario generale.

Gli approfondimenti tecnici Flutter
sono conservati in INF-WA-002.

Le evidenze analitiche dei collaudi Flutter
sono conservate in TST-RC02-002.

## 3. Inventario della ricerca Git

### 3.1. Inventario originario S046

Ricerca effettuata mediante:

git ls-files lib test supabase

Filtri utilizzati:

- write_authority.
- writeauthority.
- edit_lock.
- lease.
- takeover.
- heartbeat.
- single_writer.

Risultati individuati: 40 file.

| Categoria | File |
|---|---:|
| Flutter | 26 |
| Migrazioni | 4 |
| Test | 10 |
| Totale | 40 |

Il risultato riguarda i filtri utilizzati.

Non costituisce necessariamente
l'inventario esaustivo di tutte
le dipendenze della Write Authority.

### 3.2. Aggiornamento S047

La ricognizione RC02.06 ha approfondito
i componenti Flutter pertinenti
alla Write Authority.

Sono stati esaminati anche componenti
condivisi con autenticazione,
contesto profilo e pianificazioni stagionali.

Il numero originario di 40 file
rimane invariato come evidenza storica
della ricerca effettuata nella S046.

Non deve essere interpretato
come inventario esaustivo aggiornato.

Le evidenze successive non devono
essere sommate automaticamente
ai risultati originari.

## 4. Componenti diretti e condivisi

### 4.1. Inventario originario

| File | Responsabilita |
|---|---|
| profile_edit_lock.dart | Modello edit lock |
| profile_write_authority_controller.dart | Controller autorita |
| profile_write_authority_scope.dart | Scope condiviso |
| write_authority_scheduler.dart | Pianificazione heartbeat |
| profile_edit_lock_repository.dart | Comunicazione database |
| route_write_availability.dart | Disponibilita scrittura |
| planning_route_lifetime.dart | Ciclo di vita route |

Percorso principale:

lib/core/write_authority.

Repository:

lib/data/repositories/profile_edit_lock_repository.dart.

I percorsi completi degli altri file
devono essere risolti mediante git ls-files
quando necessario.

### 4.2. Approfondimenti S047

| Componente | Evidenza acquisita |
|---|---|
| Modelli Edit Lock | Contratti ordinari esaminati |
| AppSessionIdentity | Identita client e sessione esaminate |
| Repository Edit Lock | Tre RPC ordinarie esaminate e collaudate |
| Controller | Stati, lease, recupero e rilascio esaminati |
| Scheduler | Pianificazione e annullamento collaudati |
| Scope | Propagazione del controller collaudata |
| RouteWriteAvailability | Disponibilita temporale e invalidazione collaudate |
| ProfileSessionGate | Inizializzazione e rilascio simulato collaudati |
| AuthGate | Collegamento alla sessione autenticata esaminato |
| PlanningRouteLifetime | Approfondimento integrativo residuo |

Il livello E4 riguarda esclusivamente
i comportamenti effettivamente collaudati.

La ricognizione non certifica
integralmente ciascun componente.

### 4.3. Copertura dei contratti

| Indicatore | Risultato |
|---|---:|
| RPC SQL locali analizzate | 9/9 |
| RPC integrate nel repository Flutter | 3/9 |
| Stati delle RPC ordinarie decodificati | 12/12 |
| Stati complessivi decodificati | 12/48 |
| Stati non integrati | 36 |

Le sei RPC non integrate comprendono
Get State e le cinque RPC Takeover.

La copertura numerica dei contratti
non rappresenta la maturita complessiva
della Write Authority.

Per il dettaglio consultare INF-WA-002.

## 5. Componenti collegati alla RC05

- mutation_operation_contract.dart.
- mutation_operation_coordinator.dart.
- mutation_operation_journal.dart.
- seasonal_planning_mutation_service.dart.
- seasonal_planning_mutation_transport.dart.

Responsabilita collegate:

- Contratti delle mutazioni.
- Coordinamento delle operazioni.
- Persistenza del journal.
- Ricevute.
- Recupero e riconciliazione.

La verifica approfondita appartiene
principalmente alla RC05.

L'integrazione con la Write Authority
rimane pertinente alla RC02.

Le evidenze condivise devono essere
riutilizzate senza duplicazione
automatica delle attivita.

## 6. Risultati di scrittura dei domini

Quattordici famiglie di file
con suffisso _write_result.dart:

| Dominio |
|---|
| agronomic_parameter |
| bed |
| botanical_taxon |
| catalog_crop |
| crop_cultivar |
| garden |
| harvest_purpose |
| measurement_unit |
| planned_planting |
| planting |
| production_context |
| protection_context |
| season |
| training_context |

La presenza dei risultati tipizzati
non dimostra che tutte le mutazioni
del dominio utilizzino correttamente
la Write Authority.

La verifica dei percorsi effettivi
rimane aperta.

L'approfondimento dei percorsi
autoritativi dei domini appartiene
al controllo RC02.07.

## 7. Migrazioni principali

### 7.1. Inventario originario

Percorso:

supabase/migrations.

Migrazioni individuate:

- 20260818154920_harden_profile_edit_locks.sql.
- 20260818162315_add_takeover_grant_state.sql.
- 20260819215412_add_secure_profile_edit_lock_rpcs.sql.
- 20260823111048_add_profile_write_authority.sql.

Ulteriore migrazione individuata
mediante ricerca delle dichiarazioni:

20260915081444_add_plantings_write_rpcs.sql.

Quest'ultima ridefinisce
request_profile_edit_takeover
alla riga 1906 rilevata.

La definizione effettivamente installata
deve essere considerata autorevole
per il database locale.

### 7.2. Correzione documentale S047

La versione 1.0 riportava
una denominazione inesatta
della RPC ridefinita.

La denominazione corretta e:

request_profile_edit_takeover.

La correzione riguarda esclusivamente
l'inventario documentale.

Non e stata introdotta alcuna modifica
alle migrazioni o alle funzioni SQL.

### 7.3. Evidenze SQL consolidate

La ricognizione SQL ha individuato
nove RPC pubbliche della Write Authority.

Il dettaglio strutturale e conservato
nei documenti DB-WA-001 - DB-WA-007
e TST-RC02-001.

La riconciliazione con Flutter
e approfondita in INF-WA-002.

All'apertura della S047:

- Migrazioni locali: 48/48.
- Migrazioni remote: 34/48.
- Migrazioni non applicate al remoto: 14.

Nessuna migrazione remota applicata
durante la ricognizione RC02.06.

## 8. Inventario dei test

### 8.1. Inventario originario S046

Quattro file direttamente pertinenti:

- Test del controller Write Authority.
- Test dello Scope Write Authority.
- Test dello scheduler.
- Test del repository edit lock.

Due file condivisi:

- route_write_availability.
- planning_route_lifetime.

Quattro file collegati alla RC05:

- mutation_operation_contract.
- mutation_operation_coordinator.
- mutation_operation_journal.
- seasonal_planning_mutation_receipt.

Totale file individuati: 10.

Alla chiusura dell'inventario originario
il contenuto dei dieci file non era
ancora stato integralmente esaminato
nella RC02.

Non attribuire un numero di scenari
o un livello E4 sulla sola base
della presenza dei file.

### 8.2. Collaudi mirati S047

| Suite | Test superati |
|---|---:|
| Repository Edit Lock | 17 |
| Controller Write Authority | 33 |
| Scheduler | 2 |
| Scope | 2 |
| RouteWriteAvailability | 35 |
| Widget pianificazioni stagionali | 20 |
| ProfileSessionGate | 7 |
| Totale | 116 |

Risultato: 116/116 PASS.

Suite superate: 7/7.

Test falliti: 0.

Nuovi test introdotti: 0.

Somma delle durate riportate: 82 secondi.

Baseline generale di apertura S047:

- flutter analyze: PASS.
- flutter test: 1956/1956 PASS.

Le sette suite mirate non devono
essere sommate automaticamente
ai dieci file dell'inventario originario.

I 116 test mirati non devono essere
sommati ai 1956 test generali
come scenari necessariamente distinti.

### 8.3. Livelli di evidenza

I collaudi mirati utilizzano
dipendenze simulate.

Le evidenze E4 riguardano
i comportamenti effettivamente esercitati.

Non costituiscono prova completa
dell'integrazione Flutter-PostgreSQL.

Il dettaglio dei collaudi,
della copertura e dei limiti
e conservato in TST-RC02-002.

PlanningRouteLifetime e le suite
specifiche RC05 non devono essere
considerati integralmente collaudati
sulla base del presente consuntivo.

## 9. Dipendenze

Infrastrutture gia consolidate:

- INF-AUTH-001.
- INF-ID-001.
- FLT-PROF-001.
- DB-PROF-001.
- DB-SEC-001.
- DB-VER-001.

Riconciliazioni collegate:

- RC01.
- RC03.
- RC04.
- RC05.
- RC07.
- RC17.

Non conformita collegata:

NC-RC01-001.

La non conformita rimane aperta
e distinta dalle verifiche residue
individuate nella RC02.06.

## 10. Riutilizzo

### 10.1. Principi originari

RIUTILIZZARE:

L'inventario e le evidenze gia acquisite.

VERIFICARE:

- Contratti dei componenti.
- Acquisizione e rilascio del lock.
- Heartbeat e scadenza.
- Takeover.
- Integrazione nei domini.
- Concorrenza.
- Collaudi pertinenti.

Non introdurre una seconda infrastruttura
di autorita di scrittura nei nuovi domini.

La classificazione definitiva
dei singoli componenti richiede
il completamento della RC02.

### 10.2. Classificazione dopo RC02.06

| Componente o ambito | Classificazione |
|---|---|
| Modelli lease ordinari | RIUTILIZZARE |
| Identita applicativa | RIUTILIZZARE |
| Repository RPC ordinarie | RIUTILIZZARE |
| Controller | RIUTILIZZARE |
| Scheduler | RIUTILIZZARE |
| Scope | RIUTILIZZARE |
| RouteWriteAvailability | RIUTILIZZARE |
| ProfileSessionGate | RIUTILIZZARE |
| Get State | INTEGRARE |
| Cinque RPC Takeover | INTEGRARE |
| Modelli specifici mancanti | SVILUPPARE |
| Gestione applicativa handoff | INTEGRARE |
| Lifecycle applicativo | VERIFICARE / INTEGRARE |
| PlanningRouteLifetime | VERIFICARE |
| Logout e rilascio effettivo | VERIFICARE |
| Percorsi autoritativi dei domini | VERIFICARE |
| Collaudi integrati reali | VERIFICARE |

Le classificazioni indicano
il trattamento tecnico delle evidenze.

Non costituiscono automaticamente
nuovi pacchetti di lavoro approvati.

Non attribuire riduzioni temporali
sulla sola base della presenza
di componenti riutilizzabili.

### 10.3. Verifiche residue

Rimangono aperte le quindici
famiglie trasversali WA-V01 - WA-V15.

Le verifiche specifiche C01-C09
sono approfondimenti delle famiglie
gia individuate.

Nessuna famiglia integralmente chiusa
a seguito della sola ricognizione Flutter.

Il dettaglio e conservato
in INF-WA-002 e TST-RC02-002.

Non duplicare le attivita condivise
con RC01, RC05 e le altre
riconciliazioni pertinenti.

## 11. Limiti

### 11.1. Consolidamento originario S046

Inventario consolidato dalle evidenze
precedentemente acquisite nella RC02.

Nessuna nuova ispezione integrale
delle fonti durante il consolidamento
originario dell'inventario.

Nessun nuovo collaudo eseguito
durante tale consolidamento.

Nessuna modifica tecnica introdotta.

### 11.2. Aggiornamento S047

La ricognizione RC02.06 ha esaminato
componenti Flutter e suite esistenti.

Sono stati rieseguiti 116 test mirati.

Nessun nuovo test introdotto.

Le ricerche effettuate sono circoscritte
ai percorsi e ai filtri utilizzati.

L'assenza di risultati non costituisce
sempre prova esaustiva di assenza
di una funzionalita.

La ricognizione Flutter non equivale
alla conclusione della RC02.

Il livello complessivo rimane E3.

Il collaudo integrato reale rimane NV.

L'ambiente remoto rimane NV.

Nessuna modifica applicativa introdotta.

Nessuna modifica SQL introdotta.

Nessuna migrazione remota applicata.

Nessuna nuova non conformita
formalmente approvata.

Nessuna variazione quantitativa PERT.

### 11.3. Riferimenti documentali

- [INF-WA-002](INF-WA-002_Infrastruttura_Flutter_Write_Authority.md).
- [DB-WA-001](../03_database/DB-WA-001_Inventario_RPC_Write_Authority.md).
- [DB-WA-002](../03_database/DB-WA-002_Struttura_Edit_Lock.md).
- [DB-WA-003](../03_database/DB-WA-003_Helper_Autorita_Scrittura.md).
- [DB-WA-004](../03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md).
- [DB-WA-005](../03_database/DB-WA-005_Heartbeat_Stato_Lock.md).
- [DB-WA-006](../03_database/DB-WA-006_Protocollo_Takeover.md).
- [DB-WA-007](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md).
- [TST-RC02-001](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md).
- [TST-RC02-002](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md).
- [RC02-OBS-001](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md).
- [RC02_Stato_Parziale](../08_riutilizzo/RC02_Stato_Parziale.md).
