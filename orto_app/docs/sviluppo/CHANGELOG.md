# ORTO SMART

### CHANGELOG

# Registro delle modifiche

**Versione:** 2.1
**Stato:** Approvato

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026
**Ultimo aggiornamento:** 28/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo                | Valore                   |
| -------------------- | ------------------------ |
| Documento            | CHANGELOG                |
| Titolo               | Registro delle modifiche |
| Versione             | 2.1                      |
| Stato                | Approvato                |
| Progetto             | Orto Smart               |
| Repository           | ortosmart/orto-smart     |
| Prima emissione      | 27/07/2026               |
| Ultimo aggiornamento | 28/08/2026               |

---

# Cronologia delle revisioni

| Versione | Data       | Descrizione                                                                                                               |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------- |
| 0.1      | 27/07/2026 | Prima emissione del documento CHANGELOG                                                                                   |
| 0.2      | 01/08/2026 | Revisione della struttura documentale e allineamento con la documentazione tecnica                                        |
| 1.0      | 01/08/2026 | Revisione completa e approvazione del CHANGELOG                                                                           |
| 1.1      | 08/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.4-alpha e introduzione di DecisionWeights                                 |
| 1.2      | 09/08/2026 | Aggiornamento del CHANGELOG con la prima implementazione del FamilyNeedsEngine                                            |
| 1.3      | 09/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.6-alpha e integrazione del FamilyNeedsEngine nella RecommendationPipeline |
| 1.4      | 10/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.7-alpha e introduzione dei fabbisogni quantitativi e dei lotti pianificati |
| 1.5      | 11/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.8-alpha e prima implementazione del SuccessionPlanningEngine               |
| 1.6      | 11/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.9-alpha e prima implementazione delle finestre agronomiche                 |
| 1.7      | 12/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.10-alpha e associazione delle finestre agronomiche a colture e varietà |
| 1.8      | 16/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.11-alpha e completamento della progettazione e del congelamento della baseline Database V1 nella Sessione S017 |
| 1.9      | 16/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.12-alpha: supporto alle finestre agronomiche multiple e predisposizione dell'ambiente Supabase locale per la futura implementazione della baseline Database V1 |
| 2.0      | 18/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.13-alpha: prima migration Database V1, implementazione e verifica locale delle Fondazioni, introduzione della prima sicurezza RLS e consolidamento del primo incremento fisico della baseline |
| 2.1      | 28/08/2026 | Aggiornamento del CHANGELOG con la versione 0.1.14-alpha: protocollo completo `profile_edit_locks`, Profile Write Authority, Write Path autoritativi di `gardens` e `seasons` e integrazione Flutter fail-closed |

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
3.6 Versione 0.1.5-alpha
3.7 Versione 0.1.6-alpha
3.8 Versione 0.1.7-alpha
3.9 Versione 0.1.8-alpha
3.10 Versione 0.1.9-alpha
3.11 Versione 0.1.10-alpha
3.12 Versione 0.1.11-alpha
3.13 Versione 0.1.12-alpha
3.14 Versione 0.1.13-alpha
3.15 Versione 0.1.14-alpha

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

## 3.6 Versione 0.1.5-alpha

**Data:** 09/08/2026

### Aggiunto

- Introdotto `FamilyCropNeed` come modello per rappresentare il fabbisogno familiare associato a una coltura.
- Introdotta l'enumerazione `FamilyNeedPriority` con i livelli `none`, `low`, `medium` e `high`.
- Implementata la prima versione funzionante del `FamilyNeedsEngine`.
- Introdotta la conversione delle priorità familiari nei valori numerici `0.0`, `0.3`, `0.6` e `1.0`.
- Aggiunte motivazioni testuali associate alle valutazioni del fabbisogno familiare.
- Aggiunti 6 test automatici dedicati al `FamilyNeedsEngine`.

### Modificato

- `FamilyRecommendation.cropId` modificato da `int` a `String` per uniformarlo al tipo utilizzato dall'architettura corrente per gli identificativi delle colture.
- Baseline dei test automatici portata da 78 a 84 test superati.

### Corretto

- Corretta l'incoerenza di tipo relativa a `FamilyRecommendation.cropId`.

### Architettura

- Mantenuto il `FamilyNeedsEngine` autonomo rispetto al `DecisionEngine` e alla `RecommendationPipeline`.
- Confermata la separazione tra valutazione del fabbisogno familiare e futura pianificazione quantitativa e temporale affidata al previsto `SuccessionPlanningEngine`.
- Rinviata alla S012 la progettazione dell'integrazione del fabbisogno familiare nel sistema complessivo di raccomandazione.

### Sicurezza

Nessuna modifica.

---

## 3.7 Versione 0.1.6-alpha

**Data:** 09/08/2026

### Aggiunto

- Integrato il `FamilyNeedsEngine` nella `RecommendationPipeline`.
- Aggiunto il parametro opzionale `familyNeeds` alla pipeline.
- Introdotta l'associazione tra `cropId` e priorità familiare.
- Introdotta la classificazione interna delle raccomandazioni in fasce agronomiche mediante `_ratingBand()`.
- Aggiunti 2 test automatici dedicati all'integrazione delle esigenze familiari nella `RecommendationPipeline`.

### Modificato

- Aggiornato l'ordinamento delle raccomandazioni secondo la gerarchia: fascia agronomica, priorità familiare e punteggio agronomico.
- La priorità familiare può modificare l'ordine delle raccomandazioni soltanto all'interno della stessa fascia agronomica.
- Baseline dei test automatici portata da 84 a 86 test superati.

### Architettura

- Mantenuto invariato il `DecisionEngine`, il cui punteggio continua a dipendere esclusivamente dai criteri agronomici.
- Mantenuta invariata la configurazione standard di `DecisionWeights`: 40% spazio, 30% rotazione e 30% consociazione.
- Esclusa l'introduzione del fabbisogno familiare come quarto peso del `DecisionEngine`.
- Definito il fabbisogno familiare come criterio gerarchico di ordinamento successivo alla fascia agronomica.
- Garantito che una priorità familiare elevata non possa rendere preferibile una raccomandazione appartenente a una fascia agronomica inferiore.

### Corretto

Nessuna correzione specifica.

### Sicurezza

Nessuna modifica.

---

## 3.8 Versione 0.1.7-alpha

**Data:** 10/08/2026

### Aggiunto

- Introdotto `PlannedPlantingBatch` come modello destinato a rappresentare un lotto di coltivazione pianificato nel tempo.
- Introdotto `PlannedPlantingBatchValidator` per la validazione dei dati necessari alla rappresentazione dei lotti pianificati.
- Introdotto `FamilyConsumptionNeed` come modello quantitativo, separato da `FamilyCropNeed`, per rappresentare il fabbisogno familiare nel tempo.
- Introdotti in `FamilyConsumptionNeed` i dati `cropId`, `quantity`, `unit` e `intervalDays`.
- Previste inizialmente le unità pezzi, grammi e chilogrammi.
- Introdotto `FamilyConsumptionNeedValidator` per la validazione dei fabbisogni quantitativi familiari.
- Aggiunti complessivamente 18 nuovi test automatici dedicati ai nuovi modelli e validator.

### Modificato

- Baseline dei test automatici portata da 86 a 104 test superati.
- Evoluta la rappresentazione delle esigenze familiari distinguendo la priorità qualitativa dal fabbisogno quantitativo e periodico.

### Architettura

- Mantenuta separata la responsabilità di `FamilyCropNeed`, dedicato alla priorità familiare, da quella di `FamilyConsumptionNeed`, dedicato alla quantità necessaria nel tempo.
- Definito `PlannedPlantingBatch` come futura unità operativa della pianificazione temporale delle coltivazioni.
- Predisposte le fondamenta dati e di validazione necessarie alla futura implementazione del `SuccessionPlanningEngine`.
- Individuate quattro modalità operative da contemplare nella futura pianificazione: acquisto di piantine e trapianto, semina in semenzaio seguita da trapianto, semina diretta a file e semina diretta a spaglio.
- Stabilito che la semina diretta a file dovrà essere pianificata considerando il numero di piante finali previste.
- Stabilito che la semina diretta a spaglio dovrà poter essere pianificata considerando l'area coltivata prevista.
- Mantenuta distinta la quantità di seme dalla produzione finale prevista.
- Rinviata alla S014 la prima implementazione deterministica e testabile del `SuccessionPlanningEngine`.

### Corretto

Nessuna correzione specifica.

### Sicurezza

Nessuna modifica.

---

## 3.9 Versione 0.1.8-alpha

**Data:** 11/08/2026

### Aggiunto

- Implementata la prima versione del `SuccessionPlanningEngine`.
- Introdotta la generazione deterministica di una sequenza temporale di `PlannedPlantingBatch` a partire da un `FamilyConsumptionNeed`.
- Aggiunta la validazione del `FamilyConsumptionNeed` mediante `FamilyConsumptionNeedValidator` prima della pianificazione.
- Aggiunta la validazione di ogni lotto generato mediante `PlannedPlantingBatchValidator`.
- Introdotto il supporto al `varietyId` opzionale nella pianificazione.
- Aggiunti 8 nuovi test automatici dedicati al `SuccessionPlanningEngine`.

### Modificato

- Baseline dei test automatici portata da 104 a 112 test superati.
- La pianificazione genera il primo lotto alla data iniziale e i lotti successivi secondo `intervalDays`.
- La generazione dei lotti viene limitata all'intervallo compreso tra `startDate` ed `endDate`.
- Il `cropId` viene propagato dal fabbisogno familiare ai lotti pianificati.
- Le combinazioni incoerenti tra metodo di avvio e tipo di quantità vengono rifiutate.

### Architettura

- Trasformato il `SuccessionPlanningEngine` da componente pianificato a prima versione operativa e testabile.
- Mantenuta separata la pianificazione temporale dalla futura verifica della compatibilità agronomica delle date.
- Stabilito che il `SuccessionPlanningEngine` non deve inventare conversioni tra fabbisogno familiare e quantità di impianto in assenza delle informazioni agronomiche necessarie.
- Ammessa nella V1 esclusivamente la conversione `pieces → plants`.
- Rifiutate conversioni non supportate, come `pieces → areaSquareCm` e `kilograms → plants`.
- Mantenuta distinta la quantità richiesta dalla famiglia dalla quantità di impianto quando la conversione richiede informazioni produttive o agronomiche non ancora disponibili.
- Predisposta l'evoluzione futura verso un sistema separato di verifica delle finestre agronomiche di semina e trapianto.

### Corretto

Nessuna correzione specifica.

### Sicurezza

Nessuna modifica.

---

## 3.10 Versione 0.1.9-alpha

**Data:** 11/08/2026

### Aggiunto

- Introdotto `AgronomicWindow` come modello per rappresentare una finestra agronomica annuale associata a uno specifico `PlannedPlantingStartMethod`.
- Introdotto `AgronomicWindowValidator` per la validazione strutturale delle finestre agronomiche.
- Introdotto `AgronomicWindowEngine` per la verifica della compatibilità temporale delle date pianificate.
- Aggiunto il supporto alle finestre che attraversano il cambio dell'anno.
- Aggiunta la verifica diretta della compatibilità di un `PlannedPlantingBatch` mediante metodo di avvio e data pianificata.
- Aggiunti complessivamente 19 nuovi test automatici dedicati a `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine`.

### Modificato

- Baseline dei test automatici portata da 112 a 131 test superati.
- La verifica della stagionalità viene mantenuta separata dalla generazione temporale dei lotti.
- Gli estremi iniziale e finale delle finestre agronomiche vengono considerati inclusivi.
- Il confronto stagionale utilizza mese e giorno e mantiene la finestra indipendente da uno specifico anno.

### Architettura

- Mantenuto invariato il `SuccessionPlanningEngine`, che continua a produrre date e lotti teorici.
- Separata formalmente la pianificazione temporale dalla verifica della compatibilità agronomica.
- Affidata ad `AgronomicWindowEngine` la responsabilità della verifica temporale delle finestre agronomiche.
- Stabilito che la compatibilità di un lotto richiede contemporaneamente la corrispondenza del `PlannedPlantingStartMethod` e l'appartenenza della `plannedDate` alla finestra agronomica.
- Mantenuta la stagionalità V1 separata dalle future correzioni climatiche e meteorologiche.
- Rinviata alla S016 l'associazione delle finestre agronomiche alle colture e alle varietà.
- Mantenuta l'architettura predisposta all'utilizzo futuro della localizzazione reale dell'orto, delle temperature, del rischio di gelo e dei dati meteorologici locali, senza introdurre una dipendenza rigida da classificazioni Nord/Centro/Sud.

### Corretto

Nessuna correzione specifica.

### Sicurezza

Nessuna modifica.

---

## 3.11 Versione 0.1.10-alpha

**Data:** 12/08/2026

### Aggiunto

- Introdotto `CropAgronomicWindowRule` per associare una `AgronomicWindow` a una coltura e, opzionalmente, a una specifica varietà.
- Introdotto `AgronomicWindowResolver` per selezionare la finestra agronomica applicabile in base a coltura, varietà e metodo di avvio.
- Introdotto `AgronomicWindowEvaluation` come risultato strutturato della valutazione stagionale.
- Introdotto `AgronomicWindowService` per coordinare `AgronomicWindowResolver` e `AgronomicWindowEngine`.
- Introdotto il fallback gerarchico tra regola specifica della varietà e regola generale della coltura.
- Introdotti gli stati `compatible`, `incompatible` e `unknown` per rappresentare distintamente gli esiti della valutazione.
- Aggiunto `resolveForBatch(...)` per risolvere direttamente la finestra applicabile a un `PlannedPlantingBatch`.
- Aggiunti complessivamente 18 nuovi test automatici dedicati ai componenti introdotti nella S016.

### Modificato

- Baseline dei test automatici portata da 131 a 149 test superati.
- Le finestre agronomiche introdotte nella S015 possono ora essere associate a colture e varietà.
- La regola specifica della varietà ha precedenza sulla regola generale della coltura.
- In assenza di una regola varietale applicabile viene utilizzata in fallback la regola generale della coltura.
- L'assenza di una regola applicabile viene distinta da una reale incompatibilità agronomica mediante lo stato `unknown`.

### Architettura

- Introdotto `CropAgronomicWindowRule` come livello di associazione tra dominio delle colture e finestre agronomiche.
- Separata la selezione della finestra dalla verifica della compatibilità temporale.
- Affidata ad `AgronomicWindowResolver` la responsabilità di determinare quale finestra applicare.
- Mantenuta in `AgronomicWindowEngine` la responsabilità della verifica temporale della finestra selezionata.
- Introdotto `AgronomicWindowService` come coordinatore applicativo privo di logica agronomica propria.
- Mantenuto invariato il `SuccessionPlanningEngine`, che continua a essere responsabile esclusivamente della generazione temporale dei lotti.
- Formalizzato il principio `unknown != incompatible`, evitando che l'assenza di conoscenza venga interpretata come giudizio agronomico negativo.
- Adottato il principio della regola generale della coltura con override varietale soltanto quando necessario, limitando la futura duplicazione dei dati.
- Rinviata alla S017 la progettazione della persistenza delle regole agronomiche in Supabase.
- Mantenute separate le future correzioni basate su clima, localizzazione, rischio di gelo e dati meteorologici reali.

### Corretto

Nessuna correzione specifica.

### Sicurezza

Nessuna modifica.

---

## 3.12 Versione 0.1.11-alpha

**Data:** 16/08/2026

### Aggiunto

- Definita e congelata la baseline logica e architetturale del Database V1.
- Definite **52 entità di dominio** previste per il Database V1.
- Prevista `profile_edit_locks` come struttura tecnica separata per il coordinamento delle modifiche concorrenti, non conteggiata tra le 52 entità di dominio.
- Definita `agronomic_window_rules` come struttura persistente delle regole agronomiche; `AgronomicWindow` rimane un risultato calcolato e non viene introdotta una tabella persistente `agronomic_windows`.
- Definito `irrigation_zone_target_assignments` come nome SQL definitivo per le assegnazioni dei target alle zone di irrigazione.
- Definite le strutture necessarie per ownership, relazioni, temporalità, storicizzazione, target polimorfi controllati e contesto ambientale.

### Modificato

- L'obiettivo iniziale della S017, limitato alla progettazione della persistenza delle regole agronomiche, è stato esteso alla progettazione completa del Database V1.
- La persistenza delle regole agronomiche è stata integrata nella baseline complessiva del Database V1.
- Definito un modello di accesso monoutente per Garden nel V1: un account/profilo principale può essere utilizzato dai componenti dello stesso nucleo familiare.
- Le persone che svolgono lavori nell'orto possono essere rappresentate mediante `workers` senza richiedere account applicativi distinti.
- La multiutenza con account distinti e la condivisione dello stesso Garden sono state rinviate a evoluzioni future.
- Definita una strategia di futura implementazione incrementale mediante migration SQL tracciabili e verificabili.

### Architettura

- Separata formalmente la baseline logica Database V1 dallo schema Supabase attualmente implementato.
- Stabilito che il completamento della progettazione S017 non equivale all'implementazione fisica delle 52 entità in Supabase.
- Confermata la separazione tra dati persistenti e risultati calcolabili dal dominio applicativo.
- Definita l'ownership applicativa con `profiles` come radice dell'accesso ai dati e `gardens` come principale aggregato operativo.
- Adottato un modello **single-writer** per coordinare le modifiche concorrenti.
- Definiti principi di temporalità e storicizzazione per preservare la ricostruibilità dello stato nel tempo.
- Definiti invarianti e vincoli di integrità da applicare progressivamente nello schema SQL.
- Confermato il principio di riduzione delle duplicazioni e di utilizzo efficiente dello storage.
- Confermato che i dati meteorologici grezzi storici non devono essere duplicati integralmente in Supabase; devono essere persistiti soltanto contesti, sintesi, collegamenti o informazioni utili al dominio.
- Congelata la baseline nominale Database V1 come riferimento per la successiva implementazione SQL/Supabase.

### Corretto

Nessuna correzione specifica.

### Sicurezza

- Definito un modello di sicurezza **deny-by-default** per il Database V1.
- Confermato l'utilizzo della Row Level Security come protezione lato database.
- Stabilito che autorizzazione e ownership non devono dipendere esclusivamente dal client Flutter.
- Previsto `profile_edit_locks` per supportare il coordinamento single-writer delle operazioni di modifica.
- Rinviata l'applicazione fisica delle nuove policy e dei nuovi vincoli alle migration incrementali del Database V1.

---

## 3.13 Versione 0.1.12-alpha

**Data:** 16/08/2026

### Aggiunto

- Introdotto il supporto esplicito a **più finestre agronomiche applicabili** per la stessa coltura, varietà e metodo di avvio.
- Esteso `AgronomicWindowEvaluation` con la distinzione tra `matchedWindow` ed `evaluatedWindows`.
- Predisposto l'ambiente locale necessario allo sviluppo e al test delle future migration Supabase mediante WSL 2, Ubuntu, Docker Desktop e Supabase CLI.
- Inizializzata mediante `supabase init` la struttura locale versionata:

```text
supabase/
├── .gitignore
├── config.toml
└── seed.sql
```

- Predisposto `supabase/seed.sql`, intenzionalmente vuoto in questa fase.

### Modificato

- `AgronomicWindowResolver` restituisce l'insieme delle finestre applicabili invece di una singola finestra.
- Il resolver applica la priorità alle finestre specifiche della varietà e utilizza le finestre generali della coltura soltanto come fallback.
- `AgronomicWindowService` valuta tutte le finestre applicabili.
- La valutazione è `compatible` quando almeno una finestra è valida, `incompatible` quando esistono finestre applicabili ma nessuna è valida e `unknown` quando non esistono finestre applicabili.
- Il precedente `database/database_v1.sql`, relativo allo schema sperimentale iniziale, è stato conservato come `database/database_legacy_initial.sql` per distinguerlo dalla nuova baseline Database V1.
- Verificata sul progetto Supabase remoto la versione `PostgreSQL 17.6`, coerente con `major_version = 17` della configurazione locale.

### Architettura

- Confermato il supporto multi-finestra come parte del dominio agronomico prima della relativa persistenza.
- Predisposta l'infrastruttura versionata per implementare progressivamente la baseline Database V1 mediante migration Supabase.
- Confermato che la baseline logica congelata nella S017 rimane il riferimento architetturale per la futura implementazione SQL.
- Stabilito come punto di ripartenza della S019 lo **STEP 35.3 – Costruzione baseline SQL Database V1**.
- La prima migration prevista è `database_v1_baseline`; al termine della S018 non è ancora stata creata.

### Test

- `dart format`: 6 file verificati, 0 modifiche necessarie.
- `flutter analyze`: nessun problema rilevato.
- Test mirati sulle modifiche alle finestre agronomiche: **18/18 passati**.
- Suite completa Flutter: **151/151 test passati**.

### Commit

- `93d6bf6` — `Supporta finestre agronomiche multiple`.
- `00190ea` — `Prepara ambiente Supabase locale`.

### Corretto

Nessuna correzione specifica separata dalle modifiche descritte sopra.

### Sicurezza

- Verificato prima del commit che `supabase/config.toml` non contenga password, token o chiavi reali versionate.
- I valori sensibili della configurazione Supabase rimangono riferimenti a variabili d'ambiente.
- Durante la S018 non è stata effettuata alcuna modifica al database Supabase remoto.

---

## 3.14 Versione 0.1.13-alpha

**Data:** 18/08/2026

### Aggiunto

- Creata la prima migration versionata della baseline Database V1:
  `supabase/migrations/20260817103916_database_v1_baseline.sql`.
- Implementato il primo blocco **Fondazioni** del Database V1, comprendente:
  - `profiles`;
  - `profile_memberships`;
  - `gardens`;
  - `workers`;
  - `seasons`;
  - `profile_edit_locks`.
- Introdotto lo schema PostgreSQL `private` per gli helper autorizzativi non destinati all'accesso diretto del client.
- Introdotti gli helper server-side necessari alla verifica di ownership e appartenenza ai Profile.
- Introdotti trigger per la gestione dei metadata previsti dalle Fondazioni.
- Introdotta la prima matrice di sicurezza composta da **13 policy RLS**.

### Modificato

- Il Database V1 è passato dalla sola baseline progettata e congelata al primo incremento fisicamente implementato e verificato nell'ambiente Supabase locale.
- L'implementazione della baseline procede ora incrementalmente per gruppi coerenti di strutture e dipendenze.
- Le Fondazioni costituiscono il primo gruppo dal quale dipenderanno numerose strutture successive del Database V1.
- Schema, vincoli, ownership e sicurezza vengono sviluppati e verificati congiuntamente invece di rinviare la sicurezza a una fase successiva.
- Le migration Supabase versionate costituiscono il riferimento riproducibile per l'evoluzione fisica del Database V1.

### Architettura

- Confermata la baseline Database V1 congelata nella S017 come riferimento architetturale dell'implementazione.
- Confermato l'approccio incrementale senza trasformazione monolitica dell'intero database.
- Consolidato il modello di ownership basato su `profiles`, `profile_memberships` e `gardens`.
- Predisposta `profile_edit_locks` come infrastruttura tecnica per il futuro modello single-writer per Profile.
- Confermato che il possesso del ruolo di writer non potrà essere determinato esclusivamente dal client.
- Definito come prossimo incremento tecnico il completamento delle operazioni server-side delle Fondazioni, comprese le RPC per lock, concorrenza, `row_version` e gestione amministrativa protetta delle membership.

### Test

- Verificata la migration mediante ricostruzione completa del database locale con `supabase db reset`.
- Verificata la corretta creazione delle strutture del blocco Fondazioni.
- Eseguiti test manuali positivi delle policy RLS per verificare le operazioni autorizzate.
- Eseguiti test manuali negativi delle policy RLS per verificare il rifiuto delle operazioni non autorizzate.
- Utilizzato un dump diagnostico locale temporaneo per controllare la struttura effettivamente generata; il file diagnostico è stato successivamente eliminato.

### Commit

- `f5cd6cf` — `Crea baseline Database V1 e sicurezza RLS`.

### Corretto

Nessuna correzione specifica separata dalle modifiche descritte sopra.

### Sicurezza

- Abilitata la Row Level Security sulle strutture esposte del primo incremento secondo il modello previsto.
- Introdotte **13 policy RLS** come prima matrice di sicurezza del Database V1.
- Verificate sia operazioni autorizzate sia operazioni che devono essere rifiutate.
- Confermato il principio **deny-by-default** per l'evoluzione progressiva della sicurezza.
- Confermato che `profile_edit_locks` non dovrà essere direttamente manipolabile dal client per attribuirsi arbitrariamente il ruolo di writer.
- Le future RPC sensibili dovranno applicare autenticazione, ownership, eventuale lock, invarianti e atomicità lato server.

---

## 3.15 Versione 0.1.14-alpha

**Data:** 28/08/2026

### Aggiunto

- Completato il protocollo server-side `profile_edit_locks` per il coordinamento single-writer del Profile.
- Introdotte le RPC per acquisizione, heartbeat, rilascio, richiesta, annullamento, rifiuto, concessione e completamento del takeover e lettura dello stato del lock.
- Introdotta la Profile Write Authority come prerequisito server-side delle scritture protette.
- Implementato il Write Path autoritativo di `gardens` mediante `create_garden` e `update_garden`.
- Implementato il Write Path autoritativo di `seasons` mediante `create_season`, `update_season` e `activate_season`.
- Introdotta l’identità tecnica stabile del client, distinta dall’identità della sessione applicativa.
- Introdotti `ProfileContext` e `ProfileContextRepository`.
- Introdotti `ProfileEditLockRepository`, `ProfileWriteAuthorityController` e `WriteAuthorityScheduler`.
- Introdotti `ProfileWriteAuthorityScope` e `ProfileSessionGate`.
- Integrato il ciclo della sessione Profile nell’avvio dell’applicazione Flutter.
- Integrato `SeasonRepository` con risultati Dart tipizzati per le RPC autoritative.

### Modificato

- Rafforzato `update_garden` mediante `expected_row_version` e rifiuto `version_conflict` delle modifiche costruite su dati obsoleti.
- Esteso il modello `Season` con `rowVersion`.
- Centralizzate nelle RPC autoritative le scritture applicative su `gardens` e `seasons`.
- Separata l’identità persistente del client dall’identità temporanea della sessione applicativa.
- Impedita l’eredità automatica di un lease da parte di una nuova sessione.
- Introdotto il rilascio conservativo delle acquisizioni obsolete riferite allo stesso client.
- Bloccate localmente le scritture protette quando non è disponibile un lease valido.
- Mantenuto il controllo locale come preflight preventivo, senza sostituire le verifiche server-side.

### Architettura

- Consolidato il database PostgreSQL come autorità definitiva per identità, autorizzazione, tempo, lock, takeover, controllo versione e invarianti.
- Confermata la separazione tra autenticazione, autorizzazione, Profile Write Authority e Write Path dell’entità.
- Applicata la concorrenza ottimistica mediante `row_version` ai Write Path protetti di `gardens` e `seasons`.
- Stabilito che la creazione di una stagione produce sempre uno stato inizialmente inattivo.
- Reso immutabile `garden_id` nel Write Path di aggiornamento delle stagioni.
- Riservata la modifica di `is_active` alla sola RPC `activate_season`.
- Garantite nella stessa transazione l’attivazione della stagione target e la disattivazione dell’eventuale stagione precedentemente attiva.
- Definito come blocco tecnico successivo l’implementazione coordinata di `beds` e `bed_geometries`.

### Test

- `flutter analyze`: nessun problema rilevato.
- Suite completa Flutter: **237/237 test superati**.
- Test dedicati a `SeasonRepository`: **28/28 superati**.
- Verificati casi positivi, negativi, conflitti di versione, assenza del lease e payload RPC sconosciuti, incompleti o incoerenti.
- Verificato il comportamento fail-closed dell’infrastruttura applicativa della Profile Write Authority.

### Sicurezza

- Revocati ad `authenticated` i privilegi diretti `INSERT`, `UPDATE` e `DELETE` su `public.gardens` e `public.seasons`.
- Mantenuto `PUBLIC EXECUTE` revocato per le RPC sensibili.
- Applicati `SECURITY DEFINER`, `search_path = ''` e privilegi `EXECUTE` espliciti secondo il contratto delle funzioni.
- Conservato nel database esclusivamente l’hash SHA-256 del token del lock.
- Impedita alle pagine Flutter la gestione diretta del token del lease.
- Confermato che il gate Flutter non sostituisce autenticazione, autorizzazione, RLS, validità del lock, controllo di versione o invarianti server-side.

---

# 4. Cronologia versioni

| Versione    | Data       | Stato      | Note                                                                                                                                                              |
| ----------- | ---------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.1.0-alpha | 27/07/2026 | Archiviata | Prima versione documentata del progetto.                                                                                                                          |
| 0.1.1-alpha | 27/07/2026 | Archiviata | Introdotto il Companion Engine e consolidata l'architettura del motore agronomico.                                                                                |
| 0.1.2-alpha | 28/07/2026 | Archiviata | Introdotto `BedAnalysisService`, implementato `BedCompanionAnalyzer` e consolidata l'architettura delle analisi agronomiche.                                      |
| 0.1.3-alpha | 06/08/2026 | Archiviata | Introdotta `RecommendationPipeline` come orchestratore del processo di raccomandazione e consolidata la nuova architettura del Motore Agronomico.                 |
| 0.1.4-alpha | 08/08/2026 | Archiviata | Introdotto `DecisionWeights` e resa configurabile la ponderazione dei criteri utilizzati dal `DecisionEngine`.                                                    |
| 0.1.5-alpha | 09/08/2026 | Archiviata | Implementata la prima versione del `FamilyNeedsEngine` per la valutazione delle priorità e dei fabbisogni familiari.                                              |
| 0.1.6-alpha | 09/08/2026 | Archiviata | Integrato il `FamilyNeedsEngine` nella `RecommendationPipeline` mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| 0.1.7-alpha | 10/08/2026 | Archiviata | Introdotti fabbisogni familiari quantitativi e lotti di coltivazione pianificati come fondamenta del futuro `SuccessionPlanningEngine`. |
| 0.1.8-alpha | 11/08/2026 | Archiviata   | Implementata la prima versione del `SuccessionPlanningEngine` per generare una sequenza temporale validata di lotti pianificati a partire dal fabbisogno familiare quantitativo e periodico. |
| 0.1.9-alpha | 11/08/2026 | Archiviata   | Introdotte le finestre agronomiche mediante `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine`, mantenendo separata la compatibilità agronomica dalla pianificazione temporale del `SuccessionPlanningEngine`. |
| 0.1.10-alpha | 12/08/2026 | Archiviata | Associate le finestre agronomiche a colture e varietà mediante `CropAgronomicWindowRule`, `AgronomicWindowResolver`, `AgronomicWindowEvaluation` e `AgronomicWindowService`, introducendo il fallback varietà → coltura e la distinzione tra `unknown` e `incompatible`. |
| 0.1.11-alpha | 16/08/2026 | Archiviata | Completata e congelata nella S017 la progettazione della baseline Database V1: 52 entità di dominio più la struttura tecnica `profile_edit_locks`, con ownership, accesso familiare monoutente, modello single-writer, temporalità, sicurezza, invarianti e strategia di implementazione incrementale in Supabase. |
| 0.1.12-alpha | 16/08/2026 | Archiviata | Introdotto il supporto alle finestre agronomiche multiple e predisposto l'ambiente Supabase locale versionato per la futura implementazione incrementale della baseline Database V1; verificati 151/151 test e mantenuto invariato il database remoto. |
| 0.1.13-alpha | 18/08/2026 | Archiviata | Creata la prima migration Database V1 e implementato e verificato localmente il blocco Fondazioni con schema `private`, helper autorizzativi, trigger metadata e 13 policy RLS; consolidato il primo incremento fisico della baseline Database V1. |
| 0.1.14-alpha | 28/08/2026 | Corrente | Completato il protocollo `profile_edit_locks`, introdotta la Profile Write Authority, implementati i Write Path autoritativi di `gardens` e `seasons`, integrata la sessione Profile nel client Flutter e verificati 237/237 test. |

---

# 5. Considerazioni finali

Il presente CHANGELOG documenta in modo sintetico l'evoluzione di Orto Smart, registrando le modifiche più significative introdotte nelle diverse versioni del software.

La separazione tra CHANGELOG, Quaderno di Sviluppo (DOC-005) e Manuale Tecnico (DOC-001) consente di distinguere chiaramente la cronologia delle versioni, il dettaglio delle attività di sviluppo e l'architettura del progetto, mantenendo la documentazione ordinata e facilmente consultabile.

Il CHANGELOG deve essere aggiornato ad ogni rilascio di una nuova versione significativa dell'applicazione, garantendo la tracciabilità delle principali evoluzioni del software e mantenendo la coerenza con gli altri documenti ufficiali del progetto.