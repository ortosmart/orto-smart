# NC-RC01-001 - Scritture dirette profili e operatori

## 1. Identificazione

- Identificativo: NC-RC01-001.
- Versione: 1.0.
- Sessione di rilevazione: S046.
- Data: 26/11/2026.
- Origine: RC01, controllo 06.
- Classificazione: P1.
- Stato: APERTA.
- Macroblocchi interessati: V1-01 e V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Evidenza funzionale specifica: NV.
- Ambiente remoto: NV.

## 2. Descrizione

Durante la ricognizione RC01 sono stati
individuati cinque percorsi strutturali
di scrittura diretta sulle tabelle
profiles e workers.

I privilegi SQL e le policy RLS
consentono determinate mutazioni
al proprietario del profilo.

I percorsi esaminati non richiedono
direttamente il possesso dell'edit lock
e non richiedono la versione attesa.

La configurazione risulta pertanto
non allineata al principio generale
della scrittura autoritativa.

## 3. Percorsi interessati

| ID | Tabella | Operazione |
|---|---|---|
| WA-RC01-01 | profiles | UPDATE display_name |
| WA-RC01-02 | workers | INSERT |
| WA-RC01-03 | workers | UPDATE display_name |
| WA-RC01-04 | workers | UPDATE notes |
| WA-RC01-05 | workers | UPDATE is_active |

I cinque percorsi rappresentano
autorizzazioni strutturali rilevate.

Non rappresentano cinque incidenti
di sicurezza effettivamente avvenuti.

## 4. Evidenze tecniche

Sono state esaminate:

- Migrazione originaria.
- Riferimenti nelle migrazioni successive.
- Privilegi effettivi sulle tabelle.
- Privilegi effettivi sulle colonne.
- Policy RLS installate.
- Trigger installati.
- Definizioni degli helper di sicurezza.

Riferimenti autorevoli nel Registro:

- DB-PROF-001.
- DB-SEC-001.
- DB-VER-001.

Migrazione originaria:

supabase/migrations/20260817103916_database_v1_baseline.sql

Le policy di scrittura esaminate
verificano la proprieta del profilo.

Gli helper esaminati non verificano
il possesso dell'edit lock.

I trigger BEFORE UPDATE esaminati
aggiornano i metadati e row_version.

Non verificano la versione attesa
o l'autorita di scrittura.

## 5. Ulteriore osservazione INSERT

Il privilegio INSERT su workers
comprende tutte le otto colonne.

Fra queste sono presenti:

- id.
- profile_id.
- created_at.
- updated_at.
- row_version.

I vincoli e le policy applicabili
rimangono operativi.

Non e' stata dimostrata una modifica
abusiva effettiva dei metadati.

L'opportunita di limitare questi
privilegi deve essere approfondita
nelle riconciliazioni pertinenti.

## 6. Impatto potenziale

Possibile aggiramento strutturale
del modello single-writer.

Possibile modifica senza controllo
della versione attesa.

Possibile incoerenza rispetto
ai percorsi autoritativi degli altri domini.

L'impatto effettivo attraverso
la Data API deve essere verificato.

Non e' stata dimostrata una violazione
dell'isolamento fra profili.

Non e' stato dimostrato un accesso
non autorizzato da parte di terzi.

## 7. Approfondimenti assegnati

RC02:

Verificare l'autorita di scrittura
e i percorsi di controllo dell'edit lock.

RC03:

Verificare privilegi, RLS, RPC
ed esposizione dei percorsi diretti.

RC04:

Verificare versione attesa,
concorrenza e atomicita.

RC05:

Valutare le eventuali dipendenze
da journal e ricevute.

RC07:

Verificare la distribuzione
delle eventuali correzioni.

RC17:

Consolidare le evidenze
dei collaudi pertinenti.

## 8. Condizioni di risoluzione

Prima della chiusura della NC:

- Confermare il comportamento effettivo.
- Definire la soluzione tecnica.
- Ottenere l'autorizzazione alla modifica.
- Preservare le operazioni legittime.
- Preservare lo storico dei dati.
- Verificare i percorsi autoritativi.
- Verificare i privilegi residui.
- Collaudare le scritture senza lock.
- Collaudare le versioni non aggiornate.
- Collaudare le operazioni autorizzate.
- Verificare gli ambienti pertinenti.
- Registrare le evidenze di risoluzione.

I dettagli della soluzione tecnica
non sono ancora approvati.

Nessuna nuova RPC viene definita
dal presente documento.

## 9. Vincoli operativi

Non modificare direttamente
le autorizzazioni del database remoto.

Non applicare migrazioni correttive
senza autorizzazione.

Non utilizzare dati fittizi permanenti.

Eseguire gli eventuali collaudi
in condizioni controllate.

Non dichiarare risolta la NC
sulla base della sola analisi del codice.

La classificazione P1 impedisce
il rilascio pertinente finche'
la non conformita rimane irrisolta.

## 10. Stato quantitativo

Ore correttive: NV.

Attribuzione definitiva delle ore:
da riconciliare fra V1-01 e V1-02.

Non aggiungere automaticamente
cinque pacchetti di lavoro.

Verificare se le attivita correttive
sono gia comprese nelle stime residue.

Nessuna variazione approvata.

## 11. Stato conclusivo

- Non conformita: APERTA.
- Classificazione: P1.
- Evidenza strutturale: acquisita.
- Collaudo funzionale specifico: NV.
- Verifica remota: NV.
- Soluzione tecnica: non approvata.
- Correzione: non eseguita.

Nessuna modifica correttiva introdotta.
