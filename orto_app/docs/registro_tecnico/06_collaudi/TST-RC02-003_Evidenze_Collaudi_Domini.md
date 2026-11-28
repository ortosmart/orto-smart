# Orto Smart - Evidenze collaudi dei domini

## Metadati

- Identificativo: TST-RC02-003
- Versione: 1.0
- Sessione di introduzione: S048
- Data: 27/11/2026
- Stato: consolidamento intermedio
- Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7
- Riconciliazione: RC02.07
- Ambiente verificato: repository locale Windows e Flutter
- Macroblocchi interessati: V1-02, V1-05, V1-06, V1-07

## 1. Finalita e metodologia

La scheda conserva le evidenze dei collaudi
pertinenti alla Write Authority nei domini.

Distingue:

- Inventario dei file di test.
- Dichiarazioni statiche dei test.
- Casi eseguibili generati.
- Asserzioni effettivamente esaminate.
- Esecuzioni effettuate.
- Risultati delle esecuzioni.
- Verifiche residue.

Non confondere il numero delle dichiarazioni
con il numero dei casi eseguibili.

Non sommare le esecuzioni ripetute della
stessa suite come nuovi test disponibili.

Non dedurre la copertura completa di un
contratto dal solo titolo di un test.

Le evidenze strutturali appartengono
alla scheda INF-WA-003.

## 2. Baseline collaudi

### 2.1 Sessione S047

Le evidenze dei collaudi dell'infrastruttura
Flutter sono conservate in TST-RC02-002.

La sessione S047 ha eseguito sette suite
mirate, con 116 casi complessivi superati.

Tali evidenze devono essere riutilizzate,
senza duplicarne integralmente il contenuto.

### 2.2 Apertura S048

| Controllo | Risultato | Durata |
|---|---|---|
| flutter analyze | PASS | 19,0 secondi |
| flutter test | 1956/1956 PASS | 2 minuti e 53 secondi |

La suite generale costituisce una baseline
di regressione Flutter.

Non costituisce una certificazione completa
dei contratti SQL o del database remoto.

### 2.3 Livelli di evidenza

E3: implementazione esaminata staticamente.

E4: specifica evidenza tecnica verificata.

NV: verifica non effettuata o insufficiente.

NA: non applicabile con motivazione.

Nessuna nuova evidenza E5 acquisita.

## 3. Evidenze Orti

### 3.1 Inventario

Riconciliazione RC02.07.03.

- File di test pertinenti individuati: 8.
- Dichiarazioni di test individuate: 57.
- Nuove esecuzioni mirate: nessuna.

I conteggi derivano dalla ricognizione
statica effettuata durante S048.

Non rappresentano il numero dei casi
eseguibili ne una misura di copertura.

### 3.2 Copertura contrattuale

La riconciliazione strutturale ha individuato:

- create_garden: cinque esiti gestiti.
- update_garden: otto esiti non integrati.

La copertura contrattuale Flutter e 5/13.

Questo indicatore non misura la copertura
delle asserzioni dei test.

### 3.3 Evidenze e limitazioni

Non sono stati individuati richiami espliciti
alle RPC create_garden e update_garden
nei test SQL ricercati.

Non sono stati individuati richiami espliciti
a update_garden nei test Flutter ricercati.

La ricerca testuale non esclude verifiche
equivalenti formulate diversamente.

La suite generale S048 ha superato
1956/1956 casi.

Non e stato eseguito un collaudo
mirato del dominio Orti in RC02.07.03.

### 3.4 Verifiche residue

- Parametri e risultati della creazione.
- Integrazione della modifica orto.
- Versionamento e conflitti.
- Assenza e perdita della Write Authority.
- Identita del profilo e della route.
- Risposte non determinabili.
- Ricaricamento dei dati.
- Dipendenze della disattivazione.
- Privilegi e RLS.
- Integrazione reale Flutter-Supabase.

Prima di sviluppare nuovi test,
verificare le asserzioni gia disponibili.

## 4. Evidenze Aiuole

### 4.1 Inventario

Riconciliazione RC02.07.04.

- File di test pertinenti individuati: 15.
- Dichiarazioni di test individuate: 220.
- Nuove esecuzioni mirate: nessuna.

| Area | Dichiarazioni |
|---|---:|
| Repository | 113 |
| Pagine | 82 |
| Modelli | 13 |
| Widget | 6 |
| Motori | 4 |
| Servizi | 2 |
| Totale | 220 |

I conteggi riguardano le dichiarazioni
statiche individuate.

Non equivalgono ai casi eseguibili.

### 4.2 Copertura contrattuale

La riconciliazione strutturale ha individuato
36 esiti Flutter su 39 esiti SQL.

Le tre combinazioni mancanti sono:

| Riferimento | RPC | Esito |
|---|---|---|
| BED-CON-01 | change_bed_geometry | blocked_by_plantings |
| BED-CON-02 | change_bed_geometry | blocked_by_confirmed_plans |
| BED-CON-03 | correct_bed_geometry | blocked_by_plantings |

La scheda INF-WA-003 contiene
la descrizione tecnica proprietaria.

### 4.3 Ricerca dei collaudi pertinenti

La ricerca statica dei due nomi di stato
ha individuato riferimenti nei test
di pianificazione e coltivazioni.

Non ha individuato richiami espliciti
pertinenti ai contratti geometrici Aiuole
nei test ricercati.

Non si esclude la presenza di collaudi
equivalenti formulati diversamente.

### 4.4 Verifiche residue specifiche

- Mapping tipizzato BED-CON-01.
- Mapping tipizzato BED-CON-02.
- Mapping tipizzato BED-CON-03.
- Gestione UI dei rifiuti determinati.
- Distinzione dagli esiti non determinabili.
- Compatibilita spaziale.
- Condizioni temporali di confine.
- Storico delle geometrie.
- Correzione della geometria precedente.
- Dipendenze delle pianificazioni confermate.
- Versionamento dell'aiuola.
- Atomicita e rollback.
- Aggiornamento GardenMap.
- Accessibilita delle aiuole inattive.
- Riattivazione e dipendenze operative.

La conseguenza applicativa delle difformita
contrattuali deve essere verificata con
collaudi mirati.

Le definizioni SQL locali e remote
non devono essere considerate equivalenti.

## 5. Evidenze Stagioni

### 5.1 Inventario

Riconciliazione RC02.07.05.

- File pertinenti individuati: 5.
- Dichiarazioni di test individuate: 59.

| Area | Dichiarazioni |
|---|---:|
| SeasonRepository | 22 |
| AddPlantingPage | 6 |
| GardenPage | 9 |
| PlanningRouteIntegration | 15 |
| SeasonsPage | 7 |
| Totale | 59 |

Le dichiarazioni parametrizzate del repository
generano complessivamente 33 casi eseguibili.

Non e stato determinato il numero eseguibile
complessivo dei cinque file.

### 5.2 Collaudo mirato repository

File:

test/data/repositories/season_repository_test.dart

Comando eseguito:

flutter test test/data/repositories/season_repository_test.dart

Risultato:

- Test superati: 33/33.
- Durata riportata: 12 secondi.
- Esito: PASS.
- Sessione: S048.
- Data: 27/11/2026.

Il file utilizza provider, loader,
lease e risposte RPC simulati.

Il collaudo non invoca il database reale.

Le evidenze E4 riguardano esclusivamente
le asserzioni eseguite.

### 5.3 Distribuzione dei casi eseguibili

| Area | Casi |
|---|---:|
| Gate locale | 1 |
| Creazione | 8 |
| Modifica | 9 |
| Attivazione | 9 |
| Lettura stagione attiva | 1 |
| Lettura elenco stagioni | 5 |
| Totale | 33 |

### 5.4 Parametri delle mutazioni

Le asserzioni dei principali casi positivi
verificano le mappe complete dei parametri RPC.

| RPC | Parametri verificati |
|---|---:|
| create_season | 10/10 |
| update_season | 11/11 |
| activate_season | 6/6 |
| Totale | 27/27 |

Sono comprese le dodici informazioni
complessive della Write Authority
e le due versioni attese dei record.

Sono verificati il nome della RPC
e il numero di invocazioni nei casi pertinenti.

### 5.5 Esiti contrattuali

| RPC | Esiti verificati |
|---|---:|
| create_season | 6/6 |
| update_season | 8/8 |
| activate_season | 7/7 |
| Totale | 21/21 |

Le verifiche comprendono risultati positivi,
rifiuti tipizzati, operazioni invariate
e conflitti di versione, ove applicabili.

I conflitti delle operazioni update
e activate verificano i quattro campi
pertinenti della risposta.

L'attivazione verifica anche le informazioni
della precedente stagione disattivata.

Il caso senza precedente stagione verifica
il tipo del risultato e l'assenza
della struttura opzionale.

Non attribuire a tale caso ulteriori
asserzioni non individuate nel sorgente.

### 5.6 Risposte di protocollo non valide

Sono state individuate quattro verifiche:

- Stato di creazione sconosciuto.
- Risposta di creazione priva di created_at.
- Risposta di modifica non rappresentata da una mappa.
- Dati parziali della stagione disattivata.

Ulteriori combinazioni di risposte
malformate devono essere valutate
senza duplicare i test gia presenti.

### 5.7 Assenza della Write Authority

Il file comprende un test esplicito
di create_season senza provider di scrittura.

Il test verifica:

- Rifiuto locale dell'operazione.
- Nessuna invocazione RPC.
- Assenza del nome RPC registrato.
- Assenza dei parametri RPC registrati.

Non sono stati individuati nel file
casi espliciti equivalenti per:

- update_season.
- activate_season.

Tale assenza non dimostra che le due
operazioni siano prive del gate locale.

Verificare la copertura condivisa
prima di aggiungere nuovi casi.

### 5.8 Lettura della stagione attiva

Il test esaminato verifica:

- Identificativo orto trasmesso.
- Nove campi del modello Season.
- Nessuna invocazione RPC di mutazione.

La gestione dell'assenza della stagione
attiva deve essere verificata nei chiamanti.

### 5.9 Lettura elenco stagioni

Sono stati individuati cinque casi:

- Elenco vuoto.
- Stagioni attive e inattive.
- Identificativo orto vuoto.
- Risultato appartenente a un altro orto.
- Loader non disponibile.

L'ordine dei risultati simulati non
certifica l'ordinamento effettivo SQL.

### 5.10 Evidenze delle interfacce

I titoli dei test SeasonsPage indicano
verifiche relative a:

- Apertura delle pianificazioni.
- Stato di caricamento.
- Nome dell'orto ed elenco stagioni.
- Distinzione attive e inattive.
- Elenco vuoto.
- Errore e ripetizione del caricamento.
- Ricaricamento dopo il nuovo tentativo.

Sono state individuate due verifiche
GardenPage specificamente pertinenti:

- Apertura delle stagioni dell'orto selezionato.
- Blocco dell'autorita iniettata nel percorso.

Le asserzioni complete di questi test
non sono state esaminate in RC02.07.05.

### 5.11 Evidenze lifecycle pianificazione

Sono stati individuati 15 titoli
di test PlanningRouteIntegration
riferiti alle seguenti condizioni:

1. Disponibilita della route originaria.
2. Condivisione repository e lease.
3. Chiusura e riapertura delle route.
4. Chiusura SeasonsPage.
5. Rimozione SeasonsPage con figlio ancora presente.
6. Distruzione del navigatore.
7. Distruzione GardenPage.
8. Perdita autorita e nuovo lease.
9. Release concorrente alla distruzione.
10. Route inizialmente in sola lettura.
11. Provider RPC senza loader.
12. Loader senza provider RPC.
13. Coppia completa dei provider.
14. Configurazioni incompatibili.
15. Consultazione dopo perdita autorita.

La presenza di questi titoli aggiorna
la ricognizione precedente sul lifecycle.

Non classificare tali collaudi come assenti.

La verifica delle asserzioni e rinviata
a RC02.07.09.

### 5.12 Verifiche residue specifiche

| Riferimento | Verifica |
|---|---|
| SEA-T01 | Update senza lease |
| SEA-T02 | Activate senza lease |
| SEA-T03 | Scadenza e perdita del lease |
| SEA-T04 | Identita delle risposte |
| SEA-T05 | Date e versioni non valide |
| SEA-T06 | Assenza della stagione attiva |
| SEA-T07 | Atomicita e rollback attivazione |
| SEA-T08 | Concorrenza effettiva |
| SEA-T09 | Risposte non determinabili |
| SEA-T10 | Integrazione reale Flutter-Supabase |

Gli identificativi sono riferimenti locali
delle verifiche residue.

Non costituiscono nuove non conformita
formalizzate.

## 6. Evidenze Pianificazione

### 6.1. Riesecuzione mirata S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Flutter locale, dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/data/repositories/planned_planting_repository_test.dart test/data/repositories/planned_planting_repository_http_test.dart test/core/write_authority/seasonal_planning_mutation_receipt_test.dart test/core/write_authority/planning_route_lifetime_test.dart test/pages/planning_route_integration_test.dart test/pages/planned_plantings_write_availability_test.dart
```

Risultato: 161/161 PASS. Tempo del runner: 12 secondi. Codice di uscita: 0.
Il primo avvio in sandbox è stato interrotto dopo essere rimasto senza
output. L'esecuzione completata ha avuto accesso autorizzato alla cache
dell'SDK locale.

### 6.2. Perimetro delle evidenze

Repository, trasporto HTTP simulato, verifica e recupero delle ricevute,
disponibilità di scrittura e lifecycle della route. Livello E4 per i
comportamenti coperti. Collaudo integrato con Supabase sulla baseline
corrente: NV.

I 161 casi sono una riesecuzione mirata registrata separatamente.
Il totale della suite generale di apertura resta 1.956 test.

## 7. Evidenze Coltivazioni

### 7.1. Riesecuzione mirata S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Flutter locale, dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/data/repositories/planting_repository_write_test.dart test/pages/add_planting_page_test.dart test/pages/bed_page_test.dart test/widgets/garden/garden_map_test.dart
```

Risultato: 85/85 PASS. Tempo del runner: 11 secondi. Codice di uscita: 0.
Perimetro: repository, modulo di coltivazione, pagina aiuola e accesso
dalla mappa. Livello E4 per i comportamenti coperti. Collaudo integrato
con Supabase sulla baseline corrente: NV.

Gli 85 casi sono registrati come riesecuzione mirata separata.
Il totale della suite generale di apertura resta 1.956 test.

## 8. Altri domini

### 8.1. Catalogo e Impostazioni, riesecuzione mirata S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Esecuzione Flutter locale dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/data/repositories/agronomic_parameter_repository_test.dart test/data/repositories/botanical_taxon_repository_test.dart test/data/repositories/catalog_authority_repository_test.dart test/data/repositories/crop_cultivar_repository_test.dart test/data/repositories/crop_repository_test.dart test/data/repositories/harvest_purpose_repository_test.dart test/data/repositories/measurement_unit_repository_test.dart test/data/repositories/production_context_repository_test.dart test/data/repositories/protection_context_repository_test.dart test/data/repositories/training_context_repository_test.dart test/pages/agronomic_catalog_page_test.dart test/pages/settings_page_test.dart
```

Risultato: 251/251 PASS in 12 file. Tempo riportato dal runner:
7 secondi. Codice di uscita: 0.

Il perimetro copre i nove repository del Catalogo, le capability e
l'assegnazione iniziale della Catalog Authority, la pagina del Catalogo
e la navigazione da Impostazioni. Livello E4 per i comportamenti
collaudati. Collaudo integrato con Supabase: NV.

I 251 casi sono registrati come riesecuzione mirata separata.
Il totale della suite generale di apertura resta 1.956 test.

## 9. Collaudi trasversali riutilizzabili

Riferimenti proprietari:

- TST-RC01-001: identita e profilo.
- TST-RC02-001: evidenze strutturali SQL.
- TST-RC02-002: infrastruttura Flutter.
- INF-WA-002: lifecycle Write Authority.

Accorpare le verifiche comuni relative a:

- Identita client e sessione.
- Autorita del proprietario.
- Assenza del lease.
- Scadenza del lease.
- Perdita dell'autorita.
- Invalidazione delle route.
- Versionamento.
- Concorrenza.
- Risposte non determinabili.
- Privilegi e RLS.
- Integrazione Flutter-Supabase.

Le verifiche saranno attribuite
alle riconciliazioni competenti.

Non moltiplicare il lavoro comune
per il numero dei domini.

### 9.1. Verifiche trasversali e lifecycle, riesecuzione mirata S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Flutter locale, dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/data/repositories/profile_edit_lock_repository_test.dart test/core/write_authority/profile_write_authority_controller_test.dart test/core/write_authority/route_write_availability_test.dart test/core/profile/profile_session_gate_test.dart
```

Risultato: 92/92 PASS in quattro file. Tempo del runner: 2 secondi.
Codice di uscita: 0. Il perimetro copre repository del lock, controller,
disponibilità di scrittura della route e ProfileSessionGate.

Livello E4 per i comportamenti collaudati. Restano aperte C04, C07 e C09.
Collaudo integrato con Supabase sulla baseline corrente: NV.
I 92 casi sono una riesecuzione mirata separata. Il totale della suite
generale di apertura resta 1.956 test.

## 10. Matrice copertura e verifiche residue

### 10.1 Inventario statico

| Dominio | File pertinenti | Dichiarazioni |
|---|---:|---:|
| Orti | 8 | 57 |
| Aiuole | 15 | 220 |
| Stagioni | 5 | 59 |

I file possono essere condivisi
tra piu domini.

Non utilizzare la somma delle righe
come numero di file univoci.

Non utilizzare la somma delle dichiarazioni
come numero di test univoci.

### 10.2 Copertura delle evidenze

| Evidenza | Orti | Aiuole | Stagioni |
|---|---|---|---|
| Inventario statico | Acquisito | Acquisito | Acquisito |
| Contratti SQL-Flutter | E3 | E3 | E3 |
| Esecuzione mirata S048 | NV | NV | 33/33 PASS |
| Asserzioni repository approfondite | NV | NV | E4 parziale |
| Integrazione reale S048 | NV | NV | NV |
| Accettazione operativa | NV | NV | NV |

NV indica una verifica non acquisita
nel perimetro di questa ricognizione.

Non implica necessariamente l'assenza
di evidenze storiche in altre schede.

### 10.3 Regole di riutilizzo

RIUTILIZZARE:

- Suite generali esistenti.
- Test unitari gia pertinenti.
- Infrastrutture di simulazione.
- Test condivisi della Write Authority.

INTEGRARE:

- Coperture incomplete dei contratti.
- Collegamento dei collaudi ai nuovi flussi UI.
- Verifiche specifiche delle difformita accertate.

VERIFICARE:

- Asserzioni non ancora esaminate.
- Comportamento effettivo SQL.
- Concorrenza e rollback.
- Integrazione reale e ambiente remoto.

SVILUPPARE:

- Soltanto i casi mancanti dopo
  il completamento della riconciliazione.

## 11. Registro esecuzioni

| Sessione | Esecuzione | Risultato | Durata |
|---|---|---|---|
| S048 apertura | flutter analyze | PASS | 19,0 s |
| S048 apertura | flutter test | 1956/1956 PASS | 2 min 53 s |
| S048 RC02.07.05.20 | season_repository_test.dart | 33/33 PASS | 12 s |
| S048 RC02.07.06 | Pianificazione, sei file Flutter | 161/161 PASS | 12 s |
| S048 RC02.07.07 | Coltivazioni, quattro file Flutter | 85/85 PASS | 11 s |
| S048 RC02.07.08 | Catalogo e Impostazioni, 12 file Flutter | 251/251 PASS | 7 s |
| S048 RC02.07.09 | Verifiche trasversali e lifecycle, quattro file Flutter | 92/92 PASS | 2 s |
| S048 RC05 | Contratto, coordinatore, journal e ricevute, quattro file Flutter | 182/182 PASS | 3 s |
| S048 RC08 | Geometrie e storico, cinque file Flutter | 399/399 PASS | 15 s |
| S048 RC09 | Schermata Stagioni, un file Flutter | 7/7 PASS | 2 s |

I 33 casi della suite mirata appartengono
alla suite generale gia esistente.

Il numero di test univoci non aumenta
in conseguenza della ripetizione.

Nessun nuovo test implementato
durante la ricognizione dei tre domini.

Nessuna migrazione applicata.

Nessuna verifica operativa remota
effettuata mediante questi collaudi.

### 11.1. Ricognizione RC02.09 — Test ed evidenze integrate

| Evidenza | Esito e perimetro |
|---|---|
| Baseline Flutter S048 | flutter analyze PASS e 1.956/1.956 test superati all'apertura. Baseline Git d1de8f659b52605aa52941ea33e920db5d684bd7. |
| Riesecuzioni mirate S048 | Stagioni 33/33, Pianificazione 161/161, Coltivazioni 85/85, Catalogo e Impostazioni 251/251, verifiche trasversali 92/92. Le esecuzioni sono registrate singolarmente nel §11 e il totale della suite generale resta 1.956. |
| Collaudo integrato storico S045 | 5/5 operazioni di Pianificazione verificate con Microsoft Edge e Supabase locale. Sei ricevute COMPLETED rilevate e recupero dell'esito senza ripetere la mutazione. |
| Baseline corrente | Collaudo integrato Flutter–Supabase, verifica remota e accettazione operativa: NV. |

Le evidenze storiche sono tracciate in
[TST-S046-001](TST-S046-001_Baseline_Collaudi.md).
Il collaudo S045 riguarda Pianificazione nel suo ambiente locale.
Le riesecuzioni S048 attestano i comportamenti Flutter collaudati (E4).
Le verifiche integrate sulla baseline corrente restano aperte.

La ricognizione RC02.09 è documentale. Gli script SQL locali non sono
stati eseguiti durante questa verifica. Lo script S040 è contrassegnato
nel sorgente come incompleto.

### 11.2. RC05 — Riesecuzione mirata Flutter S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Esecuzione Flutter locale dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/core/write_authority/mutation_operation_contract_test.dart test/core/write_authority/mutation_operation_coordinator_test.dart test/core/write_authority/mutation_operation_journal_test.dart test/core/write_authority/seasonal_planning_mutation_receipt_test.dart
```

Risultato: 182/182 PASS in quattro file. Tempo del runner: 3 secondi.
Codice di uscita: 0. Il perimetro comprende contratto delle mutazioni,
coordinatore, journal e validazione delle ricevute, inclusa la
conservazione del journal quando l'aggiornamento dei dati fallisce.

Livello E4 per i comportamenti collaudati. Collaudo integrato con
PostgreSQL sulla baseline corrente: NV. I 182 casi sono una
riesecuzione mirata separata. La suite generale di apertura resta
a 1.956 test.

### 11.3. RC08 — Riesecuzione mirata Flutter S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Esecuzione Flutter locale dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/data/models/bed_geometry_test.dart test/data/repositories/bed_repository_write_test.dart test/pages/change_bed_geometry_page_test.dart test/pages/correct_bed_geometry_page_test.dart test/widgets/garden/garden_map_test.dart
```

Risultato: 399/399 PASS in cinque file. Tempo del runner: 15 secondi.
Codice di uscita: 0. Il perimetro comprende modello geometrico,
repository Aiuole, schermate di variazione e correzione e mappa.

Livello E4 per i comportamenti specifici collaudati. Il collaudo
integrato con PostgreSQL resta NV. Per change_bed_geometry restano
aperti gli esiti SQL blocked_by_plantings e blocked_by_confirmed_plans
nel decodificatore Flutter.

I 399 casi sono registrati come riesecuzione mirata separata.
La suite generale di apertura resta a 1.956 test.

### 11.4. RC09 — Riesecuzione mirata della schermata Stagioni S048

Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7.
Comando eseguito dalla directory orto_app:

```powershell
flutter test --no-pub --reporter expanded test/pages/seasons_page_test.dart
```

Risultato: 7/7 PASS. Tempo del runner: 2 secondi. Codice di uscita: 0.
I test verificano la distinzione tra stagioni attive e inattive e
l'apertura della pianificazione della stagione selezionata. Livello E4
per i comportamenti della schermata collaudati.

La riesecuzione è registrata separatamente. Il collaudo di
SeasonRepository (33/33 PASS) è già documentato nel §5.2. Il totale
della suite generale di apertura resta 1.956 test.

Attivazione concorrente ed effetti del restringimento delle date sui
record collegati: NV a runtime.

## 12. Collegamenti alle altre schede

- [Standard Registro](../01_architettura/ARC-REG-001_Standard_Registro.md)
- [Infrastruttura Flutter Write Authority](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md)
- [Integrazione nei domini](../02_infrastrutture/INF-WA-003_Integrazione_Write_Authority_Domini.md)
- [Evidenze identita e profilo](TST-RC01-001_Evidenze_Identita_Profilo.md)
- [Evidenze strutturali SQL](TST-RC02-001_Evidenze_Strutturali_SQL.md)
- [Evidenze collaudi Flutter](TST-RC02-002_Evidenze_Collaudi_Flutter.md)
- [Baseline collaudi S046](TST-S046-001_Baseline_Collaudi.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [Stato RC02](../08_riutilizzo/RC02_Stato_Parziale.md)
- [Stato corrente](../10_stato_operativo/STATO_CORRENTE.md)
