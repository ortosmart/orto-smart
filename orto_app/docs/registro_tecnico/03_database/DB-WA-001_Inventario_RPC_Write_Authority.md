# DB-WA-001 - Inventario RPC Write Authority

## 1. Identificazione

- Versione: 1.1.
- Sessione originaria: S046.
- Sessione aggiornamento: S047.
- Data: 26/11/2026.
- Origine: RC02, controlli 01.2 e 01.3.
- Aggiornamento: RC02, controllo 06.
- Macroblocco principale: V1-02.
- Baseline Git originaria: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Baseline Git aggiornamento: 39665b458221b69c469ebe1d16a686312af79320.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Collaudo integrato reale Flutter-PostgreSQL: NV.
- Ambiente remoto: NV.

### 1.1. Storico delle versioni

| Versione | Sessione | Data | Contenuto |
|---|---|---|---|
| 1.0 | S046 | 26/11/2026 | Inventario originario RPC |
| 1.1 | S047 | 26/11/2026 | Correzione denominazioni Takeover e aggiornamento verifiche |

## 2. Risultato della ricerca

Dichiarazioni individuate: 13.

Funzioni distinte individuate: 12.

Funzioni installate individuate: 12.

Ripartizione:

- RPC pubbliche: 9.
- Helper privati: 3.

La dichiarazione aggiuntiva riguarda
la ridefinizione della RPC di richiesta
del takeover in una migrazione successiva.

La corrispondenza numerica 12/12
non dimostra l'identita dei corpi
delle funzioni.

## 3. RPC pubbliche

| Funzione | Riga nella migrazione originaria |
|---|---:|
| acquire_profile_edit_lock | 112 |
| heartbeat_profile_edit_lock | 286 |
| release_profile_edit_lock | 396 |
| request_profile_edit_takeover | 503 |
| cancel_profile_edit_takeover | 645 |
| reject_profile_edit_takeover | 756 |
| grant_profile_edit_takeover | 908 |
| complete_profile_edit_takeover | 1077 |
| get_profile_edit_lock_state | 1238 |

Migrazione originaria:

20260819215412_add_secure_profile_edit_lock_rpcs.sql.

La RPC request e' stata ridefinita
nella migrazione:

20260915081444_add_plantings_write_rpcs.sql.

Riga rilevata: 1906.

### 3.1. Correzione documentale S047

La versione 1.0 riportava
denominazioni inesatte delle cinque RPC
relative al protocollo Takeover.

Le denominazioni della presente versione
corrispondono a quelle rilevate
nel catalogo PostgreSQL locale.

La correzione e' esclusivamente documentale.

Nessuna funzione SQL e' stata rinominata
o modificata.

## 4. Contratti comuni delle RPC

Tutte le nove RPC individuate:

- Appartengono allo schema public.
- Sono SECURITY DEFINER.
- Restituiscono jsonb.
- Sono eseguibili da authenticated.
- Non sono eseguibili da anon.

Argomenti comuni:

- target_profile_id UUID.
- target_client_id UUID.
- target_session_id UUID.

Argomenti aggiuntivi:

| RPC | Argomenti aggiuntivi |
|---|---|
| acquire | Nessuno |
| heartbeat | lock_token text |
| release | lock_token text |
| request | Nessuno |
| cancel | Nessuno |
| reject | lock_token text, silence_minutes integer |
| grant | lock_token text |
| complete | Nessuno |
| get_state | Nessuno |

La verifica delle firme non dimostra
la correttezza delle validazioni interne.

## 5. Helper privati

| Funzione | Restituzione | Sicurezza |
|---|---|---|
| private.profile_edit_lock_token_hash | bytea | INVOKER |
| private.is_profile_edit_lock_holder | boolean | DEFINER |
| private.lock_profile_write_authority | boolean | DEFINER |

Il primo helper riceve lock_token text.

Gli altri due ricevono:

- target_profile_id UUID.
- target_client_id UUID.
- target_session_id UUID.
- lock_token text.

Nessuno dei tre helper esaminati
risulta direttamente eseguibile
da authenticated o anon.

## 6. Fonti degli helper

Migrazione:

20260819215412_add_secure_profile_edit_lock_rpcs.sql.

Riferimenti rilevati:

- profile_edit_lock_token_hash: riga 6.
- is_profile_edit_lock_holder: riga 18.

Migrazione:

20260823111048_add_profile_write_authority.sql.

Riferimento rilevato:

- lock_profile_write_authority: riga 8.

I corpi effettivi dei tre helper
sono stati esaminati nel controllo 03.1.

Il relativo approfondimento viene
conservato in una scheda dedicata.

## 7. Stato delle verifiche

### 7.1. Stato aggiornato

| Controllo | Stato |
|---|---|
| Inventario dichiarazioni | Eseguito |
| Inventario funzioni installate | Eseguito |
| Firme | Verificate |
| Tipi restituiti | Verificati |
| SECURITY DEFINER/INVOKER | Verificato |
| EXECUTE authenticated | Verificato |
| EXECUTE anon | Verificato |
| Corpi delle nove RPC | Ricognizione strutturale eseguita |
| Validazioni interne delle RPC | Analisi strutturale eseguita |
| Ridefinizione RPC request | Verificata strutturalmente |
| Integrazione con domini | Da completare in RC02.07 |
| Collaudi funzionali specifici SQL | Da completare |
| Collaudi Flutter mirati | 116/116 PASS |
| Collaudo integrato reale | NV |
| Ambiente remoto | NV |

Le verifiche strutturali non equivalgono
a collaudo funzionale completo.

Le evidenze SQL sono conservate
nei documenti DB-WA-002 - DB-WA-007
e TST-RC02-001.

### 7.2. Ridefinizione RPC request

La definizione successiva della RPC
request_profile_edit_takeover
e' stata confrontata con quella
effettivamente installata nel database locale.

La verifica strutturale ha rilevato
corrispondenza dell'impronta normalizzata.

Il dettaglio della verifica e' conservato
in DB-WA-006 e TST-RC02-001.

### 7.3. Riconciliazione Flutter S047

| Indicatore | Risultato |
|---|---:|
| RPC pubbliche SQL analizzate | 9 |
| RPC integrate nel repository Flutter | 3 |
| RPC non integrate | 6 |
| Stati complessivi SQL | 48 |
| Stati decodificati dal repository Flutter | 12 |
| Stati non integrati | 36 |

Le tre RPC integrate riguardano
Acquire, Heartbeat e Release.

Get State e le cinque RPC Takeover
richiedono integrazione applicativa.

I dettagli sono conservati
in INF-WA-002 e TST-RC02-002.

Il livello complessivo rimane E3.

## 8. Vincoli di riutilizzo

Utilizzare le RPC esistenti
quando compatibili con il contratto
e con le evidenze acquisite.

Non creare RPC equivalenti
senza verificare quelle disponibili.

Non estendere i privilegi
degli helper privati senza motivazione.

SECURITY DEFINER non costituisce
da solo garanzia di sicurezza.

Verificare sempre le autorizzazioni
e le validazioni interne.

## 9. Collegamenti

Riferimenti originari:

- INF-WA-001.
- DB-SEC-001.
- DB-VER-001.
- FLT-PROF-001.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

Documenti di approfondimento:

- [INF-WA-001](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md).
- [INF-WA-002](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md).
- [DB-WA-002](DB-WA-002_Struttura_Edit_Lock.md).
- [DB-WA-003](DB-WA-003_Helper_Autorita_Scrittura.md).
- [DB-WA-004](DB-WA-004_Acquisizione_Rilascio_Lock.md).
- [DB-WA-005](DB-WA-005_Heartbeat_Stato_Lock.md).
- [DB-WA-006](DB-WA-006_Protocollo_Takeover.md).
- [DB-WA-007](DB-WA-007_Lifecycle_Contratti_RPC.md).
- [TST-RC02-001](../06_collaudi/TST-RC02-001_Evidenze_Strutturali_SQL.md).
- [TST-RC02-002](../06_collaudi/TST-RC02-002_Evidenze_Collaudi_Flutter.md).
- [RC02-OBS-001](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md).
- [RC02_Stato_Parziale](../08_riutilizzo/RC02_Stato_Parziale.md).

## 10. Limiti

Inventario relativo al perimetro
della ricerca eseguita nella RC02.

Nessuna ulteriore funzione esclusa
sulla base della sola ricerca testuale.

Nessuna equivalenza automatica
fra migrazioni e database remoto.

Nessuna modifica tecnica introdotta.
