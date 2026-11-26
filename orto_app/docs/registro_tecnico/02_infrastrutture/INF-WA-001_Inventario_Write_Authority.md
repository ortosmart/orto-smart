# INF-WA-001 - Inventario Write Authority

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controllo 01.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Stato della ricognizione: PARZIALE.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

## 2. Finalita

Conservare l'inventario delle infrastrutture
di Write Authority gia individuate.

Consentire la consultazione dei componenti
senza ripetere la ricerca generale.

La presenza di un componente non attesta
la completezza del suo comportamento.

## 3. Inventario della ricerca Git

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

## 4. Componenti diretti e condivisi

| File | Responsabilita da approfondire |
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

## 7. Migrazioni principali

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
request_profile_edit_lock_takeover
alla riga 1906 rilevata.

La definizione effettivamente installata
deve essere considerata autorevole
per il database locale.

## 8. Inventario dei test

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

Il contenuto dei dieci file non e'
ancora stato integralmente esaminato
nella RC02.

Non attribuire un numero di scenari
o un livello E4 sulla sola base
della presenza dei file.

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

## 10. Riutilizzo

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

## 11. Limiti

Inventario consolidato dalle evidenze
precedentemente acquisite nella RC02.

Nessuna nuova ispezione integrale
delle fonti durante il consolidamento.

Nessun nuovo collaudo eseguito.

Nessuna modifica tecnica introdotta.
