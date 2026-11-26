# DB-WA-002 - Struttura edit lock

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC02, controllo 02.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

## 2. Tabella autorevole

public.profile_edit_locks

Struttura rilevata:

- 18 colonne.
- 9 colonne obbligatorie.
- 9 colonne facoltative.
- 1 chiave primaria.
- 4 chiavi esterne.
- 10 vincoli CHECK.
- 1 indice rilevato.
- 1 policy RLS.

Nessun trigger riportato
nella descrizione esaminata.

## 3. Colonne obbligatorie

| Colonna | Tipo |
|---|---|
| profile_id | UUID |
| holder_auth_user_id | UUID |
| client_instance_id | UUID |
| holder_session_id | UUID |
| lock_token_hash | bytea |
| acquired_at | timestamptz |
| heartbeat_at | timestamptz |
| expires_at | timestamptz |
| row_version | bigint |

row_version ha valore predefinito 1.

profile_id costituisce la chiave primaria.

La struttura consente al massimo
un record edit lock per profilo.

Il possesso effettivo del lock
dipende anche dalle condizioni
temporali e dalle verifiche autoritative.

## 4. Colonne facoltative

Nove colonne dedicate a:

- Identita utente richiedente takeover.
- Identita client richiedente.
- Identita sessione richiedente.
- Timestamp della richiesta.
- Identita utente destinatario del grant.
- Identita client destinatario.
- Identita sessione destinatario.
- Timestamp del grant.
- takeover_silenced_until.

I nomi completi delle colonne
di richiesta e concessione devono
essere consultati nello schema effettivo
quando necessari allo sviluppo.

## 5. Vincoli di integrita

Dieci condizioni CHECK rilevate:

1. expires_at successivo a heartbeat_at.
2. heartbeat_at non precedente ad acquired_at.
3. Hash del token lungo 32 byte.
4. row_version maggiore o uguale a 1.
5. Richiesta takeover interamente
   valorizzata oppure interamente assente.
6. Grant takeover interamente
   valorizzato oppure interamente assente.
7. Identita della richiesta diversa
   dall'identita del titolare.
8. Identita del grant diversa
   dall'identita del titolare.
9. Richiesta e grant mutuamente esclusivi.
10. Termine di silenzio non precedente
    ad acquired_at, quando valorizzato.

Le condizioni sono riportate
in forma funzionale sintetica.

Per modifiche tecniche consultare
le espressioni SQL effettive.

## 6. Relazioni

Quattro chiavi esterne rilevate:

- profile_id verso profiles.
- Identita autenticata del titolare
  verso auth.users.
- Identita autenticata del richiedente
  verso auth.users.
- Identita autenticata del destinatario
  del grant verso auth.users.

Eliminazione referenziata RESTRICT.

Le dipendenze devono essere considerate
nelle eventuali operazioni amministrative.

## 7. Protezione del token

Il database conserva lock_token_hash.

L'hash ha dimensione di 32 byte.

La funzione di hashing esaminata
utilizza SHA-256.

Riferimento:

DB-WA-003.

Non conservare token reali,
credenziali o valori sensibili
nel Registro tecnico.

La qualita della generazione del token
rimane da verificare nelle RPC pertinenti.

## 8. Row Level Security

Risultati locali:

- RLS abilitata: True.
- RLS forzata: False.

Policy rilevata:

SELECT per authenticated.

Condizione:

private.is_profile_member(profile_id).

L'accesso in lettura e' subordinato
all'appartenenza al profilo.

La mancata attivazione di FORCE RLS
non costituisce da sola
una non conformita dimostrata.

## 9. Privilegi a livello tabella

| Ruolo | SELECT | INSERT | UPDATE | DELETE | TRUNCATE |
|---|---|---|---|---|---|
| authenticated | Si | No | No | No | No |
| anon | No | No | No | No | No |

Nessuna scrittura diretta rilevata
per authenticated o anon
nei privilegi esaminati.

## 10. Privilegi a livello colonna

Verifica effettuata su:

- 18 colonne.
- 2 ruoli.
- 36 combinazioni ruolo-colonna.
- 108 valori di privilegio.

Risultati:

authenticated:

- SELECT: 18/18.
- INSERT: 0/18.
- UPDATE: 0/18.

anon:

- SELECT: 0/18.
- INSERT: 0/18.
- UPDATE: 0/18.

La lettura SQL di tutte le colonne
comprende lock_token_hash.

Non e' stata dimostrata
una compromissione del token.

Non e' stata verificata
l'esposizione effettiva del campo
attraverso la Data API.

## 11. Osservazioni aperte

- Necessita della lettura diretta
  di tutte le colonne.
- Opportunita di minimizzare
  i privilegi SELECT.
- Generazione ed entropia del token.
- Incrementi effettivi di row_version.
- Validazioni interne delle RPC.
- Comportamento concorrente.
- Scadenza e rinnovo.
- Gestione takeover.
- Equivalenza dell'ambiente remoto.

Nessuna modifica dei privilegi
e' stata approvata.

## 12. Riutilizzo

RIUTILIZZARE:

- Tabella edit lock esistente.
- Identita del titolare.
- Identita client e sessione.
- Strutture richiesta e grant.
- Vincoli di integrita.

VERIFICARE:

- Contratti effettivi delle RPC.
- Protezione dei metadati.
- Necessita dei privilegi di lettura.
- Comportamento integrato.

Non introdurre una tabella edit lock
separata per ogni dominio.

Non utilizzare la sola esistenza
del record come prova di autorita.

## 13. Collegamenti e limiti

- INF-WA-001.
- DB-WA-001.
- DB-WA-003.
- INF-ID-001.
- DB-SEC-001.
- DB-VER-001.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

Evidenze consolidate dalla ricognizione
locale gia eseguita.

Nessun nuovo collaudo funzionale.

Nessuna modifica tecnica introdotta.
