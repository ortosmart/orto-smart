# RC01 - Conclusione tecnica

## 1. Identificazione

- Identificativo: RC01.
- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Macroblocco principale: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Stato tecnico: CONCLUSO E APPROVATO.
- Stato quantitativo: APERTO.
- Ambiente remoto: NV.

## 2. Oggetto della ricognizione

Autenticazione, identita client,
identita sessione, contesto del profilo,
membership, operatori e infrastrutture
di sicurezza collegate.

La ricognizione ha identificato
componenti disponibili, evidenze,
possibilita di riutilizzo e verifiche residue.

Non costituisce accettazione operativa
del macroblocco V1-01.

## 3. Risultati consolidati

| Indicatore | Risultato |
|---|---|
| Controlli tecnici conclusi | 8/8 |
| Infrastrutture individuate | 20 |
| Infrastrutture E3 | 11 |
| Infrastrutture E4 | 9 |
| Test unitari individuati | 16 |
| Test widget individuati | 15 |
| Test complessivi individuati | 31 |
| Elementi residui o da verificare | 30 |
| Non conformita P1 aperte | 1 |
| Riconciliazione quantitativa | Aperta |

I livelli E4 riguardano
test unitari e widget.

Non attestano collaudi integrati
su database remoto o dispositivi reali.

## 4. Indice delle schede autorevoli

| Scheda | Contenuto |
|---|---|
| INF-AUTH-001 | Autenticazione |
| INF-ID-001 | Identita client e sessione |
| FLT-PROF-001 | Contesto del profilo |
| DB-PROF-001 | Profili, membership e operatori |
| DB-SEC-001 | Autorizzazioni del profilo |
| DB-VER-001 | Trigger e versionamento |
| TST-RC01-001 | Evidenze dei test |
| RC01-INV-001 | Venti infrastrutture |
| RC01-RES-001 | Trenta elementi residui |
| NC-RC01-001 | Non conformita P1 |

Consultare le schede pertinenti
senza ripetere l'intera ricognizione.

## 5. Fonti tecniche principali

Flutter:

- lib/main.dart.
- lib/core/identity.
- lib/core/profile.
- lib/data/repositories.
- LoginPage.
- ProfileContextRepository.
- ProfileSessionGate.

Database:

- 20260817103916_database_v1_baseline.sql.
- profiles.
- profile_memberships.
- workers.
- Helper di sicurezza del profilo.
- Funzione comune di versionamento.

Collaudi:

- test/core/identity/app_identity_service_test.dart.
- test/core/profile/profile_context_repository_test.dart.
- test/core/profile/profile_context_scope_test.dart.
- test/core/profile/profile_session_gate_test.dart.

I percorsi non ancora riportati
integralmente possono essere risolti
mediante git ls-files.

## 6. Collegamenti alle sovrapposizioni

DUP-A:

- DUP-A01.
- DUP-A06.
- DUP-A07.
- DUP-A08.
- DUP-A09.

DUP-B:

- DUP-B01.
- DUP-B02.
- DUP-B07.
- DUP-B08.
- DUP-B12.

I collegamenti identificano
possibili responsabilita condivise.

Non dimostrano automaticamente
duplicazioni quantitative.

## 7. Dipendenze RC

- RC02: Write Authority.
- RC03: RLS, permessi e RPC.
- RC04: versioni e concorrenza.
- RC05: journal e ricevute.
- RC07: migrazioni e ambienti.
- RC17: collaudi e distribuzione.

La non conformita NC-RC01-001
deve essere approfondita attraverso
le riconciliazioni pertinenti.

## 8. Baseline quantitativa

Macroblocco V1-01:

- Maturita tecnica A: 70,20%.
- Maturita tecnica V1: 48,65%.
- Residuo A: 13:05.
- Residuo B: 28:55.
- Residuo complessivo: 42:00.

Valori precedentemente approvati
e mantenuti invariati.

Non costituiscono una nuova valutazione
derivante dalla chiusura tecnica RC01.

Riconciliazione PERT originaria: aperta.

Riduzioni approvate: 0 minuti.

Incrementi approvati: 0 minuti.

## 9. Procedura di riutilizzo futuro

Prima di sviluppare componenti
che dipendono da identita e profilo:

1. Consultare questa scheda.
2. Consultare RC01-INV-001.
3. Individuare i componenti pertinenti.
4. Consultare le relative schede tecniche.
5. Verificare eventuali modifiche Git.
6. Verificare le non conformita aperte.
7. Riutilizzare i componenti disponibili.
8. Integrare le funzionalita necessarie.
9. Eseguire i collaudi pertinenti.
10. Aggiornare le evidenze interessate.

Non ripetere le verifiche strutturali
gia valide per il medesimo contesto.

Non assumere equivalenza fra
ambiente locale e ambiente remoto.

## 10. Osservazioni trasversali

Durante la ricognizione RC01
e' stato rilevato il riavvio ripetuto
del container Vector locale.

Il database risultava operativo.

Nessun intervento sul container
e' stato eseguito.

Lo stato attuale del container
non e' attestato da questa osservazione.

E' stata inoltre rilevata una
visualizzazione non corretta
di alcuni caratteri nella shell.

La lettura e' stata adeguata
all'utilizzo della codifica UTF8.

Queste osservazioni non modificano
automaticamente la maturita V1-01.

## 11. Limiti del consolidamento

La scheda consolida le evidenze
e i risultati recuperati dalla RC01.

Non costituisce una nuova esecuzione
dei collaudi o una nuova ispezione
integrale del codice e del database.

I trenta elementi residui
non rappresentano automaticamente
trenta nuove attivita di sviluppo.

La chiusura tecnica della ricognizione
non implica la risoluzione della NC.

## 12. Chiusura

Ricognizione tecnica RC01:

CONCLUSA E APPROVATA.

Consolidamento nel Registro:

S046, STEP 275.R.06.

Riconciliazione quantitativa:

APERTA.

Non conformita NC-RC01-001:

APERTA, P1.

Prossima ricognizione:

RC02, dal punto di sospensione 03.2.

Nessuna variazione quantitativa introdotta.
