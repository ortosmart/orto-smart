# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 1.7
**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026
**Ultimo aggiornamento:** 03/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 1.7 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 03/09/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione della Roadmap di Sviluppo |
| 0.2 | 27/07/2026 | Aggiornamento della roadmap dopo la Sessione S004 |
| 0.3 | 01/08/2026 | Revisione della struttura documentale e aggiornamento della roadmap |
| 1.0      | 01/08/2026 | Revisione completa e approvazione della Roadmap di Sviluppo            |
| 1.1      | 08/08/2026 | Aggiornamento del Motore Agronomico e pianificazione delle evoluzioni successive |
| 1.2      | 16/08/2026 | Aggiornamento della roadmap dopo la Sessione S017: completamento e congelamento della progettazione Database V1, pianificazione dell'implementazione incrementale in Supabase e riallineamento delle priorità di sviluppo |
| 1.3 | 16/08/2026 | Aggiornamento dopo la Sessione S018: completamento dei prerequisiti locali Supabase, consolidamento delle finestre agronomiche multiple e definizione dello STEP 35.3 come punto di avvio della baseline SQL Database V1 |
| 1.4 | 18/08/2026 | Aggiornamento dopo la Sessione S019: prima migration Database V1, implementazione e verifica locale delle Fondazioni, prima matrice di 13 policy RLS e definizione delle RPC sicure e atomiche come prossimo incremento tecnico |
| 1.5 | 28/08/2026 | Aggiornamento dopo la Sessione S023: completamento del protocollo `profile_edit_locks`, Write Path autoritativi di `gardens` e `seasons`, integrazione Flutter della Profile Write Authority e definizione di `beds` e `bed_geometries` come prossimo blocco tecnico |
| 1.6 | 01/09/2026 | Aggiornamento dopo la Sessione S024: completamento del Write Path autoritativo di `beds`, implementazione della geometria storicizzata, integrazione Flutter della creazione dell’aiuola e rinvio della scelta del successivo blocco tecnico |
| 1.7 | 03/09/2026 | Manutenzione straordinaria della Roadmap: normalizzazione del nome dell’autore nei metadati del documento |

---

# Indice

## 1. Scopo

## 2. Stato del progetto

## 3. Roadmap generale
3.1 Architettura  
3.2 Gestione orto  
3.3 Motore Agronomico  
3.4 Irrigazione  
3.5 Dashboard  
3.6 Attività  
3.7 Statistiche  
3.8 Versioni future

## 4. Prossime attività

## 5. Cronologia delle revisioni

## 6. Considerazioni finali

---

# 1. Scopo

La **Roadmap di Sviluppo** descrive l'evoluzione prevista del progetto **Orto Smart**.

Il documento rappresenta il riferimento ufficiale per la pianificazione delle attività di sviluppo e viene aggiornato al termine delle principali sessioni di lavoro.

Le funzionalità sono organizzate in macro-aree e classificate in base al loro stato di avanzamento.

---

# 2. Stato del progetto

| Stato | Significato |
|--------|-------------|
| ✅ Completato | Funzionalità implementata e verificata |
| 🚧 In sviluppo | Funzionalità attualmente in lavorazione |
| 📋 Pianificato | Funzionalità prevista nelle prossime versioni |
| 💡 Idea | Possibile sviluppo futuro |

---

# 3. Roadmap generale

## 3.1 Architettura

| Funzionalità | Stato |
|--------------|:-----:|
| Struttura Flutter | ✅ Completato |
| Supabase | ✅ Completato |
| Repository Pattern | ✅ Completato |
| Modelli | ✅ Completato |
| Progettazione Database V1 | ✅ Completato |
| Implementazione Database V1 in Supabase | 🚧 In sviluppo |

---

## 3.2 Gestione orto

| Funzionalità | Stato |
|--------------|:-----:|
| Elenco aiuole | ✅ Completato |
| Visualizzazione aiuola | ✅ Completato |
| Ordinamento aiuole | ✅ Completato |
| Inserimento colture | ✅ Completato |
| Modifica colture | ✅ Completato |
| Eliminazione colture | 📋 Pianificato |

---

## 3.3 Motore Agronomico

| Funzionalità                       |       Stato       | Note                                                                                                                                                                                       |
| ---------------------------------- | :---------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| FreeSpaceEngine                    |   ✅ Completato    | Calcolo automatico degli spazi liberi nelle aiuole.                                                                                                                                        |
| SuggestionEngine                   |   ✅ Completato    | Generazione dei candidati iniziali sulla base degli spazi disponibili.                                                                                                                     |
| Companion Engine                   |   ✅ Completato    | Prima versione del motore delle consociazioni.                                                                                                                                             |
| BedAnalysisService                 |   ✅ Completato    | Servizio di coordinamento delle analisi agronomiche delle aiuole.                                                                                                                          |
| Bed Companion Analyzer             |   ✅ Completato    | Analisi automatica delle compatibilità tra le colture presenti in un'aiuola.                                                                                                               |
| RecommendationPipeline             |   ✅ Completato    | Orchestrazione del processo di raccomandazione e coordinamento dei componenti specializzati.                                                                                               |
| Decision Engine                    |   ✅ Completato    | Interpretazione delle valutazioni agronomiche e calcolo del punteggio finale delle raccomandazioni.                                                                                        |
| DecisionWeights                    |   ✅ Completato    | Configurazione e validazione dei pesi applicati ai criteri spazio, rotazione e consociazione.                                                                                              |
| Motore delle Rotazioni             |   ✅ Completato    | Prima versione operativa integrata nella RecommendationPipeline.                                                                                                                           |
| Sistema di Punteggio Agronomico    |   ✅ Completato    | Prima versione operativa basata su spazio, rotazione e consociazione con pesi configurabili.                                                                                               |
| FamilyNeedsEngine                  |    ✅ Integrato    | Prima versione completata nella S011 e integrata nella RecommendationPipeline nella S012 mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| FamilyConsumptionNeed              |   ✅ Completato    | Modello quantitativo introdotto nella S013 per rappresentare quantità, unità e periodicità del fabbisogno familiare.                                                                       |
| FamilyConsumptionNeedValidator     |   ✅ Completato    | Validazione dei fabbisogni quantitativi familiari introdotta nella S013.                                                                                                                   |
| PlannedPlantingBatch               |   ✅ Completato    | Modello introdotto nella S013 per rappresentare un lotto di coltivazione pianificato nel tempo.                                                                                            |
| PlannedPlantingBatchValidator      |   ✅ Completato    | Validazione dei dati necessari alla rappresentazione dei lotti di coltivazione pianificati.                                                                                                |
| SuccessionPlanningEngine           | ✅ V1 completata | Prima versione deterministica implementata nella S014: trasforma `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, senza introdurre conversioni agronomiche non supportate. |
| AgronomicWindow                    | ✅ Completato    | Modello annuale introdotto nella S015 per rappresentare finestre agronomiche associate a uno specifico metodo di avvio, con supporto degli intervalli che attraversano il cambio dell'anno. |
| AgronomicWindowValidator           | ✅ Completato    | Validazione strutturale delle finestre agronomiche introdotta nella S015, comprese le combinazioni mese/giorno e il supporto del 29 febbraio. |
| AgronomicWindowEngine              | ✅ V1 completata | Prima versione implementata nella S015 per verificare l'appartenenza temporale alle finestre e la compatibilità dei `PlannedPlantingBatch` in base a metodo di avvio e data. |
| Stagionalità di colture e varietà | ✅ V1 completata | Obiettivo S016 completato: le finestre agronomiche sono ora associabili a colture e varietà e i lotti pianificati possono essere valutati distinguendo `compatible`, `incompatible` e `unknown`. |
| CropAgronomicWindowRule | ✅ Completato | Modello introdotto nella S016 per associare una `AgronomicWindow` a una coltura e, opzionalmente, a una specifica varietà, privilegiando il dato generale della coltura e gli override varietali solo quando necessari. |
| AgronomicWindowResolver | ✅ V1 completata | Resolver introdotto nella S016 per selezionare la finestra applicabile secondo il fallback varietà specifica → coltura generale → nessuna regola. |
| AgronomicWindowEvaluation | ✅ Completato | Risultato strutturato introdotto nella S016 per distinguere gli stati `compatible`, `incompatible` e `unknown`, evitando di interpretare l'assenza di dati come incompatibilità. |
| AgronomicWindowService | ✅ V1 completata | Servizio introdotto nella S016 per coordinare `AgronomicWindowResolver` e `AgronomicWindowEngine` nella valutazione stagionale dei `PlannedPlantingBatch`. |
| Progettazione della persistenza delle regole agronomiche | ✅ Completato | Obiettivo iniziale S017 completato ed esteso alla progettazione dell'intero Database V1. Le regole saranno persistite mediante `agronomic_window_rules`; `AgronomicWindow` rimane un risultato calcolato e non viene introdotta una tabella persistente `agronomic_windows`. L'implementazione SQL/Supabase resta da eseguire incrementalmente. |
| 1.3 | 16/08/2026 | Aggiornamento dopo la Sessione S018: completamento dei prerequisiti locali Supabase, consolidamento delle finestre agronomiche multiple e definizione dello STEP 35.3 come punto di avvio della baseline SQL Database V1 |

---

## 3.4 Irrigazione

| Funzionalità | Stato |
|--------------|:-----:|
| Gestione manuale | 🚧 In sviluppo |
| Storico irrigazioni | 📋 Pianificato |
| Zone irrigazione | 📋 Pianificato |
| Raspberry Pi | 📋 Pianificato |
| ESP32 | 📋 Pianificato |
| Sensori del terreno | 📋 Pianificato |
| Irrigazione automatica | 📋 Pianificato |

---

## 3.5 Dashboard

| Funzionalità | Stato |
|--------------|:-----:|
| Dashboard iniziale | 🚧 In sviluppo |
| Meteo | 📋 Pianificato |
| Attività giornaliere | 📋 Pianificato |
| Stato dell'orto | 📋 Pianificato |
| Avvisi | 📋 Pianificato |
| Indicatori | 📋 Pianificato |

---

## 3.6 Attività

| Funzionalità | Stato |
|--------------|:-----:|
| Diario attività | 📋 Pianificato |
| Piano di lavoro | 📋 Pianificato |
| Timer "Inizia lavoro" | 📋 Pianificato |
| Storico lavorazioni | 📋 Pianificato |
| Tempi di lavoro | 📋 Pianificato |

---

## 3.7 Statistiche

| Funzionalità | Stato |
|--------------|:-----:|
| Produzione | 📋 Pianificato |
| Costi | 📋 Pianificato |
| Risparmio economico | 📋 Pianificato |
| Tempo dedicato | 📋 Pianificato |
| Grafici | 📋 Pianificato |

---

## 3.8 Versioni future

### Versione 0.x

Completamento delle funzionalità fondamentali dell'applicazione.

### Versione 1.0

Prima versione stabile destinata all'utilizzo quotidiano.

### Versione 2.0

Consolidamento del Motore Agronomico e introduzione delle principali funzionalità avanzate.

### Versione 3.0

Sistema completo di irrigazione intelligente e integrazione hardware.

### Versione 4.0

Assistente intelligente dedicato alla gestione completa dell'orto.

---

# 4. Prossime attività

Le attività riportate in questa sezione rappresentano le principali direttrici di sviluppo previste per le prossime versioni di Orto Smart.

L'ordine di realizzazione potrà variare in funzione delle esigenze del progetto e delle decisioni architetturali adottate durante lo sviluppo.

## Stato dopo la Sessione S024

La Sessione S024 ha proseguito il percorso incrementale di implementazione fisica del Database V1 iniziato nella S019.

Sono stati completati:

- primo blocco Fondazioni della baseline Database V1;
- schema `private`, helper autorizzativi, trigger metadata e prima matrice RLS;
- protocollo server-side completo di `profile_edit_locks`;
- Profile Write Authority server-side e integrazione Flutter fail-closed;
- Write Path autoritativo di `gardens`;
- Write Path autoritativo di `seasons`;
- implementazione di `beds`, `bed_geometries` e `bed_geometry_corrections`;
- Write Path autoritativo di `beds`;
- RPC `create_bed`, `update_bed`, `set_bed_active`, `change_bed_geometry` e `correct_bed_geometry`;
- separazione tra identità stabile dell’aiuola e geometria valida nel tempo;
- protezione degli intervalli geometrici dalla sovrapposizione;
- distinzione tra cambio ordinario della geometria e correzione storica tracciata;
- concorrenza ottimistica mediante `row_version`;
- integrazione Flutter dei modelli `Bed` e `BedGeometry`;
- estensione di `BedRepository`;
- introduzione di `ProfileContextScope` e `CreateBedPage`;
- integrazione della creazione autoritativa dell’aiuola nella sezione Orto;
- configurazione Supabase parametrizzabile mediante `--dart-define`;
- allineamento delle migration locali e remote fino a `20260830140235`;
- verifica finale mediante `flutter analyze` e **781/781 test superati**;
- verifica manuale locale positiva della creazione dell’aiuola attraverso UI e Write Path.

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**. Le Fondazioni e i Write Path autoritativi di `gardens`, `seasons` e `beds` sono implementati, mentre le restanti entità devono essere introdotte progressivamente per gruppi coerenti di strutture e dipendenze.

## Prossimo blocco tecnico

Il successivo blocco tecnico non è ancora stato scelto.

La selezione dovrà avvenire dopo il consolidamento documentale della Sessione S024, verificando:

- dipendenze effettive della baseline Database V1;
- priorità funzionali dell’applicazione;
- stato del Repository Layer e dell’interfaccia esistente;
- sicurezza e Write Path necessari;
- perimetro verificabile della sessione successiva;
- test positivi, negativi e concorrenti richiesti.

`public.plantings` è prevista nella baseline Database V1 ma non è ancora implementata mediante migration. La sua assenza produce attualmente `PGRST205` nella sezione colture del dettaglio aiuola.

Prima di scegliere `plantings` come incremento successivo dovranno essere verificati il relativo contratto V1, le relazioni con `beds`, `bed_geometries`, colture, varietà e stagioni e le dipendenze della UI esistente.

Restano inoltre aperte le interfacce per:

- modifica dei dati dell’aiuola;
- attivazione e disattivazione;
- cambio della geometria;
- correzione della geometria.

Le corrispondenti RPC e operazioni Repository sono già implementate e testate.

Le operazioni amministrative protette su `profile_memberships` rimangono un blocco successivo distinto.

## Priorità attuali

- scelta e approvazione del successivo blocco tecnico;
- prosecuzione incrementale della baseline Database V1 per gruppi coerenti di strutture e dipendenze;
- estensione progressiva dei Write Path autoritativi alle ulteriori entità di Categoria A;
- valutazione del contratto V1 e delle dipendenze di `plantings`;
- completamento progressivo delle interfacce di scrittura delle aiuole;
- riallineamento progressivo del Repository Layer e del dominio applicativo alla nuova persistenza;
- consolidamento e ampliamento del Motore Agronomico sulla base della nuova architettura dati;
- evoluzione della gestione dell’irrigazione;
- sviluppo del modulo Attività e Piano di Lavoro;
- ampliamento della Dashboard con informazioni agronomiche e meteorologiche.

La pianificazione dettagliata delle singole sessioni di sviluppo viene documentata nel **DOC-005 – Quaderno di Sviluppo**, mentre il presente documento mantiene una visione strategica dell'evoluzione del progetto.

---

# 5. Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione della Roadmap di Sviluppo |
| 0.2 | 27/07/2026 | Aggiornamento della roadmap dopo la Sessione S004 |
| 0.3 | 01/08/2026 | Revisione della struttura documentale e aggiornamento della roadmap |
| 1.0 | 01/08/2026 | Revisione completa e approvazione della Roadmap di Sviluppo |
| 1.1 | 08/08/2026 | Aggiornamento del Motore Agronomico e pianificazione delle evoluzioni successive |
| 1.2 | 16/08/2026 | Aggiornamento della roadmap dopo la Sessione S017: completamento e congelamento della progettazione Database V1, pianificazione dell'implementazione incrementale in Supabase e riallineamento delle priorità di sviluppo |
| 1.3 | 16/08/2026 | Aggiornamento dopo la Sessione S018: completamento dei prerequisiti locali Supabase, consolidamento delle finestre agronomiche multiple e definizione dello STEP 35.3 come punto di avvio della baseline SQL Database V1 |
| 1.4 | 18/08/2026 | Aggiornamento dopo la Sessione S019: prima migration Database V1, implementazione e verifica locale delle Fondazioni, prima matrice di 13 policy RLS e definizione delle RPC sicure e atomiche come prossimo incremento tecnico |
| 1.5 | 28/08/2026 | Aggiornamento dopo la Sessione S023: completamento del protocollo `profile_edit_locks`, Write Path autoritativi di `gardens` e `seasons`, integrazione Flutter della Profile Write Authority e definizione di `beds` e `bed_geometries` come prossimo blocco tecnico |
| 1.6 | 01/09/2026 | Aggiornamento dopo la Sessione S024: completamento del Write Path autoritativo di `beds`, implementazione della geometria storicizzata, integrazione Flutter della creazione dell’aiuola e rinvio della scelta del successivo blocco tecnico |
| 1.7 | 03/09/2026 | Manutenzione straordinaria della Roadmap: normalizzazione del nome dell’autore nei metadati del documento |

---

# 6. Considerazioni finali

La Roadmap di Sviluppo rappresenta il documento di riferimento per la pianificazione strategica dell'evoluzione di Orto Smart.

A differenza del Quaderno di Sviluppo (DOC-005), che documenta le attività svolte nelle singole sessioni, la Roadmap mantiene una visione di medio e lungo periodo, evidenziando gli obiettivi generali del progetto e le principali direttrici di sviluppo.

Il documento viene aggiornato in occasione del completamento di funzionalità significative o quando intervengono modifiche sostanziali nella pianificazione del progetto, mantenendo la coerenza con il Manuale Tecnico (DOC-001), il Quaderno di Sviluppo (DOC-005), le Decisioni Architetturali (DOC-011) e il CHANGELOG.

La Roadmap costituisce pertanto uno strumento di pianificazione e di orientamento dello sviluppo, contribuendo a garantire una crescita ordinata, coerente e sostenibile del progetto Orto Smart.

