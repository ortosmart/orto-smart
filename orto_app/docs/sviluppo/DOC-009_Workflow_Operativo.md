# DOC-009 – Workflow Operativo

| Campo | Valore |
|-------|--------|
| **Documento** | DOC-009 |
| **Titolo** | Workflow Operativo |
| **Versione** | 2.0 |
| **Stato** | In revisione |
| **Progetto** | Orto Smart |
| **Repository** | ortosmart/orto-smart |
| **Data prima emissione** | 29/07/2026 |
| **Ultimo aggiornamento** | 29/07/2026 |

---

# Storico delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|----------------------------------------------|
| 1.0 | 27/07/2026 | Prima emissione del Workflow Operativo |
| 2.0 | 29/07/2026 | Revisione completa del documento, definizione del metodo di sviluppo ufficiale, integrazione della Checklist Operativa e del Diagramma del Workflow |

---

# Indice

1. Scopo del documento
2. Campo di applicazione
3. Principi del Workflow
4. Flusso Operativo della Sessione
5. Controlli di Qualità
6. Gestione della Documentazione
7. Versionamento del Software
8. Chiusura della Sessione
9. Checklist Operativa

Allegato A – Checklist Workflow Operativo

Allegato B – Diagramma del Workflow

---

# 1. Scopo del documento

Il presente documento definisce il metodo ufficiale di sviluppo del progetto **Orto Smart**.

Il Workflow Operativo descrive le attività che devono essere svolte durante ogni sessione di lavoro, dalla pianificazione iniziale fino alla chiusura della sessione, garantendo uno sviluppo ordinato, ripetibile e orientato alla qualità.

Gli obiettivi del Workflow Operativo sono:

- definire un metodo di sviluppo comune;
- garantire la qualità del codice;
- mantenere allineati codice, repository e documentazione;
- assicurare la tracciabilità delle attività svolte;
- ridurre errori, dimenticanze e rilavorazioni.

Il presente documento rappresenta il riferimento operativo per tutte le attività di sviluppo del progetto Orto Smart.

---

## Principio fondamentale

> **Ogni sessione di sviluppo deve seguire il Workflow Operativo definito nel presente documento.**

---

# 2. Campo di applicazione

Il Workflow Operativo si applica a tutte le attività di sviluppo del progetto Orto Smart, indipendentemente dalla loro complessità.

In particolare si applica a:

- sviluppo di nuove funzionalità;
- correzione di errori;
- refactoring del codice;
- aggiornamento della documentazione;
- attività di manutenzione;
- evoluzione dell'architettura software.

Il Workflow Operativo deve essere seguito durante tutte le sessioni di sviluppo e costituisce il riferimento metodologico del progetto.

---

# 3. Principi del Workflow

Il Workflow Operativo si basa sui seguenti principi.

## 3.1 Pianificazione prima dello sviluppo

Ogni sessione deve iniziare con la definizione dell'obiettivo e con l'analisi della soluzione da adottare.

La progettazione precede sempre la scrittura del codice.

---

## 3.2 Qualità prima della velocità

La qualità del software ha priorità rispetto alla rapidità dello sviluppo.

Ogni modifica deve essere verificata prima di essere considerata completata.

---

## 3.3 Architettura prima dell'implementazione

Le decisioni architetturali devono essere valutate prima dell'implementazione.

Il codice deve rispettare l'architettura del progetto.

---

## 3.4 Verifica continua

Ogni sessione deve prevedere verifiche progressive mediante:

- dart format
- flutter analyze
- flutter test
- test manuali

---

## 3.5 Documentazione come parte dello sviluppo

La documentazione è parte integrante del software.

Ogni modifica significativa deve essere accompagnata dal relativo aggiornamento documentale.

---

## 3.6 Tracciabilità

Ogni attività deve poter essere ricostruita attraverso:

- Git
- documentazione
- registro delle sessioni
- decisioni architetturali

---

## 3.7 Sessione completata

Una sessione di sviluppo è considerata conclusa esclusivamente quando:

- il codice risulta aggiornato;
- la documentazione risulta aggiornata;
- il Registro Storico dello Sviluppo risulta aggiornato;
- codice, documentazione e registro storico sono coerenti e allineati.

# 4. Flusso Operativo della Sessione

Ogni sessione di sviluppo deve seguire il seguente flusso operativo.

## Fase 1 – Pianificazione

**Obiettivo**

Preparare correttamente la sessione di sviluppo.

**Attività**

- Apertura del progetto.
- Verifica dello stato del repository (`git status`).
- Aggiornamento del repository (`git pull`, se necessario).
- Definizione dell'obiettivo della sessione.
- Analisi preliminare della soluzione.
- Pianificazione delle attività.

---

## Fase 2 – Sviluppo

**Obiettivo**

Realizzare le modifiche pianificate.

**Attività**

- Analisi tecnica.
- Implementazione del codice.
- Aggiornamenti progressivi.
- Verifica continua durante lo sviluppo.

---

## Fase 3 – Controlli di Qualità

**Obiettivo**

Garantire la qualità del codice prodotto.

**Attività**

- Esecuzione di `dart format`.
- Esecuzione di `flutter analyze`.
- Esecuzione di `flutter test`.
- Correzione di eventuali anomalie.

---

## Fase 4 – Verifica Funzionale

**Obiettivo**

Verificare il corretto funzionamento della funzionalità sviluppata.

**Attività**

- Test manuali.
- Verifica dell'interfaccia utente.
- Controllo del comportamento previsto.
- Verifica dell'integrazione con le funzionalità esistenti.

---

## Fase 5 – Versionamento

**Obiettivo**

Registrare ufficialmente le modifiche.

**Attività**

- `git status`
- `git add`
- `git commit`
- `git push`
- Verifica del repository remoto.

---

## Fase 6 – Documentazione

**Obiettivo**

Mantenere aggiornata e coerente la documentazione del progetto.

**Attività**

Aggiornare, se necessario:

- DOC-001 – Manuale Tecnico
- DOC-005 – Quaderno di Sviluppo
- DOC-009 – Workflow Operativo (quando il metodo viene modificato)
- DOC-011 – Registro Decisioni Architetturali
- DOC-012 – Registro Storico dello Sviluppo
- CHANGELOG

Verificare inoltre:

- coerenza della documentazione;
- assenza di duplicazioni;
- allineamento tra codice e documentazione.

---

## Fase 7 – Chiusura della Sessione

Una sessione può essere dichiarata conclusa esclusivamente quando risultano soddisfatte tutte le seguenti condizioni:

- codice aggiornato;
- controlli di qualità superati;
- repository sincronizzato;
- documentazione aggiornata;
- Registro Storico aggiornato;
- verifica della coerenza tra i documenti;
- ore della sessione registrate;
- prossimi passi definiti.

---

# 5. Controlli di Qualità

La qualità rappresenta uno dei principi fondamentali del progetto Orto Smart.

Ogni modifica deve essere verificata prima di essere considerata completata.

I controlli minimi obbligatori sono:

- formattazione del codice (`dart format`);
- analisi statica (`flutter analyze`);
- test automatici (`flutter test`);
- test funzionali manuali.

Qualora uno dei controlli non venga superato, la sessione non può essere considerata conclusa.

---

# 6. Gestione della Documentazione

La documentazione costituisce parte integrante del progetto software.

Ogni modifica significativa deve essere accompagnata dall'aggiornamento dei documenti interessati.

Il principio adottato dal progetto è il seguente:

> Ogni informazione deve essere presente in un solo documento.

Ogni documento possiede uno scopo specifico e non deve duplicare informazioni appartenenti ad altri documenti.

---

# 7. Versionamento del Software

Il versionamento del progetto è gestito tramite Git e GitHub.

Ogni sessione deve terminare con:

- verifica dello stato del repository;
- commit descrittivo;
- push sul repository remoto;
- controllo dell'avvenuta sincronizzazione.

Il repository GitHub rappresenta il riferimento ufficiale del codice sorgente.

---

# 8. Chiusura della Sessione

Una sessione di sviluppo può essere dichiarata ufficialmente conclusa esclusivamente quando risultano soddisfatte tutte le seguenti condizioni:

- sviluppo completato;
- controlli di qualità superati;
- repository aggiornato;
- documentazione aggiornata;
- Registro Storico aggiornato;
- ore di lavoro registrate;
- prossimi obiettivi definiti.

In assenza anche di una sola delle condizioni sopra indicate, la sessione rimane aperta.

---

# 9. Checklist Operativa

La Checklist Operativa rappresenta lo strumento di supporto al Workflow Operativo.

Essa accompagna lo sviluppatore durante tutte le fasi della sessione e consente di verificare che ogni attività prevista sia stata eseguita.

La Checklist completa è riportata nell'Allegato A.

---

# Allegato A
## Checklist Workflow Operativo

(Versione 2.0)

[Inserire qui la Checklist approvata.]

---

# Allegato B
## Diagramma del Workflow

```text
Pianificazione
      │
      ▼
Sviluppo
      │
      ▼
Controlli di Qualità
      │
      ▼
Verifica Funzionale
      │
      ▼
Versionamento
      │
      ▼
Documentazione
      │
      ▼
Verifica Finale
      │
      ▼
Sessione Chiusa
```
Allegato C – Matrice della Documentazione

Allegato D – Criteri di Chiusura della Sessione

---

## Conclusione

Il Workflow Operativo definisce il metodo ufficiale di sviluppo del progetto Orto Smart.

Il rispetto sistematico delle procedure descritte nel presente documento garantisce qualità, tracciabilità, continuità e affidabilità nello sviluppo del software.

