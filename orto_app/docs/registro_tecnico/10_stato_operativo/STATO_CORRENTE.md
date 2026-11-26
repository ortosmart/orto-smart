# Orto Smart - Stato operativo corrente

## 1. Identificazione

- Sessione corrente: S046.
- Data aggiornamento: 26/11/2026.
- Repository: ortosmart/orto-smart.
- Branch di riferimento: main.
- Baseline sorgenti: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Sessione: IN CORSO.
- Registro tecnico: in consolidamento iniziale.

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
| 275.R | Registro tecnico permanente | In corso |
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
| 275.R.08 | In corso - versionamento da completare |
| 275.R.09 | Da eseguire |

Attivita integralmente concluse: 7/9.

Verifiche documentali del 26/11/2026:

- 44 documenti Markdown.
- 10 sottocartelle.
- 43 documenti indicizzati nel README.
- Nessun file vuoto.
- Verifica logica mirata: 13/13 documenti.
- Collegamenti locali verificati: 61/61.
- Collegamenti mancanti: 0.
- Documento storico collegato e preservato.
- Working tree: 44 nuovi documenti e un documento storico modificato.
- Diff documento storico: 22 righe aggiunte, nessuna eliminata.
- Nessuna modifica applicativa o alle migrazioni.

Dimensione verificata prima del presente aggiornamento:
206539 byte.

Versionamento Git ancora da completare.
Verificare commit, push e allineamento effettivo
prima di dichiarare concluso lo STEP 275.R.08.

## 5. Stato delle riconciliazioni

- RC01: conclusa tecnicamente e approvata.
- RC02: in corso, 2/10 controlli principali conclusi.
- RC03-RC18: da eseguire.
- Riconciliazioni quantitative concluse: 0/18.

Riferimenti:

- [Conclusione RC01](../08_riutilizzo/RC01_Conclusione_Tecnica.md)
- [Stato parziale RC02](../08_riutilizzo/RC02_Stato_Parziale.md)

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
- Completamento della ricognizione RC02.
- Riconciliazione delle stime PERT originarie.
- Versionamento iniziale del Registro.

Consultare:

[NC-RC01-001](../07_criticita/NC-RC01-001_Scritture_Dirette_Profili_Operatori.md)

## 8. Stato della programmazione V1

Consultare le schede della directory 09_programmazione.

- [Baseline quantitativa](../09_programmazione/V1-EST-001_Baseline_Quantitativa.md)
- [Raggruppamenti operativi](../09_programmazione/V1-EST-002_Raggruppamenti_Operativi.md)
- [Registro variazioni](../09_programmazione/V1-EST-003_Registro_Variazioni_Quantitative.md)

Nessuna variazione quantitativa approvata.
Nessuna data definitiva di rilascio approvata.

## 9. Punto esatto di ripresa

Attivita immediata: completare STEP 275.R.08.

Successivamente: STEP 275.R.09.

Riprendere RC02 dal controllo 03.2:
verifica della funzione privata is_profile_auth_user_owner.

Il comando esatto e' conservato nella scheda RC02:

[Punto di ripresa RC02](../08_riutilizzo/RC02_Stato_Parziale.md)

Non ripetere i controlli 01, 02 e 03.1
se le condizioni tecniche rimangono invariate.

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
