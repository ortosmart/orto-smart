# VERSION

| Campo             | Valore               |
| ----------------- | -------------------- |
| Progetto          | Orto Smart           |
| Versione corrente | 0.1.18-alpha         |
| Versione Flutter  | 0.1.18-alpha+3       |
| Stato             | Alpha                |
| Data versione     | 13/09/2026           |
| Linguaggio        | Flutter / Dart       |
| Backend           | Supabase             |
| Repository        | ortosmart/orto-smart |

---

La versione corrente identifica la versione pubblica del software.

Nel file `pubspec.yaml` la versione Flutter può temporaneamente non coincidere con la versione pubblica quando una sessione introduce esclusivamente modifiche al database, alle migration o alla documentazione senza modificare il client Flutter.

Tale situazione si è verificata nella Sessione S026:

```text
versione pubblica
0.1.17-alpha

versione Flutter
0.1.16-alpha+2
```

poiché la S026 aveva introdotto il Catalogo DB V1 esclusivamente lato PostgreSQL/Supabase.

Con la Sessione S027 il Catalogo V1 è stato integrato nel client Flutter.

La versione pubblica passa pertanto a:

```text
0.1.18-alpha
```

e il file `pubspec.yaml` viene riallineato a:

```text
0.1.18-alpha+3
```

La S027 non introduce nuove migration Supabase ma modifica il codice Dart/Flutter, i modelli del catalogo, il Repository Layer e i relativi test.

# Stato del progetto

Orto Smart è attualmente in fase **Alpha**.

L'architettura principale dell'applicazione è stata definita e il motore agronomico dispone dei componenti fondamentali per l'analisi delle aiuole e la generazione delle raccomandazioni.

A partire dalla versione `0.1.11-alpha` Orto Smart dispone di una baseline logica e architetturale completa del **Database V1**, progettata e congelata nella Sessione S017.

La baseline definisce:

- **52 entità di dominio**;
- la struttura tecnica separata `profile_edit_locks`;
- ownership e modello di accesso;
- accesso familiare monoutente nel V1;
- modello single-writer;
- temporalità e storicizzazione;
- invarianti;
- sicurezza e Row Level Security;
- strategia di implementazione incrementale in Supabase.

Le finestre agronomiche rimangono rappresentate nel dominio mediante `AgronomicWindow`, mentre la conoscenza persistente è prevista in `agronomic_window_rules`.

`AgronomicWindow` rimane un risultato calcolato e non viene introdotta una tabella persistente `agronomic_windows`.

La progettazione Database V1 è completata e congelata; a partire dalla versione `0.1.13-alpha` è iniziata anche la relativa implementazione fisica mediante migration PostgreSQL/Supabase versionate.

A partire dalla versione `0.1.12-alpha`, il dominio agronomico supporta più finestre agronomiche applicabili per la stessa coltura, varietà e metodo di avvio.

`AgronomicWindowResolver` restituisce l'insieme delle finestre applicabili rispettando la priorità delle regole specifiche della varietà rispetto alle regole generali della coltura.

`AgronomicWindowService` valuta tutte le finestre applicabili: il risultato è `compatible` se almeno una finestra è valida, `incompatible` se esistono finestre applicabili ma nessuna è valida e `unknown` quando non esistono finestre applicabili.

`AgronomicWindowEvaluation` distingue inoltre `matchedWindow`, cioè la finestra che ha prodotto la compatibilità, da `evaluatedWindows`, cioè l'insieme delle finestre considerate durante la valutazione.

La versione `0.1.12-alpha` ha predisposto l'ambiente locale necessario all'implementazione SQL del Database V1 mediante WSL 2, Ubuntu, Docker Desktop e Supabase CLI.

È stata inizializzata mediante `supabase init` la struttura locale versionata `supabase/`, destinata a contenere configurazione e migration del Database V1.

Il precedente `database/database_v1.sql`, relativo allo schema sperimentale iniziale, è stato conservato con il nuovo nome `database/database_legacy_initial.sql`.

La versione PostgreSQL del progetto Supabase remoto è stata verificata come `17.6`, coerente con `major_version = 17` della configurazione locale.

Con la versione `0.1.13-alpha` è stata creata la prima migration Database V1:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

La migration introduce il primo blocco **Fondazioni**:

- `profiles`;
- `profile_memberships`;
- `gardens`;
- `workers`;
- `seasons`;
- `profile_edit_locks`.

Sono stati inoltre introdotti lo schema `private`, gli helper autorizzativi, i trigger metadata e la prima matrice composta da **13 policy RLS**.

La migration è stata verificata localmente mediante `supabase db reset` e mediante test manuali positivi e negativi delle autorizzazioni.

La S019 costituisce quindi il **primo incremento fisicamente implementato e verificato** del Database V1; la baseline completa rimane ancora in corso di implementazione.

Con la versione `0.1.14-alpha` è stato completato il protocollo server-side di `profile_edit_locks`, comprendente acquisizione, heartbeat, rilascio, scadenza, richiesta e gestione del takeover e lettura autoritativa dello stato.

È stata introdotta la Profile Write Authority come prerequisito delle scritture protette.

Sono stati completati i Write Path autoritativi di Categoria A per:

- `gardens`, mediante `create_garden` e `update_garden`;
- `seasons`, mediante `create_season`, `update_season` e `activate_season`.

Le scritture dirette `INSERT`, `UPDATE` e `DELETE` da parte di `authenticated` sono revocate su `public.gardens` e `public.seasons`.

Il client Flutter dispone inoltre dell'identità tecnica del client, dell'identità della sessione applicativa, del contesto Profile e dell'infrastruttura della Profile Write Authority.

Con la versione `0.1.15-alpha` il Write Path autoritativo è stato esteso a:

```text
beds
bed_geometries
bed_geometry_corrections
```

mediante:

```text
create_bed
update_bed
set_bed_active
change_bed_geometry
correct_bed_geometry
```

Sono state consolidate:

- identità stabile dell'aiuola;
- geometria storicizzata;
- tracciamento delle rettifiche;
- concorrenza ottimistica mediante `row_version`;
- separazione tra cambio ordinario della geometria e correzione storica;
- integrazione Flutter della creazione dell'aiuola;
- configurazione Supabase parametrizzabile.

La suite finale della versione `0.1.15-alpha` comprende **781/781 test superati**.

Con la versione `0.1.16-alpha` è stata completata l'integrazione Flutter dei Write Path autoritativi di `beds`.

Sono state introdotte:

- `EditBedPage`;
- attivazione e disattivazione dell'aiuola;
- `ChangeBedGeometryPage`;
- `CorrectBedGeometryPage`;
- motivazione obbligatoria delle correzioni storiche;
- `CivilDate`;
- rilettura autoritativa dopo le scritture riuscite;
- comportamento fail-closed senza retry automatici.

La suite finale della versione `0.1.16-alpha` comprende **841/841 test superati**.

Con la versione `0.1.17-alpha`, corrispondente alla Sessione S026, è stato implementato il **Catalogo DB V1**:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

Il catalogo è Profile-owned e condiviso tra i Gardens appartenenti allo stesso Profile.

Sono state introdotte le migration:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

Le entità del catalogo utilizzano identificativi UUID.

Il Catalogo DB V1 introduce inoltre:

- `crop_varieties` come entità autonoma;
- collegamento di `crops` a `botanical_families`;
- `default_start_method` con valori canonici;
- valori agronomici di default a livello Crop;
- override opzionali a livello Crop Variety;
- fallback Crop → Crop Variety;
- fabbisogno idrico quantitativo;
- resa attesa strutturata;
- gestione degli stati attivo/inattivo;
- vincoli gerarchici;
- unicità case-insensitive;
- normalizzazione server-side;
- controllo delle temperature effettive;
- `row_version`.

Sono state introdotte nove RPC autoritative:

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

Le scritture dirette sulle tre entità del catalogo non costituiscono il Write Path applicativo.

Il percorso autoritativo è:

```text
Supabase Auth
        ↓
autorizzazione server-side
        ↓
Profile Write Authority
        ↓
RPC autoritativa
        ↓
lock / verifica parent
        ↓
row_version
```

Le letture sono protette mediante RLS.

La S026 ha verificato il catalogo mediante test SQL positivi, negativi e concorrenti e ha mantenuto allineate le migration locali e remote fino a:

```text
20260911091047_add_crop_catalog_write_rpcs.sql
```

La versione `0.1.17-alpha` non aveva modificato il client Flutter; per questo `pubspec.yaml` era rimasto temporaneamente a:

```text
0.1.16-alpha+2
```

Con la versione `0.1.18-alpha`, corrispondente alla Sessione S027, è stata completata l'**integrazione Flutter del Catalogo V1**.

È stato introdotto il modello dedicato:

```text
BotanicalFamily
```

e sono stati riallineati al contratto Database V1:

```text
Crop
CropVariety
```

`Crop` utilizza ora, tra gli altri:

- `profileId`;
- `botanicalFamilyId`;
- `defaultStartMethod`;
- parametri agronomici V1;
- fabbisogno idrico quantitativo;
- dati di resa;
- `isActive`;
- `rowVersion`;
- timestamp.

`CropVariety` utilizza:

- `id`, `profileId` e `cropId` come UUID `String`;
- `defaultStartMethod`;
- override agronomici V1;
- fabbisogno idrico quantitativo;
- dati di resa;
- `rowVersion`;
- timestamp.

È stato rimosso:

```text
CropVariety.toMap()
```

per evitare un percorso generico di scrittura diretta non coerente con l'architettura RPC-only.

Il Repository Layer del catalogo comprende ora:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

Le letture sono eseguite sotto protezione RLS.

Le scritture utilizzano esclusivamente le nove RPC autoritative introdotte nella S026.

Nei Repository del catalogo è stata verificata l'assenza di utilizzi diretti di:

```text
.insert()
.update()
.delete()
.upsert()
```

Sono stati introdotti result type dedicati con mapping esplicito degli esiti RPC, compresi:

```text
created
updated
unchanged
version_conflict
forbidden
write_forbidden
not_found
invalid_input
```

oltre agli esiti relativi a duplicati e vincoli gerarchici.

La Profile Write Authority continua a operare in modalità **fail-closed**.

La S027 ha mantenuto temporaneamente alcuni alias legacy:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

per garantire la compatibilità con componenti non ancora migrati.

Gli alias non costituiscono il nuovo contratto persistente e dovranno essere rimossi progressivamente.

La Sessione S027 non ha introdotto nuove migration Supabase.

La verifica applicativa ha prodotto:

```text
124 test mirati superati
914/914 test complessivi superati
flutter analyze: No issues found!
git diff --check: pulito
git diff --cached --check: pulito
```

La versione Flutter viene quindi riallineata alla versione pubblica mediante:

```text
0.1.18-alpha+3
```

Alla conclusione della S027 risultano completati:

- Catalogo DB V1 lato PostgreSQL/Supabase;
- Write Path autoritativi del Catalogo V1;
- modelli Flutter del catalogo;
- Repository Layer Flutter;
- letture RLS;
- scritture RPC-only;
- Profile Write Authority;
- gestione `row_version`;
- mapping tipizzato degli esiti;
- test del Repository Layer.

Restano aperti:

- UI minima di gestione del Catalogo V1;
- adattatore esplicito tra `defaultStartMethod` e i planting method legacy;
- rimozione progressiva degli alias legacy;
- Write Path autoritativo completo di `plantings`;
- operazioni amministrative protette su `profile_memberships`.

`public.plantings` rimane non implementata.

Lo sviluppo prosegue secondo le priorità che saranno approvate nella Roadmap di Sviluppo.

# Funzionalità implementate

## Gestione dati

- Gestione orti
- Gestione aiuole
- Gestione stagioni
- Catalogo DB V1 delle famiglie botaniche
- Catalogo DB V1 delle colture
- Catalogo DB V1 delle varietà
- Modello Flutter `BotanicalFamily`
- Modello Flutter `Crop` allineato al Catalogo DB V1
- Modello Flutter `CropVariety` allineato al Catalogo DB V1
- Repository Flutter del Catalogo V1
- Compatibilità legacy temporanea per i consumer non ancora migrati
- Componenti applicativi legacy per la gestione delle piantagioni; tabella e Write Path Database V1 di `plantings` ancora da implementare

## Interfaccia

- Dashboard iniziale
- Elenco aiuole
- Creazione autoritativa di una nuova aiuola
- Modifica dei dati generali dell'aiuola
- Attivazione e disattivazione dell'aiuola
- Variazione ordinaria della geometria
- Correzione storica della geometria con motivazione obbligatoria
- Formato data italiano `GG/MM/AAAA` nelle operazioni sulle aiuole
- Visualizzazione grafica delle aiuole
- Inserimento colture tramite flusso applicativo ancora parzialmente legacy
- UI amministrativa dedicata al Catalogo V1 non ancora implementata

## Motore agronomico

- PlantingValidator
- FreeSpaceEngine
- SuggestionEngine
- CompanionEngine
- BedAnalysisService
- BedCompanionAnalyzer
- RecommendationPipeline
- RecommendationMapper
- SpaceScoreCalculator
- DecisionEngine
- DecisionWeights
- FamilyNeedsEngine
- FamilyConsumptionNeed
- FamilyConsumptionNeedValidator
- PlannedPlantingBatch
- PlannedPlantingBatchValidator
- SuccessionPlanningEngine
- AgronomicWindow
- AgronomicWindowValidator
- AgronomicWindowEngine
- CropAgronomicWindowRule
- AgronomicWindowResolver
- AgronomicWindowEvaluation
- AgronomicWindowService

## Backend

- Supabase
- Repository Pattern
- Row Level Security (RLS)
- Ambiente locale Supabase
- WSL 2 / Ubuntu
- Docker Desktop
- Supabase CLI
- Struttura locale per migration Supabase versionate
- Prima migration Database V1 versionata
- Blocco Fondazioni Database V1
- Schema `private` e helper autorizzativi
- Trigger metadata
- Prima matrice di **13 policy RLS**
- Verifica locale mediante `supabase db reset`
- Test manuali positivi e negativi delle policy RLS
- Protocollo server-side completo `profile_edit_locks`
- Lease, heartbeat, scadenza e takeover
- Profile Write Authority
- Write Path autoritativo di `gardens`
- RPC `create_garden` e `update_garden`
- Concorrenza ottimistica di `update_garden`
- Write Path autoritativo di `seasons`
- RPC `create_season`, `update_season` e `activate_season`
- Tabelle `beds`, `bed_geometries` e `bed_geometry_corrections`
- Write Path autoritativo di `beds`
- RPC `create_bed`, `update_bed`, `set_bed_active`, `change_bed_geometry` e `correct_bed_geometry`
- Geometria storicizzata con intervalli temporali non sovrapposti
- Registro delle correzioni geometriche
- Concorrenza ottimistica di `beds` e `bed_geometries`
- Catalogo DB V1 con `botanical_families`, `crops` e `crop_varieties`
- Ownership del Catalogo DB V1 a livello Profile
- Identificativi UUID per famiglie botaniche, colture e varietà
- Fallback agronomico Crop → Crop Variety
- Gestione quantitativa del fabbisogno idrico
- Gestione strutturata della resa attesa
- Nove RPC autoritative del Catalogo DB V1
- Vincoli gerarchici tra famiglia botanica, coltura e varietà
- Concorrenza ottimistica mediante `row_version` sul Catalogo DB V1
- RLS in lettura sul Catalogo DB V1
- Revoca delle scritture dirette sulle entità protette
- `BotanicalFamilyRepository`
- `CropRepository` allineato al Catalogo DB V1
- `CropVarietyRepository` allineato al Catalogo DB V1
- Result type tipizzati del Catalogo V1
- Mapping esplicito e fail-closed degli status RPC
- Scritture Flutter del catalogo esclusivamente RPC-only
- Identità tecnica del client e della sessione applicativa
- Controller, scheduler, scope e gate della Profile Write Authority
- `ProfileContextScope`
- Configurazione Supabase parametrizzabile tramite `--dart-define`
- Repository Flutter tipizzati per i Write Path protetti già integrati
- Comportamento applicativo fail-closed

## Documentazione

- DOC-001 – Manuale Tecnico
- DOC-004 – Manuale Database
- DOC-005 – Quaderno di Sviluppo
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- DOC-009 – Workflow Operativo
- DOC-011 – Decisioni Architetturali
- DOC-012 – Registro Storico dello Sviluppo
- CHANGELOG

# Obiettivi della prossima versione

La Sessione S027 ha completato l'integrazione Flutter del Catalogo V1.

Alla conclusione della sessione restano aperti due principali incrementi tecnici distinti:

1. **UI minima di gestione del Catalogo V1**;
2. **Write Path autoritativo di `plantings`**.

Rimangono inoltre attività di consolidamento applicativo:

- introduzione di un adattatore esplicito tra `defaultStartMethod` V1 e i planting method legacy;
- migrazione dei consumer ancora dipendenti dagli alias legacy;
- rimozione progressiva di:
  - `Crop.sowingMethod`;
  - `Crop.botanicalFamily`;
  - `heavyFeeder`;
  - `CropVariety.defaultPlantingMethod`.

La UI amministrativa del Catalogo V1 e il Write Path di `plantings` devono rimanere blocchi tecnici distinti finché non viene approvata una diversa pianificazione.

`public.plantings` rimane non implementata nello schema Database V1 corrente.

La scelta del prossimo incremento sarà formalizzata nella successiva sessione di sviluppo e riportata nella **Roadmap di Sviluppo (DOC-008)**.

---

# Cronologia versioni

| Versione    | Data       | Stato      | Note                                                                                                                                                          |
| ----------- | ---------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto.                                                                                                                      |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico.                                                                            |
| 0.1.2-alpha | 28/07/2026 | Archiviata | Introdotti BedAnalysisService, BedCompanionAnalyzer e consolidata l'architettura del Motore Agronomico.                                                       |
| 0.1.3-alpha | 06/08/2026 | Archiviata | Introdotta RecommendationPipeline e consolidata la nuova architettura del Motore Agronomico.                                                                  |
| 0.1.4-alpha | 08/08/2026 | Archiviata | Introdotto DecisionWeights e resa configurabile la ponderazione dei criteri utilizzati dal DecisionEngine.                                                    |
| 0.1.5-alpha | 09/08/2026 | Archiviata | Implementata la prima versione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari.                                            |
| 0.1.6-alpha | 09/08/2026 | Archiviata | Integrato il FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| 0.1.7-alpha | 10/08/2026 | Archiviata   | Introdotti fabbisogni familiari quantitativi e lotti di coltivazione pianificati come fondamenta del futuro SuccessionPlanningEngine.                         |
| 0.1.8-alpha | 11/08/2026 | Archiviata   | Implementata la prima versione del SuccessionPlanningEngine per generare una sequenza temporale validata di lotti pianificati a partire dal fabbisogno familiare quantitativo e periodico. |
| 0.1.9-alpha | 11/08/2026 | Archiviata   | Introdotti AgronomicWindow, AgronomicWindowValidator e AgronomicWindowEngine per rappresentare le finestre agronomiche e verificare separatamente la compatibilità temporale dei lotti pianificati. |
| 0.1.10-alpha | 12/08/2026 | Archiviata   | Associate le finestre agronomiche a colture e varietà mediante CropAgronomicWindowRule, AgronomicWindowResolver, AgronomicWindowEvaluation e AgronomicWindowService, con fallback varietà → coltura e distinzione tra `unknown` e `incompatible`. |
| 0.1.11-alpha | 16/08/2026 | Archiviata | Completata e congelata nella S017 la progettazione della baseline Database V1: 52 entità di dominio più la struttura tecnica `profile_edit_locks`, con ownership, accesso familiare monoutente, modello single-writer, temporalità, sicurezza, invarianti e strategia di implementazione incrementale in Supabase. |
| 0.1.12-alpha | 16/08/2026 | Archiviata | Introdotto il supporto alle finestre agronomiche multiple e predisposto l'ambiente Supabase locale versionato per la futura implementazione incrementale della baseline Database V1; verificati 151/151 test e mantenuto invariato il database remoto. |
| 0.1.13-alpha | 18/08/2026 | Archiviata | Creata la prima migration Database V1 e implementato e verificato localmente il blocco Fondazioni con schema `private`, helper autorizzativi, trigger metadata e 13 policy RLS; consolidato il primo incremento fisico della baseline Database V1. |
| 0.1.14-alpha | 28/08/2026 | Archiviata | Completato il protocollo `profile_edit_locks`, introdotta la Profile Write Authority, implementati i Write Path autoritativi di `gardens` e `seasons`, integrata la sessione Profile nel client Flutter e verificati 237/237 test. |
| 0.1.15-alpha | 01/09/2026 | Archiviata | Implementati `beds`, geometria storicizzata e relativo Write Path autoritativo, integrata la creazione dell'aiuola nel client Flutter, parametrizzata la configurazione Supabase e verificati 781/781 test. |
| 0.1.16-alpha | 03/09/2026 | Archiviata | Completata l'integrazione UI dei Write Path autoritativi di `beds`, introdotte modifica dati, attivazione e disattivazione, variazione geometrica, correzione storica e gestione italiana delle date; verificati 841/841 test. |
| 0.1.17-alpha | 11/09/2026 | Archiviata | Implementato il Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, introdotte due migration e nove RPC autoritative, consolidati ownership Profile, UUID, fallback Crop → Crop Variety, acqua quantitativa, resa strutturata, RLS e concorrenza; integrazione Flutter rinviata alla S027. |
| 0.1.18-alpha | 13/09/2026 | Corrente | Completata nella S027 l'integrazione Flutter del Catalogo V1 mediante `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version` e verifica completa con 914/914 test; `pubspec.yaml` riallineato a `0.1.18-alpha+3`. |

---

# Documentazione correlata

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-004 – Manuale Database
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- DOC-009 – Workflow Operativo
- DOC-011 – Decisioni Architetturali
- DOC-012 – Registro Storico dello Sviluppo
- CHANGELOG

---

# Note

Le modifiche dettagliate sono riportate nel **CHANGELOG**, mentre il resoconto completo delle attività di sviluppo è documentato nel **DOC-005 – Quaderno di Sviluppo**. Le regole di sviluppo del progetto sono definite nel **DOC-006 – Linee Guida di Sviluppo**.