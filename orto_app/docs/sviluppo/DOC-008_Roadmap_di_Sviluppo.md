# DOC-008 – Roadmap di Sviluppo

| Campo | Valore |
|-------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 0.2 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Data prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 27/07/2026 |

---

# 1. Scopo

La **Roadmap di Sviluppo** descrive l'evoluzione prevista del progetto **Orto Smart**.

Il documento rappresenta il riferimento ufficiale per la pianificazione delle attività di sviluppo e viene aggiornato al termine delle principali sessioni di lavoro.

Le funzionalità sono organizzate in macro-aree e classificate in base al loro stato di avanzamento.

---

# 2. Stato del progetto

| Stato | Significato |
|--------|-------------|
| ✅ Completato | Funzionalità implementata e verificata |
| 🚧 In sviluppo | Funzionalità attualmente in lavorazione |
| 📋 Pianificato | Funzionalità prevista nelle prossime versioni |
| 💡 Idea | Possibile sviluppo futuro |

---

# 3. Roadmap generale

## 3.1 Architettura

| Funzionalità | Stato |
|--------------|:-----:|
| Struttura Flutter | ✅ Completato |
| Supabase | ✅ Completato |
| Repository Pattern | ✅ Completato |
| Modelli | ✅ Completato |
| Database | ✅ Completato |

---

## 3.2 Gestione orto

| Funzionalità | Stato |
|--------------|:-----:|
| Elenco aiuole | ✅ Completato |
| Visualizzazione aiuola | ✅ Completato |
| Ordinamento aiuole | ✅ Completato |
| Inserimento colture | ✅ Completato |
| Modifica colture | ✅ Completato |
| Eliminazione colture | 📋 Pianificato |

---

## 3.3 Motore Agronomico

| Funzionalità | Stato | Note |
|--------------|:-----:|------|
| FreeSpaceEngine | ✅ Completato | Calcolo automatico degli spazi liberi nelle aiuole. |
| SuggestionEngine | ✅ Completato | Individuazione del miglior spazio disponibile mediante algoritmo Best Fit. |
| Companion Engine | ✅ Completato | Prima versione del motore delle consociazioni con `CompanionRule`, `CompanionResult` e archivio delle regole. |
| Bed Companion Analyzer | 📋 Pianificato | Analisi automatica delle compatibilità tra tutte le colture presenti in un'aiuola. |
| Motore delle Rotazioni | 📋 Pianificato | Verifica delle successioni colturali tra le stagioni. |
| Sistema di Punteggio Agronomico | 📋 Pianificato | Valutazione complessiva delle aiuole basata su consociazioni, rotazioni e altri fattori agronomici. |

---

## 3.4 Irrigazione

| Funzionalità | Stato |
|--------------|:-----:|
| Gestione manuale | 🚧 In sviluppo |
| Storico irrigazioni | 📋 Pianificato |
| Zone irrigazione | 📋 Pianificato |
| Raspberry Pi | 📋 Pianificato |
| ESP32 | 📋 Pianificato |
| Sensori del terreno | 📋 Pianificato |
| Irrigazione automatica | 📋 Pianificato |

---

## 3.5 Dashboard

| Funzionalità | Stato |
|--------------|:-----:|
| Dashboard iniziale | 🚧 In sviluppo |
| Meteo | 📋 Pianificato |
| Attività giornaliere | 📋 Pianificato |
| Stato dell'orto | 📋 Pianificato |
| Avvisi | 📋 Pianificato |
| Indicatori | 📋 Pianificato |

---

## 3.6 Attività

| Funzionalità | Stato |
|--------------|:-----:|
| Diario attività | 📋 Pianificato |
| Piano di lavoro | 📋 Pianificato |
| Timer "Inizia lavoro" | 📋 Pianificato |
| Storico lavorazioni | 📋 Pianificato |
| Tempi di lavoro | 📋 Pianificato |

---

## 3.7 Statistiche

| Funzionalità | Stato |
|--------------|:-----:|
| Produzione | 📋 Pianificato |
| Costi | 📋 Pianificato |
| Risparmio economico | 📋 Pianificato |
| Tempo dedicato | 📋 Pianificato |
| Grafici | 📋 Pianificato |

---

## 3.8 Versioni future

### Versione 0.x

Completamento delle funzionalità fondamentali dell'applicazione.

### Versione 1.0

Prima versione stabile destinata all'utilizzo quotidiano.

### Versione 2.0

Consolidamento del Motore Agronomico e introduzione delle principali funzionalità avanzate.

### Versione 3.0

Sistema completo di irrigazione intelligente e integrazione hardware.

### Versione 4.0

Assistente intelligente dedicato alla gestione completa dell'orto.

---

# 4. Prossime attività

## Sessione S005

### Obiettivo principale

Realizzare il **Bed Companion Analyzer**, che analizzerà automaticamente tutte le colture presenti in un'aiuola.

### Attività previste

- analizzare tutte le coppie di colture presenti nell'aiuola;
- individuare compatibilità e incompatibilità;
- calcolare un punteggio agronomico complessivo dell'aiuola;
- generare suggerimenti automatici per migliorare le consociazioni;
- predisporre l'integrazione con il SuggestionEngine.

### Risultato atteso

Completare il **Bed Companion Analyzer** e predisporre il Motore Agronomico per l'integrazione del futuro **Motore delle Rotazioni Colturali**.

---

# 5. Cronologia revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione della Roadmap di Sviluppo. |
| 0.2 | 27/07/2026 | Aggiornata dopo la Sessione S004 con il Companion Engine e la pianificazione della Sessione S005. |

---

**Documento:** DOC-008 – Roadmap di Sviluppo

**Versione:** 0.2

**Stato:** In sviluppo

**Ultimo aggiornamento:** Sessione S004

**Documenti correlati:**

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-006 – Linee Guida di Sviluppo
- CHANGELOG
- VERSION