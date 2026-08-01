# ORTO SMART

### DOC-005

# Quaderno di Sviluppo

**Versione:** 0.1  
**Stato:** In sviluppo  

**Autore:** Renzo Siega  
**Progetto:** Orto Smart  

**Data prima emissione:** 26/07/2026  
**Ultimo aggiornamento:** 31/07/2026  

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-005 |
| Titolo | Quaderno di Sviluppo |
| Versione | 0.1 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 31/07/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|----------------------------------------------|
| 0.1 | 26/07/2026 | Prima emissione del Quaderno di Sviluppo |
| 0.2 | 31/07/2026 | Riorganizzazione della struttura documentale e uniformazione al DOC-001 |

---

# Indice

## 1. Introduzione
1.1 Scopo del documento  
1.2 Ruolo del Quaderno di Sviluppo  
1.3 Relazione con gli altri documenti  
1.4 Organizzazione del documento

## 2. Regole di aggiornamento

## 3. Sessioni di sviluppo
3.1 S001
3.2 S002
3.3 S003
3.4 S004
3.5 S005
3.6 S006
3.7 S007

## 4. Considerazioni finali

---

# 1. Introduzione

## 1.1 Scopo del documento

Il presente Quaderno di Sviluppo costituisce il diario tecnico ufficiale dello sviluppo di **Orto Smart**.

Il suo scopo è documentare in ordine cronologico l'evoluzione del progetto, registrando le attività svolte durante ciascuna sessione di sviluppo, le decisioni adottate, i test eseguiti e lo stato raggiunto dall'applicazione.

Il documento rappresenta il riferimento storico dello sviluppo del progetto e viene aggiornato al termine di ogni sessione significativa.

---

## 1.2 Ruolo del Quaderno di Sviluppo

Il Quaderno di Sviluppo raccoglie la cronologia tecnica del progetto e documenta l'evoluzione dell'architettura software nel tempo.

Ogni sessione descrive gli obiettivi prefissati, le attività svolte, le decisioni progettuali, i test eseguiti e i risultati ottenuti, costituendo una memoria storica dell'intero sviluppo.

---

## 1.3 Relazione con gli altri documenti

Il Quaderno di Sviluppo integra la documentazione tecnica di Orto Smart ed è strettamente collegato agli altri documenti del progetto.

In particolare:

- il **DOC-001 – Manuale Tecnico e Architetturale** descrive l'architettura del sistema;
- il **CHANGELOG** riporta sinteticamente le modifiche introdotte nelle diverse versioni;
- il **DOC-011 – Decisioni Architetturali** raccoglie le decisioni progettuali ufficialmente approvate;
- la **Roadmap di Sviluppo** definisce la pianificazione delle attività future.

Il Quaderno di Sviluppo rappresenta quindi il collegamento tra la cronologia delle attività svolte e la documentazione tecnica del progetto.

---

## 1.4 Organizzazione del documento

Il documento è organizzato in sessioni cronologiche.

Per ciascuna sessione vengono riportati gli obiettivi, le attività svolte, le decisioni progettuali, i test eseguiti, lo stato del progetto, i riferimenti ai commit Git e gli obiettivi della sessione successiva.

Questa struttura garantisce la completa tracciabilità dell'evoluzione di Orto Smart e facilita la consultazione della documentazione storica.

---

# 2. Regole di aggiornamento

Il Quaderno di Sviluppo viene aggiornato al termine di ogni sessione significativa di sviluppo e costituisce il registro cronologico ufficiale dell'evoluzione del progetto Orto Smart.

Ogni sessione deve documentare in modo coerente le attività svolte, le decisioni progettuali adottate, i test eseguiti e lo stato raggiunto dal progetto, mantenendo il completo allineamento con la restante documentazione tecnica.

Per ciascuna sessione devono essere registrati almeno i seguenti elementi:

- numero della sessione.
- data.
- obiettivo della sessione.
- attività svolte.
- decisioni architetturali eventualmente approvate.
- test eseguiti.
- stato del progetto.
- Commit Git.
- tempo di sviluppo (se disponibile).
- obiettivi della sessione successiva.

> **Regola operativa**
>
> Una sessione di sviluppo è considerata conclusa esclusivamente dopo il completamento delle attività tecniche previste, l'aggiornamento della documentazione interessata (Manuale Tecnico, Quaderno di Sviluppo, CHANGELOG e altri documenti applicabili), l'eventuale commit e push del codice e la registrazione della sessione nel presente Quaderno di Sviluppo.

L'adozione di queste regole garantisce la completa tracciabilità dell'evoluzione del progetto, mantiene la coerenza tra codice e documentazione e assicura che ogni sessione di sviluppo sia correttamente documentata prima della sua chiusura formale.

---

# 3. Sessioni di sviluppo

Le sessioni di sviluppo costituiscono il nucleo del presente Quaderno di Sviluppo e documentano in ordine cronologico l'evoluzione del progetto Orto Smart.

Per ciascuna sessione vengono riportati gli obiettivi, le attività svolte, le decisioni architetturali adottate, i test eseguiti, lo stato del progetto, i riferimenti ai commit Git e gli obiettivi della sessione successiva.

Questa organizzazione consente di ricostruire con precisione l'intero percorso di sviluppo dell'applicazione, mantenendo la completa tracciabilità delle modifiche introdotte nel tempo.

---

> **Nota**
>
> Le sessioni **S001–S004** sono state ricostruite a posteriori sulla base della cronologia Git, della documentazione tecnica e dello storico dello sviluppo del progetto. I contenuti rappresentano fedelmente l'evoluzione di Orto Smart, pur non derivando da un diario compilato contestualmente alle attività.

## 3.1 S001 – Avvio del progetto

**Data:** Luglio 2026

**Versione interessata:** 0.1.0-alpha

---

### Obiettivo della sessione

Avviare il progetto Orto Smart definendone le basi tecniche, predisponendo l'ambiente di sviluppo e creando la struttura iniziale dell'applicazione Flutter.

L'obiettivo principale della sessione è stato quello di realizzare le fondamenta del progetto sulle quali sviluppare successivamente tutte le funzionalità dell'applicazione.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- creazione del repository GitHub del progetto;
- inizializzazione del progetto Flutter;
- definizione della struttura iniziale delle cartelle;
- configurazione dell'ambiente di sviluppo;
- creazione del file README;
- primo avvio dell'applicazione.

---

### Decisioni architetturali

Nel corso della sessione sono state definite le principali linee guida che avrebbero orientato lo sviluppo del progetto:

- utilizzo di Flutter come framework multipiattaforma;
- utilizzo del linguaggio Dart;
- organizzazione del progetto secondo un'architettura modulare;
- gestione del codice tramite Git e GitHub.

Queste decisioni hanno costituito la base dell'architettura software adottata nelle sessioni successive.

---

### File creati

Tra i principali elementi realizzati durante la sessione:

- repository GitHub;
- progetto Flutter;
- struttura iniziale delle directory;
- file README.

---

### Database

In questa fase non era ancora presente alcuna integrazione con il database.

---

### Test eseguiti

Al termine della sessione sono stati effettuati:

- compilazione iniziale del progetto Flutter;
- verifica del corretto avvio dell'applicazione.

Le verifiche hanno confermato il corretto funzionamento dell'ambiente di sviluppo.

---

### Stato del progetto

Al termine della sessione il progetto disponeva di:

- repository GitHub operativo;
- progetto Flutter inizializzato;
- struttura software di base;
- ambiente di sviluppo configurato.

---

### Git

#### Commit

```text
Create README.md

Aggiunge progetto Flutter orto_app
```

---

### Tempo di sviluppo

Non disponibile (sessione ricostruita).

---

### Obiettivi della sessione successiva

Per la sessione S002 sono stati individuati i seguenti obiettivi:

- integrazione di Supabase;
- predisposizione del database;
- primo collegamento tra applicazione e backend.

---

### Esito della sessione

La sessione S001 rappresenta l'avvio ufficiale del progetto Orto Smart.

Con la creazione del repository GitHub, l'inizializzazione del progetto Flutter e la definizione della struttura di base dell'applicazione sono state poste le fondamenta tecniche sulle quali si svilupperanno tutte le successive evoluzioni del progetto.

---

## 3.2 S002 – Integrazione di Supabase

**Data:** Luglio 2026

**Versione interessata:** 0.1.1-alpha

---

### Obiettivo della sessione

Integrare il backend Supabase all'interno dell'applicazione Orto Smart, predisponendo l'infrastruttura necessaria alla gestione persistente dei dati e ponendo le basi per lo sviluppo delle funzionalità dell'orto.

L'obiettivo principale della sessione è stato quello di sostituire una struttura esclusivamente locale con un'architettura client-server basata su PostgreSQL e Supabase.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- creazione del progetto Supabase;
- configurazione della connessione tra Flutter e Supabase;
- predisposizione del database PostgreSQL;
- configurazione delle credenziali dell'applicazione;
- verifica della comunicazione tra applicazione e backend;
- primo utilizzo di Supabase come livello di persistenza dei dati.

---

### Decisioni architetturali

Nel corso della sessione sono state definite le principali scelte relative al backend del progetto:

- adozione di Supabase come piattaforma Backend-as-a-Service;
- utilizzo di PostgreSQL come database relazionale;
- separazione tra logica applicativa e livello di persistenza dei dati;
- progettazione orientata alla futura introduzione del Repository Layer.

Queste decisioni hanno costituito la base dell'architettura dati utilizzata nelle successive fasi di sviluppo.

---

### File creati

Tra i principali elementi introdotti durante la sessione:

- configurazione di Supabase;
- primi componenti dedicati alla connessione con il backend;
- struttura iniziale del database.

---

### File modificati

Sono stati aggiornati i file necessari all'integrazione tra Flutter e Supabase e alla configurazione dell'applicazione.

---

### Database

Nel corso della sessione è stato predisposto il database PostgreSQL gestito tramite Supabase.

Sono state poste le basi per la successiva definizione delle entità applicative e delle relative tabelle.

---

### Test eseguiti

Al termine della sessione sono stati effettuati:

- verifica della connessione tra Flutter e Supabase;
- verifica del corretto avvio dell'applicazione;
- controllo del corretto accesso al backend.

Le verifiche hanno confermato il corretto funzionamento dell'infrastruttura iniziale.

---

### Stato del progetto

Al termine della sessione il progetto disponeva di:

- backend Supabase operativo;
- database PostgreSQL configurato;
- applicazione collegata al backend;
- infrastruttura pronta per l'implementazione delle prime funzionalità.

---

### Git

#### Commit

```text
Prima versione con Supabase
```

---

### Tempo di sviluppo

Non disponibile (sessione ricostruita).

---

### Obiettivi della sessione successiva

Per la sessione S003 sono stati individuati i seguenti obiettivi:

- implementazione della gestione delle aiuole;
- introduzione della navigazione tra le pagine;
- sviluppo dei primi modelli dati dell'applicazione.

---

### Esito della sessione

La sessione S002 segna l'introduzione dell'infrastruttura dati di Orto Smart.

L'integrazione di Supabase e PostgreSQL rappresenta un passaggio fondamentale nell'evoluzione del progetto, consentendo all'applicazione di disporre di un backend strutturato e preparando il terreno per lo sviluppo delle funzionalità operative delle sessioni successive.

---

## 3.3 S003 – Gestione delle aiuole e prime funzionalità applicative

**Data:** Luglio 2026

**Versione interessata:** 0.1.2-alpha

---

### Obiettivo della sessione

Realizzare le prime funzionalità operative dell'applicazione introducendo la gestione delle aiuole, la navigazione tra le pagine e i primi componenti dedicati all'accesso ai dati.

L'obiettivo principale della sessione è stato quello di trasformare l'infrastruttura realizzata nelle sessioni precedenti in una prima applicazione funzionante, capace di visualizzare e gestire le informazioni provenienti dal database.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- implementazione della navigazione tra le principali schermate dell'applicazione;
- sviluppo della gestione delle aiuole;
- introduzione dei primi modelli dati dell'applicazione;
- implementazione dei Repository per l'accesso alle informazioni archiviate nel database;
- collegamento tra interfaccia utente e dati provenienti da Supabase;
- prime verifiche sul corretto recupero e visualizzazione delle informazioni.

---

### Decisioni architetturali

Nel corso della sessione sono state consolidate alcune scelte progettuali fondamentali:

- separazione tra interfaccia utente e accesso ai dati mediante Repository dedicati;
- utilizzo di modelli Dart per rappresentare le entità applicative;
- organizzazione del codice in componenti modulari e facilmente estendibili.

Queste decisioni hanno posto le basi dell'architettura software che caratterizzerà le successive evoluzioni di Orto Smart.

---

### File creati

Tra i principali componenti introdotti durante la sessione:

- prime pagine dell'interfaccia utente;
- modelli dati principali;
- primi Repository dell'applicazione;
- componenti dedicati alla gestione delle aiuole.

---

### File modificati

Sono stati aggiornati numerosi componenti dell'applicazione per integrare la navigazione, la gestione delle aiuole e il collegamento con il database.

---

### Database

Durante la sessione sono state effettuate le prime verifiche operative sul database Supabase e sull'utilizzo delle tabelle dedicate alla gestione dell'orto.

L'applicazione è stata resa in grado di leggere le informazioni archiviate nel database e di utilizzarle per la visualizzazione delle aiuole.

---

### Test eseguiti

Al termine della sessione sono stati effettuati:

- verifica della navigazione tra le pagine;
- controllo del recupero dei dati dal database;
- verifica della corretta visualizzazione delle aiuole;
- prove funzionali dell'applicazione.

Le verifiche hanno confermato il corretto funzionamento delle principali funzionalità implementate.

---

### Stato del progetto

Al termine della sessione il progetto disponeva di:

- navigazione funzionante;
- gestione delle aiuole;
- primi Repository operativi;
- modelli dati collegati al database;
- applicazione in grado di utilizzare dati reali provenienti da Supabase.

---

### Git

#### Commit

```text
Navigazione aiuole

Modulo aiuole + Supabase
```

---

### Tempo di sviluppo

Non disponibile (sessione ricostruita).

---

### Obiettivi della sessione successiva

Per la sessione S004 sono stati individuati i seguenti obiettivi:

- introduzione del Motore Agronomico;
- sviluppo degli algoritmi per la gestione dello spazio disponibile;
- implementazione dei primi motori di supporto alle decisioni agronomiche.

---

### Esito della sessione

La sessione S003 rappresenta il passaggio dall'infrastruttura di base alla prima applicazione realmente operativa.

Con l'introduzione della gestione delle aiuole, della navigazione e dei primi Repository, Orto Smart acquisisce una struttura software completa, predisposta per l'integrazione del Motore Agronomico nelle successive fasi di sviluppo.

---

## 3.4 S004 – Introduzione del Motore Agronomico

**Data:** Luglio 2026

**Versione interessata:** 0.1.2-alpha

---

### Obiettivo della sessione

Introdurre il primo nucleo del Motore Agronomico di Orto Smart, definendone l'architettura software e implementando i primi algoritmi dedicati all'analisi delle coltivazioni.

L'obiettivo principale della sessione è stato quello di separare la logica agronomica dal resto dell'applicazione, realizzando componenti modulari, riutilizzabili e facilmente estendibili.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- progettazione dell'architettura del Motore Agronomico;
- implementazione del **Free Space Engine** per il calcolo degli spazi disponibili nelle aiuole;
- sviluppo del **Suggestion Engine** per la proposta automatica del posizionamento delle colture;
- introduzione del primo **Companion Engine** dedicato all'analisi delle consociazioni;
- definizione dei modelli utilizzati dai motori agronomici;
- organizzazione del codice in componenti indipendenti e specializzati;
- realizzazione dei primi test dedicati ai motori agronomici.

---

### Decisioni architetturali

Nel corso della sessione sono state definite le principali linee guida dell'architettura agronomica del progetto:

- separazione della logica agronomica dall'interfaccia utente;
- introduzione di motori specializzati, ciascuno con una responsabilità ben definita;
- progettazione orientata all'estendibilità del Motore Agronomico;
- utilizzo di modelli dedicati per rappresentare i risultati delle elaborazioni.

Queste decisioni hanno costituito la base dell'architettura agronomica utilizzata nelle successive evoluzioni del progetto.

---

### File creati

Tra i principali componenti introdotti durante la sessione:

- `free_space_engine.dart`
- `suggestion_engine.dart`
- `companion_engine.dart`
- modelli dedicati al Motore Agronomico
- primi file di test del Motore Agronomico

---

### File modificati

Sono stati aggiornati diversi componenti dell'applicazione per integrare il nuovo Motore Agronomico con la gestione delle aiuole e delle coltivazioni.

---

### Database

Nel corso della sessione non sono state apportate modifiche sostanziali alla struttura del database.

Le attività hanno riguardato principalmente la logica applicativa e l'elaborazione dei dati già disponibili.

---

### Test eseguiti

Al termine della sessione sono stati effettuati:

- `flutter analyze`
- `flutter test`
- verifica del corretto funzionamento dei motori agronomici
- prove funzionali sull'integrazione con l'applicazione

Tutte le verifiche sono state completate con esito positivo.

---

### Stato del progetto

Al termine della sessione il progetto disponeva di:

- primo Motore Agronomico operativo;
- Free Space Engine funzionante;
- Suggestion Engine funzionante;
- prima implementazione del Companion Engine;
- architettura agronomica modulare e facilmente estendibile;
- test automatici dedicati ai principali algoritmi.

---

### Git

#### Commit

```text
Add authentication, RLS security and agronomic engine

Completata integrazione SuggestionEngine con inserimento automatico colture
```

---

### Tempo di sviluppo

Non disponibile (sessione ricostruita).

---

### Obiettivi della sessione successiva

Per la sessione S005 sono stati individuati i seguenti obiettivi:

- consolidamento dell'architettura del Motore Agronomico;
- refactoring del motore delle consociazioni;
- introduzione di servizi dedicati al coordinamento delle analisi;
- miglioramento della modularità dell'intero sistema.

---

### Esito della sessione

La sessione S004 rappresenta la nascita del Motore Agronomico di Orto Smart.

Con l'introduzione del Free Space Engine, del Suggestion Engine e della prima implementazione del Companion Engine, l'applicazione acquisisce la capacità di elaborare automaticamente informazioni agronomiche, ponendo le basi per lo sviluppo delle successive funzionalità di analisi, supporto alle decisioni e pianificazione intelligente dell'orto.

---

## 3.5 S005 – Consolidamento del Motore Agronomico

**Data:** 28/07/2026

**Versione interessata:** 0.1.2-alpha

---

### Obiettivo della sessione

Consolidare l'architettura del Motore Agronomico migliorandone la modularità, la manutenibilità e l'allineamento con il modello dati di Supabase.

In particolare, la sessione è stata dedicata al refactoring del motore delle consociazioni e all'introduzione di un servizio dedicato al coordinamento delle analisi delle aiuole.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- refactoring completo degli identificativi delle colture da `int` a `String`.
- allineamento del Motore Agronomico al modello dati di Supabase.
- introduzione del nuovo servizio `BedAnalysisService`.
- implementazione del nuovo `BedCompanionAnalyzer`.
- creazione del modello `BedCompanionAnalysis`.
- creazione del modello `CompanionPairAnalysis`.
- aggiornamento della `BedPage` per utilizzare il nuovo servizio di analisi.
- aggiornamento del `CompanionEngine`.
- aggiornamento delle regole di consociazione.
- aggiornamento dei test esistenti.
- creazione di nuovi test unitari per i nuovi componenti.

---

### Decisioni architetturali

Nel corso della sessione sono state approvate due nuove decisioni architetturali ufficiali, documentate nel **DOC-011 – Decisioni Architetturali**.

### DEC-001 – Standardizzazione degli identificativi delle colture

È stato deciso di utilizzare esclusivamente identificativi di tipo `String` per rappresentare le colture in tutto il progetto, eliminando definitivamente le conversioni tra `int` e `String`.

### DEC-002 – Introduzione di BedAnalysisService

È stato introdotto `BedAnalysisService` come servizio incaricato di coordinare le analisi dell'aiuola senza contenere logica agronomica.

Principio architetturale adottato:

> **Un servizio coordina, i motori calcolano.**

---

### File creati

- `bed_analysis_service.dart`
- `bed_companion_analyzer.dart`
- `bed_companion_analysis.dart`
- `companion_pair_analysis.dart`
- file di test corrispondenti

---

### File modificati

- `bed_page.dart`
- `companion_engine.dart`
- `companion_rule.dart`
- `companion_rules.dart`
- test del Motore Agronomico

---

### Database

Non sono state apportate modifiche alla struttura del database Supabase.

L'intervento ha riguardato esclusivamente il codice dell'applicazione.

---

### Test eseguiti

Al termine dello sviluppo sono stati eseguiti i seguenti controlli:

- `flutter analyze`
- `flutter test`
- verifica manuale del corretto funzionamento dell'applicazione

Tutti i controlli sono stati completati con esito positivo.

---

### Stato del progetto

Al termine della sessione il progetto presenta le seguenti caratteristiche:

- motore delle consociazioni completamente allineato al database Supabase.
- architettura più modulare e facilmente estendibile.
- maggiore separazione delle responsabilità tra interfaccia utente, servizi e motori agronomici.
- introduzione di un servizio centralizzato per l'analisi delle aiuole.
- architettura pronta per l'integrazione delle analisi delle consociazioni nell'interfaccia utente.

---

### Git

#### Commit

```text
Completa BedAnalysisService e motore consociazioni
```

#### Push

Completato con successo sul repository GitHub.

---

### Tempo di sviluppo

Da compilare, se disponibile.

---

### Obiettivi della sessione S006

Per la prossima sessione di sviluppo sono previsti i seguenti obiettivi:

- integrare i risultati del `BedCompanionAnalyzer` nella `BedPage`.
- visualizzare le consociazioni favorevoli e sfavorevoli nell'interfaccia utente.
- migliorare la presentazione dei suggerimenti agronomici.
- proseguire l'evoluzione del Motore Agronomico.

---

### Esito della sessione

La sessione **S005** si conclude con il consolidamento dell'architettura del Motore Agronomico.

L'introduzione di `BedAnalysisService`, la standardizzazione degli identificativi delle colture e il refactoring del motore delle consociazioni costituiscono una base più solida, modulare ed estendibile per lo sviluppo delle future funzionalità di **Orto Smart**.

Le decisioni adottate durante questa sessione rappresentano un importante passo avanti nell'organizzazione dell'architettura del progetto e preparano il terreno per l'integrazione delle future funzionalità agronomiche.

---

## 3.6 S006 – Decision Engine e Analisi Agronomica Integrata

**Data:** 29/07/2026

**Versione interessata:** 0.1.3-alpha

---

### Obiettivo della sessione

Completare l'integrazione dell'analisi agronomica nell'interfaccia utente introducendo un motore decisionale centralizzato in grado di elaborare automaticamente i risultati prodotti dai diversi motori agronomici e presentarli all'utente in modo chiaro e uniforme.

L'obiettivo principale è stato quello di consolidare il flusso di analisi delle aiuole, preparando l'architettura all'integrazione di ulteriori motori agronomici.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- introduzione del nuovo `DecisionEngine` come componente incaricato di trasformare i risultati delle analisi agronomiche in decisioni e suggerimenti per l'utente.
- implementazione del modello `BedDecision` per rappresentare in modo uniforme gli esiti delle analisi.
- creazione del widget `CompanionAnalysisWidget` per la visualizzazione delle consociazioni direttamente nella schermata dell'aiuola.
- integrazione del `DecisionEngine` con il `BedAnalysisService`.
- refactoring del flusso di analisi per separare il calcolo agronomico dalla presentazione nell'interfaccia utente.
- aggiornamento della `BedPage` per utilizzare il nuovo flusso decisionale.
- aggiornamento e ampliamento dei test automatici.
- verifica del corretto funzionamento dell'intero flusso di analisi agronomica.

---

### Decisioni architetturali

Nel corso della sessione è stata approvata una nuova decisione architetturale ufficiale, documentata nel **DOC-011 – Decisioni Architetturali**.

### DEC-003 – Introduzione del Decision Engine

È stato introdotto il `DecisionEngine` come componente responsabile dell'interpretazione dei risultati prodotti dai motori agronomici e della loro trasformazione in decisioni, suggerimenti e informazioni destinate all'interfaccia utente.

Principio architetturale adottato:

> **I motori analizzano, il Decision Engine interpreta, l'interfaccia presenta.**

Questa scelta rafforza la separazione delle responsabilità tra logica di calcolo, logica decisionale e presentazione, rendendo l'architettura più modulare, estendibile e facilmente manutenibile.

---

### File creati

Nel corso della sessione sono stati creati i seguenti nuovi componenti:

- `decision_engine.dart`
- `bed_decision.dart`
- `companion_analysis_widget.dart`
- file di test corrispondenti

---

### File modificati

Sono stati aggiornati diversi componenti dell'applicazione, tra cui:

- `bed_analysis_service.dart`
- `bed_page.dart`
- componenti del Motore Agronomico
- widget dell'interfaccia utente
- test automatici del progetto

---

### Database

Nel corso della sessione non sono state apportate modifiche alla struttura del database Supabase.

Le attività hanno riguardato esclusivamente l'architettura dell'applicazione, il flusso decisionale e l'integrazione dei nuovi componenti software.

---

### Attività di documentazione

A completamento delle attività di sviluppo sono state svolte le operazioni di aggiornamento della documentazione tecnica del progetto, al fine di mantenere il completo allineamento tra codice, documentazione e registro storico.

Sono stati aggiornati i seguenti documenti:

- DOC-009 – Workflow Operativo
- DOC-005 – Quaderno di Sviluppo
- DOC-012 – Registro Storico dello Sviluppo
- Checklist Workflow Operativo v2.0 (Allegato A del DOC-009)

Nel corso dell'aggiornamento della documentazione sono state inoltre approvate le seguenti regole operative:

- una sessione è considerata conclusa solo quando codice, documentazione e registro storico risultano aggiornati, coerenti e allineati;
- ogni documento deve essere completato, approvato e chiuso prima di iniziare il successivo.

L'aggiornamento della documentazione conclude ufficialmente la Sessione S006 secondo il Workflow Operativo del progetto.

---

### Esito della sessione

La sessione S006 si conclude con il completo allineamento tra sviluppo software, documentazione tecnica e registro storico, nel rispetto del Workflow Operativo adottato dal progetto Orto Smart.

L'introduzione del Decision Engine e il consolidamento del flusso di analisi agronomica rappresentano un ulteriore passo nell'evoluzione dell'architettura di Orto Smart, preparando il progetto all'integrazione di nuovi motori agronomici e di funzionalità sempre più avanzate.

---

## 3.7 S007 – Revisione e consolidamento della documentazione tecnica

**Data:** Agosto 2026

**Versione interessata:** 1.0

---

### Obiettivo della sessione

Completare la revisione organica della documentazione tecnica di Orto Smart, uniformando struttura, contenuti e criteri redazionali dei principali documenti del progetto.

L'obiettivo principale della sessione è stato consolidare il sistema documentale del progetto, garantendo coerenza tra Manuale Tecnico, Quaderno di Sviluppo, Roadmap, Decisioni Architetturali, CHANGELOG e Linee Guida di Sviluppo, definendo inoltre un workflow documentale stabile per le future sessioni di sviluppo.

### Attività svolte

Durante la Sessione S007 è stata effettuata una revisione completa della documentazione tecnica del progetto, con l'obiettivo di uniformare la struttura dei documenti, migliorarne la leggibilità e definire un metodo di gestione stabile per le future attività di sviluppo.

Le principali attività svolte sono state:

- revisione completa del **DOC-005 – Quaderno di Sviluppo**, con ricostruzione delle sessioni storiche S001, S002, S003 e consolidamento delle sessioni S004, S005 e S006;
- definizione del nuovo workflow documentale, stabilendo che una sessione di sviluppo è considerata conclusa solo dopo l'aggiornamento della documentazione, l'eventuale commit e push del codice e la registrazione della sessione nel Quaderno di Sviluppo;
- revisione e approvazione del **DOC-011 – Decisioni Architetturali (ADR)**, con consolidamento delle decisioni architetturali del progetto;
- revisione completa e approvazione del **CHANGELOG**, uniformandone struttura, cronologia e criteri di aggiornamento;
- revisione completa e approvazione del **DOC-008 – Roadmap di Sviluppo**, trasformandolo in un documento di pianificazione strategica allineato con lo stato reale del progetto;
- verifica della coerenza tra Manuale Tecnico, Quaderno di Sviluppo, Roadmap, Decisioni Architetturali, CHANGELOG e Linee Guida di Sviluppo;
- definizione di una struttura documentale uniforme per tutti i documenti principali del progetto, consolidando un sistema documentale coerente e facilmente manutenibile.

### Decisioni prese

Nel corso della sessione sono state confermate le seguenti decisioni organizzative:

- definire una struttura documentale uniforme per tutti i documenti ufficiali del progetto;
- mantenere una netta separazione tra documentazione tecnica, cronologia delle sessioni, roadmap, decisioni architetturali e registro delle modifiche;
- aggiornare la documentazione contestualmente allo sviluppo del software, evitando disallineamenti tra codice e documenti;
- considerare conclusa una sessione di sviluppo esclusivamente dopo il completamento delle attività tecniche previste, l'aggiornamento della documentazione interessata, l'eventuale commit e push del codice e la registrazione della sessione nel Quaderno di Sviluppo, secondo quanto stabilito dalla DEC-004.

### Documentazione aggiornata

Nel corso della Sessione S007 sono stati revisionati, aggiornati e approvati i principali documenti del progetto:

- **DOC-001 – Manuale Tecnico e Architetturale**
- **DOC-008 – Roadmap di Sviluppo**
- **DOC-011 – Decisioni Architetturali (ADR)**
- **CHANGELOG**

È stato inoltre aggiornato il **DOC-005 – Quaderno di Sviluppo**, con la ricostruzione delle sessioni iniziali del progetto, il consolidamento delle sessioni successive e la registrazione della presente Sessione S007.

La documentazione del progetto risulta ora uniforme nella struttura, coerente nei contenuti e allineata con lo stato attuale dello sviluppo di Orto Smart.

### Esito della sessione

La Sessione S007 ha raggiunto pienamente gli obiettivi prefissati.

È stata completata la revisione organica della documentazione tecnica del progetto, uniformando struttura, contenuti e criteri redazionali dei principali documenti ufficiali di Orto Smart.

Al termine della sessione risultano approvati il Manuale Tecnico (DOC-001), la Roadmap di Sviluppo (DOC-008), il documento delle Decisioni Architetturali (DOC-011) e il CHANGELOG, mentre il Quaderno di Sviluppo (DOC-005) è stato aggiornato con la registrazione della presente sessione.

Il progetto dispone ora di un sistema documentale completo, coerente e allineato con lo stato attuale dello sviluppo, che costituirà il riferimento ufficiale per la gestione tecnica e documentale delle future sessioni di Orto Smart.

### Tempo di lavoro

Il tempo complessivo della Sessione S007 verrà registrato al termine delle attività di documentazione, comprensivo del tempo dedicato alla revisione dei documenti e dell'aggiornamento del Quaderno di Sviluppo.

Il totale sarà riportato nel registro delle sessioni del progetto.

### Prossimi passi

Con la conclusione della Sessione S007 termina la revisione organica della documentazione tecnica di Orto Smart.

Le prossime sessioni di sviluppo riprenderanno dall'evoluzione del software, proseguendo l'implementazione delle funzionalità previste dalla Roadmap di Sviluppo e mantenendo aggiornata la documentazione secondo il workflow definito durante la presente sessione.



