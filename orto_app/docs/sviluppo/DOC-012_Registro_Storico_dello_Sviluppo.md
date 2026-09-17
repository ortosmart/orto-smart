# ORTO SMART

### DOC-012

# Registro Storico dello Sviluppo

**Versione:** 3.7

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 29/07/2026

**Ultimo aggiornamento:** 17/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-012 |
| Titolo | Registro Storico dello Sviluppo |
| Versione | 3.7 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 29/07/2026 |
| Ultimo aggiornamento | 17/09/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|----------|------|-------------|
| 1.0 | 29/07/2026 | Prima emissione del documento |
| 2.0 | 05/08/2026 | Revisione strutturale del documento, trasformazione del Registro Storico in cruscotto dell'evoluzione del progetto e uniformazione allo Standard Documentale |
| 2.1 | 08/08/2026 | Aggiornamento del Registro Storico con la Sessione S010 e consolidamento dell'evoluzione del sistema decisionale del Motore Agronomico |
| 2.2 | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S011 e introduzione della prima versione del FamilyNeedsEngine |
| 2.3 | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S012 e integrazione del FamilyNeedsEngine nella RecommendationPipeline |
| 2.4 | 10/08/2026 | Aggiornamento del Registro Storico con la Sessione S013 e predisposizione delle fondamenta del futuro SuccessionPlanningEngine |
| 2.5 | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S014 e prima implementazione del SuccessionPlanningEngine |
| 2.6 | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S015 e introduzione della prima infrastruttura delle finestre agronomiche |
| 2.7 | 12/08/2026 | Aggiornamento del Registro Storico con la Sessione S016 e associazione delle finestre agronomiche a colture e varietà |
| 2.8 | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S017, completamento e congelamento della baseline Database V1 e consolidamento dei tempi complessivi di sviluppo e documentazione |
| 2.9 | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S018: supporto alle finestre agronomiche multiple, predisposizione dell'ambiente locale Supabase e riallineamento degli indicatori evolutivi |
| 3.0 | 25/08/2026 | Aggiornamento del Registro Storico con le Sessioni S019, S020, S021 e S022, consolidamento dei tempi di sviluppo e documentazione e aggiornamento degli indicatori evolutivi |
| 3.1 | 28/08/2026 | Aggiornamento del Registro Storico con la Sessione S023, consolidamento dei Write Path autoritativi di `gardens` e `seasons`, integrazione Flutter della Profile Write Authority e riallineamento definitivo dei tempi S020–S023 |
| 3.2 | 01/09/2026 | Aggiornamento del Registro Storico con la Sessione S024: Write Path autoritativo di `beds`, geometria storicizzata, integrazione Flutter, versione 0.1.15-alpha e riallineamento degli indicatori evolutivi |
| 3.3 | 03/09/2026 | Manutenzione straordinaria del Registro Storico: consolidamento dei tempi complessivi delle Sessioni S001–S024, classificazione documentale della S007, riallineamento dei progressivi e aggiornamento del totale progetto a 167 h 51 min |
| 3.4 | 06/09/2026 | Aggiornamento del Registro Storico con la Sessione S025: completamento dell’integrazione Flutter dei Write Path autoritativi di `beds`, introduzione delle interfacce operative, gestione italiana delle date, verifica con 841/841 test superati e riallineamento degli indicatori al totale progetto di 174 h 47 min |
| 3.5 | 12/09/2026 | Aggiornamento con la Sessione S026: implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, nove RPC autoritative, sicurezza e concorrenza server-side, versione 0.1.17-alpha, definizione della S027 come integrazione Flutter del Catalogo V1 e consolidamento finale della S026 a 8 h 55 min |
| 3.6 | 14/09/2026 | Aggiornamento con la Sessione S027: completamento dell'integrazione Flutter del Catalogo V1, introduzione di `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository e result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, 914/914 test superati, versione 0.1.18-alpha e chiusura definitiva della Sessione S027 a 2 h 33 min con totale progetto di 186 h 15 min |
| 3.7 | 17/09/2026 | Aggiornamento con la Sessione S028: implementazione del modello persistente e Write Path autoritativo di `plantings`, lifecycle server-side, geometria e overlap spazio-temporale, protezione delle geometrie delle aiuole mediante `blocked_by_plantings`, integrazione Flutter, 997/997 test superati, versione `0.1.19-alpha` / `0.1.19-alpha+4`; Sessione S028 conclusa in 11 h 20 min complessivi, di cui 9 h 04 min di sviluppo e 2 h 16 min di documentazione, con totale progetto pari a 197 h 35 min |

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

Alla data dell'ultimo aggiornamento del presente documento, la Sessione S028 è conclusa sia nella fase di sviluppo sia nella fase documentale.

La fase Manuali S028 è iniziata il:

```text
17/09/2026 alle 09:01
```

ed è stata chiusa il:

```text
17/09/2026 alle 11:17
```

Il tempo documentale della Sessione S028 è:

```text
2 h 16 min
```

Lo stato corrente è:

| Indicatore | Valore |
|------------|--------|
| Ultima sessione completamente conclusa | S028 |
| Ultima fase sviluppo completata | S028 |
| Sessione in corso | Nessuna |
| Stato della documentazione | Aggiornata e consolidata fino alla Sessione S028 |
| Versione pubblica corrente | 0.1.19-alpha |
| Versione Flutter corrente | 0.1.19-alpha+4 |

La Sessione S028 ha richiesto complessivamente:

| Attività | Durata |
|----------|-------:|
| Sviluppo | 9 h 04 min |
| Documentazione | 2 h 16 min |
| **Totale S028** | **11 h 20 min** |

I progressivi definitivi del progetto alla chiusura della S028 sono:

```text
Sviluppo complessivo        146 h 14 min
Documentazione complessiva   51 h 21 min
----------------------------------------
Totale progetto             197 h 35 min
```

# 3. Cronologia sintetica dello sviluppo

La cronologia sintetica riporta, in ordine cronologico, le principali sessioni che hanno caratterizzato l'evoluzione del progetto Orto Smart.

Per ciascuna sessione vengono indicati l'evento principale e il tempo complessivo della sessione, comprensivo dello sviluppo e della documentazione quando entrambi presenti.

| Sessione | Attività principale | Ore sessione | Totale progressivo |
|-----------|---------------------|-------------:|-------------------:|
| **S001** | Avvio del progetto Orto Smart | **6 h 00 min** | **6 h 00 min** |
| **S002** | Evoluzione dell'architettura e integrazione Supabase | **7 h 00 min** | **13 h 00 min** |
| **S003** | Realizzazione del FreeSpace Engine e del Suggestion Engine | **8 h 00 min** | **21 h 00 min** |
| **S004** | Sviluppo del Companion Engine e refactoring dell'architettura | **5 h 00 min** | **26 h 00 min** |
| **S005** | Introduzione del BedAnalysisService e integrazione dell'analisi agronomica | **4 h 00 min** | **30 h 00 min** |
| **S006** | Decision Engine, integrazione dell'analisi agronomica e completamento della documentazione di progetto | **4 h 00 min** | **34 h 00 min** |
| **S007** | Revisione e consolidamento della documentazione tecnica | **11 h 00 min*** | **45 h 00 min** |
| **S008** | Censimento e consolidamento della documentazione residua | **4 h 16 min** | **49 h 16 min** |
| **S009** | Evoluzione dell'architettura del Motore Agronomico e introduzione della RecommendationPipeline | **5 h 22 min** | **54 h 38 min** |
| **S010** | Configurazione dei pesi del DecisionEngine mediante DecisionWeights | **4 h 54 min** | **59 h 32 min** |
| **S011** | Prima implementazione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari | **2 h 27 min** | **61 h 59 min** |
| **S012** | Integrazione del FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico delle raccomandazioni | **1 h 42 min** | **63 h 41 min** |
| **S013** | Introduzione dei fabbisogni quantitativi familiari e dei lotti pianificati come fondamenta del futuro SuccessionPlanningEngine | **2 h 07 min** | **65 h 48 min** |
| **S014** | Prima implementazione del SuccessionPlanningEngine per la generazione temporale validata dei lotti di coltivazione | **2 h 46 min** | **68 h 34 min** |
| **S015** | Prima implementazione delle finestre agronomiche mediante AgronomicWindow, AgronomicWindowValidator e AgronomicWindowEngine | **1 h 59 min** | **70 h 33 min** |
| **S016** | Associazione delle finestre agronomiche a colture e varietà e introduzione della valutazione stagionale dei lotti pianificati | **2 h 02 min** | **72 h 35 min** |
| **S017** | Progettazione completa e congelamento della baseline Database V1 | **25 h 14 min** | **97 h 49 min** |
| **S018** | Supporto alle finestre agronomiche multiple e predisposizione dell'ambiente locale Supabase | **3 h 56 min** | **101 h 45 min** |
| **S019** | Prima migration Database V1, implementazione delle Fondazioni e prima sicurezza RLS | **8 h 13 min** | **109 h 58 min** |
| **S020** | Hardening di `profile_edit_locks` e implementazione delle RPC server-side per il protocollo di takeover | **6 h 54 min** | **116 h 52 min** |
| **S021** | Completamento e hardening del protocollo `profile_edit_locks` e verifica delle transizioni concorrenti | **9 h 57 min** | **126 h 49 min** |
| **S022** | Primo Write Path autoritativo di Categoria A per `gardens` | **9 h 34 min** | **136 h 23 min** |
| **S023** | Profile Write Authority applicativa, hardening concorrente di `gardens` e Write Path autoritativo di `seasons` | **13 h 25 min** | **149 h 48 min** |
| **S024** | Write Path autoritativo di `beds`, geometria storicizzata e integrazione Flutter della creazione dell'aiuola | **18 h 03 min** | **167 h 51 min** |
| **S025** | Completamento dell'integrazione Flutter dei Write Path autoritativi di `beds` | **6 h 56 min** | **174 h 47 min** |
| **S026** | Implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties` e dei relativi Write Path autoritativi | **8 h 55 min** | **183 h 42 min** |
| **S027** | Integrazione Flutter del Catalogo V1 | **2 h 33 min** | **186 h 15 min** |
| **S028** | Implementazione del modello e Write Path autoritativo di `plantings` | **11 h 20 min** | **197 h 35 min** |

* La durata della S007 costituisce un valore storico consolidato riferito esclusivamente alla revisione e al consolidamento documentale. Non sono disponibili gli intervalli puntuali originari.

Per le Sessioni S004, S005 e S006 è disponibile il tempo complessivo storico della sessione, ma non la ripartizione attendibile tra sviluppo e documentazione.

Per la Sessione S026 il tempo complessivo di **8 h 55 min** è composto da:

```text
Sviluppo        7 h 04 min
Documentazione  1 h 51 min
-------------------------
Totale          8 h 55 min
```

Per la Sessione S027 il tempo complessivo di **2 h 33 min** è composto da:

```text
Sviluppo        1 h 18 min
Documentazione  1 h 15 min
-------------------------
Totale          2 h 33 min
```

Per la Sessione S028 il tempo complessivo di **11 h 20 min** è composto da:

```text
Sviluppo        9 h 04 min
Documentazione  2 h 16 min
-------------------------
Totale         11 h 20 min
```

---

## 3.1 Lettura della cronologia

La cronologia sintetica riportata nel presente capitolo costituisce uno strumento di consultazione rapida dell'evoluzione del progetto.

Essa consente di:

- ricostruire le principali tappe dello sviluppo;
- monitorare la crescita del progetto nel tempo;
- valutare l'impegno complessivamente dedicato allo sviluppo;
- mantenere uno storico sintetico delle attività svolte.

---

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
| **S014** | Prima versione del SuccessionPlanningEngine | Implementazione della prima versione deterministica del `SuccessionPlanningEngine`, capace di trasformare un `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, rifiutando le conversioni tra fabbisogno familiare e quantità di impianto non supportate dai dati agronomici disponibili. |
| **S015** | Prima infrastruttura delle finestre agronomiche | Introduzione di `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine` per rappresentare finestre agronomiche annuali e verificare separatamente la compatibilità temporale dei lotti pianificati in base al metodo di avvio e alla data. |
| **S016** | Stagionalità di colture e varietà | Introduzione di `CropAgronomicWindowRule`, `AgronomicWindowResolver`, `AgronomicWindowEvaluation` e `AgronomicWindowService` per associare le finestre agronomiche a colture e varietà, applicare il fallback varietà → coltura e distinguere `compatible`, `incompatible` e `unknown`. |
| **S017** | Baseline Database V1 | Completamento e congelamento della progettazione logica e architetturale del Database V1: 52 entità di dominio, struttura tecnica `profile_edit_locks`, ownership, modello di accesso familiare single-writer, temporalità, storicizzazione, invarianti, sicurezza, convenzioni dei dati e strategia di futura implementazione SQL/Supabase. |
| **S018** | Finestre agronomiche multiple e ambiente Supabase locale | Estensione della valutazione agronomica al supporto di più finestre applicabili, con fallback tra livelli di specificità, e predisposizione dell'ambiente locale WSL 2, Docker Desktop e Supabase CLI per l'implementazione incrementale della baseline Database V1 mediante migration versionate. |
| **S019** | Primo incremento fisico Database V1 | Creazione della prima migration `20260817103916_database_v1_baseline.sql`, implementazione del blocco Fondazioni (`profiles`, `profile_memberships`, `gardens`, `workers`, `seasons`, `profile_edit_locks`), introduzione dello schema `private`, helper autorizzativi, trigger metadata, prima matrice di 13 policy RLS e verifica locale positiva e negativa della sicurezza. |
| **S020** | RPC sicure per `profile_edit_locks` | Implementazione e verifica delle RPC server-side per la gestione del lock e del takeover, con hardening della sicurezza, dei token, dei lease e delle transizioni concorrenti. |
| **S021** | Hardening del protocollo `profile_edit_locks` | Completamento e audit del protocollo completo di `profile_edit_locks`, con verifica delle transizioni concorrenti mediante `FOR UPDATE`, rivalidazione server-side e trasferimento atomico del lock. |
| **S022** | Primo Write Path autoritativo di Categoria A | Introduzione del primo Write Path autoritativo del Database V1 per `gardens`, con `Profile Write Authority`, RPC `create_garden` e `update_garden`, revoca delle scritture dirette da parte di `authenticated`, validazioni server-side e verifica del comportamento concorrente. |
| **S023** | Profile Write Authority applicativa e Write Path di `seasons` | Rafforzato `update_garden` contro i lost update, implementato il Write Path autoritativo di `seasons`, introdotte l'identità tecnica del client e della sessione e integrati controller, scheduler, scope e gate fail-closed della Profile Write Authority nel ciclo applicativo Flutter. |
| **S024** | Write Path autoritativo di `beds` | Implementati `beds`, `bed_geometries` e `bed_geometry_corrections`, introdotte cinque RPC autoritative, integrati `BedRepository`, `ProfileContextScope` e `CreateBedPage`, parametrizzata la configurazione Supabase e verificati 781/781 test. |
| **S025** | Completamento UI del Write Path autoritativo di `beds` | Integrate modifica dei dati, attivazione e disattivazione, variazione geometrica ordinaria e correzione storica; introdotto `CivilDate`, mantenuta la separazione semantica delle operazioni geometriche, applicate rilettura autoritativa e gestione fail-closed e verificati 841/841 test. |
| **S026** | Catalogo DB V1 | Implementate `botanical_families`, `crops` e `crop_varieties` come catalogo Profile-owned con UUID, gerarchia e fallback Crop → Crop Variety, blocchi agronomici per acqua e resa, nove RPC autoritative, RLS in lettura, revoca delle scritture dirette, Profile Write Authority, concorrenza ottimistica e principio **catalogo corrente + snapshot storico**. |
| **S027** | Integrazione Flutter del Catalogo V1 | Integrato nel client Flutter il Catalogo V1 mediante `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, `BotanicalFamilyRepository`, `CropRepository` e `CropVarietyRepository`, result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version` e compatibilità legacy controllata; verificati 124 test mirati e 914/914 test complessivi. |
| **S028** | Write Path autoritativo di `plantings` | Implementato il modello persistente autoritativo delle coltivazioni reali, introdotte le RPC `create_planting`, `update_planting` e `set_planting_status`, lifecycle server-side, geometria half-open, controllo congiunto degli overlap temporali e longitudinali, compatibilità con la geometria storicizzata delle aiuole, esito `blocked_by_plantings`, Profile Write Authority, concorrenza ottimistica mediante `row_version`, integrazione Flutter e verifica finale con 997/997 test. |

---

## 4.1 Significato delle milestone

Le milestone identificano gli eventi che hanno segnato un'evoluzione significativa del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la storia tecnica di Orto Smart e rappresentano i momenti in cui sono state introdotte nuove funzionalità, nuovi componenti architetturali o importanti cambiamenti organizzativi.

La registrazione di una milestone tecnica non implica necessariamente che la relativa sessione sia già completamente chiusa sotto il profilo documentale.

La milestone tecnica della Sessione S028 e la relativa fase documentale risultano entrambe concluse.

# 5. Indicatori evolutivi

Il presente capitolo raccoglie gli indicatori che consentono di monitorare l'evoluzione del progetto nel tempo.

A differenza degli indicatori storici riportati nel capitolo 2, che rappresentano una fotografia dello stato attuale del progetto, gli indicatori evolutivi consentono di osservare la crescita di Orto Smart sotto il profilo organizzativo, tecnico e documentale.

Alla data del presente aggiornamento le Sessioni S001–S028 sono completamente concluse.

| Indicatore | Valore attuale |
|------------|----------------|
| Sessioni completamente concluse | 28 |
| Fasi sviluppo completate | 28 |
| Ore di sviluppo consolidate | 146 h 14 min |
| Ore di documentazione consolidate | 51 h 21 min |
| Totale ore progetto | 197 h 35 min |
| Motori agronomici completati | 5 |
| Documenti ufficiali approvati | 10 |
| Ultima sessione completamente conclusa | S028 |
| Ultima fase sviluppo completata | S028 |
| Sessione in corso | Nessuna |
| Versione pubblica corrente | 0.1.19-alpha |
| Versione Flutter corrente | 0.1.19-alpha+4 |

La S028 ha completato il livello successivo mediante l'implementazione del modello persistente e del Write Path autoritativo di `plantings`.

Lo stato raggiunto è:

```text
public.plantings
        ✅ modello persistente

Write Path autoritativo di plantings
        ✅

Lifecycle server-side di plantings
        ✅

UI di creazione e modifica di plantings
        ✅

UI completa del lifecycle di plantings
        ⏳

Selezione opzionale della varietà nella UI operativa
        ⏳
```

La baseline complessiva Database V1 rimane:

```text
IN CORSO
```

poiché non tutte le 52 entità progettate nella S017 sono ancora fisicamente implementate.

Il Repository Layer Flutter relativo alle coltivazioni comprende:

```text
PlantingRepository
```

con:

```text
getPlantingsByBed
createPlanting
updatePlanting
setPlantingStatus
```

Le scritture applicative ordinarie di `plantings` utilizzano esclusivamente RPC autoritative.

La S028 ha consolidato:

- Profile Write Authority fail-closed;
- concorrenza ottimistica mediante `row_version`;
- result type dedicato;
- mapping esplicito degli status RPC;
- gestione autoritativa del lifecycle;
- geometria longitudinale half-open;
- controllo congiunto degli overlap temporali e longitudinali;
- compatibilità con la geometria storicizzata delle aiuole;
- protezione delle modifiche geometriche mediante `blocked_by_plantings`;
- assenza di hard delete nel normale flusso operativo.

La verifica tecnica finale della S028 ha prodotto:

```text
997/997 test complessivi superati
flutter analyze: No issues found!
supabase db reset: OK
supabase db lint --local: nessun errore
```

Le migration introdotte nella Sessione S028 sono:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

L'ultima migration del Database V1 è:

```text
20260915081444_add_plantings_write_rpcs.sql
```

`public.plantings` è ora implementata come modello persistente autoritativo.

I quattro metodi di avvio canonici sono:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il lifecycle autoritativo comprende:

```text
sown
growing
harvest_ready
harvested
finished
removed
```

Lo stato:

```text
harvested
```

continua a occupare l'aiuola.

Soltanto:

```text
finished
removed
```

terminano l'occupazione.

La geometria longitudinale utilizza intervalli half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

Il conflitto tra coltivazioni viene rilevato soltanto quando sono contemporaneamente presenti:

```text
overlap temporale
+
overlap longitudinale
```

Le modifiche alla geometria delle aiuole possono essere bloccate mediante:

```text
blocked_by_plantings
```

quando risultano incompatibili con coltivazioni già persistite.

Il normale flusso operativo non prevede hard delete di `plantings`.

Un eventuale hard delete rimane classificato:

```text
FUTURE
```

e dovrà essere limitato a correzioni amministrative o tecniche eccezionali.

La fase sviluppo S028 è conclusa.

La fase Manuali S028 è stata chiusa il:

```text
17/09/2026 alle 11:17
```

Il tempo complessivo della Sessione S028 è:

```text
Sviluppo        9 h 04 min
Documentazione  2 h 16 min
-------------------------
Totale         11 h 20 min
```

I progressivi definitivi alla chiusura della S028 sono:

```text
Sviluppo complessivo        146 h 14 min
Documentazione complessiva   51 h 21 min
----------------------------------------
Totale progetto             197 h 35 min
```

La Sessione S028 è conclusa sia nella fase di sviluppo sia nella fase documentale.

Il successivo incremento preliminarmente approvato è:

```text
S029 — Lifecycle e varietà delle coltivazioni
```

con stato:

```text
APPROVATO PRELIMINARMENTE
NON INIZIATO
```

La pianificazione preliminare della S029 non costituisce avvio della sessione.

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