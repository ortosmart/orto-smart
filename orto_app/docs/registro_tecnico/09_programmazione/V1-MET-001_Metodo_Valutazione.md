# V1-MET-001 - Metodo permanente di valutazione

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 275.1
- Natura: metodologia approvata
- Baseline sorgenti: 20649de7474765bd1c293b20bfcedab0a9493a14

## 1. Indicatori

| ID | Indicatore |
|---|---|
| IND-01 | Maturita tecnica |
| IND-02 | Operativita reale |
| IND-03 | Avanzamento milestone A |
| IND-04 | Avanzamento V1 definitiva |
| IND-05 | Ore effettivamente lavorate |
| IND-06 | Ore residue A |
| IND-07 | Ore aggiuntive B |
| IND-08 | Ore residue complessive |

Gli indicatori devono rimanere distinti.

Il tempo lavorato non rappresenta automaticamente
la quantita di funzionalita completate.

## 2. Livelli di evidenza

Consultare ARC-REG-001 per la classificazione
E0-E5, NV e NA.

Applicare il livello alla specifica evidenza,
non indiscriminatamente all'intero dominio.

NV non equivale automaticamente a zero.

NA richiede una motivazione.

## 3. Criteri di maturita

| ID | Criterio | Peso |
|---|---|---:|
| CA01 | Requisiti | 5 |
| CA02 | Dati e migrazioni | 15 |
| CA03 | Sicurezza, RPC, RLS e autorita | 15 |
| CA04 | Componenti Flutter | 15 |
| CA05 | Interfaccia raggiungibile | 15 |
| CA06 | Errori, concorrenza e recupero | 10 |
| CA07 | Test automatici | 10 |
| CA08 | Integrazione Flutter-Supabase | 8 |
| CA09 | Verifiche sui dispositivi | 4 |
| CA10 | Documentazione | 3 |
| Totale | | 100 |

Formula:

Maturita =
somma dei prodotti punteggio per peso
divisa per la somma dei pesi applicabili.

I criteri NA vengono esclusi dal denominatore
soltanto quando motivati.

Non attribuire punteggi positivi arbitrari
alle evidenze non verificate.

## 4. Scala indicativa di maturita

| Punteggio | Interpretazione generale |
|---|---|
| 0 | Assente |
| 10 | Impostazione iniziale |
| 25 | Realizzazione iniziale |
| 50 | Realizzazione parziale |
| 75 | Realizzazione avanzata |
| 90 | Quasi completa |
| 100 | Completata rispetto al criterio |

Le descrizioni costituiscono riferimenti indicativi.

Il punteggio deve essere motivato
mediante evidenze pertinenti.

## 5. Operativita reale

Valutare la disponibilita di processi:

- Raggiungibili.
- Autorizzati.
- Persistenti.
- Sicuri.
- Integrati.
- Dotati di gestione degli errori.
- Utilizzabili nell'ambiente previsto.
- Verificati sui dispositivi pertinenti.

La ponderazione definitiva dell'operativita
rimane da consolidare.

Non utilizzare la maturita tecnica
come sostituto dell'operativita reale.

## 6. Categorie di lavoro

| ID | Categoria |
|---|---|
| L01 | Analisi |
| L02 | Database |
| L03 | RPC e sicurezza |
| L04 | Flutter |
| L05 | Interfaccia utente |
| L06 | Integrazione |
| L07 | Test automatici |
| L08 | Collaudi integrati |
| L09 | Collaudi dispositivi |
| L10 | Correzioni e regressione |
| L11 | Documentazione tecnica |
| L12 | Documentazione utente |

I test tecnici appartengono allo sviluppo.

Mantenere distinti i consuntivi storici
Sviluppo e Manuali.

L'introduzione del Registro modifica
la futura gestione documentale,
non i consuntivi storici gia acquisiti.

## 7. Metodo PERT

O = stima ottimistica.
M = stima piu probabile.
P = stima pessimistica.

Condizione:

O <= M <= P

Stima ponderata:

(O + 4*M + P) / 6

La stima PERT non rappresenta
un intervallo di confidenza statistico.

Conservare le stime originarie
quando effettivamente disponibili.

Non ricostruire valori O, M e P
partendo arbitrariamente dal risultato.

## 8. Milestone A e B

H-A = ore residue per il primo rilascio.

H-B = ore aggiuntive dopo il rilascio A.

H-V1 = H-A + H-B.

M-A = maturita del perimetro A.

M-V1 = maturita del perimetro definitivo.

Per i sei macroblocchi esclusivamente B:

- M-A: NA.
- H-A: zero.

Non confondere NA con maturita zero.

## 9. Maturita complessiva

La maturita complessiva dovra essere ponderata
in funzione della dimensione stimata
dei macroblocchi.

La ponderazione definitiva sara consolidata
nello STEP 275.9.

Non utilizzare automaticamente
la media aritmetica delle percentuali.

Il rapporto:

ore effettive / (ore effettive + ore residue)

rappresenta un indicatore temporale,
non la maturita tecnica.

## 10. Aggiornamento delle stime

Ridurre le ore residue in funzione
del lavoro stimato effettivamente completato.

Non sottrarre automaticamente
le ore realmente lavorate.

Distinguere:

- Attivita gia escluse dalle stime.
- Attivita realizzate ancora conteggiate.
- Attivita parzialmente realizzate.
- Infrastrutture disponibili.
- Integrazioni mancanti.
- Nuove necessita dimostrate.

Registrare ogni variazione
con motivazione ed evidenza.

## 11. Limiti della baseline

Le percentuali storiche di maturita tecnica
e operativita riferite a perimetri precedenti
non sono direttamente confrontabili
con il nuovo perimetro V1.

La riconciliazione quantitativa
rimane aperta.

Non determinare date definitive
prima della valutazione delle dipendenze
e delle attivita residue.
