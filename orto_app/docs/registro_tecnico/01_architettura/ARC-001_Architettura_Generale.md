# ARC-001 - Architettura generale

## Metadati

- Sessione di acquisizione: S046
- Data: 26/11/2026
- Provenienza: STEP 273-274 e decisioni precedenti
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Natura: sintesi delle decisioni architetturali acquisite

## 1. Architettura applicativa

Orto Smart utilizza Flutter per l'applicazione
e Supabase con PostgreSQL per il backend.

L'applicazione Flutter gestisce:

- Presentazione.
- Navigazione.
- Modelli tipizzati.
- Repository.
- Servizi applicativi.
- Controller.
- Stato dell'interfaccia.
- Gestione degli errori.
- Integrazione della Write Authority.

Il backend gestisce:

- Autenticazione.
- Persistenza.
- Autorizzazioni.
- Integrita referenziale.
- Vincoli di dominio.
- Mutazioni autoritative.
- Concorrenza.
- Versionamento.
- Ricevute e riconciliazione delle mutazioni.

Il server rappresenta l'autorita finale delle scritture.

## 2. Separazione delle responsabilita

Non trasferire nelle pagine Flutter
responsabilita autoritative del database.

Non duplicare nei singoli domini
infrastrutture comuni gia disponibili.

I componenti condivisi devono avere
un proprietario funzionale identificabile.

Le integrazioni specifiche rimangono
responsabilita dei rispettivi domini.

Non introdurre astrazioni universali
senza una necessita tecnica dimostrata.

## 3. Modello di accesso

V1 orientata alla gestione monoutente del profilo.

Distinguere:

- Utente autenticato.
- Profilo.
- Appartenenza al profilo.
- Ruolo.
- Operatore del lavoro.
- Istanza del client.
- Sessione applicativa.
- Autorita di scrittura.

Gli operatori non devono essere automaticamente
considerati utenti autenticati.

La gestione multiutente condivisa avanzata
non appartiene automaticamente al perimetro V1.

## 4. Navigazione principale

- Dashboard.
- Orto.
- Irrigazione.
- Attivita.
- Impostazioni.

La navigazione deve riutilizzare i processi
funzionali dei domini proprietari.

La Dashboard non deve implementare
percorsi di mutazione paralleli.

## 5. Separazione della conoscenza agronomica

V1-08:
Catalogo, identita canoniche e conoscenza approvata.

V1-09:
Interpretazione della conoscenza e motori agronomici.

V1-10:
Pianificazione stagionale.

V1-11:
Coltivazioni effettive.

Non duplicare le regole agronomiche
nei singoli processi o nelle pagine.

## 6. Separazione delle autorita

Profile Write Authority:
gestione operativa del profilo.

Catalog Authority:
gestione della conoscenza agronomica globale.

Non utilizzare automaticamente una delle due
autorita come sostituto dell'altra.

## 7. Riferimenti

- ARC-002: sicurezza e integrita.
- ARC-003: gestione dei dati.
- ARC-004: perimetro e rilasci.
- INF-CAT-001: Catalogo Agronomico.
- INF-AGR-001: motori agronomici.
- RC01-RC18: riconciliazioni tecniche.

## 8. Limiti

Questa scheda conserva le decisioni generali.

Le implementazioni effettive e i relativi
livelli di evidenza sono registrati
nelle schede tecniche specifiche.

Non confondere architettura approvata
con funzionalita gia completata.
