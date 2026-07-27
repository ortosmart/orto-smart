# DOC-001 – Manuale Tecnico

| Campo | Valore |
|-------|--------|
| Documento | DOC-001 |
| Titolo | Manuale Tecnico |
| Versione | 0.1 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Linguaggio | Flutter / Dart |
| Backend | Supabase |
| Data prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 26/07/2026 |

---

# Scopo del documento

Il Manuale Tecnico descrive l'architettura software, l'organizzazione del codice, le tecnologie utilizzate e le scelte progettuali di Orto Smart.

È destinato agli sviluppatori e costituisce il riferimento principale per lo sviluppo, la manutenzione e l'evoluzione dell'applicazione.

Gli obiettivi del documento sono:

- descrivere l'architettura generale del sistema;
- documentare i componenti software;
- definire l'organizzazione del progetto;
- facilitare la manutenzione del codice;
- rendere comprensibili le decisioni progettuali adottate.

---

# Indice

1. Architettura del sistema
2. Tecnologie utilizzate
3. Struttura del progetto
4. Architettura Flutter
5. Database Supabase
6. Repository
7. Modelli dati
8. Motore agronomico
9. Suggestion Engine
10. Gestione irrigazione
11. Sicurezza
12. Test
13. Convenzioni di sviluppo
14. Evoluzioni future

---

# 1. Architettura del sistema

## Obiettivo

Orto Smart è un'applicazione sviluppata per supportare la gestione completa di un orto reale.

L'architettura è stata progettata seguendo il principio della separazione delle responsabilità (Separation of Concerns), mantenendo distinti:

- interfaccia utente;
- logica applicativa;
- accesso ai dati;
- servizi esterni.

Questa organizzazione consente di sviluppare nuove funzionalità senza modificare componenti non interessati.

## Architettura logica

Il sistema è composto dai seguenti livelli principali.

### Interfaccia utente (UI)

Realizzata con Flutter.

Gestisce:

- pagine;
- widget;
- navigazione;
- interazione con l'utente.

### Livello Repository

Rappresenta il punto di accesso ai dati.

Ogni repository incapsula le operazioni verso Supabase evitando che l'interfaccia comunichi direttamente con il database.

### Modelli dati

I modelli rappresentano gli oggetti principali del dominio applicativo, come:

- Garden
- Bed
- Crop
- Planting
- Season

Ogni modello contiene esclusivamente la struttura dei dati e i metodi di conversione da e verso il database.

### Motore agronomico

Contiene la logica di supporto alle decisioni.

Tra le principali funzionalità:

- rotazioni colturali;
- compatibilità tra colture;
- suggerimento degli spazi disponibili;
- suggerimenti automatici di inserimento.

### Database

Il database è ospitato su Supabase.

Le tabelle sono progettate per ridurre la duplicazione dei dati e mantenere elevate prestazioni anche con un numero crescente di registrazioni.

## Principi progettuali

L'architettura segue alcuni principi fondamentali.

- Modularità.
- Basso accoppiamento tra componenti.
- Alta coesione.
- Codice facilmente testabile.
- Documentazione sincronizzata con lo sviluppo.
- Ottimizzazione dell'utilizzo dello spazio nel database.

# 2. Struttura del progetto

## 2.1 Organizzazione generale

Il codice sorgente principale di Orto Smart si trova nella cartella:

```text
lib/
```

Il progetto è organizzato separando l’interfaccia utente, i modelli dati, l’accesso al database, i servizi applicativi e i componenti grafici riutilizzabili.

La struttura principale è la seguente:

```text
lib/
├── core/
│   └── config/
├── data/
│   ├── models/
│   └── repositories/
├── pages/
├── services/
├── widgets/
├── main.dart
└── supabase_config.dart
```

Questa struttura consente di evitare che tutta la logica dell’applicazione venga concentrata nelle pagine Flutter e rende più semplice ampliare e manutenere il progetto.

---

## 2.2 File `main.dart`

### Scopo

Il file `main.dart` costituisce il punto di ingresso dell’applicazione Flutter.

### Responsabilità

Le sue principali responsabilità sono:

* inizializzare Flutter;
* inizializzare il collegamento a Supabase;
* avviare l’applicazione;
* configurare il widget principale;
* impostare il tema generale;
* definire la prima schermata mostrata all’utente.

### Avvio dell’applicazione

Prima dell’avvio dell’interfaccia viene eseguita l’inizializzazione dei servizi necessari.

La configurazione Supabase viene caricata attraverso la classe `SupabaseConfig`.

Successivamente Flutter avvia l’applicazione tramite il metodo:

```dart
runApp(...)
```

### Note progettuali

Il file deve rimanere il più semplice possibile.

La logica applicativa, le interrogazioni al database e le regole agronomiche non devono essere inserite direttamente in `main.dart`, ma affidate ai componenti specifici del progetto.

---

## 2.3 File `supabase_config.dart`

### Scopo

Il file `supabase_config.dart` contiene i parametri necessari per collegare l’applicazione al progetto Supabase.

### Contenuto

La classe `SupabaseConfig` espone:

* URL del progetto Supabase;
* chiave pubblica utilizzata dal client Flutter.

### Utilizzo

I valori vengono letti da `main.dart` durante l’inizializzazione di Supabase.

### Sicurezza

La chiave utilizzata dall’applicazione è una chiave pubblica destinata al client.

La protezione dei dati non deve dipendere dalla segretezza di questa chiave, ma dalle policy di sicurezza Row Level Security configurate nel database Supabase.

Le chiavi con privilegi amministrativi non devono essere inserite nel codice Flutter né pubblicate nel repository Git.

### Evoluzione prevista

In futuro la configurazione potrà essere trasferita in variabili d’ambiente o in file distinti per:

* sviluppo;
* test;
* produzione.

---

## 2.4 Cartella `core`

### Scopo

La cartella `core` contiene componenti generali utilizzabili da più parti dell’applicazione.

Al suo interno possono essere inseriti elementi che non appartengono direttamente a una singola funzionalità, come:

* configurazioni;
* costanti;
* utilità condivise;
* gestione degli errori;
* definizioni comuni.

### Sottocartella `core/config`

La sottocartella `config` raccoglie le configurazioni generali dell’applicazione.

Questa separazione consente di evitare valori duplicati all’interno delle pagine o dei servizi.

### Note progettuali

La cartella `core` non deve diventare un contenitore generico per file non classificati.

Ogni elemento inserito al suo interno deve avere un’utilità trasversale e chiaramente documentata.

---

## 2.5 Cartella `data`

### Scopo

La cartella `data` contiene i componenti relativi alla rappresentazione e all’accesso ai dati.

È suddivisa principalmente in:

```text
data/
├── models/
└── repositories/
```

Questa separazione distingue:

* la struttura dei dati utilizzati dall’applicazione;
* le operazioni necessarie per leggerli e modificarli nel database.

---

## 2.6 Cartella `data/models`

### Scopo

La cartella `models` contiene le classi Dart che rappresentano le principali entità del progetto.

Tra i modelli utilizzati sono presenti:

* `Garden`;
* `Bed`;
* `Crop`;
* `Planting`;
* `Season`.

### Responsabilità dei modelli

Ogni modello ha il compito di:

* rappresentare un’entità del dominio;
* definire i relativi campi;
* convertire i dati provenienti da Supabase in oggetti Dart;
* preparare i dati da inviare al database;
* mantenere una corrispondenza coerente tra codice e struttura delle tabelle.

### Principio progettuale

I modelli non devono contenere interrogazioni dirette al database né logica grafica.

La loro responsabilità principale è rappresentare i dati.

---

## 2.7 Cartella `data/repositories`

### Scopo

La cartella `repositories` contiene i componenti che gestiscono l’accesso ai dati salvati in Supabase.

Tra i repository già utilizzati nel progetto sono presenti componenti dedicati a:

* orti;
* aiuole;
* colture inserite;
* stagioni;
* piantagioni.

### Responsabilità

I repository hanno il compito di:

* eseguire interrogazioni verso Supabase;
* recuperare i dati;
* applicare filtri e ordinamenti;
* convertire i risultati nei relativi modelli;
* inserire nuovi record;
* aggiornare record esistenti;
* nascondere all’interfaccia utente i dettagli del database.

### Flusso dei dati

Il flusso ordinario è:

```text
Pagina Flutter
      ↓
Repository
      ↓
Supabase
      ↓
Repository
      ↓
Modello Dart
      ↓
Pagina Flutter
```

### Vantaggi

L’utilizzo dei repository evita che le pagine Flutter contengano direttamente chiamate al database.

Questo permette di:

* ridurre la duplicazione del codice;
* semplificare i test;
* centralizzare le interrogazioni;
* modificare il database con un impatto minore sull’interfaccia;
* mantenere una separazione chiara delle responsabilità.

---

## 2.8 Cartella `pages`

### Scopo

La cartella `pages` contiene le schermate principali dell’applicazione.

Le pagine gestiscono:

* visualizzazione dei dati;
* navigazione;
* moduli di inserimento;
* interazione con l’utente;
* richiamo dei repository e dei servizi.

### Schermate principali

L’interfaccia corrente comprende cinque sezioni principali:

* Dashboard;
* Orto;
* Irrigazione;
* Attività;
* Impostazioni.

Sono inoltre presenti pagine dedicate alla gestione delle aiuole e delle colture, tra cui:

* pagina dell’orto;
* pagina della singola aiuola;
* pagina di aggiunta di una coltura.

### Principio progettuale

Le pagine devono occuparsi principalmente della presentazione e del coordinamento delle operazioni.

Le regole agronomiche e le interrogazioni complesse non devono essere implementate direttamente nelle pagine.

---

## 2.9 Cartella `widgets`

### Scopo

La cartella `widgets` contiene componenti grafici riutilizzabili.

Un widget viene separato da una pagina quando:

* viene utilizzato in più schermate;
* contiene una rappresentazione grafica complessa;
* ha una responsabilità specifica;
* renderebbe la pagina principale troppo lunga o difficile da leggere.

### Componente rilevante

Tra i componenti principali è presente il widget che rappresenta graficamente la disposizione delle colture all’interno di un’aiuola.

Il componente utilizza:

* posizione iniziale della coltura;
* lunghezza occupata;
* larghezza disponibile;
* dimensioni reali dell’aiuola;
* nome o identificativo della coltura.

### Vantaggi

La separazione dei widget consente di:

* riutilizzare l’interfaccia;
* mantenere coerente la grafica;
* semplificare le pagine;
* testare più facilmente singoli componenti.

---

## 2.10 Cartella `services`

### Scopo

La cartella `services` contiene servizi applicativi che non appartengono direttamente ai modelli, ai repository o alle pagine.

Può includere componenti dedicati a:

* autenticazione;
* integrazione con servizi esterni;
* elaborazioni condivise;
* esportazione o stampa;
* gestione futura dei dati meteorologici;
* comunicazione futura con dispositivi di irrigazione.

### Principio progettuale

Un servizio deve avere una responsabilità chiaramente definita.

Le operazioni strettamente legate alla lettura o scrittura dei dati devono rimanere nei repository, mentre i servizi gestiscono elaborazioni o integrazioni applicative.

---

## 2.11 Motore agronomico

Il motore agronomico contiene la logica utilizzata per valutare e suggerire operazioni relative alle colture.

Le sue responsabilità includono o includeranno:

* verifica delle rotazioni;
* valutazione delle consociazioni;
* controllo dello spazio disponibile;
* suggerimento del posizionamento;
* generazione di indicazioni agronomiche;
* supporto alla pianificazione delle attività.

Il motore deve rimanere separato dall’interfaccia grafica e dal database.

Riceve dati strutturati, applica le regole e restituisce risultati utilizzabili dalle pagine o dai servizi.

Questa separazione consente di testare le regole agronomiche senza avviare l’intera applicazione.

---

## 2.12 Dipendenze tra i componenti

Le dipendenze principali seguono questa direzione:

```text
Pages
 ├── utilizzano Widgets
 ├── utilizzano Repositories
 └── utilizzano servizi o motori applicativi

Repositories
 ├── utilizzano Supabase
 └── producono Models

Agronomic Engine
 ├── riceve Models o dati strutturati
 └── restituisce valutazioni e suggerimenti

Models
 └── non dipendono dall’interfaccia utente
```

La direzione delle dipendenze deve evitare che:

* i modelli dipendano dalle pagine;
* i repository dipendano dai widget;
* il motore agronomico dipenda dalla grafica;
* le pagine contengano direttamente logica SQL o regole complesse.

---

## 2.13 Evoluzione della struttura

Con l’aumento delle funzionalità, il progetto potrà essere ulteriormente organizzato per moduli funzionali.

Possibili aree future:

```text
features/
├── garden/
├── irrigation/
├── activities/
├── weather/
├── economics/
└── settings/
```

L’adozione di una struttura per funzionalità verrà valutata quando la quantità di file renderà meno immediata l’organizzazione attuale.

Fino a quel momento, la struttura esistente viene mantenuta per evitare complessità non necessaria.

---

# 3. Database Supabase

## 3.1 Obiettivo

Il database rappresenta il cuore dell'applicazione Orto Smart.

Tutte le informazioni relative all'orto, alle aiuole, alle colture, alle piantagioni, alle attività e ai futuri moduli vengono archiviate in Supabase.

L'obiettivo della progettazione è stato quello di ottenere un database:

- normalizzato;
- facilmente espandibile;
- efficiente nello spazio occupato;
- semplice da interrogare;
- compatibile con le policy di sicurezza Row Level Security (RLS).

---

## 3.2 Tecnologie utilizzate

Il backend utilizza Supabase, basato su PostgreSQL.

Le principali funzionalità sfruttate sono:

- Database relazionale PostgreSQL;
- API REST automatiche;
- autenticazione utenti;
- Row Level Security (RLS);
- Storage (per sviluppi futuri);
- funzioni SQL.

---

## 3.3 Principi progettuali

Durante lo sviluppo sono stati adottati i seguenti principi.

### Normalizzazione

Ogni informazione viene memorizzata una sola volta.

Questo riduce:

- duplicazione dei dati;
- possibilità di inconsistenze;
- spazio occupato.

### Integrità referenziale

Le relazioni tra le tabelle sono garantite mediante chiavi esterne.

Questo impedisce la creazione di riferimenti non validi.

### Espandibilità

Ogni tabella è stata progettata prevedendo futuri ampliamenti del progetto.

Nuove funzionalità dovranno essere aggiunte preferibilmente mediante nuove tabelle piuttosto che modificando pesantemente quelle esistenti.

### Efficienza

Le interrogazioni più frequenti sono state considerate nella progettazione delle relazioni.

Quando necessario verranno utilizzati indici dedicati.

### Sicurezza

La protezione dei dati è affidata alle policy Row Level Security implementate in Supabase.

Le autorizzazioni non vengono gestite dall'app Flutter.

---

## 3.4 Schema generale

Le principali entità del database sono:

- Gardens
- Beds
- Seasons
- Crops
- Plantings
- Irrigation Events
- Irrigation Event Beds

Le relazioni principali sono:

Garden
↓
Beds
↓
Plantings
↑
Crops

Season
↓

Plantings

Irrigation Events
↓

Irrigation Event Beds

↓

Beds

---

## 3.5 Tabelle attualmente implementate

Attualmente il database comprende le seguenti tabelle principali.

| Tabella | Stato | Descrizione |
|----------|-------|-------------|
| gardens | Attiva | Gestione degli orti |
| beds | Attiva | Gestione delle aiuole |
| seasons | Attiva | Gestione delle stagioni |
| crops | Attiva | Archivio delle colture |
| plantings | Attiva | Colture presenti nelle aiuole |
| irrigation_events | Attiva | Eventi di irrigazione |
| irrigation_event_beds | Attiva | Collegamento tra irrigazioni e aiuole |

---

## 3.6 Evoluzione prevista

Nei prossimi sviluppi il database verrà esteso con nuove aree dedicate a:

- attività dell'orto;
- raccolti;
- magazzino;
- fertilizzazioni;
- trattamenti;
- meteo;
- costi e ricavi;
- tempi di lavoro;
- notifiche;
- gestione dell'irrigazione automatica.

La progettazione seguirà sempre i principi descritti in questo capitolo, mantenendo il database coerente, efficiente e facilmente manutenibile.

---

# 3.7 Tabella `gardens`

## Scopo

La tabella `gardens` rappresenta l'orto gestito dall'applicazione.

Ogni orto costituisce il contenitore logico di tutte le aiuole, delle colture e delle attività associate.

Attualmente l'applicazione è progettata principalmente per la gestione di un singolo orto, ma la struttura del database consente l'estensione futura alla gestione di più orti.

---

## Responsabilità

La tabella memorizza le informazioni generali dell'orto e costituisce il punto di partenza delle principali relazioni del database.

Da essa dipendono direttamente:

- aiuole (`beds`);
- future aree funzionali collegate all'orto.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo univoco dell'orto |
| name | Text | Nome dell'orto |
| created_at | Timestamp | Data di creazione |

---

## Chiave primaria

La chiave primaria è il campo:

- `id`

Ogni orto è identificato in modo univoco mediante UUID.

---

## Relazioni

La tabella è collegata a:

```
gardens
    │
    └──── beds
```

Ogni orto può contenere numerose aiuole.

Ogni aiuola appartiene ad un solo orto.

---

## Utilizzo nel codice

La tabella viene utilizzata principalmente attraverso:

- modello `Garden`
- `GardenRepository`
- pagine dedicate alla gestione dell'orto

L'applicazione recupera normalmente un solo orto attivo, dal quale vengono successivamente caricate tutte le aiuole.

---

## Motivazioni progettuali

L'introduzione della tabella `gardens` permette di:

- mantenere una struttura relazionale corretta;
- rendere possibile la futura gestione di più orti;
- evitare modifiche strutturali nel database in caso di espansione del progetto.

---

## Evoluzioni future

La tabella potrà essere estesa con informazioni quali:

- coordinate geografiche;
- superficie coltivata;
- tipo di terreno;
- sistema di irrigazione;
- fotografie;
- note generali.

---

# 3.8 Tabella `beds`

## Scopo

La tabella `beds` rappresenta le aiuole dell'orto.

Ogni record identifica una singola aiuola fisica sulla quale vengono coltivate una o più colture durante le diverse stagioni.

Nel progetto Orto Smart le aiuole costituiscono l'elemento centrale della gestione agronomica, poiché tutte le operazioni vengono riferite alla posizione fisica delle colture al loro interno.

---

## Responsabilità

La tabella ha il compito di:

- identificare ogni aiuola;
- memorizzarne le caratteristiche principali;
- collegarla all'orto di appartenenza;
- costituire il punto di riferimento per piantagioni, irrigazione e attività future.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo univoco dell'aiuola |
| garden_id | UUID | Orto di appartenenza |
| number | Integer | Numero progressivo dell'aiuola |
| length_cm | Integer | Lunghezza in centimetri |
| width_cm | Integer | Larghezza in centimetri |
| irrigation_zone | Text | Zona di irrigazione |
| is_active | Boolean | Indica se l'aiuola è attiva |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Chiavi esterne

La tabella contiene la seguente chiave esterna:

- `garden_id → gardens.id`

Ogni aiuola appartiene ad un solo orto.

---

## Relazioni

La tabella è collegata alle seguenti entità:

```text
gardens
    │
    └──── beds
             │
             ├──── plantings
             │
             └──── irrigation_event_beds
```

Una singola aiuola può contenere numerose piantagioni nel tempo.

---

## Utilizzo nel codice

La tabella viene utilizzata attraverso:

- modello `Bed`;
- `BedRepository`;
- pagina dell'orto;
- pagina della singola aiuola;
- widget grafico della disposizione delle colture.

L'applicazione recupera normalmente solo le aiuole attive, ordinate in base al numero progressivo.

---

## Scelte progettuali

Ogni aiuola viene identificata mediante un UUID interno, mentre il numero dell'aiuola rappresenta l'identificativo visibile all'utente.

Questa scelta consente di modificare l'ordinamento o la numerazione senza compromettere le relazioni con le altre tabelle.

Le dimensioni sono memorizzate in centimetri per garantire precisione nei calcoli del motore agronomico.

---

## Collegamento con il motore agronomico

Il motore agronomico utilizza le informazioni delle aiuole per:

- verificare lo spazio disponibile;
- calcolare il posizionamento delle colture;
- individuare gli spazi liberi;
- suggerire nuovi inserimenti;
- pianificare le rotazioni.

La lunghezza e la larghezza dell'aiuola costituiscono il riferimento geometrico per tutti i calcoli.

---

## Evoluzioni future

La tabella potrà essere estesa con ulteriori informazioni quali:

- orientamento dell'aiuola;
- materiale della struttura;
- tipologia del terreno;
- pendenza;
- esposizione al sole;
- fotografie;
- sensori installati;
- note tecniche.

---

# 3.9 Tabella `crops`

## Scopo

La tabella `crops` contiene l'archivio delle colture gestite da Orto Smart.

Ogni record rappresenta una specie coltivabile e raccoglie le informazioni utilizzate dal motore agronomico e dall'interfaccia utente durante l'inserimento delle piantagioni.

La tabella costituisce il catalogo centrale delle colture disponibili.

---

## Responsabilità

La tabella ha il compito di:

- identificare ogni coltura;
- memorizzare le caratteristiche agronomiche principali;
- fornire valori predefiniti per la semina e il trapianto;
- supportare il motore agronomico nelle decisioni.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | Integer | Identificativo della coltura |
| name | Text | Nome della coltura |
| variety | Text | Varietà della coltura |
| sowing_method | Text | Metodo di semina predefinito |
| row_spacing_cm | Integer | Distanza consigliata tra le file |
| plant_spacing_cm | Integer | Distanza consigliata tra le piante |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Relazioni

La tabella è utilizzata principalmente dalla tabella `plantings`.

```text
crops
   │
   └──── plantings
```

Una stessa coltura può essere presente in numerose piantagioni durante stagioni differenti.

---

## Utilizzo nel codice

La tabella viene utilizzata da:

- modello `Crop`;
- schermata di inserimento colture;
- `PlantingRepository`;
- motore agronomico;
- Suggestion Engine.

L'utente seleziona una coltura dal catalogo e l'applicazione utilizza automaticamente le informazioni disponibili per compilare i valori suggeriti.

---

## Scelte progettuali

Le informazioni agronomiche vengono memorizzate nella tabella `crops` anziché nelle singole piantagioni.

Questo consente di:

- evitare duplicazione dei dati;
- mantenere uniforme il catalogo delle colture;
- aggiornare facilmente i valori consigliati;
- semplificare gli algoritmi del motore agronomico.

Le singole piantagioni possono comunque modificare manualmente i valori suggeriti quando necessario.

---

## Collegamento con il motore agronomico

Il motore agronomico utilizza le informazioni della tabella `crops` per:

- suggerire le distanze di impianto;
- stimare l'area occupata;
- verificare la disponibilità di spazio;
- proporre nuovi inserimenti;
- applicare le future regole di rotazione e consociazione.

---

## Evoluzioni future

La tabella potrà essere estesa con informazioni quali:

- famiglia botanica;
- durata del ciclo colturale;
- profondità di semina;
- fabbisogno idrico;
- fabbisogno nutrizionale;
- sensibilità al gelo;
- periodo di semina;
- periodo di raccolta;
- esposizione consigliata;
- temperatura minima e massima;
- colore identificativo utilizzato nella grafica dell'app.

---

# 3.10 Tabella `seasons`

## Scopo

La tabella `seasons` gestisce le stagioni agronomiche del progetto.

Ogni stagione rappresenta un periodo di coltivazione e consente di organizzare le piantagioni nel tempo senza perdere lo storico degli anni precedenti.

L'introduzione di questa tabella permette di consultare e confrontare facilmente le coltivazioni effettuate in stagioni diverse.

---

## Responsabilità

La tabella ha il compito di:

- identificare ogni stagione;
- definire il periodo di validità;
- indicare la stagione attualmente attiva;
- collegare tutte le piantagioni allo specifico anno agricolo.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo della stagione |
| name | Text | Nome della stagione (es. "Stagione 2026") |
| start_date | Date | Data di inizio |
| end_date | Date | Data di fine |
| is_active | Boolean | Indica la stagione attualmente attiva |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Relazioni

La tabella è collegata direttamente alle piantagioni.

```text
seasons
    │
    └──── plantings
```

Ogni stagione può comprendere numerose piantagioni.

Ogni piantagione appartiene ad una sola stagione.

---

## Utilizzo nel codice

La stagione attiva viene utilizzata per:

- mostrare automaticamente le coltivazioni correnti;
- filtrare le piantagioni;
- semplificare la navigazione dell'utente;
- evitare che vengano visualizzati dati storici durante il normale utilizzo dell'app.

Le stagioni precedenti rimangono comunque disponibili per consultazioni e analisi.

---

## Scelte progettuali

La gestione delle stagioni tramite una tabella dedicata evita di utilizzare semplicemente l'anno della data di semina.

Questa scelta permette di:

- definire periodi personalizzati;
- gestire eventuali coltivazioni che attraversano due anni solari;
- mantenere uno storico ordinato;
- supportare future analisi statistiche.

---

## Collegamento con il motore agronomico

Il motore agronomico utilizza la stagione per:

- controllare le rotazioni colturali;
- verificare le colture presenti negli anni precedenti;
- suggerire la successione delle colture;
- pianificare le future semine.

Lo storico delle stagioni costituirà una delle principali fonti di informazione per le decisioni automatiche.

---

## Evoluzioni future

La tabella potrà essere estesa con:

- note sulla stagione;
- andamento climatico;
- produzione complessiva;
- costi annuali;
- ricavi annuali;
- statistiche automatiche;
- indicatori di performance dell'orto.

---

# 3.11 Tabella `plantings`

## Scopo

La tabella `plantings` rappresenta le singole piantagioni presenti nelle aiuole.

Ogni record descrive una coltura coltivata in una determinata aiuola, durante una specifica stagione, occupando una precisa posizione fisica.

Questa tabella costituisce il nucleo operativo dell'applicazione, poiché collega il catalogo delle colture con le aiuole e con la stagione di riferimento.

---

## Responsabilità

La tabella ha il compito di:

- registrare ogni nuova piantagione;
- identificare la posizione della coltura nell'aiuola;
- memorizzare le informazioni specifiche della coltivazione;
- collegare coltura, aiuola e stagione;
- fornire i dati al motore agronomico e all'interfaccia grafica.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo della piantagione |
| season_id | UUID | Stagione di appartenenza |
| bed_id | UUID | Aiuola |
| crop_id | Integer | Coltura |
| sowing_date | Date | Data di semina o trapianto |
| planting_method | Text | Metodo di coltivazione |
| plants_count | Integer | Numero di piante |
| start_position_cm | Integer | Posizione iniziale nell'aiuola |
| length_cm | Integer | Lunghezza occupata |
| occupied_width_cm | Integer | Larghezza occupata |
| row_spacing_cm | Integer | Distanza tra le file |
| plant_spacing_cm | Integer | Distanza tra le piante |
| rows_count | Integer | Numero di file |
| notes | Text | Annotazioni |
| status | Text | Stato della coltivazione |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Chiavi esterne

La tabella contiene le seguenti relazioni:

- `season_id → seasons.id`
- `bed_id → beds.id`
- `crop_id → crops.id`

---

## Relazioni

```text
seasons
     │
beds ├──── plantings ──── crops
```

Ogni piantagione appartiene:

- ad una stagione;
- ad una sola aiuola;
- ad una sola coltura.

---

## Utilizzo nel codice

La tabella viene utilizzata da:

- modello `Planting`;
- `PlantingRepository`;
- pagina della singola aiuola;
- `BedLayoutWidget`;
- motore agronomico;
- futuro sistema di irrigazione;
- futura gestione delle attività.

Ogni visualizzazione dell'aiuola viene costruita leggendo i dati presenti in questa tabella.

---

## Scelte progettuali

Le informazioni memorizzate nella piantagione rappresentano lo stato reale della coltivazione.

Anche se alcuni valori derivano dal catalogo delle colture, vengono salvati nella piantagione per conservare lo storico esatto delle scelte effettuate al momento dell'inserimento.

Questa soluzione permette di mantenere inalterati i dati storici anche se, in futuro, i valori predefiniti della coltura dovessero essere modificati.

---

## Collegamento con il motore agronomico

Il motore agronomico utilizza questa tabella per:

- calcolare gli spazi occupati;
- individuare gli spazi liberi;
- verificare eventuali sovrapposizioni;
- proporre automaticamente nuove colture;
- gestire rotazioni e consociazioni;
- pianificare irrigazione e attività.

È la principale sorgente dati per tutti gli algoritmi decisionali dell'applicazione.

---

## Evoluzioni future

La tabella potrà essere estesa con:

- data di raccolta;
- quantità prodotta;
- peso totale raccolto;
- costo della coltivazione;
- tempo di lavoro impiegato;
- fotografie;
- collegamento alle attività svolte;
- collegamento agli eventi di irrigazione;
- indicatori di salute della coltura.

---

# 3.12 Tabella `irrigation_events`

## Scopo

La tabella `irrigation_events` registra ogni intervento di irrigazione effettuato nell'orto.

Un evento di irrigazione rappresenta un'operazione eseguita in un determinato momento e può coinvolgere una o più aiuole.

Questa struttura consente di mantenere uno storico completo delle irrigazioni e costituisce la base per la futura gestione automatizzata dell'impianto.

---

## Responsabilità

La tabella ha il compito di:

- registrare ogni evento di irrigazione;
- memorizzare data e ora dell'intervento;
- distinguere irrigazioni manuali e automatiche;
- conservare eventuali note;
- fungere da intestazione degli eventi collegati alle aiuole.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo dell'evento |
| irrigation_date | Timestamp | Data e ora dell'irrigazione |
| irrigation_type | Text | Manuale o automatica |
| duration_minutes | Integer | Durata dell'irrigazione |
| notes | Text | Annotazioni |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Relazioni

La tabella è collegata alla tabella `irrigation_event_beds`.

```text
irrigation_events
        │
        └──── irrigation_event_beds
```

Un singolo evento può interessare una o più aiuole.

---

## Utilizzo nel codice

La tabella verrà utilizzata da:

- gestione irrigazione manuale;
- gestione irrigazione automatica;
- cronologia irrigazioni;
- statistiche dei consumi;
- motore decisionale.

Ogni evento rappresenta una singola operazione realmente eseguita.

---

## Scelte progettuali

La separazione tra evento di irrigazione e aiuole interessate permette di evitare duplicazioni di dati.

Se un'unica irrigazione interessa più aiuole, viene registrato un solo evento collegato a più record della tabella di relazione.

Questa soluzione migliora la normalizzazione del database e facilita future elaborazioni statistiche.

---

## Evoluzioni future

La tabella potrà essere estesa con:

- volume d'acqua utilizzato;
- consumo energetico;
- modalità automatica/manuale;
- programma di irrigazione;
- condizioni meteo;
- umidità del terreno;
- temperatura;
- identificativo del dispositivo che ha eseguito l'irrigazione.

---

# 3.13 Tabella `irrigation_event_beds`

## Scopo

La tabella `irrigation_event_beds` rappresenta la relazione tra gli eventi di irrigazione e le aiuole interessate.

Essa permette di associare un singolo evento di irrigazione a una o più aiuole, mantenendo il database normalizzato ed evitando duplicazioni di informazioni.

---

## Responsabilità

La tabella ha il compito di:

- collegare gli eventi di irrigazione alle aiuole;
- consentire irrigazioni che coinvolgono più aiuole;
- registrare informazioni specifiche dell'irrigazione per ogni aiuola;
- supportare future statistiche e analisi.

---

## Campi principali

| Campo | Tipo | Descrizione |
|--------|------|-------------|
| id | UUID | Identificativo della relazione |
| irrigation_event_id | UUID | Evento di irrigazione |
| bed_id | UUID | Aiuola irrigata |
| water_amount_liters | Numeric | Acqua distribuita (se disponibile) |
| duration_minutes | Integer | Durata specifica per l'aiuola |
| notes | Text | Annotazioni |

---

## Chiave primaria

La chiave primaria è:

- `id`

---

## Chiavi esterne

La tabella contiene le seguenti chiavi esterne:

- `irrigation_event_id → irrigation_events.id`
- `bed_id → beds.id`

---

## Relazioni

```text
irrigation_events
        │
        ├──────── irrigation_event_beds ──────── beds
```

Ogni evento può essere collegato a più aiuole.

Ogni aiuola può comparire in numerosi eventi di irrigazione nel corso del tempo.

---

## Utilizzo nel codice

La tabella verrà utilizzata da:

- cronologia irrigazioni;
- gestione irrigazione manuale;
- gestione irrigazione automatica;
- statistiche per aiuola;
- dashboard irrigazione;
- motore decisionale.

---

## Scelte progettuali

È stata adottata una tabella di collegamento invece di inserire direttamente l'identificativo dell'aiuola nella tabella `irrigation_events`.

Questa scelta permette di:

- gestire irrigazioni multiple con un solo evento;
- evitare duplicazioni dei dati comuni;
- mantenere un modello relazionale flessibile;
- facilitare future estensioni del sistema.

---

## Evoluzioni future

La tabella potrà essere estesa con:

- quantità d'acqua realmente distribuita;
- esito dell'irrigazione;
- pressione dell'impianto;
- portata media;
- stato della valvola;
- identificativo dell'elettrovalvola;
- dati provenienti da sensori di umidità;
- eventuali anomalie rilevate durante l'irrigazione.

---

# 4. Modello dati complessivo

## Panoramica

Le tabelle del database sono organizzate secondo un modello relazionale che separa i diversi concetti dell'applicazione, evitando duplicazioni di dati e facilitando l'evoluzione futura del sistema.

Il diagramma seguente mostra le principali relazioni tra le entità.

```text
                 gardens
                    │
                    │ 1
                    │
                    ▼
                  beds
                    │
        ┌───────────┴────────────┐
        │                        │
        │                        │
        ▼                        ▼
    plantings         irrigation_event_beds
        ▲                        ▲
        │                        │
        │                        │
    seasons              irrigation_events
        │
        │
        ▼
      crops
```

---

## Descrizione delle relazioni

### gardens → beds

Un orto può contenere numerose aiuole.

Ogni aiuola appartiene ad un solo orto.

---

### beds → plantings

Ogni aiuola può contenere numerose piantagioni durante la stagione.

Le piantagioni identificano la posizione reale delle colture.

---

### seasons → plantings

Ogni piantagione appartiene ad una stagione.

Questo permette di mantenere lo storico delle coltivazioni anno dopo anno.

---

### crops → plantings

Ogni piantagione fa riferimento ad una coltura presente nel catalogo.

Le caratteristiche agronomiche vengono ereditate dalla coltura e possono essere personalizzate nella singola piantagione.

---

### irrigation_events → irrigation_event_beds → beds

Un evento di irrigazione può interessare una o più aiuole.

La tabella di collegamento consente di rappresentare questa relazione senza duplicare i dati dell'evento.

---

## Principi progettuali

Il modello dati è stato progettato seguendo alcuni principi fondamentali:

- normalizzazione del database;
- separazione delle responsabilità;
- minimizzazione della duplicazione dei dati;
- espandibilità nel tempo;
- tracciabilità storica delle coltivazioni;
- semplicità di interrogazione da parte dell'applicazione Flutter.

Questi principi consentono di aggiungere nuove funzionalità senza modificare la struttura esistente del database.

# 5. Modelli Flutter

## Introduzione

I modelli Flutter rappresentano la corrispondenza diretta delle principali entità presenti nel database Supabase.

Ogni modello ha il compito di:

- rappresentare un record di una tabella;
- convertire i dati provenienti dal database in oggetti Dart;
- convertire gli oggetti Dart in mappe utilizzabili da Supabase;
- fornire un'interfaccia tipizzata al resto dell'applicazione.

L'utilizzo dei modelli permette di separare la logica applicativa dalla gestione diretta del database, migliorando leggibilità, manutenibilità e sicurezza del codice.

Nel progetto Orto Smart ogni modello è collocato nella cartella:

```
lib/data/models/
```

I principali modelli attualmente presenti sono:

- Garden
- Bed
- Crop
- Season
- Planting

Nei capitoli successivi ciascun modello verrà descritto nel dettaglio.

## 5.1 Modello `Garden`

### Scopo

Il modello `Garden` rappresenta un orto all'interno dell'applicazione.

Costituisce il punto di ingresso dell'intero sistema e contiene le informazioni generali dell'orto gestito dall'utente.

---

### Responsabilità

Il modello ha il compito di:

- rappresentare un record della tabella `gardens`;
- ricevere i dati provenienti dal database;
- renderli disponibili alle pagine Flutter;
- consentire eventuali aggiornamenti del record.

---

### Origine dei dati

```
Supabase
      │
      ▼
Tabella gardens
      │
      ▼
Garden.fromMap()
      │
      ▼
Oggetto Garden
```

---

### Utilizzo nell'applicazione

Il modello viene utilizzato principalmente da:

- GardenRepository
- Home Page
- Garden Page

Ogni volta che l'applicazione carica l'orto, viene creato un oggetto `Garden` che contiene le informazioni necessarie alle schermate successive.

---

### Vantaggi

L'utilizzo del modello consente di:

- evitare l'uso diretto di `Map<String, dynamic>` nel resto del codice;
- aumentare la leggibilità;
- ridurre gli errori di tipo;
- centralizzare la conversione dei dati.

---

### Evoluzioni future

Il modello potrà essere esteso con:

- coordinate GPS;
- fotografie;
- tipo di terreno;
- informazioni climatiche;
- impostazioni specifiche dell'orto.

## 5.2 Modello `Bed`

### Scopo

Il modello `Bed` rappresenta una singola aiuola dell'orto.

Ogni oggetto `Bed` corrisponde a un record della tabella `beds` e contiene le informazioni necessarie per identificare, visualizzare e gestire un'aiuola all'interno dell'applicazione.

---

### Responsabilità

Il modello ha il compito di:

- rappresentare una singola aiuola;
- convertire i dati provenienti da Supabase in un oggetto Dart;
- rendere disponibili le informazioni alle pagine Flutter;
- fornire i dati utilizzati dalla visualizzazione grafica delle aiuole.

---

### Origine dei dati

```text
Supabase
      │
      ▼
Tabella beds
      │
      ▼
Bed.fromMap()
      │
      ▼
Oggetto Bed
```

---

### Utilizzo nell'applicazione

Il modello viene utilizzato principalmente da:

- BedRepository;
- Garden Page;
- Bed Page;
- BedLayoutWidget;
- future funzionalità di irrigazione;
- motore agronomico.

Ogni aiuola caricata dal database viene rappresentata come un oggetto `Bed`, che viene poi utilizzato per costruire l'interfaccia e gestire le operazioni dell'utente.

---

### Informazioni gestite

Il modello contiene, tra le altre, le seguenti informazioni:

- identificativo dell'aiuola;
- orto di appartenenza;
- numero progressivo;
- lunghezza;
- larghezza;
- zona di irrigazione;
- stato di attivazione.

---

### Vantaggi

L'utilizzo del modello consente di:

- separare il codice dell'interfaccia dal database;
- utilizzare oggetti tipizzati;
- semplificare la manutenzione del codice;
- centralizzare la conversione dei dati.

---

### Evoluzioni future

Il modello potrà essere esteso con:

- orientamento dell'aiuola;
- esposizione solare;
- tipologia del terreno;
- fotografie;
- sensori associati;
- informazioni sulla fertilità del suolo.

## 5.3 Modello `Crop`

### Scopo

Il modello `Crop` rappresenta una coltura disponibile nel catalogo di Orto Smart.

Ogni oggetto `Crop` corrisponde a un record della tabella `crops` e contiene le informazioni agronomiche utilizzate per suggerire all'utente i valori predefiniti durante la creazione di una nuova piantagione.

---

### Responsabilità

Il modello ha il compito di:

- rappresentare una coltura;
- convertire i dati provenienti da Supabase in oggetti Dart;
- fornire i parametri agronomici suggeriti;
- alimentare il motore agronomico.

---

### Origine dei dati

```text
Supabase
      │
      ▼
Tabella crops
      │
      ▼
Crop.fromMap()
      │
      ▼
Oggetto Crop
```

---

### Utilizzo nell'applicazione

Il modello viene utilizzato principalmente da:

- PlantingRepository;
- AddPlantingPage;
- motore agronomico;
- Suggestion Engine;
- future statistiche.

Quando l'utente seleziona una coltura, l'applicazione crea un oggetto `Crop` che mette a disposizione tutte le informazioni necessarie per compilare automaticamente la nuova piantagione.

---

### Informazioni gestite

Il modello contiene informazioni quali:

- nome della coltura;
- varietà;
- metodo di semina;
- distanza tra le file;
- distanza tra le piante.

Nel tempo potranno essere aggiunti ulteriori parametri agronomici.

---

### Vantaggi

L'utilizzo del modello consente di:

- centralizzare le informazioni delle colture;
- evitare duplicazioni;
- uniformare i dati utilizzati dal motore agronomico;
- semplificare la manutenzione del catalogo.

---

### Evoluzioni future

Il modello potrà essere esteso con:

- famiglia botanica;
- durata del ciclo colturale;
- profondità di semina;
- fabbisogno idrico;
- fabbisogno nutrizionale;
- periodo di raccolta;
- esposizione consigliata;
- compatibilità con altre colture;
- colore identificativo per la visualizzazione grafica.

## 5.4 Modello `Season`

### Scopo

Il modello `Season` rappresenta una stagione agronomica all'interno dell'applicazione.

Ogni oggetto `Season` corrisponde a un record della tabella `seasons` e identifica un periodo di coltivazione, consentendo di organizzare le piantagioni e conservarne lo storico.

---

### Responsabilità

Il modello ha il compito di:

- rappresentare una stagione agronomica;
- convertire i dati provenienti da Supabase in oggetti Dart;
- identificare la stagione attiva;
- permettere il recupero dello storico delle coltivazioni.

---

### Origine dei dati

```text
Supabase
      │
      ▼
Tabella seasons
      │
      ▼
Season.fromMap()
      │
      ▼
Oggetto Season
```

---

### Utilizzo nell'applicazione

Il modello viene utilizzato principalmente da:

- PlantingRepository;
- motore agronomico;
- gestione delle piantagioni;
- statistiche stagionali;
- future analisi storiche.

La stagione attiva viene utilizzata automaticamente dall'applicazione per mostrare le coltivazioni correnti.

---

### Informazioni gestite

Il modello contiene:

- identificativo della stagione;
- nome della stagione;
- data di inizio;
- data di fine;
- stato attivo.

---

### Vantaggi

L'utilizzo del modello consente di:

- mantenere lo storico delle coltivazioni;
- separare i dati dei diversi anni agricoli;
- facilitare analisi e confronti;
- supportare il motore agronomico nelle rotazioni.

---

### Evoluzioni future

Il modello potrà essere esteso con:

- note stagionali;
- andamento climatico;
- indicatori produttivi;
- statistiche economiche;
- report automatici;
- valutazioni finali della stagione.

## 5.5 Modello `Planting`

### Scopo

Il modello `Planting` rappresenta una singola piantagione all'interno di un'aiuola.

Ogni oggetto `Planting` corrisponde a un record della tabella `plantings` e descrive una coltivazione reale, con la sua posizione, le sue caratteristiche e il suo stato.

È il modello centrale dell'applicazione, poiché collega orto, aiuola, stagione e coltura in un'unica entità.

---

### Responsabilità

Il modello ha il compito di:

- rappresentare una piantagione;
- convertire i dati provenienti da Supabase in oggetti Dart;
- memorizzare lo stato reale della coltivazione;
- fornire i dati al motore agronomico;
- alimentare la rappresentazione grafica delle aiuole.

---

### Origine dei dati

```text
Supabase
      │
      ▼
Tabella plantings
      │
      ▼
Planting.fromMap()
      │
      ▼
Oggetto Planting
```

---

### Utilizzo nell'applicazione

Il modello viene utilizzato da:

- PlantingRepository;
- Bed Page;
- BedLayoutWidget;
- AddPlantingPage;
- motore agronomico;
- Suggestion Engine;
- future attività;
- futura irrigazione;
- future statistiche.

Ogni piantagione caricata dal database viene trasformata in un oggetto `Planting`, che costituisce la base per tutte le elaborazioni dell'applicazione.

---

### Informazioni gestite

Il modello contiene, tra le altre, le seguenti informazioni:

- stagione;
- aiuola;
- coltura;
- data di semina o trapianto;
- metodo di coltivazione;
- numero di piante;
- posizione iniziale;
- lunghezza occupata;
- larghezza occupata;
- distanza tra le file;
- distanza tra le piante;
- numero di file;
- stato della coltivazione;
- note.

---

### Ciclo di vita della piantagione

Una piantagione segue normalmente il seguente ciclo operativo:

```text
Creazione
      │
      ▼
Inserimento nell'aiuola
      │
      ▼
Crescita
      │
      ▼
Gestione attività
      │
      ▼
Irrigazione
      │
      ▼
Raccolta
      │
      ▼
Archiviazione nello storico
```

Questo ciclo rappresenta il flusso naturale di una coltivazione all'interno di Orto Smart.

---

### Collegamento con il motore agronomico

Il modello `Planting` costituisce la principale sorgente dati del motore agronomico.

Le informazioni contenute vengono utilizzate per:

- verificare lo spazio occupato;
- individuare gli spazi liberi;
- proporre nuove piantagioni;
- controllare eventuali sovrapposizioni;
- applicare le regole di rotazione;
- applicare le regole di consociazione;
- pianificare irrigazioni e attività.

---

### Visualizzazione grafica

Il modello viene utilizzato direttamente dal `BedLayoutWidget` per rappresentare la disposizione delle colture nell'aiuola.

Ogni piantagione viene trasformata in un elemento grafico la cui posizione e dimensione dipendono dai valori memorizzati nel modello.

---

### Vantaggi

L'utilizzo del modello consente di:

- centralizzare tutte le informazioni della coltivazione;
- mantenere separata la logica dal database;
- semplificare gli algoritmi del motore agronomico;
- facilitare l'evoluzione futura dell'applicazione.

---

### Evoluzioni future

Il modello potrà essere esteso con:

- data di raccolta;
- quantità raccolta;
- peso totale;
- fotografie della coltivazione;
- costo della coltura;
- tempo di lavoro;
- collegamento alle attività;
- collegamento agli eventi di irrigazione;
- stato sanitario;
- valutazioni qualitative del raccolto.

# 6. Repository

## Introduzione

I Repository costituiscono il livello di accesso ai dati dell'applicazione.

Il loro compito è quello di isolare tutta la comunicazione con Supabase dal resto del codice Flutter.

Grazie a questa architettura, le pagine dell'applicazione non accedono mai direttamente al database, ma utilizzano esclusivamente i repository.

Questo approccio offre numerosi vantaggi:

- separazione delle responsabilità;
- codice più leggibile;
- maggiore facilità di manutenzione;
- possibilità di modificare il backend senza intervenire sull'interfaccia utente;
- migliore testabilità del codice.

Nel progetto Orto Smart tutti i repository sono collocati nella cartella:

```
lib/data/repositories/
```

Attualmente i repository principali sono:

- GardenRepository
- BedRepository
- PlantingRepository

In futuro potranno essere aggiunti ulteriori repository dedicati alle attività, all'irrigazione, ai raccolti, alle statistiche e ad altri moduli dell'applicazione.

---

## Flusso dei dati

Il flusso delle informazioni segue il seguente percorso:

```text
Supabase
      │
      ▼
Repository
      │
      ▼
Model
      │
      ▼
Pagina Flutter
      │
      ▼
Widget
```

Ogni livello ha una responsabilità ben definita e comunica esclusivamente con il livello adiacente, mantenendo l'architettura ordinata e modulare.

## 6.1 GardenRepository

### Scopo

Il `GardenRepository` gestisce tutte le operazioni di lettura e scrittura relative agli orti.

È il punto di accesso alla tabella `gardens` e rappresenta il primo livello di comunicazione tra l'applicazione e Supabase.

---

### Responsabilità

Il repository ha il compito di:

- recuperare gli orti dal database;
- convertire i dati in oggetti `Garden`;
- gestire eventuali operazioni di aggiornamento;
- isolare le query SQL dal resto dell'applicazione.

---

### Flusso operativo

```text
Pagina Flutter
      │
      ▼
GardenRepository
      │
      ▼
Supabase
      │
      ▼
Tabella gardens
```

---

### Utilizzo

Il repository viene utilizzato principalmente dalla schermata iniziale e dalla pagina dell'orto.

Quando viene richiesto il caricamento dell'orto, il repository interroga Supabase, converte il risultato in un oggetto `Garden` e lo restituisce all'interfaccia.

---

### Vantaggi

L'utilizzo del repository permette di:

- centralizzare tutte le query;
- evitare duplicazioni di codice;
- semplificare la manutenzione;
- migliorare la leggibilità del progetto.

---

### Evoluzioni future

Il repository potrà essere esteso con metodi per:

- creare nuovi orti;
- modificare le informazioni dell'orto;
- eliminare un orto;
- gestire più orti contemporaneamente.

## 6.2 BedRepository

### Scopo

Il `BedRepository` gestisce tutte le operazioni di accesso ai dati relative alle aiuole.

È il componente incaricato di interrogare la tabella `beds`, convertire i risultati in oggetti `Bed` e fornire tali informazioni alle schermate dell'applicazione.

---

### Responsabilità

Il repository ha il compito di:

- recuperare le aiuole dal database;
- filtrare le aiuole attive;
- ordinarle secondo il numero progressivo;
- convertire i record in oggetti `Bed`;
- isolare le query verso Supabase.

---

### Flusso operativo

```text
Garden Page
      │
      ▼
BedRepository
      │
      ▼
Supabase
      │
      ▼
Tabella beds
```

---

### Utilizzo

Il repository viene utilizzato principalmente da:

- Garden Page;
- Bed Page;
- future funzionalità di gestione delle aiuole.

Nel funzionamento attuale dell'applicazione, le aiuole attive vengono recuperate tramite il metodo `getBeds()`, che restituisce i dati già ordinati per numero progressivo.

---

### Vantaggi

L'utilizzo del repository permette di:

- mantenere separate le query dal resto del codice;
- centralizzare la logica di accesso ai dati;
- semplificare eventuali modifiche future al database;
- garantire uniformità nel recupero delle aiuole.

---

### Evoluzioni future

Il repository potrà essere esteso con metodi per:

- creare una nuova aiuola;
- modificare le caratteristiche di un'aiuola;
- disattivare o riattivare un'aiuola;
- recuperare un'aiuola tramite il suo identificativo;
- ricercare aiuole con filtri specifici.

---

### Stato delle funzionalità

| Metodo | Descrizione | Stato |
|--------|-------------|:-----:|
| `getBeds()` | Recupera le aiuole attive ordinate per numero | ✅ Implementato |
| `getBedById()` | Recupera una singola aiuola | ⏳ Previsto |
| `createBed()` | Crea una nuova aiuola | ⏳ Previsto |
| `updateBed()` | Modifica un'aiuola | ⏳ Previsto |
| `deleteBed()` | Disattiva o elimina un'aiuola | ⏳ Previsto |

---

### Note di implementazione

Attualmente il repository restituisce esclusivamente le aiuole attive (`is_active = true`) e le ordina tramite il campo `number`.

Questa scelta garantisce una visualizzazione coerente con la numerazione fisica delle aiuole presenti nell'orto e semplifica la navigazione dell'utente.

## 6.3 PlantingRepository

### Scopo

Il `PlantingRepository` gestisce tutte le operazioni di accesso ai dati relative alle piantagioni.

È il componente che mette in comunicazione l'applicazione con la tabella `plantings`, occupandosi del recupero, della creazione, della modifica e della futura gestione dello storico delle coltivazioni.

---

### Responsabilità

Il repository ha il compito di:

- recuperare le piantagioni dal database;
- filtrarle per aiuola e stagione;
- creare nuove piantagioni;
- aggiornare quelle esistenti;
- convertire i dati di Supabase in oggetti `Planting`;
- fornire le informazioni al motore agronomico e all'interfaccia grafica.

---

### Flusso operativo

```text
Bed Page
      │
      ▼
PlantingRepository
      │
      ▼
Supabase
      │
      ▼
Tabella plantings
```

---

### Utilizzo

Il repository viene utilizzato principalmente da:

- Bed Page;
- AddPlantingPage;
- BedLayoutWidget;
- motore agronomico;
- Suggestion Engine;
- future funzionalità di irrigazione;
- future attività.

Ogni volta che l'utente visualizza un'aiuola o inserisce una nuova coltivazione, il repository gestisce il recupero e il salvataggio delle informazioni.

---

### Vantaggi

L'utilizzo del repository consente di:

- centralizzare tutte le operazioni sulle piantagioni;
- mantenere separata la logica di accesso ai dati;
- semplificare la manutenzione del codice;
- facilitare l'introduzione di nuove funzionalità.

---

### Stato delle funzionalità

| Metodo | Descrizione | Stato |
|--------|-------------|:-----:|
| `getPlantingsByBed()` | Recupera le piantagioni di un'aiuola | ✅ Implementato |
| `addPlanting()` | Inserisce una nuova piantagione | ✅ Implementato |
| `updatePlanting()` | Aggiorna una piantagione | ✅ Implementato |
| `deletePlanting()` | Elimina una piantagione | ⏳ Previsto |
| `getPlantingsBySeason()` | Recupera le piantagioni di una stagione | ⏳ Previsto |
| `archivePlanting()` | Archivia una piantagione conclusa | ⏳ Previsto |

---

### Note di implementazione

Le piantagioni vengono recuperate ordinate in base alla posizione iniziale (`start_position_cm`).

Questa scelta garantisce una rappresentazione grafica coerente all'interno del `BedLayoutWidget` e semplifica gli algoritmi che calcolano gli spazi occupati e quelli disponibili.

Inoltre, il repository costituisce il principale punto di accesso ai dati utilizzati dal motore agronomico, che si basa sulle informazioni delle piantagioni per effettuare analisi, suggerimenti e controlli.

# 7. Motore Agronomico

## Introduzione

Il Motore Agronomico rappresenta il componente intelligente di Orto Smart.

A differenza di una tradizionale applicazione per la gestione dell'orto, il Motore Agronomico non si limita a registrare dati, ma li analizza per supportare l'utente nelle decisioni quotidiane.

Il suo obiettivo è trasformare le informazioni memorizzate nel database in suggerimenti pratici, contribuendo a migliorare la pianificazione delle coltivazioni, l'utilizzo dello spazio disponibile e la gestione dell'orto.

Nel tempo il Motore Agronomico evolverà progressivamente fino a diventare il principale sistema decisionale dell'applicazione.

---

## Obiettivi

Il Motore Agronomico è progettato per:

- analizzare le coltivazioni presenti;
- individuare gli spazi ancora disponibili;
- suggerire il posizionamento delle nuove colture;
- verificare la compatibilità tra colture;
- controllare le rotazioni colturali;
- supportare la pianificazione delle attività;
- ottimizzare l'irrigazione;
- integrare le informazioni meteorologiche;
- assistere l'utente nelle decisioni operative.

---

## Filosofia

Il Motore Agronomico non sostituisce l'esperienza dell'orticoltore.

L'obiettivo è fornire suggerimenti motivati e facilmente comprensibili, lasciando sempre all'utente la decisione finale.

Ogni suggerimento dovrà essere spiegato, in modo che l'utente possa comprenderne le motivazioni e scegliere consapevolmente se seguirlo o meno.

---

## Evoluzione prevista

Lo sviluppo del Motore Agronomico sarà incrementale.

Le funzionalità verranno introdotte progressivamente secondo una roadmap composta da moduli indipendenti, in modo da garantire stabilità, semplicità di manutenzione e possibilità di espansione futura.

## 7.1 Algoritmo di individuazione degli spazi liberi

### Obiettivo

L'algoritmo di individuazione degli spazi liberi ha il compito di analizzare una singola aiuola e determinare quali porzioni risultano ancora disponibili per l'inserimento di nuove colture.

Questa funzione costituisce la base del Motore Agronomico, poiché tutte le successive elaborazioni (suggerimenti, rotazioni, consociazioni e pianificazione) dipendono dalla corretta identificazione dello spazio disponibile.

---

### Dati di ingresso

L'algoritmo utilizza:

- dimensioni dell'aiuola;
- elenco delle piantagioni presenti;
- posizione iniziale di ogni piantagione;
- lunghezza occupata;
- larghezza occupata;
- stato della coltivazione.

---

### Elaborazione

L'algoritmo esegue le seguenti operazioni:

1. recupera tutte le piantagioni dell'aiuola;
2. le ordina in base alla posizione iniziale (`start_position_cm`);
3. individua gli spazi presenti tra una piantagione e la successiva;
4. verifica lo spazio disponibile all'inizio dell'aiuola;
5. verifica lo spazio disponibile alla fine dell'aiuola;
6. genera l'elenco completo degli spazi liberi.

---

### Risultato

Per ogni spazio libero vengono calcolati:

- posizione iniziale;
- posizione finale;
- lunghezza disponibile;
- larghezza disponibile;
- area disponibile.

Queste informazioni vengono utilizzate dal Suggestion Engine per individuare le colture compatibili.

---

### Rappresentazione semplificata

```text
Aiuola (700 cm)

|----Pomodoro----|------Spazio------|--Lattuga--|---------Spazio---------|

↓

Spazio 1
inizio: 200 cm
fine: 320 cm

↓

Spazio 2
inizio: 420 cm
fine: 700 cm
```

---

### Complessità

L'algoritmo richiede come prerequisito l'ordinamento delle piantagioni.

Una volta ordinate, l'analisi viene eseguita con una singola scansione sequenziale, risultando efficiente anche in presenza di numerose colture.

---

### Evoluzioni future

L'algoritmo verrà esteso per considerare anche:

- larghezza realmente occupata;
- colture a più file;
- semine a spaglio;
- aree non coltivabili;
- ostacoli permanenti;
- distanze di sicurezza tra colture;
- vincoli imposti dal sistema di irrigazione.

## 7.2 Algoritmo di suggerimento automatico del posizionamento

### Obiettivo

L'algoritmo di suggerimento automatico del posizionamento ha il compito di individuare la migliore posizione disponibile per l'inserimento di una nuova coltura all'interno di un'aiuola.

L'obiettivo non è soltanto trovare uno spazio libero, ma proporre la soluzione più adatta dal punto di vista agronomico e pratico.

---

### Dati di ingresso

L'algoritmo utilizza:

- elenco degli spazi liberi;
- coltura selezionata;
- lunghezza necessaria;
- larghezza necessaria;
- distanze di sicurezza;
- caratteristiche della coltura.

---

### Elaborazione

L'algoritmo esegue le seguenti operazioni:

1. recupera tutti gli spazi disponibili;
2. elimina quelli troppo piccoli;
3. verifica la compatibilità della larghezza;
4. ordina gli spazi secondo criteri di priorità;
5. individua la posizione consigliata;
6. restituisce il suggerimento all'utente.

---

### Criteri di scelta

In presenza di più spazi compatibili, il sistema privilegia:

1. utilizzo dello spazio più adatto;
2. riduzione degli spazi inutilizzati;
3. continuità delle colture;
4. semplicità delle future lavorazioni;
5. facilità di irrigazione.

---

### Risultato

Il sistema restituisce:

- posizione iniziale consigliata;
- lunghezza occupata;
- motivazione del suggerimento;
- eventuali alternative disponibili.

Il suggerimento non modifica automaticamente il database.

La decisione finale rimane sempre dell'utente.

---

### Esempio

```text
Spazi disponibili

120 cm
75 cm
240 cm

Nuova coltura

Pomodoro
necessari: 180 cm

↓

Spazio suggerito

240 cm

Motivazione

È il primo spazio sufficientemente grande e permette di mantenere una disposizione ordinata delle colture.
```

---

### Evoluzioni future

L'algoritmo potrà considerare anche:

- consociazioni favorevoli;
- rotazioni colturali;
- esposizione al sole;
- direzione dei filari;
- impianto di irrigazione;
- facilità di raccolta;
- distanza dal percorso principale;
- preferenze dell'utente.

## 7.3 Algoritmo delle rotazioni colturali

### Obiettivo

L'algoritmo delle rotazioni colturali ha il compito di suggerire la successione delle colture nelle aiuole, riducendo il rischio di impoverimento del terreno, limitando l'insorgenza di patologie e favorendo una migliore fertilità.

Le rotazioni rappresentano uno dei principi fondamentali dell'agricoltura sostenibile e costituiscono una componente essenziale del Motore Agronomico.

---

### Dati di ingresso

L'algoritmo utilizza:

- storico delle stagioni;
- storico delle piantagioni;
- famiglia botanica della coltura;
- posizione dell'aiuola;
- durata del ciclo colturale.

---

### Elaborazione

Per ogni nuova coltivazione il sistema:

1. recupera lo storico dell'aiuola;
2. individua le colture coltivate nelle stagioni precedenti;
3. confronta la famiglia botanica;
4. verifica eventuali incompatibilità;
5. assegna un livello di rischio;
6. genera un suggerimento.

---

### Livelli di valutazione

Il sistema classifica ogni proposta in quattro categorie.

| Livello | Significato |
|----------|-------------|
| 🟢 Ottimale | Rotazione consigliata |
| 🟡 Accettabile | Nessun problema rilevante |
| 🟠 Sconsigliata | Possibili criticità |
| 🔴 Da evitare | Rotazione non consigliata |

---

### Risultato

Per ogni coltura proposta il sistema mostrerà:

- livello di compatibilità;
- motivazione;
- colture precedenti considerate;
- eventuali alternative consigliate.

La decisione finale rimane sempre dell'utente.

---

### Evoluzioni future

L'algoritmo potrà considerare anche:

- fertilizzazioni effettuate;
- colture da sovescio;
- durata effettiva delle coltivazioni;
- analisi del terreno;
- presenza di fitopatie;
- dati climatici delle stagioni precedenti.

---

### Stato di implementazione

| Funzionalità | Stato |
|--------------|:-----:|
| Analisi storico colture | 📋 Pianificata |
| Verifica famiglie botaniche | 📋 Pianificata |
| Calcolo livello di rischio | 📋 Pianificata |
| Suggerimenti automatici | 📋 Pianificata |

## 7.4 Algoritmo delle consociazioni

### Obiettivo

L'algoritmo delle consociazioni ha il compito di valutare la compatibilità tra le colture presenti nella stessa aiuola e la nuova coltura che si intende inserire.

L'obiettivo è favorire associazioni benefiche tra specie vegetali e ridurre le combinazioni che potrebbero causare competizione, diffusione di malattie o riduzione della produttività.

---

### Dati di ingresso

L'algoritmo utilizza:

- coltura da inserire;
- elenco delle colture presenti nell'aiuola;
- posizione delle colture;
- famiglia botanica;
- futura tabella delle consociazioni;
- distanza reciproca tra le colture.

---

### Elaborazione

Per ogni coltura presente nell'aiuola il sistema:

1. identifica la specie coltivata;
2. confronta la compatibilità con la nuova coltura;
3. assegna un punteggio di compatibilità;
4. individua eventuali conflitti;
5. calcola un giudizio complessivo.

---

### Livelli di compatibilità

| Livello | Significato |
|----------|-------------|
| 🟢 Ottima | Consociazione consigliata |
| 🟡 Buona | Compatibilità soddisfacente |
| 🟠 Debole | Possibili criticità |
| 🔴 Negativa | Consociazione da evitare |

---

### Risultato

Il sistema presenterà all'utente:

- livello di compatibilità;
- motivazione della valutazione;
- eventuali criticità;
- suggerimenti alternativi, se disponibili.

L'utente potrà comunque confermare la scelta anche in presenza di un giudizio non ottimale.

---

### Evoluzioni future

L'algoritmo potrà tenere conto anche di:

- distanza effettiva tra le colture;
- altezza delle piante;
- ombreggiamento;
- apparato radicale;
- fabbisogno idrico;
- esigenze nutrizionali;
- attrazione di insetti utili;
- capacità di allontanare parassiti.

---

### Stato di implementazione

| Funzionalità | Stato |
|--------------|:-----:|
| Archivio consociazioni | 📋 Pianificata |
| Calcolo compatibilità | 📋 Pianificata |
| Sistema di punteggio | 📋 Pianificata |
| Suggerimenti automatici | 📋 Pianificata |

## 7.5 Pianificazione intelligente delle attività

### Obiettivo

La pianificazione intelligente delle attività ha lo scopo di suggerire all'utente quali operazioni eseguire ogni giorno, organizzandole in base alla situazione reale dell'orto.

L'obiettivo non è creare un semplice calendario, ma costruire un piano di lavoro dinamico che tenga conto dello stato delle colture, delle condizioni meteorologiche e delle priorità agronomiche.

---

### Dati di ingresso

Il sistema utilizza:

- colture presenti;
- stato delle coltivazioni;
- stagione corrente;
- previsioni meteorologiche;
- irrigazioni effettuate;
- attività già completate;
- calendario agronomico;
- preferenze dell'utente.

---

### Elaborazione

Ogni giorno il motore:

1. analizza la situazione dell'orto;
2. individua le attività necessarie;
3. assegna una priorità;
4. ordina le attività;
5. genera il piano di lavoro giornaliero.

---

### Tipologie di attività

Le attività potranno comprendere:

- semina;
- trapianto;
- irrigazione;
- raccolta;
- concimazione;
- diserbo;
- trattamenti;
- controllo fitosanitario;
- manutenzione dell'impianto.

---

### Livelli di priorità

| Priorità | Significato |
|-----------|-------------|
| 🔴 Alta | Da eseguire oggi |
| 🟠 Media | Da eseguire entro pochi giorni |
| 🟡 Bassa | Attività programmabile |
| 🔵 Informativa | Suggerimento o promemoria |

---

### Risultato

Il sistema presenterà un piano di lavoro giornaliero con:

- elenco delle attività;
- motivazione del suggerimento;
- tempo stimato;
- aiuola interessata;
- coltura coinvolta;
- priorità.

L'utente potrà confermare, rinviare o ignorare ogni attività.

---

### Collegamento con il timer di lavoro

Ogni attività potrà essere avviata mediante il pulsante **"Inizia lavoro"**.

L'avvio dell'attività consentirà di:

- registrare l'orario di inizio;
- misurare il tempo effettivamente impiegato;
- memorizzare la durata;
- aggiornare automaticamente il diario delle attività.

Questa funzionalità permetterà di raccogliere dati utili per analisi future sul tempo dedicato all'orto.

---

### Evoluzioni future

La pianificazione potrà essere estesa con:

- ottimizzazione del percorso tra le aiuole;
- raggruppamento automatico delle attività simili;
- adattamento alle condizioni meteorologiche in tempo reale;
- integrazione con l'irrigazione automatica;
- notifiche e promemoria;
- suggerimenti basati sullo storico delle lavorazioni.

---

### Stato di implementazione

| Funzionalità | Stato |
|--------------|:-----:|
| Piano di lavoro giornaliero | 📋 Pianificata |
| Calcolo delle priorità | 📋 Pianificata |
| Timer attività | 📋 Pianificata |
| Diario automatico | 📋 Pianificata |
| Stima tempi di lavoro | 📋 Pianificata |

## 7.6 Irrigazione intelligente

### Obiettivo

L'algoritmo di irrigazione intelligente ha il compito di suggerire quando irrigare, quanta acqua distribuire e quali aiuole irrigare, utilizzando le informazioni disponibili nell'applicazione e i dati meteorologici.

L'obiettivo è ridurre gli sprechi d'acqua, migliorare lo stato delle colture e assistere l'utente nelle decisioni quotidiane.

---

### Dati di ingresso

Il sistema utilizza:

- colture presenti;
- fase di sviluppo della coltura;
- fabbisogno idrico;
- irrigazioni già effettuate;
- pioggia registrata;
- previsioni meteorologiche;
- temperatura;
- umidità del terreno (futuri sensori);
- umidità dell'aria.

---

### Elaborazione

Il motore:

1. analizza il fabbisogno delle colture;
2. verifica le irrigazioni recenti;
3. considera la pioggia caduta e prevista;
4. calcola il livello di necessità;
5. propone l'eventuale irrigazione.

---

### Livelli di necessità

| Livello | Significato |
|----------|-------------|
| 🔴 Molto alta | Irrigare appena possibile |
| 🟠 Alta | Irrigazione consigliata |
| 🟡 Media | Monitorare la situazione |
| 🟢 Bassa | Nessun intervento necessario |

---

### Risultato

Per ogni aiuola il sistema potrà mostrare:

- livello di necessità;
- quantità d'acqua consigliata;
- motivazione del suggerimento;
- durata stimata dell'irrigazione;
- eventuali avvisi meteo.

L'utente potrà scegliere se seguire il suggerimento oppure modificarlo.

---

### Integrazione futura

L'algoritmo sarà progettato per funzionare sia con irrigazione manuale sia con irrigazione automatica.

Nel caso dell'impianto automatico potrà:

- attivare le elettrovalvole;
- controllare le zone di irrigazione;
- registrare automaticamente gli interventi;
- interrompere l'irrigazione in caso di pioggia o anomalie.

---

### Fonti dati

Il sistema potrà integrare informazioni provenienti da:

- stazione meteo Davis;
- archivio meteorologico storico;
- previsioni meteorologiche;
- sensori di umidità del terreno;
- Raspberry Pi;
- ESP32.

---

### Stato di implementazione

| Funzionalità | Stato |
|--------------|:-----:|
| Irrigazione manuale | 🚧 In sviluppo |
| Suggerimenti irrigazione | 📋 Pianificata |
| Analisi meteo | 📋 Pianificata |
| Integrazione Davis | 📋 Pianificata |
| Raspberry Pi | 📋 Pianificata |
| Sensori terreno | 📋 Pianificata |
| Irrigazione automatica | 📋 Pianificata |

