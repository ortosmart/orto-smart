# DOC-000 – Standard Documentale
# ORTO SMART

### DOC-000

# Standard Documentale

**Versione:** 1.1  
**Stato:** Approvato

**Autore:** Renzo Siega  
**Progetto:** Orto Smart

**Data prima emissione:** 29/07/2026  
**Ultimo aggiornamento:** 04/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-000 |
| Titolo | Standard Documentale |
| Versione | 1.1 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 29/07/2026 |
| Ultimo aggiornamento | 04/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 1.0 | 29/07/2026 | Prima emissione dello Standard Documentale |
| 1.1 | 04/08/2026 | Allineamento della struttura del documento allo standard documentale ufficiale del progetto |

---

# Indice

1. Scopo
2. Principi fondamentali
3. Struttura standard dei documenti
4. Convenzioni di scrittura
5. Numerazione dei documenti
6. Versionamento documentale
7. Documentazione ufficiale del progetto
8. Workflow documentale
9. Evoluzione della documentazione
10. Regola d'oro

---

# 1. Scopo

Il presente documento definisce gli standard ufficiali per la redazione, l'aggiornamento, il versionamento e la gestione della documentazione del progetto **Orto Smart**.

Lo scopo è garantire una documentazione:

- uniforme;
- completa;
- facilmente consultabile;
- tracciabile nel tempo;
- coerente con il codice sorgente;
- semplice da mantenere durante l'evoluzione del progetto.

Il presente standard costituisce il riferimento ufficiale per tutti i documenti del progetto e dovrà essere applicato a ogni nuovo documento o revisione della documentazione esistente.

# 2. Principi fondamentali

La documentazione è considerata parte integrante del progetto software e possiede la stessa importanza del codice sorgente.

Ogni modifica significativa al progetto deve essere accompagnata dall'aggiornamento della documentazione interessata.

I principi fondamentali della documentazione di Orto Smart sono:

- chiarezza;
- completezza;
- coerenza;
- tracciabilità;
- semplicità di consultazione;
- aggiornamento continuo.

Una sessione di sviluppo non può considerarsi conclusa fino al completamento di tutte le attività previste dal workflow ufficiale.

Prima della chiusura di ogni sessione devono essere completati:

- sviluppo del software;
- test funzionali;
- controllo della qualità del codice (`dart format`, `flutter analyze`, `flutter test`);
- aggiornamento della documentazione;
- aggiornamento del Registro Storico dello Sviluppo (DOC-012);
- commit Git;
- push sul repository GitHub.

Solo dopo il completamento di tutte queste attività la sessione può essere dichiarata ufficialmente conclusa.

# 3. Struttura standard dei documenti

Tutti i documenti ufficiali del progetto Orto Smart devono seguire una struttura uniforme, al fine di garantire leggibilità, coerenza, tracciabilità e facilità di manutenzione.

La struttura standard è la seguente.

## 3.1 Copertina

Ogni documento deve iniziare con una copertina contenente almeno:

- nome del progetto;
- codice del documento;
- titolo del documento.

La copertina consente l'immediata identificazione del documento e ne uniforma la presentazione.

---

## 3.2 Informazioni sul documento

Subito dopo la copertina deve essere riportata una tabella contenente le principali informazioni identificative.

| Campo | Descrizione |
|-------|-------------|
| Documento | Codice identificativo del documento |
| Titolo | Nome del documento |
| Versione | Versione del documento |
| Stato | Bozza, In sviluppo, Approvato o Archiviato |
| Progetto | Nome del progetto |
| Repository | Repository GitHub ufficiale |
| Prima emissione | Data di creazione del documento |
| Ultimo aggiornamento | Data dell'ultima revisione |

---

## 3.3 Cronologia delle revisioni

Ogni documento deve contenere una tabella che registri le principali revisioni effettuate nel tempo.

La cronologia deve riportare almeno:

- versione;
- data;
- descrizione sintetica della modifica.

---

## 3.4 Indice

I documenti di dimensioni medio-grandi devono contenere un indice numerato dei capitoli.

L'indice deve riflettere fedelmente la struttura del documento.

---

## 3.5 Corpo del documento

Il contenuto deve essere organizzato in capitoli e sottocapitoli numerati.

Quando opportuno possono essere utilizzati:

- tabelle;
- elenchi puntati;
- diagrammi;
- immagini;
- esempi di codice;
- note tecniche.

Ogni sezione deve trattare un solo argomento.

---

## 3.6 Considerazioni finali

Quando opportuno, il documento si conclude con una sezione dedicata alle considerazioni finali, contenente eventuali indicazioni conclusive, criteri di utilizzo o riferimenti agli altri documenti del progetto.

# 4. Convenzioni di scrittura

Per garantire uniformità e qualità della documentazione, tutti i documenti del progetto Orto Smart dovranno rispettare le seguenti convenzioni.

## 4.1 Linguaggio

- Utilizzare un linguaggio tecnico, chiaro e preciso.
- Evitare frasi ambigue o interpretabili.
- Preferire termini coerenti con il codice sorgente.
- Evitare abbreviazioni non spiegate.

---

## 4.2 Struttura

- Utilizzare titoli e sottotitoli numerati.
- Ogni capitolo deve trattare un solo argomento principale.
- Le sezioni devono seguire un ordine logico.
- Preferire elenchi puntati quando migliorano la leggibilità.

---

## 4.3 Terminologia

La terminologia utilizzata nella documentazione deve essere coerente con quella adottata nel progetto.

Esempi:

| Documentazione | Codice |
|---------------|--------|
| Aiuola | Bed |
| Coltura | Crop |
| Piantagione | Planting |
| Motore Agronomico | Agronomy Engine |
| Decision Engine | Decision Engine |

Quando un termine inglese è il nome ufficiale di una classe, di un servizio o di un componente software, deve essere mantenuto anche nella documentazione.

---

## 4.4 Esempi di codice

Gli esempi di codice devono:

- essere completi e leggibili;
- riportare solo il codice necessario;
- utilizzare la formattazione Markdown con i blocchi ```.

---

## 4.5 Tabelle

Le tabelle devono essere utilizzate quando facilitano il confronto o la consultazione dei dati.

Le intestazioni devono essere sempre descrittive e coerenti tra i documenti.

# 5. Numerazione dei documenti

Ogni documento ufficiale del progetto Orto Smart deve essere identificato da un codice univoco nel formato:

DOC-XXX

dove:

- **DOC** identifica la categoria "Documento";
- **XXX** è un numero progressivo a tre cifre.

Esempi:

| Codice | Documento |
|--------|-----------|
| DOC-000 | Standard Documentale |
| DOC-001 | Manuale Tecnico |
| DOC-005 | Quaderno di Sviluppo |
| DOC-006 | Linee Guida di Sviluppo |
| DOC-008 | Roadmap di Sviluppo |
| DOC-009 | Workflow Operativo |
| DOC-011 | Decisioni Architetturali |
| DOC-012 | Registro Storico dello Sviluppo |

## 5.1 Assegnazione dei codici

Ogni nuovo documento riceve un codice progressivo.

Il codice assegnato:

- non viene mai modificato;
- non viene mai riutilizzato;
- rimane associato al documento per tutta la vita del progetto.

## 5.2 Archiviazione

Nel caso un documento venga sostituito o ritirato, esso dovrà essere spostato nella cartella `docs/archivio`, mantenendo il proprio codice originale.

Questo garantisce la completa tracciabilità storica della documentazione.

# 6. Versionamento documentale

Ogni documento ufficiale del progetto Orto Smart deve essere versionato per garantire la tracciabilità delle modifiche nel tempo.

## 6.1 Schema di versionamento

Il versionamento segue il formato:

MAJOR.MINOR

dove:

- **MAJOR** identifica una revisione importante del documento;
- **MINOR** identifica aggiornamenti incrementali.

Esempi:

| Versione | Significato |
|----------|-------------|
| 1.0 | Prima emissione ufficiale |
| 1.1 | Correzioni o miglioramenti minori |
| 1.2 | Aggiornamenti incrementali |
| 2.0 | Revisione importante della struttura o dei contenuti |

---

## 6.2 Aggiornamento della versione

La versione del documento deve essere incrementata quando vengono apportate modifiche significative.

In particolare:

- correzioni ortografiche di lieve entità possono non richiedere un incremento della versione;
- modifiche ai contenuti devono comportare l'incremento della versione MINOR;
- revisioni sostanziali della struttura del documento richiedono l'incremento della versione MAJOR.

---

## 6.3 Indipendenza dal software

Il versionamento della documentazione è indipendente dal versionamento del software.

Ad esempio:

Software:

0.1.3-alpha

Documentazione:

DOC-001 → versione 1.4

DOC-005 → versione 0.8

DOC-011 → versione 1.1

Ogni documento evolve in funzione delle proprie modifiche e non della versione del software.

# 7. Documentazione ufficiale del progetto

La documentazione ufficiale di Orto Smart è composta dai seguenti documenti.

| Codice | Documento | Scopo |
|---------|-----------|-------|
| DOC-000 | Standard Documentale | Definisce le regole della documentazione |
| DOC-001 | Manuale Tecnico | Descrive l'architettura e il funzionamento del software |
| DOC-002 | Manuale d'Uso | Guida l'utilizzatore nell'uso dell'applicazione |
| DOC-003 | Installazione e Configurazione | Descrive l'installazione e la configurazione dell'ambiente |
| DOC-004 | Manuale Database | Documenta la struttura e l'organizzazione del database |
| DOC-005 | Quaderno di Sviluppo | Diario tecnico delle sessioni di sviluppo |
| DOC-006 | Linee Guida di Sviluppo | Definisce il metodo di sviluppo del progetto |
| DOC-007 | Test e Collaudo | Descrive le procedure di verifica e collaudo |
| DOC-008 | Roadmap di Sviluppo | Pianifica l'evoluzione futura del software |
| DOC-009 | Workflow Operativo | Descrive il flusso operativo di ogni sessione |
| CHANGELOG | Registro delle modifiche | Registra sinteticamente le modifiche introdotte nel software |
| DOC-011 | Decisioni Architetturali | Registra le decisioni progettuali più importanti |
| DOC-012 | Registro Storico dello Sviluppo | Tiene traccia del tempo dedicato al progetto e delle principali milestone |
| VERSION | Versione del progetto | Riporta la versione corrente del software e le informazioni di rilascio |

## 7.1 Nuovi documenti

Nuovi documenti potranno essere aggiunti nel corso dell'evoluzione del progetto.

Ogni nuovo documento dovrà:

- ricevere un codice progressivo univoco;
- rispettare il presente standard documentale;
- essere inserito nell'elenco della documentazione ufficiale.

# 8. Workflow documentale

La documentazione deve essere mantenuta costantemente allineata allo stato del progetto.

Ogni sessione di sviluppo segue il workflow operativo definito nel DOC-009 – Workflow Operativo.

## 8.1 Aggiornamento della documentazione

Al termine di ogni sessione devono essere aggiornati tutti i documenti interessati dalle modifiche effettuate.

A titolo di esempio:

| Documento | Quando aggiornarlo |
|-----------|-------------------|
| DOC-001 | Modifiche tecniche o architetturali |
| CHANGELOG | In occasione del rilascio di una nuova versione significativa del software |
| DOC-005 | Alla chiusura di ogni sessione |
| DOC-008 | Completamento o pianificazione di nuove funzionalità |
| DOC-011 | Nuove decisioni architetturali |
| DOC-012 | Registrazione delle ore e delle milestone |

---

## 8.2 Verifiche finali

Prima della chiusura di una sessione devono essere verificati:

- correttezza dei contenuti;
- coerenza tra documenti;
- numerazione dei documenti;
- versioni aggiornate;
- riferimenti incrociati;
- aggiornamento del Registro Storico dello Sviluppo (DOC-012).

---

## 8.3 Commit e Push

Solo dopo aver completato lo sviluppo, i test e l'aggiornamento della documentazione è possibile eseguire:

- `git status`
- `git add .`
- `git commit`
- `git push`

La documentazione deve essere sincronizzata con il codice sorgente presente nel repository GitHub.

# 9. Miglioramento continuo

La documentazione di Orto Smart è un patrimonio del progetto e deve evolvere insieme al software.

Ogni documento può essere migliorato nel tempo per aumentarne:

- chiarezza;
- completezza;
- leggibilità;
- qualità tecnica;
- facilità di manutenzione.

Le modifiche devono rispettare gli standard definiti nel presente documento e mantenere la coerenza con il resto della documentazione.

## 9.1 Nuovi documenti

Quando l'evoluzione del progetto lo richiederà, potranno essere creati nuovi documenti ufficiali.

Ogni nuovo documento dovrà:

- ricevere un codice progressivo univoco;
- rispettare il presente standard documentale;
- essere inserito nell'elenco della documentazione ufficiale;
- essere riportato nel CHANGELOG, se pertinente.

## 9.2 Revisione dello standard

Anche il presente documento (DOC-000) potrà essere aggiornato quando emergeranno nuove esigenze organizzative o nuove buone pratiche.

Ogni revisione dovrà essere motivata e registrata incrementando la versione del documento.

# 10. Regola d'oro

La qualità di Orto Smart dipende dall'equilibrio tra codice e documentazione.

Per questo motivo:

> **Nessuna sessione di sviluppo può essere considerata conclusa finché non risultano completati e sincronizzati:**
>
> - sviluppo del software;
> - test e controlli di qualità;
> - aggiornamento della documentazione;
> - aggiornamento del Registro Storico dello Sviluppo (DOC-012);
> - commit Git;
> - push sul repository GitHub.

La documentazione deve sempre rappresentare fedelmente lo stato reale del progetto.

Ogni documento costituisce parte integrante del patrimonio tecnico di Orto Smart e contribuisce alla sua evoluzione, manutenzione e futura estendibilità.

