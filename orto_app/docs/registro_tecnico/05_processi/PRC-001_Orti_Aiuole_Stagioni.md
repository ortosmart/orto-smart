# PRC-001 - Orti, aiuole e stagioni

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 273-274
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Macroblocchi: V1-05, V1-06, V1-07
- Riconciliazioni pertinenti: RC08, RC09

## 1. Orti - V1-05

Copertura delle operazioni esaminate:

- Backend: 3/3.
- Repository: 2/3.
- UI: 2/3.

RPC autoritative gia individuate:

- create_garden
- update_garden

L'aggiornamento dell'orto dispone del backend,
ma richiede il completamento delle integrazioni
repository e interfaccia.

Non ricreare la RPC senza una necessita dimostrata.

## 2. Aiuole - V1-06

Copertura delle operazioni esaminate:

- Backend: 7/7.
- Repository: 7/7.
- UI: 7/7.

Entita principali:

- beds
- bed_geometries

RPC autoritative gia individuate:

- create_bed
- update_bed
- set_bed_active
- change_bed_geometry

L'elenco non costituisce inventario esaustivo.

Responsabilita del dominio:

- Identita dell'aiuola.
- Appartenenza all'orto.
- Stato attivo.
- Geometria corrente.
- Storico delle geometrie.
- Individuazione della geometria pertinente alla data.
- Superficie coltivabile.

Riutilizzare le geometrie nei domini:

- Motori agronomici.
- Pianificazione.
- Coltivazioni.
- Irrigazione.
- Produttivita.
- Dashboard.

Non creare una seconda fonte autoritativa
delle dimensioni dell'aiuola.

Non modificare automaticamente coltivazioni
incompatibili con una variazione geometrica.

### 2.1. Vincoli, indici e trigger installati — RC08, S048

Il catalogo PostgreSQL locale è stato interrogato in una transazione
di sola lettura, terminata con ROLLBACK. La baseline installata
comprende 48 migrazioni, fino alla 20261125151100.

| Tabella | Vincoli validati | Indici | Trigger abilitati |
|---|---:|---:|---:|
| bed_geometries | 8 | 2 | 1 |
| bed_geometry_corrections | 8 | 2 | 2 |
| Totale | 16 | 4 | 3 |

Su bed_geometries, il vincolo di esclusione GiST differibile evita la
sovrapposizione di intervalli [valid_from, valid_to) per la stessa aiuola.
Il trigger BEFORE UPDATE richiama la funzione comune di versionamento.

Su bed_geometry_corrections, il catalogo conferma l'unicità per aiuola
e versione risultante e il vincolo bed_version_after = bed_version_before + 1.
Due trigger proteggono lo storico da UPDATE, DELETE e TRUNCATE.

La verifica attesta le definizioni installate. Il comportamento a runtime
e lo stato remoto restano NV.

### 2.2. Conclusione tecnica RC08 — S048

Ricognizione tecnica conclusa e approvata. La verifica locale ha
confermato 16 vincoli validati, 4 indici e 3 trigger sulle geometrie
e sullo storico delle correzioni. La riesecuzione Flutter mirata
ha superato 399/399 test, documentati in
[TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Il livello E4 riguarda i comportamenti specifici collaudati.

Il collaudo integrato con PostgreSQL e lo stato remoto restano NV.
Nel decodificatore Flutter di change_bed_geometry restano aperti
gli esiti blocked_by_plantings e blocked_by_confirmed_plans.

Riconciliazioni tecniche concluse: 8/18. Riconciliazioni quantitative
concluse: 0/18. Punto di ripresa: RC09 — Stagioni e temporalità.

## 3. Configurazione reale prevista

- Comune: Pasiano di Pordenone.
- Numero aiuole: 15.
- Dimensioni standard: 90 x 700 cm.
- Larghezza passaggi: 50 cm.
- Disposizione: aiuole parallele.

Superficie teorica coltivabile: 94,5 m2.

Superficie teorica dei 14 passaggi: 49 m2.

Superficie complessiva teorica: 143,5 m2,
esclusi passaggi perimetrali e altre aree.

Questi valori descrivono il contesto previsto.
Non attestano il popolamento del database.

## 4. Stagioni - V1-07

Copertura delle operazioni esaminate:

- Backend: 5/5.
- Repository: 5/5.
- UI: 2/5.

RPC autoritative gia individuate:

- create_season
- update_season
- activate_season

Integrazioni UI mancanti:

- Creazione.
- Modifica.
- Attivazione.

Distinguere stagione attiva e stagione consultata.

Deve essere possibile consultare stagioni diverse
senza modificare quella attiva.

L'attivazione deve rispettare il vincolo
di unicita della stagione attiva per orto.

Non concludere automaticamente le coltivazioni
al cambio della stagione.

### 4.1. Struttura installata e verifiche residue — RC09, S048

Il catalogo PostgreSQL locale, con 48 migrazioni fino alla
20261125151100, è stato interrogato in una transazione di sola lettura
terminata con ROLLBACK. Su public.seasons risultano 10 vincoli validati,
4 indici validi e 1 trigger abilitato in modalità ordinaria (O).

Il vincolo sulle date ammette una fine assente o uguale all'inizio.
La coppia (garden_id, year) è univoca. L'indice univoco parziale
seasons_one_active_per_garden_idx consente al massimo una stagione
attiva per orto. Il trigger BEFORE UPDATE richiama la funzione comune
di aggiornamento dei metadati e incremento di row_version.

La RPC activate_season verifica la versione attesa e disattiva
l'eventuale stagione precedente prima di attivare quella scelta,
nella stessa chiamata. In Flutter la stagione consultata in
Pianificazione è quella selezionata. La creazione diretta di una
coltivazione consulta invece la stagione attiva.

L'attivazione concorrente e gli effetti del restringimento delle date
sulle pianificazioni e coltivazioni già collegate restano NV a runtime.

### 4.2. Conclusione tecnica RC09 — S048

Ricognizione tecnica conclusa e approvata. La verifica del catalogo
PostgreSQL locale ha confermato 10 vincoli validati, 4 indici validi
e 1 trigger abilitato su seasons. Le evidenze Flutter comprendono
33/33 test di SeasonRepository e 7/7 test della schermata Stagioni,
documentati in [TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Il livello E4 riguarda i comportamenti specifici collaudati.

Creazione, modifica e attivazione restano da integrare nella UI.
L'attivazione concorrente e gli effetti del restringimento delle date
sui record collegati restano NV a runtime.

Riconciliazioni tecniche concluse: 9/18. Riconciliazioni quantitative
concluse: 0/18. Punto di ripresa: RC10 — Catalogo e identità canoniche.

## 5. Riutilizzo futuro

RIUTILIZZARE:

- Identita e relazioni di dominio.
- Repository esistenti.
- RPC autoritative.
- Storico delle geometrie.
- Meccanismi di attivazione.

INTEGRARE:

- Aggiornamento dell'orto.
- Gestione completa delle stagioni tramite UI.
- Visualizzazione geometrica condivisa.
- Utilizzo delle geometrie storiche nei domini.

VERIFICARE:

- Contratti esatti delle operazioni.
- Compatibilita delle modifiche geometriche.
- Concorrenza.
- Validita temporale.
- Operativita sui dispositivi previsti.

## 6. Limiti

I conteggi riguardano operazioni selezionate.

Non equivalgono alla completa accettazione
operativa dei tre macroblocchi.

I dettagli tecnici saranno consolidati
nelle rispettive schede di riconciliazione.
