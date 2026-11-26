# Orto Smart - Standard del Registro tecnico

## Metadati

- Identificativo: ARC-REG-001
- Versione: 1.0
- Sessione di introduzione: S046
- Data: 26/11/2026
- Stato: operativo
- Baseline sorgenti: 20649de7474765bd1c293b20bfcedab0a9493a14

## 1. Finalita

Il Registro tecnico costituisce la base di conoscenza permanente
per lo sviluppo di Orto Smart.

Deve ridurre la ricostruzione ripetitiva delle conoscenze,
favorire il riutilizzo delle infrastrutture esistenti,
conservare le evidenze e accelerare lo sviluppo futuro.

Il Registro sostituisce l'aggiornamento sistematico dei Manuali.
I Manuali precedenti rimangono conservati come patrimonio storico.

## 2. Responsabilita

ChatGPT gestisce la classificazione, la catalogazione,
l'organizzazione, la predisposizione al salvataggio,
l'aggiornamento e la verifica della conoscenza tecnica.

L'utente esegue le operazioni che richiedono accesso al PC
e mantiene il controllo delle decisioni progettuali,
delle autorizzazioni operative e delle pubblicazioni.

## 3. Fonte autoritativa

Il codice sorgente e le migrazioni rappresentano la fonte
autoritativa dell'implementazione.

Lo stato effettivo del database deve essere verificato
nell'ambiente pertinente.

Il Registro descrive le conoscenze acquisite e non sostituisce
il codice sorgente.

Le informazioni devono essere riferite a una baseline identificabile.

## 4. Classificazione

ARC  - Architettura e decisioni
INF  - Infrastrutture comuni
DB   - Componenti database
FLT  - Componenti Flutter
PRC  - Processi funzionali
TST  - Collaudi ed evidenze
NC   - Non conformita
OBS  - Osservazioni tecniche
PROC - Procedure riutilizzabili
V1   - Programmazione funzionale
RC   - Riconciliazione tecnica
S    - Sessioni di sviluppo

Gli identificativi gia assegnati devono essere conservati.

## 5. Struttura delle schede

Ogni scheda contiene, quando pertinente:

- Identificativo univoco
- Titolo
- Responsabilita
- Macroblocco proprietario
- Stato di implementazione
- Livello di evidenza
- Percorsi dei sorgenti
- Classi, metodi, funzioni e RPC
- Contratto funzionale
- Parametri e risultati
- Precondizioni e postcondizioni
- Dipendenze
- Integrazioni esistenti
- Protezioni di sicurezza
- Test ed evidenze
- Modalita di riutilizzo
- Limitazioni e criticita
- Attivita residue
- Commit di riferimento
- Ambiente verificato
- Sessione e data dell'ultima verifica
- Collegamenti alle altre schede

Non duplicare integralmente il codice sorgente.

## 6. Livelli di evidenza

E0 - Non implementato
E1 - Progettato
E2 - Implementato parzialmente
E3 - Implementato ma non completamente verificato
E4 - Tecnicamente verificato
E5 - Operativamente accettato
NV - Non verificato
NA - Non applicabile con motivazione

Il livello deve essere riferito alla specifica evidenza.
Un test unitario non equivale a un collaudo operativo.
Una verifica locale non equivale a una verifica remota.

## 7. Regole di riutilizzo

RIUTILIZZARE - Componente disponibile e pertinente.
INTEGRARE - Componente disponibile da collegare al dominio.
VERIFICARE - Informazione incompleta o non piu attuale.
SVILUPPARE - Funzionalita effettivamente mancante.

Prima di progettare una nuova infrastruttura,
consultare il Registro e verificare quelle gia disponibili.

Non ricostruire componenti esistenti senza motivazione.

## 8. Regole di aggiornamento

Registrare ogni conoscenza una sola volta nella scheda principale.

Utilizzare riferimenti tra schede anziche duplicare informazioni.

Aggiornare esclusivamente le schede interessate dalle modifiche.

Conservare le decisioni approvate e la loro provenienza.

Distinguere fatti verificati, ipotesi e proposte.

Non inventare informazioni mancanti.

Non conservare token, password o credenziali.

## 9. Apertura delle sessioni

Verificare il repository e il commit corrente.

Consultare l'indice del Registro.

Individuare le schede pertinenti alle attivita previste.

Verificare eventuali variazioni dei sorgenti interessati.

Riutilizzare le evidenze ancora valide.

Eseguire i controlli tecnici iniziali previsti.

## 10. Chiusura delle sessioni

Aggiornare le schede interessate.

Registrare test, decisioni, criticita e attivita residue.

Aggiornare lo stato operativo e i consuntivi.

Verificare la persistenza dei documenti.

Predisporre il checkpoint di passaggio chat.

Eseguire commit e push soltanto secondo le autorizzazioni previste.

## 11. Riconciliazione delle stime

Non sottrarre due volte attivita gia escluse dalle stime.

Distinguere infrastrutture realizzate da integrazioni mancanti.

Non ridurre automaticamente le ore residue in funzione
del tempo effettivamente lavorato.

Documentare le motivazioni delle variazioni quantitative.

## 12. Continuita della conoscenza

La memoria delle conversazioni non costituisce
l'unico archivio della conoscenza tecnica.

Il Registro deve essere persistente, versionato,
consultabile e utilizzabile nelle sessioni future.

Il checkpoint di passaggio deve indicare la posizione
del Registro e la baseline tecnica corrente.

## 13. Vincoli operativi

La gestione del Registro non autorizza automaticamente
modifiche funzionali, migrazioni, interventi sul database
remoto o pubblicazioni.

Le verifiche devono rispettare le autorizzazioni esistenti.

Le roadmap esplorative non costituiscono evidenze tecniche
e non determinano automaticamente lo sviluppo operativo.
