
# ORTO SMART

### DOC-009

# Workflow Operativo

**Versione:** 2.5
**Stato:** Approvato

**Autore:** Renzo Siega  
**Progetto:** Orto Smart

**Data prima emissione:** 28/07/2026
**Ultimo aggiornamento:** 17/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-009 |
| Titolo | Workflow Operativo |
| Versione | 2.5 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 28/07/2026 |
| Ultimo aggiornamento | 17/10/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 1.0 | 28/07/2026 | Prima emissione del Workflow Operativo |
| 2.0 | 29/07/2026 | Revisione completa del documento, definizione del metodo di sviluppo ufficiale, integrazione della Checklist Operativa e del Diagramma del Workflow |
| 2.1 | 04/08/2026 | Uniformazione allo Standard Documentale e revisione del documento |
| 2.2 | 08/08/2026 | Consolidamento del Workflow Operativo, introduzione della verifica incrociata, gestione dei tempi effettivi, revisione della sequenza Git e completamento degli allegati operativi |
| 2.3 | 03/09/2026 | Manutenzione straordinaria del Workflow Operativo: correzione della data di prima emissione sulla base della prima registrazione verificata nella cronologia Git |
| 2.4 | 13/10/2026 | Formalizzazione della separazione tra sviluppo e Manuali, dell'avvio dichiarato della fase documentale e del protocollo di passaggio e ricezione tra conversazioni; aggiornamento della Fase 6, della checklist e del diagramma operativo |
| 2.5 | 17/10/2026 | Formalizzazione della procedura controllata di compilazione e revisione documentale tramite PowerShell, con approvazione preventiva, verifiche, backup e protezione dalle sostituzioni ambigue |

---

# Indice

## 1. Scopo del documento

## 2. Campo di applicazione

## 3. Principi del Workflow

## 4. Flusso Operativo della Sessione

## 5. Controlli di Qualità

## 6. Gestione della Documentazione

## 7. Versionamento del Software

## 8. Criteri di chiusura della Sessione

## 9. Checklist Operativa

## 10. Considerazioni finali

### Allegato A – Checklist Workflow Operativo

### Allegato B – Diagramma del Workflow

### Allegato C – Matrice della Documentazione

### Allegato D – Criteri di Chiusura della Sessione

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

Ogni sessione deve prevedere verifiche progressive adeguate alla natura delle attività svolte.

Quando la sessione comprende modifiche al software, le verifiche possono comprendere, quando applicabili:

- `dart format`;
- `flutter analyze`;
- `flutter test`;
- test manuali.

Nelle sessioni esclusivamente documentali o prive di modifiche al software devono essere eseguite le verifiche pertinenti alle attività effettivamente svolte.

---

## 3.5 Documentazione come parte dello sviluppo

La documentazione è parte integrante del software.

Ogni modifica significativa deve essere accompagnata dal relativo aggiornamento documentale.

---

## 3.6 Tracciabilità

Ogni attività deve poter essere ricostruita attraverso:

- Git;
- documentazione;
- registro delle sessioni;
- decisioni architetturali.

---

## 3.7 Sessione completata

Una sessione di sviluppo può essere considerata conclusa esclusivamente quando risultano soddisfatti tutti i criteri di chiusura definiti nel presente Workflow Operativo.

La verifica operativa delle condizioni di chiusura è descritta nel capitolo **8 – Criteri di chiusura della Sessione**.

La chiusura della fase tecnica di sviluppo e il completamento documentale sono eventi distinti, anche quando appartengono alla stessa sessione progettuale.

---

## 3.8 Separazione tra sviluppo e documentazione

Le attività di sviluppo e quelle di aggiornamento dei Manuali costituiscono fasi operative distinte.

Possono essere svolte in conversazioni separate, mantenendo un riferimento comune alla sessione progettuale e garantendo la continuità delle informazioni.

La conclusione della fase sviluppo non determina automaticamente l'avvio della fase Manuali.

La fase Manuali inizia esclusivamente quando viene dichiarato esplicitamente il suo avvio, con il relativo orario.

Devono essere rispettati i seguenti principi:

- separazione delle attività tecniche e documentali;
- registrazione distinta dei rispettivi intervalli di lavoro;
- esclusione delle pause dai tempi netti;
- consolidamento del tempo di sviluppo alla conclusione della relativa fase;
- consolidamento del tempo documentale alla chiusura dichiarata dei Manuali;
- verifica incrociata prima della chiusura documentale definitiva.

La documentazione deve rappresentare lo stato tecnico effettivamente raggiunto e verificato, senza trasformare ipotesi, proiezioni esplorative o attività FUTURE in risultati già acquisiti.

---

## 3.9 Continuità operativa tra conversazioni

Il passaggio a una nuova conversazione non determina automaticamente la conclusione della sessione corrente né l'apertura di una nuova sessione.

Il cambio di conversazione e il cambio di sessione sono eventi distinti.

Quando il lavoro prosegue in una nuova conversazione, deve essere predisposto un **CHECKPOINT DI PASSAGGIO CHAT**.

Il checkpoint deve riportare, per quanto applicabile:

- identificazione della sessione e stato delle attività;
- ultimo punto effettivamente completato;
- modifiche effettuate;
- decisioni APPROVATE;
- questioni APERTE;
- elementi FUTURE o scartati;
- stato di codice, database e documentazione;
- commit, versioni e verifiche conosciute;
- tempi di lavoro e sospensioni;
- eventuali file modificati non ancora committati;
- prossimo passo operativo;
- controlli necessari alla ripresa.

Nella nuova conversazione, prima di effettuare modifiche al progetto, deve essere eseguito un **CHECKPOINT DI RICEZIONE**.

Il checkpoint di ricezione deve confrontare le informazioni trasferite con le fonti ufficiali disponibili, verificare lo stato effettivo del progetto e risolvere eventuali discrepanze prima di dichiarare verificato il passaggio.

Le informazioni contenute nel checkpoint precedente non devono essere considerate automaticamente confermate.

Il protocollo si applica, quando pertinente, sia alle conversazioni di sviluppo sia a quelle dedicate ai Manuali.

---

# 4. Flusso Operativo della Sessione

Ogni sessione di sviluppo deve seguire il seguente flusso operativo.
Le fasi devono essere applicate in funzione della natura delle attività svolte nella sessione.

Nelle sessioni che non comportano modifiche al software, le fasi relative allo sviluppo del codice, ai controlli software, alla verifica funzionale e al commit del codice possono risultare non applicabili.

Le fasi non applicabili devono essere esplicitamente riconosciute come tali e non devono essere considerate attività mancanti ai fini della chiusura della sessione.

## Fase 1 – Pianificazione

**Obiettivo**

Preparare correttamente la sessione di sviluppo.

**Attività**

- Apertura del progetto.
- Rilettura del Workflow Operativo come promemoria prima dell'avvio delle attività.
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

## Fase 5 – Commit del codice

**Obiettivo**

Registrare nel repository locale il codice verificato prodotto durante la sessione, mantenendo separato il versionamento del codice dall'aggiornamento documentale.

**Attività**

- eseguire `git status`;
- verificare i file modificati;
- eseguire `git add` esclusivamente sui file interessati;
- eseguire un commit descrittivo del codice;
- verificare il commit mediante `git log`;
- verificare nuovamente lo stato del repository.

In questa fase **non viene ancora eseguito il push finale**.

Il push su GitHub viene effettuato soltanto dopo il completamento dell'aggiornamento documentale, della verifica incrociata e dei controlli finali previsti dal Workflow Operativo.

---


## Fase 6 – Documentazione

**Obiettivo**

Mantenere la documentazione allineata allo stato reale del progetto e verificare la coerenza delle informazioni registrate.

**Avvio della fase Manuali**

Quando le attività documentali sono gestite in una fase distinta dallo sviluppo, l'avvio dei Manuali deve essere dichiarato esplicitamente, registrandone la data e l'orario.

La chiusura della fase sviluppo non comporta automaticamente l'apertura della fase Manuali.

Le due fasi mantengono registrazioni temporali distinte, anche quando appartengono alla stessa sessione progettuale.

**Attività**

- individuare i documenti realmente interessati dalle modifiche della sessione;
- aggiornare un documento alla volta;
- procedere mediante modifiche piccole e verificabili;
- rileggere ogni documento aggiornato prima di considerarlo completato;
- eliminare eventuali duplicazioni o informazioni non più coerenti;
- verificare la corretta distinzione tra funzionalità implementate, attività pianificate e decisioni ancora da assumere;
- effettuare una verifica incrociata delle informazioni condivise tra i diversi documenti.

La scelta dei documenti da aggiornare deve essere effettuata in funzione della natura delle modifiche introdotte e nel rispetto dello **Standard Documentale (DOC-000)**.

Tra i documenti che possono richiedere aggiornamento rientrano, a titolo esemplificativo:

- Manuale Tecnico (DOC-001);
- Quaderno di Sviluppo (DOC-005);
- Linee Guida di Sviluppo (DOC-006);
- Roadmap di Sviluppo (DOC-008);
- Workflow Operativo (DOC-009), quando il metodo di lavoro viene modificato;
- Decisioni Architetturali (DOC-011), quando vengono assunte nuove decisioni progettuali;
- Registro Storico dello Sviluppo (DOC-012);
- CHANGELOG;
- VERSION.

### Procedura controllata di compilazione e revisione documentale

Le modifiche ai documenti ufficiali di Orto Smart devono essere eseguite esclusivamente mediante comandi PowerShell predisposti dall'assistente e preventivamente approvati dall'utente. Non sono ammesse modifiche mediante copia-incolla manuale nel documento.

Ogni intervento deve essere limitato al contenuto effettivamente interessato:

- per revisioni sostanziali è ammessa la sostituzione controllata di capitoli o sottocapitoli completi;
- per correzioni limitate si interviene esclusivamente sul paragrafo, sulla frase o sulle parole interessate;
- non devono essere riscritte parti del documento estranee alla modifica.

Prima dell'esecuzione, lo script deve verificare l'esistenza del documento, il contenuto atteso e l'univocità delle sostituzioni. In presenza di contenuti inattesi, riferimenti ambigui o controlli non superati, l'operazione deve interrompersi senza applicare modifiche.

Quando necessario, deve essere creato un backup preventivo, con nome univoco e senza sovrascrivere backup esistenti.

Le modifiche devono preservare la codifica del documento e le terminazioni di riga originali, evitando alterazioni involontarie.

Dopo l'intervento devono essere verificati il contenuto aggiornato, le differenze Git, la coerenza dei metadati e l'assenza di modifiche estranee.

Gli script devono essere predisposti in modo da evitare duplicazioni inutili del testo tra la conversazione e il codice PowerShell.

L'approvazione della modifica documentale non costituisce automaticamente autorizzazione al commit o al push, che richiedono i controlli previsti dal workflow Git.

### Verifica incrociata

Prima della chiusura della sessione devono essere confrontati, quando applicabile:

- numero e stato delle sessioni;
- versione corrente del software e dei documenti;
- tempi di sviluppo;
- tempi di documentazione;
- tempo complessivo del progetto;
- milestone;
- indicatori evolutivi;
- stato delle funzionalità;
- componenti software e motori agronomici;
- riferimenti Git;
- documenti ufficiali;
- prossimi obiettivi.

I dati non devono essere considerati corretti per presunzione.

**Prima si verifica, poi si conferma.**

In particolare, valori numerici, versioni, commit, numero dei test e altri dati verificabili devono essere confrontati con la relativa fonte prima di essere registrati come definitivi.

Eventuali incongruenze devono essere risolte prima di procedere alla chiusura della sessione.

---

## Fase 7 – Registrazione dei tempi

**Obiettivo**

Registrare in modo attendibile il tempo effettivamente dedicato alle attività del progetto.

**Attività**

- registrare l'orario di inizio della sessione;
- annotare l'inizio di eventuali pause o sospensioni;
- registrare l'orario di ogni ripresa;
- mantenere aggiornato il conteggio del tempo effettivo durante la sessione;
- calcolare il tempo effettivo sottraendo pause, sospensioni e periodi di inattività;
- distinguere, quando previsto, il tempo dedicato allo sviluppo dal tempo dedicato alla documentazione.

Il tempo registrato deve rappresentare esclusivamente il **tempo effettivo di lavoro**.

Le pause, le sospensioni e i periodi nei quali non vengono svolte attività sul progetto non devono essere conteggiati.

Il tempo dedicato alla documentazione comprende le attività effettive di stesura, aggiornamento, rilettura, revisione e verifica incrociata dei documenti.

I tempi consolidati della sessione devono essere riportati nei documenti previsti dal sistema documentale del progetto.
Ai fini della registrazione documentale, il tempo della sessione viene consolidato nella fase di chiusura immediatamente precedente al commit finale della documentazione.

Le successive operazioni tecniche strettamente necessarie alla chiusura, quali commit della documentazione, push, verifica della sincronizzazione e registrazione del checkpoint finale, vengono tracciate mediante l'orario effettivo di conclusione della sessione e non determinano la riapertura ciclica dei documenti già consolidati.

---

## Fase 8 – Chiusura della Sessione

**Obiettivo**

Concludere formalmente la sessione assicurando l'allineamento tra codice, documentazione, tempi registrati e repository.

**Attività**

- verificare che lo sviluppo previsto dalla sessione sia stato completato;
- verificare che tutti i controlli di qualità siano stati superati;
- completare l'aggiornamento della documentazione interessata;
- completare la verifica incrociata dei documenti;
- calcolare il tempo effettivo maturato fino alla fase di chiusura, al netto di pause, sospensioni e periodi di inattività;
- aggiornare i documenti storici con i tempi consolidati della sessione;
- eseguire `git status`;
- aggiungere allo staging esclusivamente i documenti interessati;
- eseguire il commit della documentazione;
- verificare la cronologia mediante `git log`;
- verificare nuovamente lo stato del repository;
- eseguire il push finale su GitHub;
- verificare che il repository locale e quello remoto risultino sincronizzati;
- definire il checkpoint finale e gli obiettivi della sessione successiva;
- registrare l'orario effettivo di conclusione della sessione come riferimento operativo finale.

Il **push finale** rappresenta l'ultima operazione di sincronizzazione della sessione e deve essere eseguito soltanto dopo il completamento dello sviluppo, della documentazione e delle relative verifiche.

Una sessione può essere dichiarata conclusa esclusivamente quando tutti i criteri previsti dal presente Workflow Operativo risultano soddisfatti.

---

# 5. Controlli di Qualità

La qualità rappresenta uno dei principi fondamentali del progetto Orto Smart.

Ogni modifica deve essere verificata prima di essere considerata completata.

Quando la sessione comprende modifiche al software, i controlli minimi da eseguire, quando applicabili, sono:

- formattazione del codice (`dart format`);
- analisi statica (`flutter analyze`);
- test automatici (`flutter test`);
- test funzionali manuali.

Per le sessioni che riguardano esclusivamente la documentazione o altre attività che non modificano il software, devono essere eseguiti soltanto i controlli pertinenti alla natura delle modifiche effettuate.

Qualora uno dei controlli applicabili non venga superato, la sessione non può essere considerata conclusa.

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

Il Workflow Operativo distingue il versionamento del codice dalla sincronizzazione finale della sessione.

Durante la sessione devono essere rispettati i seguenti principi:

- il codice deve essere sottoposto a commit solo dopo il completamento delle verifiche previste;
- il commit del codice deve precedere l'aggiornamento documentale quando le due attività appartengono alla stessa sessione;
- la documentazione aggiornata deve essere sottoposta a commit dopo la relativa rilettura e verifica incrociata;
- eventuali commit correttivi devono essere chiaramente descrittivi e verificati prima della sincronizzazione;
- il push finale deve essere eseguito soltanto dopo il completamento del codice, della documentazione e dei controlli conclusivi;
- dopo il push deve essere verificata la corrispondenza tra repository locale e repository remoto.

Prima di ogni commit devono essere controllati mediante `git status` i file modificati e quelli presenti nello staging.

Dopo i commit devono essere utilizzati `git log` e `git status` per verificare la cronologia e lo stato del repository.

Il repository GitHub rappresenta il riferimento ufficiale del codice sorgente e della documentazione versionata del progetto.

---

# 8. Criteri di chiusura della Sessione

Una sessione può essere dichiarata ufficialmente conclusa esclusivamente quando tutte le attività previste risultano completate e verificate.

Devono risultare soddisfatte, quando applicabili, almeno le seguenti condizioni:

- obiettivo della sessione raggiunto oppure eventuali attività non completate chiaramente registrate;
- sviluppo completato e verificato;
- controlli di qualità superati;
- verifica funzionale completata;
- codice sottoposto a commit;
- documentazione interessata aggiornata e riletta;
- verifica incrociata della documentazione completata;
- eventuali incongruenze risolte;
- tempi effettivi di sviluppo e documentazione consolidati al netto di pause e sospensioni;
- documenti storici e indicatori aggiornati;
- documentazione sottoposta a commit;
- cronologia Git verificata;
- push finale completato;
- repository locale e remoto sincronizzati;
- checkpoint finale registrato;
- obiettivi della sessione successiva definiti.

Qualora una delle condizioni applicabili non risulti soddisfatta, la sessione deve rimanere aperta oppure essere esplicitamente registrata come sospesa.

La procedura operativa utilizzata per completare queste attività è definita nella **Fase 8 – Chiusura della Sessione** del capitolo 4.

---

# 9. Checklist Operativa

La Checklist Operativa rappresenta lo strumento di supporto al Workflow Operativo.

Essa accompagna lo sviluppatore durante tutte le fasi della sessione e consente di verificare che ogni attività prevista sia stata eseguita.

La Checklist completa è riportata nell'Allegato A.

---

# 10. Considerazioni finali

Il Workflow Operativo definisce il metodo ufficiale di sviluppo del progetto Orto Smart.

Il rispetto sistematico delle procedure descritte nel presente documento garantisce qualità, tracciabilità, continuità e affidabilità nello sviluppo del software.

---


# Allegato A
## Checklist Workflow Operativo

La presente checklist deve essere utilizzata come controllo operativo durante ogni sessione del progetto Orto Smart.

I controlli devono essere applicati in funzione delle attività effettivamente svolte. Le verifiche non pertinenti alla natura della sessione devono essere riconosciute come non applicabili e non costituiscono attività mancanti.

### Apertura

- [ ] Registrato l'orario di inizio della sessione
- [ ] Riletto il Workflow Operativo come promemoria
- [ ] Verificato lo stato iniziale del repository con `git status`
- [ ] Verificata, quando necessaria, la sincronizzazione del repository
- [ ] Definito l'obiettivo della sessione
- [ ] Individuate le attività previste
- [ ] Eseguito il CHECKPOINT DI RICEZIONE, quando la sessione prosegue in una nuova conversazione
- [ ] Verificate le informazioni ricevute rispetto alle fonti ufficiali disponibili

### Sviluppo

- [ ] Analizzata e progettata la modifica
- [ ] Eseguite modifiche piccole e verificabili
- [ ] Verificato progressivamente il comportamento del software
- [ ] Eseguito `dart format`, quando applicabile
- [ ] Eseguito `flutter analyze`, quando applicabile
- [ ] Eseguito `flutter test`, quando applicabile
- [ ] Completata la verifica funzionale, quando applicabile

### Commit del codice

- [ ] Verificato `git status`
- [ ] Verificati i file da aggiungere allo staging
- [ ] Eseguito il commit del codice, quando sono presenti modifiche da versionare
- [ ] Verificato il commit con `git log`, quando applicabile
- [ ] Non eseguito anticipatamente il push finale

### Documentazione

- [ ] Dichiarato esplicitamente l'avvio della fase Manuali, con relativo orario
- [ ] Mantenuta distinta la fase documentale dalla fase sviluppo
- [ ] Individuati i documenti realmente interessati
- [ ] Aggiornati i documenti necessari
- [ ] Riletti i documenti modificati
- [ ] Eliminate eventuali duplicazioni o incongruenze
- [ ] Distinte chiaramente attività completate, pianificate e future
- [ ] Completata la verifica incrociata della documentazione
- [ ] Verificati alla fonte i dati numerici e i riferimenti Git

### Tempi

- [ ] Registrato l'orario di inizio
- [ ] Annotate eventuali pause o sospensioni
- [ ] Registrate le relative riprese
- [ ] Calcolato il tempo effettivo al netto delle interruzioni
- [ ] Distinto il tempo di sviluppo dal tempo di documentazione, quando entrambi presenti
- [ ] Consolidato il tempo di sviluppo alla chiusura della relativa fase
- [ ] Consolidato il tempo documentale alla chiusura dichiarata dei Manuali
- [ ] Aggiornati i documenti che registrano i tempi

### Continuità tra conversazioni

- [ ] Predisposto il CHECKPOINT DI PASSAGGIO CHAT, quando è previsto un cambio di conversazione
- [ ] Registrati lo stato effettivo, le decisioni, i punti aperti e il prossimo passo
- [ ] Distinto il cambio di conversazione dall'eventuale cambio di sessione
- [ ] Individuate le verifiche necessarie alla ripresa

### Chiusura e Git finale

- [ ] Eseguito `git status`
- [ ] Verificati i documenti presenti nello staging
- [ ] Eseguito il commit della documentazione, quando sono presenti modifiche
- [ ] Verificata la cronologia con `git log`
- [ ] Verificato nuovamente `git status`
- [ ] Eseguito il push finale, quando necessario
- [ ] Verificata la sincronizzazione tra repository locale e remoto
- [ ] Registrato il checkpoint finale
- [ ] Definiti gli obiettivi della sessione successiva
- [ ] Registrato l'orario effettivo di conclusione della sessione

Una sessione può essere dichiarata conclusa soltanto dopo il completamento di tutti i controlli applicabili.

---


# Allegato B
## Diagramma del Workflow

Il diagramma rappresenta il flusso generale delle attività del progetto Orto Smart.

Le fasi relative al codice e alle verifiche software si applicano soltanto quando pertinenti alla natura della sessione.

La chiusura della fase sviluppo non determina automaticamente l'avvio della fase Manuali, che deve essere dichiarato esplicitamente con il relativo orario.

```text
Pianificazione e verifica dello stato iniziale
                    │
                    ▼
          Sviluppo / Analisi tecnica
                    │
                    ▼
          Controlli di Qualità
             (se applicabili)
                    │
                    ▼
          Verifica Funzionale
             (se applicabile)
                    │
                    ▼
           Commit del Codice
             (se applicabile)
                    │
                    ▼
       Chiusura della Fase Sviluppo
       e consolidamento dei suoi tempi
                    │
                    ▼
       Avvio dichiarato della Fase Manuali
       con registrazione dell'orario
                    │
                    ▼
              Documentazione
                    │
                    ▼
           Verifica Incrociata
                    │
                    ▼
        Consolidamento dei Tempi
           della Fase Manuali
                    │
                    ▼
       Commit della Documentazione
                    │
                    ▼
            Verifica Git Finale
                    │
                    ▼
               Push GitHub
             (se necessario)
                    │
                    ▼
          Verifica Sincronizzazione
                    │
                    ▼
       Checkpoint e Obiettivi Successivi
                    │
                    ▼
        Chiusura Complessiva Sessione
```

Il diagramma descrive la sequenza ordinaria. Le fasi non applicabili devono essere riconosciute come tali e non costituiscono condizioni mancanti ai fini della chiusura.

Il passaggio a una nuova conversazione può avvenire durante una qualsiasi fase e richiede, quando pertinente, il CHECKPOINT DI PASSAGGIO CHAT e il successivo CHECKPOINT DI RICEZIONE.

Il cambio di conversazione non implica automaticamente il cambio di sessione.

---

# Allegato C
## Matrice della Documentazione

La Matrice della Documentazione supporta l'individuazione dei documenti da verificare e, quando necessario, aggiornare durante una sessione.

| Tipo di modifica | Documenti da verificare |
|------------------|-------------------------|
| Modifica tecnica o nuova funzionalità | DOC-001, DOC-005, DOC-012, CHANGELOG, VERSION |
| Modifica del metodo di sviluppo | DOC-006, DOC-009, DOC-005, DOC-012 |
| Decisione architetturale significativa | DOC-011, DOC-001, DOC-005, DOC-012 |
| Modifica della pianificazione futura | DOC-008, DOC-005, DOC-012 |
| Modifica del database | DOC-001, DOC-004 quando sviluppato, DOC-005, DOC-012, CHANGELOG |
| Modifica delle procedure di test | DOC-006, DOC-007 quando sviluppato, DOC-009 |
| Aggiornamento della versione software | VERSION, CHANGELOG, DOC-005, DOC-012 |

La matrice costituisce uno strumento di verifica e non implica l'aggiornamento automatico di tutti i documenti indicati.

Per ogni sessione devono essere aggiornati esclusivamente i documenti realmente interessati dalle modifiche effettuate.

Prima della chiusura deve inoltre essere verificata la coerenza delle informazioni condivise tra i documenti coinvolti.

---

# Allegato D
## Criteri di Chiusura della Sessione

Il presente allegato definisce i criteri utilizzati per determinare se una sessione del progetto Orto Smart può essere dichiarata ufficialmente conclusa.

### Criterio 1 – Obiettivo della sessione

L'obiettivo definito all'apertura della sessione deve risultare raggiunto.

Qualora alcune attività vengano rinviate, esse devono essere chiaramente registrate come attività future e non devono essere presentate come completate.

### Criterio 2 – Qualità del software

Quando la sessione comprende modifiche al software, devono risultare completati con esito positivo i controlli di qualità applicabili, compresi:

- `dart format`, quando applicabile;
- `flutter analyze`;
- `flutter test`;
- verifiche funzionali previste.

### Criterio 3 – Codice versionato

Le modifiche al codice devono essere correttamente registrate mediante Git e i relativi commit devono essere verificati.

### Criterio 4 – Documentazione

Tutti i documenti realmente interessati dalla sessione devono risultare aggiornati e riletti.

Le attività completate, pianificate e future devono essere chiaramente distinte.

### Criterio 5 – Verifica incrociata

Le informazioni condivise tra più documenti devono risultare coerenti.

Versioni, sessioni, tempi, test, indicatori, riferimenti Git e altri dati verificabili devono essere controllati sulla relativa fonte prima della conferma definitiva.

### Criterio 6 – Tempi

Il tempo effettivo della sessione deve essere consolidato al netto di pause, sospensioni e periodi di inattività.

Quando previsto, devono essere distinti il tempo di sviluppo e il tempo di documentazione.

### Criterio 7 – Repository

Il commit della documentazione deve essere completato e verificato.

Il push finale deve essere eseguito soltanto dopo il completamento delle verifiche precedenti.

Al termine della sessione il repository locale e quello remoto devono risultare sincronizzati.

### Criterio 8 – Continuità

Deve essere registrato un checkpoint finale sufficiente a consentire la ripresa ordinata del progetto.

Devono inoltre essere definiti gli obiettivi o i prossimi passi della sessione successiva.

---

Una sessione può essere dichiarata **CHIUSA** esclusivamente quando tutti i criteri applicabili risultano soddisfatti.

Se uno o più criteri non risultano soddisfatti, la sessione deve rimanere **APERTA** oppure essere registrata come **SOSPESA**, specificandone il motivo e le attività ancora da completare.