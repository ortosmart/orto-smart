# ARC-004 - Perimetro dei rilasci e vincoli operativi

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 274-275
- Stato: perimetro approvato, programmazione in corso

## 1. Struttura dei rilasci

Milestone A:

Primo utilizzo operativo reale,
con particolare riferimento alla gestione
e pianificazione dell'orto per il 2027.

Milestone B:

Completamento aggiuntivo delle funzionalita
necessarie alla gestione quotidiana definitiva.

V1 definitiva:

Insieme delle funzionalita A e B.

B rappresenta il lavoro aggiuntivo
rispetto alla milestone A.

Non sommare due volte le attivita comuni.

## 2. Perimetro funzionale

21 macroblocchi V1.

15 macroblocchi interessati dalla milestone A.

6 macroblocchi esclusivamente B.

Il dettaglio dei macroblocchi e delle stime
e conservato nella sezione 09_programmazione.

## 3. Gestione delle variazioni

Il perimetro approvato costituisce
la base della programmazione.

Sono ammesse nel perimetro:

- Correzioni necessarie.
- Protezioni di sicurezza.
- Requisiti gia approvati.
- Integrazioni tecniche indispensabili.
- Collaudi necessari al rilascio.

Le nuove funzionalita non approvate
devono essere valutate separatamente.

Non introdurre automaticamente
ampliamenti del perimetro.

## 4. Distribuzione

Applicazione Flutter Web.

Dispositivi previsti per il primo utilizzo:

- PC con Microsoft Edge.
- iPad con Safari.

Per la versione definitiva:

- PC.
- iPad.
- iPhone.
- Dispositivi Android.

Distribuzione HTTPS e accesso dalla schermata
iniziale secondo le verifiche previste.

Hosting definitivo: da consolidare.

Non assumere la disponibilita
di applicazioni native o offline avanzato.

## 5. Accettazione

Distinguere:

- Implementazione.
- Verifica tecnica.
- Integrazione.
- Operativita reale.
- Accettazione formale.

Il superamento dei test automatici
non autorizza automaticamente il rilascio.

Le criticita P0 e P1 bloccano
l'accettazione quando applicabili.

Le criticita P2 richiedono
una valutazione esplicita.

Non derogare ai requisiti obbligatori
mediante la sola classificazione della criticita.

Le criticita minori devono essere registrate.

## 6. Migrazioni e pubblicazione

Nessuna migrazione remota senza autorizzazione.

Nessuna distribuzione automatica.

Verificare backup, recuperabilita,
allineamento e compatibilita.

Distinguere rollback dell'applicazione
e ripristino del database.

Consultare DB-MIG-001 per la baseline
e il metodo operativo delle migrazioni.

## 7. Programmazione

Le date di rilascio devono derivare
dalla valutazione delle attivita residue,
delle dipendenze e delle disponibilita.

Non utilizzare le roadmap esplorative
come fonte autoritativa dello sviluppo.

Non ridurre artificialmente le stime
per rispettare una data desiderata.

La riconciliazione quantitativa
delle stime S046 rimane aperta.

## 8. Documentazione

Il Registro tecnico sostituisce
l'aggiornamento sistematico dei Manuali.

I Manuali precedenti rimangono conservati.

La documentazione necessaria all'utilizzo
e all'accettazione dei rilasci
deve comunque essere predisposta.

Consultare ARC-REG-001 per le regole
di gestione della conoscenza permanente.

## 9. Limiti

La data definitiva del primo rilascio
non e ancora determinata.

La data definitiva di completamento B
non e ancora determinata.

Nessuna autorizzazione alla pubblicazione
deriva dalla presente scheda.
