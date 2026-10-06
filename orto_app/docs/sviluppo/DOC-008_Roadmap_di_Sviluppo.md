# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 2.5

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 06/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 2.5 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 06/10/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione della Roadmap di Sviluppo |
| 0.2 | 27/07/2026 | Aggiornamento della roadmap dopo la Sessione S004 |
| 0.3 | 01/08/2026 | Revisione della struttura documentale e aggiornamento della roadmap |
| 1.0 | 01/08/2026 | Revisione completa e approvazione della Roadmap di Sviluppo |
| 1.1 | 08/08/2026 | Aggiornamento del Motore Agronomico e pianificazione delle evoluzioni successive |
| 1.2 | 16/08/2026 | Aggiornamento dopo la Sessione S017: completamento e congelamento della progettazione Database V1, pianificazione dell'implementazione incrementale in Supabase e riallineamento delle priorità di sviluppo |
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
| 2.4 | 01/10/2026 | Aggiornamento dopo la Sessione S031: integrazione operativa Flutter del Catalogo Agronomico nelle Impostazioni, gestione dello stato e dell'inizializzazione controllata della Catalog Authority, esposizione delle capability autoritative, consultazione delle colture globali, navigazione gerarchica `Coltura → Cultivar`, caricamento on demand delle cultivar, gestione degli stati di caricamento/assenza dati/errore/retry ed eliminazione del precedente percorso autonomo `Impostazioni → Varietà`; verifica finale con 971 test superati e definizione della ricognizione tecnica delle funzioni, RPC e capability del Catalogo come primo passo della S032 |
| 2.5 | 06/10/2026 | Aggiornamento dopo la Sessione S032: ricognizione e consolidamento del contratto backend del Catalogo Agronomico, verifica della tassonomia botanica globale con rank `ORDER`, `FAMILY`, `GENUS`, `SPECIES`, `SUBSPECIES`, `VARIETY`, `FORMA` e `UNRANKED`, conferma della Cultivar come identità agronomica separata, integrazione Flutter dei Write Path di Tassonomia, Crop e Cultivar, collegamento opzionale `Crop → Taxon`, completamento della UI della Classificazione botanica, gestione della Catalog Authority, concorrenza ottimistica mediante `row_version`, rilettura autoritativa su `version_conflict` ed esiti incerti e verifica finale con `flutter analyze` senza problemi e 1077/1077 test superati; nessuna nuova migration S032 e riallineamento della roadmap futura allo stato effettivamente raggiunto |

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
| Workflow editoriale agronomico backend | ✅ Completato |
| Knowledge agronomica canonica | ✅ Completato |
| Pubblicazione e versionamento della Knowledge | ✅ Completato |
| Resolver del Catalogo Agronomico | ✅ Completato |
| Cutover canonico `botanical_taxa` → `crops` → `crop_cultivars` | ✅ Completato |
| Integrazione Flutter del Catalogo nelle Impostazioni | ✅ Completato |
| Consultazione delle colture globali | ✅ Completato |
| Navigazione gerarchica `Coltura → Cultivar` | ✅ Completato |
| Caricamento on demand delle cultivar | ✅ Completato |
| Gestione UI di loading, empty state, errore e retry del Catalogo | ✅ Completato |
| Integrazione Flutter Write Path Tassonomia | ✅ Completato |
| Integrazione Flutter Write Path Crop | ✅ Completato |
| Integrazione Flutter Write Path Cultivar | ✅ Completato |
| UI completa della Classificazione botanica | ✅ Completato |
| UI completa di gestione Crop | 📋 Pianificato |
| UI completa di gestione Cultivar | 📋 Pianificato |
| UI operativa per alias, fonti, candidati, revisione e pubblicazione | 📋 Pianificato |
| Workflow operativo di aggiornamento/importazione delle fonti | 📋 Pianificato |
| Popolamento verificato del Catalogo Agronomico | 📋 Pianificato |

La S030 ha completato l'architettura del **Catalogo Agronomico V1 globale**, il modello persistente, i Write Path autoritativi previsti dal relativo workflow, la Catalog Authority, il workflow editoriale, la Knowledge canonica, la pubblicazione, il Resolver e il cutover finale al modello:

```text
botanical_taxa
→ crops
→ crop_cultivars
```

La S031 ha completato il primo incremento operativo Flutter successivo al cutover, introducendo il percorso:

```text
Impostazioni
→ Catalogo Agronomico
→ Colture
→ Cultivar
```

L'integrazione S031 comprende:

- lettura dello stato della Catalog Authority;
- inizializzazione controllata dell'authority quando consentita dal backend;
- visualizzazione delle capability autoritative;
- consultazione delle colture globali;
- caricamento delle cultivar soltanto dopo la selezione della coltura;
- gestione degli stati di caricamento, assenza dati, errore e retry;
- eliminazione del precedente percorso autonomo `Impostazioni → Varietà`.

La S032 ha eseguito la ricognizione tecnica del contratto backend effettivamente disponibile e ha verificato che il Catalogo dispone già dei Write Path autoritativi necessari alla gestione delle identità globali.

La tassonomia botanica globale utilizza i rank canonici:

```text
ORDER
FAMILY
GENUS
SPECIES
SUBSPECIES
VARIETY
FORMA
UNRANKED
```

`CULTIVAR` non costituisce un rank tassonomico. Le cultivar sono identità agronomiche globali separate, persistite in `crop_cultivars`.

La tassonomia supporta una classificazione parziale mediante `parent_taxon_id`: non è necessario introdurre artificialmente tutti i livelli intermedi quando non sono disponibili. Le regole relative a gerarchia, cicli, stato attivo e dipendenze rimangono autoritative lato backend.

La S032 ha integrato nel livello Flutter i Write Path di:

```text
Tassonomia
Crop
Cultivar
```

e ha completato la gestione UI della **Classificazione botanica**, comprendendo:

- lettura;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- applicazione della capability `can_manage_identity`;
- gestione degli stati di errore;
- rilettura dello stato autoritativo dopo conflitti o esiti incerti.

La terminologia UI consolidata per la tassonomia è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Il collegamento tra Crop e tassonomia è opzionale e segue il contratto:

```text
Crop → Taxon
```

La concorrenza ottimistica utilizza `row_version`.

In presenza di `version_conflict` l'applicazione non deve eseguire overwrite forzati né retry automatici. Deve invece rileggere lo stato autoritativo e presentare all'utente lo stato effettivamente persistito.

La stessa regola di sicurezza si applica quando l'esito di una scrittura è incerto a causa di un errore di comunicazione: il client non deve ripetere automaticamente l'operazione, ma deve prima verificare lo stato autoritativo.

Il backend rimane l'autorità per:

- autorizzazioni;
- capability;
- normalizzazione;
- unicità;
- gerarchia tassonomica;
- prevenzione dei cicli;
- dipendenze;
- stato attivo/inattivo;
- invarianti delle identità.

Flutter non deve duplicare tali regole introducendo vincoli applicativi ulteriori non previsti dal contratto backend.

La S032 non completa ancora l'intera UI editoriale e amministrativa del Catalogo. In particolare restano FUTURE:

- UI completa di creazione, modifica, attivazione e disattivazione delle Crop;
- UI completa di creazione, modifica, attivazione e disattivazione delle Cultivar;
- gestione applicativa degli alias;
- acquisizione delle fonti;
- gestione dei dati candidati;
- revisione editoriale;
- pubblicazione;
- integrazione operativa completa del Resolver nei flussi dell'orto.

Il Catalogo non è ancora popolato con una baseline agronomica destinata all'uso reale dell'orto.

Rimane valido il principio secondo cui:

```text
fonti esterne
→ dati candidati
→ revisione
→ approvazione/pubblicazione
→ Catalogo Agronomico
```

I dati esterni non possono sovrascrivere automaticamente il Catalogo approvato e non devono essere introdotti dati dimostrativi o provvisori nel database operativo.

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
BotanicalTaxon
Crop
CropCultivar
taxon_id
crop_id
cultivar_id
```

La tassonomia botanica globale utilizza i rank canonici:

```text
ORDER
FAMILY
GENUS
SPECIES
SUBSPECIES
VARIETY
FORMA
UNRANKED
```

`CULTIVAR` non è un rank tassonomico. La Cultivar costituisce un'identità agronomica globale separata e rimane associata alla Crop attraverso il modello `crop_cultivars`.

La gerarchia tassonomica utilizza `parent_taxon_id` e supporta classificazioni parziali. Il client non deve quindi imporre la presenza di tutti i rank intermedi quando il backend non la richiede.

La S031 ha completato un primo consolidamento lato Flutter eliminando il precedente percorso autonomo:

```text
Impostazioni → Varietà
```

e adottando la navigazione gerarchica coerente con il modello canonico:

```text
Impostazioni
→ Catalogo Agronomico
→ Colture
→ Cultivar
```

La consultazione delle cultivar avviene nel contesto della coltura selezionata e il relativo caricamento viene eseguito on demand.

La S032 ha proseguito il consolidamento verificando il contratto autoritativo già disponibile nel backend e integrando nel livello Flutter i Write Path relativi a:

```text
Tassonomia
Crop
Cultivar
```

Per la tassonomia botanica sono utilizzate le RPC autoritative:

```text
create_botanical_taxon
update_botanical_taxon
set_botanical_taxon_active
```

La gestione delle identità è subordinata alle capability della **Catalog Authority**, distinta dalla Profile Write Authority e dal meccanismo `profile_edit_locks`.

La S032 ha inoltre completato nella UI la gestione della **Classificazione botanica**, comprendendo:

- consultazione;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- selezione della classificazione superiore;
- gestione degli errori;
- gestione dei conflitti di versione;
- verifica dello stato autoritativo dopo esiti incerti.

La terminologia UI consolidata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Il collegamento di una Crop alla tassonomia rimane opzionale:

```text
Crop → Taxon
```

La concorrenza ottimistica delle operazioni di modifica utilizza `row_version`.

In caso di `version_conflict`:

```text
nessun overwrite forzato
nessun retry automatico
        ↓
rilettura autoritativa
```

In caso di errore di comunicazione o altro esito incerto dopo l'invio di una scrittura:

```text
nessun retry automatico
        ↓
rilettura autoritativa
        ↓
verifica dello stato effettivamente persistito
```

Il backend rimane autoritativo per le regole relative a:

- autorizzazioni e capability;
- normalizzazione;
- unicità;
- gerarchia tassonomica;
- prevenzione dei cicli;
- parent attivo/inattivo;
- dipendenze attive;
- attivazione e disattivazione;
- invarianti delle identità.

Flutter non deve duplicare tali regole introducendo vincoli ulteriori non previsti dal contratto backend.

La parola italiana **“Varietà”** può continuare a essere utilizzata nell'interfaccia utente quando costituisce la formulazione più naturale per l'utilizzatore, ma non deve determinare la reintroduzione nel modello applicativo o persistente delle precedenti identità `CropVariety` o `variety_id`.

Rimane da completare il riallineamento progressivo dei componenti agronomici e dei consumer applicativi storici che precedono il contratto canonico S030.

In particolare, i motori agronomici sviluppati nelle sessioni precedenti devono essere integrati progressivamente con:

- identità canoniche globali;
- Knowledge agronomica pubblicata;
- Resolver del Catalogo;
- eventuali snapshot operativi necessari alla conservazione storica delle decisioni.

Le nuove evoluzioni non devono introdurre ulteriori dipendenze dal modello legacy.

Il completamento della gestione UI della tassonomia in S032 non equivale al completamento dell'intera UI amministrativa del Catalogo. Restano da completare, tra gli altri, i flussi applicativi completi di gestione delle Crop e delle Cultivar e le interfacce relative ad alias, fonti, dati candidati, revisione, pubblicazione e utilizzo operativo del Resolver.

---

## Altri blocchi futuri

Dopo il completamento della S032 restano pianificati o aperti:

- completamento della UI di gestione delle Crop, utilizzando il Write Path Flutter già integrato e mantenendo il backend come autorità per capability, normalizzazione, unicità, tassonomia, dipendenze e concorrenza;

- completamento della UI di gestione delle Cultivar nel contesto della relativa Crop, utilizzando il Write Path Flutter già integrato e mantenendo le stesse garanzie di autorità e concorrenza;

- gestione applicativa degli alias e dei relativi flussi di riconciliazione delle identità;

- workflow operativo di acquisizione/importazione delle fonti in:
  `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;

- completamento delle schermate necessarie all'acquisizione, alla gestione dei dati candidati, alla revisione editoriale e alla pubblicazione;

- integrazione completa del Resolver del Catalogo nei flussi di pianificazione e inserimento delle coltivazioni;

- selezione operativa della cultivar durante la creazione delle coltivazioni;

- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;

- smoke test con dati operativi reali dopo l'avvio della gestione effettiva dell'orto;

- backend canonico per le consociazioni tra colture;

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

La S031 ha completato e rimosso dal perimetro delle attività future:

- integrazione del Catalogo Agronomico nelle Impostazioni;
- lettura dello stato della Catalog Authority;
- inizializzazione controllata dell'authority attraverso il backend quando consentita;
- esposizione delle capability autoritative;
- consultazione delle colture globali;
- navigazione gerarchica `Coltura → Cultivar`;
- caricamento on demand delle cultivar;
- gestione degli stati di caricamento, assenza dati, errore e retry;
- eliminazione del precedente percorso autonomo `Impostazioni → Varietà`.

La S032 ha completato e rimosso dal perimetro delle attività future:

- ricognizione tecnica delle funzioni, RPC, capability e Write Path già disponibili nel backend del Catalogo;
- verifica del contratto effettivo della tassonomia botanica globale;
- consolidamento dei rank `ORDER`, `FAMILY`, `GENUS`, `SPECIES`, `SUBSPECIES`, `VARIETY`, `FORMA` e `UNRANKED`;
- conferma della Cultivar come identità agronomica separata e non come rank tassonomico;
- supporto applicativo alla classificazione tassonomica parziale mediante `parent_taxon_id`;
- integrazione Flutter del Write Path della Tassonomia;
- integrazione Flutter del Write Path delle Crop;
- integrazione Flutter del Write Path delle Cultivar;
- supporto del collegamento opzionale `Crop → Taxon`;
- gestione della concorrenza ottimistica mediante `row_version`;
- gestione sicura di `version_conflict` senza overwrite forzato e senza retry automatico;
- gestione degli esiti incerti delle scritture mediante rilettura autoritativa prima di qualsiasi nuova operazione;
- completamento della UI della **Classificazione botanica** per lettura, creazione, modifica, attivazione e disattivazione;
- applicazione della capability `can_manage_identity` alle operazioni di gestione delle identità;
- mantenimento nel backend delle regole autoritative relative a gerarchia, cicli, dipendenze e stato attivo/inattivo.

La progressione applicativa delle identità del Catalogo rimane:

```text
Tassonomia
    ↓
Crop
    ↓
Cultivar
```

Il completamento della UI della tassonomia non deve essere interpretato come completamento dell'intera UI amministrativa del Catalogo: le UI complete di gestione delle Crop e delle Cultivar restano incrementi successivi.

Il workflow delle fonti esterne rimane separato dalle identità e dai dati canonici approvati:

```text
fonte esterna
        ↓
acquisizione
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione / pubblicazione
        ↓
Catalogo Agronomico
```

Nessun dato esterno deve sovrascrivere automaticamente il Catalogo approvato.

La precedente articolazione esplorativa delle sessioni successive, compresi eventuali riferimenti a una sequenza **S032–S042+**, non costituisce una roadmap ufficiale vincolante. Le sessioni future devono essere definite progressivamente sulla base dello stato effettivamente raggiunto, delle dipendenze tecniche verificate e delle decisioni esplicitamente approvate.

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

La **Sessione S032 è completata nella fase di sviluppo**.

La S032 è partita dalla baseline stabile lasciata dalla S031 ed ha eseguito innanzitutto una ricognizione tecnica del Catalogo Agronomico globale, verificando il contratto backend realmente disponibile prima di introdurre nuove funzionalità applicative.

La ricognizione ha confermato che il backend del Catalogo dispone già di un'architettura più avanzata rispetto alla precedente pianificazione esplorativa, comprendente:

- Catalog Authority globale;
- identità botaniche globali;
- Crop globali;
- Cultivar globali;
- fonti e acquisizioni;
- osservazioni;
- alias;
- workflow editoriale;
- dati candidati;
- evidenze;
- submission e review;
- Knowledge agronomica canonica;
- pubblicazione;
- Resolver;
- Write Path autoritativi dedicati;
- cutover canonico finale.

La S032 ha quindi consolidato il contratto della tassonomia botanica globale.

I rank canonici sono:

```text
ORDER
FAMILY
GENUS
SPECIES
SUBSPECIES
VARIETY
FORMA
UNRANKED
```

`CULTIVAR` non è un rank tassonomico.

La Cultivar costituisce un'identità agronomica globale separata dalla tassonomia ed è gestita attraverso il modello canonico `crop_cultivars`.

La tassonomia utilizza `parent_taxon_id` e supporta classificazioni parziali: il client non deve richiedere artificialmente tutti i livelli intermedi quando il backend non li impone.

La S032 ha integrato nel livello Flutter i Write Path relativi a:

```text
Tassonomia
Crop
Cultivar
```

Per la tassonomia botanica sono state integrate le RPC autoritative:

```text
create_botanical_taxon
update_botanical_taxon
set_botanical_taxon_active
```

È stato inoltre integrato il collegamento opzionale:

```text
Crop → Taxon
```

La gestione delle identità rimane subordinata alle capability della **Catalog Authority**, che costituisce un'autorità distinta dalla Profile Write Authority e dal protocollo `profile_edit_locks`.

La S032 ha completato la UI della **Classificazione botanica** con:

- lettura;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- selezione della classificazione superiore;
- gestione delle capability;
- gestione degli errori;
- gestione dei conflitti di versione;
- rilettura autoritativa dopo esiti incerti.

La terminologia UI consolidata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

La concorrenza ottimistica utilizza `row_version`.

In presenza di `version_conflict` il comportamento applicativo è:

```text
nessun overwrite forzato
nessun retry automatico
        ↓
rilettura dello stato autoritativo
```

Quando l'esito di una scrittura è incerto, ad esempio per un errore di comunicazione dopo l'invio della richiesta, il comportamento rimane:

```text
nessun retry automatico
        ↓
rilettura autoritativa
        ↓
verifica dello stato effettivamente persistito
```

Il backend rimane autoritativo per:

- autorizzazioni;
- capability;
- normalizzazione;
- unicità;
- gerarchia tassonomica;
- prevenzione dei cicli;
- dipendenze;
- stato attivo/inattivo;
- invarianti delle identità.

Flutter non deve duplicare tali regole introducendo vincoli ulteriori non previsti dal contratto backend.

La verifica conclusiva della S032 ha prodotto:

```text
test specifici pagina Catalogo: 61/61 superati
flutter analyze: nessun problema
flutter test: 1077/1077 superati
```

La S032 non ha introdotto nuove migration Supabase e non ha richiesto aggiornamenti di Flutter o delle dipendenze.

Il commit tecnico conclusivo dello sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
```

Al termine dello sviluppo S032:

```text
branch: main
HEAD = origin/main
working tree: clean
test Flutter: 1077 superati
flutter analyze: OK
nuove migration S032: nessuna
```

Il completamento della S032 non coincide con il completamento dell'intera UI amministrativa del Catalogo.

Restano in particolare da sviluppare:

- UI completa di gestione delle Crop;
- UI completa di gestione delle Cultivar;
- gestione applicativa degli alias;
- acquisizione e aggiornamento delle fonti;
- gestione dei dati candidati;
- revisione editoriale;
- pubblicazione;
- integrazione operativa completa del Resolver;
- popolamento verificato del Catalogo con dati agronomici reali.

La progressione applicativa delle identità rimane:

```text
Tassonomia
    ↓
Crop
    ↓
Cultivar
```

Per il prossimo incremento di sviluppo, la direzione tecnica naturale è proseguire questa sequenza completando progressivamente la gestione applicativa delle **Crop** e successivamente delle **Cultivar**, riutilizzando i Write Path già integrati nella S032.

Un possibile perimetro della successiva sessione comprende:

### Crop

- verifica finale delle RPC e degli stati restituiti;
- UI di creazione;
- UI di modifica;
- attivazione e disattivazione;
- collegamento opzionale alla tassonomia;
- applicazione della Catalog Authority;
- gestione di `row_version`;
- gestione sicura di `version_conflict`;
- gestione degli esiti incerti mediante rilettura autoritativa;
- test specifici;
- regressione completa.

### Cultivar

Successivamente, mantenendo la gerarchia `Crop → Cultivar`:

- UI di creazione;
- UI di modifica;
- attivazione e disattivazione;
- applicazione della Catalog Authority;
- gestione della concorrenza;
- gestione sicura degli errori e degli esiti incerti;
- test specifici;
- regressione completa.

Questo perimetro costituisce una **direzione proposta per il prossimo incremento**, non l'avvio automatico di una nuova sessione né un vincolo rigido sulla sua estensione.

La sessione successiva dovrà iniziare con un **CHECKPOINT DI RICEZIONE**, verificando lo stato effettivo di repository, database, documentazione, test e contratti backend prima di effettuare modifiche.

Non vengono invece assegnati preventivamente alla prossima sessione:

- alias;
- fonti e acquisizione;
- dati candidati;
- review;
- pubblicazione;
- Resolver operativo.

Tali blocchi rimangono FUTURE e saranno pianificati soltanto quando lo stato effettivamente raggiunto e le relative dipendenze tecniche ne renderanno opportuna l'implementazione.

Rimane valido il principio:

```text
nessun dato demo o provvisorio
        ↓
Catalogo verificato
        ↓
dati reali dell'orto
```

e il workflow previsto per le fonti esterne:

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

Il popolamento con dati agronomici reali dovrà avvenire soltanto quando il relativo workflow sarà sufficientemente sicuro, verificato e tracciabile.

La precedente articolazione esplorativa delle sessioni future, compresi eventuali riferimenti alla sequenza **S032–S042+**, non costituisce una roadmap ufficiale vincolante. La pianificazione deve essere aggiornata progressivamente sulla base dello stato effettivamente raggiunto e delle decisioni esplicitamente approvate.

Nessuna nuova sessione di sviluppo viene considerata iniziata fino alla sua apertura esplicita.
