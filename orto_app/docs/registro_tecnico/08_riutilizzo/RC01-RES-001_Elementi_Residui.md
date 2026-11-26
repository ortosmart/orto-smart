# RC01-RES-001 - Elementi residui e verifiche

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: conclusione tecnica RC01.
- Macroblocco principale: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Elementi individuati: 30.

## 2. Inventario

| ID | Elemento residuo o da verificare |
|---|---|
| M01 | Logout |
| M02 | Recupero password |
| M03 | Modifica password |
| M04 | Gestione errori di autenticazione |
| M05 | Gestione errori AuthGate |
| M06 | Uscita dal percorso di errore del profilo |
| M07 | Bootstrap del profilo |
| M08 | Rinnovo della sessione |
| M09 | Persistenza identita su Edge |
| M10 | Persistenza identita su Safari |
| M11 | Inizializzazione concorrente identita client |
| M12 | Comportamento fra schede del browser |
| M13 | Indisponibilita dello Storage locale |
| M14 | Revoca della membership |
| M15 | Interfaccia di gestione del profilo |
| M16 | Modifica autoritativa del nome profilo |
| M17 | Repository degli operatori |
| M18 | Interfaccia degli operatori |
| M19 | Creazione autoritativa operatore |
| M20 | Aggiornamento autoritativo operatore |
| M21 | Gestione dello stato attivo operatore |
| M22 | Titolare come operatore |
| M23 | Gestione delle omonimie |
| M24 | Conservazione dello storico operatori |
| M25 | Collaudo integrato autenticazione |
| M26 | Collaudo integrato profilo |
| M27 | Collaudo integrato operatori |
| M28 | Verifica scritture senza edit lock |
| M29 | Collaudo PC e iPad |
| M30 | Accettazione operativa |

Gli identificativi M01-M30 sono locali
alla ricognizione RC01.

## 3. Interpretazione

L'inventario comprende:

- Funzionalita non individuate
  nel perimetro esaminato.
- Integrazioni da approfondire.
- Comportamenti da verificare.
- Collaudi non ancora dimostrati.
- Condizioni di accettazione.

Non tutti gli elementi costituiscono
funzionalita certamente mancanti.

Non tutti gli elementi richiedono
nuovo sviluppo applicativo.

Non sono trenta nuovi pacchetti
di lavoro da aggiungere alle stime.

## 4. Raggruppamenti di consultazione

Autenticazione e account:

M01-M08.

Identita e comportamento client:

M09-M13.

Autorizzazioni e profilo:

M14-M16.

Gestione degli operatori:

M17-M24.

Collaudi e accettazione:

M25-M30.

Questi raggruppamenti sono organizzativi.

Non costituiscono una sequenza
di sviluppo approvata.

## 5. Riconciliazioni collegate

- RC02: identita, lock e sessioni.
- RC03: autorizzazioni e RLS.
- RC04: versioni e concorrenza.
- RC05: recupero e riconciliazione.
- RC17: collaudi integrati e dispositivi.

Macroblocchi interessati:

- V1-01.
- V1-02.
- V1-13.
- V1-16.
- V1-17.
- V1-18.

La ripartizione definitiva
delle responsabilita e delle ore
deve evitare doppie attribuzioni.

## 6. Non conformita collegata

NC-RC01-001.

Classificazione: P1.

Riguarda i percorsi strutturali
di scrittura diretta individuati
su profiles e workers.

Elementi particolarmente pertinenti:

- M16.
- M19.
- M20.
- M21.
- M28.

Nessuna correzione tecnica
autorizzata durante il consolidamento.

## 7. Regole di aggiornamento

Per ogni elemento:

- Consultare le evidenze esistenti.
- Verificare la pertinenza al perimetro.
- Individuare eventuali dipendenze.
- Distinguere sviluppo e verifica.
- Registrare il risultato.
- Collegare eventuali non conformita.
- Evitare duplicazioni.

Aggiornare lo stato soltanto
in presenza di evidenze sufficienti.

Non dichiarare completato
un elemento non verificato.

## 8. Stato quantitativo

Nessuna attribuzione individuale
di ore ai trenta elementi.

Riconciliazione quantitativa: aperta.

Baseline V1-01 invariata:

- A: 13:05.
- B: 28:55.
- Totale: 42:00.

Le eventuali variazioni devono essere
registrate in V1-EST-003.

Nessuna variazione quantitativa introdotta.
