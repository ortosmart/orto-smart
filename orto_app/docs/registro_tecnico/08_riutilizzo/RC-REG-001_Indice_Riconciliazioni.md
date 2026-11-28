# RC-REG-001 - Indice delle riconciliazioni

## 1. Identificazione

- Versione: 1.3.
- Sessione originaria: S046.
- Sessione aggiornamento: S048.
- Data: 27/11/2026.
- Origine: STEP 275.6.4.
- Aggiornamento: consolidamento intermedio RC02.07.
- Baseline Git originaria: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline Git aggiornamento: d1de8f659b52605aa52941ea33e920db5d684bd7.
- Ricognizioni previste: 18.
- Ricognizioni tecniche concluse: 9.
- Ricognizioni quantitative concluse: 0.

### 1.1. Storico delle versioni

| Versione | Sessione | Contenuto |
|---|---|---|
| 1.1 | S046 | Consolidamento RC01 e ricognizione SQL RC02.01-05 |
| 1.2 | S047 | Aggiornamento ricognizione Flutter RC02.06 |
| 1.3 | S048 | Stato RC02.07 ed evidenze di Orti, Aiuole e Stagioni |

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
| RC02 | Write Authority ed edit lock | V1-02 | Concluso | Aperto |
| RC03 | RLS, permessi e RPC | V1-02 | Concluso | Aperto |
| RC04 | Versioni e concorrenza | V1-02 | Concluso | Aperto |
| RC05 | Journal, ricevute e riconciliazione | V1-02 | Concluso | Aperto |
| RC06 | Backup e ripristino | V1-03 | Concluso | Aperto |
| RC07 | Migrazioni e ambienti | V1-04 | Conclusa tecnicamente e approvata, DB-MIG-001 §1.3 | Aperto |
| RC08 | Geometrie e storico | V1-06 | Conclusa tecnicamente e approvata, PRC-001 §2.2 | Aperto |
| RC09 | Stagioni e temporalita | V1-07 | Conclusa tecnicamente e approvata, PRC-001 §4.2 | Aperto |
| RC10 | Catalogo e identita canoniche | V1-08 | Conclusa tecnicamente (E4, S048), INF-CAT-001 §2.14 | Aperto |
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

Ricognizione tecnica conclusa in S048.

### 9.1. Avanzamento dei controlli

- Controlli formalmente conclusi: 10/10.
- Avanzamento formale per numero di controlli: 100%.
- Controlli 01-10: conclusi.
- Controllo 07: concluso, 10/10 sottoblocchi completati.
- Controllo 10: concluso.
- Riconciliazione quantitativa: aperta.

Le percentuali rappresentano il numero
di controlli conclusi e non la maturita
complessiva della Write Authority.

### 9.2. Evidenze consolidate S046

- RPC pubbliche analizzate: 9/9.
- Helper privati esaminati: 4.
- Osservazioni storiche: 253.
- Controlli strutturali RPC: 180.
- Famiglie trasversali di verifiche residue: 15.
- Livello delle evidenze SQL: E3.

Il Registro tecnico permanente e stato
istituito e pubblicato su GitHub.

La precedente sospensione al controllo
03.2 e stata superata.

La definizione della funzione privata
is_profile_auth_user_owner e stata acquisita.

Sono stati inoltre esaminati acquisizione,
rilascio, heartbeat, stato del lock
e lifecycle completo del takeover.

### 9.3. Evidenze acquisite S047

- RPC integrate nel repository Flutter: 3/9.
- Stati SQL complessivi: 48.
- Stati decodificati dal repository Flutter: 12.
- Stati non integrati: 36.
- Suite Flutter mirate: 7/7 PASS.
- Test Flutter mirati: 116/116 PASS.
- Baseline generale Flutter: 1956/1956 PASS.
- Nuovi test introdotti: 0.
- Nuove osservazioni tecniche: 107.
- Osservazioni complessive salvate localmente: 360.
- Verifiche specifiche residue C01-C09: 9.
- Famiglie trasversali residue WA-V01-WA-V15: 15.
- Famiglie integralmente chiuse: 0.

Le tre RPC integrate sono Acquire,
Heartbeat e Release.

Get State e le cinque RPC Takeover
non risultano integrate nel repository Flutter esaminato.

Livello complessivo: E3.
Evidenze specifiche collaudate: E4.
Collaudo integrato reale: NV.
Ambiente remoto: NV.

I collaudi Flutter mirati utilizzano
dipendenze simulate.

Le evidenze condivise con RC01 e RC05
non devono essere conteggiate due volte.

### 9.4. Punto di ripresa

Completati DOC.09, DOC.10 e la ricognizione tecnica RC02.
Alla chiusura S048, punto di ripresa: RC11 — Registri, unità e parametri.

Non ripetere i controlli 01-06
se le condizioni tecniche rimangono invariate
e le evidenze consolidate sono ancora valide.

### 9.5. Riferimenti operativi

- [Stato parziale RC02](RC02_Stato_Parziale.md)
- [Osservazioni tecniche RC02](RC02-OBS-001_Osservazioni_Tecniche.md)
- [Inventario Write Authority](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md)
- [Infrastruttura Flutter Write Authority](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md)
- [Integrazione Write Authority nei domini](../02_infrastrutture/INF-WA-003_Integrazione_Write_Authority_Domini.md)
- [Lifecycle e contratti RPC](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Evidenze strutturali SQL](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md)
- [Evidenze collaudi Flutter](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md)
- [Evidenze collaudi dei domini](../06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md)
- [Stato operativo corrente](../10_stato_operativo/STATO_CORRENTE.md)

### 9.6. Limiti e dipendenze

Il completamento strutturale
non equivale al superamento
dei collaudi funzionali complessivi.

Le 15 famiglie residue non costituiscono
automaticamente nuovi pacchetti di sviluppo.

NC-RC01-001 rimane aperta,
classificazione P1.

Nessuna nuova non conformita
formalmente approvata.

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

- RC tecniche concluse: 10/18 (55,56%), da RC01 a RC10.
- RC tecniche in corso: 0/18.
- RC tecniche da eseguire: 8/18, da RC11 a RC18.
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

Indice originariamente ricostruito
dalle conoscenze acquisite nella sessione S046.

Aggiornato nella sessione S047
con le evidenze Flutter RC02.06.

La chiusura tecnica di una RC
non equivale alla risoluzione
di tutte le non conformita rilevate.

Le singole schede RC devono conservare
le evidenze e le limitazioni specifiche.

Le evidenze condivise fra riconciliazioni
non determinano duplicazioni automatiche
delle attivita o delle stime.

Nessuna variazione quantitativa introdotta.

### Attestazione conclusiva RC02.06 - S047

Data: 26/11/2026.

Le verifiche cumulative RC02.06.10.9
sono state completate: 6/6 PASS.

- Flutter analyze: PASS.
- Flutter test generale: 1956/1956 PASS.
- Collaudi mirati Flutter: 116/116 PASS.
- Osservazioni tecniche: 360/360.
- Osservazioni storiche preservate: 253/253.
- Git diff --check: codice di uscita 0.

Le indicazioni di versionamento pendente
presenti nel documento descrivono lo stato
precedente alla pubblicazione S047.

Subordinatamente al completamento del commit,
del push e alla verifica della sincronizzazione Git:

- RC02.06: concluso formalmente.
- RC02: 6/10 controlli conclusi, 60%.
- Prossimo controllo tecnico: RC02.07.
- Riconciliazioni tecniche concluse: 1/18.
- Riconciliazioni quantitative concluse: 0/18.

La conclusione riguarda la ricognizione
dell infrastruttura Flutter e non equivale
alla completa maturita della Write Authority.

Livello complessivo E3.
E4 limitato ai comportamenti collaudati.
Verifiche integrate reali e remote: NV.

Restano aperte le 15 famiglie trasversali
e i 9 controlli specifici Flutter.

Nessuna variazione PERT.
Nessuna nuova non conformita formalizzata.
Nessuna modifica applicativa o SQL.

L effettiva pubblicazione e attestata
dalle evidenze Git e dal checkpoint S047.
