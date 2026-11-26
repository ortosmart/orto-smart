# DB-PROF-001 - Profili, membership e operatori

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01, controllo 06.
- Macroblocco principale: V1-01.
- Macroblocchi utilizzatori: V1-02, V1-13, V1-16.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente verificato: PostgreSQL locale.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

## 2. Fonte tecnica

Migrazione originaria:

supabase/migrations/20260817103916_database_v1_baseline.sql

Riferimenti rilevati:

- profiles: riga 21.
- profile_memberships: riga 44.
- Indice owner: riga 79.
- workers: riga 130.

Le strutture e le autorizzazioni sono
state confrontate con il database locale
durante la ricognizione RC01.

## 3. Tabella profiles

Responsabilita:

Identita del profilo applicativo.

Elementi rilevati:

- id UUID, chiave primaria.
- Riferimento ad auth.users.
- Eliminazione referenziata RESTRICT.
- display_name obbligatorio e non vuoto.
- created_at.
- updated_at.
- row_version maggiore o uguale a 1.

Il profilo non costituisce
un operatore di lavoro.

Il nome visualizzato non costituisce
un identificativo tecnico.

## 4. Tabella profile_memberships

Responsabilita:

Associazione fra utente autenticato
e profilo applicativo.

Elementi rilevati:

- id UUID con generazione predefinita.
- profile_id.
- auth_user_id.
- role.
- is_enabled.
- created_at.
- updated_at.
- row_version.

Vincoli:

- Chiave primaria id.
- Riferimenti con eliminazione RESTRICT.
- Unicita della coppia
  profile_id e auth_user_id.
- Ruoli owner, worker e viewer.
- Membership abilitata per impostazione
  predefinita.
- Per owner, auth_user_id uguale
  a profile_id.
- Membership owner abilitata.
- Indice univoco parziale per owner.

L'indice garantisce al massimo
un owner per profilo.

Non dimostra da solo che ogni profilo
possieda necessariamente un owner.

La procedura di bootstrap del profilo
rimane da verificare.

## 5. Tabella workers

Responsabilita:

Identificazione degli operatori
che svolgono lavoro nell'orto.

Elementi rilevati:

- id UUID con generazione predefinita.
- profile_id.
- display_name.
- notes.
- is_active.
- created_at.
- updated_at.
- row_version.

Vincoli rilevati:

- Chiave primaria id.
- Riferimento al profilo con RESTRICT.
- Nome obbligatorio e non vuoto.
- Operatore attivo per impostazione
  predefinita.
- row_version maggiore o uguale a 1.

Non e' presente un collegamento diretto
obbligatorio con auth.users.

Non e' stata rilevata unicita
del nome dell'operatore.

Sono pertanto possibili omonimie.

## 6. Separazione delle responsabilita

Non confondere:

- Utente autenticato.
- Profilo applicativo.
- Membership.
- Ruolo di accesso.
- Operatore di lavoro.

Un operatore puo' rappresentare
una persona che lavora nell'orto
senza possedere credenziali applicative.

Il ruolo worker della membership
non equivale automaticamente
a un record della tabella workers.

La gestione del titolare come operatore
rimane da definire o verificare.

## 7. Dipendenze

Flutter:

- ProfileContext.
- ProfileMemberRole.
- ProfileContextRepository.
- ProfileContextScope.
- ProfileSessionGate.

Database:

- Helper di appartenenza al profilo.
- Helper di proprieta del profilo.
- Policy RLS.
- Trigger di aggiornamento e versione.

Domini futuri:

- Attivita.
- Timer.
- Registrazioni di lavoro.
- Raccolti.
- Irrigazione.
- Interventi.
- Amministrazione.

Le associazioni specifiche dei domini
devono essere verificate o sviluppate
secondo il relativo perimetro.

## 8. Osservazioni aperte

- Bootstrap del profilo.
- Garanzia di esistenza dell'owner.
- Gestione del titolare come operatore.
- Gestione delle omonimie.
- Conservazione dello storico
  dopo disattivazione dell'operatore.
- Percorsi autoritativi di modifica.
- Controllo della versione attesa.
- Dipendenze storiche ed eliminazioni.

La ricognizione non dimostra
che tutte queste funzionalita manchino.

## 9. Riutilizzo

RIUTILIZZARE:

- Strutture esistenti dei profili.
- Struttura delle membership.
- Struttura degli operatori.
- Identificativi UUID.
- Relazioni e vincoli verificati.

INTEGRARE:

- Gestione degli operatori.
- Registrazione del lavoro.
- Interfacce amministrative.

VERIFICARE:

- Bootstrap.
- Percorsi di scrittura.
- Sicurezza e integrita.
- Dipendenze storiche.

Non creare una seconda anagrafica
degli operatori senza motivazione.

## 10. Collegamenti e limiti

- INF-AUTH-001.
- INF-ID-001.
- FLT-PROF-001.
- DB-SEC-001.
- DB-VER-001.
- NC-RC01-001.
- DUP-A01.
- DUP-B01.
- DUP-B02.

Le evidenze riguardano il codice
e il database locale esaminati.

Il database remoto non e' verificato.

Nessuna modifica al database introdotta.
