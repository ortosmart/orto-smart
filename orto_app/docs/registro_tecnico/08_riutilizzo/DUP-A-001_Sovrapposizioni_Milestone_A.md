# DUP-A-001 - Sovrapposizioni Milestone A

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: STEP 275.6.2.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Aree approvate: 9/9.
- Aree riconciliate quantitativamente: 0/9.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

## 2. Principio generale

Ogni infrastruttura comune deve avere
un riferimento tecnico autorevole.

Lo sviluppo comune deve essere conteggiato
una sola volta.

Le integrazioni specifiche dei domini
rimangono distinte.

La presenza di una sovrapposizione
non dimostra automaticamente che le ore
siano state conteggiate due volte.

La riduzione quantitativa richiede
la riconciliazione delle stime originarie.

## 3. DUP-A01 - Identita e sicurezza

Macroblocchi principali:

- V1-01: identita, autenticazione e profilo.
- V1-02: sicurezza e autorita di scrittura.

Infrastrutture comuni:

- Identita client e sessione.
- Contesto del profilo.
- Ruoli e autorizzazioni.
- Write Authority.
- Edit lock.
- Helper di sicurezza.
- Controllo delle versioni.
- Journal delle operazioni.
- Ricevute e riconciliazione.

Responsabilita:

V1-01 gestisce identita e contesto.

V1-02 gestisce le infrastrutture comuni
di autorizzazione e integrita delle mutazioni.

I singoli domini mantengono:

- RPC specifiche.
- Policy e vincoli specifici.
- Validazioni di dominio.
- Integrazione Flutter.
- Collaudi specifici.

V1-04 verifica la sicurezza dell'ambiente remoto.

V1-18 verifica l'accettazione integrata.

Riconciliazioni principali:

RC01, RC02, RC03, RC04, RC05.

Stato quantitativo: aperto.

## 4. DUP-A02 - Backup e recupero

Macroblocco proprietario: V1-03.

Macroblocchi utilizzatori:

- V1-04.
- V1-17.
- V1-18.

Infrastrutture comuni:

- Produzione dei backup.
- Verifica dell'integrita.
- Conservazione delle evidenze.
- Ripristino in ambiente isolato.
- Procedure di recupero.

V1-04 utilizza queste infrastrutture
prima e dopo le migrazioni.

V1-17 gestisce la compatibilita fra
build e schema database.

Il rollback della build non equivale
al ripristino del database.

V1-18 verifica il recupero integrato
dei dati e dei processi operativi.

Riconciliazioni principali:

RC06, RC07, RC17.

Stato quantitativo: aperto.

## 5. DUP-A03 - Geometrie e occupazione

Macroblocco proprietario: V1-06.

Macroblocchi utilizzatori:

- V1-09.
- V1-10.
- V1-11.
- V1-15.
- V1-18.

Infrastrutture comuni:

- Identita delle aiuole.
- Geometrie storicizzate.
- Geometria valida alla data considerata.
- Calcolo delle superfici.
- Rappresentazione grafica delle aiuole.

V1-09 interpreta i vincoli spaziali
e temporali.

V1-10 gestisce l'occupazione pianificata.

V1-11 gestisce l'occupazione effettiva.

V1-15 aggrega le informazioni senza
duplicare la logica di calcolo.

V1-18 verifica il percorso integrato.

Non sommare occupazioni successive
come se fossero contemporanee.

Non duplicare l'occupazione derivante
da pianificazione e coltivazione collegata.

Riconciliazioni principali:

RC08, RC13, RC14, RC15, RC17.

Stato quantitativo: aperto.

## 6. DUP-A04 - Conoscenza agronomica

Macroblocco proprietario: V1-08.

Macroblocchi utilizzatori:

- V1-09.
- V1-10.
- V1-11.
- V1-18.

Infrastrutture comuni:

- Identita agronomiche canoniche.
- Tassonomia botanica.
- Registri agronomici.
- Fonti e revisioni.
- Resolver della conoscenza.
- Repository della conoscenza agronomica.

Riferimenti tecnici:

- RPC resolve_agronomic_knowledge.
- AgronomicKnowledgeRepository.
- Esiti tipizzati del Resolver.

V1-08 gestisce la conoscenza approvata.

V1-09 interpreta tale conoscenza
mediante i motori agronomici.

V1-10 e V1-11 integrano i risultati
nei rispettivi processi operativi.

V1-18 verifica il funzionamento integrato.

Non creare cataloghi paralleli
per i singoli motori.

Non trasformare conoscenze mancanti
in valori neutri arbitrari.

Riconciliazioni principali:

RC10, RC11, RC12, RC13, RC14, RC15.

Stato quantitativo: aperto.

## 7. DUP-A05 - Stagioni e temporalita

Macroblocco proprietario: V1-07.

Macroblocchi utilizzatori:

- V1-08.
- V1-09.
- V1-10.
- V1-11.
- V1-15.
- V1-18.

Infrastrutture comuni:

- Identita delle stagioni.
- Periodi stagionali.
- Stagione attiva.
- Stagione consultata.
- Contesto temporale condiviso.

V1-08 conserva le conoscenze
relative alle finestre agronomiche.

V1-09 interpreta finestre,
successioni e vincoli temporali.

V1-10 gestisce il calendario
delle pianificazioni.

V1-11 gestisce le coltivazioni
effettive anche attraverso stagioni diverse.

V1-15 aggrega le informazioni
nel contesto temporale pertinente.

Vincoli:

- Nessuna attivazione implicita.
- Nessuna chiusura automatica impropria.
- Nessuna creazione automatica non autorizzata.
- Nessuna data arbitrariamente presunta.
- Nessun doppio conteggio.

Riconciliazioni principali:

RC09, RC12, RC13, RC14, RC15.

Stato quantitativo: aperto.

## 8. DUP-A06 - Registri e configurazioni

Macroblocchi proprietari:

- V1-01: configurazione del profilo.
- V1-08: registri canonici agronomici.
- V1-16: impostazioni e amministrazione.

Principi:

Separare i dati canonici globali
dalle configurazioni del profilo.

Separare i registri agronomici
dalle configurazioni tecniche e operative.

Le impostazioni non devono duplicare
la persistenza dei domini.

Le interfacce amministrative devono
utilizzare i percorsi autoritativi.

Non introdurre una tabella universale
per configurazioni semanticamente diverse.

Riconciliazioni principali:

RC01, RC10, RC11, RC16.

Stato quantitativo: aperto.

## 9. DUP-A07 - Dispositivi e distribuzione

Macroblocchi principali:

- V1-17: distribuzione e dispositivi.
- V1-18: accettazione operativa.

I singoli domini conservano
i propri collaudi funzionali.

V1-02 conserva i collaudi
delle infrastrutture di sicurezza.

V1-17 gestisce le verifiche comuni:

- Edge.
- Safari.
- Responsivita.
- Interazioni touch.
- Distribuzione HTTPS.
- Accesso dalla schermata Home.
- Compatibilita build e database.

V1-18 verifica i percorsi reali
sui dispositivi previsti per la milestone.

Le evidenze devono identificare
ambiente, dispositivo e versione.

Non ripetere indiscriminatamente
tutti i collaudi su ogni componente.

Riconciliazioni principali:

RC16, RC17.

Stato quantitativo: aperto.

## 10. DUP-A08 - Collaudi

Livelli distinti:

1. Test unitari.
2. Test dei componenti e widget.
3. Collaudi SQL, RPC e RLS.
4. Collaudi verticali di dominio.
5. Collaudi trasversali fra domini.
6. Collaudi sui dispositivi.
7. Accettazione operativa.

Riutilizzare le evidenze ancora valide.

Integrare le evidenze incomplete.

Ripetere i controlli quando necessario
per modifiche o dipendenze interessate.

Verificare separatamente ambienti diversi.

NV non equivale a PASS.

P0 e P1 impediscono il rilascio pertinente.

P2 richiede valutazione esplicita
senza derogare ai requisiti obbligatori.

P3 deve essere registrato.

Per ogni evidenza conservare:

- Identificativo dello scenario.
- Macroblocco.
- Commit e build.
- Ambiente.
- Dispositivo e versione.
- Prerequisiti.
- Risultato atteso.
- Risultato effettivo.
- Esito.
- Riferimento all'evidenza.
- Data e ora.
- Motivazione della ripetizione.

Riconciliazione principale: RC17.

Stato quantitativo: aperto.

## 11. DUP-A09 - Conoscenza e documentazione

Principio originario:

Una sola fonte autorevole per ogni
informazione tecnica, con riferimenti
destinati ai diversi utilizzatori.

Evitare duplicazioni documentali
e ricostruzioni ripetute.

Aggiornamento metodologico S046:

Il Registro tecnico permanente
diventa lo strumento principale
di conservazione della conoscenza
necessaria allo sviluppo.

I manuali storici rimangono conservati.

La revisione sistematica di tutti
i manuali non costituisce piu
un'attivita ordinaria obbligatoria
alla chiusura di ogni sessione.

Conservare la separazione fra:

- Evidenze tecniche.
- Decisioni approvate.
- Stato operativo.
- Stime e ipotesi.
- Documentazione per l'utilizzatore.

Le ore gia lavorate rimangono invariate.

Il cambiamento metodologico non autorizza
riduzioni automatiche delle stime residue.

Riconciliazione principale: RC18.

Stato quantitativo: aperto.

## 12. Regole di riconciliazione

Per ciascuna area registrare:

- Identificativo DUP.
- Infrastruttura comune.
- Macroblocco proprietario.
- Macroblocchi utilizzatori.
- Riferimenti alle stime originarie.
- Evidenze tecniche disponibili.
- Lavoro gia escluso dalle stime.
- Eventuale lavoro duplicato.
- Integrazioni specifiche da mantenere.
- Ore eventualmente eliminabili.
- Ore eventualmente da aggiungere.
- Motivazione.
- Approvazione.

Casi da distinguere:

- Infrastruttura realizzata e gia esclusa.
- Infrastruttura realizzata ma ancora stimata.
- Infrastruttura parzialmente realizzata.
- Infrastruttura disponibile ma non integrata.
- Infrastruttura non verificata.

Non sottrarre due volte la stessa attivita.

Non confondere riutilizzo tecnico
e riduzione quantitativa dimostrata.

## 13. Stato complessivo

- Aree esaminate: 9/9.
- Aree approvate qualitativamente: 9/9.
- Aree riconciliate quantitativamente: 0/9.
- Riduzioni autorizzate: 0 minuti.
- Incrementi autorizzati: 0 minuti.

Baseline A invariata: 678:33.

Configurazione reale A separata: 43:20.

Baseline V1 invariata: 2734:18.

## 14. Collegamenti

- ARC-REG-001.
- V1-REG-001.
- V1-MET-001.
- V1-EST-001.
- V1-EST-002.
- V1-ACC-001.
- Schede delle riconciliazioni RC.

## 15. Limiti del consolidamento

Documento ricostruito dalle conoscenze
recuperate durante la sessione S046.

Non costituisce trascrizione integrale
delle conversazioni originarie.

I riferimenti RC sono organizzativi
e non attestano collaudi conclusi.

La riconciliazione delle stime PERT
originarie rimane da completare.

Nessuna variazione quantitativa introdotta.
