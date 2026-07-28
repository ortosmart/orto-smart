# CHANGELOG

Il presente documento registra tutte le modifiche rilevanti apportate al progetto **Orto Smart** tra una versione e la successiva.

Lo scopo del CHANGELOG è fornire una cronologia sintetica dell'evoluzione del software, evidenziando nuove funzionalità, miglioramenti, correzioni e modifiche significative.

Per il dettaglio delle singole sessioni di sviluppo fare riferimento al **DOC-005 – Quaderno di Sviluppo**.

Le regole e il workflow di sviluppo del progetto sono definiti nel **DOC-006 – Linee Guida di Sviluppo**.

---

# Regole di aggiornamento

Il CHANGELOG viene aggiornato quando una modifica introduce nuove funzionalità, migliora il comportamento del software, corregge bug o modifica aspetti rilevanti del progetto.

Le modifiche vengono classificate nelle seguenti categorie:

- **Aggiunto**
- **Modificato**
- **Corretto**
- **Rimosso**
- **Sicurezza**

Le attività dettagliate delle singole sessioni vengono invece documentate nel **DOC-005 – Quaderno di Sviluppo**.

---

# Versione 0.1.0-alpha

**Data:** 27/07/2026

## Aggiunto

- Creato il progetto Flutter.
- Configurato il repository GitHub.
- Integrato Supabase come backend.
- Realizzata la struttura iniziale del database.
- Implementata la gestione di orti, aiuole, colture e stagioni.
- Implementata la gestione delle piantagioni.
- Creata la visualizzazione grafica delle aiuole.
- Implementato il Repository Pattern.
- Sviluppata la prima versione del Motore Agronomico.
- Implementati `FreeSpaceEngine` e `SuggestionEngine`.
- Creato il **DOC-001 – Manuale Tecnico**.
- Creato il **DOC-005 – Quaderno di Sviluppo**.
- Creato il **DOC-008 – Roadmap di Sviluppo**.

## Modificato

- Ordinamento delle aiuole da 1 a 15.
- Migliorata la rappresentazione grafica delle aiuole.
- Esteso il modello `Planting`.
- Riorganizzata la cartella `docs`.
- Definito il workflow ufficiale di sviluppo.

## Corretto

- Risolti problemi di inserimento delle piantagioni.
- Corrette le Foreign Key del modulo irrigazione.
- Sistemate le policy RLS di Supabase.
- Eliminati gli errori segnalati da `flutter analyze`.
- Corrette anomalie nella visualizzazione grafica delle aiuole.

## Sicurezza

- Abilitata la Row Level Security (RLS) nelle tabelle Supabase.
- Verificate le policy di accesso ai dati.

---

# Versione 0.1.1-alpha

**Data:** 27/07/2026

## Aggiunto

- Prima versione del **Companion Engine**.
- Modello `CompanionRule`.
- Modello `CompanionResult`.
- Archivio delle regole di consociazione (`companion_rules.dart`).
- Prime regole agronomiche tra le colture.
- Nuovi test automatici per il motore delle consociazioni.

## Modificato

- Riorganizzata l'architettura del modulo `core/agronomy`.
- Migliorata la separazione tra Models, Data ed Engines.
- Definito il workflow ufficiale di sviluppo del progetto.

## Corretto

- Rimossi file duplicati.
- Corretti import ambigui.
- Spostati i file di test nella cartella dedicata.
- Pulita la struttura del progetto.

## Sicurezza

Nessuna modifica.

---

# Versione 0.1.2-alpha

**Data:** 28/07/2026

## Aggiunto

- Introdotto `BedAnalysisService` come servizio centralizzato per il coordinamento delle analisi dell'aiuola.
- Implementato `BedCompanionAnalyzer`.
- Creati i modelli `BedCompanionAnalysis` e `CompanionPairAnalysis`.
- Aggiunti i test unitari per `BedCompanionAnalyzer` e `BedAnalysisService`.

## Modificato

- Convertiti gli identificativi delle colture da `int` a `String` in tutto il motore delle consociazioni.
- Allineato il modello dati agronomico al modello dati di Supabase.
- Integrata `BedPage` con `BedAnalysisService` per l'analisi degli spazi e la generazione dei suggerimenti.
- Consolidata l'architettura del motore agronomico introducendo `BedAnalysisService` come orchestratore delle analisi dell'aiuola.

## Corretto

- Eliminate le conversioni tra identificativi numerici e stringhe nel motore delle consociazioni.
- Aggiornati i test unitari dopo il refactoring dell'architettura.
- Uniformato il motore agronomico al nuovo modello dati.

## Sicurezza

Nessuna modifica.

---

# Cronologia versioni

| Versione | Data | Stato | Note |
|-----------|------------|------------|--------------------------------------------------------------|
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto. |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico. |
| 0.1.2-alpha | 28/07/2026 | Corrente | Introdotto `BedAnalysisService`, implementato `BedCompanionAnalyzer` e consolidata l'architettura delle analisi agronomiche. |