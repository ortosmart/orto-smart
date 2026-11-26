# TST-RC01-001 - Evidenze identita e profilo

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01, controllo 07.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Macroblocco principale: V1-01.
- Evidenza: E4 limitata a test unitari e widget.
- Collaudo integrato remoto: NV.

## 2. Baseline generale

Riferimento: TST-S046-001.

- Flutter analyze: PASS.
- Flutter test: 1956/1956 PASS.

La ricognizione RC01 ha esaminato
il contenuto dei test pertinenti.

Non costituisce una nuova esecuzione
separata dei 31 test individuati.

## 3. Inventario dei file

| File | Test effettivi |
|---|---:|
| test/core/identity/app_identity_service_test.dart | 5 |
| test/core/profile/profile_context_repository_test.dart | 11 |
| test/core/profile/profile_context_scope_test.dart | 8 |
| test/core/profile/profile_session_gate_test.dart | 7 |
| Totale | 31 |

Dichiarazioni test individuate: 30.

Test effettivi: 31.

La differenza deriva dalla
parametrizzazione worker e viewer
nel ProfileSessionGate.

Ripartizione:

- Test unitari: 16.
- Test widget: 15.

## 4. AppIdentityService

Cinque scenari individuati:

- Creazione iniziale dell'identita client
  e relativa persistenza.
- Riutilizzo dell'identita valida.
- Sostituzione dell'identita corrotta.
- Sostituzione dell'UUID nil.
- Identita client stabile
  e identita sessione differenti.

Riferimento: INF-ID-001.

I test utilizzano persistenza
e generazione UUID controllabili.

Non dimostrano il comportamento
effettivo dello Storage del browser.

## 5. ProfileContextRepository

Undici test individuati.

Copertura rilevata:

- Risoluzione del ruolo owner.
- Risoluzione del ruolo worker.
- Risoluzione del ruolo viewer.
- Caricamento di piu membership.
- Risoluzione di un singolo profilo.
- Rifiuto dell'utente non autenticato.
- Rifiuto della membership assente.
- Rifiuto della membership ambigua.
- Rifiuto del ruolo sconosciuto.
- Rifiuto della membership disabilitata.
- Rifiuto dell'identificativo non valido.

Riferimento: FLT-PROF-001.

## 6. ProfileContextScope

Otto test individuati.

Copertura rilevata:

- Accesso al contesto mediante of.
- Accesso mediante read.
- Gestione dello Scope assente.
- Notifica delle variazioni del profilo.
- Notifica delle variazioni del ruolo.
- Mancata notifica per contesti equivalenti.
- Lettura del contesto aggiornato.
- Lettura senza sottoscrizione.

La copertura riguarda il comportamento
del componente Flutter condiviso.

## 7. ProfileSessionGate

Sette test effettivi individuati.

Scenari:

- Caricamento, acquisizione del lock
  e avvio heartbeat per il writer.
- Errore iniziale e ripetizione,
  senza acquisizione prematura.
- Rilascio alla rimozione del widget.
- Risposta tardiva del profilo
  dopo rimozione del widget.
- Disponibilita del contesto dopo
  identita e inizializzazione del lock.
- Membership worker in sola lettura.
- Membership viewer in sola lettura.

Per worker e viewer:

- Stato readOnlyMember.
- Nessuna acquisizione del lock.
- Nessuna pianificazione heartbeat.
- requireLease rifiuta la richiesta.

Riferimenti:

- FLT-PROF-001.
- RC02.

## 8. Limiti delle evidenze

I test esaminati utilizzano
dipendenze simulate.

Non dimostrano direttamente:

- Autenticazione reale con Supabase.
- Persistenza reale su Edge e Safari.
- Concorrenza fra schede del browser.
- Revoca reale della membership.
- Comportamento remoto delle policy.
- Scritture dirette senza edit lock.
- Recupero integrato dopo interruzioni.

La mancata individuazione di uno
scenario nei quattro file esaminati
non dimostra la sua assenza
dall'intera suite di test.

## 9. Regole di riutilizzo

RIUTILIZZARE:

I test esistenti e le relative evidenze
quando commit, dipendenze e condizioni
rimangono pertinenti.

INTEGRARE:

Gli scenari specifici mancanti
nei nuovi domini.

VERIFICARE:

Gli scenari reali non dimostrati
dalle dipendenze simulate.

Non riscrivere test equivalenti
senza motivazione tecnica.

Non utilizzare un PASS unitario
come sostituto del collaudo integrato.

## 10. Collegamenti

- TST-S046-001.
- INF-AUTH-001.
- INF-ID-001.
- FLT-PROF-001.
- DB-PROF-001.
- DB-SEC-001.
- RC01.
- RC02.
- RC03.
- RC17.

Nessun nuovo collaudo eseguito
durante il consolidamento documentale.

Nessuna modifica applicativa introdotta.
