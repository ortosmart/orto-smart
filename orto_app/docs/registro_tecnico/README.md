# Orto Smart - Registro tecnico permanente

## Identificazione

- Progetto: Orto Smart
- Registro: infrastrutture e componenti riutilizzabili
- Versione iniziale: 1.0
- Versione corrente: 1.3
- Sessione di introduzione: S046
- Sessione ultimo aggiornamento: S048
- Data di istituzione: 26/11/2026
- Data ultimo aggiornamento: 27/11/2026
- Baseline sorgenti originaria: 20649de7474765bd1c293b20bfcedab0a9493a14
- Baseline aggiornamento: d1de8f659b52605aa52941ea33e920db5d684bd7
- Stato del Registro: istituito e operativo, in aggiornamento progressivo

[Stato operativo corrente](10_stato_operativo/STATO_CORRENTE.md)

## 1. Finalita

Questo Registro costituisce il punto di accesso principale
alla conoscenza tecnica permanente di Orto Smart.

La sua finalita e accelerare lo sviluppo attraverso:

- Riutilizzo delle infrastrutture esistenti.
- Recupero immediato delle decisioni approvate.
- Individuazione dei sorgenti pertinenti.
- Conservazione delle evidenze tecniche.
- Riduzione delle analisi ripetitive.
- Individuazione delle integrazioni mancanti.
- Prevenzione delle duplicazioni funzionali.
- Continuita tra sessioni e agenti di sviluppo.

Il Registro sostituisce l'aggiornamento sistematico
dei Manuali precedenti, che rimangono conservati.

## 2. Standard di gestione

Consultare:

[ARC-REG-001 - Standard del Registro](01_architettura/ARC-REG-001_Standard_Registro.md)

Lo standard definisce responsabilita, classificazione,
livelli di evidenza, regole di aggiornamento e riutilizzo.

## 3. Mappa delle sezioni

| Sezione | Directory | Contenuto |
|---|---|---|
| 01 | 01_architettura | Decisioni, requisiti e vincoli |
| 02 | 02_infrastrutture | Componenti comuni riutilizzabili |
| 03 | 03_database | Tabelle, RPC, RLS e migrazioni |
| 04 | 04_flutter | Modelli, repository, servizi e controller |
| 05 | 05_processi | Flussi funzionali e integrazioni |
| 06 | 06_collaudi | Test, risultati ed evidenze |
| 07 | 07_criticita | Non conformita e debito tecnico |
| 08 | 08_riutilizzo | Matrici e procedure standard |
| 09 | 09_programmazione | Perimetro V1, milestone A e B |
| 10 | 10_stato_operativo | Baseline, sessioni e consuntivi |

Le sezioni vengono alimentate progressivamente.
Una directory presente non implica che i suoi contenuti
siano gia stati acquisiti o verificati.

## 4. Protocollo obbligatorio di consultazione

All'apertura di una sessione:

1. Verificare branch, HEAD e working tree.
2. Consultare questo indice.
3. Acquisire lo stato operativo corrente.
4. Individuare il macroblocco interessato.
5. Consultare le schede tecniche pertinenti.
6. Individuare le infrastrutture riutilizzabili.
7. Verificare le variazioni rispetto alla baseline.
8. Leggere soltanto i sorgenti necessari.
9. Eseguire i controlli tecnici iniziali previsti.
10. Procedere secondo le autorizzazioni operative.

Non ripetere una ricognizione gia documentata,
salvo variazioni dei sorgenti, evidenze insufficienti
o necessita di verifica nell'ambiente pertinente.

## 5. Regole di validita delle conoscenze

Ogni informazione deve essere riconducibile a:

- Sorgente o decisione di riferimento.
- Commit o baseline tecnica.
- Ambiente verificato.
- Sessione di acquisizione.
- Livello di evidenza.
- Eventuali limitazioni.

Il codice corrente rimane autoritativo.

Una modifica del commit non invalida automaticamente
tutte le conoscenze precedenti.

Verificare le modifiche effettivamente intervenute
e rivalidare le schede interessate.

Non trasformare informazioni non verificate
in fatti acquisiti.

## 6. Ricerca per esigenza operativa

| Esigenza | Sezioni prioritarie |
|---|---|
| Nuovo dominio funzionale | 01, 02, 05, 08, 09 |
| Nuova tabella o RPC | 02, 03, 06, 08 |
| Sicurezza e autorizzazioni | 01, 02, 03, 07 |
| Integrazione Flutter | 02, 04, 05, 06 |
| Concorrenza e versionamento | 02, 03, 06, 07 |
| Correzione di un errore | 05, 06, 07 |
| Nuovo collaudo | 05, 06, 08 |
| Migrazioni e distribuzione | 03, 06, 08, 10 |
| Pianificazione sviluppo | 07, 08, 09, 10 |
| Apertura e chiusura sessione | 09, 10 |

## 7. Regole di aggiornamento

La gestione del Registro e affidata a ChatGPT.

Aggiornare le conoscenze contestualmente allo sviluppo.

Non duplicare le informazioni tra sezioni.
Utilizzare riferimenti alla scheda principale.

Non copiare integralmente i sorgenti.

Conservare identificativi, decisioni ed evidenze.

Non eliminare informazioni storiche senza motivazione.

Non conservare credenziali, password o token.

L'utente interviene per le operazioni di interfaccia
con il PC e per le autorizzazioni previste.

## 8. Stato della ricognizione S046–S048

### 8.1. Stato delle attivita

| Attivita | Stato |
|---|---|
| STEP 271 - Checkpoint iniziale | Concluso |
| STEP 272 - Ricognizione documentale | Concluso |
| STEP 273 - Inventario tecnico | Concluso |
| STEP 274 - Perimetro V1 | Concluso |
| STEP 275 - Valutazione e riconciliazione | In corso |
| STEP 275.R - Creazione Registro | Concluso |
| STEP 276 - Sequenza operativa | Da iniziare |
| STEP 277 - Programmazione rilasci | Da iniziare |
| STEP 278 - Consolidamento Registro | Da iniziare |

RC01: riconciliazione tecnica approvata.
RC02.01–RC02.10: conclusi (10/10).
RC02.07: concluso, 10/10 sottoblocchi completati.
RC02: ricognizione tecnica conclusa.
DOC.09 e DOC.10 completati. Punto di ripresa: RC11 — Registri, unità e parametri.

RC03–RC10: concluse tecnicamente. RC11–RC18: da eseguire.

### 8.2. Consistenza del Registro

| Indicatore | S046 | S047 | S048 (locale) |
|---|---:|---:| ---: |
| Documenti Markdown complessivi | 49 | 51 | 53 |
| Documenti indicizzati | 48 | 50 | 52 |
| Directory tematiche | 10 | 10 | 10 |
| Osservazioni tecniche RC02 | 253 | 360 | 410 |
| RPC pubbliche analizzate strutturalmente | 9/9 | 9/9 | 9/9 |
| Controlli strutturali RPC | 180 | 180 | 180 |
| Famiglie trasversali residue | 15 | 15 | 15 |

Nella sessione S046 sono state aggiunte
cinque schede tecniche RC02 durante il consolidamento SQL.

Nella sessione S047 sono state aggiunte
due schede tecniche:

- INF-WA-002 - Infrastruttura Flutter Write Authority.
- TST-RC02-002 - Evidenze collaudi Flutter.

Le 253 osservazioni storiche sono conservate.
Le 107 osservazioni aggiuntive sono salvate localmente.

### 8.3. Evidenze Flutter S047

- Suite mirate: 7/7 PASS.
- Test mirati: 116/116 PASS.
- Baseline generale: 1956/1956 PASS.
- Nuovi test introdotti: 0.
- RPC integrate nel repository Flutter: 3/9.
- Stati SQL complessivi: 48.
- Stati decodificati dal repository Flutter: 12.
- Stati non integrati: 36.
- Verifiche specifiche residue C01-C09: 9.
- Famiglie trasversali residue WA-V01-WA-V15: 15.
- Famiglie integralmente chiuse: 0.

Evidenza complessiva: E3.
Evidenze specifiche collaudate: E4.
Collaudo integrato reale: NV.
Ambiente remoto: NV.

I collaudi mirati Flutter utilizzano
dipendenze simulate.

Le evidenze strutturali non equivalgono
a collaudi funzionali complessivi.

### 8.4. Stato del consolidamento

Il Registro originario S046 e stato
versionato e pubblicato su GitHub.

Gli aggiornamenti S047 sono salvati localmente.

Per S048, GitHub contiene la chiusura tecnica RC10 nel commit
`1cd7df5`. Le evidenze RC07–RC09 e le due nuove schede
INF-WA-003 e TST-RC02-003 sono presenti nel Registro locale.
Sono stati rilevati 53 documenti Markdown locali e 51 nella
baseline pubblicata, prima del consolidamento finale.

Controllo tecnico successivo:

RC11 — Registri, unità e parametri.

Per lo stato operativo aggiornato
consultare STATO_CORRENTE.

### 8.5. Stato quantitativo

- Riconciliazioni tecniche concluse: 10/18 (55,56%).
- Riconciliazioni quantitative concluse: 0/18.
- DUP-A quantitative concluse: 0/9.
- DUP-B quantitative concluse: 0/12.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

La riconciliazione quantitativa rimane aperta.

Nessuna variazione delle stime PERT.

## 9. Documentazione precedente

La documentazione storica rimane disponibile nelle
directory archivio, manuali, progetto e sviluppo.

I documenti precedenti devono essere consultati
quando necessari per recuperare decisioni o evidenze
non ancora trasferite nel Registro.

Non e previsto il loro aggiornamento sistematico.

## 10. Continuita operativa

Il checkpoint di ogni sessione deve indicare:

- Percorso del Registro.
- Commit corrente.
- Stato delle attivita.
- Schede aggiornate.
- Criticita aperte.
- Punto esatto di ripresa.

Il Registro deve essere salvato e versionato.

Commit, push, migrazioni e distribuzioni rimangono
subordinati alle autorizzazioni operative previste.

<!-- BEGIN INDICE ANALITICO -->

## 11. Indice analitico dei documenti

Indice generato dai documenti effettivamente presenti.
Consultare soltanto le schede pertinenti all'attivita.

### 01_architettura

- [ARC-001 - Architettura generale](01_architettura/ARC-001_Architettura_Generale.md)
- [ARC-002 - Sicurezza, autorita e integrita](01_architettura/ARC-002_Sicurezza_Autorita_Integrita.md)
- [ARC-003 - Principi di gestione dei dati](01_architettura/ARC-003_Principi_Gestione_Dati.md)
- [ARC-004 - Perimetro dei rilasci e vincoli operativi](01_architettura/ARC-004_Perimetro_Rilasci_Vincoli.md)
- [Orto Smart - Standard del Registro tecnico](01_architettura/ARC-REG-001_Standard_Registro.md)

### 02_infrastrutture

- [INF-AGR-001 - Motori agronomici](02_infrastrutture/INF-AGR-001_Motori_Agronomici.md)
- [INF-AUTH-001 - Autenticazione](02_infrastrutture/INF-AUTH-001_Autenticazione.md)
- [INF-CAT-001 - Catalogo Agronomico](02_infrastrutture/INF-CAT-001_Catalogo_Agronomico.md)
- [INF-ID-001 - Identita client e sessione](02_infrastrutture/INF-ID-001_Identita_Client_Sessione.md)
- [INF-WA-001 - Inventario Write Authority](02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md)
- [INF-WA-002 - Infrastruttura Flutter Write Authority](02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md)
- [INF-WA-003 - Integrazione Write Authority nei domini](02_infrastrutture/INF-WA-003_Integrazione_Write_Authority_Domini.md)

### 03_database

- [DB-INV-001 - Inventario database](03_database/DB-INV-001_Inventario_Database.md)
- [DB-MIG-001 - Baseline delle migrazioni](03_database/DB-MIG-001_Stato_Migrazioni.md)
- [DB-PROF-001 - Profili, membership e operatori](03_database/DB-PROF-001_Profili_Membership_Operatori.md)
- [DB-SEC-001 - Autorizzazioni del profilo](03_database/DB-SEC-001_Autorizzazioni_Profilo.md)
- [DB-VER-001 - Trigger e versionamento](03_database/DB-VER-001_Trigger_Versionamento.md)
- [DB-WA-001 - Inventario RPC Write Authority](03_database/DB-WA-001_Inventario_RPC_Write_Authority.md)
- [DB-WA-002 - Struttura edit lock](03_database/DB-WA-002_Struttura_Edit_Lock.md)
- [DB-WA-003 - Helper autorita di scrittura](03_database/DB-WA-003_Helper_Autorita_Scrittura.md)
- [DB-WA-004 - Acquisizione e rilascio del lock](03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md)
- [DB-WA-005 - Heartbeat e consultazione stato del lock](03_database/DB-WA-005_Heartbeat_Stato_Lock.md)
- [DB-WA-006 - Protocollo takeover](03_database/DB-WA-006_Protocollo_Takeover.md)
- [DB-WA-007 - Lifecycle e contratti RPC Write Authority](03_database/DB-WA-007_Lifecycle_Contratti_RPC.md)

### 04_flutter

- [FLT-INV-001 - Inventario architettura Flutter](04_flutter/FLT-INV-001_Inventario_Flutter.md)
- [FLT-PROF-001 - Contesto del profilo](04_flutter/FLT-PROF-001_Contesto_Profilo.md)

### 05_processi

- [PRC-001 - Orti, aiuole e stagioni](05_processi/PRC-001_Orti_Aiuole_Stagioni.md)
- [PRC-002 - Pianificazioni e coltivazioni](05_processi/PRC-002_Pianificazioni_Coltivazioni.md)
- [PRC-003 - Domini operativi aggiuntivi B](05_processi/PRC-003_Domini_Operativi_B.md)
- [PRC-004 - Dashboard, impostazioni e distribuzione](05_processi/PRC-004_Dashboard_Impostazioni_Distribuzione.md)

### 06_collaudi

- [TST-RC01-001 - Evidenze identita e profilo](06_collaudi/TST-RC01-001_Evidenze_Identita_Profilo.md)
- [TST-RC02-001 - Evidenze strutturali SQL Write Authority](06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md)
- [TST-RC02-002 - Evidenze collaudi Flutter](06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md)
- [TST-RC02-003 - Evidenze collaudi dei domini](06_collaudi/TST-RC02-003_Evidenze_Collaudi_Domini.md)
- [TST-S046-001 - Baseline dei collaudi](06_collaudi/TST-S046-001_Baseline_Collaudi.md)

### 07_criticita

- [NC-RC01-001 - Scritture dirette profili e operatori](07_criticita/NC-RC01-001_Scritture_Dirette_Profili_Operatori.md)

### 08_riutilizzo

- [DUP-A-001 - Sovrapposizioni Milestone A](08_riutilizzo/DUP-A-001_Sovrapposizioni_Milestone_A.md)
- [DUP-B-001 - Sovrapposizioni Milestone B](08_riutilizzo/DUP-B-001_Sovrapposizioni_Milestone_B.md)
- [RC01 - Conclusione tecnica](08_riutilizzo/RC01_Conclusione_Tecnica.md)
- [RC01-INV-001 - Infrastrutture riutilizzabili](08_riutilizzo/RC01-INV-001_Infrastrutture_Riutilizzabili.md)
- [RC01-RES-001 - Elementi residui e verifiche](08_riutilizzo/RC01-RES-001_Elementi_Residui.md)
- [RC02 - Stato parziale della ricognizione](08_riutilizzo/RC02_Stato_Parziale.md)
- [RC02-OBS-001 - Osservazioni tecniche](08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md)
- [RC-REG-001 - Indice delle riconciliazioni](08_riutilizzo/RC-REG-001_Indice_Riconciliazioni.md)

### 09_programmazione

- [V1-ACC-001 - Condizioni di accettazione V1](09_programmazione/V1-ACC-001_Condizioni_Accettazione.md)
- [V1-EST-001 - Baseline quantitativa V1](09_programmazione/V1-EST-001_Baseline_Quantitativa.md)
- [V1-EST-002 - Raggruppamenti operativi A e B](09_programmazione/V1-EST-002_Raggruppamenti_Operativi.md)
- [V1-EST-003 - Registro delle variazioni quantitative](09_programmazione/V1-EST-003_Registro_Variazioni_Quantitative.md)
- [V1-MET-001 - Metodo permanente di valutazione](09_programmazione/V1-MET-001_Metodo_Valutazione.md)
- [V1-REG-001 - Mappa dei macroblocchi V1](09_programmazione/V1-REG-001_Mappa_Macroblocchi.md)

### 10_stato_operativo

- [S046 - Baseline tecnica iniziale](10_stato_operativo/S046_Baseline_Tecnica.md)
- [Orto Smart - Stato operativo corrente](10_stato_operativo/STATO_CORRENTE.md)

<!-- END INDICE ANALITICO -->

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
