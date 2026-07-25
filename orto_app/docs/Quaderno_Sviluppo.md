# Quaderno di Sviluppo - Orto Smart

## Scopo

Questo documento rappresenta la cronologia tecnica dello sviluppo di **Orto Smart**.

Il suo obiettivo è documentare l'evoluzione del progetto, le decisioni progettuali, le funzionalità implementate, i problemi riscontrati e le soluzioni adottate durante lo sviluppo.

Il Quaderno di Sviluppo viene aggiornato al termine di ogni sessione di lavoro e costituisce il riferimento storico ufficiale del progetto.

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

---

# 1. Visione del progetto

Orto Smart nasce con l'obiettivo di realizzare un sistema completo per la gestione di un orto domestico, capace di assistere l'utente durante l'intero ciclo colturale.

Il progetto non vuole essere solamente un registro delle coltivazioni, ma un vero assistente agronomico capace di supportare la pianificazione, la coltivazione, l'irrigazione, la raccolta e l'analisi storica dell'orto.

Nel lungo periodo il sistema integrerà dati meteorologici, irrigazione intelligente, motore agronomico, statistiche e strumenti di supporto alle decisioni.

---

# 2. Obiettivi iniziali

Gli obiettivi definiti all'avvio del progetto sono:

- gestione dell'orto e delle aiuole;
- gestione delle colture;
- pianificazione delle semine;
- visualizzazione grafica delle aiuole;
- motore agronomico;
- suggerimento automatico degli spazi liberi;
- rotazioni colturali;
- consociazioni;
- diario delle attività;
- gestione irrigazione;
- integrazione con dati meteo;
- futura automazione mediante Raspberry Pi;
- statistiche e storico delle coltivazioni.

---

# 3. Evoluzione del progetto

L'evoluzione del progetto viene documentata attraverso la cronologia delle sessioni riportata nel capitolo 5.

Ogni sessione descrive le funzionalità sviluppate, le decisioni prese e lo stato del progetto al termine dei lavori.

---

# 4. Architettura del progetto

L'architettura tecnica dettagliata è descritta nel documento:

**Manuale_Tecnico.md**

In questo Quaderno vengono riportate solamente le decisioni architetturali più importanti che hanno influenzato l'evoluzione del progetto.

---

# 5. Cronologia delle sessioni

## Sessione S001

*Da ricostruire mediante cronologia Git e documentazione disponibile.*

---

## Sessione S002 - Organizzazione della documentazione

**Data:** 25/07/2026

### Obiettivo

Definire un metodo di lavoro stabile per il progetto Orto Smart e organizzare la documentazione tecnica.

### Attività svolte

- Definito il workflow ufficiale di sviluppo.
- Stabilito che la cartella `docs` rappresenta la fonte ufficiale della documentazione.
- Definita la struttura della documentazione del progetto.
- Creato il Quaderno di Sviluppo.
- Eliminato il file `ARCHITETTURA.md`, sostituito dal futuro `Manuale_Tecnico.md`.
- Analizzata la cronologia Git del progetto.
- Definito il metodo di aggiornamento della documentazione.
- Aggiornato il documento "Metodo di Lavoro Ufficiale".

### Decisioni progettuali

- La documentazione ufficiale risiede esclusivamente nella cartella `docs`.
- Ogni sessione termina con l'aggiornamento del Quaderno di Sviluppo.
- Il riepilogo della sessione viene preparato dall'assistente e successivamente salvato nel repository.
- Codice, test e documentazione devono evolvere insieme.

### Verifiche eseguite

- `flutter analyze`
- `flutter test` (32 test superati)

### Stato finale

È stato definito il metodo di lavoro ufficiale del progetto.

La struttura della documentazione è pronta ad accompagnare tutte le future fasi di sviluppo.

---

# 6. Decisioni progettuali principali

In questa sezione vengono riportate solamente le decisioni che modificano in modo significativo il progetto.

Esempi:

- cambiamenti architetturali;
- nuove convenzioni di sviluppo;
- modifiche al database;
- introduzione di nuovi moduli;
- cambiamenti del workflow.

---

# 7. Problemi risolti

Questa sezione raccoglie i principali problemi affrontati durante lo sviluppo e le relative soluzioni.

In questo modo sarà possibile evitare di ripetere errori già risolti.

---

# 8. Roadmap futura

Le principali funzionalità pianificate sono:

- completamento del motore agronomico;
- suggerimento automatico degli spazi liberi;
- miglioramento della grafica delle aiuole;
- gestione completa delle lavorazioni;
- gestione raccolti;
- statistiche;
- integrazione dati meteo;
- irrigazione intelligente;
- integrazione Raspberry Pi;
- applicazione mobile completa;
- assistente AI dedicato a Orto Smart.

---

**Ultimo aggiornamento:** Sessione S002