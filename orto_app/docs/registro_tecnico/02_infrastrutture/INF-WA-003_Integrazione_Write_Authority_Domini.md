# Orto Smart - Integrazione Write Authority nei domini

## Metadati

- Identificativo: INF-WA-003
- Versione: 1.0
- Sessione di introduzione: S048
- Data: 27/11/2026
- Stato: consolidamento intermedio in corso
- Baseline sorgenti: d1de8f659b52605aa52941ea33e920db5d684bd7
- Riconciliazione: RC02.07
- Macroblocchi interessati: V1-02, V1-05, V1-06, V1-07
- Ambiente: repository locale Windows, Flutter, Supabase locale

## 1. Finalita e perimetro

La scheda registra l'integrazione della Write Authority
nei domini applicativi di Orto Smart.

Distingue le infrastrutture disponibili dalle integrazioni
effettivamente presenti, dalle verifiche residue e dalle
funzionalita mancanti.

Non sostituisce il codice sorgente, le migrazioni o le
schede proprietarie delle infrastrutture condivise.

## 2. Baseline tecnica e livelli di evidenza

Baseline acquisita all'apertura S048:

- Branch main.
- HEAD e origin/main coincidenti.
- Working tree pulita.
- Flutter analyze: PASS.
- Flutter test: 1956/1956 PASS.
- Migrazioni locali: 48.
- Migrazioni remote: 34.
- Migrazioni remote pendenti: 14.

Le evidenze strutturali sono classificate E3.
Le specifiche asserzioni collaudate sono classificate E4.
Le verifiche integrate non eseguite rimangono NV.

Non viene attribuito il livello E5.

## 3. Inventario delle mutazioni applicative

Ricognizione RC02.07.02:

- Repository Flutter individuati: 19.
- Punti di invocazione RPC nei repository: 17.
- Nomi RPC distinti individuati: 58.
- Nomi RPC espliciti: 53.
- Nomi RPC dinamici del registro mutazioni: 5.
- Repository con provider Write Authority di profilo: 5.

Repository con provider:

- GardenRepository.
- BedRepository.
- SeasonRepository.
- PlannedPlantingRepository.
- PlantingRepository.

La ricerca statica non ha individuato invocazioni dirette
insert, update, delete o upsert nei repository esaminati.

Tale risultato non esclude scritture indirette,
esterne ai repository o non intercettate dalla ricerca.

Le 58 RPC comprendono mutazioni, letture, gestione lock,
Catalog Authority e operazioni del registro mutazioni.

Non rappresentano 58 mutazioni di dominio.

### 3.1 Catalog Authority

Sono state individuate 27 mutazioni del catalogo,
distribuite in nove famiglie:

- Parametri agronomici.
- Taxa botanici.
- Cultivar.
- Colture.
- Finalita di raccolta.
- Unita di misura.
- Contesti produttivi.
- Contesti di protezione.
- Contesti di allevamento.

Per ciascuna famiglia risultano operazioni di creazione,
aggiornamento e variazione dello stato attivo.

La Catalog Authority e distinta dalla Write Authority
di profilo.

La riconciliazione approfondita e rinviata a RC02.07.08.

### 3.2 Registro mutazioni pianificazione

Sono state individuate cinque mutazioni di pianificazione,
cinque RPC dinamiche di registrazione e tre operazioni
accessorie di consultazione o chiusura degli intenti.

Il dettaglio di Pianificazione è consolidato in §9. Restano gli approfondimenti RC05.

Non estendere automaticamente il registro mutazioni
agli altri domini senza una valutazione specifica.

## 4. Infrastrutture condivise riutilizzabili

Riferimenti principali:

- ProfileWriteAuthorityController.
- ProfileWriteAuthorityScope.
- ProfileEditLockLease.
- AppSessionIdentity.
- RouteWriteAvailability.
- PlanningRouteLifetime.
- ProfileWriteAuthorityUnavailableException.
- Helper SQL private.lock_profile_write_authority.

Riutilizzare le infrastrutture gia riconciliate in RC02.06.

Non duplicare la gestione del lease, delle identita,
delle scadenze o dell'invalidazione delle route.

La Write Authority locale non sostituisce
l'autorizzazione finale del server.

## 5. Matrice di riconciliazione D01-D14

D01 - Operazione applicativa.
D02 - Pagina, widget e punto di accesso.
D03 - Accesso alla Write Authority condivisa.
D04 - Acquisizione e validazione del lease.
D05 - Identificativo profilo.
D06 - Identita client e sessione.
D07 - Token di scrittura.
D08 - Percorso servizio, repository, RPC e helper.
D09 - Versione attesa del record, ove applicabile.
D10 - Esiti, errori e conflitti.
D11 - Assenza o perdita dell'autorita.
D12 - Lifecycle, scadenza e invalidazione.
D13 - Test ed evidenze disponibili.
D14 - Classificazione di riutilizzo.

Distinguere la versione del lease dalla versione
del record applicativo.

Le condizioni non applicabili devono essere motivate.

## 6. Dominio Orti

### 6.1 Responsabilita e stato

- Macroblocco proprietario: V1-05.
- Riconciliazione: RC02.07.03.
- Sessione ultima verifica: S048.
- Data ultima verifica: 27/11/2026.
- Riconciliazione tecnica: conclusa.
- Implementazione funzionale: parziale.
- Livello generale di evidenza: E3.

Il dominio dispone di due RPC autoritative SQL.
Una sola risulta integrata nel repository e nella UI.

### 6.2 Sorgenti principali

- lib/data/repositories/garden_repository.dart
- lib/data/models/garden.dart
- lib/pages/create_garden_page.dart
- lib/pages/garden_page.dart
- supabase/migrations/20260823145731*
- supabase/migrations/20260825173801*

I riferimenti alle migrazioni identificano i prefissi
temporali acquisiti durante la riconciliazione.

### 6.3 Inventario operazioni

| Operazione | SQL | Repository | UI |
|---|---|---|---|
| Lettura orti | SELECT | Presente | Presente |
| Creazione orto | create_garden | Presente | Presente |
| Modifica orto | update_garden | Assente | Assente |

La variazione dello stato attivo e compresa nel
contratto update_garden.

Non e stata individuata una RPC separata necessaria
per la sola variazione dello stato attivo.

### 6.4 Creazione orto

La RPC create_garden dispone di 14 parametri:

- Quattro parametri della Write Authority.
- Dieci parametri applicativi.

Il repository trasmette le credenziali del lease
e verifica la corrispondenza del profilo.

La riconciliazione statica ha confermato:

- Parametri SQL-Flutter: 14/14.
- Esiti SQL-Flutter: 5/5.
- Integrazione repository: presente.
- Integrazione UI: presente.

La RPC verifica l'autenticazione, l'autorita del
proprietario e il possesso della Write Authority.

Sono presenti normalizzazione dei dati, validazioni
geografiche, controlli del fuso orario e gestione
del vincolo di unicita pertinente.

### 6.5 Modifica orto

La RPC update_garden dispone di 17 parametri,
comprendenti identificativo orto, versione attesa,
stato attivo, credenziali e dati applicativi.

Il sorgente SQL prevede:

- Controllo dell'autorita del proprietario.
- Verifica della Write Authority.
- Blocco del record mediante FOR UPDATE.
- Controllo della versione attesa.
- Gestione del conflitto di versione.
- Gestione dell'operazione senza modifiche.
- Incremento della versione in caso di aggiornamento.
- Otto esiti contrattuali.

La RPC risulta disponibile nel sorgente SQL,
ma non integrata nel GardenRepository.

Non e stata individuata una UI di modifica orto.

Classificazione:

- RPC SQL: RIUTILIZZARE.
- Collegamento repository: INTEGRARE.
- Contratti Flutter mancanti: SVILUPPARE.
- Interfaccia modifica: SVILUPPARE.
- Collaudi specifici mancanti: SVILUPPARE.
- Comportamento effettivo SQL: VERIFICARE.

### 6.6 Modello Garden

Il modello Flutter e la lettura del repository
gestiscono sei campi:

- id
- profile_id
- name
- description
- is_active
- row_version

Otto ulteriori informazioni applicative necessarie
alla modifica completa non risultano rappresentate
nel modello riconciliato:

- Latitudine.
- Longitudine.
- Altitudine.
- Fuso orario.
- Paese.
- Comune.
- Localita.
- Indirizzo.

Integrare il modello e le letture senza duplicare
la struttura dati gia disponibile nel database.

Verificare i nomi SQL esatti e la nullabilita
dei campi prima di intervenire sul codice.

### 6.7 Interfaccia e lifecycle

CreateGardenPage dispone di validazioni applicative,
controllo del profilo, protezione contro invii
concorrenti e gestione del salvataggio.

La pagina blocca ulteriori tentativi dopo un esito
di scrittura non determinabile.

Sono presenti controlli mounted prima delle
operazioni successive alle attese asincrone.

GardenPage verifica il contesto della route
di creazione e prevede il ricaricamento dei dati
al rientro, se il contesto rimane valido.

Non e stata individuata una protezione specifica
dell'identita originaria del token nella pagina
di creazione, equivalente a quella riconciliata
per le route della pianificazione.

La necessita di tale protezione deve essere
valutata in RC02.07.09.

Non estendere automaticamente il registro delle
mutazioni della pianificazione al dominio Orti.

### 6.8 Matrice D01-D14

| ID | Evidenza | Classificazione |
|---|---|---|
| D01 | Due mutazioni SQL, una integrata | INTEGRARE |
| D02 | Creazione presente, modifica assente | SVILUPPARE |
| D03 | Infrastruttura Write Authority disponibile | RIUTILIZZARE |
| D04 | Provider lease presente nel repository | RIUTILIZZARE |
| D05 | Controllo profilo in creazione | RIUTILIZZARE |
| D06 | Identita client e sessione trasmesse | RIUTILIZZARE |
| D07 | Token trasmesso alla RPC | RIUTILIZZARE |
| D08 | Percorso creazione presente, modifica incompleta | INTEGRARE |
| D09 | Versionamento update presente in SQL | INTEGRARE |
| D10 | Cinque esiti gestiti, otto da integrare | INTEGRARE |
| D11 | Gate locale e protezioni server disponibili | VERIFICARE |
| D12 | Lifecycle e risposta non determinabile | VERIFICARE |
| D13 | Inventario test acquisito | VERIFICARE |
| D14 | Infrastrutture comuni riutilizzabili | RIUTILIZZARE |

La versione attesa del record non e applicabile
alla creazione di un nuovo orto.

### 6.9 Copertura contrattuale

| Indicatore | Disponibile | Riferimento |
|---|---:|---:|
| RPC autoritative SQL | 2 | 2 |
| Mutazioni repository | 1 | 2 |
| Mutazioni UI | 1 | 2 |
| Esiti create_garden | 5 | 5 |
| Esiti update_garden | 0 | 8 |
| Esiti complessivi | 5 | 13 |

La copertura contrattuale Flutter e pari al 38,46%.

Questo indicatore non rappresenta la maturita
complessiva del macroblocco V1-05.

### 6.10 Collaudi

Sono stati individuati otto file di test pertinenti
e 57 dichiarazioni di test.

Il conteggio non rappresenta il numero dei casi
eseguibili ne una certificazione della copertura
integrale del dominio.

Nessun nuovo collaudo mirato Orti e stato
eseguito durante RC02.07.03.

La suite generale iniziale S048 ha superato
1956/1956 test.

Le evidenze dettagliate saranno collocate nella
scheda proprietaria TST-RC02-003.

### 6.11 Attivita residue

- Integrare update_garden nel repository.
- Integrare gli otto esiti contrattuali mancanti.
- Completare il modello e le letture.
- Realizzare l'interfaccia di modifica.
- Collegare le protezioni Write Authority.
- Gestire conflitti e aggiornamento delle versioni.
- Verificare le conseguenze della disattivazione.
- Verificare privilegi, RLS e autorizzazioni.
- Verificare lifecycle e perdita dell'autorita.
- Verificare la gestione degli esiti non determinabili.
- Completare i collaudi specifici e integrati.

Le verifiche trasversali devono essere accorpate
con quelle degli altri domini in RC02.07.09,
RC03, RC04, RC05 e RC17, secondo competenza.

Non e stata dimostrata la necessita di una nuova
RPC autoritativa per la modifica dell'orto.

Nessuna nuova non conformita formalizzata.

Nessuna variazione quantitativa A/B approvata.

### 6.12 Conclusione

Il dominio Orti dispone delle RPC autoritative
necessarie alle due mutazioni esaminate.

L'attivita residua principale riguarda
l'integrazione Flutter della modifica orto.

La riconciliazione RC02.07.03 e conclusa.
L'accettazione operativa del dominio rimane aperta.

## 7. Dominio Aiuole

### 7.1 Responsabilita e stato

- Macroblocco proprietario: V1-06.
- Riconciliazione: RC02.07.04.
- Sessione ultima verifica: S048.
- Data ultima verifica: 27/11/2026.
- Riconciliazione tecnica: conclusa.
- Implementazione funzionale: parziale.
- Livello generale di evidenza: E3.

Il dominio dispone di cinque RPC autoritative,
tutte integrate nel repository e nelle interfacce.

Sono state individuate tre difformita contrattuali
tra gli esiti SQL e quelli gestiti in Flutter.

### 7.2 Sorgenti principali

- lib/data/repositories/bed_repository.dart
- lib/data/models/bed.dart
- lib/core/write_authority/bed_write_result.dart
- lib/pages/create_bed_page.dart
- lib/pages/edit_bed_page.dart
- lib/pages/bed_page.dart

Ulteriori componenti esaminati:

- Modello geometria aiuola.
- Tipo CivilDate.
- Interfaccia GardenMap.
- Interfaccia variazione geometria.
- Interfaccia correzione geometria.

Migrazioni contenenti le definizioni RPC riconciliate:

- 20260830095426: create_bed.
- 20260830101354: update_bed.
- 20260830103544: set_bed_active.
- 20261104230000: change_bed_geometry.
- 20260915081444: correct_bed_geometry.

I riferimenti alle migrazioni sono espressi mediante
i prefissi temporali identificati durante la ricognizione.

La definizione riconciliata di change_bed_geometry
appartiene alle migrazioni applicate localmente
ma non ancora applicate al database remoto.

### 7.3 Inventario operazioni

| Operazione | SQL | Repository | UI |
|---|---|---|---|
| Lettura elenco aiuole | SELECT | Presente | Presente |
| Lettura singola aiuola | SELECT | Presente | Presente |
| Creazione | create_bed | Presente | Presente |
| Modifica | update_bed | Presente | Presente |
| Variazione stato attivo | set_bed_active | Presente | Presente |
| Variazione geometria | change_bed_geometry | Presente | Presente |
| Correzione geometria | correct_bed_geometry | Presente | Presente |

Le letture dell'elenco ordinario restituiscono
le aiuole attive e la geometria corrente.

La lettura della singola aiuola non applica
lo stesso filtro sullo stato attivo.

### 7.4 Contratti delle RPC

| RPC | Parametri | Esiti SQL | Esiti Flutter |
|---|---:|---:|---:|
| create_bed | 11 | 6 | 6 |
| update_bed | 9 | 8 | 8 |
| set_bed_active | 7 | 7 | 7 |
| change_bed_geometry | 9 | 10 | 8 |
| correct_bed_geometry | 11 | 8 | 7 |
| Totale | 47 | 39 | 36 |

La riconciliazione statica ha confermato:

- Parametri SQL-Flutter: 47/47.
- Parametri Write Authority: 20/20.
- Versioni attese aiuola: 4/4.
- Esiti contrattuali: 36/39.
- Copertura contrattuale: 92,31%.

La correzione geometrica utilizza la versione
attesa dell'aiuola.

Non e prevista nel contratto esaminato una
versione attesa separata della geometria.

La percentuale contrattuale non rappresenta
la maturita complessiva del macroblocco V1-06.

### 7.5 Creazione aiuola

La RPC create_bed dispone di undici parametri.

Il percorso SQL verifica l'autorita del proprietario,
la Write Authority e l'appartenenza dell'orto.

Sono presenti il blocco del record orto e
una successiva verifica della Write Authority.

La creazione dell'aiuola e della geometria
iniziale avviene nella stessa operazione SQL.

La gestione delle date civili considera
il fuso orario dell'orto.

Il repository gestisce tutti i sei esiti
contrattuali individuati.

Non e stato individuato un controllo esplicito
dello stato attivo dell'orto nella RPC esaminata.

La necessita funzionale di tale controllo
rimane da verificare.

L'atomicita effettiva deve essere confermata
mediante collaudo pertinente.

### 7.6 Modifica aiuola

La RPC update_bed dispone di nove parametri
e otto esiti contrattuali.

Sono presenti:

- Verifica dell'autorita del proprietario.
- Verifica della Write Authority.
- Blocco del record aiuola.
- Controllo della versione attesa.
- Successiva verifica della Write Authority.
- Gestione dei conflitti.
- Gestione dell'operazione invariata.
- Gestione del vincolo di unicita pertinente.

Tutti gli otto esiti risultano gestiti
nel repository Flutter.

Il comportamento effettivo del versionamento
e dei trigger deve essere raccordato a RC04.

### 7.7 Variazione stato attivo

La RPC set_bed_active dispone di sette parametri
e sette esiti contrattuali.

Il percorso SQL comprende controllo
dell'autorita, blocco del record e versionamento.

Tutti gli esiti risultano gestiti in Flutter.

Non sono stati individuati controlli espliciti
sulle dipendenze operative nella definizione
SQL esaminata.

Devono essere valutate le conseguenze della
disattivazione rispetto a:

- Coltivazioni esistenti.
- Pianificazioni.
- Consultazione dello storico.
- Accessibilita delle aiuole inattive.
- Eventuale riattivazione.

Non assumere automaticamente che la presenza
di dipendenze debba impedire la disattivazione.

La regola funzionale deve essere verificata
nelle riconciliazioni competenti.

### 7.8 Variazione geometria

La RPC change_bed_geometry dispone di nove
parametri e dieci esiti contrattuali.

La definizione esaminata comprende:

- Controllo dell'autorita del proprietario.
- Verifiche ripetute della Write Authority.
- Controllo della versione attesa.
- Gestione dello storico geometrico.
- Controlli temporali.
- Controlli di compatibilita spaziale.
- Protezioni rispetto alle coltivazioni.
- Protezioni rispetto alle pianificazioni confermate.

La riconciliazione ha evidenziato la distinzione
tra gli intervalli geometrici e delle coltivazioni,
trattati con estremi semiaperti, e la gestione
dell'estremo finale delle pianificazioni.

Le condizioni di confine devono essere verificate
con i collaudi pertinenti in RC08, RC14 e RC15.

Due esiti SQL non risultano gestiti
dal contratto Flutter esaminato:

- blocked_by_plantings
- blocked_by_confirmed_plans

La definizione SQL riconciliata e disponibile
localmente ma non ancora distribuita al remoto.

### 7.9 Correzione geometria

La RPC correct_bed_geometry dispone di undici
parametri e otto esiti contrattuali.

La definizione esaminata comprende:

- Controllo dell'autorita del proprietario.
- Verifiche ripetute della Write Authority.
- Controllo della versione attesa dell'aiuola.
- Blocco della geometria interessata.
- Blocco della geometria precedente, ove presente.
- Adeguamento dell'intervallo precedente.
- Conservazione dell'estremo finale pertinente.
- Controlli di compatibilita spaziale.
- Utilizzo di bigint nei calcoli pertinenti.
- Gestione differita del vincolo di sovrapposizione.
- Conservazione delle informazioni di audit.
- Motivazione della correzione.

Un esito SQL non risulta gestito
dal contratto Flutter esaminato:

- blocked_by_plantings

Non e stata individuata nella definizione
esaminata una protezione esplicita equivalente
per le pianificazioni confermate.

La necessita e la coerenza di tale protezione
devono essere valutate in RC08 e RC14.

Il comportamento effettivo dei vincoli,
dei trigger e del rollback rimane da verificare.

### 7.10 Difformita contrattuali accertate

| Riferimento | RPC | Esito SQL non gestito |
|---|---|---|
| BED-CON-01 | change_bed_geometry | blocked_by_plantings |
| BED-CON-02 | change_bed_geometry | blocked_by_confirmed_plans |
| BED-CON-03 | correct_bed_geometry | blocked_by_plantings |

Sono presenti tre combinazioni RPC-esito mancanti,
corrispondenti a due distinti nomi di stato.

Il parser Flutter non dispone dei relativi
rami di mapping tipizzato.

La riconciliazione statica indica che tali
risposte possono essere interpretate come
violazioni del protocollo.

Le interfacce geometriche possono quindi
trattare un rifiuto determinato del server
come un esito di scrittura non determinabile.

La conseguenza applicativa deve essere
confermata mediante collaudo mirato.

Classificazione: INTEGRARE.

Riutilizzare i contratti SQL esistenti e
completare i risultati tipizzati Flutter.

Non modificare automaticamente le RPC SQL
per adattarle ai contratti Flutter incompleti.

I riferimenti BED-CON sono identificativi
locali delle evidenze contrattuali.

Non costituiscono nuove non conformita
formalizzate nel Registro delle criticita.

### 7.11 Modelli e risultati tipizzati

Il modello Bed comprende otto campi.

Il modello della geometria comprende sette campi.

Sono disponibili rappresentazioni delle date
civili, delle dimensioni e delle versioni.

Le verifiche statiche hanno individuato
controlli sulle dimensioni positive,
sulle versioni e sugli intervalli pertinenti.

Il file bed_write_result.dart contiene:

- Cinque famiglie sealed di risultati.
- Trentasei esiti tipizzati.
- Una eccezione di protocollo.
- Una struttura relativa alla geometria precedente.

Totale: 43 dichiarazioni di classe individuate.

La struttura dei risultati esistenti deve
essere riutilizzata per le integrazioni mancanti.

### 7.12 Interfacce e lifecycle

#### Creazione

CreateBedPage dispone di validazioni applicative,
controllo del profilo e protezione degli invii.

In caso di esito non determinabile viene
impedita la ripetizione automatica della scrittura.

GardenMap prevede il ricaricamento dei dati
al rientro dalla route di creazione.

#### Modifica

EditBedPage utilizza la versione originaria
del record.

In caso di conflitto deve essere verificato
il comportamento dei tentativi successivi
con la medesima versione.

Non sono stati individuati controlli espliciti
equivalenti a quelli della creazione per
l'identita originaria del profilo e del lease.

Sono presenti protezioni per gli esiti
non determinabili.

Verificare la modificabilita dei campi
durante le operazioni asincrone.

#### Dettaglio aiuola

BedPage dispone di otto flussi operativi
gestiti mediante protezioni di esclusione.

Il caricamento utilizza controlli di generazione
per limitare l'applicazione di risposte obsolete.

Il repository predefinito non dispone
necessariamente del provider di scrittura.

GardenMap fornisce il repository configurato
con la Write Authority nel percorso esaminato.

La variazione diretta dello stato attivo
verifica la disponibilita del lease.

In caso di conflitto e disponibile
il ricaricamento manuale.

Il comportamento dopo esiti non determinabili
deve essere ulteriormente verificato.

Le route figlie esaminate determinano
il ricaricamento in presenza del risultato true.

#### Variazione e correzione geometrica

Le interfacce utilizzano CivilDate e
protezioni contro invii concorrenti.

Sono presenti protezioni contro nuovi tentativi
dopo esiti non determinabili.

Non sono stati individuati controlli espliciti
di conservazione dell'identita originaria
del lease equivalenti alle route pianificazione.

La necessita di tali controlli deve essere
valutata in RC02.07.09.

### 7.13 Aggiornamento GardenMap e aiuole inattive

Nel percorso esaminato, GardenMap apre BedPage
senza attendere il completamento della route.

Non e stato individuato un ricaricamento
automatico associato al rientro dal dettaglio.

Verificare l'aggiornamento della mappa dopo:

- Modifica dei dati aiuola.
- Variazione dello stato attivo.
- Variazione geometrica.
- Correzione geometrica.

La lettura ordinaria delle aiuole
esclude quelle inattive.

La riattivazione e disponibile dal dettaglio,
ma deve essere verificata l'esistenza
di un percorso alternativo per raggiungere
un'aiuola gia disattivata.

Non classificare tale percorso come assente
prima della verifica complessiva della navigazione.

### 7.14 Matrice D01-D14

| ID | Evidenza | Classificazione |
|---|---|---|
| D01 | Cinque mutazioni SQL integrate | RIUTILIZZARE |
| D02 | Interfacce delle cinque mutazioni presenti | RIUTILIZZARE |
| D03 | Write Authority condivisa disponibile | RIUTILIZZARE |
| D04 | Provider lease nei percorsi esaminati | RIUTILIZZARE |
| D05 | Controlli profilo presenti, lifecycle da approfondire | VERIFICARE |
| D06 | Identita client e sessione trasmesse | RIUTILIZZARE |
| D07 | Token trasmesso alle cinque RPC | RIUTILIZZARE |
| D08 | Percorsi autoritativi presenti | RIUTILIZZARE |
| D09 | Quattro versioni attese riconciliate | RIUTILIZZARE |
| D10 | Trentasei esiti gestiti, tre mancanti | INTEGRARE |
| D11 | Gate locale e controlli server presenti | VERIFICARE |
| D12 | Lifecycle, refresh ed esiti incerti | VERIFICARE |
| D13 | Inventario test acquisito | VERIFICARE |
| D14 | Infrastrutture comuni disponibili | RIUTILIZZARE |

La versione attesa del record non e applicabile
alla creazione di una nuova aiuola.

### 7.15 Collaudi

Sono stati individuati quindici file pertinenti
e 220 dichiarazioni di test.

Distribuzione delle dichiarazioni:

| Area | Dichiarazioni |
|---|---:|
| Repository | 113 |
| Pagine | 82 |
| Modelli | 13 |
| Widget | 6 |
| Motori | 4 |
| Servizi | 2 |
| Totale | 220 |

Il conteggio non rappresenta il numero
effettivo dei casi eseguibili.

La ricerca dei due esiti geometrici mancanti
non ha individuato test specifici Aiuole
che li richiamino esplicitamente.

Non e esclusa la presenza di verifiche
equivalenti formulate diversamente.

Nessun nuovo collaudo mirato Aiuole e stato
eseguito durante RC02.07.04.

La suite generale iniziale S048 ha superato
1956/1956 test.

Le evidenze dettagliate dei collaudi saranno
consolidate nella scheda TST-RC02-003.

### 7.16 Attivita residue

INTEGRARE:

- Tre combinazioni contrattuali RPC-esito.
- Risultati tipizzati Flutter pertinenti.
- Messaggi applicativi dei rifiuti geometrici.
- Aggiornamento GardenMap, se confermato necessario.

VERIFICARE:

- Accessibilita delle aiuole inattive.
- Dipendenze della disattivazione.
- Compatibilita con pianificazioni confermate.
- Versionamento e trigger.
- Condizioni temporali di confine.
- Atomicita e rollback.
- Concorrenza effettiva.
- Privilegi e RLS.
- Identita originaria delle route.
- Gestione dei conflitti.
- Gestione delle risposte non determinabili.
- Copertura dei collaudi esistenti.
- Integrazione reale Flutter-Supabase.

SVILUPPARE:

- Soltanto i casi di test effettivamente mancanti,
  dopo la riconciliazione delle evidenze esistenti.

Le verifiche condivise devono essere accorpate
in RC02.07.09, RC03, RC04, RC05, RC08,
RC14, RC15 e RC17, secondo competenza.

### 7.17 Conclusione

Il dominio Aiuole dispone di tutte le cinque
mutazioni autoritative esaminate.

Non e stata dimostrata la necessita
di nuove RPC per le operazioni riconciliate.

La principale integrazione contrattuale
riguarda tre esiti SQL non gestiti in Flutter.

Le ulteriori verifiche riguardano il lifecycle,
la consistenza della navigazione, le dipendenze
operative e la sicurezza effettiva.

La riconciliazione RC02.07.04 e conclusa.

L'accettazione operativa rimane aperta.

Nessuna nuova non conformita formalizzata.

Nessuna variazione quantitativa A/B approvata.

## 8. Dominio Stagioni

### 8.1 Responsabilita e stato

- Macroblocco proprietario: V1-07.
- Riconciliazione: RC02.07.05.
- Sessione ultima verifica: S048.
- Data ultima verifica: 27/11/2026.
- Riconciliazione tecnica: conclusa.
- Implementazione funzionale: parziale.
- Livello generale di evidenza: E3.
- Collaudi specifici repository: E4 limitatamente alle asserzioni verificate.

Il dominio dispone di tre RPC autoritative SQL,
tutte integrate nel repository Flutter.

Le tre mutazioni non risultano ancora integrate
nelle interfacce applicative esaminate.

### 8.2 Sorgenti principali

- lib/data/repositories/season_repository.dart
- lib/data/models/season.dart
- season_write_result.dart
- lib/pages/seasons_page.dart
- lib/pages/garden_page.dart
- lib/pages/add_planting_page.dart
- test/data/repositories/season_repository_test.dart
- supabase/migrations/20260826063859_harden_seasons_write_path.sql

La definizione originaria della tabella seasons
e dei trigger condivisi appartiene alla migrazione
baseline identificata dal prefisso 20260817103916.

### 8.3 Inventario operazioni

| Operazione | SQL | Repository | UI |
|---|---|---|---|
| Lettura stagione attiva | SELECT | Presente | Presente |
| Lettura stagioni dell'orto | SELECT | Presente | Presente |
| Creazione stagione | create_season | Presente | Assente |
| Modifica stagione | update_season | Presente | Assente |
| Attivazione stagione | activate_season | Presente | Assente |

La stagione consultata e distinta dalla stagione
attiva dell'orto.

La consultazione di una stagione inattiva
non determina automaticamente la sua attivazione.

### 8.4 Contratti delle RPC

| RPC | Parametri | Esiti SQL | Esiti Flutter |
|---|---:|---:|---:|
| create_season | 10 | 6 | 6 |
| update_season | 11 | 8 | 8 |
| activate_season | 6 | 7 | 7 |
| Totale | 27 | 21 | 21 |

La riconciliazione statica ha confermato:

- Parametri SQL-Flutter: 27/27.
- Parametri Write Authority: 12/12.
- Versioni attese dei record: 2/2.
- Esiti contrattuali: 21/21.
- Copertura contrattuale: 100%.

La copertura contrattuale non rappresenta
la maturita complessiva del macroblocco V1-07.

### 8.5 Creazione stagione

La RPC create_season dispone di dieci parametri.

Il percorso SQL comprende:

- Controllo dell'autenticazione.
- Controllo dell'autorita del proprietario.
- Verifica della Write Authority.
- Controllo dell'appartenenza dell'orto.
- Blocco del record orto mediante FOR UPDATE.
- Normalizzazione del nome.
- Normalizzazione delle note.
- Validazione dell'anno.
- Validazione delle date.
- Validazione delle lunghezze.
- Gestione del vincolo di unicita dell'anno.

L'anno ammesso e compreso tra 1900 e 9999.

Il nome non puo superare 80 caratteri.
Le note non possono superare 1000 caratteri.

La data finale puo essere assente.

Se presente, non puo precedere la data iniziale.

La nuova stagione viene creata inattiva.

Esiti contrattuali:

- created
- forbidden
- write_forbidden
- not_found
- invalid_input
- duplicate_year

L'esito created comprende:

- season_id
- garden_id
- year
- is_active
- row_version
- created_at

Il repository gestisce tutti i sei esiti.

La versione attesa del record non e applicabile
alla creazione di una nuova stagione.

Verificare le condizioni relative allo stato
attivo dell'orto e alla coerenza delle date.

Verificare anche la normalizzazione di input
composti esclusivamente da caratteri di spazio
non ordinari, rispetto ai vincoli della tabella
e alla restituzione dell'esito invalid_input.

Non classificare tali condizioni come difetti
operativi prima dei collaudi pertinenti.

### 8.6 Modifica stagione

La RPC update_season dispone di undici parametri.

Il percorso SQL comprende:

- Controllo dell'autorita del proprietario.
- Verifica della Write Authority.
- Controllo della versione attesa positiva.
- Verifica dell'appartenenza della stagione.
- Blocco del record stagione.
- Controllo del conflitto di versione.
- Normalizzazione dei dati.
- Validazione dei cinque campi modificabili.
- Riconoscimento dell'operazione invariata.
- Aggiornamento condizionato alla versione.
- Gestione del vincolo di unicita pertinente.

I cinque campi modificabili sono:

- year
- name
- start_date
- end_date
- notes

La RPC non modifica garden_id o is_active.

Esiti contrattuali:

- updated
- unchanged
- version_conflict
- forbidden
- write_forbidden
- not_found
- invalid_input
- duplicate_year

Il repository gestisce tutti gli otto esiti.

La risposta updated comprende cinque campi
applicativi oltre allo stato contrattuale.

Le risposte unchanged e version_conflict
comprendono quattro campi ciascuna.

Il comportamento effettivo del versionamento
deve essere raccordato alla riconciliazione RC04.

Verificare le regole funzionali relative alla
modifica di stagioni storiche o attive e alle
eventuali dipendenze da coltivazioni e piani.

### 8.7 Attivazione stagione

La RPC activate_season dispone di sei parametri:

- target_profile_id
- target_season_id
- expected_row_version
- target_client_id
- target_session_id
- lock_token

Il percorso SQL comprende:

- Controllo dell'autorita del proprietario.
- Verifica della Write Authority.
- Controllo della versione attesa.
- Individuazione dell'orto proprietario.
- Blocco del record orto.
- Blocco della stagione da attivare.
- Verifica del conflitto di versione.
- Riconoscimento della stagione gia attiva.
- Individuazione della precedente stagione attiva.
- Blocco della precedente stagione, ove presente.
- Disattivazione condizionata della precedente.
- Attivazione condizionata della nuova stagione.

Le due variazioni appartengono alla stessa
operazione transazionale SQL.

La struttura prevede eccezioni in caso
di aggiornamenti condizionati non riusciti.

L'atomicita effettiva e il rollback devono
essere confermati con collaudi pertinenti.

Esiti contrattuali:

- activated
- unchanged
- version_conflict
- forbidden
- write_forbidden
- not_found
- invalid_input

L'esito activated comprende:

- season_id
- garden_id
- row_version
- updated_at

Quando viene disattivata una stagione precedente,
sono disponibili tre ulteriori informazioni
relative alla sua identita, versione e aggiornamento.

Il repository richiede che tali informazioni
opzionali siano complete oppure tutte assenti.

Il repository gestisce tutti i sette esiti.

Non sono state individuate nella definizione
esaminata restrizioni esplicite relative
alla data corrente o allo stato attivo dell'orto.

La necessita funzionale di tali restrizioni
rimane da verificare.

### 8.8 Sicurezza e integrita SQL

Le tre RPC esaminate utilizzano:

- SECURITY DEFINER.
- search_path vuoto.
- Controllo dell'autorita del proprietario.
- Helper privato della Write Authority.
- Revoca dei privilegi di esecuzione pertinenti.
- Concessione esplicita di EXECUTE ad authenticated.

La migrazione di hardening prevede inoltre
la rimozione delle policy di scrittura diretta
e la revoca dei privilegi diretti pertinenti.

Le autorizzazioni effettivamente installate
devono essere verificate in RC03.

Ciascuna delle tre RPC esaminate invoca
una volta l'helper della Write Authority.

La sufficienza della verifica rispetto ai blocchi,
alle attese e alla scadenza del lease deve essere
valutata in RC02.07.09 e RC04.

Non viene dedotta automaticamente una vulnerabilita
dalla sola presenza di una verifica iniziale.

### 8.9 Struttura tabella e versionamento

La tabella seasons comprende undici campi:

- id
- garden_id
- year
- name
- start_date
- end_date
- is_active
- notes
- created_at
- updated_at
- row_version

Sono presenti nella definizione originaria:

- Chiave primaria.
- Chiave esterna verso gardens.
- Vincolo univoco garden_id e year.
- Vincolo di coerenza delle date.
- Vincolo sulla versione positiva.
- Vincolo sul nome non vuoto.
- Indice univoco parziale sulla stagione attiva.

La migrazione di hardening aggiunge vincoli
relativi all'anno e alle lunghezze applicative.

L'indice parziale limita a una la stagione
attiva per ciascun orto.

La definizione originaria del trigger condiviso
set_updated_at_and_row_version prevede:

- updated_at impostato a now().
- row_version incrementato rispetto al valore precedente.

Il trigger opera prima dell'aggiornamento
di ciascun record interessato.

La definizione originaria comprende seasons
e altre quattro tabelle.

Riutilizzare le evidenze del trigger condiviso.

Verificare eventuali ridefinizioni successive
e lo stato effettivamente installato in RC04.

### 8.10 Modello Season

Il modello Flutter comprende nove campi:

- id
- gardenId
- year
- name
- startDate
- endDate
- isActive
- notes
- rowVersion

I cinque campi modificabili sono rappresentati.

Non sono rappresentati direttamente nel modello
created_at e updated_at.

La loro assenza non costituisce automaticamente
un'incompletezza funzionale.

La deserializzazione esaminata utilizza DateTime
per le date della stagione.

Devono essere valutati:

- Conversione degli identificativi mancanti.
- Gestione di is_active mancante.
- Validazione delle versioni.
- Coerenza delle date.
- Identita dei record restituiti.
- Coerenza con le garanzie del database.

Non sostituire automaticamente DateTime con CivilDate
senza una valutazione delle esigenze del dominio.

### 8.11 Repository e risultati tipizzati

SeasonRepository dispone di provider per:

- Lettura della stagione attiva.
- Lettura delle stagioni dell'orto.
- Invocazione RPC.
- Write Authority.

Le tre mutazioni richiedono il lease.

Il repository trasmette le quattro informazioni
della Write Authority a ciascuna RPC.

Le operazioni update e activate trasmettono
anche la versione attesa del record.

Sono presenti controlli sui risultati RPC:

- Struttura della risposta.
- Identificativi non vuoti.
- Versioni positive.
- Tipi dei campi.
- Timestamp.
- Stati contrattuali riconosciuti.
- Completezza dei dati opzionali.

Sono state individuate 26 dichiarazioni
di classe nel file dei risultati:

- Tre famiglie sealed.
- Ventuno esiti tipizzati.
- Una struttura DeactivatedSeason.
- Una eccezione di protocollo.

La corrispondenza tra i 21 esiti SQL
e i 21 esiti Flutter risulta completa.

Devono essere approfondite le verifiche
di identita e coerenza semantica delle risposte.

### 8.12 Letture e consultazione

getActiveSeason ricerca la stagione attiva
dell'orto e richiede un singolo risultato.

La gestione dell'assenza di una stagione attiva
deve essere verificata nei chiamanti.

La limitazione della query a un risultato
non sostituisce il vincolo di unicita SQL.

getSeasonsByGarden comprende:

- Controllo dell'identificativo orto.
- Controllo della disponibilita del loader.
- Controllo dell'appartenenza dei risultati.
- Ordinamento per anno decrescente e id crescente.
- Inclusione delle stagioni inattive.

L'ordinamento effettivo della query deve essere
distinto da quello restituito dai loader simulati.

### 8.13 Interfacce e integrazione Write Authority

SeasonsPage dispone di:

- Caricamento delle stagioni.
- Visualizzazione dell'orto.
- Distinzione tra stagioni attive e inattive.
- Gestione dell'elenco vuoto.
- Gestione degli errori.
- Ripetizione del caricamento.
- Navigazione verso le pianificazioni.

Non sono presenti nella pagina esaminata
interfacce per create_season, update_season
o activate_season.

La ricerca statica non ha individuato
chiamate applicative dirette alle tre mutazioni
al di fuori delle dichiarazioni del repository.

GardenPage trasmette a SeasonsPage:

- Identificativo e nome dell'orto.
- Repository stagioni eventualmente iniettato.
- Repository pianificazione.
- RouteWriteAvailability.
- PlanningRouteLifetime.

Il repository stagioni eventualmente iniettato
viene trasmesso senza una configurazione
specifica della route rilevata nel percorso.

In assenza di iniezione, SeasonsPage utilizza
il repository predefinito.

Il provider della Write Authority necessario
alle mutazioni delle stagioni deve quindi
essere collegato esplicitamente quando
saranno realizzate le relative interfacce.

Non duplicare le infrastrutture condivise.

### 8.14 Lifecycle delle route

Il percorso GardenPage verso SeasonsPage
utilizza RouteWriteAvailability e
PlanningRouteLifetime per la pianificazione.

La route conserva riferimenti al profilo,
all'identita originaria e al lease iniziale.

La disponibilita di scrittura viene invalidata
quando il contesto non risulta piu valido.

La route figlia PlannedPlantingsPage riceve
un repository circoscritto alla stagione.

Sono presenti meccanismi di retain e release
del lifetime della pianificazione.

Sono stati individuati test specifici relativi
alla chiusura delle route, alla perdita del lease
e alla distruzione dei contesti genitori.

Le relative asserzioni devono essere approfondite
in RC02.07.09.

Non considerare assenti i collaudi di lifecycle
prima dell'esame delle evidenze gia individuate.

Verificare inoltre il ricaricamento delle stagioni
dopo le future mutazioni e la gestione
delle risposte non determinabili.

### 8.15 Matrice D01-D14

| ID | Evidenza | Classificazione |
|---|---|---|
| D01 | Tre mutazioni SQL e repository disponibili | RIUTILIZZARE |
| D02 | Tre interfacce di mutazione mancanti | SVILUPPARE |
| D03 | Write Authority condivisa disponibile | RIUTILIZZARE |
| D04 | Provider presente, collegamento UI da realizzare | INTEGRARE |
| D05 | Identificativo profilo trasmesso | RIUTILIZZARE |
| D06 | Identita client e sessione trasmesse | RIUTILIZZARE |
| D07 | Token trasmesso alle tre RPC | RIUTILIZZARE |
| D08 | Percorso repository-RPC-helper presente | RIUTILIZZARE |
| D09 | Due versioni attese riconciliate | RIUTILIZZARE |
| D10 | Ventuno esiti contrattuali gestiti | RIUTILIZZARE |
| D11 | Gate locale presente, copertura da completare | VERIFICARE |
| D12 | Lifecycle condiviso disponibile | INTEGRARE |
| D13 | Trentatre test repository superati | RIUTILIZZARE |
| D14 | Infrastrutture comuni disponibili | RIUTILIZZARE |

La classificazione riguarda le singole evidenze
e non equivale all'accettazione dell'intero dominio.

### 8.16 Collaudi

Sono stati individuati cinque file pertinenti
e 59 dichiarazioni di test.

Distribuzione:

| Area | Dichiarazioni |
|---|---:|
| SeasonRepository | 22 |
| AddPlantingPage | 6 |
| GardenPage | 9 |
| PlanningRouteIntegration | 15 |
| SeasonsPage | 7 |
| Totale | 59 |

Le dichiarazioni parametrizzate possono generare
piu casi eseguibili.

Il collaudo mirato eseguito in S048:

flutter test test/data/repositories/season_repository_test.dart

Risultato:

- Test superati: 33/33.
- Durata riportata: 12 secondi.
- Esito: PASS.

I 33 casi appartengono alla suite generale
gia esistente e non rappresentano nuovi test.

Il collaudo utilizza provider e risposte simulate.

Non costituisce una verifica diretta
delle RPC nel database.

Le asserzioni esaminate coprono:

- Parametri delle tre mutazioni.
- Ventuno esiti contrattuali.
- Risposte tipizzate.
- Conflitti di versione.
- Risposte di protocollo non valide.
- Lettura della stagione attiva.
- Lettura delle stagioni dell'orto.
- Blocco della creazione in assenza del provider.

Non sono stati individuati nel file esaminato
casi espliciti equivalenti per update e activate
in assenza del provider.

Questo non dimostra che le due operazioni
siano prive di protezione.

Le evidenze dettagliate appartengono
alla scheda TST-RC02-003.

### 8.17 Attivita residue

INTEGRARE:

- Provider Write Authority nei futuri flussi UI.
- Repository e risultati tipizzati nelle interfacce.
- Gestione delle versioni e dei conflitti.
- Aggiornamento dei dati dopo le mutazioni.
- Lifecycle e protezioni delle route pertinenti.

SVILUPPARE:

- Interfaccia creazione stagione.
- Interfaccia modifica stagione.
- Interfaccia attivazione stagione.
- Soltanto i collaudi effettivamente mancanti.

VERIFICARE:

- Assenza del lease nelle tre mutazioni.
- Scadenza e perdita della Write Authority.
- Identita dei risultati restituiti.
- Validazione delle date e delle versioni.
- Assenza della stagione attiva.
- Atomicita dell'attivazione.
- Rollback e concorrenza.
- Gestione delle risposte non determinabili.
- Privilegi e RLS effettivi.
- Dipendenze operative delle stagioni.
- Integrazione reale Flutter-Supabase.

Accorpare le verifiche condivise in
RC02.07.09, RC03, RC04, RC05, RC09 e RC17,
secondo competenza.

### 8.18 Conclusione

Il dominio Stagioni dispone delle tre RPC
autoritative e dei relativi contratti Flutter.

Non sono state individuate difformita
tra gli esiti SQL e quelli del repository.

La principale attivita residua riguarda
le interfacce applicative e il collegamento
della Write Authority ai relativi flussi.

La riconciliazione RC02.07.05 e conclusa.

L'accettazione operativa rimane aperta.

Nessuna nuova non conformita formalizzata.

Nessuna variazione quantitativa A/B approvata.

## 9. Dominio Pianificazione

### 9.1. Percorso applicativo

Orto → Stagioni → Pianificazione. La schermata usa PlannedPlantingRepository
e SeasonalPlanningMutationService. Le RPC di registrazione ed esecuzione
sono definite nella migrazione 20261125151000. La consultazione della
ricevuta e la chiusura dell'intento sono definite nella 20261125151100.

### 9.2. Firme ed esiti

| Operazione | Parametri nella RPC di registrazione | Parametri nella RPC di esecuzione | Esiti SQL–Flutter |
|---|---:|---:|---:|
| Creazione | 25/25 | 25/25 | 11/11 |
| Modifica | 25/25 | 25/25 | 14/14 |
| Conferma | 10/10 | 10/10 | 11/11 |
| Annullamento | 10/10 | 10/10 | 6/6 |
| Esecuzione | 11/11 | 11/11 | 14/14 |
| Totale | 81/81 | 81/81 | 56/56 |

I nomi dei parametri corrispondono in tutte le dieci firme. Il trasporto
aggiunge identità dell'operazione, versione dello schema e generazioni
di recupero e dominio. Profilo, client, sessione e token provengono dal
lease. Le quattro operazioni su pianificazioni esistenti inviano
expected_row_version.

### 9.3. Ricevute e limiti delle evidenze

Il percorso con journal decodifica il risultato dalla ricevuta terminale.
Gli esiti SQL forbidden e write_forbidden possono essere restituiti senza
completare la ricevuta. Se la ricevuta terminale non è validabile,
l'operazione resta incerta.

Ricognizione tecnica RC02.07.06 conclusa.

Evidenza strutturale E3. Evidenze specifiche collaudate E4, documentate
in [TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Il collaudo integrato sulla baseline corrente resta NV. La matrice del
§13 conserva la fotografia dei primi tre domini a RC02.07.05.

## 10. Dominio Coltivazioni

### 10.1. Percorsi di scrittura

AddPlantingPage gestisce creazione e modifica. BedPage gestisce il
cambio di stato. GardenMap passa a BedPage il PlantingRepository
collegato alla Write Authority. Il repository invoca direttamente
le tre RPC con profilo, client, sessione e token del lease.
Modifica e cambio stato inviano expected_row_version.

### 10.2. Firme ed esiti

| Operazione | RPC | Nomi dei parametri SQL–Flutter | Combinazioni RPC–esito |
|---|---|---:|---:|
| Creazione | create_planting | 20/20 | 12/12 |
| Modifica | update_planting | 20/20 | 14/14 |
| Cambio stato | set_planting_status | 8/8 | 8/8 |
| Totale | | 48/48 | 34/34 |

Fonti delle definizioni confrontate: migrazioni 20261105000000 per
creazione, 20261104234500 per modifica e 20260915081444 per cambio stato.
La creazione diretta condivide l'helper SQL con l'esecuzione di una
pianificazione.

Evidenza strutturale E3. Evidenze specifiche collaudate E4, documentate
in [TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Collaudo integrato con Supabase sulla baseline corrente: NV.

Ricognizione tecnica RC02.07.07 conclusa.

## 11. Catalogo e altri domini

### 11.1. Catalogo Agronomico

Nove repository coprono 27 mutazioni: creazione, modifica e cambio dello
stato attivo per ciascuna famiglia. Il confronto con le definizioni SQL
nelle migrazioni locali ha verificato 131/131 nomi dei parametri e
182/182 combinazioni RPC–esito.

La Catalog Authority usa le capability dell'utente autenticato. La
lettura tramite get_my_catalog_capabilities e l'assegnazione iniziale
tramite claim_initial_catalog_authority sono operazioni separate dalle
27 mutazioni censite.

### 11.2. Profilo, impostazioni e altri repository

ProfileContextRepository legge le appartenenze ai profili. Nei sorgenti
Flutter esaminati non sono emerse chiamate di scrittura diretta a
profiles o workers. NC-RC01-001 (P1) resta aperta per i cinque percorsi
SQL già documentati. I privilegi effettivi del database non sono stati
rivalidati in questa ricognizione.

Impostazioni apre Catalogo e Documentazione. Nei percorsi esaminati
non risultano salvataggi autonomi di impostazioni. AgronomicKnowledgeRepository
risolve le conoscenze agronomiche. CropAssociationRepository restituisce
liste vuote senza interrogare il database.

Evidenza strutturale E3. Evidenze specifiche collaudate E4, documentate
in [TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Collaudo integrato con Supabase sulla baseline corrente: NV.

Ricognizione tecnica RC02.07.08 conclusa.

## 12. Verifiche trasversali

### 12.1. Evidenze statiche S048

| Area | Evidenza e verifica residua |
|---|---|
| Scadenza e generazioni | Il controller rifiuta il lease scaduto al momento della scrittura e ignora le risposte di heartbeat di generazioni superate. La risposta positiva tardiva nella stessa generazione resta da verificare (C04, WA-V03). |
| Route di Pianificazione | La disponibilità dipende da profilo, client, sessione e token del lease originale. La chiusura invalida subito la scrittura. Il notifier viene dismesso al rilascio dell'ultimo riferimento. |
| Verifica e rilascio | verifyNow() sospende localmente la scrittura. Il test esistente verifica lo stato dopo il rinnovo. La finestra con risposta pendente resta da verificare (C09, WA-V13). La chiusura della sessione avvia il rilascio senza attendere la conferma server (C07, WA-V15). |
| Handoff ed esiti incerti | Il repository decodifica transfer_pending. Gli effetti integrati del trasferimento restano da verificare. Pianificazione riconcilia gli esiti mediante ricevute. Coltivazioni invoca direttamente le RPC. |

### 12.2. Perimetro del collaudo

Evidenza strutturale E3. Le evidenze specifiche della riesecuzione
Flutter sono E4 e sono documentate in
[TST-RC02-003](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md).
Il collaudo integrato con Supabase sulla baseline corrente resta NV.

Ricognizione trasversale RC02.07.09 conclusa.

## 13. Matrice complessiva SQL-Flutter

### 13.1 Perimetro riconciliato

Situazione intermedia S048, successiva
alla conclusione di RC02.07.05.

La matrice comprende esclusivamente
le mutazioni di Orti, Aiuole e Stagioni.

Le letture non partecipano ai denominatori.

| Dominio | RPC SQL | Repository | UI |
|---|---:|---:|---:|
| Orti | 2 | 1 | 1 |
| Aiuole | 5 | 5 | 5 |
| Stagioni | 3 | 3 | 0 |
| Totale | 10 | 9 | 6 |

Indicatori strutturali:

- Mutazioni SQL disponibili: 10/10.
- Mutazioni integrate nei repository: 9/10.
- Mutazioni integrate nelle UI: 6/10.

### 13.2 Copertura degli esiti contrattuali

| Dominio | Esiti SQL | Esiti Flutter | Mancanti | Copertura |
|---|---:|---:|---:|---:|
| Orti | 13 | 5 | 8 | 38,46% |
| Aiuole | 39 | 36 | 3 | 92,31% |
| Stagioni | 21 | 21 | 0 | 100,00% |
| Totale | 73 | 62 | 11 | 84,93% |

Il conteggio riguarda combinazioni RPC-esito.

Uno stesso nome di stato puo essere presente
in piu contratti distinti.

Gli undici esiti mancanti comprendono:

- Otto esiti di update_garden non ancora integrata.
- Tre combinazioni contrattuali delle RPC geometriche.

Non rappresentano undici nuove RPC
o undici non conformita indipendenti.

### 13.3 Mutazioni da integrare nelle UI

| Dominio | Operazione |
|---|---|
| Orti | update_garden |
| Stagioni | create_season |
| Stagioni | update_season |
| Stagioni | activate_season |

Le quattro operazioni dispongono gia
delle rispettive RPC SQL.

Tre dispongono anche del repository Flutter.

### 13.4 Parametri delle mutazioni integrate

| Dominio | Parametri riconciliati |
|---|---:|
| Orti | 14/14 |
| Aiuole | 47/47 |
| Stagioni | 27/27 |
| Totale | 88/88 |

Il denominatore riguarda le nove mutazioni
gia integrate nei repository Flutter.

I 17 parametri di update_garden non sono
compresi nel denominatore di corrispondenza.

### 13.5 Riconciliazione e maturita

Le percentuali della presente matrice
sono indicatori di copertura strutturale.

Non rappresentano:

- Maturita funzionale complessiva.
- Accettazione operativa.
- Copertura completa dei collaudi.
- Equivalenza del database remoto.
- Percentuale di completamento della V1.

Alla data della fotografia del §13, RC02.07 era a cinque sottoblocchi su dieci. Il consolidamento finale conclude RC02.07 a 10/10.

RC02 rimane completata per sei
sottoblocchi su dieci.

Nessuna variazione della baseline
quantitativa A/B e stata approvata.

La matrice sara estesa dopo le successive
riconciliazioni dei domini.

### 13.6. Consolidamento finale S048

| Dominio | Operazioni nel perimetro | Nomi dei parametri corrispondenti | Esiti SQL–Flutter corrispondenti |
|---|---:|---:|---:|
| Orti | 2 | 14/14 per la creazione integrata | 5/13 |
| Aiuole | 5 | 47/47 | 36/39 |
| Stagioni | 3 | 27/27 | 21/21 |
| Pianificazione | 5 | 81/81 per le RPC di registrazione e 81/81 per quelle di esecuzione | 56/56 |
| Coltivazioni | 3 | 48/48 | 34/34 |
| Catalogo | 27 | 131/131 | 182/182 |

La matrice §§13.1–13.5 conserva il perimetro di RC02.07.05.
Le letture, l'assegnazione iniziale della Catalog Authority e le RPC
ausiliarie di riconciliazione sono escluse dai conteggi della tabella.

RC02.07 chiuso a 10/10. RC02 è a 7/10. Le riesecuzioni Flutter sono
registrate separatamente in TST-RC02-003. Il collaudo integrato con
Supabase sulla baseline corrente resta NV. Restano aperte le verifiche
trasversali residue e NC-RC01-001 (P1), da approfondire in RC02.08.

## 14. Attivita residue e classificazioni

RIUTILIZZARE - Componente disponibile e pertinente.

INTEGRARE - Componente disponibile da collegare.

VERIFICARE - Evidenza incompleta o non verificata.

SVILUPPARE - Funzionalita effettivamente mancante.

La formalizzazione delle non conformita compete
a RC02.08.

Nessuna variazione quantitativa A/B autorizzata.

## 15. Collegamenti al Registro

- [Standard Registro](../01_architettura/ARC-REG-001_Standard_Registro.md)
- [Inventario Write Authority](INF-WA-001_Inventario_Write_Authority.md)
- [Infrastruttura Flutter](INF-WA-002_Infrastruttura_Flutter_Write_Authority.md)
- [Inventario RPC](../03_database/DB-WA-001_Inventario_RPC_Write_Authority.md)
- [Inventario Flutter](../04_flutter/FLT-INV-001_Inventario_Flutter.md)
- [Processi Orti Aiuole Stagioni](../05_processi/PRC-001_Orti_Aiuole_Stagioni.md)
- [Processi Pianificazioni Coltivazioni](../05_processi/PRC-002_Pianificazioni_Coltivazioni.md)
- [Collaudi Flutter](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [Stato RC02](../08_riutilizzo/RC02_Stato_Parziale.md)
- [Stato corrente](../10_stato_operativo/STATO_CORRENTE.md)
