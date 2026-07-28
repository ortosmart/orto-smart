# DOC-011 – Decisioni Architetturali (ADR)

## Scopo del documento

Il presente documento raccoglie le principali decisioni architetturali prese durante lo sviluppo di **Orto Smart**.

Ogni decisione descrive il contesto in cui è stata presa, la soluzione adottata, le motivazioni e le conseguenze sull'architettura del progetto.

Le decisioni riportate in questo documento rappresentano il riferimento ufficiale per l'evoluzione del software e permettono di comprendere le motivazioni tecniche delle scelte effettuate nel tempo.

Per il dettaglio delle attività svolte durante ogni sessione fare riferimento al **DOC-005 – Quaderno di Sviluppo**.

---

# Regole di aggiornamento

Il documento viene aggiornato esclusivamente quando viene presa una decisione che modifica in modo significativo l'architettura del progetto.

Non vengono registrati bug fix, refactoring minori o modifiche implementative che non comportano cambiamenti strutturali.

Ogni decisione deve riportare:

- Identificativo progressivo (DEC-XXX)
- Stato
- Data
- Sessione di sviluppo
- Contesto
- Decisione
- Motivazione
- Alternative valutate
- Conseguenze

---

# DEC-001 – Standardizzazione degli identificativi delle colture

**Stato:** Approvata

**Data:** 28/07/2026

**Sessione:** S005

## Contesto

Durante lo sviluppo del Motore Agronomico sono emerse incongruenze dovute all'utilizzo contemporaneo di identificativi numerici (`int`) e testuali (`String`) per rappresentare le colture.

Il modello dati di Supabase utilizza identificativi di tipo `String`, mentre alcune componenti del motore delle consociazioni continuavano a utilizzare valori numerici, rendendo necessarie conversioni tra i due tipi.

## Decisione

Adottare esclusivamente identificativi di tipo `String` per tutte le colture all'interno del progetto.

Ogni componente del Motore Agronomico dovrà utilizzare direttamente `Crop.id` e `Planting.cropId` senza conversioni intermedie.

## Motivazione

- Uniformare completamente il modello dati.
- Eliminare conversioni inutili.
- Ridurre la possibilità di errori.
- Semplificare il codice.
- Allineare definitivamente il motore agronomico al database Supabase.

## Alternative valutate

- Mantenere identificativi numerici nel motore agronomico.
- Continuare con conversioni automatiche tra `int` e `String`.

Entrambe le alternative sono state scartate perché aumentavano la complessità del codice.

## Conseguenze

- Maggiore coerenza dell'architettura.
- Codice più semplice da mantenere.
- Eliminazione definitiva delle conversioni di tipo.

---

# DEC-002 – Introduzione di BedAnalysisService

**Stato:** Approvata

**Data:** 28/07/2026

**Sessione:** S005

## Contesto

Con l'aumento dei motori agronomici (analisi degli spazi, suggerimenti di coltivazione, consociazioni e futuri moduli) la `BedPage` rischiava di diventare responsabile del coordinamento diretto delle varie analisi.

## Decisione

Introdurre un servizio dedicato denominato `BedAnalysisService` con il solo compito di coordinare le analisi dell'aiuola.

Il servizio non contiene logica agronomica ma richiama i singoli motori specializzati.

## Motivazione

- Ridurre le responsabilità della UI.
- Centralizzare il punto di accesso alle analisi.
- Favorire l'estendibilità futura.
- Mantenere indipendenti i motori agronomici.

Principio adottato:

> **Un servizio coordina, i motori calcolano.**

## Alternative valutate

- Gestire ogni motore direttamente dalla `BedPage`.
- Accorpare tutta la logica in un unico motore.

Entrambe le soluzioni sono state scartate perché avrebbero aumentato l'accoppiamento tra interfaccia utente e logica applicativa.

## Conseguenze

- Architettura più modulare.
- Maggiore riutilizzabilità dei motori.
- Più semplice integrazione dei futuri moduli (rotazioni, irrigazione, calendario, attività, ecc.).
- Migliore separazione delle responsabilità secondo il principio della Single Responsibility.

---

# Registro delle decisioni

| ID | Data | Sessione | Titolo | Stato |
|----|------------|----------|---------------------------------------------------------|-----------|
| DEC-001 | 28/07/2026 | S005 | Standardizzazione degli identificativi delle colture | Approvata |
| DEC-002 | 28/07/2026 | S005 | Introduzione di BedAnalysisService | Approvata |