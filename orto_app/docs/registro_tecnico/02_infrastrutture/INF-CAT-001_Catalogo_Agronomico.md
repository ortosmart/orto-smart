# INF-CAT-001 - Catalogo Agronomico

## Metadati

- Proprietario: V1-08
- Riconciliazioni: RC10, RC11, RC12
- Sessione: S046
- Provenienza: STEP 273-274
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Stato: infrastruttura disponibile, integrazioni incomplete

## 1. Responsabilita

Gestire identita agronomiche canoniche,
tassonomia botanica, colture, cultivar,
registri tecnici e conoscenza agronomica approvata.

Separare i dati candidati provenienti dalle fonti
esterne dai dati ufficialmente approvati.

## 2. Consistenza acquisita

| Elemento | Quantita |
|---|---:|
| Tabelle del Catalogo | 26 |
| RPC editoriali rilevate, incluso Resolver | 26 |
| Registri tecnici backend | 7/7 |
| RPC dei registri | 21 |
| Registri con modello e repository Flutter | 6/7 |
| Registri con pagina Flutter | 3/7 |
| Registri raggiungibili dalla navigazione | 1/7 |

I conteggi devono essere consolidati
nelle riconciliazioni specifiche.

Non sommare automaticamente gruppi di RPC
senza verificare eventuali sovrapposizioni.

## 3. Autorita

Catalog Authority distinta dalla Profile Write Authority.

La gestione delle identita globali e della conoscenza
approvata non deve essere confusa con la gestione
operativa del singolo orto.

Nessuna fonte esterna puo sovrascrivere
automaticamente il Catalogo approvato.

## 4. Processo editoriale

Fonte
-> Documento e revisione
-> Acquisizione
-> Osservazione
-> Normalizzazione
-> Candidato
-> Evidenza
-> Presentazione per revisione
-> Revisione
-> Pubblicazione
-> Resolver

Il processo rappresenta l'architettura approvata.
La completezza delle singole integrazioni
deve essere verificata separatamente.

## 5. Resolver

RPC:

resolve_agronomic_knowledge

Componente Flutter:

AgronomicKnowledgeRepository

Cinque esiti tipizzati rilevati.

Le denominazioni e i contratti esatti
degli esiti saranno consolidati in RC12.

Il Resolver risulta disponibile ma non ancora
integrato nei motori agronomici e nelle pagine
esaminate durante la ricognizione.

## 6. Registri Flutter

Componenti individuati per:

- HarvestPurpose.
- MeasurementUnit.
- AgronomicParameter.

HarvestPurpose raggiungibile dalla navigazione.

Le pagine MeasurementUnit e AgronomicParameter
non risultavano raggiungibili nella ricognizione.

Non ricreare questi componenti:
completare le integrazioni necessarie.

## 7. Popolamento

Nell'insieme delle 18 tabelle locali
esaminate per il popolamento:

- 17 risultavano vuote.
- 1 conteneva la Catalog Authority.

I due seed esaminati risultavano vuoti.

Stato dei dati remoti: NV.

Non introdurre dati fittizi permanenti.

## 8. Riutilizzo

Domini utilizzatori previsti:

- V1-09 Motori agronomici.
- V1-10 Pianificazioni.
- V1-11 Coltivazioni.
- V1-12 Raccolti.
- V1-14 Irrigazione.
- V1-19 Gestione economica.
- V1-21 Fertilizzazioni e trattamenti.

Il riutilizzo dei registri canonici non implica
che tutte le integrazioni siano gia implementate.

## 9. Vincoli permanenti

- Identita canoniche stabili.
- Fonti tracciabili.
- Revisioni conservate.
- Dati candidati separati.
- Pubblicazione controllata.
- Nessuna sovrascrittura automatica.
- Conservazione della storia.
- Nessun valore agronomico inventato.

## 10. Attivita residue

- Consolidare inventario e contratti.
- Completare integrazioni Flutter.
- Completare navigazione dei registri.
- Integrare Resolver nei motori e nei domini.
- Verificare popolamento e fonti.
- Collaudare i percorsi editoriali e operativi.
- Verificare ambiente remoto.

Le ore residue sono gestite nella programmazione V1.
