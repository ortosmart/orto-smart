# ARC-002 - Sicurezza, autorita e integrita

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: decisioni precedenti e STEP 274-275
- Proprietario principale: V1-02
- Riconciliazioni: RC01, RC02, RC03, RC04, RC05

## 1. Principi fondamentali

- Autorita finale delle scritture sul server.
- RLS sulle tabelle applicative pertinenti.
- Privilegi minimi necessari.
- RPC autoritative per le mutazioni previste.
- Controlli di appartenenza e ruolo.
- Single-writer per le operazioni protette.
- Identificazione distinta di client e sessione.
- Verifica della validita temporale del lease.
- Gestione esplicita della concorrenza.
- Protezione contro aggiornamenti obsoleti.

La presenza di un controllo Flutter
non sostituisce il controllo server-side.

## 2. Write Authority

Riutilizzare l'infrastruttura comune esistente.

Distinguere:

- Acquisizione del lock.
- Mantenimento mediante heartbeat.
- Rilascio.
- Scadenza.
- Richiesta di takeover.
- Concessione.
- Completamento del takeover.
- Consultazione dello stato.
- Verifica transazionale dell'autorita.

Le RPC di dominio devono utilizzare
il contratto autoritativo appropriato.

Non implementare un secondo sistema
di lock per ogni nuovo dominio.

## 3. Fail-closed

In assenza dei prerequisiti necessari,
non autorizzare la mutazione.

Non interpretare uno stato sconosciuto
come autorizzazione valida.

Non considerare il semplice accesso
a una pagina come prova di autorita.

## 4. Versionamento

Le entita soggette a concorrenza devono
utilizzare i meccanismi di versionamento previsti.

Distinguere:

- Versione corrente del record.
- Versione attesa dalla mutazione.
- Aggiornamento atomico.
- Conflitto di versione.
- Rivalidazione dello stato.

Non sovrascrivere automaticamente
modifiche concorrenti non esaminate.

## 5. Journal e ricevute

Distinguere:

- Preparazione della mutazione.
- Invio.
- Esito certo.
- Esito incerto.
- Recupero.
- Riconciliazione.

Non dichiarare riuscita una mutazione
in assenza di evidenza sufficiente.

Non ripetere indiscriminatamente
una mutazione dall'esito incerto.

Riutilizzare journal, coordinamento e ricevute
quando pertinenti al contratto del dominio.

La disponibilita del journal per le pianificazioni
non dimostra la sua integrazione in tutti i domini.

## 6. Integrita delle operazioni

Le operazioni correlate che richiedono atomicita
devono essere gestite nella stessa transazione.

Rivalidare sul server i prerequisiti
prima delle mutazioni autoritative.

Conservare la coerenza tra:

- Identita.
- Relazioni.
- Stato funzionale.
- Geometria.
- Validita temporale.
- Quantita.
- Versionamento.
- Evidenze tecniche.

## 7. Amministrazione e correzioni

Distinguere:

- Modifica ordinaria.
- Correzione controllata.
- Annullamento.
- Disattivazione.
- Riattivazione.
- Archiviazione.
- Cancellazione eccezionale.
- Riconciliazione.
- Ripristino.

La cancellazione fisica non deve diventare
il normale percorso di gestione dello storico.

Le operazioni amministrative devono rispettare
dipendenze, autorita e integrita.

## 8. Criticita note

NC-RC01-001:

Percorsi diretti di mutazione su profiles e workers
non ancora protetti dal contratto comune
di Write Authority.

Priorita P1.
Correzione non ancora autorizzata.

OBS-RC02-29:

Leggibilita SQL dell'hash del token del lock
per i membri autorizzati dalla RLS.

Valutazione di sicurezza ancora aperta.

Non considerare queste criticita risolte
per effetto della sola registrazione.

## 9. Verifiche future

- RC02: Write Authority.
- RC03: RLS e autorizzazioni.
- RC04: concorrenza e versionamento.
- RC05: journal e ricevute.
- RC17: collaudi integrati.

Le schede specifiche conserveranno contratti,
sorgenti, test e limitazioni.
