# RC02 - Stato parziale della ricognizione

## 1. Identificazione

- Identificativo: RC02.
- Versione: 1.2.
- Sessione originaria: S046.
- Sessione aggiornamento: S047.
- Data: 26/11/2026.
- Macroblocco principale: V1-02.
- Baseline Git originaria: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline Git aggiornamento: 39665b458221b69c469ebe1d16a686312af79320.
- Stato tecnico: IN CORSO.
- Stato quantitativo: APERTO.
- Evidenza complessiva: E3.
- Evidenze specifiche collaudate: E4.
- Collaudo integrato reale: NV.
- Ambiente remoto: NV.

### 1.1. Storico delle versioni

| Versione | Sessione | Contenuto |
|---|---|---|
| 1.1 | S046 | Consolidamento ricognizione SQL RC02.01-05 |
| 1.2 | S047 | Consolidamento ricognizione Flutter RC02.06 |

## 2. Oggetto

Write Authority, edit lock, single-writer e integrazione
con i percorsi autoritativi.

La ricognizione identifica le infrastrutture disponibili,
i relativi contratti e le verifiche ancora necessarie.

## 3. Piano dei controlli

| ID | Controllo | Stato |
|---|---|---|
| 01 | Inventario Flutter, SQL e test | Concluso |
| 02 | Struttura profile_edit_locks | Concluso strutturalmente |
| 03 | Helper, acquisizione e rilascio RPC | Concluso strutturalmente |
| 04 | Heartbeat, scadenza e rinnovo | Concluso strutturalmente |
| 05 | Lifecycle takeover | Concluso strutturalmente |
| 06 | Controller, scheduler, scope e gate Flutter | Ricognizione conclusa; consolidamento finale pendente |
| 07 | Integrazione nei domini | Da eseguire |
| 08 | Approfondimento NC-RC01-001 | Da eseguire |
| 09 | Test ed evidenze integrate | Da eseguire |
| 10 | Conclusione tecnica | Da eseguire |

Controlli formalmente conclusi: 5/10.
Controlli con ricognizione acquisita: 6/10.

Avanzamento previsto dopo la chiusura RC02.06: 60%.

Non costituisce percentuale di maturita della Write Authority.

La conclusione della ricognizione dei controlli 01-06
non equivale al superamento dei collaudi funzionali
e integrati complessivi.

## 4. Dettaglio delle verifiche eseguite

Controllo 01:

- 01.1: inventario dei file.
- 01.2: dichiarazioni SQL.
- 01.3: funzioni installate e privilegi.

Controllo 02:

- 02.1: struttura tabella edit lock.
- 02.2: RLS e privilegi tabella.
- 02.3: privilegi sulle colonne.

Controllo 03:

- 03.1: definizioni dei tre helper iniziali.
- 03.2: dipendenza owner esplicita.
- 03.3: acquisizione del lock.
- 03.4: rilascio del lock.

Controllo 04:

- 04.1: heartbeat e rinnovo.
- 04.2: consultazione dello stato del lock.

Controllo 05:

- 05.1: richiesta takeover.
- 05.2: annullamento richiesta.
- 05.3: rifiuto richiesta e silenziamento.
- 05.4: concessione takeover.
- 05.5: completamento takeover.
- 05.6: confronto storico request e riconciliazione lifecycle.

I controlli 01-05 sono conclusi
nel rispettivo perimetro strutturale.

Controllo 06:

- 06.1: modelli e contratti Flutter.
- 06.2: repository RPC.
- 06.3: controller Write Authority.
- 06.4: scheduler e scadenze.
- 06.5: scope e propagazione.
- 06.6: disponibilita di scrittura delle route e widget.
- 06.7: lifecycle takeover Flutter.
- 06.8: errori, recupero autorita e ProfileSessionGate.
- 06.9: riconciliazione Flutter-PostgreSQL.
- 06.10: consolidamento delle evidenze.

Le evidenze dei controlli 06.1-06.9
sono state acquisite.

Il controllo 06.10 rimane subordinato
alle verifiche cumulative e al versionamento.

Non ripetere i controlli conclusi se le condizioni
tecniche rimangono invariate.

Le verifiche funzionali residue devono essere
riconciliate con le evidenze di collaudo esistenti.

## 5. Evidenze consolidate

| Scheda | Contenuto |
|---|---|
| INF-WA-001 | Inventario Flutter, migrazioni e test |
| INF-WA-002 | Infrastruttura Flutter Write Authority |
| DB-WA-001 | Inventario RPC e helper |
| DB-WA-002 | Struttura edit lock e privilegi |
| DB-WA-003 | Contratti dei quattro helper esaminati |
| DB-WA-004 | Acquisizione e rilascio lock |
| DB-WA-005 | Heartbeat e stato lock |
| DB-WA-006 | Protocollo takeover |
| DB-WA-007 | Lifecycle e contratti RPC |
| TST-RC02-001 | Evidenze strutturali SQL |
| TST-RC02-002 | Evidenze collaudi Flutter |
| RC02-OBS-001 | Osservazioni tecniche |

### 5.1. Evidenze strutturali SQL S046

- 40 file individuati nella ricerca iniziale.
- 13 dichiarazioni SQL inizialmente individuate.
- 12 funzioni distinte installate nel perimetro iniziale.
- 9 RPC pubbliche analizzate strutturalmente.
- 3 helper privati del perimetro iniziale.
- 1 helper owner aggiuntivo esaminato.
- 4 helper privati complessivamente esaminati.
- 18 colonne della tabella edit lock.
- 10 vincoli CHECK.
- 253 osservazioni storiche consolidate.
- 180 controlli strutturali sulle nove RPC.
- 15 famiglie trasversali di verifiche residue.

La dipendenza owner aggiuntiva non e compresa
nel conteggio iniziale delle dodici funzioni.

### 5.2. Evidenze del lifecycle

- Lease ordinario: 120 secondi.
- Richiesta takeover: 600 secondi.
- Concessione takeover: 60 secondi.
- Silenziamento: 5, 15 o 30 minuti.
- Token generato dal server mediante 32 byte casuali.
- Memorizzazione del solo hash SHA-256.
- Serializzazione delle mutazioni protette mediante helper autoritativo.
- Sospensione delle mutazioni protette durante il grant valido.
- Sostituzione del token al completamento takeover.

### 5.3. Evidenze Flutter S047

| Indicatore | Risultato |
|---|---:|
| RPC integrate nel repository Flutter | 3/9 |
| Stati SQL complessivi | 48 |
| Stati decodificati dal repository Flutter | 12 |
| Stati non integrati | 36 |
| Suite mirate superate | 7/7 |
| Test mirati superati | 116/116 |
| Test falliti | 0 |
| Baseline generale Flutter | 1956/1956 |
| Nuovi test introdotti | 0 |
| Osservazioni aggiuntive | 107 |
| Osservazioni complessive | 360 |
| Verifiche specifiche residue C01-C09 | 9 |
| Famiglie residue WA-V01-WA-V15 | 15 |
| Famiglie integralmente chiuse | 0 |

Heartbeat ordinario: 30 secondi.
Intervallo di recupero: 10 secondi.

Le tre RPC integrate sono Acquire,
Heartbeat e Release.

Get State e le cinque RPC Takeover
non risultano integrate nel repository Flutter esaminato.

I 116 test mirati non devono essere sommati
automaticamente alla baseline generale.

### 5.4. Livello delle evidenze

Le definizioni SQL esaminate costituiscono
evidenze strutturali E3.

Il confronto storico della RPC request
e stato consolidato in DB-WA-006 e TST-RC02-001.

Le 15 famiglie WA-V01-WA-V15
sono documentate in DB-WA-007.

Non costituiscono automaticamente
15 nuovi pacchetti di sviluppo.

Nessun nuovo collaudo funzionale
eseguito durante il consolidamento S046.

I collaudi mirati Flutter S047
utilizzano dipendenze simulate.

Il livello E4 riguarda esclusivamente
i comportamenti effettivamente collaudati.

Il livello complessivo rimane E3.

Collaudo integrato reale: NV.
Ambiente remoto: NV.

### 5.5. Riferimenti di approfondimento

- [INF-WA-002](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md).
- [TST-RC02-002](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md).
- [RC02-OBS-001](RC02-OBS-001_Osservazioni_Tecniche.md).
- [DB-WA-007](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md).

## 6. Dipendenze

- INF-AUTH-001.
- INF-ID-001.
- FLT-PROF-001.
- DB-PROF-001.
- DB-SEC-001.
- DB-VER-001.
- RC01, RC03, RC04, RC05, RC07, RC17.

Non conformita collegata:
NC-RC01-001, P1, aperta.

## 7. Baseline quantitativa

Macroblocco V1-02:

- Maturita tecnica A: 85,65%.
- Maturita tecnica V1: 72,35%.
- Residuo A: 11:00.
- Residuo B: 24:55.
- Residuo complessivo: 35:55.

La baseline e' condivisa fra RC02, RC03, RC04 e RC05.
Non moltiplicare le ore per il numero di riconciliazioni.

Riconciliazione PERT originaria: aperta.
Riduzioni approvate: 0 minuti.
Incrementi approvati: 0 minuti.

## 8. Punto esatto di ripresa

### 8.1. Consolidamento corrente

Completare RC02.06.10:

- Aggiornamento dello stato e degli indici.
- Verifiche cumulative di integrita.
- Versionamento e chiusura.

Non considerare formalmente concluso RC02.06
prima del completamento di tali verifiche.

### 8.2. Controllo tecnico successivo

RC02.07 - Integrazione nei domini.

Obiettivo:

Verificare i percorsi effettivi di scrittura
dei domini applicativi e la loro integrazione
con la Write Authority esistente.

Utilizzare le evidenze gia consolidate in:

- INF-WA-001.
- INF-WA-002.
- DB-WA-001 - DB-WA-007.
- TST-RC02-001.
- TST-RC02-002.
- RC02-OBS-001.

Verificare progressivamente:

- Inventario dei percorsi di mutazione.
- Collegamento dei repository alle RPC autoritative.
- Acquisizione e validazione del lease.
- Propagazione di token e identita.
- Utilizzo di row_version ove previsto.
- Gestione degli errori e dei conflitti.
- Disponibilita di scrittura nelle pagine e nelle route.
- Lifecycle effettivo delle route, incluso PlanningRouteLifetime.
- Dipendenze condivise con RC03, RC04 e RC05.
- Evidenze di collaudo gia disponibili.

Il piano analitico del controllo RC02.07
deve essere definito alla ripresa effettiva.

Non ripetere la ricognizione strutturale
SQL e Flutter gia acquisita.

Conservare aperte le verifiche residue
C01-C09 e WA-V01-WA-V15.

NC-RC01-001 rimane aperta
e sara approfondita nel controllo RC02.08.

## 9. Procedura successiva

Prima della chiusura RC02.06:

- Completare l'aggiornamento degli indici.
- Verificare integrita e persistenza del Registro.
- Ottenere autorizzazione al commit e al push.
- Verificare la baseline Git risultante.

Dopo la chiusura RC02.06:

- Consultare le schede tecniche pertinenti.
- Definire il piano analitico RC02.07.
- Proseguire con RC02.07-10.
- Sottoporre la conclusione tecnica ad approvazione.
- Riconciliare separatamente la baseline quantitativa.

Procedere un comando alla volta.

Aggiornare il Registro alla conclusione
dei controlli tecnici significativi,
evitando duplicazioni documentali.

Non introdurre correzioni applicative
senza la relativa autorizzazione.

Non applicare migrazioni remote
senza autorizzazione esplicita.

## 10. Limiti e stato conclusivo

La ricognizione RC02 non e conclusa.

Il consolidamento documentale non aumenta
la maturita tecnica della Write Authority.

Le evidenze locali non attestano
l'equivalenza dell'ambiente remoto.

I collaudi Flutter simulati non attestano
il funzionamento integrato reale con PostgreSQL.

Nessuna nuova non conformita formalmente approvata.
Nessuna correzione applicativa autorizzata.
Nessuna variazione quantitativa introdotta.

Nessuna modifica applicativa introdotta.
Nessuna modifica SQL introdotta.
Nessuna migrazione remota applicata.

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
