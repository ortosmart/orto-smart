# VERSION

| Campo | Valore |
| ----------------- | -------------------- |
| Progetto | Orto Smart |
| Versione corrente | 0.1.21-alpha |
| Versione Flutter | 0.1.21-alpha+6 |
| Stato | Alpha |
| Data versione | 27/09/2026 |
| Linguaggio | Flutter / Dart |
| Backend | Supabase |
| Repository | ortosmart/orto-smart |

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

La versione pubblica era quindi passata a:

```text
0.1.18-alpha
```

e il file `pubspec.yaml` era stato riallineato a:

```text
0.1.18-alpha+3
```

Con la Sessione S028 sono stati modificati sia il Database V1 sia il client Flutter.

La versione pubblica era quindi passata a:

```text
0.1.19-alpha
```

e la versione Flutter era stata aggiornata a:

```text
0.1.19-alpha+4
```

Con la Sessione S029 è stato completato il livello applicativo del lifecycle delle coltivazioni, riutilizzando il Write Path autoritativo introdotto nella S028 senza modificare il contratto persistente del Database V1.

La versione pubblica era quindi passata a:

```text
0.1.20-alpha
```

e la versione Flutter era stata aggiornata a:

```text
0.1.20-alpha+5
```

La S029 ha introdotto in particolare:

- UI completa del lifecycle di `plantings`;
- azioni contestuali in `PlantingCard`;
- gestione esplicita di `end_date` per gli stati terminali `finished` e `removed`;
- mantenimento dell'occupazione dell'aiuola nello stato `harvested`;
- refresh autoritativo su `version_conflict` e `invalid_transition`;
- nessuna nuova migration;
- nessuna nuova RPC;
- nessuna modifica alle policy RLS.

La verifica tecnica finale della S029 è stata:

```text
flutter test finale:
1011/1011 test passati

bed_page_test.dart:
30/30 test passati

planting_card_test.dart:
9/9 test passati

flutter analyze finale:
No issues found! (ran in 12.8s)
```

Il dato di 1011 test rappresenta la suite completa finale effettivamente eseguita dopo l'aggiunta dell'ultimo test dedicato a `PlantingCard`.

Le verifiche dedicate di `BedPage` e `PlantingCard` restano confermate come controlli specifici aggiuntivi rispetto alla suite completa.

Con la Sessione S030 è stata completata l'architettura globale del **Catalogo Agronomico V1**, sostituendo il precedente modello di catalogo personale Profile-owned introdotto nelle S026–S027.

La versione pubblica passa pertanto a:

```text
0.1.21-alpha
```

e, poiché la S030 ha comportato anche il riallineamento del client Flutter al nuovo contratto del Catalogo Agronomico globale, la versione Flutter viene aggiornata a:

```text
0.1.21-alpha+6
```

La S030 introduce e consolida in particolare:

- identità botaniche globali canoniche mediante `botanical_taxa`;
- separazione tra identità botaniche e conoscenza agronomica;
- normalizzazione canonica dei testi del Catalogo;
- Catalog Authority globale con capability distinte per gestione identità, ingestion, review e publishing;
- registro dei parametri agronomici;
- vocabolari e contesti agronomici;
- fonti, acquisizioni e osservazioni tracciabili;
- alias e riconciliazione delle identità agronomiche;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione e versionamento della Knowledge;
- Resolver del Catalogo Agronomico;
- read model canonici `crop_catalog_read` e `crop_cultivar_catalog_read`;
- modello canonico `crops` e `crop_cultivars`;
- migrazione del contratto `plantings` da `variety_id` a `cultivar_id`;
- riallineamento Flutter da `CropVariety` / `varietyId` a `CropCultivar` / `cultivarId`;
- introduzione di `CatalogCapabilities` e `CatalogAuthorityRepository`;
- rimozione dei precedenti percorsi applicativi di gestione personale del catalogo;
- cutover finale dal precedente Catalogo DB V1 al nuovo Catalogo Agronomico globale;
- **26 tabelle** nel perimetro del nuovo Catalogo Agronomico S030.

Il cutover finale ha rimosso le precedenti strutture:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

e ha consolidato come strutture canoniche:

```text
botanical_taxa
crops
crop_cultivars
```

Il modello `plantings` utilizza ora:

```text
crop_id
cultivar_id
```

con `cultivar_id` opzionale e vincolo composto tra cultivar e coltura.

La S030 mantiene il principio secondo cui i dati provenienti da fonti esterne non possono diventare automaticamente dati operativi né sovrascrivere automaticamente dati approvati del Catalogo.

Il flusso concettuale consolidato è:

```text
Fonte esterna
        ↓
importazione / ingestion
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione
        ↓
Catalogo Agronomico
```

La verifica tecnica finale della S030 comprende:

```text
supabase db reset:
success

DB lint locale:
No schema errors found

DB lint remoto:
No schema errors found

Acceptance Tranche 10:
superata

Acceptance Tranche 11:
superata

dart format lib test:
Formatted 174 files

flutter analyze:
No issues found!

flutter test:
953 test passati

git diff --check:
nessuna anomalia
```

La migration finale del cutover è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

ed è stata applicata sia al database locale sia al database remoto, verificando l'allineamento alla stessa migration finale.

Lo smoke test applicativo finale in Edge ha inoltre verificato:

- Dashboard raggiungibile;
- assenza di eccezioni applicative;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto “Nessuna varietà presente” correttamente gestito;
- assenza del precedente pulsante di aggiunta della varietà personale;
- corretta gestione di un Profile privo di Garden.

Il test manuale di aiuole e `Planting` non è stato eseguibile nello smoke test finale esclusivamente perché il Profile utilizzato non contiene ancora un Garden.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori. Il popolamento operativo dovrà iniziare soltanto con dati reali e con una baseline verificata e approvata del Catalogo Agronomico.

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

Con la versione `0.1.17-alpha`, corrispondente alla Sessione S026, è stato implementato il primo **Catalogo DB V1**:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

Il catalogo era Profile-owned e condiviso tra i Gardens appartenenti allo stesso Profile.

Sono state introdotte le migration:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

Le entità del catalogo utilizzavano identificativi UUID.

Il Catalogo DB V1 introduceva inoltre:

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

Le scritture dirette sulle tre entità del catalogo non costituivano il Write Path applicativo.

Il percorso autoritativo era:

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

Le letture erano protette mediante RLS.

La S026 ha verificato il catalogo mediante test SQL positivi, negativi e concorrenti e ha mantenuto allineate le migration locali e remote fino a:

```text
20260911091047_add_crop_catalog_write_rpcs.sql
```

La versione `0.1.17-alpha` non aveva modificato il client Flutter; per questo `pubspec.yaml` era rimasto temporaneamente a:

```text
0.1.16-alpha+2
```

Con la versione `0.1.18-alpha`, corrispondente alla Sessione S027, è stata completata l'**integrazione Flutter del primo Catalogo V1**.

È stato introdotto il modello dedicato:

```text
BotanicalFamily
```

e sono stati riallineati al contratto Database V1:

```text
Crop
CropVariety
```

`Crop` utilizzava, tra gli altri:

- `profileId`;
- `botanicalFamilyId`;
- `defaultStartMethod`;
- parametri agronomici V1;
- fabbisogno idrico quantitativo;
- dati di resa;
- `isActive`;
- `rowVersion`;
- timestamp.

`CropVariety` utilizzava:

- `id`, `profileId` e `cropId` come UUID `String`;
- `defaultStartMethod`;
- override agronomici V1;
- fabbisogno idrico quantitativo;
- dati di resa;
- `rowVersion`;
- timestamp.

Era stato rimosso:

```text
CropVariety.toMap()
```

per evitare un percorso generico di scrittura diretta non coerente con l'architettura RPC-only.

Il Repository Layer del catalogo comprendeva:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

Le letture erano eseguite sotto protezione RLS.

Le scritture utilizzavano esclusivamente le nove RPC autoritative introdotte nella S026.

Nei Repository del catalogo era stata verificata l'assenza di utilizzi diretti di:

```text
.insert()
.update()
.delete()
.upsert()
```

Erano stati introdotti result type dedicati con mapping esplicito degli esiti RPC, compresi:

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

La Profile Write Authority continuava a operare in modalità **fail-closed**.

La S027 aveva mantenuto temporaneamente alcuni alias legacy:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

per garantire la compatibilità con componenti non ancora migrati.

Gli alias non costituivano il nuovo contratto persistente ed erano destinati alla progressiva rimozione.

La Sessione S027 non ha introdotto nuove migration Supabase.

La verifica applicativa S027 ha prodotto:

```text
124 test mirati superati
914/914 test complessivi superati
flutter analyze: No issues found!
git diff --check: pulito
git diff --cached --check: pulito
```

Con la versione `0.1.19-alpha`, corrispondente alla Sessione S028, è stato implementato il **modello autoritativo di `plantings`**.

Sono state introdotte le migration:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

Il modello persistente di `plantings` introdotto nella S028 comprendeva:

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

Le relazioni tra Profile, Garden, Season, Bed, Crop e Variety erano validate lato database.

Sono stati consolidati i quattro metodi di avvio persistenti:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il valore legacy:

```text
manual
```

rimane soltanto un concetto applicativo relativo al posizionamento e non costituisce un metodo agronomico persistito.

Sono state introdotte le RPC:

```text
create_planting
update_planting
set_planting_status
```

Le scritture Flutter su `plantings` utilizzano esclusivamente il Write Path autoritativo RPC-only.

`PlantingRepository` espone:

```text
getPlantingsByBed
createPlanting
updatePlanting
setPlantingStatus
```

La Profile Write Authority rimane prerequisito delle scritture protette e opera in modalità fail-closed.

La concorrenza ottimistica utilizza `row_version`.

La geometria longitudinale della coltivazione utilizza l'intervallo half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

Due coltivazioni possono quindi toccarsi sul confine senza essere considerate sovrapposte.

La larghezza occupata deve rispettare:

```text
(rows_count - 1) * row_spacing_cm <= occupied_width_cm
```

La disposizione delle piante deve rispettare:

```text
(plants_count - 1) * plant_spacing_cm <= length_cm
```

Il calcolo utilizza il numero totale di piante.

La sovrapposizione viene bloccata soltanto quando sono contemporaneamente presenti:

- overlap temporale;
- overlap longitudinale.

La geometria di una coltivazione deve inoltre essere compatibile con tutte le geometrie dell'aiuola temporalmente sovrapposte al periodo di occupazione.

Le RPC:

```text
change_bed_geometry
correct_bed_geometry
```

sono state rafforzate per impedire variazioni incompatibili con coltivazioni esistenti.

È stato introdotto l'esito:

```text
blocked_by_plantings
```

Il lifecycle autoritativo comprende:

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

Gli stati iniziali dipendono dal metodo:

```text
purchased_seedlings      → growing
nursery_then_transplant  → growing
direct_rows              → sown
direct_broadcast         → sown
```

`start_date` rappresenta l'inizio effettivo dell'occupazione dell'aiuola e non può essere futuro.

`end_date`:

- deve essere `NULL` negli stati intermedi;
- è obbligatorio per `finished`;
- è obbligatorio per `removed`;
- deve essere maggiore o uguale a `start_date`;
- non può essere futuro.

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

terminano l'occupazione fisica.

Non è stato introdotto un normale hard delete applicativo di `plantings`.

L'eventuale hard delete rimane FUTURE e dovrà essere riservato a operazioni amministrative o tecniche eccezionali di correzione.

Sul lato Flutter sono stati riallineati al contratto S028:

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

È stato inoltre introdotto:

```text
lib/core/write_authority/planting_write_result.dart
```

La S028 ha verificato:

```text
supabase db reset
success

supabase db lint --local
No schema errors found

flutter analyze
No issues found!

flutter test
997/997 test superati
```

Con la versione `0.1.20-alpha`, corrispondente alla Sessione S029, è stato completato il livello applicativo del lifecycle delle coltivazioni reali senza modificare il contratto persistente introdotto nella S028.

La S029 ha completato:

- visualizzazione delle sole transizioni lifecycle consentite;
- azioni contestuali in `PlantingCard`;
- gestione esplicita di `end_date` per `finished` e `removed`;
- proposta del giorno corrente come valore iniziale della data terminale, mantenendola modificabile;
- assenza di chiusura implicita della coltivazione;
- mantenimento dell'occupazione dell'aiuola nello stato `harvested`;
- rilascio dello spazio soltanto con `finished` o `removed`;
- gestione esplicita degli esiti RPC del lifecycle;
- gestione dei conflitti concorrenti;
- refresh autoritativo dell'aiuola dopo `version_conflict` e `invalid_transition`;
- test dedicati al lifecycle e alle date terminali.

La verifica finale S029 ha prodotto:

```text
flutter test:
1011/1011 test passati

bed_page_test.dart:
30/30 test passati

planting_card_test.dart:
9/9 test passati

flutter analyze:
No issues found! (ran in 12.8s)
```

La Sessione S029 non ha introdotto nuove migration Supabase né modificato il contratto persistente S028.

Con la versione `0.1.21-alpha`, corrispondente alla Sessione S030, è stata completata l'architettura del **Catalogo Agronomico V1 globale**.

La S030 supera il precedente modello Profile-owned delle S026–S027 e separa in modo esplicito:

```text
identità botanica globale
        ↓
identità agronomica globale
        ↓
conoscenza agronomica canonica
        ↓
pubblicazione
        ↓
Resolver
        ↓
uso operativo
```

Il Catalogo Agronomico corrente è progettato per essere:

- globale;
- multisource;
- tracciabile;
- versionabile;
- contestualizzabile;
- editorialmente controllato;
- separato dai dati operativi del singolo orto.

## Identità botaniche globali

La tassonomia botanica canonica è rappresentata da:

```text
botanical_taxa
```

con rank:

```text
FAMILY
GENUS
SPECIES
VARIETY
CULTIVAR
```

La normalizzazione canonica dei testi utilizza:

```text
private.normalize_catalog_text(text)
```

con normalizzazione Unicode, trim, riduzione degli spazi e normalizzazione per il confronto.

## Catalog Authority

L'autorità globale del Catalogo è rappresentata da:

```text
catalog_authorities
```

con capability distinte per:

- gestione delle identità;
- ingestion;
- review;
- publishing.

Le capability dell'utente corrente possono essere lette mediante:

```text
get_my_catalog_capabilities()
```

L'inizializzazione esplicita dell'autorità iniziale utilizza:

```text
claim_initial_catalog_authority()
```

La claim:

- non è automatica;
- è consentita soltanto all'unico owner idoneo;
- è idempotente;
- non consente di reclamare nuovamente un'autorità già inizializzata.

Le funzioni sensibili sono `SECURITY DEFINER`, utilizzano `search_path` vuoto e non concedono `EXECUTE` ad `anon`.

## Conoscenza agronomica

La S030 introduce:

- registro dei parametri agronomici;
- vocabolari e contesti;
- fonti;
- acquisizioni;
- osservazioni;
- alias;
- riconciliazione delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione e versionamento;
- Resolver.

Il flusso concettuale approvato è:

```text
Fonte esterna
        ↓
importazione / ingestion
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione
        ↓
Catalogo Agronomico
```

I dati provenienti da fonti esterne non possono:

- diventare automaticamente dati operativi;
- sovrascrivere automaticamente dati approvati del Catalogo.

Il dato candidato rimane quindi separato dal dato canonico approvato.

Le revisioni mantengono una catena esplicita mediante:

```text
previous_revision_id
```

Il freeze semantico inizia dal primo artefatto immutabile.

Lo stato `NOT_MAPPABLE` è ammesso esclusivamente nei casi `CONFLICTING` e `CONTEXTUAL`.

Le operazioni di WITHDRAW devono conservare il contenuto canonico necessario alla tracciabilità.

## Modello canonico corrente

Il cutover finale S030 ha rimosso:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

e consolidato:

```text
botanical_taxa
crops
crop_cultivars
```

Il perimetro del nuovo Catalogo Agronomico S030 comprende **26 tabelle**.

I read model canonici sono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati con:

```text
security_invoker = true
```

Il modello `plantings`, originariamente introdotto nella S028 con `variety_id`, è stato migrato al contratto corrente:

```text
crop_id
cultivar_id
```

`cultivar_id` è opzionale.

La coerenza tra cultivar e coltura è garantita mediante il vincolo composto:

```text
(cultivar_id, crop_id)
        ↓
crop_cultivars(id, crop_id)
```

Il precedente `variety_id` è stato rimosso.

## Flutter

Il client Flutter è stato riallineato al nuovo contratto globale.

La terminologia tecnica corrente utilizza:

```text
CropCultivar
cultivarId
cultivar_id
```

al posto di:

```text
CropVariety
varietyId
variety_id
crop_variety
```

La UI italiana può continuare a utilizzare il termine **Varietà** come etichetta destinata all'utente.

Sono stati introdotti:

```text
CatalogCapabilities
CropCultivar
CatalogAuthorityRepository
CropCultivarRepository
```

`CropRepository` legge il read model:

```text
crop_catalog_read
```

e non espone più i precedenti percorsi di scrittura del catalogo personale.

`CropCultivarRepository` legge:

```text
crop_cultivar_catalog_read
```

`CatalogAuthorityRepository` espone la lettura delle capability e la claim esplicita dell'autorità iniziale.

La claim dell'autorità non viene eseguita automaticamente.

Sono stati rimossi dal contratto Flutter corrente:

- modello e Repository personali delle famiglie botaniche;
- `CropVariety`;
- `CropVarietyRepository`;
- result type delle precedenti scritture personali delle varietà;
- result type delle precedenti scritture personali delle colture;
- pagina personale di aggiunta della varietà;
- relativi test legacy.

`RotationEngine` confronta la famiglia botanica mediante UUID canonico; il nome della famiglia rimane un dato di presentazione.

Il backend canonico delle consociazioni non è ancora stato implementato.

Per questo motivo `CropAssociationRepository` restituisce attualmente insiemi vuoti invece di interrogare una relazione canonica inesistente, mentre il motore delle consociazioni rimane disponibile.

Il backend canonico delle associazioni è FUTURE.

La catena operativa di `Planting` è stata migrata da Variety a Cultivar.

I valori agronomici memorizzati sul `Planting` rimangono snapshot operativi: il Resolver può proporre valori, ma non deve modificare automaticamente un `Planting` senza conferma dell'utente.

`AddPlantingPage` non espone ancora un selettore operativo della cultivar.

In creazione:

```text
cultivarId: null
```

In modifica viene preservato:

```text
planting.cultivarId
```

La selezione esplicita della cultivar nella UI di creazione rimane FUTURE.

## Verifica tecnica S030

La migration finale del cutover è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

La stessa migration finale risulta applicata sia localmente sia sul database remoto.

La verifica finale comprende:

```text
supabase db reset
success

DB lint locale
No schema errors found

DB lint remoto
No schema errors found

Acceptance Tranche 10
superata

Acceptance Tranche 11
superata

dart format lib test
Formatted 174 files

flutter analyze
No issues found!

flutter test
953 test passati

git diff --check
nessuna anomalia
```

Lo smoke test finale in Edge ha verificato:

- Dashboard funzionante;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto “Nessuna varietà presente” correttamente gestito;
- assenza del precedente pulsante di aggiunta della varietà personale;
- corretta gestione di un Profile privo di Garden.

Il test manuale delle aiuole e dei `Planting` non è stato eseguibile esclusivamente perché il Profile utilizzato nello smoke test non dispone ancora di un Garden.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

Il popolamento operativo dovrà iniziare soltanto con dati reali e dopo la disponibilità di una baseline verificata e approvata del Catalogo Agronomico.

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
creazione delle 15 aiuole reali
        ↓
apertura stagione reale
        ↓
registrazione delle coltivazioni reali
```

# Funzionalità implementate

## Gestione dati

- Gestione orti
- Gestione aiuole
- Gestione stagioni
- Modello persistente autoritativo `plantings`
- Modello Flutter `Planting` allineato al contratto corrente
- Repository Flutter autoritativo per `plantings`
- Lifecycle server-side delle coltivazioni
- Validazione spaziale e temporale dell'occupazione delle aiuole
- Catalogo Agronomico V1 globale
- Tassonomia botanica globale mediante `botanical_taxa`
- Identità agronomiche globali mediante `crops` e `crop_cultivars`
- Separazione tra identità botaniche, identità agronomiche e conoscenza agronomica
- Registro dei parametri agronomici
- Vocabolari e contesti agronomici
- Fonti, acquisizioni e osservazioni
- Alias e riconciliazione delle identità
- Workflow editoriale
- Knowledge agronomica canonica
- Pubblicazione e versionamento della Knowledge
- Resolver della conoscenza agronomica
- Read model canonici `crop_catalog_read` e `crop_cultivar_catalog_read`
- Tracciabilità multisource dei dati agronomici
- Separazione tra dati candidati e dati canonici approvati
- Catena esplicita delle revisioni mediante `previous_revision_id`
- Modello globale di Catalog Authority
- Capability distinte per identity management, ingestion, review e publishing
- Migrazione di `plantings` dal precedente `variety_id` al corrente `cultivar_id`
- Vincolo di coerenza tra `cultivar_id` e `crop_id`
- Snapshot agronomici operativi conservati sul `Planting`

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
- Inserimento delle coltivazioni riallineato al contratto corrente
- Modifica delle coltivazioni riallineata al contratto corrente
- Gestione dei quattro metodi di avvio persistenti
- Controllo delle date non future
- Validazione della geometria e dei sesti
- UI del lifecycle di `plantings`
- Azioni contestuali in `PlantingCard`
- Gestione esplicita di `end_date` per `finished` e `removed`
- Mantenimento dell'occupazione dell'aiuola nello stato `harvested`
- Rilascio dello spazio soltanto con `finished` o `removed`
- Refresh autoritativo su `version_conflict` e `invalid_transition`
- Pagina Varietà collegata al Catalogo globale in sola lettura
- Stato vuoto “Nessuna varietà presente”
- Rimozione del precedente pulsante di aggiunta della varietà personale
- Gestione corretta di un Profile privo di Garden

La UI amministrativa/editoriale completa del Catalogo Agronomico non è ancora implementata.

`AddPlantingPage` non espone ancora un selettore operativo della cultivar.

In creazione viene utilizzato:

```text
cultivarId: null
```

mentre in modifica viene preservato:

```text
planting.cultivarId
```

La selezione esplicita della cultivar nella creazione di un `Planting` rimane FUTURE.

## Motore agronomico

- `PlantingValidator`
- `FreeSpaceEngine`
- `SuggestionEngine`
- `CompanionEngine`
- `BedAnalysisService`
- `BedCompanionAnalyzer`
- `RecommendationPipeline`
- `RecommendationMapper`
- `SpaceScoreCalculator`
- `DecisionEngine`
- `DecisionWeights`
- `FamilyNeedsEngine`
- `FamilyConsumptionNeed`
- `FamilyConsumptionNeedValidator`
- `PlannedPlantingBatch`
- `PlannedPlantingBatchValidator`
- `SuccessionPlanningEngine`
- `AgronomicWindow`
- `AgronomicWindowValidator`
- `AgronomicWindowEngine`
- `CropAgronomicWindowRule`
- `AgronomicWindowResolver`
- `AgronomicWindowEvaluation`
- `AgronomicWindowService`
- `RotationEngine` riallineato alle famiglie botaniche canoniche mediante UUID

`AgronomicWindowResolver`, appartenente al motore delle finestre agronomiche, rimane distinto dal Resolver introdotto nella S030 per la Knowledge del Catalogo Agronomico.

Il motore delle consociazioni rimane disponibile a livello applicativo.

Il backend canonico delle associazioni tra colture non è ancora implementato; `CropAssociationRepository` restituisce attualmente insiemi vuoti anziché interrogare una relazione canonica inesistente.

L'implementazione del backend canonico delle consociazioni rimane FUTURE.

## Backend

- Supabase
- Repository Pattern
- Row Level Security (RLS)
- Ambiente locale Supabase
- WSL 2 / Ubuntu
- Docker Desktop
- Supabase CLI
- Migration Supabase versionate
- Database PostgreSQL 17
- Schema `private` e helper autorizzativi
- Trigger metadata
- Profile Write Authority
- Protocollo server-side completo `profile_edit_locks`
- Lease, heartbeat, scadenza e takeover
- Identità tecnica del client e della sessione applicativa
- `ProfileContextScope`
- Controller, scheduler, scope e gate della Profile Write Authority
- Comportamento applicativo fail-closed
- Configurazione Supabase parametrizzabile tramite `--dart-define`

### Write Path operativi

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
- Modello persistente autoritativo `public.plantings`
- RPC `create_planting`
- RPC `update_planting`
- RPC `set_planting_status`
- Lifecycle autoritativo di `plantings`
- Concorrenza ottimistica mediante `row_version`
- Validazioni metodo-dipendenti
- Controllo overlap spaziale e temporale
- Integrazione con la geometria storicizzata delle aiuole
- Protezione delle variazioni geometriche mediante `blocked_by_plantings`
- `PlantingRepository`
- Result type tipizzati per il Write Path di `plantings`
- Scritture Flutter di `plantings` esclusivamente RPC-only
- Gestione esplicita di `end_date` per gli stati terminali
- Stato `harvested` ancora occupante
- Rilascio dell'occupazione soltanto con `finished` o `removed`
- Refresh autoritativo su `version_conflict` e `invalid_transition`

### Catalogo Agronomico globale

- `botanical_taxa`
- `crops`
- `crop_cultivars`
- **26 tabelle** nel perimetro del Catalogo Agronomico S030
- Normalizzazione canonica mediante `private.normalize_catalog_text(text)`
- Registro dei parametri agronomici
- Vocabolari e contesti agronomici
- Fonti agronomiche
- Acquisizioni
- Osservazioni
- Alias delle identità
- Riconciliazione delle identità
- Workflow editoriale
- Knowledge agronomica canonica
- Revisioni concatenate mediante `previous_revision_id`
- Pubblicazione della Knowledge
- Versionamento
- Resolver
- `crop_catalog_read`
- `crop_cultivar_catalog_read`
- `security_invoker=true` sui read model canonici
- Catalog Authority globale
- Capability separate per identity management, ingestion, review e publishing
- RPC `get_my_catalog_capabilities()`
- RPC `claim_initial_catalog_authority()`
- Claim iniziale esplicita, idempotente e non automatica
- Funzioni sensibili `SECURITY DEFINER`
- `search_path` vuoto sulle funzioni sensibili
- assenza di `EXECUTE` per `anon` sulle RPC sensibili
- Write Path autoritativi per identità
- Write Path autoritativi per registry e context
- Write Path autoritativi per ingestion
- Write Path autoritativi per workflow editoriale
- Pubblicazione autoritativa della Knowledge
- Resolver autoritativo
- RLS e privilegi espliciti
- revoca delle scritture dirette non necessarie
- separazione tra dato candidato e dato approvato
- divieto di sovrascrittura automatica del Catalogo da fonti esterne

Il cutover finale S030 ha rimosso dal modello corrente:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Il contratto corrente utilizza:

```text
botanical_taxa
crops
crop_cultivars
```

`plantings` utilizza:

```text
crop_id
cultivar_id
```

con `cultivar_id` opzionale e vincolo composto:

```text
(cultivar_id, crop_id)
        →
crop_cultivars(id, crop_id)
```

Il precedente `variety_id` è stato rimosso.

### Flutter — Catalogo Agronomico

- `CatalogCapabilities`
- `Crop`
- `CropCultivar`
- `CatalogAuthorityRepository`
- `CropRepository`
- `CropCultivarRepository`
- terminologia tecnica `cultivarId` / `cultivar_id`
- lettura delle colture mediante `crop_catalog_read`
- lettura delle cultivar mediante `crop_cultivar_catalog_read`
- lettura delle capability del Catalogo
- claim esplicita dell'autorità iniziale disponibile nel Repository
- nessuna claim automatica
- rimozione dei precedenti percorsi di scrittura del catalogo personale
- rimozione del modello personale delle famiglie botaniche
- rimozione di `CropVariety`
- rimozione di `CropVarietyRepository`
- rimozione dei result type delle precedenti scritture personali
- rimozione della precedente pagina personale di aggiunta della varietà
- migrazione della catena `Planting` da Variety a Cultivar

La terminologia italiana della UI può continuare a utilizzare **Varietà**, mentre il contratto tecnico utilizza **Cultivar**.

## Verifica tecnica corrente

La migration finale del Catalogo Agronomico S030 è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Lo stato finale verificato comprende:

```text
supabase db reset
success

DB lint locale
No schema errors found

DB lint remoto
No schema errors found

Acceptance Tranche 10
superata

Acceptance Tranche 11
superata

dart format lib test
Formatted 174 files

flutter analyze
No issues found!

flutter test
953 test passati

git diff --check
nessuna anomalia
```

La migration finale S030 risulta allineata tra database locale e remoto.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

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

La Sessione S030 ha completato l'architettura e il cutover tecnico del **Catalogo Agronomico V1 globale**.

Il Catalogo dispone ora delle fondazioni necessarie per gestire:

- identità botaniche globali;
- identità agronomiche globali;
- registro dei parametri agronomici;
- vocabolari e contesti;
- fonti, acquisizioni e osservazioni;
- alias e riconciliazione;
- workflow editoriale;
- Knowledge agronomica canonica;
- pubblicazione e versionamento;
- Resolver;
- Catalog Authority con capability distinte;
- read model canonici;
- integrazione Flutter con `Crop` e `CropCultivar`;
- collegamento opzionale di `Planting` a una cultivar.

La S030 è quindi **tecnicamente completata**.

Non viene assegnato automaticamente un numero di sessione al prossimo incremento: la relativa sessione sarà definita soltanto al momento della sua effettiva apertura.

## Attività post-S030

Restano da sviluppare o completare:

- backend canonico delle associazioni tra colture;
- UI amministrativa/editoriale completa del Catalogo Agronomico;
- azione UI esplicita e sicura per `claim_initial_catalog_authority()`;
- workflow operativo di importazione, ingestion, revisione e approvazione delle fonti;
- schermate del workflow editoriale;
- integrazione completa del Resolver nella creazione e pianificazione dei `Planting`;
- selezione esplicita della cultivar nel flusso di creazione di un `Planting`;
- popolamento editoriale del Catalogo con dati agronomici verificabili;
- smoke test con dati operativi reali;
- manutenzione periodica dei codici ISO 3166-1 alpha-2 mediante migration e test verificati;
- verifica e, se necessario, ripristino del percorso UI per la creazione del primo Garden;
- ulteriori incrementi del Database V1 non ancora implementati.

La manutenzione dei codici ISO 3166-1 alpha-2 non dovrà essere automatica: gli aggiornamenti dovranno essere verificati e introdotti mediante migration e test controllati.

## Aggiornamento delle fonti agronomiche

La funzione prevista per l'aggiornamento delle fonti sarà collocata in:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Aggiornamento fonti
```

Il flusso operativo dovrà rispettare l'architettura approvata:

```text
Fonte esterna
        ↓
importazione / ingestion
        ↓
dato candidato
        ↓
revisione
        ↓
approvazione
        ↓
Catalogo Agronomico
```

I dati provenienti da fonti esterne non potranno:

- diventare automaticamente dati operativi;
- sovrascrivere automaticamente dati già approvati nel Catalogo.

Il popolamento del Catalogo dovrà utilizzare fonti verificabili e mantenere la relativa tracciabilità.

## Avvio dell'utilizzo reale dell'orto

Il database deve rimanere privo di dati demo, di prova o provvisori fino all'avvio della gestione reale dell'orto.

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
creazione delle 15 aiuole reali
        ↓
apertura stagione reale
        ↓
registrazione dei Planting reali
```

Il popolamento operativo deve quindi iniziare con **dati reali**, non con seed dimostrativi o record provvisori.

Prima dell'avvio operativo dovrà essere disponibile una baseline del Catalogo Agronomico sufficientemente verificata e approvata.

## Planting

`AddPlantingPage` non dispone ancora della selezione esplicita della cultivar durante la creazione.

Attualmente:

```text
creazione → cultivarId: null
modifica  → preserva planting.cultivarId
```

La selezione esplicita della cultivar rimane FUTURE.

I valori agronomici memorizzati nel `Planting` devono continuare a essere considerati **snapshot operativi**.

Il Resolver potrà proporre valori agronomici, ma nessuna proposta dovrà modificare automaticamente il `Planting` senza conferma dell'utente.

## Associazioni tra colture

Il motore applicativo delle consociazioni rimane disponibile, ma il backend canonico delle associazioni tra colture non è ancora implementato.

Fino alla disponibilità del relativo modello canonico:

```text
CropAssociationRepository
```

non deve interrogare una relazione inesistente.

La realizzazione del backend canonico delle associazioni rimane FUTURE.

## Hard delete dei Planting

Non è previsto un normale hard delete di `plantings` nel flusso operativo.

L'eventuale hard delete rimane FUTURE e dovrà essere disponibile esclusivamente come operazione amministrativa o tecnica eccezionale per correggere record inseriti per errore.

Non dovrà costituire un'azione ordinaria disponibile durante la normale gestione delle coltivazioni.

## Ulteriori sviluppi FUTURE

Rimangono inoltre fuori dal perimetro completato della S030:

- correzioni amministrative avanzate;
- statistiche di raccolto e rese effettive;
- costi e ricavi;
- irrigazione;
- evoluzione dell'interfaccia utente;
- ulteriori sviluppi architetturali del Database V1.

L'ordine e l'assegnazione di questi sviluppi alle future sessioni saranno definiti progressivamente secondo il workflow del progetto.

# Cronologia versioni

| Versione | Data | Stato | Note |
| ----------- | ---------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto. |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico. |
| 0.1.2-alpha | 28/07/2026 | Archiviata | Introdotti BedAnalysisService, BedCompanionAnalyzer e consolidata l'architettura del Motore Agronomico. |
| 0.1.3-alpha | 06/08/2026 | Archiviata | Introdotta RecommendationPipeline e consolidata la nuova architettura del Motore Agronomico. |
| 0.1.4-alpha | 08/08/2026 | Archiviata | Introdotto DecisionWeights e resa configurabile la ponderazione dei criteri utilizzati dal DecisionEngine. |
| 0.1.5-alpha | 09/08/2026 | Archiviata | Implementata la prima versione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari. |
| 0.1.6-alpha | 09/08/2026 | Archiviata | Integrato il FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| 0.1.7-alpha | 10/08/2026 | Archiviata | Introdotti fabbisogni familiari quantitativi e lotti di coltivazione pianificati come fondamenta del futuro SuccessionPlanningEngine. |
| 0.1.8-alpha | 11/08/2026 | Archiviata | Implementata la prima versione del SuccessionPlanningEngine per generare una sequenza temporale validata di lotti pianificati a partire dal fabbisogno familiare quantitativo e periodico. |
| 0.1.9-alpha | 11/08/2026 | Archiviata | Introdotti AgronomicWindow, AgronomicWindowValidator e AgronomicWindowEngine per rappresentare le finestre agronomiche e verificare separatamente la compatibilità temporale dei lotti pianificati. |
| 0.1.10-alpha | 12/08/2026 | Archiviata | Associate le finestre agronomiche a colture e varietà mediante CropAgronomicWindowRule, AgronomicWindowResolver, AgronomicWindowEvaluation e AgronomicWindowService, con fallback varietà → coltura e distinzione tra `unknown` e `incompatible`. |
| 0.1.11-alpha | 16/08/2026 | Archiviata | Completata e congelata nella S017 la progettazione della baseline Database V1: 52 entità di dominio più la struttura tecnica `profile_edit_locks`, con ownership, accesso familiare monoutente, modello single-writer, temporalità, sicurezza, invarianti e strategia di implementazione incrementale in Supabase. |
| 0.1.12-alpha | 16/08/2026 | Archiviata | Introdotto il supporto alle finestre agronomiche multiple e predisposto l'ambiente Supabase locale versionato per la futura implementazione incrementale della baseline Database V1; verificati 151/151 test e mantenuto invariato il database remoto. |
| 0.1.13-alpha | 18/08/2026 | Archiviata | Creata la prima migration Database V1 e implementato e verificato localmente il blocco Fondazioni con schema `private`, helper autorizzativi, trigger metadata e 13 policy RLS; consolidato il primo incremento fisico della baseline Database V1. |
| 0.1.14-alpha | 28/08/2026 | Archiviata | Completato il protocollo `profile_edit_locks`, introdotta la Profile Write Authority, implementati i Write Path autoritativi di `gardens` e `seasons`, integrata la sessione Profile nel client Flutter e verificati 237/237 test. |
| 0.1.15-alpha | 01/09/2026 | Archiviata | Implementati `beds`, geometria storicizzata e relativo Write Path autoritativo, integrata la creazione dell'aiuola nel client Flutter, parametrizzata la configurazione Supabase e verificati 781/781 test. |
| 0.1.16-alpha | 03/09/2026 | Archiviata | Completata l'integrazione UI dei Write Path autoritativi di `beds`, introdotte modifica dati, attivazione e disattivazione, variazione geometrica, correzione storica e gestione italiana delle date; verificati 841/841 test. |
| 0.1.17-alpha | 11/09/2026 | Archiviata | Implementato il Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, introdotte due migration e nove RPC autoritative, consolidati ownership Profile, UUID, fallback Crop → Crop Variety, acqua quantitativa, resa strutturata, RLS e concorrenza; integrazione Flutter rinviata alla S027. |
| 0.1.18-alpha | 13/09/2026 | Archiviata | Completata nella S027 l'integrazione Flutter del Catalogo V1 mediante `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version` e verifica completa con 914/914 test; `pubspec.yaml` riallineato a `0.1.18-alpha+3`. |
| 0.1.19-alpha | 17/09/2026 | Archiviata | Implementato nella S028 il modello e Write Path autoritativo di `plantings`, introdotto il lifecycle server-side, consolidati geometria, temporalità e overlap, protette le variazioni geometriche delle aiuole, riallineato il client Flutter e verificati 997/997 test; `pubspec.yaml` aggiornato a `0.1.19-alpha+4`. |
| 0.1.20-alpha | 18/09/2026 | Archiviata | Completata nella S029 la UI del lifecycle di `plantings`, introdotte azioni contestuali in `PlantingCard`, gestione esplicita di `end_date` per `finished` e `removed`, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`; nessuna modifica al contratto persistente S028; suite completa finale verificata con 1011/1011 test passati, verifiche dedicate `BedPage` 30/30 e `PlantingCard` 9/9, `flutter analyze` finale pulito; `pubspec.yaml` aggiornato a `0.1.20-alpha+5`. |
| 0.1.21-alpha | 27/09/2026 | Corrente | Completata nella S030 l'architettura globale del Catalogo Agronomico V1: tassonomia botanica globale, identità agronomiche globali, registro parametri, contesti, fonti, acquisizioni, osservazioni, alias, workflow editoriale, Knowledge canonica, pubblicazione e Resolver; completato il cutover a `botanical_taxa`, `crops` e `crop_cultivars`, migrato `plantings` da `variety_id` a `cultivar_id`, riallineato il client Flutter al contratto Cultivar e consolidato un perimetro di 26 tabelle; migration finale `20260923154831_finalize_global_catalog_cutover.sql`; `supabase db reset` riuscito, lint locale e remoto senza errori, acceptance Tranche 10 e 11 superate, `flutter analyze` pulito e 953 test Flutter passati; versione Flutter prevista `0.1.21-alpha+6`. |

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