# VERSION

| Campo             | Valore               |
| ----------------- | -------------------- |
| Progetto          | Orto Smart           |
| Versione corrente | 0.1.17-alpha         |
| Versione Flutter  | 0.1.16-alpha+2       |
| Stato             | Alpha                |
| Data versione     | 11/09/2026           |
| Linguaggio        | Flutter / Dart       |
| Backend           | Supabase             |
| Repository        | ortosmart/orto-smart |

---

La versione corrente identifica la versione pubblica del software.

Nel file `pubspec.yaml` la versione Flutter può temporaneamente non coincidere con la versione pubblica quando una sessione introduce esclusivamente modifiche al database, alle migration o alla documentazione senza modificare il client Flutter.

Alla conclusione della S026:

- versione pubblica corrente: `0.1.17-alpha`;
- versione Flutter presente in `pubspec.yaml`: `0.1.16-alpha+2`.

La S026 non ha modificato codice Dart/Flutter; l'allineamento applicativo del nuovo Catalogo DB V1 è previsto nella S027.

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

`update_garden`, `update_season` e `activate_season` applicano la concorrenza ottimistica mediante `expected_row_version` secondo il rispettivo contratto.

Il client Flutter dispone ora di:

- identità tecnica stabile del client;
- identità distinta della sessione applicativa;
- contesto Profile;
- Repository del lock;
- controller e scheduler della Profile Write Authority;
- scope applicativo;
- gate locale fail-closed;
- adapter tipizzato per le scritture autoritative di `seasons`.

Il controllo locale costituisce un preflight preventivo. Il database PostgreSQL rimane l'autorità definitiva per identità, autorizzazione, tempo, lock, takeover, controllo di versione e invarianti.

Con la versione `0.1.15-alpha` il Write Path autoritativo è stato esteso a `beds`.

Sono state implementate:

- l'identità stabile dell'aiuola in `beds`;
- la geometria storicizzata in `bed_geometries`;
- la registrazione delle rettifiche in `bed_geometry_corrections`;
- le RPC `create_bed`, `update_bed`, `set_bed_active`, `change_bed_geometry` e `correct_bed_geometry`;
- la concorrenza ottimistica mediante `row_version`;
- la separazione tra cambio ordinario della geometria e correzione storica;
- i modelli Flutter `Bed` e `BedGeometry`;
- risultati di scrittura tipizzati e fail-closed;
- l'estensione di `BedRepository`;
- `ProfileContextScope`;
- la pagina `CreateBedPage`;
- l'integrazione del percorso di creazione nella sezione Orto;
- la configurazione Supabase parametrizzabile mediante `SUPABASE_URL` e `SUPABASE_ANON_KEY`, mantenendo il remoto come default.

Le sei migration della versione risultano allineate tra ambiente locale e database remoto fino a `20260830140235`.

La creazione di un'aiuola attraverso interfaccia Flutter e Write Path autoritativo è stata verificata positivamente nell'ambiente Supabase locale.

La suite finale della versione `0.1.15-alpha` comprende **781/781 test superati**.

Con la versione `0.1.16-alpha` è stata completata l'integrazione Flutter di tutti i Write Path autoritativi già disponibili per `beds`.

Sono state implementate:

- la pagina `EditBedPage` per modificare numero, nome e note dell'aiuola;
- l'attivazione e la disattivazione dell'aiuola tramite `setBedActive`;
- la pagina `ChangeBedGeometryPage` per le variazioni geometriche ordinarie;
- la pagina `CorrectBedGeometryPage` per le correzioni storiche;
- la motivazione obbligatoria delle correzioni storiche;
- l'helper `CivilDate` per utilizzare `GG/MM/AAAA` nell'interfaccia, mantenendo `AAAA-MM-GG` nei modelli, nelle RPC e nel database;
- la gestione della concorrenza ottimistica mediante `expectedRowVersion`;
- la rilettura autoritativa dell'aiuola dopo ogni scrittura riuscita;
- il trattamento fail-closed degli esiti non confermabili, senza retry automatici;
- il funzionamento read-only di `BedPage` quando la Profile Write Authority non è disponibile.

La variazione ordinaria della geometria e la correzione storica rimangono operazioni distinte. Un esito `correction_required` non avvia automaticamente una rettifica storica, ma indirizza l'utente verso la funzione dedicata.

La Sessione S025 non ha introdotto nuove migration Supabase e utilizza le RPC autoritative implementate nella S024.

La suite finale della versione `0.1.16-alpha` comprende **841/841 test superati**. Le operazioni di modifica dati, attivazione e disattivazione, variazione geometrica e correzione storica sono state verificate positivamente anche mediante prova locale end-to-end.

Con la versione `0.1.17-alpha`, corrispondente alla Sessione S026, è stato implementato il **Catalogo DB V1** necessario prima del futuro Write Path autoritativo di `plantings`.

La gerarchia persistente del catalogo è:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

Le tre entità sono Profile-owned e condivise tra i Garden appartenenti allo stesso Profile.

Sono state introdotte le migration:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

Le entità del catalogo utilizzano identificativi UUID, rappresentati nel dominio Dart mediante `String`.

Il precedente modello applicativo legacy, che rappresentava la varietà come testo all'interno di `Crop`, non costituisce più il contratto persistente del Database V1.

Il Catalogo DB V1 introduce inoltre:

- `crop_varieties` come entità autonoma;
- collegamento di `crops` a `botanical_families`;
- `default_start_method` con valori canonici;
- valori agronomici di default a livello Crop;
- override opzionali a livello Crop Variety;
- fallback campo per campo Crop → Crop Variety per i valori agronomici previsti;
- blocco quantitativo per il fabbisogno idrico;
- blocco strutturato per la resa attesa;
- gestione degli stati attivo/inattivo;
- vincoli gerarchici di attivazione e disattivazione;
- unicità case-insensitive secondo il livello gerarchico;
- normalizzazione server-side dei testi;
- controllo delle temperature effettive dopo il fallback;
- `row_version` per la concorrenza ottimistica.

Per il fabbisogno idrico quantitativo sono previsti:

- `water_requirement_value`;
- `water_requirement_basis`;
- `water_interval_days`.

I valori consentiti per `water_requirement_basis` sono:

- `per_plant`;
- `per_m2`.

A livello Variety il blocco quantitativo dell'acqua deve essere completamente assente, ereditando il Crop, oppure completamente definito. Gli override parziali non sono consentiti.

Per la resa attesa sono previsti:

- `expected_yield_min`;
- `expected_yield_avg`;
- `expected_yield_max`;
- `expected_yield_unit`;
- `yield_source_name`;
- `yield_source_url`;
- `yield_source_year`;
- `yield_notes`.

La resa varietale, quando presente, costituisce un blocco autonomo e non utilizza fallback campo per campo.

Sono state introdotte nove RPC autoritative:

1. `create_botanical_family`;
2. `update_botanical_family`;
3. `set_botanical_family_active`;
4. `create_crop`;
5. `update_crop`;
6. `set_crop_active`;
7. `create_crop_variety`;
8. `update_crop_variety`;
9. `set_crop_variety_active`.

Le scritture dirette sulle entità del catalogo non costituiscono il Write Path applicativo.

Il percorso autoritativo segue il modello:

```text
Supabase Auth
    ↓
autorizzazione server-side
    ↓
Profile Write Authority
    ↓
RPC autoritativa
    ↓
lock della riga / verifica parent
    ↓
row_version
```

Il database rimane l'autorità definitiva per:

- identità;
- appartenenza al Profile;
- Profile Write Authority;
- gerarchia;
- invarianti;
- concorrenza;
- stato delle entità.

Le letture sono protette mediante RLS e appartenenza al Profile.

Le RPC sono `SECURITY DEFINER`, utilizzano `search_path` controllato e sono eseguibili esclusivamente dal ruolo `authenticated`.

I test SQL manuali della S026 hanno verificato casi positivi, negativi e concorrenti, comprese autorizzazioni, duplicati, normalizzazione, stati, gerarchia, fallback, acqua, resa, temperature effettive, RLS e privilegi.

`supabase db lint --local` non ha introdotto nuovi problemi riferibili alla S026.

`supabase db diff --local` ha restituito:

```text
No schema changes found
```

Le migration locali e remote risultano allineate fino a:

```text
20260911091047_add_crop_catalog_write_rpcs.sql
```

La S026 consolida inoltre il principio:

> **catalogo corrente + snapshot storico**

Le modifiche future al catalogo corrente non dovranno riscrivere retroattivamente dati, calcoli o decisioni storiche già consolidate.

Lo stesso principio dovrà essere applicato ai futuri dati storici legati ad acqua, irrigazione e decisioni agronomiche.

La versione `0.1.17-alpha` non introduce modifiche al client Flutter.

Il file `pubspec.yaml` rimane pertanto alla versione:

```text
0.1.16-alpha+2
```

Il successivo blocco tecnico approvato è:

> **S027 — Integrazione Flutter del Catalogo V1**

La S027 dovrà introdurre modelli Dart, result type, repository, letture RLS, scritture esclusivamente tramite RPC, integrazione con la Profile Write Authority, gestione di `row_version`, mapping completo degli esiti server-side e relativi test.

`public.plantings` rimane non implementata alla conclusione della S026 e sarà affrontata solo dopo il completamento dell'integrazione Flutter del Catalogo V1.

Le operazioni amministrative protette su `profile_memberships` rimangono un blocco successivo distinto.

Lo sviluppo prosegue secondo le priorità definite nella Roadmap di Sviluppo.

# Funzionalità implementate

## Gestione dati

- Gestione orti
- Gestione aiuole
- Gestione stagioni
- Catalogo DB V1 delle famiglie botaniche
- Catalogo DB V1 delle colture
- Catalogo DB V1 delle varietà
- Componenti Flutter legacy per la gestione delle colture, in attesa di allineamento al Catalogo DB V1 nella S027
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
- Inserimento colture mediante interfaccia legacy, non ancora integrata con il Catalogo DB V1 della S026

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

---

# Obiettivi della prossima versione

Il successivo blocco tecnico approvato è:

> **S027 — Integrazione Flutter del Catalogo V1**

La S027 ha come obiettivo l'integrazione nel client Flutter del Catalogo DB V1 implementato lato PostgreSQL/Supabase nella S026.

Il perimetro approvato comprende:

- modelli Dart del catalogo;
- result type per create, update e set active;
- repository;
- letture tramite RLS;
- scritture esclusivamente mediante RPC autoritative;
- integrazione con la Profile Write Authority;
- gestione della concorrenza mediante `row_version`;
- mapping completo degli esiti restituiti dalle RPC;
- test di repository e mapping;
- successiva valutazione della minima interfaccia necessaria per la gestione del catalogo.

`plantings` rimane fuori dal perimetro iniziale della S027.

L'implementazione del Write Path autoritativo di `plantings` verrà affrontata solo dopo il consolidamento dell'integrazione Flutter del Catalogo V1.

La pianificazione completa rimane definita nella **Roadmap di Sviluppo (DOC-008)**.

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
| 0.1.17-alpha | 11/09/2026 | Corrente | Implementato il Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, introdotte due migration e nove RPC autoritative, consolidati ownership Profile, UUID, fallback Crop → Crop Variety, acqua quantitativa, resa strutturata, RLS e concorrenza; integrazione Flutter rinviata alla S027. |

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