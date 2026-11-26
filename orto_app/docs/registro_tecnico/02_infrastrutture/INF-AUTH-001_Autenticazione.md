# INF-AUTH-001 - Autenticazione

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01.
- Macroblocco: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente: codice Flutter esaminato in S046.
- Evidenza: E3.
- Riferimenti: DUP-A01, RC01, RC03, RC17.

## 2. Componenti esistenti

- Supabase.initialize.
- AuthGate.
- LoginPage.
- ProfileSessionGate.

Riferimenti tecnici:

- lib/main.dart.
- login_page.dart.
- profile_session_gate.dart.

I percorsi non riportati integralmente
devono essere risolti mediante git ls-files.

## 3. Inizializzazione

Supabase viene inizializzato
prima dell'avvio dell'applicazione.

AuthGate utilizza:

- StreamBuilder.
- onAuthStateChange.
- currentSession.

L'assenza di una sessione autenticata
determina l'accesso alla pagina di login.

La presenza di una sessione autenticata
consente l'accesso al ProfileSessionGate.

Il widget autenticato utilizza
ValueKey associata all'identita utente.

## 4. LoginPage

Autenticazione mediante:

signInWithPassword.

Comportamenti rilevati:

- Controllo dei campi non vuoti.
- Stato di caricamento.
- Disabilitazione dell'invio durante il login.
- Gestione della visibilita della password.
- Autofill.
- Gestione della tastiera.
- Controlli mounted.
- Rilascio dei controller.

Gestione degli errori:

- Credenziali non valide.
- Email non confermata.
- Altri messaggi AuthException.
- Errore generico di connessione.

Alcuni messaggi AuthException vengono
mostrati senza traduzione specifica.

## 5. Limiti rilevati

Nella ricerca effettuata in RC01
non sono state individuate chiamate
applicative esplicite per:

- Registrazione.
- Logout.
- Recupero password.
- Modifica password.
- Aggiornamento esplicito della sessione.

La ricerca non esclude meccanismi
automatici gestiti dal client Supabase.

AuthGate non presenta una gestione
esplicita di snapshot.hasError
nel codice esaminato.

Il percorso di errore del ProfileSessionGate
consente il tentativo di ripetizione.

Non e' stata individuata in tale percorso
una specifica azione di logout.

## 6. Sicurezza

L'autenticazione non attribuisce
automaticamente autorita di scrittura.

Il contesto del profilo e la Write Authority
rimangono responsabilita separate.

Non introdurre autenticazioni parallele
nei singoli domini operativi.

Non conservare credenziali o token
nel Registro tecnico.

## 7. Riutilizzo

RIUTILIZZARE:

- Inizializzazione Supabase.
- AuthGate.
- LoginPage.
- Collegamento al ProfileSessionGate.

INTEGRARE:

- Percorsi di gestione dell'account
  previsti dal perimetro approvato.

VERIFICARE:

- Gestione degli errori di autenticazione.
- Rinnovo della sessione.
- Comportamento su Edge e Safari.
- Revoca dell'accesso.
- Collaudo integrato con Supabase.

## 8. Limiti dell'evidenza

Ricognizione del codice eseguita in S046.

Nessuna nuova prova integrata
di autenticazione eseguita in RC01.

Nessuna verifica remota attestata.

Le assenze rilevate si riferiscono
al perimetro della ricerca effettuata.

Nessuna modifica applicativa introdotta.
