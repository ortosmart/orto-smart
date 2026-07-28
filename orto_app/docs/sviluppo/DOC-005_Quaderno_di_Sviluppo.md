# DOC-005 – Quaderno di Sviluppo

Il presente documento costituisce il diario tecnico ufficiale dello sviluppo di **Orto Smart**.

Ogni sessione documenta gli obiettivi prefissati, le attività svolte, le decisioni prese, i test eseguiti e lo stato del progetto al termine dei lavori.

Il Quaderno di Sviluppo rappresenta il riferimento cronologico dell'evoluzione del progetto e integra le informazioni riportate nel **CHANGELOG**, nel **Manuale Tecnico** e nel documento delle **Decisioni Architetturali (DOC-011)**.

---

# Regole di aggiornamento

Al termine di ogni sessione di sviluppo devono essere registrati almeno i seguenti elementi:

- Numero della sessione.
- Data.
- Obiettivo della sessione.
- Attività svolte.
- Decisioni architetturali eventualmente approvate.
- Test eseguiti.
- Stato del progetto.
- Commit Git.
- Tempo di sviluppo (se disponibile).
- Obiettivi della sessione successiva.

---

# S005 – Consolidamento del Motore Agronomico

**Data:** 28/07/2026

**Versione interessata:** 0.1.2-alpha

---

## Obiettivo della sessione

Consolidare l'architettura del Motore Agronomico migliorandone la modularità, la manutenibilità e l'allineamento con il modello dati di Supabase.

In particolare la sessione è stata dedicata al refactoring del motore delle consociazioni e all'introduzione di un servizio dedicato al coordinamento delle analisi delle aiuole.

---

## Attività svolte

Durante la sessione sono state completate le seguenti attività:

- Refactoring completo degli identificativi delle colture da `int` a `String`.
- Allineamento del Motore Agronomico al modello dati di Supabase.
- Introduzione del nuovo servizio `BedAnalysisService`.
- Implementazione del nuovo `BedCompanionAnalyzer`.
- Creazione del modello `BedCompanionAnalysis`.
- Creazione del modello `CompanionPairAnalysis`.
- Aggiornamento della `BedPage` per utilizzare il nuovo servizio di analisi.
- Aggiornamento del `CompanionEngine`.
- Aggiornamento delle regole di consociazione.
- Aggiornamento dei test esistenti.
- Creazione di nuovi test unitari per i nuovi componenti.

---

## Decisioni architetturali

Nel corso della sessione sono state approvate due nuove decisioni architetturali ufficiali, documentate nel **DOC-011 – Decisioni Architetturali**.

### DEC-001 – Standardizzazione degli identificativi delle colture

È stato deciso di utilizzare esclusivamente identificativi di tipo `String` per rappresentare le colture in tutto il progetto, eliminando definitivamente le conversioni tra `int` e `String`.

### DEC-002 – Introduzione di BedAnalysisService

È stato introdotto `BedAnalysisService` come servizio incaricato di coordinare le analisi dell'aiuola senza contenere logica agronomica.

Principio architetturale adottato:

> **Un servizio coordina, i motori calcolano.**

---

## File creati

- `bed_analysis_service.dart`
- `bed_companion_analyzer.dart`
- `bed_companion_analysis.dart`
- `companion_pair_analysis.dart`
- Relativi file di test.

---

## File modificati

- `bed_page.dart`
- `companion_engine.dart`
- `companion_rule.dart`
- `companion_rules.dart`
- Test del Motore Agronomico.

---

## Database

Non sono state apportate modifiche alla struttura del database Supabase.

L'intervento ha riguardato esclusivamente il codice dell'applicazione.

---

## Test eseguiti

Al termine dello sviluppo sono stati eseguiti i seguenti controlli:

- `flutter analyze`
- `flutter test`
- Verifica manuale del corretto funzionamento dell'applicazione.

Tutti i controlli sono stati completati con esito positivo.

---

## Stato del progetto

Al termine della sessione il progetto presenta le seguenti caratteristiche:

- Motore delle consociazioni completamente allineato al database Supabase.
- Architettura più modulare e facilmente estendibile.
- Maggiore separazione delle responsabilità tra interfaccia utente, servizi e motori agronomici.
- Introduzione di un servizio centralizzato per l'analisi delle aiuole.
- Base pronta per l'integrazione delle analisi delle consociazioni nell'interfaccia utente.

---

## Git

### Commit

```text
Completa BedAnalysisService e motore consociazioni
```

### Push

Completato con successo sul repository GitHub.

---

## Tempo di sviluppo

Da compilare, se disponibile.

---

## Obiettivi della sessione S006

Per la prossima sessione di sviluppo sono previsti i seguenti obiettivi:

- Integrare i risultati del `BedCompanionAnalyzer` nella `BedPage`.
- Visualizzare le consociazioni favorevoli e sfavorevoli nell'interfaccia utente.
- Migliorare la presentazione dei suggerimenti agronomici.
- Proseguire l'evoluzione del Motore Agronomico.

---

## Esito della sessione

La sessione **S005** si conclude con il consolidamento dell'architettura del Motore Agronomico.

L'introduzione di `BedAnalysisService`, la standardizzazione degli identificativi delle colture e il refactoring del motore delle consociazioni costituiscono una base più solida, modulare ed estendibile per lo sviluppo delle future funzionalità di **Orto Smart**.

Le decisioni prese durante questa sessione rappresentano un importante passo avanti nell'organizzazione dell'architettura del progetto e preparano il terreno per l'integrazione delle future funzionalità agronomiche.