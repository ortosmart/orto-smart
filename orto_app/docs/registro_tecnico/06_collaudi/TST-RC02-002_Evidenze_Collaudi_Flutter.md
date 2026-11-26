# TST-RC02-002 - Evidenze collaudi Flutter

## 1. Identificazione

- Versione: 1.0.
- Sessione: S047.
- Data: 26/11/2026.
- Origine: RC02, controllo 06.
- Macroblocco principale: V1-02.
- Baseline Git: 39665b458221b69c469ebe1d16a686312af79320.
- Ambiente: Flutter locale.
- Risultato collaudi mirati: 116/116 PASS.
- Evidenza: E4 per i comportamenti effettivamente collaudati.
- Evidenza complessiva infrastruttura: E3.
- Collaudo integrato reale Flutter-PostgreSQL: NV.
- Ambiente remoto: NV.

## 2. Finalita e perimetro dei collaudi

Il documento conserva le evidenze
dei collaudi Flutter mirati eseguiti
durante la ricognizione RC02.06.

Finalita:

- Identificare i comportamenti gia collaudati.
- Preservare le evidenze riutilizzabili.
- Evitare la ripetizione non necessaria dei test.
- Distinguere le prove strutturali da quelle funzionali.
- Identificare i limiti delle prove simulate.
- Conservare le verifiche residue.
- Collegare le evidenze condivise tra riconciliazioni.

Il documento integra TST-RC02-001,
dedicato alle evidenze strutturali SQL.

Non costituisce certificazione completa
del protocollo Write Authority.

## 3. Ambiente e baseline

### 3.1. Baseline Git

Commit di riferimento:

39665b458221b69c469ebe1d16a686312af79320.

Branch: main.

All'apertura della sessione S047
la baseline Git risultava allineata
con origin/main.

### 3.2. Verifiche generali di apertura

| Verifica | Risultato |
|---|---|
| flutter analyze | PASS |
| flutter test | 1956/1956 PASS |
| Working tree iniziale | Pulita |

Le verifiche generali costituiscono
la baseline tecnica di apertura S047.

### 3.3. Ambiente database

Le verifiche di apertura hanno rilevato:

- Migrazioni locali: 48/48.
- Migrazioni remote: 34/48.
- Migrazioni non applicate al remoto: 14.

I collaudi Flutter documentati
non hanno comportato applicazione
di migrazioni al database remoto.

La presenza delle migrazioni locali
non costituisce prova del comportamento
integrato Flutter-PostgreSQL.

## 4. Metodologia e livelli di evidenza

### 4.1. Metodologia

Per ciascuna suite sono stati esaminati:

- Responsabilita del componente.
- Contratti applicativi.
- Comportamenti verificati dai test.
- Dipendenze simulate.
- Risultato dell'esecuzione.
- Limiti della copertura.
- Verifiche residue.

Non sono stati introdotti nuovi test
durante la ricognizione RC02.06.

Sono state rieseguite suite esistenti.

### 4.2. Livelli di evidenza

| Livello | Interpretazione nel presente documento |
|---|---|
| E3 | Componente implementato, non integralmente verificato |
| E4 | Comportamento specifico tecnicamente verificato |
| NV | Comportamento non verificato |
| NA | Controllo non applicabile |

Il livello E4 e circoscritto
alle condizioni effettivamente esercitate.

Non deve essere attribuito automaticamente
all'intero componente.

### 4.3. Dipendenze simulate

Le suite utilizzano, secondo il componente:

- Invocatori RPC simulati.
- Risposte RPC predisposte.
- Scheduler controllabili.
- Riferimenti temporali iniettati.
- Controller e contesti di test.
- Widget test Flutter.
- Persistenza del journal simulata.

Queste tecniche consentono di verificare
comportamenti applicativi deterministici.

Non dimostrano autonomamente:

- Effettiva esecuzione delle RPC PostgreSQL.
- Applicazione reale delle policy RLS.
- Concorrenza tra sessioni database.
- Comportamento della rete reale.
- Comportamento dei browser durante sospensione.
- Funzionamento dell'ambiente remoto.

## 5. Repository Edit Lock

### 5.1. Risultato

- Controllo: RC02.06.2.
- Componente: ProfileEditLockRepository.
- Test eseguiti: 17.
- Test superati: 17.
- Test falliti: 0.
- Durata riportata: 00:13.
- Esito: PASS.

### 5.2. Acquire

Otto test complessivi.

Comportamenti verificati:

- Invocazione della RPC prevista.
- Trasmissione dei parametri identificativi.
- Interpretazione del risultato acquired.
- Conservazione dell'identita applicativa.
- Acquisizione del token.
- Interpretazione della scadenza UTC.
- Interpretazione della row version.
- Rappresentazione testuale senza esposizione del token.
- Decodifica degli esiti negativi.
- Rifiuto del token mancante.
- Rifiuto dello stato sconosciuto.
- Rifiuto della risposta non rappresentabile come mappa.

Gli esiti negativi comprendono:

- already_held.
- busy.
- forbidden.
- invalid_input.

### 5.3. Heartbeat

Quattro test complessivi.

Comportamenti verificati:

- Invocazione della RPC prevista.
- Trasmissione dell'identita e del token.
- Interpretazione del risultato renewed.
- Conservazione dell'identita e del token.
- Aggiornamento della scadenza.
- Aggiornamento della row version.
- Interpretazione di not_holder.
- Interpretazione di forbidden.
- Rifiuto della risposta non conforme nel caso collaudato.

Il caso non conforme comprende
contemporaneamente una scadenza non valida
e una row version pari a zero.

Non dimostra isolatamente
il rifiuto della sola row version.

### 5.4. Release

Cinque test complessivi.

Comportamenti verificati:

- Invocazione della RPC prevista.
- Trasmissione dei parametri del lease.
- Interpretazione di released.
- Interpretazione di not_holder.
- Interpretazione di transfer_pending.
- Interpretazione di forbidden.
- Rifiuto dello stato sconosciuto.

### 5.5. Copertura dei contratti

| Operazione | Stati decodificati | Stati previsti |
|---|---:|---:|
| Acquire | 5 | 5 |
| Heartbeat | 3 | 3 |
| Release | 4 | 4 |
| Totale | 12 | 12 |

La copertura riguarda la decodifica
delle tre RPC ordinarie.

Non equivale alla gestione completa
del lifecycle applicativo.

### 5.6. Verifiche residue

- Validazione isolata della row version.
- Ulteriori anomalie di decodifica.
- Validazione formale delle identita.
- Formato del token.
- Coerenza temporale delle risposte.
- Errori di trasporto.
- Risposte perse o tardive.
- Collaudo delle RPC reali.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 6. Controller Write Authority

### 6.1. Risultato

- Controllo: RC02.06.3.
- Componente: ProfileWriteAuthorityController.
- Test eseguiti: 33.
- Test superati: 33.
- Test falliti: 0.
- Durata riportata: 00:13.
- Esito: PASS.

### 6.2. Inizializzazione e ruoli

Comportamenti verificati:

- Membro non autorizzato in sola lettura.
- Acquisizione del lease per owner.
- Stato writer dopo acquisizione valida.
- Gestione degli esiti negativi Acquire.
- Recupero dopo errore di acquisizione.

### 6.3. Disponibilita del lease

Comportamenti verificati:

- Disponibilita del lease corrente.
- Compatibilita del lease rinnovato.
- Rifiuto di token differenti.
- Rifiuto di identita client differenti.
- Rifiuto di identita sessione differenti.
- Rifiuto di profili differenti.
- Indisponibilita alla scadenza esatta.
- Verifica temporale senza effetti collaterali.
- Indisponibilita durante recupero.
- Indisponibilita dopo rilascio.
- Indisponibilita dopo dispose.
- Indisponibilita per membro in sola lettura.

### 6.4. Collegamento con BedRepository

Sono presenti prove di integrazione
applicativa simulata con BedRepository.

Comportamenti verificati:

- Richiesta del lease per le operazioni protette.
- Rifiuto della scrittura dopo scadenza.
- Utilizzo del nuovo token da parte
  del medesimo repository dopo nuova acquisizione.

Queste prove non costituiscono
collaudo reale delle RPC di dominio.

L'analisi completa dei percorsi
autoritativi appartiene alla RC02.07.

### 6.5. Heartbeat

Comportamenti verificati:

- Rinnovo ordinario.
- Aggiornamento del lease.
- Sospensione della scrittura dopo errore.
- Ripristino dopo recupero valido.
- Gestione dell'errore pendente oltre scadenza.
- Perdita dell'autorita dopo not_holder.
- Revoca dopo forbidden.
- Gestione della risposta non conforme.
- Recupero dopo scadenza.
- Pianificazione di nuovi tentativi.

### 6.6. Verifica immediata

E stato collaudato il risultato finale
del metodo verifyNow.

Rimane da collaudare specificamente
la disponibilita di scrittura
mentre la verifica e ancora pendente.

### 6.7. Release e dismissione

Comportamenti verificati:

- Rilascio dell'autorita locale.
- Invocazione del repository.
- Gestione dell'errore durante rilascio.
- Annullamento delle attivita pianificate.
- Protezione rispetto ad acquisizioni obsolete.
- Tentativo di rilascio di un lease
  acquisito da una generazione non piu corrente.

La revoca sincrona prima della risposta
del repository dispone di ulteriore
evidenza nella suite RouteWriteAvailability.

### 6.8. Verifiche residue

- Perdita della risposta Acquire.
- Heartbeat positivo di generazione obsoleta.
- Interferenza tra generazioni concorrenti.
- Risposta positiva tardiva dopo scadenza.
- Risposta positiva tardiva dopo riacquisizione.
- Gestione specifica di transfer_pending.
- Sospensione locale durante handoff.
- Rilascio effettivo alla chiusura.
- Verifica immediata ancora pendente.
- Rilascio del lease precedente
  durante reinizializzazione.

Classificazione: RIUTILIZZARE / VERIFICARE / INTEGRARE.

## 7. Scheduler

### 7.1. Risultato

- Controllo: RC02.06.4.
- Componente: TimerWriteAuthorityScheduler.
- Test eseguiti: 2.
- Test superati: 2.
- Test falliti: 0.
- Durata riportata: 00:11.
- Esito: PASS.

### 7.2. Comportamenti verificati

Primo test:

- Pianificazione di una callback.
- Esecuzione della callback.
- Completamento del segnale asincrono previsto.

Secondo test:

- Pianificazione di una callback ritardata.
- Annullamento prima dell'esecuzione.
- Assenza dell'esecuzione durante
  la finestra temporale osservata.

### 7.3. Limiti

Il primo test non verifica isolatamente
il numero complessivo delle invocazioni.

L'annullamento non dimostra
l'interruzione di una operazione
asincrona gia iniziata.

Rimangono da approfondire:

- Eccezioni asincrone.
- Callback tardive.
- Sospensione dell'applicazione.
- Sospensione del browser.
- Interazioni con operazioni concorrenti.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 8. Scope

### 8.1. Risultato

- Controllo: RC02.06.5.
- Componente: ProfileWriteAuthorityScope.
- Test eseguiti: 2.
- Test superati: 2.
- Test falliti: 0.
- Durata riportata: 00:07.
- Esito: PASS.

### 8.2. Comportamenti verificati

- Accesso al controller mediante Scope.
- Disponibilita della medesima istanza.
- Accesso obbligatorio reattivo.
- Accesso obbligatorio non reattivo.
- Errore in assenza dello Scope obbligatorio.

### 8.3. Verifiche residue

- Accesso opzionale in assenza dello Scope.
- Propagazione delle notifiche.
- Ricostruzione dei widget dipendenti.
- Comportamento non reattivo.
- Collegamento al servizio delle mutazioni stagionali.

La disponibilita dei metodi nel sorgente
non equivale alla verifica completa
delle loro conseguenze applicative.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 9. RouteWriteAvailability

### 9.1. Risultato

- Controllo: RC02.06.6.
- Componente: RouteWriteAvailability.
- Test eseguiti: 35.
- Test superati: 35.
- Test falliti: 0.
- Durata riportata: 00:06.
- Esito: PASS.

### 9.2. Disponibilita iniziale

Comportamenti verificati:

- Assenza di autorita.
- Assenza del lease originario.
- Indisponibilita iniziale della scrittura.
- Assenza di attivazione tardiva.
- Disponibilita con lease valido.
- Pianificazione della scadenza.
- Assenza di RPC aggiuntive per la sola route.

### 9.3. Contesto applicativo

Comportamenti verificati:

- Indisponibilita con contesto non valido.
- Rivalutazione del contesto.
- Ripristino del contesto compatibile.
- Comportamento fail-closed in caso di eccezione.
- Mancata attivazione di una route
  inizialmente non autorizzata.

### 9.4. Scadenza temporale

Comportamenti verificati:

- Indisponibilita alla scadenza esatta.
- Disponibilita immediatamente prima della scadenza.
- Caso limite a un microsecondo dalla scadenza.
- Notifica della variazione di disponibilita.
- Assenza di timer per lease gia scaduto.
- Ripianificazione dopo callback anticipata.
- Protezione da callback obsolete.
- Rivalutazione dopo rinnovo.

### 9.5. Coerenza temporale

Sono stati collaudati:

- Utilizzo coerente del riferimento temporale.
- Singola valutazione temporale nei casi previsti.
- Coerenza tra apertura e pianificazione.
- Coerenza tra aggiornamento e pianificazione.
- Scadenza durante la validazione del contesto.

### 9.6. Rinnovo e recupero

Comportamenti verificati:

- Aggiornamento della scadenza dopo rinnovo.
- Conservazione della route con medesimo token.
- Ripristino dopo recupero compatibile.
- Indisponibilita dopo rilascio.
- Mancata riattivazione con nuovo token.
- Validita del lease originario
  rispetto alla nuova scadenza compatibile.

### 9.7. Revoca sincrona

E stato verificato che il rilascio
revoca la disponibilita locale
prima del completamento asincrono.

Il risultato costituisce evidenza E4
della revoca locale nel caso simulato.

Non costituisce prova del completamento
della RPC Release sul database.

### 9.8. Invalidazione permanente

Comportamenti verificati:

- Revoca immediata della disponibilita.
- Conservazione dello stato del controller.
- Assenza di nuove RPC.
- Annullamento del timer.
- Notifica sincrona della variazione.
- Idempotenza.
- Mancata riattivazione dopo heartbeat.
- Mancata riattivazione dopo refresh.
- Assenza di notifica non necessaria
  per route gia indisponibile.
- Comportamento dopo dispose.
- Protezione da callback obsolete.
- Utilizzabilita del notifier fino al dispose.

### 9.9. Dismissione

Sono stati collaudati:

- Annullamento delle attivita pianificate.
- Rimozione dei listener.
- Indisponibilita dopo dispose del controller.

Il caso di dispose del controller
comprende una rivalutazione esplicita.

Non dimostra autonomamente
la notifica spontanea di tutti
i widget interessati.

### 9.10. Verifiche residue

- Lifecycle effettivo delle route genitrici.
- Integrazione PlanningRouteLifetime.
- Notifiche UI dopo dispose del controller.
- Sospensione e ripresa del browser.
- Scadenze durante operazioni reali.
- Comportamento con RPC effettive.
- Integrazione con handoff e takeover.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 10. Widget pianificazioni stagionali

### 10.1. Risultato

- Controllo: RC02.06.6.
- Componente: percorso widget pianificazioni stagionali.
- Test eseguiti: 20.
- Test superati: 20.
- Test falliti: 0.
- Durata riportata: 00:21.
- Esito: PASS.

### 10.2. Creazione e aggiornamento

Sono stati collaudati tre scenari
generati relativi al salvataggio.

Comportamenti verificati:

- Creazione.
- Aggiornamento.
- Gestione del risultato negativo.
- Invocazione della RPC pertinente.
- Trasmissione dei parametri di dominio verificati.
- Gestione del risultato applicativo.

Questi scenari non verificano
esplicitamente tutti i parametri
identificativi del lock e il token.

### 10.3. Recupero mediante ricevuta

E stato collaudato uno scenario
di recupero di una mutazione predisposta.

Comportamenti verificati:

- Presenza dell'operazione nel journal.
- Lettura della ricevuta.
- Corrispondenza dell'identificativo operazione.
- Corrispondenza dell'identita.
- Corrispondenza del dominio.
- Corrispondenza del tipo di mutazione.
- Corrispondenza dello schema.
- Corrispondenza delle generazioni.
- Corrispondenza del fingerprint.
- Recupero dello stato confirmed.
- Recupero della versione prevista.
- Assenza di ripetizione della mutazione.
- Rimozione dell'operazione dal journal.

L'evidenza riguarda il caso simulato.

Il collaudo completo del protocollo
delle ricevute appartiene alla RC05.

### 10.4. Esecuzione

E stato collaudato uno scenario
relativo all'esecuzione della pianificazione.

Comportamenti verificati:

- Annullamento della selezione della data
  senza invocazione RPC.
- Selezione della data.
- Singola invocazione della RPC prevista.
- Trasmissione della versione attesa.
- Gestione del risultato executed.

### 10.5. Conferma e annullamento

Sono stati collaudati due scenari
generati per conferma e annullamento.

Comportamenti verificati:

- Indisponibilita in presenza di journal pendente.
- Indisponibilita senza autorita di scrittura.
- Disponibilita con autorita valida.
- Indisponibilita durante RPC pendente.
- Singola invocazione della RPC.
- Trasmissione dell'identificativo.
- Trasmissione della versione attesa.
- Aggiornamento dopo risultato positivo.

### 10.6. Disponibilita della scrittura

Tredici scenari riguardano
la disponibilita di scrittura
e il collegamento al notifier.

Comportamenti verificati:

- Sola lettura in assenza di disponibilita.
- Assenza di timer o RPC non necessari.
- Scrittura disponibile con autorita valida.
- Sola lettura con contesto non valido.
- Stati di caricamento, elenco vuoto ed errore.
- Disponibilita del nuovo tentativo.
- Revoca sincrona dopo rilascio.
- Indisponibilita alla scadenza esatta.
- Invalidazione permanente.
- Mancata riattivazione con nuovo token.
- Ripristino del contesto compatibile.
- Rimozione del listener dopo unmount.
- Trasferimento delle sottoscrizioni
  dopo sostituzione del notifier.

Il widget non assume automaticamente
la proprieta del notifier ricevuto.

### 10.7. Consuntivo interno

| Gruppo | Test |
|---|---:|
| Creazione e aggiornamento | 3 |
| Recupero mediante ricevuta | 1 |
| Esecuzione | 1 |
| Conferma e annullamento | 2 |
| Disponibilita e notifier | 13 |
| Totale | 20 |

### 10.8. Limiti e dipendenze

I test utilizzano RPC simulate,
scheduler controllabili e journal di test.

Non costituiscono prova di:

- Esecuzione reale PostgreSQL.
- Protezione RLS effettiva.
- Gestione reale della concorrenza.
- Persistenza reale delle ricevute.
- Lifecycle completo delle route genitrici.
- Comportamento su browser reale.

Le evidenze devono essere condivise
con RC02.07 e RC05 senza duplicazione
automatica delle attivita.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 11. ProfileSessionGate

### 11.1. Risultato

- Controllo: RC02.06.8.
- Componente: ProfileSessionGate.
- Test eseguiti: 7.
- Test superati: 7.
- Test falliti: 0.
- Durata riportata: 00:11.
- Esito: PASS.

Le sei dichiarazioni di test
comprendono un caso parametrizzato
per worker e viewer.

### 11.2. T01 - Inizializzazione ordinaria

Comportamenti verificati:

- Caricamento durante risoluzione del profilo.
- Disponibilita del contesto risolto.
- Propagazione del controller.
- Acquisizione dell'autorita.
- Disponibilita della scrittura.
- Una invocazione Acquire.
- Pianificazione del primo heartbeat.

### 11.3. T02 - Errore e nuovo tentativo

Comportamenti verificati:

- Errore durante risoluzione iniziale.
- Propagazione dell'errore al componente previsto.
- Assenza di RPC prima della risoluzione.
- Nuovo tentativo.
- Seconda risoluzione valida.
- Acquisizione successiva dell'autorita.

### 11.4. T03 - Rimozione del Gate

Comportamenti verificati:

- Acquisizione iniziale.
- Rimozione del Gate.
- Tentativo di rilascio.
- Sequenza Acquire e Release simulata.

Non viene dimostrato il rilascio
effettivo del record PostgreSQL.

### 11.5. T04 - Risoluzione tardiva

Comportamenti verificati:

- Rimozione del Gate durante risoluzione pendente.
- Completamento tardivo della risoluzione.
- Assenza di creazione dell'identita.
- Assenza di invocazioni RPC.
- Assenza di attivita pianificate.

### 11.6. T05 - Identita pendente

Comportamenti verificati:

- Assenza del contesto pubblicato
  durante acquisizione dell'identita.
- Assenza dello Scope.
- Assenza di acquisizione RPC.
- Completamento dell'identita.
- Pubblicazione del contesto previsto.
- Acquisizione dell'autorita.
- Tentativo di rilascio alla rimozione.

### 11.7. T06 e T07 - Worker e viewer

Comportamenti verificati per entrambi i ruoli:

- Disponibilita del contesto profilo.
- Conservazione del ruolo.
- Stato readOnlyMember.
- Indisponibilita della scrittura.
- Rifiuto della richiesta obbligatoria del lease.
- Assenza di Acquire.
- Assenza di heartbeat.
- Assenza di RPC dopo rimozione.

### 11.8. Limiti delle prove

L'invocatore simulato registra
i nomi delle RPC.

Non verifica integralmente
tutti i parametri trasmessi.

Lo scheduler di test registra
le pianificazioni senza eseguire
le relative operazioni temporali.

Il riferimento temporale e controllato.

### 11.9. Verifiche residue

- Rimozione durante creazione dell'identita.
- Rimozione durante Acquire pendente.
- Sessione owner con stato busy.
- Sessione owner con stato recovering.
- Logout effettivo.
- Rilascio prima della perdita dell'autenticazione.
- Completamento della RPC Release.
- Sospensione e ripresa dell'applicazione.

Le evidenze gia acquisite in RC01
devono essere riutilizzate.

Classificazione: RIUTILIZZARE / VERIFICARE.

## 12. Consuntivo complessivo

### 12.1. Risultati delle suite

| Suite | Test | Superati | Falliti | Esito |
|---|---:|---:|---:|---|
| Repository Edit Lock | 17 | 17 | 0 | PASS |
| Controller Write Authority | 33 | 33 | 0 | PASS |
| Scheduler | 2 | 2 | 0 | PASS |
| Scope | 2 | 2 | 0 | PASS |
| RouteWriteAvailability | 35 | 35 | 0 | PASS |
| Widget pianificazioni stagionali | 20 | 20 | 0 | PASS |
| ProfileSessionGate | 7 | 7 | 0 | PASS |
| Totale | 116 | 116 | 0 | PASS |

Risultato complessivo: 116/116 PASS.

Suite superate: 7/7.

Test falliti: 0.

### 12.2. Durate riportate

| Suite | Durata |
|---|---|
| Repository Edit Lock | 00:13 |
| Controller Write Authority | 00:13 |
| Scheduler | 00:11 |
| Scope | 00:07 |
| RouteWriteAvailability | 00:06 |
| Widget pianificazioni stagionali | 00:21 |
| ProfileSessionGate | 00:11 |

Somma delle durate riportate: 82 secondi.

La somma non rappresenta
il tempo complessivo di sviluppo
o di analisi della sessione.

### 12.3. Rapporto con la baseline generale

Baseline di apertura:

1956/1956 PASS.

Collaudi mirati:

116/116 PASS.

I collaudi mirati possono essere
compresi nella baseline generale.

Non devono essere sommati
come test necessariamente distinti.

Non e stato eseguito un nuovo
collaudo generale dopo ogni suite.

## 13. Matrice di copertura

### 13.1. Contratti RPC

| RPC | Stati SQL | Stati decodificati |
|---|---:|---:|
| acquire_profile_edit_lock | 5 | 5 |
| heartbeat_profile_edit_lock | 3 | 3 |
| release_profile_edit_lock | 4 | 4 |
| get_profile_edit_lock_state | 10 | 0 |
| request_profile_edit_takeover | 6 | 0 |
| cancel_profile_edit_takeover | 4 | 0 |
| reject_profile_edit_takeover | 6 | 0 |
| grant_profile_edit_takeover | 5 | 0 |
| complete_profile_edit_takeover | 5 | 0 |
| Totale | 48 | 12 |

Indicatori:

- RPC SQL locali analizzate: 9/9.
- RPC integrate nel repository Flutter: 3/9.
- Stati ordinari decodificati: 12/12.
- Stati complessivi decodificati: 12/48.
- Stati non integrati: 36.

La copertura numerica dei contratti
non rappresenta la maturita complessiva
della Write Authority.

### 13.2. Comportamenti applicativi

| Ambito | Evidenza | Stato |
|---|---|---|
| Decodifica ordinaria RPC | E4 | Verificata nei casi simulati |
| Gestione lease | E4 | Verificata nei casi simulati |
| Sola lettura worker e viewer | E4 | Verificata nei casi simulati |
| Heartbeat ordinario | E4 | Verificato nei casi simulati |
| Recupero dopo errore | E4 | Verificato nei casi simulati |
| Revoca locale sincrona | E4 | Verificata nei casi simulati |
| Protezione temporale route | E4 | Verificata nei casi simulati |
| Invalidazione permanente route | E4 | Verificata nei casi simulati |
| Propagazione controller | E4 | Verificata nei casi simulati |
| Inizializzazione Gate | E4 | Verificata nei casi simulati |
| Recupero ricevuta stagionale | E4 | Verificato nel caso simulato |
| Lifecycle completo takeover | NV | Aperto |
| Logout reale | NV | Aperto |
| Rilascio PostgreSQL effettivo | NV | Aperto |
| Concorrenza reale | NV | Aperto |
| Integrazione Flutter-PostgreSQL | NV | Aperta |
| Funzionamento remoto | NV | Aperto |

## 14. Verifiche residue

### 14.1. Verifiche specifiche C01-C09

| ID | Verifica | Famiglia |
|---|---|---|
| C01 | Perdita risposta Acquire | WA-V04 |
| C02 | Heartbeat di generazione obsoleta | WA-V01 |
| C03 | Interferenza tra generazioni concorrenti | WA-V01 |
| C04 | Heartbeat positivo tardivo dopo scadenza | WA-V03 |
| C05 | Gestione Release transfer_pending | WA-V13 |
| C06 | Sospensione autorita durante handoff | WA-V06 |
| C07 | Rilascio effettivo durante chiusura e logout | WA-V15 |
| C08 | Validazione isolata row version | WA-V11 |
| C09 | Comportamento durante verifyNow pendente | WA-V13 |

C05 e C07 dispongono di evidenze
positive parziali relative
alla revoca locale e al tentativo
di rilascio.

Non sono integralmente chiuse.

### 14.2. Famiglie trasversali

| Famiglia | Stato |
|---|---|
| WA-V01 | Aperta |
| WA-V02 | Aperta |
| WA-V03 | Parzialmente verificata |
| WA-V04 | Aperta |
| WA-V05 | Aperta |
| WA-V06 | Integrazione Flutter residua |
| WA-V07 | Aperta |
| WA-V08 | Parzialmente verificata |
| WA-V09 | Integrazione Flutter residua |
| WA-V10 | Aperta |
| WA-V11 | Parzialmente verificata |
| WA-V12 | Aperta |
| WA-V13 | Parzialmente verificata |
| WA-V14 | Approfondimento RC02.07 |
| WA-V15 | Aperta |

Nessuna famiglia integralmente chiusa.

Le evidenze residue non costituiscono
automaticamente nuove non conformita
o nuovi pacchetti di sviluppo.

### 14.3. Collaudi integrati

Rimangono da verificare:

- Acquisizione reale concorrente.
- Rinnovo reale del lease.
- Rilascio reale.
- Mutazioni protette.
- RLS e helper autoritativi.
- Variazioni membership.
- Lifecycle completo takeover.
- Invalidazione del token precedente.
- Risposte perse.
- Scadenze e sospensione.
- Logout e chiusura della sessione.
- Comportamento remoto.

Il programma operativo dei collaudi
integrati sara definito
nei pertinenti controlli RC02.

## 15. Evidenze condivise RC01, RC02 e RC05

### 15.1. RC01

Evidenze condivise:

- Autenticazione.
- Identita applicativa.
- Contesto profilo.
- Inizializzazione della sessione.
- ProfileSessionGate.
- Separazione dei ruoli.

Le evidenze gia consolidate in RC01
devono essere richiamate
senza duplicazione automatica.

NC-RC01-001 rimane aperta e distinta.

### 15.2. RC02

Evidenze principali:

- Lease.
- Repository Edit Lock.
- Controller.
- Scheduler.
- Scope.
- Disponibilita delle route.
- Riconciliazione dei contratti SQL.
- Lifecycle ordinario.

La verifica dei percorsi di dominio
proseguira in RC02.07.

### 15.3. RC05

Evidenze condivise:

- Contratti delle mutazioni.
- Coordinamento delle operazioni.
- Journal.
- Ricevute.
- Recupero delle operazioni.
- Percorso delle pianificazioni stagionali.

Il collaudo simulato della ricevuta
costituisce evidenza riutilizzabile.

Non costituisce certificazione completa
dell'infrastruttura RC05.

### 15.4. Regole di riutilizzo

- Conservare il riferimento alla suite originaria.
- Distinguere il comportamento verificato.
- Evitare il doppio conteggio dei test.
- Evitare la duplicazione delle attivita.
- Ripetere i test quando necessario
  per modifiche, regressioni o nuove condizioni.
- Non attribuire riduzioni temporali automatiche.

## 16. Limiti e riferimenti

### 16.1. Limiti del consolidamento

Il documento conserva una sintesi
analitica delle evidenze acquisite.

Non costituisce trascrizione integrale
dei sorgenti delle suite o degli output.

I raggruppamenti descrivono
i comportamenti verificati.

Non attribuiscono necessariamente
un test distinto a ogni comportamento.

Le durate riportate sono quelle
visualizzate durante le esecuzioni.

La classificazione E4 riguarda
esclusivamente i comportamenti
effettivamente esercitati.

Il livello complessivo della Write Authority
rimane E3.

Il collaudo integrato reale rimane NV.

L'ambiente remoto rimane NV.

### 16.2. Riferimenti documentali

- [INF-WA-001](../02_infrastrutture/INF-WA-001_Inventario_Write_Authority.md).
- [INF-WA-002](../02_infrastrutture/INF-WA-002_Infrastruttura_Flutter_Write_Authority.md).
- [DB-WA-001](../03_database/DB-WA-001_Inventario_RPC_Write_Authority.md).
- [DB-WA-004](../03_database/DB-WA-004_Acquisizione_Rilascio_Lock.md).
- [DB-WA-005](../03_database/DB-WA-005_Heartbeat_Stato_Lock.md).
- [DB-WA-006](../03_database/DB-WA-006_Protocollo_Takeover.md).
- [DB-WA-007](../03_database/DB-WA-007_Lifecycle_Contratti_RPC.md).
- [TST-RC02-001](TST-RC02-001_Evidenze_Strutturali_SQL.md).
- [RC02-OBS-001](../08_riutilizzo/RC02-OBS-001_Osservazioni_Tecniche.md).
- [RC02_Stato_Parziale](../08_riutilizzo/RC02_Stato_Parziale.md).

### 16.3. Chiusura documentale

Collaudi mirati eseguiti: 116.

Collaudi mirati superati: 116.

Collaudi mirati falliti: 0.

Nuovi test introdotti: 0.

Nessuna modifica applicativa introdotta.

Nessuna modifica SQL introdotta.

Nessuna migrazione remota applicata.

Nessuna nuova non conformita
formalmente approvata.

Nessuna variazione quantitativa PERT.

Il consolidamento definitivo richiede
verifica documentale, indicizzazione
e versionamento Git.

## 17. Tracciabilita dei sorgenti e ripetibilita

Percorsi effettivi verificati mediante git ls-files.

Baseline: 39665b458221b69c469ebe1d16a686312af79320.

| Sorgente | Test superati | Durata rilevata |
|---|---:|---:|
| `test/data/repositories/profile_edit_lock_repository_test.dart` | 17/17 | 13 s |
| `test/core/write_authority/profile_write_authority_controller_test.dart` | 33/33 | 13 s |
| `test/core/write_authority/write_authority_scheduler_test.dart` | 2/2 | 11 s |
| `test/core/write_authority/profile_write_authority_scope_test.dart` | 2/2 | 7 s |
| `test/core/write_authority/route_write_availability_test.dart` | 35/35 | 6 s |
| `test/core/write_authority/seasonal_planning_mutation_receipt_test.dart` | 20/20 | 21 s |
| `test/core/profile/profile_session_gate_test.dart` | 7/7 | 11 s |
| Totale | 116/116 | 82 s |

### 17.1. Comandi di riproduzione

Eseguire dalla directory principale orto_app.

```powershell
flutter test test/data/repositories/profile_edit_lock_repository_test.dart
flutter test test/core/write_authority/profile_write_authority_controller_test.dart
flutter test test/core/write_authority/write_authority_scheduler_test.dart
flutter test test/core/write_authority/profile_write_authority_scope_test.dart
flutter test test/core/write_authority/route_write_availability_test.dart
flutter test test/core/write_authority/seasonal_planning_mutation_receipt_test.dart
flutter test test/core/profile/profile_session_gate_test.dart
```

Eseguire un comando alla volta.

### 17.2. Limiti delle evidenze

I risultati si riferiscono alle esecuzioni S047 gia acquisite.
Le durate sono quelle riportate dagli output originari.
Il totale di 82 secondi rappresenta la somma delle sette durate.
Non rappresenta il tempo complessivo della ricognizione.

I test utilizzano dipendenze simulate.
Nessun nuovo test introdotto.
Nessuna nuova esecuzione durante questo aggiornamento.
Collaudo integrato reale: NV.
Ambiente remoto: NV.
