# VERSION

| Campo             | Valore               |
| ----------------- | -------------------- |
| Progetto          | Orto Smart           |
| Versione corrente | 0.1.14-alpha         |
| Stato             | Alpha                |
| Data versione     | 28/08/2026           |
| Linguaggio        | Flutter / Dart       |
| Backend           | Supabase             |
| Repository        | ortosmart/orto-smart |

---

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

Il controllo locale costituisce un preflight preventivo. Il database PostgreSQL rimane l’autorità definitiva per identità, autorizzazione, tempo, lock, takeover, controllo di versione e invarianti.

La suite finale della versione comprende **237/237 test superati**.

Il prossimo blocco tecnico concordato è l’implementazione coordinata di `beds` e `bed_geometries`, con identità stabile dell’aiuola, geometria storicizzata e Write Path autoritativo.

Le operazioni amministrative protette su `profile_memberships` rimangono un blocco successivo distinto.

Lo sviluppo prosegue secondo le priorità definite nella Roadmap di Sviluppo.


---

# Funzionalità implementate

## Gestione dati

- Gestione orti
- Gestione aiuole
- Gestione colture
- Gestione stagioni
- Gestione piantagioni

## Interfaccia

- Dashboard iniziale
- Elenco aiuole
- Visualizzazione grafica delle aiuole
- Inserimento colture

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
- Revoca delle scritture dirette su `gardens` e `seasons`
- Identità tecnica del client e della sessione applicativa
- Controller, scheduler, scope e gate della Profile Write Authority
- Repository Flutter tipizzati per i Write Path protetti
- Comportamento applicativo fail-closed

## Documentazione

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- DOC-009 – Workflow Operativo
- DOC-011 – Decisioni Architetturali
- CHANGELOG

---

# Obiettivi della prossima versione

Gli obiettivi della prossima versione del software sono definiti nella **Roadmap di Sviluppo (DOC-008)**.

Il presente documento riporta esclusivamente la versione corrente del software e il relativo stato di avanzamento, evitando duplicazioni con la documentazione di pianificazione del progetto.

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
| 0.1.14-alpha | 28/08/2026 | Corrente | Completato il protocollo `profile_edit_locks`, introdotta la Profile Write Authority, implementati i Write Path autoritativi di `gardens` e `seasons`, integrata la sessione Profile nel client Flutter e verificati 237/237 test. |

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