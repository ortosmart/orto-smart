# ORTO SMART

### DOC-006

# Linee Guida di Sviluppo

**Versione:** 1.1
**Stato:** Approvato

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026
**Ultimo aggiornamento:** 08/08/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-006 |
| Titolo | Linee Guida di Sviluppo |
| Versione | 1.1 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 08/08/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima versione del documento |
| 1.0 | 04/08/2026 | Revisione completa, uniformazione allo Standard Documentale e approvazione del documento |
| 1.1 | 08/08/2026 | Aggiornamento del workflow di sviluppo, introduzione della verifica incrociata della documentazione e formalizzazione della registrazione dei tempi effettivi |

---

# Indice

## 1. Scopo

## 2. Principi del progetto

## 3. Architettura

## 4. Convenzioni di sviluppo

## 5. Organizzazione del progetto

## 6. Workflow di sviluppo

## 7. Gestione Git

## 8. Gestione della documentazione

## 9. Standard di qualità

## 10. Evoluzione del progetto

## 11. Considerazioni finali

---

# 1. Scopo

Il presente documento definisce gli standard di sviluppo del progetto Orto Smart.

L'obiettivo è garantire uniformità, qualità del codice, tracciabilità delle modifiche e coerenza della documentazione durante l'intero ciclo di vita del progetto.

---

# 2. Principi del progetto

- Codice semplice e leggibile.
- Una responsabilità per ogni classe.
- Evitare duplicazioni.
- Preferire componenti riutilizzabili.
- Documentare ogni modifica significativa.
- Privilegiare la manutenibilità rispetto alla complessità.

---

# 3. Architettura

Principi adottati:

- Repository Pattern
- Modelli separati dalla UI
- Business Logic separata dall'interfaccia
- Motore agronomico indipendente dalla UI
- Database normalizzato
- Utilizzo di Supabase come backend

---

# 4. Convenzioni di sviluppo

## Nomi dei file

snake_case

Esempio

free_space_engine.dart

---

## Nomi delle classi

PascalCase

Esempio

FreeSpaceEngine

---

## Variabili

camelCase

Esempio

availableLength

---

## Costanti

camelCase oppure static const secondo gli standard Dart.

---

# 5. Organizzazione del progetto

Descrizione della struttura delle cartelle.

lib/
core/
data/
pages/
widgets/
services/
docs/

Per ogni cartella verrà descritto il suo scopo.

---

# 6. Principi del workflow di sviluppo

Le presenti Linee Guida definiscono i principi generali che devono essere seguiti durante lo sviluppo del progetto Orto Smart.

Il workflow operativo dettagliato, comprensivo della sequenza delle attività, delle verifiche e delle procedure di chiusura di ogni sessione, è definito nel **DOC-009 – Workflow Operativo**.

Ogni sessione deve seguire un processo ordinato, progressivo e verificabile basato sui seguenti principi:

1. controllo iniziale dello stato del progetto e del repository;
2. analisi e progettazione delle modifiche;
3. implementazione mediante piccoli cambiamenti verificabili;
4. esecuzione dei test e delle verifiche funzionali;
5. esecuzione di `flutter analyze`;
6. esecuzione di `flutter test`;
7. commit del codice verificato;
8. aggiornamento della documentazione interessata;
9. rilettura e verifica dei singoli documenti;
10. verifica incrociata della coerenza tra codice, documentazione e dati di progetto;
11. commit della documentazione;
12. verifica finale del repository;
13. push su GitHub;
14. registrazione dei tempi effettivi della sessione;
15. definizione del checkpoint e degli obiettivi della sessione successiva.

Le attività devono essere svolte **passo dopo passo**, verificando l'esito di ciascuna operazione prima di procedere con la successiva.

I dati riportati nella documentazione, in particolare versioni, sessioni, tempi, indicatori e riferimenti Git, non devono essere considerati corretti per presunzione, ma verificati sulle relative fonti ufficiali prima della conferma.

Il tempo dedicato al progetto deve rappresentare esclusivamente il tempo effettivo di lavoro. Pause, sospensioni e periodi di inattività devono essere esclusi dal conteggio e registrati secondo le modalità definite nel DOC-009.

Una sessione non è considerata conclusa fino al completamento delle verifiche previste, dell'aggiornamento e della verifica incrociata della documentazione, della registrazione dei tempi e della sincronizzazione finale del repository.

---

# 7. Gestione Git

Il controllo di versione del progetto è affidato a Git e al repository GitHub ufficiale.

Le presenti Linee Guida definiscono i principi generali da seguire nell'utilizzo del sistema di versionamento.

Le procedure operative relative a commit, push, gestione dei branch e sincronizzazione del repository sono descritte nel **DOC-009 – Workflow Operativo**.

Durante lo sviluppo devono essere rispettati i seguenti principi:

- eseguire commit significativi e facilmente comprensibili;
- mantenere il repository sempre in uno stato coerente;
- sincronizzare regolarmente il repository remoto;
- evitare commit contenenti codice non verificato;
- garantire la corrispondenza tra codice sorgente e documentazione.

Gli aspetti disciplinati dalle presenti Linee Guida riguardano in particolare:

- commit;
- branch;
- push;
- gestione delle versioni;

nonché i criteri generali per la redazione dei messaggi di commit.

---

# 8. Gestione della documentazione

La documentazione costituisce parte integrante del progetto Orto Smart e deve essere mantenuta costantemente allineata allo stato reale del software.

Gli standard documentali, la struttura dei documenti e l'elenco della documentazione ufficiale sono definiti nel **DOC-000 – Standard Documentale**.

Le presenti Linee Guida stabiliscono il principio secondo cui ogni modifica significativa al progetto deve essere accompagnata dall'aggiornamento della documentazione interessata.

La scelta dei documenti da aggiornare dipende dalla natura delle modifiche introdotte e deve rispettare il workflow definito nel **DOC-009 – Workflow Operativo**.

Prima della chiusura di ogni sessione deve essere effettuata una verifica incrociata della documentazione interessata, allo scopo di garantire la coerenza delle informazioni condivise tra i diversi documenti.

La verifica deve comprendere, quando applicabile, versioni, numero delle sessioni, tempi di lavoro, stato delle attività, milestone, indicatori evolutivi, riferimenti Git e componenti software documentati.

Ogni dato deve essere verificato sulla relativa fonte prima di essere considerato definitivo. In caso di incongruenze, la sessione non può essere considerata conclusa fino al loro completo allineamento.

---

# 9. Standard di qualità

La qualità del software rappresenta uno dei principi fondamentali del progetto Orto Smart.

Prima di ogni commit devono essere completate le verifiche previste dal processo di sviluppo, al fine di garantire stabilità, manutenibilità e coerenza del progetto.

In particolare devono essere verificati almeno i seguenti aspetti:

- esecuzione di `flutter analyze`;
- esecuzione di `flutter test`;
- assenza di warning o errori;
- assenza di codice inutilizzato;
- aggiornamento della documentazione interessata.

Le procedure operative di verifica sono descritte nel **DOC-009 – Workflow Operativo**.

---

# 10. Evoluzione del progetto

Le presenti Linee Guida definiscono i principi che devono accompagnare l'evoluzione del progetto Orto Smart nel tempo.

Ogni nuova funzionalità dovrà essere progettata nel rispetto dell'architettura esistente, privilegiando la semplicità, la manutenibilità e la possibilità di estendere il software senza introdurre complessità non necessarie.

In particolare dovranno essere sempre rispettati i seguenti principi:

- evitare codice duplicato;
- mantenere il motore agronomico modulare;
- progettare pensando alle future espansioni;
- ottimizzare lo spazio occupato nel database;
- evitare dati ridondanti;
- mantenere compatibilità con il piano gratuito di Supabase quando possibile.

---

# 11. Considerazioni finali

Le presenti Linee Guida di Sviluppo costituiscono il riferimento per la progettazione, l'implementazione e la manutenzione del progetto Orto Smart.

Il documento definisce i principi che devono guidare lo sviluppo del software, promuovendo uniformità, qualità del codice, tracciabilità delle modifiche e coerenza dell'architettura nel tempo.

Le procedure operative, gli standard documentali e le decisioni architetturali sono disciplinati dai documenti specifici del progetto, ai quali le presenti Linee Guida fanno riferimento.

Il documento dovrà essere aggiornato ogniqualvolta vengano introdotti nuovi principi di sviluppo o modifiche sostanziali al metodo di lavoro del progetto, mantenendo la coerenza con il DOC-000 – Standard Documentale, il DOC-009 – Workflow Operativo, il DOC-011 – Decisioni Architetturali e il Quaderno di Sviluppo (DOC-005).
