# ORTO SMART

### DOC-011

# Decisioni Architetturali (ADR)

**Versione:** 0.4
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 28/07/2026
**Ultimo aggiornamento:** 09/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-011 |
| Titolo | Decisioni Architetturali (ADR) |
| Versione | 0.4 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 28/07/2026 |
| Ultimo aggiornamento | 09/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|-----------------------------------------------|
| 0.1 | 28/07/2026 | Prima emissione del documento Decisioni Architetturali |
| 0.2 | 01/08/2026 | Riorganizzazione della struttura documentale e aggiornamento delle decisioni architetturali |
| 0.3      | 08/08/2026 | Aggiornamento della DEC-003 con l'evoluzione introdotta nella Sessione S010 mediante DecisionWeights |
| 0.4      | 09/08/2026 | Introduzione della DEC-005 sulla separazione tra fabbisogno familiare e pianificazione temporale |

---

# Indice

## 1. Scopo del documento

## 2. Regole di aggiornamento

## 3. Decisioni Architetturali

3.1 DEC-001 – Standardizzazione degli identificativi delle colture  
3.2 DEC-002 – Introduzione di BedAnalysisService  
3.3 DEC-003 – Introduzione del Decision Engine  
3.4 DEC-004 – Chiusura formale delle sessioni di sviluppo
3.5 DEC-005 – Separazione tra fabbisogno familiare e pianificazione temporale

## 4. Registro delle decisioni

## 5. Considerazioni finali

Il presente documento raccoglie le principali decisioni architetturali che hanno guidato l'evoluzione di Orto Smart, documentandone il contesto, le motivazioni e le conseguenze sull'architettura del progetto.

La registrazione delle decisioni architetturali consente di preservare la conoscenza tecnica maturata durante lo sviluppo, favorendo la comprensione delle scelte progettuali e garantendo continuità nell'evoluzione del software.

Ogni nuova decisione che comporti modifiche significative all'architettura dovrà essere documentata nel presente documento, mantenendolo costantemente allineato con il Manuale Tecnico (DOC-001), il Quaderno di Sviluppo (DOC-005) e gli altri documenti ufficiali del progetto.

Il documento Decisioni Architetturali costituisce pertanto il riferimento ufficiale per la tracciabilità delle principali scelte progettuali adottate nello sviluppo di Orto Smart e rappresenta uno strumento fondamentale per garantirne la coerenza, la manutenibilità e l'evoluzione nel tempo.

---

# 1. Scopo del documento

Il presente documento raccoglie le principali decisioni architetturali prese durante lo sviluppo di **Orto Smart**.

Ogni decisione descrive il contesto in cui è stata presa, la soluzione adottata, le motivazioni e le conseguenze sull'architettura del progetto.

Le decisioni riportate nel presente documento costituiscono il riferimento ufficiale per l'evoluzione dell'architettura software del progetto e consentono di comprendere le motivazioni tecniche delle scelte adottate nel tempo.

Per il dettaglio delle attività svolte durante ogni sessione fare riferimento al **DOC-005 – Quaderno di Sviluppo**.

---

# 2. Regole di aggiornamento

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

Ogni decisione architetturale deve essere approvata e documentata contestualmente alla sessione di sviluppo nella quale viene adottata, mantenendo il presente documento allineato con il Quaderno di Sviluppo (DOC-005) e con il Manuale Tecnico (DOC-001).

---

# 3. Decisioni Architetturali

## 3.1 DEC-001 – Standardizzazione degli identificativi delle colture

**Stato:** Approvata

**Data:** 28/07/2026

**Sessione:** S005

### Contesto

Durante lo sviluppo del Motore Agronomico sono emerse incongruenze dovute all'utilizzo contemporaneo di identificativi numerici (`int`) e testuali (`String`) per rappresentare le colture.

Il modello dati di Supabase utilizza identificativi di tipo `String`, mentre alcune componenti del motore delle consociazioni continuavano a utilizzare valori numerici, rendendo necessarie conversioni tra i due tipi.

### Decisione

Adottare esclusivamente identificativi di tipo `String` per tutte le colture all'interno del progetto.

Ogni componente del Motore Agronomico dovrà utilizzare direttamente `Crop.id` e `Planting.cropId` senza conversioni intermedie.

### Motivazione

- Uniformare completamente il modello dati.
- Eliminare conversioni inutili.
- Ridurre la possibilità di errori.
- Semplificare il codice.
- Allineare definitivamente il motore agronomico al database Supabase.

### Alternative valutate

- Mantenere identificativi numerici nel motore agronomico.
- Continuare con conversioni automatiche tra `int` e `String`.

Entrambe le alternative sono state scartate perché aumentavano la complessità del codice.

### Conseguenze

- Maggiore coerenza dell'architettura.
- Codice più semplice da mantenere.
- Eliminazione definitiva delle conversioni di tipo.

---

## 3.2 DEC-002 – Introduzione di BedAnalysisService

**Stato:** Approvata

**Data:** 28/07/2026

**Sessione:** S005

### Contesto

Con l'aumento dei motori agronomici (analisi degli spazi, suggerimenti di coltivazione, consociazioni e futuri moduli) la `BedPage` rischiava di diventare responsabile del coordinamento diretto delle varie analisi.

### Decisione

Introdurre un servizio dedicato denominato `BedAnalysisService` con il solo compito di coordinare le analisi dell'aiuola.

Il servizio non contiene logica agronomica ma richiama i singoli motori specializzati.

### Motivazione

- Ridurre le responsabilità della UI.
- Centralizzare il punto di accesso alle analisi.
- Favorire l'estendibilità futura.
- Mantenere indipendenti i motori agronomici.

Principio adottato:

> **Un servizio coordina, i motori calcolano.**

### Alternative valutate

- Gestire ogni motore direttamente dalla `BedPage`.
- Accorpare tutta la logica in un unico motore.

Entrambe le soluzioni sono state scartate perché avrebbero aumentato l'accoppiamento tra interfaccia utente e logica applicativa.

### Conseguenze

- Architettura più modulare.
- Maggiore riutilizzabilità dei motori.
- Più semplice integrazione dei futuri moduli (rotazioni, irrigazione, calendario, attività, ecc.).
- Migliore separazione delle responsabilità secondo il principio della Single Responsibility.

---

## 3.3 DEC-003 – Introduzione del Decision Engine

**Stato:** Approvata

**Data:** 29/07/2026

**Sessione:** S006

### Contesto

Con l'integrazione di un numero crescente di motori agronomici, è emersa la necessità di separare la logica di analisi dalla logica di interpretazione dei risultati.

In assenza di un componente dedicato, l'interfaccia utente avrebbe dovuto interpretare direttamente gli esiti prodotti dai diversi motori agronomici, aumentando l'accoppiamento tra presentazione e logica applicativa e rendendo più complessa l'evoluzione del sistema.

### Decisione

Introdurre un componente dedicato denominato `DecisionEngine`, responsabile dell'interpretazione dei risultati prodotti dai motori agronomici e della loro trasformazione in decisioni, suggerimenti e informazioni destinate all'interfaccia utente.

Il `DecisionEngine` non esegue elaborazioni agronomiche, ma coordina e interpreta i risultati forniti dai diversi motori specializzati.

### Evoluzione della decisione – Sessione S009

L'architettura introdotta dalla DEC-003 è stata completata con l'introduzione della `RecommendationPipeline`, componente responsabile dell'orchestrazione del processo di raccomandazione.

La `RecommendationPipeline` coordina i motori agronomici, raccoglie le valutazioni prodotte dai componenti specializzati, invoca il `DecisionEngine` e converte il risultato nel modello destinato all'interfaccia utente.

Il `DecisionEngine` mantiene il ruolo definito dalla presente decisione architetturale:

- interpreta le valutazioni ricevute;
- calcola il punteggio finale;
- produce le raccomandazioni;
- non coordina il flusso;
- non invoca direttamente gli altri motori.

La separazione delle responsabilità prevista dalla DEC-003 rimane invariata. La `RecommendationPipeline` ne costituisce l'implementazione operativa e il componente ufficiale di orchestrazione del processo di raccomandazione.

### Evoluzione della decisione – Sessione S010

Nel corso della Sessione S010 l'implementazione della DEC-003 è stata ulteriormente consolidata mediante l'introduzione di `DecisionWeights`.

La configurazione dei pesi utilizzati per il calcolo del punteggio finale è stata separata dalla logica interna del `DecisionEngine`.

La configurazione standard attualmente adottata assegna:

- 40% al criterio spazio;
- 30% al criterio rotazione;
- 30% al criterio consociazione.

`DecisionWeights` consente inoltre l'utilizzo di configurazioni personalizzate e ne verifica la validità prima dell'utilizzo da parte del `DecisionEngine`.

Questa evoluzione non modifica la decisione architetturale originaria: il `DecisionEngine` continua a essere responsabile dell'interpretazione delle valutazioni e del calcolo del punteggio finale, mentre la configurazione dei criteri viene mantenuta separata dalla logica decisionale.

La separazione introdotta migliora la configurabilità e l'estendibilità del sistema, preparando il processo decisionale all'eventuale introduzione futura di ulteriori criteri agronomici.

### Motivazione

- Separare la logica decisionale dalla logica di calcolo.
- Ridurre le responsabilità dell'interfaccia utente.
- Uniformare la presentazione dei risultati agronomici.
- Favorire l'estendibilità del sistema con nuovi motori di analisi.
- Mantenere un'architettura modulare e facilmente manutenibile.

Principio adottato:

> **I motori analizzano, il Decision Engine interpreta, l'interfaccia presenta.**

### Alternative valutate

- Interpretare i risultati direttamente nell'interfaccia utente.
- Integrare la logica decisionale all'interno dei singoli motori agronomici.

Entrambe le soluzioni sono state scartate perché avrebbero aumentato l'accoppiamento tra i componenti e ridotto la modularità dell'architettura.

### Conseguenze

- Maggiore separazione delle responsabilità tra analisi, interpretazione e presentazione.
- Architettura più modulare ed estendibile.
- Maggiore uniformità nella gestione dei suggerimenti agronomici.
- Base architetturale pronta per l'integrazione di futuri motori agronomici.

---

## 3.4 DEC-004 – Chiusura formale delle sessioni di sviluppo

**Stato:** Approvata

**Data:** 01/08/2026

**Sessione:** S007

### Contesto

Con la crescita del progetto e della documentazione tecnica è emersa la necessità di definire un processo univoco per la conclusione delle sessioni di sviluppo.

In assenza di una regola condivisa, il rischio era quello di considerare terminata una sessione prima del completo aggiornamento della documentazione tecnica, compromettendo la coerenza tra codice, documentazione e cronologia del progetto.

### Decisione

Stabilire che una sessione di sviluppo sia considerata conclusa esclusivamente dopo il completamento delle attività tecniche previste, l'aggiornamento della documentazione interessata, l'eventuale commit e push del codice e la registrazione della sessione nel Quaderno di Sviluppo.

Questa regola costituisce parte integrante del Workflow Operativo del progetto Orto Smart.

### Motivazione

- Garantire l'allineamento tra codice e documentazione.
- Assicurare la tracciabilità delle attività di sviluppo.
- Evitare documentazione incompleta o non aggiornata.
- Rendere ripetibile e verificabile il processo di sviluppo.
- Consolidare un metodo di lavoro uniforme per tutte le future sessioni.

### Alternative valutate

- Considerare conclusa la sessione al termine delle sole attività di sviluppo.
- Aggiornare la documentazione in momenti successivi e non necessariamente al termine della sessione.

Entrambe le alternative sono state scartate perché avrebbero aumentato il rischio di disallineamento tra il codice, la documentazione e la cronologia del progetto.

### Conseguenze

- Introduzione di un processo formale di chiusura delle sessioni di sviluppo.
- Maggiore coerenza tra codice, documentazione e storico del progetto.
- Migliore tracciabilità delle attività svolte.
- Processo di sviluppo più ordinato, ripetibile e facilmente manutenibile nel tempo.

---

## 3.5 DEC-005 – Separazione tra fabbisogno familiare e pianificazione temporale

**Stato:** Approvata

**Data:** 09/08/2026

**Sessione:** S011

### Contesto

Durante la progettazione dell'evoluzione del sistema di raccomandazione di Orto Smart è emersa la necessità di considerare anche le esigenze familiari nella scelta delle colture.

Sono state individuate due responsabilità differenti:

- valutare quanto una determinata coltura sia necessaria o desiderata dalla famiglia;
- determinare quantità, lotti e distribuzione temporale delle coltivazioni per garantire continuità del raccolto e limitare le sovrapproduzioni.

L'accorpamento di queste responsabilità in un unico componente avrebbe reso più complessa la logica applicativa e avrebbe mescolato la valutazione del fabbisogno con la pianificazione della produzione.

### Decisione

Separare formalmente la valutazione del fabbisogno familiare dalla pianificazione quantitativa e temporale delle coltivazioni.

Il `FamilyNeedsEngine` è responsabile esclusivamente della valutazione delle priorità e dei fabbisogni familiari associati alle colture.

La futura pianificazione delle quantità, dei lotti e della distribuzione temporale delle coltivazioni sarà affidata a un componente distinto denominato `SuccessionPlanningEngine`.

La `RecommendationPipeline` manterrà il ruolo di coordinamento dei diversi componenti del processo di raccomandazione.

La separazione architetturale adottata è:

    FamilyNeedsEngine
            ↓
    fabbisogno / priorità familiare

    SuccessionPlanningEngine
            ↓
    quantità, lotti e distribuzione temporale

    RecommendationPipeline
            ↓
    coordinamento dei motori

Nella prima implementazione il `FamilyNeedsEngine` rimane autonomo e non viene integrato prematuramente nel `DecisionEngine` o nella `RecommendationPipeline`.

La modalità di integrazione del fabbisogno familiare nel sistema complessivo di raccomandazione sarà progettata in una sessione successiva.

### Motivazione

- Separare la valutazione delle esigenze familiari dalla pianificazione della produzione.
- Evitare l'accumulo di responsabilità differenti nello stesso motore.
- Mantenere modulari e indipendenti i componenti del Motore Agronomico.
- Consentire l'evoluzione separata dei criteri familiari e della pianificazione temporale.
- Preparare il sistema alla gestione futura di semine e trapianti scalari.
- Ridurre il rischio di sovrapproduzioni concentrate nello stesso periodo.
- Preservare il ruolo della `RecommendationPipeline` come componente di coordinamento.

### Alternative valutate

- Integrare fabbisogno familiare e pianificazione temporale direttamente nel `FamilyNeedsEngine`.
- Inserire immediatamente il fabbisogno familiare nel `DecisionEngine`.
- Integrare immediatamente il `FamilyNeedsEngine` nella `RecommendationPipeline` senza aver prima definito il rapporto tra priorità familiare e criteri agronomici.

Le alternative sono state scartate perché avrebbero aumentato l'accoppiamento tra responsabilità differenti o anticipato decisioni non ancora sufficientemente progettate.

### Conseguenze

- Il `FamilyNeedsEngine` mantiene una responsabilità specifica e limitata.
- Il futuro `SuccessionPlanningEngine` avrà una responsabilità distinta dedicata alla pianificazione quantitativa e temporale.
- La `RecommendationPipeline` potrà coordinare i due componenti senza trasferire loro responsabilità improprie.
- L'integrazione del fabbisogno familiare nel sistema decisionale richiederà una progettazione specifica.
- Una priorità familiare elevata non dovrà, da sola, rendere consigliabile una coltura agronomicamente inappropriata.
- L'architettura rimane predisposta alla futura gestione delle produzioni scalari e della continuità del raccolto.

---

# 4. Registro delle decisioni

| ID | Data | Sessione | Titolo | Stato |
|----|------------|----------|---------------------------------------------------------|-----------|
| DEC-001 | 28/07/2026 | S005 | Standardizzazione degli identificativi delle colture | Approvata |
| DEC-002 | 28/07/2026 | S005 | Introduzione di BedAnalysisService | Approvata |
| DEC-003 | 29/07/2026 | S006 | Introduzione del Decision Engine | Approvata |
| DEC-004 | 01/08/2026 | S007 | Chiusura formale delle sessioni di sviluppo | Approvata |
| DEC-005 | 09/08/2026 | S011 | Separazione tra fabbisogno familiare e pianificazione temporale | Approvata |

---

# 5. Considerazioni finali

Il presente documento raccoglie le principali decisioni architetturali che hanno guidato l'evoluzione di Orto Smart, documentandone il contesto, le motivazioni e le conseguenze sull'architettura del progetto.

La registrazione delle decisioni architetturali consente di preservare la conoscenza tecnica maturata durante lo sviluppo, favorendo la comprensione delle scelte progettuali e garantendo continuità nell'evoluzione del software.

Ogni nuova decisione che comporti modifiche significative all'architettura dovrà essere documentata nel presente documento, mantenendolo costantemente allineato con il Manuale Tecnico (DOC-001), il Quaderno di Sviluppo (DOC-005) e gli altri documenti ufficiali del progetto.

Il documento Decisioni Architetturali costituisce pertanto il riferimento ufficiale per la tracciabilità delle principali scelte progettuali adottate nello sviluppo di Orto Smart e rappresenta uno strumento fondamentale per garantirne la coerenza, la manutenibilità e l'evoluzione nel tempo.