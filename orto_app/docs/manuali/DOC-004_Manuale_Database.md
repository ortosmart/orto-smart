# ORTO SMART

### DOC-004

# Manuale Database

**Versione:** 1.0
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 16/08/2026
**Ultimo aggiornamento:** 16/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
| --- | --- |
| Documento | DOC-004 |
| Titolo | Manuale Database |
| Versione | 1.0 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 16/08/2026 |
| Ultimo aggiornamento | 16/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
| --- | --- | --- |
| 1.0 | 16/08/2026 | Prima emissione del Manuale Database e documentazione della baseline Database V1 progettata nella Sessione S017 |

---

# Indice

1. Scopo del documento
2. Stato del database
3. Principi architetturali del Database V1
4. Baseline nominale Database V1
5. Relazioni e flussi principali
6. Temporalità e storicizzazione
7. Convenzioni dei dati
8. Ownership e modello di accesso
9. Sicurezza e Row Level Security
10. Invarianti e integrità dei dati
11. Strategie di implementazione e migrazione
12. Funzionalità escluse dal V1
13. Considerazioni finali

---

# 1. Scopo del documento

Il presente Manuale Database descrive l'architettura, l'organizzazione e i principi di progettazione del database di **Orto Smart**.

Il documento distingue esplicitamente:

- il database Supabase attualmente implementato e utilizzato dall'applicazione;
- la baseline logica del **Database V1**, progettata e congelata durante la Sessione S017;
- le attività di implementazione SQL, migrazione, sicurezza e collaudo ancora da eseguire.

La baseline Database V1 costituisce il riferimento ufficiale per la futura traduzione dello schema in PostgreSQL/Supabase.

La progettazione V1 comprende **52 entità di dominio**. A queste si aggiunge `profile_edit_locks`, prevista come struttura tecnica separata per il controllo della concorrenza e pertanto non conteggiata come 53ª entità di dominio.

Il completamento della progettazione logica non implica che le 52 entità siano già presenti nel database operativo. Al termine della Sessione S017 le relative migration SQL non sono ancora state implementate.

Il presente documento ha inoltre lo scopo di mantenere separati:

- struttura persistente e logica decisionale del dominio Dart;
- configurazioni e fatti realmente avvenuti;
- pianificazione e realtà;
- dati operativi e informazioni derivate o calcolate;
- stato corrente e informazioni che richiedono storicizzazione.

Il dettaglio storico delle decisioni e delle attività che hanno portato alla definizione del Database V1 è documentato nel **DOC-005 – Quaderno di Sviluppo** e nel **DOC-011 – Decisioni Architetturali**.

---

# 2. Stato del database

Il progetto Orto Smart si trova in una fase di transizione tra il database operativo attualmente utilizzato dall'applicazione e la nuova architettura Database V1 progettata nella Sessione S017.

È pertanto necessario distinguere chiaramente lo **stato implementato** dallo **stato progettato**.

## 2.1 Database attualmente implementato

L'applicazione utilizza **Supabase**, basato su PostgreSQL, come backend persistente.

Tra le principali entità operative già presenti nel database utilizzato dall'applicazione rientrano:

- `gardens`;
- `beds`;
- `crops`;
- `seasons`;
- `plantings`.

Questa struttura appartiene al database operativo precedente alla riprogettazione V1 e non deve essere confusa con la baseline architetturale definitiva descritta nel presente manuale.

La presenza di una entità nella baseline Database V1 non implica che la relativa tabella, relazione, policy o migration sia già stata realizzata in Supabase.

## 2.2 Database V1 progettato

Durante la Sessione S017 è stata completata la progettazione logica e architetturale del **Database V1**.

Lo STEP 34 — Database V1 è stato dichiarato:

> **COMPLETATO E CONGELATO**

La baseline definitiva comprende:

- **52 entità di dominio V1**;
- `profile_edit_locks` come struttura tecnica separata;
- relazioni e cardinalità principali;
- criteri di temporalità e storicizzazione;
- ownership e modello di accesso;
- principi di sicurezza e autorizzazione;
- invarianti principali;
- convenzioni per unità, date, timestamp e valori nulli;
- criteri per la futura implementazione SQL/Supabase.

Il controllo nominale finale ha confermato la baseline **52/52**.

`AgronomicWindow` rimane un risultato calcolato a partire dalle regole agronomiche e non corrisponde a una tabella `agronomic_windows` del Database V1.

Il nome SQL definitivo dell'assegnazione dei target alle zone irrigue è:

`irrigation_zone_target_assignments`

e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

## 2.3 Stato di implementazione

Al termine della Sessione S017:

- la progettazione del Database V1 è completata;
- la baseline nominale è congelata;
- le migration SQL della nuova baseline non sono ancora state realizzate;
- lo schema Supabase operativo non è ancora stato trasformato integralmente nella nuova struttura;
- le policy RLS e le altre misure di sicurezza previste dalla nuova architettura devono essere implementate e verificate insieme allo schema;
- i test di integrazione del nuovo Database V1 devono ancora essere definiti ed eseguiti.

La successiva fase di sviluppo dovrà quindi tradurre la baseline congelata in SQL/Supabase senza riaprire lo STEP 34, salvo l'emersione di un errore concreto nella progettazione.

---

# 3. Principi architetturali del Database V1

La progettazione del Database V1 è stata guidata da un insieme di principi architetturali destinati a preservare coerenza, tracciabilità, efficienza e possibilità di evoluzione.

## 3.1 Separazione tra pianificazione e realtà

Orto Smart distingue formalmente ciò che viene pianificato da ciò che viene realmente eseguito.

La catena produttiva principale è:

```text
consumption_needs
        ↓
season_crop_plans
        ↓
planned_plantings
        ↓
plantings
        ↓
harvest_events
```

`planned_plantings` rappresenta ciò che si prevede di fare.

`plantings` rappresenta ciò che è stato realmente effettuato.

Una coltivazione reale può quindi differire dal piano senza perdere la tracciabilità della pianificazione originaria.

## 3.2 Dati persistenti e risultati calcolati

Il Database V1 evita di memorizzare informazioni facilmente derivabili quando non esiste una ragione storica o funzionale per conservarle.

Tra gli esempi principali:

- `AgronomicWindow` è calcolata a partire da `agronomic_window_rules`;
- quantità realmente eseguite e scostamenti dal piano possono essere derivati dagli eventi reali;
- il valore economico complessivo della produzione può essere calcolato a partire dai raccolti e dalle relative valorizzazioni;
- risultati di motori agronomici come rotazioni e compatibilità non vengono memorizzati come dati duplicati quando possono essere ricostruiti.

Il database conserva invece snapshot o valori congelati quando sono necessari per ricostruire correttamente una decisione storica.

## 3.3 Generalizzazione e specializzazione

Quando una regola è valida per una coltura in generale, deve essere rappresentata una sola volta.

Le specializzazioni varietali vengono introdotte soltanto quando necessarie.

Il principio è:

```text
regola generale della coltura
        +
override varietale solo quando necessario
```

Questo criterio riduce la duplicazione dei dati e mantiene compatta la rappresentazione persistente.

## 3.4 Storicizzazione delle configurazioni

Le configurazioni che possono cambiare nel tempo non devono sovrascrivere retroattivamente la situazione storica.

Il modello temporale di riferimento è:

```text
[valid_from, valid_to)
```

L'intervallo è chiuso all'inizio e aperto alla fine.

Questo principio viene utilizzato per le relazioni e configurazioni che devono poter essere ricostruite nel tempo.

## 3.5 Identità stabile e proprietà variabili

Quando un elemento mantiene la propria identità ma alcune sue caratteristiche possono cambiare, identità e configurazione storica vengono separate.

Il caso di riferimento è:

```text
Bed
        ↓
BedGeometry
```

`beds` mantiene l'identità stabile dell'aiuola.

`bed_geometries` conserva dimensioni e geometria valide nei diversi periodi.

Una variazione futura della geometria non cancella quindi la configurazione precedente.

## 3.6 Regole e fatti operativi

Il Database V1 distingue la conoscenza e la pianificazione dai fatti realmente avvenuti.

Esempio:

```text
ActivityRule
        ↓
Task
        ↓
WorkLog
```

dove:

- `activity_rules` rappresenta regole e conoscenza operativa;
- `tasks` rappresenta lavoro previsto;
- `work_logs` rappresenta lavoro realmente svolto.

Analoga separazione viene mantenuta tra configurazione irrigua ed eventi di irrigazione reali.

## 3.7 Eventi specializzati

Gli eventi operativi mantengono entità dedicate quando hanno semantiche differenti.

Sono quindi distinti:

- irrigazioni;
- fertilizzazioni;
- trattamenti;
- raccolti;
- costi;
- eventi strutturati dell'orto;
- registrazioni di lavoro.

Il V1 evita una tabella generica `events` che renderebbe ambigue responsabilità, vincoli e dati specifici dei diversi domini.

## 3.8 Efficienza e riduzione delle duplicazioni

La struttura V1 privilegia:

- normalizzazione;
- dati elementari;
- relazioni esplicite;
- valori derivati quando ricostruibili;
- snapshot soltanto quando necessari;
- assenza di duplicazione dello storico meteorologico grezzo.

In particolare Supabase non deve diventare un secondo archivio completo dei dati meteorologici già conservati dalle fonti autorevoli esterne o locali.

## 3.9 Estendibilità controllata

La baseline V1 è progettata per essere estendibile senza anticipare strutture prive di un requisito concreto.

La progettazione evita quindi di introdurre prematuramente:

- inventario e lotti;
- contabilità avanzata;
- vendite e fatturazione;
- GIS/PostGIS;
- collaborazione multi-writer;
- automazione hardware completa;
- analytics avanzate.

Queste aree restano future e potranno essere introdotte senza alterare retroattivamente i principi fondamentali della baseline.

---

# 4. Baseline nominale Database V1

La baseline Database V1 comprende **52 entità di dominio**, organizzate per area funzionale.

L'elenco seguente utilizza i nomi nominali definitivi congelati al termine della Sessione S017.

`profile_edit_locks` è documentata separatamente come infrastruttura tecnica e non rientra nel conteggio delle 52 entità di dominio.

## 4.1 Identità e ownership

1. `profiles`
2. `gardens`
3. `workers`
4. `seasons`

La catena fondamentale di ownership è:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

Un `Profile` può possedere più `Gardens`.

`workers` rappresenta invece le persone alle quali può essere attribuito il lavoro nell'orto.

La presenza di un `worker` non implica automaticamente l'esistenza di un account applicativo personale.

## 4.2 Catalogo agronomico

5. `botanical_families`
6. `crops`
7. `crop_varieties`
8. `crop_associations`
9. `agronomic_window_rules`

La relazione agronomica principale è:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

`crop_associations` rappresenta le relazioni agronomiche tra colture.

Le finestre agronomiche seguono il principio:

```text
agronomic_window_rules
        ↓
motore agronomico
        ↓
AgronomicWindow
```

`AgronomicWindow` è quindi un risultato calcolato.

La tabella:

```text
agronomic_windows
```

**non appartiene al Database V1**.

Le regole agronomiche possono rappresentare più periodi annuali e specializzazioni varietali e sono progettate per essere semanticamente versionate.

## 4.3 Struttura fisica dell'orto

10. `garden_areas`
11. `beds`
12. `bed_geometries`
13. `garden_structures`
14. `devices`
15. `water_sources`
16. `irrigation_zones`

La separazione fondamentale relativa alle aiuole è:

```text
beds
        ↓
identità stabile

bed_geometries
        ↓
geometria e dimensioni valide nel tempo
```

Una variazione futura delle dimensioni o della geometria di una aiuola non modifica retroattivamente la sua configurazione storica.

`garden_areas` consente di rappresentare porzioni fisiche significative dell'orto quando `garden` o `bed` non risultano sufficientemente granulari.

`garden_structures` rappresenta strutture fisiche dell'orto.

`devices` rappresenta dispositivi utilizzati dal sistema.

`water_sources` rappresenta le fonti idriche.

`irrigation_zones` rappresenta le zone configurabili dell'impianto irriguo.

Nel Database V1 non viene introdotta una modellazione GIS/PostGIS.

## 4.4 Relazioni e configurazioni temporali

17. `garden_area_beds`
18. `garden_structure_areas`
19. `device_assignments`
20. `device_links`
21. `irrigation_zone_assignments`
22. `irrigation_zone_sources`
23. `water_source_links`
24. `irrigation_zone_targets`
25. `irrigation_zone_target_assignments`

Queste entità rappresentano relazioni e configurazioni che non devono essere incorporate direttamente nelle entità principali quando possiedono una propria semantica o possono variare nel tempo.

Le configurazioni temporali adottano, quando applicabile, intervalli del tipo:

```text
[valid_from, valid_to)
```

Questo consente di conservare la configurazione storicamente valida senza sovrascrivere retroattivamente il passato.

`garden_area_beds` collega le aree fisiche dell'orto alle aiuole.

`garden_structure_areas` collega le strutture alle aree fisiche interessate.

`device_assignments` e `device_links` rappresentano rispettivamente assegnazioni e collegamenti relativi ai dispositivi.

Le configurazioni irrigue sono mantenute separate dagli eventi di irrigazione realmente eseguiti.

In particolare:

- `irrigation_zone_assignments` gestisce le assegnazioni delle zone irrigue;
- `irrigation_zone_sources` collega le zone alle relative fonti;
- `water_source_links` rappresenta i collegamenti tra fonti idriche;
- `irrigation_zone_targets` rappresenta i target configurabili delle zone;
- `irrigation_zone_target_assignments` rappresenta le assegnazioni dei target alle zone.

`irrigation_zone_target_assignments` è il **nome SQL definitivo** approvato al termine del controllo nominale S017 e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

## 4.5 Fabbisogno e preferenze

26. `crop_preferences`
27. `consumption_needs`

Le due entità rappresentano concetti distinti.

`crop_preferences` descrive preferenze e priorità relative alle colture.

`consumption_needs` rappresenta invece il fabbisogno quantitativo del nucleo nel tempo.

Questa distinzione preserva la separazione tra:

```text
preferenza / priorità
        ≠
fabbisogno quantitativo nel tempo
```

Il fabbisogno costituisce l'origine della catena di pianificazione produttiva:

```text
consumption_needs
        ↓
season_crop_plans
        ↓
planned_plantings
        ↓
plantings
        ↓
harvest_events
```

## 4.6 Regole operative

28. `activity_rules`

`activity_rules` rappresenta le regole operative utilizzabili per determinare o suggerire attività da eseguire.

Le regole operative sono mantenute distinte dalle attività pianificate e dal lavoro realmente svolto.

Il principio è:

```text
ActivityRule
        ↓
Task
        ↓
WorkLog
```

Le regole che possono modificare semanticamente il proprio comportamento devono essere versionate senza alterare retroattivamente le decisioni storiche.

## 4.7 Pianificazione

29. `season_crop_plans`
30. `planned_plantings`
31. `tasks`
32. `task_targets`

`season_crop_plans` rappresenta la decisione produttiva relativa a una coltura per una determinata stagione.

`planned_plantings` rappresenta lo scaglionamento concreto della pianificazione e rimane distinta da `plantings`, che descrive ciò che viene realmente coltivato.

Una `PlannedPlanting` può originare **0..N Plantings**.

Per le pianificazioni viene mantenuta la semantica:

```text
planned
closed
cancelled
```

Lo stato descrive la decisione relativa al piano. Quantità realmente eseguita, avanzamento e scostamento rispetto alla pianificazione devono essere derivati dai fatti reali e non duplicati inutilmente.

`tasks` rappresenta il lavoro pianificato.

`task_targets` consente di associare un task ai target pertinenti senza confondere il task con il lavoro effettivamente svolto.

La separazione fondamentale rimane:

```text
Task
        ≠
WorkLog
```

Un task descrive ciò che deve essere fatto; un work log registra ciò che è stato realmente eseguito.

## 4.8 Realtà colturale e lavoro

33. `plantings`
34. `work_logs`
35. `work_log_targets`

`plantings` rappresenta ciò che viene realmente coltivato e deve rimanere distinta dalla pianificazione contenuta in `planned_plantings`.

Una `PlannedPlanting` può originare **0..N Plantings**.

`work_logs` registra il lavoro realmente svolto.

`work_log_targets` consente di associare una registrazione di lavoro ai target pertinenti.

La durata del lavoro può essere ricostruita attraverso durata e timestamp secondo le convenzioni definite dal Database V1.

Per raggruppare più registrazioni appartenenti alla stessa sessione operativa viene utilizzato concettualmente `work_session_id`, senza introdurre una entità persistente `work_sessions`.

## 4.9 Produzione

36. `harvest_events`
37. `harvest_valuations`

Una `Planting` può produrre **0..N HarvestEvents**.

`harvest_events` registra i raccolti realmente effettuati.

`harvest_valuations` conserva la valorizzazione economica effettivamente adottata per un raccolto.

Il modello mantiene separati:

```text
MarketPrice
        ↓
prezzo rilevato

HarvestValuation
        ↓
prezzo effettivamente adottato per il raccolto
```

Il totale della produzione e gli altri valori aggregati derivabili dai singoli eventi non devono essere duplicati senza necessità.

## 4.10 Irrigazione

38. `irrigation_events`
39. `irrigation_event_targets`

Le entità di irrigazione reale sono separate dalla configurazione dell'impianto irriguo.

`irrigation_events` rappresenta un'irrigazione realmente eseguita.

`irrigation_event_targets` associa l'evento ai target effettivamente irrigati.

Per la futura irrigazione automatica, gli eventi possono rappresentare gli stati:

```text
running
completed
interrupted
unknown
```

La futura produzione automatica degli eventi deve essere idempotente mediante l'identità del dispositivo produttore e `external_event_id`.

## 4.11 Fertilizzazione

40. `fertilization_events`
41. `fertilization_event_targets`

`fertilization_events` registra le fertilizzazioni realmente effettuate.

`fertilization_event_targets` associa ciascun evento ai target interessati.

Il V1 mantiene la gestione volutamente essenziale e non introduce un sistema di inventario o di lotti per i prodotti utilizzati.

## 4.12 Trattamenti

42. `treatment_events`
43. `treatment_event_targets`

`treatment_events` registra i trattamenti realmente effettuati.

`treatment_event_targets` associa ciascun trattamento ai target interessati.

Anche in questo dominio il Database V1 registra direttamente il fatto operativo senza richiedere una gestione inventariale dei prodotti.

## 4.13 Eventi e diario

44. `garden_events`
45. `garden_event_targets`
46. `diary_entries`
47. `diary_entry_targets`

`garden_events` rappresenta eventi strutturati relativi all'orto.

`garden_event_targets` collega tali eventi ai target interessati.

`diary_entries` conserva annotazioni e registrazioni del diario.

`diary_entry_targets` permette di collegare una annotazione ai relativi target mantenendo separata la nota descrittiva dall'evento strutturato.

## 4.14 Economia

48. `market_prices`
49. `cost_events`
50. `cost_event_targets`

`market_prices` conserva le rilevazioni dei prezzi di mercato.

`cost_events` registra i costi effettivamente sostenuti.

`cost_event_targets` consente di attribuire un costo ai target pertinenti.

Nel V1:

```text
cost_events   = Garden-scoped
market_prices = Profile-owned
```

`MarketPrice` conserva la rilevazione originale, mentre `HarvestValuation` conserva il prezzo effettivamente adottato per valorizzare un raccolto.

Ammortamenti, contabilità avanzata, vendite, clienti e fatturazione rimangono fuori dal Database V1.

## 4.15 Contesto ambientale

51. `environment_context_snapshots`
52. `environment_context_links`

`environment_context_snapshots` conserva esclusivamente fotografie del contesto ambientale effettivamente utilizzato quando queste sono necessarie per spiegare o ricostruire una decisione.

`environment_context_links` collega il contesto ambientale alle entità o decisioni pertinenti.

Il Database V1 non duplica l'intero archivio meteorologico.

Il principio rimane:

```text
Davis/CumulusMX
        =
fonte locale primaria

Open-Meteo
        =
forecast / fallback

EnvironmentContextSnapshot
        =
fotografia selettiva del contesto realmente utilizzato
```

## 4.16 Infrastruttura tecnica separata

Oltre alle **52 entità di dominio**, il Database V1 prevede:

`profile_edit_locks`

Questa struttura **non costituisce una 53ª entità di dominio**.

È infrastruttura tecnica destinata alla gestione del modello **single-writer per Profile**, con supporto a heartbeat, scadenza del lock e takeover consensuale tra dispositivi.

La baseline complessiva prevista è pertanto:

```text
52 entità di dominio
+
1 struttura tecnica: profile_edit_locks
=
53 strutture fisiche previste
```

Il controllo nominale finale della Sessione S017 ha quindi congelato la baseline a **52/52 entità di dominio**, con `profile_edit_locks` mantenuta separata.

---

# 5. Relazioni e flussi principali

Il Database V1 è progettato attorno a relazioni che mantengono separati identità, configurazione, pianificazione e fatti realmente avvenuti.

Le relazioni descritte in questo capitolo rappresentano i principali flussi concettuali della baseline V1. I vincoli SQL e le foreign key definitive saranno tradotti e verificati durante l'implementazione delle migration.

## 5.1 Ownership principale

La catena fondamentale di ownership è:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

`profiles` rappresenta il livello applicativo associato all'identità autenticata.

`gardens` appartiene al relativo `Profile` e costituisce il principale confine dei dati operativi dell'orto.

Le entità operative Garden-scoped devono essere raggiungibili dal relativo `Garden` attraverso relazioni esplicite e verificabili.

## 5.2 Catalogo agronomico

La relazione fondamentale del catalogo agronomico è:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

Una coltura appartiene alla relativa famiglia botanica.

Una varietà specializza una coltura senza duplicarne inutilmente le informazioni generali.

Le regole agronomiche seguono il principio:

```text
Crop
  +
CropVariety opzionale
  +
metodo di avvio
        ↓
AgronomicWindowRule
        ↓
AgronomicWindow calcolata
```

Quando esiste una specializzazione varietale applicabile, questa può prevalere sulla regola generale della coltura secondo la logica definita dal dominio applicativo.

Il database conserva le regole e i relativi dati persistenti; la determinazione della `AgronomicWindow` applicabile rimane responsabilità del dominio.

## 5.3 Struttura fisica e geometria

L'identità dell'aiuola è mantenuta separata dalla sua geometria:

```text
Garden
        ↓
Bed
        ↓
BedGeometry
```

`Bed` rappresenta l'identità stabile dell'aiuola.

`BedGeometry` rappresenta invece la geometria valida in uno specifico intervallo temporale.

La separazione permette di modificare dimensioni o configurazione fisica senza alterare retroattivamente i dati storici riferiti alla stessa aiuola.

Le ulteriori relazioni fisiche vengono rappresentate mediante entità dedicate quando possiedono una propria semantica o validità temporale.

## 5.4 Pianificazione e realtà

Uno dei principi centrali del Database V1 è la separazione tra ciò che viene pianificato e ciò che accade realmente.

Il flusso produttivo principale è:

```text
ConsumptionNeed
        ↓
SeasonCropPlan
        ↓
PlannedPlanting
        ↓
Planting
        ↓
HarvestEvent
```

`ConsumptionNeed` rappresenta il fabbisogno quantitativo.

`SeasonCropPlan` rappresenta la decisione produttiva stagionale.

`PlannedPlanting` rappresenta lo scaglionamento pianificato.

`Planting` rappresenta la coltivazione realmente effettuata.

`HarvestEvent` rappresenta un singolo raccolto realmente eseguito.

Le cardinalità concettuali rilevanti comprendono:

```text
PlannedPlanting
        ↓
0..N Plantings

Planting
        ↓
0..N HarvestEvents
```

Questa struttura consente alla realtà di divergere dalla pianificazione senza modificare retroattivamente il piano originario.

## 5.5 Attività e lavoro reale

La gestione del lavoro mantiene distinti tre livelli:

```text
ActivityRule
        ↓
Task
        ↓
WorkLog
```

`ActivityRule` rappresenta una regola operativa.

`Task` rappresenta un'attività pianificata.

`WorkLog` rappresenta lavoro realmente svolto.

Pertanto:

```text
Task ≠ WorkLog
```

L'esecuzione di un lavoro può essere registrata anche quando non deriva da un task precedentemente pianificato.

I target vengono associati mediante le relative entità di collegamento, mantenendo separato il fatto operativo dall'oggetto sul quale esso viene eseguito.

Più `WorkLog` appartenenti alla stessa sessione operativa possono condividere un `work_session_id`, senza richiedere una tabella `work_sessions`.

## 5.6 Configurazione irrigua ed eventi reali

La configurazione dell'impianto irriguo rimane distinta dalle irrigazioni realmente effettuate.

Il principio è:

```text
WaterSource
        ↓
configurazione irrigua
        ↓
IrrigationZone
        ↓
target configurati
```

mentre l'esecuzione reale segue:

```text
IrrigationEvent
        ↓
IrrigationEventTarget
```

Una modifica futura della configurazione non deve riscrivere retroattivamente gli eventi di irrigazione già registrati.

Questa separazione prepara inoltre il sistema alla futura automazione hardware mantenendo invariato il significato storico degli eventi.

## 5.7 Eventi operativi e target

Diversi fatti operativi adottano il modello:

```text
Evento
        ↓
EventTarget
```

Questo principio viene applicato, secondo il relativo dominio, a:

- irrigazione;
- fertilizzazione;
- trattamenti;
- eventi dell'orto;
- diario;
- costi.

La separazione tra evento e target consente a uno stesso fatto di riferirsi ai soggetti pertinenti senza duplicare l'evento principale.

## 5.8 Produzione e valorizzazione economica

Il Database V1 mantiene distinti raccolto, prezzo rilevato e valorizzazione adottata:

```text
HarvestEvent
        ↓
HarvestValuation
        ↑
MarketPrice
```

`HarvestEvent` registra il raccolto reale.

`MarketPrice` rappresenta una rilevazione economica disponibile.

`HarvestValuation` conserva la valorizzazione effettivamente adottata per il raccolto.

Questa separazione evita che una successiva modifica o nuova rilevazione del prezzo di mercato modifichi retroattivamente il valore attribuito a un raccolto storico.

I costi rimangono registrati separatamente mediante `CostEvent` e i relativi target.

## 5.9 Contesto ambientale

Il Database V1 non replica lo storico meteorologico completo.

Quando una decisione o un evento richiede la conservazione del contesto ambientale utilizzato, il flusso concettuale è:

```text
fonte meteorologica
        ↓
EnvironmentContextSnapshot
        ↓
EnvironmentContextLink
        ↓
decisione / entità pertinente
```

Lo snapshot conserva soltanto le informazioni ambientali necessarie a ricostruire il contesto effettivamente utilizzato.

Questo modello mantiene l'archivio meteorologico esterno separato dal database operativo di Orto Smart e limita la duplicazione dei dati.

---

# 6. Temporalità e storicizzazione

Il Database V1 tratta esplicitamente la dimensione temporale dei dati, distinguendo tra fatti avvenuti, configurazioni valide nel tempo, pianificazioni e regole soggette a evoluzione.

L'obiettivo è preservare la ricostruibilità storica senza duplicare informazioni derivabili e senza modificare retroattivamente il significato dei dati già registrati.

## 6.1 Configurazioni valide nel tempo

Le configurazioni che possono cambiare nel corso della vita dell'orto utilizzano, quando applicabile, intervalli temporali secondo la convenzione:

```text
[valid_from, valid_to)
```

L'intervallo è quindi:

- inclusivo su `valid_from`;
- esclusivo su `valid_to`.

Quando `valid_to` è `NULL`, la configurazione può rappresentare quella attualmente valida, se coerente con le invarianti della relativa entità.

Questo modello permette di chiudere una configurazione precedente e introdurne una nuova senza sovrascrivere la storia.

È applicabile, secondo il dominio specifico, a elementi quali geometrie, assegnazioni e configurazioni che possono evolvere nel tempo.

## 6.2 Identità stabile e stato storico

Quando un oggetto mantiene la propria identità pur cambiando configurazione, l'identità stabile deve essere separata dagli attributi storicizzati.

Il caso fondamentale è:

```text
Bed
        ↓
identità stabile

BedGeometry
        ↓
configurazione geometrica valida nel tempo
```

Una modifica delle dimensioni o della geometria di un'aiuola non deve quindi alterare retroattivamente la configurazione che risultava valida per eventi o coltivazioni precedenti.

Lo stesso principio guida le altre configurazioni temporali del Database V1.

## 6.3 Fatti realmente avvenuti

Gli eventi reali rappresentano fatti storici.

Rientrano in questa categoria, tra gli altri:

- `plantings`;
- `work_logs`;
- `harvest_events`;
- `irrigation_events`;
- `fertilization_events`;
- `treatment_events`;
- `garden_events`;
- `cost_events`.

Un fatto realmente avvenuto non deve essere trasformato retroattivamente in un fatto diverso soltanto perché una configurazione, una regola o una pianificazione è cambiata successivamente.

Le eventuali correzioni devono rispettare la semantica UPDATE / VOID / DELETE definita per il Database V1 e le relative invarianti.

## 6.4 Pianificazione e storia reale

I dati pianificati devono essere conservati separatamente dai dati reali.

Il principio fondamentale è:

```text
pianificazione
        ≠
realtà
```

Per esempio:

```text
PlannedPlanting
        ↓
0..N Plantings
```

Una variazione nella realtà non deve richiedere la riscrittura del piano originario.

Analogamente, quantità realmente eseguite, avanzamento e scostamenti devono essere derivati dai fatti disponibili quando possibile, evitando campi ridondanti che possano divergere dalla realtà registrata.

## 6.5 Versionamento semantico delle regole

Le regole agronomiche e operative possono evolvere nel tempo.

Quando una modifica cambia il **significato** di una regola, la versione precedente non deve essere sovrascritta se ciò renderebbe impossibile comprendere decisioni storiche prese utilizzando quella versione.

Il principio è:

```text
modifica puramente descrittiva
        ↓
UPDATE possibile

modifica semantica
        ↓
nuova versione della regola
```

Questo criterio riguarda in particolare le regole agronomiche e operative utilizzate dai motori decisionali dell'applicazione.

La persistenza conserva la conoscenza necessaria; la logica decisionale rimane nel dominio applicativo.

## 6.6 Date e timestamp

Il Database V1 distingue tra:

```text
date
```

e:

```text
timestamptz
```

`date` viene utilizzato quando il significato del dato è esclusivamente riferito a un giorno di calendario e l'orario non costituisce parte dell'informazione.

`timestamptz` viene utilizzato quando è necessario rappresentare un istante reale e confrontabile nel tempo.

Non deve essere aggiunto un orario artificiale a un'informazione che possiede soltanto significato giornaliero.

Allo stesso modo, un evento per il quale l'istante effettivo è significativo non deve essere ridotto a una semplice data.

## 6.7 Timezone del Garden

Ogni `Garden` deve disporre di una timezone espressa mediante identificatore **IANA**.

La timezone del Garden costituisce il riferimento per interpretare correttamente:

- date operative;
- eventi;
- pianificazioni;
- visualizzazioni locali;
- elaborazioni dipendenti dal giorno locale.

Gli istanti persistiti come `timestamptz` devono mantenere una semantica temporale non ambigua, mentre la conversione e la presentazione nel tempo locale devono utilizzare la timezone IANA del Garden.

Non devono essere utilizzate come riferimento persistente abbreviazioni locali ambigue o offset UTC fissi quando il significato richiede una vera zona temporale.

## 6.8 Valori NULL e informazione sconosciuta

`NULL` deve rappresentare l'assenza reale o la non conoscenza di un'informazione quando tale stato è semanticamente ammesso.

Non devono essere utilizzati valori fittizi per sostituire un'informazione sconosciuta.

Il principio generale è:

```text
dato sconosciuto
        ≠
zero
        ≠
false
        ≠
stringa vuota
```

La possibilità di utilizzare `NULL` deve comunque essere definita coerentemente con le invarianti della specifica entità.

## 6.9 Snapshot e ricostruibilità storica

Quando una decisione dipende da informazioni esterne che possono cambiare nel tempo, può essere necessario conservare uno snapshot selettivo del contesto realmente utilizzato.

Il caso principale previsto dal Database V1 è:

```text
EnvironmentContextSnapshot
```

Lo snapshot non costituisce una copia completa dello storico meteorologico.

Serve invece a conservare le informazioni ambientali necessarie a spiegare o ricostruire una decisione o un evento quando il semplice riferimento alla fonte esterna non sarebbe sufficiente.

La storicizzazione deve quindi essere **selettiva e motivata**, evitando la duplicazione indiscriminata di dati già conservati nelle relative fonti autorevoli.

---

# 7. Convenzioni dei dati

Il Database V1 adotta convenzioni comuni per garantire coerenza tra le diverse aree funzionali, ridurre le conversioni implicite e impedire che lo stesso dato venga rappresentato in modi incompatibili.

Le convenzioni definite in questo capitolo costituiscono la baseline logica. I tipi PostgreSQL concreti, i vincoli e le precisioni definitive saranno verificati durante la traduzione della baseline in migration SQL/Supabase.

## 7.1 Unità canoniche

Le quantità persistenti devono utilizzare unità canoniche definite dal dominio.

L'obiettivo è evitare che lo stesso tipo di misura venga memorizzato utilizzando unità differenti senza una regola esplicita di conversione.

Il principio generale è:

```text
input utente
        ↓
conversione
        ↓
unità canonica persistita
        ↓
eventuale conversione per visualizzazione
```

L'interfaccia può presentare o accettare unità più convenienti per l'utente, ma il livello persistente deve mantenere una rappresentazione coerente.

Quando l'unità non è implicitamente e inequivocabilmente determinata dal campo, deve essere rappresentata esplicitamente.

## 7.2 Quantità e precisione

Le quantità devono utilizzare una precisione adeguata al significato agronomico, operativo o economico del dato.

Non deve essere introdotta precisione artificiale superiore a quella realmente disponibile.

Allo stesso tempo, arrotondamenti destinati esclusivamente alla visualizzazione non devono modificare il valore persistito quando la precisione originale è significativa.

Le quantità derivate devono essere calcolate dai dati sorgente quando possibile, evitando la memorizzazione ridondante di valori che potrebbero diventare incoerenti.

## 7.3 Identificativi

Ogni entità persistente deve disporre di una identità stabile e non dipendente da attributi descrittivi modificabili.

Nomi, descrizioni, codici visualizzati all'utente o altre proprietà modificabili non devono essere utilizzati come sostituti dell'identificativo tecnico quando ciò comprometterebbe la stabilità delle relazioni.

Le foreign key devono riferirsi agli identificativi persistenti delle entità correlate.

La scelta definitiva dei tipi SQL degli identificativi deve essere coerente all'interno del Database V1 e sarà verificata durante la progettazione delle migration.

## 7.4 Denominazioni SQL

Le strutture persistenti utilizzano denominazioni SQL esplicite e non ambigue.

I nomi delle tabelle della baseline V1 sono espressi in:

```text
snake_case
```

Le denominazioni devono descrivere chiaramente il ruolo della struttura evitando abbreviazioni non necessarie.

Quando una tabella rappresenta un collegamento o un target, il nome deve rendere riconoscibile il contesto al quale appartiene.

Per questo motivo il controllo nominale finale della S017 ha adottato:

```text
irrigation_zone_target_assignments
```

al posto della precedente denominazione provvisoria:

```text
zone_target_assignments
```

La denominazione definitiva elimina l'ambiguità e identifica esplicitamente il dominio irriguo.

## 7.5 Dati persistenti e dati calcolati

Il database deve conservare i dati necessari a rappresentare fatti, configurazioni, regole e decisioni persistenti.

Non devono invece essere introdotte tabelle o colonne soltanto per conservare risultati che possono essere calcolati in modo affidabile dai dati sorgente, salvo che esista una motivazione esplicita di storicizzazione, prestazioni o audit.

Il caso fondamentale definito nella S017 è:

```text
agronomic_window_rules
        ↓
logica di dominio
        ↓
AgronomicWindow
```

`AgronomicWindow` è un risultato calcolato e non corrisponde a una tabella persistente `agronomic_windows`.

Lo stesso principio deve essere applicato agli aggregati e agli indicatori ricostruibili dai fatti registrati.

## 7.6 Dato generale e specializzazione

Quando un'informazione può essere definita a livello generale e specializzata soltanto in alcuni casi, il Database V1 privilegia la rappresentazione generale evitando duplicazioni.

Il principio è:

```text
dato generale
        +
specializzazione solo quando necessaria
```

Nel dominio agronomico questo consente, per esempio, di mantenere informazioni generali a livello di coltura e introdurre una specializzazione varietale soltanto quando il comportamento della varietà differisce realmente.

La logica applicativa determina la precedenza e il fallback tra le regole applicabili.

## 7.7 Valori sconosciuti e valori neutri

L'assenza di informazione deve essere distinta da un valore reale pari a zero, falso o vuoto.

Pertanto:

```text
NULL
        ≠
0
        ≠
false
        ≠
''
```

Un valore neutro deve essere persistito soltanto quando rappresenta realmente il dato osservato.

Quando invece l'informazione non è disponibile o non è applicabile, deve essere utilizzata la rappresentazione prevista dal modello della specifica entità.

Questo principio evita di trasformare l'assenza di conoscenza in un'informazione apparentemente certa.

## 7.8 Date, timestamp e timezone

Le convenzioni temporali definite nel Capitolo 6 sono applicate uniformemente a tutte le entità.

In sintesi:

- `date` rappresenta un giorno di calendario quando l'orario non è parte dell'informazione;
- `timestamptz` rappresenta un istante reale;
- la timezone applicativa del Garden utilizza un identificatore IANA;
- non devono essere inventati orari per dati che possiedono soltanto significato giornaliero;
- gli intervalli di validità utilizzano, quando applicabile, la convenzione `[valid_from, valid_to)`.

La scelta tra data e timestamp deve quindi dipendere dal significato del dato e non dalla comodità tecnica dell'implementazione.

## 7.9 Evitare duplicazioni

La progettazione del Database V1 privilegia strutture compatte e normalizzate quando questo non compromette chiarezza, integrità o ricostruibilità storica.

Prima di persistere un dato derivato deve essere verificato se esso può essere ottenuto in modo affidabile dalle informazioni già registrate.

Esempi di informazioni da non duplicare inutilmente comprendono:

- totali ricostruibili dai singoli eventi;
- avanzamenti derivabili dai fatti reali;
- aggregati ottenibili dalle registrazioni sorgente;
- storico meteorologico completo già disponibile presso la fonte autorevole;
- proprietà generali replicate su ogni specializzazione senza necessità.

La denormalizzazione potrà essere introdotta soltanto quando esisterà una motivazione concreta e verificabile.

## 7.10 Coerenza tra database e dominio applicativo

Il database rappresenta la persistenza e protegge le invarianti strutturali, ma non deve assorbire indiscriminatamente la logica decisionale del dominio Dart.

Il principio architetturale rimane:

```text
Supabase / PostgreSQL
        ↓
repository e mapping
        ↓
dominio Dart
        ↓
motori decisionali
```

Il database deve garantire integrità, ownership, autorizzazione e invarianti che devono essere vere indipendentemente dal client.

La logica agronomica e decisionale che determina interpretazioni, fallback, valutazioni e raccomandazioni rimane invece nel dominio applicativo, salvo specifiche responsabilità server-side necessarie per sicurezza o atomicità.

---

# 8. Ownership e modello di accesso

Il Database V1 definisce esplicitamente l'ownership dei dati e il relativo modello di accesso.

L'obiettivo è fare in modo che ogni dato persistente possieda un percorso di appartenenza chiaro e verificabile, evitando strutture prive di ownership o autorizzazioni basate esclusivamente sul comportamento del client.

## 8.1 Profile come radice applicativa

L'identità autenticata viene collegata al relativo `Profile`.

La catena principale è:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

`Profile` costituisce quindi la principale radice applicativa dell'ownership.

Le informazioni appartenenti direttamente all'utente, e non a uno specifico orto, possono essere mantenute a livello Profile quando il loro significato lo richiede.

## 8.2 Garden come confine operativo

`Garden` rappresenta il principale confine di appartenenza dei dati operativi dell'orto.

Le entità Garden-scoped devono essere riconducibili in modo verificabile al relativo Garden, direttamente oppure attraverso una catena di relazioni non ambigua.

Il principio è:

```text
Profile
        ↓
Garden
        ↓
dati operativi
```

Questo modello consente di verificare l'accesso ai dati partendo dall'ownership del Garden senza affidarsi a informazioni fornite liberamente dal client.

## 8.3 Dati Garden-scoped e Profile-owned

Non tutte le entità appartengono necessariamente allo stesso livello.

La baseline distingue almeno:

```text
Garden-scoped
```

e:

```text
Profile-owned
```

I dati operativi relativi a uno specifico orto sono normalmente Garden-scoped.

Le informazioni che appartengono al profilo indipendentemente da uno specifico Garden possono invece essere Profile-owned.

Un caso esplicitamente definito nella S017 è:

```text
cost_events   = Garden-scoped
market_prices = Profile-owned
```

Questa distinzione deve essere preservata durante la futura implementazione delle foreign key e delle policy RLS.

## 8.4 Workers

`workers` rappresenta le persone alle quali può essere attribuito il lavoro svolto nell'orto.

Il concetto di worker è distinto dall'identità utilizzata per autenticarsi nell'applicazione.

Il principio è:

```text
Worker
        ≠
necessariamente account applicativo
```

Una persona può quindi essere rappresentata come worker per consentire l'attribuzione di attività e tempi di lavoro senza che debba necessariamente possedere credenziali personali di accesso.

Questa separazione evita di trasformare la gestione operativa delle persone in un sistema di autorizzazione più complesso del necessario.

## 8.5 Accesso dei componenti familiari

Durante la S017 è emerso il possibile requisito futuro di consentire ai componenti familiari accessi personali mediante credenziali distinte.

Tale requisito **non modifica la baseline congelata del Database V1**.

In particolare non viene introdotta una entità:

```text
household_users
```

come 53ª entità di dominio.

L'eventuale modello di accesso personale dei componenti familiari dovrà essere approfondito separatamente e realizzato mediante meccanismi di autenticazione e autorizzazione coerenti con la sicurezza server-side.

Rimane pertanto valido che:

```text
worker
        ≠
necessariamente utente autenticato
```

e che l'eventuale evoluzione degli account familiari non deve alterare retroattivamente il significato di `workers`.

## 8.6 Modello single-writer

Il Database V1 adotta per il Profile un modello operativo **single-writer**.

L'obiettivo è evitare modifiche concorrenti non coordinate provenienti da più dispositivi appartenenti allo stesso Profile.

Il principio concettuale è:

```text
Profile
        ↓
un writer attivo
        ↓
eventuali altri dispositivi non writer
```

Il single-writer non sostituisce RLS, autorizzazione o invarianti del database.

Costituisce un ulteriore meccanismo di coordinamento delle modifiche concorrenti.

## 8.7 Coordinamento del writer

Il coordinamento tecnico del single-writer utilizza la struttura:

```text
profile_edit_locks
```

`profile_edit_locks` è infrastruttura tecnica e non appartiene alle 52 entità di dominio.

Il meccanismo deve essere progettato per supportare almeno:

- identificazione del writer attivo;
- heartbeat;
- scadenza del lock;
- recupero da sessioni o dispositivi non più attivi;
- takeover consensuale quando previsto.

Il possesso di un lock non deve essere determinato o imposto unilateralmente dal client senza verifica server-side.

I dettagli implementativi e le relative garanzie di sicurezza saranno definiti durante la traduzione della baseline in SQL/Supabase.

## 8.8 Evoluzione futura verso il multi-writer

La collaborazione concorrente completa tra più writer non appartiene al Database V1.

Il V1 privilegia un modello più semplice e controllabile:

```text
single-writer per Profile
```

Una futura evoluzione multi-writer richiederebbe la definizione di strategie aggiuntive per:

- concorrenza;
- conflitti;
- versionamento;
- sincronizzazione;
- autorizzazioni;
- eventuale funzionamento offline.

Tale evoluzione deve essere considerata separatamente e non deve complicare prematuramente la baseline V1.

## 8.9 Principio di ownership verificabile

L'ownership non deve dipendere soltanto da valori dichiarati dal client.

Per ogni operazione sui dati deve essere possibile determinare server-side il percorso che collega l'identità autenticata alla risorsa interessata.

Concettualmente:

```text
utente autenticato
        ↓
Profile autorizzato
        ↓
Garden autorizzato
        ↓
risorsa richiesta
```

Le foreign key e le relazioni del Database V1 devono rendere questo percorso verificabile.

Le modalità concrete di enforcement mediante RLS, funzioni server-side, vincoli e transazioni sono documentate nel capitolo successivo.

---

# 9. Sicurezza e Row Level Security

Il Database V1 adotta un modello di sicurezza nel quale il client applicativo non costituisce una fonte attendibile per l'autorizzazione.

La sicurezza deve essere garantita dal backend e dal database indipendentemente dal comportamento dell'interfaccia Flutter.

Il principio fondamentale è:

```text
Flutter
        =
client non fidato
```

Di conseguenza, controlli presenti nell'interfaccia, pulsanti nascosti, filtri applicativi o identificativi trasmessi dal client non possono costituire da soli una barriera di sicurezza.

## 9.1 Principio deny-by-default

L'accesso ai dati deve seguire un approccio:

```text
deny-by-default
```

Una operazione deve essere consentita soltanto quando esiste una regola esplicita che dimostra che l'identità autenticata possiede il diritto di eseguirla.

In assenza di una autorizzazione verificabile, l'operazione deve essere rifiutata.

Questo principio deve essere applicato alle operazioni di:

- lettura;
- inserimento;
- modifica;
- eliminazione;
- operazioni server-side che producono effetti persistenti.

## 9.2 Row Level Security

PostgreSQL Row Level Security costituisce una delle principali barriere di autorizzazione del Database V1.

Le tabelle esposte al client devono essere protette mediante RLS secondo il relativo modello di ownership.

Concettualmente:

```text
utente autenticato
        ↓
Profile
        ↓
Garden
        ↓
risorsa
```

Una policy deve poter verificare che la risorsa richiesta appartenga effettivamente al Profile o al Garden autorizzato.

La semplice presenza di un `profile_id`, `garden_id` o altro identificativo nella richiesta del client non costituisce prova di autorizzazione.

## 9.3 Autorizzazione server-side

Le decisioni di autorizzazione devono essere ricavate server-side dall'identità autenticata e dalle relazioni persistenti.

Il client può indicare quale risorsa intende utilizzare, ma non può decidere autonomamente di esserne proprietario o di possedere i privilegi necessari.

Il principio è:

```text
richiesta client
        ↓
identità autenticata
        ↓
verifica server-side
        ↓
ownership / autorizzazione
        ↓
operazione consentita o rifiutata
```

Le operazioni che non possono essere protette in modo sufficientemente robusto mediante accesso diretto alle tabelle devono essere esposte attraverso funzioni o procedure server-side opportunamente autorizzate.

## 9.4 Flutter come client non fidato

L'applicazione Flutter deve essere progettata assumendo che le richieste provenienti dal client possano essere manipolate.

Pertanto non devono essere considerate garanzie di sicurezza:

- validazioni eseguite esclusivamente nell'interfaccia;
- valori di ownership forniti dal client;
- stato locale dell'applicazione;
- controlli di visibilità dei componenti UI;
- sequenze operative che il client potrebbe aggirare.

Le validazioni client-side rimangono utili per l'esperienza utente, ma le invarianti di sicurezza devono essere verificate nuovamente dal backend o dal database.

## 9.5 Invarianti protette dal database

Le condizioni che devono essere vere indipendentemente dal client devono essere protette mediante gli strumenti appropriati del database.

A seconda del caso potranno essere utilizzati:

- `NOT NULL`;
- foreign key;
- `UNIQUE`;
- `CHECK`;
- exclusion constraint;
- RLS;
- funzioni server-side;
- transazioni;
- altri vincoli PostgreSQL appropriati.

La scelta concreta deve essere effettuata durante la traduzione della baseline logica in SQL.

La logica decisionale agronomica non deve essere trasferita indiscriminatamente nel database, ma le invarianti necessarie a impedire stati persistenti impossibili o non autorizzati devono essere protette lato server.

## 9.6 Operazioni atomiche e transazioni

Le operazioni che modificano più strutture e che devono essere considerate una singola unità logica devono essere eseguite atomicamente.

Il principio è:

```text
tutta l'operazione riesce
        oppure
nessuna modifica viene consolidata
```

Quando una operazione critica richiede più verifiche e modifiche coordinate, deve essere valutato l'utilizzo di una transazione o di una funzione server-side.

Questo evita stati intermedi incoerenti prodotti da richieste separate del client.

## 9.7 Sicurezza del modello single-writer

Il modello single-writer per Profile non deve essere affidato esclusivamente allo stato locale dell'applicazione.

La struttura tecnica:

```text
profile_edit_locks
```

deve essere gestita con controlli server-side sufficienti a impedire che un client possa attribuirsi arbitrariamente il ruolo di writer.

Il meccanismo deve supportare in modo controllato:

- acquisizione del lock;
- verifica del writer corrente;
- heartbeat;
- scadenza;
- rilascio;
- eventuale takeover consensuale.

Le operazioni che dipendono dal possesso del lock devono verificare server-side che il writer sia effettivamente autorizzato.

Il single-writer costituisce un meccanismo di coordinamento e non sostituisce RLS o le normali verifiche di ownership.

## 9.8 Protezione delle operazioni sensibili

Le operazioni sensibili non devono dipendere da una successione di controlli effettuati esclusivamente dal client.

Quando un'operazione richiede contemporaneamente:

```text
autenticazione
+
ownership
+
eventuale lock
+
invarianti
+
scrittura
```

le verifiche necessarie devono essere eseguite nel perimetro server-side appropriato e, quando necessario, nella stessa operazione atomica.

Questo principio riduce il rischio di race condition e di modifiche effettuate tra una verifica e la successiva scrittura.

## 9.9 Identità tecnica per dispositivi futuri

La futura automazione mediante Raspberry Pi o altri dispositivi non deve utilizzare nel dispositivo credenziali amministrative generali del progetto.

In particolare:

```text
service_role
```

non deve essere distribuita al Raspberry Pi come credenziale applicativa ordinaria.

La futura automazione hardware dovrà utilizzare una identità tecnica dedicata e privilegi limitati alle operazioni strettamente necessarie.

Il principio è quello del **least privilege**:

```text
identità tecnica
        ↓
solo permessi necessari
        ↓
solo risorse autorizzate
```

L'architettura concreta dell'identità tecnica verrà definita quando sarà implementata l'automazione hardware.

## 9.10 Idempotenza degli eventi automatici

Le integrazioni automatiche devono essere progettate per tollerare ritrasmissioni e retry senza generare duplicazioni incontrollate.

Per gli eventi prodotti automaticamente è previsto il principio:

```text
producer_device_id
        +
external_event_id
        ↓
identità idempotente dell'evento
```

Una ritrasmissione dello stesso evento deve poter essere riconosciuta senza creare un nuovo fatto duplicato.

La forma SQL definitiva dei relativi vincoli sarà definita durante l'implementazione.

## 9.11 Segreti e credenziali

Segreti, credenziali privilegiate e chiavi amministrative non devono essere incorporati nel codice client distribuito.

Il client deve utilizzare esclusivamente credenziali compatibili con il modello pubblico previsto da Supabase e affidarsi a RLS e alle autorizzazioni server-side per la protezione effettiva dei dati.

Le credenziali con privilegi elevati devono rimanere esclusivamente negli ambienti server-side appropriati.

La gestione concreta dei segreti dovrà seguire le modalità supportate dall'infrastruttura utilizzata al momento dell'implementazione.

## 9.12 Sicurezza come parte delle migration

RLS, policy, vincoli e funzioni di sicurezza non devono essere considerati una fase accessoria successiva alla creazione delle tabelle.

La traduzione del Database V1 in SQL deve procedere integrando fin dall'inizio:

```text
schema
+
foreign key
+
invarianti
+
RLS
+
autorizzazione
+
test
```

Ogni gruppo di migration dovrà essere verificato anche dal punto di vista della sicurezza prima di essere considerato completato.

Il Database V1 non sarà quindi considerato implementato soltanto perché le 52 entità esistono fisicamente: dovranno essere operative anche le protezioni previste dalla baseline.

---

# 10. Invarianti e integrità dei dati

Il Database V1 deve impedire la persistenza di stati strutturalmente incoerenti anche quando una richiesta proviene da un client errato, obsoleto o manipolato.

Le invarianti descritte in questo capitolo rappresentano condizioni che devono rimanere vere indipendentemente dall'interfaccia utilizzata.

La loro implementazione concreta potrà utilizzare, secondo il caso:

- foreign key;
- `NOT NULL`;
- `UNIQUE`;
- `CHECK`;
- exclusion constraint;
- RLS;
- funzioni server-side;
- transazioni;
- altri strumenti PostgreSQL appropriati.

La scelta del meccanismo SQL definitivo verrà effettuata durante l'implementazione delle migration.

## 10.1 Integrità referenziale

Ogni relazione persistente deve riferirsi a entità esistenti e compatibili con il relativo dominio.

Le foreign key devono impedire riferimenti verso record inesistenti.

L'eliminazione o la modifica di una entità referenziata deve utilizzare una strategia esplicita e coerente con il significato storico del dato.

Non devono essere adottati automaticamente comportamenti `CASCADE` quando potrebbero eliminare fatti storici o informazioni che devono essere conservate.

## 10.2 Coerenza dell'ownership

Le relazioni non devono consentire di collegare arbitrariamente dati appartenenti a ownership incompatibili.

Quando due entità Garden-scoped partecipano alla stessa relazione, deve essere garantito che appartengano al Garden corretto secondo la semantica della relazione.

Concettualmente deve essere impedita una situazione come:

```text
Garden A
   ↓
risorsa A
   ↓
relazione non valida
   ↓
risorsa B
   ↑
Garden B
```

quando la relazione richiede che entrambe le risorse appartengano allo stesso Garden.

Il semplice possesso di identificativi formalmente validi non è sufficiente: deve essere verificata anche la compatibilità dell'ownership.

## 10.3 Intervalli temporali

Gli intervalli di validità che utilizzano:

```text
[valid_from, valid_to)
```

devono rispettare almeno la condizione:

```text
valid_to > valid_from
```

quando `valid_to` è valorizzato.

`valid_to = NULL` può rappresentare un intervallo ancora aperto quando ammesso dalla relativa entità.

Non devono essere persistiti intervalli temporalmente impossibili.

## 10.4 Sovrapposizioni temporali

Quando il dominio stabilisce che per una determinata entità o relazione possa esistere una sola configurazione valida nello stesso momento, gli intervalli temporali incompatibili non devono sovrapporsi.

Il principio è:

```text
configurazione A
[---------)

configurazione B
          [---------)
```

e non:

```text
configurazione A
[-------------)

configurazione B
       [-------------)
```

quando entrambe rappresentano configurazioni mutuamente esclusive dello stesso oggetto.

Non tutte le relazioni temporali richiedono necessariamente unicità temporale: il vincolo deve essere applicato soltanto dove previsto dalla semantica del dominio.

## 10.5 Identità stabile delle aiuole

`beds` rappresenta l'identità stabile dell'aiuola.

`bed_geometries` rappresenta invece la configurazione geometrica valida nel tempo.

Pertanto una modifica della geometria non deve richiedere la creazione di una nuova identità `bed` quando l'aiuola mantiene semanticamente la propria identità.

Allo stesso tempo non deve essere possibile alterare la geometria corrente in modo da riscrivere retroattivamente la configurazione storica.

## 10.6 Pianificazione e fatti reali

Le entità di pianificazione non devono essere confuse con i fatti realmente avvenuti.

In particolare:

```text
planned_plantings
        ≠
plantings

tasks
        ≠
work_logs
```

Una `planned_planting` può originare:

```text
0..N plantings
```

e non deve essere imposto artificialmente un rapporto uno-a-uno.

Quantità reali, avanzamento e scostamenti devono essere ricavati dai fatti registrati quando possibile, evitando valori duplicati che potrebbero divergere dalla realtà.

## 10.7 Quantità valide

Le quantità devono rispettare il significato fisico e logico del relativo campo.

Quando una quantità non può semanticamente essere negativa, il database deve impedirne la persistenza.

Lo zero deve essere distinto dall'assenza di informazione.

Il principio rimane:

```text
NULL
        ≠
0
```

I limiti e le precisioni concrete saranno definiti per ciascun campo durante la progettazione SQL.

## 10.8 Target e relazioni controllate

Le entità `*_targets` consentono di associare eventi, task, registrazioni o altre entità ai relativi oggetti di dominio.

La flessibilità dei target non deve però consentire riferimenti arbitrari o semanticamente impossibili.

Il database e il livello server-side devono garantire, secondo il modello definitivo:

- esistenza del target;
- tipo di target ammesso;
- ownership compatibile;
- coerenza con l'entità sorgente;
- assenza di combinazioni impossibili.

La flessibilità del modello non deve quindi trasformarsi in perdita di integrità referenziale.

## 10.9 Configurazione irrigua ed eventi

La configurazione dell'impianto irriguo deve rimanere distinta dagli eventi di irrigazione realmente eseguiti.

Pertanto:

```text
irrigation_zones
irrigation_zone_assignments
irrigation_zone_sources
irrigation_zone_targets
irrigation_zone_target_assignments
```

descrivono configurazioni e relazioni dell'impianto, mentre:

```text
irrigation_events
irrigation_event_targets
```

registrano fatti realmente avvenuti.

Una modifica futura della configurazione irrigua non deve riscrivere retroattivamente il significato degli eventi storici.

## 10.10 Regole agronomiche

`agronomic_window_rules` rappresenta le informazioni persistenti utilizzate per determinare le finestre agronomiche.

Non deve essere introdotta una tabella persistente:

```text
agronomic_windows
```

soltanto per memorizzare il risultato calcolato.

Le regole devono poter distinguere almeno:

- coltura;
- eventuale specializzazione varietale;
- metodo di impianto;
- periodo o periodi applicabili;
- versione semanticamente rilevante quando necessario.

Le modifiche che cambiano il significato di una regola non devono compromettere la ricostruibilità delle decisioni storiche.

## 10.11 Eventi storici e correzioni

Un fatto realmente avvenuto non deve essere cancellato o riscritto indiscriminatamente quando è necessario correggere un errore.

La strategia concreta deve distinguere semanticamente, secondo il tipo di dato e l'operazione:

```text
UPDATE
VOID
DELETE
```

In generale:

- `UPDATE` è appropriato quando si corregge un dato senza alterare impropriamente il significato storico;
- `VOID` deve essere valutato quando il fatto deve rimanere tracciabile ma non deve più essere considerato valido;
- `DELETE` deve essere limitato ai casi nei quali la cancellazione è semanticamente e storicamente accettabile.

Le regole definitive per le singole entità saranno tradotte in vincoli e operazioni server-side durante l'implementazione.

## 10.12 Idempotenza

Gli eventi provenienti da sistemi automatici devono poter essere riconosciuti in caso di retry o ritrasmissione.

La baseline prevede il principio:

```text
producer_device_id
        +
external_event_id
        ↓
evento identificabile univocamente
```

Quando questi identificativi sono applicabili, una seconda trasmissione dello stesso evento non deve generare un nuovo fatto duplicato.

Il vincolo SQL concreto verrà definito insieme alle entità automatiche interessate.

## 10.13 Single-writer

Quando una operazione richiede il possesso del ruolo di writer del Profile, non deve essere sufficiente che il client dichiari di possedere il lock.

L'autorizzazione deve verificare lo stato persistente di:

```text
profile_edit_locks
```

e le condizioni necessarie di validità del lock.

Acquisizione, rinnovo, scadenza, rilascio e takeover devono preservare l'invariante secondo cui non possono essere riconosciuti contemporaneamente writer incompatibili per lo stesso Profile.

## 10.14 Snapshot ambientali

`environment_context_snapshots` deve conservare soltanto il contesto ambientale necessario alla ricostruibilità della decisione o del fatto al quale è collegato.

`environment_context_links` deve collegare lo snapshot alle entità pertinenti mantenendo ownership e riferimenti coerenti.

Gli snapshot non devono trasformarsi in una duplicazione indiscriminata dello storico meteorologico completo disponibile presso le fonti autorevoli.

Il principio è:

```text
contesto necessario alla decisione
        =
persistibile

archivio meteorologico grezzo completo
        =
non duplicato automaticamente
```

## 10.15 Integrità prima della comodità del client

La struttura persistente non deve essere indebolita per rendere più semplice una specifica schermata o una particolare sequenza di richieste Flutter.

Quando esiste un conflitto tra:

```text
comodità del client
```

e:

```text
integrità persistente
```

deve essere preservata l'integrità del database.

Repository, servizi e mapping applicativi hanno il compito di adattare il dominio e l'interfaccia alla struttura persistente senza eliminare le garanzie definite dalla baseline.

---

# 11. Strategie di implementazione e migrazione

La baseline Database V1 definita nella Sessione S017 costituisce il riferimento logico e architetturale per la futura implementazione PostgreSQL/Supabase.

La sua approvazione non comporta una trasformazione immediata del database operativo esistente.

L'implementazione deve procedere in modo incrementale, verificabile e reversibile per quanto ragionevolmente possibile, mantenendo funzionante il progetto durante il passaggio dalla struttura attuale alla nuova baseline.

## 11.1 Baseline congelata come riferimento

Lo STEP 34 — Database V1 è stato dichiarato completato e congelato dopo il controllo nominale finale:

```text
52/52 entità di dominio
+
1 struttura tecnica profile_edit_locks
```

La successiva implementazione SQL deve quindi tradurre questa baseline senza riaprire continuamente le decisioni architetturali già approvate.

Una modifica della baseline deve essere valutata soltanto quando emerge:

- un errore concreto;
- una contraddizione non rilevata;
- una impossibilità tecnica dimostrata;
- un requisito indispensabile non rappresentabile dalla struttura congelata.

Una semplice preferenza implementativa non costituisce motivo sufficiente per modificare la baseline.

## 11.2 Stato attuale e stato obiettivo

Durante la migrazione devono essere mantenuti distinti:

```text
database operativo attuale
```

e:

```text
Database V1 progettato
```

Il primo rappresenta ciò che Supabase contiene e che l'applicazione può utilizzare realmente in un determinato momento.

Il secondo rappresenta lo schema obiettivo approvato.

La documentazione e le verifiche non devono dichiarare come implementata una struttura che esiste soltanto nella baseline progettuale.

## 11.3 Implementazione incrementale

La trasformazione verso il Database V1 non deve essere eseguita come una singola modifica monolitica.

Il principio operativo è:

```text
piccolo gruppo coerente di modifiche
        ↓
migration
        ↓
verifica
        ↓
test
        ↓
commit
        ↓
gruppo successivo
```

Ogni incremento deve lasciare il repository e il database in uno stato comprensibile e verificabile.

Questo approccio riduce il rischio di introdurre contemporaneamente errori strutturali, problemi di sicurezza e regressioni applicative difficili da isolare.

## 11.4 Ordine delle dipendenze

Le migration devono rispettare le dipendenze tra le entità.

In linea generale devono essere introdotte prima le strutture dalle quali dipendono le successive.

Un possibile ordine logico di alto livello è:

```text
identità e ownership
        ↓
catalogo agronomico
        ↓
struttura fisica
        ↓
relazioni e configurazioni
        ↓
fabbisogno e pianificazione
        ↓
fatti reali ed eventi
        ↓
economia e contesto ambientale
        ↓
infrastruttura tecnica necessaria
```

L'ordine SQL concreto dovrà essere definito analizzando foreign key, vincoli, funzioni, policy e dipendenze effettive.

## 11.5 Schema e sicurezza insieme

La creazione di una tabella non è considerata completa se la relativa sicurezza prevista dalla baseline non è stata affrontata.

Ogni gruppo di migration deve valutare insieme:

```text
tabella
+
foreign key
+
vincoli
+
indici necessari
+
RLS
+
policy
+
eventuali funzioni server-side
+
test
```

Non deve essere rimandata sistematicamente a una fase finale l'introduzione della sicurezza.

Una tabella esposta senza le protezioni richieste non rappresenta una implementazione completa del Database V1.

## 11.6 Migrazione dei dati esistenti

Quando una nuova struttura sostituisce o specializza dati già presenti nel database operativo, deve essere definita esplicitamente la strategia di migrazione.

Prima di modificare o rimuovere una struttura esistente devono essere verificati:

- dati realmente presenti;
- utilizzo da parte del codice Flutter;
- repository interessati;
- foreign key esistenti;
- policy RLS esistenti;
- possibilità di trasformare i dati senza perdita informativa.

La migrazione deve privilegiare la conservazione dei dati validi già presenti.

Non devono essere cancellati dati esistenti soltanto per semplificare l'adozione della nuova struttura.

## 11.7 Compatibilità con il codice applicativo

Le migration e il codice Flutter devono evolvere in modo coordinato.

Quando cambia la struttura persistente devono essere verificati almeno:

```text
modelli
repository
mapping
servizi
motori che consumano i dati
test
```

Non deve essere introdotta una dipendenza del codice applicativo da una struttura che non è ancora disponibile nel database utilizzato.

Quando necessario potranno essere adottati passaggi transitori compatibili con lo schema precedente e quello nuovo.

## 11.8 Repository come confine di persistenza

Il collegamento tra Supabase e dominio applicativo deve continuare a utilizzare il Repository Pattern.

Concettualmente:

```text
Supabase
        ↓
Repository
        ↓
mapping
        ↓
dominio Dart
```

Il dominio non deve dipendere direttamente dai dettagli della rappresentazione SQL quando tali dettagli possono essere confinati nel livello di persistenza.

Questo principio è particolarmente importante per la futura integrazione di:

```text
agronomic_window_rules
```

con:

```text
CropAgronomicWindowRule
AgronomicWindowResolver
AgronomicWindowEngine
AgronomicWindowService
```

La struttura persistente deve alimentare il dominio senza trasferire nel database la logica decisionale già consolidata negli engine Dart.

## 11.9 Migration tracciabili

Ogni modifica strutturale al database deve essere rappresentata da migration versionate e conservate nel repository secondo la struttura che verrà adottata per Supabase.

Non devono essere considerate sufficienti modifiche manuali eseguite esclusivamente dalla Dashboard senza una corrispondente rappresentazione riproducibile nel progetto.

Il principio è:

```text
modifica database
        ↓
migration tracciata
        ↓
repository Git
```

In questo modo lo stato del database può essere ricostruito e sottoposto a revisione.

## 11.10 Verifica delle migration

Ogni gruppo di migration deve essere sottoposto a verifiche appropriate prima di essere considerato completato.

Le verifiche dovranno comprendere, secondo il contenuto della migration:

- creazione corretta delle strutture;
- foreign key;
- vincoli;
- intervalli temporali;
- ownership;
- RLS;
- operazioni consentite;
- operazioni che devono essere rifiutate;
- compatibilità con repository e dominio;
- eventuale migrazione dei dati preesistenti.

I test devono includere anche casi negativi, non soltanto operazioni autorizzate e valide.

## 11.11 Backup e possibilità di recupero

Prima di migration distruttive o trasformazioni significative dei dati deve essere valutata una strategia di recupero adeguata.

In particolare, prima di operazioni che possano comportare perdita o trasformazione irreversibile devono essere verificate:

- disponibilità dei dati originali;
- possibilità di esportazione o backup;
- procedura di rollback quando tecnicamente possibile;
- procedura di ripristino quando un rollback automatico non è realistico.

La possibilità di applicare una migration non implica che essa debba essere eseguita senza una strategia di recupero.

## 11.12 Nessun big bang

La baseline delle 52 entità non deve essere interpretata come obbligo di creare contemporaneamente tutte le strutture fisiche.

L'implementazione deve procedere per blocchi coerenti e utili allo sviluppo effettivo dell'applicazione.

Il principio è:

```text
baseline completa
        ≠
implementazione simultanea
```

L'obiettivo è raggiungere progressivamente la baseline V1 mantenendo in ogni fase controllo tecnico, testabilità e tracciabilità.

## 11.13 Criterio di completamento

Il Database V1 potrà essere considerato realmente implementato soltanto quando la baseline progettuale sarà stata tradotta e verificata nel sistema operativo.

La sola presenza nominale delle tabelle non sarà sufficiente.

Il completamento richiederà almeno:

- strutture persistenti previste;
- relazioni e foreign key;
- invarianti;
- temporalità prevista;
- ownership;
- RLS e autorizzazioni;
- infrastruttura tecnica necessaria;
- migrazione dei dati esistenti quando applicabile;
- integrazione con repository e dominio;
- test di integrazione e sicurezza;
- documentazione aggiornata.

Fino a quel momento deve essere mantenuta esplicita la distinzione:

```text
Database V1 progettato
        ≠
Database V1 completamente implementato
```

---

# 12. Funzionalità escluse dal V1

La baseline Database V1 è stata progettata privilegiando le funzionalità necessarie al funzionamento concreto di Orto Smart ed evitando di introdurre anticipatamente strutture non indispensabili.

Le funzionalità indicate in questo capitolo sono state escluse consapevolmente dal Database V1.

La loro esclusione non rappresenta una dimenticanza progettuale, ma una decisione esplicita volta a mantenere il V1 compatto, comprensibile e implementabile.

Una funzionalità esclusa potrà essere rivalutata in una versione futura sulla base di un requisito concreto.

## 12.1 Inventario e magazzino

Il Database V1 non introduce un sistema di inventario o magazzino.

In particolare non appartiene alla baseline V1 una entità:

```text
inventory_items
```

né viene introdotta una gestione strutturata di:

- giacenze;
- movimenti di carico e scarico;
- lotti di magazzino;
- scadenze di magazzino;
- valorizzazione delle scorte;
- riconciliazioni inventariali.

Nel V1 gli acquisti e le spese possono essere registrati mediante:

```text
cost_events
```

mentre fertilizzazioni e trattamenti registrano direttamente le informazioni relative a ciò che è stato realmente utilizzato.

L'eventuale introduzione futura di un magazzino dovrà essere giustificata da esigenze operative concrete e non dovrà trasformare Orto Smart in un gestionale di magazzino non necessario.

## 12.2 Lotti di scorta

Il Database V1 non introduce una gestione separata dei lotti fisici di prodotti o materiali presenti in magazzino.

Non vengono quindi modellati nel V1 concetti quali:

```text
lotto acquistato
        ↓
giacenza residua
        ↓
consumi progressivi
        ↓
tracciamento di magazzino
```

Le informazioni necessarie a descrivere un trattamento, una fertilizzazione o una spesa devono essere conservate nell'evento pertinente senza richiedere obbligatoriamente l'esistenza preventiva di un lotto inventariale.

## 12.3 Ammortamenti

Il Database V1 non introduce un sistema di calcolo degli ammortamenti.

Gli investimenti strutturali possono essere registrati mediante:

```text
cost_events
```

e collegati, quando pertinente, a strutture, dispositivi o altri target.

Il calcolo contabile dell'ammortamento nel tempo rimane una funzionalità futura.

Questa scelta mantiene separata la registrazione del costo realmente sostenuto dalle elaborazioni contabili avanzate.

## 12.4 Contabilità avanzata

Orto Smart V1 non è progettato come software di contabilità generale.

Rimangono quindi escluse dal Database V1 funzionalità quali:

- partita doppia;
- piano dei conti;
- registrazioni contabili fiscali;
- gestione IVA;
- scritture di assestamento;
- bilanci contabili;
- gestione fiscale completa.

Il V1 mantiene invece le informazioni economiche necessarie alla gestione dell'orto attraverso strutture quali:

```text
cost_events
market_prices
harvest_events
harvest_valuations
```

Queste consentono analisi economiche utili senza introdurre un sistema contabile completo.

## 12.5 GIS e PostGIS

Il Database V1 non introduce una modellazione geografica GIS/PostGIS.

La rappresentazione fisica dell'orto viene gestita mediante strutture applicative quali:

```text
garden_areas
beds
bed_geometries
garden_structures
```

senza richiedere nel V1 funzionalità geospaziali avanzate.

L'eventuale adozione futura di PostGIS dovrà essere valutata soltanto qualora emergano requisiti che non possano essere soddisfatti in modo adeguato dalla rappresentazione geometrica prevista.

## 12.6 Multi-writer completo

Il Database V1 non implementa la modifica concorrente completa da parte di più writer dello stesso Profile.

Il modello approvato è:

```text
single-writer per Profile
```

coordinato mediante la struttura tecnica:

```text
profile_edit_locks
```

Una futura modalità multi-writer richiederebbe strategie aggiuntive per conflitti, concorrenza, sincronizzazione e versionamento.

Tale complessità non viene introdotta anticipatamente nel V1.

## 12.7 Multiutenza avanzata e condivisione del Garden

Il Database V1 non introduce un sistema avanzato nel quale più account applicativi distinti possiedano contemporaneamente ruoli e permessi articolati sullo stesso Garden.

Nel V1 il modello di ownership rimane centrato sulla catena:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

`workers` permette di rappresentare le persone che svolgono attività nell'orto senza trasformarle necessariamente in utenti autenticati.

L'eventuale evoluzione futura verso account personali distinti, condivisione del Garden e ruoli differenziati dovrà essere progettata separatamente senza modificare il significato di `workers`.

## 12.8 Archivio meteorologico grezzo duplicato

Il Database V1 non replica automaticamente in Supabase l'intero archivio storico meteorologico disponibile presso le fonti autorevoli.

La persistenza ambientale prevista è selettiva e utilizza:

```text
environment_context_snapshots
environment_context_links
```

quando è necessario conservare il contesto utilizzato per una decisione o collegato a un fatto.

Il principio è:

```text
storico meteorologico grezzo completo
        ↓
fonte autorevole

contesto necessario a Orto Smart
        ↓
snapshot selettivo
```

Questo evita duplicazioni di grandi quantità di dati che non apporterebbero valore aggiuntivo al Database V1.

## 12.9 Automazione irrigua completa

Il Database V1 predispone le strutture necessarie a rappresentare fonti idriche, zone, target, dispositivi ed eventi di irrigazione.

Non significa però che il V1 implementi già l'intero sistema hardware di irrigazione automatica.

La futura automazione mediante Raspberry Pi, sensori, elettrovalvole o altri dispositivi richiederà ulteriori componenti applicativi e infrastrutturali.

Il database deve essere predisposto a ricevere eventi e configurazioni coerenti, ma l'automazione hardware completa costituisce una fase successiva.

## 12.10 Correzione climatica e meteorologica avanzata

Le regole agronomiche V1 e gli snapshot ambientali forniscono le fondamenta per utilizzare il contesto ambientale senza incorporare prematuramente un modello climatico complesso.

Rimangono evoluzioni successive le correzioni decisionali avanzate basate, per esempio, su:

- andamento meteorologico reale;
- previsioni;
- temperature accumulate;
- rischio di gelo;
- anomalie stagionali;
- altri indicatori climatici.

Queste elaborazioni devono essere introdotte nei motori applicativi quando saranno definite e testabili, senza trasferire automaticamente la logica decisionale nel database.

## 12.11 Principio per le estensioni future

Una funzionalità esclusa dal V1 non deve essere introdotta soltanto perché potrebbe risultare utile in futuro.

Prima di estendere la baseline devono essere verificati:

```text
requisito concreto
        ↓
necessità reale
        ↓
impatto sul dominio
        ↓
impatto sul database
        ↓
decisione architetturale
        ↓
implementazione
```

Questo principio protegge Orto Smart dalla crescita non controllata dello schema e mantiene il database proporzionato alle esigenze effettive del progetto.

Le estensioni future dovranno inoltre preservare, quando possibile, la compatibilità semantica con i dati storici già registrati nel Database V1.

---

# 13. Considerazioni finali

Il Database V1 di Orto Smart costituisce la baseline logica e architetturale definita e congelata durante la Sessione S017.

La progettazione ha portato alla definizione di:

```text
52 entità di dominio
+
1 struttura tecnica profile_edit_locks
```

per un totale previsto di **53 strutture fisiche**, fermo restando che `profile_edit_locks` non appartiene al conteggio delle entità di dominio.

Il controllo nominale finale **52/52** ha inoltre consolidato due decisioni importanti:

- `agronomic_windows` non costituisce una tabella persistente del Database V1, poiché `AgronomicWindow` rimane un risultato calcolato a partire da `agronomic_window_rules`;
- `irrigation_zone_target_assignments` costituisce il nome SQL definitivo e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

## 13.1 Principi consolidati

La baseline Database V1 è fondata sui seguenti principi:

- separazione tra pianificazione e realtà;
- separazione tra configurazioni e fatti realmente avvenuti;
- identità stabile distinta dalle configurazioni storicizzate;
- storicizzazione selettiva quando necessaria;
- riduzione delle duplicazioni;
- utilizzo di dati derivati invece della loro persistenza quando possibile;
- ownership verificabile;
- sicurezza server-side;
- RLS con approccio deny-by-default;
- Flutter considerato client non fidato;
- separazione tra persistenza e logica decisionale del dominio;
- implementazione incrementale mediante migration tracciate;
- estensioni future introdotte soltanto in presenza di requisiti concreti.

Questi principi devono essere preservati durante la futura implementazione SQL/Supabase.

## 13.2 Stato raggiunto

Al termine della progettazione S017 il Database V1 è:

```text
progettato
        ✓

controllato nominalmente
        ✓

congelato
        ✓

documentato
        ✓

completamente implementato in Supabase
        ✗
```

La presenza della baseline nel presente manuale non deve quindi essere confusa con lo stato fisico del database operativo.

Le 52 entità non sono ancora tutte presenti in Supabase e le relative migration, policy RLS, funzioni server-side, invarianti e verifiche devono essere implementate progressivamente.

## 13.3 Passaggio alla fase di implementazione

La fase successiva dovrà tradurre la baseline progettuale in PostgreSQL/Supabase secondo il workflow definito nel presente manuale.

Il percorso generale sarà:

```text
baseline Database V1 congelata
        ↓
analisi dello schema Supabase esistente
        ↓
definizione del primo gruppo coerente di migration
        ↓
implementazione SQL
        ↓
vincoli e RLS
        ↓
integrazione repository / dominio
        ↓
test
        ↓
verifica
        ↓
commit e documentazione
```

Non dovrà essere effettuata una trasformazione monolitica dell'intero database.

Ogni incremento dovrà essere sufficientemente piccolo da poter essere verificato prima di procedere al successivo.

## 13.4 Relazione con il dominio applicativo

Il Database V1 non sostituisce il dominio Dart.

La separazione architetturale da preservare rimane:

```text
Supabase / PostgreSQL
        ↓
Repository
        ↓
mapping
        ↓
dominio Dart
        ↓
servizi ed engine
```

Il database conserva dati, relazioni, ownership, invarianti e informazioni necessarie alla ricostruibilità.

Il dominio applicativo mantiene invece la responsabilità delle valutazioni e delle decisioni agronomiche.

Un esempio fondamentale è:

```text
agronomic_window_rules
        ↓
Repository
        ↓
CropAgronomicWindowRule
        ↓
AgronomicWindowResolver
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowService
```

Questo consente alla persistenza di adattarsi al dominio consolidato senza trasferire impropriamente nel database la logica degli engine.

## 13.5 Evoluzione del documento

Il presente Manuale Database dovrà essere aggiornato insieme all'implementazione effettiva del Database V1.

Durante le future migration dovranno essere documentati almeno:

- schema SQL realmente implementato;
- tipi e precisioni definitivi;
- primary key e foreign key;
- vincoli;
- indici;
- policy RLS;
- funzioni server-side;
- strategie di migrazione dei dati;
- test di integrazione e sicurezza;
- eventuali differenze motivate rispetto alla baseline progettuale.

Qualora emerga la necessità di modificare una decisione congelata, la variazione dovrà essere tracciata nella documentazione architetturale e non introdotta silenziosamente durante l'implementazione.

## 13.6 Documentazione correlata

Il presente documento deve essere letto insieme agli altri documenti ufficiali di Orto Smart.

In particolare:

- **DOC-001 — Manuale Tecnico** descrive l'architettura generale dell'applicazione;
- **DOC-005 — Quaderno di Sviluppo** conserva la cronologia dettagliata delle sessioni;
- **DOC-006 — Linee Guida di Sviluppo** definisce le regole generali di sviluppo;
- **DOC-007 — Test e Collaudo** documenta i criteri e le verifiche di test;
- **DOC-008 — Roadmap di Sviluppo** definisce l'evoluzione pianificata;
- **DOC-009 — Workflow Operativo** descrive il processo operativo;
- **DOC-011 — Decisioni Architetturali** conserva le decisioni progettuali approvate;
- **DOC-012 — Registro Storico dello Sviluppo** mantiene il riepilogo storico complessivo;
- **CHANGELOG** registra sinteticamente le modifiche introdotte nelle diverse versioni.

Il **DOC-004 — Manuale Database** costituisce il riferimento specifico per la struttura persistente e per l'evoluzione del Database V1.

---

La baseline descritta nel presente documento rappresenta quindi il punto di partenza controllato per l'implementazione del nuovo database di Orto Smart.

Il principio da mantenere durante le successive sessioni è:

```text
prima progettare
        ↓
poi implementare
        ↓
sempre verificare
```

La progettazione S017 non deve essere riaperta durante l'implementazione salvo l'emersione di un errore concreto o di una necessità architetturale dimostrata.