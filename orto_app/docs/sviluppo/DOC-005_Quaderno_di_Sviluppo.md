# ORTO SMART

### DOC-005

# Quaderno di Sviluppo

**Versione:** 0.3
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 26/07/2026
**Ultimo aggiornamento:** 08/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-005 |
| Titolo | Quaderno di Sviluppo |
| Versione | 0.3 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 08/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|----------------------------------------------|
| 0.1 | 26/07/2026 | Prima emissione del Quaderno di Sviluppo |
| 0.2 | 31/07/2026 | Riorganizzazione della struttura documentale e uniformazione al DOC-001 |
| 0.3      | 08/08/2026 | Aggiornamento del Quaderno con consolidamento delle Sessioni S009 e S010 |

---

# Registro delle sessioni di sviluppo

| Sessione | Periodo | Durata | Totale progetto | Attività principale | Stato |
|-----------|------------|:------:|:---------------:|---------------------------------------------------------------|:-----:|
| S001 | Maggio 2026 | 5 h 30 min | 5 h 30 min | Avvio del progetto Orto Smart e configurazione dell'ambiente di sviluppo | ✅ |
| S002 | Giugno 2026 | 3 h 00 min | 8 h 30 min | Integrazione di Supabase e sviluppo delle funzionalità di base | ✅ |
| S003 | Luglio 2026 | 2 h 15 min | 10 h 45 min | Gestione delle aiuole e sviluppo del FreeSpaceEngine | ✅ |
| S004 | Luglio 2026 | Da ricostruire | Da aggiornare | Introduzione del Companion Engine e consolidamento dell'architettura agronomica | ✅ |
| S005 | Luglio 2026 | Da ricostruire | Da aggiornare | BedAnalysisService e Bed Companion Analyzer | ✅ |
| S006 | Luglio 2026 | Da ricostruire | Da aggiornare | Decision Engine e consolidamento del Motore Agronomico | ✅ |
| S007 | Agosto 2026 | 11 h 00 min* | Da aggiornare | Revisione e consolidamento della documentazione tecnica | ✅ |
| S008 | Agosto 2026 | 4 h 16 min | 40 h 31 min | Censimento e consolidamento della documentazione residua | ✅ |
| S009     | Agosto 2026 |   5 h 22 min   |   45 h 53 min   | Evoluzione dell'architettura del Motore Agronomico e introduzione della RecommendationPipeline | ✅ |
| S010     | Agosto 2026 |   4 h 54 min   |   50 h 47 min   | Configurazione dei pesi del DecisionEngine mediante DecisionWeights | ✅ |
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
3.8 S008
3.9 S009

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

---

## 3.8 S008 – Censimento e consolidamento della documentazione residua

**Data:** Agosto 2026

**Versione interessata:** Documentazione del progetto

### Obiettivo della sessione

Completare il censimento, la revisione e il consolidamento della documentazione residua del progetto Orto Smart, uniformando i documenti allo Standard Documentale (DOC-000), eliminando duplicazioni, chiarendo il ruolo di ciascun documento e verificandone la coerenza reciproca.

L'obiettivo principale della sessione è stato consolidare definitivamente il sistema documentale del progetto, assicurando che ogni documento abbia uno scopo ben definito e che l'insieme della documentazione costituisca un riferimento affidabile per lo sviluppo futuro.

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- completato il censimento della documentazione ufficiale del progetto;
- revisionati e approvati i documenti ancora in stato "In revisione";
- consolidato il sistema documentale eliminando duplicazioni tra i documenti;
- definito con precisione il ruolo e le responsabilità di ciascun documento ufficiale;
- verificata la coerenza reciproca tra Quaderno di Sviluppo, Workflow Operativo, Registro Storico, Roadmap, Decisioni Architetturali, CHANGELOG e VERSION;
- aggiornato il file VERSION per allinearlo alle versioni ufficiali del software e al CHANGELOG;
- verificata la corrispondenza tra cronologia delle sessioni, milestone e sviluppo effettivo del progetto utilizzando il Quaderno di Sviluppo come fonte primaria;
- completata la rilettura tecnica finale dei documenti revisionati prima della loro approvazione.

### Decisioni prese

Nel corso della sessione sono state consolidate le seguenti decisioni organizzative:

- attribuire a ciascun documento ufficiale del progetto un ruolo specifico e non sovrapposto agli altri documenti;
- utilizzare sempre la documentazione ufficiale come fonte primaria per le verifiche storiche, evitando ricostruzioni basate esclusivamente sulla memoria;
- mantenere il principio "una sola fonte autorevole per ogni informazione", eliminando le duplicazioni tra i documenti;
- considerare il file VERSION come riferimento esclusivo per la versione del software, mentre la Roadmap, il CHANGELOG, il Quaderno di Sviluppo e il Registro Storico mantengono le rispettive responsabilità documentali.

### Documentazione aggiornata

Nel corso della Sessione S008 sono stati revisionati, aggiornati e approvati i seguenti documenti ufficiali del progetto:

- DOC-006 – Linee Guida di Sviluppo;
- DOC-009 – Workflow Operativo;
- DOC-012 – Registro Storico dello Sviluppo;
- VERSION.

Sono stati inoltre verificati la coerenza e l'allineamento con i seguenti documenti:

- DOC-000 – Standard Documentale;
- DOC-001 – Manuale Tecnico e Architetturale;
- DOC-005 – Quaderno di Sviluppo;
- DOC-008 – Roadmap di Sviluppo;
- DOC-011 – Decisioni Architetturali;
- CHANGELOG.

Al termine della sessione il sistema documentale del progetto risulta coerente, aggiornato e conforme ai principi definiti nello Standard Documentale (DOC-000).

### Esito della sessione

La Sessione S008 si conclude con il completamento del censimento e del consolidamento della documentazione residua del progetto Orto Smart.

Nel corso della sessione è stato completato il processo di revisione dei documenti ancora in stato "In revisione", verificandone la coerenza reciproca e uniformandoli ai criteri definiti dallo Standard Documentale (DOC-000).

Al termine della sessione il sistema documentale del progetto risulta organizzato secondo una chiara separazione delle responsabilità tra i documenti, riducendo le duplicazioni e migliorando la tracciabilità delle informazioni.

La documentazione costituisce ora una base stabile e coerente per la prosecuzione dello sviluppo software e per le future evoluzioni del progetto Orto Smart.

### Tempo di lavoro

Tempo complessivo della Sessione S008:

### Tempo di lavoro

| Attività | Tempo |
|----------|------:|
| Revisione e consolidamento della documentazione | 3 h 46 min |
| Operazioni di chiusura della sessione | 30 min |
| **Totale Sessione S008** | **4 h 16 min** |

Il tempo della revisione documentale è stato ricostruito parzialmente sulla base degli orari disponibili. Le operazioni finali comprendono l'aggiornamento del Quaderno di Sviluppo, le verifiche Git, il commit e il push sul repository GitHub.

### Prossimi passi

Con la conclusione della Sessione S008 termina il consolidamento del sistema documentale del progetto Orto Smart.

La successiva Sessione S009 sarà dedicata alla ripresa dello sviluppo software, proseguendo l'implementazione delle funzionalità previste dalla Roadmap di Sviluppo e mantenendo aggiornati i documenti del progetto secondo il Workflow Operativo definito.

La documentazione consolidata durante la S008 costituirà il riferimento ufficiale per tutte le future attività di sviluppo.

---

## 3.9 S009 – Evoluzione dell'architettura del Motore Agronomico

**Data:** Agosto 2026

**Versione interessata:** 0.1.3-alpha

---

### Obiettivo della sessione

Completare l'evoluzione dell'architettura del Motore Agronomico introducendo una pipeline di orchestrazione del processo di raccomandazione, migliorando la separazione delle responsabilità tra i componenti e preparando il sistema all'integrazione di nuovi motori agronomici.

L'obiettivo principale della sessione è stato sostituire il precedente flusso basato sul solo `SuggestionEngine` con un'architettura modulare centrata sulla `RecommendationPipeline`, mantenendo la piena compatibilità con l'interfaccia utente e con i componenti esistenti.

---

### Attività svolte

Durante la sessione sono state completate le seguenti attività:

- introduzione della `RecommendationPipeline` come componente di orchestrazione del processo di raccomandazione;
- trasformazione del `SuggestionEngine` in motore specializzato dedicato all'analisi degli spazi disponibili;
- introduzione di `RecommendationMapper` per la conversione dei risultati nel modello destinato all'interfaccia utente;
- riorganizzazione del flusso di elaborazione del Motore Agronomico, separando orchestrazione, analisi, interpretazione e presentazione;
- integrazione della nuova pipeline con `BedAnalysisService`;
- aggiornamento e ampliamento dei test automatici;
- verifica del corretto funzionamento dell'applicazione dopo il refactoring dell'architettura.

---

### Decisioni architetturali

Nel corso della sessione non sono state approvate nuove Decisioni Architetturali (ADR).

È stata invece completata l'implementazione operativa della **DEC-003 – Introduzione del Decision Engine**, mediante l'introduzione della `RecommendationPipeline` come componente responsabile dell'orchestrazione del processo di raccomandazione.

La `RecommendationPipeline` coordina i motori agronomici, raccoglie le valutazioni prodotte dai componenti specializzati e demanda al `DecisionEngine` la sola interpretazione dei risultati e la generazione delle raccomandazioni, nel rispetto della separazione delle responsabilità definita dalla DEC-003.

---

### File creati

Nel corso della sessione sono stati introdotti i seguenti nuovi componenti principali:

- `recommendation_pipeline.dart`
- `recommendation_mapper.dart`
- `family_recommendation.dart`
- `planting_recommendation.dart`
- relativi file di test automatici

---

### File modificati

Nel corso della sessione sono stati aggiornati i principali componenti del Motore Agronomico, tra cui:

- `bed_analysis_service.dart`
- `suggestion_engine.dart`
- `decision_engine.dart`
- componenti del Motore Agronomico interessati dal nuovo flusso di raccomandazione;
- test automatici del progetto.

---

### Database

Nel corso della sessione non sono state apportate modifiche alla struttura del database Supabase.

Le attività hanno riguardato esclusivamente l'architettura software del Motore Agronomico e il flusso di raccomandazione dell'applicazione.

---

### Test eseguiti

Al termine della sessione sono stati effettuati i seguenti controlli:

- `flutter analyze`
- `flutter test` (**72 test superati**)
- verifica del corretto funzionamento dell'applicazione dopo il refactoring della `RecommendationPipeline`
- verifica dell'assenza di regressioni nell'interfaccia utente

Tutte le verifiche sono state completate con esito positivo.

---

### Stato del progetto

Al termine della sessione il progetto dispone delle seguenti caratteristiche:

- architettura del Motore Agronomico riorganizzata secondo una pipeline di orchestrazione;
- `RecommendationPipeline` introdotta come componente centrale del processo di raccomandazione;
- `SuggestionEngine` trasformato in motore specializzato per l'analisi degli spazi disponibili;
- maggiore separazione delle responsabilità tra orchestrazione, analisi, interpretazione e presentazione;
- architettura predisposta per l'integrazione di nuovi motori agronomici;
- 72 test automatici superati senza regressioni funzionali.

---

### Git

#### Commit

```text
Introduce RecommendationPipeline and agronomic evaluation architecture

Sostituisce il vecchio SuggestionEngine con RecommendationPipeline
```

#### Push

Il push finale della Sessione S009 è stato completato correttamente al termine dell'aggiornamento documentale.

La sessione è stata successivamente consolidata con il commit:

`ea7b653 Consolida tempi e indicatori della Sessione S009`

al termine del quale il repository locale e quello remoto risultavano sincronizzati.

---

### Tempo di lavoro

| Attività | Tempo |
|-----------|------:|
| Sviluppo software | 3 h 40 min |
| Documentazione | 1 h 42 min |
| **Totale Sessione S009** | **5 h 22 min** |

---

### Esito della sessione

La Sessione S009 rappresenta un'importante evoluzione dell'architettura del Motore Agronomico di Orto Smart.

L'introduzione della `RecommendationPipeline` ha completato l'evoluzione del flusso di raccomandazione, consolidando la separazione delle responsabilità tra orchestrazione, analisi, interpretazione e presentazione, senza introdurre regressioni funzionali.

L'architettura risultante è più modulare, estendibile e pronta ad accogliere i futuri motori agronomici previsti dalla Roadmap di Sviluppo.

---

### Prossimi passi

Con la conclusione della Sessione S009 l'architettura del nuovo processo di raccomandazione risulta consolidata.

La successiva Sessione S010 sarà dedicata all'evoluzione delle funzionalità del Motore Agronomico previste dalla Roadmap di Sviluppo, proseguendo l'implementazione dei motori specialistici e mantenendo aggiornati il codice, la documentazione tecnica e il registro storico secondo il Workflow Operativo del progetto.

---

# Sessione S010 – Configurazione dei pesi del DecisionEngine

**Data:** 08/08/2026
**Stato:** Completata
**Tipo:** Sviluppo tecnico / evoluzione del Motore Agronomico

---

### Obiettivo della sessione

La Sessione S010 è stata dedicata al consolidamento del sistema decisionale del Motore Agronomico introdotto nelle sessioni precedenti.

L'obiettivo principale è stato rendere configurabili i pesi dei diversi criteri agronomici utilizzati dal `DecisionEngine`, evitando che tali valori rimanessero incorporati rigidamente nella logica del motore e predisponendo l'architettura all'introduzione futura di ulteriori criteri decisionali.

La configurazione standard definita nella sessione assegna i seguenti pesi:

- spazio: 40%;
- rotazione: 30%;
- consociazione: 30%.

---

### Attività svolte

Nel corso della Sessione S010 è stata introdotta una configurazione esplicita dei pesi utilizzati dal processo decisionale del Motore Agronomico.

È stato creato il componente:

- `lib/core/agronomy/scoring/decision_weights.dart`

contenente la classe `DecisionWeights`, responsabile della configurazione dei pesi associati ai criteri agronomici utilizzati dal `DecisionEngine`.

La classe gestisce i seguenti criteri:

- spazio;
- rotazione;
- consociazione.

Sono state inoltre introdotte:

- la proprietà `total`, utilizzata per calcolare la somma complessiva dei pesi;
- la validazione della configurazione;
- il controllo dell'assenza di valori negativi;
- la configurazione predefinita `DecisionWeights.standard`.

Il `DecisionEngine` è stato modificato affinché riceva la configurazione dei pesi mediante:

`DecisionEngine({this.weights = DecisionWeights.standard})`

Il motore verifica la validità della configurazione ricevuta e rifiuta configurazioni non valide mediante `ArgumentError`.

La `RecommendationPipeline` è stata adeguata per utilizzare esplicitamente `DecisionWeights.standard` nel processo di generazione delle raccomandazioni.

Questa evoluzione mantiene separata la configurazione dei criteri dalla logica decisionale e consente di modificare in futuro il peso relativo dei diversi fattori senza incorporare tali valori direttamente nel `DecisionEngine`.

---

### Test eseguiti

Nel corso della Sessione S010 sono stati aggiornati e ampliati i test automatici relativi al sistema decisionale del Motore Agronomico.

È stato creato:

- `test/core/agronomy/scoring/decision_weights_test.dart`

con verifiche relative a:

- configurazione standard 40/30/30;
- configurazione personalizzata valida;
- somma complessiva diversa da `1.0`;
- presenza di pesi negativi.

È stato inoltre aggiornato `decision_engine_test.dart` con verifiche relative a:

- generazione delle raccomandazioni;
- calcolo del punteggio ponderato;
- ordinamento delle raccomandazioni;
- motivazioni associate ai risultati;
- utilizzo di pesi personalizzati;
- rifiuto di configurazioni dei pesi non valide.

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – nessun errore rilevato;
- `flutter test` – **78 test automatici superati**.

La baseline di qualità raggiunta al termine della Sessione S010 è pertanto:

**78 test automatici superati e `flutter analyze` senza errori.**

---

### Decisioni architetturali

Nel corso della Sessione S010 non sono state approvate nuove Decisioni Architetturali (ADR).

È stata consolidata l'architettura decisionale già introdotta nelle sessioni precedenti, separando ulteriormente la configurazione dei criteri dalla logica del `DecisionEngine`.

L'introduzione di `DecisionWeights` consente al `DecisionEngine` di utilizzare configurazioni differenti senza modificare direttamente l'algoritmo di calcolo del punteggio.

La `RecommendationPipeline` mantiene il ruolo di orchestrazione del processo e utilizza la configurazione standard dei pesi per il sistema decisionale corrente.

---

### Progettazione delle evoluzioni future

Nella seconda parte della Sessione S010 è stata avviata la progettazione delle successive evoluzioni del Motore Agronomico.

Sono state distinte due responsabilità future:

- `FamilyNeedsEngine`, destinato alla valutazione delle priorità e dei fabbisogni familiari delle colture;
- `SuccessionPlanningEngine`, destinato alla pianificazione temporale delle coltivazioni e alla distribuzione delle produzioni nel tempo.

La separazione dei due motori ha l'obiettivo di evitare che la valutazione del fabbisogno familiare venga mescolata con la pianificazione delle successioni colturali.

Nel repository risultano già presenti:

- `lib/core/agronomy/engines/family_needs_engine.dart`;
- `lib/core/agronomy/models/family_recommendation.dart`.

Durante l'analisi è stata individuata in `FamilyRecommendation` un'incoerenza tra il tipo attualmente utilizzato per `cropId` e il tipo adottato dall'architettura corrente per `Crop.id`.

La correzione di tale incoerenza non è stata effettuata nella S010 ed è stata rinviata alla Sessione S011.

Il `FamilyNeedsEngine` e il futuro `SuccessionPlanningEngine` non fanno pertanto parte del flusso operativo della `RecommendationPipeline` consolidato nella S010.

---

### File creati

Nel corso della Sessione S010 è stato creato:

- `lib/core/agronomy/scoring/decision_weights.dart`;
- `test/core/agronomy/scoring/decision_weights_test.dart`.

---

### File modificati

Nel corso della Sessione S010 sono stati modificati i componenti interessati dalla configurazione dei pesi decisionali, tra cui:

- `lib/core/agronomy/engines/decision_engine.dart`;
- `lib/services/recommendation_pipeline.dart`;
- `test/core/agronomy/engines/decision_engine_test.dart`.

---

### Database

Nel corso della Sessione S010 non sono state apportate modifiche alla struttura o ai dati del database Supabase.

Le attività hanno riguardato esclusivamente il Motore Agronomico, la configurazione del sistema decisionale e i relativi test automatici.

---

### Stato del progetto

Al termine dello sviluppo della Sessione S010 il sistema decisionale del Motore Agronomico dispone delle seguenti caratteristiche:

- `RecommendationPipeline` come componente di orchestrazione del processo di raccomandazione;
- generazione dei candidati affidata al `SuggestionEngine`;
- valutazioni separate di spazio, rotazione e consociazione;
- `DecisionEngine` responsabile del calcolo del punteggio finale e dell'ordinamento delle raccomandazioni;
- `DecisionWeights` responsabile della configurazione dei pesi decisionali;
- configurazione standard 40% spazio, 30% rotazione e 30% consociazione;
- possibilità di utilizzare configurazioni personalizzate dei pesi;
- validazione preventiva della configurazione dei pesi;
- architettura predisposta all'introduzione futura di ulteriori criteri decisionali;
- 78 test automatici superati senza regressioni rilevate;
- `flutter analyze` completato senza errori.

---

### Git

#### Commit sviluppo

```text
89a0a04 Rende configurabili i pesi del DecisionEngine
```

Il commit `89a0a04` è stato pubblicato correttamente su GitHub.

Al termine della fase di sviluppo della Sessione S010 il repository locale e quello remoto risultavano sincronizzati e il working tree era pulito.

La documentazione della Sessione S010 viene aggiornata successivamente secondo il Workflow Operativo del progetto.

---

### Tempo di lavoro

| Attività                 |          Tempo |
| ------------------------ | -------------: |
| Sviluppo software        |         42 min |
| Documentazione           |     4 h 12 min |
| **Totale Sessione S010** | **4 h 54 min** |

Il tempo della Sessione S010 è stato consolidato considerando esclusivamente il lavoro effettivamente svolto.

La pausa pranzo dalle 13:59 alle 14:52, pari a 53 minuti, è stata esclusa integralmente dal conteggio.

---

### Esito della sessione

La Sessione S010 ha consolidato il sistema decisionale del Motore Agronomico introducendo una configurazione esplicita e validata dei pesi utilizzati dal `DecisionEngine`.

La separazione dei pesi dalla logica decisionale rende il sistema più configurabile ed estendibile e prepara l'architettura all'introduzione futura di ulteriori criteri di valutazione.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e 78 test automatici superati.

---

### Prossimi passi

La Sessione S011 sarà dedicata principalmente all'evoluzione del `FamilyNeedsEngine`.

Gli obiettivi fissati sono:

1. verificare completamente l'implementazione esistente di `FamilyNeedsEngine`;
2. verificare `FamilyRecommendation` e gli eventuali componenti collegati;
3. correggere in modo controllato l'incoerenza tra `int cropId` e `String cropId`;
4. definire formalmente input, output e responsabilità del `FamilyNeedsEngine`;
5. stabilire una prima versione del modello di fabbisogno familiare;
6. definire una rappresentazione semplice e sostenibile delle priorità familiari;
7. predisporre i relativi test automatici;
8. valutare l'integrazione con `RecommendationPipeline` soltanto dopo la verifica dei test;
9. mantenere separata la responsabilità del futuro `SuccessionPlanningEngine`;
10. rinviare la progettazione dettagliata del `SuccessionPlanningEngine` a uno step successivo, salvo la possibilità di definirne preliminarmente l'architettura.

Il checkpoint tecnico di partenza della S011 è:

- commit sviluppo: `89a0a04`;
- `flutter analyze`: superato;
- `flutter test`: 78/78;
- repository sincronizzato al termine dello sviluppo S010.

---

# Sessione S011 – Prima implementazione del FamilyNeedsEngine

**Data:** 08–09/08/2026
**Stato:** Completata
**Tipo:** Sviluppo tecnico / evoluzione del Motore Agronomico

---

### Obiettivo della sessione

La Sessione S011 è stata dedicata alla prima implementazione funzionante del `FamilyNeedsEngine`, componente destinato a rappresentare il fabbisogno familiare associato alle diverse colture.

L'obiettivo principale è stato introdurre un modello semplice e autonomo per esprimere la priorità attribuita dalla famiglia a una coltura, mantenendo tale responsabilità separata sia dalla valutazione agronomica sia dalla futura pianificazione temporale delle produzioni.

La sessione è partita dalla baseline tecnica consolidata nella S010:

- commit di riferimento documentale precedente: `128298b`;
- repository pulito e sincronizzato;
- `flutter analyze` senza errori;
- 78 test automatici superati.

---

### Attività svolte

Nel corso della Sessione S011 è stata innanzitutto corretta l'incoerenza individuata nella sessione precedente nel modello `FamilyRecommendation`.

Il campo:

`FamilyRecommendation.cropId`

è stato modificato da `int` a `String`, uniformandolo al tipo utilizzato dall'architettura corrente per gli identificativi delle colture.

È stato successivamente introdotto il modello:

- `FamilyCropNeed`

destinato a rappresentare il fabbisogno familiare associato a una specifica coltura.

È stata inoltre definita l'enumerazione:

- `FamilyNeedPriority.none`;
- `FamilyNeedPriority.low`;
- `FamilyNeedPriority.medium`;
- `FamilyNeedPriority.high`.

Il precedente stub del `FamilyNeedsEngine` è stato trasformato in una prima implementazione funzionante.

Il motore converte le priorità familiari nei seguenti valori numerici:

- `none` → `0.0`;
- `low` → `0.3`;
- `medium` → `0.6`;
- `high` → `1.0`.

Per ogni valutazione vengono inoltre prodotte motivazioni testuali comprensibili, in modo che il risultato non sia rappresentato esclusivamente da un valore numerico.

È stato stabilito che il `FamilyNeedsEngine` conserva l'ordine degli elementi ricevuti in ingresso.

---

### Responsabilità del FamilyNeedsEngine

La responsabilità attuale del `FamilyNeedsEngine` è limitata alla valutazione del fabbisogno o della priorità familiare di una coltura.

Il motore non determina:

- il numero di piante da coltivare;
- il numero di semine o trapianti;
- la distribuzione temporale delle coltivazioni;
- la successione dei lotti;
- la compatibilità agronomica complessiva della coltura.

Queste responsabilità rimangono separate.

In particolare è stata confermata la distinzione architetturale:

    FamilyNeedsEngine
            ↓
    fabbisogno / priorità familiare

    SuccessionPlanningEngine
            ↓
    quantità, lotti e distribuzione temporale

    RecommendationPipeline
            ↓
    coordinamento dei motori

Il futuro `SuccessionPlanningEngine` sarà destinato alla gestione delle semine e dei trapianti scalari, alla continuità del raccolto e alla prevenzione delle sovrapproduzioni concentrate in un unico periodo.

---

### Integrazione con il sistema decisionale

Nella Sessione S011 il `FamilyNeedsEngine` è stato mantenuto intenzionalmente autonomo.

Non è stato integrato nel:

- `DecisionEngine`;
- `RecommendationPipeline`.

Questa scelta evita di introdurre prematuramente il fabbisogno familiare nel punteggio complessivo prima di aver definito formalmente il suo rapporto con i criteri agronomici esistenti.

L'integrazione viene pertanto rinviata alla Sessione S012.

---

### Test eseguiti

Per il `FamilyNeedsEngine` sono stati aggiunti **6 nuovi test automatici**.

I test verificano il comportamento della prima implementazione del motore, compresa la gestione delle priorità familiari, la conversione nei relativi valori numerici, le motivazioni prodotte e il mantenimento dell'ordine degli input.

La baseline complessiva dei test è passata da:

**78 → 84 test automatici.**

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – **No issues found**;
- `flutter test` – **84/84 All tests passed**.

Non sono state rilevate regressioni rispetto alla baseline precedente.

---

### Decisioni architetturali

La Sessione S011 ha consolidato la separazione tra tre responsabilità differenti:

1. valutazione agronomica delle colture;
2. valutazione del fabbisogno familiare;
3. futura pianificazione della produzione nel tempo.

Il `FamilyNeedsEngine` rimane pertanto un componente autonomo che fornisce informazioni relative alle esigenze familiari senza modificare direttamente la valutazione agronomica.

È stato inoltre stabilito che un'elevata priorità familiare non dovrà, da sola, rendere consigliabile una coltura agronomicamente inappropriata.

La modalità precisa con cui questa regola verrà applicata nella pipeline sarà oggetto della progettazione della S012.

---

### Database

Nel corso della Sessione S011 non sono state apportate modifiche alla struttura o ai dati del database Supabase.

La prima versione del `FamilyNeedsEngine` riguarda esclusivamente il dominio applicativo e il Motore Agronomico.

La futura persistenza delle preferenze o dei fabbisogni familiari non è stata definita in questa sessione.

---

### Stato del progetto

Al termine della Sessione S011 il Motore Agronomico dispone anche di un primo componente autonomo per la rappresentazione delle esigenze familiari.

Lo stato raggiunto comprende:

- `FamilyRecommendation.cropId` allineato al tipo `String`;
- modello `FamilyCropNeed`;
- enumerazione `FamilyNeedPriority`;
- quattro livelli di priorità familiare;
- conversione delle priorità in valori numerici;
- motivazioni testuali associate alle valutazioni;
- mantenimento dell'ordine degli input;
- `FamilyNeedsEngine` ancora separato dal sistema decisionale principale;
- futura pianificazione temporale mantenuta separata nel previsto `SuccessionPlanningEngine`;
- 84 test automatici complessivi superati;
- `flutter analyze` senza errori.

---

### Git

#### Commit sviluppo

`e1f741e Implementa la prima versione del FamilyNeedsEngine`

Il commit è stato pubblicato correttamente su GitHub.

Al termine della fase di sviluppo della Sessione S011:

- `main = origin/main`;
- working tree pulito.

Il repository risultava quindi pulito e sincronizzato.

---

### Tempo di lavoro

|| Attività                 |       Tempo |
| ------------------------ | ----------: |
| Sviluppo software        |      37 min |
| Documentazione           |  1 h 50 min |
| **Totale Sessione S011** | **2 h 27 min** |

Il tempo di sviluppo comprende esclusivamente il lavoro effettivamente svolto.

La sospensione tra l'8 e il 9 agosto 2026 è stata esclusa integralmente dal conteggio.

Il tempo dedicato alla documentazione è stato registrato separatamente nella sessione Manuali S011 e consolidato alla chiusura.

---

### Esito della sessione

La Sessione S011 ha introdotto la prima versione funzionante del `FamilyNeedsEngine`, trasformando il precedente componente preliminare in un motore dotato di un modello esplicito delle esigenze familiari e coperto da test automatici.

L'architettura mantiene intenzionalmente separati il fabbisogno familiare, la valutazione agronomica e la futura pianificazione temporale delle produzioni.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **84 test automatici superati**.

---

### Prossimi passi

La Sessione S012 sarà dedicata principalmente alla progettazione dell'integrazione del fabbisogno familiare nel sistema complessivo di raccomandazione.

Gli obiettivi fissati sono:

1. stabilire dove inserire il `FamilyNeedsEngine` nella `RecommendationPipeline`;
2. determinare se il fabbisogno familiare debba costituire un quarto fattore del punteggio, un bonus oppure un criterio distinto;
3. impedire che una forte esigenza familiare possa rendere consigliabile una coltura agronomicamente inappropriata;
4. valutare l'evoluzione di `DecisionWeights`, attualmente configurato secondo lo schema 40/30/30;
5. definire il comportamento del sistema quando non sono disponibili informazioni sul fabbisogno familiare;
6. valutare le eventuali modifiche necessarie a `CandidateAgronomicEvaluation` e `PlantingRecommendation`;
7. definire i nuovi test necessari prima dell'integrazione;
8. soltanto dopo queste decisioni, realizzare l'integrazione minima nella `RecommendationPipeline` e verificare l'intera suite.

Il futuro `SuccessionPlanningEngine` non costituisce l'obiettivo principale della S012 e rimane previsto per uno step successivo dedicato alla pianificazione delle colture nel tempo.

Il checkpoint tecnico di partenza della S012 è:

- commit sviluppo: `e1f741e`;
- `flutter analyze`: superato;
- `flutter test`: 84/84;
- repository pulito e sincronizzato al termine dello sviluppo S011.

---

# Sessione S012 – Integrazione del FamilyNeedsEngine nella RecommendationPipeline

**Data:** 09/08/2026
**Stato:** Completata
**Tipo:** Sviluppo tecnico / evoluzione del sistema di raccomandazione

---

### Obiettivo della sessione

La Sessione S012 è stata dedicata all'integrazione della prima versione del `FamilyNeedsEngine` nella `RecommendationPipeline`.

L'obiettivo principale è stato stabilire come utilizzare le esigenze familiari nel processo complessivo di raccomandazione senza compromettere la correttezza agronomica delle valutazioni già prodotte dal sistema.

La sessione è partita dal checkpoint tecnico consolidato nella S011:

- commit sviluppo: `e1f741e`;
- `flutter analyze`: superato;
- `flutter test`: 84/84;
- repository pulito e sincronizzato;
- `FamilyNeedsEngine` disponibile come componente autonomo ma non ancora integrato nella `RecommendationPipeline`.

---

### Decisione progettuale

Nel corso della S012 è stato stabilito che il fabbisogno familiare non deve diventare un quarto peso del `DecisionEngine`.

Il punteggio agronomico continua pertanto a essere calcolato esclusivamente mediante i tre criteri già definiti:

- spazio: 40%;
- rotazione: 30%;
- consociazione: 30%.

Le esigenze familiari intervengono invece successivamente come criterio gerarchico di ordinamento delle raccomandazioni.

L'ordinamento adottato è:

    1. Fascia agronomica
    2. Priorità familiare
    3. Punteggio agronomico

Questa soluzione consente di favorire una coltura maggiormente richiesta dalla famiglia soltanto quando le alternative appartengono alla stessa fascia agronomica.

Una priorità familiare elevata non può quindi rendere preferibile una coltura appartenente a una fascia agronomica inferiore.

---

### Attività svolte

La `RecommendationPipeline` è stata estesa introducendo il parametro opzionale:

`familyNeeds`

Il parametro consente alla pipeline di ricevere le informazioni relative alle esigenze familiari senza rendere obbligatoria la presenza di tali dati.

La pipeline utilizza il `FamilyNeedsEngine` per valutare le priorità familiari e associa i risultati alle colture mediante il relativo `cropId`.

È stata introdotta una classificazione interna delle raccomandazioni in fasce agronomiche mediante:

`_ratingBand()`

L'ordinamento finale delle raccomandazioni utilizza quindi, in ordine gerarchico:

1. fascia agronomica;
2. priorità familiare;
3. punteggio agronomico.

---

### Integrazione del FamilyNeedsEngine

Il `FamilyNeedsEngine` è ora integrato nella `RecommendationPipeline`.

La sua integrazione non modifica direttamente il punteggio prodotto dal `DecisionEngine`.

Il processo può essere rappresentato sinteticamente come:

    Motori agronomici
            ↓
    DecisionEngine
            ↓
    punteggio e fascia agronomica
            ↓
    FamilyNeedsEngine
            ↓
    priorità familiare
            ↓
    ordinamento finale della RecommendationPipeline

La `RecommendationPipeline` mantiene pertanto il ruolo di coordinamento del processo complessivo di raccomandazione.

---

### DecisionWeights

La configurazione `DecisionWeights` rimane invariata.

La configurazione standard continua a essere:

- spazio: 40%;
- rotazione: 30%;
- consociazione: 30%.

Non è stato introdotto un peso dedicato alle esigenze familiari.

Questa scelta mantiene separati:

- il punteggio agronomico;
- la priorità familiare.

---

### Protezione della correttezza agronomica

Una delle condizioni fondamentali definite nella S012 è che il fabbisogno familiare non possa annullare o superare una differenza significativa nella qualità agronomica delle raccomandazioni.

Per questo motivo la priorità familiare viene applicata soltanto dopo la classificazione delle raccomandazioni nelle rispettive fasce agronomiche.

L'ordine gerarchico:

    fascia agronomica
        ↓
    priorità familiare
        ↓
    punteggio agronomico

garantisce che una coltura con priorità familiare elevata possa essere favorita rispetto a un'altra solamente quando entrambe appartengono alla stessa fascia agronomica.

---

### Test eseguiti

Nel corso della Sessione S012 sono stati aggiunti **2 nuovi test automatici** dedicati all'integrazione delle esigenze familiari nella `RecommendationPipeline`.

I test verificano:

1. che la priorità familiare possa modificare l'ordine delle raccomandazioni appartenenti alla stessa fascia agronomica;
2. che una priorità familiare elevata non possa superare una raccomandazione appartenente a una fascia agronomica superiore.

La baseline complessiva dei test è passata da:

**84 → 86 test automatici.**

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – **No issues found**;
- `flutter test` – **86/86 All tests passed**.

Non sono state rilevate regressioni rispetto alla baseline precedente.

---

### Decisioni architetturali

La Sessione S012 ha definito formalmente il rapporto tra valutazione agronomica e fabbisogno familiare nel processo di raccomandazione.

Il fabbisogno familiare:

- non modifica direttamente il punteggio agronomico;
- non viene aggiunto a `DecisionWeights`;
- viene utilizzato come criterio gerarchico successivo alla fascia agronomica;
- può modificare l'ordine soltanto tra raccomandazioni appartenenti alla stessa fascia agronomica.

Questa scelta mantiene separata la valutazione tecnica agronomica dalla preferenza familiare e preserva il principio secondo cui una coltura agronomicamente meno appropriata non deve diventare preferibile soltanto perché maggiormente richiesta.

La decisione dovrà essere registrata nel DOC-011 – Decisioni Architetturali.

---

### Database

Nel corso della Sessione S012 non sono state apportate modifiche alla struttura o ai dati del database Supabase.

L'integrazione del `FamilyNeedsEngine` riguarda esclusivamente il dominio applicativo e il processo di raccomandazione.

La persistenza futura delle esigenze familiari rimane una possibilità da progettare in una fase successiva.

---

### Stato del progetto

Al termine della Sessione S012 il sistema di raccomandazione dispone delle seguenti caratteristiche:

- `FamilyNeedsEngine` integrato nella `RecommendationPipeline`;
- parametro opzionale `familyNeeds`;
- associazione delle priorità familiari mediante `cropId`;
- classificazione delle raccomandazioni in fasce agronomiche;
- ordinamento gerarchico basato su fascia agronomica, priorità familiare e punteggio agronomico;
- `DecisionWeights` invariato con configurazione 40/30/30;
- separazione tra punteggio agronomico e priorità familiare;
- protezione contro il superamento di una fascia agronomica superiore mediante la sola priorità familiare;
- 86 test automatici complessivi superati;
- `flutter analyze` senza errori.

---

### Git

#### Commit sviluppo

`bf90a62 Integra le esigenze familiari nella RecommendationPipeline`

Il commit è stato pubblicato correttamente su GitHub.

Al termine della fase di sviluppo della Sessione S012:

- `main = origin/main`;
- working tree pulito.

Il repository risultava quindi pulito e sincronizzato.

---

### Tempo di lavoro

| Attività                 |      Tempo |
| ------------------------ | ---------: |
| Sviluppo software        |     53 min |
| Documentazione           |     49 min |
| **Totale Sessione S012** | **1 h 42 min** |

Il tempo indicato comprende esclusivamente il lavoro effettivamente svolto.

La documentazione della Sessione S012 è stata svolta in due tranche:

- 09/08/2026 dalle 20:38 alle 20:53: 15 min;
- 10/08/2026 dalle 00:03 alle 00:37: 34 min.

La sospensione dalle 20:53 alle 00:03 è stata esclusa integralmente dal conteggio.

---

### Esito della sessione

La Sessione S012 ha completato la prima integrazione del `FamilyNeedsEngine` nella `RecommendationPipeline`.

La soluzione adottata mantiene invariato il punteggio agronomico e utilizza le esigenze familiari come criterio gerarchico di ordinamento, preservando la priorità della correttezza agronomica.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **86 test automatici superati**.

---

### Prossimi passi

La Sessione S013 sarà dedicata al consolidamento dell'integrazione appena introdotta e alla progettazione del modo in cui il criterio familiare verrà esposto al resto dell'applicazione e all'utente.

Gli obiettivi preliminari sono:

1. verificare come rappresentare e fornire le esigenze familiari al livello applicativo;
2. stabilire come consentire all'utente di definire o modificare le priorità familiari;
3. mantenere separata la logica di priorità dalla futura gestione delle quantità;
4. preparare il passaggio dal concetto di priorità familiare al concetto di fabbisogno quantitativo;
5. progettare successivamente il collegamento con la pianificazione scalare delle coltivazioni.

L'evoluzione prevista rimane:

    FamilyNeedsEngine
            ↓
    priorità / fabbisogno familiare
            ↓
    quantità familiari
            ↓
    pianificazione scalare delle colture

Il checkpoint tecnico di partenza della S013 è:

- commit sviluppo: `bf90a62`;
- `flutter analyze`: superato;
- `flutter test`: 86/86;
- repository pulito e sincronizzato al termine dello sviluppo S012.

---

# Sessione S013 – Fabbisogni quantitativi e lotti di coltivazione pianificati

**Data:** 10/08/2026
**Stato:** Completata
**Tipo:** Sviluppo tecnico / preparazione del SuccessionPlanningEngine

### Obiettivo della sessione

La Sessione S013 è stata dedicata alla preparazione delle fondamenta dati e di validazione necessarie alla futura implementazione del `SuccessionPlanningEngine`.

L'obiettivo principale è stato introdurre i modelli necessari per rappresentare quantitativamente il fabbisogno familiare nel tempo e i relativi lotti di coltivazione pianificati, mantenendo separate le responsabilità già definite nell'architettura del Motore Agronomico.

La sessione è partita dalla baseline tecnica consolidata nella S012:

- commit sviluppo: `bf90a62`;
- `flutter analyze`: superato;
- `flutter test`: 86/86;
- repository pulito e sincronizzato.

### Attività svolte

Nel corso della Sessione S013 sono stati introdotti quattro nuovi componenti principali.

#### PlannedPlantingBatch

È stato introdotto il modello `PlannedPlantingBatch`, destinato a rappresentare un lotto di coltivazione pianificato nel tempo.

Il modello costituisce la futura unità operativa prodotta dal `SuccessionPlanningEngine` e permette di mantenere distinta la pianificazione temporale dalle informazioni relative al fabbisogno familiare.

#### PlannedPlantingBatchValidator

È stato introdotto `PlannedPlantingBatchValidator`, responsabile della validazione dei dati necessari alla rappresentazione dei lotti pianificati.

La presenza di un validatore dedicato consente di mantenere separate la struttura dei dati e le relative regole di validità.

#### FamilyConsumptionNeed

È stato introdotto il modello `FamilyConsumptionNeed`, separato da `FamilyCropNeed`.

`FamilyCropNeed` continua a rappresentare la priorità attribuita dalla famiglia a una coltura, mentre `FamilyConsumptionNeed` descrive quantitativamente il consumo familiare nel tempo.

Il modello comprende:

- `cropId`;
- `quantity`;
- `unit`;
- `intervalDays`.

Sono previste inizialmente le seguenti unità:

- pezzi;
- grammi;
- chilogrammi.

Questa distinzione permette di rappresentare separatamente concetti differenti quali:

- quanto una coltura sia desiderata dalla famiglia;
- quale quantità della coltura sia necessaria;
- con quale periodicità tale quantità debba essere disponibile.

#### FamilyConsumptionNeedValidator

È stato introdotto `FamilyConsumptionNeedValidator`, responsabile della validazione dei fabbisogni quantitativi familiari.

Il validatore impedisce in particolare la definizione di fabbisogni caratterizzati da:

- coltura non specificata;
- quantità minore o uguale a zero;
- intervallo minore o uguale a zero.

### Separazione delle responsabilità

La Sessione S013 ha ulteriormente precisato la separazione delle responsabilità relative alle esigenze familiari e alla futura pianificazione temporale.

L'architettura prevista è:

    FamilyCropNeed
            ↓
    priorità familiare

    FamilyConsumptionNeed
            ↓
    quantità necessaria nel tempo

    PlannedPlantingBatch
            ↓
    lotto operativo pianificato

    SuccessionPlanningEngine
            ↓
    distribuzione temporale dei lotti

`FamilyCropNeed` e `FamilyConsumptionNeed` rappresentano pertanto due informazioni differenti e non devono essere sovrapposti.

Il primo esprime una priorità qualitativa, mentre il secondo introduce il fabbisogno quantitativo e periodico necessario alla futura pianificazione delle produzioni.

### Modalità operative di coltivazione

Durante la progettazione della futura pianificazione sono state individuate quattro modalità operative che il sistema dovrà progressivamente contemplare:

1. acquisto di piantine e successivo trapianto;
2. semina in semenzaio seguita da trapianto;
3. semina diretta a file nell'aiuola;
4. semina diretta a spaglio nell'aiuola.

Queste modalità richiedono criteri di pianificazione differenti.

Per la semina diretta a file, la pianificazione dovrà essere basata sul numero di **piante finali previste**, anziché sulla sola quantità di seme utilizzata.

La quantità di seme costituisce infatti un'informazione operativa, ma non rappresenta direttamente la quantità di prodotto che sarà resa disponibile alla famiglia.

Per la semina diretta a spaglio, la pianificazione dovrà invece poter utilizzare l'**area coltivata prevista** come riferimento operativo.

La quantità di seme rimane anche in questo caso un dato utile alla gestione della coltivazione, ma non deve essere considerata equivalente alla produzione finale.

### Relazione con il SuccessionPlanningEngine

Nella Sessione S013 non è stato ancora implementato il `SuccessionPlanningEngine`.

Sono state invece realizzate le strutture necessarie affinché la sua prima implementazione possa operare su dati espliciti, separati e validati.

Il flusso concettuale previsto è:

    fabbisogno familiare quantitativo
            +
    caratteristiche produttive della coltura o varietà
            +
    periodo di consumo desiderato
            ↓
    SuccessionPlanningEngine
            ↓
    serie di PlannedPlantingBatch

La prima versione del motore dovrà essere deterministica e testabile.

Le successive evoluzioni potranno progressivamente considerare ulteriori fattori quali:

- giorni al raccolto;
- resa prevista della varietà;
- metodo di impianto;
- spazio disponibile;
- rotazioni;
- consociazioni;
- stagionalità;
- condizioni meteorologiche.

### Test eseguiti

La Sessione S013 è partita da una baseline di **86 test automatici**.

Sono stati aggiunti:

- 3 test per `PlannedPlantingBatch`;
- 7 test per `PlannedPlantingBatchValidator`;
- 2 test per `FamilyConsumptionNeed`;
- 6 test per `FamilyConsumptionNeedValidator`.

Sono stati quindi introdotti complessivamente **18 nuovi test automatici**.

La baseline complessiva è passata da:

**86 → 104 test automatici.**

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – **No issues found**;
- `flutter test` – **104/104 All tests passed**.

Non sono state rilevate regressioni rispetto alla baseline precedente.

### Decisioni progettuali

La Sessione S013 ha consolidato i seguenti principi:

1. la priorità familiare e il fabbisogno quantitativo familiare rappresentano concetti distinti;
2. `FamilyCropNeed` continua a rappresentare la priorità familiare;
3. `FamilyConsumptionNeed` rappresenta quantità e periodicità del consumo;
4. `PlannedPlantingBatch` rappresenta il lotto operativo pianificato;
5. la quantità di seme non deve essere considerata equivalente alla produzione finale;
6. la semina diretta a file dovrà essere pianificata considerando le piante finali previste;
7. la semina a spaglio dovrà poter essere pianificata considerando l'area coltivata prevista;
8. il futuro `SuccessionPlanningEngine` rimane responsabile della distribuzione temporale dei lotti.

### Database

Nel corso della Sessione S013 non sono state indicate modifiche alla struttura o ai dati del database Supabase.

I nuovi componenti riguardano il dominio applicativo e la preparazione del futuro sistema di pianificazione.

L'eventuale persistenza dei fabbisogni quantitativi e dei lotti pianificati dovrà essere definita separatamente quando tale necessità verrà affrontata.

### Stato del progetto

Al termine della Sessione S013 Orto Smart dispone delle prime strutture esplicite necessarie alla futura pianificazione quantitativa e temporale delle coltivazioni.

Lo stato raggiunto comprende:

- modello `PlannedPlantingBatch`;
- `PlannedPlantingBatchValidator`;
- modello `FamilyConsumptionNeed`;
- `FamilyConsumptionNeedValidator`;
- separazione tra priorità familiare e fabbisogno quantitativo;
- rappresentazione della periodicità mediante `intervalDays`;
- prime unità quantitative: pezzi, grammi e chilogrammi;
- definizione delle quattro modalità operative di coltivazione da considerare nella futura pianificazione;
- distinzione tra quantità di seme e produzione finale prevista;
- predisposizione architetturale per il futuro `SuccessionPlanningEngine`;
- 104 test automatici complessivi superati;
- `flutter analyze` senza errori.

### Git

#### Commit sviluppo

`9dfbcf6 Introduce fabbisogni quantitativi e lotti pianificati`

Il commit comprende:

- 8 file modificati;
- 398 inserimenti.

Il commit è stato pubblicato correttamente su GitHub.

Al termine dello sviluppo della Sessione S013:

- `main = origin/main`;
- working tree pulito.

### Tempo di lavoro

| Attività                 |      Tempo |
| ------------------------ | ---------: |
| Sviluppo software        | 1 h 23 min |
| Documentazione           |     44 min |
| **Totale Sessione S013** | **2 h 07 min** |

Il tempo indicato comprende esclusivamente il lavoro effettivamente svolto.

La fase di sviluppo della S013 si è svolta il 10/08/2026 dalle 10:44 alle 12:20, con una pausa dalle 10:50 alle 11:03 esclusa integralmente dal conteggio.

La Sessione Manuali S013 si è svolta il 10/08/2026 dalle 12:23 alle 13:07, senza pause dichiarate.

Il tempo complessivo effettivo della Sessione S013 è pertanto pari a 2 h 07 min.

### Esito della sessione

La Sessione S013 ha predisposto le fondamenta dati e di validazione necessarie alla futura pianificazione scalare delle coltivazioni.

La distinzione tra `FamilyCropNeed` e `FamilyConsumptionNeed` consente ora di separare chiaramente la priorità qualitativa attribuita a una coltura dalla quantità effettivamente necessaria alla famiglia nel tempo.

L'introduzione di `PlannedPlantingBatch` fornisce inoltre il modello destinato a rappresentare i singoli lotti prodotti dal futuro sistema di pianificazione.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **104 test automatici superati**.

### Prossimi passi

La Sessione S014 sarà dedicata alla prima implementazione del `SuccessionPlanningEngine`.

L'obiettivo principale sarà realizzare una prima versione deterministica e testabile capace di trasformare un fabbisogno familiare quantitativo e periodico in una sequenza temporale validata di `PlannedPlantingBatch`.

Il flusso iniziale previsto è:

    fabbisogno familiare
            +
    caratteristiche produttive della coltura/varietà
            +
    periodo di consumo desiderato
            ↓
    SuccessionPlanningEngine
            ↓
    serie di PlannedPlantingBatch

La prima implementazione dovrà concentrarsi sulla generazione deterministica dei lotti senza anticipare l'intero sistema agronomico futuro.

Le evoluzioni successive potranno integrare progressivamente:

- giorni al raccolto;
- resa prevista della varietà;
- metodo di impianto;
- spazio disponibile;
- rotazioni;
- consociazioni;
- stagionalità;
- condizioni meteorologiche.

Il checkpoint tecnico di partenza della S014 è:

- commit sviluppo: `9dfbcf6`;
- `flutter analyze`: superato;
- `flutter test`: 104/104;
- repository pulito e sincronizzato al termine dello sviluppo S013.