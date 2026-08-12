# ORTO SMART

### DOC-011

# Decisioni Architetturali (ADR)

**Versione:** 0.9
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 28/07/2026
**Ultimo aggiornamento:** 12/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo                | Valore                         |
| -------------------- | ------------------------------ |
| Documento            | DOC-011                        |
| Titolo               | Decisioni Architetturali (ADR) |
| Versione             | 0.9                            |
| Stato                | In sviluppo                    |
| Progetto             | Orto Smart                     |
| Repository           | ortosmart/orto-smart           |
| Prima emissione      | 28/07/2026                     |
| Ultimo aggiornamento | 12/08/2026                     |

---

# Cronologia delle revisioni

| Versione | Data       | Descrizione                                                                                                                |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| 0.1      | 28/07/2026 | Prima emissione del documento Decisioni Architetturali                                                                     |
| 0.2      | 01/08/2026 | Riorganizzazione della struttura documentale e aggiornamento delle decisioni architetturali                                |
| 0.3      | 08/08/2026 | Aggiornamento della DEC-003 con l'evoluzione introdotta nella Sessione S010 mediante DecisionWeights                       |
| 0.4      | 09/08/2026 | Introduzione della DEC-005 sulla separazione tra fabbisogno familiare e pianificazione temporale                           |
| 0.5      | 09/08/2026 | Introduzione della DEC-006 sull'integrazione gerarchica del fabbisogno familiare nel sistema di raccomandazione            |
| 0.6      | 10/08/2026 | Introduzione della DEC-007 sulla separazione tra priorità familiare, fabbisogno quantitativo e lotto pianificato           |
| 0.7      | 11/08/2026 | Introduzione della DEC-008 sul divieto di conversioni implicite non supportate nella pianificazione                        |
| 0.8      | 11/08/2026 | Introduzione della DEC-009 sulla separazione tra pianificazione temporale e compatibilità agronomica                       |
| 0.9      | 12/08/2026 | Introduzione della DEC-010 sulla risoluzione gerarchica delle regole agronomiche e sulla distinzione tra assenza di conoscenza e incompatibilità |

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
3.6 DEC-006 – Integrazione gerarchica del fabbisogno familiare nel sistema di raccomandazione
3.7 DEC-007 – Separazione tra priorità familiare, fabbisogno quantitativo e lotto pianificato
3.8 DEC-008 – Divieto di conversioni implicite non supportate nella pianificazione
3.9 DEC-009 – Separazione tra pianificazione temporale e compatibilità agronomica
3.10 DEC-010 – Risoluzione gerarchica delle regole agronomiche e distinzione dell'assenza di conoscenza

## 4. Registro delle decisioni

## 5. Considerazioni finali

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

## 3.6 DEC-006 – Integrazione gerarchica del fabbisogno familiare nel sistema di raccomandazione

**Stato:** Approvata

**Data:** 09/08/2026

**Sessione:** S012

### Contesto

Con la prima implementazione del `FamilyNeedsEngine` è emersa la necessità di stabilire come integrare le esigenze familiari nel sistema complessivo di raccomandazione senza compromettere la correttezza delle valutazioni agronomiche.

Il sistema decisionale dispone già di un punteggio agronomico calcolato dal `DecisionEngine` mediante i criteri:

- spazio;
- rotazione;
- consociazione.

La configurazione standard di `DecisionWeights` assegna:

- 40% allo spazio;
- 30% alla rotazione;
- 30% alla consociazione.

L'introduzione delle esigenze familiari ha reso necessario decidere se tali informazioni dovessero diventare un quarto peso del `DecisionEngine` oppure essere utilizzate secondo una logica distinta.

### Decisione

Non introdurre il fabbisogno familiare come quarto peso del `DecisionEngine`.

Il punteggio agronomico continua a essere determinato esclusivamente dai criteri agronomici già definiti mediante `DecisionWeights`.

Le esigenze familiari vengono integrate nella `RecommendationPipeline` come criterio gerarchico di ordinamento.

L'ordine adottato è:

    1. Fascia agronomica
    2. Priorità familiare
    3. Punteggio agronomico

La `RecommendationPipeline` classifica le raccomandazioni nelle rispettive fasce agronomiche e applica successivamente la priorità familiare.

La priorità familiare può modificare l'ordine delle raccomandazioni soltanto quando queste appartengono alla stessa fascia agronomica.

Una raccomandazione appartenente a una fascia agronomica superiore mantiene pertanto la precedenza anche in presenza di una priorità familiare inferiore.

### Motivazione

- Preservare la correttezza agronomica come criterio prioritario del sistema.
- Evitare che una preferenza familiare possa compensare una valutazione agronomica significativamente peggiore.
- Mantenere separati il punteggio agronomico e il fabbisogno familiare.
- Evitare di modificare inutilmente `DecisionWeights`.
- Conservare il ruolo del `DecisionEngine` come componente responsabile esclusivamente della valutazione agronomica.
- Utilizzare la `RecommendationPipeline` come punto di coordinamento dei diversi criteri del processo di raccomandazione.
- Rendere il sistema più leggibile, modulare ed estendibile.

Principio adottato:

> **La correttezza agronomica stabilisce la fascia; il fabbisogno familiare ordina le alternative equivalenti dal punto di vista agronomico.**

### Alternative valutate

- Introdurre il fabbisogno familiare come quarto peso del `DecisionEngine`.
- Modificare la configurazione `DecisionWeights` per includere direttamente la priorità familiare.
- Applicare un bonus numerico al punteggio agronomico in funzione delle esigenze familiari.
- Consentire alla priorità familiare di ordinare globalmente tutte le raccomandazioni indipendentemente dalla fascia agronomica.

Le alternative sono state scartate perché avrebbero mescolato criteri agronomici e familiari nello stesso punteggio oppure avrebbero consentito alle preferenze familiari di superare valutazioni agronomiche qualitativamente superiori.

### Conseguenze

- `DecisionWeights` rimane configurato sui soli criteri agronomici 40/30/30.
- Il `DecisionEngine` continua a produrre il punteggio agronomico senza dipendere dalle esigenze familiari.
- Il `FamilyNeedsEngine` viene integrato nella `RecommendationPipeline`.
- La `RecommendationPipeline` gestisce l'ordinamento gerarchico delle raccomandazioni.
- La fascia agronomica ha priorità rispetto alle esigenze familiari.
- La priorità familiare interviene soltanto all'interno della stessa fascia agronomica.
- Il punteggio agronomico viene utilizzato come criterio successivo nell'ordinamento.
- Una priorità familiare elevata non può rendere preferibile una raccomandazione appartenente a una fascia agronomica inferiore.
- L'architettura rimane predisposta alla futura introduzione di quantità familiari e pianificazione scalare delle coltivazioni.

---

## 3.7 DEC-007 – Separazione tra priorità familiare, fabbisogno quantitativo e lotto pianificato

**Stato:** Approvata

**Data:** 10/08/2026

**Sessione:** S013

### Contesto

Con l'integrazione del `FamilyNeedsEngine` nel sistema di raccomandazione è stata completata la prima gestione della priorità attribuita dalla famiglia alle diverse colture.

La preparazione del futuro `SuccessionPlanningEngine` ha però reso necessario rappresentare un'informazione differente: non soltanto quanto una coltura sia desiderata, ma quale quantità debba essere disponibile e con quale periodicità.

È inoltre necessario mantenere distinta tale esigenza dal lotto operativo che il futuro sistema di pianificazione dovrà generare.

Sono state pertanto individuate tre responsabilità differenti:

- rappresentare la priorità qualitativa attribuita dalla famiglia a una coltura;
- rappresentare quantitativamente quanto prodotto è necessario e con quale periodicità;
- rappresentare il singolo lotto di coltivazione pianificato nel tempo.

L'accorpamento di questi concetti avrebbe reso ambigua la responsabilità dei modelli e aumentato l'accoppiamento tra esigenze familiari e pianificazione operativa.

### Decisione

Mantenere formalmente separati priorità familiare, fabbisogno quantitativo-periodico e lotto di coltivazione pianificato.

La separazione adottata è:

```text
FamilyCropNeed
        ↓
priorità familiare

FamilyConsumptionNeed
        ↓
quantità necessaria nel tempo

PlannedPlantingBatch
        ↓
lotto operativo pianificato

SuccessionPlanningEngine
        ↓
distribuzione temporale dei lotti
```

`FamilyCropNeed` continua a rappresentare la priorità qualitativa attribuita dalla famiglia a una coltura.

`FamilyConsumptionNeed` rappresenta invece il fabbisogno quantitativo e periodico mediante:

- `cropId`;
- `quantity`;
- `unit`;
- `intervalDays`.

`PlannedPlantingBatch` rappresenta il lotto operativo pianificato che sarà utilizzato dal futuro sistema di pianificazione.

Le regole di validità dei nuovi modelli vengono mantenute separate mediante `FamilyConsumptionNeedValidator` e `PlannedPlantingBatchValidator`.

Il `SuccessionPlanningEngine` rimane un componente distinto e sarà responsabile della trasformazione dei fabbisogni quantitativi e periodici in una sequenza temporale di lotti pianificati.

Nella Sessione S013 vengono introdotte esclusivamente le fondamenta dati e di validazione; il `SuccessionPlanningEngine` non è ancora implementato.

### Modalità operative

La futura pianificazione dovrà contemplare quattro modalità operative:

1. acquisto di piantine e trapianto;
2. semina in semenzaio seguita da trapianto;
3. semina diretta a file nell'aiuola;
4. semina diretta a spaglio nell'aiuola.

Per la semina diretta a file, il riferimento della pianificazione dovrà essere costituito dal numero di piante finali previste e non dalla sola quantità di seme utilizzata.

Per la semina diretta a spaglio, il sistema dovrà invece poter utilizzare come riferimento l'area coltivata prevista.

La quantità di seme rimane un'informazione operativa utile, ma non viene considerata equivalente alla produzione finale.

### Motivazione

- Distinguere una preferenza qualitativa da un fabbisogno quantitativo.
- Rappresentare esplicitamente la periodicità del consumo familiare.
- Evitare che `FamilyCropNeed` accumuli responsabilità non appartenenti alla gestione delle priorità.
- Separare il fabbisogno familiare dal lotto operativo prodotto dalla pianificazione.
- Preparare un'interfaccia dati chiara per il futuro `SuccessionPlanningEngine`.
- Mantenere separate le regole di validazione dalla rappresentazione dei modelli.
- Consentire al futuro pianificatore di gestire modalità di coltivazione differenti.
- Evitare di utilizzare la quantità di seme come sostituto improprio della produzione finale prevista.
- Preparare il sistema alla distribuzione scalare delle coltivazioni e alla riduzione delle sovrapproduzioni concentrate.

### Alternative valutate

- Estendere `FamilyCropNeed` aggiungendo direttamente quantità e periodicità.
- Affidare al `FamilyNeedsEngine` anche la pianificazione quantitativa delle coltivazioni.
- Utilizzare direttamente la quantità di seme come misura della produzione pianificata.
- Rappresentare fabbisogno familiare e lotto pianificato mediante un unico modello.
- Implementare immediatamente il `SuccessionPlanningEngine` senza introdurre preventivamente modelli e validatori dedicati.

Le alternative sono state scartate perché avrebbero mescolato responsabilità differenti, reso meno esplicito il dominio applicativo oppure introdotto prematuramente logiche di pianificazione senza una base dati sufficientemente definita.

### Conseguenze

- `FamilyCropNeed` rimane dedicato alla priorità familiare.
- `FamilyConsumptionNeed` rappresenta quantità, unità e periodicità del fabbisogno.
- `PlannedPlantingBatch` rappresenta separatamente il lotto operativo pianificato.
- `FamilyConsumptionNeedValidator` e `PlannedPlantingBatchValidator` mantengono separate le rispettive regole di validità.
- Il futuro `SuccessionPlanningEngine` dispone delle fondamenta necessarie per ricevere fabbisogni quantitativi e generare lotti pianificati.
- Le diverse modalità di coltivazione potranno essere trattate secondo criteri appropriati alla loro natura.
- La quantità di seme rimane distinta dalla produzione finale prevista.
- L'architettura rimane predisposta alla futura pianificazione scalare e alla continuità delle produzioni.

---

## 3.8 DEC-008 – Divieto di conversioni implicite non supportate nella pianificazione

**Stato:** Approvata

**Data:** 11/08/2026

**Sessione:** S014

### Contesto

Con la prima implementazione del `SuccessionPlanningEngine` è diventato necessario trasformare un `FamilyConsumptionNeed` in una sequenza temporale di `PlannedPlantingBatch`.

Il fabbisogno familiare può essere espresso mediante unità differenti, tra cui:

- pezzi;
- grammi;
- chilogrammi.

La quantità necessaria alla famiglia non coincide però necessariamente con la quantità di impianto richiesta per ottenere quella produzione.

Ad esempio:

- 5 kg di pomodori necessari alla famiglia non equivalgono automaticamente a 5 piante di pomodoro;
- un fabbisogno espresso in pezzi non determina automaticamente una superficie da seminare;
- una quantità espressa in peso richiede informazioni sulla resa produttiva della coltura o della varietà prima di poter essere trasformata in un numero di piante.

L'introduzione automatica di tali conversioni senza dati agronomici sufficienti produrrebbe risultati apparentemente precisi ma tecnicamente non affidabili.

### Decisione

Il `SuccessionPlanningEngine` non deve inventare conversioni tra fabbisogno familiare e quantità di impianto quando il sistema non dispone delle informazioni agronomiche necessarie per determinarle correttamente.

La prima versione del motore ammette esclusivamente la conversione:

```text
pieces → plants
```

Sono invece esplicitamente rifiutate conversioni quali:

```text
pieces → areaSquareCm
kilograms → plants
```

e, più in generale, tutte le conversioni che richiedono dati produttivi o agronomici non ancora disponibili.

La relazione adottata è pertanto:

```text
fabbisogno familiare
        ↓
conversione esplicitamente supportata
        ↓
quantità di impianto
        ↓
PlannedPlantingBatch
```

Se una conversione non è esplicitamente supportata, la pianificazione deve essere rifiutata anziché produrre un valore stimato arbitrariamente.

### Separazione delle responsabilità

La decisione mantiene distinti:

```text
FamilyConsumptionNeed
        ↓
quantità richiesta dalla famiglia

SuccessionPlanningEngine
        ↓
pianificazione temporale

informazioni agronomiche future
        ↓
conversione tra produzione richiesta e quantità di impianto
```

Il `SuccessionPlanningEngine` mantiene quindi la responsabilità della distribuzione temporale dei lotti, senza assumere autonomamente conoscenze relative alla resa produttiva delle colture.

Le conversioni future potranno essere introdotte soltanto quando saranno disponibili dati sufficienti, ad esempio:

- resa media per pianta;
- resa prevista della varietà;
- densità di coltivazione;
- superficie necessaria;
- metodo di impianto;
- caratteristiche produttive specifiche della coltura.

### Motivazione

- Evitare conversioni agronomicamente arbitrarie.
- Impedire che valori espressi in unità differenti vengano trattati come equivalenti.
- Mantenere espliciti i limiti conoscitivi del sistema.
- Evitare risultati numericamente validi ma agronomicamente errati.
- Mantenere separata la pianificazione temporale dalla stima della resa produttiva.
- Consentire l'introduzione futura di conversioni soltanto quando supportate da dati reali.
- Rendere il comportamento del motore deterministico e verificabile mediante test.
- Preservare la modularità del `SuccessionPlanningEngine`.

### Alternative valutate

- Convertire direttamente la quantità richiesta nel numero di piante utilizzando lo stesso valore numerico.
- Utilizzare conversioni predefinite indipendenti dalla coltura o dalla varietà.
- Stimare automaticamente superfici o quantità di impianto anche in assenza di dati produttivi.
- Integrare immediatamente nel `SuccessionPlanningEngine` regole di resa non ancora disponibili nel dominio applicativo.

Le alternative sono state scartate perché avrebbero introdotto assunzioni non supportate dai dati e reso il risultato della pianificazione potenzialmente fuorviante.

### Conseguenze

- La V1 del `SuccessionPlanningEngine` supporta esclusivamente `pieces → plants`.
- Le conversioni non supportate vengono rifiutate.
- Il motore non interpreta automaticamente una quantità espressa in peso come numero di piante.
- Il motore non trasforma automaticamente un fabbisogno espresso in pezzi in una superficie da coltivare.
- La futura conversione tra fabbisogno e quantità di impianto richiederà informazioni agronomiche dedicate.
- La pianificazione temporale rimane separata dalla futura stima della resa produttiva.
- L'architettura resta predisposta all'introduzione progressiva di conversioni esplicitamente definite e testabili.

---

## 3.9 DEC-009 – Separazione tra pianificazione temporale e compatibilità agronomica

**Stato:** Approvata

**Data:** 11/08/2026

**Sessione:** S015

### Contesto

Con la prima implementazione del `SuccessionPlanningEngine` nella Sessione S014, Orto Smart è diventato in grado di trasformare un `FamilyConsumptionNeed` in una sequenza temporale teorica di `PlannedPlantingBatch`.

La pianificazione deterministica basata su `intervalDays` stabilisce quando generare i diversi lotti, ma non determina se le date ottenute siano effettivamente compatibili con il ciclo agronomico della coltura.

Una data teoricamente corretta dal punto di vista della successione temporale può infatti risultare inadatta per:

- semina in semenzaio;
- semina diretta;
- trapianto;
- altre future modalità operative;

in funzione del periodo dell'anno e, nelle evoluzioni successive, delle caratteristiche della coltura, della varietà, del clima e delle condizioni meteorologiche.

Integrare direttamente tali verifiche nel `SuccessionPlanningEngine` avrebbe progressivamente aumentato le responsabilità del componente, mescolando la generazione temporale dei lotti con la valutazione della loro ammissibilità agronomica.

### Decisione

Mantenere formalmente separate la pianificazione temporale teorica dei lotti e la verifica della loro compatibilità agronomica.

La separazione adottata è:

```text
FamilyConsumptionNeed
        ↓
SuccessionPlanningEngine
        ↓
PlannedPlantingBatch
        ↓
verifica agronomica separata
        ↓
AgronomicWindowEngine
```

Il `SuccessionPlanningEngine` mantiene la responsabilità di generare la sequenza temporale teorica dei `PlannedPlantingBatch`.

La compatibilità agronomica viene verificata separatamente mediante l'infrastruttura introdotta nella Sessione S015:

```text
AgronomicWindow
        ↓
AgronomicWindowValidator
        ↓
AgronomicWindowEngine
```

`AgronomicWindow` rappresenta una finestra annuale associata a uno specifico `PlannedPlantingStartMethod`.

`AgronomicWindowValidator` verifica la validità strutturale della finestra.

`AgronomicWindowEngine` verifica l'appartenenza temporale di una data alla finestra e la compatibilità di un `PlannedPlantingBatch`.

La compatibilità di un lotto richiede contemporaneamente:

```text
batch.startMethod == window.startMethod
```

e:

```text
batch.plannedDate ∈ AgronomicWindow
```

Il `SuccessionPlanningEngine` non viene quindi modificato per incorporare direttamente le regole relative alle finestre agronomiche.

### Rappresentazione annuale delle finestre

Le finestre agronomiche vengono rappresentate indipendentemente da uno specifico anno mediante:

- mese iniziale;
- giorno iniziale;
- mese finale;
- giorno finale.

Questa rappresentazione consente di descrivere una stagionalità ricorrente annualmente.

Sono supportate sia finestre comprese nello stesso anno solare:

```text
15 marzo → 30 settembre
```

sia finestre che attraversano il cambio dell'anno:

```text
1 ottobre → 28 febbraio
```

Gli estremi sono considerati inclusivi.

Il confronto temporale utilizza quindi mese e giorno della data senza rendere la finestra dipendente dall'anno specifico del `PlannedPlantingBatch`.

### Separazione dalla futura correzione climatica e meteorologica

La prima versione delle finestre agronomiche rappresenta esclusivamente una compatibilità stagionale di base.

Non vengono ancora incorporate direttamente informazioni relative a:

- temperature;
- rischio di gelo;
- localizzazione geografica;
- condizioni meteorologiche;
- dati della stazione meteorologica;
- adattamento dinamico delle finestre.

L'evoluzione prevista mantiene distinti i diversi livelli:

```text
pianificazione temporale teorica
        ↓
compatibilità stagionale di base
        ↓
future correzioni climatiche e meteorologiche
```

La futura valutazione non dovrà dipendere rigidamente da classificazioni generiche Nord/Centro/Sud.

L'architettura dovrà rimanere predisposta all'utilizzo della localizzazione reale dell'orto e delle informazioni meteorologiche locali.

### Motivazione

- Mantenere il `SuccessionPlanningEngine` dedicato alla pianificazione temporale.
- Evitare l'accumulo di responsabilità agronomiche nel pianificatore.
- Separare una data teoricamente pianificata dalla sua effettiva ammissibilità agronomica.
- Rendere indipendente e testabile la logica delle finestre agronomiche.
- Consentire l'evoluzione delle regole stagionali senza modificare il motore di successione.
- Gestire correttamente finestre che attraversano il cambio dell'anno.
- Distinguere la compatibilità del metodo di avvio dalla sola appartenenza temporale.
- Preparare l'associazione futura delle finestre a colture e varietà.
- Preparare l'integrazione futura di temperatura, gelo, localizzazione e meteo reale.
- Evitare una dipendenza architetturale rigida da classificazioni climatiche generiche.

### Alternative valutate

- Integrare direttamente le finestre agronomiche nel `SuccessionPlanningEngine`.
- Rendere il `SuccessionPlanningEngine` responsabile sia della generazione sia della correzione delle date.
- Associare la compatibilità esclusivamente alla data ignorando il metodo di avvio.
- Rappresentare le finestre mediante intervalli legati a uno specifico anno.
- Introdurre immediatamente nel motore delle finestre anche temperatura, gelo e dati meteorologici.
- Utilizzare fin dalla prima versione una classificazione climatica rigida Nord/Centro/Sud.

Le alternative sono state scartate perché avrebbero aumentato l'accoppiamento tra responsabilità differenti, limitato la riutilizzabilità dei componenti o introdotto prematuramente criteri climatici e meteorologici non ancora modellati.

### Conseguenze

- Il `SuccessionPlanningEngine` rimane invariato e continua a produrre lotti teorici.
- `AgronomicWindow` rappresenta separatamente le finestre agronomiche annuali.
- `AgronomicWindowValidator` mantiene separate le regole di validità strutturale.
- `AgronomicWindowEngine` verifica la compatibilità temporale.
- La compatibilità di un lotto richiede sia metodo di avvio sia data compatibili.
- Le finestre possono attraversare il cambio dell'anno.
- Gli estremi delle finestre sono inclusivi.
- La stagionalità V1 rimane separata da clima e meteo.
- Le finestre non sono ancora associate direttamente a `Crop` o `CropVariety`.
- La futura associazione delle finestre alle colture e alle varietà potrà essere introdotta senza modificare la responsabilità del `SuccessionPlanningEngine`.
- Le future correzioni climatiche e meteorologiche potranno essere aggiunte come livello separato della valutazione agronomica.

---

## 3.10 DEC-010 – Risoluzione gerarchica delle regole agronomiche e distinzione dell'assenza di conoscenza

**Stato:** Approvata

**Data:** 12/08/2026

**Sessione:** S016

### Contesto

La Sessione S015 ha introdotto `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine`, separando formalmente la pianificazione temporale dei lotti dalla verifica della loro compatibilità agronomica.

Le finestre introdotte nella S015 erano tuttavia ancora astratte e non risultavano associate direttamente alle colture o alle varietà.

Per rendere utilizzabile la stagionalità nel dominio applicativo è diventato necessario stabilire:

- come associare una finestra agronomica a una coltura;
- come rappresentare eventuali regole specifiche di una varietà;
- quale regola utilizzare quando sono disponibili sia una regola generale sia una specifica;
- come rappresentare l'assenza di una regola;
- quale componente debba selezionare la regola;
- quale componente debba verificarne la compatibilità temporale;
- come coordinare l'intero processo senza aumentare le responsabilità del `SuccessionPlanningEngine`.

Era inoltre necessario evitare che l'assenza di informazioni agronomiche venisse interpretata automaticamente come incompatibilità.

Una coltura per la quale Orto Smart non possiede ancora una regola stagionale non può infatti essere considerata agronomicamente incompatibile: il sistema dispone semplicemente di informazioni insufficienti per formulare il giudizio.

### Decisione

Associare le finestre agronomiche alle colture e alle varietà mediante un modello dedicato denominato `CropAgronomicWindowRule`.

Una regola può essere:

```text
varietyId == null
        ↓
regola generale della coltura

varietyId != null
        ↓
regola specifica della varietà
```

Quando viene valutato un `PlannedPlantingBatch`, la selezione della regola deve seguire una gerarchia deterministica:

```text
regola specifica della varietà
        ↓
regola generale della coltura
        ↓
nessuna regola disponibile
```

La regola specifica della varietà ha quindi precedenza sulla regola generale della coltura.

In assenza di una regola varietale applicabile, il sistema utilizza automaticamente la regola generale della coltura.

Se non è disponibile alcuna regola applicabile, il sistema non deve classificare il lotto come incompatibile.

Il risultato deve invece essere:

```text
unknown
```

Viene pertanto formalizzato il principio:

```text
unknown != incompatible
```

### Separazione delle responsabilità

La selezione della regola e la verifica della compatibilità temporale devono rimanere responsabilità distinte.

L'architettura adottata è:

```text
PlannedPlantingBatch
        ↓
AgronomicWindowResolver
        ↓
CropAgronomicWindowRule
        ↓
AgronomicWindow
        ↓
AgronomicWindowEngine
        ↓
AgronomicWindowEvaluation
```

Le responsabilità sono assegnate nel seguente modo.

`CropAgronomicWindowRule`:

- associa una finestra a una coltura;
- può specializzare la regola per una varietà;
- non valuta la data del lotto.

`AgronomicWindowResolver`:

- riceve le regole disponibili;
- considera coltura, varietà e metodo di avvio;
- privilegia la regola specifica della varietà;
- utilizza in fallback la regola generale della coltura;
- restituisce l'assenza di una regola quando nessuna corrispondenza è disponibile;
- non verifica la compatibilità temporale.

`AgronomicWindowEngine`:

- riceve la finestra selezionata;
- verifica la compatibilità del metodo di avvio;
- verifica l'appartenenza temporale della data alla finestra;
- non decide quale regola utilizzare.

`AgronomicWindowEvaluation`:

- rappresenta il risultato strutturato della valutazione;
- distingue `compatible`, `incompatible` e `unknown`;
- conserva la finestra utilizzata quando disponibile;
- può fornire le motivazioni del risultato.

`AgronomicWindowService`:

- coordina `AgronomicWindowResolver` e `AgronomicWindowEngine`;
- produce `AgronomicWindowEvaluation`;
- non introduce logica agronomica propria.

Il `SuccessionPlanningEngine` rimane responsabile esclusivamente della generazione temporale dei lotti e non viene modificato per incorporare la selezione o la valutazione delle regole stagionali.

### Stati della valutazione

Il risultato della valutazione non viene rappresentato mediante un semplice valore booleano.

Sono definiti tre stati:

```text
compatible
incompatible
unknown
```

`compatible` significa:

```text
regola disponibile
        +
data e metodo compatibili
```

`incompatible` significa:

```text
regola disponibile
        +
data o metodo non compatibili
```

`unknown` significa:

```text
nessuna regola applicabile
        ↓
conoscenza agronomica insufficiente
```

Questa distinzione impedisce che una mancanza di dati venga trasformata in un giudizio agronomico negativo.

### Principio di generalizzazione e override varietale

La struttura delle regole deve privilegiare il dato generale della coltura e introdurre informazioni specifiche della varietà soltanto quando realmente necessarie.

Il principio è:

```text
regola generale della coltura
        +
override della varietà solo quando necessario
```

Questo approccio consente di:

- ridurre la duplicazione dei dati;
- mantenere compatta la futura struttura persistente;
- rappresentare eccezioni varietali senza replicare tutte le informazioni della coltura;
- mantenere un comportamento di fallback deterministico.

### Persistenza

La Sessione S016 non introduce ancora la persistenza delle regole agronomiche in Supabase.

La persistenza viene deliberatamente rinviata fino alla stabilizzazione del dominio e del comportamento applicativo.

Il principio adottato è:

```text
dominio
        ↓
comportamento verificato mediante test
        ↓
contratto stabile
        ↓
progettazione della persistenza
```

La futura struttura Supabase dovrà quindi adattarsi al dominio consolidato e non determinare prematuramente la struttura dei componenti applicativi.

Prima della progettazione dello schema persistente dovranno essere verificati:

- struttura reale di `crops`;
- struttura reale di `crop_varieties`;
- foreign key e vincoli esistenti;
- differenza tra gli identificativi `String` utilizzati dal dominio agronomico, gli identificativi `int` attualmente utilizzati da `CropVariety` e i `bigint` presenti in Supabase;
- possibilità che una coltura e uno stesso metodo di avvio possiedano più finestre agronomiche nello stesso anno.

### Separazione dalle future correzioni climatiche e meteorologiche

La S016 consolida la stagionalità di base delle colture e delle varietà ma non introduce ancora correzioni dinamiche basate sul clima o sul meteo.

Rimane valida la separazione:

```text
pianificazione temporale teorica
        ↓
stagionalità di base della coltura o varietà
        ↓
compatibilità del lotto
        ↓
future correzioni climatiche e meteorologiche
```

Restano quindi fuori dalla responsabilità dei componenti introdotti nella S016:

- temperatura reale;
- rischio di gelo;
- localizzazione geografica;
- condizioni meteorologiche correnti;
- dati della stazione meteorologica locale;
- adattamento dinamico delle finestre.

Questi elementi potranno essere introdotti successivamente come livello separato senza modificare la responsabilità fondamentale del sistema di risoluzione delle finestre.

### Motivazione

- Associare le finestre agronomiche alle effettive colture e varietà.
- Consentire override varietali senza duplicare inutilmente le regole generali.
- Definire un fallback deterministico tra varietà e coltura.
- Distinguere chiaramente assenza di conoscenza e incompatibilità.
- Evitare falsi giudizi agronomici negativi in presenza di dati mancanti.
- Separare la selezione della regola dalla verifica temporale.
- Mantenere il `SuccessionPlanningEngine` indipendente dalla stagionalità.
- Rendere ogni componente autonomamente testabile.
- Mantenere il servizio applicativo privo di logica agronomica propria.
- Stabilizzare il dominio prima di progettare la persistenza.
- Ridurre la futura duplicazione dei dati.
- Preparare l'integrazione successiva con Supabase.
- Preservare la separazione dalle future correzioni climatiche e meteorologiche.

### Alternative valutate

- Associare direttamente le finestre a `Crop` e `CropVariety` modificando immediatamente i modelli esistenti.
- Duplicare tutte le regole della coltura per ogni varietà.
- Utilizzare esclusivamente regole specifiche delle varietà.
- Utilizzare esclusivamente regole generali delle colture.
- Integrare la selezione della regola direttamente nell'`AgronomicWindowEngine`.
- Integrare l'intero processo nel `SuccessionPlanningEngine`.
- Rappresentare il risultato mediante un semplice booleano.
- Interpretare l'assenza di una regola come incompatibilità.
- Creare immediatamente le tabelle Supabase prima della stabilizzazione del dominio.
- Integrare già nella S016 temperatura, gelo, localizzazione e meteo reale.

Le alternative sono state scartate perché avrebbero aumentato l'accoppiamento tra responsabilità differenti, introdotto duplicazioni, prodotto giudizi non supportati dai dati oppure vincolato prematuramente il dominio alla persistenza.

### Conseguenze

- Le finestre agronomiche possono essere associate a colture e varietà mediante `CropAgronomicWindowRule`.
- Le regole generali della coltura possono essere specializzate mediante override varietali.
- `AgronomicWindowResolver` seleziona la regola applicabile.
- La regola specifica della varietà ha precedenza sulla regola generale della coltura.
- In assenza della regola varietale viene utilizzata la regola generale della coltura.
- In assenza di qualsiasi regola applicabile il risultato è `unknown`.
- `unknown` rimane semanticamente distinto da `incompatible`.
- `AgronomicWindowEngine` mantiene la responsabilità della verifica temporale.
- `AgronomicWindowEvaluation` rappresenta il risultato mediante tre stati.
- `AgronomicWindowService` coordina resolver ed engine senza introdurre logica agronomica propria.
- Il `SuccessionPlanningEngine` rimane separato dalla valutazione stagionale.
- La persistenza Supabase non viene ancora introdotta.
- La progettazione della persistenza viene rinviata alla sessione successiva.
- La futura struttura dati dovrà privilegiare regole generali con override varietali quando necessari.
- Le correzioni climatiche e meteorologiche rimangono un livello evolutivo successivo e separato.

---

# 4. Registro delle decisioni

| ID      | Data       | Sessione | Titolo                                                                                | Stato     |
| ------- | ---------- | -------- | ------------------------------------------------------------------------------------- | --------- |
| DEC-001 | 28/07/2026 | S005     | Standardizzazione degli identificativi delle colture                                  | Approvata |
| DEC-002 | 28/07/2026 | S005     | Introduzione di BedAnalysisService                                                    | Approvata |
| DEC-003 | 29/07/2026 | S006     | Introduzione del Decision Engine                                                      | Approvata |
| DEC-004 | 01/08/2026 | S007     | Chiusura formale delle sessioni di sviluppo                                           | Approvata |
| DEC-005 | 09/08/2026 | S011     | Separazione tra fabbisogno familiare e pianificazione temporale                       | Approvata |
| DEC-006 | 09/08/2026 | S012     | Integrazione gerarchica del fabbisogno familiare nel sistema di raccomandazione       | Approvata |
| DEC-007 | 10/08/2026 | S013     | Separazione tra priorità familiare, fabbisogno quantitativo e lotto pianificato       | Approvata |
| DEC-008 | 11/08/2026 | S014     | Divieto di conversioni implicite non supportate nella pianificazione                      | Approvata |
| DEC-009 | 11/08/2026 | S015     | Separazione tra pianificazione temporale e compatibilità agronomica                | Approvata |
| DEC-010 | 12/08/2026 | S016     | Risoluzione gerarchica delle regole agronomiche e distinzione dell'assenza di conoscenza | Approvata |

---

# 5. Considerazioni finali

Il presente documento raccoglie le principali decisioni architetturali che hanno guidato l'evoluzione di Orto Smart, documentandone il contesto, le motivazioni e le conseguenze sull'architettura del progetto.

La registrazione delle decisioni architetturali consente di preservare la conoscenza tecnica maturata durante lo sviluppo, favorendo la comprensione delle scelte progettuali e garantendo continuità nell'evoluzione del software.

Ogni nuova decisione che comporti modifiche significative all'architettura dovrà essere documentata nel presente documento, mantenendolo costantemente allineato con il Manuale Tecnico (DOC-001), il Quaderno di Sviluppo (DOC-005) e gli altri documenti ufficiali del progetto.

Il documento Decisioni Architetturali costituisce pertanto il riferimento ufficiale per la tracciabilità delle principali scelte progettuali adottate nello sviluppo di Orto Smart e rappresenta uno strumento fondamentale per garantirne la coerenza, la manutenibilità e l'evoluzione nel tempo.