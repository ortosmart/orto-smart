# DOC-005 – Quaderno di Sviluppo Orto Smart

| Campo | Valore |
|-------|--------|
| Documento | DOC-005 |
| Titolo | Quaderno di Sviluppo Orto Smart |
| Versione | 0.2 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Linguaggio | Flutter / Dart |
| Backend | Supabase |
| Data prima emissione | 26/07/2026 |
| Ultimo aggiornamento | 27/07/2026 |

---

# Scopo

Il **Quaderno di Sviluppo** rappresenta il diario tecnico ufficiale del progetto **Orto Smart**.

Il suo scopo è documentare, in ordine cronologico, l'evoluzione del software, descrivendo le attività svolte durante ogni sessione di sviluppo, le decisioni progettuali adottate, le problematiche affrontate, le soluzioni implementate e lo stato raggiunto dal progetto.

A differenza del **CHANGELOG**, che riporta una sintesi delle modifiche introdotte tra una versione e la successiva, il Quaderno di Sviluppo conserva la cronologia completa del lavoro svolto e costituisce il riferimento storico dell'intero progetto.

Il documento viene aggiornato al termine di ogni sessione di sviluppo e accompagna costantemente l'evoluzione del software.

---

# Filosofia del progetto

Orto Smart nasce come progetto personale con l'obiettivo di realizzare un sistema completo per la gestione tecnica e agronomica di un orto reale.

Lo sviluppo del progetto segue alcuni principi fondamentali:

- sviluppo incrementale, una funzionalità alla volta;
- codice semplice, leggibile e facilmente manutenibile;
- documentazione aggiornata insieme al codice;
- utilizzo di Git per il controllo delle versioni;
- database progettato per essere efficiente e ridurre al minimo lo spazio occupato;
- eliminazione delle duplicazioni inutili dei dati;
- separazione tra interfaccia utente, logica applicativa e accesso ai dati;
- tracciabilità delle decisioni progettuali.

Ogni sessione di sviluppo segue il workflow ufficiale definito nel **DOC-006 – Linee Guida di Sviluppo**, che prevede:

1. Progettazione dell'architettura.
2. Preparazione della struttura del progetto.
3. Implementazione del codice.
4. Esecuzione di `flutter analyze`.
5. Esecuzione di `flutter test`.
6. Aggiornamento della documentazione.
7. Commit Git.
8. Push sul repository GitHub.

Questo documento costituisce il diario tecnico ufficiale del progetto e rappresenta il riferimento storico delle principali decisioni adottate durante lo sviluppo.

---

# Indice

1. Visione del progetto
2. Obiettivi iniziali
3. Evoluzione del progetto
4. Architettura del progetto
5. Cronologia delle sessioni
6. Decisioni progettuali principali
7. Problemi risolti
8. Roadmap futura
9. Cronologia revisioni

---

# 1. Visione del progetto

Orto Smart nasce con l'obiettivo di realizzare un sistema completo per la gestione di un orto domestico, capace di assistere l'utente durante l'intero ciclo colturale.

Il progetto non vuole limitarsi alla registrazione delle coltivazioni, ma evolvere in un vero assistente agronomico in grado di supportare la pianificazione delle colture, la gestione delle aiuole, l'irrigazione, la raccolta, l'analisi storica dei dati e il processo decisionale.

Nel lungo periodo il sistema integrerà dati meteorologici, irrigazione intelligente, motore agronomico, statistiche, automazione e strumenti di supporto alle decisioni.

---

# 2. Obiettivi iniziali

Gli obiettivi definiti all'avvio del progetto sono:

- gestione dell'orto e delle aiuole;
- gestione delle colture;
- pianificazione delle semine e dei trapianti;
- visualizzazione grafica delle aiuole;
- motore agronomico;
- individuazione automatica degli spazi liberi;
- suggerimento del posizionamento delle colture;
- gestione delle consociazioni;
- gestione delle rotazioni colturali;
- diario delle attività;
- gestione dell'irrigazione;
- integrazione con i dati meteorologici;
- futura automazione mediante Raspberry Pi;
- statistiche e storico delle coltivazioni.

---

# 3. Evoluzione del progetto

L'evoluzione del progetto viene documentata attraverso la cronologia delle sessioni riportata nel Capitolo 5.

Ogni sessione descrive:

- gli obiettivi prefissati;
- le attività svolte;
- le decisioni progettuali adottate;
- le verifiche effettuate;
- lo stato del progetto al termine dei lavori.

La cronologia delle sessioni costituisce la memoria tecnica ufficiale dell'intero sviluppo.

---

# 4. Architettura del progetto

L'architettura tecnica del software è descritta nel **DOC-001 – Manuale Tecnico**.

Il presente documento riporta esclusivamente le decisioni architetturali che hanno influenzato l'evoluzione del progetto e le motivazioni che hanno portato alle principali scelte progettuali.
---

# 5. Cronologia delle sessioni

## Sessione S001 – Avvio del progetto

**Data:** Da ricostruire

### Obiettivo

Avviare il progetto Orto Smart e definire le basi tecniche e organizzative per lo sviluppo dell'applicazione.

### Attività svolte

La documentazione disponibile non consente ancora di ricostruire con precisione le attività svolte durante questa prima fase.

La ricostruzione della sessione verrà effettuata attraverso:

- cronologia Git del repository;
- primi commit del progetto;
- documentazione storica disponibile;
- file sorgente iniziali.

### Decisioni progettuali

Le decisioni tecniche adottate durante questa fase verranno integrate dopo la ricostruzione della cronologia completa del progetto.

### Verifiche eseguite

Non disponibili.

### Stato finale

Sessione in fase di ricostruzione.

---

## Sessione S002 – Organizzazione della documentazione

**Data:** 25/07/2026

### Obiettivo

Definire un metodo di lavoro stabile per il progetto Orto Smart e organizzare la documentazione tecnica affinché accompagni costantemente lo sviluppo del software.

### Attività svolte

Durante questa sessione sono state definite le basi organizzative del progetto.

In particolare sono state svolte le seguenti attività:

- definizione del workflow ufficiale di sviluppo;
- individuazione della cartella `docs` come archivio ufficiale della documentazione;
- progettazione della struttura della documentazione tecnica;
- creazione del **DOC-005 – Quaderno di Sviluppo**;
- sostituzione del precedente `ARCHITETTURA.md` con il futuro **DOC-001 – Manuale Tecnico**;
- analisi della cronologia Git del progetto;
- definizione delle modalità di aggiornamento della documentazione;
- aggiornamento del metodo di lavoro ufficiale.

### Decisioni progettuali

Durante la sessione sono state approvate le seguenti decisioni:

- la documentazione ufficiale del progetto risiede esclusivamente nella cartella `docs`;
- ogni sessione di sviluppo termina con l'aggiornamento della documentazione;
- il Quaderno di Sviluppo rappresenta il diario tecnico ufficiale del progetto;
- codice, test e documentazione devono evolvere in modo sincronizzato;
- la cronologia delle versioni viene mantenuta nel **CHANGELOG**, mentre il dettaglio delle attività viene registrato nel Quaderno di Sviluppo.

### Verifiche eseguite

- `flutter analyze`
- `flutter test` (**32 test superati**)

### Stato finale

È stato definito il metodo di lavoro ufficiale del progetto.

La struttura della documentazione è pronta ad accompagnare tutte le successive fasi di sviluppo e costituisce la base organizzativa dell'intero progetto.

### Documentazione aggiornata

- ✅ VERSION
- ✅ CHANGELOG
- ✅ DOC-005 – Quaderno di Sviluppo

---

## Sessione S003 – FreeSpaceEngine e SuggestionEngine

**Data:** 26/07/2026

### Obiettivo

Realizzare il primo nucleo del Motore Agronomico per individuare automaticamente gli spazi liberi presenti nelle aiuole e suggerire il posizionamento ottimale di una nuova coltura.

### Attività svolte

Durante questa sessione è stata sviluppata la prima parte del Motore Agronomico, introducendo i moduli **FreeSpaceEngine** e **SuggestionEngine**.

#### FreeSpaceEngine

Sono stati implementati i componenti necessari per individuare automaticamente gli spazi disponibili all'interno di un'aiuola.

In particolare sono stati realizzati:

- la classe `FreeSpace`;
- il motore `FreeSpaceEngine`;
- il calcolo automatico degli spazi liberi;
- l'ordinamento automatico delle colture;
- la gestione delle principali configurazioni dell'aiuola.

Il motore è in grado di gestire correttamente i seguenti casi:

- aiuola completamente vuota;
- presenza di una coltura;
- presenza di più colture;
- colture adiacenti;
- aiuola completamente occupata.

#### SuggestionEngine

Successivamente è stata sviluppata la prima versione del **SuggestionEngine**.

Sono state implementate le seguenti funzionalità:

- metodo `suggestSpaces()`;
- ricerca degli spazi compatibili con la lunghezza richiesta;
- ordinamento dei suggerimenti secondo il criterio **Best Fit**, privilegiando lo spazio sufficiente più piccolo.

Questa soluzione costituisce la base per i futuri algoritmi di pianificazione automatica delle colture.

### Decisioni progettuali

Durante la sessione sono state adottate le seguenti decisioni:

- separare la ricerca degli spazi dalla logica di suggerimento;
- utilizzare oggetti `FreeSpace` come interfaccia tra i due motori;
- progettare un'architettura modulare, facilmente estendibile con nuovi motori agronomici;
- predisporre il sistema per l'integrazione di consociazioni, rotazioni colturali e algoritmi di valutazione.

### Verifiche eseguite

- `flutter analyze` → Nessun problema rilevato.
- `flutter test` → **40 test superati**.

### Stato finale

È stata completata la prima versione del Motore Agronomico dedicata all'individuazione degli spazi disponibili e al suggerimento automatico del posizionamento delle colture.

L'architettura risulta ora predisposta per l'introduzione dei successivi moduli dedicati alle consociazioni, alle rotazioni colturali e ai sistemi di valutazione agronomica.

### Documentazione aggiornata

- ✅ VERSION
- ✅ CHANGELOG
- ✅ DOC-001 – Manuale Tecnico
- ✅ DOC-005 – Quaderno di Sviluppo
- ✅ DOC-008 – Roadmap di Sviluppo
---

## Sessione S004 – Companion Engine e Motore delle Consociazioni

**Data:** 27/07/2026

### Obiettivo

Realizzare la prima versione del **Companion Engine**, introdurre il Motore delle Consociazioni e consolidare l'architettura del Motore Agronomico attraverso una riorganizzazione del progetto e la verifica della qualità del codice.

### Attività svolte

Durante questa sessione è stato sviluppato il primo modulo dedicato all'analisi delle consociazioni tra colture, completando la terza componente del Motore Agronomico.

Parallelamente è stata eseguita una revisione dell'architettura del progetto, con l'obiettivo di migliorarne l'organizzazione, la manutenibilità e l'estendibilità.

#### Riordino dell'architettura

Sono state svolte le seguenti attività:

- verifica della struttura delle cartelle `lib` e `test`;
- individuazione e correzione di file collocati in percorsi non corretti;
- eliminazione di file inutilizzati o duplicati;
- controllo finale dell'albero del progetto.

Al termine della riorganizzazione il progetto presenta una struttura più ordinata, modulare e facilmente estendibile.

#### Companion Engine

È stata realizzata la prima versione del **Companion Engine**, incaricato di valutare la compatibilità agronomica tra due colture.

Sono stati introdotti i seguenti componenti:

- `CompanionRule`, modello che rappresenta una regola di consociazione;
- `CompanionResult`, modello che rappresenta il risultato dell'analisi, indipendente dall'interfaccia utente.

#### Archivio delle regole

È stato creato il file:

`lib/core/agronomy/data/companion_rules.dart`

contenente:

- identificativi delle colture (`CropIds`);
- archivio delle prime regole di consociazione.

Le prime regole implementate riguardano:

- Pomodoro ↔ Basilico;
- Lattuga ↔ Zucchine;
- Pomodoro ↔ Zucchine.

#### Implementazione del motore

Sono stati sviluppati i principali metodi del Companion Engine:

- `findRule()`, per la ricerca delle regole di consociazione;
- `analyze()`, che restituisce un oggetto `CompanionResult` contenente il livello di compatibilità e il relativo messaggio descrittivo.

Quando non esiste una regola specifica tra due colture, il motore restituisce automaticamente una compatibilità neutrale.

#### Test automatici

Sono stati realizzati nuovi test per verificare:

- ricerca delle regole;
- gestione dell'ordine inverso delle colture;
- comportamento in assenza di regole;
- corretto funzionamento del metodo `analyze()`;
- messaggi restituiti;
- livello di compatibilità.

Tutti i test sono stati completati con esito positivo.

### Decisioni progettuali

Durante la sessione è stato consolidato il workflow ufficiale del progetto, che prevede:

1. progettazione dell'architettura;
2. preparazione della struttura del progetto;
3. implementazione del codice;
4. esecuzione di `flutter analyze`;
5. esecuzione di `flutter test`;
6. aggiornamento della documentazione;
7. commit Git;
8. push sul repository GitHub.

È stata inoltre confermata la suddivisione del Motore Agronomico in moduli indipendenti, così da favorire l'evoluzione del progetto senza aumentare l'accoppiamento tra i componenti.

### Verifiche eseguite

- `flutter analyze` → Nessun problema rilevato.
- `flutter test` → Tutti i test superati.

### Stato finale

Al termine della sessione il Motore Agronomico risulta composto dai seguenti moduli:

- FreeSpaceEngine;
- SuggestionEngine;
- CompanionEngine.

L'architettura è ora pronta per lo sviluppo del **Bed Companion Analyzer**, che analizzerà automaticamente la compatibilità tra tutte le colture presenti in una stessa aiuola.

### Documentazione aggiornata

- ✅ VERSION
- ✅ CHANGELOG
- ✅ DOC-001 – Manuale Tecnico
- ✅ DOC-005 – Quaderno di Sviluppo
- ✅ DOC-008 – Roadmap di Sviluppo

---

# 6. Decisioni progettuali principali

In questa sezione vengono riportate esclusivamente le decisioni che hanno modificato in modo significativo l'architettura, il workflow o l'organizzazione del progetto.

Tra le principali decisioni adottate:

- utilizzo di Flutter come framework di sviluppo;
- adozione di Supabase come backend;
- utilizzo del Repository Pattern per l'accesso ai dati;
- separazione tra interfaccia utente, logica applicativa e accesso ai dati;
- sviluppo modulare del Motore Agronomico;
- utilizzo di Git per il controllo delle versioni;
- aggiornamento della documentazione al termine di ogni sessione di sviluppo;
- organizzazione della documentazione ufficiale nella cartella `docs`.

Nuove decisioni progettuali verranno aggiunte in questa sezione quando influenzeranno in modo significativo l'evoluzione del progetto.

---

# 7. Problemi risolti

Questa sezione raccoglie i principali problemi affrontati durante lo sviluppo e le relative soluzioni adottate.

L'obiettivo è conservare la memoria tecnica del progetto, facilitare la manutenzione del codice ed evitare il ripetersi di problematiche già risolte.

Tra i principali interventi effettuati:

- correzione delle Foreign Key del modulo irrigazione;
- risoluzione dei problemi di inserimento delle piantagioni;
- configurazione delle policy Row Level Security (RLS) di Supabase;
- eliminazione degli errori segnalati da `flutter analyze`;
- correzione delle anomalie nella rappresentazione grafica delle aiuole;
- riorganizzazione dell'architettura del progetto e dei file di test.

---

# 8. Roadmap futura

Le principali funzionalità pianificate per le prossime fasi di sviluppo sono:

- Bed Companion Analyzer;
- Motore delle Rotazioni Colturali;
- sistema di valutazione agronomica dei suggerimenti;
- miglioramento della rappresentazione grafica delle aiuole;
- gestione completa delle lavorazioni;
- gestione dei raccolti;
- statistiche e analisi storiche;
- integrazione con i dati meteorologici;
- irrigazione intelligente;
- integrazione con Raspberry Pi;
- applicazione mobile completa;
- assistente AI dedicato a Orto Smart.

L'elenco dettagliato delle attività pianificate è riportato nel **DOC-008 – Roadmap di Sviluppo**, che rappresenta il riferimento ufficiale per la pianificazione del progetto.

---

# Cronologia revisioni

| Revisione | Data | Descrizione |
|-----------|------------|------------------------------------------------------------|
| 0.1 | 26/07/2026 | Prima emissione del Quaderno di Sviluppo con ricostruzione delle sessioni S001-S003. |
| 0.2 | 27/07/2026 | Inserita la Sessione S004, consolidato il workflow ufficiale e documentato il primo Motore delle Consociazioni. |

---

**Documento:** DOC-005 – Quaderno di Sviluppo Orto Smart

**Versione:** 0.2

**Stato:** In sviluppo

**Ultimo aggiornamento:** Sessione S004

**Documento correlato:**

- DOC-001 – Manuale Tecnico
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- CHANGELOG
- VERSION