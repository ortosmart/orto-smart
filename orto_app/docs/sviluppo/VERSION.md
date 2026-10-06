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

La versione pubblica è quindi passata a:

```text
0.1.21-alpha
```

e, poiché la S030 ha comportato anche il riallineamento del client Flutter al nuovo contratto del Catalogo Agronomico globale, la versione Flutter è stata aggiornata a:

```text
0.1.21-alpha+6
```

La S030 ha introdotto e consolidato in particolare:

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

Con la Sessione S031 la stessa versione `0.1.21-alpha` è stata estesa senza assegnare una nuova versione pubblica e senza modificare la versione Flutter `0.1.21-alpha+6`.

La S031 ha completato il primo livello di integrazione operativa Flutter del Catalogo Agronomico mediante:

- accesso da `Impostazioni → Catalogo Agronomico`;
- lettura e visualizzazione delle capability della Catalog Authority;
- inizializzazione esplicita e confermata della Catalog Authority;
- nessuna claim automatica;
- consultazione delle colture globali;
- navigazione gerarchica `Coltura → Cultivar`;
- caricamento delle cultivar on demand;
- gestione degli stati di caricamento, assenza di dati ed errore;
- rimozione del precedente percorso autonomo `Impostazioni → Varietà`.

La S031 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

La verifica tecnica finale S031 ha prodotto:

```text
flutter analyze
No issues found!

flutter test
971 test passati
```

Con la Sessione S032 la stessa versione corrente `0.1.21-alpha` è stata ulteriormente estesa, mantenendo invariata anche la versione Flutter:

```text
0.1.21-alpha+6
```

La ricognizione tecnica iniziale S032 ha confermato che il backend dispone già dei Write Path autoritativi per la gestione delle identità globali di:

```text
Taxon
Crop
Cultivar
```

La precedente pianificazione S032–S042+ è stata pertanto riconosciuta come esplorativa e non vincolante rispetto allo stato tecnico effettivamente raggiunto.

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

`CULTIVAR` non costituisce un rank tassonomico.

Le cultivar rimangono identità agronomiche globali separate, rappresentate mediante:

```text
crop_cultivars
```

La gerarchia botanica utilizza `parent_taxon_id` e supporta una tassonomia parziale, senza richiedere artificialmente tutti i livelli intermedi.

Il collegamento:

```text
Crop → Taxon
```

è opzionale.

La S032 ha integrato nel client Flutter i Write Path delle identità:

- `BotanicalTaxon`;
- `Crop`;
- `CropCultivar`.

La Catalog Authority rimane separata dalla Profile Write Authority e dal protocollo `profile_edit_locks`.

Le operazioni di gestione delle identità sono subordinate alle capability della Catalog Authority e, in particolare, a:

```text
can_manage_identity
```

La concorrenza ottimistica utilizza:

```text
row_version
```

In caso di `version_conflict` il client non forza l'overwrite e non esegue retry automatici: viene invece riletto lo stato autoritativo dal backend.

Lo stesso principio viene applicato quando l'esito di una scrittura è incerto: non viene eseguito un retry automatico di un'operazione che potrebbe essere già stata applicata.

La S032 ha inoltre completato la UI di gestione della tassonomia botanica nel Catalogo Agronomico.

La terminologia applicativa approvata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

La gestione comprende:

- lettura delle voci botaniche;
- creazione;
- modifica;
- disattivazione;
- riattivazione;
- caricamento degli stati attivi e inattivi quando richiesto dalla gestione;
- conferma esplicita prima della disattivazione;
- rilettura autoritativa dopo conflitti o esiti incerti.

Flutter non replica le regole server-side relative a normalizzazione, unicità, gerarchia, cicli e dipendenze.

La progressione applicativa consolidata per la gestione delle identità del Catalogo è:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

Alla conclusione dello sviluppo S032:

```text
Taxonomy Write Path        completato
Crop Write Path            completato
Cultivar Write Path        completato

Taxonomy management UI     completata
Crop management UI         FUTURE
Cultivar management UI     FUTURE
```

La verifica tecnica finale S032 ha prodotto:

```text
Catalog page test suite
61/61 test superati

flutter analyze
No issues found!

flutter test
1077/1077 test superati
```

Il commit tecnico conclusivo dello sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

La S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

La versione pubblica corrente rimane quindi:

```text
0.1.21-alpha
```

e la versione Flutter corrente rimane:

```text
0.1.21-alpha+6
```

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

Il popolamento operativo dovrà iniziare soltanto con dati reali e con una baseline verificata e approvata del Catalogo Agronomico.

---

# Stato del progetto

Il progetto **Orto Smart** utilizza un'architettura Flutter + Supabase con Write Path autoritativi, RLS, concorrenza ottimistica e separazione tra configurazione strutturale, Catalogo Agronomico globale e dati operativi dell'orto.

Le versioni precedenti hanno progressivamente consolidato la baseline Database V1, la Profile Write Authority, i Write Path di Garden, Season, Bed e Planting e, successivamente, il Catalogo Agronomico V1 globale.

Con la versione `0.1.17-alpha`, corrispondente alla Sessione S026, era stato implementato il primo **Catalogo DB V1**:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
```

Il catalogo era Profile-owned e condiviso tra i Gardens appartenenti allo stesso Profile.

Erano state introdotte le migration:

```text
20260911084752_add_crop_catalog.sql
20260911091047_add_crop_catalog_write_rpcs.sql
```

e nove RPC autoritative per famiglie botaniche, colture e varietà.

Con la Sessione S027 il primo Catalogo V1 era stato integrato nel client Flutter mediante `BotanicalFamily`, `Crop`, `CropVariety` e Repository dedicati, mantenendo scritture RPC-only e Profile Write Authority fail-closed.

Il modello delle S026–S027 costituisce oggi uno stato storico superato dal Catalogo Agronomico globale introdotto nella S030.

Con la versione `0.1.19-alpha`, corrispondente alla Sessione S028, è stato implementato il modello autoritativo di `plantings`.

Sono state introdotte:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

con le RPC:

```text
create_planting
update_planting
set_planting_status
```

Il Write Path di `plantings` utilizza concorrenza ottimistica mediante `row_version`, validazioni server-side, controllo degli overlap spaziali e temporali e integrazione con la geometria storicizzata delle aiuole.

Il lifecycle autoritativo comprende:

```text
sown
growing
harvest_ready
harvested
finished
removed
```

con transizioni:

```text
sown          → growing | removed
growing       → harvest_ready | removed
harvest_ready → harvested | removed
harvested     → finished | removed
finished      → nessuna
removed       → nessuna
```

Lo stato `harvested` continua a occupare l'aiuola.

Soltanto:

```text
finished
removed
```

terminano l'occupazione fisica.

Con la versione `0.1.20-alpha`, corrispondente alla Sessione S029, è stato completato il livello applicativo del lifecycle senza modificare il contratto persistente introdotto nella S028.

La verifica finale S029 ha prodotto:

```text
flutter test
1011/1011 test passati

bed_page_test.dart
30/30 test passati

planting_card_test.dart
9/9 test passati

flutter analyze
No issues found!
```

Con la versione corrente `0.1.21-alpha`, corrispondente inizialmente alla Sessione S030, è stata completata l'architettura del **Catalogo Agronomico V1 globale**.

La S030 ha superato il precedente modello Profile-owned delle S026–S027 e ha separato:

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

La Sessione S031 ha successivamente esteso la stessa versione `0.1.21-alpha` con il primo livello di integrazione operativa Flutter del Catalogo Agronomico.

È stato reso operativo il percorso:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Colture
        ↓
Cultivar
```

La S031 ha completato:

- integrazione di `CatalogAuthorityRepository` nella UI;
- lettura e visualizzazione delle capability;
- inizializzazione esplicita e confermata della Catalog Authority;
- nessuna claim automatica;
- consultazione delle colture globali;
- navigazione `Coltura → Cultivar`;
- caricamento delle cultivar on demand;
- gestione degli stati di caricamento, assenza di dati ed errore;
- rimozione del precedente percorso autonomo `Impostazioni → Varietà`.

La S031 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

La verifica finale S031 ha prodotto:

```text
flutter analyze
No issues found!

flutter test
971 test passati
```

Il commit finale dello sviluppo S031 è:

```text
b436d663e46149202e081a3079eb162567fb0909
```

La Sessione S032 ha ulteriormente esteso la stessa versione corrente `0.1.21-alpha`, mantenendo invariata anche la versione Flutter `0.1.21-alpha+6`.

La ricognizione iniziale S032 ha confermato che il backend dispone già dei Write Path autoritativi necessari per la gestione delle identità globali di:

```text
Taxon
Crop
Cultivar
```

La precedente pianificazione S032–S042+ è stata pertanto riconosciuta come esplorativa e non vincolante rispetto allo stato tecnico effettivamente raggiunto.

La S032 ha integrato nel client Flutter i Write Path delle identità:

```text
BotanicalTaxon
Crop
CropCultivar
```

e ha completato la UI di gestione della tassonomia botanica.

Alla conclusione dello sviluppo S032:

```text
Taxonomy Write Path        completato
Crop Write Path            completato
Cultivar Write Path        completato

Taxonomy management UI     completata
Crop management UI         FUTURE
Cultivar management UI     FUTURE
```

La verifica tecnica finale S032 ha prodotto:

```text
Catalog page test suite
61/61 test superati

flutter analyze
No issues found!

flutter test
1077/1077 test superati
```

Il commit tecnico conclusivo dello sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

La S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

## Identità botaniche globali

La tassonomia botanica canonica è rappresentata da:

```text
botanical_taxa
```

I rank canonici correnti sono:

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

`CULTIVAR` **non è un rank tassonomico**.

Le cultivar costituiscono identità agronomiche globali separate e sono rappresentate mediante:

```text
crop_cultivars
```

La gerarchia botanica utilizza:

```text
parent_taxon_id
```

e supporta una tassonomia parziale.

Non è quindi necessario che ogni voce botanica disponga di tutti i livelli intermedi della classificazione.

Il collegamento:

```text
Crop → Taxon
```

è opzionale.

La normalizzazione canonica dei testi utilizza:

```text
private.normalize_catalog_text(text)
```

con normalizzazione Unicode, trim, riduzione degli spazi e normalizzazione per il confronto.

Le regole relative a normalizzazione, unicità, gerarchia, prevenzione dei cicli e dipendenze rimangono autoritative lato backend e non devono essere duplicate artificialmente nel client Flutter.

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

La Catalog Authority rimane distinta dalla Profile Write Authority e dal protocollo:

```text
profile_edit_locks
```

Le operazioni di gestione delle identità sono subordinate alle capability della Catalog Authority e, in particolare, a:

```text
can_manage_identity
```

## Conoscenza agronomica

La S030 ha introdotto:

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

Il perimetro del Catalogo Agronomico S030 comprende **26 tabelle**.

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

La concorrenza ottimistica delle identità del Catalogo utilizza:

```text
row_version
```

In presenza di:

```text
version_conflict
```

il client non forza l'overwrite e non esegue retry automatici, ma rilegge lo stato autoritativo dal backend.

In presenza di un esito di scrittura incerto il client non ripete automaticamente l'operazione, perché la scrittura potrebbe essere già stata applicata.

## Flutter

Il client Flutter è stato riallineato al contratto globale nella S030, integrato operativamente nella S031 ed esteso nella S032 con i Write Path delle identità e la gestione completa della tassonomia botanica.

La terminologia tecnica corrente utilizza:

```text
BotanicalTaxon
Crop
CropCultivar
cultivarId
cultivar_id
```

Il precedente contratto basato su:

```text
BotanicalFamily
CropVariety
varietyId
variety_id
crop_variety
```

non rappresenta più il modello corrente.

La UI italiana può utilizzare **Varietà** quando appropriato come termine destinato all'utente, mentre il contratto tecnico utilizza **Cultivar**.

Per la tassonomia botanica, la terminologia UI approvata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Il client dispone di:

```text
CatalogCapabilities
BotanicalTaxon
Crop
CropCultivar

CatalogAuthorityRepository
BotanicalTaxonRepository
CropRepository
CropCultivarRepository
```

`CropRepository` e `CropCultivarRepository` mantengono le letture canoniche del Catalogo e, con S032, dispongono anche dei rispettivi Write Path autoritativi.

`BotanicalTaxonRepository` integra il Write Path della tassonomia botanica.

La progressione applicativa consolidata è:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

La UI di gestione della **Classificazione botanica** comprende:

- lettura;
- creazione;
- modifica;
- disattivazione;
- riattivazione;
- caricamento degli stati attivi e inattivi quando necessario;
- conferma esplicita prima della disattivazione;
- rilettura autoritativa dopo conflitti o esiti incerti.

La gestione è disponibile soltanto quando le capability della Catalog Authority consentono la gestione delle identità.

Flutter non replica le regole server-side relative a:

- normalizzazione;
- unicità;
- gerarchia;
- cicli;
- dipendenze;
- stato attivo;
- concorrenza.

La gestione di `version_conflict` non forza l'overwrite e non esegue retry automatici.

Un esito di scrittura incerto determina una verifica mediante rilettura autoritativa e non una ripetizione automatica della scrittura.

La Sessione S031 aveva inoltre rimosso il precedente percorso autonomo:

```text
Impostazioni
    ↓
Varietà
```

La consultazione delle cultivar continua ad avvenire nel contesto della coltura:

```text
Catalogo Agronomico
    ↓
Coltura
    ↓
Cultivar
```

Sono stati rimossi dal contratto Flutter corrente:

- modello e Repository personali delle famiglie botaniche;
- `CropVariety`;
- `CropVarietyRepository`;
- result type delle precedenti scritture personali;
- pagina personale di aggiunta della varietà;
- precedente percorso autonomo `Impostazioni → Varietà`;
- relativi test legacy non più coerenti con il contratto corrente.

`RotationEngine` confronta la famiglia botanica mediante UUID canonico; il nome della famiglia rimane un dato di presentazione.

Il backend canonico delle consociazioni non è ancora stato implementato.

Per questo motivo `CropAssociationRepository` restituisce attualmente insiemi vuoti invece di interrogare una relazione canonica inesistente, mentre il motore delle consociazioni rimane disponibile.

Il backend canonico delle associazioni rimane FUTURE.

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

La UI completa di gestione Crop rimane FUTURE.

La UI completa di gestione Cultivar rimane FUTURE.

Il database continua a rimanere intenzionalmente privo di dati demo, di prova o provvisori.

## Verifica tecnica corrente

La baseline persistente corrente del Catalogo Agronomico rimane quella completata nella Sessione S030.

La migration finale del cutover è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

La stessa migration finale risulta applicata sia localmente sia sul database remoto.

Le verifiche database consolidate nella S030 comprendono:

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
```

La S031 non ha introdotto nuove migration Supabase.

La S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente del Catalogo Agronomico.

La verifica applicativa finale S032 comprende:

```text
Catalog page test suite
61/61 test superati

flutter analyze
No issues found!

flutter test
1077/1077 test superati
```

Il commit tecnico conclusivo dello sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

Al termine dello sviluppo S032 il repository risultava verificato, pulito e allineato al remoto dopo il push del commit tecnico conclusivo.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

Il popolamento operativo dovrà iniziare soltanto con dati reali e dopo la disponibilità di una baseline verificata e approvata del Catalogo Agronomico.

La sequenza operativa prevista rimane:

```text
verifica database locale pulito
        ↓
verifica separata database remoto
        ↓
popolamento del Catalogo Agronomico verificato
        ↓
creazione Garden reale
        ↓
creazione delle 15 aiuole reali
        ↓
apertura stagione reale
        ↓
registrazione delle coltivazioni reali
```

---

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
- Tassonomia parziale mediante `parent_taxon_id`
- Collegamento opzionale `Crop → Taxon`
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
- Concorrenza ottimistica mediante `row_version`

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
- Accesso al Catalogo Agronomico da `Impostazioni → Catalogo Agronomico`
- Visualizzazione dello stato e delle capability della Catalog Authority
- Azione esplicita e confermata per l'inizializzazione della Catalog Authority
- Consultazione delle colture globali
- Navigazione gerarchica `Coltura → Cultivar`
- Caricamento delle cultivar on demand
- Gestione degli stati di caricamento, assenza di cultivar ed errore
- Possibilità di riprovare il caricamento delle cultivar dopo un errore
- Rimozione del precedente percorso autonomo `Impostazioni → Varietà`
- Gestione completa della Classificazione botanica
- Lettura delle voci botaniche
- Creazione di una voce botanica
- Modifica di una voce botanica
- Disattivazione con conferma esplicita
- Riattivazione
- Visualizzazione degli stati attivi e inattivi quando necessario alla gestione
- Gestione della Classificazione superiore
- Rilettura autoritativa dopo conflitti concorrenti
- Rilettura autoritativa dopo esiti di scrittura incerti
- Gestione corretta di un Profile privo di Garden

La terminologia UI approvata per la tassonomia è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

La gestione delle identità del Catalogo è subordinata alle capability della Catalog Authority e, in particolare, a:

```text
can_manage_identity
```

La UI non replica le regole autoritative del backend relative a normalizzazione, unicità, gerarchia, cicli, dipendenze, stato attivo e concorrenza.

In presenza di:

```text
version_conflict
```

non viene forzato l'overwrite e non viene eseguito un retry automatico.

Il client rilegge invece lo stato autoritativo.

Lo stesso principio viene applicato quando l'esito di una scrittura è incerto: l'operazione non viene automaticamente ripetuta perché potrebbe essere già stata applicata dal backend.

La progressione applicativa consolidata è:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

Alla conclusione della S032:

```text
Taxonomy management UI     completata
Crop management UI         FUTURE
Cultivar management UI     FUTURE
```

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
- Catalog Authority globale separata dalla Profile Write Authority
- Concorrenza ottimistica mediante `row_version`

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

Il contratto canonico corrente utilizza:

```text
botanical_taxa
crops
crop_cultivars
```

Il perimetro del Catalogo Agronomico consolidato nella S030 comprende **26 tabelle**.

La tassonomia botanica utilizza i rank:

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

Le cultivar sono identità agronomiche globali separate mediante:

```text
crop_cultivars
```

La gerarchia tassonomica utilizza:

```text
parent_taxon_id
```

e supporta una tassonomia parziale.

Il collegamento:

```text
Crop → Taxon
```

è opzionale.

Il Catalogo comprende inoltre:

- normalizzazione canonica mediante `private.normalize_catalog_text(text)`
- registro dei parametri agronomici
- vocabolari e contesti agronomici
- fonti agronomiche
- acquisizioni
- osservazioni
- alias delle identità
- riconciliazione delle identità
- workflow editoriale
- Knowledge agronomica canonica
- revisioni concatenate mediante `previous_revision_id`
- pubblicazione della Knowledge
- versionamento
- Resolver
- `crop_catalog_read`
- `crop_cultivar_catalog_read`
- `security_invoker=true` sui read model canonici
- Catalog Authority globale
- capability separate per identity management, ingestion, review e publishing
- RPC `get_my_catalog_capabilities()`
- RPC `claim_initial_catalog_authority()`
- claim iniziale esplicita, idempotente e non automatica
- funzioni sensibili `SECURITY DEFINER`
- `search_path` vuoto sulle funzioni sensibili
- assenza di `EXECUTE` per `anon` sulle RPC sensibili
- Write Path autoritativi per identità
- Write Path autoritativi per registry e context
- Write Path autoritativi per ingestion
- Write Path autoritativi per workflow editoriale
- pubblicazione autoritativa della Knowledge
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

Il client Flutter utilizza il contratto canonico globale mediante:

- `CatalogCapabilities`
- `BotanicalTaxon`
- `Crop`
- `CropCultivar`
- `CatalogAuthorityRepository`
- `BotanicalTaxonRepository`
- `CropRepository`
- `CropCultivarRepository`
- terminologia tecnica `cultivarId` / `cultivar_id`
- lettura delle colture mediante `crop_catalog_read`
- lettura delle cultivar mediante `crop_cultivar_catalog_read`
- lettura delle capability del Catalogo
- claim esplicita dell'autorità iniziale
- nessuna claim automatica
- rimozione dei precedenti percorsi di scrittura del catalogo personale
- rimozione del modello personale delle famiglie botaniche
- rimozione di `CropVariety`
- rimozione di `CropVarietyRepository`
- migrazione della catena `Planting` da Variety a Cultivar

Con la Sessione S032 sono stati integrati nel client Flutter i Write Path autoritativi di:

```text
BotanicalTaxon
Crop
CropCultivar
```

I Repository gestiscono gli esiti RPC in modo esplicito e mantengono il backend autoritativo per:

- autorizzazione;
- capability;
- normalizzazione;
- unicità;
- gerarchia;
- prevenzione dei cicli;
- dipendenze;
- stato attivo;
- concorrenza.

La concorrenza ottimistica utilizza:

```text
row_version
```

In presenza di `version_conflict`:

```text
nessun overwrite forzato
nessun retry automatico
rilettura autoritativa
```

In presenza di un esito di scrittura incerto:

```text
nessun retry automatico
verifica mediante rilettura autoritativa
```

La pagina del Catalogo Agronomico continua a:

- leggere le capability mediante `CatalogAuthorityRepository`;
- distinguere Catalog Authority inizializzata e non inizializzata;
- esporre **Inizializza Catalogo** quando applicabile;
- richiedere conferma esplicita prima della claim iniziale;
- non eseguire claim automatica;
- caricare le colture globali;
- consentire la consultazione delle cultivar nel contesto della coltura.

Con la S032 la stessa pagina integra inoltre la gestione completa della **Classificazione botanica**.

La progressione applicativa consolidata è:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

Lo stato corrente è:

```text
Taxonomy Write Path        completato
Crop Write Path            completato
Cultivar Write Path        completato

Taxonomy management UI     completata
Crop management UI         FUTURE
Cultivar management UI     FUTURE
```

La S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

## Verifica tecnica corrente

La baseline persistente corrente del Catalogo Agronomico rimane quella completata nella Sessione S030.

La migration finale del Catalogo Agronomico S030 è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Le verifiche database consolidate nella S030 rimangono valide:

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
```

La migration finale S030 risulta allineata tra database locale e remoto.

La Sessione S031 non ha introdotto nuove migration Supabase.

La Sessione S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente del Catalogo Agronomico.

La verifica finale S032 ha prodotto:

```text
Catalog page test suite
61/61 test superati

flutter analyze
No issues found!

flutter test
1077/1077 test superati
```

Il commit tecnico conclusivo dello sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

Al termine dello sviluppo S032 il repository risultava verificato, pulito e allineato al remoto dopo il push del commit tecnico conclusivo.

Il database rimane intenzionalmente privo di dati demo, di prova o provvisori.

Il popolamento del Catalogo Agronomico dovrà iniziare soltanto con dati reali, verificabili e tracciabili, dopo la disponibilità di una baseline agronomica verificata e approvata.

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

La Sessione S030 ha completato l'architettura e il cutover tecnico del **Catalogo Agronomico V1 globale**.

La Sessione S031 ha completato il primo livello di integrazione operativa Flutter del Catalogo Agronomico.

La Sessione S032 ha successivamente completato:

- ricognizione tecnica del backend già disponibile per la gestione delle identità del Catalogo;
- integrazione Flutter del Write Path della tassonomia botanica;
- integrazione Flutter del Write Path delle colture;
- integrazione Flutter del Write Path delle cultivar;
- lettura della Classificazione botanica;
- creazione delle voci botaniche;
- modifica delle voci botaniche;
- disattivazione e riattivazione delle voci botaniche;
- gestione della concorrenza ottimistica mediante `row_version`;
- rilettura autoritativa dopo `version_conflict`;
- gestione sicura degli esiti di scrittura incerti senza retry automatico;
- UI completa di gestione della tassonomia botanica.

La S032 non ha introdotto nuove migration Supabase e non ha modificato il contratto persistente consolidato nella S030.

Lo stato raggiunto nella gestione delle identità è:

```text
Taxonomy Write Path        completato
Crop Write Path            completato
Cultivar Write Path        completato

Taxonomy management UI     completata
Crop management UI         FUTURE
Cultivar management UI     FUTURE
```

La progressione applicativa consolidata è:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

La versione pubblica corrente rimane:

```text
0.1.21-alpha
```

e la versione Flutter corrente rimane:

```text
0.1.21-alpha+6
```

La S032 costituisce un ulteriore incremento funzionale della versione corrente e non determina automaticamente l'assegnazione di una nuova versione pubblica.

La direzione naturale proposta per il successivo incremento di sviluppo è il completamento progressivo della gestione Flutter delle identità del Catalogo:

```text
Crop management UI
        ↓
Cultivar management UI
```

Questa direzione non costituisce tuttavia un'assegnazione automatica o vincolante dell'intero perimetro alla Sessione S033.

La successiva sessione di sviluppo dovrà iniziare con un **CHECKPOINT DI RICEZIONE**, verificando la baseline tecnica effettiva, lo stato Git, il contratto corrente e il passaggio di consegne prima di introdurre modifiche.

Soltanto dopo tale verifica verrà confermato il perimetro operativo della nuova sessione.

## Attività post-S032

Restano da sviluppare o completare:

- UI completa di gestione delle colture globali;
- UI completa di gestione delle cultivar globali;
- gestione UI degli alias;
- workflow operativo delle fonti e dell'acquisizione;
- normalizzazione e importazione dei dati esterni;
- gestione dei dati candidati;
- schermate di review editoriale;
- gestione della pubblicazione;
- integrazione operativa del Resolver;
- backend canonico delle associazioni tra colture;
- selezione esplicita della cultivar nel flusso di creazione di un `Planting`;
- integrazione completa del Resolver nella creazione e pianificazione dei `Planting`;
- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;
- smoke test con dati operativi reali;
- manutenzione periodica dei codici ISO 3166-1 alpha-2 mediante migration e test verificati;
- verifica e, se necessario, ripristino del percorso UI per la creazione del primo Garden;
- ulteriori incrementi del Database V1 non ancora implementati.

Per la gestione delle identità del Catalogo rimangono vincolanti i principi consolidati nella S032:

- backend autoritativo;
- Catalog Authority separata dalla Profile Write Authority;
- capability `can_manage_identity`;
- normalizzazione canonica server-side;
- vincoli di unicità server-side;
- tassonomia botanica globale;
- tassonomia parziale mediante `parent_taxon_id`;
- `CULTIVAR` separata dai rank tassonomici;
- collegamento opzionale `Crop → Taxon`;
- gerarchia `Coltura → Cultivar`;
- concorrenza ottimistica mediante `row_version`;
- nessun overwrite forzato su `version_conflict`;
- nessun retry automatico dopo un esito di scrittura incerto;
- rilettura autoritativa dopo conflitti o esiti incerti;
- separazione tra dati candidati e dati approvati.

Flutter non deve duplicare artificialmente le regole autoritative del backend relative a normalizzazione, unicità, gerarchia, cicli e dipendenze.

Il popolamento del Catalogo non dovrà utilizzare dati dimostrativi o provvisori.

I dati agronomici reali dovranno essere introdotti soltanto quando il relativo workflow sarà sufficientemente sicuro, verificato e tracciabile.

La manutenzione dei codici ISO 3166-1 alpha-2 non dovrà essere automatica: gli aggiornamenti dovranno essere verificati e introdotti mediante migration e test controllati.

## Gestione futura di Crop e Cultivar

La direzione naturale successiva alla gestione completa della tassonomia è l'estensione della UI alle identità:

```text
Crop
    ↓
Cultivar
```

Per Crop dovranno essere verificati e integrati progressivamente:

- creazione;
- modifica;
- attivazione;
- disattivazione;
- collegamento opzionale al Taxon;
- gestione di `row_version`;
- `version_conflict`;
- esiti di scrittura incerti;
- rilettura autoritativa;
- capability della Catalog Authority;
- test specifici;
- regressione globale.

Successivamente, per Cultivar dovranno essere verificati e integrati progressivamente:

- gestione nel contesto della relativa Crop;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- gestione di `row_version`;
- conflitti concorrenti;
- esiti di scrittura incerti;
- rilettura autoritativa;
- capability della Catalog Authority;
- test specifici;
- regressione globale.

La presenza dei Write Path Flutter già integrati nella S032 non implica che le relative UI complete siano già disponibili.

La progressione dovrà continuare a rispettare:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

senza introdurre percorsi di scrittura diretta alternativi al backend autoritativo.

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

La presenza nel backend delle strutture per fonti, acquisizione, candidati, review, pubblicazione e Resolver non equivale al completamento delle relative UI e dei workflow operativi Flutter.

Questi incrementi rimangono FUTURE e dovranno essere affrontati progressivamente.

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

Rimangono inoltre fuori dal perimetro completato fino alla Sessione S032:

- correzioni amministrative avanzate;
- statistiche di raccolto e rese effettive;
- costi e ricavi;
- irrigazione;
- evoluzione dell'interfaccia utente;
- ulteriori sviluppi architetturali del Database V1.

L'ordine e l'assegnazione di questi sviluppi alle future sessioni saranno definiti progressivamente secondo il workflow del progetto.

La conclusione della S032 non determina automaticamente il contenuto definitivo della sessione successiva.

La direzione naturale proposta è il completamento progressivo della gestione delle identità:

```text
Taxonomy completata
        ↓
Crop
        ↓
Cultivar
```

ma il perimetro effettivo della nuova sessione dovrà essere confermato soltanto dopo il relativo **CHECKPOINT DI RICEZIONE**.

Gli incrementi relativi ad alias, fonti, acquisizione, candidati, review, pubblicazione e Resolver rimangono FUTURE e non vengono assegnati preventivamente alla sessione successiva.

---

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
| 0.1.21-alpha | 27/09/2026 | Corrente | Completata nella S030 l'architettura globale del Catalogo Agronomico V1: tassonomia botanica globale, identità agronomiche globali, registro parametri, contesti, fonti, acquisizioni, osservazioni, alias, workflow editoriale, Knowledge canonica, pubblicazione e Resolver; completato il cutover a `botanical_taxa`, `crops` e `crop_cultivars`, migrato `plantings` da `variety_id` a `cultivar_id`, riallineato il client Flutter al contratto Cultivar e consolidato un perimetro di 26 tabelle; migration finale `20260923154831_finalize_global_catalog_cutover.sql`; `supabase db reset` riuscito, lint locale e remoto senza errori, acceptance Tranche 10 e 11 superate. Nella S031 la stessa versione corrente è stata estesa con l'integrazione operativa Flutter del Catalogo Agronomico in `Impostazioni → Catalogo Agronomico → Colture → Cultivar`, lettura delle capability, inizializzazione esplicita e confermata della Catalog Authority, consultazione delle colture globali, caricamento on demand delle cultivar, gestione degli stati UI e rimozione del precedente percorso autonomo `Impostazioni → Varietà`; nessuna nuova migration Supabase e nessuna modifica al contratto persistente; verifica finale S031 con `flutter analyze` pulito e 971 test passati. Nella S032 sono stati integrati nel client Flutter i Write Path autoritativi di Taxon, Crop e Cultivar ed è stata completata la UI di gestione della Classificazione botanica con lettura, creazione, modifica, disattivazione e riattivazione; consolidati tassonomia parziale mediante `parent_taxon_id`, rank `ORDER`, `FAMILY`, `GENUS`, `SPECIES`, `SUBSPECIES`, `VARIETY`, `FORMA`, `UNRANKED`, Cultivar separata dai rank tassonomici, collegamento opzionale `Crop → Taxon`, capability `can_manage_identity`, concorrenza ottimistica mediante `row_version`, nessun overwrite forzato su `version_conflict`, nessun retry automatico dopo esiti incerti e rilettura autoritativa; nessuna nuova migration Supabase e nessuna modifica al contratto persistente S030; verifica finale S032 con Catalog page 61/61 test, `flutter analyze` pulito e suite globale 1077/1077 test; commit tecnico finale `842a6b6468964300d43d0edac1d8853c3a4bb908`; versione Flutter corrente `0.1.21-alpha+6`. |

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