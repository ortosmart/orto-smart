# ORTO SMART

### DOC-012

# Registro Storico dello Sviluppo

**Versione:** 2.9
**Stato:** Approvato

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 29/07/2026  
**Ultimo aggiornamento:** 16/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-012 |
| Titolo | Registro Storico dello Sviluppo |
| Versione | 2.9 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 29/07/2026 |
| Ultimo aggiornamento | 16/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data       | Descrizione                                                                                                                                                  |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1.0      | 29/07/2026 | Prima emissione del documento                                                                                                                                |
| 2.0      | 05/08/2026 | Revisione strutturale del documento, trasformazione del Registro Storico in cruscotto dell'evoluzione del progetto e uniformazione allo Standard Documentale |
| 2.1      | 08/08/2026 | Aggiornamento del Registro Storico con la Sessione S010 e consolidamento dell'evoluzione del sistema decisionale del Motore Agronomico                       |
| 2.2      | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S011 e introduzione della prima versione del FamilyNeedsEngine                                            |
| 2.3      | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S012 e integrazione del FamilyNeedsEngine nella RecommendationPipeline                                    |
| 2.4      | 10/08/2026 | Aggiornamento del Registro Storico con la Sessione S013 e predisposizione delle fondamenta del futuro SuccessionPlanningEngine                               |
| 2.5      | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S014 e prima implementazione del SuccessionPlanningEngine                                                      |
| 2.6      | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S015 e introduzione della prima infrastruttura delle finestre agronomiche                                                |
| 2.7      | 12/08/2026 | Aggiornamento del Registro Storico con la Sessione S016 e associazione delle finestre agronomiche a colture e varietà |
| 2.8      | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S017, completamento e congelamento della baseline Database V1 e consolidamento dei tempi complessivi di sviluppo e documentazione |
| 2.9      | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S018: supporto alle finestre agronomiche multiple, predisposizione dell'ambiente locale Supabase e riallineamento degli indicatori evolutivi |

---

# Indice

## 1. Scopo

## 2. Indicatori storici del progetto

## 3. Cronologia sintetica dello sviluppo

## 4. Milestone del progetto

## 5. Indicatori evolutivi

## 6. Regole di aggiornamento

## 7. Evoluzione futura

## 8. Considerazioni finali

---

# 1. Scopo

Il Registro Storico dello Sviluppo documenta l'evoluzione del progetto Orto Smart dal punto di vista storico e quantitativo.

Il documento ha lo scopo di mantenere una visione d'insieme dell'intero progetto, registrando nel tempo:

- la cronologia sintetica dello sviluppo;
- il tempo complessivamente dedicato al progetto;
- le principali milestone;
- l'evoluzione dell'architettura;
- la crescita della documentazione.

A differenza del DOC-005 – Quaderno di Sviluppo, che descrive in dettaglio le singole sessioni, il presente documento rappresenta una sintesi storica dell'intero progetto.

Il Registro Storico dello Sviluppo costituisce il riferimento ufficiale per il monitoraggio dell'evoluzione di Orto Smart.

# 2. Indicatori storici del progetto

Il presente capitolo riassume gli indicatori storici che descrivono lo stato evolutivo del progetto Orto Smart.

Gli indicatori riportati costituiscono una fotografia sintetica del progetto alla data dell'ultimo aggiornamento del presente documento e consentono di monitorarne la crescita nel tempo.

Le informazioni riportate nel presente capitolo vengono aggiornate al termine delle sessioni di sviluppo concluse, mantenendo la coerenza con il Quaderno di Sviluppo (DOC-005) e con il Workflow Operativo (DOC-009).

## 2.1 Stato attuale del progetto

Alla data dell'ultimo aggiornamento del presente documento, il progetto Orto Smart presenta i seguenti indicatori storici.

| Indicatore                          | Valore                                           |
| ----------------------------------- | ------------------------------------------------ |
| Sessioni completate                 | 18                                               |
| Tempo complessivo di sviluppo       | 70 h 07 min                                      |
| Tempo complessivo di documentazione | 22 h 53 min                                      |
| Tempo complessivo progetto          | 93 h 00 min                                      |
| Prima sessione                      | S001                                             |
| Ultima sessione                     | S018                                             |
| Stato della documentazione          | Aggiornata e consolidata fino alla Sessione S018 |

\* Valore riferito alle sole ore di sviluppo software consolidate. Il tempo di documentazione è riportato separatamente.

# 3. Cronologia sintetica dello sviluppo

La cronologia sintetica riporta, in ordine cronologico, le principali sessioni che hanno caratterizzato l'evoluzione del progetto Orto Smart.

Per ciascuna sessione vengono indicati l'evento principale e il tempo di sviluppo consolidato, consentendo di ricostruire rapidamente la crescita del progetto nel tempo.

| Sessione | Attività principale | Ore sessione | Totale progressivo |
|-----------|---------------------|-------------:|-------------------:|
| **S001** | Avvio del progetto Orto Smart | **6 h** | **6 h** |
| **S002** | Evoluzione dell'architettura e integrazione Supabase | **7 h** | **13 h** |
| **S003** | Realizzazione del FreeSpace Engine e del Suggestion Engine | **8 h** | **21 h** |
| **S004** | Sviluppo del Companion Engine e refactoring dell'architettura | **5 h** | **26 h** |
| **S005** | Introduzione del BedAnalysisService e integrazione dell'analisi agronomica | **4 h** | **30 h** |
| **S006** | Decision Engine, integrazione dell'analisi agronomica e completamento della documentazione di progetto | **4 h** | **34 h** |
| **S007** | Revisione e consolidamento della documentazione tecnica | **2 h 15 min** | **36 h 15 min** |
| **S008** | Censimento e consolidamento della documentazione residua | **4 h 16 min** | **40 h 31 min** |
| **S009** | Evoluzione dell'architettura del Motore Agronomico e introduzione della RecommendationPipeline | **5 h 22 min** | **45 h 53 min** |
| **S010** | Configurazione dei pesi del DecisionEngine mediante DecisionWeights | **4 h 54 min** | **50 h 47 min** |
| **S011** | Prima implementazione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari | **2 h 27 min** | **53 h 14 min** |
| **S012** | Integrazione del FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico delle raccomandazioni | **1 h 42 min** | **54 h 56 min** |
| **S013** | Introduzione dei fabbisogni quantitativi familiari e dei lotti pianificati come fondamenta del futuro SuccessionPlanningEngine | **2 h 07 min** | **57 h 03 min** |
| **S014** | Prima implementazione del SuccessionPlanningEngine per la generazione temporale validata dei lotti di coltivazione | **1 h 32 min** | **59 h 49 min** |
| **S015** | Prima implementazione delle finestre agronomiche mediante AgronomicWindow, AgronomicWindowValidator e AgronomicWindowEngine | **1 h 00 min** |    **61 h 48 min** |
| **S016** | Associazione delle finestre agronomiche a colture e varietà e introduzione della valutazione stagionale dei lotti pianificati | **1 h 06 min** | **63 h 50 min** |
| **S017** | Progettazione completa e congelamento della baseline Database V1 | **20 h 24 min** | **89 h 04 min** |
| **S018** | Supporto alle finestre agronomiche multiple e predisposizione dell'ambiente locale Supabase | **3 h 56 min** | **93 h 00 min** |

---

## 3.1 Lettura della cronologia

La cronologia sintetica riportata nel presente capitolo costituisce uno strumento di consultazione rapida dell'evoluzione del progetto.

Essa consente di:

- ricostruire le principali tappe dello sviluppo;
- monitorare la crescita del progetto nel tempo;
- valutare l'impegno complessivamente dedicato allo sviluppo;
- mantenere uno storico sintetico delle attività svolte.

# 4. Milestone del progetto

Le milestone rappresentano i principali traguardi che hanno segnato l'evoluzione del progetto Orto Smart.

A differenza della cronologia delle sessioni, che documenta lo svolgimento delle attività nel tempo, le milestone evidenziano i cambiamenti che hanno avuto un impatto significativo sull'architettura, sulle funzionalità, sull'organizzazione o sulla documentazione del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la crescita complessiva di Orto Smart.

| Sessione | Milestone | Descrizione |
|-----------|-----------|-------------|
| **S001** | Avvio del progetto | Definizione degli obiettivi e creazione della struttura iniziale dell'applicazione. |
| **S002** | Integrazione Supabase | Collegamento dell'app al database e definizione della prima architettura dati. |
| **S003** | Primo Motore Agronomico | Completamento del FreeSpace Engine e del Suggestion Engine. |
| **S004** | Companion Engine | Introduzione del motore delle consociazioni e refactoring dell'architettura agronomica. |
| **S005** | BedAnalysisService | Centralizzazione dell'analisi agronomica tramite un servizio dedicato. |
| **S006** | Decision Engine | Introduzione del Decision Engine, integrazione dell'analisi agronomica nell'interfaccia utente e consolidamento del Workflow Operativo e della documentazione tecnica. |
| **S007** | Revisione e consolidamento della documentazione tecnica | Revisione organica dei principali documenti del progetto, definizione del workflow documentale e consolidamento del sistema documentale ufficiale di Orto Smart. |
| **S008** | Consolidamento del sistema documentale del progetto | Completata la revisione della documentazione ufficiale del progetto, definito il ruolo di ciascun documento e consolidato il sistema documentale di Orto Smart. |
| **S009** | RecommendationPipeline | Completata la nuova architettura del processo di raccomandazione mediante l'introduzione della RecommendationPipeline come componente di orchestrazione del Motore Agronomico. |
| **S010** | DecisionWeights | Introduzione della configurazione separata e validata dei pesi del DecisionEngine, rendendo il sistema decisionale configurabile e predisposto all'integrazione futura di ulteriori criteri agronomici. |
| **S011** | FamilyNeedsEngine | Prima implementazione del motore dedicato alla valutazione delle priorità e dei fabbisogni familiari, mantenuto separato dalla futura pianificazione quantitativa e temporale delle coltivazioni. |
| **S012** | Integrazione FamilyNeedsEngine nella RecommendationPipeline | Integrazione delle esigenze familiari nel processo di raccomandazione mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico, mantenendo invariato il punteggio agronomico del DecisionEngine. |
| **S013** | Fondamenta del SuccessionPlanningEngine | Introduzione di `FamilyConsumptionNeed`, `FamilyConsumptionNeedValidator`, `PlannedPlantingBatch` e `PlannedPlantingBatchValidator` come fondamenta dati e di validazione per la futura pianificazione quantitativa e temporale delle coltivazioni. |
| **S014** | Prima versione del SuccessionPlanningEngine                | Implementazione della prima versione deterministica del `SuccessionPlanningEngine`, capace di trasformare un `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, rifiutando le conversioni tra fabbisogno familiare e quantità di impianto non supportate dai dati agronomici disponibili. |
| **S015** | Prima infrastruttura delle finestre agronomiche             | Introduzione di `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine` per rappresentare finestre agronomiche annuali e verificare separatamente la compatibilità temporale dei lotti pianificati in base al metodo di avvio e alla data. |
| **S016** | Stagionalità di colture e varietà | Introduzione di `CropAgronomicWindowRule`, `AgronomicWindowResolver`, `AgronomicWindowEvaluation` e `AgronomicWindowService` per associare le finestre agronomiche a colture e varietà, applicare il fallback varietà → coltura e distinguere `compatible`, `incompatible` e `unknown`. |
| **S017** | Baseline Database V1 | Completamento e congelamento della progettazione logica e architetturale del Database V1: 52 entità di dominio, struttura tecnica `profile_edit_locks`, ownership, modello di accesso familiare single-writer, temporalità, storicizzazione, invarianti, sicurezza, convenzioni dei dati e strategia di futura implementazione SQL/Supabase. |
| **S018** | Finestre agronomiche multiple e ambiente Supabase locale | Estensione della valutazione agronomica al supporto di più finestre applicabili, con fallback tra livelli di specificità, e predisposizione dell'ambiente locale WSL 2, Docker Desktop e Supabase CLI per l'implementazione incrementale della baseline Database V1 mediante migration versionate. |

---

## 4.1 Significato delle milestone

Le milestone identificano gli eventi che hanno segnato un'evoluzione significativa del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la storia tecnica di Orto Smart e rappresentano i momenti in cui sono state introdotte nuove funzionalità, nuovi componenti architetturali o importanti cambiamenti organizzativi.

# 5. Indicatori evolutivi

Il presente capitolo raccoglie gli indicatori che consentono di monitorare l'evoluzione del progetto nel tempo.

A differenza degli indicatori storici riportati nel capitolo 2, che rappresentano una fotografia dello stato attuale del progetto, gli indicatori evolutivi consentono di osservare la crescita di Orto Smart sotto il profilo organizzativo, tecnico e documentale.

Essi vengono aggiornati progressivamente al termine delle sessioni di sviluppo e costituiscono uno strumento di monitoraggio dell'evoluzione complessiva del progetto.

| Indicatore                    | Valore attuale |
| ----------------------------- | -------------- |
| Sessioni completate           | 18             |
| Ore di sviluppo consolidate   | 70 h 07 min    |
| Ore di documentazione         | 22 h 53 min    |
| Totale ore progetto           | 93 h 00 min    |
| Motori agronomici completati  | 5              |
| Documenti ufficiali approvati | 10             |
| Ultima sessione completata    | S018           |
| Sessione in corso             | Nessuna        |

Gli indicatori evolutivi vengono aggiornati al termine delle sessioni di sviluppo concluse e consentono di monitorare l'evoluzione del progetto sotto il profilo tecnico, organizzativo e documentale.

---

# 6. Regole di aggiornamento

Il Registro Storico dello Sviluppo deve essere aggiornato al termine di ogni sessione di sviluppo.

Per ogni nuova sessione di sviluppo dovranno essere aggiornati, ove necessario, i seguenti elementi:

- gli indicatori storici del progetto;
- la cronologia sintetica dello sviluppo;
- gli indicatori evolutivi;
- le milestone, qualora la sessione introduca un cambiamento significativo;
- il tempo di sviluppo consolidato;
- le informazioni di sintesi del progetto.

Prima della chiusura della sessione dovrà inoltre essere verificata la coerenza tra il Registro Storico dello Sviluppo, il Quaderno di Sviluppo (DOC-005), il Workflow Operativo (DOC-009) e la restante documentazione del progetto.

## 6.1 Registrazione delle ore

Le ore di lavoro devono essere registrate alla chiusura di ogni sessione, distinguendo, ove possibile, il tempo dedicato allo sviluppo software da quello dedicato alla documentazione.

La registrazione tempestiva delle ore consente di mantenere uno storico affidabile dell'impegno complessivamente dedicato al progetto ed evita ricostruzioni successive.

A partire dalla Sessione S007, il tempo dedicato al progetto potrà essere distinto tra:

| Attività | Ore |
|----------|----:|
| Sviluppo software | - |
| Documentazione | - |
| Totale sessione | - |

Questa suddivisione permetterà un monitoraggio più accurato dell'evoluzione del progetto.

# 7. Evoluzione futura

Il Registro Storico dello Sviluppo è un documento destinato ad evolversi insieme al progetto Orto Smart.

Con la crescita del software potranno essere introdotti nuovi indicatori e nuovi strumenti di analisi, mantenendo il ruolo del documento come riferimento storico dell'evoluzione tecnica, organizzativa e documentale del progetto.

Tra le possibili estensioni future rientrano, a titolo esemplificativo:

- andamento delle ore di sviluppo e documentazione;
- numero di commit per sessione;
- numero di test automatici;
- principali release del software;
- crescita della documentazione;
- evoluzione dei motori agronomici;
- decisioni architetturali introdotte;
- statistiche sull'evoluzione complessiva del progetto.

L'obiettivo è mantenere il presente documento come il principale riferimento storico per monitorare la crescita di Orto Smart nel lungo periodo.

---

# 8. Considerazioni finali

Il Registro Storico dello Sviluppo rappresenta il riferimento ufficiale per la ricostruzione dell'evoluzione del progetto Orto Smart.

Il documento raccoglie gli indicatori storici, le principali milestone e gli elementi che consentono di monitorare nel tempo la crescita del progetto sotto il profilo tecnico, organizzativo e documentale.

Insieme al Quaderno di Sviluppo (DOC-005), al Workflow Operativo (DOC-009) e alle Decisioni Architetturali (DOC-011), il presente documento contribuisce a garantire la tracciabilità e la memoria storica del progetto.

Il Registro Storico dello Sviluppo dovrà essere aggiornato con continuità, mantenendo coerenza con la restante documentazione e accompagnando l'evoluzione di Orto Smart durante tutto il suo ciclo di vita.