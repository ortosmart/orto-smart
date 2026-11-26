# RC01-INV-001 - Infrastrutture riutilizzabili

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: conclusione tecnica RC01.
- Macroblocco: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Infrastrutture individuate: 20.

## 2. Inventario

| ID | Infrastruttura | Evidenza | Riferimento |
|---|---|---|---|
| R01 | Inizializzazione Supabase | E3 | INF-AUTH-001 |
| R02 | LoginPage | E3 | INF-AUTH-001 |
| R03 | AuthGate | E3 | INF-AUTH-001 |
| R04 | ProfileContext | E4 | FLT-PROF-001 |
| R05 | ProfileMemberRole | E4 | FLT-PROF-001 |
| R06 | ProfileContextRepository | E4 | FLT-PROF-001 |
| R07 | ProfileContextScope | E4 | FLT-PROF-001 |
| R08 | ProfileSessionGate | E4 | FLT-PROF-001 |
| R09 | ClientInstanceIdStore | E4 | INF-ID-001 |
| R10 | Persistenza SharedPreferences | E3 | INF-ID-001 |
| R11 | AppIdentityService | E4 | INF-ID-001 |
| R12 | AppSessionIdentity | E4 | INF-ID-001 |
| R13 | Tabella profiles | E3 | DB-PROF-001 |
| R14 | Tabella profile_memberships | E3 | DB-PROF-001 |
| R15 | Tabella workers | E3 | DB-PROF-001 |
| R16 | Helper di sicurezza | E3 | DB-SEC-001 |
| R17 | Policy RLS di lettura | E3 | DB-SEC-001 |
| R18 | Funzione comune di versionamento | E3 | DB-VER-001 |
| R19 | Trigger di aggiornamento | E3 | DB-VER-001 |
| R20 | Integrazione iniziale Write Authority | E4 | FLT-PROF-001 |

Gli identificativi R01-R20 sono locali
alla ricognizione RC01.

## 3. Distribuzione delle evidenze

- E3: 11 infrastrutture.
- E4: 9 infrastrutture.
- Totale: 20 infrastrutture.

E4 riguarda i test unitari e widget
esaminati durante RC01.

Non costituisce attestazione
di collaudo integrato remoto.

## 4. Regole di riutilizzo

R01-R12:

Riutilizzare i componenti Flutter
di autenticazione, identita e profilo.

R13-R15:

Riutilizzare le strutture dati esistenti
per i rispettivi significati funzionali.

R16-R17:

Riutilizzare gli helper e i principi
di separazione dei profili.

Verificare le autorizzazioni specifiche
di ogni nuovo dominio.

R18-R19:

Riutilizzare il versionamento comune
quando compatibile con il contratto
della mutazione autoritativa.

R20:

Riutilizzare l'integrazione iniziale
con Write Authority.

Completare gli approfondimenti RC02.

## 5. Vincoli

Il riutilizzo non autorizza:

- Scritture dirette non autoritative.
- Eliminazione dei controlli di sicurezza.
- Eliminazione dei collaudi specifici.
- Assunzione di operativita remota.
- Riduzione automatica delle stime.

La NC-RC01-001 rimane aperta.

## 6. Dipendenze principali

- RC02: Write Authority.
- RC03: RLS e autorizzazioni.
- RC04: versioni e concorrenza.
- RC05: journal e ricevute.
- RC07: ambienti e migrazioni.
- RC17: collaudi e distribuzione.

Domini utilizzatori principali:

- V1-02.
- V1-13.
- V1-15.
- V1-16.
- V1-17.
- V1-18.

## 7. Stato quantitativo

Baseline V1-01:

- A: 13:05.
- B: 28:55.
- Totale: 42:00.

Le venti infrastrutture non costituiscono
venti riduzioni quantitative.

Riconciliazione PERT originaria: aperta.

Riduzioni approvate: 0 minuti.

Incrementi approvati: 0 minuti.

Nessuna variazione quantitativa introdotta.
