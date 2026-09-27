# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 2.3

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 27/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 2.3 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 27/09/2026 |

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
| 2.1 | 17/09/2026 | Aggiornamento dopo la Sessione S028: implementazione del modello e Write Path autoritativo di `plantings`, lifecycle server-side, geometria e overlap spaziale/temporale, protezione delle geometrie delle aiuole mediante `blocked_by_plantings`, integrazione Flutter e verifica con 997/997 test; definizione preliminare della S029 come lifecycle e varietà delle coltivazioni, non ancora iniziata |
| 2.2 | 18/09/2026 | Aggiornamento dopo la Sessione S029: completamento della UI del lifecycle di `plantings`, gestione esplicita di `end_date` per gli stati terminali, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`; nessuna modifica al contratto persistente S028; consolidamento preparatorio del futuro Catalogo Agronomico V1 e della possibile S030, non ancora iniziata |
| 2.3 | 27/09/2026 | Aggiornamento dopo la Sessione S030: completamento dell'architettura e del cutover del Catalogo Agronomico V1 globale, introduzione di identità botaniche canoniche, Catalog Authority, fonti e acquisizioni, workflow editoriale, Knowledge agronomica canonica, pubblicazione e Resolver; migrazione finale a `botanical_taxa` → `crops` → `crop_cultivars`, integrazione Flutter, deploy remoto e verifica finale con 953 test superati; riallineamento delle attività future alla fase successiva alla S030 |

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
| Architettura Catalogo Agronomico V1 globale | ✅ Completato |
| Identità botaniche canoniche globali | ✅ Completato |
| Catalog Authority e capability autoritative | ✅ Completato |
| Fonti, acquisizioni e osservazioni agronomiche | ✅ Completato |
| Workflow editoriale agronomico | ✅ Completato |
| Knowledge agronomica canonica | ✅ Completato |
| Pubblicazione e versionamento della Knowledge | ✅ Completato |
| Resolver del Catalogo Agronomico | ✅ Completato |
| Cutover canonico `botanical_taxa` → `crops` → `crop_cultivars` | ✅ Completato |
| UI editoriale/amministrativa completa del Catalogo Agronomico | 📋 Pianificato |
| Workflow operativo di aggiornamento/importazione delle fonti | 📋 Pianificato |
| Popolamento verificato del Catalogo Agronomico | 📋 Pianificato |

Il completamento del Catalogo Agronomico V1 nella S030 riguarda l'architettura, il modello persistente, i Write Path autoritativi, il workflow editoriale, la pubblicazione, il Resolver, il cutover finale e la relativa integrazione tecnica.

Il Catalogo non è ancora popolato con una baseline agronomica destinata all'uso reale dell'orto. I dati esterni dovranno essere acquisiti come dati candidati, revisionati e approvati prima dell'utilizzo operativo.

Il completamento del Catalogo Agronomico V1 non coincide inoltre con il completamento dell'intero Database V1, la cui implementazione rimane incrementale.

---

## 3.2 Gestione orto

| Funzionalità | Stato |
|--------------|:-----:|
| Elenco aiuole | ✅ Completato |
| Visualizzazione aiuola | ✅ Completato |
| Ordinamento aiuole | ✅ Completato |
| Creazione aiuole | ✅ Completato |
| Modifica dati aiuola | ✅ Completato |
| Attivazione/disattivazione aiuola | ✅ Completato |
| Variazione geometria aiuola | ✅ Completato |
| Correzione storica geometria | ✅ Completato |
| Inserimento coltivazioni | ✅ Completato |
| Modifica coltivazioni | ✅ Completato |
| Modello persistente autoritativo `plantings` | ✅ Completato |
| Write Path autoritativo `plantings` | ✅ Completato |
| Lifecycle server-side delle coltivazioni | ✅ Completato |
| UI lifecycle delle coltivazioni | ✅ Implementata e testata |
| Gestione `end_date` terminale | ✅ Completato |
| Refresh autoritativo su conflitti/transizioni non valide | ✅ Completato |
| Migrazione `plantings` da varietà legacy a cultivar canonica | ✅ Completato |
| Selezione operativa della cultivar nelle coltivazioni | 📋 Pianificato |
| Verifica/ripristino del flusso UI di creazione del primo Garden | 📋 Da verificare |
| Hard delete ordinario delle coltivazioni | 💡 Escluso dal normale flusso / FUTURE amministrativo |

La UI del lifecycle delle coltivazioni è stata implementata e verificata mediante test automatici nella S029. Questo non equivale al completamento dell'intero flusso operativo dell'interfaccia dell'orto.

Nel test manuale conclusivo della S030 il profilo utilizzato non disponeva di un Garden; di conseguenza non è stato possibile raggiungere e verificare manualmente il percorso completo Garden → aiuole → coltivazioni. Rimane quindi aperta la verifica o il ripristino della raggiungibilità UI della creazione del primo Garden.

Dopo il cutover S030, `plantings` utilizza `crop_id` e l'eventuale `cultivar_id`. L'interfaccia di creazione non espone ancora la selezione operativa della cultivar: una nuova coltivazione viene attualmente creata senza cultivar esplicita, mentre in modifica viene preservato l'eventuale `cultivar_id` già presente.

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
| Stagionalità di colture e varietà | ✅ V1 completata | Obiettivo storico S016: le finestre agronomiche sono associabili a colture e varietà secondo il modello applicativo allora vigente. Il riallineamento completo al Catalogo Agronomico S030 resta evolutivo. |
| CropAgronomicWindowRule | ✅ Completato | Modello storico S016 per associare una `AgronomicWindow` a una coltura e, opzionalmente, a una specifica varietà. Il modello precede il cutover canonico S030. |
| AgronomicWindowResolver | ✅ V1 completata | Resolver storico S016 basato sul fallback varietà specifica → coltura generale → nessuna regola. È distinto dal Resolver del Catalogo Agronomico introdotto nella S030. |
| AgronomicWindowEvaluation | ✅ Completato | Risultato strutturato introdotto nella S016 per distinguere gli stati `compatible`, `incompatible` e `unknown`, evitando di interpretare l'assenza di dati come incompatibilità. |
| AgronomicWindowService | ✅ V1 completata | Servizio introdotto nella S016 per coordinare `AgronomicWindowResolver` e `AgronomicWindowEngine` nella valutazione stagionale dei `PlannedPlantingBatch`. |
| Progettazione della persistenza delle regole agronomiche | ✅ Completato | Obiettivo S017 completato nell'ambito della progettazione Database V1. L'implementazione e il riallineamento delle regole persistenti al Catalogo Agronomico corrente restano incrementali. |
| Integrazione completa del Resolver S030 nei flussi di pianificazione e inserimento | 📋 Pianificato | Il Resolver canonico è disponibile a livello di Catalogo; la sua integrazione completa nei flussi operativi rimane FUTURE. |
| Backend canonico delle consociazioni | 📋 Pianificato | Il motore applicativo esiste, ma il backend canonico del Catalogo per le associazioni tra colture non è ancora implementato. |

I componenti agronomici realizzati nelle sessioni precedenti alla S030 restano risultati tecnici validi delle rispettive fasi di sviluppo. La loro terminologia storica non viene riscritta retroattivamente.

Il Catalogo Agronomico S030 introduce tuttavia un nuovo contratto canonico globale. L'integrazione progressiva dei motori agronomici con `botanical_taxa`, `crops`, `crop_cultivars`, Knowledge pubblicata e Resolver costituisce quindi un'evoluzione successiva e deve evitare nuove dipendenze dal modello legacy.

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

## Stato dopo la Sessione S028

La Sessione S028 ha completato il modello persistente e il **Write Path autoritativo di `plantings`**.

La sequenza tecnica consolidata è ora:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
        ↓
plantings
```

Tutti e quattro i livelli risultano ora implementati lato PostgreSQL/Supabase.

Il Catalogo V1 dispone inoltre del relativo Repository Layer Flutter.

`plantings` dispone ora del modello persistente, del Write Path autoritativo e dell'integrazione Flutter necessaria alla creazione e modifica delle coltivazioni.

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

- assenza di eliminazione fisica applicativa ordinaria del catalogo;

- concorrenza ottimistica mediante `row_version`;

- locking server-side e gerarchico dove necessario;

- nove RPC autoritative del Catalogo V1:

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

- compatibilità legacy temporanea mediante:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

La Sessione S028 ha inoltre introdotto:

```text
public.plantings
```

come modello persistente autoritativo delle coltivazioni reali.

Il modello comprende:

```text
id
profile_id
garden_id
season_id
bed_id
crop_id
variety_id
start_method
start_date
end_date
start_position_cm
length_cm
plant_spacing_cm
row_spacing_cm
rows_count
occupied_width_cm
plants_count
seed_quantity_g
status
notes
created_at
updated_at
row_version
```

Sono stati consolidati i quattro metodi persistenti:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il valore:

```text
manual
```

rimane esclusivamente un concetto applicativo relativo al posizionamento e non costituisce un metodo agronomico persistito.

Sono state introdotte le migration:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

e le RPC:

```text
create_planting
update_planting
set_planting_status
```

Il Write Path applicativo segue:

```text
UI
        ↓
PlantingRepository
        ↓
Profile Write Authority
        ↓
RPC autoritativa
        ↓
PostgreSQL
```

Le scritture ordinarie di `plantings` sono quindi RPC-only.

La concorrenza ottimistica utilizza:

```text
row_version
```

e il controllo della versione attesa quando previsto dal contratto della RPC.

La geometria longitudinale utilizza intervalli half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

La disposizione delle file deve rispettare:

```text
(rows_count - 1) * row_spacing_cm <= occupied_width_cm
```

La disposizione delle piante deve rispettare:

```text
(plants_count - 1) * plant_spacing_cm <= length_cm
```

Il controllo utilizza il numero totale di piante.

Una sovrapposizione viene rifiutata quando sono contemporaneamente presenti:

```text
overlap temporale
+
overlap longitudinale
```

La geometria di una coltivazione deve inoltre essere compatibile con tutte le geometrie dell'aiuola temporalmente interessate dalla sua occupazione.

Le RPC:

```text
change_bed_geometry
correct_bed_geometry
```

sono state rafforzate e possono restituire:

```text
blocked_by_plantings
```

quando una variazione geometrica renderebbe incompatibili coltivazioni già persistite.

## Lifecycle di `plantings`

Il lifecycle autoritativo server-side è implementato.

Gli stati previsti sono:

```text
sown
growing
harvest_ready
harvested
finished
removed
```

Le transizioni ammesse sono:

```text
sown          → growing | removed
growing       → harvest_ready | removed
harvest_ready → harvested | removed
harvested     → finished | removed
finished      → nessuna
removed       → nessuna
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

Con la Sessione S029 anche l'esperienza UI del lifecycle è stata completata.

`PlantingCard` espone azioni contestuali coerenti con lo stato corrente e inoltra le richieste mediante:

```text
onStatusChange
```

a:

```text
BedPage
```

Il flusso applicativo consolidato è:

```text
PlantingCard
        ↓
BedPage
        ↓
PlantingRepository.setPlantingStatus
        ↓
set_planting_status
        ↓
PostgreSQL
```

Le transizioni intermedie:

```text
sown → growing
growing → harvest_ready
harvest_ready → harvested
```

mantengono:

```text
end_date = null
```

Le transizioni terminali:

```text
harvested → finished
* → removed
```

richiedono invece una conferma esplicita di:

```text
end_date
```

La UI propone inizialmente il giorno corrente, lasciandolo modificabile entro i limiti:

```text
end_date >= start_date
end_date <= giorno corrente
```

La S029 ha inoltre introdotto la rilettura autoritativa delle coltivazioni in presenza degli esiti:

```text
version_conflict
invalid_transition
```

prima di informare l'utente.

PostgreSQL continua a essere l'autorità definitiva per la validità delle transizioni, le autorizzazioni, la concorrenza e la validazione della data terminale.

La Sessione S029 non ha introdotto nuove migration, nuove RPC, modifiche RLS o variazioni del contratto persistente S028.

## Integrazione Flutter S028

Sono stati riallineati al contratto S028:

```text
Planting
PlantingRepository
AddPlantingPage
BedPage
GardenPage
GardenMap
PlantingCard
RotationEngine
```

È stato introdotto:

```text
PlantingWriteResult
```

per il mapping tipizzato degli esiti del Write Path.

`PlantingRepository` espone:

```text
getPlantingsByBed
createPlanting
updatePlanting
setPlantingStatus
```

La pagina di inserimento è stata riallineata ai quattro metodi di avvio persistenti e alle regole di geometria, date e quantità previste dal contratto Database V1.

La verifica finale S028 ha prodotto:

```text
flutter analyze
No issues found!
```

```text
flutter test
997/997 test superati
```

La ricostruzione locale del database è stata verificata mediante:

```text
supabase db reset
```

e il controllo dello schema mediante:

```text
supabase db lint --local
```

senza errori.

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**, poiché la baseline completa delle 52 entità non è ancora fisicamente implementata.

## Integrazione Flutter S029

La Sessione S029 ha completato l'integrazione applicativa del lifecycle di `plantings`.

Sono stati aggiornati principalmente:

```text
PlantingCard
BedPage
test/pages/bed_page_test.dart
```

ed è stato introdotto:

```text
test/widgets/planting_card_test.dart
```

`PlantingCard` espone ora le sole azioni lifecycle coerenti con lo stato corrente.

Sono stati eliminati dal normale flusso:

```text
Elimina
onDelete
planned
```

come elementi del precedente comportamento applicativo.

`BedPage` utilizza:

```text
PlantingRepository.setPlantingStatus
```

senza scritture dirette sulla tabella.

La verifica tecnica finale S029 ha prodotto:

```text
flutter test finale:
1011/1011 test passati

bed_page_test.dart:
30/30 test passati

planting_card_test.dart finale:
9/9 test passati

flutter analyze finale:
No issues found! (ran in 12.8s)
```

Il dato di 1011 test rappresenta la suite completa finale effettivamente eseguita dopo l'aggiunta dell'ultimo test dedicato a `PlantingCard`.

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**, poiché la baseline completa delle 52 entità non è ancora fisicamente implementata.

## Sessione S029 completata

La pianificazione preliminare:

```text
S029 — Lifecycle e varietà delle coltivazioni
```

ha portato all'effettiva Sessione S029, svolta il:

```text
17/09/2026
```

La fase sviluppo è stata completata in:

```text
1 h 19 min
```

La sessione ha completato:

1. visualizzazione in UI delle sole transizioni lifecycle consentite;

2. utilizzo di:

```text
set_planting_status
```

come Write Path autoritativo delle transizioni;

3. gestione esplicita di:

```text
end_date
```

per:

```text
finished
removed
```

4. proposta del giorno corrente come valore iniziale di `end_date`, mantenendolo modificabile;

5. assenza di chiusura implicita della coltivazione;

6. evidenza applicativa che:

```text
harvested
```

continua a occupare l'aiuola;

7. rilascio dello spazio soltanto mediante:

```text
finished
removed
```

8. gestione degli esiti RPC;

9. gestione di:

```text
version_conflict
invalid_transition
```

10. refresh autoritativo delle coltivazioni dopo tali esiti;

11. test dedicati al lifecycle e alla gestione terminale.

Non è stata invece implementata durante S029 la selezione facoltativa della varietà.

Rimangono quindi aperti:

- selezione della varietà nel flusso operativo delle coltivazioni;
- mantenimento e gestione applicativa della varietà;
- progressiva eliminazione delle dipendenze legacy;
- UI amministrativa completa del Catalogo V1.

La Sessione S029 non ha modificato il Database V1.

Non sono state introdotte:

```text
migration
nuove tabelle
nuove colonne
nuove RPC
modifiche RLS
```

## Hard delete di `plantings`

Il normale flusso operativo non deve prevedere l'eliminazione definitiva di una coltivazione.

Gli stati:

```text
finished
removed
```

rappresentano le chiusure ordinarie del ciclo di vita.

Un eventuale hard delete rimane classificato:

```text
FUTURE
```

e dovrà essere disponibile esclusivamente come correzione amministrativa o tecnica eccezionale per record inseriti per errore.

Non dovrà essere disponibile nel normale flusso operativo dell'orto.

## Catalogo Agronomico

La Sessione S030 ha completato l'architettura tecnica e il cutover del **Catalogo Agronomico V1 globale**.

Il Catalogo è separato dai dati operativi del singolo orto e utilizza identità canoniche globali.

Il modello canonico corrente è basato sulla catena:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

La S030 ha inoltre introdotto e verificato:

- identità botaniche globali;
- normalizzazione canonica dei testi del Catalogo;
- Catalog Authority globale con capability distinte;
- registro dei parametri agronomici;
- vocabolari e contesti agronomici;
- fonti, acquisizioni e osservazioni;
- alias e riconciliazione delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- integrità e sicurezza del Catalogo;
- pubblicazione e versionamento;
- Resolver canonico;
- Write Path autoritativi;
- read model canonici;
- cutover finale dal modello legacy;
- integrazione tecnica Flutter necessaria al nuovo contratto.

Il perimetro del Catalogo Agronomico introdotto nella S030 comprende complessivamente **26 tabelle**.

Le precedenti strutture:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

sono state eliminate nel cutover finale.

I `plantings` utilizzano ora:

```text
crop_id
cultivar_id opzionale
```

con riferimento alle identità canoniche del Catalogo.

### Separazione tra fonti esterne e Catalogo approvato

Rimane valido e viene consolidato il principio secondo cui i dati provenienti da fonti esterne non possono diventare automaticamente dati canonici utilizzabili dall'applicazione.

Il flusso previsto è:

```text
Fonte esterna
        ↓
acquisizione / ingestion
        ↓
osservazione / dato candidato
        ↓
revisione editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Catalogo utilizzabile
```

L'importazione o lo scraping:

```text
NON
```

devono scrivere direttamente o sovrascrivere automaticamente il Catalogo Agronomico approvato.

Le informazioni acquisite devono rimanere tracciabili rispetto alla fonte e attraversare il workflow editoriale previsto prima della pubblicazione.

La funzione operativa di aggiornamento delle fonti rimane prevista in:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Aggiornamento fonti
```

La relativa UI e il flusso operativo completo di acquisizione, revisione e pubblicazione restano da implementare.

### Popolamento del Catalogo

Il completamento tecnico della S030 non costituisce popolamento agronomico del Catalogo.

Il database deve continuare a rimanere privo di dati dimostrativi, provvisori o inseriti esclusivamente per simulare il funzionamento dell'applicazione.

Prima dell'avvio della gestione reale dell'orto dovrà essere predisposta una baseline del Catalogo Agronomico composta esclusivamente da dati:

- reali;
- verificabili;
- tracciabili rispetto alle fonti;
- revisionati secondo il workflow previsto;
- approvati per l'utilizzo operativo.

La **carota** rimane un possibile primo caso pilota per verificare il processo completo di acquisizione, revisione, pubblicazione e utilizzo dei dati agronomici.

Gli eventuali dati precedentemente raccolti a titolo preparatorio non costituiscono automaticamente dati approvati del Catalogo.

---

## Consolidamento post-S030

Il cutover S030 ha eliminato le principali dipendenze persistenti dal precedente modello personale del Catalogo.

Nel contratto canonico corrente non devono essere reintrodotte nuove dipendenze da:

```text
botanical_families
crop_varieties
CropVariety
variety_id
```

La terminologia tecnica corrente utilizza:

```text
botanical_taxa
crops
crop_cultivars
CropCultivar
cultivar_id
```

La parola italiana **“Varietà”** può continuare a essere utilizzata nell'interfaccia utente quando è la formulazione più naturale per l'utilizzatore.

Rimane da completare il riallineamento progressivo dei componenti agronomici e dei consumer applicativi storici che precedono il nuovo contratto S030.

In particolare, i motori agronomici sviluppati nelle sessioni precedenti devono essere integrati progressivamente con:

- identità canoniche globali;
- Knowledge agronomica pubblicata;
- Resolver del Catalogo;
- eventuali snapshot operativi necessari alla conservazione storica delle decisioni.

Le nuove evoluzioni non devono introdurre ulteriori dipendenze dal modello legacy.

---

## Altri blocchi futuri

Restano pianificati o aperti dopo la S030:

- backend canonico per le consociazioni tra colture;

- UI editoriale e amministrativa completa del Catalogo Agronomico;

- azione UI esplicita e protetta per l'inizializzazione della Catalog Authority mediante `claim_initial_catalog_authority()`;

- workflow operativo di acquisizione/importazione delle fonti in:
  `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;

- schermate del workflow editoriale;

- integrazione completa del Resolver del Catalogo nei flussi di pianificazione e inserimento delle coltivazioni;

- selezione operativa della cultivar durante la creazione delle coltivazioni;

- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;

- smoke test con dati operativi reali dopo l'avvio della gestione effettiva dell'orto;

- manutenzione periodica controllata dei dati ISO 3166-1 alpha-2 mediante migration e test verificati, senza aggiornamenti automatici non revisionati;

- verifica o ripristino della raggiungibilità UI della creazione del primo Garden;

- creazione delle 15 aiuole reali dopo l'avvio operativo;

- apertura della stagione reale;

- registrazione delle coltivazioni reali;

- operazioni amministrative protette su `profile_memberships`;

- prosecuzione dell'implementazione incrementale delle restanti entità del Database V1;

- riallineamento progressivo dei motori agronomici storici al Catalogo canonico S030;

- evoluzione successiva delle aree:
  - irrigazione;
  - attività;
  - dashboard;
  - statistiche.

L'hard delete dei `plantings` rimane escluso dal normale flusso applicativo. Potrà essere valutato esclusivamente come futura funzione amministrativa o tecnica protetta per la correzione di record inseriti per errore.

---

## Avvio della fase operativa reale

Il completamento tecnico del Catalogo Agronomico S030 non autorizza l'introduzione di dati dimostrativi o provvisori nel database.

La sequenza prevista per il passaggio all'utilizzo reale rimane:

1. verificare che il database locale sia nello stato atteso e privo di dati provvisori;

2. verificare separatamente lo stato del database remoto;

3. predisporre e pubblicare una baseline verificata del Catalogo Agronomico;

4. creare il Garden reale;

5. creare le 15 aiuole reali;

6. aprire la stagione reale;

7. registrare le coltivazioni reali.

Il popolamento operativo deve quindi iniziare soltanto quando il Catalogo dispone di una baseline sufficientemente verificata e approvata.

---

## Prossimo incremento

La **Sessione S030 è completata nella fase di sviluppo**.

Sono stati completati:

- architettura del Catalogo Agronomico V1 globale;
- implementazione SQL/Supabase;
- Write Path autoritativi;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione e Resolver;
- cutover finale;
- integrazione Flutter necessaria;
- deploy remoto;
- verifiche database;
- analisi Flutter;
- suite automatica finale con **953 test superati**;
- smoke test applicativo conclusivo compatibile con lo stato privo di dati reali.

Il commit tecnico conclusivo della S030 è:

```text
f9f5830796ecc16a14ef1b3fb4ce26bd081846b5
```

La migration conclusiva è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Lo schema locale e quello remoto risultavano allineati alla migration conclusiva al termine della sessione di sviluppo.

Il prossimo incremento tecnico **non viene assegnato automaticamente** dalla Roadmap.

Prima dell'avvio di una nuova sessione di sviluppo dovranno essere definiti e approvati il relativo perimetro e il prossimo passo tecnico, scegliendo tra le attività FUTURE e APERTE documentate.

Rimane prioritario preservare i principi consolidati:

```text
nessun dato demo o provvisorio
        ↓
Catalogo verificato
        ↓
dati reali dell'orto
```

e:

```text
fonte esterna
        ↓
dato candidato
        ↓
revisione
        ↓
pubblicazione
        ↓
dato canonico utilizzabile
```

Nessuna nuova sessione di sviluppo viene considerata iniziata fino alla sua apertura esplicita.
