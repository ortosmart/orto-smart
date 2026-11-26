# Orto Smart - Stato operativo corrente

## 1. Identificazione

- Sessione corrente: S046.
- Data aggiornamento: 26/11/2026.
- Repository: ortosmart/orto-smart.
- Branch di riferimento: main.
- Baseline sorgenti: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline documentale pubblicata: 76acd230567d13e0cd6e6b2376e5b25bba301b38.
- Sessione: IN CORSO.
- Registro tecnico: istituito e operativo.
- Consolidamento aggiuntivo RC02: IN CORSO.

La baseline sorgenti identifica il codice
applicativo oggetto della ricognizione.

La baseline documentale identifica
il primo versionamento del Registro.

Il presente aggiornamento precede
il versionamento aggiuntivo CONS.05.

## 2. Consultazione obbligatoria

- [Indice generale](../README.md)
- [Standard del Registro](../01_architettura/ARC-REG-001_Standard_Registro.md)
- [Baseline iniziale S046](S046_Baseline_Tecnica.md)
- [Indice riconciliazioni](../08_riutilizzo/RC-REG-001_Indice_Riconciliazioni.md)

Il presente documento identifica lo stato operativo.
Le schede specialistiche conservano le evidenze autorevoli.
Il codice e il database effettivo rimangono le fonti tecniche primarie.

## 3. Stato della sessione S046

| STEP | Attivita | Stato |
|---|---|---|
| 271 | Checkpoint iniziale | Concluso |
| 272 | Ricognizione documentale | Concluso con perimetro ridotto approvato |
| 273 | Inventario tecnico | Concluso |
| 274 | Perimetro V1 | Concluso |
| 275 | Valutazione e riconciliazione | In corso |
| 275.R | Registro tecnico permanente | Concluso |
| 276 | Sequenza operativa | Da iniziare |
| 277 | Programmazione rilasci | Da iniziare |
| 278 | Consolidamento Registro | Da iniziare |

## 4. Stato del Registro permanente

| Attivita | Stato |
|---|---|
| 275.R.01 | Conclusa |
| 275.R.02 | Conclusa |
| 275.R.03 | Conclusa |
| 275.R.04 | Conclusa |
| 275.R.05 | Conclusa |
| 275.R.06 | Conclusa |
| 275.R.07 | Conclusa |
| 275.R.08 | Conclusa |
| 275.R.09 | Conclusa |

Attivita integralmente concluse: 9/9.

### 4.1. Baseline documentale pubblicata

Commit:

76acd230567d13e0cd6e6b2376e5b25bba301b38

Messaggio:

Introduce il Registro tecnico permanente di Orto Smart S046

Evidenze del primo versionamento:

- Commit completato.
- Push origin main completato.
- HEAD e origin/main coincidenti.
- Working tree pulita dopo il push.
- 45 file interessati.
- 44 nuovi documenti del Registro.
- Un documento storico modificato e preservato.
- 9204 righe aggiunte.
- Nessuna riga eliminata.
- Nessuna modifica applicativa o alle migrazioni.

Verifiche della baseline iniziale:

- 44 documenti Markdown.
- 10 sottocartelle.
- 43 documenti indicizzati.
- Nessun file vuoto.
- Verifica logica mirata: 13/13 documenti.
- Collegamenti locali verificati: 61/61.
- Collegamenti mancanti: 0.
- Diff documento storico: 22 righe aggiunte, nessuna eliminata.

Dimensione storica verificata prima
dell aggiornamento conclusivo iniziale:
206539 byte.

Questi valori si riferiscono alla
baseline iniziale e non alla consistenza
del consolidamento aggiuntivo.

### 4.2. Consolidamento aggiuntivo RC02

| Attivita | Stato |
|---|---|
| CONS.01 - Baseline Git | Conclusa |
| CONS.02 - Schede tecniche | Conclusa |
| CONS.03 - Osservazioni | Conclusa |
| CONS.04 - Allineamento Registro | In corso |
| CONS.05 - Integrita e versionamento | Da eseguire |

Consistenza locale acquisita:

- 49 documenti Markdown.
- 10 directory tematiche.
- 48 documenti indicizzati.
- 5 nuove schede tecniche RC02.
- 253 osservazioni consolidate localmente.
- 41 osservazioni presenti nella baseline pubblicata.
- 212 osservazioni aggiuntive da versionare.
- 9 RPC pubbliche analizzate strutturalmente.
- 180 controlli strutturali RPC.
- 4 helper privati esaminati.
- 15 famiglie trasversali di verifiche residue.

La verifica conclusiva dei collegamenti
e dell integrita complessiva deve essere
completata prima del nuovo commit.

Il presente documento rappresenta
lo stato precedente al commit CONS.05.

La pubblicazione successiva deve essere
attestata mediante le evidenze Git effettive.

## 5. Stato delle riconciliazioni

- RC01: conclusa tecnicamente e approvata.
- RC02: in corso, 5/10 controlli principali conclusi strutturalmente.
- RC03-RC18: da eseguire.
- Riconciliazioni quantitative concluse: 0/18.

Avanzamento RC02 per numero di controlli: 50%.

Non costituisce percentuale di maturita
tecnica della Write Authority.

Controlli RC02 conclusi:

- 01: inventario Flutter, SQL e test.
- 02: struttura edit lock e privilegi.
- 03: helper, acquisizione e rilascio.
- 04: heartbeat e stato lock.
- 05: lifecycle takeover.

Controlli RC02 ancora aperti:

- 06: infrastrutture Flutter.
- 07: integrazione nei domini.
- 08: approfondimento NC-RC01-001.
- 09: test ed evidenze integrate.
- 10: conclusione tecnica.

Riferimenti:

- [Conclusione RC01](../08_riutilizzo/RC01_Conclusione_Tecnica.md)
- [Stato parziale RC02](../08_riutilizzo/RC02_Stato_Parziale.md)
- [Osservazioni RC02](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [Helper autoritativi](../03_database/DB-WA-003_Helper_Autorita_Scrittura.md)
- [Acquisizione e rilascio](../03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [Heartbeat e stato](../03_database/DB-WA-005_Heartbeat_Stato_Lock.md)
- [Protocollo takeover](../03_database/DB-WA-006_Protocollo_Takeover.md)
- [Lifecycle e contratti RPC](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Evidenze strutturali SQL](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md)

Le evidenze SQL E3 non equivalgono
a nuovi collaudi funzionali superati.

Nessuna variazione quantitativa approvata.

## 6. Baseline tecnica e ambienti

Ultime evidenze acquisite:

- Flutter analyze: PASS.
- Flutter test: 1956/1956.
- Migrazioni repository: 48.
- Migrazioni locali: 48.
- Migrazioni remote: 34.
- Migrazioni remote pendenti: 14.
- Applicazione remota: non autorizzata.

Consultare:

- [Collaudi](../06_collaudi/TST-S046-001_Baseline_Collaudi.md)
- [Migrazioni e backup](../03_database/DB-MIG-001_Stato_Migrazioni.md)

Questi valori rappresentano le ultime evidenze acquisite.
Non costituiscono nuove verifiche degli ambienti.

## 7. Criticita e verifiche aperte

- NC-RC01-001: P1, aperta.
- Ripristino funzionale del backup: NV.
- Allineamento delle migrazioni remote: pendente.
- Completamento della ricognizione RC02.06-10.
- Riconciliazione delle 15 famiglie di verifiche residue Write Authority.
- Riconciliazione delle stime PERT originarie.
- Verifica conclusiva del consolidamento aggiuntivo.
- Versionamento aggiuntivo CONS.05.

Il versionamento iniziale del Registro
risulta completato.

Le verifiche residue non costituiscono
automaticamente nuovi pacchetti di sviluppo.

Consultare:

- [NC-RC01-001](../07_criticita/NC-RC01-001_Scritture_Dirette_Profili_Operatori.md)
- [Lifecycle e verifiche residue](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)

## 8. Stato della programmazione V1

Consultare le schede della directory 09_programmazione.

- [Baseline quantitativa](../09_programmazione/V1-EST-001_Baseline_Quantitativa.md)
- [Raggruppamenti operativi](../09_programmazione/V1-EST-002_Raggruppamenti_Operativi.md)
- [Registro variazioni](../09_programmazione/V1-EST-003_Registro_Variazioni_Quantitative.md)

Nessuna variazione quantitativa approvata.
Nessuna data definitiva di rilascio approvata.

## 9. Punto esatto di ripresa

Attivita immediata:

- Concludere CONS.04.
- Eseguire CONS.05.
- Verificare integrita e coerenza del Registro.
- Ottenere autorizzazione al commit e al push.
- Verificare HEAD, origin/main e working tree.

Successivamente:

Riprendere RC02 dal controllo 06:

Controller, scheduler, scope e gate Flutter.

Consultare preventivamente:

- [Inventario Write Authority](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md)
- [Lifecycle e contratti RPC](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)
- [Punto di ripresa RC02](../08_riutilizzo/RC02_Stato_Parziale.md)

Il primo comando di ispezione Flutter
deve essere definito alla ripresa effettiva.

Non ripetere i controlli RC02.01-05
se le condizioni tecniche rimangono invariate.

Procedere un comando alla volta.

Nessuna modifica applicativa
senza autorizzazione pertinente.

Nessuna migrazione remota
senza autorizzazione esplicita.

## 10. Regole di aggiornamento

Aggiornare questo documento:

- Alla conclusione di ogni sessione.
- In occasione di sospensioni significative.
- Dopo variazioni della baseline tecnica.
- Dopo modifiche dello stato delle riconciliazioni.
- Prima del trasferimento a una nuova chat.

Conservare le baseline storiche separate.
Registrare i consuntivi effettivi nei checkpoint.
Non inventare orari, risultati o avanzamenti.

Il Registro e' gestito da ChatGPT.
Le autorizzazioni operative rimangono di competenza dell'utente.

Nessuna modifica applicativa o al database introdotta.
