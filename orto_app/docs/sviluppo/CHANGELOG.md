# ORTO SMART

### CHANGELOG

# Registro delle modifiche

**Versione:** 1.1
**Stato:** Approvato

**Autore:** Renzo Siega  
**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026
**Ultimo aggiornamento:** 08/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | CHANGELOG |
| Titolo | Registro delle modifiche |
| Versione | 1.1 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 08/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione del documento CHANGELOG |
| 0.2 | 01/08/2026 | Revisione della struttura documentale e allineamento con la documentazione tecnica |
| 1.0 | 01/08/2026 | Revisione completa e approvazione del CHANGELOG |
| 1.1      | 08/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.4-alpha e introduzione di DecisionWeights |

---

# Indice

## 1. Scopo del documento

## 2. Regole di aggiornamento

## 3. Registro delle versioni
3.1 Versione 0.1.0-alpha  
3.2 Versione 0.1.1-alpha  
3.3 Versione 0.1.2-alpha
3.4 Versione 0.1.3-alpha
3.5 Versione 0.1.4-alpha

## 4. Cronologia versioni

## 5. Considerazioni finali

---

# 1. Scopo del documento

Il presente documento registra tutte le modifiche rilevanti apportate al progetto **Orto Smart** tra una versione e la successiva.

Lo scopo del CHANGELOG è fornire una cronologia sintetica dell'evoluzione del software, evidenziando nuove funzionalità, miglioramenti, correzioni e modifiche significative.

Per il dettaglio delle singole sessioni di sviluppo fare riferimento al **DOC-005 – Quaderno di Sviluppo**.

Le regole e il workflow di sviluppo del progetto sono definiti nel **DOC-006 – Linee Guida di Sviluppo**.

---

# 2. Regole di aggiornamento

Il CHANGELOG viene aggiornato quando una modifica introduce nuove funzionalità, migliora il comportamento del software, corregge bug o modifica aspetti rilevanti del progetto.

Le modifiche vengono classificate nelle seguenti categorie:

- **Aggiunto**
- **Modificato**
- **Corretto**
- **Rimosso**
- **Sicurezza**

Le attività dettagliate delle singole sessioni vengono invece documentate nel **DOC-005 – Quaderno di Sviluppo**.

---

# 3. Registro delle versioni

## 3.1 Versione 0.1.0-alpha

**Data:** 27/07/2026

### Aggiunto

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

### Modificato

- Ordinamento delle aiuole da 1 a 15.
- Migliorata la rappresentazione grafica delle aiuole.
- Esteso il modello `Planting`.
- Riorganizzata la cartella `docs`.
- Definito il workflow ufficiale di sviluppo.

### Corretto

- Risolti problemi di inserimento delle piantagioni.
- Corrette le Foreign Key del modulo irrigazione.
- Sistemate le policy RLS di Supabase.
- Eliminati gli errori segnalati da `flutter analyze`.
- Corrette anomalie nella visualizzazione grafica delle aiuole.

### Sicurezza

- Abilitata la Row Level Security (RLS) nelle tabelle Supabase.
- Verificate le policy di accesso ai dati.

---

## 3.2 Versione 0.1.1-alpha

**Data:** 27/07/2026

### Aggiunto

- Prima versione del **Companion Engine**.
- Modello `CompanionRule`.
- Modello `CompanionResult`.
- Archivio delle regole di consociazione (`companion_rules.dart`).
- Prime regole agronomiche tra le colture.
- Nuovi test automatici per il motore delle consociazioni.

### Modificato

- Riorganizzata l'architettura del modulo `core/agronomy`.
- Migliorata la separazione tra Models, Data ed Engines.
- Definito il workflow ufficiale di sviluppo del progetto.

### Corretto

- Rimossi file duplicati.
- Corretti import ambigui.
- Spostati i file di test nella cartella dedicata.
- Pulita la struttura del progetto.

### Sicurezza

Nessuna modifica.

---

## 3.3 Versione 0.1.2-alpha

**Data:** 28/07/2026

### Aggiunto

- Introdotto `BedAnalysisService` come servizio centralizzato per il coordinamento delle analisi dell'aiuola.
- Implementato `BedCompanionAnalyzer`.
- Creati i modelli `BedCompanionAnalysis` e `CompanionPairAnalysis`.
- Aggiunti i test unitari per `BedCompanionAnalyzer` e `BedAnalysisService`.

### Modificato

- Convertiti gli identificativi delle colture da `int` a `String` in tutto il motore delle consociazioni.
- Allineato il modello dati agronomico al modello dati di Supabase.
- Integrata `BedPage` con `BedAnalysisService` per l'analisi degli spazi e la generazione dei suggerimenti.
- Consolidata l'architettura del motore agronomico introducendo `BedAnalysisService` come orchestratore delle analisi dell'aiuola.

### Corretto

- Eliminate le conversioni tra identificativi numerici e stringhe nel motore delle consociazioni.
- Aggiornati i test unitari dopo il refactoring dell'architettura.
- Uniformato il motore agronomico al nuovo modello dati.

### Sicurezza

Nessuna modifica.

## 3.4 Versione 0.1.3-alpha

**Data:** 06/08/2026

### Aggiunto

- Introdotta `RecommendationPipeline` come componente di orchestrazione del processo di raccomandazione.
- Introdotti `RecommendationMapper` e `SpaceScoreCalculator`.
- Estesa l'architettura del Motore Agronomico con una pipeline modulare per il coordinamento dei motori specializzati.

### Modificato

- `SuggestionEngine` trasformato in componente specializzato della `RecommendationPipeline`.
- Riorganizzato il flusso di elaborazione del Motore Agronomico.
- Aggiornata l'integrazione tra `BedAnalysisService` e il nuovo processo di raccomandazione.
- Migliorata la separazione delle responsabilità tra orchestrazione, analisi e interpretazione dei risultati.

### Corretto

- Mantenuta la compatibilità con l'interfaccia utente esistente durante il refactoring dell'architettura.
- Aggiornati i test automatici senza introdurre regressioni.

### Sicurezza

Nessuna modifica.

---

## 3.5 Versione 0.1.4-alpha

**Data:** 08/08/2026

### Aggiunto

- Introdotto `DecisionWeights` come componente dedicato alla configurazione dei pesi utilizzati dal `DecisionEngine`.
- Aggiunta la configurazione standard dei criteri decisionali: 40% spazio, 30% rotazione e 30% consociazione.
- Aggiunta la validazione delle configurazioni personalizzate dei pesi.
- Aggiunti test automatici dedicati a `DecisionWeights`.

### Modificato

- `DecisionEngine` aggiornato per ricevere una configurazione `DecisionWeights`.
- `RecommendationPipeline` aggiornata per utilizzare `DecisionWeights.standard`.
- Resa configurabile la ponderazione dei criteri utilizzati per il calcolo del punteggio finale delle raccomandazioni.
- Estesi i test automatici del `DecisionEngine` per verificare configurazioni personalizzate e non valide.

### Corretto

- Eliminata la dipendenza del `DecisionEngine` da pesi decisionali incorporati rigidamente nella propria logica.

### Sicurezza

Nessuna modifica.

---

# 4. Cronologia versioni

| Versione | Data | Stato | Note |
|-----------|------------|------------|--------------------------------------------------------------|
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto. |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico. |
| 0.1.2-alpha | 28/07/2026 | Archiviata | Introdotto `BedAnalysisService`, implementato `BedCompanionAnalyzer` e consolidata l'architettura delle analisi agronomiche. |
| 0.1.3-alpha | 06/08/2026 | Archiviata | Introdotta `RecommendationPipeline` come orchestratore del processo di raccomandazione e consolidata la nuova architettura del Motore Agronomico. |
| 0.1.4-alpha | 08/08/2026 | Corrente   | Introdotto `DecisionWeights` e resa configurabile la ponderazione dei criteri utilizzati dal `DecisionEngine`. |

---

# 5. Considerazioni finali

Il presente CHANGELOG documenta in modo sintetico l'evoluzione di Orto Smart, registrando le modifiche più significative introdotte nelle diverse versioni del software.

La separazione tra CHANGELOG, Quaderno di Sviluppo (DOC-005) e Manuale Tecnico (DOC-001) consente di distinguere chiaramente la cronologia delle versioni, il dettaglio delle attività di sviluppo e l'architettura del progetto, mantenendo la documentazione ordinata e facilmente consultabile.

Il CHANGELOG deve essere aggiornato ad ogni rilascio di una nuova versione significativa dell'applicazione, garantendo la tracciabilità delle principali evoluzioni del software e mantenendo la coerenza con gli altri documenti ufficiali del progetto.
