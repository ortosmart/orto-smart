# VERSION

| Campo             | Valore               |
| ----------------- | -------------------- |
| Progetto          | Orto Smart           |
| Versione corrente | 0.1.6-alpha          |
| Stato             | Alpha                |
| Data versione     | 09/08/2026           |
| Linguaggio        | Flutter / Dart       |
| Backend           | Supabase             |
| Repository        | ortosmart/orto-smart |

---

# Stato del progetto

Orto Smart è attualmente in fase **Alpha**.

L'architettura principale dell'applicazione è stata definita e il motore agronomico dispone dei componenti fondamentali per l'analisi delle aiuole. Lo sviluppo prosegue con l'introduzione di nuove funzionalità agronomiche previste dalla Roadmap di Sviluppo.

---

# Funzionalità implementate

## Gestione dati

- Gestione orti
- Gestione aiuole
- Gestione colture
- Gestione stagioni
- Gestione piantagioni

## Interfaccia

- Dashboard iniziale
- Elenco aiuole
- Visualizzazione grafica delle aiuole
- Inserimento colture

## Motore agronomico

- PlantingValidator
- FreeSpaceEngine
- SuggestionEngine
- CompanionEngine
- BedAnalysisService
- BedCompanionAnalyzer
- RecommendationPipeline
- RecommendationMapper
- SpaceScoreCalculator
- DecisionEngine
- DecisionWeights
- FamilyNeedsEngine

## Backend

- Supabase
- Repository Pattern
- Row Level Security (RLS)

## Documentazione

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- DOC-009 – Workflow Operativo
- DOC-011 – Decisioni Architetturali
- CHANGELOG

---

# Obiettivi della prossima versione

Gli obiettivi della prossima versione del software sono definiti nella **Roadmap di Sviluppo (DOC-008)**.

Il presente documento riporta esclusivamente la versione corrente del software e il relativo stato di avanzamento, evitando duplicazioni con la documentazione di pianificazione del progetto.

---

# Cronologia versioni

| Versione    | Data       | Stato      | Note                                                                                                                                                              |
| ----------- | ---------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto.                                                                                                                          |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico.                                                                                |
| 0.1.2-alpha | 28/07/2026 | Archiviata | Introdotti BedAnalysisService, BedCompanionAnalyzer e consolidata l'architettura del Motore Agronomico.                                                           |
| 0.1.3-alpha | 06/08/2026 | Archiviata | Introdotta RecommendationPipeline e consolidata la nuova architettura del Motore Agronomico.                                                                      |
| 0.1.4-alpha | 08/08/2026 | Archiviata | Introdotto DecisionWeights e resa configurabile la ponderazione dei criteri utilizzati dal DecisionEngine.                                                        |
| 0.1.5-alpha | 09/08/2026 | Archiviata | Implementata la prima versione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari.                                                |
| 0.1.6-alpha | 09/08/2026 | Corrente   | Integrato il FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico.     |

---

# Documentazione correlata

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-006 – Linee Guida di Sviluppo
- DOC-008 – Roadmap di Sviluppo
- DOC-009 – Workflow Operativo
- DOC-011 – Decisioni Architetturali
- CHANGELOG

---

# Note

Le modifiche dettagliate sono riportate nel **CHANGELOG**, mentre il resoconto completo delle attività di sviluppo è documentato nel **DOC-005 – Quaderno di Sviluppo**. Le regole di sviluppo del progetto sono definite nel **DOC-006 – Linee Guida di Sviluppo**.