# ORTO SMART

### DOC-004

# Manuale Database

**Versione:** 2.1
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 16/08/2026
**Ultimo aggiornamento:** 17/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
| --- | --- |
| Documento | DOC-004 |
| Titolo | Manuale Database |
| Versione | 2.1 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 16/08/2026 |
| Ultimo aggiornamento | 17/09/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
| --- | --- | --- |
| 1.0 | 16/08/2026 | Prima emissione del Manuale Database e documentazione della baseline Database V1 progettata nella Sessione S017 |
| 1.1 | 16/08/2026 | Aggiornamento con la Sessione S018: predisposizione dell'ambiente locale Supabase, inizializzazione della struttura per migration versionate, conservazione dello schema sperimentale come `database_legacy_initial.sql`, verifica di PostgreSQL 17.6 e definizione del punto di avvio della futura baseline SQL Database V1 |
| 1.2 | 18/08/2026 | Aggiornamento con la Sessione S019: creazione della prima migration Database V1, implementazione e verifica locale delle Fondazioni, introduzione dello schema `private`, helper autorizzativi, trigger metadata, prima matrice di 13 policy RLS, test positivi e negativi e definizione delle RPC sicure e atomiche come successivo incremento tecnico |
| 1.3 | 20/08/2026 | Aggiornamento con la Sessione S020: hardening di `profile_edit_locks`, introduzione dello stato sicuro di takeover, implementazione e verifica delle prime cinque RPC server-side per acquisizione, heartbeat, rilascio, richiesta e annullamento del takeover, consolidamento delle regole di sicurezza, concorrenza, token e temporizzazione e distinzione delle operazioni di takeover ancora da completare |
| 1.4 | 23/08/2026 | Aggiornamento con la Sessione S021: completamento e hardening del protocollo `profile_edit_locks`, verifica delle transizioni concorrenti mediante `FOR UPDATE`, rivalidazione server-side e definizione del successivo Write Path autoritativo delle entità di Categoria A |
| 1.5 | 24/08/2026 | Aggiornamento con la Sessione S022: introduzione del primo Write Path autoritativo di Categoria A per `gardens`, helper `Profile Write Authority`, RPC `create_garden` e `update_garden`, revoca delle scritture dirette da parte di `authenticated`, validazioni server-side e controllo della concorrenza |
| 1.6 | 28/08/2026 | Aggiornamento con la Sessione S023: hardening concorrente di `update_garden`, introduzione del Write Path autoritativo di `seasons` mediante `create_season`, `update_season` e `activate_season`, revoca delle scritture dirette, concorrenza ottimistica tramite `row_version` e attivazione atomica della stagione |
| 1.7 | 01/09/2026 | Aggiornamento con la Sessione S024: implementazione V1 di `beds`, `bed_geometries` e `bed_geometry_corrections`, Write Path autoritativo delle aiuole, storicizzazione geometrica, concorrenza ottimistica, tracciamento delle correzioni e allineamento delle migration locale/remoto |
| 1.8 | 03/09/2026 | Manutenzione straordinaria del Manuale Database: chiarimento della distinzione tra componenti legacy e schema Database V1 implementato, documentazione dell'assenza corrente di `public.plantings` e separazione delle otto tabelle di dominio dalla struttura tecnica `profile_edit_locks` |
| 1.9 | 11/09/2026 | Aggiornamento con la Sessione S026: implementazione del Catalogo DB V1 costituito da `botanical_families`, `crops` e `crop_varieties`, introduzione dei relativi Write Path autoritativi, validazioni agronomiche e gerarchiche, concorrenza ottimistica, Profile Write Authority, RLS, revoca delle scritture dirette e allineamento delle migration locale/remoto |
| 2.0 | 13/09/2026 | Aggiornamento con la Sessione S027: integrazione Flutter del Catalogo DB V1 mediante `BotanicalFamily`, `Crop` e `CropVariety`, introduzione e riallineamento dei Repository dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version`, result type tipizzati, compatibilità legacy temporanea e verifica applicativa con 914/914 test superati |
| 2.1 | 17/09/2026 | Aggiornamento con la Sessione S028: implementazione del modello autoritativo di `plantings`, introduzione delle migration dedicate e delle RPC `create_planting`, `update_planting` e `set_planting_status`, lifecycle autoritativo, vincoli metodo-dipendenti, sovrapposizione spaziale e temporale half-open, integrazione con la geometria storicizzata delle aiuole, protezione delle variazioni geometriche mediante `blocked_by_plantings`, Profile Write Authority, concorrenza ottimistica e verifica finale del database e dell'applicazione |

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

- il database Supabase operativo utilizzato dall'applicazione;
- la baseline logica del **Database V1**, progettata e congelata durante la Sessione S017;
- l'implementazione fisica progressiva della baseline, avviata nella Sessione S019;
- i Write Path autoritativi e i meccanismi di sicurezza già implementati;
- l'integrazione Flutter delle strutture già portate nel contratto applicativo;
- le entità e i flussi della baseline che devono ancora essere implementati.

La baseline Database V1 costituisce il riferimento ufficiale per la sua traduzione progressiva in PostgreSQL/Supabase e per il successivo allineamento del client Flutter.

La progettazione V1 comprende **52 entità di dominio**.

A queste si aggiunge:

```text
profile_edit_locks
```

prevista come struttura tecnica separata per il controllo della concorrenza e pertanto non conteggiata come 53ª entità di dominio.

Con la Sessione S019 è stata creata la prima migration Database V1:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

Da allora l'implementazione procede per incrementi verificabili.

Alla conclusione della Sessione S028 risultano, tra gli altri, implementati:

- Fondazioni Database V1;
- protocollo `profile_edit_locks`;
- Profile Write Authority;
- Write Path autoritativi di `gardens`;
- Write Path autoritativi di `seasons`;
- Write Path autoritativi di `beds`;
- Catalogo DB V1:
  - `botanical_families`;
  - `crops`;
  - `crop_varieties`;
- nove RPC autoritative del catalogo;
- integrazione Flutter del Catalogo V1 tramite modelli, Repository, result type e mapping tipizzato;
- modello persistente autoritativo di `plantings`;
- Write Path autoritativo di `plantings`;
- lifecycle server-side delle coltivazioni;
- integrazione Flutter necessaria alla creazione e modifica delle coltivazioni.

La Sessione S028 ha introdotto le migration:

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

`public.plantings` è quindi presente nello schema Database V1 implementato.

Il Write Path di `plantings` applica:

- Profile Write Authority;
- controllo server-side delle relazioni;
- validazioni metodo-dipendenti;
- controllo della geometria;
- controllo delle sovrapposizioni spaziali e temporali;
- lifecycle autoritativo;
- concorrenza ottimistica mediante `row_version`;
- comportamento fail-closed.

Le variazioni della geometria delle aiuole sono inoltre protette rispetto alle coltivazioni esistenti mediante il possibile esito:

```text
blocked_by_plantings
```

La verifica finale S028 ha confermato:

```text
supabase db reset
success
```

```text
supabase db lint --local
No schema errors found
```

```text
flutter analyze
No issues found!
```

```text
flutter test
997 tests passed
```

Il Database V1 non è ancora completamente implementato.

La UI amministrativa dedicata al Catalogo V1 non è ancora implementata.

Per `plantings` rimangono inoltre da completare, lato applicativo:

- UI completa del lifecycle;
- selezione della varietà;
- gestione esplicita di `end_date` nelle transizioni terminali;
- progressiva eliminazione delle dipendenze legacy residue.

Il presente manuale documenta quindi sia la **baseline congelata** sia lo **stato effettivamente raggiunto**, mantenendo distinta la progettazione completa dall'implementazione progressiva.

# 2. Stato del database

Il progetto Orto Smart si trova in una fase di transizione tra il database operativo attualmente utilizzato dall'applicazione e la nuova architettura Database V1 progettata nella Sessione S017.

È pertanto necessario distinguere chiaramente lo **stato implementato** dallo **stato progettato**.

## 2.1 Database attualmente implementato

L'applicazione utilizza **Supabase**, basato su PostgreSQL, come backend persistente.

Nel codice applicativo sono presenti componenti appartenenti a fasi evolutive differenti del progetto, ma dalla Sessione S028 anche il dominio delle coltivazioni reali dispone di un modello persistente e di un Write Path autoritativo coerente con il Database V1.

Le strutture del Database V1 già implementate e utilizzabili comprendono, tra le altre:

- `gardens`;
- `beds`;
- `bed_geometries`;
- `seasons`;
- `botanical_families`;
- `crops`;
- `crop_varieties`;
- `plantings`.

Rimangono componenti applicativi legacy ancora utilizzati in alcuni flussi, in particolare per:

- alcuni utilizzi storici dei dati delle colture;
- motore di rotazione;
- alias temporanei del Catalogo V1.

La presenza di componenti legacy non modifica il contratto persistente autoritativo delle strutture già migrate.

La Sessione S026 ha completato il blocco propedeutico del **Catalogo DB V1**, introducendo nello schema reale:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

La Sessione S027 ne ha completato l'integrazione Flutter mediante:

- modello dedicato `BotanicalFamily`;
- riallineamento di `Crop`;
- riallineamento di `CropVariety`;
- `BotanicalFamilyRepository`;
- `CropRepository`;
- `CropVarietyRepository`;
- letture sotto protezione RLS;
- scritture esclusivamente mediante le nove RPC autoritative;
- Profile Write Authority fail-closed;
- gestione di `row_version`;
- result type e mapping esplicito degli status RPC.

La Sessione S028 ha quindi introdotto nello schema reale:

```text
public.plantings
```

mediante le migration:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

La prima migration introduce e consolida il modello persistente autoritativo delle coltivazioni reali.

La seconda introduce il relativo Write Path mediante:

```text
create_planting
update_planting
set_planting_status
```

`plantings` è collegata esplicitamente al proprio contesto mediante:

```text
profile_id
garden_id
season_id
bed_id
crop_id
variety_id
```

e conserva le informazioni necessarie a rappresentare:

- metodo di avvio;
- data di inizio dell'occupazione;
- eventuale data di fine;
- geometria longitudinale;
- larghezza pratica occupata;
- sesti;
- quantità;
- stato lifecycle;
- note;
- concorrenza tramite `row_version`.

Il Write Path applica Profile Write Authority, validazioni server-side, vincoli relazionali, controllo della geometria, controllo delle sovrapposizioni e concorrenza ottimistica.

Le operazioni Flutter ordinarie su `plantings` utilizzano il Repository Layer e le RPC autoritative senza eseguire scritture dirette sulla tabella.

La UI amministrativa dedicata al Catalogo V1 non è ancora implementata.

Il Database V1 completo non coincide ancora con l'intera baseline delle 52 entità progettate nella S017: l'implementazione fisica continua incrementalmente.

Lo stato fisicamente implementato del Database V1 è riportato nel paragrafo 2.3 e deve essere distinto sia dalla baseline completa progettata sia dagli eventuali componenti legacy ancora presenti nel codice Flutter.

La presenza di una entità nella baseline Database V1 non implica automaticamente che tutte le altre strutture, relazioni, policy o funzionalità appartenenti alla baseline siano già state implementate.

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

Al termine della Sessione S028 la situazione del Database V1 è la seguente:

- la progettazione logica e architetturale completata nella S017 rimane la baseline ufficiale congelata;
- l'ambiente locale Supabase predisposto nella S018 è operativo per sviluppo, ricostruzione e collaudo;
- sono implementate migration versionate fino alle due migration S028 dedicate a `plantings`;
- è implementato il gruppo **Fondazioni**;
- sono presenti lo schema `private`, gli helper autorizzativi, i trigger metadata e la matrice RLS;
- è completato e verificato il protocollo server-side `profile_edit_locks`;
- è disponibile la Profile Write Authority server-side;
- `gardens` dispone del Write Path autoritativo mediante `create_garden` e `update_garden`;
- `seasons` dispone del Write Path autoritativo mediante `create_season`, `update_season` e `activate_season`;
- `beds` dispone del Write Path autoritativo mediante `create_bed`, `update_bed`, `set_bed_active`, `change_bed_geometry` e `correct_bed_geometry`;
- il Catalogo DB V1 dispone delle tabelle `botanical_families`, `crops` e `crop_varieties`;
- il catalogo è Profile-owned e condiviso tra tutti i Gardens appartenenti allo stesso Profile;
- il Write Path autoritativo del catalogo è implementato mediante nove RPC dedicate di creazione, aggiornamento e variazione dello stato attivo;
- le scritture dirette `INSERT`, `UPDATE` e `DELETE` su `botanical_families`, `crops` e `crop_varieties` sono revocate ad `authenticated`;
- la lettura del catalogo è protetta mediante RLS;
- le operazioni di modifica richiedono una Profile Write Authority valida;
- la concorrenza ottimistica utilizza `row_version` ed `expected_row_version` quando previsto dal contratto;
- i parent vengono lockati quando necessario per serializzare correttamente operazioni concorrenti sulle gerarchie padre/figlio;
- le validazioni agronomiche e gerarchiche del catalogo vengono eseguite server-side;
- il Catalogo DB V1 è integrato nel client Flutter;
- sono implementati `BotanicalFamilyRepository`, `CropRepository` e `CropVarietyRepository`;
- le letture Flutter del catalogo utilizzano direttamente la RLS;
- le scritture Flutter del catalogo utilizzano esclusivamente le nove RPC autoritative;
- il mapping degli esiti RPC è tipizzato e fail-closed;
- `public.plantings` è implementata nello schema Database V1;
- il Write Path autoritativo di `plantings` è disponibile mediante `create_planting`, `update_planting` e `set_planting_status`;
- `PlantingRepository` utilizza le RPC autoritative per le scritture ordinarie;
- le coltivazioni utilizzano Profile Write Authority in modalità fail-closed;
- `plantings` utilizza `row_version` per la concorrenza ottimistica;
- la geometria delle coltivazioni viene verificata rispetto alla geometria valida dell'aiuola;
- le sovrapposizioni vengono controllate considerando congiuntamente occupazione spaziale e temporale;
- le modifiche alla geometria delle aiuole sono protette rispetto alle coltivazioni esistenti;
- `change_bed_geometry` e `correct_bed_geometry` possono restituire `blocked_by_plantings`;
- il lifecycle autoritativo delle coltivazioni è implementato server-side;
- la UI amministrativa dedicata al Catalogo V1 non è ancora implementata;
- la gestione UI completa del lifecycle di `plantings` rimane un incremento successivo;
- il Database V1 completo non è ancora implementato.

Le strutture applicative e di dominio attualmente implementate comprendono:

```text
profiles
profile_memberships
gardens
workers
seasons
beds
bed_geometries
bed_geometry_corrections
botanical_families
crops
crop_varieties
plantings
```

A queste si aggiunge la struttura tecnica separata:

```text
profile_edit_locks
```

Le migration principali introdotte dalla Sessione S024 sono:

```text
20260830091156_add_beds_and_geometry_history.sql
20260830095426_add_beds_write_rpcs.sql
20260830101354_add_bed_geometry_write_rpcs.sql
20260830103544_add_bed_geometry_corrections.sql
20260830133429_harden_bed_geometry_write_rpcs.sql
```

Le migration del Catalogo DB V1 introdotte nella Sessione S026 sono:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

Le migration di `plantings` introdotte nella Sessione S028 sono:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

La verifica S028 ha confermato la ricostruibilità e la coerenza dello schema mediante:

```text
supabase db reset
success
```

e:

```text
supabase db lint --local
No schema errors found
```

Sul lato Flutter la verifica completa ha inoltre prodotto:

```text
flutter analyze
No issues found!
```

e:

```text
flutter test
997 tests passed
```

---

# 3. Principi architetturali del Database V1

La progettazione del Database V1 è stata guidata da un insieme di principi architetturali destinati a preservare coerenza, tracciabilità, efficienza e possibilità di evoluzione.

## 3.1 Separazione tra pianificazione e realt�

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
preferenza / priorit�
        �
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
        �
WorkLog
```

Un task descrive ciò che deve essere fatto; un work log registra ciò che è stato realmente eseguito.

## 4.8 Realtà colturale e lavoro

33. `plantings`
34. `work_logs`
35. `work_log_targets`

`plantings` rappresenta ciò che viene realmente coltivato e rimane semanticamente distinta dalla pianificazione contenuta in `planned_plantings`.

Una `PlannedPlanting` può originare:

```text
0..N Plantings
```

Dalla Sessione S028 `public.plantings` è implementata fisicamente nel Database V1 e dispone di un proprio Write Path autoritativo.

Il contesto di ogni coltivazione viene rappresentato mediante:

```text
id
profile_id
garden_id
season_id
bed_id
crop_id
variety_id
```

`variety_id` può essere assente quando la coltivazione viene registrata soltanto a livello di coltura.

Il modello persistente comprende inoltre:

```text
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

## Metodi di avvio

I valori persistiti ammessi per:

```text
start_method
```

sono:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il precedente valore UI:

```text
manual
```

non costituisce un metodo agronomico persistito.

Le validazioni dipendono dal metodo di avvio.

Per:

```text
purchased_seedlings
nursery_then_transplant
```

sono richiesti:

```text
plants_count
plant_spacing_cm
```

mentre:

```text
seed_quantity_g
```

deve essere nullo.

`rows_count` e `row_spacing_cm` devono risultare entrambi null oppure entrambi valorizzati.

Per:

```text
direct_rows
```

sono richiesti:

```text
rows_count
row_spacing_cm
```

mentre possono essere presenti, quando coerenti:

```text
plants_count
plant_spacing_cm
seed_quantity_g
```

Per:

```text
direct_broadcast
```

devono essere null:

```text
rows_count
row_spacing_cm
plant_spacing_cm
plants_count
```

ed è richiesto:

```text
seed_quantity_g
```

## Occupazione geometrica

La geometria della coltivazione utilizza:

```text
start_position_cm
length_cm
occupied_width_cm
```

`start_position_cm` rappresenta la posizione longitudinale iniziale nell'aiuola.

`length_cm` rappresenta la lunghezza longitudinale occupata.

`occupied_width_cm` rappresenta la larghezza pratica assegnata alla coltivazione.

Non viene persistita una coordinata trasversale di partenza.

L'intervallo longitudinale utilizza semantica half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

Due coltivazioni possono quindi toccarsi esattamente sul confine senza essere considerate sovrapposte.

Quando presenti, i sesti devono rispettare:

```text
(rows_count - 1) * row_spacing_cm <= occupied_width_cm
```

e:

```text
(plants_count - 1) * plant_spacing_cm <= length_cm
```

La seconda relazione utilizza il numero totale di piante, non un valore derivato di piante per fila.

## Occupazione temporale

`start_date` rappresenta l'inizio della reale occupazione fisica dell'aiuola.

La data:

- non può essere futura;
- partecipa alla verifica della compatibilità con la geometria storicizzata dell'aiuola;
- costituisce il limite iniziale dell'occupazione temporale.

`end_date` rimane nullo mentre la coltivazione occupa ancora l'aiuola.

È obbligatorio negli stati terminali:

```text
finished
removed
```

e deve rispettare:

```text
end_date >= start_date
```

oltre a non poter essere futuro.

La semantica temporale dell'occupazione è coerente con il modello half-open adottato per la geometria.

## Lifecycle

Gli stati persistiti sono:

```text
sown
growing
harvest_ready
harvested
finished
removed
```

Le transizioni consentite sono:

```text
sown          -> growing | removed
growing       -> harvest_ready | removed
harvest_ready -> harvested | removed
harvested     -> finished | removed
finished      -> nessuna
removed       -> nessuna
```

Lo stato iniziale dipende dal metodo.

Per:

```text
purchased_seedlings
nursery_then_transplant
```

lo stato iniziale è:

```text
growing
```

Per:

```text
direct_rows
direct_broadcast
```

lo stato iniziale è:

```text
sown
```

Lo stato:

```text
harvested
```

non chiude l'occupazione fisica dell'aiuola.

La coltivazione continua quindi a partecipare ai controlli di occupazione fino al passaggio a:

```text
finished
removed
```

## Sovrapposizioni

Una sovrapposizione viene rifiutata quando coincidono contemporaneamente:

1. occupazione temporale;
2. occupazione longitudinale.

La verifica tiene conto della geometria dell'aiuola valida durante l'intero periodo interessato dalla coltivazione.

La protezione opera anche nel verso opposto: una variazione o correzione della geometria dell'aiuola non può rendere incompatibili coltivazioni già registrate.

Le RPC:

```text
change_bed_geometry
correct_bed_geometry
```

possono pertanto restituire:

```text
blocked_by_plantings
```

## Write Path

Il Write Path autoritativo utilizza:

```text
create_planting
update_planting
set_planting_status
```

`create_planting` concentra server-side:

- autorizzazione;
- Profile Write Authority;
- controllo delle entità collegate;
- stato attivo delle entità pertinenti;
- validazione del metodo;
- validazione delle quantità;
- validazione geometrica;
- validazione temporale;
- controllo degli overlap.

`update_planting` gestisce le modifiche ordinarie e utilizza la concorrenza ottimistica mediante `expected_row_version`.

Rimangono immutabili:

```text
id
profile_id
garden_id
bed_id
```

`start_method` e `start_date` possono essere modificati soltanto nelle fasi iniziali ammesse dal contratto.

Il lifecycle e `end_date` sono separati dall'aggiornamento ordinario e vengono gestiti mediante:

```text
set_planting_status
```

La cancellazione fisica ordinaria non fa parte del normale lifecycle.

La chiusura applicativa avviene mediante:

```text
finished
removed
```

Un eventuale hard delete rimane riservato a futuri strumenti amministrativi o a correzioni eccezionali.

---

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

Dalla Sessione S026 questa relazione non è più soltanto parte della baseline progettata, ma è implementata fisicamente nel Database V1 mediante:

```text
botanical_families
crops
crop_varieties
```

Le tre entità sono **Profile-owned** e condivise tra tutti i Gardens appartenenti allo stesso Profile.

Gli identificativi utilizzati dal nuovo Catalogo DB V1 sono UUID.

Il modello applica una separazione tra:

- valori generali e predefiniti della Crop;
- eventuali specializzazioni della Crop Variety.

La Crop contiene i valori di riferimento generali della coltura.

La Crop Variety contiene gli eventuali override varietali.

Per i campi che ammettono specializzazione viene applicato un fallback campo-per-campo dalla Variety verso la Crop.

Il fallback è previsto per:

```text
default_start_method
row_spacing_cm
plant_spacing_cm
sowing_depth_cm
germination_days
harvest_days
min_temperature
optimal_temperature
productivity
water_requirement
```

`rotation_seasons` rimane invece una proprietà esclusiva della Crop e non viene ridefinita dalla Variety.

Il valore canonico utilizzato per il metodo di avvio è:

```text
default_start_method
```

I valori ammessi nella V1 sono:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il precedente concetto testuale di famiglia botanica viene sostituito dalla relazione mediante:

```text
botanical_family_id
```

e il precedente concetto `Crop.variety` viene sostituito dall’entità autonoma:

```text
crop_varieties
```

La coerenza dei valori termici viene verificata anche dopo l’applicazione del fallback.

Ad esempio, se una Crop definisce:

```text
min_temperature = 10
optimal_temperature = 24
```

e una Variety definisce:

```text
min_temperature = 25
optimal_temperature = NULL
```

il risultato effettivo dopo fallback sarebbe:

```text
min_temperature = 25
optimal_temperature = 24
```

e deve pertanto essere rifiutato come `invalid_input`.

Il fabbisogno idrico qualitativo rimane rappresentato da:

```text
water_requirement
```

Per il fabbisogno idrico quantitativo vengono utilizzati:

```text
water_requirement_value
water_requirement_basis
water_interval_days
```

I valori ammessi per `water_requirement_basis` sono:

```text
per_plant
per_m2
```

Per una Crop Variety il blocco quantitativo dell’acqua segue una regola atomica:

- tutti i campi NULL → fallback completo dalla Crop;
- tutti i campi valorizzati → override completo della Variety;
- override parziale → non ammesso.

Non appartengono al contratto V1:

```text
water_requirement_period
per_week
per_irrigation
```

Il fabbisogno idrico contenuto nel catalogo rappresenta un riferimento agronomico di base.

Condizioni quali pioggia, temperatura, siccità, umidità del suolo e altri fattori ambientali potranno influenzare in futuro il calcolo operativo dell’irrigazione senza modificare retroattivamente il valore base del catalogo.

La resa prevista utilizza:

```text
expected_yield_min
expected_yield_avg
expected_yield_max
expected_yield_unit
yield_source_name
yield_source_url
yield_source_year
yield_notes
```

Le unità canoniche ammesse sono:

```text
kg_per_m2
kg_per_plant
g_per_m2
g_per_plant
pieces_per_m2
pieces_per_plant
```

Le regole principali prevedono che:

- `expected_yield_min`, `expected_yield_avg` ed `expected_yield_max` siano maggiori o uguali a zero;
- i valori min/avg/max siano reciprocamente coerenti;
- se almeno un valore di resa è valorizzato, `expected_yield_unit` sia obbligatoria;
- se nessun valore di resa è valorizzato, unità e informazioni di fonte siano NULL;
- la fonte sia opzionale e possa essere anche parziale quando esiste almeno una resa;
- `yield_source_year` sia maggiore o uguale a `1800`.

Per le Crop Variety il blocco resa non utilizza fallback campo-per-campo.

La regola è:

- nessuna resa varietale → eredita l’intero blocco resa dalla Crop;
- almeno una resa varietale → utilizza un blocco resa autonomo della Variety.

Le regole agronomiche seguono inoltre il principio:

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

Il Catalogo DB V1 segue infine il principio:

**catalogo corrente + snapshot storico**

Le modifiche future ai valori correnti del catalogo non devono modificare retroattivamente decisioni, calcoli o risultati storici che abbiano già utilizzato quei valori.

Lo stesso principio dovrà essere mantenuto, quando applicabile, anche per dati agronomici futuri utilizzati nelle decisioni operative.

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

## 5.4 Pianificazione e realt�

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

Gli eventi e le registrazioni reali rappresentano fatti storici.

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

Dalla Sessione S028 `plantings` costituisce anche un esempio concreto di questa regola.

Una coltivazione conserva infatti:

```text
start_date
```

come data di inizio della reale occupazione fisica dell'aiuola e:

```text
end_date
```

come eventuale data di chiusura dell'occupazione negli stati terminali.

Il lifecycle persistente utilizza:

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

rappresenta un fatto reale già avvenuto ma non implica che la coltivazione abbia cessato di occupare fisicamente l'aiuola.

Solo:

```text
finished
removed
```

chiudono l'occupazione temporale e richiedono `end_date`.

Le eventuali correzioni dei fatti storici devono rispettare la semantica UPDATE / VOID / DELETE definita per il Database V1 e le invarianti della specifica entità.

Per `plantings` il normale lifecycle applicativo non utilizza hard delete: la chiusura ordinaria avviene mediante gli stati `finished` o `removed`.

## 6.4 Pianificazione e storia reale

I dati pianificati devono essere conservati separatamente dai dati reali.

Il principio fondamentale è:

```text
pianificazione
        �
realt�
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

Il modello autoritativo di `plantings` introdotto nella Sessione S028 utilizza:

```text
start_date
end_date
```

come date civili.

`start_date` rappresenta il giorno nel quale inizia la reale occupazione fisica dell'aiuola e:

- non può essere futuro;
- partecipa al controllo della geometria valida nel tempo;
- costituisce l'estremo iniziale dell'occupazione temporale.

`end_date`:

- rimane `NULL` negli stati che continuano a occupare l'aiuola;
- è obbligatorio per `finished`;
- è obbligatorio per `removed`;
- deve rispettare `end_date >= start_date`;
- non può essere futuro.

La semantica temporale deve rimanere coerente con la natura civile delle due date e non deve introdurre timestamp artificiali quando il dominio richiede soltanto il giorno.

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
        �
zero
        �
false
        �
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
        �
0
        �
false
        �
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
        �
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
        �
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

Il comportamento fail-closed costituisce parte dello stesso principio: una risposta RPC sconosciuta, incompleta o non interpretabile in modo sicuro non deve essere considerata equivalente a una scrittura riuscita.

## 9.2 Row Level Security

PostgreSQL Row Level Security costituisce una delle principali barriere di autorizzazione del Database V1.

Con la Sessione S019 questo principio è stato applicato concretamente al primo gruppo implementato della baseline, costituito dalle Fondazioni.

La prima matrice RLS protegge le sei tabelle:

```text
profiles
profile_memberships
gardens
workers
seasons
profile_edit_locks
```

Sulle strutture interessate sono state definite e verificate complessivamente:

> **13 policy RLS**

Le policy implementate utilizzano l'identità autenticata e le relazioni persistenti per determinare gli accessi consentiti.

Il modello di autorizzazione continua a seguire concettualmente la catena:

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

La prima matrice RLS è stata collaudata mediante test manuali sia positivi sia negativi, verificando in particolare:

- isolamento tra Profile differenti;
- distinzione tra owner e worker;
- comportamento con membership disabilitata;
- accesso autorizzato e non autorizzato ai `gardens`;
- protezione delle `profile_memberships`;
- protezione di `profile_edit_locks`;
- accesso alle `seasons`;
- accesso ai `workers`;
- rifiuto di operazioni di scrittura o eliminazione non autorizzate.

Il criterio di collaudo adottato è:

```text
operazione autorizzata
        ↓
deve riuscire

operazione non autorizzata
        ↓
deve fallire
```

Il superamento dei soli casi positivi non è quindi sufficiente per considerare verificata una policy di sicurezza.

Le **13 policy RLS** implementate nella S019 costituiscono la prima matrice di sicurezza del Database V1 e non rappresentano la protezione definitiva dell'intera baseline.

Le tabelle introdotte successivamente devono essere protette e collaudate progressivamente secondo lo stesso principio deny-by-default.

Nella Sessione S026 questo criterio è stato applicato anche al Catalogo DB V1.

Per:

```text
botanical_families
crops
crop_varieties
```

il ruolo `authenticated` dispone della lettura regolata da RLS ma non dei privilegi diretti di:

```text
INSERT
UPDATE
DELETE
```

La lettura del catalogo verifica l'appartenenza al Profile mediante:

```text
private.is_profile_member(profile_id)
```

I test runtime della S026 hanno verificato che:

- un membro del Profile possa leggere il relativo catalogo;
- un utente autenticato non membro del Profile non possa leggerlo.

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

L'identità autenticata viene determinata server-side tramite i meccanismi messi a disposizione da Supabase/PostgreSQL, tra cui `auth.uid()` quando previsto dal contratto della funzione.

Gli identificativi e gli attributi trasmessi dal client devono essere considerati dati di input e non prove di autorizzazione.

## 9.4 Flutter come client non fidato

L'applicazione Flutter deve essere progettata assumendo che le richieste provenienti dal client possano essere manipolate.

Pertanto non devono essere considerate garanzie di sicurezza:

- validazioni eseguite esclusivamente nell'interfaccia;
- valori di ownership forniti dal client;
- stato locale dell'applicazione;
- controlli di visibilità dei componenti UI;
- sequenze operative che il client potrebbe aggirare;
- presenza locale di un token o di uno stato che non sia stato rivalidato server-side.

Le validazioni client-side rimangono utili per l'esperienza utente e per prevenire richieste manifestamente errate, ma le invarianti di sicurezza devono essere verificate nuovamente dal backend o dal database.

Il controllo Flutter costituisce quindi un **preflight preventivo** e non sostituisce mai l'autorità server-side.

Il client non deve inoltre eseguire retry automatici quando l'esito effettivo di una scrittura non è confermabile, perché una ritrasmissione potrebbe duplicare o alterare un'operazione già eseguita.

## 9.5 Invarianti protette dal database

Le condizioni che devono essere vere indipendentemente dal client devono essere protette mediante gli strumenti appropriati del database.

A seconda del caso possono essere utilizzati:

- `NOT NULL`;
- foreign key;
- `UNIQUE`;
- `CHECK`;
- exclusion constraint;
- RLS;
- funzioni server-side;
- transazioni;
- row lock;
- altri vincoli PostgreSQL appropriati.

La logica decisionale agronomica non deve essere trasferita indiscriminatamente nel database, ma le invarianti necessarie a impedire stati persistenti impossibili, incoerenti o non autorizzati devono essere protette lato server.

La Sessione S026 ha applicato concretamente questo principio al Catalogo DB V1, introducendo validazioni server-side relative, tra l'altro, a:

- unicità case-insensitive;
- gerarchia Botanical Family → Crop → Crop Variety;
- stato attivo dei parent;
- valori ammessi per `default_start_method`;
- coerenza delle temperature;
- blocco quantitativo del fabbisogno idrico;
- blocco della resa;
- anno della fonte;
- immutabilità di `crop_varieties.crop_id`.

## 9.6 Operazioni atomiche e transazioni

Le operazioni che modificano più strutture e che devono essere considerate una singola unità logica devono essere eseguite atomicamente.

Il principio è:

```text
tutta l'operazione riesce
        oppure
nessuna modifica viene consolidata
```

Quando una operazione critica richiede più verifiche e modifiche coordinate, deve essere utilizzata una transazione o una funzione server-side appropriata.

Questo evita stati intermedi incoerenti prodotti da richieste separate del client.

Le operazioni autoritative introdotte nelle Sessioni S022–S026 centralizzano progressivamente:

```text
autorizzazione
        +
validazione
        +
concorrenza
        +
invarianti
        +
scrittura
```

nello stesso perimetro server-side.

## 9.7 Sicurezza del modello single-writer

Il modello single-writer per Profile non deve essere affidato esclusivamente allo stato locale dell'applicazione.

La struttura tecnica:

```text
profile_edit_locks
```

è stata fisicamente introdotta nella prima migration Database V1 della Sessione S019 e rimane separata dalle 52 entità di dominio.

La tabella costituisce la base persistente per il coordinamento del writer e la relativa protezione RLS è stata verificata durante i test manuali della prima matrice di sicurezza.

Il lock non attribuisce automaticamente autorizzazioni aggiuntive e non sostituisce:

- autenticazione;
- ownership;
- membership valida;
- Row Level Security;
- invarianti;
- controlli server-side.

La gestione del lock supporta:

- acquisizione;
- verifica del writer corrente;
- heartbeat e rinnovo;
- scadenza;
- rilascio;
- richiesta e gestione del takeover;
- concorrenza tra client;
- controllo dello stato e delle transizioni autorizzate.

Con la Sessione S020 è stata implementata e testata una prima parte delle operazioni server-side del protocollo:

- `acquire_profile_edit_lock`;
- `heartbeat_profile_edit_lock`;
- `release_profile_edit_lock`;
- `request_profile_edit_takeover`;
- `cancel_profile_edit_takeover`.

La Sessione S021 ha successivamente completato e rafforzato il protocollo con:

- `reject_profile_edit_takeover`;
- `grant_profile_edit_takeover`;
- `complete_profile_edit_takeover`;
- `get_profile_edit_lock_state`.

L'acquisizione del lock è riservata all'`owner` del Profile.

I ruoli `worker` e `viewer` non possono acquisirlo.

`client_id` e `session_id` identificano il contesto tecnico della richiesta, ma non costituiscono autenticazione e non possono sostituire l'identità determinata server-side.

Il `lock_token` viene generato esclusivamente lato server mediante materiale casuale di 32 byte.

Nel database viene conservato solamente il relativo hash SHA-256; il token in chiaro non deve essere persistito in log, UI, URL o storage persistente.

Il protocollo utilizza:

- heartbeat ogni **30 secondi**;
- lease del lock pari a **2 minuti**;
- validità della richiesta di takeover pari a **10 minuti**;
- validità del grant di takeover pari a **60 secondi**;
- silenziamento delle nuove richieste di takeover pari a **5, 15 o 30 minuti**.

L'orologio PostgreSQL costituisce l'autorità temporale del protocollo.

Un lock scaduto non può essere resuscitato mediante heartbeat.

Le operazioni concorrenti sulle righe di lock esistenti utilizzano `FOR UPDATE`; la prima acquisizione o il riciclo di un lock scaduto utilizza `INSERT ... ON CONFLICT`.

Le operazioni che dipendono dal possesso del lock devono verificare server-side che il writer sia effettivamente autorizzato e che lo stato del lock sia valido nel momento della modifica.

Il client non può modificare direttamente `profile_edit_locks` per attribuirsi arbitrariamente il ruolo di writer.

Il single-writer costituisce quindi un meccanismo di coordinamento e non sostituisce RLS o le normali verifiche di ownership e autorizzazione.

## 9.8 Protezione delle operazioni sensibili e Write Path autoritativi

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

La Sessione S019 ha confermato che alcune operazioni delle Fondazioni richiedono una protezione ulteriore rispetto al semplice accesso diretto alle tabelle mediante RLS.

La Sessione S020 ha avviato l'implementazione concreta delle RPC sicure e atomiche relative a `profile_edit_locks`.

La Sessione S021 ha completato il protocollo e ne ha effettuato l'hardening mediante un audit incrociato delle transizioni concorrenti.

Le RPC del protocollo applicano i seguenti criteri:

- identità ricavata server-side;
- nessuna fiducia nei dati di autorizzazione forniti dal client;
- privilegio minimo;
- utilizzo di `SECURITY DEFINER`;
- `search_path = ''`;
- `PUBLIC EXECUTE` revocato;
- `EXECUTE` concesso esclusivamente ai ruoli previsti dal contratto;
- operazioni atomiche quando richiesto;
- test positivi e negativi;
- verifica dei principali tentativi di bypass.

L'hardening della Sessione S021 ha inoltre verificato:

- serializzazione delle operazioni concorrenti mediante `FOR UPDATE`;
- rivalidazione di holder, client, sessione, token e lease dopo l'eventuale attesa sul row lock;
- utilizzo di `clock_timestamp()` nei punti temporali autoritativi interessati;
- impossibilità di resuscitare un lease scaduto mediante heartbeat;
- conservazione del lock durante un grant di takeover ancora valido;
- protezione del lease durante l'handoff di takeover;
- precedenza del grant valido nello stato restituito da `get_profile_edit_lock_state`;
- trasferimento atomico mediante `complete_profile_edit_takeover`;
- generazione di un nuovo token al completamento del takeover.

Il protocollo `profile_edit_locks` è considerato architetturalmente coerente allo stato attuale.

### Write Path di `gardens`

Il completamento del protocollo `profile_edit_locks` ha consentito nella Sessione S022 l'introduzione del primo Write Path autoritativo di Categoria A, applicato a `gardens`.

Sono disponibili:

```text
create_garden
update_garden
```

Il Write Path verifica server-side:

- identità autenticata;
- ownership attiva del Profile;
- Profile Write Authority;
- client;
- sessione;
- token;
- lease;
- stato del takeover.

Le RPC centralizzano validazione e scrittura atomica.

I privilegi diretti `INSERT`, `UPDATE` e `DELETE` su `public.gardens` sono revocati ad `authenticated`.

Nella Sessione S023 `update_garden` è stata rafforzata rendendo obbligatorio `expected_row_version`.

La versione viene verificata sia sullo stato letto sia nella condizione della scrittura finale.

Se la riga non corrisponde più alla versione attesa, la RPC restituisce:

```text
version_conflict
```

e non applica l'aggiornamento.

### Write Path di `seasons`

La Sessione S023 ha introdotto il Write Path autoritativo di `seasons` mediante:

```text
create_season
update_season
activate_season
```

I privilegi diretti `INSERT`, `UPDATE` e `DELETE` su `public.seasons` sono revocati ad `authenticated`, mentre `SELECT` rimane regolato dalle autorizzazioni previste.

`create_season` crea la stagione inizialmente inattiva e impedisce la duplicazione dell'anno nello stesso Garden.

`update_season` modifica esclusivamente i dati descrittivi e temporali, mantiene immutabile `garden_id` e non modifica `is_active`.

`activate_season` costituisce l'unica operazione applicativa autorizzata a cambiare lo stato attivo.

La RPC attiva la stagione target e disattiva atomicamente l'eventuale stagione precedentemente attiva nello stesso Garden.

`update_season` e `activate_season` richiedono `expected_row_version` e restituiscono `version_conflict` quando lo stato corrente non coincide più con quello atteso.

### Write Path di `beds`

La Sessione S024 ha introdotto il Write Path autoritativo di `beds` mediante:

```text
create_bed
update_bed
set_bed_active
change_bed_geometry
correct_bed_geometry
```

L'identità stabile dell'aiuola è mantenuta in `beds`.

La geometria valida nel tempo viene conservata in `bed_geometries`.

Le variazioni geometriche ordinarie e le correzioni storiche restano operazioni semanticamente distinte.

Le correzioni storiche vengono registrate separatamente in `bed_geometry_corrections`.

La concorrenza ottimistica utilizza le versioni attese previste dal contratto delle singole RPC.

Le scritture dirette sulle tabelle protette rimangono revocate.

La Sessione S025 ha completato l'integrazione Flutter dei cinque Write Path, mantenendo il controllo server-side come autorità definitiva.

### Write Path del Catalogo DB V1

La Sessione S026 ha introdotto il Write Path autoritativo del Catalogo DB V1 per:

```text
botanical_families
crops
crop_varieties
```

Il catalogo è Profile-owned e condiviso tra i Gardens dello stesso Profile.

Le nove RPC autoritative sono:

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

Le scritture applicative sulle tre tabelle sono consentite esclusivamente attraverso le RPC previste.

Le scritture dirette:

```text
INSERT
UPDATE
DELETE
```

sono revocate ad `authenticated`.

Le RPC sono definite con:

```text
SECURITY DEFINER
```

e:

```text
search_path = ''
```

Il privilegio `EXECUTE` è concesso ad `authenticated` e revocato ad `anon` e `public`.

Le scritture autoritative seguono il flusso:

```text
Supabase Auth
        ↓
autorizzazione server-side
        ↓
Profile Write Authority
        ↓
RPC autoritativa
        ↓
FOR UPDATE / row_version
        ↓
scrittura
```

Il lease della Profile Write Authority viene rivalidato dopo eventuali attese sui row lock.

La concorrenza ottimistica utilizza:

```text
expected_row_version
```

e:

```text
row_version
```

quando previsto dall'operazione.

I parent vengono lockati quando necessario per serializzare correttamente operazioni concorrenti quali:

- creazione di un figlio;
- riattivazione di un figlio;
- disattivazione di un parent;
- cambio della Botanical Family di una Crop.

Le principali regole gerarchiche protette server-side sono:

- una Botanical Family non può essere disattivata se contiene Crop attive;
- una Crop non può essere disattivata se contiene Crop Variety attive;
- una Crop può essere creata soltanto sotto una Botanical Family attiva;
- una Crop può essere spostata soltanto verso una Botanical Family attiva dello stesso Profile;
- una Crop può essere riattivata soltanto se la Botanical Family padre è attiva;
- una Crop Variety può essere creata soltanto sotto una Crop attiva;
- una Crop Variety può essere riattivata soltanto se la Crop padre è attiva;
- riattivare un parent non riattiva automaticamente i figli;
- i record inattivi rimangono modificabili;
- `crop_varieties.crop_id` è immutabile dopo la creazione.

La Sessione S026 ha verificato mediante test SQL positivi e negativi:

- Profile Write Authority;
- owner/non-owner;
- normalizzazione degli input;
- unicità case-insensitive;
- stato attivo e riattivazione;
- gerarchie padre/figlio;
- concorrenza ottimistica;
- `unchanged`;
- `version_conflict`;
- fallback Crop → Variety;
- coerenza delle temperature dopo fallback;
- blocco quantitativo dell'acqua;
- blocco della resa;
- RLS;
- privilegi di esecuzione delle RPC.

I test sono stati eseguiti con dati fittizi all'interno di transazioni:

```text
BEGIN
...
ROLLBACK
```

senza lasciare dati persistenti.

I Write Path di `gardens`, `seasons`, `beds` e del Catalogo DB V1 sono considerati completati e coerenti allo stato attuale.

Le operazioni amministrative protette su `profile_memberships`, `plantings` e le ulteriori entità della baseline rimangono incrementi successivi.

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

La Sessione S019 ha applicato concretamente questo principio alla prima migration della baseline.

Il primo incremento è stato verificato mediante:

- ricostruzione completa locale con `supabase db reset`;
- controllo delle sei tabelle Fondazioni;
- verifica dello schema `private`;
- verifica degli helper autorizzativi;
- verifica dei trigger metadata;
- verifica dell'attivazione della Row Level Security;
- verifica di **13 policy RLS**;
- test manuali positivi;
- test manuali negativi;
- controllo dei tentativi di accesso e modifica non autorizzati.

Le Sessioni successive hanno mantenuto lo stesso principio estendendolo progressivamente ai Write Path autoritativi.

Nella Sessione S026 sono state verificate anche:

```text
supabase db lint --local
```

che non ha rilevato nuovi problemi introdotti dalla sessione, e:

```text
supabase db diff --local
```

che ha restituito:

```text
No schema changes found
```

Le due migration S026 sono state applicate anche al database Supabase remoto.

La verifica mediante:

```text
supabase migration list
```

ha confermato l'allineamento locale/remoto fino a:

```text
20260911091047
```

Il principio operativo consolidato rimane:

```text
migration
        ↓
ricostruzione / applicazione controllata
        ↓
verifica struttura
        ↓
verifica autorizzazioni
        ↓
test positivi
        ↓
test negativi
        ↓
incremento verificato
```

Ogni successivo gruppo di migration deve essere verificato anche dal punto di vista della sicurezza prima di essere considerato completato.

Il Database V1 non sarà quindi considerato implementato soltanto perché le 52 entità esistono fisicamente: dovranno essere operative e collaudate anche le protezioni previste dalla baseline.

Le RPC sicure e atomiche costituiscono parte integrante del modello di protezione delle operazioni sensibili e devono essere verificate con lo stesso metodo prima di essere considerate consolidate.

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

Gli intervalli di validità delle configurazioni che utilizzano:

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

Dalla Sessione S028 il principio half-open viene applicato anche alla semantica di occupazione delle coltivazioni.

Per la dimensione longitudinale:

```text
[start_position_cm, start_position_cm + length_cm)
```

rappresenta lo spazio occupato da una `planting`.

Due intervalli possono quindi toccarsi esattamente sul confine senza sovrapporsi.

Lo stesso principio viene applicato concettualmente all'occupazione temporale, così da distinguere in modo deterministico periodi contigui da periodi realmente sovrapposti.

Per `plantings`:

```text
start_date
```

apre l'occupazione temporale.

`end_date` la chiude soltanto negli stati terminali:

```text
finished
removed
```

Una coltivazione con stato:

```text
harvested
```

continua quindi a occupare l'aiuola.

## 10.4 Sovrapposizioni temporali

Quando il dominio stabilisce che per una determinata entità o relazione possa esistere una sola configurazione valida nello stesso momento, gli intervalli temporali incompatibili non devono sovrapporsi.

Il principio generale è:

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

Per `plantings` la Sessione S028 ha introdotto una regola più specifica.

Due coltivazioni risultano incompatibili soltanto quando coincidono entrambe:

1. una sovrapposizione temporale;
2. una sovrapposizione longitudinale nella stessa aiuola.

La sola sovrapposizione temporale non è quindi sufficiente se le coltivazioni occupano porzioni longitudinali differenti dell'aiuola.

Analogamente, la sola sovrapposizione spaziale non costituisce conflitto se i relativi periodi di occupazione non si sovrappongono.

Il controllo deve inoltre considerare la geometria dell'aiuola valida durante l'intero intervallo temporale interessato dalla coltivazione.

La protezione opera anche nel verso opposto:

```text
planting esistente
        +
nuova geometria bed
        ↓
verifica compatibilità
```

Una variazione o correzione geometrica che renderebbe incompatibile una coltivazione esistente deve essere rifiutata.

Le RPC:

```text
change_bed_geometry
correct_bed_geometry
```

possono in tale situazione restituire:

```text
blocked_by_plantings
```

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
        �
plantings

tasks
        �
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
        �
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

La baseline Database V1 definita nella Sessione S017 costituisce il riferimento logico e architetturale per l'implementazione PostgreSQL/Supabase.

La sua approvazione non comporta una trasformazione immediata e monolitica del database operativo esistente.

L'implementazione deve procedere in modo incrementale, verificabile e reversibile per quanto ragionevolmente possibile, mantenendo il progetto in uno stato controllabile durante la progressiva traduzione della baseline in strutture fisiche, sicurezza, Write Path autoritativi e integrazione applicativa.

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

Le strutture tecniche introdotte successivamente per sicurezza, autorizzazione o tracciamento devono essere documentate distinguendole dalle 52 entità di dominio congelate.

## 11.2 Stato attuale e stato obiettivo

Durante l'implementazione devono essere mantenuti distinti:

```text
database effettivamente implementato
```

e:

```text
Database V1 progettato
```

Il primo rappresenta ciò che Supabase contiene realmente e che l'applicazione può utilizzare in un determinato momento.

Il secondo rappresenta la baseline obiettivo approvata.

La documentazione e le verifiche non devono dichiarare come implementata una struttura che esiste soltanto nella baseline progettuale.

Alla conclusione della Sessione S028 il Database V1 rimane parzialmente implementato, ma comprende ormai anche il dominio autoritativo delle coltivazioni reali.

Sono disponibili, tra le altre strutture:

```text
Fondazioni
gardens
seasons
beds
bed_geometries
bed_geometry_corrections
botanical_families
crops
crop_varieties
plantings
```

`public.plantings` è quindi presente nello schema implementato e dispone del relativo Write Path autoritativo.

Restano invece ancora da implementare ulteriori entità appartenenti alla baseline congelata delle 52 entità.

La distinzione tra stato implementato e stato obiettivo deve continuare a essere mantenuta esplicita durante ogni incremento successivo.

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

La Sessione S019 ha applicato per la prima volta concretamente questo metodo mediante:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

Il primo incremento implementato è costituito dal gruppo **Fondazioni**, comprendente:

- `profiles`;
- `profile_memberships`;
- `gardens`;
- `seasons`;
- `workers`;
- `profile_edit_locks`.

L'incremento è stato accompagnato dalla creazione dello schema `private`, dagli helper autorizzativi necessari, dai trigger metadata e dalla prima matrice di **13 policy RLS**.

Le sessioni successive hanno continuato secondo lo stesso criterio:

- S020 e S021 hanno completato e rafforzato il protocollo server-side `profile_edit_locks`;
- S022 ha introdotto la Profile Write Authority e il primo Write Path autoritativo per `gardens`;
- S023 ha rafforzato `update_garden` e introdotto il Write Path autoritativo di `seasons`;
- S024 ha implementato `beds`, `bed_geometries`, `bed_geometry_corrections` e il relativo Write Path;
- S025 ha completato l'integrazione Flutter dei Write Path di `beds`;
- S026 ha implementato il Catalogo DB V1 e i relativi nove Write Path autoritativi;
- S027 ha completato l'integrazione Flutter del Catalogo V1;
- S028 ha implementato il modello autoritativo di `plantings`, il relativo Write Path, il lifecycle server-side e l'integrazione Flutter necessaria alla creazione e modifica delle coltivazioni.

La sequenza delle migration implementate comprende:

```text
20260817103916_database_v1_baseline.sql
20260818154920_harden_profile_edit_locks.sql
20260818162315_add_takeover_grant_state.sql
20260819215412_add_secure_profile_edit_lock_rpcs.sql
20260823111048_add_profile_write_authority.sql
20260823145731_harden_gardens_write_path.sql
20260824145346_add_update_garden_rpc.sql
20260825173801_harden_update_garden_row_version.sql
20260826063859_harden_seasons_write_path.sql
20260830091156_add_beds_and_geometry_history.sql
20260830095426_add_beds_write_rpcs.sql
20260830101354_add_update_bed_rpc.sql
20260830103544_add_set_bed_active_rpc.sql
20260830133429_add_change_bed_geometry_rpc.sql
20260830140235_add_correct_bed_geometry_rpc.sql
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Il Catalogo DB V1 dispone delle RPC:

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

Il dominio `plantings` dispone delle RPC:

```text
create_planting
update_planting
set_planting_status
```

La Sessione S028 ha inoltre rafforzato:

```text
change_bed_geometry
correct_bed_geometry
```

rispetto alla compatibilità con coltivazioni esistenti.

`crop_associations`, `agronomic_window_rules` e le ulteriori entità non ancora implementate rimangono incrementi successivi.

Anche le operazioni amministrative protette su `profile_memberships` costituiscono un blocco distinto ancora da completare.

L'implementazione deve continuare a procedere per blocchi coerenti, senza trasformare la baseline completa in una migration monolitica.

## 11.4 Ordine delle dipendenze

Le migration devono rispettare le dipendenze tra le entità.

In linea generale devono essere introdotte prima le strutture dalle quali dipendono le successive.

Un ordine logico di alto livello della baseline è:

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

Questo schema rappresenta un criterio architetturale e non una sequenza SQL rigida.

L'ordine SQL concreto deve essere definito analizzando:

- foreign key;
- vincoli;
- helper autorizzativi;
- funzioni;
- policy RLS;
- dipendenze applicative;
- invarianti da proteggere.

La Sessione S019 ha applicato concretamente questo criterio introducendo per primo il gruppo **Fondazioni**, necessario per stabilire identità, ownership, membership, contesto Garden e coordinamento single-writer.

L'ordine adottato nel primo incremento è stato:

```text
profiles
        ↓
profile_memberships
        ↓
gardens
        ↓
seasons / workers
        ↓
profile_edit_locks
```

La Sessione S026 ha confermato nuovamente il principio delle dipendenze.

L'obiettivo iniziale era analizzare e preparare il futuro Write Path di `plantings`.

Durante l'analisi è emerso che `plantings` dipende da un catalogo agronomico operativo non ancora disponibile nel Database V1 implementato.

È stato quindi approvato il percorso:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
        ↓
plantings
```

La S026 ha completato i primi tre livelli lato PostgreSQL/Supabase.

La Sessione S027 ha successivamente completato l'integrazione Flutter dei medesimi livelli mediante:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

e i relativi Repository.

Alla conclusione della S027 la sequenza risulta quindi:

```text
Catalogo DB V1
        ✓
Write Path Catalogo V1
        ✓
integrazione Flutter Catalogo V1
        ✓
plantings
        ✗
```

`plantings` rimane un incremento successivo.

La UI amministrativa del Catalogo V1 costituisce invece un blocco applicativo distinto e non modifica l'ordine delle dipendenze persistenti.

Per gli incrementi successivi l'ordine SQL dovrà continuare a essere determinato dalle dipendenze effettive tra foreign key, vincoli, helper autorizzativi, policy RLS e funzioni server-side.

## 11.5 Schema e sicurezza insieme

La creazione di una tabella non è considerata completa se la relativa sicurezza prevista dal contratto non è stata affrontata.

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
privilegi
+
test
```

Non deve essere rimandata sistematicamente a una fase finale l'introduzione della sicurezza.

Una tabella esposta senza le protezioni richieste non rappresenta una implementazione completa del Database V1.

La Sessione S019 ha applicato concretamente questo criterio alle Fondazioni mediante:

- schema `private`;
- helper autorizzativi;
- trigger metadata;
- attivazione della Row Level Security;
- definizione di **13 policy RLS**;
- test manuali positivi;
- test manuali negativi;
- verifica dei tentativi di accesso, modifica ed eliminazione non autorizzati.

La Sessione S026 ha applicato lo stesso principio alle tre tabelle del Catalogo DB V1.

Per:

```text
botanical_families
crops
crop_varieties
```

sono stati introdotti e verificati:

- vincoli;
- indici;
- trigger metadata;
- RLS;
- privilegi;
- RPC autoritative;
- concorrenza ottimistica;
- validazioni server-side;
- test positivi e negativi.

Il ruolo `authenticated` dispone della lettura regolata da RLS ma non dei privilegi diretti di:

```text
INSERT
UPDATE
DELETE
```

Le scritture applicative avvengono esclusivamente tramite le RPC autorizzate.

Il metodo consolidato è quindi:

```text
struttura persistente
        +
ownership
        +
sicurezza
        +
Write Path autoritativo quando necessario
        +
test positivi
        +
test negativi
        =
incremento verificato
```

## 11.6 Migrazione dei dati esistenti

Quando una nuova struttura sostituisce o specializza dati già presenti nel database operativo o nel codice legacy, deve essere definita esplicitamente la strategia di migrazione.

Prima di modificare o rimuovere una struttura esistente devono essere verificati:

- dati realmente presenti;
- utilizzo da parte del codice Flutter;
- Repository interessati;
- foreign key esistenti;
- policy RLS esistenti;
- compatibilità con il nuovo contratto;
- possibilità di trasformare i dati senza perdita informativa.

La migrazione deve privilegiare la conservazione dei dati validi già presenti.

Non devono essere cancellati dati esistenti soltanto per semplificare l'adozione della nuova struttura.

La Sessione S026 ha mantenuto separato il nuovo Catalogo DB V1 dai componenti Flutter legacy.

La Sessione S027 ha eseguito il primo riallineamento applicativo esplicito tra il contratto legacy e il Catalogo V1.

In particolare:

- `BotanicalFamily` è stato introdotto come modello dedicato;
- `Crop` è stato riallineato al contratto V1;
- `CropVariety` è stato riallineato al contratto V1;
- gli identificativi del catalogo sono rappresentati come UUID `String`;
- `CropVariety.toMap()` è stato rimosso;
- i Repository utilizzano letture RLS e scritture RPC-only.

La migrazione applicativa non è tuttavia ancora completa.

Sono stati mantenuti temporaneamente alcuni alias legacy:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

per non interrompere flussi applicativi ancora dipendenti dalle rappresentazioni precedenti.

Questi alias:

- non costituiscono il nuovo contratto persistente;
- non devono essere utilizzati per introdurre nuove dipendenze;
- devono essere rimossi soltanto dopo la migrazione esplicita dei rispettivi consumer.

Rimangono in particolare da migrare o riallineare completamente:

- `AddPlantingPage`;
- alcuni utilizzi del motore di rotazione;
- i relativi widget e test;
- la relazione tra `defaultStartMethod` V1 e i planting method legacy.

La migrazione dal modello legacy al contratto V1 deve quindi continuare in modo esplicito, incrementale e verificato, senza assumere equivalenza automatica tra le due rappresentazioni.

## 11.7 Compatibilità con il codice applicativo

Le migration e il codice Flutter devono evolvere in modo coordinato.

Quando cambia la struttura persistente devono essere verificati almeno:

```text
modelli
repository
mapping
result type
servizi
motori che consumano i dati
UI
test
```

Non deve essere introdotta una dipendenza del codice applicativo da una struttura che non è ancora disponibile nel database utilizzato.

Allo stesso modo, l'esistenza di una nuova struttura nel database non implica automaticamente che il client Flutter la utilizzi già.

La sequenza S026–S027 costituisce un esempio concreto di questo principio.

Dopo la S026:

```text
Catalogo DB V1
        =
implementato nel database

Catalogo Flutter V1
        =
non ancora integrato
```

La S027 ha completato il relativo passaggio applicativo.

La Sessione S028 ha applicato lo stesso principio al dominio delle coltivazioni.

Alla conclusione della S028:

```text
public.plantings
        =
implementata

Write Path plantings
        =
implementato

PlantingRepository
        =
riallineato

AddPlantingPage
        =
riallineata al contratto S028
```

L'integrazione comprende:

- modello `Planting` riallineato al contratto Database V1;
- `PlantingRepository`;
- result type dedicati alle scritture;
- Profile Write Authority fail-closed;
- `create_planting`;
- `update_planting`;
- `set_planting_status`;
- gestione di `row_version`;
- validazioni metodo-dipendenti;
- controlli geometrici;
- controlli temporali;
- gestione degli overlap;
- adeguamento dei componenti che utilizzano lo spazio dell'aiuola;
- test dedicati.

La verifica finale della S028 ha confermato:

```text
flutter analyze
No issues found!
```

```text
flutter test
997 tests passed
```

Sono inoltre risultati positivi:

```text
supabase db reset
success
```

e:

```text
supabase db lint --local
No schema errors found
```

La compatibilità con il codice applicativo precedente continua a non essere ottenuta mediante conversioni implicite.

Gli alias legacy ancora presenti devono rimanere esplicitamente temporanei e non devono essere utilizzati per introdurre nuove dipendenze.

Alla conclusione della S028 rimangono distinti:

```text
integrazione dati Catalogo V1
        ✓

Write Path plantings
        ✓

creazione/modifica plantings lato UI
        ✓

UI amministrativa Catalogo V1
        ✗

UI completa lifecycle plantings
        ✗

selezione varietà nel flusso plantings
        ✗
```

La futura evoluzione deve eliminare progressivamente le dipendenze legacy residue senza alterare retroattivamente il contratto persistente consolidato.

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

Il Repository deve inoltre costituire il confine applicativo verso le RPC autoritative quando una entità non consente scritture dirette.

Per il Catalogo DB V1 il modello consolidato è:

```text
lettura
        ↓
RLS
        ↓
Repository
        ↓
dominio Dart
```

e:

```text
scrittura
        ↓
Repository
        ↓
Profile Write Authority
        ↓
RPC autoritativa
        ↓
PostgreSQL
```

I Repository del catalogo sono:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

Dalla Sessione S028 lo stesso modello viene applicato anche a:

```text
PlantingRepository
```

Le letture di `plantings` avvengono attraverso il Repository sotto protezione RLS.

Le scritture ordinarie passano attraverso:

```text
create_planting
update_planting
set_planting_status
```

e non devono introdurre percorsi diretti alternativi.

Nei Repository RPC-only non devono essere introdotte scritture mediante:

```text
.insert()
.update()
.delete()
.upsert()
```

quando il contratto dell'entità prevede esclusivamente il Write Path autoritativo.

Le invarianti autoritative rimangono responsabilità del database.

Le eventuali validazioni Flutter servono a migliorare l'esperienza utente ma non sostituiscono i controlli server-side.

Il mapping delle risposte RPC deve rimanere:

- esplicito;
- tipizzato;
- fail-closed;
- coerente con gli status effettivamente restituiti dal server.

La futura integrazione di:

```text
agronomic_window_rules
```

dovrà continuare a preservare la separazione tra persistenza e logica decisionale già consolidata negli engine Dart:

```text
CropAgronomicWindowRule
AgronomicWindowResolver
AgronomicWindowEngine
AgronomicWindowService
```

La struttura persistente deve alimentare il dominio senza trasferire indiscriminatamente nel database la logica decisionale degli engine applicativi.

## 11.9 Migration tracciabili

Ogni modifica strutturale al database deve essere rappresentata da migration versionate e conservate nel repository.

Non devono essere considerate sufficienti modifiche manuali eseguite esclusivamente dalla Dashboard Supabase senza una corrispondente rappresentazione riproducibile nel progetto.

Il principio è:

```text
modifica database
        ↓
migration tracciata
        ↓
repository Git
```

In questo modo lo stato del database può essere ricostruito, verificato e sottoposto a revisione.

La Sessione S019 ha applicato concretamente questo principio mediante la prima migration della baseline Database V1:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

La Sessione S026 ha continuato lo stesso modello mediante:

```text
supabase/migrations/20260911084752_add_crop_catalog.sql
supabase/migrations/20260911091047_add_crop_catalog_write_rpcs.sql
```

Le migration del Catalogo DB V1 sono state applicate anche al database Supabase remoto mediante:

```text
supabase db push
```

e la verifica eseguita nella S026 aveva confermato:

```text
Local = Remote fino a 20260911091047
```

La Sessione S028 ha proseguito la stessa strategia introducendo le migration versionate:

```text
supabase/migrations/20260915080700_add_plantings_authoritative_model.sql
supabase/migrations/20260915081444_add_plantings_write_rpcs.sql
```

La prima introduce il modello persistente autoritativo di `plantings`.

La seconda introduce:

```text
create_planting
update_planting
set_planting_status
```

e rafforza l'integrazione del dominio `plantings` con:

- Profile Write Authority;
- concorrenza ottimistica;
- lifecycle;
- invarianti metodo-dipendenti;
- geometria dell'aiuola;
- sovrapposizioni spaziali e temporali;
- protezione delle variazioni geometriche rispetto alle coltivazioni esistenti.

L'evoluzione fisica del Database V1 deve quindi continuare attraverso migration:

- versionate;
- riproducibili;
- conservate nel repository;
- verificabili mediante ricostruzione locale;
- sottoposte a test;
- coerenti con il contratto applicativo.

Non devono essere introdotte modifiche strutturali permanenti esclusivamente dalla Dashboard Supabase senza una migration corrispondente nel repository.

La cronologia delle migration deve permettere di ricostruire progressivamente l'evoluzione effettiva del Database V1 senza dipendere dallo stato manuale di un singolo ambiente.

## 11.10 Verifica delle migration

Ogni gruppo di migration deve essere sottoposto a verifiche appropriate prima di essere considerato completato.

Le verifiche devono comprendere, secondo il contenuto della migration:

- creazione corretta delle strutture;
- foreign key;
- vincoli;
- intervalli temporali;
- ownership;
- RLS;
- privilegi;
- operazioni consentite;
- operazioni che devono essere rifiutate;
- concorrenza;
- invarianti;
- compatibilità con Repository e dominio;
- eventuale migrazione dei dati preesistenti.

I test devono includere anche casi negativi, non soltanto operazioni autorizzate e valide.

La Sessione S019 ha applicato concretamente questi criteri alla prima migration Database V1 mediante:

- `supabase db reset`;
- controllo delle sei strutture Fondazioni;
- verifica dello schema `private`;
- verifica degli helper autorizzativi;
- verifica dei trigger metadata;
- verifica della Row Level Security;
- verifica delle **13 policy RLS**;
- test manuali di accesso autorizzato;
- test manuali di accesso non autorizzato;
- tentativi di scrittura non autorizzati;
- tentativi di eliminazione non autorizzati.

La Sessione S026 ha esteso il metodo di verifica al Catalogo DB V1.

I test funzionali SQL sono stati eseguiti con dati fittizi all'interno di transazioni:

```text
BEGIN
...
ROLLBACK
```

senza lasciare dati persistenti.

Sono stati verificati, tra gli altri:

- creazione delle entità;
- normalizzazione degli input;
- unicità case-insensitive;
- Profile Write Authority;
- owner/non-owner;
- aggiornamenti;
- `unchanged`;
- `version_conflict`;
- modifica di record inattivi;
- vincoli gerarchici;
- disattivazione e riattivazione;
- validazione di `default_start_method`;
- validazione del fabbisogno idrico quantitativo;
- validazione della resa;
- coerenza min/avg/max;
- validazione delle temperature;
- fallback Crop → Variety;
- blocco degli override parziali non ammessi;
- RLS;
- privilegi delle RPC.

Nella S026 sono stati inoltre eseguiti:

```text
supabase db lint --local
```

e:

```text
supabase db diff --local
```

con risultato:

```text
No schema changes found
```

La Sessione S028 ha applicato gli stessi principi alle migration di `plantings`.

È stata verificata la ricostruzione completa dello schema mediante:

```text
supabase db reset
```

con esito positivo.

È stato inoltre eseguito:

```text
supabase db lint --local
```

senza errori di schema.

Le verifiche S028 hanno coperto il nuovo contratto di `plantings`, comprendendo:

- struttura persistente;
- relazioni tra Profile, Garden, Season, Bed, Crop e Variety;
- metodi di avvio ammessi;
- vincoli metodo-dipendenti;
- geometria longitudinale;
- larghezza occupata;
- sesti;
- date;
- lifecycle;
- `row_version`;
- conflitti concorrenti;
- overlap spaziali;
- overlap temporali;
- compatibilità con la geometria storicizzata dell'aiuola;
- blocco delle variazioni geometriche incompatibili mediante `blocked_by_plantings`;
- Write Path autoritativo RPC-only.

La verifica applicativa collegata alle migration S028 ha inoltre confermato:

```text
flutter analyze
No issues found!
```

e:

```text
flutter test
997 tests passed
```

Una migration non deve essere considerata verificata soltanto perché viene applicata senza errori.

Deve essere controllato anche il comportamento effettivo:

- della struttura;
- delle autorizzazioni;
- delle invarianti;
- della concorrenza;
- del contratto RPC;
- dell'integrazione applicativa.

Il criterio consolidato rimane:

```text
migration versionata
        ↓
applicazione / ricostruzione controllata
        ↓
verifica struttura effettiva
        ↓
verifica sicurezza
        ↓
test positivi
        ↓
test negativi
        ↓
verifica integrazione applicativa
        ↓
commit e push
```

## 11.11 Backup e possibilità di recupero

Prima di migration distruttive o trasformazioni significative dei dati deve essere valutata una strategia di recupero adeguata.

In particolare, prima di operazioni che possano comportare perdita o trasformazione irreversibile devono essere verificate:

- disponibilità dei dati originali;
- possibilità di esportazione o backup;
- procedura di rollback quando tecnicamente possibile;
- procedura di ripristino quando un rollback automatico non è realistico.

La possibilità di applicare una migration non implica che essa debba essere eseguita senza una strategia di recupero.

Il principio operativo rimane coerente con le regole generali del progetto:

> **Sicurezza prima di tutto.**

## 11.12 Nessun big bang

La baseline delle 52 entità non deve essere interpretata come obbligo di creare contemporaneamente tutte le strutture fisiche.

L'implementazione deve procedere per blocchi coerenti e utili allo sviluppo effettivo dell'applicazione.

Il principio è:

```text
baseline completa
        �
implementazione simultanea
```

La Sessione S026 costituisce un esempio concreto di questo metodo.

L'obiettivo iniziale era avvicinarsi a `plantings`, ma l'analisi delle dipendenze ha evidenziato la necessità di implementare prima il Catalogo DB V1.

È stato quindi completato esclusivamente il blocco propedeutico:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

senza anticipare `plantings`.

L'obiettivo rimane raggiungere progressivamente la baseline V1 mantenendo in ogni fase controllo tecnico, testabilità e tracciabilità.

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
- Write Path autoritativi dove previsti;
- migrazione dei dati esistenti quando applicabile;
- integrazione con Repository e dominio;
- test di integrazione e sicurezza;
- documentazione aggiornata.

Fino a quel momento deve essere mantenuta esplicita la distinzione:

```text
Database V1 progettato
        ≠
Database V1 completamente implementato
```

Alla conclusione della S028:

```text
Catalogo DB V1
        ✓

Write Path Catalogo V1
        ✓

integrazione Flutter Catalogo V1
        ✓

public.plantings
        ✓

Write Path plantings
        ✓

integrazione Flutter creazione/modifica plantings
        ✓

lifecycle server-side plantings
        ✓

UI amministrativa Catalogo V1
        ✗

UI completa lifecycle plantings
        ✗

Database V1 completo
        ✗
```

La Sessione S028 ha introdotto:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

e ha completato il Write Path autoritativo mediante:

```text
create_planting
update_planting
set_planting_status
```

Il Database V1 continua quindi a essere considerato **parzialmente implementato**, ma `plantings` non appartiene più all'elenco delle entità ancora mancanti.

Restano incrementi successivi le ulteriori entità della baseline non ancora tradotte nello schema operativo e le funzionalità applicative non ancora integrate.

La UI minima di gestione del Catalogo V1 rimane un incremento applicativo distinto.

Per `plantings` rimangono invece aperti, lato applicativo:

- gestione UI completa del lifecycle;
- selezione della varietà;
- gestione esplicita di `end_date` nelle transizioni terminali;
- eliminazione progressiva delle dipendenze legacy residue.

Il completamento del Database V1 continuerà pertanto a essere valutato sulla base dello stato realmente implementato e verificato, non sulla sola presenza della progettazione nominale.

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

`profile_edit_locks` rimane una struttura tecnica separata e non appartiene al conteggio delle 52 entità di dominio.

Il controllo nominale finale **52/52** ha inoltre consolidato due decisioni importanti:

- `agronomic_windows` non costituisce una tabella persistente del Database V1, poiché `AgronomicWindow` rimane un risultato calcolato a partire da `agronomic_window_rules`;
- `irrigation_zone_target_assignments` costituisce il nome SQL definitivo e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

L'implementazione fisica del Database V1 è iniziata nella Sessione S019 e procede incrementalmente mediante migration versionate, controlli di sicurezza, test positivi e negativi e Write Path autoritativi.

Alla conclusione della Sessione S028 il Database V1 rimane parzialmente implementato, ma comprende ormai:

- Fondazioni;
- protocollo `profile_edit_locks`;
- Profile Write Authority;
- Write Path di `gardens`;
- Write Path di `seasons`;
- modello e Write Path autoritativo delle aiuole;
- Catalogo DB V1;
- integrazione Flutter del Catalogo V1;
- modello persistente autoritativo di `plantings`;
- Write Path autoritativo di `plantings`;
- lifecycle server-side delle coltivazioni;
- integrazione Flutter necessaria alla creazione e modifica delle coltivazioni.

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
- Write Path autoritativi per le operazioni che richiedono protezione server-side;
- concorrenza ottimistica mediante `row_version` ed `expected_row_version` quando prevista dal contratto;
- comportamento fail-closed in presenza di esiti sconosciuti, incompleti o non verificabili;
- nessun retry automatico quando l'esito effettivo di una scrittura non è confermabile;
- rilettura del dato autoritativo dopo una scrittura riuscita quando prevista dal flusso applicativo;
- letture dirette consentite soltanto quando protette dalle policy RLS previste;
- scritture del Catalogo V1 esclusivamente mediante RPC autoritative;
- scritture ordinarie di `plantings` esclusivamente mediante RPC autoritative;
- integrità della geometria storicizzata rispetto ai fatti reali registrati;
- semantica half-open per gli intervalli nei domini che la richiedono;
- estensioni future introdotte soltanto in presenza di requisiti concreti.

Questi principi devono essere preservati durante la progressiva implementazione SQL/Supabase e durante l'integrazione Flutter.

Il principio operativo generale rimane coerente con le regole del progetto:

> **Presto e bene non conviene.**

e:

> **Sicurezza prima di tutto.**

## 13.2 Stato raggiunto

Il percorso di implementazione può essere sintetizzato come:

```text
Database V1 progettato
        ✓
controllato nominalmente
        ✓
congelato
        ✓
documentato
        ✓
ambiente locale Supabase predisposto
        ✓
migration versionate
        ✓
Fondazioni implementate
        ✓
protocollo single-writer verificato
        ✓
Profile Write Authority implementata
        ✓
Write Path gardens verificato
        ✓
Write Path seasons verificato
        ✓
Write Path beds verificato
        ✓
Catalogo DB V1 implementato
        ✓
Write Path Catalogo DB V1 verificato
        ✓
integrazione Flutter Catalogo V1
        ✓
modello autoritativo plantings
        ✓
Write Path plantings
        ✓
integrazione Flutter creazione/modifica plantings
        ✓
lifecycle server-side plantings
        ✓
UI gestione Catalogo V1
        ✗
UI completa lifecycle plantings
        ✗
Database V1 completo
        ✗
```

L'ambiente locale Supabase predisposto nella Sessione S018 rimane il riferimento per sviluppo, ricostruzione e verifica.

La prima migration Database V1 è:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

Il primo gruppo implementato comprende le strutture Fondazioni:

```text
profiles
profile_memberships
gardens
workers
seasons
profile_edit_locks
```

Sono stati inoltre introdotti nel corso delle sessioni successive:

```text
beds
bed_geometries
bed_geometry_corrections
botanical_families
crops
crop_varieties
plantings
```

`profile_edit_locks` rimane infrastruttura tecnica separata.

`profile_memberships` costituisce una struttura di sicurezza e accesso introdotta nell'implementazione fisica e deve essere distinta dalle 52 entità di dominio congelate.

La Sessione S028 ha introdotto le migration:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Il Database V1 completo non è ancora implementato, ma:

```text
public.plantings
```

è ora presente nello schema implementato e dispone del relativo Write Path autoritativo.

La verifica locale S028 ha confermato:

```text
supabase db reset
success
```

e:

```text
supabase db lint --local
No schema errors found
```

## 13.3 Evoluzione dell'implementazione dalla S019 alla S028

La Sessione S019 ha avviato concretamente la traduzione della baseline Database V1 congelata nella S017 in strutture PostgreSQL/Supabase versionate e verificabili.

Il primo incremento ha riguardato il blocco **Fondazioni** e ha introdotto:

- schema `private`;
- helper autorizzativi;
- trigger metadata;
- Row Level Security;
- **13 policy RLS**;
- test manuali positivi;
- test manuali negativi.

La Sessione S020 ha avviato l'implementazione delle RPC server-side del protocollo `profile_edit_locks`.

La Sessione S021 ha completato e rafforzato il protocollo single-writer, verificando:

- serializzazione mediante `FOR UPDATE`;
- rivalidazione server-side dopo eventuali attese sui row lock;
- utilizzo dell'orologio PostgreSQL come autorità temporale;
- protezione del lease;
- gestione sicura del takeover;
- trasferimento atomico del lock.

La Sessione S022 ha introdotto la Profile Write Authority e il primo Write Path autoritativo per:

```text
gardens
```

mediante:

```text
create_garden
update_garden
```

La Sessione S023 ha rafforzato `update_garden` mediante `expected_row_version` e ha introdotto il Write Path autoritativo di:

```text
seasons
```

mediante:

```text
create_season
update_season
activate_season
```

La Sessione S024 ha introdotto:

```text
beds
bed_geometries
bed_geometry_corrections
```

e il relativo Write Path autoritativo mediante:

```text
create_bed
update_bed
set_bed_active
change_bed_geometry
correct_bed_geometry
```

La Sessione S025 ha completato l'integrazione Flutter dei Write Path autoritativi di `beds`, mantenendo:

- Profile Write Authority;
- concorrenza ottimistica;
- rilettura autoritativa;
- comportamento fail-closed;
- separazione tra variazione geometrica ordinaria e correzione storica;
- gestione delle date civili mediante `CivilDate`.

La Sessione S026 ha introdotto il **Catalogo DB V1**:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

mediante:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

e le nove RPC autoritative:

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

La Sessione S027 non ha modificato lo schema PostgreSQL/Supabase.

Ha invece completato l'integrazione Flutter del Catalogo V1 mediante:

```text
BotanicalFamily
Crop
CropVariety
```

e:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

con letture RLS, scritture RPC-only, Profile Write Authority fail-closed, result type tipizzati e gestione della concorrenza mediante `row_version`.

La verifica applicativa S027 ha confermato:

```text
124 test mirati superati
914 test complessivi superati
flutter analyze: No issues found
```

La Sessione S028 ha quindi implementato il modello autoritativo di:

```text
public.plantings
```

mediante:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Il modello persistente comprende il contesto:

```text
profile_id
garden_id
season_id
bed_id
crop_id
variety_id
```

e le informazioni operative:

```text
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
row_version
```

Il Write Path autoritativo utilizza:

```text
create_planting
update_planting
set_planting_status
```

e applica:

- Profile Write Authority;
- concorrenza ottimistica;
- validazione delle relazioni;
- controllo degli stati attivi delle entità collegate;
- validazioni metodo-dipendenti;
- validazioni geometriche;
- validazioni temporali;
- controllo delle sovrapposizioni;
- lifecycle autoritativo;
- comportamento fail-closed.

La S028 ha inoltre rafforzato:

```text
change_bed_geometry
correct_bed_geometry
```

per impedire che variazioni della geometria rendano incompatibili coltivazioni esistenti.

Il nuovo esito specifico è:

```text
blocked_by_plantings
```

Sul lato Flutter sono stati riallineati:

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

ed è stato introdotto:

```text
lib/core/write_authority/planting_write_result.dart
```

La verifica finale S028 ha confermato:

```text
flutter analyze
No issues found!
```

```text
flutter test
997 tests passed
```

## 13.4 Stato dei Write Path autoritativi

Alla conclusione della Sessione S028 risultano completati e coerenti allo stato attuale i Write Path autoritativi di:

```text
gardens
seasons
beds
botanical_families
crops
crop_varieties
plantings
```

Per il Catalogo DB V1 e per `plantings` è inoltre disponibile il relativo Repository Layer Flutter.

Le scritture protette seguono il principio:

```text
autenticazione
        +
ownership
        +
Profile Write Authority quando prevista
        +
concorrenza
        +
invarianti
        +
operazione atomica
        =
modifica autorizzata
```

Le RPC devono continuare a essere progettate secondo il principio del privilegio minimo, con particolare attenzione a:

- `SECURITY DEFINER`;
- `search_path = ''`;
- privilegi `EXECUTE`;
- `REVOKE`;
- `GRANT`;
- identità autenticata;
- impossibilità per il client di attribuirsi autonomamente privilegi;
- concorrenza;
- rivalidazione del lease;
- comportamento fail-closed.

Il percorso raggiunto è:

```text
Fondazioni e protocollo single-writer verificati
        ↓
Write Path gardens verificato
        ↓
Write Path seasons verificato
        ↓
Write Path beds verificato
        ↓
integrazione Flutter beds completata
        ↓
Catalogo DB V1 implementato
        ↓
Write Path Catalogo DB V1 verificato
        ↓
integrazione Flutter Catalogo V1 completata
        ↓
plantings implementata
        ↓
Write Path plantings verificato
        ↓
integrazione Flutter creazione/modifica plantings
        ↓
ulteriori incrementi applicativi e Database V1
```

Le operazioni amministrative protette su `profile_memberships` rimangono un blocco separato ancora da implementare.

## 13.5 Relazione con il dominio applicativo

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

Il database conserva:

- dati persistenti;
- relazioni;
- ownership;
- autorizzazioni;
- invarianti;
- stato concorrente;
- informazioni necessarie alla ricostruibilità.

Il dominio applicativo mantiene invece la responsabilità delle valutazioni e delle decisioni agronomiche.

Un esempio fondamentale rimane:

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

Il Database V1 conserva le regole persistenti.

La determinazione della `AgronomicWindow` applicabile rimane responsabilità del dominio.

Lo stesso principio vale per il Catalogo DB V1.

Il database conserva valori di riferimento, relazioni e invarianti, mentre il dominio applicativo utilizza tali dati nei calcoli e nelle decisioni agronomiche.

La S028 conferma ulteriormente questa separazione.

Per `plantings`, il database è autoritativo per:

- ownership;
- relazioni;
- lifecycle;
- geometria persistita;
- date;
- overlap;
- concorrenza;
- invarianti strutturali.

Il client Flutter gestisce invece:

- presentazione;
- raccolta degli input;
- feedback;
- pre-validazioni UX;
- coordinamento con i Repository;
- utilizzo agronomico dei dati.

Le pre-validazioni Flutter non sostituiscono mai il controllo server-side.

Il catalogo continua inoltre a seguire il principio:

> **catalogo corrente + snapshot storico**

Le future modifiche ai valori correnti del catalogo non devono riscrivere retroattivamente calcoli, decisioni o risultati storici già consolidati.

## 13.6 Incrementi successivi

La sequenza tecnica consolidata fino alla S028 è:

```text
Catalogo DB V1
        ↓
Write Path Catalogo V1
        ↓
integrazione Flutter Catalogo V1
        ↓
modello autoritativo plantings
        ↓
Write Path plantings
        ↓
integrazione Flutter creazione/modifica plantings
        ↓
incrementi successivi
```

La Sessione S028 ha completato il Write Path autoritativo di `plantings`.

Non è stata invece completata l'intera esperienza utente relativa al lifecycle.

Restano aperti, tra gli incrementi applicativi:

- UI completa delle transizioni lifecycle;
- scelta facoltativa della varietà durante la gestione della coltivazione;
- gestione esplicita di `end_date` nelle transizioni terminali;
- gestione degli esiti concorrenti nella UI lifecycle;
- refresh completo dei componenti interessati dopo il cambio di stato;
- progressiva rimozione delle dipendenze legacy residue;
- UI amministrativa del Catalogo V1.

Il lifecycle server-side è già implementato e costituisce il contratto autoritativo che la futura UI dovrà utilizzare.

La pianificazione preliminare successiva prevede di portare queste funzionalità nella UI senza riaprire il contratto persistente definito nella S028.

## 13.7 Evoluzione del documento

Il presente Manuale Database deve essere aggiornato insieme all'implementazione effettiva del Database V1.

Durante le future migration devono essere documentati almeno:

- schema SQL realmente implementato;
- tipi e precisioni definitivi;
- primary key e foreign key;
- vincoli;
- indici;
- policy RLS;
- funzioni server-side;
- privilegi;
- strategie di migrazione dei dati;
- concorrenza;
- Write Path autoritativi;
- test di integrazione e sicurezza;
- eventuali differenze motivate rispetto alla baseline progettuale.

Anche le integrazioni Flutter che modificano il rapporto tra Repository Layer e contratti persistenti devono essere riportate quando incidono sull'architettura complessiva di accesso ai dati.

Qualora emerga la necessità di modificare una decisione congelata, la variazione deve essere valutata e tracciata nella documentazione architetturale e non introdotta silenziosamente durante l'implementazione.

## 13.8 Documentazione correlata

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

La baseline descritta nel presente documento costituisce il riferimento architetturale controllato per l'implementazione del Database V1 di Orto Smart.

Il principio da mantenere durante le successive sessioni è:

```text
prima progettare
        ↓
poi implementare
        ↓
sempre verificare
```

La progettazione S017 non deve essere riaperta durante l'implementazione salvo l'emersione di un errore concreto o di una necessità architetturale dimostrata.

Alla conclusione della Sessione S028:

- il Catalogo DB V1 è implementato e verificato lato PostgreSQL/Supabase;
- il Repository Layer Flutter del catalogo è integrato;
- `public.plantings` è implementata;
- il Write Path autoritativo di `plantings` è implementato;
- il lifecycle autoritativo è implementato server-side;
- la geometria delle aiuole è protetta rispetto alle coltivazioni esistenti;
- `PlantingRepository` e la UI di creazione/modifica sono riallineati al contratto S028;
- `flutter analyze` non segnala problemi;
- la suite completa raggiunge **997 test superati**;
- la UI amministrativa del Catalogo V1 non è ancora implementata;
- la UI completa del lifecycle di `plantings` rimane un incremento successivo;
- il Database V1 complessivo rimane parzialmente implementato.
