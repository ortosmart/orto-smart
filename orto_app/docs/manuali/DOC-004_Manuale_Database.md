# ORTO SMART

### DOC-004

# Manuale Database

**Versione:** 2.2
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 16/08/2026
**Ultimo aggiornamento:** 24/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
| --- | --- |
| Documento | DOC-004 |
| Titolo | Manuale Database |
| Versione | 2.2 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 16/08/2026 |
| Ultimo aggiornamento | 24/09/2026 |

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
| 2.2 | 24/09/2026 | Aggiornamento con le Sessioni S029-S030: consolidamento del lifecycle applicativo delle coltivazioni e trasformazione del Catalogo Agronomico V1 in architettura globale, multisorgente, tracciabile, versionabile, contestualizzabile ed editorialmente controllata; introduzione di identità botaniche globali, registry dei parametri, contesti, provenienza, ingestion, workflow editoriale, Knowledge canonica, Catalog Authority e capability, Write Path autoritativi, pubblicazione e Resolver; cutover finale verso `botanical_taxa`, `crops` e `crop_cultivars`, migrazione di `plantings` da varietà a cultivar, integrazione Flutter, verifica completa locale/remota e definizione degli incrementi FUTURE post-S030 |

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
- le successive evoluzioni architetturali approvate e versionate;
- i Write Path autoritativi e i meccanismi di sicurezza implementati;
- l'integrazione Flutter delle strutture già portate nel contratto applicativo;
- lo stato corrente raggiunto dopo la Sessione S030;
- le entità, le interfacce e i flussi che devono ancora essere implementati.

La baseline Database V1 costituisce il riferimento storico e architetturale per la traduzione progressiva del modello in PostgreSQL/Supabase.

La sua implementazione fisica può evolvere quando emergono necessità architetturali concrete, purché tali evoluzioni siano:

- esplicite;
- motivate;
- versionate;
- verificate;
- documentate;
- coerenti con le decisioni architetturali approvate.

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

## Evoluzione fino alla S029

Tra le Sessioni S019 e S029 sono stati progressivamente implementati e consolidati, tra gli altri:

- Fondazioni Database V1;
- protocollo `profile_edit_locks`;
- Profile Write Authority;
- Write Path autoritativi di `gardens`;
- Write Path autoritativi di `seasons`;
- Write Path autoritativi di `beds`;
- prima implementazione del Catalogo DB V1;
- integrazione Flutter del primo Catalogo V1;
- modello persistente autoritativo di `plantings`;
- Write Path autoritativo di `plantings`;
- lifecycle server-side delle coltivazioni;
- integrazione Flutter per creazione e modifica delle coltivazioni;
- integrazione UI del lifecycle.

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

Il Write Path di `plantings` ha consolidato:

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

La Sessione S029 non ha modificato il contratto persistente introdotto dalla S028.

Ha completato il livello applicativo del lifecycle delle coltivazioni utilizzando il Write Path autoritativo già disponibile.

Il flusso applicativo consolidato nella S029 era:

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

La verifica tecnica finale S029 ha confermato:

```text
flutter test
1011/1011 test passati

bed_page_test.dart
30/30 test passati

planting_card_test.dart
9/9 test passati

flutter analyze
No issues found! (ran in 12.8s)
```

Questi risultati rimangono parte della cronologia verificata del progetto, ma non rappresentano il conteggio della suite corrente dopo la successiva evoluzione S030.

## Evoluzione S030 del Catalogo Agronomico

La Sessione S030 ha trasformato sostanzialmente l'architettura del Catalogo Agronomico V1.

Il precedente modello Profile-owned è stato sostituito operativamente da un Catalogo:

- globale;
- multisorgente;
- tracciabile;
- versionabile;
- contestualizzabile;
- editorialmente controllato;
- separato dai dati operativi del singolo orto.

L'implementazione S030 è stata realizzata attraverso undici tranche tecniche:

1. identità globali;
2. registry dei parametri agronomici;
3. vocabolari di contesto;
4. fonti, acquisizioni e osservazioni;
5. alias delle identità agronomiche;
6. workflow editoriale;
7. Knowledge agronomica canonica;
8. hardening dell'integrità;
9. Write Path autoritativi;
10. pubblicazione e Resolver;
11. cutover globale finale DB + Flutter.

Il nuovo perimetro del Catalogo Agronomico comprende **26 tabelle**.

La catena canonica corrente delle identità è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Il cutover finale ha rimosso dal modello corrente:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Questi nomi possono continuare a comparire nel manuale quando descrivono correttamente una fase storica precedente.

## Provenienza, workflow e Knowledge

La S030 ha introdotto una separazione esplicita tra:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
workflow editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Resolver
```

Un dato proveniente da una fonte esterna non diventa automaticamente dato canonico.

Le osservazioni importate costituiscono materiale candidato da valutare attraverso il workflow previsto.

Nessuna fonte esterna può sovrascrivere automaticamente la Knowledge approvata.

La tracciabilità comprende, secondo il relativo contratto:

- provenienza;
- identità;
- contesto;
- revisioni;
- stato editoriale;
- pubblicazione;
- eventuale WITHDRAW.

Le revisioni editoriali utilizzano una catena esplicita mediante:

```text
previous_revision_id
```

e gli artefatti soggetti a semantic freeze non possono essere modificati liberamente dopo il raggiungimento dello stato che ne determina l'immutabilità.

## Catalog Authority

La gestione autoritativa del Catalogo globale non dipende dalla proprietà di un singolo Profile o Garden.

La S030 ha introdotto una **Catalog Authority** globale con capability distinte per:

- gestione delle identità;
- ingestion;
- review;
- publication.

Sono disponibili:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

Il claim iniziale:

- è esplicito;
- non è automatico;
- è idempotente;
- è consentito soltanto al soggetto idoneo previsto dal contratto;
- non permette di reclamare nuovamente un'authority già inizializzata.

La UI dedicata all'esecuzione sicura del claim rimane un incremento FUTURE.

## Plantings dopo il cutover S030

La S030 ha riallineato `plantings` al nuovo Catalogo globale.

Il contratto persistente corrente utilizza:

```text
crop_id
cultivar_id
```

con `cultivar_id` facoltativo.

La coerenza tra cultivar e coltura è protetta mediante foreign key composita:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

Il precedente:

```text
variety_id
```

è stato rimosso dal modello persistente corrente.

I riferimenti a `variety_id` o `crop_varieties` rimasti nelle parti storiche del documento descrivono esclusivamente le fasi precedenti al cutover S030.

I valori agronomici memorizzati nel contesto operativo di un Planting continuano a rappresentare snapshot operativi quando il relativo contratto ne prevede la persistenza.

Una successiva modifica della Knowledge canonica non deve modificare automaticamente tali fatti storici.

## Read model e integrazione Flutter

Il confine di lettura corrente del Catalogo utilizza:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

configurati con:

```text
security_invoker = true
```

L'integrazione Flutter corrente comprende:

```text
CropRepository
CropCultivarRepository
CatalogAuthorityRepository
CatalogCapabilities
```

La terminologia tecnica utilizza:

```text
cultivarId
cultivar_id
CropCultivar
```

mentre la UI italiana può continuare a presentare all'utente il termine **Varietà**.

Il `RotationEngine` utilizza l'UUID canonico della famiglia botanica per i confronti; il nome della famiglia rimane destinato alla presentazione.

Il backend canonico delle associazioni colturali non è ancora implementato.

Per evitare interrogazioni verso una relazione inesistente:

```text
CropAssociationRepository
```

restituisce attualmente insiemi vuoti.

Il relativo backend rimane FUTURE.

## Resolver e decisione operativa

Il Resolver introdotto nella S030 determina la Knowledge canonica applicabile secondo il proprio contratto.

Non sostituisce però la decisione operativa del dominio applicativo o dell'utente.

Il flusso da preservare è:

```text
Knowledge canonica
        ↓
Resolver
        ↓
Repository / dominio Dart
        ↓
valutazione o proposta
        ↓
eventuale conferma dell'utente
        ↓
Write Path autoritativo
        ↓
fatto operativo persistente
```

Pertanto:

```text
Knowledge risolta
        ≠
modifica automatica del Planting
```

## Verifica tecnica S030

La Sessione S030 è stata verificata mediante ricostruzione completa del database da zero.

La verifica finale ha confermato:

```text
supabase db reset
completato con successo
```

```text
DB lint locale
No schema errors found
```

```text
DB lint remoto
No schema errors found
```

Sono inoltre state superate:

- Acceptance Tranche 10;
- Acceptance Tranche 11.

Le fixture utilizzate per le verifiche sono state sottoposte a rollback e non sono rimasti dati di prova persistenti.

La migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

è stata applicata anche al database remoto.

Alla chiusura tecnica S030 lo stato verificato delle migration era:

```text
locale:  20260923154831
remoto:  20260923154831
```

Sul lato Flutter sono stati verificati:

```text
dart format lib test
174 file formattati

flutter analyze
No issues found

flutter test
953 test passati
```

Lo smoke test finale su Edge ha inoltre confermato:

- Dashboard funzionante;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- corretta visualizzazione dello stato “Nessuna varietà presente”;
- assenza del precedente pulsante di aggiunta;
- corretta gestione di un profilo privo di Garden.

Il test manuale completo di Beds e Planting non è stato possibile nello smoke test finale perché il profilo utilizzato non disponeva di un Garden.

## Stato corrente del documento

Il Database V1 complessivo rimane **parzialmente implementato**.

La conclusione tecnica S030 non implica che tutte le funzionalità applicative del Catalogo siano già disponibili.

Restano FUTURE, tra gli incrementi principali:

- backend canonico delle associazioni colturali;
- UI editoriale e amministrativa completa del Catalogo;
- azione UI esplicita e sicura per il claim iniziale della Catalog Authority;
- flusso operativo di ingestion/import/review in `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- schermate del workflow editoriale;
- integrazione completa del Resolver nei flussi di pianificazione e creazione delle coltivazioni;
- popolamento editoriale del Catalogo con dati agronomici verificabili;
- smoke test con dati operativi reali;
- manutenzione periodica ISO 3166-1 alpha-2 mediante migration e test verificati, mai automatica;
- verifica o ripristino del percorso UI per la creazione del primo Garden;
- completamento progressivo delle restanti aree del Database V1.

Il database deve rimanere privo di dati demo o provvisori fino all'avvio della gestione reale dell'orto.

La sequenza prevista per l'avvio operativo è:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
caricamento Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle 15 Beds reali
        ↓
apertura Season reale
        ↓
registrazione Plantings reali
```

Il presente manuale documenta quindi contemporaneamente:

```text
baseline storica S017
        +
evoluzione implementativa
        +
stato fisico corrente
        +
contratti autoritativi
        +
incrementi FUTURE
```

mantenendo sempre distinta la progettazione storica dall'implementazione effettivamente raggiunta.

# 2. Stato del database

Il progetto Orto Smart si trova in una fase di implementazione incrementale della baseline Database V1 progettata nella Sessione S017.

È necessario distinguere chiaramente:

- la **baseline logica Database V1**, che rimane il riferimento progettuale congelato;
- lo **schema PostgreSQL/Supabase effettivamente implementato**;
- il **Catalogo Agronomico V1**, la cui architettura è stata profondamente evoluta nella Sessione S030;
- le funzionalità applicative Flutter effettivamente integrate;
- gli incrementi della baseline non ancora implementati.

La Sessione S030 ha completato il passaggio dal precedente Catalogo DB V1 Profile-owned a un **Catalogo Agronomico V1 globale, multisorgente, tracciabile, versionabile, contestualizzabile ed editorialmente controllato**.

Il modello corrente deve pertanto essere distinto dalle precedenti architetture S026–S029, che rimangono valide come ricostruzione storica dell'evoluzione del progetto ma non rappresentano più il contratto corrente del Catalogo.

## 2.1 Database attualmente implementato

L'applicazione utilizza **Supabase**, basato su PostgreSQL, come backend persistente.

L'implementazione procede mediante migration versionate e mantiene il database come autorità per:

- integrità referenziale;
- ownership;
- autorizzazioni;
- invarianti persistenti;
- Write Path protetti;
- concorrenza;
- lifecycle;
- tracciabilità delle modifiche;
- sicurezza server-side.

Nel perimetro già implementato rientrano, tra le altre, le strutture relative a:

- Profile e membership;
- Garden;
- Seasons;
- Beds e geometria storicizzata;
- Catalogo Agronomico V1;
- Plantings;
- infrastruttura di coordinamento single-writer.

### Catalogo Agronomico V1 corrente

La Sessione S030 ha sostituito il precedente modello Profile-owned:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

con un'architettura globale in cui identità botaniche, identità agronomiche e Knowledge agronomica sono concetti distinti.

La catena canonica delle identità utilizzata dall'applicazione è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Le tabelle legacy:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

non appartengono più allo schema operativo finale del Catalogo dopo il cutover S030.

`botanical_taxa` rappresenta la tassonomia botanica globale.

I rank canonici previsti sono:

```text
FAMILY
GENUS
SPECIES
VARIETY
CULTIVAR
```

`crops` rappresenta le identità agronomiche globali delle colture.

`crop_cultivars` rappresenta le cultivar associate alle rispettive colture.

La terminologia tecnica corrente utilizza:

```text
cultivar
cultivar_id
CropCultivar
```

La UI italiana può continuare a utilizzare il termine **Varietà** quando questo migliora la comprensibilità per l'utente.

### Identità botaniche e Knowledge agronomica

La S030 separa esplicitamente:

```text
identità botanica/agronomica
        ≠
Knowledge agronomica
```

Le identità stabiliscono **che cosa è** una coltura o cultivar.

La Knowledge agronomica stabilisce invece **che cosa è noto agronomicamente** su tale identità, con provenienza, contesto, revisione e versione tracciabili.

Il Catalogo è progettato per supportare il flusso:

```text
fonte esterna
        ↓
acquisizione
        ↓
osservazione
        ↓
dato candidato
        ↓
revisione editoriale
        ↓
approvazione
        ↓
pubblicazione
        ↓
Knowledge agronomica canonica
```

Un dato esterno non diventa automaticamente dato canonico.

Nessuna fonte esterna può sovrascrivere automaticamente dati già approvati nel Catalogo.

### Catalog Authority

La gestione protetta del Catalogo globale utilizza:

```text
catalog_authorities
```

con capability distinte per:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

L'inizializzazione esplicita dell'autorità iniziale utilizza:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

Il claim iniziale:

- non è automatico;
- è consentito soltanto al proprietario idoneo previsto dal contratto;
- è idempotente;
- non consente di reclamare nuovamente una authority già inizializzata.

Le operazioni protette del Catalogo sono eseguite mediante Write Path server-side autoritativi.

Flutter è considerato client non fidato e non costituisce l'autorità per le invarianti del Catalogo.

### Normalizzazione delle identità

La normalizzazione testuale canonica del Catalogo utilizza:

```text
private.normalize_catalog_text(text)
```

con criteri coerenti per:

- normalizzazione Unicode;
- trim;
- riduzione degli spazi;
- confronto normalizzato dei testi.

Questo consente di ridurre duplicazioni semantiche dovute esclusivamente a differenze di rappresentazione testuale.

### Read model applicativi

La lettura applicativa canonica delle colture e cultivar utilizza:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati con:

```text
security_invoker = true
```

Il client Flutter utilizza:

```text
CropRepository
CropCultivarRepository
CatalogAuthorityRepository
```

Il precedente:

```text
CropVarietyRepository
```

non appartiene più al contratto applicativo corrente.

### Plantings

`public.plantings` continua a rappresentare le coltivazioni reali.

Il Write Path autoritativo rimane disponibile mediante:

```text
create_planting
update_planting
set_planting_status
```

La relazione corrente con il Catalogo utilizza:

```text
crop_id
cultivar_id
```

dove `cultivar_id` è opzionale.

La coerenza tra cultivar e coltura è protetta mediante la relazione composita:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

Il precedente:

```text
variety_id
```

non appartiene più al contratto persistente corrente di `plantings`.

`plantings` conserva inoltre le informazioni operative necessarie a rappresentare:

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

I valori agronomici memorizzati nella coltivazione costituiscono snapshot operativi.

Il Catalogo e il futuro utilizzo completo del Resolver possono proporre valori, ma non devono modificare automaticamente una coltivazione reale senza conferma dell'utente.

Il Write Path di `plantings` continua ad applicare:

- Profile Write Authority;
- validazioni server-side;
- vincoli relazionali;
- controllo della geometria;
- controllo congiunto delle sovrapposizioni spaziali e temporali;
- concorrenza ottimistica;
- lifecycle autoritativo.

Le operazioni Flutter ordinarie utilizzano `PlantingRepository` e le RPC autoritative senza scritture dirette sulla tabella.

Il lifecycle integrato nella S029 rimane operativo dopo il cutover S030.

Sono quindi mantenuti:

- azioni contestuali in `PlantingCard`;
- conferma esplicita di `end_date` per `finished` e `removed`;
- `end_date = null` nelle transizioni intermedie;
- mantenimento dell'occupazione dell'aiuola nello stato `harvested`;
- refresh autoritativo in caso di `version_conflict`;
- refresh autoritativo in caso di `invalid_transition`.

### Stato applicativo del Catalogo

La S030 ha completato l'architettura persistente, i Write Path autoritativi necessari, i read model e il riallineamento Flutter indispensabile al nuovo contratto.

Non costituiscono invece ancora funzionalità operative complete:

- UI editoriale/amministrativa completa del Catalogo;
- workflow UI completo di ingestion, revisione e pubblicazione;
- azione UI definitiva e sicura per `claim_initial_catalog_authority()`;
- integrazione completa del Resolver nel flusso di pianificazione e creazione delle coltivazioni;
- backend canonico delle associazioni colturali;
- popolamento editoriale reale del Catalogo con dati agronomici verificati.

Il Database V1 complessivo non coincide ancora con l'intera baseline delle 52 entità progettate nella S017: l'implementazione fisica continua incrementalmente.

La presenza di una entità nella baseline Database V1 non implica automaticamente che tutte le strutture, relazioni, policy o funzionalità previste dalla baseline siano già implementate.

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

La baseline S017 costituisce il riferimento progettuale, ma la sua traduzione fisica può evolvere mediante decisioni architetturali successive documentate e versionate.

La S030 costituisce un esempio di questa evoluzione controllata: il Catalogo Agronomico è stato specializzato rispetto alla precedente implementazione fisica senza cancellare la tracciabilità delle decisioni e degli stati storici precedenti.

`AgronomicWindow` rimane un risultato calcolato a partire dalle regole agronomiche e non corrisponde a una tabella `agronomic_windows` del Database V1.

Il nome SQL definitivo dell'assegnazione dei target alle zone irrigue è:

```text
irrigation_zone_target_assignments
```

e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

## 2.3 Stato di implementazione

Al termine della Sessione S030 la situazione del Database V1 è la seguente:

- la progettazione logica e architetturale completata nella S017 rimane la baseline ufficiale congelata;
- l'ambiente locale Supabase è operativo per sviluppo, ricostruzione e collaudo;
- le migration costituiscono la fonte riproducibile dello schema PostgreSQL/Supabase;
- è implementato il gruppo **Fondazioni**;
- sono presenti lo schema `private`, gli helper autorizzativi, i trigger metadata e le protezioni RLS previste dai domini già implementati;
- è completato e verificato il protocollo server-side `profile_edit_locks`;
- è disponibile la Profile Write Authority server-side;
- `gardens` dispone del Write Path autoritativo mediante `create_garden` e `update_garden`;
- `seasons` dispone del Write Path autoritativo mediante `create_season`, `update_season` e `activate_season`;
- `beds` dispone del Write Path autoritativo mediante `create_bed`, `update_bed`, `set_bed_active`, `change_bed_geometry` e `correct_bed_geometry`;
- il precedente Catalogo DB V1 Profile-owned è stato sostituito dal Catalogo Agronomico V1 globale;
- `botanical_taxa`, `crops` e `crop_cultivars` costituiscono le identità canoniche correnti del Catalogo;
- identità botaniche/agronomiche e Knowledge agronomica sono separate;
- il Catalogo supporta fonti, acquisizioni, osservazioni, alias, workflow editoriale, Knowledge canonica, pubblicazione e Resolver;
- `catalog_authorities` governa le capability autoritative del Catalogo;
- sono disponibili `get_my_catalog_capabilities()` e `claim_initial_catalog_authority()`;
- le scritture protette del Catalogo utilizzano RPC server-side autoritative;
- le autorizzazioni vengono verificate server-side;
- Flutter rimane un client non fidato;
- `crop_catalog_read` e `crop_cultivar_catalog_read` costituiscono i read model applicativi canonici;
- i read model operano con `security_invoker = true`;
- `CropRepository` utilizza il nuovo read model delle colture;
- `CropCultivarRepository` utilizza il nuovo read model delle cultivar;
- `CatalogAuthorityRepository` espone la lettura delle capability e il claim esplicito dell'autorità iniziale;
- `BotanicalFamilyRepository`, `CropVarietyRepository` e i relativi contratti legacy non appartengono più all'architettura corrente;
- `public.plantings` è implementata;
- il Write Path autoritativo di `plantings` utilizza `create_planting`, `update_planting` e `set_planting_status`;
- `PlantingRepository` utilizza le RPC autoritative per le scritture ordinarie;
- `plantings` utilizza `crop_id` e l'opzionale `cultivar_id`;
- `variety_id` è stato rimosso dal contratto persistente corrente;
- la relazione composita `(cultivar_id, crop_id)` protegge la coerenza con `crop_cultivars(id, crop_id)`;
- le coltivazioni utilizzano Profile Write Authority in modalità fail-closed;
- `plantings` utilizza `row_version` per la concorrenza ottimistica;
- la geometria delle coltivazioni viene verificata rispetto alla geometria valida dell'aiuola;
- le sovrapposizioni vengono controllate considerando congiuntamente occupazione spaziale e temporale;
- le modifiche alla geometria delle aiuole sono protette rispetto alle coltivazioni esistenti;
- `change_bed_geometry` e `correct_bed_geometry` possono restituire `blocked_by_plantings`;
- il lifecycle autoritativo delle coltivazioni è implementato server-side;
- il lifecycle è integrato nella UI;
- `PlantingCard` espone azioni contestuali coerenti con lo stato corrente;
- `BedPage` utilizza `PlantingRepository.setPlantingStatus`;
- gli stati terminali `finished` e `removed` richiedono conferma esplicita di `end_date`;
- lo stato `harvested` continua a mantenere occupata l'aiuola;
- `version_conflict` e `invalid_transition` provocano una rilettura autoritativa delle coltivazioni;
- il motore di rotazione utilizza l'identità canonica della famiglia botanica;
- il nome della famiglia rimane informazione di presentazione e non chiave di confronto;
- il backend canonico delle associazioni colturali non è ancora implementato;
- `CropAssociationRepository` non interroga una relazione canonica inesistente e restituisce insiemi vuoti nello stato corrente;
- la UI editoriale/amministrativa completa del Catalogo non è ancora implementata;
- l'integrazione completa del Resolver nei flussi operativi rimane un incremento successivo;
- il popolamento reale del Catalogo con dati agronomici verificati rimane un incremento successivo;
- il Database V1 complessivo rimane parzialmente implementato.

Tra le strutture già operative e le principali strutture canoniche introdotte nel perimetro corrente rientrano:

```text
profiles
profile_memberships
gardens
workers
seasons
beds
bed_geometries
bed_geometry_corrections
botanical_taxa
crops
crop_cultivars
catalog_authorities
plantings
```

A queste si aggiungono le strutture del Catalogo Agronomico necessarie a rappresentare:

```text
registri dei parametri agronomici
vocabolari di contesto
fonti
acquisizioni
osservazioni
alias
workflow editoriale
Knowledge agronomica canonica
pubblicazione
Resolver
```

e la struttura tecnica separata:

```text
profile_edit_locks
```

Le principali migration già consolidate nelle sessioni precedenti rimangono parte della catena riproducibile dello schema.

Per le aiuole e la geometria storicizzata, dalla S024:

```text
20260830091156_add_beds_and_geometry_history.sql
20260830095426_add_beds_write_rpcs.sql
20260830101354_add_bed_geometry_write_rpcs.sql
20260830103544_add_bed_geometry_corrections.sql
20260830133429_harden_bed_geometry_write_rpcs.sql
```

Per il precedente Catalogo DB V1, dalla S026:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

Queste migration rimangono nella storia riproducibile dello schema anche se le strutture legacy del Catalogo vengono successivamente trasformate o rimosse dal cutover S030.

Per `plantings`, dalla S028:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Le principali migration S030 del Catalogo Agronomico sono:

```text
20260920192606_add_global_catalog_identity.sql
20260920200852_add_agronomic_parameter_registry.sql
20260920203021_add_agronomic_context_vocabularies.sql
20260921124219_add_agronomic_sources_and_observations.sql
20260921142750_add_agronomic_identity_aliases.sql
20260921145956_add_agronomic_editorial_workflow.sql
20260922082448_add_canonical_agronomic_knowledge.sql
20260922091737_harden_agronomic_catalog_integrity.sql
20260922154850_add_catalog_identity_write_rpcs.sql
20260922165844_add_catalog_registry_write_rpcs.sql
20260922175238_add_catalog_ingestion_write_rpcs.sql
20260923080435_add_catalog_editorial_write_rpcs.sql
20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
20260923154831_finalize_global_catalog_cutover.sql
```

La migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

completa il cutover del Catalogo globale e il riallineamento del contratto persistente utilizzato da Flutter.

La ricostruzione completa dello schema è stata verificata mediante:

```text
supabase db reset
```

con applicazione da zero dell'intera catena di migration.

Il lint finale dello schema è stato verificato sia localmente sia sul database Supabase remoto, con esito:

```text
No schema errors found
```

Le acceptance S030 delle Tranche 10 e 11 sono state completate con esito positivo utilizzando fixture transazionali successivamente sottoposte a rollback.

La verifica applicativa finale S030 ha inoltre confermato:

```text
flutter analyze
No issues found

flutter test
953 test passati
```

Il numero inferiore di test rispetto alla S029 non rappresenta una regressione funzionale: la S030 ha eliminato modelli, Repository, Write Result e test appartenenti al precedente contratto del Catalogo, sostituendoli con il nuovo modello globale.

Il database deve rimanere privo di dati demo, provvisori o di prova persistenti fino all'avvio della gestione reale dell'orto.

Il popolamento operativo dovrà iniziare soltanto dopo la disponibilità di una baseline verificata e approvata del Catalogo Agronomico.

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

La baseline nominale Database V1 definita nella S017 comprende:

5. `botanical_families`
6. `crops`
7. `crop_varieties`
8. `crop_associations`
9. `agronomic_window_rules`

Nella baseline S017 la relazione agronomica principale era rappresentata concettualmente come:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

`crop_associations` rappresenta, nella baseline nominale, le relazioni agronomiche tra colture.

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

Le regole agronomiche possono rappresentare più periodi annuali e specializzazioni e sono progettate per essere semanticamente versionate.

### Evoluzione implementativa S030

I nomi e le relazioni sopra riportati descrivono la **baseline nominale congelata nella S017** e devono essere conservati come riferimento progettuale e storico.

La Sessione S030 ha successivamente evoluto l'implementazione fisica del Catalogo Agronomico senza modificare retroattivamente la baseline S017.

Nel contratto persistente corrente:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

sostituisce, sul piano implementativo, la precedente catena:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

La S030 introduce inoltre un perimetro più ampio per:

- identità botaniche globali;
- identità agronomiche globali;
- registri dei parametri agronomici;
- vocabolari di contesto;
- fonti e acquisizioni;
- osservazioni;
- alias delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione;
- Resolver;
- Catalog Authority.

`crop_associations` rimane parte della baseline nominale Database V1, ma il relativo backend canonico non è ancora implementato nel nuovo Catalogo globale.

`agronomic_window_rules` rimane anch'essa parte della baseline nominale. Il principio secondo cui `AgronomicWindow` è un risultato calcolato e non una entità persistente `agronomic_windows` rimane invariato.

La corrispondenza tra baseline nominale e implementazione fisica deve quindi essere letta come evoluzione architetturale controllata e non come sostituzione retroattiva della progettazione S017.

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

La Sessione S030 ne ha successivamente riallineato il contratto persistente al nuovo Catalogo Agronomico globale, sostituendo il precedente riferimento alla varietà con il riferimento canonico alla cultivar.

Il contesto corrente di ogni coltivazione viene rappresentato mediante:

```text
id
profile_id
garden_id
season_id
bed_id
crop_id
cultivar_id
```

`crop_id` identifica la coltura canonica.

`cultivar_id` è facoltativo e può essere assente quando la coltivazione viene registrata soltanto a livello di coltura.

Quando `cultivar_id` è valorizzato, la coerenza tra cultivar e coltura è protetta mediante la foreign key composita:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

Il precedente campo:

```text
variety_id
```

appartiene al contratto storico S028 ed è stato rimosso dal modello persistente corrente durante il cutover S030.

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

I valori agronomici persistiti nel Planting costituiscono dati operativi della coltivazione.

Quando derivano da una proposta agronomica o dalla Knowledge canonica, la loro persistenza rappresenta lo snapshot operativo effettivamente confermato per quella coltivazione. Una successiva modifica della Knowledge canonica non deve quindi modificare automaticamente il Planting già registrato.

### Metodi di avvio

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

### Occupazione geometrica

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

### Occupazione temporale

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

### Lifecycle

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

### Sovrapposizioni

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

### Write Path

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
- coerenza tra `crop_id` e l'eventuale `cultivar_id`;
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

Dalla Sessione S030 il Catalogo Agronomico V1 utilizza un'architettura **globale, multisorgente, tracciabile, versionabile, contestualizzabile ed editorialmente controllata**.

Il Catalogo non appartiene a un singolo Profile o Garden.

La separazione fondamentale è:

```text
identità botanica/agronomica
        ≠
dati osservati dalle fonti
        ≠
Knowledge agronomica canonica
        ≠
snapshot operativi del Garden
```

Questa separazione impedisce che:

- una fonte esterna diventi automaticamente verità canonica;
- una modifica editoriale alteri retroattivamente dati operativi già utilizzati;
- la stessa identità botanica venga duplicata per ogni Profile;
- informazioni provenienti da fonti diverse perdano la propria provenienza;
- valori dipendenti dal contesto vengano trattati come proprietà universali della coltura.

### Identità botaniche globali

La tassonomia botanica canonica è rappresentata da:

```text
botanical_taxa
```

I rank previsti sono:

```text
FAMILY
GENUS
SPECIES
VARIETY
CULTIVAR
```

Le identità botaniche sono globali.

La normalizzazione testuale canonica utilizza:

```text
private.normalize_catalog_text(text)
```

e applica criteri coerenti di:

- normalizzazione Unicode;
- trim;
- riduzione degli spazi;
- confronto normalizzato dei testi.

La normalizzazione consente di individuare come equivalenti rappresentazioni testuali che differiscono soltanto per aspetti non semanticamente significativi.

L'identità botanica non deve essere determinata mediante semplici stringhe di presentazione.

Gli UUID costituiscono gli identificativi persistenti delle identità canoniche.

### Identità agronomiche

Le identità agronomiche operative del Catalogo sono rappresentate da:

```text
crops
crop_cultivars
```

La relazione principale è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

`crops` rappresenta le colture agronomiche globali.

`crop_cultivars` rappresenta le cultivar associate alle rispettive colture.

Una cultivar specializza l'identità della coltura senza richiedere la duplicazione della Crop.

La terminologia tecnica corrente utilizza:

```text
cultivar
cultivar_id
CropCultivar
```

Il precedente contratto tecnico:

```text
variety
variety_id
CropVariety
crop_varieties
```

non appartiene più all'implementazione corrente dopo il cutover S030.

Il termine italiano **Varietà** può comunque essere mantenuto nella UI quando appropriato per l'utente.

### Registri dei parametri agronomici

I tipi di informazione agronomica non vengono trattati come un insieme indefinito di campi aggiunti direttamente alle identità.

La S030 introduce un registro dei parametri agronomici che consente di definire in modo controllato le grandezze e le proprietà trattate dal Catalogo.

Questo permette di separare:

```text
che cosa rappresenta il parametro
        ↓
quale valore è stato osservato
        ↓
in quale contesto è valido
        ↓
quale valore è stato approvato e pubblicato
```

Il registro costituisce quindi parte dell'infrastruttura semantica del Catalogo e permette successive estensioni senza trasformare ogni nuova informazione agronomica in una modifica strutturale delle identità `crops` o `crop_cultivars`.

### Contesto agronomico

Un valore agronomico può dipendere dal contesto.

La S030 introduce vocabolari di contesto per evitare di trattare come universali informazioni valide soltanto in determinate condizioni.

Il principio è:

```text
identità
  +
parametro
  +
contesto applicabile
        ↓
informazione agronomica interpretabile
```

Il contesto consente di rappresentare in modo strutturato le condizioni rilevanti per la Knowledge senza incorporarle nel nome della coltura o della cultivar.

Questo principio è particolarmente importante per informazioni che possono dipendere, ad esempio, da condizioni ambientali, tecniche colturali, metodo di avvio o altri fattori descritti dai vocabolari canonici del Catalogo.

### Fonti, acquisizioni e osservazioni

La provenienza dei dati agronomici è esplicita.

Il flusso di ingestion distingue:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
```

Una fonte identifica l'origine dell'informazione.

Un'acquisizione rappresenta l'atto o il processo con cui i dati vengono raccolti da quella fonte.

Un'osservazione rappresenta il dato ottenuto e conserva il collegamento necessario alla propria provenienza.

L'ingestion non equivale ad approvazione.

Il principio fondamentale è:

```text
dato importato
        ≠
dato canonico
```

Uno scraping, un'importazione o un'altra acquisizione esterna produce quindi informazioni candidate da sottoporre al processo editoriale.

Nessuna fonte esterna può sovrascrivere automaticamente il Catalogo approvato.

### Alias delle identità

Le denominazioni provenienti dalle fonti esterne possono differire dalle identità canoniche.

Il Catalogo mantiene pertanto un livello esplicito di alias e riconciliazione delle identità.

Il principio è:

```text
denominazione esterna
        ↓
alias / mapping
        ↓
identità canonica
```

Questo consente di preservare la forma originaria utilizzata dalla fonte senza moltiplicare le identità canoniche.

Un dato non riconciliabile non deve essere forzato artificialmente su un'identità.

Lo stato:

```text
NOT_MAPPABLE
```

è ammesso nei casi editorialmente previsti di:

```text
CONFLICTING
CONTEXTUAL
```

secondo le invarianti introdotte nella S030.

### Workflow editoriale

Il passaggio da dato osservato a Knowledge canonica richiede un workflow editoriale esplicito.

Il flusso concettuale è:

```text
fonte esterna
        ↓
acquisizione
        ↓
osservazione
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione
        ↓
pubblicazione
        ↓
Knowledge agronomica canonica
```

Le operazioni editoriali sono protette server-side.

La revisione non modifica retroattivamente una precedente revisione immutabile.

La catena delle revisioni utilizza:

```text
previous_revision_id
```

per rendere esplicita la relazione tra una revisione e quella che la precede.

Il semantic freeze inizia dal primo artefatto dichiarato immutabile dal workflow.

Le successive correzioni devono quindi produrre nuovi artefatti o revisioni secondo il contratto previsto, anziché alterare retroattivamente quelli congelati.

Il workflow consente inoltre la reintroduzione controllata mediante CREATE di contenuti precedentemente ritirati quando le condizioni previste dal contratto sono soddisfatte.

### Knowledge agronomica canonica

La Knowledge agronomica canonica rappresenta il risultato editoriale approvato.

Non coincide con:

- l'identità della Crop;
- l'identità della cultivar;
- la singola osservazione di una fonte;
- il valore operativo già memorizzato in un Planting.

La relazione concettuale è:

```text
identità canonica
        +
parametro agronomico
        +
contesto
        +
evidenza/provenienza
        +
revisione editoriale
        ↓
Knowledge canonica
```

Questo modello consente di conservare informazioni provenienti da più fonti senza obbligare il sistema a perdere la loro origine o a scegliere automaticamente un valore come verità.

### Pubblicazione

L'approvazione editoriale e la pubblicazione sono concetti distinti.

La pubblicazione determina quale Knowledge approvata è resa disponibile al consumo applicativo secondo il contratto del Catalogo.

Il ritiro di un contenuto non deve distruggere la ricostruibilità storica.

Quando viene eseguito un WITHDRAW, il sistema deve preservare o copiare il contenuto canonico completo necessario alla tracciabilità.

Il Catalogo segue quindi il principio:

```text
revisione
        ↓
approvazione
        ↓
pubblicazione
        ↓
eventuale ritiro tracciato
```

senza modifica retroattiva degli artefatti storici che devono rimanere ricostruibili.

### Resolver

La S030 introduce il Resolver come livello incaricato di determinare la Knowledge applicabile a una richiesta agronomica.

Concettualmente:

```text
identità
  +
parametro richiesto
  +
contesto disponibile
        ↓
Resolver
        ↓
Knowledge applicabile
```

Il Resolver non trasforma automaticamente il risultato in un fatto operativo.

In particolare:

```text
Knowledge risolta
        ≠
modifica automatica del Planting
```

Nel flusso operativo il Resolver potrà proporre valori appropriati, ma l'applicazione non deve modificare automaticamente i dati reali della coltivazione senza conferma dell'utente.

L'integrazione completa del Resolver nei flussi Flutter di pianificazione e creazione delle coltivazioni rimane un incremento successivo alla S030.

### Catalog Authority

Le operazioni sensibili sul Catalogo globale sono governate da:

```text
catalog_authorities
```

Le capability sono separate:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

Questa separazione evita di rappresentare l'autorità sul Catalogo mediante un unico flag indistinto.

Le capability permettono di distinguere:

- gestione delle identità;
- acquisizione dei dati;
- revisione editoriale;
- pubblicazione.

L'applicazione può conoscere le capability dell'utente autenticato mediante:

```text
get_my_catalog_capabilities()
```

L'inizializzazione dell'autorità iniziale utilizza:

```text
claim_initial_catalog_authority()
```

Il claim:

- è esplicito;
- non viene eseguito automaticamente dal client;
- è limitato al proprietario idoneo previsto dal contratto;
- è idempotente;
- non consente di reclamare un'autorità già inizializzata.

### Read model

La lettura applicativa delle identità canoniche utilizza:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

I read model sono configurati con:

```text
security_invoker = true
```

Flutter utilizza rispettivamente:

```text
CropRepository
CropCultivarRepository
```

mentre:

```text
CatalogAuthorityRepository
```

gestisce il contratto applicativo relativo alle capability e al claim esplicito dell'autorità iniziale.

### Relazione con Plantings

Le coltivazioni reali fanno riferimento alle identità canoniche mediante:

```text
plantings.crop_id
plantings.cultivar_id
```

`cultivar_id` è opzionale.

La coerenza tra Crop e cultivar è protetta dalla relazione:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

Una cultivar non può quindi essere associata a un Planting appartenente a una Crop differente.

I valori agronomici utilizzati operativamente da una coltivazione rimangono snapshot del fatto operativo.

Il principio è:

```text
Catalogo corrente
        ↓
proposta / decisione
        ↓
snapshot operativo
```

Una successiva revisione del Catalogo non deve modificare retroattivamente il Planting.

Questo mantiene separati:

- conoscenza agronomica corrente;
- decisione presa in un determinato momento;
- stato reale della coltivazione.

### Relazione con le finestre agronomiche

Il principio già definito dal Database V1 rimane valido:

```text
regole / Knowledge agronomica
        ↓
motore agronomico
        ↓
AgronomicWindow calcolata
```

`AgronomicWindow` rimane un risultato calcolato e non una tabella persistente `agronomic_windows`.

L'evoluzione del Catalogo S030 non modifica questo principio generale.

La determinazione della finestra applicabile rimane responsabilità del dominio agronomico sulla base delle regole e della Knowledge disponibili.

### Associazioni colturali

`crop_associations` appartiene alla baseline nominale Database V1, ma il backend canonico delle associazioni colturali non è stato ancora implementato nel nuovo Catalogo globale S030.

Il motore applicativo delle associazioni rimane disponibile, ma nello stato corrente:

```text
CropAssociationRepository
        ↓
insieme vuoto
```

anziché interrogare una relazione canonica inesistente.

Questa soluzione evita di presentare come persistente un contratto backend non ancora realizzato.

L'implementazione del backend canonico delle associazioni colturali rimane un incremento FUTURE.

### Principio di storicizzazione

Il Catalogo Agronomico V1 segue un principio più forte del precedente semplice modello:

```text
catalogo corrente
        +
revisioni
        +
provenienza
        +
pubblicazioni
        +
snapshot operativi
```

Le modifiche future alla Knowledge corrente non devono modificare retroattivamente:

- osservazioni originali;
- revisioni immutabili;
- pubblicazioni storicamente rilevanti;
- decisioni già assunte;
- valori già confermati dall'utente;
- Plantings e altri fatti operativi.

La ricostruibilità storica e la provenienza dell'informazione prevalgono sulla comodità di sovrascrivere il dato corrente.

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

Quando una decisione dipende da informazioni esterne o da conoscenze che possono cambiare nel tempo, il sistema deve conservare le informazioni necessarie a spiegare e ricostruire il contesto realmente utilizzato.

La ricostruibilità storica non richiede necessariamente la duplicazione completa della fonte originaria.

Il principio generale è:

```text
dato o conoscenza corrente
        ↓
decisione operativa
        ↓
informazione storica sufficiente a ricostruire la decisione
```

### Snapshot del contesto ambientale

Il caso previsto dalla baseline Database V1 per il contesto ambientale è:

```text
EnvironmentContextSnapshot
```

Lo snapshot non costituisce una copia completa dello storico meteorologico.

Serve invece a conservare le informazioni ambientali necessarie a spiegare o ricostruire una decisione o un evento quando il semplice riferimento alla fonte esterna non sarebbe sufficiente.

La storicizzazione ambientale deve quindi essere **selettiva e motivata**, evitando la duplicazione indiscriminata di dati già conservati nelle relative fonti autorevoli.

### Ricostruibilità del Catalogo Agronomico

Dalla S030 il Catalogo Agronomico applica un ulteriore livello di ricostruibilità storica.

Il sistema distingue:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
revisione editoriale
        ↓
pubblicazione
        ↓
utilizzo operativo
```

La provenienza del dato deve rimanere ricostruibile anche quando la Knowledge canonica evolve.

Le revisioni che hanno raggiunto il semantic freeze non devono essere modificate retroattivamente.

La relazione:

```text
previous_revision_id
```

permette di mantenere esplicita la catena tra revisioni successive.

Il ritiro di un contenuto mediante WITHDRAW non deve cancellare le informazioni necessarie alla ricostruzione storica: il contenuto canonico richiesto dal contratto deve essere preservato o copiato nell'artefatto storico appropriato.

### Snapshot operativi

La Knowledge agronomica corrente e i dati operativi del Garden hanno temporalità differenti.

Il principio è:

```text
Knowledge disponibile al momento
        ↓
proposta o decisione
        ↓
conferma dell'utente
        ↓
snapshot operativo
```

Una successiva modifica, revisione o pubblicazione del Catalogo non deve modificare retroattivamente un fatto operativo già registrato.

In particolare, i valori agronomici memorizzati in un `Planting` rimangono snapshot della decisione operativa effettuata in quel momento.

Il Resolver può individuare o proporre Knowledge applicabile, ma non deve trasformare automaticamente una revisione del Catalogo in una modifica dei dati operativi già confermati.

### Principio complessivo

La ricostruibilità storica utilizza quindi meccanismi differenti in funzione del dominio:

- riferimenti alla fonte quando sufficienti;
- snapshot selettivi quando necessari a spiegare una decisione;
- provenienza delle osservazioni per i dati acquisiti;
- catene di revisione per l'evoluzione editoriale;
- pubblicazioni e ritiri tracciati per la Knowledge canonica;
- snapshot operativi per i fatti reali del Garden.

L'obiettivo non è conservare copie indiscriminate di ogni informazione, ma preservare **la quantità minima di stato storico necessaria a ricostruire correttamente fatti, decisioni e conoscenze utilizzate**.

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

Nelle strutture Database V1 già implementate vengono utilizzati identificativi UUID secondo il contratto definito dalle relative migration.

Questo principio si applica anche al Catalogo Agronomico globale introdotto nella S030: identità botaniche, Crop e cultivar devono essere referenziate mediante i rispettivi identificativi canonici e non mediante nomi o altre stringhe di presentazione.

La normalizzazione testuale del Catalogo contribuisce all'identificazione e alla prevenzione dei duplicati semantici, ma non sostituisce l'UUID come identità persistente delle entità.

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

Il principio architetturale generale rimane:

```text
Supabase / PostgreSQL
        ↓
repository e mapping
        ↓
dominio Dart
        ↓
motori decisionali
```

Il database deve garantire:

- integrità;
- ownership;
- autorizzazione;
- atomicità delle operazioni che la richiedono;
- invarianti che devono essere vere indipendentemente dal client.

Flutter deve essere considerato un client non fidato e non può costituire l'unica protezione per invarianti persistenti o operazioni sensibili.

La S030 introduce inoltre, per il Catalogo Agronomico, responsabilità server-side specifiche relative a:

- Catalog Authority;
- ingestion;
- workflow editoriale;
- pubblicazione;
- integrità della Knowledge;
- Resolver.

Il Resolver appartiene al contratto autoritativo della Knowledge e determina quale informazione agronomica canonica sia applicabile sulla base dell'identità, del parametro e del contesto disponibili.

Questo non trasferisce al database l'intera decisione operativa.

Il principio rimane:

```text
Knowledge risolta
        ↓
dominio applicativo
        ↓
proposta / valutazione
        ↓
eventuale conferma dell'utente
        ↓
fatto operativo
```

La logica che combina Knowledge, stato reale dell'orto, obiettivi dell'utente e altri elementi decisionali rimane responsabilità del dominio applicativo, salvo le responsabilità server-side esplicitamente definite per sicurezza, integrità, tracciabilità o atomicità.

Una risposta del Resolver non deve quindi produrre automaticamente una modifica persistente di un `Planting` o di un altro fatto operativo senza il passaggio applicativo previsto dal relativo contratto.

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

## 8.3 Dati Garden-scoped, Profile-owned e globali

Non tutte le entità appartengono allo stesso livello di ownership o di visibilità.

La baseline Database V1 distingue almeno:

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

Dalla Sessione S030 l'implementazione introduce inoltre una terza categoria:

```text
Global
```

utilizzata dal Catalogo Agronomico V1.

Il principio corrente è quindi:

```text
Garden-scoped
        → dati appartenenti a uno specifico Garden

Profile-owned
        → dati appartenenti al Profile ma non a un singolo Garden

Global
        → dati condivisi e non posseduti da un singolo Profile o Garden
```

Le identità canoniche del Catalogo Agronomico, tra cui:

```text
botanical_taxa
crops
crop_cultivars
```

sono globali.

Anche le strutture necessarie alla Knowledge agronomica globale devono essere interpretate secondo il relativo contratto di Catalogo e non come dati privati di uno specifico Garden.

L'introduzione del livello globale non elimina l'ownership applicativa dei dati operativi.

In particolare:

```text
Catalogo Agronomico globale
        ≠
dati operativi globali del Garden
```

Un `Planting`, una Season, un Bed o un altro fatto operativo continua ad appartenere al proprio contesto applicativo anche quando fa riferimento a un'identità agronomica globale.

La relazione concettuale è quindi:

```text
identità agronomica globale
        ↓
riferimento dal dato operativo
        ↓
Profile / Garden proprietario del fatto operativo
```

L'autorità di modifica del Catalogo globale non deriva automaticamente dalla normale ownership di un Profile o Garden.

Le operazioni sensibili del Catalogo sono governate separatamente mediante:

```text
catalog_authorities
```

e dalle relative capability.

Ownership, foreign key, RLS, privilegi SQL e Write Path devono rispettare questa distinzione sia nelle strutture già implementate sia nei successivi incrementi del Database V1.

Il client Flutter non deve dedurre l'autorità di scrittura dalla sola possibilità di leggere un'identità globale.

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

### Evoluzione dei Write Path del Catalogo Agronomico

#### S026 — Write Path storico del Catalogo DB V1

La Sessione S026 ha introdotto il primo Write Path autoritativo del Catalogo DB V1 per:

```text
botanical_families
crops
crop_varieties
```

In quella fase il catalogo era **Profile-owned** e condiviso tra i Gardens dello stesso Profile.

Le nove RPC autoritative erano:

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

Le scritture applicative sulle tre tabelle erano consentite esclusivamente attraverso le RPC previste.

Le scritture dirette:

```text
INSERT
UPDATE
DELETE
```

erano revocate ad `authenticated`.

Le RPC erano definite con:

```text
SECURITY DEFINER
```

e:

```text
search_path = ''
```

Il privilegio `EXECUTE` era concesso ad `authenticated` e revocato ad `anon` e `public`.

Il flusso autoritativo era:

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

Il lease della Profile Write Authority veniva rivalidato dopo eventuali attese sui row lock.

La concorrenza ottimistica utilizzava:

```text
expected_row_version
```

e:

```text
row_version
```

quando previsto dall'operazione.

I parent venivano lockati quando necessario per serializzare correttamente operazioni concorrenti quali:

- creazione di un figlio;
- riattivazione di un figlio;
- disattivazione di un parent;
- cambio della Botanical Family di una Crop.

Le principali regole gerarchiche protette server-side erano:

- una Botanical Family non poteva essere disattivata se conteneva Crop attive;
- una Crop non poteva essere disattivata se conteneva Crop Variety attive;
- una Crop poteva essere creata soltanto sotto una Botanical Family attiva;
- una Crop poteva essere spostata soltanto verso una Botanical Family attiva dello stesso Profile;
- una Crop poteva essere riattivata soltanto se la Botanical Family padre era attiva;
- una Crop Variety poteva essere creata soltanto sotto una Crop attiva;
- una Crop Variety poteva essere riattivata soltanto se la Crop padre era attiva;
- riattivare un parent non riattivava automaticamente i figli;
- i record inattivi rimanevano modificabili;
- `crop_varieties.crop_id` era immutabile dopo la creazione.

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

Questo modello rimane documentato come **stato storico S026**, ma non rappresenta più il contratto corrente del Catalogo dopo la Sessione S030.

#### S030 — Write Path autoritativi del Catalogo Agronomico globale

La Sessione S030 ha sostituito il precedente Catalogo Profile-owned con un'architettura globale dotata di autorità e capability dedicate.

Il principio di sicurezza corrente è:

```text
Supabase Auth
        ↓
identità autenticata
        ↓
Catalog Authority
        ↓
capability richiesta
        ↓
RPC autoritativa
        ↓
validazioni e invarianti server-side
        ↓
scrittura atomica
```

L'autorità sul Catalogo non deriva dalla normale ownership di un Garden o Profile.

La tabella:

```text
catalog_authorities
```

mantiene le capability distinte:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

Questa separazione consente di attribuire soltanto l'autorità necessaria al tipo di operazione richiesta.

Le aree protette introdotte progressivamente dalla S030 comprendono:

```text
gestione delle identità
gestione di registri e contesti
ingestion
workflow editoriale
pubblicazione
Resolver
```

I Write Path sono stati introdotti mediante migration dedicate:

```text
20260922154850_add_catalog_identity_write_rpcs.sql
20260922165844_add_catalog_registry_write_rpcs.sql
20260922175238_add_catalog_ingestion_write_rpcs.sql
20260923080435_add_catalog_editorial_write_rpcs.sql
20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
```

Il cutover finale è completato da:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

#### Authority iniziale

Il client può conoscere le capability disponibili mediante:

```text
get_my_catalog_capabilities()
```

L'inizializzazione della prima Catalog Authority avviene esclusivamente mediante l'azione esplicita:

```text
claim_initial_catalog_authority()
```

Il claim iniziale:

- non viene eseguito automaticamente;
- verifica server-side l'identità autenticata;
- è consentito soltanto al proprietario idoneo previsto dal contratto;
- richiede che l'authority non sia già stata inizializzata;
- è idempotente rispetto allo stato previsto dal contratto;
- non permette di utilizzare il normale client come fonte dell'autorizzazione.

Le funzioni sensibili sono definite secondo il modello di hardening previsto, utilizzando quando richiesto:

```text
SECURITY DEFINER
```

con:

```text
search_path = ''
```

e privilegi di esecuzione espliciti.

Per le funzioni protette non deve essere disponibile un accesso anonimo non previsto.

Il ruolo `authenticated` riceve esclusivamente i privilegi necessari al contratto applicativo.

#### Gestione delle identità

La gestione delle identità globali richiede:

```text
can_manage_identity
```

Il server protegge:

- identità botaniche;
- identità agronomiche;
- relazioni tra Crop e cultivar;
- normalizzazione delle chiavi testuali;
- unicità;
- coerenza delle gerarchie;
- invarianti necessarie al Catalogo globale.

La normalizzazione canonica utilizza:

```text
private.normalize_catalog_text(text)
```

Il client non può sostituire i controlli server-side mediante normalizzazioni eseguite soltanto in Flutter.

#### Registri e contesti

Le operazioni che modificano i registri dei parametri agronomici e i vocabolari di contesto utilizzano Write Path dedicati.

Registri e vocabolari costituiscono parte del contratto semantico del Catalogo e non devono essere modificati mediante scritture client arbitrarie.

Le RPC verificano server-side l'autorità richiesta e le invarianti applicabili.

#### Ingestion

L'ingestion richiede la capability:

```text
can_ingest
```

Il flusso protetto è:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
```

L'acquisizione di un dato non attribuisce al dato lo stato di Knowledge canonica.

Il sistema mantiene quindi la separazione:

```text
dato acquisito
        ≠
dato approvato
        ≠
dato pubblicato
```

Un processo di scraping o importazione non può utilizzare il proprio accesso di ingestion per sovrascrivere automaticamente Knowledge già approvata.

#### Workflow editoriale

Le operazioni di revisione sono protette mediante la capability:

```text
can_review
```

Il workflow editoriale applica server-side le transizioni e le invarianti previste.

La catena delle revisioni utilizza:

```text
previous_revision_id
```

Le revisioni che hanno raggiunto il semantic freeze non devono essere alterate retroattivamente.

Le correzioni devono essere rappresentate mediante il workflow previsto e nuovi artefatti o revisioni quando richiesto dal contratto.

Lo stato:

```text
NOT_MAPPABLE
```

è consentito soltanto nei casi previsti:

```text
CONFLICTING
CONTEXTUAL
```

La reintroduzione controllata mediante CREATE di contenuti precedentemente ritirati è ammessa esclusivamente secondo le condizioni definite dal contratto editoriale.

#### Pubblicazione

La pubblicazione richiede la capability:

```text
can_publish
```

L'approvazione editoriale e la pubblicazione rimangono operazioni concettualmente distinte.

Il server impedisce che il semplice possesso di capability di ingestion o review equivalga automaticamente all'autorità di pubblicazione.

Il ritiro mediante WITHDRAW deve preservare il contenuto canonico completo necessario alla tracciabilità e alla ricostruibilità storica.

La pubblicazione non deve distruggere:

- provenienza;
- osservazioni;
- revisioni;
- catena editoriale;
- informazioni necessarie alla ricostruzione dello stato storico.

#### Resolver

Il Resolver opera sulla Knowledge pubblicata secondo il contratto server-side definito nella S030.

Il principio di sicurezza è:

```text
richiesta
        ↓
Resolver
        ↓
Knowledge applicabile
```

La risposta del Resolver non costituisce autorizzazione a modificare automaticamente un fatto operativo.

In particolare:

```text
risultato del Resolver
        ≠
UPDATE automatico di plantings
```

L'eventuale applicazione di una proposta agronomica a un dato operativo deve passare attraverso il relativo flusso applicativo e il Write Path autoritativo previsto.

#### Read model e client Flutter

Le letture canoniche utilizzate dal client comprendono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

configurati con:

```text
security_invoker = true
```

Il client Flutter utilizza i read model e i Repository previsti dal contratto corrente, ma rimane un **client non fidato**.

La possibilità di leggere un'identità globale non attribuisce automaticamente alcuna capability di modifica del Catalogo.

#### Privilegi e Data API

Le migration devono definire esplicitamente i privilegi necessari alle strutture esposte attraverso la Data API.

La sicurezza del Catalogo non deve dipendere da grant impliciti o da impostazioni esterne non riproducibili.

Per ogni nuova struttura pubblica devono essere valutati e dichiarati esplicitamente:

```text
GRANT
REVOKE
RLS
policy
EXECUTE
```

in funzione del contratto previsto.

L'esposizione di una tabella o funzione attraverso la Data API non equivale all'autorizzazione a modificarne liberamente il contenuto.

#### Stato corrente dei Write Path

Dopo la S030 risultano implementati e verificati Write Path autoritativi per i principali perimetri già sviluppati, tra cui:

```text
gardens
seasons
beds
plantings
Catalogo Agronomico globale
```

`plantings`, introdotta nella S028 e integrata nel lifecycle Flutter nella S029, non costituisce quindi più un incremento futuro.

Il Catalogo Agronomico globale dispone dei Write Path necessari al perimetro S030, mentre rimangono FUTURE:

- UI editoriale/amministrativa completa;
- workflow operativo UI di ingestion/importazione e revisione;
- azione UI definitiva e sicura per `claim_initial_catalog_authority()`;
- integrazione completa del Resolver nei flussi di pianificazione e creazione delle coltivazioni;
- backend canonico delle associazioni colturali;
- ulteriori Write Path delle entità Database V1 non ancora implementate.

I test S030 hanno verificato le operazioni previste mediante acceptance test e fixture transazionali sottoposte a rollback, senza lasciare dati di prova persistenti.

Il principio rimane:

```text
sicurezza applicativa
        +
privilegi SQL
        +
RLS
        +
capability
        +
Write Path autoritativi
        +
invarianti server-side
```

e nessuno di questi livelli deve essere sostituito da controlli affidati esclusivamente al client.

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

RLS, policy, privilegi, vincoli e funzioni di sicurezza non devono essere considerati una fase accessoria successiva alla creazione delle tabelle.

La traduzione e l'evoluzione del Database V1 in SQL devono integrare fin dall'inizio:

```text
schema
+
foreign key
+
invarianti
+
RLS
+
policy
+
GRANT / REVOKE
+
autorizzazione server-side
+
test
```

La migration costituisce quindi non soltanto una modifica strutturale, ma una parte della definizione riproducibile del contratto di sicurezza del database.

### Evoluzione delle verifiche

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

che non aveva rilevato nuovi problemi introdotti dalla sessione, e:

```text
supabase db diff --local
```

che aveva restituito:

```text
No schema changes found
```

Le migration S026 erano state applicate anche al database Supabase remoto e la verifica mediante:

```text
supabase migration list
```

aveva confermato l'allineamento locale/remoto fino a:

```text
20260911091047
```

Questi risultati rimangono parte della cronologia di verifica del Database V1.

### Verifica S030

La Sessione S030 ha applicato lo stesso metodo all'evoluzione completa del Catalogo Agronomico globale.

La catena delle migration è stata ricostruita da zero mediante:

```text
supabase db reset
```

con applicazione corretta dell'intera sequenza fino alla migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

La verifica finale dello schema mediante lint è stata eseguita sia localmente sia sul database Supabase remoto, con esito:

```text
No schema errors found
```

Gli acceptance test delle Tranche 10 e 11 sono stati completati con esito positivo.

Le fixture utilizzate durante le verifiche sono state eseguite in modo controllato e sottoposte a rollback, senza lasciare dati di prova persistenti nel database.

Il cutover finale è stato applicato anche al database Supabase remoto.

La verifica delle migration ha confermato l'allineamento:

```text
locale = 20260923154831
remoto = 20260923154831
```

La S030 ha inoltre consolidato il principio secondo cui le migration devono dichiarare esplicitamente i privilegi necessari alle strutture esposte dal database.

Per ogni nuova struttura pubblica devono quindi essere valutati, secondo il relativo contratto:

```text
RLS
policy
GRANT
REVOKE
EXECUTE
```

L'esistenza fisica di una tabella, view o funzione nello schema `public` non deve essere interpretata come autorizzazione implicita all'accesso o alla modifica.

Questo principio è particolarmente importante per le strutture raggiungibili attraverso la Data API: i privilegi necessari devono essere parte della migration riproducibile e non dipendere da grant impliciti o da configurazioni manuali non documentate.

### Metodo operativo consolidato

Il flusso di verifica rimane:

```text
migration
        ↓
ricostruzione / applicazione controllata
        ↓
verifica struttura
        ↓
verifica RLS e policy
        ↓
verifica GRANT / REVOKE / EXECUTE
        ↓
verifica autorizzazioni server-side
        ↓
test positivi
        ↓
test negativi
        ↓
lint e controlli di coerenza
        ↓
verifica locale / remoto quando prevista
        ↓
incremento verificato
```

Ogni successivo gruppo di migration deve essere verificato anche dal punto di vista della sicurezza prima di essere considerato completato.

Le RPC sicure e atomiche costituiscono parte integrante del modello di protezione delle operazioni sensibili e devono essere verificate con lo stesso metodo prima di essere considerate consolidate.

Lo stesso vale per:

- funzioni `SECURITY DEFINER`;
- capability;
- funzioni di inizializzazione dell'autorità;
- read model;
- Resolver;
- workflow editoriali;
- ulteriori Write Path autoritativi.

Il Database V1 non sarà considerato completato soltanto per la presenza fisica delle entità previste: strutture, relazioni, invarianti, autorizzazioni e percorsi di accesso devono essere implementati e collaudati secondo il contratto previsto per ciascun incremento.

La sicurezza rimane quindi una proprietà della migration e del relativo processo di verifica, non un'aggiunta successiva affidata al client.

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

Dalla Sessione S030 questo principio si applica anche alla struttura canonica del Catalogo Agronomico globale.

La catena delle identità agronomiche correnti comprende:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Le relazioni devono garantire che una Crop e una cultivar facciano riferimento alle identità botaniche e agronomiche compatibili previste dal relativo contratto.

Per i dati operativi, `plantings` utilizza:

```text
crop_id
```

e, quando presente:

```text
cultivar_id
```

La coerenza tra Crop e cultivar non deve essere affidata al solo client.

Il modello corrente protegge la relazione mediante il vincolo composto:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

in modo che una cultivar non possa essere associata operativamente a una Crop diversa da quella a cui appartiene.

Il precedente riferimento:

```text
variety_id
```

non appartiene più al contratto corrente di `plantings`.

L'integrità referenziale deve inoltre preservare la ricostruibilità delle strutture editoriali e della Knowledge agronomica: revisioni, provenienza, pubblicazioni e riferimenti storici non devono essere distrutti mediante operazioni di cancellazione incompatibili con il relativo significato.

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

## 10.10 Regole agronomiche e Knowledge canonica

La baseline nominale Database V1 prevedeva:

```text
agronomic_window_rules
```

come struttura persistente utilizzata per determinare le finestre agronomiche.

La Sessione S030 ha evoluto il modello agronomico introducendo un'architettura più generale basata su:

```text
identità agronomiche
        +
registro dei parametri
        +
contesti
        +
fonti e acquisizioni
        +
osservazioni
        +
workflow editoriale
        +
Knowledge canonica
        +
pubblicazione
        +
Resolver
```

Il principio originario rimane valido: il database deve conservare i dati, le regole e la Knowledge necessari alla determinazione agronomica, non duplicare indiscriminatamente ogni risultato calcolato.

In particolare non deve essere introdotta una tabella persistente:

```text
agronomic_windows
```

soltanto per memorizzare il risultato di una finestra agronomica calcolata.

`AgronomicWindow` rimane quindi un concetto derivato.

La Knowledge agronomica deve poter distinguere, secondo il parametro e il contesto applicabile, gli elementi semanticamente necessari, tra cui:

- identità della coltura;
- eventuale specializzazione per cultivar;
- parametro agronomico;
- contesto applicabile;
- provenienza;
- revisione editoriale;
- stato di pubblicazione;
- versione semanticamente rilevante.

Le osservazioni provenienti dalle fonti non devono diventare automaticamente Knowledge canonica.

Il flusso concettuale rimane:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
revisione editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Resolver
```

Le modifiche che cambiano il significato agronomico non devono compromettere la ricostruibilità delle decisioni storiche.

Per questo motivo la S030 introduce e protegge:

```text
previous_revision_id
```

per la catena esplicita delle revisioni e applica il semantic freeze agli artefatti che hanno raggiunto lo stato previsto dal contratto.

Il ritiro di contenuto pubblicato non deve cancellarne la storia.

La semantica di WITHDRAW deve preservare il contenuto canonico necessario alla tracciabilità e alla ricostruzione dello stato precedente.

Il Resolver determina la Knowledge applicabile in funzione dell'identità, del parametro e del contesto, ma il suo risultato non costituisce automaticamente un nuovo fatto operativo.

Vale quindi l'invariante:

```text
Knowledge risolta
        ≠
modifica automatica del Planting
```

I valori agronomici già registrati su un `Planting` rimangono snapshot operativi del fatto applicato.

Una nuova Knowledge o un diverso risultato del Resolver può produrre una proposta, ma non deve modificare retroattivamente o automaticamente lo stato operativo senza il flusso applicativo e la conferma previsti.

Il backend canonico delle associazioni colturali non è ancora implementato nel perimetro S030 e rimane un incremento FUTURE; non deve quindi essere rappresentato come Knowledge persistente già disponibile.

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

Alla conclusione della Sessione S030 il Database V1 rimane **parzialmente implementato**, ma comprende ormai anche:

- Fondazioni e modello Profile;
- Gardens;
- Seasons;
- Beds e geometria storicizzata;
- Plantings con Write Path autoritativo e lifecycle;
- Catalogo Agronomico globale nel perimetro completato dalla S030.

Tra le strutture operative già presenti rientrano:

```text
Fondazioni
gardens
seasons
beds
bed_geometries
bed_geometry_corrections
plantings
```

Il Catalogo Agronomico corrente non utilizza più come struttura operativa la precedente catena S026:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

Il cutover S030 ha consolidato invece la catena:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

all'interno di un perimetro complessivo di **26 tabelle** dedicate al nuovo Catalogo Agronomico.

Il perimetro S030 comprende strutture relative a:

```text
identità botaniche e agronomiche
+
Catalog Authority
+
registro dei parametri agronomici
+
vocabolari di contesto
+
fonti e acquisizioni
+
osservazioni
+
alias e mapping delle identità
+
workflow editoriale
+
Knowledge canonica
+
pubblicazione
+
Resolver
```

Le precedenti strutture:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

non appartengono più allo schema operativo corrente dopo il cutover finale.

`public.plantings` rimane presente nello schema implementato e utilizza il contratto corrente:

```text
crop_id
+
cultivar_id opzionale
```

con vincolo di coerenza tra cultivar e Crop.

Il precedente:

```text
variety_id
```

non appartiene più al contratto persistente corrente di `plantings`.

L'implementazione del Catalogo S030 non significa tuttavia che l'intera baseline Database V1 sia completata.

Restano ancora da implementare o completare ulteriori entità e funzionalità previste dalla baseline e dagli incrementi FUTURE, tra cui il backend canonico delle associazioni colturali e ulteriori strutture Database V1 non ancora tradotte nello schema operativo.

Devono inoltre essere mantenuti distinti:

```text
struttura database implementata
```

e:

```text
funzionalità applicativa/UI completamente disponibile
```

Una struttura può essere già implementata e protetta nel database senza che tutte le relative schermate amministrative o operative siano già disponibili nel client Flutter.

È il caso, dopo S030, di alcune funzionalità del Catalogo Agronomico globale, per le quali rimangono FUTURE, tra l'altro:

- UI editoriale e amministrativa completa;
- flusso operativo UI di ingestion/importazione e revisione;
- azione UI definitiva e sicura per `claim_initial_catalog_authority()`;
- integrazione completa del Resolver nei flussi di pianificazione e creazione delle coltivazioni;
- backend canonico delle associazioni colturali.

La distinzione tra:

```text
baseline progettuale
stato fisicamente implementato
integrazione applicativa disponibile
funzionalità FUTURE
```

deve continuare a essere mantenuta esplicita durante ogni incremento successivo.

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
- S026 ha implementato il primo Catalogo DB V1 Profile-owned e i relativi nove Write Path autoritativi;
- S027 ha completato l'integrazione Flutter di quel Catalogo V1;
- S028 ha implementato il modello autoritativo di `plantings`, il relativo Write Path, il lifecycle server-side e l'integrazione Flutter necessaria alla creazione e modifica delle coltivazioni;
- S029 ha completato il livello applicativo del lifecycle delle coltivazioni utilizzando il contratto persistente S028, senza introdurre nuove migration;
- S030 ha trasformato il precedente Catalogo DB V1 nel nuovo Catalogo Agronomico globale, multisorgente, tracciabile, versionabile, contestualizzabile ed editorialmente controllato.

### Catena storica fino a S029

La sequenza delle migration consolidate prima della S030 comprende:

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

Il Catalogo S026 disponeva storicamente delle RPC:

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

Queste RPC appartengono al contratto storico del Catalogo Profile-owned S026 e non devono essere interpretate come il Write Path corrente del Catalogo globale post-S030.

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

La Sessione S029 ha completato l'uso applicativo del lifecycle di `plantings` senza modificare schema, migration, RPC, RLS o contratto persistente.

### S030 — evoluzione incrementale del Catalogo Agronomico

La S030 non è stata implementata come un unico cutover monolitico.

Lo sviluppo è stato suddiviso in **11 tranche tecniche**, ciascuna costruita sulle dipendenze consolidate dalla precedente:

```text
1. Authority e identità globali
        ↓
2. Registro dei parametri agronomici
        ↓
3. Vocabolari di contesto
        ↓
4. Fonti, acquisizioni e osservazioni
        ↓
5. Alias delle identità agronomiche
        ↓
6. Workflow editoriale
        ↓
7. Knowledge agronomica canonica
        ↓
8. Hardening dell'integrità
        ↓
9. Write Path autoritativi
        ↓
10. Pubblicazione + Resolver
        ↓
11. Cutover globale finale DB + Flutter
```

Le migration principali introdotte dalla S030 sono:

```text
20260920192606_add_global_catalog_identity.sql
20260920200852_add_agronomic_parameter_registry.sql
20260920203021_add_agronomic_context_vocabularies.sql
20260921124219_add_agronomic_sources_and_observations.sql
20260921142750_add_agronomic_identity_aliases.sql
20260921145956_add_agronomic_editorial_workflow.sql
20260922082448_add_canonical_agronomic_knowledge.sql
20260922091737_harden_agronomic_catalog_integrity.sql
20260922154850_add_catalog_identity_write_rpcs.sql
20260922165844_add_catalog_registry_write_rpcs.sql
20260922175238_add_catalog_ingestion_write_rpcs.sql
20260923080435_add_catalog_editorial_write_rpcs.sql
20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
20260923154831_finalize_global_catalog_cutover.sql
```

Le 11 tranche non corrispondono necessariamente a una singola migration ciascuna: alcune tranche hanno richiesto più migration coerenti per separare struttura, hardening e Write Path.

Il cutover finale ha consolidato la catena corrente:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

e ha rimosso dallo schema operativo finale:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Il contratto di `plantings` è stato conseguentemente riallineato da:

```text
crop_id + variety_id
```

a:

```text
crop_id + cultivar_id opzionale
```

con protezione referenziale della coerenza Crop/cultivar.

La S030 ha inoltre introdotto in modo incrementale:

- Catalog Authority globale;
- capability separate per identity, ingestion, review e publish;
- normalizzazione canonica delle identità;
- registro dei parametri agronomici;
- vocabolari di contesto;
- provenienza mediante fonti, acquisizioni e osservazioni;
- alias e mapping delle identità;
- workflow editoriale;
- catena delle revisioni;
- Knowledge canonica;
- hardening delle invarianti;
- Write Path autoritativi;
- pubblicazione;
- Resolver;
- read model canonici;
- adattamento Flutter al nuovo contratto globale.

La strategia incrementale ha consentito di verificare progressivamente le dipendenze prima del cutover finale, anziché sostituire il vecchio Catalogo all'inizio della sessione.

Il database è stato infine ricostruito da zero mediante:

```text
supabase db reset
```

verificando che l'intera catena delle migration conducesse correttamente allo schema finale.

### Incrementi successivi

Il completamento del perimetro tecnico S030 non equivale al completamento dell'intero Database V1.

Rimangono incrementi successivi, tra gli altri:

- backend canonico delle associazioni colturali;
- ulteriori entità della baseline non ancora implementate;
- operazioni amministrative protette ancora mancanti;
- integrazioni applicative FUTURE collegate al Catalogo e al Resolver.

Il precedente riferimento nominale a:

```text
agronomic_window_rules
```

rimane parte della storia e della baseline progettuale, ma l'architettura S030 ha introdotto un modello di Knowledge agronomica più generale. Non deve quindi essere descritto come se fosse già il backend canonico corrente delle finestre agronomiche.

L'implementazione deve continuare a procedere per blocchi coerenti, verificabili e tracciabili, senza trasformare la baseline completa in una migration monolitica.

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
- privilegi;
- dipendenze applicative;
- invarianti da proteggere.

### Evoluzione S019–S029

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

Durante l'analisi era emerso che `plantings` dipendeva da un catalogo agronomico operativo non ancora disponibile nel Database V1 implementato.

Era stato quindi approvato il percorso:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
        ↓
plantings
```

La S026 aveva completato i primi tre livelli lato PostgreSQL/Supabase.

La Sessione S027 aveva successivamente completato l'integrazione Flutter dei medesimi livelli mediante:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

e i relativi Repository.

Alla conclusione della S027 lo stato era quindi:

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

In quel momento `plantings` costituiva ancora un incremento successivo.

La Sessione S028 ha completato tale dipendenza introducendo:

```text
Catalogo DB V1
        ↓
plantings
        ↓
Write Path plantings
        ↓
integrazione Flutter
```

La Sessione S029 ha quindi completato il livello applicativo del lifecycle delle coltivazioni utilizzando il contratto persistente già consolidato nella S028.

La precedente sequenza S026–S029 rimane una ricostruzione storica dell'evoluzione del progetto e non deve essere interpretata come descrizione del Catalogo corrente post-S030.

### Dipendenze del Catalogo Agronomico S030

La Sessione S030 ha applicato lo stesso principio a una trasformazione architetturale più ampia.

Il nuovo Catalogo Agronomico non poteva essere costruito partendo direttamente dalla pubblicazione della Knowledge o dal Resolver.

È stato necessario introdurre progressivamente le strutture dalle quali tali livelli dipendono.

La sequenza concettuale è:

```text
Catalog Authority
+
identità globali
        ↓
registro dei parametri agronomici
        ↓
vocabolari di contesto
        ↓
fonti e acquisizioni
        ↓
osservazioni
        ↓
alias e mapping delle identità
        ↓
workflow editoriale
        ↓
Knowledge agronomica canonica
        ↓
hardening dell'integrità
        ↓
Write Path autoritativi
        ↓
pubblicazione
        ↓
Resolver
        ↓
cutover finale DB + Flutter
```

L'ordine non è casuale.

Le osservazioni richiedono identità, fonti e contesti sufficientemente definiti.

Il workflow editoriale richiede dati candidati e strutture sulle quali operare.

La Knowledge canonica richiede che identità, parametri, contesti e provenienza siano già rappresentabili.

La pubblicazione richiede un modello editoriale e una Knowledge già protetti dalle relative invarianti.

Il Resolver richiede Knowledge pubblicabile e un contratto sufficientemente stabile per determinare quale contenuto sia applicabile.

Il cutover finale può avvenire soltanto dopo che il nuovo modello è in grado di sostituire il precedente senza lasciare riferimenti operativi incoerenti.

### Dipendenze del cutover finale

La Tranche 11 ha quindi riallineato le dipendenze operative alla catena canonica:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
        ↓
plantings
```

`plantings` mantiene:

```text
crop_id
```

e può utilizzare:

```text
cultivar_id
```

quando è presente una cultivar specifica.

La relazione composta tra Crop e cultivar impedisce che il riferimento operativo utilizzi una cultivar appartenente a una Crop diversa.

Le precedenti dipendenze operative verso:

```text
botanical_families
crop_varieties
variety_id
```

sono state eliminate dal contratto corrente mediante il cutover S030.

La UI amministrativa del Catalogo, il workflow operativo di aggiornamento delle fonti e l'integrazione completa del Resolver costituiscono livelli applicativi successivi e non devono essere confusi con le dipendenze persistenti già implementate.

Per gli incrementi successivi l'ordine SQL deve continuare a essere determinato dalle dipendenze effettive tra:

```text
foreign key
+
vincoli
+
helper autorizzativi
+
RLS e policy
+
GRANT / REVOKE
+
funzioni server-side
+
capability
+
contratto applicativo
```

Una struttura non deve essere introdotta soltanto perché prevista dalla baseline: deve essere collocata nell'incremento in cui le sue dipendenze possono essere implementate, protette e verificate in modo coerente.

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
GRANT / REVOKE
+
test
```

Non deve essere rimandata sistematicamente a una fase finale l'introduzione della sicurezza.

Una tabella esposta senza le protezioni richieste non rappresenta una implementazione completa del Database V1.

### Applicazione storica del principio

La Sessione S019 ha applicato concretamente questo criterio alle Fondazioni mediante:

- schema `private`;
- helper autorizzativi;
- trigger metadata;
- attivazione della Row Level Security;
- definizione di **13 policy RLS**;
- test manuali positivi;
- test manuali negativi;
- verifica dei tentativi di accesso, modifica ed eliminazione non autorizzati.

La Sessione S026 ha applicato lo stesso principio alle tre tabelle dell'allora Catalogo DB V1:

```text
botanical_families
crops
crop_varieties
```

Per tali strutture erano stati introdotti e verificati:

- vincoli;
- indici;
- trigger metadata;
- RLS;
- privilegi;
- RPC autoritative;
- concorrenza ottimistica;
- validazioni server-side;
- test positivi e negativi.

Nel contratto S026 il ruolo `authenticated` disponeva della lettura regolata da RLS ma non dei privilegi diretti di:

```text
INSERT
UPDATE
DELETE
```

Le scritture applicative avvenivano esclusivamente tramite le RPC autorizzate.

Questo modello rimane parte della storia implementativa del progetto, ma non rappresenta più il contratto corrente del Catalogo Agronomico dopo il cutover S030.

### Applicazione al Catalogo Agronomico S030

La Sessione S030 ha esteso il principio:

```text
schema + sicurezza
```

all'intero nuovo Catalogo Agronomico globale.

La sicurezza non dipende più dall'ownership Profile-owned del precedente Catalogo, ma da una **Catalog Authority globale** con capability distinte.

Le capability implementate comprendono:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

Le operazioni sensibili devono quindi verificare lato server non soltanto l'identità autenticata, ma anche la capability richiesta per l'operazione.

Il principio corrente è:

```text
utente autenticato
        ↓
Catalog Authority
        ↓
capability richiesta
        ↓
RPC autoritativa
        ↓
validazione server-side
        ↓
invarianti
        ↓
scrittura atomica
```

La presenza di accesso in lettura a una struttura del Catalogo non implica autorità di modifica.

Il client Flutter deve continuare a essere considerato non affidabile ai fini autorizzativi.

### Funzioni e privilegi

Le funzioni sensibili `SECURITY DEFINER` devono mantenere un contratto esplicito e controllato.

Nel perimetro S030 sono stati adottati, dove previsti:

- `SECURITY DEFINER`;
- `search_path` vuoto;
- riferimenti espliciti agli oggetti necessari;
- revoca dei privilegi non necessari;
- concessione esplicita di `EXECUTE` ai ruoli previsti;
- nessun `EXECUTE` per `anon` sulle funzioni autoritative;
- autorizzazione server-side indipendente dal client.

Questo principio si applica anche alle funzioni di inizializzazione e interrogazione della Catalog Authority, tra cui:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

L'inizializzazione della Catalog Authority è esplicita e non automatica.

`claim_initial_catalog_authority()` deve rispettare le invarianti definite dal contratto S030, tra cui l'idoneità dell'unico owner previsto, l'idempotenza e l'impossibilità di riappropriarsi di una authority già inizializzata.

### Lettura e read model

I read model canonici:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

sono configurati con:

```text
security_invoker = true
```

in modo che la lettura continui a rispettare il contesto di sicurezza dell'utente chiamante invece di acquisire implicitamente privilegi del proprietario della view.

Anche i privilegi necessari all'accesso tramite Data API devono essere espliciti e coerenti con RLS, policy e contratto applicativo.

La presenza di un oggetto nello schema `public` non deve essere interpretata come autorizzazione implicita all'accesso o alla modifica.

### Regola consolidata

Il metodo consolidato diventa quindi:

```text
struttura persistente
        +
integrità referenziale
        +
ownership oppure authority
        +
RLS e policy
        +
GRANT / REVOKE
        +
Write Path autoritativo quando necessario
        +
capability quando prevista
        +
test positivi
        +
test negativi
        =
incremento verificato
```

La sicurezza deve essere progettata, implementata e verificata nello stesso incremento che introduce o modifica la struttura persistente interessata.

Questo principio deve essere mantenuto anche nelle migration future, comprese quelle che introdurranno nuove tabelle nello schema `public` o nuovi Write Path server-side.

## 11.6 Migrazione dei dati esistenti

Quando una nuova struttura sostituisce o specializza dati già presenti nel database operativo o nel codice legacy, deve essere definita esplicitamente la strategia di migrazione.

Prima di modificare o rimuovere una struttura esistente devono essere verificati:

- dati realmente presenti;
- utilizzo da parte del codice Flutter;
- Repository interessati;
- foreign key esistenti;
- policy RLS esistenti;
- privilegi e Write Path;
- compatibilità con il nuovo contratto;
- possibilità di trasformare i dati senza perdita informativa.

La migrazione deve privilegiare la conservazione dei dati validi già presenti.

Non devono essere cancellati dati esistenti soltanto per semplificare l'adozione della nuova struttura.

### Evoluzione storica S026–S029

La Sessione S026 aveva mantenuto separato il nuovo Catalogo DB V1 dai componenti Flutter legacy.

La Sessione S027 aveva eseguito il primo riallineamento applicativo esplicito tra il contratto legacy e il Catalogo V1.

In particolare:

- `BotanicalFamily` era stato introdotto come modello dedicato;
- `Crop` era stato riallineato al contratto V1;
- `CropVariety` era stato riallineato al contratto V1;
- gli identificativi del catalogo erano rappresentati come UUID `String`;
- `CropVariety.toMap()` era stato rimosso;
- i Repository utilizzavano letture RLS e scritture RPC-only.

In quella fase erano stati mantenuti temporaneamente alcuni alias legacy:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

per non interrompere flussi applicativi ancora dipendenti dalle rappresentazioni precedenti.

Tali alias non costituivano il nuovo contratto persistente e non dovevano essere utilizzati per introdurre nuove dipendenze.

Le Sessioni S028 e S029 hanno successivamente riallineato il dominio `plantings` e il relativo lifecycle al contratto allora vigente, completando gli incrementi applicativi previsti per quella fase.

Questa sequenza rimane parte della storia della migrazione applicativa e non descrive il contratto corrente post-S030.

### Cutover S030

La Sessione S030 ha richiesto una nuova migrazione strutturale e applicativa perché il Catalogo è passato dal precedente modello Profile-owned al modello globale.

La catena precedente:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

è stata sostituita dalla catena canonica:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Durante la costruzione incrementale della S030 è stata utilizzata anche la struttura temporanea:

```text
catalog_crops_s030
```

necessaria a preparare il nuovo modello prima del cutover finale.

La migration:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

ha completato il passaggio allo schema operativo definitivo della S030.

Dopo il cutover non appartengono più allo schema operativo corrente:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

mentre le identità canoniche correnti sono rappresentate da:

```text
botanical_taxa
crops
crop_cultivars
```

### Migrazione di plantings

Anche il contratto persistente di `plantings` è stato riallineato.

Il precedente riferimento:

```text
variety_id
```

è stato sostituito da:

```text
cultivar_id
```

opzionale.

Il contratto corrente utilizza quindi:

```text
crop_id
+
cultivar_id opzionale
```

con vincolo composto:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

in modo da impedire l'associazione di un Planting a una cultivar appartenente a una Crop diversa.

### Migrazione Flutter

Il cutover S030 ha richiesto anche il riallineamento del codice Flutter.

Il precedente modello tecnico:

```text
CropVariety
```

è stato sostituito da:

```text
CropCultivar
```

e il contratto applicativo utilizza ora:

```text
cultivarId
cultivar_id
CropCultivar
```

al posto di:

```text
varietyId
variety_id
CropVariety
crop_variety
inactive_variety
```

La terminologia italiana **Varietà** può continuare a essere utilizzata nella UI quando appropriato, senza modificare il contratto tecnico basato sul concetto di cultivar.

Il livello Repository è stato conseguentemente riallineato:

```text
CropRepository
        ↓
crop_catalog_read

CropCultivarRepository
        ↓
crop_cultivar_catalog_read
```

Il precedente flusso di scrittura personale del Catalogo non rappresenta più il contratto corrente.

Le operazioni autoritative del Catalogo globale dipendono ora dalla Catalog Authority e dalle capability previste dal modello S030.

### Conservazione dei dati e stato reale del database

La strategia di migrazione deve sempre distinguere tra:

```text
trasformazione dello schema
```

e:

```text
migrazione di dati reali esistenti
```

Alla conclusione della S030 il progetto non ha ancora avviato il popolamento operativo reale del Catalogo e dell'orto.

Il database deve rimanere privo di dati demo, provvisori o di esempio fino all'avvio della fase operativa reale.

Di conseguenza non devono essere introdotti seed artificiali soltanto per simulare una migrazione di contenuti che non esistono realmente.

Quando inizierà il popolamento operativo, la sequenza prevista è:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
caricamento Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle Beds reali
        ↓
apertura Season reale
        ↓
registrazione Plantings reali
```

I dati provenienti da fonti esterne dovranno inoltre seguire il flusso:

```text
fonte esterna
        ↓
ingestion
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione
        ↓
Knowledge / Catalogo pubblicato
```

e non potranno essere trasformati automaticamente in dati operativi o sovrascrivere contenuti approvati.

### Regola per le migrazioni future

Ogni futura sostituzione strutturale deve quindi verificare separatamente:

```text
schema da trasformare
+
dati reali eventualmente presenti
+
dipendenze applicative
+
integrità referenziale
+
sicurezza e privilegi
+
Write Path
+
compatibilità Flutter
+
strategia di rollback o recupero
```

La migrazione deve rimanere esplicita, incrementale, verificabile e tracciabile.

Non deve essere assunta equivalenza automatica tra strutture legacy e nuovi contratti, né devono essere creati dati artificiali per mascherare l'assenza di dati reali da migrare.

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

### Evoluzione S026–S027

La sequenza S026–S027 costituisce un primo esempio concreto di questo principio.

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

Il modello applicativo era allora basato sulla catena:

```text
BotanicalFamily
        ↓
Crop
        ↓
CropVariety
```

coerente con il contratto persistente del Catalogo Profile-owned introdotto nella S026.

Questa configurazione rimane parte della storia del progetto, ma non rappresenta più il contratto corrente dopo la S030.

### Evoluzione S028–S029

La stessa separazione è stata applicata al dominio delle coltivazioni tra S028 e S029.

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

L'integrazione S028 comprendeva:

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

La verifica finale della S028 aveva confermato:

```text
flutter analyze
No issues found!
```

```text
flutter test
997 tests passed
```

Erano inoltre risultati positivi:

```text
supabase db reset
success
```

e:

```text
supabase db lint --local
No schema errors found
```

La Sessione S029 ha completato il livello applicativo del lifecycle senza introdurre modifiche a:

```text
schema
migration
RPC
RLS
contratto persistente
```

La UI utilizza il contratto S028 consolidato secondo il flusso:

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

Dalla S029 risultano disponibili lato UI:

- transizione `sown → growing`;
- transizione `growing → harvest_ready`;
- transizione `harvest_ready → harvested`;
- transizione `harvested → finished`;
- transizione verso `removed` dagli stati consentiti;
- richiesta esplicita di `end_date` per `finished` e `removed`;
- mantenimento di `end_date = null` nelle transizioni intermedie;
- refresh autoritativo dei dati in caso di `version_conflict`;
- refresh autoritativo dei dati in caso di `invalid_transition`;
- informazione esplicita che `harvested` non libera ancora l'aiuola.

Alla conclusione della S029 lo stato applicativo era quindi:

```text
integrazione dati Catalogo V1
        ✓

Write Path plantings
        ✓

creazione/modifica plantings lato UI
        ✓

UI lifecycle plantings
        ✓

end_date terminale esplicita lato UI
        ✓

refresh version_conflict / invalid_transition
        ✓

UI amministrativa Catalogo V1
        ✗

selezione varietà nel flusso plantings
        ✗
```

Questa fotografia deve essere letta come stato storico alla conclusione della S029.

### Cutover applicativo S030

La Sessione S030 ha modificato il contratto del Catalogo e ha quindi richiesto un riallineamento esplicito del codice Flutter.

La nuova architettura non utilizza più come contratto tecnico corrente:

```text
BotanicalFamily
CropVariety
CropVarietyRepository
varietyId
variety_id
crop_variety
inactive_variety
```

Il contratto corrente utilizza invece:

```text
Crop
CropCultivar
CropCultivarRepository
cultivarId
cultivar_id
```

La terminologia italiana **Varietà** può continuare a essere utilizzata nella UI quando appropriato, senza reintrodurre il precedente contratto tecnico `CropVariety`.

### Repository del Catalogo dopo S030

`CropRepository` è stato riallineato al read model canonico:

```text
CropRepository
        ↓
crop_catalog_read
```

e non espone più le precedenti scritture personali del Catalogo.

`CropCultivarRepository` utilizza:

```text
CropCultivarRepository
        ↓
crop_cultivar_catalog_read
```

Per la gestione delle capability del Catalogo è stato introdotto:

```text
CatalogAuthorityRepository
```

insieme al modello:

```text
CatalogCapabilities
```

Il Repository consente di interrogare le capability dell'utente autenticato e di utilizzare l'operazione esplicita di inizializzazione della Catalog Authority prevista dal backend.

Il claim iniziale non deve essere eseguito automaticamente dal client.

### Riallineamento del dominio Planting

La catena applicativa delle coltivazioni è stata riallineata dal precedente riferimento alla varietà al nuovo riferimento alla cultivar.

Il contratto tecnico corrente utilizza:

```text
cropId
+
cultivarId opzionale
```

in coerenza con il contratto persistente:

```text
crop_id
+
cultivar_id opzionale
```

Il precedente:

```text
varietyId
```

non appartiene più al contratto corrente.

I valori agronomici memorizzati nel Planting continuano a rappresentare snapshot operativi.

L'introduzione della Knowledge canonica e del Resolver non autorizza quindi il client a modificare automaticamente un Planting già esistente.

Il principio rimane:

```text
Knowledge canonica
        ↓
Resolver
        ↓
proposta applicativa
        ↓
valutazione / conferma utente
        ↓
Write Path autoritativo
        ↓
dato operativo persistente
```

### Motori agronomici

Anche i consumer applicativi del Catalogo devono essere compatibili con le nuove identità canoniche.

Il motore di rotazione confronta la famiglia botanica tramite UUID canonico.

Il nome della famiglia rimane un dato di presentazione e non deve sostituire l'identità persistente nei confronti applicativi.

Per le consociazioni il motore applicativo rimane disponibile, ma il backend canonico di `crop_associations` non è ancora implementato.

Di conseguenza `CropAssociationRepository` restituisce attualmente insiemi vuoti invece di interrogare una relazione persistente inesistente.

Questo comportamento evita di simulare nel client una struttura backend che non è ancora stata implementata.

### Rimozione del contratto legacy

La compatibilità applicativa non deve essere ottenuta mantenendo indefinitamente alias o modelli legacy.

Con il cutover S030 sono stati rimossi i componenti non più appartenenti al contratto corrente, compresi:

- modello personale della famiglia botanica e relativo Repository;
- result type di scrittura della famiglia botanica;
- `CropVariety`;
- `CropVarietyRepository`;
- result type di scrittura delle varietà;
- vecchi result type di scrittura personale delle Crop;
- pagina personale legacy di aggiunta varietà;
- test riferiti esclusivamente ai componenti rimossi.

L'obiettivo non è mantenere due contratti paralleli, ma completare ogni cutover in modo esplicito e verificato.

### Verifica finale S030

Dopo il riallineamento DB + Flutter sono stati verificati:

```text
dart format lib test
Formatted 174 files
```

```text
flutter analyze
No issues found!
```

e la suite Flutter completa:

```text
953 tests passed
```

Il database è stato inoltre ricostruito dalla catena completa delle migration e verificato mediante:

```text
supabase db reset
```

con esito positivo.

Il lint finale dello schema è risultato:

```text
No schema errors found
```

sia localmente sia sul database Supabase remoto.

Le acceptance della Tranche 10 e della Tranche 11 sono risultate positive e le fixture utilizzate sono state eliminate mediante rollback.

### Stato applicativo dopo S030

Alla conclusione tecnica della S030 risultano quindi distinti:

```text
Catalogo globale DB
        ✓

identità canoniche globali
        ✓

Catalog Authority e capability
        ✓

ingestion backend
        ✓

workflow editoriale backend
        ✓

Knowledge canonica
        ✓

pubblicazione backend
        ✓

Resolver backend
        ✓

read model canonici
        ✓

integrazione Flutter del contratto Catalogo corrente
        ✓

riallineamento Planting da variety a cultivar
        ✓

UI editoriale/amministrativa completa del Catalogo
        ✗

UI operativa completa per ingestion/revisione
        ✗

azione UI definitiva per claim iniziale Catalog Authority
        ✗

integrazione completa del Resolver nel flusso di pianificazione/creazione Planting
        ✗

backend canonico delle associazioni colturali
        ✗
```

La presenza di un backend implementato non deve quindi essere confusa con la disponibilità di una UI completa per tutte le sue funzioni.

La futura evoluzione applicativa deve continuare a rispettare il contratto persistente corrente e non deve reintrodurre dipendenze verso le strutture eliminate dal cutover S030.

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

Il Repository deve inoltre costituire il confine applicativo verso le RPC autoritative quando un'operazione non consente scritture dirette.

Le invarianti autoritative rimangono responsabilità del database.

Le eventuali validazioni Flutter servono a migliorare l'esperienza utente, ma non sostituiscono i controlli server-side.

### Evoluzione storica del Catalogo

Nel Catalogo DB V1 introdotto dalla S026 e integrato in Flutter nella S027 il modello era:

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

I Repository del Catalogo erano:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

Questa configurazione descrive il contratto storico del Catalogo Profile-owned S026/S027 e non il contratto corrente dopo il cutover S030.

### PlantingRepository

Dalla Sessione S028 lo stesso principio di separazione della persistenza viene applicato anche a:

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

Il flusso applicativo rimane:

```text
UI / dominio Dart
        ↓
PlantingRepository
        ↓
RPC autoritativa
        ↓
PostgreSQL
```

Nei Repository RPC-only non devono essere introdotte scritture mediante:

```text
.insert()
.update()
.delete()
.upsert()
```

quando il contratto dell'entità prevede esclusivamente il Write Path autoritativo.

Il mapping delle risposte RPC deve rimanere:

- esplicito;
- tipizzato;
- fail-closed;
- coerente con gli status effettivamente restituiti dal server.

### Repository del Catalogo dopo S030

Il cutover S030 ha modificato il contratto concreto dei Repository del Catalogo.

Il livello di lettura corrente utilizza i read model canonici:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

configurati con:

```text
security_invoker = true
```

Il flusso delle Crop è quindi:

```text
crop_catalog_read
        ↓
CropRepository
        ↓
Crop
        ↓
dominio applicativo
```

Il flusso delle cultivar è:

```text
crop_cultivar_catalog_read
        ↓
CropCultivarRepository
        ↓
CropCultivar
        ↓
dominio applicativo
```

Il precedente:

```text
CropVarietyRepository
```

non appartiene più al contratto corrente.

`CropRepository` non espone più il precedente Write Path personale del Catalogo.

Le scritture autoritative del Catalogo globale sono separate dalle normali letture applicative e dipendono dalla Catalog Authority e dalle capability previste dal backend.

### CatalogAuthorityRepository

La S030 ha introdotto:

```text
CatalogAuthorityRepository
```

e:

```text
CatalogCapabilities
```

come confine applicativo per le operazioni relative all'autorità del Catalogo.

Il Repository può interrogare le capability dell'utente autenticato mediante il contratto server-side previsto da:

```text
get_my_catalog_capabilities()
```

e può utilizzare, quando esplicitamente richiesto dal flusso applicativo autorizzato:

```text
claim_initial_catalog_authority()
```

Il claim iniziale della Catalog Authority non deve essere eseguito automaticamente.

Il Repository non deve trasformare la semplice autenticazione o la possibilità di leggere il Catalogo in autorità di scrittura.

Il principio è:

```text
utente autenticato
        ↓
CatalogAuthorityRepository
        ↓
RPC autoritativa
        ↓
Catalog Authority
        ↓
capability
        ↓
operazione consentita oppure rifiutata
```

Le capability rimangono determinate e verificate lato server.

### Repository e Write Path del Catalogo globale

Per le operazioni autoritative del Catalogo il Repository applicativo deve essere soltanto il punto di accesso al contratto server-side.

Non deve replicare nel client le regole relative a:

- gestione delle identità;
- ingestion;
- review;
- publish;
- transizioni editoriali;
- catene di revisione;
- semantic freeze;
- pubblicazione;
- WITHDRAW;
- invarianti della Knowledge.

Il modello rimane:

```text
UI / dominio
        ↓
Repository
        ↓
RPC autoritativa
        ↓
verifica Catalog Authority
        ↓
verifica capability
        ↓
invarianti server-side
        ↓
PostgreSQL
```

Le validazioni applicative possono anticipare errori evidenti, ma il client Flutter non costituisce la fonte autoritativa delle regole.

### Repository e Resolver

La S030 ha inoltre introdotto il Resolver server-side della Knowledge agronomica.

Questo modifica il confine tra persistenza e logica applicativa rispetto alla precedente previsione basata esclusivamente su:

```text
agronomic_window_rules
```

Il Resolver può determinare la Knowledge canonica applicabile in funzione delle identità, del parametro e del contesto previsti dal contratto.

Il risultato del Resolver non costituisce tuttavia automaticamente un fatto operativo.

Il flusso corretto rimane:

```text
Knowledge canonica
        ↓
Resolver
        ↓
Repository / dominio applicativo
        ↓
proposta o valutazione
        ↓
conferma utente quando richiesta
        ↓
Write Path autoritativo
        ↓
dato operativo
```

Il Repository non deve quindi utilizzare il risultato del Resolver per modificare automaticamente un Planting persistente.

I valori agronomici già memorizzati nel Planting continuano a rappresentare snapshot operativi.

### Motori applicativi

L'introduzione del Resolver server-side non implica che tutta la logica agronomica debba essere trasferita indiscriminatamente nel database.

Devono essere mantenute distinte:

```text
integrità e selezione autoritativa della Knowledge
```

e:

```text
valutazione, proposta e comportamento applicativo
```

Il database deve proteggere identità, provenienza, revisioni, pubblicazione, contesto e invarianti della Knowledge.

Gli engine e i servizi Dart possono continuare a utilizzare tali dati per produrre valutazioni e proposte applicative quando la relativa responsabilità appartiene al dominio client.

Per le rotazioni, ad esempio, il confronto dell'identità botanica deve utilizzare l'UUID canonico della famiglia, mentre il nome rimane destinato alla presentazione.

Per le consociazioni il backend canonico non è ancora implementato.

Il relativo Repository non deve quindi simulare una persistenza inesistente: `CropAssociationRepository` restituisce attualmente insiemi vuoti, mantenendo disponibile il motore applicativo senza inventare dati backend.

### Regola consolidata

Il Repository Pattern deve continuare a garantire che:

```text
SQL / Supabase
        ≠
dominio Dart
```

e che il passaggio tra i due livelli avvenga attraverso contratti espliciti.

In particolare:

```text
lettura canonica
        ↓
read model / RLS
        ↓
Repository
        ↓
dominio
```

mentre per le operazioni protette:

```text
dominio / UI
        ↓
Repository
        ↓
RPC autoritativa
        ↓
authority / ownership / capability
        ↓
invarianti server-side
        ↓
persistenza
```

Il Repository deve nascondere i dettagli di persistenza senza nascondere il significato del contratto autoritativo.

Non deve introdurre scorciatoie che aggirino RLS, capability, RPC o invarianti server-side.

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

### Evoluzione fino alla S029

La Sessione S019 ha applicato concretamente questo principio mediante la prima migration della baseline Database V1:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

La Sessione S026 ha continuato lo stesso modello mediante:

```text
supabase/migrations/20260911084752_add_crop_catalog.sql
supabase/migrations/20260911091047_add_crop_catalog_write_rpcs.sql
```

Le migration del Catalogo DB V1 erano state applicate anche al database Supabase remoto mediante:

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

La Sessione S029 non ha richiesto nuove migration, perché ha completato il lifecycle lato applicativo utilizzando il contratto persistente già consolidato nella S028.

### Migration S030

La Sessione S030 ha proseguito la stessa strategia mediante una sequenza incrementale di migration dedicate alla nuova architettura del Catalogo Agronomico globale.

Le migration principali sono:

```text
supabase/migrations/20260920192606_add_global_catalog_identity.sql
supabase/migrations/20260920200852_add_agronomic_parameter_registry.sql
supabase/migrations/20260920203021_add_agronomic_context_vocabularies.sql
supabase/migrations/20260921124219_add_agronomic_sources_and_observations.sql
supabase/migrations/20260921142750_add_agronomic_identity_aliases.sql
supabase/migrations/20260921145956_add_agronomic_editorial_workflow.sql
supabase/migrations/20260922082448_add_canonical_agronomic_knowledge.sql
supabase/migrations/20260922091737_harden_agronomic_catalog_integrity.sql
supabase/migrations/20260922154850_add_catalog_identity_write_rpcs.sql
supabase/migrations/20260922165844_add_catalog_registry_write_rpcs.sql
supabase/migrations/20260922175238_add_catalog_ingestion_write_rpcs.sql
supabase/migrations/20260923080435_add_catalog_editorial_write_rpcs.sql
supabase/migrations/20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
supabase/migrations/20260923154831_finalize_global_catalog_cutover.sql
```

La sequenza documenta progressivamente:

```text
authority e identità globali
        ↓
registro dei parametri
        ↓
vocabolari di contesto
        ↓
fonti, acquisizioni e osservazioni
        ↓
alias delle identità
        ↓
workflow editoriale
        ↓
Knowledge canonica
        ↓
hardening
        ↓
Write Path autoritativi
        ↓
pubblicazione e Resolver
        ↓
cutover finale
```

Questa suddivisione permette di ricostruire non soltanto lo schema finale, ma anche l'ordine con cui sono state introdotte e protette le sue dipendenze.

### Cutover finale

La migration:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

rappresenta il cutover finale della S030.

Essa conclude il passaggio dalle strutture transitorie e legacy al contratto operativo basato su:

```text
botanical_taxa
crops
crop_cultivars
```

e riallinea il dominio `plantings` al riferimento opzionale:

```text
cultivar_id
```

al posto del precedente:

```text
variety_id
```

Il cutover elimina inoltre dallo schema operativo corrente le strutture non più appartenenti al contratto finale:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

La presenza nella cronologia Git delle migration che avevano originariamente creato strutture successivamente eliminate non costituisce un'anomalia.

Le migration rappresentano infatti l'evoluzione dello schema nel tempo e devono permettere di ricostruire il database finale applicando l'intera catena in ordine.

Non devono quindi essere riscritte retroattivamente le migration storiche soltanto perché una migration successiva modifica o rimuove una struttura precedente.

### Verifica locale e remota

Alla conclusione tecnica della S030 l'intera catena delle migration è stata verificata mediante ricostruzione da zero del database locale:

```text
supabase db reset
```

con esito positivo.

La migration finale è stata inoltre applicata al database Supabase remoto.

L'allineamento finale verificato è:

```text
Local  = 20260923154831
Remote = 20260923154831
```

Il database locale e quello remoto risultano quindi allineati alla migration:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

### Regola consolidata

L'evoluzione fisica del Database V1 deve continuare attraverso migration:

- versionate;
- incrementali;
- riproducibili;
- conservate nel repository;
- verificabili mediante ricostruzione locale;
- sottoposte a test;
- coerenti con il contratto applicativo;
- coerenti con RLS, policy, privilegi e Write Path;
- applicabili in modo controllato agli ambienti previsti.

Non devono essere introdotte modifiche strutturali permanenti esclusivamente dalla Dashboard Supabase senza una migration corrispondente nel repository.

La cronologia delle migration deve permettere di ricostruire progressivamente l'evoluzione effettiva del Database V1 senza dipendere dallo stato manuale di un singolo ambiente.

Il criterio rimane:

```text
migration storiche immutabili
        +
nuove migration incrementali
        +
ricostruzione verificabile
        +
allineamento controllato degli ambienti
        =
schema tracciabile
```

## 11.10 Verifica delle migration

Ogni gruppo di migration deve essere sottoposto a verifiche appropriate prima di essere considerato completato.

Le verifiche devono comprendere, secondo il contenuto della migration:

- creazione corretta delle strutture;
- foreign key;
- vincoli;
- intervalli temporali;
- ownership oppure authority;
- RLS;
- policy;
- privilegi;
- `GRANT` e `REVOKE`;
- operazioni consentite;
- operazioni che devono essere rifiutate;
- concorrenza;
- invarianti;
- compatibilità con Repository e dominio;
- eventuale migrazione dei dati preesistenti.

I test devono includere anche casi negativi, non soltanto operazioni autorizzate e valide.

### Verifiche S019

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

### Verifiche S026

La Sessione S026 ha esteso il metodo di verifica all'allora Catalogo DB V1 Profile-owned.

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

Queste verifiche descrivono il contratto storico S026 e non il Catalogo globale corrente introdotto dalla S030.

### Verifiche S028

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

Le verifiche S028 hanno coperto il contratto di `plantings` allora vigente, comprendendo:

- struttura persistente;
- relazioni tra Profile, Garden, Season, Bed, Crop e Variety secondo il contratto S028;
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

La verifica applicativa collegata alle migration S028 aveva inoltre confermato:

```text
flutter analyze
No issues found!
```

e:

```text
flutter test
997 tests passed
```

Il riferimento a Variety appartiene alla fotografia storica S028. Il contratto persistente corrente è stato successivamente riallineato dalla S030 a `crop_id` e `cultivar_id` opzionale.

### Verifiche S030

La Sessione S030 ha applicato il metodo di verifica all'intera nuova architettura del Catalogo Agronomico globale e al cutover finale.

La prima verifica fondamentale è stata la ricostruzione completa del database da zero mediante:

```text
supabase db reset
```

con esito positivo.

Questo test ha verificato che l'intera catena delle migration, comprese quelle storiche e tutte le migration S030, conduca correttamente allo schema finale.

La catena è stata verificata fino a:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

### Lint dello schema

Il lint finale dello schema è stato verificato sia localmente sia sul database Supabase remoto, con esito:

```text
No schema errors found
```

La verifica non si è quindi limitata all'ambiente locale.

### Acceptance Tranche 10

Le acceptance della Tranche 10 hanno verificato il perimetro relativo a:

```text
pubblicazione
+
Resolver
```

insieme alle invarianti e ai contratti introdotti dalle migration precedenti da cui tali funzionalità dipendono.

Le fixture necessarie ai test sono state utilizzate in modo controllato e successivamente eliminate mediante rollback.

Nessun dato di prova persistente è stato lasciato nel database.

### Acceptance Tranche 11

Le acceptance della Tranche 11 hanno verificato il cutover globale finale.

Sono stati verificati, nel perimetro previsto dalla tranche:

- completamento della catena canonica del Catalogo;
- eliminazione delle strutture legacy previste dal cutover;
- contratto finale di `crops`;
- contratto finale di `crop_cultivars`;
- riallineamento di `plantings`;
- rimozione del precedente `variety_id`;
- utilizzo di `cultivar_id` opzionale;
- coerenza referenziale Crop/cultivar;
- read model canonici;
- compatibilità del nuovo contratto con l'integrazione Flutter.

Anche per questa acceptance le fixture sono state eliminate mediante rollback.

Il database è quindi rimasto privo dei dati temporanei utilizzati esclusivamente per la verifica.

### Verifica locale e remota

La migration finale S030 è stata applicata anche al database Supabase remoto.

L'allineamento finale verificato è:

```text
Local  = 20260923154831
Remote = 20260923154831
```

Lo schema locale e quello remoto risultano pertanto allineati alla migration:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

### Verifica dell'integrazione Flutter S030

La verifica del cutover non si è limitata al database.

Dopo il riallineamento applicativo sono stati eseguiti:

```text
dart format lib test
```

con risultato:

```text
Formatted 174 files
```

È stato quindi eseguito:

```text
flutter analyze
```

con risultato:

```text
No issues found!
```

La suite Flutter completa ha inoltre concluso:

```text
953 tests passed
```

Sono stati verificati anche i flussi applicativi interessati dalla sostituzione del precedente contratto Variety con il nuovo contratto cultivar.

### Smoke test finale

La verifica finale S030 ha incluso anche uno smoke test dell'applicazione in Edge.

Sono stati verificati:

- Dashboard raggiungibile;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto `Nessuna varietà presente` correttamente gestito;
- assenza del precedente pulsante di aggiunta personale della varietà;
- corretta gestione di un profilo privo di Garden.

Il test manuale completo di Beds e Planting non è stato eseguibile perché il profilo verificato non disponeva di un Garden.

Questa condizione rappresenta un limite dei dati operativi disponibili per lo smoke test e non un errore rilevato nel cutover.

### Criterio di verifica

Una migration non deve essere considerata verificata soltanto perché viene applicata senza errori.

Deve essere controllato anche il comportamento effettivo:

- della struttura;
- delle autorizzazioni;
- delle capability, quando previste;
- delle invarianti;
- della concorrenza;
- del contratto RPC;
- dei privilegi;
- dei read model;
- dell'integrazione applicativa;
- dell'eventuale migrazione o trasformazione dei dati.

Il criterio consolidato rimane:

```text
migration versionata
        ↓
applicazione / ricostruzione controllata
        ↓
verifica struttura effettiva
        ↓
verifica sicurezza e privilegi
        ↓
test positivi
        ↓
test negativi
        ↓
acceptance
        ↓
verifica integrazione applicativa
        ↓
verifica ambiente remoto quando prevista
        ↓
commit e push
```

Per le migration che modificano contratti utilizzati dal client, il completamento tecnico richiede quindi sia la verifica dello schema sia la verifica dell'integrazione applicativa corrispondente.

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
        ≠
implementazione simultanea
```

### Esempio S026

La Sessione S026 costituisce un primo esempio concreto di questo metodo.

L'obiettivo iniziale era avvicinarsi a `plantings`, ma l'analisi delle dipendenze aveva evidenziato la necessità di implementare prima il Catalogo DB V1 allora previsto.

Era stato quindi completato esclusivamente il blocco propedeutico:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

senza anticipare `plantings`.

`plantings` è stato successivamente implementato nella S028, dopo il consolidamento delle dipendenze necessarie.

### Esempio S030

La Sessione S030 ha applicato lo stesso principio a una trasformazione architetturale molto più ampia.

Il nuovo Catalogo Agronomico globale non è stato introdotto mediante una singola migration monolitica.

L'implementazione è stata suddivisa in **11 tranche tecniche**:

```text
1. Authority e identità globali
        ↓
2. Registro dei parametri agronomici
        ↓
3. Vocabolari di contesto
        ↓
4. Fonti, acquisizioni e osservazioni
        ↓
5. Alias delle identità agronomiche
        ↓
6. Workflow editoriale
        ↓
7. Knowledge agronomica canonica
        ↓
8. Hardening dell'integrità
        ↓
9. Write Path autoritativi
        ↓
10. Pubblicazione + Resolver
        ↓
11. Cutover globale finale DB + Flutter
```

Ogni tranche ha costruito e verificato le dipendenze necessarie alla successiva.

Il precedente Catalogo non è stato eliminato all'inizio della trasformazione.

Il cutover definitivo è stato eseguito soltanto dopo avere costruito e verificato il nuovo modello fino al livello necessario per sostituire in modo coerente il contratto precedente.

La migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

ha quindi completato una trasformazione preparata progressivamente, non un cambiamento improvviso e isolato.

### Regola per gli incrementi successivi

Lo stesso criterio deve essere mantenuto per le parti del Database V1 ancora da implementare.

In particolare:

```text
nuova esigenza
        ↓
analisi delle dipendenze
        ↓
blocco minimo coerente
        ↓
migration
        ↓
sicurezza
        ↓
test
        ↓
integrazione applicativa quando prevista
        ↓
incremento successivo
```

Non devono essere anticipate strutture soltanto perché appartengono alla baseline completa.

Allo stesso modo, una trasformazione ampia non deve essere concentrata artificialmente in una singola migration quando può essere suddivisa in incrementi verificabili.

L'obiettivo rimane raggiungere progressivamente la baseline V1 e le sue evoluzioni approvate mantenendo in ogni fase:

- controllo tecnico;
- sicurezza;
- testabilità;
- riproducibilità;
- tracciabilità;
- possibilità di individuare con precisione eventuali regressioni.

## 11.13 Criterio di completamento

Il Database V1 potrà essere considerato realmente implementato soltanto quando la baseline progettuale e le evoluzioni architetturali approvate saranno state tradotte e verificate nel sistema operativo per il perimetro previsto.

La sola presenza nominale delle tabelle non è sufficiente.

Il completamento richiede, secondo il dominio interessato:

- strutture persistenti previste;
- relazioni e foreign key;
- invarianti;
- temporalità prevista;
- ownership oppure authority;
- RLS e autorizzazioni;
- privilegi espliciti;
- infrastruttura tecnica necessaria;
- Write Path autoritativi dove previsti;
- capability dove previste;
- migrazione dei dati esistenti quando applicabile;
- integrazione con Repository e dominio;
- integrazione applicativa richiesta dal perimetro;
- test di integrazione e sicurezza;
- verifiche positive e negative;
- migration riproducibili;
- documentazione aggiornata.

Fino al completamento dell'intera baseline deve essere mantenuta esplicita la distinzione:

```text
Database V1 progettato
        ≠
Database V1 completamente implementato
```

Deve inoltre essere distinta la condizione:

```text
backend implementato
        ≠
funzionalità UI completa
```

perché un dominio può essere già presente e protetto nel database senza disporre ancora di tutte le schermate operative o amministrative previste.

### Stato storico alla conclusione della S029

Alla conclusione della S029 risultavano completati:

```text
Catalogo DB V1 Profile-owned
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

UI lifecycle plantings
        ✓

end_date terminale esplicita lato UI
        ✓

refresh su version_conflict / invalid_transition
        ✓

UI amministrativa Catalogo V1
        ✗

selezione varietà nel flusso plantings
        ✗

Database V1 completo
        ✗
```

Questa fotografia rappresenta lo stato storico alla conclusione della S029 e non il contratto corrente del Catalogo dopo la S030.

La S028 aveva introdotto:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

e il Write Path autoritativo:

```text
create_planting
update_planting
set_planting_status
```

La S029 aveva quindi completato il livello applicativo del lifecycle utilizzando il contratto persistente S028, senza introdurre nuove migration o modificare schema, RPC e RLS.

Questa parte del dominio rimane consolidata, pur essendo stata successivamente riallineata dalla S030 rispetto al riferimento Crop/cultivar.

### Stato raggiunto con S030

La Sessione S030 ha completato il perimetro tecnico previsto per la nuova architettura del Catalogo Agronomico V1.

Il Catalogo corrente è:

```text
globale
+
multisorgente
+
tracciabile
+
versionabile
+
contestualizzabile
+
editorialmente controllato
```

Il nuovo perimetro comprende **26 tabelle** dedicate all'architettura del Catalogo Agronomico.

La catena canonica delle identità operative è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Le precedenti strutture:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

non appartengono più allo schema operativo finale.

Il dominio `plantings` utilizza ora:

```text
crop_id
+
cultivar_id opzionale
```

con protezione referenziale della coerenza Crop/cultivar.

Il precedente:

```text
variety_id
```

è stato rimosso dal contratto persistente corrente.

### Perimetro tecnico S030 completato

Alla conclusione tecnica della S030 risultano implementati e verificati:

```text
Authority e identità globali
        ✓

registro dei parametri agronomici
        ✓

vocabolari di contesto
        ✓

fonti, acquisizioni e osservazioni
        ✓

alias e mapping delle identità
        ✓

workflow editoriale backend
        ✓

Knowledge agronomica canonica
        ✓

hardening dell'integrità
        ✓

Write Path autoritativi del Catalogo
        ✓

pubblicazione backend
        ✓

Resolver backend
        ✓

cutover globale finale
        ✓

read model canonici
        ✓

integrazione Flutter del contratto Catalogo corrente
        ✓

riallineamento Planting da variety a cultivar
        ✓
```

Sono inoltre disponibili:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

nel contratto previsto per la gestione della Catalog Authority.

Il claim iniziale rimane esplicito e non automatico.

### Verifica del completamento tecnico S030

Il perimetro tecnico S030 è stato verificato mediante:

```text
supabase db reset
        ✓

lint schema locale
        ✓

lint schema remoto
        ✓

Acceptance Tranche 10
        ✓

Acceptance Tranche 11
        ✓

rollback fixture di test
        ✓

allineamento Local / Remote
        ✓

flutter analyze
        ✓

suite Flutter completa
        ✓

smoke test Edge
        ✓ nel perimetro verificabile
```

L'allineamento finale delle migration è:

```text
Local  = 20260923154831
Remote = 20260923154831
```

La suite Flutter finale ha concluso:

```text
953 tests passed
```

Lo smoke test ha inoltre confermato il corretto comportamento delle schermate raggiungibili nel profilo utilizzato.

La verifica manuale completa di Beds e Planting non è stata possibile nello smoke test finale perché il profilo non disponeva di un Garden.

Questa limitazione deve rimanere distinta da un errore tecnico del cutover.

### Perimetro non completato

Il completamento tecnico della S030 non equivale al completamento dell'intero Database V1.

Restano FUTURE, tra gli altri:

- backend canonico delle associazioni colturali;
- UI editoriale e amministrativa completa del Catalogo Agronomico;
- flusso operativo di ingestion/importazione e revisione in `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- azione UI esplicita e sicura per `claim_initial_catalog_authority()`;
- integrazione completa del Resolver nei flussi di pianificazione e creazione delle coltivazioni;
- popolamento editoriale del Catalogo con dati agronomici verificabili;
- ulteriori entità della baseline Database V1 non ancora implementate;
- ulteriori Write Path richiesti dai domini che verranno implementati successivamente.

Rimane inoltre da verificare o ripristinare, nel flusso applicativo operativo, il percorso UI per la creazione del primo Garden prima dell'avvio con i dati reali.

### Avvio dei dati reali

Il completamento di una struttura tecnica non autorizza l'introduzione di dati demo o provvisori.

Prima dell'avvio operativo reale deve essere mantenuto il principio:

```text
nessun dato di prova persistente
```

La sequenza operativa prevista è:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
caricamento Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle Beds reali
        ↓
apertura Season reale
        ↓
registrazione Plantings reali
```

Il popolamento del Catalogo deve utilizzare fonti verificabili e il workflow editoriale previsto.

I dati acquisiti da fonti esterne non possono diventare automaticamente dati approvati né sovrascrivere automaticamente il Catalogo pubblicato.

### Criterio finale

Il Database V1 continua quindi a essere considerato **parzialmente implementato**.

Il criterio di completamento non è:

```text
tabella presente
```

ma:

```text
struttura implementata
+
dipendenze coerenti
+
integrità verificata
+
sicurezza verificata
+
Write Path protetto quando necessario
+
integrazione applicativa richiesta
+
test positivi e negativi
+
migration riproducibili
+
documentazione aggiornata
```

Soltanto quando l'intero perimetro previsto per il Database V1 sarà stato implementato e verificato secondo questi criteri potrà essere dichiarato:

```text
Database V1 completamente implementato
```

Fino ad allora ogni sessione deve continuare a dichiarare separatamente ciò che è:

```text
progettato
implementato
verificato
integrato lato applicazione
FUTURE
```

senza anticipare come completate funzionalità che appartengono ancora agli incrementi successivi.

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

- `agronomic_windows` non costituisce una tabella persistente del Database V1, poiché `AgronomicWindow` rimane un risultato calcolato a partire dalle regole agronomiche applicabili;
- `irrigation_zone_target_assignments` costituisce il nome SQL definitivo e sostituisce la precedente denominazione provvisoria `zone_target_assignments`.

La baseline S017 rimane il riferimento progettuale storico del Database V1.

L'implementazione fisica non è tuttavia una trasposizione immutabile dei nomi e delle strutture originariamente ipotizzate: le successive sessioni possono evolvere il modello fisico quando l'analisi tecnica individua una soluzione più corretta, purché tale evoluzione sia esplicita, versionata, verificata e documentata.

L'implementazione fisica del Database V1 è iniziata nella Sessione S019 e procede incrementalmente mediante migration versionate, controlli di sicurezza, test positivi e negativi e Write Path autoritativi.

Le Sessioni S019–S029 hanno progressivamente consolidato:

- Fondazioni;
- protocollo `profile_edit_locks`;
- Profile Write Authority;
- Write Path di `gardens`;
- Write Path di `seasons`;
- modello e Write Path autoritativo delle aiuole;
- prima implementazione del Catalogo DB V1;
- integrazione Flutter del Catalogo;
- modello persistente autoritativo di `plantings`;
- Write Path autoritativo di `plantings`;
- lifecycle server-side delle coltivazioni;
- integrazione Flutter della creazione, modifica e gestione lifecycle delle coltivazioni.

La Sessione S030 ha introdotto una successiva evoluzione architetturale sostanziale del Catalogo Agronomico.

Il precedente modello personale del Catalogo è stato sostituito da un'architettura:

```text
globale
+
multisorgente
+
tracciabile
+
versionabile
+
contestualizzabile
+
editorialmente controllata
```

La catena canonica corrente delle identità è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Il nuovo perimetro del Catalogo Agronomico comprende **26 tabelle** e separa esplicitamente:

- identità botaniche e agronomiche;
- parametri agronomici;
- contesti;
- fonti;
- acquisizioni;
- osservazioni;
- alias e mapping;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione;
- risoluzione contestuale mediante Resolver;
- autorità e capability di gestione.

La S030 ha inoltre completato il cutover del contratto `plantings` dal precedente riferimento Variety al nuovo riferimento cultivar.

Alla conclusione tecnica della S030 il Database V1 rimane **parzialmente implementato**, ma il perimetro tecnico previsto per il nuovo Catalogo Agronomico globale risulta implementato e verificato.

Il completamento della S030 non equivale pertanto al completamento dell'intera baseline Database V1.

## 13.1 Principi consolidati

La baseline Database V1 e le successive evoluzioni architetturali approvate sono fondate sui seguenti principi:

- separazione tra pianificazione e realtà;
- separazione tra configurazioni e fatti realmente avvenuti;
- identità stabile distinta dalle configurazioni storicizzate;
- storicizzazione selettiva quando necessaria;
- riduzione delle duplicazioni;
- utilizzo di dati derivati invece della loro persistenza quando possibile;
- ownership verificabile per i dati che appartengono a Profile o Garden;
- authority esplicita per i domini globali che non appartengono a un singolo Profile o Garden;
- sicurezza server-side;
- RLS con approccio deny-by-default;
- privilegi espliciti mediante `GRANT`, `REVOKE` ed `EXECUTE` quando previsti dal contratto;
- Flutter considerato client non fidato;
- separazione tra persistenza, Knowledge, proposta applicativa e decisione operativa;
- implementazione incrementale mediante migration tracciate;
- Write Path autoritativi per le operazioni che richiedono protezione server-side;
- capability esplicite quando l'autorizzazione non può essere derivata dalla sola ownership;
- concorrenza ottimistica mediante `row_version` ed `expected_row_version` quando prevista dal contratto;
- comportamento fail-closed in presenza di esiti sconosciuti, incompleti o non verificabili;
- nessun retry automatico quando l'esito effettivo di una scrittura non è confermabile;
- rilettura del dato autoritativo dopo una scrittura riuscita quando prevista dal flusso applicativo;
- letture dirette consentite soltanto attraverso strutture e policy previste dal contratto di sicurezza;
- scritture ordinarie di `plantings` esclusivamente mediante RPC autoritative;
- scritture protette del Catalogo Agronomico globale esclusivamente attraverso i relativi Write Path autoritativi;
- separazione tra dato acquisito da una fonte esterna e dato canonico approvato;
- nessuna promozione automatica di un dato esterno a Knowledge approvata;
- nessuna sovrascrittura automatica del Catalogo pubblicato da parte di una fonte esterna;
- provenienza e tracciabilità delle informazioni agronomiche;
- revisioni editoriali esplicite e ricostruibili;
- utilizzo di `previous_revision_id` per la catena delle revisioni prevista dal workflow;
- semantic freeze a partire dal primo artefatto immutabile previsto dal processo editoriale;
- conservazione della tracciabilità anche in caso di WITHDRAW;
- separazione tra Knowledge canonica e snapshot operativi;
- il Resolver può determinare la Knowledge applicabile ma non modificare automaticamente un fatto operativo;
- una proposta agronomica diventa fatto persistente soltanto attraverso il flusso applicativo previsto e, quando richiesto, la conferma dell'utente;
- integrità della geometria storicizzata rispetto ai fatti reali registrati;
- semantica half-open per gli intervalli nei domini che la richiedono;
- database privo di dati demo o provvisori prima dell'avvio operativo reale;
- estensioni future introdotte soltanto in presenza di requisiti concreti.

Per il Catalogo Agronomico globale il flusso concettuale consolidato è:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
revisione editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Resolver
        ↓
proposta applicativa
        ↓
eventuale conferma dell'utente
        ↓
fatto operativo
```

Questo flusso impedisce di confondere:

```text
dato trovato
        ≠
dato approvato
        ≠
dato pubblicato
        ≠
decisione operativa
```

La Catalog Authority globale utilizza capability distinte per separare le responsabilità:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

L'accesso in lettura al Catalogo non implica quindi automaticamente il diritto di modificarne identità, acquisire fonti, revisionare contenuti o pubblicare Knowledge.

Questi principi devono essere preservati durante la progressiva implementazione SQL/Supabase, durante l'integrazione Flutter e durante i futuri popolamenti del Catalogo con dati agronomici reali.

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
prima implementazione Catalogo DB V1
        ✓
Write Path Catalogo DB V1 Profile-owned
        ✓
integrazione Flutter del primo Catalogo
        ✓
modello autoritativo plantings
        ✓
Write Path plantings
        ✓
integrazione Flutter creazione/modifica plantings
        ✓
lifecycle server-side plantings
        ✓
UI lifecycle plantings
        ✓
end_date terminale esplicita lato UI
        ✓
refresh UI su conflitti lifecycle
        ✓
architettura Catalogo Agronomico globale S030
        ✓
Catalog Authority e capability
        ✓
fonti, acquisizioni e osservazioni
        ✓
workflow editoriale backend
        ✓
Knowledge agronomica canonica
        ✓
pubblicazione backend
        ✓
Resolver backend
        ✓
cutover globale DB
        ✓
cutover Flutter Variety → cultivar
        ✓
read model canonici
        ✓
UI editoriale/amministrativa completa del Catalogo
        ✗
workflow operativo Aggiornamento fonti
        ✗
integrazione completa Resolver nei flussi Planting
        ✗
backend canonico associazioni colturali
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

`profile_edit_locks` rimane infrastruttura tecnica separata.

`profile_memberships` costituisce una struttura di sicurezza e accesso introdotta nell'implementazione fisica e deve essere distinta dalle 52 entità di dominio congelate.

Le sessioni successive hanno progressivamente introdotto i domini relativi a:

- geometria e gestione delle aiuole;
- primo Catalogo DB V1;
- coltivazioni;
- lifecycle delle coltivazioni;
- nuovo Catalogo Agronomico globale.

### Plantings

La Sessione S028 ha introdotto:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

e il relativo Write Path autoritativo:

```text
create_planting
update_planting
set_planting_status
```

La Sessione S029 non ha introdotto nuove migration.

Ha completato il livello applicativo del lifecycle utilizzando il contratto persistente definito nella S028.

Il flusso consolidato rimane:

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

Sono disponibili lato UI:

- le transizioni lifecycle consentite dal server;
- la richiesta esplicita di `end_date` per gli stati terminali;
- il mantenimento dell'occupazione nello stato `harvested`;
- il refresh autoritativo dopo `version_conflict`;
- il refresh autoritativo dopo `invalid_transition`.

La S030 ha successivamente riallineato il riferimento agronomico di `plantings` al nuovo Catalogo globale.

Il contratto corrente utilizza:

```text
crop_id
cultivar_id opzionale
```

con relazione composita che impedisce di associare a un Crop una cultivar appartenente a un Crop differente.

Il precedente:

```text
variety_id
```

non appartiene più al contratto persistente corrente.

### Catalogo Agronomico globale

La Sessione S030 ha sostituito il precedente modello personale del Catalogo con un'architettura globale.

La catena canonica corrente è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Le strutture legacy:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

sono state rimosse dal modello operativo finale mediante il cutover S030.

Il nuovo perimetro del Catalogo comprende **26 tabelle** e supporta:

- identità botaniche globali;
- identità agronomiche globali;
- registro dei parametri agronomici;
- vocabolari di contesto;
- fonti;
- acquisizioni;
- osservazioni;
- alias e mapping delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- revisioni;
- pubblicazione;
- Resolver;
- Catalog Authority;
- capability distinte.

Le capability correnti sono:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

L'autorità iniziale può essere gestita attraverso:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

Il claim iniziale è esplicito, non automatico, idempotente e soggetto alle condizioni autoritative previste dal backend.

### Lettura del Catalogo

I read model canonici utilizzati dall'applicazione sono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati secondo il contratto S030 con:

```text
security_invoker = true
```

Lato Flutter:

```text
CropRepository
        ↓
crop_catalog_read
```

e:

```text
CropCultivarRepository
        ↓
crop_cultivar_catalog_read
```

costituiscono il confine di lettura corrente.

La terminologia tecnica utilizza:

```text
CropCultivar
cultivarId
cultivar_id
```

mentre l'interfaccia utente può continuare a utilizzare il termine italiano:

```text
Varietà
```

### Provenienza e Knowledge

Il nuovo Catalogo distingue esplicitamente:

```text
dato acquisito
        ≠
osservazione
        ≠
dato revisionato
        ≠
Knowledge canonica
        ≠
dato pubblicato
        ≠
decisione operativa
```

Il flusso concettuale è:

```text
Fonte esterna
        ↓
acquisizione
        ↓
osservazione
        ↓
revisione
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Resolver
```

Un'importazione non può quindi sovrascrivere automaticamente il Catalogo approvato.

Il Resolver può individuare la Knowledge applicabile a un determinato contesto, ma non modifica automaticamente un Planting né trasforma autonomamente una raccomandazione in fatto operativo.

### Verifica tecnica S030

La ricostruibilità completa dello schema è stata verificata mediante:

```text
supabase db reset
```

fino alla migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Il lint finale dello schema è stato verificato sia localmente sia sul database Supabase remoto con esito:

```text
No schema errors found
```

Le acceptance delle Tranche 10 e 11 sono state completate con esito positivo.

Le fixture utilizzate durante le verifiche sono state eliminate mediante rollback, senza lasciare dati di prova persistenti.

L'allineamento finale verificato è:

```text
Local  = 20260923154831
Remote = 20260923154831
```

La verifica applicativa finale ha inoltre confermato:

```text
dart format lib test
Formatted 174 files
```

```text
flutter analyze
No issues found!
```

e:

```text
953 tests passed
```

Lo smoke test finale in Edge ha confermato:

- Dashboard raggiungibile;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- corretta gestione dello stato `Nessuna varietà presente`;
- assenza del precedente pulsante di aggiunta personale della varietà;
- corretta gestione del profilo senza Garden.

La verifica manuale completa di Beds e Planting non è stata possibile nello smoke test finale perché il profilo utilizzato non disponeva di un Garden.

### Stato complessivo

Alla conclusione tecnica della S030:

```text
perimetro tecnico Catalogo Agronomico S030
        ✓

cutover DB
        ✓

cutover Flutter necessario
        ✓

verifica locale
        ✓

verifica remota
        ✓

Database V1 completo
        ✗
```

Il Database V1 rimane quindi **parzialmente implementato**.

In particolare, il completamento tecnico del Catalogo S030 non deve essere confuso con:

- popolamento reale del Catalogo;
- UI editoriale/amministrativa completa;
- workflow operativo di aggiornamento delle fonti;
- integrazione completa del Resolver nei flussi di pianificazione;
- backend canonico delle associazioni colturali;
- completamento delle restanti entità della baseline Database V1.

Lo stato raggiunto deve continuare a essere valutato sulla base di ciò che è realmente implementato, verificato e integrato, senza considerare operative le funzionalità ancora classificate come FUTURE.

## 13.3 Evoluzione dell'implementazione dalla S019 alla S030

La Sessione S019 ha avviato concretamente la traduzione della baseline Database V1 congelata nella S017 in strutture PostgreSQL/Supabase versionate e verificabili.

### S019 — Fondazioni

Il primo incremento ha riguardato il blocco **Fondazioni** e ha introdotto:

- schema `private`;
- helper autorizzativi;
- trigger metadata;
- Row Level Security;
- **13 policy RLS**;
- test manuali positivi;
- test manuali negativi.

### S020–S021 — Protocollo single-writer

La Sessione S020 ha avviato l'implementazione delle RPC server-side del protocollo `profile_edit_locks`.

La Sessione S021 ha completato e rafforzato il protocollo single-writer, verificando:

- serializzazione mediante `FOR UPDATE`;
- rivalidazione server-side dopo eventuali attese sui row lock;
- utilizzo dell'orologio PostgreSQL come autorità temporale;
- protezione del lease;
- gestione sicura del takeover;
- trasferimento atomico del lock.

### S022 — Gardens

La Sessione S022 ha introdotto la Profile Write Authority e il primo Write Path autoritativo per:

```text
gardens
```

mediante:

```text
create_garden
update_garden
```

### S023 — Seasons

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

### S024–S025 — Beds e geometria storicizzata

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

### S026 — Prima implementazione del Catalogo DB V1

La Sessione S026 ha introdotto il primo **Catalogo DB V1**:

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

Questa architettura era Profile-owned e costituisce la fotografia storica del Catalogo implementato nella S026.

### S027 — Integrazione Flutter del primo Catalogo

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

### S028 — Plantings

La Sessione S028 ha quindi implementato il modello autoritativo di:

```text
public.plantings
```

mediante:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Il modello persistente S028 comprendeva il contesto:

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

Il riferimento `variety_id` rappresenta il contratto storico S028 ed è stato successivamente sostituito dal cutover S030.

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

### S029 — Lifecycle applicativo delle coltivazioni

La Sessione S029 non ha introdotto nuove migration e non ha modificato il contratto PostgreSQL/Supabase definito dalla S028.

Ha completato l'integrazione applicativa del lifecycle delle coltivazioni utilizzando il Write Path autoritativo esistente.

Il flusso consolidato è:

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

La S029 ha integrato lato Flutter:

- transizioni lifecycle consentite;
- richiesta esplicita di `end_date` per gli stati terminali;
- mantenimento di `end_date = null` nelle transizioni intermedie;
- mantenimento dell'occupazione dell'aiuola nello stato `harvested`;
- rilettura autoritativa dopo `version_conflict`;
- rilettura autoritativa dopo `invalid_transition`.

La verifica finale S029 ha confermato:

```text
flutter analyze
No issues found!
```

e:

```text
1011 tests passed
```

con inoltre:

```text
bed_page_test.dart
30/30
```

e:

```text
planting_card_test.dart
9/9
```

La S029 costituisce quindi un esempio di evoluzione applicativa completata senza necessità di modificare lo schema persistente.

### S030 — Catalogo Agronomico globale

La Sessione S030 ha introdotto una trasformazione architetturale sostanziale del Catalogo Agronomico.

Il precedente modello Profile-owned è stato evoluto verso un Catalogo:

```text
globale
+
multisorgente
+
tracciabile
+
versionabile
+
contestualizzabile
+
editorialmente controllato
```

Lo sviluppo è stato organizzato in **11 tranche tecniche**.

#### Tranche 1 — Authority e identità globali

È stata introdotta la base delle identità globali e della Catalog Authority mediante:

```text
20260920192606_add_global_catalog_identity.sql
```

con:

- `catalog_authorities`;
- `botanical_taxa`;
- normalizzazione canonica dei testi;
- identità agronomiche globali preparatorie.

La funzione:

```text
private.normalize_catalog_text(text)
```

stabilisce il contratto di normalizzazione utilizzato per l'identità testuale del Catalogo.

#### Tranche 2 — Registro dei parametri agronomici

È stato introdotto il registro dei parametri mediante:

```text
20260920200852_add_agronomic_parameter_registry.sql
```

separando l'identità del parametro dalla singola osservazione o dal singolo valore editoriale.

#### Tranche 3 — Vocabolari di contesto

La migration:

```text
20260920203021_add_agronomic_context_vocabularies.sql
```

ha introdotto i vocabolari necessari alla contestualizzazione della Knowledge agronomica.

#### Tranche 4 — Fonti, acquisizioni e osservazioni

La migration:

```text
20260921124219_add_agronomic_sources_and_observations.sql
```

ha introdotto il livello di provenienza necessario a distinguere:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
```

Il dato acquisito non viene considerato automaticamente dato approvato.

#### Tranche 5 — Alias delle identità

La migration:

```text
20260921142750_add_agronomic_identity_aliases.sql
```

ha introdotto alias e mapping delle identità agronomiche.

#### Tranche 6 — Workflow editoriale

La migration:

```text
20260921145956_add_agronomic_editorial_workflow.sql
```

ha introdotto il workflow editoriale e la gestione esplicita delle revisioni.

Il contratto comprende il collegamento:

```text
previous_revision_id
```

e le regole necessarie alla ricostruibilità della storia editoriale.

#### Tranche 7 — Knowledge agronomica canonica

La migration:

```text
20260922082448_add_canonical_agronomic_knowledge.sql
```

ha introdotto il livello di Knowledge canonica, distinto sia dalle osservazioni delle fonti sia dai fatti operativi dell'orto.

#### Tranche 8 — Hardening dell'integrità

La migration:

```text
20260922091737_harden_agronomic_catalog_integrity.sql
```

ha rafforzato gli invarianti e i vincoli del nuovo modello.

#### Tranche 9 — Write Path autoritativi

I Write Path del nuovo Catalogo sono stati introdotti progressivamente mediante:

```text
20260922154850_add_catalog_identity_write_rpcs.sql
20260922165844_add_catalog_registry_write_rpcs.sql
20260922175238_add_catalog_ingestion_write_rpcs.sql
20260923080435_add_catalog_editorial_write_rpcs.sql
```

La protezione non è più basata sulla ownership personale del vecchio Catalogo.

Il nuovo modello utilizza una Catalog Authority globale con capability distinte:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

#### Tranche 10 — Pubblicazione e Resolver

La migration:

```text
20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
```

ha introdotto il livello di pubblicazione e il Resolver della Knowledge agronomica.

Il Resolver seleziona la Knowledge applicabile al contesto previsto dal contratto, ma non modifica automaticamente i fatti operativi.

#### Tranche 11 — Cutover globale DB + Flutter

La migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

ha completato il cutover verso la catena canonica:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

e ha rimosso dal modello operativo finale:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Il contratto `plantings` è stato riallineato da:

```text
variety_id
```

a:

```text
cultivar_id
```

opzionale, mantenendo `crop_id` e introducendo la protezione referenziale composita Crop/cultivar.

Sul lato Flutter il contratto tecnico è stato riallineato a:

```text
CropCultivar
CropCultivarRepository
cultivarId
cultivar_id
```

mentre il termine italiano **Varietà** può continuare a essere utilizzato nell'interfaccia utente.

Sono stati inoltre introdotti:

```text
CatalogCapabilities
CatalogAuthorityRepository
```

per l'integrazione con le capability della Catalog Authority.

I read model canonici sono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

con:

```text
security_invoker = true
```

Il `RotationEngine` utilizza l'identità canonica della famiglia botanica tramite UUID; il nome della famiglia rimane informazione di visualizzazione.

Il backend canonico delle associazioni colturali non è stato introdotto nella S030.

`CropAssociationRepository` restituisce quindi insiemi vuoti invece di interrogare una relazione inesistente, mantenendo disponibile il motore applicativo senza inventare un backend non ancora implementato.

### Verifica finale S030

La catena completa delle migration è stata ricostruita mediante:

```text
supabase db reset
```

con esito positivo.

Il lint finale dello schema, locale e remoto, ha restituito:

```text
No schema errors found
```

Le acceptance delle Tranche 10 e 11 sono state completate con esito positivo e le fixture utilizzate sono state eliminate mediante rollback.

L'allineamento finale verificato è:

```text
Local  = 20260923154831
Remote = 20260923154831
```

La verifica Flutter finale ha confermato:

```text
dart format lib test
Formatted 174 files
```

```text
flutter analyze
No issues found!
```

```text
953 tests passed
```

Lo smoke test finale in Edge ha inoltre verificato il perimetro applicativo raggiungibile senza rilevare eccezioni o errori rossi.

La verifica manuale completa di Beds e Planting non è stata possibile perché il profilo utilizzato non disponeva di un Garden.

### Stato dopo S030

La S030 conclude il proprio perimetro tecnico, ma non completa l'intero Database V1.

Restano incrementi successivi, tra cui:

- backend canonico delle associazioni colturali;
- UI editoriale/amministrativa completa del Catalogo;
- workflow operativo di aggiornamento delle fonti;
- azione UI esplicita e sicura per il claim iniziale della Catalog Authority;
- integrazione completa del Resolver nei flussi operativi;
- popolamento editoriale del Catalogo con dati verificabili;
- ulteriori entità e Write Path della baseline Database V1 non ancora implementati.

La progressione S019–S030 conferma quindi il metodo adottato:

```text
baseline
        ↓
incremento coerente
        ↓
migration
        ↓
sicurezza
        ↓
test
        ↓
integrazione applicativa
        ↓
verifica
        ↓
incremento successivo
```

senza anticipare come operative funzionalità appartenenti alle sessioni future.

## 13.4 Stato dei Write Path autoritativi

Alla conclusione della Sessione S030 risultano implementati e verificati Write Path autoritativi per i principali domini già tradotti nello schema operativo.

Per i domini operativi personali rimangono correnti i Write Path di:

```text
gardens
seasons
beds
plantings
```

Il Catalogo Agronomico segue invece, dalla S030, un modello autoritativo globale distinto dall'ownership dei dati operativi dell'orto.

### Write Path operativi

I Write Path di `gardens`, `seasons`, `beds` e `plantings` continuano a seguire, secondo il rispettivo contratto, principi quali:

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

Per `plantings` il Write Path corrente continua a utilizzare:

```text
create_planting
update_planting
set_planting_status
```

Il cutover S030 ha riallineato il riferimento agronomico del Planting al nuovo contratto:

```text
crop_id
+
cultivar_id opzionale
```

senza eliminare il carattere autoritativo del Write Path.

### Evoluzione del Write Path del Catalogo

Nella S026 il Catalogo DB V1 Profile-owned disponeva delle nove RPC:

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

Queste RPC appartengono alla fotografia storica del Catalogo S026 e non rappresentano il contratto autoritativo corrente dopo il cutover S030.

La S030 ha sostituito il modello personale con un Catalogo globale governato da:

```text
Catalog Authority
        +
capability
        +
Write Path autoritativo
```

Le capability distinte sono:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

Il principio corrente diventa quindi:

```text
autenticazione
        ↓
Catalog Authority
        ↓
capability richiesta
        ↓
RPC autoritativa
        ↓
validazione server-side
        ↓
invarianti
        ↓
operazione atomica
```

I Write Path S030 coprono i principali blocchi relativi a:

- gestione delle identità;
- registro dei parametri e contesti;
- ingestion;
- workflow editoriale;
- pubblicazione.

Le relative migration sono:

```text
20260922154850_add_catalog_identity_write_rpcs.sql
20260922165844_add_catalog_registry_write_rpcs.sql
20260922175238_add_catalog_ingestion_write_rpcs.sql
20260923080435_add_catalog_editorial_write_rpcs.sql
20260923095238_add_agronomic_knowledge_publication_and_resolver.sql
```

Il cutover finale è stato completato mediante:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

### Inizializzazione della Catalog Authority

Il contratto S030 espone:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

Il claim iniziale:

- è esplicito;
- non viene eseguito automaticamente dal client;
- è consentito soltanto all'unico owner idoneo previsto dal contratto;
- è idempotente;
- non consente di reclamare nuovamente un'authority già inizializzata.

Lato Flutter:

```text
CatalogAuthorityRepository
```

espone il confine applicativo necessario alla lettura delle capability e al claim esplicito, senza attribuire autonomamente privilegi al client.

L'azione UI sicura per eseguire il claim iniziale rimane FUTURE.

### Regole di sicurezza comuni

Le RPC protette devono continuare a essere progettate secondo il principio del privilegio minimo, con particolare attenzione a:

- `SECURITY DEFINER` quando richiesto;
- `search_path = ''`;
- identità autenticata;
- controllo server-side di ownership oppure authority;
- capability server-side quando previste;
- privilegi `EXECUTE`;
- `REVOKE`;
- `GRANT`;
- impossibilità per il client di attribuirsi autonomamente privilegi;
- concorrenza;
- rivalidazione del lease quando prevista;
- invarianti;
- comportamento fail-closed.

L'esistenza di accesso in lettura non deve implicare automaticamente accesso in scrittura.

Allo stesso modo:

```text
utente autenticato
        ≠
Catalog Authority
```

e:

```text
Catalog Authority
        ≠
possesso automatico di ogni capability
```

Le autorizzazioni devono essere determinate dal backend.

### Stato raggiunto

Il percorso consolidato è:

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
primo Catalogo DB V1 Profile-owned implementato
        ↓
primo Write Path Catalogo verificato
        ↓
integrazione Flutter del primo Catalogo completata
        ↓
plantings implementata
        ↓
Write Path plantings verificato
        ↓
lifecycle applicativo plantings completato
        ↓
Catalog Authority globale S030
        ↓
Write Path identità / registry / ingestion / editoriali
        ↓
pubblicazione + Resolver
        ↓
cutover globale DB + Flutter
        ↓
ulteriori incrementi applicativi e Database V1
```

Il perimetro tecnico dei Write Path del Catalogo previsto dalla S030 è quindi implementato.

Restano FUTURE le interfacce applicative complete necessarie a utilizzare operativamente tutti questi Write Path, in particolare:

- UI editoriale/amministrativa del Catalogo;
- workflow UI di ingestion e revisione;
- azione UI sicura per il claim iniziale;
- integrazione completa del Resolver nei flussi operativi.

Le operazioni amministrative protette su `profile_memberships` rimangono un blocco separato ancora da implementare.

## 13.5 Relazione con il dominio applicativo

Il Database V1 non sostituisce il dominio Dart.

La separazione architetturale da preservare rimane, nel caso generale:

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
        ↓
presentazione / proposta
        ↓
eventuale decisione dell'utente
```

La S030 ha tuttavia chiarito che alcune responsabilità autoritative possono appartenere al backend senza per questo trasformare il database nel motore decisionale dell'applicazione.

Il database conserva e protegge:

- dati persistenti;
- relazioni;
- ownership;
- authority;
- capability;
- autorizzazioni;
- invarianti;
- stato concorrente;
- provenienza;
- revisioni;
- stato di pubblicazione;
- informazioni necessarie alla ricostruibilità;
- Knowledge canonica quando prevista dal dominio.

Il dominio applicativo mantiene invece la responsabilità di utilizzare i dati autoritativi nei flussi applicativi, nelle valutazioni agronomiche, nelle proposte e nelle interazioni con l'utente.

### Regole e risultati derivati

Un principio fondamentale rimane:

```text
regola persistente
        ≠
risultato derivato
```

La baseline Database V1 prevede, per esempio, regole agronomiche persistenti dalle quali può essere determinata una finestra agronomica applicabile.

`AgronomicWindow` rimane un risultato calcolato e non richiede una tabella persistente dedicata soltanto a memorizzare il risultato del calcolo.

L'evoluzione S030 non modifica questo principio.

La nuova architettura consente di rappresentare in modo più strutturato:

- parametro agronomico;
- identità agronomica;
- contesto;
- provenienza;
- osservazione;
- revisione;
- Knowledge canonica;
- pubblicazione.

Il risultato applicativo derivato da tali informazioni rimane distinto dalla Knowledge persistente da cui è stato ottenuto.

### Knowledge canonica e Resolver

Con la S030 il backend dispone di un Resolver per determinare la Knowledge canonica applicabile in funzione del contratto previsto.

Il flusso concettuale diventa:

```text
fonti / osservazioni
        ↓
workflow editoriale
        ↓
Knowledge canonica pubblicata
        ↓
Resolver
        ↓
Repository / mapping
        ↓
dominio Dart
        ↓
engine / servizio applicativo
        ↓
proposta
        ↓
eventuale conferma dell'utente
        ↓
Write Path autoritativo
        ↓
fatto operativo persistente
```

Il Resolver è autoritativo rispetto alla selezione della Knowledge prevista dal proprio contratto.

Non è invece autoritativo rispetto alla decisione operativa dell'utente.

In particolare:

```text
Knowledge risolta
        ≠
Planting modificato
```

e:

```text
raccomandazione agronomica
        ≠
fatto operativo
```

Il Resolver può quindi fornire al dominio applicativo informazioni coerenti con identità, parametro e contesto, ma non deve modificare automaticamente un Planting.

Quando una proposta comporta una modifica persistente dell'orto, il passaggio deve avvenire attraverso il flusso applicativo previsto e, quando richiesta, la conferma dell'utente.

### Plantings

Per `plantings`, il database rimane autoritativo per:

- ownership;
- relazioni;
- lifecycle;
- geometria persistita;
- date;
- overlap;
- concorrenza;
- invarianti strutturali;
- coerenza tra `crop_id` e `cultivar_id`.

Il client Flutter gestisce invece:

- presentazione;
- raccolta degli input;
- feedback;
- pre-validazioni UX;
- coordinamento con i Repository;
- utilizzo agronomico dei dati;
- presentazione delle proposte;
- acquisizione delle conferme richieste dal flusso.

Le pre-validazioni Flutter non sostituiscono mai il controllo server-side.

Allo stesso modo, una conferma dell'utente non autorizza il client a bypassare gli invarianti del backend.

Il fatto persistente deve comunque essere scritto attraverso il Write Path autoritativo previsto.

### Catalogo globale e dominio Flutter

Per il Catalogo corrente, il confine di lettura applicativo utilizza:

```text
crop_catalog_read
        ↓
CropRepository
        ↓
Crop
```

e:

```text
crop_cultivar_catalog_read
        ↓
CropCultivarRepository
        ↓
CropCultivar
```

La gestione dell'autorità utilizza invece:

```text
Catalog Authority
        ↓
capability
        ↓
RPC autoritativa
```

con integrazione Flutter attraverso:

```text
CatalogAuthorityRepository
CatalogCapabilities
```

Il client può leggere le capability che gli competono, ma non può attribuirsele autonomamente.

### Snapshot operativi e ricostruibilità storica

Il principio storico:

> **catalogo corrente + snapshot storico**

rimane valido, ma deve essere interpretato nel nuovo modello S030.

La Knowledge canonica può evolvere nel tempo senza riscrivere retroattivamente i fatti operativi già consolidati.

I valori agronomici salvati nel contesto di un Planting costituiscono snapshot operativi quando il contratto prevede che debbano rappresentare la decisione effettivamente utilizzata in quel momento.

Pertanto:

```text
Knowledge corrente aggiornata
        ≠
modifica automatica dello snapshot operativo storico
```

Le future revisioni, pubblicazioni o WITHDRAW della Knowledge non devono alterare retroattivamente decisioni operative già registrate.

La ricostruibilità deve invece permettere di distinguere:

```text
quale Knowledge era disponibile
        +
quale proposta è stata elaborata
        +
quale decisione operativa è stata confermata
        +
quale fatto è stato infine persistito
```

secondo il livello di tracciabilità previsto dal relativo dominio.

### Principio consolidato

La separazione finale da preservare è quindi:

```text
database
= persistenza + integrità + sicurezza + Knowledge autoritativa

Resolver
= selezione della Knowledge applicabile

dominio Dart
= interpretazione applicativa + valutazione + proposta

utente
= decisione quando il flusso richiede conferma

Write Path
= trasformazione autorizzata della decisione in fatto persistente
```

Nessuno di questi livelli deve assumere implicitamente le responsabilità degli altri.

## 13.6 Incrementi successivi

La sequenza tecnica consolidata fino alla conclusione della S030 è:

```text
Fondazioni
        ↓
Write Path operativi
        ↓
primo Catalogo DB V1
        ↓
plantings
        ↓
lifecycle applicativo plantings
        ↓
Catalogo Agronomico globale
        ↓
Catalog Authority
        ↓
provenienza e workflow editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione + Resolver
        ↓
cutover globale DB + Flutter
        ↓
incrementi successivi
```

La Sessione S030 ha quindi realizzato la trasformazione che, alla conclusione della S029, era ancora indicata come futura preparazione del Catalogo Agronomico V1.

Il flusso:

```text
fonte esterna
        ↓
dato candidato
        ↓
revisione
        ↓
dato approvato
        ↓
Catalogo Agronomico
```

non rappresenta più soltanto una direzione progettuale.

La S030 ha implementato il backend necessario a distinguere:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
workflow editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Resolver
```

Rimangono tuttavia incrementi successivi necessari per trasformare l'architettura tecnica implementata in un flusso operativo completo.

### Backend canonico delle associazioni colturali

Il backend canonico delle associazioni colturali non è stato implementato nella S030.

Il motore applicativo delle associazioni rimane disponibile, ma:

```text
CropAssociationRepository
```

restituisce attualmente insiemi vuoti invece di interrogare una relazione backend inesistente.

L'introduzione del modello canonico delle associazioni dovrà essere progettata e verificata in una sessione successiva.

### UI editoriale e amministrativa del Catalogo

La S030 ha implementato il backend autoritativo necessario alla gestione del Catalogo, ma non la UI editoriale/amministrativa completa.

Rimane FUTURE l'interfaccia applicativa per utilizzare in modo controllato le capability:

```text
can_manage_identity
can_ingest
can_review
can_publish
```

La UI non dovrà duplicare o sostituire le verifiche server-side.

### Aggiornamento delle fonti

La funzione operativa prevista in:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Aggiornamento fonti
```

rimane da implementare lato applicativo.

Il flusso dovrà utilizzare l'architettura S030 mantenendo la separazione:

```text
dato acquisito
        ≠
dato approvato
```

e:

```text
fonte esterna
        ≠
autorità sul Catalogo pubblicato
```

Nessuna importazione o attività di scraping potrà sovrascrivere automaticamente la Knowledge approvata.

### Claim iniziale della Catalog Authority

Il backend espone:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

ma rimane FUTURE una specifica azione UI esplicita e sicura per il claim iniziale.

Il claim non deve essere eseguito automaticamente all'avvio dell'applicazione o come effetto collaterale di una normale lettura del Catalogo.

### Integrazione completa del Resolver

Il Resolver backend è implementato.

Rimane FUTURE la sua integrazione completa nei flussi applicativi di:

- pianificazione;
- creazione delle coltivazioni;
- proposta dei parametri agronomici;
- eventuali suggerimenti contestuali.

Il principio da mantenere è:

```text
Knowledge risolta
        ↓
proposta
        ↓
conferma dell'utente quando prevista
        ↓
Write Path autoritativo
        ↓
fatto operativo
```

Il Resolver non deve modificare automaticamente un Planting esistente.

### Popolamento del Catalogo Agronomico

La struttura tecnica del Catalogo è disponibile, ma il Catalogo deve ancora essere popolato editorialmente con dati agronomici verificabili.

Il popolamento reale dovrà:

- utilizzare fonti identificabili;
- mantenere la provenienza;
- utilizzare ingestion e workflow editoriale;
- distinguere osservazioni da Knowledge canonica;
- sottoporre i dati alle revisioni previste;
- pubblicare soltanto contenuti approvati;
- evitare dati demo o provvisori persistenti.

Il database deve rimanere privo di popolamenti di prova destinati soltanto a simulare l'uso operativo.

### Avvio operativo dell'orto reale

Prima dell'introduzione dei dati reali deve essere verificato il percorso applicativo necessario alla creazione del primo Garden.

Lo smoke test finale S030 ha infatti verificato correttamente la gestione di un profilo senza Garden, ma non ha consentito il test manuale completo di Beds e Planting.

Prima dell'avvio operativo deve quindi essere verificato o ripristinato il percorso UI per:

```text
creazione Garden reale
```

La sequenza prevista per l'avvio reale rimane:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
caricamento Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle 15 Beds reali
        ↓
apertura Season reale
        ↓
registrazione Plantings reali
```

Questa fase dovrà utilizzare dati reali e non seed dimostrativi o popolamenti provvisori.

### Ulteriori incrementi Database V1

Il Database V1 rimane parzialmente implementato.

Restano quindi da affrontare progressivamente:

- ulteriori entità della baseline non ancora tradotte nello schema operativo;
- relativi vincoli e relazioni;
- RLS e privilegi;
- Write Path autoritativi dove necessari;
- Repository e modelli Dart;
- integrazione Flutter;
- test;
- documentazione.

Le operazioni amministrative protette su `profile_memberships` rimangono inoltre un blocco separato ancora da implementare.

### Regola per gli incrementi futuri

Gli incrementi successivi devono continuare a seguire il metodo consolidato:

```text
requisito concreto
        ↓
analisi delle dipendenze
        ↓
progettazione
        ↓
migration versionata
        ↓
sicurezza
        ↓
test positivi e negativi
        ↓
integrazione applicativa
        ↓
verifica
        ↓
documentazione
```

Le funzionalità FUTURE non devono essere rappresentate come già operative soltanto perché il backend dispone di una parte delle strutture necessarie.

Allo stesso modo, la presenza di un'interfaccia applicativa non deve essere considerata sufficiente quando manca ancora il relativo contratto autoritativo server-side.

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
- modelli di authority e capability;
- provenienza dei dati quando rilevante;
- workflow editoriali;
- regole di revisione e immutabilità;
- Knowledge canonica;
- meccanismi di pubblicazione e WITHDRAW;
- Resolver server-side;
- read model;
- test di integrazione e sicurezza;
- eventuali differenze motivate rispetto alla baseline progettuale.

Anche le integrazioni Flutter che modificano il rapporto tra Repository Layer e contratti persistenti devono essere riportate quando incidono sull'architettura complessiva di accesso ai dati.

La documentazione deve inoltre distinguere chiaramente:

```text
baseline progettuale storica
        ↓
implementazione effettivamente raggiunta
        ↓
stato corrente
        ↓
incrementi FUTURE
```

Una decisione valida nel proprio contesto storico non deve essere riscritta retroattivamente soltanto perché una sessione successiva introduce un'architettura più evoluta.

Quando una nuova decisione sostituisce operativamente una precedente, la relazione deve essere dichiarata esplicitamente mantenendo la tracciabilità storica.

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
- **DOC-011 — Decisioni Architetturali** conserva le decisioni progettuali approvate, compresa la DEC-015 relativa all'architettura globale, multisorgente ed editoriale del Catalogo Agronomico V1;
- **DOC-012 — Registro Storico dello Sviluppo** mantiene il riepilogo storico complessivo;
- **CHANGELOG** registra sinteticamente le modifiche introdotte nelle diverse versioni.

Il **DOC-004 — Manuale Database** costituisce il riferimento specifico per la struttura persistente e per l'evoluzione del Database V1.

---

La baseline S017 descritta nel presente documento rimane il riferimento storico e architetturale dal quale è iniziata l'implementazione del Database V1.

L'implementazione successiva ha però introdotto evoluzioni esplicite, versionate e verificate.

Il principio da mantenere durante le successive sessioni è:

```text
prima progettare
        ↓
poi implementare
        ↓
sempre verificare
```

La progettazione S017 non deve essere modificata retroattivamente.

Le evoluzioni necessarie devono invece essere introdotte attraverso decisioni architetturali, migration e verifiche tracciabili.

### Evoluzione S028 e S029

La Sessione S028 ha completato il modello persistente e il Write Path autoritativo delle coltivazioni.

In quella fase:

- `public.plantings` è stata consolidata;
- il Write Path autoritativo di `plantings` è stato implementato;
- il lifecycle autoritativo è stato implementato server-side;
- la geometria delle aiuole è stata protetta rispetto alle coltivazioni esistenti;
- `PlantingRepository` e la UI di creazione/modifica sono stati riallineati al contratto persistente allora vigente;
- il modello utilizzava ancora la terminologia e la relazione storica della varietà successivamente sostituite dalla S030.

La Sessione S029 non ha modificato il contratto persistente definito nella S028.

Non sono state introdotte nuove:

```text
migration
modifiche schema
RPC
policy RLS
```

La S029 ha invece completato il livello applicativo del lifecycle delle coltivazioni riutilizzando:

```text
set_planting_status
```

attraverso il Repository Layer.

Alla conclusione della S029 risultavano disponibili:

- UI delle transizioni lifecycle previste dal contratto server-side;
- conferma esplicita di `end_date` per `finished` e `removed`;
- mantenimento di `end_date = null` nelle transizioni intermedie;
- mantenimento dell'occupazione dell'aiuola nello stato `harvested`;
- refresh autoritativo in caso di `version_conflict`;
- refresh autoritativo in caso di `invalid_transition`;
- azioni contestuali in `PlantingCard` coerenti con lo stato corrente.

La verifica applicativa finale S029 aveva confermato:

```text
flutter test finale:           1011/1011 test passati
bed_page_test.dart:              30/30 test passati
planting_card_test.dart:           9/9 test passati
flutter analyze finale:           No issues found! (ran in 12.8s)
```

Questi dati rimangono parte della cronologia verificata S029 e non devono essere interpretati come conteggio della suite corrente dopo la successiva trasformazione S030.

### Evoluzione S030

La Sessione S030 ha introdotto un'evoluzione architetturale sostanziale del Catalogo Agronomico V1.

Il Catalogo è passato dal precedente modello Profile-owned a un modello:

- globale;
- multisorgente;
- tracciabile;
- versionabile;
- contestualizzabile;
- editorialmente controllato;
- separato dai dati operativi del singolo orto.

La realizzazione è stata suddivisa in undici tranche tecniche:

1. identità globali;
2. registry dei parametri agronomici;
3. vocabolari di contesto;
4. fonti, acquisizioni e osservazioni;
5. alias delle identità agronomiche;
6. workflow editoriale;
7. Knowledge agronomica canonica;
8. hardening dell'integrità;
9. Write Path autoritativi;
10. pubblicazione e Resolver;
11. cutover globale finale DB + Flutter.

Il perimetro finale del nuovo Catalogo Agronomico comprende **26 tabelle**.

La catena canonica corrente delle identità è:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

Il cutover finale ha rimosso dal modello corrente:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Tali nomi possono continuare a comparire nel presente documento esclusivamente quando necessari a descrivere correttamente la baseline o la cronologia delle sessioni precedenti.

### Plantings dopo il cutover S030

Il modello corrente di `plantings` utilizza:

```text
crop_id
cultivar_id
```

dove `cultivar_id` è facoltativo.

La coerenza tra cultivar e coltura è protetta mediante relazione composita verso:

```text
crop_cultivars(id, crop_id)
```

Il precedente:

```text
variety_id
```

è stato rimosso dal contratto persistente corrente.

Gli eventuali riferimenti a `variety_id` nelle sezioni storiche descrivono esclusivamente lo stato precedente al cutover S030.

### Authority e Write Path del Catalogo

La S030 ha introdotto una Catalog Authority globale con capability distinte per:

- gestione delle identità;
- ingestion;
- review;
- publication.

Il client Flutter non determina autonomamente tali autorizzazioni.

Il backend rimane autoritativo.

Sono inoltre disponibili:

```text
get_my_catalog_capabilities()
claim_initial_catalog_authority()
```

con bootstrap esplicito della prima authority idonea.

Il claim:

- non è automatico;
- è idempotente;
- richiede l'idoneità prevista dal contratto;
- non consente di reclamare nuovamente un'authority già inizializzata.

La relativa azione UI esplicita e sicura rimane FUTURE.

### Provenienza, workflow e Knowledge

La S030 ha implementato la separazione tra:

```text
fonte
        ↓
acquisizione
        ↓
osservazione
        ↓
workflow editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
```

Un dato proveniente da una fonte esterna non diventa automaticamente Knowledge canonica.

La provenienza rimane tracciabile e le revisioni editoriali utilizzano una catena esplicita attraverso:

```text
previous_revision_id
```

Il semantic freeze protegge gli artefatti divenuti immutabili secondo il relativo contratto.

Il WITHDRAW deve mantenere la ricostruibilità del contenuto canonico necessario alla tracciabilità storica.

Nessuna fonte esterna può sovrascrivere automaticamente il Catalogo approvato.

### Resolver

La S030 ha introdotto il Resolver server-side della Knowledge agronomica.

Il Resolver determina la Knowledge canonica applicabile secondo il proprio contratto, ma non prende automaticamente la decisione operativa al posto del dominio applicativo o dell'utente.

Il principio corrente è:

```text
Knowledge canonica
        ↓
Resolver
        ↓
dominio applicativo
        ↓
proposta
        ↓
eventuale conferma dell'utente
        ↓
Write Path autoritativo
        ↓
fatto operativo
```

I valori agronomici persistiti nel contesto operativo di un Planting rimangono snapshot della decisione effettivamente adottata quando il relativo contratto ne prevede la memorizzazione.

Una successiva evoluzione della Knowledge non deve modificarli automaticamente.

### Read model e integrazione Flutter

Il confine di lettura corrente del Catalogo utilizza:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati con:

```text
security_invoker = true
```

L'integrazione Flutter utilizza:

```text
CropRepository
CropCultivarRepository
CatalogAuthorityRepository
CatalogCapabilities
```

La terminologia tecnica corrente utilizza:

```text
cultivarId
cultivar_id
CropCultivar
```

mentre l'interfaccia utente italiana può continuare a utilizzare il termine **Varietà** quando appropriato per l'utente finale.

Il `RotationEngine` confronta l'identificativo UUID canonico della famiglia botanica; il nome della famiglia rimane un'informazione di presentazione.

Il backend canonico delle associazioni colturali non è ancora implementato.

Per evitare dipendenze verso una relazione inesistente, `CropAssociationRepository` restituisce attualmente insiemi vuoti; il relativo backend rimane FUTURE.

### Verifiche finali S030

La verifica tecnica conclusiva S030 ha confermato:

```text
supabase db reset:             completato con successo
DB lint locale:                No schema errors found
DB lint remoto:                No schema errors found
Acceptance Tranche 10:         superata
Acceptance Tranche 11:         superata
flutter analyze:               No issues found
flutter test:                  953 test passati
```

Le fixture utilizzate nelle verifiche di acceptance sono state sottoposte a rollback e non sono rimasti dati di prova persistenti.

La migration finale:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

risulta applicata anche al database remoto.

Lo stato delle migration verificato alla chiusura tecnica S030 era:

```text
locale:  20260923154831
remoto:  20260923154831
```

Lo smoke test finale su Edge ha inoltre verificato:

- Dashboard funzionante;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto “Nessuna varietà presente” correttamente gestito;
- assenza del precedente pulsante di aggiunta;
- corretta gestione del profilo privo di Garden.

Il test manuale completo di Beds e Planting non è stato possibile in tale smoke test perché il profilo utilizzato non disponeva di un Garden.

### Stato corrente e incrementi aperti

Alla conclusione tecnica della S030 il perimetro backend previsto per la nuova architettura del Catalogo Agronomico è implementato e verificato.

Restano FUTURE, tra gli altri:

- backend canonico delle associazioni colturali;
- UI editoriale e amministrativa completa del Catalogo;
- azione UI esplicita e sicura per il claim iniziale della Catalog Authority;
- flusso operativo di ingestion/import/review in `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- schermate del workflow editoriale;
- integrazione completa del Resolver nei flussi di pianificazione e creazione dei Planting;
- popolamento editoriale del Catalogo con dati agronomici verificabili;
- smoke test con dati operativi reali;
- manutenzione periodica ISO 3166-1 alpha-2 mediante migration e test verificati, mai automatica;
- verifica o ripristino del percorso UI per la creazione del primo Garden;
- ulteriori sviluppi delle aree del Database V1 non ancora implementate.

Il Database V1 complessivo rimane pertanto **parzialmente implementato**.

L'avvio operativo con dati reali dovrà avvenire soltanto dopo la disponibilità di una baseline verificata del Catalogo Agronomico e seguire la sequenza:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
caricamento Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle 15 Beds reali
        ↓
apertura Season reale
        ↓
registrazione Plantings reali
```

Non devono essere introdotti seed dimostrativi o dati provvisori destinati soltanto a simulare l'uso reale.

La S030 conferma infine il principio architetturale generale secondo cui:

```text
backend implementato
        ≠
funzione applicativa completa
```

e:

```text
dato esterno disponibile
        ≠
Knowledge approvata
```

e:

```text
Knowledge risolta
        ≠
decisione operativa automatica
```

Schema, sicurezza, authority, integrazione applicativa, interazione utente e documentazione devono continuare a evolvere come livelli distinti ma coerenti.

## Conclusione

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

La baseline S017 descritta nel presente documento costituisce il riferimento storico e architetturale controllato da cui è partita l'implementazione progressiva del Database V1 di Orto Smart.

Le successive evoluzioni approvate, comprese quelle introdotte dalla Sessione S030, fanno parte della storia architetturale ufficiale del progetto e devono essere mantenute esplicite, versionate e verificabili.

Il principio da mantenere durante le successive sessioni è:

```text
prima progettare
        ↓
poi implementare
        ↓
sempre verificare
```

La baseline S017 non deve essere modificata retroattivamente per farla coincidere con lo stato fisico corrente.

Quando emerge una necessità architetturale concreta, l'evoluzione deve invece essere:

```text
analizzata
        ↓
approvata
        ↓
implementata mediante migration e codice versionati
        ↓
verificata
        ↓
documentata come evoluzione della baseline
```

La Sessione S030 costituisce un esempio di questa regola: il precedente Catalogo DB V1 Profile-owned non è stato riscritto retroattivamente nella storia del progetto, ma è stato evoluto esplicitamente verso il nuovo **Catalogo Agronomico V1 globale, multisorgente, tracciabile, versionabile, contestualizzabile ed editorialmente controllato**.

Alla conclusione della S030 il contratto corrente comprende, tra gli elementi principali:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

insieme a:

- Catalog Authority e capability dedicate;
- registry dei parametri agronomici;
- vocabolari di contesto;
- fonti, acquisizioni e osservazioni;
- alias e mapping delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione e WITHDRAW tracciabili;
- Resolver;
- read model canonici;
- Write Path autoritativi;
- integrazione Flutter coerente con il nuovo contratto;
- `plantings` riallineati a `crop_id` e `cultivar_id` opzionale.

La verifica tecnica S030 ha confermato:

```text
supabase db reset
completato con successo

DB lint locale
No schema errors found

DB lint remoto
No schema errors found

Acceptance Tranche 10
superata

Acceptance Tranche 11
superata

migration finale locale
20260923154831

migration finale remota
20260923154831

flutter analyze
No issues found

flutter test
953 test passati
```

Le fixture di verifica sono state sottoposte a rollback e il database deve continuare a rimanere privo di dati demo o provvisori fino all'avvio della gestione reale dell'orto.

Il Database V1 complessivo rimane **parzialmente implementato**.

Gli incrementi successivi devono proseguire secondo lo stesso principio:

```text
baseline storica
        +
decisioni architetturali versionate
        +
migration riproducibili
        +
sicurezza server-side
        +
integrazione applicativa controllata
        +
test
        +
documentazione coerente
```

In questo modo il Manuale Database conserva contemporaneamente la storia progettuale, lo stato fisico effettivamente raggiunto e la direzione delle evoluzioni future, senza confondere ciò che era valido in una fase precedente con il contratto corrente.