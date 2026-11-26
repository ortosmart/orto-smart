# RC02-OBS-001 - Osservazioni tecniche

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controlli 01, 02 e 03.1.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Stato: PARZIALE.
- Ambiente verificato: codice Git e PostgreSQL locale.
- Ambiente remoto: NV.

## 2. Osservazioni inventario

| ID | Osservazione |
|---|---|
| OBS01 | Individuate nove RPC pubbliche di gestione edit lock |
| OBS02 | Individuati tre helper privati nel perimetro iniziale |
| OBS03 | RPC request takeover ridefinita in migrazione successiva |
| OBS04 | Corrispondenza numerica 12/12 delle funzioni individuate |
| OBS05 | Firme e privilegi delle funzioni verificati |
| OBS06 | Integrazione effettiva nei domini ancora da verificare |
| OBS07 | Configurazione remota non verificata |
| OBS08 | Nessuna esecuzione delle nove RPC consentita ad anon |
| OBS09 | Nessuna esecuzione diretta dei tre helper consentita ad authenticated o anon |
| OBS10 | Validazioni interne delle RPC ancora da approfondire |

Riferimenti: INF-WA-001, DB-WA-001.

## 3. Osservazioni struttura edit lock

| ID | Osservazione |
|---|---|
| OBS11 | Al massimo un record edit lock per profilo |
| OBS12 | Identita distinte di utente, client e sessione |
| OBS13 | Hash del token vincolato a 32 byte |
| OBS14 | Vincoli temporali su acquisizione, heartbeat e scadenza |
| OBS15 | Coerenza delle colonne della richiesta takeover |
| OBS16 | Coerenza delle colonne del grant takeover |
| OBS17 | Richiesta e grant mutuamente esclusivi |
| OBS18 | Vincolo temporale sul periodo di silenzio |
| OBS19 | Presenza di row_version |
| OBS20 | Incrementi effettivi della versione nelle RPC da verificare |
| OBS21 | Protezione dei metadati verificata soltanto parzialmente |
| OBS22 | Utilizzo SHA-256 confermato |
| OBS23 | Dipendenze referenziali con eliminazione RESTRICT |
| OBS24 | RLS attiva |
| OBS25 | FORCE RLS non attiva |
| OBS26 | Nessuna scrittura diretta rilevata nei privilegi esaminati |
| OBS27 | Nessun accesso alla tabella consentito ad anon |
| OBS28 | SELECT consentito ad authenticated su tutte le 18 colonne |
| OBS29 | Hash del token leggibile dai membri autorizzati |
| OBS30 | Nessun privilegio INSERT o UPDATE sulle singole colonne per i ruoli esaminati |
| OBS31 | Necessita della lettura diretta di tutte le colonne da verificare |
| OBS32 | Minimizzazione dei privilegi SELECT da valutare |

Riferimento: DB-WA-002.

La lettura dell'hash non dimostra una compromissione del token.
Esposizione effettiva mediante Data API da verificare.
Nessuna modifica dei privilegi approvata.

## 4. Osservazioni helper autoritativi

| ID | Osservazione |
|---|---|
| OBS33 | Serializzazione mediante SELECT FOR UPDATE |
| OBS34 | Acquisizione clock_timestamp dopo attesa del blocco |
| OBS35 | Rivalutazione delle condizioni di autorita |
| OBS36 | Rifiuto dei parametri nulli |
| OBS37 | Controllo della finestra grant di 60 secondi |
| OBS38 | Helper di verifica titolare e helper autoritativo non intercambiabili |
| OBS39 | Dipendenza is_profile_auth_user_owner da esaminare |
| OBS40 | Generazione ed entropia del token da verificare |
| OBS41 | Utilizzo corretto degli helper nelle RPC di dominio da verificare |

Riferimento: DB-WA-003.

## 5. Interpretazione delle osservazioni

Le osservazioni comprendono evidenze strutturali positive,
caratteristiche tecniche, limiti, dipendenze e possibili miglioramenti.

Non costituiscono 41 non conformita.
Non costituiscono 41 nuovi pacchetti di sviluppo.
Non attribuire automaticamente classificazioni P0-P3.
Le eventuali non conformita richiedono evidenze specifiche.

## 6. Collegamenti

- RC01, RC02, RC03, RC04, RC05.
- NC-RC01-001.
- INF-WA-001.
- DB-WA-001.
- DB-WA-002.
- DB-WA-003.

NC-RC01-001 rimane aperta e distinta dalle osservazioni RC02.

## 7. Stato quantitativo

- Osservazioni consolidate: 41.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

Nessuna variazione delle stime derivante dal numero di osservazioni.

## 8. Limiti del consolidamento

Inventario sintetico ricostruito dalle evidenze gia acquisite.
Non costituisce trascrizione integrale degli output SQL originari.
Nessun nuovo collaudo eseguito.

Nessuna modifica tecnica introdotta.
