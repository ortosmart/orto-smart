# ORTO SMART

### DOC-011

# Decisioni Architetturali (ADR)

**Versione:** 1.8
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 28/07/2026
**Ultimo aggiornamento:** 03/09/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo                | Valore                         |
| -------------------- | ------------------------------ |
| Documento            | DOC-011                        |
| Titolo               | Decisioni Architetturali (ADR) |
| Versione             | 1.8                            |
| Stato                | In sviluppo                    |
| Progetto             | Orto Smart                     |
| Repository           | ortosmart/orto-smart           |
| Prima emissione      | 28/07/2026                     |
| Ultimo aggiornamento | 03/09/2026                     |

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
| 1.0      | 16/08/2026 | Introduzione della DEC-011 sulla baseline architetturale del Database V1 e congelamento della progettazione S017 |
| 1.1      | 16/08/2026 | Aggiornamento della DEC-010 con l'evoluzione introdotta nella Sessione S018: supporto a più finestre agronomiche applicabili, fallback tra livelli di specificità e distinzione tra `matchedWindow` ed `evaluatedWindows` |
| 1.2      | 20/08/2026 | Introduzione della DEC-012 sulla sicurezza e gestione concorrente di `profile_edit_locks` nella Sessione S020, con definizione del protocollo server-side, token, lease, heartbeat, takeover, controllo della concorrenza e privilegi delle RPC |
| 1.3      | 21/08/2026 | Aggiornamento della DEC-012 con l'hardening della concorrenza introdotto nella Sessione S021, audit finale del protocollo `profile_edit_lock` e definizione del confine con il futuro Write Path autoritativo Categoria A |
| 1.4      | 23/08/2026 | Consolidamento della DEC-012 con il completamento e l'hardening del protocollo `profile_edit_locks` nella Sessione S021 e definizione del confine architetturale con il futuro Write Path autoritativo Categoria A |
| 1.5      | 24/08/2026 | Aggiornamento della DEC-012 con la Sessione S022: applicazione del protocollo `profile_edit_locks` come fondamento del primo Write Path autoritativo di Categoria A per `gardens`, introduzione di `Profile Write Authority`, RPC `create_garden` e `update_garden` e definizione del confine con le ulteriori entità di Categoria A |
| 1.6      | 28/08/2026 | Aggiornamento della DEC-012 con la Sessione S023: hardening concorrente di `update_garden`, estensione del Write Path autoritativo a `seasons`, introduzione dell’identità tecnica del client e della sessione e integrazione Flutter fail-closed della Profile Write Authority |
| 1.7      | 01/09/2026 | Aggiornamento della DEC-012 con la Sessione S024: estensione del Write Path autoritativo a `beds`, geometria storicizzata, concorrenza ottimistica, correzioni tracciate e integrazione Flutter mediante `ProfileContextScope` e risultati tipizzati |
| 1.8      | 03/09/2026 | Manutenzione straordinaria delle Decisioni Architetturali: eliminazione della duplicazione relativa all’attivazione atomica della stagione nella DEC-012 |

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
3.11 DEC-011 – Baseline architetturale del Database V1
3.12 DEC-012 – Sicurezza e gestione concorrente del `profile_edit_lock`

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
- `AgronomicWindowResolver` determina l'insieme delle regole e delle finestre applicabili.
- Le regole specifiche della varietà hanno precedenza sulle regole generali della coltura.
- Se esiste almeno una regola specifica della varietà, vengono utilizzate tutte le relative finestre applicabili.
- Soltanto in assenza di regole varietali vengono utilizzate le finestre generali della coltura.
- Il fallback opera quindi tra livelli di specificità e non tra singole finestre.
- In assenza di qualsiasi finestra applicabile il risultato è `unknown`.
- A partire dalla S018, `AgronomicWindowEvaluation` distingue `matchedWindow` da `evaluatedWindows`.
- La valutazione è `compatible` se almeno una finestra applicabile è valida e `incompatible` soltanto se esistono finestre applicabili ma nessuna risulta valida.
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

## 3.11 DEC-011 – Baseline architetturale del Database V1

**Stato:** Approvata

**Data:** 16/08/2026

**Sessione:** S017

### Contesto

La crescita del dominio applicativo di Orto Smart ha reso necessario riesaminare in modo organico la struttura persistente del progetto prima di procedere con ulteriori implementazioni in Supabase.

Le funzionalità introdotte nelle sessioni precedenti hanno progressivamente ampliato il dominio oltre il nucleo iniziale costituito da orti, aiuole, colture, stagioni e piantagioni.

In particolare, la progettazione deve supportare in modo coerente:

- catalogo agronomico e varietà;
- regole agronomiche;
- preferenze e fabbisogni familiari;
- pianificazione stagionale e scaglionamento delle coltivazioni;
- attività pianificate e lavoro realmente svolto;
- raccolte e valorizzazione della produzione;
- irrigazione;
- fertilizzazioni e trattamenti;
- strutture e dispositivi dell'orto;
- eventi e diario;
- costi;
- contesto ambientale;
- evoluzione temporale delle configurazioni;
- ownership, accesso e sicurezza dei dati.

La Sessione S017 è stata pertanto dedicata alla progettazione completa del Database V1 prima della sua traduzione in migration SQL/Supabase.

La progettazione ha inoltre richiesto di stabilire esplicitamente quali informazioni debbano essere persistite, quali debbano essere calcolate dal dominio applicativo e quali funzionalità debbano essere rinviate oltre il V1.

### Decisione

Viene adottata e congelata la baseline architetturale del **Database V1 di Orto Smart**, composta da:

- **52 entità di dominio**;
- **1 struttura tecnica**, `profile_edit_locks`, separata dal dominio;
- per un totale previsto di **53 strutture fisiche persistenti** una volta completata l'implementazione.

Il controllo nominale finale della Sessione S017 ha verificato **52/52 entità di dominio**.

La baseline congelata costituisce il riferimento ufficiale per la successiva implementazione SQL/Supabase.

#### Ownership e accesso

L'ownership applicativa segue la catena:

```text
Supabase Auth
        ↓
Profile
        ↓
Garden
```

`Profile` costituisce la radice applicativa dell'ownership.

Un Profile può possedere più Garden.

Per il V1 viene adottato un modello con **un account/Profile principale** per il nucleo che utilizza l'orto.

I componenti della stessa famiglia possono utilizzare lo stesso accesso applicativo senza richiedere account Supabase distinti.

Le persone alle quali deve essere attribuito il lavoro svolto nell'orto sono rappresentate mediante `workers`.

La presenza di un `worker` non implica l'esistenza di un account applicativo personale.

Rimangono pertanto distinti i concetti di:

```text
account autenticato
        ≠
persona che utilizza materialmente l'app
        ≠
worker al quale viene attribuito il lavoro
```

La multiutenza con account personali distinti e condivisione dello stesso Garden viene rinviata a una possibile evoluzione futura.

#### Modello single-writer

Per il V1 viene adottato un modello **single-writer per Profile**.

L'utilizzo dello stesso accesso da più dispositivi non deve consentire modifiche concorrenti incontrollate.

`profile_edit_locks` viene prevista come infrastruttura tecnica per il coordinamento delle operazioni di scrittura.

`profile_edit_locks` non costituisce un'entità di dominio e non viene pertanto conteggiata tra le 52 entità della baseline.

L'architettura deve comunque rimanere evolvibile verso un futuro modello multi-writer senza richiedere una riprogettazione completa del dominio.

#### Separazione tra pianificazione e realtà

Il Database V1 mantiene esplicitamente separate le informazioni pianificate dai fatti realmente avvenuti.

In particolare:

```text
consumption_needs
        ↓
season_crop_plans
        ↓
planned_plantings
        ↓
plantings
        ↓
harvest_events
```

`planned_plantings` rappresenta ciò che si prevede di coltivare.

`plantings` rappresenta ciò che viene realmente coltivato.

Una pianificazione non viene trasformata retroattivamente per simulare la realtà.

Analogamente:

```text
ActivityRule
        ↓
Task
        ↓
WorkLog
```

`Task` rappresenta il lavoro pianificato.

`WorkLog` rappresenta il lavoro realmente svolto.

Le quantità eseguite, gli avanzamenti e gli scostamenti devono essere derivati dai fatti reali quando possibile, evitando duplicazioni non necessarie.

#### Temporalità e storicizzazione

Le entità che rappresentano configurazioni modificabili nel tempo devono preservare la ricostruibilità storica.

Quando applicabile viene adottata la semantica temporale:

```text
[valid_from, valid_to)
```

Le modifiche future non devono alterare retroattivamente il significato dei dati storici.

In particolare viene separata l'identità stabile delle aiuole dalla loro geometria:

```text
beds
        ↓
identità stabile

bed_geometries
        ↓
geometria valida nel tempo
```

Lo stesso principio viene applicato alle configurazioni e alle relazioni per le quali la validità temporale costituisce informazione di dominio.

#### Regole agronomiche e dati calcolati

Le regole necessarie alla determinazione delle finestre agronomiche vengono persistite mediante:

```text
agronomic_window_rules
```

`AgronomicWindow` rimane invece un risultato calcolato dal motore agronomico.

Non viene pertanto introdotta nel Database V1 una tabella persistente:

```text
agronomic_windows
```

Questa scelta mantiene separati:

```text
conoscenza persistente
        ≠
risultato calcolato
```

Le regole agronomiche devono poter essere versionate semanticamente quando una modifica potrebbe alterare l'interpretazione storica delle decisioni.

#### Irrigazione

La configurazione dell'impianto irriguo viene mantenuta distinta dagli eventi di irrigazione realmente avvenuti.

Le zone, le fonti, i collegamenti e i target configurabili appartengono alla configurazione dell'impianto.

Gli eventi di irrigazione rappresentano invece fatti operativi.

Il nome SQL definitivo dell'entità relativa alle assegnazioni dei target alle zone irrigue è:

```text
irrigation_zone_target_assignments
```

La precedente denominazione provvisoria:

```text
zone_target_assignments
```

viene abbandonata.

#### Contesto ambientale e meteorologico

Il Database V1 non deve duplicare inutilmente archivi meteorologici grezzi esterni.

Le osservazioni meteorologiche locali possono provenire dalla stazione Davis/CumulusMX, mentre Open-Meteo costituisce la fonte esterna principale per le previsioni e può essere utilizzato come fallback quando la fonte locale non è disponibile.

Il database deve conservare soltanto il contesto ambientale necessario a rendere comprensibili e ricostruibili decisioni o eventi mediante:

```text
environment_context_snapshots
environment_context_links
```

L'archivio meteorologico grezzo completo rimane esterno al Database V1.

#### Sicurezza

La sicurezza del Database V1 deve essere applicata lato database e non affidata esclusivamente al client Flutter.

Flutter viene considerato un client non fidato ai fini dell'autorizzazione.

L'implementazione Supabase dovrà adottare:

- Row Level Security;
- principio deny-by-default;
- verifica server-side dell'ownership;
- vincoli di integrità;
- operazioni atomiche quando necessarie;
- protezione delle operazioni sensibili;
- gestione sicura delle credenziali;
- idempotenza per i futuri eventi automatici.

Schema e sicurezza devono essere sviluppati e verificati insieme durante le migration.

#### Funzionalità escluse dal V1

Non vengono introdotte nella baseline V1 funzionalità che aumenterebbero inutilmente la complessità iniziale senza essere indispensabili al funzionamento dell'applicazione.

Restano fuori dal V1, tra le altre:

- inventario e gestione di magazzino;
- lotti di scorta;
- ammortamenti;
- contabilità avanzata;
- GIS/PostGIS;
- multi-writer completo;
- multiutenza avanzata con account distinti e condivisione del Garden;
- duplicazione dell'archivio meteorologico grezzo;
- automazione irrigua completa;
- correzioni climatiche e meteorologiche avanzate.

Tali funzionalità potranno essere introdotte successivamente senza modificare la baseline V1 finché non risultino effettivamente necessarie.

### Motivazione

La decisione consente di disporre di una baseline persistente coerente prima di iniziare la realizzazione delle migration SQL.

La progettazione preventiva riduce il rischio di introdurre progressivamente tabelle isolate, duplicazioni, relazioni incoerenti o strutture difficili da evolvere.

La separazione tra configurazioni, pianificazione, fatti reali e dati calcolati permette inoltre di preservare la storia dell'orto e di ricostruire correttamente le decisioni nel tempo.

Il modello di ownership scelto mantiene semplice il V1 e risponde all'utilizzo familiare dell'applicazione senza introdurre prematuramente un sistema completo di condivisione multiutente.

Il modello single-writer limita i problemi di concorrenza derivanti dall'utilizzo dello stesso accesso da dispositivi diversi, mantenendo comunque aperta la possibilità di una futura evoluzione multi-writer.

La scelta di non duplicare l'archivio meteorologico grezzo e di evitare funzionalità di magazzino, contabilità avanzata e GIS contribuisce inoltre a mantenere il Database V1 proporzionato alle esigenze effettive del progetto.

### Alternative valutate

Sono state considerate e scartate o rinviate diverse alternative:

- creare account distinti per ogni componente familiare già nel V1;
- introdurre immediatamente un modello multi-writer completo;
- rappresentare ogni persona che svolge un lavoro come utente autenticato;
- memorizzare `AgronomicWindow` come tabella persistente;
- utilizzare `zone_target_assignments` come denominazione definitiva;
- incorporare direttamente nelle entità principali relazioni che richiedono propria temporalità;
- sovrascrivere le configurazioni precedenti invece di storicizzarle;
- trattare pianificazione e realtà come un'unica informazione;
- memorizzare nel database risultati facilmente derivabili dai fatti reali;
- duplicare nel Database V1 l'archivio meteorologico grezzo;
- introdurre inventario e gestione di magazzino;
- introdurre ammortamenti e contabilità avanzata;
- adottare GIS/PostGIS nel V1;
- realizzare immediatamente l'automazione irrigua completa.

Queste alternative sono state escluse perché avrebbero aumentato la complessità, introdotto duplicazioni o anticipato funzionalità non necessarie alla prima versione operativa.

### Conseguenze

- La baseline Database V1 viene congelata a **52 entità di dominio**.
- `profile_edit_locks` rimane una struttura tecnica separata.
- L'implementazione completa prevede pertanto **52 entità di dominio + 1 struttura tecnica**.
- Le successive migration SQL devono rispettare la baseline congelata.
- Eventuali variazioni della baseline richiederanno una motivazione architetturale esplicita.
- L'ownership parte dal Profile e raggiunge i dati attraverso il Garden.
- Il V1 utilizza un account/Profile principale condivisibile dal nucleo familiare.
- I `workers` rimangono indipendenti dagli account autenticati.
- Il V1 adotta un modello single-writer per Profile.
- Pianificazione e fatti reali rimangono separati.
- Le configurazioni temporalmente significative devono essere storicizzabili.
- `AgronomicWindow` rimane calcolato e `agronomic_windows` non viene introdotta come tabella persistente.
- `irrigation_zone_target_assignments` costituisce il nome SQL definitivo.
- Il contesto ambientale viene conservato selettivamente senza duplicare l'archivio meteorologico grezzo.
- RLS, autorizzazione e invarianti devono essere implementati insieme allo schema.
- Inventario, contabilità avanzata, GIS, multi-writer completo e altre estensioni non necessarie rimangono fuori dal V1.
- La progettazione dello STEP 34 viene considerata **completata e congelata**.
- La fase successiva consiste nella traduzione incrementale della baseline in migration SQL/Supabase, senza riaprire la progettazione salvo l'emersione di un errore concreto.

---

## 3.12 DEC-012 – Sicurezza e gestione concorrente del `profile_edit_lock`

**Stato:** Approvata

**Data:** 01/09/2026

**Sessione:** S020–S024

### Contesto

Il modello V1 di Orto Smart adotta un modello **single-writer per Profile**, nel quale lo stesso accesso applicativo può essere utilizzato da dispositivi diversi.

Il semplice utilizzo di autenticazione, autorizzazione e Row Level Security non è sufficiente a coordinare in modo atomico le modifiche concorrenti tra dispositivi.

È pertanto necessario che il coordinamento del writer e le transizioni sensibili del lock siano governati lato server, senza affidarsi ai dati di autorizzazione dichiarati dal client.

### Decisione

Viene adottato `profile_edit_locks` come infrastruttura tecnica server-side per il coordinamento del writer del Profile.

Il lock può essere acquisito esclusivamente dall'`owner` del Profile. `worker` e `viewer` non possono acquisirlo.

Il client comunica esclusivamente l'intenzione dell'operazione e gli identificatori tecnici necessari alla sessione. Il server determina in modo autoritativo identità, autorizzazione, validità temporale, stato del lock e transizioni consentite.

Il `lock_token` viene generato esclusivamente lato server mediante materiale casuale di **32 byte**. Nel database viene conservato esclusivamente l'hash **SHA-256** del token. Il token in chiaro non deve essere persistito né esposto in log, interfaccia, URL o storage persistente.

Il protocollo utilizza:

- heartbeat ogni **30 secondi**;
- lease del lock pari a **2 minuti**;
- richiesta di takeover valida per **10 minuti**;
- grant di takeover valido per **60 secondi**;
- silenziamento delle nuove richieste di takeover impostabile a **5, 15 o 30 minuti**;
- orologio PostgreSQL come unica autorità temporale.

Le operazioni sensibili sono esposte mediante RPC server-side controllate. Le RPC utilizzano, quando necessario, `SECURITY DEFINER`, `search_path = ''`, privilegi `EXECUTE` espliciti e `PUBLIC EXECUTE` revocato.

Il protocollo completo comprende:

- `acquire_profile_edit_lock`;
- `heartbeat_profile_edit_lock`;
- `release_profile_edit_lock`;
- `request_profile_edit_takeover`;
- `cancel_profile_edit_takeover`;
- `reject_profile_edit_takeover`;
- `grant_profile_edit_takeover`;
- `complete_profile_edit_takeover`;
- `get_profile_edit_lock_state`.

### Hardening della concorrenza

La Sessione S021 ha completato l'hardening del protocollo mediante un audit incrociato dell'intero percorso:

```text
acquire → heartbeat → release → request takeover → cancel → reject → grant → complete → get_state
```

Le operazioni che modificano lo stato di un lock esistente utilizzano `FOR UPDATE` nei punti necessari alla serializzazione concorrente.

Dopo l'eventuale attesa sul row lock, le verifiche autoritative vengono rivalidate utilizzando il tempo server-side aggiornato. Nei punti interessati viene utilizzato `clock_timestamp()` dopo l'attesa, evitando che una decisione temporale venga presa sulla base di un valore acquisito prima della serializzazione.

`heartbeat_profile_edit_lock` rivalida holder, client, sessione, token e lease dopo l'acquisizione del row lock. Un lock già scaduto non può essere resuscitato mediante heartbeat.

`release_profile_edit_lock` segue lo stesso principio di rivalidazione. Se è presente un grant di takeover ancora valido, il rilascio non cancella il lock ma restituisce `transfer_pending`, preservando il trasferimento in corso. Se il grant è scaduto, il rilascio può procedere normalmente.

`grant_profile_edit_takeover` protegge il lease del lock durante l'handoff mediante:

```text
expires_at =
    greatest(
        pel.expires_at,
        server_now + interval '60 seconds'
    )
```

In questo modo il lock non può scadere o essere riciclato da `acquire_profile_edit_lock` mentre il grant valido è ancora protetto.

Il grant non modifica `heartbeat_at` e non accorcia un lease già superiore a 60 secondi.

`get_profile_edit_lock_state` attribuisce precedenza a un grant valido rispetto allo stato ordinario dell'holder. Se il grant è destinato alla sessione chiamante viene restituito `transfer_granted_to_me`; se è destinato a un'altra sessione viene restituito `transfer_pending`.

`complete_profile_edit_takeover` esegue il trasferimento in modo atomico, assegnando il nuovo holder, client e sessione, generando un nuovo token server-side, azzerando lo stato del takeover e creando il nuovo lease. Il vecchio token non sopravvive al trasferimento.

Le operazioni concorrenti devono mantenere un comportamento conservativo e fail-closed. Un retry non deve duplicare transizioni di stato né prolungare impropriamente i timer.

In caso di risposta persa durante `acquire` o `complete_profile_edit_takeover`, il V1 non introduce un meccanismo speciale di recovery: si attende la naturale scadenza del lease, fino a **2 minuti**, quindi si procede con una nuova acquisizione.

### Verifiche e audit

La Sessione S021 ha verificato con test SQL mirati le principali transizioni concorrenti del protocollo.

Sono stati verificati, tra gli altri, i seguenti scenari:

- `cancel_profile_edit_takeover` valido → `cancelled`, campi della richiesta azzerati e `row_version` incrementata;
- concorrenza su `cancel` → comportamento conservativo senza modifica indebita dello stato;
- `reject_profile_edit_takeover` valido → `rejected`, richiesta azzerata e silenziamento applicato;
- concorrenza su `reject` → `not_holder`, con stato preservato;
- `grant_profile_edit_takeover` valido → `granted`, con conversione corretta della richiesta in grant;
- concorrenza su `grant` → nessuna modifica indebita;
- `complete_profile_edit_takeover` valido → `completed`, con nuovo token, nuovo holder e nuovo lease;
- grant scaduto → `grant_expired`, senza trasferimento;
- `release_profile_edit_lock` normale → `released` e riga eliminata;
- release durante grant valido → `transfer_pending`, con riga e grant preservati;
- release dopo grant scaduto → `released`;
- grant con lease residuo di 15 secondi → lease portato a 60 secondi;
- grant con lease residuo di 120 secondi → lease conservato a 120 secondi.

Dopo le correzioni introdotte durante l'hardening è stato eseguito un nuovo audit incrociato dell'intero protocollo concorrente.

L'audit non ha individuato ulteriori problemi bloccanti. Il protocollo `profile_edit_lock` e takeover è pertanto considerato architetturalmente coerente allo stato attuale.

Non vengono introdotti ulteriori meccanismi di complessità, quali advisory lock, retry loop, nuovi stati o nuove RPC, in assenza di un problema concreto che ne giustifichi l'introduzione.

### Integrazione applicativa della Profile Write Authority

La Sessione S023 ha integrato il protocollo server-side nel ciclo applicativo Flutter senza trasferire al client alcuna autorità definitiva.

Vengono mantenute distinte:

- identità autenticata dell’utente;
- identità tecnica stabile del client;
- identità della sessione applicativa;
- contesto Profile;
- token temporaneo del lease.

L’identità stabile del client viene conservata localmente. A ogni avvio viene invece generata una nuova identità della sessione applicativa.

Una nuova sessione non eredita automaticamente il lease ottenuto da una sessione precedente. Il token del lease non viene conservato nello storage persistente dell’identità tecnica.

Il ciclo applicativo coordina:

- risoluzione del contesto Profile ed esposizione tramite `ProfileContextScope`;
- rilascio conservativo delle acquisizioni obsolete riferite allo stesso client;
- acquisizione del lease;
- heartbeat;
- scadenza e perdita dell’autorità;
- rilascio;
- aggiornamento dello stato applicativo.

`ProfileWriteAuthorityController` e `WriteAuthorityScheduler` coordinano il ciclo del lease utilizzando i tempi autoritativi restituiti dal database.

`ProfileSessionGate` impedisce l’ingresso nel ciclo applicativo protetto finché non sono disponibili identità, contesto Profile e stato iniziale della Write Authority coerenti.

`ProfileWriteAuthorityScope` espone alle componenti discendenti lo stato della Write Authority senza consentire alle pagine di gestire direttamente il token.

`ProfileContextScope`, introdotto nella Sessione S024, espone alle componenti discendenti il contesto Profile già risolto, evitando che le singole pagine debbano ricostruirlo o riceverlo attraverso passaggi manuali non uniformi.

In assenza di un lease valido, le scritture protette vengono bloccate localmente secondo un comportamento fail-closed.

Il gate e il controllo locale costituiscono esclusivamente un preflight preventivo. Autenticazione, autorizzazione, validità del lease, token, stato del takeover, controllo della versione e invarianti rimangono verificati autoritativamente dalle RPC server-side.

### Confine con il Write Path autoritativo

La protezione concorrente di `profile_edit_locks` costituisce il fondamento tecnico del Write Path autoritativo delle entità di Categoria A, ma non implica che tutte le entità strutturali del Database V1 siano già protette da un Write Path autoritativo completo.

Nella Sessione S022 questo modello è stato applicato per la prima volta a `gardens`. Nella Sessione S023 è stato rafforzato il controllo concorrente di `update_garden` ed è stato applicato il Write Path autoritativo a `seasons`. Nella Sessione S024 il modello è stato esteso a `beds` e alla relativa geometria storicizzata.

Per `gardens`, `seasons` e `beds`, le operazioni protette verificano lato server, secondo il contratto specifico dell’entità:

- Profile Write Authority valida;
- identità autenticata e ownership attiva del Profile;
- client e sessione;
- token valido;
- lease valido;
- stato del takeover compatibile con la scrittura;
- validazione degli input;
- appartenenza del Garden al Profile autorizzato e, per `seasons`, appartenenza della stagione al Garden autorizzato;
- controllo della versione mediante `row_version` quando previsto;
- invarianti specifiche dell’entità.

Per `gardens` sono disponibili:

- `create_garden`;
- `update_garden`.

`update_garden` richiede `expected_row_version`. La versione attesa viene verificata rispetto allo stato corrente e nella condizione dell’aggiornamento finale. Una modifica costruita su una versione obsoleta viene rifiutata con `version_conflict`.

Per `seasons` sono disponibili:

- `create_season`;
- `update_season`;
- `activate_season`.

La creazione produce sempre una stagione inizialmente inattiva. `update_season` non consente di modificare direttamente `garden_id` o `is_active` e applica la concorrenza ottimistica mediante `expected_row_version`.

L’attivazione viene eseguita esclusivamente mediante `activate_season`, che attiva la stagione target e disattiva atomicamente l’eventuale stagione precedentemente attiva nello stesso Garden.

Per `beds` sono disponibili:

- `create_bed`;
- `update_bed`;
- `set_bed_active`;
- `change_bed_geometry`;
- `correct_bed_geometry`.

`create_bed` crea atomicamente l’identità stabile dell’aiuola e la geometria iniziale. Le operazioni di aggiornamento e variazione dello stato applicano la concorrenza ottimistica mediante `expected_row_version`.

`change_bed_geometry` rappresenta una variazione fisica ordinaria: chiude l’intervallo precedente e crea una nuova geometria. `correct_bed_geometry` rappresenta invece la rettifica di un dato storico errato e registra separatamente lo stato precedente e quello successivo in `bed_geometry_corrections`.

Gli intervalli di `bed_geometries` non possono sovrapporsi per la stessa aiuola.

Le scritture dirette da parte di `authenticated` sono revocate sulle entità protette `public.gardens`, `public.seasons`, `public.beds`, `public.bed_geometries` e `public.bed_geometry_corrections`, secondo il contratto specifico delle rispettive tabelle.

Il preflight eseguito dal client non costituisce una protezione sufficiente e non sostituisce le verifiche autoritative server-side.

I Write Path di `gardens`, `seasons` e `beds` sono considerati completati e coerenti allo stato attuale. Le ulteriori entità di Categoria A dovranno essere protette progressivamente mediante RPC autoritative definite secondo il contratto specifico di ciascuna entità.

### Motivazione

La scelta di governare il coordinamento del writer lato server riduce il rischio che due dispositivi operanti sullo stesso Profile possano modificare contemporaneamente lo stesso stato senza una serializzazione affidabile.

La separazione tra autenticazione, autorizzazione, lock e Write Path consente di mantenere distinti i diversi livelli di sicurezza del sistema:

- autenticazione dell'identità;
- autorizzazione dell'operazione;
- coordinamento della concorrenza;
- verifica delle versioni;
- applicazione atomica delle modifiche.

L'utilizzo del database come autorità per tempo, stato e transizioni evita che il client possa determinare autonomamente la validità del proprio lock o di un takeover.

L'impiego di `FOR UPDATE` e la rivalidazione dopo l'attesa sul row lock riducono il rischio di race condition tra operazioni concorrenti.

La scelta di mantenere il protocollo semplice e fail-closed evita di introdurre meccanismi di sincronizzazione aggiuntivi prima che emerga una necessità concreta.

Il protocollo costituisce inoltre la base controllata per il Write Path autoritativo delle entità di Categoria A. La Sessione S022 ha dimostrato l’applicazione concreta di questo modello mediante il Write Path di `gardens`; la Sessione S023 ne ha rafforzato il controllo concorrente e ha applicato lo stesso modello a `seasons`; la Sessione S024 lo ha esteso a `beds`, mantenendo separati identità stabile, geometria storicizzata e correzioni tracciate. Le ulteriori entità saranno implementate progressivamente secondo il rispettivo contratto.

### Alternative valutate

Sono state considerate e scartate o rinviate le seguenti alternative:

- affidare il coordinamento della concorrenza esclusivamente al client;
- considerare `client_id` o `session_id` come elementi sufficienti per autenticare l'operazione;
- memorizzare il `lock_token` in chiaro nel database;
- utilizzare l'orologio del client come autorità temporale;
- introdurre un meccanismo di retry automatico lato server per tutte le transizioni;
- introdurre advisory lock PostgreSQL come ulteriore livello generale di sincronizzazione;
- introdurre nuovi stati o nuove RPC senza una necessità concreta;
- considerare il lock come sostituto di autenticazione, autorizzazione, RLS o controllo del Write Path;
- implementare immediatamente il Write Path autoritativo di tutte le entità del Database V1 insieme al protocollo del lock.

Le alternative sono state escluse o rinviate perché avrebbero aumentato la complessità, indebolito la separazione delle responsabilità o anticipato funzionalità non ancora necessarie.

Il Write Path delle ulteriori entità di Categoria A rimane pertanto un blocco tecnico distinto, da implementare progressivamente applicando il protocollo del lock e le verifiche server-side previste per ciascuna entità.

### Conseguenze

- `profile_edit_locks` rimane una struttura tecnica separata dalle 52 entità di dominio del Database V1.
- Il V1 dispone di un protocollo server-side completo per acquisizione, mantenimento, rilascio e takeover del lock.
- Il coordinamento della concorrenza viene governato dal database e non dal solo client.
- Il token del lock non viene conservato in chiaro.
- Il tempo PostgreSQL costituisce l'autorità temporale del protocollo.
- Le transizioni concorrenti vengono serializzate nei punti necessari mediante locking della riga e rivalidazione post-lock.
- Il protocollo mantiene un comportamento conservativo e fail-closed.
- Il modello single-writer per Profile rimane invariato.
- L’identità tecnica stabile del client rimane distinta dall’identità della sessione applicativa.
- Una nuova sessione applicativa non eredita automaticamente il lease di una sessione precedente.
- Le pagine non gestiscono direttamente il token del lease.
- Il blocco locale fail-closed delle scritture costituisce un controllo preventivo e non sostituisce le verifiche server-side.
- Il protocollo del lock non sostituisce autenticazione, autorizzazione, RLS o invarianti del database.
- Il protocollo del lock costituisce il fondamento del Write Path autoritativo di Categoria A, ma non implica il completamento dei Write Path di tutte le entità di Categoria A.
- `gardens`, `seasons` e `beds` dispongono di Write Path autoritativi di Categoria A completati e coerenti allo stato attuale; le ulteriori entità strutturali potranno essere considerate pienamente protette contro lost update solo dopo l’implementazione delle relative operazioni server-side autoritative con le verifiche previste dal contratto di ciascuna entità.
- L’identità stabile dell’aiuola rimane separata dalla geometria valida nel tempo.
- Il cambio ordinario della geometria rimane distinto dalla correzione storica tracciata.
- Gli intervalli geometrici della stessa aiuola non possono sovrapporsi.
- Non vengono introdotti nel V1 ulteriori meccanismi di concorrenza non giustificati da problemi concreti.
- Il protocollo costituisce la baseline tecnica per l'estensione progressiva del Write Path autoritativo alle ulteriori entità di Categoria A.

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
| DEC-011 | 16/08/2026 | S017     | Baseline architetturale del Database V1                                               | Approvata |
| DEC-012 | 01/09/2026 | S020–S024 | Sicurezza e gestione concorrente del `profile_edit_locks` e fondamento del Write Path autoritativo di Categoria A | Approvata |

---

# 5. Considerazioni finali

Il presente documento raccoglie le principali decisioni architetturali che hanno guidato l'evoluzione di Orto Smart, documentandone il contesto, le motivazioni e le conseguenze sull'architettura del progetto.

La registrazione delle decisioni architetturali consente di preservare la conoscenza tecnica maturata durante lo sviluppo, favorendo la comprensione delle scelte progettuali e garantendo continuità nell'evoluzione del software.

Ogni nuova decisione che comporti modifiche significative all'architettura dovrà essere documentata nel presente documento, mantenendolo costantemente allineato con il Manuale Tecnico (DOC-001), il Quaderno di Sviluppo (DOC-005) e gli altri documenti ufficiali del progetto.

Il documento Decisioni Architetturali costituisce pertanto il riferimento ufficiale per la tracciabilità delle principali scelte progettuali adottate nello sviluppo di Orto Smart e rappresenta uno strumento fondamentale per garantirne la coerenza, la manutenibilità e l'evoluzione nel tempo.