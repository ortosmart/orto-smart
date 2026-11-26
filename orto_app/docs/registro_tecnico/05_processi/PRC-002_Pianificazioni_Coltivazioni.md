# PRC-002 - Pianificazioni e coltivazioni

## Metadati

- Sessione: S046
- Provenienza: STEP 273-274 e checkpoint S045
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Macroblocchi: V1-10, V1-11
- Riconciliazioni: RC14, RC15

## 1. Separazione dei domini

La pianificazione rappresenta un'intenzione futura.

La coltivazione rappresenta una presenza effettiva.

Non confondere conferma della pianificazione
con esecuzione reale.

Non contabilizzare due volte una pianificazione
eseguita e la coltivazione da essa generata.

## 2. Pianificazioni stagionali

Entita principali:

- season_plans
- planned_plantings

Ciclo funzionale:

- draft
- confirmed
- executed
- cancelled

Bozze e pianificazioni confermate possono
essere modificate o annullate secondo i contratti.

Executed e cancelled sono stati terminali
del normale ciclo operativo.

L'esecuzione deve creare atomicamente
la coltivazione effettiva collegata.

RPC gia individuate:

- create_planned_planting
- update_planned_planting
- confirm_planned_planting
- cancel_planned_planting
- execute_planned_planting

Le operazioni di lettura e recupero
devono essere consolidate in RC14 e RC05.

## 3. Infrastruttura delle mutazioni

Componenti Flutter gia individuati:

- MutationOperationContract
- MutationOperationCoordinator
- MutationOperationJournal
- SeasonalPlanningMutationService
- SeasonalPlanningMutationTransport

Riutilizzare questi componenti secondo
i rispettivi contratti e responsabilita.

Non presumere che il journal sia gia integrato
in tutti gli altri domini.

## 4. Evidenze S045

Cinque mutazioni collaudate con Edge
e Supabase locale.

Sei ricevute COMPLETED rilevate.

Recupero verificato senza nuova mutazione.

Nessun residuo dei record temporanei.

Riferimento:

../06_collaudi/TST-S046-001_Baseline_Collaudi.md

## 5. Presentazione delle pianificazioni

Navigazione approvata:

Orto -> Stagioni -> Pianificazione.

Consultazione per aiuola e calendario.

Possibilita di iniziare una pianificazione
dal contesto della stagione o dell'aiuola.

La lista esaminata mostra:

- Data.
- Stato.
- Posizione.
- Lunghezza.

Informazioni e capacita da completare:

- Coltura e cultivar.
- Identificazione dell'aiuola.
- Data prevista di conclusione.
- Quantita e distanze.
- Raggruppamenti e filtri.
- Calendario.
- Rappresentazione spaziale.
- Integrazione delle valutazioni agronomiche.

Non considerare il ciclo delle mutazioni
equivalente al completamento della pianificazione.

## 6. Coltivazioni effettive

Entita principale:

- plantings

Copertura delle operazioni esaminate:

- Backend: 4/4.
- Repository: 4/4.
- UI: 4/4.

La creazione diretta di una coltivazione
deve rimanere possibile.

Non tutte le coltivazioni devono necessariamente
derivare da una pianificazione.

La raccolta non libera automaticamente
la superficie occupata.

La coltivazione rimane occupante fino
alla conclusione o rimozione prevista.

Conservare il collegamento storico
con la pianificazione originaria.

## 7. Presentazione delle coltivazioni

PlantingCard esaminata:

- Coltura.
- Data iniziale.
- Posizione.
- Lunghezza.
- Numero piante.
- Stato.
- Note.

Le transizioni esatte e le firme RPC
devono essere consolidate in RC15.

## 8. Occupazione spaziale e temporale

Utilizzare geometrie pertinenti alla data.

Non sommare occupazioni successive
come se fossero contemporanee.

Distinguere occupazione prevista ed effettiva.

Evitare il doppio conteggio
delle pianificazioni gia eseguite.

Riutilizzare i motori spaziali e temporali
del dominio V1-09.

## 9. Attivita residue

- Integrazione del Resolver.
- Valutazioni agronomiche.
- Verifiche spaziali e temporali.
- Calendario e rappresentazione delle aiuole.
- Presentazione completa delle informazioni.
- Concorrenza e casi limite.
- Collaudi integrati.
- Accettazione operativa.

Non duplicare le infrastrutture comuni.

## 10. Limiti

Le evidenze integrate disponibili riguardano
principalmente le pianificazioni in ambiente locale.

Operativita remota e accettazione reale: NV.

Le ore residue sono gestite separatamente
nella programmazione V1.
