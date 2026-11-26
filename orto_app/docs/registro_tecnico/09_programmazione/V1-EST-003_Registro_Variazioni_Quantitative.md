# V1-EST-003 - Registro delle variazioni quantitative

## 1. Identificazione

- Versione: 1.0.
- Sessione di istituzione: S046.
- Data: 26/11/2026.
- Baseline: V1-EST-001.
- Metodo: V1-MET-001.
- Origine: STEP 275.6.

## 2. Baseline di riferimento

| Indicatore | Ore e minuti | Minuti |
|---|---:|---:|
| Milestone A | 678:33 | 40713 |
| Milestone B | 2055:45 | 123345 |
| V1 complessiva | 2734:18 | 164058 |
| Configurazione reale A | 43:20 | 2600 |
| A con configurazione | 721:53 | 43313 |
| V1 con configurazione A | 2777:38 | 166658 |

Configurazione aggiuntiva B: NV.

Correttezza aritmetica verificata
nella sessione S046.

Riconciliazione delle stime PERT
originarie non ancora conclusa.

## 3. Finalita

Registrare ogni variazione delle stime
residue in maniera verificabile.

Preservare la baseline originaria.

Evitare riduzioni arbitrarie,
duplicazioni e perdita dello storico.

Distinguere le ore stimate residue
dalle ore effettivamente lavorate.

## 4. Tipologie di variazione

- RID: riduzione documentata.
- INC: incremento documentato.
- RIC: riclassificazione senza variazione netta.
- RST: ristima motivata.
- COR: correzione documentale.

Una correzione di trascrizione
non modifica la stima approvata.

Una riclassificazione non riduce
automaticamente il totale V1.

## 5. Contenuto obbligatorio

Per ogni proposta registrare:

- Identificativo univoco VAR-V1.
- Sessione e data.
- Macroblocco interessato.
- Milestone A oppure B.
- Pacchetto di lavoro originario.
- Riferimenti DUP e RC.
- Tipologia della variazione.
- Stima precedente.
- Riduzione proposta in minuti.
- Incremento proposto in minuti.
- Stima risultante.
- Evidenza tecnica.
- Motivazione.
- Dipendenze.
- Verifica di assenza di doppio conteggio.
- Stato della proposta.
- Approvazione.
- Data di applicazione.

## 6. Stati delle variazioni

PROPOSTA:

Variazione individuata ma non approvata.

VERIFICATA:

Evidenze e calcoli controllati,
in attesa di approvazione.

APPROVATA:

Variazione autorizzata esplicitamente.

APPLICATA:

Variazione approvata incorporata
nella baseline quantitativa corrente.

RESPINTA:

Variazione non accettata.

SUPERATA:

Variazione sostituita da una successiva
registrazione, mantenendo lo storico.

## 7. Regole di calcolo

Utilizzare i minuti interi
come unita di riconciliazione.

Residuo aggiornato:

Residuo precedente
meno riduzioni approvate
piu incrementi approvati.

Applicare ciascuna variazione
una sola volta.

Non modificare la baseline corrente
per una semplice proposta.

Non sottrarre automaticamente
le ore effettivamente lavorate.

Le ore lavorate e le ore residue
misurano grandezze differenti.

Non ridurre il lavoro residuo
per la sola disponibilita di codice.

Verificare le integrazioni
e i collaudi ancora necessari.

## 8. Registro delle variazioni

| ID | Sessione | Macroblocco | Milestone | DUP/RC | Tipo | Riduzione min | Incremento min | Stato |
|---|---|---|---|---|---|---:|---:|---|

Nessuna variazione quantitativa
approvata o applicata alla data
di istituzione del Registro.

## 9. Correzioni documentali

COR-S046-001:

Correzione della precedente segnalazione
errata di una differenza di 20 minuti
nella trascrizione della baseline.

Verifica automatica delle 21 righe:

- Differenza A: 0 minuti.
- Differenza B: 0 minuti.
- Coerenza complessiva: True.
- Esito: PASS.

Riferimento: V1-EST-001.

Impatto sulle stime approvate: 0 minuti.

## 10. Riepilogo quantitativo corrente

| Indicatore | Baseline | Riduzioni | Incrementi | Residuo corrente |
|---|---:|---:|---:|---:|
| A | 678:33 | 0:00 | 0:00 | 678:33 |
| B | 2055:45 | 0:00 | 0:00 | 2055:45 |
| V1 | 2734:18 | 0:00 | 0:00 | 2734:18 |
| Configurazione A | 43:20 | 0:00 | 0:00 | 43:20 |
| V1 con configurazione A | 2777:38 | 0:00 | 0:00 | 2777:38 |

Configurazione aggiuntiva B: NV.

## 11. Controlli prima dell'approvazione

Verificare:

- Esistenza della stima originaria.
- Pertinenza dell'evidenza.
- Lavoro gia escluso dalla baseline.
- Eventuali sovrapposizioni.
- Dipendenze residue.
- Integrazioni ancora necessarie.
- Collaudi ancora necessari.
- Assenza di doppio conteggio.
- Correttezza aritmetica.
- Motivazione della variazione.

La riduzione deve riferirsi
a lavoro realmente ancora stimato.

## 12. Aggiornamento del Registro

Aggiornare questo documento
quando viene individuata o approvata
una variazione quantitativa.

Conservare il collegamento
alla relativa scheda RC.

Aggiornare i riepiloghi derivati
soltanto dopo l'approvazione.

Non alterare retroattivamente
i consuntivi delle sessioni concluse.

Non duplicare le motivazioni:
utilizzare riferimenti alle evidenze
e alle schede tecniche autorevoli.

## 13. Collegamenti e limiti

- ARC-REG-001.
- V1-MET-001.
- V1-EST-001.
- V1-EST-002.
- DUP-A-001.
- DUP-B-001.
- RC-REG-001.

La struttura del Registro delle variazioni
e' introdotta nella sessione S046
come strumento organizzativo permanente.

Non costituisce una nuova stima PERT.

Non costituisce autorizzazione
a modificare le stime approvate.

Nessuna variazione quantitativa introdotta.
