# INF-ID-001 - Identita client e sessione

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01.
- Macroblocco: V1-01.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Evidenza: E4 limitata ai test unitari.
- Riferimenti: RC01, RC02, RC05.

## 2. Componenti

- ClientInstanceIdStore.
- AppIdentityService.
- AppSessionIdentity.
- SharedPreferencesAsync.
- Astrazione della persistenza.
- Generazione UUID iniettabile.

Percorso funzionale:

lib/core/identity.

Collaudo:

test/core/identity/app_identity_service_test.dart.

## 3. Identita persistente del client

ClientInstanceIdStore espone getOrCreate.

Comportamento rilevato:

1. Lettura dell'identita persistente.
2. Verifica del valore disponibile.
3. Riutilizzo di un UUID valido non nil.
4. Generazione di un nuovo UUIDv4
   quando il valore non e' valido.
5. Validazione del valore generato.
6. Attesa del salvataggio persistente.
7. Restituzione dell'identita.

Chiave SharedPreferences:

orto_smart.client_instance_id.v1

La persistenza e' astratta
per consentire test indipendenti.

## 4. Identita della sessione

AppIdentityService utilizza
ClientInstanceIdStore.getOrCreate.

Genera una nuova identita di sessione.

Controlli rilevati:

- UUID valido.
- UUID non nil.
- Identita sessione diversa
  dall'identita persistente del client.

AppSessionIdentity rappresenta
la coppia immutabile delle identita.

L'identita del client deve rimanere
distinta dall'identita della sessione.

## 5. Dipendenze

L'identita viene acquisita
dal ProfileSessionGate.

Viene utilizzata nell'inizializzazione
del controller Write Authority.

Rappresenta un prerequisito
per la gestione degli edit lock.

La compatibilita con journal
e riconciliazione deve essere
verificata nella RC05.

## 6. Evidenze di collaudo

Cinque test unitari individuati:

- Creazione e persistenza iniziale.
- Riutilizzo dell'identita valida.
- Sostituzione dell'identita corrotta.
- Sostituzione dell'UUID nil.
- Identita client stabile e sessioni diverse.

Baseline generale S046:

1956 test superati su 1956.

I test utilizzano dipendenze simulate.

Non dimostrano da soli
la persistenza reale del browser.

## 7. Osservazioni aperte

Non e' stata individuata
una sincronizzazione esplicita
per chiamate concorrenti a getOrCreate.

Da verificare:

- Inizializzazioni concorrenti.
- Comportamento fra schede del browser.
- Persistenza su Edge.
- Persistenza su Safari.
- Indisponibilita dello Storage locale.
- Validazione lato server.
- Isolamento del journal.

Il costruttore diretto
di AppSessionIdentity non presenta
le medesime validazioni del servizio
nel codice esaminato.

Queste osservazioni non costituiscono
automaticamente difetti funzionali provati.

## 8. Riutilizzo

RIUTILIZZARE:

- ClientInstanceIdStore.
- AppIdentityService.
- AppSessionIdentity.
- Astrazione della persistenza.
- Test unitari disponibili.

VERIFICARE:

- Concorrenza.
- Persistenza reale.
- Comportamento multidispositivo.
- Integrazione con Write Authority.
- Integrazione con journal.

Non generare identita client separate
nei singoli repository di dominio.

Non utilizzare l'identita persistente
come sostituto dell'autenticazione.

Nessuna modifica applicativa introdotta.
