# ORTO SMART

### DOC-001

# Manuale Tecnico e Architetturale

**Versione:** 1.1
**Stato:** Approvato  

**Autore:** Renzo Siega  
**Progetto:** Orto Smart  

**Data prima emissione:** 26/07/2026  
**Ultimo aggiornamento:** 08/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-001 |
| Titolo | Manuale Tecnico e Architetturale |
| Versione | 1.1 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Linguaggio | Flutter / Dart |
| Backend | Supabase / PostgreSQL |
| Repository | ortosmart/orto-smart |
| Prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 08/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data       | Descrizione                                                                                       |
| -------- | ---------- | ------------------------------------------------------------------------------------------------- |
| 0.1      | 26/07/2026 | Prima emissione del Manuale Tecnico                                                               |
| 0.2      | 27/07/2026 | Aggiornamento architettura e struttura documentale                                                |
| 1.0      | 31/07/2026 | Revisione completa e approvazione del Manuale Tecnico                                             |
| 1.1      | 08/08/2026 | Aggiornamento del Motore Agronomico con RecommendationPipeline, DecisionEngine e DecisionWeights |
---

# Indice

## 1. Scopo del documento
1.1 Finalità  
1.2 Destinatari  
1.3 Obiettivi  
1.4 Aggiornamento del documento

## 2. Architettura generale
2.1 Obiettivo  
2.2 Visione architetturale  
2.3 Architettura a livelli  
2.4 Tecnologie utilizzate  
2.5 Principi architetturali  
2.6 Componenti principali  
2.7 Flusso generale delle informazioni  
2.8 Evoluzione dell'architettura  
2.9 Considerazioni finali

## 3. Struttura del progetto
3.1 Obiettivo  
3.2 Organizzazione generale  
3.3 Struttura delle directory principali  
3.4 Cartella core  
3.5 Cartella data  
3.6 Cartella models  
3.7 Cartella repositories  
3.8 Cartella pages  
3.9 Cartella widgets  
3.10 Cartella services  
3.11 File principali  
3.12 Considerazioni finali

## 4. Modello dati
4.1 Obiettivo  
4.2 Principi del modello dati  
4.3 Entità principali  
4.4 Relazioni tra le entità  
4.5 Flusso dei dati applicativi  
4.6 Evoluzione del modello dati  
4.7 Considerazioni finali

## 5. Database PostgreSQL
5.1 Obiettivo  
5.2 Architettura del database  
5.3 Tabelle principali  
5.4 Relazioni e vincoli  
5.5 Integrità dei dati  
5.6 Prestazioni  
5.7 Sicurezza  
5.8 Evoluzione futura  
5.9 Considerazioni finali

## 6. Repository Layer
6.1 Obiettivo  
6.2 Architettura del Repository Layer  
6.3 Repository implementati  
6.4 Flusso delle operazioni  
6.5 Gestione degli errori  
6.6 Vantaggi dell'architettura  
6.7 Evoluzione futura  
6.8 Considerazioni finali

## 7. Interfaccia Utente
7.1 Obiettivo  
7.2 Architettura dell'interfaccia  
7.3 Navigazione  
7.4 Pagine principali  
7.5 Widget principali  
7.6 Gestione dello stato  
7.7 Principi di progettazione  
7.8 Evoluzione futura  
7.9 Considerazioni finali

## 8. Motore Agronomico
8.1 Obiettivo  
8.2 Architettura del Motore Agronomico  
8.3 Componenti principali  
8.4 Flusso delle elaborazioni  
8.5 Validazione  
8.6 Vantaggi dell'architettura  
8.7 Evoluzione futura  
8.8 Considerazioni finali

## 9. Test e Qualità del Software
9.1 Obiettivo  
9.2 Strategia di test  
9.3 Flutter Analyze  
9.4 Test automatici  
9.5 Qualità del codice  
9.6 Gestione delle regressioni  
9.7 Evoluzione futura  
9.8 Considerazioni finali

## 10. Evoluzione del Progetto
10.1 Visione generale  
10.2 Principi evolutivi  
10.3 Aree di sviluppo  
10.4 Scalabilità dell'architettura  
10.5 Integrazioni future  
10.6 Roadmap di alto livello  
10.7 Considerazioni finali

---

# Prefazione

Il presente Manuale Tecnico e Architetturale costituisce il documento di riferimento per la progettazione software di **Orto Smart**.

Il suo obiettivo è descrivere in modo organico l'architettura dell'applicazione, le principali scelte progettuali e l'organizzazione dei componenti che ne costituiscono il funzionamento.

Il manuale è stato redatto con l'intento di documentare non solo lo stato attuale del progetto, ma anche i principi architetturali che ne guideranno l'evoluzione futura, mantenendo una chiara distinzione tra la struttura del sistema, il processo di sviluppo e la pianificazione delle attività.

La documentazione è organizzata in capitoli tematici, ciascuno dedicato a uno specifico livello dell'architettura software, con l'obiettivo di facilitare la consultazione, la manutenzione e l'evoluzione del progetto nel tempo.

Il presente documento costituisce il riferimento tecnico ufficiale di Orto Smart e viene aggiornato in occasione delle principali evoluzioni dell'architettura dell'applicazione.

---

# 1. Scopo del documento

## 1.1 Finalità

Il presente Manuale Tecnico costituisce il documento di riferimento per l'architettura software del progetto **Orto Smart**.

Il suo scopo è descrivere in modo sistematico la struttura dell'applicazione, le tecnologie impiegate, l'organizzazione del codice, il modello dati, i principali componenti software e le scelte progettuali adottate durante lo sviluppo.

Il documento rappresenta il riferimento tecnico ufficiale del progetto e deve essere mantenuto costantemente allineato all'evoluzione del codice sorgente.

---

## 1.2 Destinatari

Il manuale è destinato principalmente a:

- sviluppatori coinvolti nel progetto;
- futuri collaboratori;
- manutentori dell'applicazione;
- chiunque abbia la necessità di comprendere l'architettura e il funzionamento interno di Orto Smart.

Non costituisce un manuale d'uso dell'applicazione, ma un documento tecnico dedicato agli aspetti progettuali e implementativi.

---

## 1.3 Obiettivi

Gli obiettivi principali del Manuale Tecnico sono:

- documentare l'architettura software dell'applicazione;
- descrivere l'organizzazione del progetto e dei suoi componenti;
- illustrare il modello dati e la struttura del database;
- documentare le principali scelte architetturali;
- facilitare la manutenzione e l'evoluzione del software;
- fornire una base di riferimento per lo sviluppo delle future funzionalità.

---

## 1.4 Aggiornamento del documento

Il Manuale Tecnico è parte integrante del progetto Orto Smart.

Ogni modifica significativa dell'architettura, del database o dei principali componenti dell'applicazione deve essere accompagnata dal corrispondente aggiornamento del presente Manuale Tecnico.

Mantenere il Manuale Tecnico sincronizzato con il codice sorgente garantisce la coerenza della documentazione e facilita la manutenzione del progetto nel lungo periodo.

# 2. Architettura del sistema

## 2.1 Obiettivi dell'architettura

L'architettura di **Orto Smart** è stata progettata per realizzare un'applicazione robusta, modulare, facilmente estendibile e capace di accompagnare l'evoluzione del progetto nel lungo periodo.

Fin dalle prime fasi di sviluppo è stato adottato un approccio orientato alla separazione delle responsabilità (*Separation of Concerns*), organizzando il software in componenti indipendenti e ben definiti. Ogni componente svolge un ruolo specifico e comunica con gli altri attraverso interfacce chiare, riducendo le dipendenze e semplificando la manutenzione del codice.

Questa impostazione consente di introdurre nuove funzionalità, correggere eventuali problemi e migliorare le prestazioni senza dover modificare l'intera struttura dell'applicazione.

Gli obiettivi principali dell'architettura sono:

- separare l'interfaccia utente dalla logica applicativa;
- isolare l'accesso ai dati mediante il **Repository Layer**;
- mantenere il Motore Agronomico indipendente dal database e dall'interfaccia utente;
- favorire il riutilizzo dei componenti software;
- semplificare le attività di test, manutenzione ed evoluzione del progetto;
- garantire un'architettura scalabile, adatta all'integrazione di nuove funzionalità.

L'architettura è stata inoltre progettata per supportare gli sviluppi previsti del progetto, tra cui l'espansione del Motore Agronomico, la gestione avanzata delle attività, l'integrazione con sistemi di irrigazione automatica, l'utilizzo dei dati meteorologici e l'introduzione di ulteriori moduli intelligenti.

L'obiettivo finale è disporre di una base software stabile, coerente e facilmente manutenibile, capace di sostenere la crescita di Orto Smart senza compromettere la qualità del codice e della documentazione.

## 2.2 Principi progettuali

L'architettura di Orto Smart si basa su un insieme di principi progettuali che guidano tutte le decisioni di sviluppo. L'obiettivo è realizzare un'applicazione ordinata, coerente e facilmente evolvibile, mantenendo una chiara separazione tra le diverse responsabilità del sistema.

Ogni nuova funzionalità viene progettata nel rispetto di questi principi, così da preservare nel tempo la qualità del codice e la semplicità dell'architettura.

I principi fondamentali adottati sono i seguenti.

### Modularità

L'applicazione è suddivisa in moduli indipendenti, ciascuno con una responsabilità ben definita. Questa organizzazione consente di sviluppare, modificare o sostituire un componente senza influire sul funzionamento degli altri.

### Separazione delle responsabilità

Ogni livello dell'applicazione svolge un compito specifico.

- L'interfaccia utente gestisce la presentazione dei dati e l'interazione con l'utente.
- I Repository si occupano esclusivamente dell'accesso ai dati.
- I modelli rappresentano le entità del dominio applicativo.
- Il Motore Agronomico implementa la logica decisionale e gli algoritmi di elaborazione.

Questa suddivisione riduce l'accoppiamento tra i componenti e rende il sistema più semplice da comprendere e mantenere.

### Riutilizzo del codice

Le funzionalità comuni vengono implementate una sola volta e rese disponibili ai diversi moduli dell'applicazione. Questo approccio riduce la duplicazione del codice e facilita la manutenzione.

### Testabilità

L'architettura è progettata per consentire il test dei singoli componenti in modo indipendente. La separazione tra logica applicativa, accesso ai dati e interfaccia utente permette di verificare il comportamento di ciascun modulo senza dipendere dagli altri.

### Scalabilità

La struttura dell'applicazione è predisposta per accogliere nuove funzionalità senza richiedere modifiche sostanziali all'architettura esistente. Nuovi moduli potranno essere integrati mantenendo la stessa organizzazione del progetto.

### Manutenibilità

Il codice è organizzato in modo chiaro e coerente, favorendo interventi di manutenzione rapidi e riducendo il rischio di introdurre errori durante l'evoluzione del software.

### Efficienza

Le scelte architetturali sono orientate a un utilizzo efficiente delle risorse, con particolare attenzione all'organizzazione del database, alla riduzione delle duplicazioni e all'ottimizzazione delle comunicazioni tra applicazione e backend.

L'adozione sistematica di questi principi costituisce la base dell'architettura di Orto Smart e garantisce una crescita ordinata del progetto nel tempo.

## 2.3 Architettura generale

L'architettura di Orto Smart è organizzata secondo una struttura a livelli (*layered architecture*), nella quale ogni componente svolge una funzione specifica e comunica esclusivamente con i livelli adiacenti.

Questa organizzazione consente di mantenere il codice ordinato, ridurre le dipendenze tra i moduli e facilitare l'introduzione di nuove funzionalità senza compromettere la stabilità dell'applicazione.

Lo schema seguente rappresenta la struttura logica dell'intero sistema.

```mermaid
flowchart TD

    U[Utente]

    UI[Flutter UI<br/>Pagine e Widget]

    REPO[Repository Layer]

    MODEL[Modelli Dati]

    ENGINE[Motore Agronomico]

    SUPA[Supabase]

    DB[(PostgreSQL)]

    U --> UI
    UI --> REPO

    REPO --> MODEL
    MODEL --> REPO

    REPO --> SUPA
    SUPA --> DB
    DB --> SUPA

    REPO --> ENGINE
    ENGINE --> REPO
```

**Figura 2.1 – Architettura logica di Orto Smart.**

L'utente interagisce esclusivamente con l'interfaccia sviluppata in Flutter. L'interfaccia non accede direttamente al database, ma utilizza il Repository Layer come punto di accesso ai dati.

Il Repository Layer gestisce tutte le comunicazioni con Supabase, trasforma i dati provenienti dal database in modelli Dart e li rende disponibili all'applicazione.

Il Motore Agronomico utilizza i dati forniti dai Repository per eseguire analisi, elaborazioni e suggerimenti, senza effettuare accessi diretti al database. Questa separazione rende il sistema più modulare, facilmente testabile e semplice da estendere.

L'intera architettura è progettata per mantenere indipendenti i diversi livelli dell'applicazione, garantendo un'elevata manutenibilità e una crescita ordinata del progetto.

## 2.4 Componenti dell'architettura

L'architettura di Orto Smart è composta da un insieme di componenti specializzati che collaborano tra loro per garantire una chiara separazione delle responsabilità e una gestione efficiente dell'applicazione.

Ogni componente svolge un ruolo ben definito e comunica con gli altri esclusivamente attraverso interfacce chiare, mantenendo basso l'accoppiamento e favorendo la manutenibilità del sistema.

### Flutter UI

L'interfaccia utente è sviluppata con Flutter e rappresenta il punto di contatto tra l'utente e l'applicazione.

Gestisce:

- pagine;
- widget;
- navigazione;
- acquisizione degli input dell'utente;
- presentazione dei dati.

La UI non contiene logica di business né accede direttamente al database.

---

### Repository Layer

Il Repository Layer costituisce il livello di accesso ai dati.

I Repository centralizzano tutte le operazioni di lettura e scrittura verso Supabase, trasformando i dati provenienti dal database in oggetti Dart utilizzabili dall'applicazione.

Questo livello isola completamente l'interfaccia utente dalla struttura del database. L'organizzazione e le responsabilità dei Repository sono approfondite nel Capitolo 6.

---

### Modelli dati

I modelli rappresentano le principali entità del dominio applicativo.

Ogni modello descrive la struttura dei dati e fornisce i metodi necessari per la conversione tra gli oggetti Dart e i record del database.

I modelli non contengono logica di business né effettuano interrogazioni dirette al database.

---

### Motore Agronomico

Il Motore Agronomico rappresenta il componente intelligente dell'applicazione.

Riceve i dati dai Repository, applica algoritmi e regole agronomiche e restituisce analisi, suggerimenti e risultati utilizzati dall'interfaccia utente.

La sua indipendenza dal database e dall'interfaccia utente ne facilita lo sviluppo, il collaudo e l'estensione con nuovi algoritmi. Il Motore Agronomico viene descritto in dettaglio nel Capitolo 8.

---

### Supabase

Supabase costituisce il backend dell'applicazione.

Fornisce il database PostgreSQL, i servizi di autenticazione, le API di accesso ai dati e i meccanismi di sicurezza necessari al corretto funzionamento del sistema.

L'applicazione comunica esclusivamente con Supabase attraverso il Repository Layer.

---

### PostgreSQL

PostgreSQL rappresenta il livello di persistenza dei dati.

Contiene tutte le informazioni gestite dall'applicazione, organizzate secondo un modello relazionale progettato per garantire integrità, efficienza ed espandibilità.

Il database costituisce la fonte autorevole di tutti i dati utilizzati da Orto Smart. La struttura del database e il modello dati vengono approfonditi nei Capitoli 4 e 5.

---

L'interazione coordinata di questi componenti consente di mantenere un'architettura ordinata, modulare e facilmente evolvibile, rendendo possibile l'introduzione di nuove funzionalità senza alterare la struttura generale dell'applicazione.

## 2.5 Flusso dei dati

Il flusso dei dati all'interno di Orto Smart segue un percorso ben definito, progettato per mantenere separate le responsabilità dei diversi livelli dell'applicazione.

Ogni richiesta dell'utente attraversa una serie di componenti specializzati che elaborano i dati e restituiscono il risultato all'interfaccia. Nessun componente accede direttamente a livelli che non rientrano nelle proprie responsabilità, garantendo così un'architettura ordinata e facilmente manutenibile.

Il diagramma seguente rappresenta il flusso logico delle informazioni.

```mermaid
sequenceDiagram
    actor U as Utente

    participant UI as Flutter UI
    participant R as Repository Layer
    participant S as Supabase
    participant DB as PostgreSQL
    participant E as Motore Agronomico

    U->>UI: Interazione
    UI->>R: Richiesta dati
    R->>S: Query
    S->>DB: Accesso ai dati
    DB-->>S: Risultato
    S-->>R: Dati

    R->>E: Elaborazione (se necessaria)
    E-->>R: Risultato

    R-->>UI: Modelli dati
    UI-->>U: Aggiornamento dell'interfaccia
```

**Figura 2.2 – Flusso dei dati tra i principali componenti dell'applicazione.**

Il processo può essere riassunto nelle seguenti fasi:

1. L'utente esegue un'azione attraverso l'interfaccia dell'applicazione.
2. La Flutter UI inoltra la richiesta al Repository competente.
3. Il Repository comunica con Supabase per leggere o aggiornare i dati.
4. Supabase interroga il database PostgreSQL ed esegue l'operazione richiesta.
5. I dati vengono restituiti al Repository.
6. Se necessario, il Repository richiede un'elaborazione al Motore Agronomico.
7. Il Repository restituisce all'interfaccia i modelli dati già pronti per l'utilizzo.
8. La Flutter UI aggiorna la schermata mostrando il risultato all'utente.

Questo flusso garantisce che ogni componente operi esclusivamente nell'ambito delle proprie responsabilità, migliorando la leggibilità del codice, facilitando i test e riducendo il rischio di effetti collaterali durante l'evoluzione del progetto.

## 2.6 Vantaggi dell'architettura

L'architettura adottata da Orto Smart offre numerosi vantaggi sia durante lo sviluppo sia nelle future attività di manutenzione ed evoluzione del progetto.

La suddivisione dell'applicazione in componenti indipendenti consente di mantenere il codice ordinato, ridurre la complessità e semplificare l'introduzione di nuove funzionalità.

I principali vantaggi sono i seguenti.

### Manutenibilità

La chiara separazione delle responsabilità permette di intervenire su un singolo componente senza influenzare il funzionamento degli altri, riducendo il rischio di introdurre errori durante le modifiche.

### Scalabilità

L'architettura è predisposta per accogliere nuovi moduli e nuove funzionalità mantenendo invariata la struttura generale dell'applicazione. Questo consente una crescita progressiva del progetto senza dover riprogettare il software.

### Testabilità

Ogni componente può essere verificato in modo indipendente. La separazione tra interfaccia utente, accesso ai dati e logica applicativa facilita la realizzazione di test automatici e rende più semplice individuare eventuali anomalie.

### Riutilizzo del codice

La suddivisione in moduli favorisce il riutilizzo delle componenti comuni, riducendo la duplicazione del codice e migliorandone la qualità complessiva.

### Affidabilità

L'isolamento delle responsabilità limita gli effetti delle modifiche e rende il comportamento dell'applicazione più prevedibile e stabile nel tempo.

### Evoluzione del progetto

L'architettura costituisce una base solida per l'introduzione di nuove funzionalità, come l'espansione del Motore Agronomico, la gestione avanzata delle attività, l'integrazione con sistemi di irrigazione automatica e l'utilizzo di ulteriori sorgenti dati.

Nel complesso, l'architettura di Orto Smart è stata progettata per garantire un equilibrio tra semplicità, flessibilità ed estendibilità, accompagnando l'evoluzione del progetto senza compromettere la qualità del software.

## 2.7 Evoluzione futura

L'architettura di Orto Smart è stata progettata con una visione di lungo periodo, prevedendo fin dalle prime fasi di sviluppo la possibilità di integrare nuove funzionalità senza modificare la struttura portante dell'applicazione.

L'organizzazione modulare del sistema consente di ampliare progressivamente le capacità dell'applicazione, mantenendo invariati i principi progettuali descritti nei paragrafi precedenti.

Tra le principali aree di evoluzione previste rientrano:

- ampliamento del Motore Agronomico con nuovi algoritmi di analisi e supporto decisionale;
- gestione avanzata delle attività e pianificazione automatica dei lavori nell'orto;
- integrazione con sistemi di irrigazione automatica basati su Raspberry Pi ed ESP32;
- utilizzo dei dati meteorologici per supportare irrigazione, pianificazione e analisi agronomiche;
- introduzione di moduli dedicati a raccolti, fertilizzazioni, trattamenti, costi, ricavi e statistiche;
- sviluppo di funzionalità intelligenti basate sull'analisi storica dei dati raccolti.

L'architettura potrà inoltre essere estesa con nuovi servizi e componenti senza compromettere il funzionamento dei moduli esistenti, preservando la compatibilità con le versioni precedenti dell'applicazione.

L'obiettivo è accompagnare la crescita di Orto Smart mantenendo nel tempo un software affidabile, facilmente manutenibile e in grado di adattarsi alle future esigenze del progetto.

# 3. Struttura del progetto

## 3.1 Obiettivo

La struttura del progetto rappresenta l'organizzazione fisica del codice sorgente di Orto Smart.

L'obiettivo principale è mantenere una chiara separazione tra i diversi componenti dell'applicazione, facilitando lo sviluppo, la manutenzione e l'introduzione di nuove funzionalità.

L'organizzazione delle cartelle riflette direttamente l'architettura descritta nel capitolo precedente: ogni directory è dedicata a una specifica responsabilità e contiene esclusivamente gli elementi necessari allo svolgimento del proprio compito.

Questa impostazione rende il progetto più semplice da comprendere, favorisce il riutilizzo del codice e permette di individuare rapidamente il punto in cui intervenire durante lo sviluppo.

La struttura è progettata per evolvere insieme all'applicazione, mantenendo nel tempo ordine, coerenza e scalabilità.

## 3.2 Organizzazione generale

Il codice sorgente principale dell'applicazione è contenuto nella cartella `lib/`, che rappresenta il cuore del progetto Flutter.

Al suo interno il codice è organizzato in directory specializzate, ciascuna dedicata a un preciso livello dell'architettura software.

La seguente struttura rappresenta l'organizzazione attuale del progetto.

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

Ogni directory svolge una responsabilità specifica e contribuisce a mantenere il progetto ordinato e facilmente manutenibile.

Nei paragrafi successivi verrà descritto il ruolo di ciascun componente della struttura.

## 3.3 Struttura delle directory principali

La cartella `lib/` contiene tutti i componenti software sviluppati per Orto Smart. La sua organizzazione segue i principi architetturali descritti nel Capitolo 2, mantenendo una netta separazione tra interfaccia utente, logica applicativa, gestione dei dati e configurazione.

Ogni directory è dedicata a uno specifico ambito funzionale, riducendo l'accoppiamento tra i componenti e facilitando la manutenzione del codice.

Le principali directory del progetto sono:

| Directory | Responsabilità |
|-----------|----------------|
| `core/` | Configurazioni e componenti condivisi dell'applicazione. |
| `data/` | Modelli del dominio e Repository per l'accesso ai dati. |
| `pages/` | Schermate dell'applicazione e gestione della navigazione. |
| `widgets/` | Componenti grafici riutilizzabili. |
| `services/` | Servizi applicativi e logica di supporto. |
| `main.dart` | Punto di ingresso dell'applicazione Flutter. |
| `supabase_config.dart` | Parametri di configurazione della connessione a Supabase. |

Questa organizzazione consente di individuare rapidamente il punto in cui intervenire durante lo sviluppo, mantenendo il codice ordinato e facilmente comprensibile anche all'aumentare delle funzionalità dell'applicazione.

## 3.4 Cartella `core`

La directory `core/` contiene gli elementi condivisi dall'intera applicazione che non appartengono a uno specifico modulo funzionale.

Attualmente ospita la sottocartella `config/`, nella quale sono raccolte le configurazioni generali del progetto.

Lo scopo della directory `core` è centralizzare le risorse comuni, evitando duplicazioni e mantenendo uniforme il comportamento dell'applicazione.

Con l'evoluzione di Orto Smart questa directory potrà includere ulteriori componenti condivisi, come costanti, utility, estensioni, temi grafici, servizi comuni e classi di supporto utilizzate trasversalmente dai diversi moduli del progetto.

## 3.5 Cartella `data`

La directory `data/` raccoglie tutti i componenti dedicati alla gestione dei dati dell'applicazione.

Questo livello rappresenta il collegamento tra il database Supabase e la logica applicativa, occupandosi della rappresentazione delle entità del dominio e dell'accesso ai dati.

La cartella è suddivisa in due aree principali:

- `models/`, che contiene le classi che rappresentano le entità dell'applicazione;
- `repositories/`, che implementa l'accesso ai dati e le comunicazioni con Supabase.

Questa organizzazione mantiene separata la struttura dei dati dalla logica di accesso al database, semplificando la manutenzione e rendendo il codice più leggibile e facilmente estendibile.

## 3.6 Cartella `models`

La directory `models/` contiene le classi che rappresentano il modello dati di Orto Smart.

Ogni modello descrive una specifica entità del dominio applicativo, come orti, aiuole, colture, stagioni, piantagioni e gli altri elementi gestiti dal sistema.

Le classi presenti in questa cartella hanno il compito di:

- rappresentare i dati provenienti dal database;
- convertire i record di Supabase in oggetti Dart;
- convertire gli oggetti Dart nei dati da salvare nel database;
- garantire una struttura dati coerente all'interno dell'applicazione.

I modelli non contengono logica di business né effettuano operazioni di accesso al database. La loro responsabilità è esclusivamente quella di rappresentare le informazioni in modo strutturato.

Questa separazione consente di mantenere il codice più ordinato, facilita il riutilizzo delle classi e rende più semplice l'introduzione di nuove entità durante l'evoluzione del progetto.

## 3.7 Cartella `repositories`

La directory `repositories/` implementa il Repository Layer descritto nel Capitolo 2.

Ogni Repository è responsabile dell'accesso ai dati relativi a una specifica entità dell'applicazione.

Le principali responsabilità dei Repository sono:

- eseguire interrogazioni verso Supabase;
- inserire, aggiornare ed eliminare i dati;
- convertire i risultati delle query nei modelli Dart;
- gestire eventuali errori di comunicazione con il backend;
- fornire all'applicazione un'interfaccia uniforme per l'accesso ai dati.

Grazie a questa architettura, le pagine dell'applicazione non comunicano mai direttamente con il database, ma utilizzano esclusivamente i Repository.

Questo approccio riduce l'accoppiamento tra i componenti, facilita i test e permette di modificare il backend senza influire sul resto dell'applicazione.

## 3.8 Cartella `pages`

La directory `pages/` contiene tutte le schermate dell'applicazione, ovvero i componenti che costituiscono l'interfaccia utente di Orto Smart.

Ogni pagina rappresenta una specifica funzionalità del sistema, come la dashboard, la gestione dell'orto, delle aiuole, delle colture, dell'irrigazione o delle attività.

Le pagine hanno il compito di:

- gestire l'interazione con l'utente;
- acquisire gli input;
- richiedere i dati ai Repository;
- visualizzare le informazioni ricevute;
- aggiornare l'interfaccia in base allo stato dell'applicazione.

Le pagine non implementano direttamente la logica di business né effettuano accessi al database. Ogni operazione sui dati viene delegata ai Repository o ai servizi dedicati, mantenendo una chiara separazione delle responsabilità.

## 3.9 Cartella `widgets`

La directory `widgets/` raccoglie i componenti grafici riutilizzabili dell'applicazione.

Un widget rappresenta una porzione dell'interfaccia che può essere utilizzata in più pagine senza duplicare il codice. Questo approccio favorisce la modularità dell'interfaccia utente e rende più semplice la manutenzione del progetto.

Tra gli esempi di widget riutilizzabili rientrano:

- schede informative;
- pulsanti personalizzati;
- componenti grafici;
- layout delle aiuole;
- elementi di navigazione;
- finestre di dialogo.

L'utilizzo di widget dedicati consente di mantenere le pagine più semplici e leggibili, migliorando l'organizzazione del codice e facilitando eventuali modifiche future.

## 3.10 Cartella `services`

La directory `services/` contiene i servizi applicativi che implementano funzionalità trasversali utilizzate da più componenti del sistema.

I servizi permettono di concentrare in un unico punto operazioni che non appartengono né all'interfaccia utente né ai Repository, mantenendo il codice ordinato e facilmente riutilizzabile.

Con l'evoluzione del progetto questa cartella ospiterà, ad esempio:

- servizi di supporto al Motore Agronomico;
- gestione delle notifiche;
- elaborazioni automatiche;
- integrazione con sistemi esterni;
- servizi meteorologici;
- gestione dell'irrigazione automatica;
- funzionalità condivise tra più moduli.

La presenza di una directory dedicata ai servizi contribuisce a mantenere l'architettura modulare e facilita l'introduzione di nuove funzionalità senza modificare i componenti esistenti.

## 3.11 File principali

Oltre alle directory principali, il progetto comprende alcuni file fondamentali per l'avvio e la configurazione dell'applicazione.

### `main.dart`

È il punto di ingresso dell'applicazione Flutter.

Ha il compito di inizializzare l'ambiente di esecuzione, configurare i servizi necessari all'avvio e creare l'applicazione principale.

### `supabase_config.dart`

Contiene i parametri di configurazione utilizzati per la connessione al backend Supabase.

La separazione della configurazione dal resto del codice migliora l'organizzazione del progetto e semplifica la gestione delle impostazioni dell'applicazione.

## 3.12 Considerazioni finali

La struttura del progetto Orto Smart è stata progettata per garantire ordine, modularità e facilità di manutenzione durante l'intero ciclo di vita dell'applicazione.

La suddivisione del codice in directory specializzate riflette direttamente l'architettura descritta nel Capitolo 2 e consente di mantenere chiaramente separate le responsabilità dei diversi componenti del sistema.

Questa organizzazione permette di:

- individuare rapidamente il codice relativo a una specifica funzionalità;
- semplificare lo sviluppo di nuovi moduli;
- ridurre il rischio di introdurre errori durante le modifiche;
- favorire il riutilizzo del codice;
- rendere il progetto facilmente comprensibile anche a nuovi sviluppatori.

La struttura attuale rappresenta una base solida ma sufficientemente flessibile per accompagnare la crescita di Orto Smart. Con l'introduzione di nuove funzionalità potranno essere aggiunte ulteriori directory e componenti, mantenendo comunque i principi di modularità, separazione delle responsabilità e scalabilità che caratterizzano l'intera architettura del progetto.

Nel Capitolo 4 verrà descritto il modello dati dell'applicazione, analizzando le principali entità gestite da Orto Smart e le relazioni che le collegano all'interno del database.

# 4. Modello dati

## 4.1 Obiettivo

Il modello dati rappresenta il fondamento dell'intera applicazione Orto Smart.

Il suo scopo è descrivere in modo strutturato tutte le informazioni gestite dal sistema, definendo le principali entità del dominio applicativo e le relazioni esistenti tra esse.

Una progettazione accurata del modello dati garantisce coerenza, integrità e semplicità di evoluzione del software, consentendo di introdurre nuove funzionalità senza compromettere la compatibilità con la struttura esistente.

Il modello dati costituisce inoltre il collegamento tra il database PostgreSQL, i Repository e il Motore Agronomico, assicurando una rappresentazione uniforme delle informazioni all'interno dell'applicazione.

## 4.2 Principi del modello dati

Il modello dati di Orto Smart è stato progettato seguendo gli stessi principi che guidano l'intera architettura software dell'applicazione: semplicità, modularità, coerenza ed estendibilità.

L'obiettivo è rappresentare in modo fedele gli elementi che caratterizzano la gestione di un orto, mantenendo una struttura sufficientemente flessibile da supportare l'evoluzione del progetto nel tempo.

La progettazione del modello dati si basa sui seguenti principi fondamentali.

### Coerenza

Ogni informazione viene rappresentata una sola volta, evitando duplicazioni e mantenendo un'unica fonte autorevole per ciascun dato.

### Integrità

Le relazioni tra le entità sono definite in modo da garantire la consistenza dei dati e prevenire la presenza di informazioni incoerenti o non valide.

### Modularità

Ogni entità descrive uno specifico concetto del dominio applicativo e può evolvere indipendentemente dalle altre, riducendo l'accoppiamento tra i diversi componenti del sistema.

### Estendibilità

Il modello dati è stato progettato per consentire l'introduzione di nuove entità e nuove relazioni senza richiedere modifiche sostanziali alla struttura esistente.

### Efficienza

Particolare attenzione è dedicata all'ottimizzazione dello spazio di archiviazione e alla riduzione delle ridondanze, mantenendo il database semplice, performante e facilmente manutenibile.

Questi principi costituiscono la base su cui vengono progettate tutte le tabelle del database e le corrispondenti classi del modello dati utilizzate dall'applicazione.

## 4.3 Entità principali

Il modello dati di Orto Smart è composto da un insieme di entità che rappresentano gli elementi fondamentali per la gestione dell'orto e delle attività agronomiche.

Ogni entità descrive uno specifico concetto del dominio applicativo ed è rappresentata sia all'interno del database PostgreSQL sia tramite una corrispondente classe Dart utilizzata dall'applicazione.

Le sezioni seguenti descrivono le principali entità attualmente implementate nel sistema, evidenziandone il ruolo all'interno del dominio applicativo e le relazioni con gli altri componenti del modello dati.

### Garden

Rappresenta un orto gestito dall'applicazione.

Contiene le informazioni generali dell'orto, come il nome, la posizione e le impostazioni principali. Costituisce l'entità principale alla quale sono collegate tutte le aiuole.

### Bed

Rappresenta una singola aiuola.

Ogni aiuola appartiene a un orto ed è caratterizzata da proprietà geometriche, come lunghezza e larghezza, oltre che dalle informazioni necessarie alla gestione delle coltivazioni.

### Crop

Rappresenta una coltura.

Contiene le informazioni agronomiche utilizzate dal sistema, come il nome della coltura e i parametri necessari al Motore Agronomico per elaborare suggerimenti e verifiche.

### Season

Rappresenta una stagione agricola.

Permette di organizzare le coltivazioni in periodi distinti, mantenendo separata la cronologia delle diverse annate.

### Planting

Rappresenta una coltivazione presente in un'aiuola.

Ogni piantagione è associata a una specifica coltura, appartiene a una stagione e contiene tutte le informazioni necessarie alla gestione dello spazio occupato e delle caratteristiche della coltivazione.

L'insieme di queste entità costituisce il nucleo del modello dati attualmente utilizzato dall'applicazione e rappresenta la base su cui verranno sviluppate le future funzionalità di Orto Smart.

## 4.4 Relazioni tra le entità

Le entità descritte nel paragrafo precedente non sono indipendenti, ma sono collegate tra loro attraverso relazioni che rappresentano la struttura logica dell'applicazione.

Questo insieme di relazioni rappresenta il nucleo del modello dati, evitando duplicazioni e garantendo l'integrità dei dati.

Lo schema seguente rappresenta le principali relazioni attualmente implementate.

```text
Garden
   │
   └───────< Bed
                │
                └───────< Planting >─────── Crop
                               │
                               ▼
                            Season
```

Le relazioni principali sono le seguenti.

- Un **Garden** può contenere una o più **Bed**.
- Ogni **Bed** appartiene a un solo **Garden**.
- Una **Bed** può contenere più **Planting**.
- Ogni **Planting** appartiene a una sola **Bed**.
- Ogni **Planting** è associata a una sola **Crop**.
- Una **Crop** può essere utilizzata in molte **Planting**.
- Ogni **Planting** appartiene a una sola **Season**.
- Una **Season** può comprendere numerose **Planting**.

Questa organizzazione rappresenta il nucleo del modello dati attualmente utilizzato da Orto Smart e costituisce la base per l'integrazione delle future funzionalità, come la gestione dell'irrigazione, delle attività, delle rotazioni colturali e delle analisi agronomiche.


## 4.5 Flusso dei dati applicativi

Le entità del modello dati costituiscono il punto di collegamento tra il database, la logica applicativa e l'interfaccia utente.

Ogni informazione segue un percorso ben definito che garantisce coerenza, separazione delle responsabilità e facilità di manutenzione.

Il flusso generale dei dati può essere riassunto come segue.

```text
PostgreSQL
      │
      ▼
Supabase
      │
      ▼
Repository
      │
      ▼
Modelli Dart
      │
      ▼
Motore Agronomico
      │
      ▼
Flutter UI
```

Durante la lettura dei dati, i Repository recuperano le informazioni dal database tramite Supabase e le convertono nei corrispondenti modelli Dart.

Il Motore Agronomico utilizza tali modelli per effettuare elaborazioni, verifiche e suggerimenti, senza accedere direttamente al database.

L'interfaccia utente riceve infine dati già elaborati e pronti per la visualizzazione, mantenendo completamente separata la logica di presentazione dalla logica applicativa.

Questa organizzazione rende il sistema facilmente testabile, favorisce il riutilizzo del codice e consente di introdurre nuove funzionalità senza modificare il flusso generale delle informazioni.

## 4.6 Evoluzione del modello dati

Il modello dati di Orto Smart è stato progettato con un approccio incrementale, prevedendo fin dalle prime fasi di sviluppo la possibilità di estendere il sistema senza modificare la struttura fondamentale delle entità già implementate.

Le entità attualmente presenti costituiscono il nucleo operativo dell'applicazione e supportano la gestione degli orti, delle aiuole, delle colture, delle stagioni e delle piantagioni.

Con l'evoluzione del progetto il modello dati verrà progressivamente ampliato per supportare nuove funzionalità, tra cui:

- gestione delle attività agronomiche;
- registrazione degli eventi di irrigazione;
- gestione delle fertilizzazioni e dei trattamenti;
- monitoraggio dei raccolti;
- gestione dei costi e dei ricavi;
- statistiche e analisi storiche;
- integrazione con il Motore Agronomico per supportare decisioni sempre più avanzate.

L'espansione del modello dati seguirà gli stessi principi descritti nei paragrafi precedenti, privilegiando la modularità, la normalizzazione delle informazioni e la compatibilità con le strutture già esistenti.

Questo approccio consentirà di mantenere il database ordinato, facilmente manutenibile e pronto ad accogliere le future evoluzioni del progetto senza richiedere modifiche sostanziali alle entità già consolidate.

## 4.7 Considerazioni finali

Il modello dati di Orto Smart rappresenta la base sulla quale si sviluppano tutte le funzionalità dell'applicazione.

La suddivisione delle informazioni in entità ben definite, unite da relazioni coerenti e gestite attraverso i Repository, garantisce un'elevata manutenibilità del codice e consente di estendere il sistema senza compromettere le funzionalità esistenti.

L'adozione di un modello dati modulare permette inoltre di integrare progressivamente nuove caratteristiche, mantenendo separati il livello di persistenza, la logica applicativa e l'interfaccia utente.

Nei Capitoli 5, 6, 7 e 8 verranno approfonditi rispettivamente il database PostgreSQL, il Repository Layer, l'Interfaccia Utente e il Motore Agronomico, descrivendo il ruolo e il funzionamento di ciascun componente all'interno dell'architettura di Orto Smart.

# 5. Database PostgreSQL

## 5.1 Obiettivo

Il database PostgreSQL costituisce il livello di persistenza dei dati di Orto Smart ed è responsabile della memorizzazione permanente di tutte le informazioni gestite dall'applicazione.

L'obiettivo del database è garantire affidabilità, integrità e prestazioni, assicurando che ogni dato venga archiviato in modo coerente e possa essere recuperato in maniera efficiente dalle componenti software.

Orto Smart utilizza Supabase come piattaforma Backend-as-a-Service (BaaS), sfruttando PostgreSQL come database relazionale e i servizi messi a disposizione dalla piattaforma per l'autenticazione, la sicurezza e l'accesso ai dati.

La progettazione del database segue gli stessi principi adottati per il modello dati e per l'architettura generale dell'applicazione, privilegiando la modularità, la normalizzazione delle informazioni e la facilità di evoluzione nel tempo.

Nei paragrafi successivi verranno descritte la struttura del database, le tabelle principali, le relazioni, i vincoli di integrità e le scelte progettuali adottate durante lo sviluppo.

## 5.2 Architettura del database

Il database di Orto Smart è basato su PostgreSQL ed è ospitato sulla piattaforma Supabase, che fornisce un ambiente completo per la gestione del backend dell'applicazione.

L'architettura del database è stata progettata secondo il modello relazionale, nel quale le informazioni sono organizzate in tabelle collegate tra loro mediante chiavi primarie e chiavi esterne.

Questa struttura consente di rappresentare in modo efficiente le relazioni tra le diverse entità dell'applicazione, garantendo coerenza dei dati e riducendo le ridondanze.

L'accesso al database avviene esclusivamente attraverso i Repository dell'applicazione, che utilizzano il client Supabase per eseguire le operazioni di lettura e scrittura dei dati.

L'applicazione non accede mai direttamente alle tabelle del database, ma opera sempre tramite il livello di astrazione fornito dai Repository, mantenendo separati il livello di persistenza, la logica applicativa e l'interfaccia utente.

L'architettura adottata facilita inoltre la manutenzione del sistema, semplifica l'introduzione di nuove funzionalità e consente di evolvere il database mantenendo la compatibilità con il codice esistente.

Lo schema generale dell'architettura è rappresentato nel diagramma seguente.

```text
Flutter UI
      │
      ▼
Repository
      │
      ▼
Supabase Client
      │
      ▼
Supabase Platform
      │
      ▼
PostgreSQL Database
```

## 5.3 Tabelle principali

Il database di Orto Smart è organizzato in un insieme di tabelle relazionate tra loro, ciascuna dedicata alla gestione di uno specifico ambito funzionale dell'applicazione.

Ogni tabella rappresenta una delle entità descritte nel Capitolo 4 e contiene le informazioni necessarie alla gestione dell'orto e delle funzionalità del sistema.

Le principali tabelle attualmente implementate nel database sono le seguenti.

### gardens

Contiene le informazioni generali relative agli orti gestiti dall'applicazione.

Ogni record identifica un orto e rappresenta il punto di partenza della struttura dati.

### beds

Contiene le aiuole appartenenti a ciascun orto.

Ogni aiuola è collegata a un record della tabella `gardens` mediante una chiave esterna.

### crops

Contiene l'anagrafica delle colture.

Per ogni coltura vengono memorizzate le informazioni agronomiche utilizzate dal Motore Agronomico e dall'interfaccia utente.

### seasons

Contiene le stagioni agricole.

Questa tabella permette di separare le coltivazioni appartenenti a differenti annate, mantenendo disponibile lo storico delle attività.

### plantings

Contiene tutte le coltivazioni presenti nelle aiuole.

Ogni record è associato a una specifica aiuola, a una coltura e a una stagione agricola, rappresentando l'elemento centrale della gestione operativa dell'applicazione.

Le tabelle sopra descritte costituiscono il nucleo del database attualmente utilizzato da Orto Smart e rappresentano la base per tutte le elaborazioni effettuate dal Motore Agronomico.

## 5.4 Relazioni e vincoli

Le tabelle del database sono collegate tra loro mediante chiavi primarie (Primary Key) e chiavi esterne (Foreign Key), che garantiscono la coerenza delle informazioni e l'integrità referenziale del sistema.

Ogni tabella possiede una chiave primaria univoca che identifica in modo inequivocabile ciascun record.

Le relazioni tra le tabelle vengono realizzate attraverso chiavi esterne, che consentono di collegare logicamente le diverse entità del database senza duplicare le informazioni.

L'utilizzo dei vincoli di integrità permette di impedire l'inserimento di dati non coerenti, assicurando che ogni riferimento tra le tabelle sia sempre valido.

Tra i principali vincoli adottati nel database si possono citare:

- identificazione univoca dei record mediante chiavi primarie;
- collegamento tra le tabelle attraverso chiavi esterne;
- obbligatorietà dei campi essenziali mediante vincoli `NOT NULL`;
- mantenimento della coerenza referenziale tra le entità.

Questa struttura garantisce un'elevata affidabilità del database e costituisce la base per il corretto funzionamento dell'applicazione e del Motore Agronomico.

## 5.5 Integrità dei dati

L'integrità dei dati rappresenta uno degli aspetti fondamentali dell'architettura del database di Orto Smart.

L'obiettivo è garantire che tutte le informazioni archiviate siano corrette, coerenti e affidabili durante l'intero ciclo di vita dell'applicazione.

Per raggiungere questo risultato vengono adottati diversi meccanismi di controllo, implementati sia a livello di database sia a livello applicativo.

A livello di database, PostgreSQL utilizza vincoli di integrità, chiavi primarie, chiavi esterne e restrizioni sui campi per impedire l'inserimento di dati non validi o incoerenti.

A livello applicativo, ulteriori verifiche vengono eseguite dai Repository e dal Motore Agronomico prima del salvataggio delle informazioni, riducendo il rischio di errori e mantenendo elevata la qualità dei dati.

Questa doppia strategia di validazione consente di garantire la consistenza delle informazioni, preservando l'affidabilità del sistema anche durante la sua evoluzione.

## 5.6 Prestazioni e ottimizzazione

La progettazione del database di Orto Smart tiene conto non solo della correttezza dei dati, ma anche delle prestazioni e dell'efficienza nell'utilizzo delle risorse.

Fin dalle prime fasi di sviluppo è stata adottata una struttura dati normalizzata, con l'obiettivo di ridurre le ridondanze, semplificare la manutenzione e ottimizzare lo spazio di archiviazione.

Le principali strategie adottate comprendono:

- utilizzo di chiavi primarie per l'identificazione univoca dei record;
- impiego di chiavi esterne per evitare duplicazioni delle informazioni;
- organizzazione delle tabelle secondo criteri di normalizzazione;
- separazione tra dati operativi e logica applicativa;
- utilizzo di query mirate attraverso i Repository dell'applicazione.

Particolare attenzione è inoltre dedicata alla crescita futura del progetto. Le nuove funzionalità verranno progettate privilegiando il riutilizzo delle strutture esistenti e limitando la memorizzazione di dati ridondanti.

Questo approccio consente di mantenere il database efficiente, facilmente scalabile e compatibile con le esigenze operative dell'applicazione nel lungo periodo.

## 5.7 Sicurezza

La sicurezza del database rappresenta un elemento fondamentale dell'architettura di Orto Smart ed è affidata alle funzionalità offerte da Supabase e PostgreSQL.

L'accesso ai dati avviene esclusivamente tramite il client Supabase utilizzato dall'applicazione, evitando connessioni dirette al database da parte dell'interfaccia utente.

Per garantire la protezione delle informazioni archiviate vengono utilizzati i seguenti meccanismi:

- autenticazione degli utenti tramite Supabase Authentication;
- controllo degli accessi mediante Row Level Security (RLS);
- definizione di policy di accesso per le tabelle del database;
- utilizzo di connessioni protette tra applicazione e backend.

La Row Level Security (RLS) costituisce uno dei principali strumenti di protezione del database. Essa consente di definire regole che stabiliscono quali record possono essere letti, modificati o eliminati da ciascun utente, impedendo accessi non autorizzati ai dati.

La configurazione delle policy RLS viene gestita direttamente all'interno del database PostgreSQL tramite Supabase, mantenendo separata la logica di sicurezza dal codice dell'applicazione.

L'adozione di questi meccanismi consente di realizzare un sistema sicuro, affidabile e facilmente estendibile anche con l'introduzione di nuove funzionalità.

## 5.8 Evoluzione del database

Il database di Orto Smart è stato progettato seguendo un approccio incrementale, in modo da poter accompagnare la crescita dell'applicazione senza richiedere modifiche sostanziali alla struttura esistente.

Le tabelle attualmente implementate costituiscono il nucleo operativo del sistema e sono sufficienti a supportare le funzionalità oggi disponibili.

Con l'evoluzione del progetto verranno progressivamente introdotte nuove tabelle e nuove relazioni per supportare funzionalità aggiuntive, tra cui:

- gestione completa delle attività agricole;
- registrazione degli eventi di irrigazione;
- gestione delle fertilizzazioni e dei trattamenti;
- monitoraggio dei raccolti;
- analisi statistiche e reportistica;
- gestione economica dell'orto;
- integrazione con nuovi moduli del Motore Agronomico.

Ogni evoluzione del database verrà progettata mantenendo la compatibilità con le strutture esistenti, limitando le modifiche invasive e preservando l'integrità dei dati già memorizzati.

Questo approccio consente di far evolvere il progetto in modo ordinato, mantenendo elevata la qualità dell'architettura e semplificando le future attività di manutenzione.

## 5.9 Considerazioni finali

Il database PostgreSQL rappresenta il componente centrale per la gestione delle informazioni di Orto Smart e costituisce il punto di riferimento per tutte le funzionalità dell'applicazione.

La progettazione relazionale, l'utilizzo di Supabase, i meccanismi di sicurezza e l'organizzazione modulare delle tabelle garantiscono un'infrastruttura affidabile, scalabile e facilmente estendibile.

L'adozione di criteri di normalizzazione, l'impiego dei Repository come livello di accesso ai dati e l'integrazione con il Motore Agronomico consentono di mantenere separati i diversi livelli dell'applicazione, facilitandone l'evoluzione e la manutenzione.

Nei Capitoli 6, 7 e 8 verranno approfonditi rispettivamente il Repository Layer, l'Interfaccia Utente e il Motore Agronomico, completando la descrizione dell'architettura software di Orto Smart.

# 6. Repository Layer

## 6.1 Obiettivo

Il Repository Layer rappresenta il livello dell'architettura software incaricato della gestione dell'accesso ai dati dell'applicazione.

Il suo compito principale è isolare tutta la logica di comunicazione con il database dal resto del sistema, fornendo un'interfaccia semplice e uniforme per la lettura, l'inserimento, l'aggiornamento e l'eliminazione delle informazioni.

Grazie a questa separazione, l'interfaccia utente, il Motore Agronomico e gli altri componenti dell'applicazione non devono conoscere i dettagli implementativi del database o delle API di Supabase, ma interagiscono esclusivamente con i Repository.

Questo approccio rende il codice più modulare, facilmente manutenibile e maggiormente riutilizzabile, oltre a semplificare le attività di test e l'evoluzione futura dell'applicazione.

Nei paragrafi successivi verranno descritti l'architettura del Repository Layer, i Repository attualmente implementati e il loro ruolo nel funzionamento di Orto Smart.

## 6.2 Architettura del Repository Layer

Il Repository Layer costituisce il livello di collegamento tra la logica applicativa e il database PostgreSQL gestito tramite Supabase.

Ogni Repository è responsabile della gestione di una specifica entità del sistema e incapsula tutte le operazioni di accesso ai dati, evitando che il resto dell'applicazione interagisca direttamente con il database.

L'architettura adottata segue il principio della separazione delle responsabilità (Separation of Concerns), assegnando a ciascun livello un compito ben definito:

- **Interfaccia utente**: gestisce la presentazione delle informazioni e l'interazione con l'utente;
- **Repository**: si occupano delle operazioni di lettura e scrittura dei dati;
- **Modelli**: rappresentano le entità dell'applicazione;
- **Supabase**: gestisce la comunicazione con il database PostgreSQL;
- **Database**: garantisce la persistenza e l'integrità delle informazioni.

Questa organizzazione rende il codice più ordinato, facilita la manutenzione e consente di modificare o estendere il sistema senza impattare sugli altri livelli dell'applicazione.

```text
┌─────────────────────────────┐
│        Flutter UI           │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│      Repository Layer       │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       Modelli Dart          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│     Supabase Flutter SDK    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│    PostgreSQL Database      │
└─────────────────────────────┘
```

## 6.3 Repository implementati

Orto Smart adotta un'architettura basata su Repository specializzati, ciascuno dedicato alla gestione di una specifica entità del sistema.

Ogni Repository incapsula le operazioni di accesso ai dati, fornendo metodi dedicati per interrogare, inserire, aggiornare ed eliminare le informazioni archiviate nel database.

Attualmente il progetto comprende i seguenti Repository principali:

### GardenRepository

Gestisce le informazioni relative all'orto principale, consentendo il recupero dei dati generali e delle configurazioni dell'installazione.

### BedRepository

Si occupa della gestione delle aiuole, permettendo il recupero dell'elenco delle aiuole attive e delle relative informazioni strutturali.

### CropRepository

Gestisce il catalogo delle colture disponibili, rendendo accessibili le caratteristiche agronomiche utilizzate dall'applicazione e dal Motore Agronomico.

### SeasonRepository

Amministra le stagioni colturali, consentendo di individuare la stagione attiva e di organizzare cronologicamente le attività dell'orto.

### PlantingRepository

PlantingRepository gestisce le piantagioni dell'applicazione. Si occupa del loro inserimento, aggiornamento e recupero, mantenendole ordinate secondo la posizione occupata nelle singole aiuole.

L'organizzazione in Repository indipendenti rende il codice più leggibile, favorisce il riutilizzo delle funzionalità e semplifica l'introduzione di nuovi moduli senza modificare le componenti già esistenti.

## 6.4 Flusso delle operazioni

Il Repository Layer svolge il ruolo di intermediario tra l'interfaccia utente e il database, garantendo che tutte le operazioni di accesso ai dati seguano un flusso ben definito.

Quando l'utente esegue un'azione nell'applicazione, la richiesta viene elaborata dall'interfaccia utente e inoltrata al Repository competente. Quest'ultimo comunica con Supabase, che esegue le operazioni sul database PostgreSQL e restituisce i risultati al Repository.

I dati ricevuti vengono convertiti nei corrispondenti modelli dell'applicazione e resi disponibili ai componenti che li hanno richiesti, mantenendo separati i diversi livelli dell'architettura.

Questo flusso consente di centralizzare la logica di accesso ai dati, ridurre le duplicazioni di codice e garantire un comportamento uniforme in tutta l'applicazione.

```text
Utente
   │
   ▼
Flutter UI
   │
   ▼
Repository
   │
   ▼
Supabase
   │
   ▼
PostgreSQL
   │
   ▼
Supabase
   │
   ▼
Repository
   │
   ▼
Flutter UI
   │
   ▼
Utente
```

## 6.5 Gestione degli errori

La gestione degli errori rappresenta un aspetto fondamentale del Repository Layer, poiché consente di intercettare eventuali anomalie durante le operazioni di accesso al database e di impedirne la propagazione incontrollata all'interno dell'applicazione.

Gli errori possono derivare da diverse cause, tra cui problemi di connessione, dati non validi, violazioni dei vincoli del database o malfunzionamenti dei servizi esterni.

I Repository hanno il compito di rilevare tali situazioni, gestirle in modo appropriato e restituire ai livelli superiori informazioni utili per consentire all'applicazione di reagire correttamente.

Quando possibile, gli errori vengono trasformati in messaggi comprensibili per l'utente, evitando l'esposizione di dettagli tecnici interni che potrebbero risultare poco chiari o compromettere la sicurezza del sistema.

Questa strategia contribuisce a migliorare l'affidabilità dell'applicazione, semplifica le attività di debug durante lo sviluppo e favorisce una migliore esperienza d'uso.

## 6.6 Vantaggi dell'architettura

L'adozione del Repository Layer offre numerosi vantaggi dal punto di vista progettuale e contribuisce a rendere Orto Smart un'applicazione modulare, scalabile e facilmente manutenibile.

Tra i principali benefici dell'architettura adottata si evidenziano:

- separazione tra la logica di accesso ai dati e l'interfaccia utente;
- riduzione della duplicazione del codice;
- maggiore leggibilità e organizzazione del progetto;
- facilità di manutenzione e aggiornamento dei singoli componenti;
- possibilità di eseguire test in modo più semplice e mirato;
- elevata scalabilità grazie all'aggiunta di nuovi Repository senza modificare quelli esistenti.

Questa organizzazione consente inoltre di concentrare tutta la logica di comunicazione con il database in un unico livello dell'applicazione, semplificando l'introduzione di nuove funzionalità e l'eventuale evoluzione delle tecnologie utilizzate.

L'architettura a Repository rappresenta quindi una scelta progettuale che favorisce la qualità del software e garantisce una solida base per la crescita futura del progetto Orto Smart.

## 6.7 Evoluzione futura

Il Repository Layer è stato progettato con una struttura modulare che ne facilita l'estensione in parallelo alla crescita dell'applicazione.

Con l'introduzione di nuove funzionalità verranno sviluppati Repository dedicati ai rispettivi domini applicativi, mantenendo invariati i principi architetturali adottati fin dalle prime fasi del progetto.

Tra le future evoluzioni previste rientrano Repository per la gestione delle attività agricole, dell'irrigazione, dei raccolti, delle fertilizzazioni, dei trattamenti, delle statistiche e dei moduli economici.

L'introduzione di nuovi Repository consentirà di mantenere il codice organizzato, limitando l'impatto delle modifiche sulle componenti già esistenti e favorendo il riutilizzo della logica di accesso ai dati.

Questo approccio garantisce la continuità dell'architettura software e permette al progetto di evolvere in modo ordinato, mantenendo elevati standard di qualità e manutenibilità.

## 6.8 Considerazioni finali

Il Repository Layer costituisce uno degli elementi fondamentali dell'architettura software di Orto Smart, rappresentando il punto di collegamento tra la logica applicativa e il database.

La separazione tra interfaccia utente, Repository, modelli e database consente di realizzare un sistema modulare, facilmente estendibile e semplice da mantenere nel tempo.

L'adozione di Repository specializzati favorisce inoltre il riutilizzo del codice, la riduzione delle duplicazioni e una gestione uniforme delle operazioni di accesso ai dati.

Questa architettura fornisce una base solida per l'evoluzione futura del progetto, consentendo l'integrazione di nuove funzionalità senza compromettere l'organizzazione e la qualità del software.

Nel Capitolo 7 – Interfaccia Utente verranno descritte l'organizzazione delle pagine, la navigazione e i principali componenti grafici dell'applicazione.

# 7. Interfaccia Utente

## 7.1 Obiettivo

L'Interfaccia Utente rappresenta il livello dell'applicazione con cui l'utilizzatore interagisce durante tutte le attività di gestione dell'orto.

Il suo obiettivo è fornire un'esperienza d'uso semplice, intuitiva e coerente, consentendo di accedere rapidamente alle funzionalità offerte da Orto Smart senza richiedere conoscenze tecniche.

L'interfaccia è progettata per adattarsi sia all'utilizzo su computer durante le attività di pianificazione, sia all'impiego su dispositivi mobili direttamente nell'orto, dove velocità, chiarezza e semplicità operativa assumono un ruolo fondamentale.

L'organizzazione delle pagine, dei componenti grafici e dei flussi di navigazione segue gli stessi principi architetturali adottati per il resto dell'applicazione, mantenendo separata la logica di presentazione dalla logica di business e dall'accesso ai dati.

Nei paragrafi successivi verranno descritti l'architettura dell'interfaccia, la struttura della navigazione, le principali pagine dell'applicazione e i criteri progettuali adottati durante lo sviluppo.

## 7.2 Architettura dell'interfaccia

L'interfaccia utente di Orto Smart è sviluppata con Flutter e adotta un'architettura basata su widget, nella quale ogni elemento grafico rappresenta un componente autonomo e riutilizzabile.

L'organizzazione dell'interfaccia segue una struttura gerarchica che separa chiaramente la presentazione delle informazioni dalla logica applicativa e dall'accesso ai dati.

Le pagine dell'applicazione richiedono le informazioni ai Repository, ricevono i modelli elaborati dal livello applicativo e si occupano esclusivamente della loro visualizzazione e dell'interazione con l'utente.

Questa separazione delle responsabilità rende l'interfaccia più semplice da mantenere, facilita il riutilizzo dei componenti grafici e consente di introdurre nuove funzionalità senza modificare la struttura generale dell'applicazione.

L'architettura dell'interfaccia può essere rappresentata dal seguente schema.

```text
Utente
    │
    ▼
Flutter UI
    │
    ▼
Pagine (Pages)
    │
    ▼
Widget
    │
    ▼
Repository
    │
    ▼
Supabase
    │
    ▼
PostgreSQL
```

Ogni livello svolge un ruolo specifico e comunica esclusivamente con il livello immediatamente adiacente, contribuendo a mantenere il codice ordinato, modulare e facilmente estendibile.

## 7.3 Navigazione dell'applicazione

La navigazione di Orto Smart è stata progettata per consentire all'utente di accedere rapidamente alle principali funzionalità dell'applicazione, riducendo il numero di passaggi necessari per svolgere le attività più frequenti.

L'organizzazione delle pagine segue una struttura semplice e intuitiva, nella quale ogni sezione dell'applicazione è dedicata a uno specifico ambito funzionale.

La schermata principale rappresenta il punto di accesso alle diverse aree operative dell'applicazione, permettendo all'utente di spostarsi rapidamente tra le varie funzionalità senza perdere il contesto di lavoro.

La navigazione è stata progettata tenendo conto sia dell'utilizzo su computer sia dell'impiego su dispositivi mobili, privilegiando percorsi brevi, pulsanti facilmente raggiungibili e una disposizione coerente degli elementi dell'interfaccia.

Lo schema generale della navigazione può essere rappresentato come segue.

```text
Home
 │
 ├── Dashboard
 ├── Orto
 │      │
 │      └── Aiuola
 │              │
 │              ├── Dettaglio colture
 │              └── Aggiungi coltura
 │
 ├── Irrigazione
 ├── Attività
 └── Impostazioni
```

Questa struttura consente di mantenere la navigazione chiara e facilmente estendibile, rendendo possibile l'introduzione di nuove sezioni senza modificare l'organizzazione generale dell'applicazione.

## 7.4 Pagine principali dell'applicazione

L'interfaccia di Orto Smart è organizzata in un insieme di pagine, ciascuna dedicata a uno specifico ambito funzionale della gestione dell'orto.

Ogni pagina è progettata per svolgere un compito ben definito e collabora con le altre attraverso un flusso di navigazione semplice e coerente, mantenendo separata la logica di presentazione dalla logica applicativa.

Le principali pagine attualmente implementate sono le seguenti.

### HomePage

Costituisce la schermata principale dell'applicazione e rappresenta il punto di accesso a tutte le funzionalità di Orto Smart.

Da questa pagina l'utente può raggiungere rapidamente le diverse sezioni operative dell'applicazione.

### GardenPage

Visualizza l'orto e l'elenco delle aiuole disponibili.

Da questa schermata è possibile selezionare una specifica aiuola per visualizzarne il contenuto oppure avviare l'inserimento di una nuova coltura.

### BedPage

Mostra il dettaglio di una singola aiuola.

Visualizza le colture presenti, la rappresentazione grafica della loro disposizione, le informazioni principali e le operazioni disponibili per la gestione dell'aiuola.

### AddPlantingPage

Consente l'inserimento di una nuova coltivazione all'interno di un'aiuola.

Durante questa fase vengono raccolte le informazioni necessarie alla registrazione della coltura e all'elaborazione da parte del Motore Agronomico.

### Pagine future

Con l'evoluzione del progetto verranno introdotte nuove pagine dedicate, tra le quali:

- gestione delle attività agricole;
- irrigazione;
- raccolti;
- fertilizzazioni e trattamenti;
- statistiche;
- gestione economica;
- impostazioni avanzate.

L'organizzazione modulare dell'interfaccia consente di aggiungere nuove pagine mantenendo invariata la struttura generale della navigazione e garantendo uniformità nell'esperienza d'uso.

## 7.5 Widget principali

L'interfaccia di Orto Smart è costruita utilizzando widget Flutter, ciascuno dedicato a una specifica funzione dell'applicazione.

L'adozione di componenti riutilizzabili consente di mantenere il codice ordinato, ridurre le duplicazioni e garantire uniformità grafica e funzionale tra le diverse pagine.

I principali widget attualmente utilizzati sono i seguenti.

### Widget di navigazione

Gestiscono lo spostamento tra le diverse sezioni dell'applicazione, consentendo all'utente di accedere rapidamente alle funzionalità disponibili.

### Widget di visualizzazione

Sono utilizzati per mostrare le informazioni relative all'orto, alle aiuole e alle coltivazioni, organizzando i dati in modo chiaro e facilmente consultabile.

### Widget di inserimento dati

Consentono all'utente di registrare nuove informazioni attraverso moduli e campi di input, effettuando controlli preliminari sulla correttezza dei dati inseriti.

### BedLayoutWidget

Rappresenta uno dei principali widget personalizzati dell'applicazione.

Visualizza la disposizione grafica delle colture all'interno dell'aiuola, mostrando la posizione occupata da ciascuna coltivazione e fornendo una rappresentazione immediata dello spazio disponibile.

Questo componente costituisce uno degli elementi distintivi di Orto Smart e rappresenta il collegamento tra i dati gestiti dal Motore Agronomico e la loro visualizzazione grafica.

### Widget futuri

Con l'evoluzione del progetto verranno introdotti nuovi widget dedicati alla gestione dell'irrigazione, delle attività agricole, delle statistiche, dei grafici e delle funzionalità avanzate del Motore Agronomico.

L'utilizzo di widget indipendenti e riutilizzabili consente di mantenere l'interfaccia coerente, facilitando la manutenzione e l'estensione dell'applicazione nel tempo.

## 7.6 Gestione dello stato

La gestione dello stato dell'applicazione ha il compito di mantenere sincronizzate le informazioni visualizzate dall'interfaccia utente con i dati presenti nel database.

Ogni pagina recupera i dati necessari tramite i Repository e aggiorna automaticamente la visualizzazione quando vengono effettuate operazioni di inserimento, modifica o eliminazione.

L'obiettivo è garantire che l'utente visualizzi sempre informazioni coerenti e aggiornate, evitando duplicazioni dei dati e mantenendo separata la logica di presentazione dalla logica applicativa.

L'attuale architettura dell'applicazione adotta un approccio semplice e modulare, adeguato alle funzionalità oggi implementate e facilmente estendibile con la crescita del progetto.

Il flusso di aggiornamento dello stato può essere rappresentato come segue.

```text
Utente
   │
   ▼
Interazione con la UI
   │
   ▼
Repository
   │
   ▼
Supabase
   │
   ▼
PostgreSQL
   │
   ▼
Repository
   │
   ▼
Aggiornamento della UI
```

Questa organizzazione consente di mantenere il comportamento dell'applicazione prevedibile, semplifica le attività di manutenzione e costituisce una solida base per l'introduzione di future tecniche di gestione dello stato, qualora la complessità del progetto lo rendesse necessario.

## 7.7 Principi di progettazione dell'interfaccia

L'interfaccia utente di Orto Smart è stata progettata seguendo criteri di semplicità, chiarezza e praticità operativa, con l'obiettivo di supportare l'utente durante tutte le attività di gestione dell'orto.

Le principali scelte progettuali adottate sono le seguenti.

### Semplicità

Ogni schermata mostra esclusivamente le informazioni necessarie allo svolgimento dell'attività corrente, riducendo gli elementi superflui e favorendo una consultazione immediata.

### Coerenza

L'organizzazione delle pagine, dei pulsanti e dei componenti grafici mantiene uno stile uniforme in tutta l'applicazione, facilitando l'apprendimento e l'utilizzo delle diverse funzionalità.

### Modularità

L'interfaccia è composta da pagine e widget indipendenti, facilmente riutilizzabili e progettati per evolvere senza influire sul resto dell'applicazione.

### Utilizzo sul campo

Orto Smart è stato progettato non solo per l'utilizzo da computer durante la pianificazione, ma anche per l'impiego direttamente nell'orto tramite dispositivi mobili.

Per questo motivo l'interfaccia privilegia operazioni rapide, pulsanti facilmente selezionabili e una navigazione essenziale, consentendo all'utente di registrare informazioni anche durante le attività operative.

### Evoluzione continua

L'interfaccia è stata progettata per poter accogliere nuove funzionalità mantenendo coerenza grafica e semplicità d'utilizzo, evitando modifiche sostanziali alla struttura generale dell'applicazione.

L'insieme di questi principi costituisce una delle basi progettuali di Orto Smart e guiderà lo sviluppo delle future versioni dell'interfaccia.

## 7.8 Evoluzione futura

L'interfaccia utente di Orto Smart è stata progettata secondo un'architettura modulare che ne consente l'evoluzione progressiva senza richiedere modifiche sostanziali ai componenti già esistenti.

Con l'ampliamento delle funzionalità dell'applicazione verranno introdotte nuove pagine, nuovi widget e ulteriori strumenti di supporto alle attività agronomiche, mantenendo invariati i principi di semplicità, coerenza e facilità d'uso.

Tra le principali evoluzioni previste rientrano:

- gestione completa delle attività agricole;
- pianificazione e controllo dell'irrigazione;
- visualizzazione avanzata dei suggerimenti del Motore Agronomico;
- statistiche e grafici sull'andamento dell'orto;
- gestione economica e monitoraggio dei costi;
- notifiche e promemoria delle attività;
- ottimizzazione dell'interfaccia per smartphone e tablet.

Ogni nuova funzionalità verrà integrata mantenendo uno stile grafico uniforme e un'esperienza d'uso coerente con le versioni precedenti, garantendo continuità operativa agli utenti dell'applicazione.

## 7.9 Considerazioni finali

L'Interfaccia Utente costituisce il punto di contatto tra l'utente e tutte le funzionalità offerte da Orto Smart.

La progettazione basata su Flutter, l'organizzazione modulare delle pagine, l'utilizzo di widget riutilizzabili e la separazione tra presentazione, logica applicativa e accesso ai dati consentono di realizzare un'interfaccia moderna, estendibile e facilmente manutenibile.

Le scelte progettuali adottate permettono all'applicazione di essere utilizzata efficacemente sia durante la pianificazione delle attività sia direttamente nell'orto, offrendo un'esperienza d'uso semplice, coerente e orientata alle esigenze operative dell'utilizzatore.

L'architettura dell'interfaccia rappresenta quindi una base solida per l'evoluzione futura del progetto e si integra pienamente con il Modello Dati, il Database PostgreSQL, il Repository Layer e il Motore Agronomico descritti nei capitoli precedenti.

Nel Capitolo 8 verrà approfondita l'architettura del Motore Agronomico, descrivendone i principi di funzionamento, i principali componenti e il ruolo svolto nell'elaborazione delle informazioni agronomiche e dei suggerimenti forniti all'utente.

# 8. Motore Agronomico

## 8.1 Obiettivo

Il Motore Agronomico rappresenta il componente dell'applicazione incaricato di elaborare le informazioni relative alle coltivazioni e di supportare l'utente nelle decisioni riguardanti la gestione dell'orto.

A differenza dei componenti dedicati esclusivamente alla memorizzazione o alla visualizzazione dei dati, il Motore Agronomico analizza le informazioni disponibili, applica regole agronomiche e produce risultati utili per la pianificazione delle attività.

L'obiettivo del motore è trasformare i dati raccolti dall'applicazione in informazioni di supporto decisionale, mantenendo separata la logica agronomica dal resto del sistema.

L'architettura del Motore Agronomico è stata progettata secondo criteri di modularità, estendibilità e riutilizzabilità, consentendo l'introduzione di nuovi algoritmi senza modificare le componenti già esistenti.

Attualmente il Motore Agronomico comprende moduli dedicati alla validazione delle coltivazioni, all'analisi degli spazi disponibili, alla generazione di suggerimenti automatici e alla verifica delle consociazioni tra colture.

Nei paragrafi successivi verranno descritti l'architettura del motore, i principali componenti implementati, il flusso delle elaborazioni e le future evoluzioni previste.

## 8.2 Architettura del Motore Agronomico

Il Motore Agronomico di Orto Smart è costituito da un insieme di componenti indipendenti, ciascuno specializzato nello svolgimento di uno specifico compito.

Ogni modulo implementa una particolare logica agronomica e collabora con gli altri attraverso un'architettura modulare che favorisce il riutilizzo del codice, la semplicità di manutenzione e l'estendibilità del sistema.

Il motore non accede direttamente al database, ma opera esclusivamente sui modelli ricevuti dal Repository Layer, mantenendo separata la logica agronomica dalla persistenza dei dati.

L'architettura attualmente implementata può essere rappresentata dal seguente schema.

```text
Repository Layer
        │
        ▼
 Modelli e risultati di analisi
        │
        ▼
RecommendationPipeline
        │
        ├── SuggestionEngine
        ├── RotationEngine
        ├── AssociationEngine
        ├── SpaceScoreCalculator
        ├── DecisionEngine
        │       └── DecisionWeights
        └── RecommendationMapper
        │
        ▼
Risultati e raccomandazioni
        │
        ▼
Flutter UI
```

La `RecommendationPipeline` costituisce il componente di orchestrazione del processo di raccomandazione.

La pipeline coordina i motori e i componenti specializzati, raccoglie le valutazioni agronomiche, demanda al `DecisionEngine` l'interpretazione dei risultati e utilizza `RecommendationMapper` per produrre il modello destinato all'interfaccia utente.

Il `DecisionEngine` applica criteri ponderati mediante `DecisionWeights`, mantenendo separata la configurazione dei pesi dalla logica decisionale.

I singoli componenti rimangono specializzati e indipendenti, consentendo l'evoluzione del Motore Agronomico senza concentrare responsabilità differenti in un unico modulo.

## 8.3 Componenti principali

Il Motore Agronomico di Orto Smart è composto da componenti specializzati che collaborano attraverso la `RecommendationPipeline`.

Ogni componente mantiene una responsabilità specifica, evitando di concentrare nello stesso modulo generazione dei candidati, valutazioni agronomiche, decisione finale e trasformazione dei risultati.

### PlantingValidator

Il `PlantingValidator` verifica la validità dei dati relativi alle coltivazioni prima che vengano utilizzati o registrati dall'applicazione.

Il componente contribuisce a impedire l'elaborazione di informazioni incomplete o incoerenti.

### FreeSpaceEngine

Il `FreeSpaceEngine` analizza gli spazi occupati e disponibili all'interno delle aiuole.

I risultati prodotti vengono adattati mediante `FreeSpaceAdapter` e utilizzati dal processo di generazione delle raccomandazioni.

### SuggestionEngine

Il `SuggestionEngine` costituisce il componente specializzato nella generazione dei candidati iniziali.

Riceve gli spazi disponibili e le colture analizzabili e produce i `SuggestionCandidate` che verranno successivamente sottoposti alle valutazioni agronomiche.

Il componente non determina autonomamente la raccomandazione finale.

### RotationEngine

Il `RotationEngine` valuta il candidato in relazione alla storia delle coltivazioni presenti nell'aiuola e produce un risultato utilizzato nella valutazione agronomica complessiva.

### AssociationEngine

L'`AssociationEngine` valuta la compatibilità del candidato con le coltivazioni già presenti, utilizzando le informazioni sulle associazioni e sulle colture coinvolte.

### SpaceScoreCalculator

Lo `SpaceScoreCalculator` calcola il punteggio relativo all'utilizzo dello spazio confrontando la lunghezza richiesta dal candidato con quella disponibile.

### CandidateAgronomicEvaluation

Il modello `CandidateAgronomicEvaluation` raccoglie in una struttura unica:

- candidato;
- punteggio relativo allo spazio;
- risultato della rotazione;
- risultato delle associazioni.

Questa struttura costituisce l'ingresso del processo decisionale.

### DecisionEngine

Il `DecisionEngine` interpreta le valutazioni agronomiche già prodotte dai componenti specializzati.

Non genera i candidati e non richiama direttamente gli altri motori.

Per ciascun candidato calcola un punteggio finale ponderato utilizzando:

- punteggio spazio;
- punteggio rotazione;
- punteggio associazione.

Le raccomandazioni vengono successivamente ordinate in modo decrescente in base al punteggio ottenuto.

### DecisionWeights

`DecisionWeights` contiene la configurazione dei pesi utilizzati dal `DecisionEngine`.

La configurazione standard attualmente adottata è:

- spazio: 40%;
- rotazione: 30%;
- consociazione: 30%.

La classe consente anche l'utilizzo di configurazioni personalizzate e verifica che:

- nessun peso sia negativo;
- la somma complessiva dei pesi sia pari a `1.0`.

Il `DecisionEngine` rifiuta configurazioni non valide mediante `ArgumentError`.

### FamilyNeedsEngine

Il `FamilyNeedsEngine` è il componente responsabile della valutazione del fabbisogno familiare associato alle diverse colture.

La sua responsabilità è limitata alla rappresentazione della priorità familiare attribuita a una coltura e rimane separata dal calcolo del punteggio agronomico prodotto dal `DecisionEngine`.

Il modello di ingresso utilizza `FamilyCropNeed`, mentre la priorità è rappresentata mediante l'enumerazione `FamilyNeedPriority`.

Sono attualmente previsti quattro livelli:

- `none`;
- `low`;
- `medium`;
- `high`.

Il motore converte tali priorità nei seguenti valori numerici:

- `none` → `0.0`;
- `low` → `0.3`;
- `medium` → `0.6`;
- `high` → `1.0`.

Il risultato viene restituito mediante `FamilyRecommendation`.

Il campo `cropId` utilizza il tipo `String`, coerentemente con il modello degli identificativi delle colture utilizzato nel resto dell'architettura.

Oltre al valore numerico, il motore produce una motivazione testuale comprensibile associata alla valutazione.

Il `FamilyNeedsEngine` mantiene l'ordine degli elementi ricevuti in ingresso.

Nella versione attuale il motore non determina:

- il numero di piante da coltivare;
- il numero di semine o trapianti;
- la distribuzione temporale delle colture;
- la successione dei lotti;
- la compatibilità agronomica complessiva.

Queste responsabilità restano separate.

In particolare, la pianificazione quantitativa e temporale delle colture sarà affidata al futuro `SuccessionPlanningEngine`.

A partire dalla Sessione S012, il `FamilyNeedsEngine` è integrato nella `RecommendationPipeline`.

Le esigenze familiari non costituiscono un quarto criterio ponderato del `DecisionEngine` e non modificano direttamente il punteggio agronomico.

La configurazione `DecisionWeights` rimane pertanto basata esclusivamente su:

- spazio: 40%;
- rotazione: 30%;
- consociazione: 30%.

La priorità familiare viene utilizzata dalla `RecommendationPipeline` come criterio gerarchico di ordinamento successivo alla fascia agronomica.

L'ordine applicato è:

    1. Fascia agronomica
    2. Priorità familiare
    3. Punteggio agronomico

Questa gerarchia garantisce che una coltura maggiormente richiesta dalla famiglia possa essere favorita rispetto a un'altra soltanto quando entrambe appartengono alla stessa fascia agronomica.

Una priorità familiare elevata non può pertanto rendere preferibile una coltura appartenente a una fascia agronomica inferiore.

La separazione architetturale attuale può essere rappresentata come:

    Motori agronomici
            ↓
    DecisionEngine
            ↓
    punteggio agronomico
            ↓
    RecommendationPipeline
            ↓
    classificazione della fascia agronomica
            ↓
    FamilyNeedsEngine
            ↓
    priorità familiare
            ↓
    ordinamento gerarchico finale

Il futuro `SuccessionPlanningEngine` rimane separato da questo processo e sarà responsabile della pianificazione quantitativa e temporale delle coltivazioni, comprese quantità, lotti e distribuzione delle produzioni nel tempo.

### RecommendationMapper

Il `RecommendationMapper` converte la valutazione agronomica e la relativa raccomandazione nel modello utilizzato dall'interfaccia utente.

### RecommendationPipeline

La `RecommendationPipeline` orchestra l'intero processo di generazione delle raccomandazioni.

La pipeline non contiene regole agronomiche proprie, ma coordina i componenti specializzati, costruisce le valutazioni agronomiche, invoca il `DecisionEngine` e utilizza il `RecommendationMapper` per produrre il risultato destinato all'interfaccia.

A partire dalla Sessione S012, la pipeline integra anche le informazioni prodotte dal `FamilyNeedsEngine`.

Le esigenze familiari vengono fornite mediante il parametro opzionale `familyNeeds`.

Il `FamilyNeedsEngine` valuta tali esigenze e la pipeline associa la priorità familiare risultante alla relativa coltura mediante `cropId`.

La priorità familiare non modifica direttamente il punteggio calcolato dal `DecisionEngine`.

La `RecommendationPipeline` applica invece un ordinamento gerarchico basato su:

1. fascia agronomica;
2. priorità familiare;
3. punteggio agronomico.

La classificazione delle raccomandazioni nelle rispettive fasce agronomiche viene gestita internamente mediante `_ratingBand()`.

La fascia agronomica costituisce il criterio prioritario dell'ordinamento. La priorità familiare può quindi modificare l'ordine delle raccomandazioni soltanto all'interno della stessa fascia agronomica.

Il punteggio agronomico viene utilizzato come criterio successivo quando i criteri precedenti non determinano un ordine differente.

Questa struttura mantiene separati il giudizio agronomico e le esigenze familiari e impedisce che una priorità familiare elevata renda preferibile una raccomandazione appartenente a una fascia agronomica inferiore.

Il processo di ordinamento può essere sintetizzato come:

    Fascia agronomica
            ↓
    Priorità familiare
            ↓
    Punteggio agronomico
            ↓
    Raccomandazione finale

## 8.4 Flusso delle elaborazioni

Il Motore Agronomico elabora le informazioni seguendo un flusso logico nel quale ciascun componente interviene nel momento appropriato, utilizzando i risultati prodotti dai moduli precedenti.

L'elaborazione ha inizio quando l'utente inserisce una nuova coltivazione oppure richiede un'analisi dell'aiuola.

I dati vengono recuperati dal Repository Layer, convertiti nei modelli dell'applicazione e successivamente analizzati dai diversi componenti del Motore Agronomico.

Il seguente schema rappresenta un flusso logico di riferimento. In funzione dell'operazione richiesta, i singoli moduli possono essere utilizzati anche indipendentemente oppure in combinazioni differenti.

Il flusso generale delle elaborazioni può essere rappresentato come segue.

```text
Utente
   │
   ▼
Flutter UI
   │
   ▼
Repository Layer
   │
   ▼
BedAnalysisResult
   │
   ▼
FreeSpaceAdapter
   │
   ▼
SuggestionEngine
   │
   ▼
SuggestionCandidate
   │
   ├──────────────┬────────────────┐
   ▼              ▼                ▼
RotationEngine  AssociationEngine  SpaceScoreCalculator
   │              │                │
   └──────────────┴────────────────┘
                  │
                  ▼
      CandidateAgronomicEvaluation
                  │
                  ▼
            DecisionEngine
                  │
                  ▼
      PlantingRecommendation
                  │
                  ▼
       RecommendationMapper
                  │
                  ▼
          SuggestionResult
                  │
                  ▼
              Flutter UI
```

La `RecommendationPipeline` coordina questo flusso senza incorporare direttamente le regole agronomiche dei singoli componenti.

Gli spazi disponibili vengono convertiti tramite `FreeSpaceAdapter` nel formato utilizzato dal nucleo agronomico. Il `SuggestionEngine` genera quindi i candidati iniziali.

Per ogni candidato vengono prodotte separatamente la valutazione della rotazione, la valutazione delle associazioni e il punteggio relativo allo spazio. I risultati vengono raccolti in una `CandidateAgronomicEvaluation`.

Il `DecisionEngine` utilizza queste valutazioni per calcolare il punteggio finale ponderato secondo la configurazione definita da `DecisionWeights` e ordina le raccomandazioni in base al punteggio ottenuto.

Infine, `RecommendationMapper` converte ogni risultato nel formato utilizzato dall'applicazione e la pipeline restituisce il `SuggestionResult` destinato all'interfaccia utente.

La separazione tra generazione dei candidati, valutazioni agronomiche, decisione e mapping mantiene il sistema modulare e permette l'introduzione futura di ulteriori criteri senza concentrare responsabilità differenti nello stesso componente.

## 8.5 Validazione e controlli

Per garantire l'affidabilità delle elaborazioni, il Motore Agronomico esegue una serie di controlli prima di applicare le proprie regole.

La validazione dei dati rappresenta un passaggio fondamentale per evitare l'elaborazione di informazioni incomplete, incoerenti o non compatibili con il modello dell'applicazione.

Il principale componente dedicato a questa attività è il **PlantingValidator**, che verifica la correttezza dei dati relativi alle nuove coltivazioni prima che vengano utilizzati dagli altri moduli del motore.

Tra i controlli effettuati rientrano, ad esempio:

- la presenza delle informazioni obbligatorie;
- la coerenza dei valori numerici;
- la validità delle dimensioni e delle posizioni delle coltivazioni;
- il rispetto dei vincoli previsti dal modello dati.

L'esecuzione preventiva di questi controlli consente di ridurre la possibilità di errori durante le elaborazioni successive e garantisce che tutti i moduli del Motore Agronomico operino su dati consistenti.

L'approccio adottato favorisce inoltre una maggiore robustezza dell'applicazione, semplifica la manutenzione del codice e rende più agevole l'introduzione di nuove funzionalità senza compromettere l'affidabilità del sistema.

## 8.6 Vantaggi dell'architettura

L'architettura del Motore Agronomico è stata progettata per garantire modularità, affidabilità e facilità di evoluzione nel tempo.

La suddivisione della logica in componenti indipendenti consente a ciascun modulo di svolgere uno specifico compito senza introdurre dipendenze non necessarie con gli altri elementi del sistema.

Tra i principali vantaggi dell'architettura adottata si evidenziano:

- separazione tra logica agronomica, interfaccia utente e accesso ai dati;
- elevata modularità dei componenti;
- semplicità di manutenzione del codice;
- possibilità di riutilizzare gli stessi moduli in contesti differenti;
- facilità nell'introduzione di nuovi algoritmi agronomici;
- maggiore robustezza grazie alla validazione preventiva dei dati;
- architettura facilmente testabile mediante test automatici.

Queste caratteristiche consentono al progetto di evolvere progressivamente senza richiedere modifiche sostanziali ai componenti già sviluppati.

L'approccio modulare adottato permette inoltre di ampliare il Motore Agronomico con nuove funzionalità mantenendo elevata la qualità del codice e favorendo la manutenzione nel lungo periodo.

## 8.7 Evoluzione futura

L'architettura modulare del Motore Agronomico è stata progettata per consentire un'evoluzione progressiva delle funzionalità senza richiedere modifiche sostanziali ai componenti già implementati.

Le versioni future di Orto Smart prevedono l'introduzione di nuovi moduli dedicati all'analisi e al supporto delle decisioni agronomiche, ampliando progressivamente le capacità del sistema.

Tra le principali evoluzioni previste rientrano:

- evoluzione dell'analisi delle rotazioni colturali mediante criteri agronomici progressivamente più avanzati;
- pianificazione delle successioni delle colture;
- suggerimenti automatici basati sul calendario agronomico;
- supporto alla gestione dell'irrigazione, integrando le informazioni meteorologiche e lo stato delle coltivazioni;
- analisi dello storico delle colture per migliorare la pianificazione delle stagioni successive;
- integrazione di ulteriori regole agronomiche e nuove tipologie di controlli.

L'organizzazione adottata consente di aggiungere nuovi moduli mantenendo inalterata l'architettura generale del Motore Agronomico, favorendo la crescita del progetto e la qualità del software nel lungo periodo.

## 8.8 Considerazioni finali

Il Motore Agronomico rappresenta il nucleo logico di Orto Smart e costituisce l'elemento che distingue l'applicazione da un semplice sistema di registrazione delle informazioni.

Attraverso un'architettura modulare e indipendente, il motore trasforma i dati raccolti durante la gestione dell'orto in elaborazioni e suggerimenti utili a supportare le decisioni dell'utente.

La separazione tra logica agronomica, accesso ai dati e interfaccia utente garantisce un'elevata manutenibilità del software e consente l'introduzione di nuove funzionalità senza compromettere i componenti esistenti.

L'architettura adottata rappresenta una base solida per lo sviluppo futuro del progetto, permettendo di integrare progressivamente nuovi algoritmi e nuovi strumenti di supporto alla gestione dell'orto.

Nel Capitolo 9 verranno approfonditi gli aspetti relativi ai test del software e alle strategie adottate per garantire la qualità, l'affidabilità e la stabilità dell'applicazione.

# 9. Test e Qualità del Software

## 9.1 Obiettivo

La qualità del software rappresenta uno degli obiettivi fondamentali dello sviluppo di Orto Smart.

Per garantire affidabilità, stabilità e facilità di manutenzione, il progetto adotta un processo di verifica continuo durante tutte le fasi di sviluppo, affiancando l'implementazione del codice a controlli automatici e test funzionali.

L'obiettivo non è solamente individuare eventuali errori, ma prevenire l'introduzione di regressioni, mantenere elevata la qualità del codice e assicurare che ogni nuova funzionalità si integri correttamente con quelle già esistenti.

Le attività di verifica comprendono l'analisi statica del codice, l'esecuzione di test automatici e il controllo del corretto funzionamento delle principali componenti dell'applicazione.

Nei paragrafi successivi verranno illustrati il metodo di verifica adottato, gli strumenti utilizzati e le strategie impiegate per mantenere nel tempo la qualità del progetto.

## 9.2 Strategia di test

Orto Smart adotta una strategia di verifica continua durante l'intero ciclo di sviluppo, con l'obiettivo di individuare tempestivamente eventuali anomalie e garantire la stabilità dell'applicazione.

Ogni nuova funzionalità viene sviluppata seguendo un processo che prevede la progettazione, l'implementazione, la verifica del codice e l'esecuzione dei test prima della sua integrazione nell'applicazione.

La strategia adottata si basa su tre principi fondamentali:

- verificare il corretto funzionamento delle nuove funzionalità;
- assicurare che le modifiche non introducano regressioni nelle componenti già esistenti;
- mantenere elevata la qualità complessiva del codice durante l'evoluzione del progetto.

Per raggiungere questi obiettivi vengono utilizzati strumenti di analisi statica del codice, test automatici e verifiche funzionali eseguite durante lo sviluppo.

Questo approccio consente di individuare gli errori nelle fasi iniziali, riducendo i costi di correzione e migliorando l'affidabilità complessiva del software.

Le verifiche vengono eseguite in modo sistematico prima del completamento delle attività di sviluppo e rappresentano parte integrante del processo di realizzazione di Orto Smart.

## 9.3 Flutter Analyze

Durante lo sviluppo di Orto Smart viene utilizzato il comando `flutter analyze` per eseguire l'analisi statica del codice sorgente.

Questo strumento verifica automaticamente il rispetto delle regole del linguaggio Dart e delle buone pratiche di sviluppo, individuando errori sintattici, problemi di tipizzazione, codice non utilizzato e altre possibili anomalie prima dell'esecuzione dell'applicazione.

L'analisi statica rappresenta una delle prime verifiche effettuate dopo l'implementazione di una nuova funzionalità e prima dell'esecuzione dei test automatici.

L'utilizzo sistematico di `flutter analyze` consente di:

- individuare tempestivamente errori di compilazione;
- rilevare potenziali problemi di qualità del codice;
- mantenere uniforme lo stile di sviluppo del progetto;
- ridurre la probabilità di introdurre difetti nelle versioni successive.

L'assenza di errori segnalati dall'analizzatore costituisce un requisito preliminare per considerare completata una sessione di sviluppo e procedere con le successive attività di verifica.

## 9.4 Test automatici

Oltre all'analisi statica del codice, Orto Smart utilizza test automatici per verificare il corretto funzionamento delle componenti implementate.

I test consentono di controllare che gli algoritmi producano i risultati attesi e che le modifiche introdotte non alterino il comportamento delle funzionalità già sviluppate.

Particolare attenzione viene dedicata ai componenti del Motore Agronomico, dove la correttezza delle elaborazioni rappresenta un requisito fondamentale per l'affidabilità dell'applicazione.

I test automatici permettono di:

- verificare il comportamento delle singole componenti;
- controllare la correttezza degli algoritmi implementati;
- individuare rapidamente eventuali regressioni;
- facilitare l'evoluzione del software mantenendo elevata l'affidabilità del progetto.

L'esecuzione dei test viene effettuata mediante il comando `flutter test`, che consente di verificare automaticamente il corretto funzionamento delle funzionalità coperte dai test.

I test rappresentano uno strumento essenziale del processo di sviluppo e costituiscono un'importante garanzia di qualità durante l'evoluzione di Orto Smart.

## 9.5 Qualità del codice

La qualità del codice rappresenta un elemento fondamentale nello sviluppo di Orto Smart e costituisce uno degli obiettivi perseguiti durante tutte le fasi del progetto.

Per mantenere il software facilmente comprensibile, manutenibile ed estendibile, vengono adottati criteri di progettazione orientati alla semplicità, alla modularità e alla separazione delle responsabilità tra i diversi componenti dell'applicazione.

Tra i principi adottati durante lo sviluppo si evidenziano:

- organizzazione del codice in componenti con responsabilità ben definite;
- separazione tra interfaccia utente, logica applicativa, logica agronomica e accesso ai dati;
- utilizzo di modelli e repository per isolare la gestione delle informazioni;
- riduzione delle dipendenze tra i moduli;
- progettazione orientata al riutilizzo del codice.

Il rispetto di questi principi facilita la manutenzione del progetto, semplifica l'introduzione di nuove funzionalità e contribuisce a ridurre il rischio di errori durante l'evoluzione dell'applicazione.

La qualità del codice viene inoltre verificata attraverso revisioni durante lo sviluppo, analisi statica e test automatici, così da mantenere nel tempo un'architettura coerente e affidabile.

## 9.6 Gestione delle regressioni

Durante l'evoluzione di Orto Smart viene prestata particolare attenzione alla prevenzione delle regressioni, ovvero all'introduzione involontaria di errori in funzionalità già sviluppate a seguito dell'implementazione di nuove caratteristiche.

Per ridurre questo rischio, ogni modifica viene verificata seguendo un processo strutturato che comprende l'analisi statica del codice, l'esecuzione dei test automatici e il controllo del corretto funzionamento delle principali funzionalità dell'applicazione.

L'approccio adottato prevede che le nuove implementazioni siano integrate progressivamente, mantenendo la compatibilità con l'architettura esistente e limitando l'impatto sulle componenti già consolidate.

La progettazione modulare del software contribuisce inoltre a contenere gli effetti delle modifiche, poiché ogni componente opera in modo indipendente e con responsabilità ben definite.

La prevenzione delle regressioni rappresenta un elemento essenziale per garantire la continuità dello sviluppo e mantenere elevata l'affidabilità dell'applicazione nel corso delle successive versioni.

## 9.7 Evoluzione futura

La strategia di verifica adottata in Orto Smart è destinata ad evolvere parallelamente alla crescita del progetto, accompagnando l'introduzione di nuove funzionalità e l'espansione del Motore Agronomico.

Con l'aumento della complessità dell'applicazione, verranno progressivamente ampliate le attività di test e di controllo della qualità, mantenendo come obiettivo principale l'affidabilità del software e la prevenzione delle regressioni.

Tra gli sviluppi previsti rientrano:

- incremento della copertura dei test automatici;
- introduzione di test dedicati ai nuovi moduli del Motore Agronomico;
- ampliamento delle verifiche sulle funzionalità di irrigazione e pianificazione delle attività;
- consolidamento delle procedure di controllo qualità prima del rilascio di nuove versioni;
- continuo miglioramento dell'organizzazione del codice e della documentazione tecnica.

L'approccio adottato consentirà di accompagnare l'evoluzione di Orto Smart mantenendo elevati standard di qualità e garantendo la stabilità dell'applicazione nel lungo periodo.

## 9.8 Considerazioni finali

La qualità del software rappresenta uno dei principi fondamentali dello sviluppo di Orto Smart e accompagna ogni fase del ciclo di vita del progetto.

L'integrazione tra analisi statica del codice, test automatici, progettazione modulare e verifiche continue consente di realizzare un'applicazione affidabile, facilmente manutenibile e pronta ad evolvere nel tempo.

L'approccio adottato permette di introdurre nuove funzionalità mantenendo la stabilità delle componenti già sviluppate, riducendo il rischio di regressioni e favorendo una crescita progressiva del sistema.

La strategia di qualità documentata in questo capitolo costituisce una base metodologica destinata ad accompagnare l'intero sviluppo di Orto Smart, contribuendo a garantire la robustezza dell'applicazione e la fiducia degli utenti nel suo utilizzo.

Nel Capitolo 10 verranno illustrate le prospettive di evoluzione del progetto, con particolare riferimento alle funzionalità previste nelle future versioni e alla roadmap di sviluppo.

# 10. Evoluzione del Progetto

## 10.1 Visione generale

Orto Smart è un progetto concepito per evolvere progressivamente, accompagnando le esigenze dell'utente e l'introduzione di nuove funzionalità senza compromettere la stabilità dell'architettura esistente.

Fin dalle prime fasi di sviluppo, particolare attenzione è stata dedicata alla progettazione di una struttura modulare, nella quale ogni componente possa essere esteso o sostituito mantenendo inalterata la coerenza complessiva del sistema.

La visione del progetto non si limita alla gestione delle coltivazioni, ma mira a realizzare una piattaforma capace di supportare l'intera gestione dell'orto attraverso strumenti di pianificazione, analisi e supporto alle decisioni.

L'evoluzione di Orto Smart sarà guidata da criteri di qualità del software, semplicità di utilizzo e solidità architetturale, privilegiando soluzioni facilmente manutenibili e orientate alla crescita nel lungo periodo.

Nei paragrafi successivi vengono illustrati i principi che guideranno l'evoluzione dell'applicazione e le principali direttrici di sviluppo previste.

## 10.2 Principi evolutivi

L'evoluzione di Orto Smart sarà guidata da un insieme di principi progettuali definiti fin dalle prime fasi di sviluppo e destinati a rimanere validi durante l'intero ciclo di vita del progetto.

Ogni nuova funzionalità dovrà integrarsi con l'architettura esistente rispettando la modularità del sistema, la separazione delle responsabilità tra i componenti e la semplicità di manutenzione del codice.

In particolare, lo sviluppo del progetto seguirà i seguenti principi:

- evoluzione incrementale attraverso piccoli miglioramenti progressivi;
- mantenimento della compatibilità con l'architettura esistente;
- separazione tra interfaccia utente, logica applicativa, logica agronomica e accesso ai dati;
- riutilizzo dei componenti software già sviluppati;
- estensione del Motore Agronomico mediante moduli indipendenti;
- attenzione alla qualità del codice, ai test automatici e alla documentazione tecnica.

L'obiettivo è garantire una crescita ordinata del progetto, evitando un aumento eccessivo della complessità e preservando nel tempo la leggibilità e la manutenibilità del software.

Questi principi costituiscono il riferimento per tutte le future attività di sviluppo e rappresentano la base metodologica sulla quale continuerà ad evolvere Orto Smart.

## 10.3 Aree di sviluppo

L'evoluzione di Orto Smart interesserà progressivamente tutte le principali aree funzionali dell'applicazione, con l'obiettivo di realizzare un sistema sempre più completo per la gestione dell'orto.

Lo sviluppo seguirà un approccio incrementale, privilegiando l'introduzione di nuove funzionalità attraverso componenti modulari e facilmente integrabili nell'architettura esistente.

Le principali aree di sviluppo previste comprendono:

- ampliamento delle funzionalità del Motore Agronomico;
- gestione avanzata delle coltivazioni e delle stagioni;
- pianificazione delle attività agricole;
- evoluzione della gestione dell'irrigazione;
- analisi statistiche e supporto alle decisioni;
- miglioramento continuo dell'interfaccia utente e dell'esperienza d'uso;
- ottimizzazione delle prestazioni e dell'organizzazione dei dati.

L'evoluzione delle diverse aree avverrà in modo coordinato, mantenendo la coerenza con l'architettura generale del progetto e con i principi progettuali definiti nei capitoli precedenti.

La pianificazione dettagliata delle singole funzionalità non costituisce oggetto del presente Manuale Tecnico ed è demandata alla documentazione dedicata alla roadmap di sviluppo, che viene aggiornata durante l'evoluzione del progetto.

## 10.4 Scalabilità dell'architettura

L'architettura di Orto Smart è stata progettata con l'obiettivo di supportare la crescita del progetto nel lungo periodo, consentendo l'introduzione di nuove funzionalità senza richiedere modifiche sostanziali alle componenti già esistenti.

La separazione tra interfaccia utente, logica applicativa, Motore Agronomico e livello di accesso ai dati permette di sviluppare ogni area in modo indipendente, riducendo le dipendenze tra i moduli e facilitando la manutenzione del software.

L'organizzazione del codice in componenti specializzati favorisce inoltre il riutilizzo delle funzionalità esistenti e rende possibile l'integrazione di nuovi moduli mantenendo la coerenza dell'architettura generale.

La scalabilità del progetto riguarda non solo gli aspetti tecnici, ma anche l'organizzazione dello sviluppo e della documentazione. La suddivisione delle responsabilità tra codice, manuali tecnici, roadmap e documentazione storica consente infatti di accompagnare l'evoluzione del progetto mantenendo ordine, tracciabilità e facilità di aggiornamento.

Questa impostazione permette a Orto Smart di evolvere progressivamente, preservando la qualità del software e garantendo la sostenibilità dello sviluppo nel tempo.

## 10.5 Integrazioni future

L'architettura di Orto Smart è stata progettata per favorire l'integrazione con servizi, dispositivi e componenti esterni, mantenendo un basso livello di accoppiamento tra i diversi moduli del sistema.

Questa impostazione consentirà di ampliare progressivamente le funzionalità dell'applicazione senza richiedere modifiche sostanziali all'architettura esistente.

Tra le principali aree di integrazione previste rientrano:

- servizi meteorologici e utilizzo dei dati climatici;
- sistemi di irrigazione automatizzata;
- dispositivi hardware dedicati al monitoraggio dell'orto;
- sistemi di notifica e pianificazione delle attività;
- strumenti di analisi statistica e supporto alle decisioni;
- eventuali servizi esterni che potranno essere introdotti nel corso dell'evoluzione del progetto.

Ogni nuova integrazione dovrà rispettare i principi architetturali descritti nel presente Manuale Tecnico, privilegiando componenti modulari, facilmente sostituibili e indipendenti dalle specifiche tecnologie utilizzate.

Questo approccio consentirà al progetto di adattarsi all'evoluzione delle tecnologie nel tempo, preservando la stabilità e la manutenibilità dell'applicazione.

## 10.6 Roadmap di alto livello

L'evoluzione di Orto Smart seguirà una pianificazione progressiva, orientata all'introduzione graduale di nuove funzionalità e al consolidamento dell'architettura esistente.

Il presente Manuale Tecnico descrive la direzione architetturale del progetto e i principi che ne guidano lo sviluppo, mentre la pianificazione operativa delle attività è documentata nel documento **DOC-008 – Roadmap di Sviluppo**, aggiornato durante l'avanzamento del progetto.

Questa separazione consente di mantenere stabile la documentazione architetturale e di gestire in modo indipendente la pianificazione delle singole attività, delle priorità e delle future implementazioni.

La roadmap costituisce pertanto uno strumento dinamico di gestione dello sviluppo, mentre il Manuale Tecnico rappresenta il riferimento architetturale stabile per le scelte progettuali e per l'evoluzione del sistema.

L'adozione di questa organizzazione documentale garantisce maggiore chiarezza, tracciabilità e semplicità di manutenzione, favorendo una crescita ordinata del progetto nel tempo.

## 10.7 Considerazioni finali

Il presente Manuale Tecnico raccoglie e documenta l'architettura software, i principi progettuali e le principali scelte tecniche che costituiscono il fondamento del progetto Orto Smart.

La struttura modulare dell'applicazione, la separazione delle responsabilità tra i diversi componenti e l'adozione di criteri di qualità, manutenibilità ed estendibilità costituiscono gli elementi guida per lo sviluppo presente e futuro del sistema.

Il Manuale Tecnico rappresenta il documento di riferimento architetturale del progetto e fornisce il quadro entro il quale dovranno essere progettate e realizzate le successive evoluzioni dell'applicazione, garantendo continuità e coerenza con le scelte progettuali adottate.

La pianificazione delle attività di sviluppo, la cronologia delle modifiche e la gestione delle versioni sono documentate in documenti dedicati, mantenendo una chiara distinzione tra architettura, processo di sviluppo e gestione del progetto.

L'insieme della documentazione di Orto Smart costituisce un patrimonio tecnico del progetto e contribuisce a renderne più semplice la manutenzione, la collaborazione e l'evoluzione nel tempo.

Con il completamento del presente Manuale Tecnico viene definita l'architettura di riferimento della versione corrente di Orto Smart, destinata a costituire la base per le future evoluzioni del software.
