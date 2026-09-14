# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 2.0

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 14/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 2.0 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 14/09/2026 |

---

# Cronologia delle revisioni

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
| 1.8 | 06/09/2026 | Aggiornamento dopo la Sessione S025: completamento dell’integrazione Flutter dei Write Path autoritativi di `beds`, introduzione delle interfacce di modifica e gestione geometrica, gestione italiana delle date, rilettura autoritativa e verifica con 841/841 test superati |
| 1.9 | 11/09/2026 | Aggiornamento dopo la Sessione S026: implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, nove RPC autoritative, RLS, Profile Write Authority, concorrenza ottimistica, validazioni gerarchiche e agronomiche e definizione della S027 come integrazione Flutter del Catalogo V1 |
| 2.0 | 14/09/2026 | Aggiornamento dopo la Sessione S027: completamento dell'integrazione Flutter del Catalogo V1, introduzione di `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository e result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version`, compatibilità legacy controllata e verifica con 914/914 test; prossimo incremento tecnico non ancora approvato |

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

L'ordine di realizzazione può variare in funzione delle esigenze del progetto e delle decisioni architetturali approvate durante lo sviluppo.

## Stato dopo la Sessione S027

La Sessione S027 ha completato l'integrazione Flutter del **Catalogo DB V1** introdotto nella S026.

La sequenza tecnica consolidata rimane:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
        ↓
plantings
```

I primi tre livelli risultano ora implementati sia lato PostgreSQL/Supabase sia nel Repository Layer Flutter.

Risultano completati:

- primo blocco Fondazioni della baseline Database V1;

- schema `private`, helper autorizzativi, trigger metadata e prima matrice RLS;

- protocollo server-side completo di `profile_edit_locks`;

- Profile Write Authority server-side;

- integrazione Flutter fail-closed della Profile Write Authority;

- Write Path autoritativo di `gardens`;

- Write Path autoritativo di `seasons`;

- implementazione di:
  - `beds`;
  - `bed_geometries`;
  - `bed_geometry_corrections`;

- Write Path autoritativo di `beds`;

- integrazione Flutter completa dei Write Path disponibili per `beds`;

- Catalogo DB V1 composto da:

```text
botanical_families
crops
crop_varieties
```

- ownership del catalogo a livello Profile;

- condivisione del catalogo tra i Gardens appartenenti allo stesso Profile;

- identificativi UUID per le entità del Catalogo DB V1;

- separazione della Crop Variety come entità autonoma;

- relazione persistente Crop → Botanical Family mediante `botanical_family_id`;

- relazione persistente Crop Variety → Crop mediante `crop_id`;

- `default_start_method` con valori canonici;

- fallback agronomico Crop → Crop Variety;

- gestione quantitativa del fabbisogno idrico;

- gestione strutturata della resa prevista;

- validazioni server-side di gerarchia, temperature, acqua, resa e unicità;

- regole di attivazione, disattivazione e riattivazione coerenti con la gerarchia;

- immutabilità di `crop_varieties.crop_id`;

- assenza di eliminazione fisica applicativa del catalogo;

- concorrenza ottimistica mediante `row_version`;

- locking server-side e gerarchico dove necessario;

- nove RPC autoritative:

```text
create_botanical_family
update_botanical_family
set_botanical_family_active

create_crop
update_crop
set_crop_active

create_crop_variety
update_crop_variety
set_crop_variety_active
```

- RLS in lettura mediante membership del Profile;

- revoca delle scritture dirette sulle entità protette;

- principio:

> **catalogo corrente + snapshot storico**

- modello Flutter:

```text
BotanicalFamily
```

- riallineamento al Database V1 dei modelli:

```text
Crop
CropVariety
```

- Repository Flutter:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

- letture del Catalogo V1 sotto protezione RLS;

- scritture del Catalogo V1 esclusivamente tramite RPC autoritative;

- integrazione della Profile Write Authority nei Repository del catalogo;

- gestione applicativa di `row_version`;

- result type dedicati e mapping esplicito degli status RPC;

- comportamento fail-closed degli esiti non riconosciuti o non confermabili;

- rimozione di `CropVariety.toMap()` per evitare un percorso generico di scrittura diretta;

- verifica dell'assenza nei Repository del catalogo di:

```text
.insert()
.update()
.delete()
.upsert()
```

- compatibilità legacy temporanea mediante:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

- suite mirata del Catalogo V1:

```text
124 test superati
```

- suite Flutter completa:

```text
914/914 test superati
```

- `flutter analyze` con risultato:

```text
No issues found!
```

La Sessione S027 non ha introdotto nuove migration Supabase.

Le migration locali e remote rimangono allineate fino a:

```text
20260911091047_add_crop_catalog_write_rpcs.sql
```

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**, poiché la baseline completa delle 52 entità non è ancora fisicamente implementata.

`public.plantings` rimane non implementata.

## Blocchi tecnici ancora aperti

Alla conclusione della S027 risultano aperti due principali incrementi tecnici distinti.

### UI minima di gestione del Catalogo V1

Il Catalogo V1 dispone ora del modello persistente, delle RPC e del Repository Layer Flutter, ma non di una UI amministrativa dedicata completa.

Un possibile incremento successivo consiste quindi nell'introdurre la minima interfaccia necessaria per:

- gestione delle famiglie botaniche;
- gestione delle colture;
- gestione delle varietà;
- attivazione e disattivazione;
- utilizzo dei Write Path autoritativi già disponibili.

Questo incremento riguarda esclusivamente l'interfaccia e non richiede la ridefinizione del contratto persistente già consolidato.

### Write Path autoritativo di `plantings`

Il secondo principale incremento consiste nell'implementazione di:

```text
public.plantings
```

secondo il contratto Database V1.

L'implementazione dovrà rispettare:

- Profile ownership;
- relazioni con Garden, Bed, Crop e Crop Variety;
- Profile Write Authority;
- RLS;
- RPC autoritative;
- concorrenza;
- invarianti;
- eventuale storicizzazione richiesta dal contratto Database V1;
- integrazione Flutter;
- compatibilità con il Motore Agronomico.

Il prerequisito precedentemente fissato dalla S026 è ora soddisfatto:

> il Catalogo DB V1 è integrato nel client Flutter.

Ciò rende tecnicamente possibile affrontare `plantings`, ma **non determina automaticamente che questo debba essere il prossimo incremento**.

## Consolidamento legacy

Prima o durante i successivi incrementi dovrà essere gestita anche la compatibilità residua con il modello applicativo precedente.

Rimangono da affrontare:

- adattatore esplicito tra `defaultStartMethod` e i planting method legacy;

- migrazione dei consumer ancora dipendenti da:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

- successiva rimozione degli alias legacy quando non saranno più necessari.

Gli alias mantenuti nella S027 sono temporanei e non devono diventare nuove dipendenze architetturali.

## Altri blocchi futuri

Restano inoltre pianificati:

- operazioni amministrative protette su `profile_memberships`;

- persistenza di `agronomic_window_rules`;

- prosecuzione dell'implementazione incrementale delle restanti entità Database V1;

- integrazione progressiva del principio **catalogo corrente + snapshot storico** nei dati decisionali;

- evoluzione successiva delle aree irrigazione, attività, dashboard e statistiche.

## Prossimo incremento

Alla conclusione della S027 **non viene dichiarata una S028 né viene fissato automaticamente il prossimo blocco tecnico**.

I due candidati principali sono:

```text
A. UI minima di gestione del Catalogo V1

B. Write Path autoritativo di plantings
```

La scelta dovrà essere effettuata esplicitamente all'avvio della successiva sessione di sviluppo sulla base delle dipendenze, del valore operativo e del rischio tecnico.

Fino a tale decisione entrambi i blocchi rimangono:

> **APERTO / PIANIFICATO**