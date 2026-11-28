# DB-MIG-001 - Baseline delle migrazioni

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 271
- Commit: 20649de7474765bd1c293b20bfcedab0a9493a14

## 1. Stato iniziale

| Indicatore | Quantita |
|---|---:|
| Migrazioni nel repository | 48 |
| Migrazioni applicate localmente | 48 |
| Migrazioni applicate sul remoto | 34 |
| Migrazioni da applicare sul remoto | 14 |
| Migrazioni presenti soltanto sul remoto | 0 |

Allineamento numerico remoto: 34/48.

Il rapporto numerico delle migrazioni non rappresenta
la percentuale di completamento funzionale della V1.

Ultima migrazione remota rilevata:
20261014200459

### 1.1. Confronto delle versioni locali — RC07, S048

Verifica in sola lettura del 27/11/2026 sulla baseline Git
d1de8f659b52605aa52941ea33e920db5d684bd7.

Le 48 versioni ricavate dai nomi dei file in supabase/migrations
coincidono una per una con le versioni registrate in
supabase_migrations.schema_migrations nel PostgreSQL locale.
Differenze: 0. Ultima versione locale: 20261125151100.

La corrispondenza delle versioni attesta l'allineamento del registro
locale. L'equivalenza funzionale degli schemi richiede verifiche
dedicate.

### 1.2. Verifica del registro remoto — RC07, S048

La consultazione del progetto Supabase collegato con
`supabase migration list --linked` è terminata con codice 0.

| Riscontro | Valore |
|---|---:|
| Versioni locali | 48 |
| Versioni remote, tutte presenti anche in locale | 34 |
| Versioni presenti soltanto in locale | 14 |
| Versioni presenti soltanto sul remoto | 0 |
| Ultima versione remota | 20261014200459 |

Il riscontro conferma la rilevazione precedente. Restano pendenti
11 migrazioni di S039 e 3 di S045, come indicato nel §2.
La verifica riguarda le versioni registrate. L'equivalenza funzionale
degli schemi resta da verificare. Nessuna migrazione è stata applicata.

### 1.3. Conclusione tecnica RC07 — S048

Ricognizione tecnica conclusa e approvata. Il confronto delle versioni
registrate conferma 48/48 in locale, 34 sul remoto, 14 pendenti
e zero versioni presenti soltanto sul remoto.

L'equivalenza funzionale degli schemi resta NV. La distribuzione
delle 14 migrazioni resta aperta e richiede autorizzazione separata.

Riconciliazioni tecniche concluse: 7/18. Riconciliazioni quantitative
concluse: 0/18. Punto di ripresa: RC08 — Geometrie e storico.

## 2. Migrazioni remote pendenti

- 11 migrazioni provenienti dalla S039.
- 3 migrazioni provenienti dalla S045.

Identificativi S045:

- 20261125150900
- 20261125151000
- 20261125151100

Applicazione locale confermata.

Applicazione remota eseguita in S048. Vedere §2.1.

### 2.1. Allineamento Supabase remoto — RC10, S048

Il 28/11/2026 sulla baseline `d1de8f6`, il dry run ha confermato
le 14 versioni pendenti, da `20261104190000` a `20261125151100`.
Il backup logico pre-migrazione del remoto è conservato in
`C:/Sviluppo/orto-smart-backups/S048-RC10-remoto-20261128`.
Comprende schema, ruoli, dati, schemi gestiti e storico migrazioni.
L'esportazione dati esclude le due tabelle degli upload multipart
di Storage.

Il ripristino in PostgreSQL isolato senza rete ha recuperato le 34
versioni pre-migrazione e i conteggi di catalogo attesi (3 taxa,
1 coltura e 0 cultivar). Le 14 migrazioni sono state provate sulla
copia ripristinata. Il container di prova è stato rimosso.

Il titolare ha autorizzato l'applicazione sul remoto. La CLI ha
completato tutte le 14 migrazioni e il controllo PostgreSQL ha
confermato 48 versioni registrate, ultima `20261125151100`, e il
vincolo `planned_plantings_cultivar_crop_fk` validato.
I riscontri funzionali sono in
[INF-CAT-001 §2.14](../02_infrastrutture/INF-CAT-001_Catalogo_Agronomico.md#214-collaudo-della-pianificazione-su-supabase-remoto--rc10-s048).

## 3. Backup precedente alle migrazioni S045

File:

C:\Sviluppo\OrtoSmart_Checkpoint\Sviluppo\S045\orto_s045_268_pre_migrazioni_20261125_213844.dump

Dimensione: 1480696 byte.

SHA256:
7665D6FE737292625B5D18B0F1A3A662E4E86B0AA5B2959D4B603250048825E3

Hash acquisito il 26/11/2026.

Lettura del backup mediante pg_restore verificata.

Ripristino funzionale completo: non ancora verificato.

Non disponibile un hash precedente per confronto.

## 4. Procedura remota approvata come metodo

Prima di qualsiasi applicazione:

- Verificare lo stato effettivo del remoto.
- Predisporre il backup richiesto.
- Verificare la recuperabilita del backup.
- Esaminare le migrazioni pendenti.
- Eseguire il dry-run.
- Acquisire autorizzazione esplicita.

Comando previsto per il dry-run:

supabase db push --linked --dry-run --skip-vault

Comando previsto per l'applicazione autorizzata:

supabase db push --linked --skip-vault

Non utilizzare automaticamente:

- --include-all
- --include-roles
- --include-seed
- --yes

La procedura non costituisce autorizzazione
all'esecuzione delle migrazioni.

## 5. Gestione delle anomalie

In caso di errore durante una migrazione:

- Interrompere la procedura.
- Acquisire l'errore effettivo.
- Verificare lo stato delle migrazioni.
- Verificare eventuali modifiche parziali.
- Non presumere atomicita dell'intero insieme.
- Definire il recupero prima di procedere.

## 6. Dipendenze

- RC06: backup e ripristino.
- RC07: migrazioni.
- V1-03: protezione e recupero dei dati.
- V1-04: allineamento e distribuzione database.

Le verifiche dettagliate dei singoli file
saranno consolidate nelle rispettive riconciliazioni.
