# DB-WA-003 - Helper autorita di scrittura

## 1. Identificazione

- Versione: 1.1.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controlli 03.1 e 03.2, con riconciliazione 03.3-05.
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
- private.is_profile_auth_user_owner.

I corpi effettivamente installati
sono stati acquisiti durante RC02
mediante pg_get_functiondef.

Nessuna delle quattro funzioni esaminate
risulta direttamente eseguibile
da authenticated o anon.

Le prime tre funzioni appartengono
al perimetro iniziale Write Authority.

La quarta costituisce una dipendenza
esplicita dell helper autoritativo.

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

### 3.1. Generazione del token

Generazione verificata strutturalmente
nelle RPC acquire e complete takeover.

- Generazione esclusivamente server.
- extensions.gen_random_bytes(32).
- 32 byte casuali, pari a 256 bit.
- Rappresentazione esadecimale di 64 caratteri.
- Memorizzazione del solo hash SHA-256.
- Hash memorizzato di 32 byte.
- Token in chiaro restituito nelle risposte di acquisizione e completamento riusciti.
- Nessuna restituzione del token mediante get_state.
- Nessuna restituzione del token mediante already_held.

Il completamento takeover sostituisce
il precedente hash con quello del nuovo token.

La perdita della risposta di acquisizione
o completamento richiede una specifica
verifica del recupero lato Flutter.

Evidenza strutturale E3.
Nessun collaudo statistico o funzionale
della generazione eseguito.

Riferimenti: DB-WA-004, DB-WA-006, DB-WA-007.

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

Dipendenza verificata nel controllo RC02.03.2:

private.is_profile_auth_user_owner(
    target_profile_id,
    current_auth_user_id
)

Firma SQL:

private.is_profile_auth_user_owner(uuid,uuid)

Caratteristiche:

- Linguaggio SQL.
- STABLE.
- SECURITY DEFINER.
- search_path vuoto.
- Restituzione boolean.
- Esecuzione diretta non consentita ad authenticated o anon.

La funzione verifica mediante EXISTS
la presenza di una membership
in public.profile_memberships.

Condizioni congiunte:

- profile_id corrispondente al profilo richiesto.
- auth_user_id corrispondente all utente fornito.
- role uguale a owner.
- is_enabled uguale a true.

La funzione riceve esplicitamente
l identita utente dal chiamante.

Il chiamante interno deve fornire
un identita attendibile.

Nel caso di lock_profile_write_authority
l identita proviene da auth.uid().

La verifica viene effettuata dopo
l acquisizione del blocco transazionale
e del riferimento clock_timestamp().

Non assumere equivalenza automatica
con private.is_profile_owner:
i rispettivi contratti di identificazione
devono essere rispettati.

La verifica strutturale 03.2 e conclusa.

Rimane aperta la verifica funzionale
delle variazioni concorrenti di membership.

Riferimenti: OBS42-OBS46, DB-WA-004.

## 9. Finestra del grant

L helper autoritativo rifiuta
la scrittura durante la finestra
temporale del grant ancora valido.

Condizione temporale rilevata:

Timestamp del grant
piu intervallo di 60 secondi
successivo a server_now.

Il lifecycle e stato riconciliato
strutturalmente nei controlli RC02.03-05.

Durate rilevate:

- Lease ordinario: 120 secondi.
- Richiesta takeover: 600 secondi.
- Concessione takeover: 60 secondi.
- Silenziamento: 5, 15 o 30 minuti.

Durante la richiesta pendente
il titolare conserva l autorita
se tutte le condizioni risultano valide.

Durante la concessione valida
l helper autoritativo impedisce
le mutazioni protette del titolare uscente.

Il destinatario acquisisce la nuova
identita holder e il nuovo token
mediante complete takeover.

La concessione estende il lease
almeno fino al termine dell handoff.

Heartbeat puo rinnovare il lease
durante la concessione senza
prolungare la finestra del grant
o ripristinare l autorita protetta.

Queste evidenze sono strutturali.

Rimangono da verificare i comportamenti
funzionali, concorrenti e lato Flutter.

Riferimenti: DB-WA-005, DB-WA-006, DB-WA-007.

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

Evidenze principali:

- Definizioni effettive dei tre helper iniziali: RC02.03.1.
- Definizione installata di is_profile_auth_user_owner: RC02.03.2.
- Contratti acquire e release: RC02.03.3-03.4.
- Contratti heartbeat e get_state: RC02.04.
- Contratti takeover e riconciliazione lifecycle: RC02.05.

La collocazione sorgente specifica
dell helper owner esplicito non viene
attribuita senza riscontro puntuale.

Riferimenti: DB-WA-004, DB-WA-005,
DB-WA-006, DB-WA-007, TST-RC02-001.

## 12. Verifiche ancora aperte

Verifiche strutturali concluse:

- Definizione is_profile_auth_user_owner.
- Generazione e hash del token.
- Acquisizione del lock.
- Rilascio del lock.
- Heartbeat e scadenza.
- Consultazione dello stato.
- Lifecycle takeover.

Verifiche residue:

- Utilizzo autoritativo degli helper nelle RPC di dominio.
- Gestione del risultato false.
- Conservazione del blocco nella transazione della mutazione.
- Concorrenza effettiva.
- Variazioni concorrenti di membership.
- Comportamento temporale durante attese e scadenze.
- Rollback e integrita transazionale.
- Perdita risposta e recupero del token.
- Integrazione Flutter e comportamento fail-closed.
- Riconciliazione dei collaudi funzionali esistenti.
- Comportamento remoto.

I controlli RC02.01-05 sono conclusi
strutturalmente.

I controlli RC02.06-10 rimangono aperti.

Le verifiche residue devono essere
riconciliate con le famiglie trasversali
WA-V01-WA-V15 definite in DB-WA-007.

Non costituiscono automaticamente
nuovi pacchetti di sviluppo.

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
- DB-WA-004.
- DB-WA-005.
- DB-WA-006.
- DB-WA-007.
- DB-SEC-001.
- DB-VER-001.
- FLT-PROF-001.
- TST-RC02-001.
- RC02-OBS-001.
- RC02.
- RC03.
- RC04.
- RC05.
- NC-RC01-001.

Documento consolidato dalle evidenze
precedentemente acquisite.

Livello strutturale E3.
Collaudo funzionale specifico NV.
Ambiente remoto NV.

Nessuna nuova ispezione integrale
delle definizioni SQL durante CONS.04.

Nessun nuovo collaudo funzionale.
Nessuna modifica tecnica introdotta.
Nessuna variazione quantitativa approvata.
