# DB-WA-001 - Inventario RPC Write Authority

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controlli 01.2 e 01.3.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

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
| request_profile_edit_lock_takeover | 503 |
| cancel_profile_edit_lock_takeover | 645 |
| reject_profile_edit_lock_takeover | 756 |
| grant_profile_edit_lock_takeover | 908 |
| complete_profile_edit_lock_takeover | 1077 |
| get_profile_edit_lock_state | 1238 |

Migrazione originaria:

20260819215412_add_secure_profile_edit_lock_rpcs.sql.

La RPC request e' stata ridefinita
nella migrazione:

20260915081444_add_plantings_write_rpcs.sql.

Riga rilevata: 1906.

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

| Controllo | Stato |
|---|---|
| Inventario dichiarazioni | Eseguito |
| Inventario funzioni installate | Eseguito |
| Firme | Verificate |
| Tipi restituiti | Verificati |
| SECURITY DEFINER/INVOKER | Verificato |
| EXECUTE authenticated | Verificato |
| EXECUTE anon | Verificato |
| Corpi delle nove RPC | Da completare |
| Validazioni interne delle RPC | Da completare |
| Ridefinizione RPC request | Da approfondire |
| Integrazione con domini | Da completare |
| Collaudi funzionali specifici | Da completare |
| Ambiente remoto | NV |

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

- INF-WA-001.
- DB-SEC-001.
- DB-VER-001.
- FLT-PROF-001.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

## 10. Limiti

Inventario relativo al perimetro
della ricerca eseguita nella RC02.

Nessuna ulteriore funzione esclusa
sulla base della sola ricerca testuale.

Nessuna equivalenza automatica
fra migrazioni e database remoto.

Nessuna modifica tecnica introdotta.
