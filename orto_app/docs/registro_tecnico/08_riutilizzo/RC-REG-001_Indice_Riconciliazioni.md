# RC-REG-001 - Indice delle riconciliazioni

## 1. Identificazione

- Versione: 1.1.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: STEP 275.6.4.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ricognizioni previste: 18.
- Ricognizioni tecniche concluse: 1.
- Ricognizioni quantitative concluse: 0.

## 2. Finalita

Individuare le infrastrutture disponibili,
le possibilita di riutilizzo e il lavoro
effettivamente ancora necessario.

Evitare nuove ricognizioni integrali
di componenti gia verificati.

Distinguere disponibilita tecnica,
integrazione, collaudo e operativita.

## 3. Indice delle riconciliazioni

| ID | Infrastruttura | Macroblocco principale | Stato tecnico | Stato quantitativo |
|---|---|---|---|---|
| RC01 | Autenticazione, identita e profilo | V1-01 | Concluso | Aperto |
| RC02 | Write Authority ed edit lock | V1-02 | In corso | Aperto |
| RC03 | RLS, permessi e RPC | V1-02 | Da eseguire | Aperto |
| RC04 | Versioni e concorrenza | V1-02 | Da eseguire | Aperto |
| RC05 | Journal, ricevute e riconciliazione | V1-02 | Da eseguire | Aperto |
| RC06 | Backup e ripristino | V1-03 | Da eseguire | Aperto |
| RC07 | Migrazioni e ambienti | V1-04 | Da eseguire | Aperto |
| RC08 | Geometrie e storico | V1-06 | Da eseguire | Aperto |
| RC09 | Stagioni e temporalita | V1-07 | Da eseguire | Aperto |
| RC10 | Catalogo e identita canoniche | V1-08 | Da eseguire | Aperto |
| RC11 | Registri, unita e parametri | V1-08 | Da eseguire | Aperto |
| RC12 | Resolver e acquisizione conoscenza | V1-08 | Da eseguire | Aperto |
| RC13 | Motori agronomici | V1-09 | Da eseguire | Aperto |
| RC14 | Lifecycle pianificazioni | V1-10 | Da eseguire | Aperto |
| RC15 | Lifecycle coltivazioni | V1-11 | Da eseguire | Aperto |
| RC16 | Flutter e navigazione | Trasversale | Da eseguire | Aperto |
| RC17 | Collaudi e distribuzione | V1-17/V1-18 | Da eseguire | Aperto |
| RC18 | Conoscenza e documentazione | Trasversale | Da eseguire | Aperto |

Lo stato Da eseguire riguarda la specifica
riconciliazione RC, non l'assenza di codice
o di evidenze tecniche precedenti.

## 4. Contenuto delle schede RC

Ogni riconciliazione deve identificare:

- ID e responsabilita.
- Macroblocco principale.
- Macroblocchi utilizzatori.
- Riferimenti DUP-A e DUP-B.
- Componenti esistenti.
- Percorsi dei file.
- Simboli e contratti tecnici.
- Dipendenze.
- Vincoli di sicurezza.
- Evidenze disponibili.
- Commit ed ambiente verificato.
- Livello di evidenza.
- Collaudi disponibili.
- Limitazioni.
- Non conformita.
- Integrazioni mancanti.
- Possibilita di riutilizzo.
- Stime originarie pertinenti.
- Lavoro gia escluso dalle stime.
- Eventuali variazioni quantitative.
- Approvazione.

## 5. Classificazione del riutilizzo

RIUTILIZZARE:

Componente disponibile e pertinente,
con evidenza sufficiente al nuovo utilizzo.

INTEGRARE:

Componente disponibile, ma richiede
collegamento o adattamento al nuovo dominio.

VERIFICARE:

Evidenza insufficiente o non piu valida
per il contesto di utilizzo previsto.

SVILUPPARE:

Componente o comportamento necessario
non ancora disponibile.

Utilizzare i livelli di evidenza definiti
nello standard ARC-REG-001.

## 6. Casi di riconciliazione quantitativa

Caso 1:

Infrastruttura realizzata e gia esclusa
dalla stima residua.

Nessuna ulteriore riduzione.

Caso 2:

Infrastruttura realizzata ma ancora
compresa nella stima residua.

Possibile riduzione documentata.

Caso 3:

Infrastruttura parzialmente realizzata.

Rivalutare il lavoro effettivamente residuo.

Caso 4:

Infrastruttura disponibile ma non integrata.

Mantenere le attivita di integrazione
e i collaudi ancora necessari.

Caso 5:

Infrastruttura non verificata.

Mantenere aperta la riconciliazione.

## 7. Dipendenze quantitative condivise

RC02, RC03, RC04 e RC05 fanno riferimento
alla medesima baseline V1-02:

- A: 11:00.
- B: 24:55.
- Totale: 35:55.

Questi valori non costituiscono quattro
pacchetti di lavoro indipendenti.

RC10, RC11 e RC12 condividono V1-08:

- A: 103:40.
- B: 70:50.
- Totale: 174:30.

Anche in questo caso non moltiplicare
la baseline per il numero di RC.

RC16, RC17 e RC18 possono interessare
piu macroblocchi.

La ripartizione delle ore richiede
la riconciliazione dei pacchetti originari.

## 8. Stato RC01

Ricognizione tecnica conclusa
e approvata nella sessione S046.

- Controlli tecnici: 8/8.
- Infrastrutture individuate: 20.
- Elementi residui o da verificare: 30.
- NC-RC01-001: aperta, classificazione P1.
- Riconciliazione quantitativa: aperta.

I trenta elementi residui non costituiscono
automaticamente trenta nuovi pacchetti.

La non conformita deve essere approfondita
nelle riconciliazioni pertinenti.

Nessuna correzione tecnica autorizzata.

## 9. Stato RC02

Ricognizione tecnica in corso.

- Controlli principali: 5/10 conclusi strutturalmente.
- Avanzamento per numero di controlli: 50%.
- Controlli 01-05: conclusi strutturalmente.
- Controlli 06-10: ancora aperti.
- RPC pubbliche analizzate: 9/9.
- Helper privati esaminati: 4.
- Osservazioni consolidate localmente: 253.
- Controlli strutturali RPC: 180.
- Famiglie trasversali di verifiche residue: 15.
- Livello delle evidenze SQL: E3.
- Ambiente remoto: NV.
- Riconciliazione quantitativa: aperta.

Il Registro tecnico permanente e stato
istituito e pubblicato su GitHub.

La precedente sospensione al controllo
03.2 e stata superata.

La definizione della funzione privata
is_profile_auth_user_owner e stata acquisita.

Sono stati inoltre esaminati acquisizione,
rilascio, heartbeat, stato del lock
e lifecycle completo del takeover.

Punto di ripresa:

RC02.06 - Controller, scheduler,
scope e gate Flutter.

Prima della ripresa completare
la verifica e il versionamento
del consolidamento aggiuntivo.

Riferimenti operativi:

- [Stato parziale RC02](RC02_Stato_Parziale.md)
- [Osservazioni tecniche RC02](RC02-OBS-001_Osservazioni_Tecniche.md)
- [Inventario Write Authority](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md)
- [Lifecycle e contratti RPC](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Evidenze strutturali SQL](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md)
- [Stato operativo corrente](../10_stato_operativo/STATO_CORRENTE.md)

Non ripetere i controlli 01-05
se le condizioni tecniche
rimangono invariate.

Il completamento strutturale
non equivale al superamento
dei collaudi funzionali.

Le 15 famiglie residue non costituiscono
automaticamente nuovi pacchetti di sviluppo.

NC-RC01-001 rimane aperta, classificazione P1.

Nessuna variazione quantitativa approvata.

## 10. Procedura di consultazione

Prima di una nuova ricognizione:

1. Consultare questo indice.
2. Consultare la scheda RC pertinente.
3. Consultare le infrastrutture collegate.
4. Verificare il commit di riferimento.
5. Individuare eventuali modifiche.
6. Recuperare soltanto le evidenze mancanti.
7. Aggiornare le schede interessate.

Non ripetere indiscriminatamente
le verifiche gia valide.

Il codice e il database effettivo
rimangono le fonti tecniche autorevoli.

## 11. Stato complessivo

- RC tecniche concluse: 1/18.
- RC tecniche in corso: 1/18.
- RC tecniche da eseguire: 16/18.
- RC quantitative concluse: 0/18.
- DUP-A quantitative concluse: 0/9.
- DUP-B quantitative concluse: 0/12.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

## 12. Collegamenti e limiti

- ARC-REG-001.
- DUP-A-001.
- DUP-B-001.
- V1-MET-001.
- V1-EST-001.
- V1-EST-003.

Indice ricostruito dalle conoscenze
acquisite durante la sessione S046.

La chiusura tecnica di una RC
non equivale alla risoluzione
di tutte le non conformita rilevate.

Le singole schede RC devono conservare
le evidenze e le limitazioni specifiche.

Nessuna variazione quantitativa introdotta.
