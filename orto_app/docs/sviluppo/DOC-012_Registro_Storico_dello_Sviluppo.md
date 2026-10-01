# ORTO SMART

### DOC-012

# Registro Storico dello Sviluppo

**Versione:** 4.0

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 29/07/2026

**Ultimo aggiornamento:** 01/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-012 |
| Titolo | Registro Storico dello Sviluppo |
| Versione | 4.0 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 29/07/2026 |
| Ultimo aggiornamento | 01/10/2026 |

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
| 3.4 | 06/09/2026 | Aggiornamento del Registro Storico con la Sessione S025: completamento dell'integrazione Flutter dei Write Path autoritativi di `beds`, introduzione delle interfacce operative, gestione italiana delle date, verifica con 841/841 test superati e riallineamento degli indicatori al totale progetto di 174 h 47 min |
| 3.5 | 12/09/2026 | Aggiornamento con la Sessione S026: implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, nove RPC autoritative, sicurezza e concorrenza server-side, versione 0.1.17-alpha, definizione della S027 come integrazione Flutter del Catalogo V1 e consolidamento finale della S026 a 8 h 55 min |
| 3.6 | 14/09/2026 | Aggiornamento con la Sessione S027: completamento dell'integrazione Flutter del Catalogo V1, introduzione di `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository e result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, 914/914 test superati, versione 0.1.18-alpha e chiusura definitiva della Sessione S027 a 2 h 33 min con totale progetto di 186 h 15 min |
| 3.7 | 17/09/2026 | Aggiornamento con la Sessione S028: implementazione del modello persistente e Write Path autoritativo di `plantings`, lifecycle server-side, geometria e overlap spazio-temporale, protezione delle geometrie delle aiuole mediante `blocked_by_plantings`, integrazione Flutter, 997/997 test superati, versione `0.1.19-alpha` / `0.1.19-alpha+4`; Sessione S028 conclusa in 11 h 20 min complessivi, di cui 9 h 04 min di sviluppo e 2 h 16 min di documentazione, con totale progetto pari a 197 h 35 min |
| 3.8 | 18/09/2026 | Aggiornamento e chiusura della Sessione S029: completamento della UI del lifecycle di `plantings`, gestione esplicita di `end_date` per gli stati terminali, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`, suite completa finale verificata con 1011/1011 test superati; Sessione S029 conclusa in 4 h 09 min complessivi, di cui 1 h 19 min di sviluppo e 2 h 50 min di documentazione, con totale progetto pari a 201 h 44 min |
| 3.9 | 28/09/2026 | Aggiornamento e chiusura della Sessione S030: completamento del Catalogo Agronomico globale attraverso 11 tranche tecniche, introduzione delle identità botaniche globali, Catalog Authority, fonti e osservazioni, workflow editoriale, Knowledge agronomica canonica, pubblicazione e Resolver, cutover finale Database + Flutter, 26 tabelle nel perimetro Catalogo e 953 test Flutter superati; Sessione S030 conclusa in 27 h 19 min complessivi, di cui 21 h 06 min di sviluppo e 6 h 13 min di documentazione, con totale progetto pari a 229 h 03 min |
| 4.0 | 01/10/2026 | Aggiornamento e chiusura della Sessione S031: integrazione operativa Flutter del Catalogo Agronomico nel percorso `Impostazioni → Catalogo Agronomico → Colture → Cultivar`, integrazione della Catalog Authority e delle relative capability, inizializzazione esplicita e confermata dell'authority, consultazione delle colture globali, caricamento on demand delle cultivar, gestione degli stati UI e rimozione del precedente percorso autonomo `Impostazioni → Varietà`; 971 test Flutter superati, nessuna nuova migration, Sessione S031 conclusa in 6 h 06 min complessivi, di cui 4 h 03 min di sviluppo e 2 h 03 min di documentazione, con totale progetto pari a 235 h 09 min; versione pubblica invariata a `0.1.21-alpha` e versione Flutter invariata a `0.1.21-alpha+6`. |

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

Alla data dell'ultimo aggiornamento del presente documento, la Sessione S031 è completamente conclusa sia nella fase di sviluppo sia nella fase documentale.

La fase sviluppo S031 si è svolta dal:

```text
28/09/2026
```

al:

```text
30/09/2026 alle 11:33
```

attraverso più intervalli di lavoro e sospensione registrati nel Quaderno di Sviluppo (DOC-005).

Il tempo di sviluppo consolidato della Sessione S031 è:

```text
4 h 03 min
```

La fase Manuali S031 è iniziata il:

```text
30/09/2026 alle 11:37
```

ed è stata articolata nei seguenti intervalli netti di lavoro:

```text
30/09/2026   11:37 → 12:00   0 h 23 min
01/10/2026   09:16 → 09:58   0 h 42 min
01/10/2026   11:09 → 12:07   0 h 58 min
---------------------------------------
Totale                         2 h 03 min
```

Gli intervalli intercorsi tra una sospensione e la successiva ripresa sono esclusi dal conteggio.

La fase documentale S031 è stata conclusa il:

```text
01/10/2026 alle 12:07
```

Il tempo documentale netto della Sessione S031 è pertanto:

```text
2 h 03 min
```

Lo stato corrente è:

| Indicatore | Valore |
|------------|--------|
| Ultima sessione completamente conclusa | S031 |
| Ultima fase sviluppo completata | S031 |
| Sessione in corso | Nessuna |
| Stato della documentazione | Aggiornamento S031 concluso |
| Versione pubblica corrente | 0.1.21-alpha |
| Versione Flutter corrente | 0.1.21-alpha+6 |

Il tempo complessivo della Sessione S031 è:

| Attività | Durata |
|----------|-------:|
| Sviluppo | 4 h 03 min |
| Documentazione | 2 h 03 min |
| **Totale S031** | **6 h 06 min** |

I progressivi definitivi del progetto alla chiusura della S031 sono:

```text
Sviluppo complessivo        172 h 42 min
Documentazione complessiva   62 h 27 min
----------------------------------------
Totale progetto             235 h 09 min
```

La Sessione S031 ha completato l'integrazione operativa Flutter del Catalogo Agronomico globale realizzato nella S030, rendendo disponibile il percorso applicativo canonico:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

L'integrazione mantiene il backend del Catalogo come fonte autoritativa e non introduce dati agronomici demo, provvisori o di esempio nel database.

La gestione della Catalog Authority è stata integrata nell'interfaccia mediante `CatalogAuthorityRepository`.

La UI consente di rappresentare lo stato dell'authority e le capability disponibili all'utente autenticato.

L'inizializzazione iniziale della Catalog Authority rimane un'azione esplicita: non viene eseguita automaticamente dal client e richiede conferma dell'utente prima dell'invocazione della relativa operazione autoritativa.

La consultazione delle colture globali utilizza il Repository Layer del Catalogo.

Dopo la selezione di una coltura, le cultivar associate vengono caricate on demand, mantenendo la gerarchia canonica:

```text
Crop
    ↓
Cultivar
```

La UI gestisce esplicitamente gli stati:

```text
loading
empty
error
retry
```

Il precedente percorso autonomo:

```text
Impostazioni → Varietà
```

è stato rimosso.

Le cultivar sono ora consultate esclusivamente nel contesto della coltura selezionata attraverso il percorso gerarchico del Catalogo Agronomico.

La Sessione S031 non ha introdotto nuove migration Supabase.

La baseline database derivata dalla S030 rimane pertanto invariata sotto il profilo delle migration e del contratto persistente.

La verifica tecnica finale della S031 ha confermato:

```text
flutter analyze
    No issues found

flutter test
    971 test superati
```

Il commit tecnico conclusivo della S031 è:

```text
b436d663e46149202e081a3079eb162567fb0909
Rimuove gestione separata delle cultivar
```

Alla chiusura dello sviluppo S031 il branch `main` risultava allineato a `origin/main` e il working tree risultava pulito.

La Sessione S032 dovrà partire dalla baseline stabile della S031.

Il primo passo previsto non consiste nella scelta preventiva tra creazione di una coltura o creazione di una cultivar, ma in una ricognizione tecnica delle funzioni e delle RPC già disponibili per la gestione delle identità del Catalogo.

La scelta del primo Write Path da implementare dovrà derivare da tale ricognizione, mantenendo:

- backend autoritativo;
- capability `can_manage_identity`;
- normalizzazione e unicità delle identità;
- tassonomia botanica globale;
- tracciabilità;
- gerarchia Crop → Cultivar;
- separazione tra dati candidati e dati approvati;
- assenza di popolamenti demo o provvisori.

Il popolamento reale del Catalogo con dati agronomici dovrà iniziare soltanto quando il relativo workflow sarà sufficientemente sicuro, verificato e tracciabile.

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
| **S029** | Completamento della UI del lifecycle di `plantings` | **4 h 09 min** | **201 h 44 min** |
| **S030** | Implementazione del Catalogo Agronomico globale e cutover finale Database + Flutter | **27 h 19 min** | **229 h 03 min** |
| **S031** | Integrazione operativa Flutter del Catalogo Agronomico e navigazione gerarchica Coltura → Cultivar | **6 h 06 min** | **235 h 09 min** |

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

Per la Sessione S029 il tempo complessivo di **4 h 09 min** è composto da:

```text
Sviluppo        1 h 19 min
Documentazione  2 h 50 min
-------------------------
Totale          4 h 09 min
```

La fase Manuali S029 si è svolta il 18/09/2026 secondo gli intervalli:

```text
09:03 → 10:41   1 h 38 min
11:31 → 12:43   1 h 12 min
---------------------------
Totale          2 h 50 min
```

La pausa dichiarata dalle 10:41 alle 11:31 è esclusa dal conteggio.

Per la Sessione S030 il tempo complessivo di **27 h 19 min** è composto da:

```text
Sviluppo        21 h 06 min
Documentazione   6 h 13 min
--------------------------
Totale          27 h 19 min
```

La fase sviluppo S030 si è svolta dal 18/09/2026 al 23/09/2026 ed è stata chiusa alle 22:23 del 23/09/2026.

La fase Manuali S030 si è svolta secondo gli intervalli:

```text
23/09/2026   22:48 → 23:14   0 h 26 min
24/09/2026   09:02 → 12:54   3 h 52 min
27/09/2026   21:00 → 22:32   1 h 32 min
28/09/2026   11:22 → 11:45   0 h 23 min
---------------------------------------
Totale                         6 h 13 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

Il totale progressivo definitivo del progetto alla chiusura della S030 è:

```text
229 h 03 min
```

Per la Sessione S031 il tempo complessivo di **6 h 06 min** è composto da:

```text
Sviluppo         4 h 03 min
Documentazione   2 h 03 min
--------------------------
Totale           6 h 06 min
```

La fase sviluppo S031 si è svolta secondo gli intervalli consolidati nel Quaderno di Sviluppo (DOC-005) ed è stata chiusa alle **11:33 del 30/09/2026**, con un tempo netto complessivo di **4 h 03 min**.

La fase Manuali S031 si è svolta secondo gli intervalli:

```text
30/09/2026   11:37 → 12:00   0 h 23 min
01/10/2026   09:16 → 09:58   0 h 42 min
01/10/2026   11:09 → 12:07   0 h 58 min
---------------------------------------
Totale                         2 h 03 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

La fase documentale S031 è stata conclusa alle **12:07 del 01/10/2026**.

Il totale progressivo definitivo del progetto alla chiusura della S031 è:

```text
235 h 09 min
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
| **S029** | Lifecycle operativo delle coltivazioni | Completata la UI del lifecycle di `plantings`, introdotte azioni contestuali in `PlantingCard`, gestione esplicita di `end_date` per `finished` e `removed`, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`; nessuna modifica al contratto persistente S028. |
| **S030** | Catalogo Agronomico globale | Completata attraverso 11 tranche tecniche la nuova architettura globale del Catalogo Agronomico: identità botaniche globali, registro dei parametri agronomici, vocabolari e contesti, fonti/acquisizioni/osservazioni, alias e riconciliazione, workflow editoriale, Knowledge agronomica canonica, Catalog Authority e sicurezza, pubblicazione/versionamento, Resolver e read model, fino al cutover finale Database + Flutter. Il perimetro Catalogo comprende 26 tabelle; le vecchie strutture `botanical_families`, `catalog_crops_s030` e `crop_varieties` sono state rimosse e il contratto operativo è stato riallineato a `botanical_taxa`, `crops`, `crop_cultivars` e `cultivar_id`. |
| **S031** | Integrazione operativa Flutter del Catalogo Agronomico | Completata l'integrazione applicativa del Catalogo Agronomico globale nel percorso `Impostazioni → Catalogo Agronomico → Colture → Cultivar`; integrate la lettura delle capability della Catalog Authority e l'inizializzazione esplicita e confermata dell'authority, la consultazione delle colture globali, il caricamento on demand delle cultivar e gli stati loading/empty/error/retry; eliminato il precedente percorso autonomo `Impostazioni → Varietà`, mantenendo la gerarchia canonica Crop → Cultivar e il backend autoritativo. Nessuna nuova migration; verifica finale con 971 test Flutter superati. |

---

## 4.1 Significato delle milestone

Le milestone identificano gli eventi che hanno segnato un'evoluzione significativa del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la storia tecnica di Orto Smart e rappresentano i momenti in cui sono state introdotte nuove funzionalità, nuovi componenti architetturali o importanti cambiamenti organizzativi.

La registrazione di una milestone tecnica non implica necessariamente che la relativa sessione sia già completamente chiusa sotto il profilo documentale.

La milestone tecnica della Sessione S030 ha completato il passaggio dal precedente Catalogo V1 Profile-owned a un Catalogo Agronomico globale, multisource, tracciabile, versionabile, contestualizzabile ed editorialmente controllato, mantenuto separato dai dati operativi del singolo orto.

La relativa fase documentale S030 è conclusa.

La milestone tecnica della Sessione S031 ha portato il Catalogo Agronomico globale nel normale percorso applicativo delle Impostazioni, rendendo operativa la consultazione gerarchica:

```text
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La S031 ha inoltre integrato nell'interfaccia lo stato della Catalog Authority e le relative capability, mantenendo l'inizializzazione dell'authority come operazione esplicita e confermata e non come effetto automatico dell'apertura della pagina.

La relativa fase documentale S031 è conclusa.

La S031 non modifica il contratto persistente definito dalla S030 e non introduce nuove migration: rappresenta l'incremento applicativo che rende concretamente consultabile nel client Flutter il Catalogo globale realizzato nella sessione precedente.

La conclusione della S031 non equivale al completamento dell'intero workflow editoriale e amministrativo del Catalogo. I successivi Write Path di gestione delle identità e il workflow di acquisizione, revisione, approvazione e pubblicazione dei dati rimangono incrementi successivi da realizzare in modo controllato.

---

# 5. Indicatori evolutivi

Il presente capitolo raccoglie gli indicatori che consentono di monitorare l'evoluzione del progetto nel tempo.

A differenza degli indicatori storici riportati nel capitolo 2, che rappresentano una fotografia dello stato attuale del progetto, gli indicatori evolutivi consentono di osservare la crescita di Orto Smart sotto il profilo organizzativo, tecnico e documentale.

Alla data del presente aggiornamento le Sessioni S001–S031 sono completamente concluse.

| Indicatore | Valore attuale |
|------------|----------------|
| Sessioni completamente concluse | 31 |
| Fasi sviluppo completate | 31 |
| Ore di sviluppo consolidate | 172 h 42 min |
| Ore di documentazione consolidate | 62 h 27 min |
| Totale ore progetto | 235 h 09 min |
| Motori agronomici completati | 5 |
| Documenti ufficiali approvati | 10 |
| Ultima sessione completamente conclusa | S031 |
| Ultima fase sviluppo completata | S031 |
| Sessione in corso | Nessuna |
| Versione pubblica corrente | 0.1.21-alpha |
| Versione Flutter corrente | 0.1.21-alpha+6 |

La S028 ha completato il modello persistente e il Write Path autoritativo di `plantings`.

La S029 ha completato il livello applicativo del lifecycle delle coltivazioni.

La S030 ha completato una revisione architetturale del Catalogo Agronomico, sostituendo il precedente modello Profile-owned introdotto nelle S026–S027 con un modello globale separato dai dati operativi del singolo orto.

La S031 ha completato l'integrazione operativa Flutter del Catalogo Agronomico globale nel percorso:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La S031 ha inoltre integrato:

- lettura dello stato e delle capability della Catalog Authority;
- inizializzazione iniziale dell'authority mediante azione esplicita e confermata dall'utente;
- consultazione delle colture globali;
- caricamento delle cultivar on demand dopo la selezione della coltura;
- stati applicativi di loading, empty, error e retry;
- rimozione del precedente accesso autonomo `Impostazioni → Varietà`;
- mantenimento della gerarchia canonica Crop → Cultivar e del backend autoritativo.

Lo stato evolutivo raggiunto è:

```text
public.plantings
        ✅ modello persistente

Write Path autoritativo di plantings
        ✅

Lifecycle server-side di plantings
        ✅

UI di creazione e modifica di plantings
        ✅

UI lifecycle di plantings
        ✅

Gestione end_date terminale
        ✅

Refresh autoritativo su conflitti/transizioni non valide
        ✅

Catalogo Agronomico globale
        ✅

Identità botaniche globali
        ✅

Fonti, acquisizioni e osservazioni
        ✅

Workflow editoriale
        ✅

Knowledge agronomica canonica
        ✅

Catalog Authority
        ✅

Pubblicazione e Resolver
        ✅

Cutover finale Database + Flutter
        ✅

Integrazione operativa Catalogo Agronomico nelle Impostazioni
        ✅

Lettura capability Catalog Authority nella UI
        ✅

Inizializzazione iniziale Catalog Authority esplicita e confermata
        ✅

Consultazione colture globali
        ✅

Navigazione gerarchica Coltura → Cultivar
        ✅

Caricamento cultivar on demand
        ✅

Gestione loading / empty / error / retry del Catalogo
        ✅

Rimozione del percorso autonomo Impostazioni → Varietà
        ✅

Selezione esplicita del cultivar nella UI di creazione planting
        ⏳

Backend canonico delle consociazioni
        ⏳

UI amministrativa/editoriale completa del Catalogo
        ⏳
```

La baseline complessiva Database V1 rimane:

```text
IN CORSO
```

poiché non tutte le 52 entità di dominio progettate nella S017 sono ancora fisicamente implementate.

La S030 ha completato il nuovo perimetro persistente e autoritativo del Catalogo Agronomico globale.

La S031 non modifica tale perimetro persistente e non introduce nuove migration: completa invece l'integrazione operativa del Catalogo nel client Flutter.

Il completamento della S031 non equivale al completamento dell'intera baseline Database V1 né dell'intero workflow amministrativo/editoriale del Catalogo.


## Catalogo Agronomico globale

Il Catalogo Agronomico risultante dalla S030 è:

- globale;
- multisource;
- tracciabile;
- versionabile;
- contestualizzabile;
- editorialmente controllato;
- separato dai dati operativi del singolo orto.

Il perimetro Catalogo realizzato nella S030 comprende:

```text
26 tabelle
```

Le identità botaniche globali sono rappresentate mediante:

```text
botanical_taxa
```

con ranghi canonici:

```text
FAMILY
GENUS
SPECIES
VARIETY
CULTIVAR
```

La normalizzazione testuale del Catalogo è centralizzata mediante:

```text
private.normalize_catalog_text(text)
```

e applica normalizzazione Unicode, trim, spazi singoli e forma normalizzata per il confronto.

Le identità agronomiche operative canoniche sono rappresentate da:

```text
crops
crop_cultivars
```

Il precedente modello Profile-owned:

```text
botanical_families
crops
crop_varieties
```

appartiene allo storico delle S026–S027 e non rappresenta più il contratto corrente del Catalogo.

Al cutover finale S030 sono state rimosse le strutture legacy:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Il contratto corrente di `plantings` utilizza:

```text
crop_id
cultivar_id
```

con:

```text
crop_id → crops(id)
```

e vincolo composto:

```text
(cultivar_id, crop_id)
        →
crop_cultivars(id, crop_id)
```

Il precedente:

```text
variety_id
```

è stato rimosso dal contratto persistente corrente.

## Catalog Authority e sicurezza

La S030 ha introdotto una Catalog Authority globale con capability distinte per:

```text
identity management
ingestion
review
publishing
```

Le capability dell'utente autenticato possono essere lette mediante:

```text
get_my_catalog_capabilities()
```

L'inizializzazione esplicita dell'authority è disponibile mediante:

```text
claim_initial_catalog_authority()
```

La claim:

- non viene eseguita automaticamente dal client;
- è consentita soltanto all'owner idoneo quando l'authority non è ancora inizializzata;
- è idempotente;
- non consente una nuova acquisizione dell'authority già inizializzata.

Le RPC sensibili seguono il modello:

```text
SECURITY DEFINER
search_path vuoto
nessun EXECUTE ad anon
EXECUTE esplicito ad authenticated dove previsto
autorizzazione server-side
```

RLS, privilegi espliciti e Write Path controllati rimangono principi fondamentali dell'architettura.

## Fonti, ingestion e workflow editoriale

La S030 ha implementato il perimetro necessario a mantenere separati:

```text
fonte esterna
        ↓
acquisizione / ingestion
        ↓
osservazione / dato candidato
        ↓
revisione editoriale
        ↓
Knowledge agronomica canonica
        ↓
pubblicazione
        ↓
Resolver / read model
```

I dati provenienti da fonti esterne non possono sovrascrivere automaticamente il Catalogo approvato.

L'importazione produce dati candidati da sottoporre al processo editoriale.

Il principio rimane:

```text
dato esterno ≠ dato automaticamente approvato
```

Il workflow consente di mantenere tracciabilità tra fonti, osservazioni, revisioni e contenuto canonico.

La catena delle revisioni utilizza:

```text
previous_revision_id
```

per mantenere una relazione esplicita con la revisione precedente.

Il modello editoriale consolidato prevede inoltre che:

- CREATE possa reintrodurre in modo controllato contenuto precedentemente ritirato;
- il semantic freeze inizi dal primo artefatto immutabile;
- `NOT_MAPPABLE` sia ammesso soltanto per `CONFLICTING` e `CONTEXTUAL`;
- WITHDRAW conservi il contenuto canonico necessario alla tracciabilità.

## Knowledge, pubblicazione e Resolver

La Knowledge agronomica canonica è separata dalle identità botaniche e dalle osservazioni provenienti dalle fonti.

La S030 ha completato il percorso tecnico fino alla pubblicazione e al Resolver.

I read model canonici esposti al client sono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati con:

```text
security_invoker = true
```

Il Resolver può fornire dati agronomici utilizzabili dai flussi applicativi, ma non deve modificare automaticamente i dati operativi già persistiti.

I valori agronomici registrati su un planting rimangono snapshot operativi.

Il principio applicativo è:

```text
Resolver propone
utente conferma
dato operativo viene registrato
```

e non:

```text
Resolver modifica automaticamente planting esistenti
```

## Integrazione Flutter S030

Il client Flutter è stato riallineato al nuovo Catalogo globale.

Sono stati introdotti:

```text
CatalogCapabilities
CropCultivar
CatalogAuthorityRepository
CropCultivarRepository
```

`CropRepository` legge dal read model:

```text
crop_catalog_read
```

`CropCultivarRepository` legge dal read model:

```text
crop_cultivar_catalog_read
```

`CatalogAuthorityRepository` espone la lettura delle capability e la claim esplicita dell'authority.

Sono stati rimossi dal contratto corrente i componenti legacy relativi al Catalogo Profile-owned, compresi:

```text
BotanicalFamily
CropVariety
CropVarietyRepository
varietyId
variety_id
```

quando utilizzati come elementi del contratto applicativo corrente.

La terminologia tecnica corrente utilizza:

```text
cultivar
cultivarId
cultivar_id
CropCultivar
```

L'interfaccia italiana può continuare a utilizzare il termine:

```text
Varietà
```

come etichetta comprensibile all'utente.

Il motore delle rotazioni confronta l'UUID canonico della famiglia botanica; il nome della famiglia rimane informazione di visualizzazione.

## Integrazione operativa Flutter S031

La S031 ha completato l'integrazione operativa del Catalogo Agronomico globale nell'interfaccia Flutter, partendo dal contratto applicativo e dai repository predisposti nella S030.

Il percorso applicativo corrente è:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La pagina del Catalogo Agronomico integra `CatalogAuthorityRepository` per leggere lo stato e le capability della Catalog Authority.

L'inizializzazione iniziale dell'authority rimane un'operazione esplicita.

Il client:

```text
apre il Catalogo
        ↓
legge le capability
        ↓
verifica lo stato dell'authority
        ↓
propone l'inizializzazione soltanto quando applicabile
        ↓
richiede conferma esplicita dell'utente
        ↓
esegue claim_initial_catalog_authority()
```

La claim non viene quindi eseguita automaticamente all'apertura della pagina.

La consultazione delle identità agronomiche segue la gerarchia canonica:

```text
Crop
    ↓
CropCultivar
```

Le colture globali vengono lette tramite il read model:

```text
crop_catalog_read
```

e presentate nella sezione:

```text
Catalogo Agronomico → Colture
```

Le cultivar non vengono caricate indiscriminatamente insieme all'intero Catalogo.

Dopo la selezione di una coltura, il client carica on demand le cultivar associate mediante `CropCultivarRepository` e il read model:

```text
crop_cultivar_catalog_read
```

La UI gestisce esplicitamente gli stati:

```text
loading
empty
error
retry
```

sia per la consultazione delle colture sia, dove applicabile, per il caricamento delle cultivar.

La S031 consolida quindi nell'interfaccia la relazione:

```text
Coltura
    ↓
Cultivar appartenenti alla coltura
```

evitando di rappresentare le cultivar come un catalogo autonomo e scollegato dalla coltura di appartenenza.

Per questo motivo il precedente accesso separato:

```text
Impostazioni → Varietà
```

è stato rimosso.

Il termine tecnico canonico rimane:

```text
Cultivar
```

mentre eventuali etichette italiane rivolte all'utente possono continuare a utilizzare terminologia comprensibile senza modificare il contratto tecnico sottostante.

La S031 non introduce nuove migration e non modifica il modello persistente del Catalogo definito dalla S030.

Il backend rimane autoritativo e la UI non introduce Write Path diretti o scorciatoie che aggirino Catalog Authority, capability, normalizzazione, unicità, tassonomia o tracciabilità.

La S031 non ha introdotto dati dimostrativi, provvisori o di esempio nel Catalogo.

Il popolamento reale del Catalogo rimane subordinato alla disponibilità di un workflow sicuro, verificato e tracciabile per la gestione delle identità e dei dati agronomici.

La verifica finale della S031 ha confermato:

```text
flutter analyze
        ✅ nessun problema

flutter test
        ✅ 971 test superati

nuove migration
        0
```

Il commit conclusivo della fase sviluppo S031 è:

```text
b436d663e46149202e081a3079eb162567fb0909
```

con messaggio:

```text
Rimuove gestione separata delle cultivar
```

Alla chiusura della fase sviluppo S031 il branch `main` risultava allineato a `origin/main` e il working tree risultava pulito.

## Plantings dopo il cutover S030

Il Repository Layer Flutter relativo alle coltivazioni continua a comprendere:

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

Le scritture applicative ordinarie di `plantings` continuano a utilizzare esclusivamente RPC autoritative.

Restano validi i principi consolidati nelle S028–S029:

- Profile Write Authority fail-closed;
- concorrenza ottimistica mediante `row_version`;
- result type dedicati;
- mapping esplicito degli status RPC;
- lifecycle autoritativo;
- geometria longitudinale half-open;
- controllo congiunto degli overlap temporali e longitudinali;
- compatibilità con la geometria storicizzata delle aiuole;
- protezione delle modifiche geometriche mediante `blocked_by_plantings`;
- assenza di hard delete nel normale flusso operativo;
- `end_date = null` durante le transizioni intermedie;
- conferma esplicita di `end_date` per `finished` e `removed`;
- mantenimento dell'occupazione nello stato `harvested`;
- rilascio dello spazio soltanto negli stati `finished` e `removed`;
- refresh autoritativo su `version_conflict` e `invalid_transition`.

I quattro metodi di avvio canonici rimangono:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il lifecycle autoritativo rimane:

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

`AddPlantingPage` non espone ancora un selettore operativo esplicito del cultivar.

Nel flusso di creazione corrente:

```text
cultivarId = null
```

mentre nel flusso di modifica viene preservato l'eventuale:

```text
planting.cultivarId
```

La selezione esplicita del cultivar nella UI di creazione rimane quindi FUTURE.

## Consociazioni

Il motore applicativo delle consociazioni rimane disponibile.

Non esiste ancora un backend canonico S030 equivalente alla precedente relazione di catalogo per le consociazioni.

Nello stato corrente:

```text
CropAssociationRepository
```

restituisce insiemi vuoti anziché interrogare una relazione canonica non ancora esistente.

La realizzazione del backend canonico delle consociazioni rimane:

```text
FUTURE
```

## Verifiche tecniche S030

La migration conclusiva della S030 è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Il reset completo del database locale mediante:

```text
supabase db reset
```

è stato completato con successo applicando da zero l'intera catena delle migration.

Il lint del database ha restituito, sia sul perimetro verificato localmente sia sul remoto:

```text
No schema errors found
```

Gli acceptance test delle Tranche 10 e 11 sono stati superati e le relative fixture sono state sottoposte a rollback.

La verifica Flutter finale ha prodotto:

```text
dart format lib test
Formatted 174 files

flutter analyze
No issues found

flutter test
953 test superati
```

Il valore:

```text
Formatted 174 files
```

rappresenta l'output del comando di formattazione e non implica che tutti i 174 file siano stati modificati.

Lo smoke test Edge ha verificato:

- Dashboard raggiungibile;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto “Nessuna varietà presente” corretto;
- assenza del precedente pulsante di aggiunta varietà;
- gestione corretta del profilo senza Garden;
- impossibilità di eseguire il test manuale di aiuole e planting esclusivamente per assenza di un Garden nel profilo utilizzato.

La migration finale è stata applicata anche al database remoto.

Alla verifica conclusiva della fase sviluppo:

```text
local  = 20260923154831
remote = 20260923154831
```

Il commit tecnico conclusivo è:

```text
f9f5830796ecc16a14ef1b3fb4ce26bd081846b5
Completa il cutover del catalogo agronomico globale
```

## Timing e progressivi S030

La fase sviluppo S030 è conclusa con:

```text
21 h 06 min
```

La fase Manuali S030 è conclusa con:

```text
6 h 13 min
```

Il tempo complessivo della Sessione S030 è:

```text
Sviluppo        21 h 06 min
Documentazione   6 h 13 min
--------------------------
Totale          27 h 19 min
```

I progressivi definitivi alla chiusura della S030 sono:

```text
Sviluppo complessivo        168 h 39 min
Documentazione complessiva   60 h 24 min
----------------------------------------
Totale progetto             229 h 03 min
```

La Sessione S030 è quindi conclusa sia nella fase di sviluppo sia nella fase documentale.

## Elementi FUTURE post-S031

La chiusura della S031 non implica il completamento dell'intero progetto né dell'intero sistema editoriale e amministrativo del Catalogo Agronomico.

La S031 ha completato l'integrazione operativa in lettura del Catalogo nel client Flutter e ha reso disponibile nella UI l'inizializzazione esplicita e confermata della Catalog Authority.

Rimangono aperti, tra gli altri:

- ricognizione tecnica delle funzioni e RPC disponibili per la gestione delle identità del Catalogo prima di scegliere il successivo Write Path;
- definizione e implementazione dei Write Path autoritativi necessari alla gestione delle identità del Catalogo;
- backend canonico delle consociazioni;
- UI amministrativa/editoriale completa del Catalogo Agronomico;
- workflow operativo di ingestion/import/review in `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- schermate del workflow editoriale;
- integrazione completa del Resolver nella creazione e pianificazione dei planting;
- selezione esplicita del cultivar nel flusso di creazione dei planting;
- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;
- smoke test con dati operativi reali;
- manutenzione periodica ISO 3166-1 alpha-2 mediante migration e test verificati, mai automatica;
- verifica o ripristino del percorso UI per la creazione del primo Garden;
- completamento delle ulteriori entità previste dalla baseline Database V1;
- hard delete amministrativo o tecnico eccezionale dei planting, escluso dal normale flusso operativo.

Il primo passo previsto per la S032 è una ricognizione tecnica delle funzioni e RPC già disponibili per la gestione delle identità del Catalogo.

La S032 non parte con una decisione preventiva tra:

```text
creazione coltura
oppure
creazione cultivar
```

La scelta del primo Write Path da implementare dovrà derivare dalla ricognizione tecnica e dal contratto autoritativo effettivamente disponibile.

Nell'evoluzione successiva devono essere preservati i principi consolidati:

```text
backend autoritativo
Catalog Authority
can_manage_identity
normalizzazione
unicità
tassonomia
tracciabilità
gerarchia Crop → Cultivar
separazione dati candidati / dati approvati
```

Il workflow editoriale futuro deve mantenere la separazione:

```text
Aggiornamento fonti
        ↓
acquisizione dati candidati
        ↓
revisione
        ↓
approvazione / pubblicazione
        ↓
Catalogo Agronomico
```

I dati provenienti da fonti esterne non devono sovrascrivere automaticamente il Catalogo approvato.

Il database deve rimanere privo di dati demo, provvisori o di prova fino all'avvio della gestione reale dell'orto.

In particolare, l'avvio della S032 non prevede il popolamento del Catalogo con ortaggi o cultivar di esempio.

Il popolamento reale del Catalogo dovrà iniziare soltanto quando il relativo workflow sarà sufficientemente sicuro, verificato e tracciabile da consentire l'inserimento di dati reali e agronomicamente controllati.

La sequenza operativa prevista per l'avvio reale rimane:

```text
1. verifica database locale pulito
2. verifica separata dello stato del database remoto
3. caricamento del Catalogo Agronomico verificato
4. creazione del Garden reale
5. creazione delle 15 aiuole reali
6. apertura della stagione reale
7. registrazione dei planting reali
```

Il popolamento reale del Catalogo dovrà avvenire soltanto su una baseline agronomica verificata e approvata.

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