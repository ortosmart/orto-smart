# INF-CAT-001 - Catalogo Agronomico

## Metadati

- Proprietario: V1-08
- Riconciliazioni: RC10, RC11, RC12
- Sessione: S046
- Provenienza: STEP 273-274
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Stato: infrastruttura disponibile, integrazioni incomplete

## 1. Responsabilita

Gestire identita agronomiche canoniche,
tassonomia botanica, colture, cultivar,
registri tecnici e conoscenza agronomica approvata.

Separare i dati candidati provenienti dalle fonti
esterne dai dati ufficialmente approvati.

## 2. Consistenza acquisita

| Elemento | Quantita |
|---|---:|
| Tabelle del Catalogo | 26 |
| RPC editoriali rilevate, incluso Resolver | 26 |
| Registri tecnici backend | 7/7 |
| RPC dei registri | 21 |
| Registri con modello e repository Flutter | 6/7 |
| Registri con pagina Flutter | 3/7 |
| Registri raggiungibili dalla navigazione | 1/7 |

I conteggi devono essere consolidati
nelle riconciliazioni specifiche.

Non sommare automaticamente gruppi di RPC
senza verificare eventuali sovrapposizioni.

### 2.1. Identità canoniche e alias — RC10, S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Il catalogo PostgreSQL locale è stato interrogato in una transazione
di sola lettura, terminata con ROLLBACK. Risultano 48 migrazioni
registrate, fino alla 20261125151100.

| Tabella | Vincoli validati |
|---|---:|
| botanical_taxa | 9 |
| crops | 6 |
| crop_cultivars | 8 |
| taxon_aliases | 8 |
| crop_aliases | 8 |
| cultivar_aliases | 8 |
| Totale | 47 |

I taxa hanno una chiave esterna verso il padre e un vincolo di unicità
su rango, nome scientifico normalizzato e autore normalizzato.
Il nome canonico normalizzato è univoco per le colture e, per le
cultivar, all'interno della coltura. Gli alias sono univoci per entità,
alias normalizzato e lingua, con NULLS NOT DISTINCT.

Plantings e planned_plantings referenziano crops e usano una chiave
esterna composta (cultivar_id, crop_id) per garantire l'appartenenza
della cultivar alla coltura indicata.

Le migrazioni definiscono nove RPC di scrittura per gli alias.
Nei sorgenti Flutter esaminati non sono emersi percorsi di consultazione
o modifica degli alias. La verifica riguarda le definizioni installate
e i sorgenti esaminati. Il comportamento a runtime e lo stato remoto
restano da verificare per questo perimetro.

### 2.2. Evidenze Flutter riutilizzabili — RC10, S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Il confronto riusa la riesecuzione locale S048 documentata
in TST-RC02-003 §8.1.
I 251/251 PASS riguardano l'intero blocco Catalogo e Impostazioni
(12 file), che include i tre repository riportati di seguito.

| Percorso | Test di repository | Copertura riutilizzabile (E4) |
|---|---|---|
| Taxa | `botanical_taxon_repository_test.dart` | Lettura e filtro per stato, creazione, aggiornamento, cambio di stato, gestione delle risposte per conflitto di versione e dipendenze attive. |
| Colture | `crop_repository_test.dart` | Lettura del catalogo globale e filtro per stato, creazione, aggiornamento, cambio di stato, gestione delle risposte per nome canonico duplicato, conflitto di versione e dipendenze attive. |
| Cultivar | `crop_cultivar_repository_test.dart` | Lettura per coltura e stato, invio dell'identificativo della coltura in creazione, aggiornamento e cambio di stato, gestione delle risposte per nome canonico duplicato e conflitto di versione. |

**RIUTILIZZARE.** I test di pagina `botanical_classification_page_test.dart`
e `crops_and_cultivars_page_test.dart` rientrano nella suite generale di
apertura S048 (1.956/1.956 PASS). La riesecuzione mirata del §8.1 non
include questi due file. Il confronto non ha comportato nuove esecuzioni.

I test del repository verificano il trattamento delle risposte simulate.
Le prove locali sui vincoli di unicità e appartenenza sono riportate nel
§2.3. Il collaudo integrato dei percorsi di lettura è riportato nel §2.5.
Per gli alias si vedano le evidenze strutturali del §2.1 e il collaudo
SQL delle RPC del §2.4.

### 2.3. Prove transazionali PostgreSQL locale — RC10, S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Ambiente: Supabase locale, container `supabase_db_orto_app`.
Le prove SQL sono state eseguite con `psql` sullo schema installato,
con dati temporanei e `ROLLBACK` finale.

| Prova | Casi superati | Esito |
|---|---:|---|
| Unicità canonica di taxa, colture e cultivar | 3 | Le varianti maiuscole sono state respinte dai rispettivi vincoli di unicità. |
| Ambito del nome canonico della cultivar | 1 | Lo stesso nome è stato accettato per due colture distinte. |
| Unicità degli alias di taxa, colture e cultivar | 3 | Le varianti maiuscole dello stesso alias per la stessa entità, con lingua `NULL`, sono state respinte dai rispettivi vincoli. |
| Appartenenza della cultivar in `plantings` e `planned_plantings` | 2 | Entrambe le tabelle hanno accettato la coppia valida e respinto la coppia incoerente tramite le chiavi esterne composte `plantings_cultivar_crop_fkey` e `planned_plantings_cultivar_crop_fk`. |

**RIUTILIZZARE (E4).** Nove prove superate sui vincoli PostgreSQL locali.
I due casi di appartenenza, inizialmente saltati per assenza di righe,
sono stati completati con orto, stagione, aiuola, piano e catalogo
temporanei. Le due esecuzioni con esito positivo sono terminate con
`ROLLBACK`.

Il collaudo SQL delle RPC degli alias è riportato nel §2.4.

### 2.4. Collaudo SQL delle RPC degli alias — RC10, S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Ambiente: Supabase locale, container `supabase_db_orto_app`.
Le chiamate da `psql` sono state eseguite con ruolo `authenticated`
e identità simulata dell'utente locale associato alla Catalog Authority
con `can_manage_identity`. La transazione con dati di prova temporanei
si è conclusa con `ROLLBACK`.

| Entità | RPC collaudate | Esito |
|---|---|---:|
| Taxon | `create_taxon_alias`, `update_taxon_alias`, `set_taxon_alias_active` | 6/6 PASS |
| Coltura | `create_crop_alias`, `update_crop_alias`, `set_crop_alias_active` | 6/6 PASS |
| Cultivar | `create_cultivar_alias`, `update_cultivar_alias`, `set_cultivar_alias_active` | 6/6 PASS |

**RIUTILIZZARE (E4).** 18/18 verifiche SQL superate. Per ogni entità
sono stati verificati creazione con ricevuta, rifiuto del duplicato
normalizzato con lingua `NULL`, aggiornamento, conflitto con versione
obsoleta al cambio di stato, disattivazione e riattivazione. Nelle tre
mutazioni successive alla creazione riuscite è stato verificato
l'incremento della versione.

Il collaudo SQL ha esercitato le RPC con la Catalog Authority locale.
Il §2.5 documenta il collaudo via Data API per i percorsi di lettura
delle identità canoniche.

### 2.5. Collaudo integrato Flutter–Supabase locale — RC10, S048

Data del collaudo: 28/11/2026. Baseline sorgenti:
d1de8f659b52605aa52941ea33e920db5d684bd7.
Ambiente: Flutter Web in Edge (`localhost:54110`) e Supabase locale
(`127.0.0.1:54321)), con sessione autenticata e Catalog Authority
attiva per la gestione delle identità.

| Percorso | Esito osservato |
|---|---|
| Classificazione botanica | Stato vuoto iniziale. Dopo il caricamento dei dati di prova, visualizzazione del taxon con rango `SPECIES`. |
| Colture e Cultivar | Stato vuoto iniziale. Dopo il caricamento dei dati di prova, visualizzazione della coltura con il taxon associato. |
| Selezione coltura → elenco cultivar | La selezione della coltura di prova ha mostrato la cultivar associata, indicata come provvisoria. |

**RIUTILIZZARE (E4).** Collaudo integrato locale superato per i
percorsi di lettura osservati. Le tre voci sono state inserite via SQL,
lette tramite l'app e poi rimosse per identificativo esatto. Il
controllo PostgreSQL successivo ha restituito zero righe residue.

Il collaudo locale delle mutazioni Flutter e delle RPC degli alias
via Data API è riportato nel §2.10. La verifica strutturale remota
è riportata nel §2.6.

### 2.6. Verifica strutturale Supabase remoto — RC10, S048

Data della verifica: 28/11/2026. Baseline di confronto:
d1de8f659b52605aa52941ea33e920db5d684bd7.
Sul progetto Supabase remoto collegato sono state eseguite query
`SELECT` con `supabase db query --linked` sul catalogo PostgreSQL
e sul registro delle migrazioni.

| Oggetto | Esito |
|---|---|
| Vincoli di identità canonica e alias | 10 degli 11 vincoli selezionati sono presenti e validati, inclusi unicità normalizzata e chiave esterna composta cultivar–coltura in `plantings`. |
| Pianificazione | `planned_plantings` è assente sul remoto. La chiave esterna composta `planned_plantings_cultivar_crop_fk` è stata verificata a runtime solo in locale (§2.3). |
| Viste di lettura | `crop_catalog_read` e `crop_cultivar_catalog_read` sono presenti. |
| RPC degli alias | 9/9 presenti con le firme rilevate e ritorno `jsonb`. Il privilegio effettivo `EXECUTE` risulta disponibile per `authenticated` e assente per `anon` in tutti i casi. |
| Registro delle migrazioni | Al momento della verifica, 34 versioni sul remoto, ultima `20261014200459`, rispetto alle 48 della baseline locale. Per l'allineamento successivo vedere [DB-MIG-001 §2.1](../03_database/DB-MIG-001_Stato_Migrazioni.md#21-allineamento-supabase-remoto--rc10-s048). |

**RIUTILIZZARE (E4).** Evidenza tecnica per i soli metadati PostgreSQL
osservati nell'ambiente remoto.

### 2.7. Prova SQL di lettura su Supabase remoto — RC10, S048

Sul progetto remoto collegato, una transazione SQL `READ ONLY` con
`SET LOCAL ROLE authenticated` ha restituito i soli conteggi aggregati
visibili al ruolo: 3 taxa da `botanical_taxa`, 1 coltura da
`crop_catalog_read` e 0 cultivar da `crop_cultivar_catalog_read`.
La transazione si è conclusa con `ROLLBACK`.

**RIUTILIZZARE (E4).** Accesso SQL in lettura verificato per il ruolo
`authenticated` sulle tre relazioni interrogate.

La prova ha utilizzato il ruolo PostgreSQL. Il collaudo con una
sessione utente in Flutter è riportato nel §2.8.

### 2.8. Collaudo Flutter–Supabase remoto in lettura — RC10, S048

Data del collaudo: 28/11/2026. Baseline sorgenti di riferimento:
d1de8f659b52605aa52941ea33e920db5d684bd7. Ambiente: Flutter Web in
Edge (`localhost:56263`) collegato a Supabase remoto, con sessione
autenticata e Catalog Authority attiva.

| Percorso | Esito osservato |
|---|---|
| Classificazione botanica | Visualizzati tre taxa: Amaryllidaceae, Allium e Allium sativum. |
| Colture e Cultivar | Visualizzata la coltura Aglio bianco, associata ad Allium sativum e ad Amaryllidaceae. |
| Selezione coltura → elenco cultivar | La selezione di Aglio bianco ha mostrato «Nessuna cultivar presente». |

**RIUTILIZZARE (E4).** I percorsi di lettura osservati in Flutter
sono coerenti con i conteggi SQL del §2.7. Un elenco con una cultivar
associata è stato verificato nell'ambiente locale (§2.5). Le
operazioni del collaudo remoto sono state di sola lettura.

La verifica con un elenco cultivar popolato e il collaudo SQL
delle RPC degli alias sul remoto sono riportati nel §2.9.

### 2.9. Elenco cultivar popolato e RPC degli alias su Supabase remoto — RC10, S048

Data del collaudo: 28/11/2026. Baseline sorgenti di riferimento:
d1de8f659b52605aa52941ea33e920db5d684bd7.

| Percorso | Esito osservato |
|---|---|
| RPC degli alias via SQL | 18/18 verifiche su nove RPC, con ruolo `authenticated` e identità simulata di una Catalog Authority remota. Per taxa, colture e cultivar sono stati verificati creazione, duplicato con lingua `NULL`, aggiornamento, conflitto di versione, disattivazione e riattivazione. La transazione si è conclusa con `ROLLBACK`. |
| Lettura cultivar via Flutter–Data API | In Edge, riaprendo l'elenco di Aglio bianco, è stata visualizzata la cultivar di prova associata, indicata come provvisoria. |
| Rimozione dei dati di prova | La cultivar inserita via SQL per la prova Flutter è stata rimossa per UUID e nome esatti. La query successiva ha restituito zero righe di prova residue tra taxa, colture e cultivar. |

**RIUTILIZZARE (E4).** Collaudo remoto dei comportamenti SQL
osservati per le RPC degli alias e della lettura di un elenco
cultivar popolato tramite Flutter.

### 2.10. Mutazioni Flutter e RPC degli alias via Data API locale — RC10, S048

Data del collaudo: 28/11/2026. Baseline sorgenti di riferimento:
d1de8f659b52605aa52941ea33e920db5d684bd7. Ambiente: Flutter Web in
modalità release (`127.0.0.1:54111`) e Supabase locale
(`127.0.0.1:54321`).

| Percorso | Esito |
|---|---|
| Mutazioni da Flutter | 12/12 PASS. Con una sessione autenticata e Catalog Authority attiva, creazione, modifica, disattivazione e riattivazione di taxon, coltura e cultivar. PostgreSQL ha confermato tutte e tre le voci attive alla versione 4. |
| RPC degli alias via Data API | 18/18 PASS sulle nove RPC. Per ciascuna entità: creazione, rifiuto del duplicato, aggiornamento, conflitto con versione obsoleta, disattivazione e riattivazione. Verificato l'incremento di versione nelle tre mutazioni riuscite successive alla creazione. Chiamate HTTP con ruolo `authenticated` e token di test locale a breve scadenza tenuto in memoria. |
| Ripristino dei dati | Rimosse le sei voci di prova dal database locale. Il controllo per identificativi e relazioni ha restituito zero righe residue. |

**RIUTILIZZARE (E4).** Collaudo integrato locale superato per i
comportamenti osservati.

**VERIFICARE (NV).** Le mutazioni da Flutter e le RPC degli alias
via Data API sono state collaudate in locale. Sul remoto valgono
le evidenze dei §§2.6–2.9 e resta assente `planned_plantings`.
L'equivalenza funzionale complessiva resta da verificare. RC10
resta aperta.

### 2.11. Confronto delle definizioni SQL locale–remoto — RC10, S048

Baseline sorgenti di riferimento: d1de8f659b52605aa52941ea33e920db5d684bd7.
Le definizioni installate sono state lette con `psql` su Supabase
locale e con `supabase db query --linked` sul progetto remoto.
Il confronto ha usato le impronte MD5 del testo restituito da
`pg_get_functiondef` e `pg_get_viewdef`, abbinate per oggetto.

| Oggetti confrontati | Impronte coincidenti |
|---|---:|
| RPC di creazione, aggiornamento e cambio di stato per taxa, colture, cultivar e relativi alias | 18/18 |
| Viste `crop_catalog_read` e `crop_cultivar_catalog_read` | 2/2 |
| Totale | 20/20 |

**RIUTILIZZARE (E4).** Corrispondenza delle definizioni SQL estratte
per i venti oggetti confrontati.

La differenza relativa a `planned_plantings` è documentata nel §2.6.
Il collaudo delle mutazioni Flutter sul remoto è riportato nel §2.12.

### 2.12. Mutazioni Flutter e RPC degli alias su Supabase remoto — RC10, S048

Baseline sorgenti di riferimento: d1de8f659b52605aa52941ea33e920db5d684bd7.
Ambiente: Flutter Web in modalità release (`127.0.0.1:54112`),
Supabase remoto e sessione autenticata con Catalog Authority attiva.

**RIUTILIZZARE (E4).** 12/12 mutazioni superate. Dall'interfaccia
sono stati eseguiti creazione, modifica, disattivazione e riattivazione
di un taxon, una coltura e una cultivar associati e contrassegnati
per il collaudo. PostgreSQL ha confermato tutte e tre le voci attive
alla versione 4. La rimozione ha riguardato le sole tre voci di prova
e il controllo successivo ha restituito zero righe residue.

**RIUTILIZZARE (E4).** Il 28/11/2026, in S048 e sulla stessa
baseline, il titolare ha eseguito da PowerShell il collaudo delle nove
RPC degli alias via Data API remota con sessione autenticata e
`can_manage_identity = true`. Esito riportato in sessione: 18/18 PASS,
6/6 per ciascuna entità. Sono stati verificati creazione, rifiuto del
duplicato con lingua `NULL`, aggiornamento, conflitto con versione
obsoleta, disattivazione e riattivazione. Le tre mutazioni successive
alla creazione hanno incrementato ciascuna la versione di una unità.

Il titolare ha eseguito la pulizia nel SQL Editor con il marcatore
univoco della prova e ha riportato zero righe residue in ciascuna
delle tre tabelle degli alias e delle tre tabelle delle identità.

### 2.13. Impatto sulla pianificazione stagionale — RC10, S048

Valutazione del 28/11/2026 sulla baseline di §2.12, basata sul
codice Flutter, sulle migrazioni e sulle verifiche già acquisite.
Il percorso di lettura per stagione interroga direttamente
`planned_plantings` in
[`PlannedPlantingRepository`](../../../lib/data/repositories/planned_planting_repository.dart).
La migrazione
[`20261104190000`](../../../supabase/migrations/20261104190000_add_seasonal_planting_plans.sql)
vincola la coppia `(cultivar_id, crop_id)` alla coppia canonica
`(id, crop_id)` in `crop_cultivars`.

**RIUTILIZZARE (E4).** Il controllo di coerenza della coppia nella
pianificazione è stato collaudato a runtime in locale (§2.3).
Per le coltivazioni effettive, il vincolo composto di `plantings`
risultava presente e validato sul remoto (§2.6). Le evidenze remote
su identità e alias restano applicabili ai comportamenti collaudati
nei §§2.8–2.9 e 2.12.

Nel remoto osservato in §2.6, l'assenza di `planned_plantings`
impediva la lettura Flutter dei piani e la verifica a runtime del
vincolo. Il collaudo successivo all'allineamento è riportato in §2.14.

### 2.14. Collaudo della pianificazione su Supabase remoto — RC10, S048

Data 28/11/2026, baseline sorgenti `d1de8f6`, remoto alla versione
`20261125151100`. PostgreSQL ha confermato il vincolo
`planned_plantings_cultivar_crop_fk` validato.

| Prova | Esito |
|---|---|
| SQL transazionale | 2/2 PASS. La coppia cultivar–coltura valida è stata accettata e la coppia incoerente è stata respinta dal vincolo atteso. Una query separata ha confermato zero righe residue dopo `ROLLBACK`. |
| Lettura Flutter Web | PASS. Dall'orto e dalla stagione di prova, la sessione autenticata ha visualizzato il piano del 01/05/2026 in stato Bozza. |
| Pulizia dopo Flutter | PostgreSQL ha confermato zero righe residue per il marcatore di prova dopo la rimozione. |

**RIUTILIZZARE (E4).** RC10 conclusa tecnicamente nel perimetro
verificato di identità, alias e utilizzo della coppia cultivar–coltura
in pianificazione. Accettazione operativa e riconciliazione
quantitativa restano aperte.

**VERIFICARE (NV).** Durante la navigazione nell'orto temporaneo,
la sezione Aiuole ha mostrato un errore di caricamento. La lettura del
piano è riuscita. Causa e riproducibilità dell'errore restano da accertare.

## 3. Autorita

Catalog Authority distinta dalla Profile Write Authority.

La gestione delle identita globali e della conoscenza
approvata non deve essere confusa con la gestione
operativa del singolo orto.

Nessuna fonte esterna puo sovrascrivere
automaticamente il Catalogo approvato.

## 4. Processo editoriale

Fonte
-> Documento e revisione
-> Acquisizione
-> Osservazione
-> Normalizzazione
-> Candidato
-> Evidenza
-> Presentazione per revisione
-> Revisione
-> Pubblicazione
-> Resolver

Il processo rappresenta l'architettura approvata.
La completezza delle singole integrazioni
deve essere verificata separatamente.

## 5. Resolver

RPC:

resolve_agronomic_knowledge

Componente Flutter:

AgronomicKnowledgeRepository

Cinque esiti tipizzati rilevati.

Le denominazioni e i contratti esatti
degli esiti saranno consolidati in RC12.

Il Resolver risulta disponibile ma non ancora
integrato nei motori agronomici e nelle pagine
esaminate durante la ricognizione.

## 6. Registri Flutter

Componenti individuati per:

- HarvestPurpose.
- MeasurementUnit.
- AgronomicParameter.

HarvestPurpose raggiungibile dalla navigazione.

Le pagine MeasurementUnit e AgronomicParameter
non risultavano raggiungibili nella ricognizione.

Non ricreare questi componenti:
completare le integrazioni necessarie.

## 7. Popolamento

Nell'insieme delle 18 tabelle locali
esaminate per il popolamento:

- 17 risultavano vuote.
- 1 conteneva la Catalog Authority.

I due seed esaminati risultavano vuoti.

Stato dei dati remoti: NV.

Non introdurre dati fittizi permanenti.

## 8. Riutilizzo

Domini utilizzatori previsti:

- V1-09 Motori agronomici.
- V1-10 Pianificazioni.
- V1-11 Coltivazioni.
- V1-12 Raccolti.
- V1-14 Irrigazione.
- V1-19 Gestione economica.
- V1-21 Fertilizzazioni e trattamenti.

Il riutilizzo dei registri canonici non implica
che tutte le integrazioni siano gia implementate.

## 9. Vincoli permanenti

- Identita canoniche stabili.
- Fonti tracciabili.
- Revisioni conservate.
- Dati candidati separati.
- Pubblicazione controllata.
- Nessuna sovrascrittura automatica.
- Conservazione della storia.
- Nessun valore agronomico inventato.

## 10. Attivita residue

- Consolidare inventario e contratti.
- Completare integrazioni Flutter.
- Completare navigazione dei registri.
- Integrare Resolver nei motori e nei domini.
- Verificare popolamento e fonti.
- Collaudare i percorsi editoriali e operativi.
- Verificare ambiente remoto.

Le ore residue sono gestite nella programmazione V1.
