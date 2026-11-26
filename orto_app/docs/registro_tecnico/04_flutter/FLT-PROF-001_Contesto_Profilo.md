# FLT-PROF-001 - Contesto del profilo

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01.
- Macroblocco: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Evidenza: E4 limitata a test unitari e widget.
- Riferimenti: RC01, RC02, RC03, RC05.

## 2. Componenti

- ProfileMemberRole.
- ProfileContext.
- ProfileContextScope.
- ProfileContextRepository.
- ProfileSessionGate.

Percorsi funzionali:

- lib/core/profile.
- lib/data/repositories.

## 3. Ruoli

ProfileMemberRole riconosce:

- owner.
- worker.
- viewer.

Valori sconosciuti vengono rifiutati.

ProfileContext contiene:

- profileId.
- role.

canWrite identifica il ruolo owner.

Il ruolo owner non sostituisce
la verifica dell'autorita di scrittura.

## 4. Validazione del contesto

ProfileContext.fromMembershipMap
rifiuta i valori non conformi.

Controlli rilevati:

- profileId di tipo stringa.
- UUID valido.
- UUID non nil.
- Ruolo riconosciuto.
- is_enabled uguale a true.

Il contesto non viene costruito
arbitrariamente a partire
da dati incompleti.

## 5. ProfileContextRepository

Utilizza currentUser di Supabase.

Interroga profile_memberships.

Campi selezionati:

- profile_id.
- role.
- is_enabled.

Filtri:

- auth_user_id dell'utente corrente.
- is_enabled uguale a true.

Ordinamento:

created_at.

resolveSingleProfileContext
richiede un solo profilo valido.

Esiti rilevati:

- Utente non autenticato.
- Membership assente.
- Membership ambigua.
- Membership valida.

Non selezionare arbitrariamente
uno fra piu profili disponibili.

## 6. ProfileContextScope

InheritedWidget condiviso.

Metodi:

- of.
- read.

L'assenza dello Scope genera errore.

Le notifiche dipendono
dalle variazioni di profileId e role.

read consente la lettura
senza sottoscrizione alle notifiche.

Riutilizzare lo Scope nei domini
senza duplicare il contesto del profilo.

## 7. ProfileSessionGate

Sequenza rilevata:

1. Risoluzione del profilo.
2. Acquisizione delle identita.
3. Inizializzazione del controller
   Write Authority.
4. Esposizione del contesto.
5. Esposizione della Write Authority.

Stati gestiti:

- Caricamento.
- Errore.
- Disponibilita del contesto.

Utilizza controlli mounted
e identificativo di generazione
per le inizializzazioni asincrone.

Il tentativo di ripetizione
e' protetto dalle inizializzazioni
contemporanee gia in corso.

La disponibilita del contesto
non equivale necessariamente
alla disponibilita del lock.

## 8. Integrazioni

Struttura condivisa:

ProfileContextScope
  ProfileWriteAuthorityScope
    Interfaccia applicativa

ProfileSessionGate inizializza inoltre
il servizio delle mutazioni
delle pianificazioni stagionali.

Componenti collegati:

- SeasonalPlanningMutationService.
- MutationOperationCoordinator.
- MutationOperationJournal.
- SharedPreferencesMutationJournalPersistence.

La ricognizione di questi componenti
appartiene principalmente alla RC05.

## 9. Rilascio delle risorse

Durante dispose:

- Incremento della generazione.
- Richiesta asincrona di release.
- Dispose del controller.

La correttezza del rilascio
in tutte le condizioni concorrenti
deve essere approfondita nella RC02.

Non assumere che la richiesta
asincrona di rilascio sia sempre
completata prima della distruzione.

## 10. Evidenze di collaudo

File:

- test/core/profile/profile_context_repository_test.dart.
- test/core/profile/profile_context_scope_test.dart.
- test/core/profile/profile_session_gate_test.dart.

Test effettivi individuati:

- Repository: 11.
- Scope: 8.
- Gate: 7.
- Totale: 26.

Il conteggio del Gate comprende
i casi parametrizzati worker e viewer.

Copertura rilevata:

- Risoluzione del profilo.
- Ruoli validi e non validi.
- Membership assenti o ambigue.
- Validazione dei dati.
- Notifiche dello Scope.
- Caricamento e ripetizione.
- Inizializzazione Write Authority.
- Rilascio delle risorse.
- Risposte asincrone tardive.
- Membri in sola lettura.

Test unitari e widget con dipendenze
simulate, non collaudi remoti.

## 11. Osservazioni aperte

- Revoca della membership durante
  una sessione attiva.
- Rilascio del lock e dispose.
- Recupero dopo inizializzazione fallita.
- Isolamento del journal.
- Distinzione fra membership
  e operatori di lavoro.
- Verifica delle policy RLS.

Approfondimenti assegnati
alle riconciliazioni pertinenti.

## 12. Riutilizzo

RIUTILIZZARE:

- ProfileContext.
- ProfileMemberRole.
- ProfileContextRepository.
- ProfileContextScope.
- ProfileSessionGate.

INTEGRARE:

- Nuovi domini nel contesto esistente.

VERIFICARE:

- Revoca delle autorizzazioni.
- Gestione delle sessioni reali.
- Concorrenza e recupero.
- Comportamento sui dispositivi.

Non introdurre un secondo sistema
di risoluzione del profilo.

Non utilizzare canWrite come unica
autorizzazione alle mutazioni.

Nessuna modifica applicativa introdotta.
