# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 2.2

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 18/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 2.2 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 18/09/2026 |

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
| UI lifecycle delle coltivazioni | ✅ Completato |
| Gestione `end_date` terminale | ✅ Completato |
| Refresh autoritativo su conflitti/transizioni non valide | ✅ Completato |
| Selezione varietà nelle coltivazioni | 📋 Pianificato |
| Verifica flusso UI di creazione del primo Garden | 📋 Da verificare |
| Hard delete ordinario delle coltivazioni | 💡 Escluso dal normale flusso / FUTURE amministrativo |

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

La UI amministrativa del Catalogo V1 rimane un blocco distinto.

Prima dell'utilizzo operativo dei dati agronomici dovrà essere definito e verificato un **Catalogo Agronomico V1 strutturato, tracciabile e versionabile**.

Non devono essere introdotti popolamenti manuali ad hoc o dati provvisori destinati a essere utilizzati come baseline operativa.

Il database deve rimanere privo di dati di prova o provvisori fino all'avvio della gestione reale dell'orto.

La preparazione successiva alla S029 ha consolidato il principio:

```text
Fonte esterna
        ↓
AgronomicImport
        ↓
dato candidato
        ↓
AgronomicReview
        ↓
AgronomicCatalog
```

L'acquisizione da fonti esterne e il Catalogo approvato devono quindi essere livelli distinti.

Lo scraping o l'importazione:

```text
NON
```

devono scrivere direttamente nel Catalogo Agronomico approvato.

I dati acquisiti devono essere prima memorizzati come dati candidati e sottoposti a revisione.

Gli stati preliminarmente previsti sono:

```text
DRAFT
REVIEW
APPROVED
ARCHIVED
```

Soltanto dati nello stato appropriato di approvazione potranno essere utilizzati operativamente.

Nessun dato esterno deve sovrascrivere automaticamente il Catalogo Agronomico approvato.

La funzione prevista per l'aggiornamento delle fonti sarà collocata in:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Aggiornamento fonti
```

La struttura dovrà distinguere chiaramente:

```text
coltura / specie
varietà / cultivar
origine commerciale
```

È inoltre previsto il principio di ereditarietà agronomica:

```text
Crop
        ↓
valore generale

CropVariety
        ↓
override specifico quando necessario
```

Ogni singolo valore agronomico dovrà mantenere informazioni sulla propria provenienza e sulla fonte utilizzata.

La gestione delle fonti dovrà quindi permettere di distinguere almeno:

```text
fonte
dato acquisito
dato candidato
revisione
dato approvato
versione
```

La **carota** è stata individuata come possibile primo caso pilota per validare il modello completo.

Gli eventuali valori agronomici già raccolti per tale coltura devono però essere considerati:

```text
CANDIDATI
NON APPROVATI
```

fino alla definizione e verifica del Catalogo Agronomico V1.

Questa progettazione preliminare è stata svolta fuori dal perimetro tecnico e dal timing della Sessione S029.

Non costituisce ancora implementazione del Catalogo e non costituisce avvio della Sessione S030.

## Consolidamento legacy

Rimane da completare la progressiva eliminazione delle dipendenze dal modello applicativo precedente.

Tra gli elementi ancora da affrontare figurano:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

Gli alias legacy:

- non rappresentano il nuovo contratto persistente;
- non devono essere utilizzati per introdurre nuove dipendenze;
- devono essere rimossi progressivamente dopo la migrazione dei relativi consumer.

## Altri blocchi futuri

Restano inoltre pianificati:

- operazioni amministrative protette su `profile_memberships`;

- persistenza di `agronomic_window_rules`;

- prosecuzione dell'implementazione incrementale delle restanti entità Database V1;

- integrazione progressiva del principio **catalogo corrente + snapshot storico** nei dati decisionali;

- UI amministrativa del Catalogo V1;

- Catalogo Agronomico strutturato e verificato;

- evoluzione successiva delle aree:
  - irrigazione;
  - attività;
  - dashboard;
  - statistiche.

## Prossimo incremento

La Sessione S029 è stata completata nella fase di sviluppo.

Il prossimo incremento tecnico non viene considerato automaticamente avviato né assegnato esclusivamente sulla base della roadmap.

Come preparazione preliminare è stata individuata come possibile Sessione successiva:

```text
S030 — Catalogo Agronomico V1
```

Lo stato è:

```text
PREPARAZIONE PRELIMINARE
NON INIZIATO
```

La possibile S030 dovrà iniziare con un checkpoint di ricezione e una ricognizione delle strutture già disponibili:

```text
crops
crop_varieties
regole e strutture agronomiche esistenti
```

Il percorso preliminare comprende:

1. verifica della baseline Database V1 esistente;

2. ricognizione delle strutture agronomiche attuali;

3. definizione dei requisiti del Catalogo Agronomico V1;

4. distinzione tra:
   - fonte;
   - dato importato;
   - dato candidato;
   - revisione;
   - valore approvato;

5. progettazione della tracciabilità:

```text
source
        ↓
candidate
        ↓
review
        ↓
catalog
```

6. stati:

```text
DRAFT
REVIEW
APPROVED
ARCHIVED
```

7. versionamento dei valori;

8. contestualizzazione geografica e produttiva;

9. relazione e compatibilità con `plantings`;

10. eventuale migration e relativi Write Path soltanto dopo approvazione della struttura;

11. futura UI amministrativa;

12. popolamento controllato esclusivamente con dati reali e verificati;

13. utilizzo della carota come possibile primo caso completo di verifica.

Rimane separato un altro punto aperto emerso durante la verifica applicativa:

```text
verifica della raggiungibilità UI
della creazione del primo Garden
```

Il Write Path di `gardens` esiste già dalla S022, ma deve essere verificato se la relativa pagina:

- esiste ed è raggiungibile;
- esiste ma il comando è nascosto;
- non è ancora integrata nel flusso corrente.

Questo punto non viene assegnato automaticamente alla S030.

La Sessione S030:

> **NON È ANCORA INIZIATA**

e dovrà essere avviata esplicitamente prima di qualsiasi modifica tecnica appartenente al suo eventuale perimetro.
