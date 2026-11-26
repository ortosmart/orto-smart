# DB-SEC-001 - Autorizzazioni del profilo

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01, controllo 06.
- Macroblocchi: V1-01 e V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente: PostgreSQL locale.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

## 2. Helper di sicurezza

Funzioni esaminate:

- private.is_profile_member(uuid).
- private.is_profile_owner(uuid).
- private.can_access_garden(uuid).

Caratteristiche rilevate:

- Funzioni SQL.
- STABLE.
- SECURITY DEFINER.
- search_path vuoto.
- Riferimenti espliciti agli schemi.
- Verifica dell'identita auth.uid().

La prima funzione verifica
una membership abilitata.

La seconda verifica
una membership owner abilitata.

La terza verifica l'accesso all'orto
attraverso il profilo e la membership.

Questi helper non verificano
da soli il possesso dell'edit lock.

## 3. Accesso allo schema private

Nella migrazione originaria:

- Revoca dell'accesso pubblico.
- USAGE ad authenticated.
- Revoca dell'esecuzione pubblica
  delle funzioni pertinenti.
- EXECUTE ad authenticated
  per i tre helper esaminati.

Le definizioni effettive degli helper
sono state esaminate nel database locale.

Non estendere queste autorizzazioni
indiscriminatamente alle altre
funzioni dello schema private.

## 4. Row Level Security

RLS attiva sulle tabelle:

- public.profiles.
- public.profile_memberships.
- public.workers.

Sei policy rilevate nel database locale.

Tutte le sei policy esaminate
sono PERMISSIVE per authenticated.

La RLS e i privilegi SQL devono
essere considerati congiuntamente.

## 5. Policy profiles

SELECT:

Accesso ai membri abilitati
del profilo pertinente.

UPDATE:

Consentito all'owner pertinente
attraverso USING e WITH CHECK.

La policy non richiede direttamente
il possesso della Write Authority.

## 6. Policy profile_memberships

SELECT:

- Owner del profilo pertinente.
- Utente interessato alla propria
  membership abilitata.

Non sono state rilevate
policy di scrittura diretta
per authenticated.

## 7. Policy workers

SELECT:

Accesso ai membri abilitati
del profilo pertinente.

INSERT:

Controllo di proprieta del profilo.

UPDATE:

Controllo di proprieta del profilo
mediante USING e WITH CHECK.

Le policy di scrittura esaminate
non richiedono direttamente
il possesso della Write Authority.

## 8. Privilegi a livello tabella

Risultati rilevati per authenticated:

| Tabella | SELECT | INSERT | UPDATE | DELETE | TRUNCATE |
|---|---|---|---|---|---|
| profiles | Si | No | No | No | No |
| profile_memberships | Si | No | No | No | No |
| workers | Si | Si | No | No | No |

L'assenza del privilegio UPDATE
a livello tabella non esclude
privilegi UPDATE sulle singole colonne.

## 9. Privilegi a livello colonna

Risultati rilevati:

- SELECT sulle 21 colonne complessive.
- INSERT sulle 8 colonne di workers.
- UPDATE su 4 colonne complessive.

Colonne aggiornabili:

- profiles.display_name.
- workers.display_name.
- workers.notes.
- workers.is_active.

Il privilegio INSERT su workers
comprende anche colonne tecniche:

- id.
- profile_id.
- created_at.
- updated_at.
- row_version.

I vincoli e le policy applicabili
rimangono comunque operativi.

Non e' stata dimostrata
una modifica abusiva effettiva.

## 10. Percorsi diretti individuati

Identificativi della ricognizione:

- WA-RC01-01: profiles.display_name.
- WA-RC01-02: INSERT workers.
- WA-RC01-03: workers.display_name.
- WA-RC01-04: workers.notes.
- WA-RC01-05: workers.is_active.

Sono cinque percorsi strutturali
di scrittura diretta individuati.

Le policy verificano la proprieta
del profilo, ma non il possesso
dell'edit lock.

La verifica della versione attesa
non e' richiesta dai percorsi diretti
esaminati.

Riferimento:

NC-RC01-001, classificazione P1.

La non conformita rimane aperta.

## 11. Limiti della ricognizione

Sono state esaminate:

- Migrazione originaria.
- Riferimenti nelle migrazioni successive.
- Privilegi effettivi locali.
- Privilegi sulle colonne.
- Policy effettive locali.
- Trigger effettivi locali.
- Definizioni degli helper.

La ricerca testuale nelle migrazioni
successive non esclude modifiche
introdotte da istruzioni generiche.

La configurazione effettiva locale
costituisce l'evidenza principale.

Non e' stato eseguito in RC01
un tentativo funzionale di scrittura
senza edit lock.

L'esposizione effettiva mediante
Data API e il comportamento remoto
rimangono da verificare.

## 12. Riutilizzo e collegamenti

RIUTILIZZARE:

- Helper di appartenenza.
- Helper di proprieta.
- Helper di accesso all'orto.
- Modello di separazione dei profili.

VERIFICARE:

- Privilegi dei nuovi domini.
- Policy RLS.
- Percorsi di scrittura diretta.
- Write Authority.
- Controllo della versione attesa.

Non utilizzare le policy esistenti
come modello completo di scrittura
senza considerare NC-RC01-001.

Collegamenti:

- ARC-002.
- DB-PROF-001.
- DB-VER-001.
- FLT-PROF-001.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

Nessuna modifica al database introdotta.
