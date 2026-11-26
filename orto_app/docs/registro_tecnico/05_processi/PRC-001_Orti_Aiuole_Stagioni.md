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
