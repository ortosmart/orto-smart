# DB-WA-003 - Helper autorita di scrittura

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controllo 03.1.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Collaudo funzionale specifico: NV.
- Ambiente remoto: NV.

## 2. Funzioni esaminate

- private.profile_edit_lock_token_hash.
- private.is_profile_edit_lock_holder.
- private.lock_profile_write_authority.

I corpi effettivamente installati
sono stati acquisiti durante RC02
mediante pg_get_functiondef.

Nessuna delle tre funzioni esaminate
risulta direttamente eseguibile
da authenticated o anon.

## 3. Hash del token

Funzione:

private.profile_edit_lock_token_hash(lock_token text)

Caratteristiche:

- Linguaggio SQL.
- IMMUTABLE.
- SECURITY INVOKER.
- search_path vuoto.
- Restituzione bytea.

Comportamento rilevato:

extensions.digest(lock_token, 'sha256')

La funzione calcola l'hash del token.

Non genera il token.

Non verifica autonomamente
l'autorita di scrittura.

## 4. Verifica del titolare

Funzione:

private.is_profile_edit_lock_holder

Argomenti:

- target_profile_id UUID.
- target_client_id UUID.
- target_session_id UUID.
- lock_token text.

Caratteristiche:

- Linguaggio SQL.
- STABLE.
- SECURITY DEFINER.
- search_path vuoto.
- Restituzione boolean.

Condizioni rilevate:

- Record relativo al profilo.
- Titolare autenticato uguale ad auth.uid().
- Identita client corrispondente.
- Identita sessione corrispondente.
- Hash del token corrispondente.
- expires_at successivo a now().
- Verifica private.is_profile_owner.

La funzione utilizza una verifica
di esistenza del record pertinente.

Non acquisisce il blocco FOR UPDATE
nella definizione esaminata.

Non contiene la verifica specifica
della finestra temporale del grant
presente nell'altro helper.

## 5. Helper autoritativo

Funzione:

private.lock_profile_write_authority

Argomenti:

- target_profile_id UUID.
- target_client_id UUID.
- target_session_id UUID.
- lock_token text.

Caratteristiche:

- Linguaggio PLPGSQL.
- SECURITY DEFINER.
- search_path vuoto.
- Restituzione boolean.

Responsabilita rilevata:

Acquisire il blocco transazionale
sul record edit lock e verificare
le condizioni dell'autorita di scrittura.

## 6. Sequenza autoritativa

Comportamento rilevato:

1. Acquisizione dell'identita autenticata.
2. Rifiuto dei parametri nulli.
3. Lettura del record edit lock
   mediante SELECT FOR UPDATE.
4. Rifiuto del record assente.
5. Acquisizione dell'orario server
   mediante clock_timestamp().
6. Verifica della proprieta del profilo.
7. Verifica dell'identita del titolare.
8. Verifica dell'identita client.
9. Verifica dell'identita sessione.
10. Verifica dell'hash del token.
11. Verifica della scadenza.
12. Verifica della finestra del grant.
13. Restituzione true soltanto
    dopo il superamento dei controlli.

La sequenza costituisce una sintesi
del corpo effettivo esaminato.

Per modifiche consultare
la definizione SQL autorevole.

## 7. Serializzazione e tempo

SELECT FOR UPDATE acquisisce
un blocco sul record pertinente.

Il blocco rimane associato
alla transazione chiamante.

clock_timestamp viene acquisito
dopo l'eventuale attesa del blocco.

Questo consente di valutare
la scadenza rispetto al tempo
effettivo successivo all'attesa.

La protezione richiede che
la mutazione pertinente avvenga
nella medesima transazione.

Il chiamante deve rispettare
il risultato boolean restituito.

La presenza dell'helper non dimostra
che ogni RPC di dominio lo utilizzi
correttamente.

## 8. Verifica della proprieta

Dipendenza rilevata:

private.is_profile_auth_user_owner(
    target_profile_id,
    current_auth_user_id
)

La funzione viene richiamata
nell'helper autoritativo.

La definizione di questa dipendenza
non e' ancora stata esaminata
nella RC02.

La relativa verifica costituisce
il controllo successivo 03.2.

Non assumere equivalenza automatica
con private.is_profile_owner.

## 9. Finestra del grant

L'helper autoritativo rifiuta
la scrittura quando risulta
applicabile la finestra temporale
del grant ancora valido.

Condizione temporale rilevata:

Timestamp del grant
piu intervallo di 60 secondi
successivo a server_now.

La verifica completa del lifecycle
del takeover rimane aperta.

Non attribuire automaticamente
questa durata alla scadenza ordinaria
dell'edit lock.

## 10. Differenze fra gli helper

| Caratteristica | is_profile_edit_lock_holder | lock_profile_write_authority |
|---|---|---|
| Verifica titolare | Si | Si |
| Verifica client e sessione | Si | Si |
| Verifica hash | Si | Si |
| Verifica scadenza | Si | Si |
| Riferimento temporale | now() | clock_timestamp() |
| Blocco FOR UPDATE | No | Si |
| Controllo specifico grant | No | Si |
| Linguaggio | SQL | PLPGSQL |

Gli helper non devono essere
considerati intercambiabili.

La scelta dipende dal contratto
della funzione chiamante.

## 11. Fonti tecniche

Migrazione:

20260819215412_add_secure_profile_edit_lock_rpcs.sql

- profile_edit_lock_token_hash: riga 6.
- is_profile_edit_lock_holder: riga 18.

Migrazione:

20260823111048_add_profile_write_authority.sql

- lock_profile_write_authority: riga 8.

Evidenza principale:

Definizioni effettive delle funzioni
acquisite dal database locale
nel controllo RC02 03.1.

## 12. Verifiche ancora aperte

- Definizione is_profile_auth_user_owner.
- Generazione del token.
- Acquisizione del lock.
- Rilascio del lock.
- Heartbeat.
- Scadenza.
- Lifecycle takeover.
- Utilizzo degli helper nei domini.
- Gestione del risultato false.
- Concorrenza effettiva.
- Rollback.
- Comportamento remoto.

Il controllo 03.1 non conclude
l'intero controllo principale 03.

## 13. Riutilizzo

RIUTILIZZARE:

Gli helper esistenti nei contesti
compatibili con i rispettivi contratti.

VERIFICARE:

L'utilizzo autoritativo
nelle singole RPC di dominio.

Non creare una seconda funzione
di controllo dell'autorita
senza motivazione tecnica.

Non sostituire la verifica server
con il solo controllo Flutter.

Non considerare il semplice controllo
del titolare equivalente alla
serializzazione transazionale.

## 14. Collegamenti e limiti

- INF-WA-001.
- DB-WA-001.
- DB-WA-002.
- DB-SEC-001.
- DB-VER-001.
- FLT-PROF-001.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

Documento consolidato dalle evidenze
precedentemente acquisite.

Nessuna nuova ispezione integrale
delle definizioni SQL.

Nessun nuovo collaudo funzionale.

Nessuna modifica tecnica introdotta.
