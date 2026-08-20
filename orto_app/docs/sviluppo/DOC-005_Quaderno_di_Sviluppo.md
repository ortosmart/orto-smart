# ORTO SMART

### DOC-005

# Quaderno di Sviluppo

**Versione:** 0.6
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 26/07/2026
**Ultimo aggiornamento:** 18/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-005 |
| Titolo | Quaderno di Sviluppo |
| Versione | 0.6 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 18/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|----------------------------------------------|
| 0.1 | 26/07/2026 | Prima emissione del Quaderno di Sviluppo |
| 0.2 | 31/07/2026 | Riorganizzazione della struttura documentale e uniformazione al DOC-001 |
| 0.3      | 08/08/2026 | Aggiornamento del Quaderno con consolidamento delle Sessioni S009 e S010 |
| 0.4 | 16/08/2026 | Riallineamento strutturale del Quaderno fino alla S017 e documentazione della progettazione e del congelamento del Database V1 |
| 0.5 | 16/08/2026 | Aggiornamento del Quaderno con la Sessione S018: supporto alle finestre agronomiche multiple, preparazione dell'ambiente Supabase locale e predisposizione della futura baseline SQL Database V1 |
| 0.6 | 18/08/2026 | Aggiornamento del Quaderno con la Sessione S019: prima migration Database V1, implementazione delle Fondazioni, schema `private`, helper autorizzativi, trigger metadata, prima matrice RLS e verifiche locali di sicurezza |

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
| S011 | 09/08/2026 | 2 h 27 min | 53 h 14 min | Prima implementazione del FamilyNeedsEngine | ✅ |
| S012 | 09/08/2026 | 1 h 42 min | 54 h 56 min | Integrazione del FamilyNeedsEngine nella RecommendationPipeline | ✅ |
| S013 | 10/08/2026 | 2 h 07 min | 57 h 03 min | Fabbisogni quantitativi e lotti di coltivazione pianificati | ✅ |
| S014 | 11/08/2026 | 2 h 46 min | 59 h 49 min | Prima implementazione del SuccessionPlanningEngine | ✅ |
| S015 | 11/08/2026 | 1 h 59 min | 61 h 48 min | Prima implementazione delle finestre agronomiche | ✅ |
| S016 | 11–12/08/2026 | 2 h 02 min | 63 h 50 min | Associazione delle finestre agronomiche a colture e varietà | ✅ |
| S017 | 12–16/08/2026 | 25 h 14 min | 89 h 04 min | Progettazione e congelamento del Database V1 | ✅ |
| S018 | 16/08/2026 | 3 h 56 min | 93 h 00 min | Finestre agronomiche multiple e preparazione ambiente Supabase locale | ✅ |
| S019 | 17–18/08/2026 | 8 h 13 min | 101 h 13 min | Prima migration Database V1, Fondazioni e sicurezza RLS | ✅ |

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
3.10 S010
3.11 S011
3.12 S012
3.13 S013
3.14 S014
3.15 S015
3.16 S016
3.17 S017
3.18 S018
3.19 S019

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

---

# Sessione S014 – Prima implementazione del SuccessionPlanningEngine

**Data:** 10–11/08/2026
**Stato:** Completata
**Tipo:** Sviluppo tecnico / pianificazione temporale delle coltivazioni

### Obiettivo della sessione

La Sessione S014 è stata dedicata alla prima implementazione del `SuccessionPlanningEngine`, utilizzando le fondamenta dati e di validazione predisposte nella Sessione S013.

L'obiettivo principale è stato realizzare una prima versione deterministica e testabile capace di trasformare un `FamilyConsumptionNeed` in una sequenza temporale di `PlannedPlantingBatch`, mantenendo esplicite e controllate le conversioni tra fabbisogno familiare e quantità di impianto.

La sessione è partita dalla baseline tecnica consolidata nella S013:

- commit sviluppo: `9dfbcf6`;
- `flutter analyze`: superato;
- `flutter test`: 104/104;
- repository pulito e sincronizzato.

### Attività svolte

Nel corso della Sessione S014 è stata implementata la prima versione del `SuccessionPlanningEngine`.

Il nuovo componente è stato creato in:

```text
lib/core/agronomy/engines/succession_planning_engine.dart
```

con relativo file di test:

```text
test/core/agronomy/engines/succession_planning_engine_test.dart
```

### SuccessionPlanningEngine V1

La prima versione del `SuccessionPlanningEngine` trasforma un fabbisogno familiare quantitativo e periodico in una sequenza temporale di lotti pianificati.

Il motore:

- valida il `FamilyConsumptionNeed` mediante `FamilyConsumptionNeedValidator`;
- rifiuta intervalli nei quali `startDate > endDate`;
- genera il primo lotto alla data iniziale;
- genera i lotti successivi secondo `intervalDays`;
- include un lotto soltanto se la relativa data rimane entro `endDate`;
- propaga il `cropId`;
- supporta un `varietyId` opzionale;
- valida ogni lotto mediante `PlannedPlantingBatchValidator`;
- impedisce combinazioni incoerenti tra metodo di avvio e tipo di quantità.

La validazione di `intervalDays` impedisce inoltre valori minori o uguali a zero, evitando che la generazione temporale possa produrre un ciclo infinito.

Il comportamento temporale della V1 può essere rappresentato come:

```text
FamilyConsumptionNeed
        +
startDate
        +
endDate
        ↓
SuccessionPlanningEngine
        ↓
PlannedPlantingBatch 1
        ↓ intervalDays
PlannedPlantingBatch 2
        ↓ intervalDays
PlannedPlantingBatch 3
        ↓
...
fino a endDate
```

### Regola sulle conversioni

Durante la Sessione S014 è stato stabilito un principio fondamentale per l'evoluzione del sistema:

> Il `SuccessionPlanningEngine` non deve inventare conversioni tra fabbisogno familiare e quantità di impianto quando non dispone delle informazioni agronomiche necessarie.

Nella V1 viene pertanto ammessa esclusivamente la conversione:

```text
pieces → plants
```

Sono invece esplicitamente rifiutate conversioni quali:

```text
pieces → areaSquareCm
kilograms → plants
```

e, più in generale, tutte le conversioni che richiederebbero informazioni agronomiche non ancora disponibili.

Ad esempio, un fabbisogno familiare di 5 kg di pomodori non può essere interpretato automaticamente come 5 piante di pomodoro.

Analogamente, un fabbisogno espresso in pezzi non può essere trasformato arbitrariamente in una determinata superficie da seminare.

Questa regola mantiene espliciti i limiti conoscitivi del motore ed evita di introdurre assunzioni agronomiche non supportate dai dati.

### Evoluzione temporale e agronomica

La Sessione S014 ha inoltre chiarito che la semplice successione temporale dei lotti non sarà sufficiente per la versione evoluta del sistema.

Occorrerà distinguere almeno quattro momenti concettualmente differenti:

```text
quando la famiglia desidera il prodotto
        ↓
quando dovrebbe essere disponibile il raccolto
        ↓
quando occorre seminare o trapiantare
        ↓
se quella data è agronomicamente possibile
```

Il `SuccessionPlanningEngine` V1 genera attualmente una successione temporale deterministica.

La futura evoluzione dovrà invece permettere di verificare la compatibilità delle date teoriche con le caratteristiche agronomiche della coltura.

Tra i fattori che dovranno essere progressivamente considerati rientrano:

- finestra di semina in semenzaio;
- finestra di semina diretta;
- finestra di trapianto;
- periodo di raccolta;
- temperature minime;
- rischio di gelo;
- localizzazione climatica dell'orto.

La futura architettura non dovrà dipendere esclusivamente da una classificazione rigida Nord/Centro/Sud.

Tale classificazione potrà eventualmente costituire una prima indicazione, ma il sistema dovrà rimanere predisposto all'utilizzo della posizione reale dell'orto e dei dati meteorologici locali.

### Test eseguiti

La Sessione S014 è partita da una baseline di **104 test automatici**.

Sono stati aggiunti:

- 8 test dedicati al `SuccessionPlanningEngine`.

La baseline complessiva è quindi passata da:

**104 → 112 test automatici.**

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – **No issues found!**
- `flutter test` – **112/112 All tests passed**.

Non sono state rilevate regressioni rispetto alla baseline precedente.

### Decisioni progettuali

La Sessione S014 ha consolidato i seguenti principi:

1. il `SuccessionPlanningEngine` deve produrre una sequenza temporale deterministica di `PlannedPlantingBatch`;
2. il fabbisogno ricevuto deve essere validato prima della pianificazione;
3. ogni lotto prodotto deve essere validato;
4. il motore non deve inventare conversioni non supportate da informazioni agronomiche disponibili;
5. nella V1 è ammessa esclusivamente la conversione `pieces → plants`;
6. conversioni che richiedono informazioni produttive o agronomiche aggiuntive devono essere rifiutate;
7. la successione temporale deve rimanere distinta dalla futura verifica della compatibilità agronomica delle date;
8. la futura gestione della stagionalità dovrà essere predisposta all'utilizzo della localizzazione reale e dei dati meteorologici locali.

### Database

Nel corso della Sessione S014 non sono state introdotte modifiche alla struttura o ai dati del database Supabase.

Il nuovo `SuccessionPlanningEngine` opera nel dominio applicativo sui modelli già predisposti nella Sessione S013.

La persistenza dei fabbisogni quantitativi e dei lotti pianificati rimane una responsabilità da progettare separatamente quando necessaria.

### Stato del progetto

Al termine della Sessione S014 Orto Smart dispone della prima versione operativa del `SuccessionPlanningEngine`.

Lo stato raggiunto comprende:

- `SuccessionPlanningEngine` V1;
- generazione deterministica dei lotti secondo `intervalDays`;
- gestione dell'intervallo `startDate`–`endDate`;
- propagazione di `cropId`;
- supporto del `varietyId` opzionale;
- validazione del fabbisogno in ingresso;
- validazione dei lotti generati;
- controllo delle combinazioni tra metodo di avvio e tipo di quantità;
- principio di non introduzione di conversioni agronomiche arbitrarie;
- conversione V1 `pieces → plants`;
- predisposizione concettuale alla futura validazione delle finestre agronomiche;
- 112 test automatici complessivi superati;
- `flutter analyze` senza errori.

### Git

#### Commit sviluppo

`e19ae1a Implementa la prima versione del SuccessionPlanningEngine`

Il commit comprende:

- 2 file aggiunti;
- 231 inserimenti.

Il commit è stato pubblicato correttamente su GitHub.

Al termine dello sviluppo della Sessione S014:

- `main = origin/main`;
- working tree pulito.

### Tempo di lavoro

| Attività                 |      Tempo |
| ------------------------ | ---------: |
| Sviluppo software        | 1 h 32 min |
| Documentazione           | 1 h 14 min |
| **Totale Sessione S014** | **2 h 46 min** |

Il tempo indicato comprende esclusivamente il lavoro effettivamente svolto.

La fase di sviluppo della S014 è iniziata il 10/08/2026 alle 16:13 ed è stata sospesa alle 16:33.

La sessione è ripresa l'11/08/2026 alle 09:25 e la fase di sviluppo si è conclusa alle 10:37.

La sospensione dalle 16:33 del 10/08/2026 alle 09:25 dell'11/08/2026 è stata esclusa integralmente dal conteggio.

Il tempo effettivo di sviluppo della Sessione S014 è pertanto pari a 1 h 32 min.

La Sessione Manuali S014 si è svolta l'11/08/2026 dalle 10:50 alle 12:04, senza pause dichiarate.

Il tempo effettivo di documentazione è pari a 1 h 14 min.

Il tempo complessivo effettivo della Sessione S014 è pertanto pari a 2 h 46 min.

### Esito della sessione

La Sessione S014 ha raggiunto l'obiettivo previsto introducendo la prima versione deterministica e testabile del `SuccessionPlanningEngine`.

Il sistema è ora in grado di trasformare un fabbisogno familiare quantitativo e periodico compatibile con le regole della V1 in una sequenza temporale validata di `PlannedPlantingBatch`.

La scelta di rifiutare conversioni non supportate impedisce al motore di introdurre assunzioni arbitrarie sulla relazione tra quantità consumata e quantità da coltivare.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **112 test automatici superati**.

### Prossimi passi

La Sessione S015 sarà dedicata alla progettazione e alla prima implementazione del sistema di finestre agronomiche.

Prima di definire nuovi modelli o motori dovrà essere verificato quali dati di calendario colturale siano già disponibili nei modelli e nel database di Orto Smart.

L'obiettivo preliminare è separare le date teoriche prodotte dalla pianificazione dalla verifica della loro effettiva compatibilità con il ciclo colturale.

Il flusso concettuale previsto è:

```text
SuccessionPlanningEngine
        ↓
date teoriche
        ↓
PlantingWindow / SeasonalityEngine
        ↓
date agronomicamente ammissibili
```

La prima evoluzione dovrà considerare progressivamente:

- finestre di semina in semenzaio;
- finestre di semina diretta;
- finestre di trapianto;
- periodo di raccolta.

Le successive evoluzioni potranno integrare:

- temperature minime;
- rischio di gelo;
- localizzazione reale dell'orto;
- dati meteorologici locali.

Non dovranno essere introdotte prematuramente regole rigide Nord/Centro/Sud senza aver prima analizzato i dati colturali già disponibili.

Il checkpoint tecnico di partenza della S015 è:

- commit sviluppo: `e19ae1a`;
- `flutter analyze`: superato;
- `flutter test`: 112/112;
- repository pulito e sincronizzato al termine dello sviluppo S014.

---

# Sessione S015 – Prima implementazione delle finestre agronomiche

### Obiettivo della sessione

La Sessione S015 è stata dedicata alla progettazione e alla prima implementazione del sistema di finestre agronomiche, proseguendo l'evoluzione della pianificazione temporale introdotta con il `SuccessionPlanningEngine` nella Sessione S014.

L'obiettivo principale è stato iniziare a rispondere alla seguente domanda:

> Una data teoricamente proposta per una semina o un trapianto è anche agronomicamente compatibile con il periodo dell'anno?

È stato mantenuto il principio architetturale definito nella Sessione S014 secondo cui il `SuccessionPlanningEngine` continua a produrre date e lotti teorici senza incorporare direttamente le regole relative alla stagionalità.

La verifica della compatibilità agronomica viene pertanto affidata a componenti separati.

La sessione è partita dalla baseline tecnica consolidata al termine della S014:

- commit documentazione: `7401d71`;
- `flutter analyze`: **No issues found!**;
- `flutter test`: **112/112 All tests passed**;
- repository pulito e sincronizzato con `origin/main`.

### Ricognizione iniziale

Prima di implementare nuovi componenti è stata effettuata una ricognizione del codice esistente per verificare quali informazioni agronomiche fossero già disponibili.

È emerso che `CropVariety` dispone già di alcuni dati utili, tra cui:

- `minTemperature`;
- `optimalTemperature`;
- `harvestDays`;
- `defaultPlantingMethod`.

Non risultavano invece ancora modellate vere finestre annuali dedicate a:

- semina in semenzaio;
- semina diretta;
- trapianto;
- periodo di raccolta.

È stata inoltre verificata la documentazione precedente, che aveva già previsto la futura introduzione di:

- finestre di semina in semenzaio;
- finestre di semina diretta;
- finestre di trapianto;
- periodo di raccolta;
- temperature minime;
- rischio di gelo;
- localizzazione climatica dell'orto.

È stato confermato anche il principio secondo cui la futura gestione della stagionalità non dovrà dipendere esclusivamente da classificazioni climatiche rigide come Nord/Centro/Sud.

L'architettura dovrà rimanere predisposta all'utilizzo della posizione reale dell'orto e dei dati meteorologici locali.

### Attività svolte

Nel corso della Sessione S015 è stata realizzata la prima infrastruttura dedicata alla rappresentazione e alla verifica delle finestre agronomiche annuali.

Sono stati introdotti tre nuovi componenti applicativi:

```text
AgronomicWindow
        ↓
AgronomicWindowValidator
        ↓
AgronomicWindowEngine
```

Il nuovo modello è stato creato in:

```text
lib/core/agronomy/models/agronomic_window.dart
```

Il relativo validatore è stato creato in:

```text
lib/core/agronomy/agronomic_window_validator.dart
```

Il nuovo motore è stato creato in:

```text
lib/core/agronomy/engines/agronomic_window_engine.dart
```

Sono stati inoltre creati i rispettivi file di test:

```text
test/core/agronomy/models/agronomic_window_test.dart
test/core/agronomy/agronomic_window_validator_test.dart
test/core/agronomy/engines/agronomic_window_engine_test.dart
```

La Sessione S015 ha deliberatamente mantenuto invariato il `SuccessionPlanningEngine`, evitando di incorporare al suo interno le regole relative alla stagionalità.

### AgronomicWindow

`AgronomicWindow` rappresenta una finestra agronomica annuale utilizzabile per descrivere il periodo nel quale uno specifico metodo di avvio della coltivazione è considerato temporalmente compatibile.

Il modello utilizza i seguenti dati:

- `startMethod`;
- `startMonth`;
- `startDay`;
- `endMonth`;
- `endDay`.

La finestra non è associata a uno specifico anno.

Questa scelta consente di rappresentare la stagionalità come intervallo ricorrente annualmente e permette di confrontare una data utilizzando esclusivamente mese e giorno.

Sono quindi rappresentabili sia finestre comprese all'interno dello stesso anno solare, ad esempio:

```text
15 marzo → 30 settembre
```

sia finestre che attraversano il cambio dell'anno, ad esempio:

```text
1 ottobre → 28 febbraio
```

Gli estremi della finestra sono considerati inclusivi.

Una data coincidente con il giorno iniziale o con il giorno finale appartiene pertanto alla finestra.

### AgronomicWindowValidator

`AgronomicWindowValidator` mantiene separate dal modello le regole necessarie a verificare la validità strutturale di una finestra agronomica.

Il validatore verifica:

- validità del mese iniziale;
- validità del giorno iniziale;
- validità del mese finale;
- validità del giorno finale;
- coerenza delle combinazioni mese/giorno.

Vengono pertanto riconosciute e rifiutate date impossibili, come:

```text
31 aprile
```

mentre viene considerata strutturalmente valida una data come:

```text
29 febbraio
```

Per effettuare la validazione delle combinazioni mese/giorno viene utilizzato tecnicamente l'anno `2000`, in quanto anno bisestile.

Il validatore non impone la condizione:

```text
inizio <= fine
```

perché una finestra che attraversa il cambio dell'anno, ad esempio ottobre → febbraio, costituisce deliberatamente un intervallo valido.

La responsabilità del validator rimane limitata alla validità strutturale della finestra e non comprende la verifica dell'appartenenza di una specifica data all'intervallo.

### AgronomicWindowEngine

`AgronomicWindowEngine` è il componente responsabile della verifica temporale delle finestre agronomiche.

La prima versione introduce due operazioni principali:

- `contains()`;
- `isBatchCompatible()`.

#### contains()

Il metodo `contains()` determina se una determinata `DateTime` appartiene a una `AgronomicWindow`.

Il controllo utilizza mese e giorno della data, mantenendo la finestra indipendente dall'anno specifico.

Il metodo gestisce:

- finestre standard comprese nello stesso anno solare;
- finestre che attraversano il 31 dicembre;
- estremo iniziale incluso;
- estremo finale incluso.

Per una finestra standard:

```text
15 marzo → 30 settembre
```

sono considerate compatibili le date comprese tra i due estremi inclusi.

Per una finestra che attraversa il cambio dell'anno:

```text
1 ottobre → 28 febbraio
```

sono considerate compatibili sia le date comprese tra ottobre e dicembre sia quelle comprese tra gennaio e febbraio.

#### isBatchCompatible()

Il metodo `isBatchCompatible()` permette di verificare direttamente la compatibilità tra:

```text
PlannedPlantingBatch
        +
AgronomicWindow
```

Un lotto viene considerato compatibile soltanto quando risultano contemporaneamente soddisfatte due condizioni:

```text
batch.startMethod == window.startMethod
```

e:

```text
batch.plannedDate ∈ AgronomicWindow
```

Il comportamento può essere sintetizzato come:

```text
metodo corretto + data nella finestra
        ↓
compatibile

metodo diverso + data nella finestra
        ↓
non compatibile

metodo corretto + data fuori finestra
        ↓
non compatibile
```

La compatibilità agronomica V1 richiede quindi sia la corrispondenza del metodo di avvio sia l'appartenenza temporale della data alla relativa finestra.

### Separazione architetturale

Durante la Sessione S015 è stato deliberatamente deciso di non modificare il `SuccessionPlanningEngine`.

La separazione architetturale adottata è:

```text
Fabbisogno familiare
        ↓
SuccessionPlanningEngine
        ↓
date/lotti teorici
        ↓
verifica agronomica separata
        ↓
AgronomicWindowEngine
```

Il `SuccessionPlanningEngine` mantiene la responsabilità della generazione temporale teorica dei lotti.

`AgronomicWindowEngine` mantiene invece la responsabilità di verificare se la data e il metodo di avvio di un lotto siano compatibili con una finestra agronomica.

Questa separazione evita di trasformare il `SuccessionPlanningEngine` in un componente monolitico e consente di aggiungere progressivamente ulteriori criteri di compatibilità senza modificare la responsabilità principale del pianificatore temporale.

### Limiti della V1 ed evoluzioni rinviate

La Sessione S015 introduce l'infrastruttura necessaria alla rappresentazione e alla verifica delle finestre agronomiche, ma non introduce ancora dati stagionali reali delle singole colture o varietà.

Non sono stati implementati nella S015:

- dati stagionali reali delle singole colture;
- associazione delle finestre a `Crop`;
- associazione delle finestre a `CropVariety`;
- temperature come criterio dinamico di compatibilità;
- rischio di gelo;
- posizione geografica dell'orto;
- classificazione climatica;
- utilizzo di dati meteorologici reali;
- adattamento dinamico delle finestre sulla base della stazione meteorologica;
- persistenza delle finestre in Supabase;
- integrazione diretta delle finestre nella `RecommendationPipeline`.

Questi elementi sono stati deliberatamente rinviati per mantenere incrementale l'evoluzione dell'architettura.

La stagionalità introdotta nella S015 deve pertanto essere considerata una prima infrastruttura temporale sulla quale costruire progressivamente la futura compatibilità agronomica reale.

### Evoluzione climatica e meteorologica

La prima versione delle finestre agronomiche rimane deliberatamente separata dalle condizioni climatiche e meteorologiche.

L'evoluzione futura dovrà poter considerare progressivamente:

```text
finestra agronomica di base
        +
caratteristiche della coltura o varietà
        +
localizzazione reale dell'orto
        +
temperature
        +
rischio di gelo
        +
dati meteorologici locali
        ↓
compatibilità agronomica evoluta
```

L'architettura non dovrà dipendere rigidamente da una classificazione Nord/Centro/Sud.

Tale classificazione potrà eventualmente costituire un'informazione generale, ma il sistema dovrà rimanere predisposto all'utilizzo della localizzazione effettiva dell'orto e delle informazioni meteorologiche locali disponibili.

### Test eseguiti

La Sessione S015 è partita da una baseline di **112 test automatici**.

Sono stati aggiunti:

- 2 test dedicati ad `AgronomicWindow`;
- 6 test dedicati ad `AgronomicWindowValidator`;
- 11 test dedicati ad `AgronomicWindowEngine`.

Il totale dei nuovi test introdotti nella sessione è quindi:

```text
AgronomicWindow             +2
AgronomicWindowValidator    +6
AgronomicWindowEngine      +11
                           ---
Totale                     +19
```

La baseline complessiva è passata da:

**112 → 131 test automatici.**

Al termine dello sviluppo sono stati eseguiti i controlli globali:

- `flutter analyze` – **No issues found!**;
- `flutter test` – **131/131 All tests passed**.

Non sono state rilevate regressioni rispetto alla baseline precedente.

### Decisioni progettuali

La Sessione S015 ha consolidato i seguenti principi:

1. la successione temporale e la compatibilità agronomica costituiscono responsabilità separate;
2. il `SuccessionPlanningEngine` continua a produrre date e lotti teorici;
3. `AgronomicWindow` descrive una finestra annuale indipendente dall'anno specifico;
4. una finestra agronomica può attraversare il cambio dell'anno;
5. gli estremi delle finestre sono inclusivi;
6. ogni finestra è associata a uno specifico `PlannedPlantingStartMethod`;
7. `AgronomicWindowValidator` è responsabile della validità strutturale della finestra;
8. `AgronomicWindowEngine` è responsabile della verifica temporale;
9. la compatibilità di un `PlannedPlantingBatch` richiede contemporaneamente metodo di avvio e data compatibili;
10. la stagionalità V1 rimane separata dalle future correzioni climatiche e meteorologiche;
11. la futura evoluzione dovrà poter utilizzare la localizzazione reale dell'orto e i dati meteorologici locali;
12. l'architettura non dovrà dipendere rigidamente da classificazioni climatiche Nord/Centro/Sud.

### Database

Nel corso della Sessione S015 non sono state introdotte modifiche alla struttura o ai dati del database Supabase.

Le finestre agronomiche introdotte nella prima versione operano esclusivamente nel dominio applicativo.

Non è stata ancora introdotta la persistenza delle finestre agronomiche nel database.

L'eventuale struttura di persistenza dovrà essere progettata separatamente quando saranno definiti i dati stagionali reali da associare alle colture e alle varietà.

### Stato del progetto

Al termine della Sessione S015 Orto Smart dispone della prima infrastruttura operativa per la rappresentazione e la verifica delle finestre agronomiche annuali.

Lo stato raggiunto comprende:

- `AgronomicWindow`;
- `AgronomicWindowValidator`;
- `AgronomicWindowEngine`;
- rappresentazione di finestre annuali indipendenti dall'anno;
- supporto di finestre che attraversano il cambio dell'anno;
- estremi temporali inclusivi;
- associazione della finestra al metodo di avvio;
- verifica dell'appartenenza temporale mediante `contains()`;
- verifica diretta dei lotti mediante `isBatchCompatible()`;
- separazione tra generazione temporale e compatibilità agronomica;
- mantenimento invariato del `SuccessionPlanningEngine`;
- predisposizione alla futura associazione delle finestre a colture e varietà;
- predisposizione alla futura integrazione di localizzazione, temperature, gelo e dati meteorologici;
- 131 test automatici complessivi superati;
- `flutter analyze` senza errori.

### Git

#### Commit sviluppo

`f4c02af Introduce le finestre agronomiche di pianificazione`

Il commit comprende:

- 6 nuovi file;
- 382 inserimenti;
- nessun file preesistente modificato.

Il commit è stato pubblicato correttamente su GitHub.

Il push ha aggiornato il repository remoto:

```text
7401d71..f4c02af  main -> main
```

Al termine dello sviluppo della Sessione S015:

- `main = origin/main`;
- working tree pulito.

### Tempo di lavoro

| Attività                 |          Tempo |
| ------------------------ | -------------: |
| Sviluppo software        |     1 h 00 min |
| Documentazione           |          59 min |
| **Totale Sessione S015** | **1 h 59 min** |

Il tempo indicato comprende esclusivamente il lavoro effettivamente svolto.

La fase di sviluppo della Sessione S015 si è svolta l'11/08/2026 dalle 16:49 alle 17:49, senza pause dichiarate.

Il tempo effettivo di sviluppo della Sessione S015 è pertanto pari a 1 h 00 min.

La Sessione Manuali S015 si è svolta l'11/08/2026 dalle 17:55 alle 18:54, senza pause dichiarate.

Il tempo effettivo di documentazione della Sessione S015 è pertanto pari a 59 min.

Il tempo complessivo effettivo della Sessione S015 è pertanto pari a 1 h 59 min.

### Esito della sessione

La Sessione S015 ha raggiunto l'obiettivo previsto introducendo la prima infrastruttura dedicata alle finestre agronomiche.

Il sistema è ora in grado di rappresentare finestre annuali associate a uno specifico metodo di avvio e di verificare se la data e il metodo di un `PlannedPlantingBatch` siano compatibili con la finestra considerata.

La scelta di mantenere separato il `SuccessionPlanningEngine` preserva la specializzazione dei componenti e prepara l'architettura all'introduzione progressiva di informazioni stagionali, climatiche e meteorologiche.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **131 test automatici superati**.

### Prossimi passi

La Sessione S016 sarà dedicata all'associazione delle finestre agronomiche alle colture e alle varietà e alla prima verifica della stagionalità reale dei lotti pianificati, mantenendo separata la futura correzione climatica e meteorologica.

La sequenza evolutiva del sistema è:

```text
S013
fabbisogni quantitativi e lotti pianificati
        ↓
S014
SuccessionPlanningEngine
        ↓
S015
finestre agronomiche
        ↓
S016
stagionalità di colture e varietà
        ↓
evoluzioni future
clima, localizzazione, gelo e meteo reale
```

La S016 dovrà quindi partire dall'analisi di come associare le finestre agronomiche introdotte nella S015 a `Crop` e `CropVariety`.

L'obiettivo sarà iniziare a trasformare le finestre astratte introdotte nella S015 in informazioni stagionali effettivamente utilizzabili per valutare i lotti pianificati.

Dovrà essere mantenuta la separazione tra:

```text
stagionalità di base della coltura o varietà
        ↓
compatibilità temporale del lotto
        ↓
future correzioni climatiche e meteorologiche
```

La futura integrazione di temperature, rischio di gelo, localizzazione reale dell'orto e dati meteorologici locali rimarrà una responsabilità evolutiva successiva e separata.

Il checkpoint tecnico di partenza della S016 è:

- commit sviluppo: `f4c02af`;
- `flutter analyze`: superato;
- `flutter test`: 131/131;
- repository pulito e sincronizzato al termine dello sviluppo S015.

---

# Sessione S016 – Associazione delle finestre agronomiche a colture e varietà

**Data:** 11/08/2026

**Orario sviluppo:** 19:11–20:17

**Tempo effettivo di sviluppo:** 1 h 06 min

**Pause:** nessuna

## Obiettivo della sessione

L'obiettivo della Sessione S016 è stato proseguire il lavoro iniziato nella S015 sulle finestre agronomiche, definendo come associare una finestra agronomica a una coltura o a una specifica varietà e costruendo il primo flusso applicativo capace di valutare la compatibilità stagionale di un lotto pianificato.

La scelta architetturale principale della sessione è stata quella di consolidare prima il modello di dominio e il comportamento applicativo, rimandando la persistenza delle regole in Supabase a una fase successiva.

## Stato iniziale

All'apertura della Sessione S016:

- repository `main` sincronizzato con `origin/main`;
- working tree pulito;
- ultimo commit: `44b481f Aggiorna documentazione Sessione S015`;
- `flutter analyze`: nessun problema;
- `flutter test`: 131 test superati.

La S015 aveva già introdotto:

- `AgronomicWindow`;
- `AgronomicWindowValidator`;
- `AgronomicWindowEngine`;
- gestione delle finestre che attraversano la fine dell'anno;
- verifica della compatibilità tra finestra e `PlannedPlantingBatch`.

Mancava però il collegamento tra le finestre agronomiche e le effettive colture e varietà.

## Analisi preliminare

Prima dell'implementazione è stata verificata la struttura esistente di `Crop`, `CropVariety`, `Planting`, repository e motori agronomici.

È emersa una differenza già presente nel progetto nella rappresentazione degli identificativi:

- gran parte del dominio agronomico utilizza `String` per `cropId` e `varietyId`;
- `CropVariety` utilizza ancora `int` per `id` e `cropId`;
- in Supabase `crops.id`, `crop_varieties.id` e `crop_varieties.crop_id` sono attualmente `bigint`.

Per evitare una modifica trasversale non necessaria durante la S016, il nuovo dominio delle finestre agronomiche continua a utilizzare identificativi `String`, coerentemente con `PlannedPlantingBatch` e con gli altri componenti del motore agronomico.

È stata inoltre valutata la possibilità di modificare immediatamente Supabase.

Si è deciso deliberatamente di non farlo nella S016: prima viene definito e verificato il comportamento del dominio; successivamente verrà progettato il modello persistente sulla base di un contratto ormai stabile.

## Implementazione

### CropAgronomicWindowRule

È stato creato:

`lib/core/agronomy/models/crop_agronomic_window_rule.dart`

Il modello rappresenta l'associazione tra una finestra agronomica e:

- una coltura;
- opzionalmente una specifica varietà.

La semantica definita è:

```text
varietyId == null
        ↓
regola generale della coltura

varietyId != null
        ↓
regola specifica della varietà
```

Questo permette di mantenere una regola generale e introdurre eccezioni varietali soltanto quando necessarie, evitando duplicazioni inutili dei dati.

Sono stati creati i relativi test:

`test/core/agronomy/models/crop_agronomic_window_rule_test.dart`

### AgronomicWindowResolver

È stato creato:

`lib/core/agronomy/engines/agronomic_window_resolver.dart`

Il resolver seleziona la finestra agronomica applicabile in base a:

- `cropId`;
- `varietyId`;
- `PlannedPlantingStartMethod`.

È stata definita la seguente gerarchia:

```text
regola specifica della varietà
        ↓
regola generale della coltura
        ↓
nessuna regola
```

Il comportamento previsto è pertanto:

1. se esiste una regola specifica per la varietà e per il metodo di impianto richiesto, viene utilizzata quella;
2. in assenza della regola varietale viene utilizzata la regola generale della coltura;
3. se non esiste alcuna regola applicabile viene restituito `null`.

Il resolver non valuta la data del lotto. Questa responsabilità rimane nell'`AgronomicWindowEngine`.

È stato inoltre introdotto:

`resolveForBatch(...)`

che permette al resolver di ricevere direttamente un `PlannedPlantingBatch`, estraendo:

- `cropId`;
- `varietyId`;
- `startMethod`.

Sono stati creati i relativi test:

`test/core/agronomy/engines/agronomic_window_resolver_test.dart`

Al termine della sessione il resolver dispone di **8 test dedicati**.

### AgronomicWindowEvaluation

È stato creato:

`lib/core/agronomy/models/agronomic_window_evaluation.dart`

È stato deciso di non rappresentare il risultato della valutazione mediante un semplice valore booleano.

Sono stati introdotti tre stati:

- `compatible`;
- `incompatible`;
- `unknown`.

La distinzione è intenzionale:

```text
unknown != incompatible
```

`unknown` significa che Orto Smart non possiede una regola agronomica sufficiente per esprimere un giudizio.

`incompatible` significa invece che una regola è disponibile, ma la data pianificata non rientra nella finestra prevista.

Il modello contiene inoltre:

- la finestra agronomica utilizzata, quando disponibile;
- una lista di motivazioni (`reasons`);
- getter per identificare rapidamente i tre stati.

Sono stati introdotti factory constructor dedicati:

- `AgronomicWindowEvaluation.compatible(...)`;
- `AgronomicWindowEvaluation.incompatible(...)`;
- `AgronomicWindowEvaluation.unknown(...)`.

La struttura segue il pattern già utilizzato nel progetto da risultati come `RotationResult`.

Sono stati creati i relativi test:

`test/core/agronomy/models/agronomic_window_evaluation_test.dart`

Test dedicati: **4**.

### AgronomicWindowService

È stato creato:

`lib/services/agronomic_window_service.dart`

Il servizio segue il pattern già presente in `BedAnalysisService`.

Non contiene logica agronomica propria, ma coordina:

- `AgronomicWindowResolver`;
- `AgronomicWindowEngine`.

Il metodo:

`evaluateBatch(...)`

riceve:

- un insieme di `CropAgronomicWindowRule`;
- un `PlannedPlantingBatch`.

Il flusso risultante è:

```text
PlannedPlantingBatch
        ↓
AgronomicWindowResolver
        ↓
selezione della finestra
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowEvaluation
```

Il risultato finale può essere:

**compatible**

- regola trovata;
- data del lotto dentro la finestra.

**incompatible**

- regola trovata;
- data del lotto fuori dalla finestra.

**unknown**

- nessuna regola applicabile disponibile.

Il servizio conserva automaticamente il fallback:

```text
varietà specifica
        ↓
coltura generale
        ↓
unknown
```

Sono stati creati i relativi test:

`test/services/agronomic_window_service_test.dart`

Test dedicati: **4**.

## Separazione delle responsabilità

La Sessione S016 ha consolidato la seguente architettura:

```text
PlannedPlantingBatch
        ↓
AgronomicWindowResolver
        ↓
AgronomicWindow
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowEvaluation
```

Le responsabilità rimangono separate:

- `AgronomicWindowResolver` decide **quale finestra applicare**;
- `AgronomicWindowEngine` decide **se la data del lotto è compatibile con quella finestra**;
- `AgronomicWindowService` coordina resolver ed engine e produce il risultato applicativo;
- `SuccessionPlanningEngine` rimane responsabile della generazione temporale dei lotti.

Questa separazione evita di concentrare nel `SuccessionPlanningEngine` conoscenze relative alla stagionalità, alla selezione delle regole e alla persistenza.

## Persistenza Supabase

Durante la S016 non sono state apportate modifiche a Supabase.

La scelta è intenzionale.

Il dominio delle finestre agronomiche viene prima stabilizzato e testato indipendentemente dalla persistenza.

La futura struttura Supabase dovrà adattarsi al dominio e non viceversa.

In particolare dovrà supportare:

- regole generali per coltura;
- regole specifiche per varietà;
- differenti metodi di impianto;
- una o eventualmente più finestre agronomiche;
- futura estensione delle informazioni agronomiche senza duplicazioni inutili.

Rimane valido il principio generale di efficienza dei dati adottato nel progetto:

```text
dato generale della coltura
        +
override specifico della varietà solo quando necessario
```

Questa struttura limita le duplicazioni e mantiene compatta la futura rappresentazione persistente.

## Test

La baseline iniziale della Sessione S016 era:

```text
131 test
```

Sono stati aggiunti complessivamente **18 nuovi test**:

| Componente                  | Nuovi test |
| --------------------------- | ---------: |
| `CropAgronomicWindowRule`   |          2 |
| `AgronomicWindowResolver`   |          8 |
| `AgronomicWindowEvaluation` |          4 |
| `AgronomicWindowService`    |          4 |
| **Totale**                  |     **18** |

Il controllo mirato finale ha prodotto:

```text
18/18 All tests passed
```

La suite completa ha prodotto:

```text
149/149 All tests passed
```

La baseline dei test automatici è quindi passata:

```text
131 → 149 test
```

L'analisi statica finale ha prodotto:

```text
flutter analyze
→ No issues found!
```

Nessuna regressione è stata rilevata.

## File introdotti

La Sessione S016 ha introdotto 8 nuovi file.

### Implementazione

- `lib/core/agronomy/engines/agronomic_window_resolver.dart`;
- `lib/core/agronomy/models/agronomic_window_evaluation.dart`;
- `lib/core/agronomy/models/crop_agronomic_window_rule.dart`;
- `lib/services/agronomic_window_service.dart`.

### Test

- `test/core/agronomy/engines/agronomic_window_resolver_test.dart`;
- `test/core/agronomy/models/agronomic_window_evaluation_test.dart`;
- `test/core/agronomy/models/crop_agronomic_window_rule_test.dart`;
- `test/services/agronomic_window_service_test.dart`.

Diff complessivo:

```text
8 file nuovi
497 inserzioni
```

## Decisioni progettuali

La Sessione S016 ha consolidato i seguenti principi:

1. Le finestre agronomiche vengono associate a colture e varietà mediante `CropAgronomicWindowRule`.
2. Una regola può essere generale per una coltura oppure specifica per una varietà.
3. La regola specifica della varietà ha precedenza sulla regola generale della coltura.
4. La selezione della finestra e la valutazione temporale rimangono responsabilità distinte.
5. `AgronomicWindowResolver` determina quale finestra utilizzare.
6. `AgronomicWindowEngine` determina se la data appartiene alla finestra selezionata.
7. `AgronomicWindowService` coordina i componenti senza incorporare logica agronomica propria.
8. L'assenza di una regola non equivale a incompatibilità: `unknown != incompatible`.
9. La persistenza Supabase viene rimandata consapevolmente fino alla stabilizzazione del dominio.
10. La futura persistenza dovrà privilegiare il dato generale della coltura con override varietali soltanto quando necessari.
11. Il dominio delle finestre agronomiche continua a utilizzare identificativi `String`, rinviando la risoluzione dell'attuale differenza con `CropVariety` e con gli identificativi `bigint` di Supabase alla progettazione della persistenza.

## Git

### Commit sviluppo

`3cdf212 Integra la stagionalità dei lotti pianificati`

Il commit comprende:

- 8 nuovi file;
- 497 inserzioni.

Il commit è stato pubblicato correttamente su GitHub.

Al termine dello sviluppo della Sessione S016:

- `main = origin/main`;
- working tree pulito.

### Tempo di lavoro

| Attività                 |          Tempo |
| ------------------------ | -------------: |
| Sviluppo software        |     1 h 06 min |
| Documentazione           |         56 min |
| **Totale Sessione S016** | **2 h 02 min** |

Il tempo indicato comprende esclusivamente il lavoro effettivamente svolto.

La fase di sviluppo della Sessione S016 si è svolta l'11/08/2026 dalle 19:11 alle 20:17, senza pause dichiarate.

Il tempo effettivo di sviluppo della Sessione S016 è pertanto pari a **1 h 06 min**.

La Sessione Manuali S016 si è svolta il 12/08/2026 dalle 14:39 alle 15:35, senza pause dichiarate.

Il tempo effettivo di documentazione della Sessione S016 è pertanto pari a **56 min**.

Il tempo complessivo effettivo della Sessione S016 è pertanto pari a **2 h 02 min**.

## Esito della sessione

La Sessione S016 ha raggiunto l'obiettivo previsto associando le finestre agronomiche alle colture e alle varietà e introducendo il primo flusso applicativo completo per la valutazione della stagionalità dei lotti pianificati.

Il sistema è ora in grado di:

- individuare una regola specifica della varietà;
- utilizzare in fallback la regola generale della coltura;
- distinguere l'assenza di informazioni agronomiche da una reale incompatibilità;
- verificare separatamente la compatibilità temporale del lotto;
- produrre un risultato applicativo strutturato mediante `AgronomicWindowEvaluation`.

Lo sviluppo tecnico della sessione si è concluso con `flutter analyze` senza errori e **149 test automatici superati**.

La persistenza delle regole agronomiche non è stata introdotta prematuramente e rimane il principale passaggio evolutivo successivo.

## Prossimi passi

La Sessione S017 sarà dedicata alla progettazione della persistenza delle regole delle finestre agronomiche e al collegamento del dominio ormai stabile con Supabase.

La sessione dovrà partire dall'analisi dello schema esistente e non dalla modifica immediata del database.

Dovranno essere verificati:

- schema reale di `crops`;
- schema reale di `crop_varieties`;
- vincoli e foreign key coinvolti;
- differenza tra gli identificativi `String` utilizzati dal dominio agronomico, gli identificativi `int` di `CropVariety` e i `bigint` presenti in Supabase;
- possibilità che una stessa coltura e uno stesso metodo di impianto possiedano più finestre agronomiche nello stesso anno.

La futura struttura persistente dovrà rappresentare almeno:

- coltura;
- varietà opzionale;
- metodo di impianto;
- mese e giorno iniziale;
- mese e giorno finale;
- eventuali metadati agronomici necessari.

Il flusso architetturale da preservare sarà:

```text
Supabase
        ↓
Repository
        ↓
dominio
        ↓
AgronomicWindowResolver
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowService
        ↓
AgronomicWindowEvaluation
```

Solo dopo aver definito e verificato lo schema dovrà essere valutata l'esecuzione della migration Supabase.

Il checkpoint tecnico di partenza della S017 è:

- commit sviluppo: `3cdf212`;
- `flutter analyze`: superato;
- `flutter test`: 149/149;
- fallback: varietà specifica → coltura generale → `unknown`;
- repository pulito e sincronizzato al termine dello sviluppo S016.

---

---

# Sessione S017 – Progettazione e congelamento del Database V1

**Periodo sviluppo:** 12/08/2026 – 15/08/2026
**Apertura sviluppo:** 12/08/2026, ore 16:04
**Chiusura sviluppo:** 15/08/2026, ore 23:37
**Tempo sviluppo effettivo:** circa **20 h 24 min**

> Nota timing: l'unico dato approssimativo della ricostruzione temporale è la ripresa del 14/08/2026, registrata intorno alle 14:15.

## Obiettivo iniziale

La Sessione S017 era stata inizialmente pianificata come prosecuzione diretta della S016.

L'obiettivo previsto era progettare la persistenza delle regole delle finestre agronomiche e collegare il dominio ormai consolidato a Supabase senza trasferire nel database la logica decisionale degli engine Dart.

Il punto di partenza era:

```text
Supabase
        ↓
Repository
        ↓
CropAgronomicWindowRule
        ↓
AgronomicWindowResolver
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowService
```

La sessione doveva verificare in particolare:

- schema reale di `crops`;
- schema reale di `crop_varieties`;
- foreign key e vincoli esistenti;
- differenze tra gli identificativi utilizzati dal dominio Dart e quelli presenti in Supabase;
- possibilità di rappresentare più finestre agronomiche per la stessa coltura, varietà e metodo di impianto;
- struttura persistente necessaria per `agronomic_window_rules`.

Non era previsto, all'apertura della sessione, di riprogettare integralmente il database di Orto Smart.

## Evoluzione iniziale della sessione

Durante la prima fase della S017 è emerso che una coltura o varietà può possedere **più finestre agronomiche nello stesso anno** per uno stesso metodo di avvio.

Il modello introdotto nella S016 restava valido nei suoi principi fondamentali:

```text
regola specifica della varietà
        ↓
fallback
        ↓
regola generale della coltura
        ↓
assenza di conoscenza
```

ma l'ipotesi di risolvere una sola `AgronomicWindow` non risultava sufficiente per rappresentare correttamente tutti i casi agronomici.

Sono state quindi avviate modifiche tecniche a:

- `lib/core/agronomy/engines/agronomic_window_resolver.dart`;
- `lib/core/agronomy/models/agronomic_window_evaluation.dart`;
- `lib/services/agronomic_window_service.dart`;
- `test/core/agronomy/engines/agronomic_window_resolver_test.dart`;
- `test/core/agronomy/models/agronomic_window_evaluation_test.dart`;
- `test/services/agronomic_window_service_test.dart`.

Le modifiche evolvono il contratto da una singola finestra:

```text
AgronomicWindow?
```

verso la possibilità di gestire:

```text
List<AgronomicWindow>
```

preservando il principio:

```text
finestre specifiche della varietà
        ↓
se presenti, vengono utilizzate

altrimenti
        ↓
finestre generali della coltura

assenza di regole
        ↓
nessuna conoscenza disponibile
```

Queste modifiche sono state effettuate durante la S017 ma **non sono state completate, verificate e committate** prima del successivo cambio di scala della sessione.

Al termine dello sviluppo S017 risultano ancora presenti nel working tree come lavoro tecnico aperto e non devono essere interpretate né come scarto né come implementazione completata.

## Cambio di scala della S017

L'analisi necessaria per persistere correttamente le regole agronomiche ha evidenziato che lo schema Supabase esistente era cresciuto progressivamente insieme all'applicazione e non rappresentava più in modo organico il dominio maturato.

È stato quindi deciso di interrompere temporaneamente l'implementazione incrementale e svolgere un **censimento completo del dominio e del database**.

Da questo censimento è emersa la necessità di progettare una vera baseline:

> **DATABASE V1 DI ORTO SMART**

La sessione ha quindi cambiato obiettivo operativo.

Il nuovo obiettivo è diventato:

> progettare completamente il Database V1 prima di qualsiasi nuova migration SQL/Supabase, definendo entità, relazioni, cardinalità, temporalità, ownership, sicurezza, invarianti e strategia di migrazione.

È stato esplicitamente stabilito di **non iniziare SQL** fino al completamento della progettazione logica e architetturale.

---

## STEP 34 – Progettazione del Database V1

La riprogettazione è stata condotta in modo sistematico, evitando di trasformare immediatamente ogni requisito in una nuova tabella.

Per ogni area del dominio sono stati analizzati:

- concetto rappresentato;
- necessità effettiva nel V1;
- distinzione tra dato persistente e dato calcolato;
- relazioni con le entità già individuate;
- necessità di storicizzazione;
- ownership;
- implicazioni di sicurezza;
- possibilità di rinviare la funzionalità a una fase futura.

L'obiettivo non era massimizzare il numero di tabelle, ma ottenere una struttura sufficientemente completa da sostenere il V1 senza trasformare il database in un sistema inutilmente complesso.

### Aree di dominio analizzate

La progettazione ha esaminato in particolare:

- identità e ownership;
- orti e stagioni;
- catalogo agronomico;
- famiglie botaniche;
- colture e varietà;
- consociazioni;
- finestre e regole agronomiche;
- struttura fisica dell'orto;
- aree e aiuole;
- geometria storica delle aiuole;
- strutture fisiche;
- dispositivi;
- fonti idriche;
- zone irrigue;
- preferenze colturali;
- fabbisogni di consumo;
- pianificazione stagionale;
- piantagioni pianificate;
- piantagioni reali;
- attività;
- lavoro effettivamente svolto;
- raccolte;
- valorizzazione della produzione;
- irrigazioni;
- fertilizzazioni;
- trattamenti;
- eventi dell'orto;
- diario;
- costi;
- prezzi di mercato;
- contesto ambientale;
- sicurezza e concorrenza.

### Principi consolidati

Durante lo STEP 34 sono stati consolidati alcuni principi trasversali.

#### Persistenza e logica applicativa

Il database deve conservare fatti, configurazioni e conoscenza persistente.

Gli engine Dart continuano invece a essere responsabili della logica decisionale.

Il principio rimane:

```text
database
        ↓
dati e regole persistenti

dominio Dart
        ↓
interpretazione e logica agronomica
```

Non devono essere create tabelle soltanto per materializzare risultati che possono essere correttamente calcolati.

#### Pianificazione e realtà

La pianificazione non deve essere confusa con ciò che avviene realmente.

La catena produttiva V1 è stata consolidata come:

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

Una `PlannedPlanting` può generare **0..N Plantings**.

La quantità realmente eseguita e lo scostamento dal piano devono essere ricostruibili dai fatti reali senza duplicare inutilmente lo stato.

#### Attività e lavoro

Sono stati mantenuti separati:

```text
ActivityRule
        ↓
Task
        ↓
WorkLog
```

`activity_rules` rappresenta conoscenza operativa.

`tasks` rappresenta ciò che deve essere fatto.

`work_logs` rappresenta ciò che è stato realmente eseguito.

Il futuro comando applicativo **Inizia lavoro** dovrà operare rispettando questa separazione.

#### Temporalità

Le configurazioni che possono cambiare nel tempo non devono sovrascrivere retroattivamente la storia.

Quando applicabile viene adottato l'intervallo:

```text
[valid_from, valid_to)
```

È stata inoltre separata l'identità stabile dell'aiuola dalla sua geometria:

```text
beds
        ↓
identità stabile

bed_geometries
        ↓
geometria valida nel tempo
```

#### Regole agronomiche

Le finestre agronomiche vengono derivate da:

```text
agronomic_window_rules
        ↓
motore agronomico
        ↓
AgronomicWindow
```

`AgronomicWindow` rimane quindi un risultato calcolato.

Non viene introdotta nel Database V1 una tabella persistente:

```text
agronomic_windows
```

Le regole che possono cambiare semanticamente devono poter essere versionate senza alterare retroattivamente l'interpretazione delle decisioni storiche.

#### Contesto ambientale

È stata confermata la separazione tra archivio meteorologico completo e contesto necessario alle decisioni di Orto Smart.

La stazione Davis/CumulusMX costituisce la fonte primaria/autorevole per le osservazioni meteorologiche locali.

Open-Meteo costituisce la fonte esterna principale per le previsioni e il fallback quando la fonte locale non è disponibile.

Il Database V1 non deve duplicare l'archivio meteorologico grezzo.

Sono previste invece:

```text
environment_context_snapshots
environment_context_links
```

per conservare il contesto ambientale necessario alla ricostruibilità delle decisioni e degli eventi.

### Modello di accesso familiare

Durante la progettazione è stato analizzato esplicitamente il modo in cui il proprietario dell'orto e i componenti della stessa famiglia utilizzeranno l'applicazione.

Per il V1 è stato scelto un modello semplice:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

Il V1 prevede **un account/Profile principale** per il nucleo che utilizza l'orto.

I componenti della stessa famiglia possono utilizzare lo stesso accesso senza richiedere account personali distinti.

Le persone alle quali deve essere attribuito il lavoro sono rappresentate mediante:

```text
workers
```

Un `worker` non implica quindi automaticamente un account Supabase.

Rimangono distinti:

```text
account autenticato
        ≠
persona che utilizza materialmente l'app
        ≠
worker al quale viene attribuito il lavoro
```

La multiutenza con account distinti e condivisione dello stesso Garden viene rinviata oltre il V1.

### Modello single-writer

Per evitare scritture concorrenti incontrollate quando lo stesso accesso viene utilizzato da più dispositivi, il V1 adotta un modello **single-writer per Profile**.

È stata prevista:

```text
profile_edit_locks
```

come infrastruttura tecnica per il coordinamento del writer.

Questa struttura non rappresenta un concetto agronomico o operativo del dominio e viene quindi mantenuta separata dal conteggio delle entità di dominio.

### Funzionalità valutate e rinviate

Durante lo STEP 34 alcune funzionalità sono state esaminate esplicitamente ma escluse dalla baseline V1.

Tra queste:

- inventario e magazzino;
- lotti di scorta;
- ammortamenti;
- contabilità avanzata;
- GIS/PostGIS;
- multi-writer completo;
- multiutenza avanzata con account distinti e condivisione del Garden;
- archivio meteorologico grezzo duplicato;
- automazione irrigua completa;
- correzione climatica e meteorologica avanzata.

In particolare, la gestione dell'inventario era stata inizialmente valutata come possibile componente minimale del V1.

Una successiva revisione durante lo STEP 34 ha portato alla decisione definitiva di **non introdurre `inventory_items` nel Database V1**.

Acquisti e spese rimangono rappresentabili mediante `cost_events`, mentre fertilizzazioni e trattamenti registrano direttamente le informazioni pertinenti agli eventi realmente avvenuti.

## Baseline nominale finale

Al termine della progettazione è stato eseguito un controllo nominale completo delle entità previste.

Il controllo ha evidenziato inizialmente un'apparente anomalia:

```text
53 nomi
        ↓
52 entità di dominio attese
```

La verifica ha individuato la causa in `agronomic_windows`.

Poiché `AgronomicWindow` è un risultato calcolato a partire da `agronomic_window_rules`, `agronomic_windows` è stata definitivamente esclusa dalle tabelle persistenti V1.

Il controllo nominale ha inoltre eliminato un'ambiguità nella denominazione:

```text
zone_target_assignments
```

è stata sostituita definitivamente da:

```text
irrigation_zone_target_assignments
```

Il risultato finale è:

```text
52 entità di dominio
+
1 struttura tecnica: profile_edit_locks
=
53 strutture fisiche previste
```

`profile_edit_locks` rimane separata dal conteggio delle 52 perché costituisce infrastruttura tecnica.

Il controllo nominale ufficiale si è quindi concluso con:

> **52/52 entità di dominio verificate.**

## Esito dello STEP 34

Al termine della Sessione S017 risultano completati:

- progettazione logica e architetturale del Database V1;
- analisi delle aree funzionali;
- definizione delle 52 entità di dominio;
- definizione delle relazioni e cardinalità principali;
- temporalità e storicizzazione;
- ownership e modello di accesso;
- modello familiare V1;
- modello single-writer;
- principi di sicurezza;
- invarianti principali;
- convenzioni dei dati;
- distinzione tra dati persistenti e dati calcolati;
- distinzione tra pianificazione e fatti reali;
- controllo nominale finale 52/52;
- risoluzione dell'anomalia 53 → 52;
- verifica dei nomi SQL definitivi.

Pertanto viene dichiarato:

> **STEP 34 – DATABASE V1 COMPLETATO E CONGELATO**

La baseline non deve essere riaperta durante la successiva implementazione salvo l'emersione di un errore concreto nella progettazione.

La descrizione tecnica completa della baseline è riportata nel **DOC-004 – Manuale Database**.

La decisione architetturale di congelamento della baseline è registrata nel **DOC-011 – Decisioni Architetturali**, mediante **DEC-011 – Baseline architetturale del Database V1**.

---

## Decisioni progettuali della Sessione S017

La Sessione S017 ha consolidato le seguenti decisioni principali:

1. Il Database V1 deve essere progettato integralmente prima dell'avvio delle nuove migration SQL/Supabase.
2. La baseline definitiva comprende **52 entità di dominio**.
3. `profile_edit_locks` costituisce una struttura tecnica separata e non appartiene al conteggio delle 52 entità.
4. `AgronomicWindow` rimane un risultato calcolato; non viene introdotta una tabella persistente `agronomic_windows`.
5. Il nome SQL definitivo dell'assegnazione dei target irrigui è `irrigation_zone_target_assignments`.
6. Pianificazione e realtà devono rimanere separate.
7. Task e lavoro realmente svolto devono rimanere separati.
8. Le configurazioni temporalmente significative devono essere storicizzabili.
9. L'identità stabile delle aiuole deve essere separata dalla geometria valida nel tempo.
10. Il V1 utilizza un account/Profile principale per il nucleo che utilizza l'orto.
11. I componenti della stessa famiglia possono utilizzare lo stesso accesso applicativo.
12. I `workers` consentono di attribuire il lavoro alle persone senza richiedere account personali distinti.
13. Il V1 adotta un modello single-writer per Profile.
14. La multiutenza con account distinti e condivisione dello stesso Garden viene rinviata oltre il V1.
15. La sicurezza deve essere applicata lato database mediante RLS, ownership verificabile, vincoli e operazioni server-side appropriate.
16. Il client Flutter non deve costituire l'unica barriera di autorizzazione.
17. Davis/CumulusMX costituisce la fonte primaria per le osservazioni meteorologiche locali.
18. Open-Meteo costituisce la fonte esterna principale per le previsioni e il fallback.
19. L'archivio meteorologico grezzo non deve essere duplicato nel Database V1.
20. Inventario e magazzino non vengono introdotti nel V1.
21. Ammortamenti e contabilità avanzata rimangono funzionalità future.
22. GIS/PostGIS non viene introdotto nel V1.
23. La baseline congelata deve essere implementata incrementalmente e non mediante una migrazione monolitica.
24. Schema, sicurezza e verifiche devono procedere insieme durante l'implementazione.
25. Lo STEP 34 non deve essere riaperto salvo l'emersione di un errore concreto nella progettazione.

La decisione architetturale complessiva è formalizzata nella **DEC-011 – Baseline architetturale del Database V1**.

## Stato del codice al termine dello sviluppo S017

La S017 ha avuto natura prevalentemente progettuale e architetturale.

Durante la fase iniziale erano state avviate modifiche al dominio delle finestre agronomiche per supportare più finestre applicabili.

Al termine dello sviluppo S017 risultano modificati e non ancora committati:

```text
lib/core/agronomy/engines/agronomic_window_resolver.dart
lib/core/agronomy/models/agronomic_window_evaluation.dart
lib/services/agronomic_window_service.dart
test/core/agronomy/engines/agronomic_window_resolver_test.dart
test/core/agronomy/models/agronomic_window_evaluation_test.dart
test/services/agronomic_window_service_test.dart
```

Queste modifiche costituiscono **lavoro tecnico aperto**.

Non devono essere incluse automaticamente nel commit documentale della S017 e dovranno essere riesaminate nella successiva sessione di sviluppo prima di essere considerate completate.

La progettazione del Database V1 non ha comportato l'esecuzione di migration SQL sulla nuova baseline.

Pertanto, al termine della S017:

```text
Database V1 progettato e congelato
        ↓
documentazione
        ↓
implementazione SQL/Supabase ancora da eseguire
```

## Timing dello sviluppo

Il tempo della Sessione S017 è stato registrato al netto delle pause e delle sospensioni.

### 12/08/2026

| Fascia | Tempo |
| --- | ---: |
| 16:04 → 17:10 | 1 h 06 min |
| 21:51 → 23:08 | 1 h 17 min |
| **Totale 12/08** | **2 h 23 min** |

### 13/08/2026

| Fascia | Tempo |
| --- | ---: |
| 09:35 → 13:23 | 3 h 48 min |
| 14:18 → 15:13 | 55 min |
| 17:08 → 17:23 | 15 min |
| 22:24 → 23:21 | 57 min |
| **Totale 13/08** | **5 h 55 min** |

### 14/08/2026

| Fascia | Tempo |
| --- | ---: |
| 09:50 → 11:52 | 2 h 02 min |
| ≈14:15 → 15:03 | ≈48 min |
| 18:25 → 19:05 | 40 min |
| 20:09 → 20:51 | 42 min |
| 21:14 → 24:00 | 2 h 46 min |
| **Totale 14/08** | **6 h 58 min** |

La ripresa delle ore **≈14:15** è l'unico orario approssimativo della ricostruzione temporale della S017.

### 15/08/2026

| Fascia | Tempo |
| --- | ---: |
| 00:00 → 00:53 | 53 min |
| 09:55 → 11:05 | 1 h 10 min |
| 12:14 → 14:48 | 2 h 34 min |
| 23:06 → 23:37 | 31 min |
| **Totale 15/08** | **5 h 08 min** |

### Totale sviluppo S017

```text
12/08    2 h 23 min
13/08    5 h 55 min
14/08    6 h 58 min
15/08    5 h 08 min
--------------------
Totale  20 h 24 min
```

Il tempo effettivo di **sviluppo** della Sessione S017 è quindi pari a:

> **20 h 24 min**

La fase di sviluppo è iniziata il **12/08/2026 alle 16:04** ed è stata chiusa il **15/08/2026 alle 23:37**.

## Timing della documentazione

La documentazione conclusiva della Sessione S017 è stata svolta il **16/08/2026**, al netto della pausa pranzo.

| Fascia | Tempo |
| --- | ---: |
| 10:01 → 13:38 | 3 h 37 min |
| 14:24 → 15:37 | 1 h 13 min |
| **Totale documentazione S017** | **4 h 50 min** |

La pausa dalle **13:38 alle 14:24** è esclusa dal conteggio.

Il tempo effettivo di **documentazione** della Sessione S017 è quindi pari a:

> **4 h 50 min**

## Tempo complessivo della Sessione S017

```text
Sviluppo         20 h 24 min
Documentazione    4 h 50 min
----------------------------
Totale           25 h 14 min
```

Il tempo complessivo effettivo della **Sessione S017**, comprensivo di sviluppo e documentazione, è quindi pari a:

> **25 h 14 min**

## Esito della Sessione S017

La Sessione S017 ha superato significativamente l'obiettivo iniziale.

L'attività era iniziata con la progettazione della persistenza delle regole agronomiche, ma l'analisi ha evidenziato la necessità di consolidare preventivamente l'intera architettura persistente dell'applicazione.

Il risultato principale della sessione è quindi la definizione di una **baseline Database V1 completa e congelata**.

Sono stati definiti:

- perimetro persistente del V1;
- 52 entità di dominio;
- struttura tecnica `profile_edit_locks`;
- ownership;
- modello di accesso familiare;
- modello single-writer;
- relazioni principali;
- temporalità;
- storicizzazione;
- invarianti;
- principi di sicurezza;
- convenzioni dei dati;
- separazione tra pianificazione e realtà;
- separazione tra configurazioni ed eventi;
- strategia per il contesto ambientale;
- funzionalità esplicitamente rinviate;
- strategia generale per la futura implementazione e migrazione.

Il controllo nominale conclusivo ha verificato **52/52 entità di dominio**.

L'anomalia iniziale di 53 nomi è stata risolta escludendo `agronomic_windows` dalle strutture persistenti.

È stato inoltre congelato il nome definitivo:

```text
irrigation_zone_target_assignments
```

La progettazione dello STEP 34 viene pertanto considerata **completata**.

## Prossimi passi

Prima di iniziare l'implementazione SQL/Supabase devono essere completate le attività documentali della S017 e verificato l'allineamento dei documenti ufficiali.

Successivamente la nuova baseline dovrà essere implementata **incrementalmente**, mantenendo il metodo di lavoro del progetto:

```text
architettura
        ↓
implementazione controllata
        ↓
analyze
        ↓
test
        ↓
documentazione
        ↓
commit
        ↓
push
```

La fase successiva dovrà inoltre riesaminare le modifiche Dart ancora presenti nel working tree relative alla gestione di più finestre agronomiche.

Tali modifiche dovranno essere:

1. riesaminate rispetto alla baseline Database V1 congelata;
2. completate se ancora coerenti;
3. sottoposte a `flutter analyze`;
4. sottoposte all'intera suite di test;
5. committate separatamente soltanto dopo verifica.

L'implementazione del Database V1 dovrà partire dalle dipendenze fondamentali e procedere per piccoli gruppi verificabili, evitando un approccio big bang.

La baseline congelata nel DOC-004 e nella DEC-011 costituisce il riferimento da rispettare durante questa fase.

---

# Sessione S018 – Finestre agronomiche multiple e preparazione ambiente Supabase locale

**Data sviluppo:** 16/08/2026
**Apertura sviluppo:** 15:57
**Chiusura sviluppo:** 18:32
**Tempo sviluppo effettivo:** **2 h 35 min**

## Obiettivo della sessione

La Sessione S018 ha avuto come obiettivo la ripresa ordinata dello sviluppo dopo la revisione completa del Database V1 svolta nella S017.

In particolare, la sessione doveva:

- riesaminare e mettere in sicurezza le modifiche rimaste aperte relative alla gestione di più finestre agronomiche;
- verificare completamente il comportamento mediante analisi statica e test;
- predisporre l'infrastruttura locale necessaria per la futura implementazione del Database V1 mediante migration Supabase versionate;
- mantenere invariato il database remoto fino alla disponibilità di una baseline SQL verificata localmente.

## Finestre agronomiche multiple

Sono state riesaminate le sei modifiche tecniche rimaste nel working tree al termine della S017.

La nuova gestione supporta più finestre agronomiche applicabili alla stessa coltura, varietà e metodo di avvio.

Il comportamento consolidato è:

```text
finestre specifiche della varietà
        ↓
se presenti, vengono utilizzate

altrimenti
        ↓
finestre generali della coltura

nessuna finestra applicabile
        ↓
unknown
```

`AgronomicWindowResolver` restituisce quindi più finestre applicabili anziché una singola finestra.

`AgronomicWindowEvaluation` distingue:

```text
matchedWindow
```

dalla collezione:

```text
evaluatedWindows
```

`AgronomicWindowService` verifica tutte le finestre applicabili secondo la seguente semantica:

- `compatible` se almeno una finestra risulta compatibile;
- `incompatible` se esistono finestre applicabili ma nessuna risulta compatibile;
- `unknown` se non esistono finestre applicabili.

### Verifiche

Sono stati eseguiti:

- `dart format` sui 6 file interessati: **6 file, 0 modifiche**;
- `flutter analyze`: **No issues found**;
- test mirati: **18/18 passati**;
- suite completa: **151/151 test passati**.

### Commit

Le modifiche sono state consolidate nel commit:

```text
93d6bf6  Supporta finestre agronomiche multiple
```

Il commit è stato pubblicato correttamente sul repository remoto.

## Avvio dell'implementazione Database V1

Dopo il consolidamento delle finestre agronomiche multiple è stata avviata la preparazione tecnica necessaria per tradurre la baseline Database V1 congelata nella S017 in migration PostgreSQL/Supabase versionate.

Prima di creare nuove migration sono stati controllati i file SQL preesistenti:

```text
database/database_v1.sql
database/seed.sql
```

Il precedente `database_v1.sql` rappresentava soltanto il primo schema sperimentale del progetto, contenente un sottoinsieme molto limitato del dominio.

Il file è stato quindi conservato come riferimento storico rinominandolo:

```text
database/database_legacy_initial.sql
```

Il controllo del repository ha confermato che nessun riferimento dipendeva dal precedente nome `database_v1.sql`.

## Ambiente locale Supabase

È stato predisposto sul PC un ambiente completo per sviluppare e collaudare localmente il Database V1 prima di intervenire sul progetto Supabase remoto.

La configurazione verificata comprende:

- WSL 2 `2.7.11.0`;
- kernel WSL `6.18.33.2`;
- Ubuntu `24.04.4 LTS`;
- Docker Desktop con backend WSL 2;
- Docker Engine/CLI `29.7.2`;
- container Linux;
- 8 CPU logiche disponibili;
- circa 3,75 GiB disponibili per Docker/WSL;
- Scoop `0.5.3`;
- Supabase CLI `2.114.0`;
- PATH Windows e Visual Studio Code verificato.

Considerata la disponibilità di circa 8 GB di RAM sul portatile, Docker verrà normalmente mantenuto spento quando non necessario e avviato durante le attività che richiedono l'ambiente Supabase locale.

## Verifica PostgreSQL remoto

Dal SQL Editor del progetto Supabase è stata eseguita esclusivamente la query di lettura:

```sql
select version();
```

Il database remoto ha restituito:

```text
PostgreSQL 17.6
```

La verifica conferma che:

```text
major_version = 17
```

generato dalla Supabase CLI è coerente con il database remoto.

Durante la Sessione S018 **non è stata effettuata alcuna modifica al database remoto**.

## Inizializzazione Supabase locale

È stato eseguito:

```text
supabase init
```

La procedura ha creato:

```text
supabase/
├── .gitignore
├── config.toml
└── seed.sql
```

`supabase/seed.sql` è intenzionalmente vuoto in questa fase.

Prima del commit è stato verificato `supabase/config.toml`.

Non sono state versionate password, token o chiavi reali; gli eventuali valori sensibili sono gestiti mediante riferimenti a variabili d'ambiente.

### Commit infrastrutturale

La predisposizione dell'ambiente è stata consolidata nel commit:

```text
00190ea  Prepara ambiente Supabase locale
```

Il commit è stato pubblicato correttamente sul repository remoto.

## Stato Git finale dello sviluppo S018

Al termine dello sviluppo:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Pertanto:

```text
main = origin/main
working tree clean
```

La prima migration Database V1 **non è stata volutamente creata durante la S018**.

## Timing dello sviluppo

La fase di sviluppo della Sessione S018 si è svolta il **16/08/2026** senza interruzioni.

| Fascia | Tempo |
| --- | ---: |
| 15:57 → 18:32 | 2 h 35 min |
| **Totale sviluppo S018** | **2 h 35 min** |

Il tempo effettivo di sviluppo della Sessione S018 è pertanto pari a:

> **2 h 35 min**

## Timing della documentazione

La documentazione conclusiva della Sessione S018 si è svolta il **16/08/2026**, al netto della pausa per cena.

| Fascia | Tempo |
| --- | ---: |
| 18:39 → 19:30 | 51 min |
| 21:14 → 21:44 | 30 min |
| **Totale documentazione S018** | **1 h 21 min** |

La pausa dalle **19:30 alle 21:14** è esclusa dal conteggio.

Il tempo effettivo di **documentazione** della Sessione S018 è quindi pari a:

> **1 h 21 min**

## Tempo complessivo della Sessione S018

Sviluppo: **2 h 35 min**
Documentazione: **1 h 21 min**
Totale: **3 h 56 min**

Il tempo complessivo effettivo della **Sessione S018**, comprensivo di sviluppo e documentazione, è quindi pari a:

> **3 h 56 min**

## Punto di ripartenza S019

La futura Sessione S019 Sviluppo ripartirà dallo:

> **STEP 35.3 – Costruzione baseline SQL Database V1**

Dopo i controlli iniziali della nuova sessione, la prima operazione prevista sarà:

```text
supabase migration new database_v1_baseline
```

La baseline Database V1 congelata nella S017 verrà tradotta progressivamente in SQL per gruppi coerenti di tabelle e dipendenze.

Durante l'implementazione non dovranno essere introdotte nuove entità in modo implicito.

Eventuali necessità architetturali emerse durante la traduzione SQL dovranno essere valutate esplicitamente prima di modificare la baseline congelata.

---

# Sessione S019 – Baseline Database V1 e prima sicurezza RLS

**Data sviluppo:** 17/08/2026
**Stato:** Sviluppo concluso – documentazione in corso
**Chiusura sviluppo:** 21:41
**Tempo sviluppo effettivo:** **6 h 03 min**
**Pause sviluppo complessive:** **3 h 05 min**

## Obiettivo della sessione

La Sessione S019 ha avuto come obiettivo l'avvio effettivo dell'implementazione SQL della baseline Database V1 definita e congelata nella S017 e preparata tecnicamente nella S018.

Il punto di partenza era lo:

```text
STEP 35.3 – Costruzione baseline SQL Database V1
```

La sessione ha inoltre adottato come principio guida:

> **sicurezza prima di tutto**

L'implementazione non è stata quindi limitata alla creazione delle prime strutture dati, ma ha incluso fin dall'inizio ownership, autorizzazione, Row Level Security e verifiche positive e negative della sicurezza.

## Creazione della migration Database V1

È stata creata la prima migration versionata della nuova baseline:

```text
supabase/migrations/20260817103916_database_v1_baseline.sql
```

La migration rappresenta l'avvio concreto della traduzione della baseline architetturale Database V1 in PostgreSQL/Supabase.

L'implementazione è stata mantenuta incrementale e concentrata sul primo gruppo coerente di strutture fondamentali, evitando una trasformazione monolitica dell'intero Database V1.

## Fondazioni Database V1

La prima parte della baseline implementata comprende le seguenti sei tabelle:

```text
profiles
profile_memberships
gardens
workers
seasons
profile_edit_locks
```

Queste strutture costituiscono le **Fondazioni** del Database V1.

Il primo incremento fornisce la base necessaria per:

- Profile e ownership;
- membership e ruoli;
- Garden;
- rappresentazione dei worker;
- stagioni;
- coordinamento single-writer mediante `profile_edit_locks`.

La presenza delle sei tabelle non implica che l'intera baseline Database V1 sia già implementata.

Le restanti strutture continueranno a essere introdotte progressivamente mediante gruppi coerenti e verificabili.

## Schema `private` e helper autorizzativi

La migration introduce anche lo schema:

```text
private
```

destinato a contenere componenti interni e helper utilizzati per la sicurezza e l'autorizzazione.

Sono stati predisposti helper autorizzativi necessari alla valutazione dell'identità, dell'appartenenza al Profile e dei permessi, evitando di delegare al client Flutter decisioni di sicurezza.

Il principio applicato è:

```text
client
        ↓
richiesta
        ↓
database / server
        ↓
verifica identità
        ↓
verifica appartenenza e ruolo
        ↓
autorizzazione
```

Il client applicativo rimane pertanto un componente non fidato dal punto di vista dell'autorizzazione.

## Metadata e trigger

Sono stati introdotti i trigger necessari alla gestione coerente dei metadata previsti dalle Fondazioni.

Le strutture e i trigger sono stati verificati dopo la ricostruzione completa del database locale.

La verifica non si è limitata al contenuto nominale della migration, ma ha controllato anche la struttura effettivamente generata dal database.

## Row Level Security

La prima matrice RLS del Database V1 è stata implementata sulle Fondazioni.

Sono state verificate complessivamente:

> **13 policy RLS**

Le policy proteggono l'accesso ai dati secondo ownership, membership, ruolo e contesto del Profile.

La sicurezza mantiene l'approccio:

```text
deny-by-default
        +
privilegio minimo
```

L'accesso consentito deve essere esplicitamente previsto.

L'assenza di una regola autorizzativa non viene interpretata come un permesso implicito.

La Row Level Security viene quindi considerata parte integrante dello schema Database V1 e non un livello di sicurezza da aggiungere successivamente.

## Verifica locale della migration

È stato eseguito con successo:

```text
supabase db reset
```

La ricostruzione locale da zero è stata completata correttamente.

Questo ha verificato che la migration sia riproducibile a partire dall'ambiente Supabase locale predisposto nella S018.

La struttura realmente generata è stata inoltre verificata mediante un dump locale diagnostico.

Il dump è stato utilizzato esclusivamente come strumento temporaneo di verifica della struttura effettivamente prodotta.

Terminato il controllo, il dump diagnostico è stato eliminato e non è stato conservato come artefatto permanente del repository.

## Verifica delle Fondazioni

Dopo la ricostruzione locale sono state verificate le sei tabelle Fondazioni:

```text
profiles
profile_memberships
gardens
workers
seasons
profile_edit_locks
```

Sono stati inoltre verificati:

- schema `private`;
- helper autorizzativi;
- trigger metadata;
- Row Level Security;
- policy applicate;
- comportamento delle autorizzazioni nei principali scenari previsti.

La verifica ha quindi riguardato sia la struttura fisica generata sia il comportamento della prima matrice di sicurezza.

## Test manuali RLS

La verifica della sicurezza non si è limitata ai casi autorizzati.

Sono stati eseguiti test manuali sia **positivi** sia **negativi**, verificando che le operazioni consentite funzionino e che quelle non autorizzate vengano effettivamente bloccate.

Sono stati verificati scenari relativi a:

- isolamento tra Profile differenti;
- comportamento dell'owner;
- comportamento di worker/viewer;
- membership disabilitata;
- accesso ai `gardens`;
- accesso alle `profile_memberships`;
- accesso a `profile_edit_locks`;
- accesso alle `seasons`;
- accesso ai `workers`;
- tentativi di scrittura non autorizzati;
- tentativi di eliminazione non autorizzati.

I test hanno confermato che la prima matrice RLS delle Fondazioni applica correttamente i vincoli previsti nei casi verificati.

Il metodo di verifica adottato stabilisce inoltre un principio importante per le successive fasi:

> non è sufficiente verificare che un'operazione autorizzata funzioni; deve essere verificato anche che un'operazione non autorizzata fallisca.

I test negativi diventano quindi parte integrante della verifica della sicurezza del Database V1.

## Principi di sicurezza consolidati

La Sessione S019 conferma e concretizza i seguenti principi:

- sicurezza lato database e server;
- privilegio minimo;
- approccio deny-by-default;
- RLS come parte integrante dello schema;
- nessuna fiducia nell'autorizzazione dichiarata dal client;
- isolamento tra Profile;
- distinzione tra owner e ruoli subordinati;
- membership disabilitata non utilizzabile come autorizzazione valida;
- controllo dell'identità lato server;
- operazioni sensibili da realizzare mediante RPC controllate;
- test negativi obbligatori oltre ai test positivi;
- schema, autorizzazione e sicurezza sviluppati e verificati insieme.

La sicurezza non viene quindi considerata una fase successiva all'implementazione dello schema.

Il principio operativo consolidato è:

```text
struttura
        +
ownership
        +
autorizzazione
        +
RLS
        +
test positivi
        +
test negativi
        =
incremento verificato
```

## Stato del database remoto

Le attività della S019 hanno riguardato la migration versionata e le verifiche nell'ambiente Supabase locale.

La ricostruzione e i test della nuova baseline sono stati eseguiti localmente tramite Supabase CLI.

L'ambiente locale continua quindi a rappresentare il banco di prova della nuova baseline prima delle future operazioni sul database operativo.

## Commit e push

Il lavoro della Sessione S019 è stato consolidato nel commit:

```text
f5cd6cf  Crea baseline Database V1 e sicurezza RLS
```

Il commit è stato pubblicato correttamente sul repository remoto.

Al termine della sessione di sviluppo:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Pertanto:

```text
main = origin/main
working tree clean
```

## Timing dello sviluppo

La Sessione S019 Sviluppo si è svolta il **17/08/2026**.

Il tempo è stato registrato al netto delle sospensioni.

```text
Tempo effettivo sviluppo    6 h 03 min
Pause complessive           3 h 05 min
```

La fase di sviluppo è stata conclusa alle:

> **21:41**

Il tempo effettivo di sviluppo della Sessione S019 è pertanto pari a:

> **6 h 03 min**

## Esito della Sessione S019

La Sessione S019 ha avviato concretamente l'implementazione SQL della baseline Database V1.

Il risultato principale della sessione comprende:

- creazione della prima migration versionata Database V1;
- implementazione delle prime sei tabelle Fondazioni;
- introduzione dello schema `private`;
- introduzione degli helper autorizzativi;
- introduzione dei trigger metadata;
- implementazione della prima matrice RLS;
- verifica di **13 policy RLS**;
- ricostruzione locale completa mediante `supabase db reset`;
- verifica della struttura effettivamente generata;
- utilizzo e successiva eliminazione del dump diagnostico;
- test manuali positivi e negativi della sicurezza;
- verifica dell'isolamento tra Profile e dei principali ruoli;
- commit e push del lavoro;
- repository finale pulito e sincronizzato.

La baseline Database V1 non è ancora completamente implementata.

La S019 costituisce il **primo incremento SQL verificato** della baseline progettata nella S017.

## Punto di continuità successivo

Il successivo blocco tecnico previsto riguarda la progettazione e l'implementazione delle **RPC sicure e atomiche** necessarie per le operazioni sensibili delle Fondazioni.

La priorità prevista riguarda `profile_edit_locks`, con particolare attenzione a:

- acquisizione del lock;
- heartbeat e rinnovo;
- rilascio;
- scadenza;
- richiesta di takeover;
- concorrenza tra dispositivi o client differenti;
- controllo di `row_version`;
- impedimento delle modifiche dirette alla tabella.

Un secondo gruppo previsto riguarda le operazioni amministrative su `profile_memberships`, tra cui:

- aggiunta o abilitazione di un membro;
- eventuale cambio di ruolo;
- disabilitazione;
- protezione dell'owner;
- prevenzione di condizioni che possano lasciare un Profile senza controllo;
- eliminazione della necessità di scritture dirette dal client.

La progettazione delle RPC dovrà inoltre valutare:

- privilegio minimo;
- utilizzo di `SECURITY DEFINER` soltanto quando necessario;
- `search_path` esplicito e sicuro;
- `REVOKE` e `GRANT EXECUTE` espliciti;
- verifica dell'identità mediante `auth.uid()`;
- assenza di fiducia nei dati di autorizzazione forniti dal client;
- comportamento in presenza di client concorrenti;
- test positivi;
- test negativi;
- tentativi di bypass.

Questi elementi costituiscono il punto di continuità previsto dopo la S019 e **non rappresentano funzionalità già implementate nella presente sessione**.

## Timing della documentazione

La documentazione della Sessione S019 è iniziata il **18/08/2026 alle 11:43**.

Il tempo di documentazione viene registrato al netto delle eventuali sospensioni.

| Fascia | Tempo |
| --- | ---: |
| 11:43 → 13:09 | 1 h 26 min |
| 14:43 → 15:27 | 44 min |
| **Totale documentazione S019** | **2 h 10 min** |

La pausa pranzo dalle **13:09 alle 14:43** è esclusa dal conteggio.

La documentazione della Sessione S019 si è conclusa il **18/08/2026 alle 15:27**.

## Tempo complessivo della Sessione S019

Sviluppo: **6 h 03 min**
Documentazione: **2 h 10 min**
Totale S019: **8 h 13 min**

La Sessione S019 è pertanto conclusa con un tempo effettivo complessivo di **8 h 13 min**, al netto delle sospensioni.

---

# Sessione S020 — Sicurezza concorrente `profile_edit_locks`

**Periodo sviluppo:** 18–20/08/2026
**Documentazione:** 20/08/2026 — 17:47→18:05 = 18 min

## Obiettivo della sessione

La Sessione S020 prosegue l'implementazione delle Fondazioni del Database V1 avviata nella S019, concentrandosi sulla gestione sicura e concorrente del lock di modifica del profilo.

L'obiettivo tecnico è impedire modifiche concorrenti non controllate allo stesso Profile e spostare sul database/server le decisioni sensibili relative ad acquisizione, mantenimento, rilascio e takeover del lock.

La progettazione segue i principi guida del progetto:

- **sicurezza prima di tutto**;
- **presto e bene non conviene**;
- privilegio minimo;
- nessuna fiducia nei dati di autorizzazione forniti dal client;
- operazioni sensibili atomiche e governate lato server.

## Timing dello sviluppo

La fase di sviluppo della Sessione S020 si è svolta tra il **18 e il 20 agosto 2026**.

| Fascia | Tempo |
| --- | ---: |
| 18/08 — 15:51 → 18:49 | 2 h 58 min |
| 19/08 — 15:29 → 16:22 | 53 min |
| 19→20/08 — 23:39 → 00:46 | 1 h 07 min |
| 20/08 — 14:52 → 16:30 | 1 h 38 min |
| **Totale sviluppo S020** | **6 h 36 min** |

Il tempo indicato rappresenta il lavoro effettivo di sviluppo registrato al netto delle sospensioni.

## APPROVATO / CONGELATO

Durante la Sessione S020 sono state consolidate le regole di sicurezza e concorrenza per `profile_edit_locks`.

Le decisioni approvate sono:

- il principio guida resta **sicurezza prima di tutto**;
- il principio operativo resta **presto e bene non conviene**;
- il `profile_edit_lock` può essere acquisito esclusivamente dall'**owner** del Profile;
- `worker` e `viewer` non possono acquisire il lock;
- il client comunica soltanto l'intenzione dell'operazione, mentre il server determina identità, autorizzazione, tempi e stato;
- `client_id` e `session_id` sono identificatori tecnici e **non costituiscono autenticazione**;
- il `lock_token` viene generato esclusivamente lato server;
- il token casuale ha lunghezza pari a **32 byte**;
- nel database viene conservato esclusivamente l'hash **SHA-256** del token;
- il token non deve essere persistito in chiaro;
- il token non deve comparire in log, interfaccia utente, URL o storage persistente;
- heartbeat previsto ogni **30 secondi**;
- durata del lease pari a **2 minuti**;
- validità della richiesta di takeover pari a **10 minuti**;
- validità del grant di takeover pari a **60 secondi**;
- il silenziamento delle nuove richieste di takeover può essere impostato a **5, 15 o 30 minuti**;
- l'orologio PostgreSQL costituisce l'unica autorità temporale;
- un lock scaduto non può essere resuscitato mediante heartbeat;
- sulle righe di lock esistenti viene utilizzato locking concorrente mediante `FOR UPDATE`;
- la prima acquisizione o il riciclo di un lock scaduto utilizza `INSERT ... ON CONFLICT`;
- nel V1 non viene introdotto un `lock_timeout` dedicato;
- un errore tecnico determina rollback completo dell'operazione;
- la UI non deve esporre dettagli tecnici interni relativi al lock;
- un retry non deve duplicare transizioni di stato né prolungare impropriamente i timer;
- in caso di risposta persa durante `acquire` o `complete takeover`, il V1 non introduce un meccanismo speciale di recovery: si attende la naturale scadenza del lease, fino a **2 minuti**, quindi si procede con una nuova acquisizione.

---

## IMPLEMENTATO E TESTATO

Nel corso della Sessione S020 sono stati implementati e verificati i primi meccanismi server-side necessari alla gestione sicura di `profile_edit_locks`.

### Helper privati

Sono presenti i seguenti helper nello schema `private`:

- `private.profile_edit_lock_token_hash(...)`;
- `private.is_profile_edit_lock_holder(...)`;
- `private.is_profile_auth_user_owner(...)`;
- `private.can_edit_profile(...)`.

Per gli helper privati è stato revocato `PUBLIC EXECUTE`.

### RPC implementate

Sono state implementate le seguenti RPC:

1. `acquire_profile_edit_lock`;
2. `heartbeat_profile_edit_lock`;
3. `release_profile_edit_lock`;
4. `request_profile_edit_takeover`;
5. `cancel_profile_edit_takeover`.

Le RPC sensibili sono state realizzate con:

- `SECURITY DEFINER`;
- `search_path = ''`;
- `EXECUTE` concesso a `authenticated` e `postgres`;
- `PUBLIC EXECUTE` revocato.

### Migrazioni introdotte

La Sessione S020 ha prodotto le seguenti migration:

20260818154920_harden_profile_edit_locks.sql
20260818162315_add_takeover_grant_state.sql
20260819215412_add_secure_profile_edit_lock_rpcs.sql

### Verifiche eseguite

I test eseguiti hanno verificato, tra gli altri, i seguenti scenari:

- acquisizione iniziale del lock;
- risposta `already_held`;
- risposta `busy`;
- riciclo corretto di un lock scaduto;
- rifiuto dell'acquisizione da parte di `viewer`;
- rifiuto dell'acquisizione da parte di `worker`;
- heartbeat valido;
- rifiuto di token errato;
- impossibilità di resuscitare un lock già scaduto;
- rilascio del lock;
- richiesta di takeover;
- annullamento della richiesta di takeover;
- comportamento previsto durante lo stato `transfer_pending`.

Le verifiche effettuate confermano il corretto funzionamento delle RPC attualmente implementate nei casi coperti dai test della sessione.

---

## APERTO / NON ANCORA IMPLEMENTATO

Lo STEP 4.32 non è ancora concluso.

Restano da implementare le seguenti RPC:

- `reject_profile_edit_takeover`;
- `grant_profile_edit_takeover`;
- `complete_profile_edit_takeover`;
- `get_profile_edit_lock_state`.

Il punto esatto di ripresa dello sviluppo è:

`STEP 4.32.11 — reject_profile_edit_takeover`

Dopo l'implementazione di `reject_profile_edit_takeover` dovrà essere verificato anche il comportamento `silenced` già previsto in `request_profile_edit_takeover`.

Questi elementi appartengono allo stato aperto della Sessione S020 e non devono essere considerati già implementati o testati.

## Stato Git al passaggio alla documentazione

All'apertura della fase documentale S020 lo stato del repository è stato verificato direttamente.

```text
branch       main
HEAD         f167b57
origin/main  a7e1c4e

main avanti di 3 commit rispetto a origin/main
working tree clean
```

I tre commit locali di sviluppo sono:

```text
f167b57  Aggiunge RPC sicure per profile edit lock
c4ab49e  Aggiunge stato sicuro takeover grant
b4a7311  Rafforza sicurezza profile edit locks
```

Al momento del passaggio alla documentazione i tre commit di sviluppo non risultano ancora pubblicati su `origin/main`.

Nessun push viene eseguito prima del completamento e della verifica della documentazione S020.

## Punto di continuità successivo

La Sessione S020 non conclude ancora lo STEP 4.32.

Il successivo punto tecnico da affrontare nello sviluppo è:

`STEP 4.32.11 — reject_profile_edit_takeover`

Dopo questa RPC dovranno essere completate e verificate anche:

- `grant_profile_edit_takeover`;
- `complete_profile_edit_takeover`;
- `get_profile_edit_lock_state`.

Dovrà inoltre essere verificato il comportamento `silenced` già previsto in `request_profile_edit_takeover`.

Fino al completamento e ai test di questi elementi, la gestione completa del takeover di `profile_edit_locks` resta parziale.

## Tempo complessivo della Sessione S020

Sviluppo: **6 h 36 min**
Documentazione: **18 min**
Totale S020: **6 h 54 min**