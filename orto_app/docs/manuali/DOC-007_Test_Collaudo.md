# ORTO SMART

### DOC-007

# Test e Collaudo

**Versione:** 1.0 (proposta per la prima emissione)
**Stato:** In sviluppo

**Autore:** Renzo Siega
**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026
**Ultimo aggiornamento:** 16/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|-------|--------|
| Documento | DOC-007 |
| Titolo | Test e Collaudo |
| Versione | 1.0 (proposta) |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 16/10/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|----------|------|-------------|
| 1.0 (proposta) | 16/10/2026 | Avvio della redazione del documento Test e Collaudo; definizione della struttura iniziale |
| 1.0 (proposta) | 16/10/2026 | Revisione preliminare: normalizzazione dei paragrafi, uniformazione dei riferimenti DOC-001 e DOC-004 e aggiornamento dei metadati; nessuna emissione ufficiale |

---

# Indice

1. Scopo del documento
2. Campo di applicazione
3. Tipologie e classificazione dei test
4. Ambienti e strumenti di collaudo
5. Preparazione ed esecuzione dei test
6. Test automatici Dart e Flutter
7. Test database PostgreSQL e Supabase
8. Test funzionali e di integrazione
9. Test di sicurezza e autorizzazione
10. Criteri di accettazione
11. Gestione delle anomalie e regressioni
12. Registrazione dei risultati e delle evidenze
13. Collaudo complessivo dell'applicazione
14. Manutenzione e aggiornamento del documento
15. Considerazioni finali

# 1. Scopo del documento

Il presente documento definisce le procedure di test, verifica e collaudo del progetto **Orto Smart**, sviluppato mediante Flutter, Dart e Supabase con database PostgreSQL.

Lo scopo del documento è stabilire criteri e modalità uniformi per verificare il corretto funzionamento delle componenti software, l'affidabilità delle operazioni e il rispetto dei requisiti funzionali, tecnici e di sicurezza del progetto.

In particolare, il DOC-007 ha i seguenti obiettivi:

- definire le tipologie di test applicabili alle diverse componenti
  dell'applicazione;
- descrivere le modalità di preparazione, esecuzione e verifica dei test;
- stabilire criteri oggettivi per valutare gli esiti delle verifiche;
- documentare i controlli relativi al codice Flutter e Dart;
- documentare i controlli relativi al database PostgreSQL e Supabase;
- definire le verifiche funzionali, di integrazione e di sicurezza;
- garantire la tracciabilità dei risultati e delle relative evidenze;
- disciplinare la registrazione delle anomalie e la ripetizione dei test;
- supportare il collaudo complessivo delle funzionalità effettivamente
  implementate.

Il documento distingue le procedure di verifica previste dai test effettivamente eseguiti.

Un test può essere dichiarato superato esclusivamente quando la sua esecuzione e il relativo esito positivo risultano verificabili.

I test non eseguiti, non applicabili o non superati devono essere identificati esplicitamente, senza essere considerati verifiche completate con successo.

Il DOC-007 costituisce il riferimento specifico per le procedure di test e collaudo di Orto Smart.

Il metodo generale di sviluppo e la sequenza delle attività delle sessioni rimangono disciplinati rispettivamente dai seguenti documenti:

- **DOC-006 — Linee Guida di Sviluppo**;
- **DOC-009 — Workflow Operativo**.

Le regole di redazione e versionamento documentale rimangono disciplinate dal **DOC-000 — Standard Documentale**.

Il presente documento deve rappresentare fedelmente lo stato effettivo e verificato del progetto, senza attribuire a funzionalità future o non ancora collaudate risultati non acquisiti.

# 2. Campo di applicazione

Il presente documento si applica alle attività di test, verifica e collaudo delle componenti software del progetto **Orto Smart**.

Le procedure descritte devono essere utilizzate in funzione della natura delle modifiche effettuate e delle funzionalità effettivamente implementate.

L'applicabilità dei controlli deve essere determinata sulla base dei componenti interessati, dei requisiti da verificare e dei rischi associati alle modifiche.

## 2.1 Componenti interessati

Il campo di applicazione comprende, quando pertinenti:

- codice applicativo sviluppato con Flutter e Dart;
- interfaccia utente e navigazione dell'applicazione;
- modelli, servizi e repository applicativi;
- logica di validazione e motori agronomici;
- comunicazione tra applicazione e Supabase;
- database PostgreSQL, schema e migration SQL;
- funzioni SQL, procedure RPC e relativi contratti;
- autenticazione, autorizzazione e politiche RLS;
- gestione delle sessioni applicative e delle autorizzazioni
  alla modifica dei dati;
- integrazione tra le diverse componenti software.

L'inclusione di un componente nel presente elenco non implica che tutte le relative funzionalità siano già implementate, operative o collaudate.

## 2.2 Attività soggette a verifica

Le procedure di test e collaudo si applicano, quando pertinenti, alle seguenti attività:

- introduzione di nuove funzionalità;
- modifica di funzionalità esistenti;
- correzione di anomalie;
- refactoring del codice;
- modifica dello schema o della logica del database;
- modifica dei controlli di sicurezza;
- modifica delle interfacce e dei contratti tra componenti;
- interventi che possono influire su funzionalità già verificate.

L'assenza di modifiche a un componente non esclude la necessità di eseguire test di regressione quando altri interventi possono influenzarne il comportamento.

## 2.3 Applicabilità dei controlli

I controlli devono essere selezionati in relazione alle modifiche effettivamente apportate.

In particolare:

- le modifiche al codice Dart o Flutter richiedono i controlli
  di formattazione, analisi statica e test previsti dal progetto;
- le modifiche SQL richiedono verifiche specifiche del database
  e dei contratti interessati;
- le modifiche che coinvolgono più componenti richiedono,
  quando pertinenti, verifiche di integrazione;
- le modifiche ai meccanismi di autenticazione, autorizzazione
  o protezione dei dati richiedono controlli di sicurezza pertinenti;
- le modifiche esclusivamente documentali richiedono verifiche
  documentali e non comportano automaticamente l'esecuzione
  dei test software.

L'esecuzione dei controlli Dart e Flutter non deve essere considerata automaticamente necessaria per modifiche esclusivamente SQL, in assenza di modifiche o dipendenze applicative che ne giustifichino l'esecuzione.

## 2.4 Esclusioni e limitazioni

Il DOC-007 non sostituisce:

- il DOC-000, che disciplina lo Standard Documentale;
- il DOC-001 — Manuale Tecnico e Architetturale, che descrive l'architettura tecnica del software;
- il DOC-004 — Manuale Database, che documenta la struttura del database;
- il DOC-006, che definisce le Linee Guida di Sviluppo;
- il DOC-009, che disciplina il Workflow Operativo.

Il presente documento non costituisce una certificazione automatica della qualità o della sicurezza dell'applicazione.

Il superamento di un insieme di test dimostra esclusivamente il soddisfacimento delle condizioni effettivamente verificate, nell'ambiente e nelle condizioni di esecuzione documentate.

Le funzionalità future, non implementate o non ancora sottoposte a collaudo non possono essere dichiarate operative o validate sulla base delle sole procedure descritte nel presente documento.

# 3. Tipologie e classificazione dei test

Le verifiche del progetto **Orto Smart** sono classificate in base all'obiettivo del controllo, al componente interessato e al livello di integrazione coinvolto.

La classificazione permette di individuare i test pertinenti alle modifiche effettuate, evitando sia l'omissione di controlli necessari sia l'esecuzione indiscriminata di verifiche non applicabili.

Le categorie descritte nel presente capitolo rappresentano le tipologie di controllo previste dal progetto.

La loro descrizione non implica che tutti i test siano già implementati, automatizzati o eseguiti.

## 3.1 Controlli statici del codice

I controlli statici verificano caratteristiche del codice senza richiedere l'esecuzione funzionale dell'applicazione.

Per il codice Dart e Flutter comprendono, quando applicabili:

- verifica della formattazione mediante `dart format`;
- analisi statica mediante `flutter analyze`;
- individuazione di errori, avvisi e problemi segnalati
  dagli strumenti di analisi;
- controllo della coerenza del codice rispetto alle
  convenzioni adottate dal progetto.

I controlli statici non sostituiscono i test funzionali, i test di integrazione o le verifiche di sicurezza.

## 3.2 Test unitari

I test unitari verificano il comportamento di singole unità logiche del software in condizioni controllate.

Possono riguardare, quando pertinenti:

- funzioni di calcolo;
- validatori;
- trasformazioni e normalizzazioni dei dati;
- regole applicative;
- componenti della logica agronomica;
- gestione dei risultati e degli errori.

Ogni test unitario deve prevedere condizioni iniziali definite, dati di ingresso e risultati attesi verificabili.

Quando necessario, le dipendenze esterne possono essere isolate mediante sostituti controllati.

Il superamento dei test unitari non dimostra, da solo, il corretto funzionamento dell'intero sistema.

## 3.3 Test di integrazione

I test di integrazione verificano la collaborazione tra due o più componenti del sistema.

Per Orto Smart possono comprendere:

- interazione tra interfaccia utente e logica applicativa;
- comunicazione tra repository Flutter e Supabase;
- chiamate alle funzioni RPC del database;
- gestione delle risposte e degli errori restituiti
  dai componenti esterni;
- coerenza dei dati trasferiti tra applicazione e database.

Le verifiche devono considerare sia i percorsi di esecuzione corretti sia le condizioni di errore pertinenti.

## 3.4 Test funzionali

I test funzionali verificano che una funzionalità si comporti secondo i requisiti e le regole approvate.

Possono essere eseguiti manualmente oppure mediante strumenti di automazione, quando disponibili.

Le verifiche possono riguardare:

- inserimento e consultazione dei dati;
- modifica delle informazioni;
- validazione degli input;
- gestione degli errori;
- navigazione tra le schermate;
- coerenza dei risultati mostrati all'utente;
- comportamento delle funzionalità effettivamente implementate.

Ogni verifica deve avere un risultato atteso identificabile e confrontabile con quello osservato.

## 3.5 Test del database

I test del database verificano la correttezza delle strutture e dei comportamenti definiti in PostgreSQL e Supabase.

Possono comprendere:

- applicazione delle migration SQL;
- verifica di tabelle, colonne, vincoli e indici;
- controllo delle funzioni e procedure RPC;
- verifica dei contratti di ingresso e uscita;
- controllo delle transazioni;
- gestione degli errori e delle condizioni limite;
- verifica della coerenza e dell'integrità dei dati.

I test devono essere eseguiti in un ambiente appropriato e con modalità che non compromettano i dati operativi.

Le verifiche specifiche del database sono approfondite nel Capitolo 7.

## 3.6 Test di sicurezza e autorizzazione

I test di sicurezza verificano il rispetto dei meccanismi di protezione e delle regole di accesso previste dal progetto.

Possono comprendere:

- autenticazione dell'utente;
- autorizzazione alle operazioni;
- applicazione delle politiche Row Level Security (RLS);
- verifica dei privilegi sulle risorse del database;
- controllo delle operazioni consentite e negate;
- gestione delle sessioni;
- verifica dei meccanismi di autorizzazione
  alle modifiche dei dati.

I test devono includere, quando pertinenti, sia i casi autorizzati sia i tentativi di operazioni non consentite.

Il superamento di questi controlli non costituisce una certificazione generale della sicurezza dell'applicazione.

Le procedure specifiche sono approfondite nel Capitolo 9.

## 3.7 Test di regressione

I test di regressione verificano che una modifica non abbia introdotto anomalie in comportamenti precedentemente funzionanti.

Sono particolarmente importanti in presenza di:

- correzioni di errori;
- refactoring;
- modifiche ai contratti tra componenti;
- modifiche allo schema o alle funzioni del database;
- cambiamenti dei meccanismi di autorizzazione;
- modifiche a componenti condivisi.

L'estensione dei test di regressione deve essere determinata in base all'impatto potenziale della modifica e ai rischi identificati.

## 3.8 Test end-to-end

I test end-to-end verificano un percorso funzionale completo attraverso i componenti effettivamente coinvolti nell'operazione.

Per Orto Smart possono comprendere, quando pertinenti, l'interazione tra:

- interfaccia Flutter;
- logica applicativa;
- servizi e repository;
- autenticazione e autorizzazione;
- funzioni RPC;
- database PostgreSQL.

Il test deve verificare il risultato complessivo dell'operazione, non soltanto il comportamento isolato dei singoli componenti.

I test end-to-end possono essere manuali o automatizzati, in base agli strumenti effettivamente disponibili.

## 3.9 Test negativi e condizioni limite

I test negativi verificano il comportamento del sistema quando riceve richieste non valide o incontra condizioni non consentite.

I test delle condizioni limite verificano il comportamento in prossimità dei valori e delle situazioni ammesse dai requisiti.

Possono comprendere:

- dati mancanti o non validi;
- valori fuori intervallo;
- operazioni non autorizzate;
- riferimenti inesistenti;
- violazioni di vincoli;
- richieste incompatibili con lo stato corrente;
- errori restituiti da servizi o componenti esterni.

Il risultato atteso può consistere nel rifiuto controllato dell'operazione, purché coerente con il contratto previsto e senza alterazioni indebite dei dati.

## 3.10 Classificazione degli esiti

Ogni verifica eseguita deve essere associata a un esito esplicito.

Sono previste le seguenti classificazioni:

| Esito | Significato |
|-------|-------------|
| SUPERATO | Test eseguito con risultato conforme alle condizioni attese |
| NON SUPERATO | Test eseguito con risultato non conforme |
| NON ESEGUITO | Test previsto o pertinente ma non eseguito |
| NON APPLICABILE | Test non pertinente all'attività o al componente verificato |
| BLOCCATO | Test non completabile a causa di una condizione impeditiva |

L'esito **BLOCCATO** deve essere accompagnato dalla descrizione dell'impedimento.

Un test NON ESEGUITO o BLOCCATO non può essere considerato SUPERATO.

La classificazione NON APPLICABILE deve essere motivata quando il controllo potrebbe essere ragionevolmente ritenuto pertinente.

## 3.11 Criteri di selezione dei test

La selezione dei test deve considerare:

- natura della modifica;
- componenti interessati;
- dipendenze tra componenti;
- impatto sui dati;
- impatto sulla sicurezza;
- possibili regressioni;
- requisiti e contratti coinvolti;
- disponibilità degli ambienti di verifica.

La selezione deve essere proporzionata ai rischi e deve consentire di motivare i controlli effettivamente eseguiti e quelli esclusi.

I criteri di accettazione, le modalità di registrazione degli esiti e la gestione delle anomalie sono disciplinati nei capitoli successivi del presente documento.

# 4. Ambienti e strumenti di collaudo

Le attività di test e collaudo di **Orto Smart** devono essere eseguite in ambienti identificabili, controllati e adeguati alla natura delle verifiche previste.

La scelta dell'ambiente e degli strumenti dipende dai componenti interessati, dal tipo di test e dai rischi associati all'operazione.

Ogni risultato deve essere riferibile all'ambiente nel quale il test è stato effettivamente eseguito.

## 4.1 Ambiente di sviluppo locale

L'ambiente di sviluppo locale costituisce il riferimento principale per la preparazione delle modifiche e per l'esecuzione dei controlli tecnici preliminari.

Per Orto Smart comprende, secondo la configurazione effettivamente utilizzata:

- sistema operativo Windows;
- Visual Studio Code;
- Flutter SDK e Dart SDK;
- terminale PowerShell;
- Git per il controllo delle versioni;
- browser utilizzati per le verifiche dell'applicazione;
- strumenti di sviluppo locale Supabase;
- database PostgreSQL locale.

La disponibilità di uno strumento non implica che esso debba essere utilizzato in ogni sessione.

Le versioni effettive degli strumenti devono essere rilevate quando necessarie alla riproducibilità dei test o all'analisi di eventuali anomalie.

## 4.2 Ambiente database locale

Il database PostgreSQL locale, gestito attraverso gli strumenti Supabase previsti dal progetto, è utilizzabile per le verifiche tecniche che richiedono un ambiente controllato.

Le verifiche possono comprendere:

- applicazione delle migration SQL;
- controlli dello schema;
- esecuzione di test sulle funzioni RPC;
- verifica dei vincoli e delle transazioni;
- prove di autorizzazione e sicurezza;
- test negativi e condizioni limite;
- verifiche di integrazione con l'applicazione.

Prima dell'esecuzione deve essere accertato quale database sia effettivamente collegato agli strumenti utilizzati.

Le operazioni potenzialmente distruttive devono essere autorizzate e limitate all'ambiente previsto per il test.

## 4.3 Ambiente Supabase remoto

L'ambiente Supabase remoto costituisce un ambiente distinto da quello locale.

Le verifiche sul progetto remoto devono essere pianificate in funzione delle operazioni consentite e dei dati presenti.

Prima di eseguire controlli che modificano lo stato del database remoto è necessario:

- identificare il progetto di destinazione;
- verificare il collegamento effettivo;
- determinare l'impatto dell'operazione;
- accertare che la verifica sia autorizzata;
- evitare modifiche non necessarie ai dati operativi.

Il superamento di un test locale non deve essere automaticamente considerato prova del medesimo risultato nell'ambiente remoto.

## 4.4 Ambiente di esecuzione Flutter

Le verifiche funzionali dell'applicazione devono essere eseguite su piattaforme effettivamente supportate dalla versione del progetto sottoposta a test.

Per l'attuale sviluppo web di Orto Smart, gli strumenti di esecuzione possono comprendere:

- browser Microsoft Edge;
- server web locale Flutter;
- altri browser o dispositivi utilizzati
  per verifiche specifiche.

Le modalità di avvio devono essere coerenti con l'obiettivo del test.

Quando pertinente, occorre distinguere l'esecuzione in modalità di sviluppo da quella in modalità release.

Il risultato ottenuto su un browser o dispositivo non dimostra automaticamente il corretto funzionamento su tutte le altre piattaforme.

## 4.5 Strumenti di verifica Dart e Flutter

Gli strumenti di controllo del codice Dart e Flutter comprendono, quando applicabili:

- `dart format`, per la verifica della formattazione;
- `flutter analyze`, per l'analisi statica;
- `flutter test`, per l'esecuzione dei test
  automatici disponibili;
- strumenti di avvio Flutter, per le verifiche
  funzionali e di integrazione.

La disponibilità del comando `flutter test` non implica l'esistenza di una suite completa di test automatici.

L'esito dei comandi deve essere valutato sulla base dell'output effettivamente ottenuto.

## 4.6 Strumenti di verifica del database

Gli strumenti utilizzabili per le verifiche PostgreSQL e Supabase possono comprendere:

- Supabase CLI;
- client SQL compatibili con PostgreSQL;
- terminale PowerShell;
- comandi di controllo delle migration;
- interrogazioni SQL di verifica;
- strumenti di consultazione del database.

L'utilizzo di questi strumenti deve rispettare le regole di sicurezza e le autorizzazioni previste dal progetto.

Le verifiche devono distinguere le operazioni di sola lettura da quelle che modificano dati, strutture o autorizzazioni.

## 4.7 Separazione degli ambienti e protezione dei dati

Gli ambienti locale e remoto devono essere considerati distinti.

Prima di eseguire test che possono modificare dati o strutture è necessario verificare la destinazione effettiva dell'operazione.

I dati di prova devono essere utilizzati esclusivamente in condizioni controllate e non devono contaminare il database destinato all'utilizzo operativo dell'orto.

Non devono essere introdotti dati provvisori nel database operativo al solo scopo di eseguire verifiche.

Quando un test richiede dati temporanei, devono essere definite preventivamente le modalità di isolamento e ripristino.

Le operazioni distruttive o irreversibili non devono essere eseguite senza un'esplicita valutazione del rischio e la necessaria autorizzazione.

## 4.8 Tracciabilità dell'ambiente di test

Quando necessario per comprendere o riprodurre una verifica, devono essere registrate le informazioni essenziali sull'ambiente utilizzato.

Possono comprendere:

- data della verifica;
- sessione di sviluppo di riferimento;
- ambiente locale o remoto;
- componente sottoposto a test;
- versione del codice o commit Git;
- versioni degli strumenti pertinenti;
- comando o procedura eseguita;
- risultato osservato;
- eventuali anomalie o limitazioni.

La registrazione deve essere proporzionata alla complessità e alla criticità del controllo.

Le modalità operative di esecuzione e di registrazione delle evidenze sono approfondite nei capitoli successivi.

# 5. Preparazione ed esecuzione dei test

Le attività di test di **Orto Smart** devono essere preparate, eseguite e verificate secondo una procedura controllata, proporzionata alla natura delle modifiche e ai rischi associati.

Ogni test deve avere uno scopo identificabile, condizioni di esecuzione definite e un risultato atteso verificabile.

La procedura descritta nel presente capitolo si applica sia ai test manuali sia ai test automatizzati, con gli adattamenti necessari alla specifica tipologia di verifica.

## 5.1 Identificazione dell'oggetto della verifica

Prima di iniziare i test devono essere identificati:

- la sessione di sviluppo o l'attività di riferimento;
- la funzionalità o il componente interessato;
- le modifiche effettivamente apportate;
- i requisiti e i contratti coinvolti;
- le dipendenze con altri componenti;
- gli eventuali rischi per dati, sicurezza e funzionalità esistenti.

L'identificazione deve basarsi sullo stato reale del progetto e sulle modifiche effettivamente eseguite.

Non devono essere considerate implementate funzionalità soltanto previste o descritte nella documentazione.

## 5.2 Definizione del piano di verifica

Per ogni attività devono essere individuati i controlli necessari, tenendo conto della classificazione del Capitolo 3.

Il piano di verifica deve definire, quando pertinenti:

- obiettivo dei test;
- componenti interessati;
- ambiente di esecuzione;
- strumenti necessari;
- condizioni iniziali;
- dati o condizioni di ingresso;
- operazioni da eseguire;
- risultati attesi;
- eventuali verifiche di regressione;
- criteri di accettazione.

Il piano può essere sintetico per modifiche circoscritte e più articolato per interventi complessi o critici.

Non è necessario predisporre un documento separato per ogni singolo controllo, purché le informazioni necessarie siano identificabili e tracciabili.

## 5.3 Verifica preliminare dell'ambiente

Prima dell'esecuzione devono essere verificati, quando applicabili:

- disponibilità degli strumenti necessari;
- correttezza della directory di lavoro;
- identificazione del repository e del ramo Git;
- versione del codice sottoposta a test;
- disponibilità dei servizi richiesti;
- identificazione dell'ambiente locale o remoto;
- collegamento al database previsto;
- condizioni necessarie per l'esecuzione del test.

In presenza di operazioni che modificano dati o strutture del database, l'identificazione della destinazione deve precedere l'esecuzione.

Un ambiente non identificato o non conforme alle condizioni previste impedisce l'avvio dei test che potrebbero comprometterne i dati.

## 5.4 Preparazione delle condizioni iniziali

Le condizioni iniziali devono consentire di interpretare correttamente il risultato del test.

Possono comprendere:

- stato iniziale dei dati;
- presenza o assenza di record pertinenti;
- identità e autorizzazioni utilizzate;
- stato della sessione applicativa;
- disponibilità dei componenti coinvolti;
- configurazione delle dipendenze necessarie.

Quando il test richiede dati temporanei, devono essere definite modalità controllate di preparazione, isolamento e ripristino.

La preparazione non deve introdurre dati di prova permanenti nel database operativo.

Le condizioni iniziali devono essere documentate quando necessarie per riprodurre il test o comprenderne l'esito.

## 5.5 Definizione dei risultati attesi

Prima dell'esecuzione devono essere stabiliti i risultati attesi della verifica.

I risultati attesi devono derivare, quando disponibili, da:

- requisiti approvati;
- contratti applicativi;
- vincoli del database;
- regole di autorizzazione;
- comportamenti funzionali previsti;
- decisioni architetturali approvate.

Il risultato atteso deve essere sufficientemente preciso da permettere il confronto con il comportamento effettivamente osservato.

Un test non deve essere considerato superato soltanto perché non sono comparsi errori visibili.

Quando il risultato atteso non è definibile, il test deve essere chiarito prima di attribuirgli un esito positivo.

## 5.6 Esecuzione controllata

I test devono essere eseguiti secondo le operazioni previste e nell'ambiente identificato.

Durante l'esecuzione occorre:

- utilizzare i comandi o le procedure pertinenti;
- rispettare le condizioni iniziali stabilite;
- osservare i risultati prodotti;
- rilevare eventuali messaggi di errore;
- evitare operazioni aggiuntive non necessarie;
- interrompere le verifiche potenzialmente rischiose
  quando emergono condizioni inattese.

Quando un test viene modificato durante l'esecuzione, la variazione deve essere riconoscibile nella registrazione del risultato, se rilevante per la sua interpretazione.

Le operazioni non effettivamente eseguite non devono essere registrate come completate.

## 5.7 Confronto tra risultato atteso e osservato

Al termine del test il risultato osservato deve essere confrontato con quello atteso.

La verifica deve considerare, quando pertinenti:

- valori restituiti;
- modifiche effettivamente applicate;
- integrità e coerenza dei dati;
- messaggi e codici di errore;
- autorizzazioni rispettate;
- assenza di effetti collaterali indebiti;
- comportamento dei componenti integrati.

L'esito deve essere classificato secondo le categorie definite nel paragrafo 3.10.

Un risultato parziale non può essere automaticamente classificato come SUPERATO se non soddisfa tutte le condizioni necessarie per l'accettazione del test.

## 5.8 Gestione delle interruzioni e dei blocchi

Se un test non può essere completato, devono essere identificati il motivo e le condizioni che ne impediscono la prosecuzione.

Possono costituire impedimenti:

- indisponibilità dell'ambiente;
- assenza di dipendenze necessarie;
- configurazione non conforme;
- mancanza delle autorizzazioni richieste;
- condizioni iniziali non riproducibili;
- anomalie che impediscono la verifica.

Un test interrotto senza una conclusione verificabile non deve essere considerato superato.

Quando applicabile, l'esito deve essere classificato come BLOCCATO o NON ESEGUITO, specificandone la motivazione.

## 5.9 Ripetizione delle verifiche

Un test deve essere ripetuto quando una modifica successiva può influenzare il comportamento precedentemente verificato.

La ripetizione è necessaria, quando pertinente, dopo:

- correzione di un'anomalia;
- modifica del codice sottoposto a test;
- modifica di una funzione o di un contratto RPC;
- modifica di vincoli o strutture del database;
- cambiamenti delle regole di autorizzazione;
- interventi sulle dipendenze del componente.

I risultati precedenti rimangono evidenze delle verifiche svolte sulla versione originariamente testata.

Non devono essere automaticamente estesi a versioni successive non verificate.

## 5.10 Conclusione dell'attività di test

Prima di considerare conclusa un'attività di verifica devono essere accertati:

- identificazione dei test effettivamente eseguiti;
- disponibilità dei relativi esiti;
- registrazione delle anomalie rilevate;
- identificazione dei test non eseguiti o bloccati;
- valutazione dei controlli di regressione pertinenti;
- rispetto dei criteri di accettazione applicabili;
- assenza di modifiche indesiderate ai dati operativi.

La conclusione dell'attività di test non equivale automaticamente all'approvazione complessiva della funzionalità o del rilascio.

L'accettazione dipende dai criteri definiti nel Capitolo 10 e dalle evidenze effettivamente disponibili.

Le modalità di registrazione dei risultati sono disciplinate nel Capitolo 12.

# 6. Test automatici Dart e Flutter

I controlli automatici del codice Dart e Flutter costituiscono una parte delle attività di verifica del progetto **Orto Smart**.

Il loro obiettivo è individuare problemi di formattazione, analisi statica e comportamento delle componenti software per le quali sono disponibili test eseguibili.

I controlli devono essere selezionati in relazione alle modifiche effettivamente apportate e alle indicazioni contenute nel DOC-006 — Linee Guida di Sviluppo.

L'esecuzione di un comando non costituisce, da sola, prova del superamento dei controlli: devono essere considerati l'output e l'esito effettivamente ottenuti.

## 6.1 Ambito di applicazione

I controlli Dart e Flutter sono pertinenti, in particolare, quando vengono modificati:

- file sorgente Dart;
- widget e schermate Flutter;
- modelli applicativi;
- servizi e repository;
- validatori e logica applicativa;
- componenti dei motori agronomici;
- test automatici esistenti;
- configurazioni che possono influenzare
  l'analisi o l'esecuzione del codice.

Per modifiche esclusivamente SQL o documentali, i controlli Dart e Flutter non sono automaticamente obbligatori.

Devono tuttavia essere considerati quando la modifica coinvolge contratti, dipendenze o comportamenti dell'applicazione Flutter.

## 6.2 Preparazione dell'ambiente

Prima dell'esecuzione dei controlli è necessario verificare che il terminale si trovi nella directory corretta del progetto Flutter.

Per Orto Smart, la directory di riferimento è:

`C:\Sviluppo\orto-smart\orto-smart\orto_app`

Nel terminale PowerShell è possibile controllare la posizione corrente mediante:

```powershell
Get-Location
```

Quando necessario, è possibile verificare la disponibilità degli strumenti mediante:

```powershell
flutter --version
dart --version
```

Le versioni effettivamente rilevate devono essere registrate quando pertinenti alla riproducibilità della verifica.

## 6.3 Verifica della formattazione

La verifica della formattazione controlla la conformità del codice Dart alle regole applicate dallo strumento `dart format`.

Per verificare la formattazione senza modificare automaticamente i file:

```powershell
dart format --output=none --set-exit-if-changed lib test
```

Il comando deve essere adattato alle directory effettivamente presenti nel progetto.

L'esito deve essere valutato sulla base del codice di uscita e dei messaggi prodotti.

Quando è necessario applicare la formattazione ai file interessati, può essere utilizzato:

```powershell
dart format percorso\file.dart
```

L'applicazione della formattazione costituisce una modifica ai file e deve essere verificata prima di proseguire.

La formattazione corretta non dimostra l'assenza di errori logici o funzionali.

## 6.4 Analisi statica Flutter

L'analisi statica permette di individuare problemi rilevabili dagli strumenti di analisi del codice Dart e Flutter.

Il comando di riferimento è:

```powershell
flutter analyze
```

L'esecuzione deve avvenire dalla directory del progetto Flutter.

Il risultato deve essere valutato verificando:

- completamento del comando;
- eventuali errori;
- eventuali avvisi;
- segnalazioni informative pertinenti;
- codice di uscita.

La presenza di segnalazioni deve essere esaminata prima di dichiarare superato il controllo.

L'assenza di problemi segnalati non dimostra automaticamente la correttezza funzionale dell'applicazione.

## 6.5 Esecuzione dei test automatici

I test automatici Dart e Flutter disponibili possono essere eseguiti mediante:

```powershell
flutter test
```

Il comando esegue i test individuati dallo strumento nella configurazione corrente.

Prima di interpretare il risultato occorre accertare quali test siano effettivamente presenti e quali componenti siano coperti.

Il completamento del comando non dimostra che tutte le funzionalità del progetto dispongano di test automatici.

Quando necessario, un singolo file di test può essere eseguito specificandone il percorso:

```powershell
flutter test test\percorso_test.dart
```

Il percorso indicato è esemplificativo e deve essere sostituito con quello di un file di test realmente esistente.

## 6.6 Interpretazione dei risultati

Per ogni controllo eseguito devono essere considerati:

- comando utilizzato;
- ambiente di esecuzione;
- versione del codice verificata;
- completamento o interruzione del comando;
- codice di uscita;
- messaggi prodotti;
- numero di test eseguiti, quando disponibile;
- eventuali test falliti o ignorati.

Un controllo non eseguito non può essere registrato come superato.

Un comando che non individua test eseguibili non costituisce prova del superamento di test automatici.

Eventuali test ignorati devono essere riconoscibili nella registrazione dell'esito.

## 6.7 Gestione degli errori

Quando un controllo segnala un problema, occorre distinguere tra:

- errore del codice sottoposto a verifica;
- errore di configurazione;
- indisponibilità di dipendenze;
- problema dell'ambiente di esecuzione;
- test non coerente con i requisiti approvati;
- comportamento inatteso dell'applicazione.

La causa deve essere analizzata prima di introdurre modifiche correttive.

Non devono essere alterati i risultati attesi di un test soltanto per ottenere un esito formalmente positivo.

Dopo una correzione devono essere ripetuti i controlli pertinenti.

## 6.8 Copertura e limiti dei test automatici

I test automatici verificano esclusivamente i comportamenti effettivamente coperti dai casi di test eseguiti.

La copertura deve essere valutata rispetto alle funzionalità e ai rischi interessati, senza presumere che la presenza di una suite garantisca una verifica completa.

Quando una funzionalità non dispone di test automatici adeguati, devono essere valutate verifiche manuali o di integrazione pertinenti.

I controlli automatici non sostituiscono:

- test funzionali;
- test di integrazione;
- verifiche del database;
- controlli di sicurezza;
- test end-to-end;
- valutazione dei criteri di accettazione.

## 6.9 Registrazione delle evidenze

I risultati dei controlli Dart e Flutter devono essere registrati secondo le modalità previste dal Capitolo 12.

Quando pertinenti, le evidenze devono consentire di ricostruire:

- quale comando è stato eseguito;
- su quale versione del codice;
- in quale ambiente;
- con quale risultato;
- quali problemi sono stati rilevati;
- quali verifiche sono state ripetute
  dopo eventuali correzioni.

Non è necessario duplicare integralmente gli output quando una sintesi verificabile e un riferimento all'evidenza originale sono sufficienti.

Le evidenze devono distinguere chiaramente i controlli SUPERATI da quelli NON SUPERATI, NON ESEGUITI, NON APPLICABILI o BLOCCATI.

# 7. Test database PostgreSQL e Supabase

Le verifiche del database di **Orto Smart** hanno lo scopo di accertare la correttezza delle strutture, dei vincoli, delle funzioni e dei comportamenti implementati in PostgreSQL e Supabase.

I test devono essere selezionati in relazione alle modifiche effettivamente apportate e ai contratti tecnici interessati.

Le verifiche devono considerare sia i comportamenti attesi sia le condizioni di errore pertinenti.

Il superamento di un test deve essere documentato attraverso risultati effettivamente osservati e non può essere dedotto dalla sola presenza di codice SQL o di migration applicate.

## 7.1 Ambito delle verifiche

I controlli del database possono riguardare, quando pertinenti:

- struttura delle tabelle;
- colonne e tipi di dato;
- chiavi primarie ed esterne;
- vincoli di integrità;
- indici e vincoli di unicità;
- valori predefiniti;
- trigger;
- funzioni SQL e PL/pgSQL;
- procedure RPC esposte all'applicazione;
- transazioni;
- autorizzazioni e privilegi;
- politiche Row Level Security (RLS);
- coerenza tra database e contratti applicativi.

Le verifiche devono essere limitate ai componenti effettivamente coinvolti, estendendosi alle dipendenze quando necessario.

La presenza di una struttura nel database non costituisce, da sola, prova del corretto funzionamento delle operazioni che la utilizzano.

## 7.2 Identificazione dell'ambiente

Prima di eseguire verifiche SQL è necessario identificare l'ambiente di destinazione.

Devono essere distinti almeno:

- database PostgreSQL locale;
- progetto Supabase remoto.

Quando pertinente, devono essere accertati:

- progetto e database collegati;
- modalità di connessione;
- identità o ruolo utilizzato;
- schema interessato;
- versione delle migration applicate;
- presenza di dati che devono essere preservati.

Non devono essere eseguite operazioni potenzialmente distruttive quando la destinazione non è stata identificata con sufficiente certezza.

I test locali e quelli remoti devono essere registrati separatamente.

## 7.3 Verifica delle migration SQL

Le migration devono essere verificate rispetto alle modifiche strutturali e funzionali che introducono.

I controlli possono comprendere:

- presenza dei file di migration previsti;
- corretto ordine di applicazione;
- esito dell'applicazione;
- creazione o modifica degli oggetti attesi;
- compatibilità con le strutture esistenti;
- assenza di modifiche indesiderate;
- coerenza con i contratti approvati.

Quando pertinente, deve essere verificata anche la corrispondenza tra le migration registrate nell'ambiente locale e quelle presenti nell'ambiente remoto.

La presenza di un file di migration nel repository non dimostra che esso sia stato applicato a un database.

L'esito di applicazione deve essere verificato nell'ambiente interessato.

## 7.4 Verifica dello schema e dei vincoli

I test strutturali devono accertare che gli oggetti del database rispettino le definizioni approvate.

Le verifiche possono comprendere:

- esistenza delle tabelle previste;
- correttezza dei nomi e dei tipi delle colonne;
- obbligatorietà dei valori;
- chiavi primarie;
- chiavi esterne;
- vincoli CHECK;
- vincoli UNIQUE;
- indici;
- valori predefiniti;
- trigger e relativi effetti.

Quando necessario, devono essere verificati anche i comportamenti in presenza di dati non validi.

Il rifiuto di un'operazione che viola un vincolo può costituire il risultato atteso di un test negativo.

La verifica deve accertare che il rifiuto avvenga secondo il comportamento previsto, senza modifiche indebite ai dati.

## 7.5 Test delle funzioni SQL e delle RPC

Le funzioni SQL e PL/pgSQL devono essere verificate rispetto ai rispettivi contratti.

Per le funzioni RPC utilizzate dall'applicazione, i controlli possono comprendere:

- nome e firma della funzione;
- parametri richiesti;
- tipi dei parametri;
- validazione degli input;
- condizioni preliminari;
- autorizzazioni richieste;
- risultato restituito;
- codici o messaggi di errore previsti;
- modifiche effettivamente applicate;
- gestione delle condizioni non consentite.

Devono essere verificati, quando pertinenti, sia i casi di successo sia quelli di rifiuto.

Un test che verifica esclusivamente la presenza della funzione non dimostra la correttezza del suo comportamento.

Le verifiche devono considerare anche la compatibilità del contratto RPC con il codice applicativo che lo utilizza.

## 7.6 Verifica delle transazioni e dell'atomicità

Le operazioni che modificano più elementi correlati devono essere verificate rispetto alle garanzie transazionali previste.

Quando pertinente, i test devono accertare:

- applicazione completa delle modifiche valide;
- annullamento delle modifiche in caso di errore;
- assenza di aggiornamenti parziali indebiti;
- mantenimento dei vincoli di integrità;
- coerenza dello stato finale dei dati.

Il risultato atteso deve essere definito in base al contratto dell'operazione.

Un errore non deve lasciare il database in uno stato incoerente rispetto alle garanzie previste.

## 7.7 Verifica della concorrenza

Quando una funzionalità prevede controlli sulla modifica concorrente dei dati, devono essere eseguite verifiche pertinenti a tali meccanismi.

Per Orto Smart possono riguardare:

- identificazione della sessione applicativa;
- autorizzazione alla scrittura;
- acquisizione e mantenimento dei lock;
- rilascio dei lock;
- rifiuto delle scritture non autorizzate;
- gestione delle richieste concorrenti;
- controllo delle versioni dei record.

I test devono verificare i comportamenti effettivamente previsti dai contratti approvati e implementati.

Non devono essere presunti comportamenti di concorrenza non verificati nell'ambiente sottoposto a test.

Le verifiche specifiche dei permessi sono approfondite nel Capitolo 9.

## 7.8 Test negativi e condizioni limite

I test negativi del database devono verificare il comportamento in presenza di richieste non valide o non consentite.

Possono comprendere:

- parametri mancanti;
- valori nulli non ammessi;
- valori fuori intervallo;
- identificativi inesistenti;
- riferimenti non validi;
- duplicazioni vietate;
- violazioni dei vincoli;
- operazioni incompatibili con lo stato corrente;
- richieste effettuate senza autorizzazione;
- versioni dei record non coerenti.

Per ogni caso deve essere definito il risultato atteso.

Il test deve accertare non soltanto il rifiuto dell'operazione, ma anche l'assenza di effetti collaterali non consentiti.

## 7.9 Integrità e coerenza dei dati

Le verifiche di integrità devono accertare che le operazioni mantengano la coerenza dei dati interessati.

Quando pertinente, devono essere controllati:

- rispetto delle relazioni tra record;
- conservazione dei dati non coinvolti;
- corretta applicazione degli aggiornamenti;
- rispetto delle regole di unicità;
- coerenza delle versioni dei record;
- comportamento delle eliminazioni previste;
- assenza di modifiche non richieste.

La verifica deve considerare lo stato iniziale e quello finale.

La semplice assenza di errori SQL non dimostra che i dati risultanti siano corretti.

## 7.10 Test di autorizzazione e RLS

I controlli relativi alle autorizzazioni del database devono verificare il rispetto delle regole di accesso previste dal progetto.

Possono comprendere:

- privilegi concessi ai ruoli;
- accesso alle tabelle;
- applicazione delle politiche RLS;
- autorizzazione all'esecuzione delle RPC;
- comportamento delle funzioni
  SECURITY DEFINER;
- separazione tra operazioni consentite
  e operazioni negate;
- controllo delle identità utilizzate.

Le verifiche devono essere effettuate con ruoli e condizioni coerenti con il caso sottoposto a test.

Un controllo eseguito con privilegi elevati non dimostra automaticamente che le protezioni funzionino per un utente applicativo ordinario.

Le procedure di sicurezza sono approfondite nel Capitolo 9.

## 7.11 Protezione dei dati durante i test

I test del database devono essere progettati in modo da non compromettere i dati destinati all'utilizzo operativo di Orto Smart.

Non devono essere introdotti dati di prova permanenti nel database operativo.

Quando sono necessari inserimenti o modifiche temporanee, devono essere definite preventivamente modalità di isolamento e ripristino.

Possono essere utilizzati, quando tecnicamente appropriati:

- ambienti locali isolati;
- transazioni con annullamento finale;
- dati temporanei controllati;
- procedure di ripristino verificate.

L'utilizzo di una transazione non deve essere considerato garanzia universale di reversibilità per qualsiasi operazione.

Le operazioni distruttive, i reset e gli interventi sui dati remoti richiedono una valutazione preventiva del rischio e un'autorizzazione esplicita.

## 7.12 Verifica del ripristino

Quando un test modifica temporaneamente lo stato del database, deve essere verificato il ripristino previsto.

I controlli possono comprendere:

- assenza dei record temporanei;
- ripristino dei valori originari;
- conservazione delle relazioni;
- assenza di modifiche residue;
- integrità degli oggetti interessati.

Se il ripristino non può essere dimostrato, il test non deve essere considerato completamente concluso per gli aspetti relativi alla protezione dei dati.

Le eventuali anomalie residue devono essere documentate e gestite.

## 7.13 Interpretazione dei risultati

L'esito dei test database deve essere determinato confrontando il risultato osservato con quello atteso.

Quando pertinenti, devono essere valutati:

- completamento dell'operazione;
- valori restituiti;
- messaggi e codici di errore;
- modifiche applicate;
- modifiche rifiutate;
- integrità dei dati;
- rispetto delle autorizzazioni;
- assenza di effetti collaterali indebiti.

L'esito deve essere classificato secondo le categorie definite nel paragrafo 3.10.

Un test non eseguito non può essere considerato superato.

Il superamento dei test locali non costituisce automaticamente prova del superamento dei medesimi controlli nell'ambiente remoto.

## 7.14 Registrazione delle evidenze

Le verifiche del database devono essere documentate secondo le modalità previste dal Capitolo 12.

Quando pertinenti, le evidenze devono consentire di identificare:

- ambiente utilizzato;
- versione del codice o delle migration;
- oggetto del database verificato;
- comando o interrogazione eseguita;
- condizioni iniziali;
- risultato atteso;
- risultato osservato;
- esito del test;
- eventuali anomalie;
- eventuale ripristino effettuato.

Le informazioni riservate, comprese credenziali, token e altri segreti, non devono essere riportate nelle evidenze di collaudo.

I risultati devono essere sufficienti a ricostruire la verifica senza duplicare inutilmente informazioni già disponibili nelle fonti ufficiali.

# 8. Test funzionali e di integrazione

I test funzionali e di integrazione di **Orto Smart** hanno lo scopo di verificare che le funzionalità applicative si comportino secondo i requisiti e i contratti approvati.

Le verifiche devono considerare sia il comportamento delle singole funzionalità sia la corretta interazione tra i componenti coinvolti.

Il risultato di un test deve essere determinato attraverso l'osservazione del comportamento effettivo dell'applicazione e dei sistemi interessati.

## 8.1 Ambito dei test funzionali

I test funzionali possono riguardare, quando pertinenti:

- accesso e inizializzazione dell'applicazione;
- navigazione tra le schermate;
- visualizzazione dei dati;
- inserimento di nuove informazioni;
- modifica dei dati esistenti;
- operazioni di chiusura o annullamento;
- gestione delle condizioni di errore;
- aggiornamento delle informazioni visualizzate;
- rispetto delle regole applicative;
- coerenza delle informazioni persistite.

Le funzionalità devono essere verificate in relazione al loro stato effettivo di implementazione.

Le funzioni pianificate ma non ancora realizzate non devono essere considerate automaticamente disponibili o collaudate.

## 8.2 Ambito dei test di integrazione

I test di integrazione devono verificare il corretto funzionamento delle interazioni tra componenti distinti.

Per Orto Smart possono comprendere:

- interazione tra schermate Flutter;
- interazione tra interfaccia e logica applicativa;
- interazione tra logica applicativa e repository;
- comunicazione con Supabase;
- invocazione delle funzioni RPC;
- lettura dei risultati restituiti dal database;
- aggiornamento dell'interfaccia dopo le operazioni;
- gestione degli errori provenienti dai servizi.

La verifica di un singolo componente non dimostra automaticamente il corretto funzionamento dell'intero flusso.

Quando una modifica coinvolge più livelli, il collaudo deve considerare le interazioni effettivamente interessate.

## 8.3 Preparazione dei casi di test

Prima dell'esecuzione deve essere identificato il comportamento da verificare.

Quando pertinente, il caso di test deve definire:

- funzionalità interessata;
- requisiti o contratti di riferimento;
- ambiente utilizzato;
- condizioni iniziali;
- dati necessari;
- sequenza delle operazioni;
- risultato atteso;
- verifiche dello stato finale;
- eventuali condizioni di ripristino.

I casi di test devono essere sufficientemente chiari da consentire la ripetizione della verifica nelle medesime condizioni, per quanto tecnicamente possibile.

I dati di prova devono rispettare le regole di protezione e isolamento definite nel Capitolo 7.

## 8.4 Verifica della navigazione

I test di navigazione devono verificare che l'utente possa raggiungere le funzionalità disponibili attraverso i percorsi previsti.

Quando pertinente, devono essere controllati:

- apertura delle schermate;
- passaggio tra le sezioni;
- ritorno alla schermata precedente;
- mantenimento del contesto applicativo;
- comportamento dei comandi di navigazione;
- assenza di percorsi non previsti;
- corretta gestione delle schermate non accessibili.

Le verifiche devono essere effettuate sui dispositivi e browser pertinenti al collaudo previsto.

Un percorso funzionante in un ambiente non dimostra automaticamente che sia corretto in tutti gli altri.

## 8.5 Verifica della visualizzazione dei dati

I test di visualizzazione devono accertare che le informazioni mostrate dall'applicazione siano coerenti con i dati disponibili e con le regole di presentazione approvate.

Quando pertinente, devono essere verificati:

- caricamento dei dati;
- corretta associazione delle informazioni;
- ordinamento e filtri;
- visualizzazione di elenchi vuoti;
- aggiornamento dopo una modifica;
- gestione dei dati mancanti;
- visualizzazione degli errori;
- assenza di informazioni appartenenti
  a contesti non autorizzati.

La corretta visualizzazione deve essere valutata rispetto al risultato atteso, non soltanto rispetto all'assenza di errori nell'interfaccia.

## 8.6 Verifica delle operazioni di inserimento

I test di inserimento devono verificare l'intero percorso previsto, dalla compilazione dei dati alla loro eventuale persistenza.

Quando pertinente, devono essere controllati:

- disponibilità dei campi previsti;
- validazione dei valori;
- gestione dei campi obbligatori;
- conferma dell'operazione;
- invocazione del percorso di scrittura previsto;
- risultato restituito;
- aggiornamento dell'interfaccia;
- effettiva persistenza dei dati;
- assenza di inserimenti duplicati indebiti.

Un messaggio di conferma nell'interfaccia non costituisce, da solo, prova dell'avvenuto salvataggio nel database.

Quando necessario, lo stato persistito deve essere verificato separatamente.

## 8.7 Verifica delle operazioni di modifica

I test di modifica devono verificare che l'applicazione consenta gli aggiornamenti previsti nel rispetto dei relativi contratti.

Quando pertinente, devono essere controllati:

- selezione del record corretto;
- caricamento dei valori esistenti;
- modifica dei campi consentiti;
- validazione dei nuovi valori;
- conferma o annullamento;
- rispetto delle autorizzazioni;
- aggiornamento del record previsto;
- mantenimento dei dati non interessati;
- corretta visualizzazione dello stato finale.

Devono essere considerati anche i casi nei quali la modifica non è consentita.

Il rifiuto deve essere coerente con le regole applicative e non deve produrre modifiche indebite.

## 8.8 Verifica dei flussi applicativi completi

Quando una funzionalità coinvolge più passaggi consecutivi, il collaudo deve verificare l'intero percorso operativo.

Per Orto Smart, in relazione alle funzioni effettivamente implementate, possono essere considerati flussi riguardanti:

- gestione del profilo e del contesto applicativo;
- gestione degli orti;
- gestione delle aiuole;
- gestione delle stagioni;
- consultazione del Catalogo Agronomico;
- gestione delle coltivazioni;
- passaggio tra elenco, dettaglio e modifica;
- aggiornamento dei dati dopo un'operazione.

L'elenco non costituisce attestazione di disponibilità o collaudo di tutte le funzionalità indicate.

Ogni flusso deve essere valutato sulla base dello stato reale dell'applicazione al momento del test.

## 8.9 Verifica delle regole applicative

I test devono verificare che le operazioni rispettino le regole funzionali e i vincoli approvati.

Quando pertinente, devono essere controllati:

- validazione degli input;
- condizioni necessarie per procedere;
- coerenza delle relazioni tra entità;
- gestione degli stati dei record;
- rispetto delle regole di modifica;
- rispetto delle regole di annullamento;
- comportamento in condizioni non ammesse.

Le regole applicative devono essere verificate sia attraverso i risultati mostrati dall'interfaccia sia, quando necessario, attraverso lo stato effettivo dei dati.

## 8.10 Verifica degli errori applicativi

I test devono considerare anche le condizioni di errore che possono verificarsi durante l'utilizzo dell'applicazione.

Quando pertinente, possono comprendere:

- dati non validi;
- campi obbligatori mancanti;
- operazioni non autorizzate;
- dati non più disponibili;
- risposta inattesa di un servizio;
- errore restituito da una RPC;
- interruzione della comunicazione;
- mancato completamento di una scrittura.

Il comportamento atteso deve essere definito per ciascun caso pertinente.

L'applicazione deve evitare di rappresentare come riuscita un'operazione non completata.

Devono inoltre essere verificati, quando previsti, i messaggi mostrati all'utente e le possibilità di recupero dall'errore.

## 8.11 Verifica dello stato dell'interfaccia

Le verifiche devono considerare la coerenza dello stato dell'interfaccia durante e dopo le operazioni.

Quando pertinente, devono essere controllati:

- indicatori di caricamento;
- disponibilità dei comandi;
- prevenzione delle conferme multiple indebite;
- aggiornamento degli elenchi;
- mantenimento della selezione;
- visualizzazione delle conferme;
- visualizzazione degli errori;
- comportamento dopo l'annullamento;
- corretto stato dopo un nuovo caricamento.

Il risultato visualizzato deve essere coerente con l'esito effettivo dell'operazione eseguita.

## 8.12 Verifica della persistenza

Quando un'operazione prevede la modifica permanente dei dati, deve essere verificata la persistenza secondo il contratto applicativo.

I controlli possono comprendere:

- presenza del record inserito;
- aggiornamento dei valori modificati;
- mantenimento dei dati non coinvolti;
- coerenza dopo il ricaricamento;
- corretta associazione al contesto;
- assenza di duplicazioni non consentite.

La verifica può richiedere la consultazione del database, purché effettuata con modalità compatibili con la sicurezza e la protezione dei dati.

I controlli strutturali e transazionali del database sono disciplinati nel Capitolo 7.

## 8.13 Test su browser e dispositivi

Quando il collaudo prevede più ambienti di utilizzo, devono essere verificate le funzionalità pertinenti su ciascun ambiente selezionato.

I controlli possono riguardare:

- corretta apertura dell'applicazione;
- navigazione;
- visualizzazione delle schermate;
- utilizzo dei comandi;
- inserimento e modifica dei dati;
- comportamento degli elementi dell'interfaccia;
- visualizzazione dei messaggi;
- gestione degli errori.

Per ogni verifica deve essere identificato l'ambiente effettivamente utilizzato.

Il superamento di un test su un determinato browser o dispositivo non equivale al superamento su tutti gli ambienti possibili.

## 8.14 Test di regressione funzionale

Dopo modifiche che possono influenzare funzionalità già operative, devono essere individuati i test di regressione pertinenti.

La selezione deve considerare:

- componenti modificati;
- dipendenze applicative;
- contratti interessati;
- flussi che utilizzano gli stessi dati;
- precedenti anomalie correlate;
- rischi introdotti dalla modifica.

I test di regressione devono verificare che le funzionalità precedentemente corrette non abbiano subito alterazioni indesiderate.

Non è necessario ripetere indiscriminatamente ogni test esistente quando la modifica non lo richiede, salvo diverse esigenze di collaudo complessivo.

## 8.15 Interpretazione dei risultati

L'esito dei test funzionali e di integrazione deve essere determinato confrontando il comportamento osservato con quello atteso.

Devono essere considerati, quando pertinenti:

- correttezza del percorso eseguito;
- risultato mostrato all'utente;
- risposta dei componenti coinvolti;
- effettiva persistenza dei dati;
- rispetto delle regole applicative;
- gestione delle condizioni di errore;
- assenza di effetti collaterali indebiti.

Gli esiti devono essere classificati secondo le categorie definite nel paragrafo 3.10.

Un test non eseguito non può essere considerato superato.

L'assenza di errori visibili non costituisce da sola prova di correttezza funzionale.

## 8.16 Registrazione delle evidenze

Le verifiche funzionali e di integrazione devono essere documentate secondo le modalità previste dal Capitolo 12.

Quando pertinente, devono essere registrati:

- funzionalità o flusso verificato;
- ambiente utilizzato;
- versione applicativa;
- condizioni iniziali;
- operazioni eseguite;
- risultato atteso;
- risultato osservato;
- esito del test;
- eventuali anomalie;
- eventuali operazioni di ripristino.

Le evidenze devono consentire di ricostruire il comportamento verificato senza introdurre dati riservati o informazioni non necessarie.

Le anomalie devono essere gestite secondo quanto previsto dal Capitolo 11.

# 9. Test di sicurezza e autorizzazione

I test di sicurezza e autorizzazione di **Orto Smart** hanno lo scopo di verificare che l'accesso ai dati e l'esecuzione delle operazioni rispettino i vincoli di sicurezza approvati.

Le verifiche devono considerare sia le operazioni consentite sia i tentativi che devono essere rifiutati.

Il collaudo deve distinguere l'autenticazione dell'utente, l'appartenenza al profilo applicativo e l'autorizzazione a eseguire una specifica operazione.

La presenza di un controllo nell'interfaccia non costituisce, da sola, una garanzia di sicurezza del sistema.

I controlli devono essere verificati nei livelli applicativi e nel database effettivamente responsabili dell'applicazione delle regole.

## 9.1 Ambito delle verifiche di sicurezza

I test di sicurezza possono riguardare, quando pertinenti:

- autenticazione dell'utente;
- validità della sessione;
- identificazione del profilo applicativo;
- appartenenza al profilo;
- autorizzazioni di lettura;
- autorizzazioni di scrittura;
- politiche Row Level Security (RLS);
- privilegi sugli oggetti del database;
- esecuzione delle funzioni RPC;
- controllo dei lock applicativi;
- gestione delle richieste concorrenti;
- separazione tra identità e ruoli;
- protezione delle informazioni riservate;
- comportamento in caso di accesso negato.

I controlli devono essere selezionati in relazione alle funzionalità implementate e ai contratti di sicurezza interessati.

Non devono essere considerate superate verifiche non effettivamente eseguite.

## 9.2 Identificazione dell'ambiente di test

Prima di eseguire test di sicurezza deve essere identificato l'ambiente interessato.

Devono essere distinti almeno:

- ambiente PostgreSQL e Supabase locale;
- progetto Supabase remoto;
- applicazione Flutter collegata
  all'ambiente oggetto di verifica.

Quando pertinente, devono essere accertati:

- identità autenticata;
- profilo applicativo;
- ruolo database utilizzato;
- sessione applicativa;
- client applicativo;
- eventuale lock attivo;
- oggetti e funzioni coinvolti.

L'esecuzione di test con privilegi elevati non deve essere confusa con il comportamento di un normale client applicativo autenticato.

I risultati devono indicare le condizioni effettivamente utilizzate.

## 9.3 Test di autenticazione

I test di autenticazione devono verificare che le funzionalità protette siano accessibili soltanto nelle condizioni previste.

Quando pertinente, devono essere controllati:

- accesso con sessione valida;
- comportamento senza autenticazione;
- comportamento con sessione non valida;
- gestione della scadenza della sessione;
- aggiornamento dello stato applicativo;
- rifiuto delle operazioni non consentite;
- assenza di accessi indebiti ai dati.

Il risultato atteso deve essere definito in relazione al contratto della funzionalità interessata.

Una schermata non accessibile non dimostra automaticamente che il database rifiuti le medesime operazioni.

## 9.4 Test dell'identità applicativa

Orto Smart distingue l'identità di autenticazione dalle informazioni necessarie a identificare il contesto applicativo.

I test devono verificare, quando pertinente:

- corretta identificazione dell'utente;
- corretta associazione al profilo;
- utilizzo del profilo previsto;
- gestione dei riferimenti non validi;
- rifiuto delle associazioni non autorizzate;
- coerenza tra identità e operazione richiesta.

Le verifiche devono considerare i controlli realmente implementati.

Non devono essere dedotte autorizzazioni dalla sola presenza di identificativi nei parametri di una richiesta.

## 9.5 Test delle autorizzazioni di lettura

Le verifiche delle operazioni di lettura devono accertare che i dati siano accessibili esclusivamente nelle condizioni previste.

Quando pertinente, devono essere testati:

- lettura autorizzata;
- lettura senza autenticazione;
- lettura con profilo non autorizzato;
- lettura di record inesistenti;
- consultazione di dati collegati;
- accesso tramite query applicative;
- accesso tramite funzioni previste.

Il comportamento osservato deve essere confrontato con il risultato atteso.

L'assenza di record restituiti deve essere interpretata correttamente, distinguendo quando possibile l'assenza di dati dal rifiuto dell'accesso.

## 9.6 Test delle autorizzazioni di scrittura

I test delle operazioni di scrittura devono verificare che inserimenti, modifiche ed eventuali eliminazioni siano consentiti soltanto nelle condizioni previste.

Quando pertinente, devono essere controllati:

- autorizzazione dell'utente;
- appartenenza al profilo;
- validità del contesto applicativo;
- presenza delle condizioni di scrittura;
- utilizzo delle funzioni previste;
- rifiuto delle richieste non autorizzate;
- assenza di modifiche dopo il rifiuto.

Le verifiche devono considerare sia il risultato restituito sia lo stato finale del database.

Un'operazione rifiutata non deve produrre modifiche indebite.

## 9.7 Test delle politiche RLS

Le politiche Row Level Security devono essere verificate rispetto ai comportamenti approvati per le tabelle interessate.

Quando pertinente, i controlli devono comprendere:

- presenza e abilitazione delle RLS;
- politiche effettivamente applicabili;
- accessi consentiti;
- accessi negati;
- differenze tra ruoli;
- comportamento delle operazioni dirette;
- coerenza con le funzioni RPC autorizzate.

Le verifiche devono utilizzare ruoli e identità rappresentativi del caso sottoposto a test.

Un risultato ottenuto mediante un ruolo che aggira le RLS non dimostra il corretto funzionamento delle politiche per i client ordinari.

La verifica deve distinguere la configurazione dichiarata dal comportamento effettivo.

## 9.8 Test dei privilegi database

Le verifiche devono considerare i privilegi concessi agli oggetti del database.

Quando pertinente, possono riguardare:

- privilegi sugli schemi;
- privilegi sulle tabelle;
- privilegi sulle sequenze;
- permessi di esecuzione delle funzioni;
- accesso dei ruoli applicativi;
- assenza di concessioni non previste.

Deve essere verificata la coerenza tra i privilegi effettivi e i contratti di accesso approvati.

La presenza di una policy RLS non sostituisce la necessità di verificare i privilegi SQL.

Analogamente, un privilegio SQL non dimostra che una specifica operazione sia consentita dalle RLS.

## 9.9 Test delle funzioni RPC protette

Le funzioni RPC che eseguono operazioni protette devono essere verificate rispetto alle condizioni di accesso e autorizzazione previste.

Quando pertinente, devono essere controllati:

- permesso di invocazione;
- identità dell'utente chiamante;
- validità dei parametri;
- appartenenza al profilo;
- condizioni necessarie alla scrittura;
- risultato delle richieste autorizzate;
- rifiuto delle richieste non autorizzate;
- assenza di effetti collaterali indebiti.

I test devono considerare anche i casi nei quali il chiamante fornisce identificativi validi ma non possiede l'autorizzazione necessaria all'operazione.

La correttezza della firma RPC non costituisce prova sufficiente della sicurezza della funzione.

## 9.10 Test delle funzioni SECURITY DEFINER

Le funzioni PostgreSQL definite con SECURITY DEFINER richiedono verifiche specifiche in relazione ai privilegi con i quali vengono eseguite.

Quando pertinente, devono essere verificati:

- identità e privilegi del proprietario;
- permessi di esecuzione concessi;
- controlli di autorizzazione interni;
- gestione dei parametri ricevuti;
- riferimenti agli oggetti SQL;
- configurazione del search_path;
- rifiuto delle operazioni non consentite;
- assenza di escalation dei privilegi.

I test devono accertare che l'esecuzione con i privilegi del proprietario non consenta di aggirare i controlli applicativi previsti dal contratto.

La presenza della clausola SECURITY DEFINER non costituisce, da sola, una vulnerabilità né una garanzia di sicurezza.

## 9.11 Test dell'autorità di scrittura

Le verifiche dell'autorità di scrittura devono accertare che le modifiche siano consentite soltanto al soggetto autorizzato nelle condizioni previste.

Per i meccanismi implementati in Orto Smart, i test possono riguardare:

- identificazione del client;
- identificazione della sessione;
- associazione al profilo;
- possesso dell'autorità di scrittura;
- validità del token di lock;
- rifiuto delle scritture concorrenti;
- comportamento in assenza di lock;
- comportamento con lock non valido.

I test devono rispettare i contratti effettivamente approvati per le operazioni interessate.

Non devono essere presunte autorizzazioni derivanti dalla sola disponibilità dell'interfaccia di modifica.

## 9.12 Test del ciclo di vita dei lock

Quando una funzionalità utilizza i lock applicativi di Orto Smart, devono essere verificate le operazioni pertinenti al relativo ciclo di vita.

Possono comprendere:

- acquisizione del lock;
- mantenimento tramite heartbeat;
- rilascio del lock;
- comportamento dopo la scadenza;
- tentativo di acquisizione concorrente;
- richiesta di takeover;
- annullamento della richiesta;
- rifiuto della richiesta;
- eventuale trasferimento dell'autorità.

Ogni operazione deve essere verificata rispetto alle condizioni e ai risultati previsti dal contratto implementato.

L'esistenza di una funzione non dimostra che tutte le transizioni del ciclo di vita siano state collaudate.

## 9.13 Test della concorrenza e dei conflitti

Le verifiche di concorrenza devono accertare che richieste provenienti da client o sessioni distinti rispettino le regole di accesso previste.

Quando pertinente, devono essere testati:

- tentativi simultanei di scrittura;
- operazioni con lock appartenente
  a un'altra sessione;
- richieste con token non valido;
- utilizzo di versioni obsolete;
- comportamento dopo il rilascio del lock;
- gestione delle richieste concorrenti;
- conservazione dell'integrità dei dati.

Il risultato deve essere verificato anche nello stato finale del database.

I test devono evitare di alterare dati operativi o provocare conflitti in ambienti non isolati.

## 9.14 Test delle condizioni di accesso negato

I test negativi di sicurezza devono verificare il rifiuto delle operazioni non consentite.

Quando pertinente, possono comprendere:

- utente non autenticato;
- sessione non valida;
- profilo non autorizzato;
- identificativi non coerenti;
- lock assente;
- lock scaduto;
- token errato;
- richiesta proveniente da altro client;
- versione del record non valida;
- tentativo di invocazione non autorizzata.

Per ciascun caso deve essere definito il risultato atteso.

Il test deve accertare sia il rifiuto dell'operazione sia l'assenza di modifiche o divulgazioni non consentite.

## 9.15 Protezione dei segreti e dei dati riservati

Le verifiche devono considerare la protezione delle informazioni che non devono essere esposte all'utente o nei materiali di collaudo.

Quando pertinente, devono essere controllati:

- credenziali;
- token di autenticazione;
- token di lock;
- chiavi di accesso;
- configurazioni riservate;
- messaggi diagnostici;
- log applicativi;
- evidenze dei test.

Le informazioni riservate non devono essere copiate nei documenti di collaudo, nei messaggi di verifica o negli screenshot condivisi.

Quando un'evidenza contiene informazioni non necessarie, deve essere opportunamente oscurata prima della conservazione.

La verifica deve distinguere le informazioni tecniche necessarie alla diagnosi dai segreti che non devono essere divulgati.

## 9.16 Sicurezza dell'ambiente di collaudo

I test di sicurezza devono essere eseguiti in condizioni controllate.

Prima delle verifiche devono essere considerati:

- ambiente di destinazione;
- identità utilizzate;
- privilegi disponibili;
- dati presenti;
- possibili effetti delle operazioni;
- modalità di isolamento;
- possibilità di ripristino;
- autorizzazioni necessarie.

I test che richiedono alterazioni dei privilegi, disabilitazione delle RLS, modifica delle policy o interventi potenzialmente distruttivi non devono essere eseguiti senza una valutazione preventiva e un'autorizzazione esplicita.

I dati operativi devono essere preservati secondo le regole definite nel Capitolo 7.

## 9.17 Interpretazione dei risultati

L'esito dei test di sicurezza deve essere determinato confrontando il comportamento osservato con il risultato atteso.

Quando pertinente, devono essere valutati:

- identità effettivamente utilizzata;
- privilegi disponibili;
- operazione richiesta;
- autorizzazione prevista;
- risposta ottenuta;
- modifiche eventualmente applicate;
- dati eventualmente restituiti;
- assenza di effetti non autorizzati.

Gli esiti devono essere classificati secondo le categorie definite nel paragrafo 3.10.

Il rifiuto di una richiesta può costituire un test superato quando rappresenta il comportamento atteso.

Un test non eseguito non può essere considerato superato.

L'assenza di errori visibili non costituisce prova sufficiente della sicurezza dell'operazione.

## 9.18 Registrazione delle evidenze

I test di sicurezza devono essere documentati secondo le modalità previste dal Capitolo 12.

Quando pertinente, le evidenze devono consentire di identificare:

- controllo di sicurezza verificato;
- ambiente utilizzato;
- versione del codice o del database;
- ruolo o categoria di identità impiegata;
- condizioni iniziali;
- operazione eseguita;
- risultato atteso;
- risultato osservato;
- esito del test;
- eventuali anomalie;
- eventuale ripristino.

Non devono essere registrati token, password, chiavi riservate o altre informazioni segrete in forma utilizzabile.

Le anomalie individuate devono essere gestite secondo quanto previsto dal Capitolo 11.

Il superamento dei test deve essere riferito alle verifiche realmente eseguite e non deve essere interpretato come garanzia assoluta di assenza di vulnerabilità.

# 10. Criteri di accettazione

I criteri di accettazione di **Orto Smart** definiscono le condizioni necessarie per considerare superati i test e per valutare l'esito del collaudo delle funzionalità applicative.

L'accettazione deve basarsi su risultati effettivamente verificati, confrontati con requisiti, contratti e comportamenti attesi.

La sola esecuzione di un test non costituisce prova del suo superamento.

Analogamente, l'assenza di errori visibili non dimostra automaticamente la correttezza della funzionalità verificata.

I criteri devono essere applicati in relazione all'ambito del collaudo e allo stato effettivo di implementazione del progetto.

## 10.1 Principi generali di accettazione

L'accettazione deve rispettare i seguenti principi:

- riferimento a requisiti e contratti approvati;
- identificazione dell'oggetto verificato;
- definizione del risultato atteso;
- osservazione del risultato effettivo;
- confronto tra risultato atteso e osservato;
- registrazione delle evidenze pertinenti;
- valutazione delle anomalie;
- tracciabilità della decisione finale.

Un risultato non verificabile non deve essere considerato automaticamente conforme.

I criteri di accettazione non devono essere modificati retroattivamente per giustificare un risultato inatteso.

Eventuali modifiche ai criteri devono essere motivate e approvate prima della loro applicazione.

## 10.2 Condizioni per il superamento di un test

Un singolo test può essere considerato superato quando risultano soddisfatte le condizioni applicabili al caso.

In particolare:

- il test è stato effettivamente eseguito;
- l'ambiente utilizzato è identificato;
- le condizioni iniziali sono coerenti
  con quelle previste;
- la procedura è stata eseguita
  nelle modalità stabilite;
- il risultato osservato corrisponde
  al risultato atteso;
- non sono emersi effetti collaterali
  non consentiti;
- le evidenze necessarie sono disponibili;
- l'eventuale ripristino richiesto
  è stato verificato.

Il superamento deve essere riferito allo specifico caso di test.

Non può essere esteso automaticamente ad altri ambienti, condizioni o funzionalità non verificate.

## 10.3 Condizioni di mancato superamento

Un test non deve essere considerato superato quando il risultato osservato non corrisponde a quello atteso.

Possono costituire condizioni di mancato superamento:

- comportamento funzionale non corretto;
- violazione di un vincolo;
- modifica di dati non prevista;
- mancata persistenza di un'operazione;
- autorizzazione concessa indebitamente;
- operazione legittima rifiutata
  in contrasto con il contratto;
- risposta non coerente di una RPC;
- perdita o alterazione di dati;
- errore applicativo non previsto;
- effetto collaterale non consentito.

Le anomalie devono essere registrate e gestite secondo il Capitolo 11.

Un risultato negativo non deve essere reinterpretato come positivo senza una nuova verifica o una motivata revisione del comportamento atteso.

## 10.4 Test non eseguiti e non applicabili

Un test non eseguito non può essere classificato come superato.

La mancata esecuzione deve essere distinta dal mancato superamento.

Quando una verifica non è applicabile all'oggetto o all'ambiente considerato, deve essere registrata la relativa motivazione.

La classificazione degli esiti deve rispettare le categorie definite nel paragrafo 3.10.

Non devono essere introdotte classificazioni incompatibili con quelle già stabilite.

La presenza di test non eseguiti deve essere valutata rispetto alla completezza del collaudo previsto.

## 10.5 Accettazione dei test automatici

I test automatici possono essere considerati superati quando l'esecuzione si conclude con il risultato atteso.

Quando pertinente, devono essere verificati:

- corretta individuazione dei test;
- completamento dell'esecuzione;
- assenza di fallimenti;
- assenza di errori non previsti;
- coerenza dell'ambiente;
- correttezza delle condizioni di test;
- disponibilità dell'output di esecuzione.

Un comando terminato senza segnalazioni evidenti non deve essere considerato sufficiente quando non è possibile stabilire se i test previsti siano stati eseguiti.

I criteri specifici per i test Dart e Flutter sono descritti nel Capitolo 6.

## 10.6 Accettazione dei test database

I test del database possono essere considerati superati quando le verifiche previste confermano il comportamento atteso.

Quando pertinente, devono essere accertati:

- correttezza della struttura;
- rispetto dei vincoli;
- risultato delle funzioni RPC;
- integrità delle transazioni;
- correttezza dello stato finale;
- assenza di modifiche indebite;
- rispetto delle autorizzazioni;
- ripristino delle condizioni richieste.

Il superamento di una verifica strutturale non dimostra automaticamente la correttezza delle operazioni applicative che utilizzano la struttura.

I criteri specifici dei test database sono descritti nel Capitolo 7.

## 10.7 Accettazione dei test funzionali

I test funzionali possono essere considerati superati quando il comportamento dell'applicazione corrisponde a quello previsto.

Quando pertinente, devono essere verificati:

- correttezza della navigazione;
- correttezza dei dati visualizzati;
- validazione degli input;
- completamento delle operazioni;
- aggiornamento dell'interfaccia;
- persistenza dei dati;
- gestione degli errori;
- assenza di effetti collaterali indebiti.

Un messaggio di conferma non costituisce prova sufficiente del completamento dell'operazione quando è prevista una modifica persistente dei dati.

I criteri specifici sono descritti nel Capitolo 8.

## 10.8 Accettazione dei test di integrazione

I test di integrazione possono essere considerati superati quando i componenti coinvolti interagiscono secondo i contratti previsti.

Quando pertinente, devono essere verificati:

- corretta trasmissione delle richieste;
- correttezza dei parametri;
- compatibilità dei contratti;
- interpretazione delle risposte;
- propagazione degli errori;
- aggiornamento dello stato applicativo;
- coerenza dei dati persistiti.

Il superamento dei test dei singoli componenti non sostituisce la verifica delle loro interazioni.

I criteri specifici sono descritti nel Capitolo 8.

## 10.9 Accettazione dei test di sicurezza

I test di sicurezza possono essere considerati superati quando le operazioni consentite funzionano nelle condizioni previste e quelle non autorizzate vengono correttamente rifiutate.

Quando pertinente, devono essere verificati:

- autenticazione;
- identità applicativa;
- appartenenza al profilo;
- autorizzazioni di lettura;
- autorizzazioni di scrittura;
- applicazione delle RLS;
- privilegi database;
- controlli delle funzioni RPC;
- autorità di scrittura;
- gestione dei lock;
- assenza di accessi indebiti;
- assenza di modifiche non autorizzate.

Il rifiuto di una richiesta può costituire un risultato positivo quando rappresenta il comportamento atteso.

I criteri specifici sono descritti nel Capitolo 9.

## 10.10 Accettazione dei test negativi

Un test negativo può essere considerato superato quando il sistema rifiuta correttamente un'operazione non consentita o gestisce una condizione non valida secondo il contratto previsto.

La verifica deve considerare:

- condizione iniziale;
- richiesta effettuata;
- motivo atteso del rifiuto;
- risultato effettivamente restituito;
- assenza di modifiche indebite;
- mantenimento dell'integrità dei dati.

Non è sufficiente osservare un errore generico quando il contratto richiede un comportamento specifico.

Il test deve dimostrare che il rifiuto è coerente con la regola verificata.

## 10.11 Accettazione delle regressioni

Una verifica di regressione può essere considerata superata quando conferma che le funzionalità interessate dalla modifica mantengono i comportamenti previsti.

La selezione dei test deve considerare:

- modifiche introdotte;
- dipendenze coinvolte;
- rischi identificati;
- precedenti anomalie;
- contratti interessati;
- flussi applicativi correlati.

Un test di regressione fallito deve essere valutato prima di accettare la modifica.

Il superamento di una selezione di test di regressione deve essere riferito all'ambito effettivamente verificato.

## 10.12 Valutazione delle anomalie

La presenza di anomalie deve essere valutata prima dell'accettazione di una funzionalità o di un collaudo.

Per ogni anomalia pertinente devono essere considerati:

- comportamento osservato;
- risultato atteso;
- riproducibilità;
- impatto funzionale;
- impatto sui dati;
- impatto sulla sicurezza;
- eventuali dipendenze;
- stato della correzione;
- risultato delle verifiche successive.

Le anomalie che compromettono integrità dei dati, autorizzazioni o comportamenti essenziali non devono essere ignorate ai fini dell'accettazione.

La gestione delle anomalie è disciplinata nel Capitolo 11.

## 10.13 Accettazione con limitazioni

Quando un collaudo non copre tutte le condizioni possibili, le limitazioni devono essere dichiarate esplicitamente.

Possono riguardare:

- ambienti non verificati;
- dispositivi non verificati;
- funzionalità non implementate;
- test non eseguiti;
- condizioni non riproducibili;
- dipendenze non disponibili;
- anomalie ancora aperte.

L'eventuale accettazione con limitazioni deve essere motivata e autorizzata dal responsabile della decisione.

Non può essere utilizzata per considerare superati test che non lo sono.

Non deve inoltre comportare l'accettazione implicita di rischi non valutati per la sicurezza o l'integrità dei dati.

## 10.14 Accettazione di una funzionalità

Una funzionalità può essere considerata accettata quando risultano soddisfatti i criteri applicabili al relativo ambito di collaudo.

La valutazione deve considerare:

- requisiti e contratti di riferimento;
- stato effettivo dell'implementazione;
- test previsti;
- test effettivamente eseguiti;
- risultati ottenuti;
- anomalie riscontrate;
- regressioni pertinenti;
- eventuali limitazioni dichiarate;
- evidenze disponibili.

L'accettazione deve essere esplicitamente registrata.

Il superamento di singoli test non determina automaticamente l'accettazione complessiva della funzionalità.

## 10.15 Accettazione di una modifica

Una modifica applicativa o del database può essere considerata accettabile quando sono state verificate le condizioni pertinenti al suo contenuto e ai suoi rischi.

Quando necessario, devono essere valutati:

- correttezza della modifica;
- compatibilità con i contratti esistenti;
- integrità dei dati;
- rispetto delle autorizzazioni;
- test automatici;
- test funzionali;
- test di integrazione;
- test di regressione;
- eventuali anomalie residue.

L'accettazione della modifica deve essere distinta dalla sua registrazione nel repository.

Un commit Git non costituisce, da solo, attestazione di collaudo superato.

## 10.16 Accettazione del collaudo complessivo

Il collaudo complessivo può essere considerato concluso quando l'ambito previsto è stato verificato e i relativi risultati sono stati valutati.

La decisione deve considerare:

- funzionalità incluse nel collaudo;
- ambienti interessati;
- test previsti;
- test eseguiti;
- risultati ottenuti;
- anomalie ancora aperte;
- verifiche di regressione;
- eventuali limitazioni;
- evidenze disponibili;
- autorizzazione alla conclusione.

L'accettazione complessiva non deve essere dedotta dalla sola somma dei test superati.

Le modalità del collaudo complessivo sono approfondite nel Capitolo 13.

## 10.17 Responsabilità della decisione

La decisione di accettazione deve essere riconducibile al soggetto autorizzato a esprimerla.

La registrazione deve distinguere:

- esecuzione tecnica dei test;
- raccolta delle evidenze;
- valutazione dei risultati;
- decisione di accettazione.

L'esecutore di un test non deve essere considerato automaticamente responsabile dell'accettazione finale, salvo che tale responsabilità gli sia stata attribuita.

La decisione deve essere coerente con l'organizzazione e con le responsabilità effettivamente stabilite per Orto Smart.

## 10.18 Registrazione dell'accettazione

Ogni decisione formale di accettazione deve essere documentata in modo tracciabile.

Quando pertinente, devono essere registrati:

- oggetto dell'accettazione;
- versione del codice o del database;
- ambiente interessato;
- ambito dei test;
- risultati delle verifiche;
- anomalie e limitazioni;
- evidenze di riferimento;
- decisione assunta;
- soggetto responsabile;
- data della decisione.

Le registrazioni devono consentire di distinguere chiaramente le verifiche superate, quelle non superate e quelle non eseguite.

Le modalità generali di registrazione delle evidenze sono definite nel Capitolo 12.

## 10.19 Riesame dell'accettazione

Una decisione di accettazione può richiedere un riesame quando intervengono modifiche che incidono sulle condizioni precedentemente verificate.

Possono costituire motivi di riesame:

- modifiche ai requisiti;
- modifiche ai contratti;
- aggiornamenti applicativi;
- migration del database;
- correzione di anomalie;
- nuove anomalie rilevate;
- modifiche alle autorizzazioni;
- variazioni dell'ambiente;
- nuove dipendenze tecniche.

Il riesame deve individuare quali verifiche devono essere ripetute.

L'accettazione precedente rimane riferita alle condizioni nelle quali era stata espressa.

Non costituisce automaticamente una garanzia di conformità per versioni successive.

# 11. Gestione delle anomalie e regressioni

La gestione delle anomalie e delle regressioni di **Orto Smart** ha lo scopo di assicurare che i comportamenti inattesi rilevati durante lo sviluppo e il collaudo siano identificati, documentati, valutati e verificati dopo la correzione.

Le anomalie devono essere considerate in relazione ai requisiti, ai contratti approvati e ai risultati attesi.

La gestione deve distinguere la rilevazione del problema, la valutazione del suo impatto, la correzione tecnica e la verifica dell'effettivo ripristino del comportamento.

La sola applicazione di una modifica non dimostra che l'anomalia sia risolta.

## 11.1 Definizione di anomalia

Ai fini del presente documento, un'anomalia è un comportamento osservato che non corrisponde al comportamento atteso oppure una condizione tecnica che compromette una verifica prevista.

Le anomalie possono riguardare:

- interfaccia e navigazione;
- validazione degli input;
- logica applicativa;
- integrazione Flutter e Supabase;
- struttura e vincoli del database;
- funzioni SQL e RPC;
- persistenza dei dati;
- autenticazione e autorizzazioni;
- gestione dei lock;
- concorrenza e transazioni;
- esecuzione dei test automatici;
- configurazione dell'ambiente.

Una segnalazione deve essere valutata prima di essere classificata come difetto effettivo.

## 11.2 Rilevazione delle anomalie

Le anomalie possono emergere durante test automatici, verifiche manuali, test funzionali, test database o controlli di sicurezza.

Possono inoltre essere rilevate durante l'utilizzo dell'applicazione o attraverso l'analisi dei risultati tecnici disponibili.

La rilevazione deve registrare, quando possibile:

- operazione in corso;
- condizioni iniziali;
- comportamento atteso;
- comportamento osservato;
- ambiente utilizzato;
- versione interessata;
- messaggi diagnostici pertinenti.

La rilevazione non equivale automaticamente alla conferma della causa del problema.

## 11.3 Registrazione delle anomalie

Ogni anomalia rilevante deve essere registrata in modo sufficientemente dettagliato da consentirne la valutazione e l'eventuale riproduzione.

Quando pertinente, la registrazione deve comprendere:

- identificativo della segnalazione;
- data della rilevazione;
- componente interessato;
- descrizione del problema;
- risultato atteso;
- risultato osservato;
- procedura di riproduzione;
- ambiente e versione;
- impatto conosciuto;
- stato della gestione;
- evidenze disponibili.

Gli strumenti di registrazione devono essere quelli effettivamente adottati per il progetto.

Non deve essere presunta l'esistenza di un sistema di tracciamento non ancora introdotto.

## 11.4 Riproducibilità dell'anomalia

Quando possibile, un'anomalia deve essere riprodotta in condizioni controllate.

La verifica deve identificare:

- prerequisiti;
- dati necessari;
- sequenza delle operazioni;
- ambiente;
- risultato atteso;
- risultato osservato.

Se l'anomalia non è riproducibile, tale condizione deve essere registrata.

La mancata riproduzione non dimostra automaticamente che il problema sia inesistente o definitivamente risolto.

Devono essere conservate le evidenze disponibili e le eventuali condizioni che possono aver influito sul comportamento osservato.

## 11.5 Classificazione delle anomalie

Le anomalie devono essere classificate in base alla natura del problema e al suo impatto effettivo.

Quando pertinente, possono essere distinte anomalie:

- funzionali;
- applicative;
- di integrazione;
- relative al database;
- di integrità dei dati;
- di autorizzazione;
- di sicurezza;
- di concorrenza;
- di configurazione;
- relative ai test.

La classificazione deve facilitare l'analisi e la gestione del problema.

Non deve sostituire la valutazione della gravità o delle conseguenze operative.

## 11.6 Valutazione della gravità

La gravità di un'anomalia deve essere valutata considerando le conseguenze del comportamento osservato.

Devono essere considerati, quando pertinenti:

- perdita o alterazione dei dati;
- accesso non autorizzato;
- violazione dei contratti di sicurezza;
- indisponibilità di funzioni essenziali;
- blocco di un flusso operativo;
- incoerenza dello stato applicativo;
- presenza di soluzioni temporanee;
- estensione del problema;
- possibilità di riproduzione.

Non devono essere attribuiti livelli di gravità formali senza una classificazione approvata per il progetto.

La valutazione deve comunque consentire di distinguere i problemi che impediscono l'accettazione da quelli che richiedono ulteriori approfondimenti.

## 11.7 Priorità di intervento

La priorità di intervento deve essere determinata in relazione alla gravità, all'impatto e alle dipendenze dell'anomalia.

Possono influire sulla priorità:

- rischio per l'integrità dei dati;
- rischio per la sicurezza;
- blocco delle attività di sviluppo;
- impossibilità di proseguire i test;
- numero di funzionalità coinvolte;
- probabilità di ricorrenza;
- disponibilità di una correzione;
- rischio introdotto dalla modifica.

La priorità non deve essere confusa con la gravità dell'anomalia.

Un problema apparentemente limitato può richiedere un intervento anticipato se impedisce verifiche fondamentali.

## 11.8 Analisi della causa

Prima di correggere un'anomalia deve essere effettuata, per quanto possibile, un'analisi della causa.

L'analisi può interessare:

- codice Flutter o Dart;
- stato dell'interfaccia;
- richieste al database;
- parametri delle RPC;
- funzioni SQL;
- vincoli e trigger;
- politiche RLS;
- autorizzazioni;
- gestione dei lock;
- dati e condizioni iniziali;
- configurazione dell'ambiente.

Le ipotesi devono essere distinte dalle cause effettivamente confermate.

Una modifica basata su una causa presunta deve essere verificata con particolare attenzione.

## 11.9 Definizione della correzione

La correzione deve essere progettata in relazione alla causa individuata e ai contratti da rispettare.

Prima dell'intervento devono essere considerati, quando pertinenti:

- componente da modificare;
- comportamento da ripristinare;
- dipendenze coinvolte;
- effetti sui dati esistenti;
- effetti sulle autorizzazioni;
- compatibilità con le RPC;
- necessità di una migration;
- test da ripetere;
- possibilità di ripristino.

La correzione deve evitare modifiche non necessarie a componenti estranei al problema.

Eventuali variazioni dei contratti devono seguire il processo di valutazione e approvazione previsto.

## 11.10 Verifica della correzione

Dopo una correzione deve essere ripetuta la verifica che aveva evidenziato l'anomalia, quando riproducibile.

La verifica deve accertare:

- comportamento atteso ripristinato;
- assenza dell'anomalia osservata;
- correttezza dello stato finale;
- assenza di effetti collaterali indebiti;
- rispetto dei vincoli applicabili;
- rispetto delle autorizzazioni;
- coerenza dei dati persistiti.

La sola compilazione del progetto o l'assenza di errori di analisi statica non dimostra la risoluzione di un difetto funzionale.

L'esito della verifica deve essere registrato.

## 11.11 Definizione di regressione

Una regressione è un comportamento precedentemente conforme che risulta compromesso dopo una modifica.

Può derivare, ad esempio, da:

- aggiornamento del codice;
- modifica di una funzione SQL;
- introduzione di una migration;
- variazione dei vincoli;
- modifica delle autorizzazioni;
- aggiornamento delle dipendenze;
- cambiamento di configurazione;
- correzione di un'altra anomalia.

Una regressione deve essere trattata come un'anomalia e deve essere valutata in relazione al suo impatto.

## 11.12 Selezione dei test di regressione

Dopo una modifica devono essere individuate le verifiche necessarie per accertare che i comportamenti esistenti non siano stati compromessi.

La selezione deve considerare:

- file e componenti modificati;
- contratti coinvolti;
- funzioni dipendenti;
- flussi applicativi correlati;
- tabelle e RPC interessate;
- controlli di sicurezza;
- precedenti anomalie;
- rischi introdotti dalla modifica.

La selezione dei test deve essere proporzionata alla natura e all'impatto dell'intervento.

Non deve essere dichiarata una copertura completa quando è stata verificata soltanto una parte del sistema.

## 11.13 Regressioni applicative

Le regressioni applicative devono essere verificate nei flussi interessati dalla modifica.

Quando pertinente, devono essere controllati:

- navigazione;
- caricamento dei dati;
- inserimento dei record;
- modifica dei record;
- gestione delle conferme;
- aggiornamento dell'interfaccia;
- gestione degli errori;
- persistenza delle operazioni.

I controlli devono includere le interazioni tra componenti quando la modifica può influire sul comportamento complessivo.

Le modalità dei test funzionali e di integrazione sono descritte nel Capitolo 8.

## 11.14 Regressioni database e sicurezza

Le modifiche al database e ai meccanismi di autorizzazione richiedono verifiche coerenti con i rischi introdotti.

Quando pertinente, devono essere controllati:

- struttura e vincoli;
- esecuzione delle migration;
- comportamento delle RPC;
- atomicità delle operazioni;
- integrità dei dati;
- politiche RLS;
- privilegi SQL;
- funzioni SECURITY DEFINER;
- controlli dei lock;
- richieste concorrenti;
- accessi autorizzati e negati.

Una modifica che ripristina un'operazione autorizzata non deve introdurre accessi o scritture indebite.

I riferimenti per queste verifiche sono i Capitoli 7 e 9.

## 11.15 Anomalie bloccanti e accettazione

Le anomalie devono essere considerate nella valutazione dell'accettazione della funzionalità o del collaudo.

Particolare attenzione deve essere riservata ai problemi che compromettono:

- integrità dei dati;
- sicurezza e autorizzazioni;
- correttezza delle scritture;
- coerenza delle transazioni;
- disponibilità delle funzioni essenziali;
- rispetto dei contratti approvati.

Un'anomalia non risolta non deve essere ignorata per dichiarare superata una verifica fallita.

Le condizioni di accettazione e le eventuali limitazioni sono definite nel Capitolo 10.

## 11.16 Stato e chiusura delle anomalie

Lo stato di un'anomalia deve rappresentare la situazione effettiva della sua gestione.

La chiusura deve essere motivata e sostenuta da verifiche adeguate.

Quando pertinente, devono risultare:

- problema identificato;
- correzione applicata;
- verifica della correzione;
- regressioni pertinenti eseguite;
- risultato osservato;
- eventuali limitazioni residue;
- decisione di chiusura.

Un'anomalia non deve essere considerata risolta soltanto perché è stata modificata una porzione di codice.

Se il problema si ripresenta, deve essere riesaminato senza cancellare le evidenze della gestione precedente.

## 11.17 Tracciabilità delle modifiche

Le correzioni e le verifiche devono essere collegate, quando possibile, alle modifiche effettivamente effettuate.

Possono essere utilizzati i riferimenti disponibili a:

- file modificati;
- migration;
- test eseguiti;
- versioni del codice;
- commit Git;
- risultati di collaudo;
- documentazione tecnica;
- decisioni approvate.

La presenza di un commit non costituisce da sola prova di correzione verificata.

La tracciabilità deve permettere di ricostruire il rapporto tra anomalia, intervento e risultato della verifica.

## 11.18 Evidenze e riesame

Le evidenze delle anomalie e delle regressioni devono essere registrate secondo le modalità previste dal Capitolo 12.

Quando pertinente, devono comprendere:

- descrizione dell'anomalia;
- ambiente e versione;
- condizioni di riproduzione;
- risultato atteso;
- risultato osservato;
- analisi effettuata;
- correzione applicata;
- test ripetuti;
- risultati delle regressioni;
- stato conclusivo.

Le informazioni riservate devono essere protette secondo quanto previsto dal Capitolo 9.

La gestione delle anomalie deve essere riesaminata quando emergono nuove evidenze o modifiche che incidono sulla valutazione precedente.

L'obiettivo è conservare una documentazione verificabile del problema e della sua gestione, senza attribuire esiti positivi a controlli non eseguiti.

# 12. Registrazione dei risultati e delle evidenze

La registrazione dei risultati e delle evidenze di **Orto Smart** ha lo scopo di rendere verificabili e ricostruibili le attività di test e collaudo effettivamente eseguite.

Le registrazioni devono consentire di distinguere le verifiche previste, quelle eseguite e i risultati ottenuti.

Le evidenze devono sostenere le conclusioni riportate senza sostituire la valutazione tecnica del comportamento osservato.

La documentazione dei risultati deve essere proporzionata alla natura e alla rilevanza della verifica effettuata.

Non devono essere attribuiti esiti positivi a test non eseguiti o a risultati non sufficientemente verificati.

## 12.1 Finalità della registrazione

La registrazione dei risultati deve consentire di:

- identificare il test eseguito;
- ricostruire le condizioni iniziali;
- individuare l'ambiente utilizzato;
- conoscere il risultato atteso;
- conoscere il risultato osservato;
- verificare l'esito attribuito;
- identificare eventuali anomalie;
- collegare le evidenze disponibili;
- ricostruire la decisione conclusiva.

La registrazione deve permettere di distinguere i fatti osservati dalle interpretazioni e dalle decisioni successive.

## 12.2 Identificazione del test

Ogni registrazione deve identificare in modo sufficientemente chiaro la verifica alla quale si riferisce.

Quando pertinente, devono essere indicati:

- identificativo del test;
- denominazione;
- funzionalità o componente;
- obiettivo della verifica;
- requisito o contratto di riferimento;
- tipologia del test;
- procedura utilizzata;
- eventuali prerequisiti.

L'identificativo può essere quello già previsto dalla documentazione tecnica o dal sistema di test adottato.

Non deve essere presunta l'esistenza di una numerazione non ancora definita per il progetto.

## 12.3 Identificazione dell'ambiente

Le evidenze devono consentire di riconoscere l'ambiente nel quale è stata eseguita la verifica.

Quando pertinente, devono essere indicati:

- ambiente locale o remoto;
- sistema operativo;
- versione di Flutter e Dart;
- browser o dispositivo;
- ambiente PostgreSQL e Supabase;
- configurazione applicativa rilevante;
- eventuali servizi dipendenti;
- condizioni particolari del test.

Le informazioni devono essere sufficienti a interpretare il risultato.

Non devono essere riportati segreti o credenziali per documentare l'ambiente.

## 12.4 Identificazione della versione

I risultati devono essere riferiti alla versione effettivamente sottoposta a verifica.

Quando pertinente, possono essere indicati:

- branch Git;
- commit Git;
- stato del working tree;
- migration applicate;
- versione dello schema database;
- versione delle dipendenze;
- configurazione rilevante.

La presenza di modifiche non committate deve essere dichiarata quando può influire sulla ricostruzione del risultato.

Un riferimento a un commit non dimostra automaticamente che il test sia stato eseguito sul contenuto esatto di quel commit.

## 12.5 Registrazione delle condizioni iniziali

Le condizioni iniziali devono essere registrate quando sono necessarie per comprendere o riprodurre il comportamento osservato.

Possono comprendere:

- stato dell'applicazione;
- identità e profilo utilizzati;
- sessione applicativa;
- eventuale lock;
- dati preesistenti;
- configurazione rilevante;
- prerequisiti tecnici;
- stato delle dipendenze.

Devono essere evitati riferimenti ambigui a condizioni non documentate.

Quando una condizione iniziale non può essere ricostruita, la limitazione deve essere segnalata.

## 12.6 Registrazione della procedura eseguita

La registrazione deve descrivere le operazioni effettivamente eseguite quando tale informazione è necessaria per verificare il risultato.

Quando pertinente, devono essere indicati:

- comando utilizzato;
- funzione o RPC invocata;
- operazione applicativa;
- sequenza delle azioni;
- parametri rilevanti;
- eventuali variazioni rispetto
  alla procedura prevista.

Le procedure devono essere riportate in modo comprensibile e verificabile.

Non devono essere presentate come eseguite operazioni soltanto pianificate o suggerite.

## 12.7 Risultato atteso

Il risultato atteso deve essere identificato prima della valutazione dell'esito del test.

Deve derivare, quando applicabile, da requisiti, contratti, regole di business o comportamenti formalmente approvati.

Può riguardare:

- risposta dell'interfaccia;
- risultato di una funzione;
- modifica persistente dei dati;
- rifiuto di un'operazione;
- rispetto di un vincolo;
- mantenimento dello stato;
- assenza di effetti collaterali.

Il risultato atteso non deve essere ridefinito retroattivamente per far coincidere il test con il comportamento osservato.

## 12.8 Risultato osservato

Il risultato osservato deve descrivere ciò che è stato effettivamente rilevato durante la verifica.

Quando pertinente, può comprendere:

- output del comando;
- messaggio applicativo;
- risposta della RPC;
- comportamento dell'interfaccia;
- contenuto dei dati restituiti;
- stato finale del database;
- errore rilevato;
- eventuali effetti collaterali.

La descrizione deve distinguere l'osservazione diretta dalle ipotesi sulla causa.

Un risultato incompleto deve essere registrato come tale.

## 12.9 Registrazione dell'esito

L'esito del test deve essere determinato confrontando il risultato osservato con quello atteso.

La classificazione deve rispettare le categorie definite nel paragrafo 3.10.

La registrazione deve distinguere almeno le situazioni pertinenti di verifica superata, non superata, non eseguita o non applicabile, secondo la classificazione approvata.

Non devono essere introdotte nuove categorie incompatibili con quelle già definite.

Il significato dell'esito deve essere coerente con i criteri di accettazione del Capitolo 10.

## 12.10 Evidenze dei test automatici

Le evidenze dei test automatici devono consentire di verificare che i controlli previsti siano stati effettivamente eseguiti.

Quando pertinente, possono comprendere:

- comando di esecuzione;
- identificazione della suite;
- numero dei test eseguiti;
- risultati prodotti;
- eventuali fallimenti;
- messaggi diagnostici;
- codice di uscita del processo;
- ambiente e versione.

Un output privo di errori visibili non è sufficiente quando non dimostra che i test attesi siano stati individuati ed eseguiti.

I riferimenti specifici per Dart e Flutter sono descritti nel Capitolo 6.

## 12.11 Evidenze dei test database

Le evidenze dei test database devono consentire di ricostruire le verifiche eseguite sulle strutture e sulle operazioni SQL.

Quando pertinente, possono comprendere:

- query di verifica;
- funzione RPC interessata;
- parametri non riservati;
- risultato restituito;
- stato iniziale e finale;
- vincoli verificati;
- transazioni controllate;
- comportamento delle autorizzazioni;
- eventuale ripristino.

Le evidenze devono distinguere i risultati ottenuti con privilegi amministrativi da quelli ottenuti con ruoli applicativi ordinari.

Le modalità dei test database sono approfondite nel Capitolo 7.

## 12.12 Evidenze dei test funzionali

Le evidenze dei test funzionali devono documentare il comportamento osservato nell'applicazione.

Quando pertinente, possono comprendere:

- percorso di navigazione;
- operazione effettuata;
- dati utilizzati;
- messaggi visualizzati;
- comportamento dell'interfaccia;
- stato successivo all'operazione;
- verifica della persistenza;
- eventuali errori.

Gli screenshot possono essere utilizzati quando aggiungono informazioni utili alla comprensione del risultato.

Una schermata di conferma non sostituisce la verifica della persistenza quando prevista.

I test funzionali e di integrazione sono descritti nel Capitolo 8.

## 12.13 Evidenze dei test di sicurezza

Le evidenze dei test di sicurezza devono documentare le condizioni di autorizzazione e il comportamento effettivo del sistema.

Quando pertinente, devono identificare:

- categoria di identità utilizzata;
- ruolo applicabile;
- operazione richiesta;
- autorizzazione attesa;
- risposta ottenuta;
- eventuali dati restituiti;
- eventuali modifiche effettuate;
- assenza di effetti non autorizzati.

Le evidenze non devono contenere credenziali, token o chiavi riservate in forma utilizzabile.

I riferimenti specifici sono descritti nel Capitolo 9.

## 12.14 Evidenze delle anomalie e regressioni

Le anomalie e le regressioni devono essere documentate in modo da collegare il problema osservato alle verifiche successive.

Quando pertinente, devono risultare:

- identificazione dell'anomalia;
- condizioni di rilevazione;
- risultato atteso;
- risultato osservato;
- eventuale riproduzione;
- analisi effettuata;
- modifica applicata;
- verifica della correzione;
- test di regressione eseguiti;
- esito conclusivo.

La documentazione deve distinguere l'applicazione della correzione dalla verifica del suo risultato.

La gestione delle anomalie è disciplinata nel Capitolo 11.

## 12.15 Organizzazione e conservazione

Le evidenze devono essere organizzate in modo da consentire il recupero delle informazioni necessarie al riesame.

L'organizzazione deve permettere di collegare le registrazioni ai test, alle versioni e alle decisioni pertinenti.

La modalità di conservazione deve essere coerente con gli strumenti e le procedure effettivamente adottati per Orto Smart.

Non deve essere presunta l'esistenza di un archivio o di un sistema documentale non ancora istituito.

Devono essere evitate duplicazioni non necessarie e conservazioni prive di una finalità identificabile.

## 12.16 Protezione delle informazioni riservate

La raccolta delle evidenze deve rispettare i requisiti di sicurezza e riservatezza applicabili.

Non devono essere divulgati:

- password;
- token di autenticazione;
- token di lock;
- chiavi riservate;
- credenziali di servizio;
- configurazioni sensibili;
- dati personali non necessari.

Quando un output contiene informazioni riservate, devono essere conservate soltanto le parti necessarie alla verifica, opportunamente protette.

La protezione delle evidenze deve essere coerente con i principi del Capitolo 9.

## 12.17 Tracciabilità e riesame

Le registrazioni devono permettere di ricostruire il collegamento tra verifica eseguita, risultato osservato e decisione assunta.

Quando pertinente, devono essere identificabili:

- requisito o contratto;
- test;
- ambiente;
- versione;
- risultato;
- eventuale anomalia;
- correzione;
- verifica successiva;
- decisione di accettazione.

Le evidenze devono essere riesaminate quando emergono informazioni che possono modificare l'interpretazione precedente.

Una decisione di accettazione deve rimanere riferita alle condizioni effettivamente verificate.

## 12.18 Completezza della documentazione

La documentazione di un test può essere considerata completa quando contiene le informazioni necessarie a comprendere la verifica e a sostenerne l'esito.

La completezza deve essere valutata in relazione alla natura del test, alla sua criticità e ai criteri di accettazione applicabili.

Non è necessario produrre evidenze ridondanti quando quelle disponibili sono sufficienti e verificabili.

Non devono invece essere omesse informazioni indispensabili alla ricostruzione del risultato.

Le registrazioni costituiscono il supporto documentale per le decisioni di accettazione definite nel Capitolo 10 e per il collaudo complessivo descritto nel Capitolo 13.

# 13. Collaudo complessivo dell'applicazione

Il collaudo complessivo di **Orto Smart** ha lo scopo di valutare il comportamento dell'applicazione nel suo insieme, considerando le funzionalità effettivamente implementate, i contratti approvati e le integrazioni necessarie al loro corretto funzionamento.

Il collaudo complessivo non sostituisce i test unitari, i test database, i test funzionali o le verifiche di sicurezza.

Esso utilizza i risultati di tali verifiche e li integra con controlli sui flussi applicativi e sulla coerenza generale del sistema.

Il presente capitolo definisce le modalità di organizzazione, esecuzione e valutazione del collaudo complessivo.

Non costituisce una dichiarazione di avvenuto collaudo né certifica il superamento di verifiche non documentate.

## 13.1 Obiettivi del collaudo complessivo

Il collaudo complessivo deve consentire di valutare:

- correttezza delle funzioni disponibili;
- coerenza tra interfaccia e database;
- rispetto dei contratti applicativi;
- integrità dei dati;
- correttezza delle autorizzazioni;
- gestione degli errori;
- comportamento dei flussi integrati;
- assenza di regressioni rilevanti;
- adeguatezza delle evidenze raccolte;
- presenza di eventuali limitazioni.

La valutazione deve riferirsi allo stato reale del progetto nel momento del collaudo.

Le funzionalità non implementate non devono essere presentate come collaudate.

## 13.2 Perimetro del collaudo

Prima dell'esecuzione deve essere identificato il perimetro del collaudo.

Il perimetro deve distinguere:

- funzionalità incluse;
- funzionalità escluse;
- componenti effettivamente disponibili;
- dipendenze necessarie;
- ambienti coinvolti;
- condizioni operative previste;
- eventuali limitazioni note.

Le esclusioni devono essere motivate.

Una funzionalità prevista per uno sviluppo futuro non deve essere considerata automaticamente parte del collaudo corrente.

L'ampliamento del perimetro richiede una nuova valutazione delle verifiche necessarie.

## 13.3 Prerequisiti del collaudo

Prima dell'avvio devono essere verificati i prerequisiti pertinenti.

Quando applicabile, comprendono:

- disponibilità dell'applicazione;
- configurazione dell'ambiente;
- accessibilità dei servizi richiesti;
- stato del database;
- migration previste;
- identità di prova autorizzate;
- disponibilità dei dati necessari;
- procedure di verifica definite;
- criteri di accettazione individuati;
- strumenti per registrare le evidenze.

L'assenza di un prerequisito può impedire l'esecuzione di una o più verifiche.

Tale condizione deve essere registrata senza attribuire esiti positivi ai test non eseguiti.

## 13.4 Identificazione della versione

Il collaudo deve essere riferito a una versione identificabile dell'applicazione e del database.

Quando pertinente, devono risultare:

- branch Git;
- commit di riferimento;
- presenza di modifiche non committate;
- versione di Flutter e Dart;
- ambiente di esecuzione;
- versione o stato di Supabase;
- migration applicate;
- configurazioni rilevanti.

Se il codice o il database cambiano durante il collaudo, deve essere valutato quali verifiche ripetere.

Un risultato ottenuto su una versione precedente non deve essere automaticamente attribuito alla versione successiva.

## 13.5 Preparazione dell'ambiente

L'ambiente deve essere preparato in modo coerente con il perimetro del collaudo.

Quando pertinente, devono essere verificati:

- avvio dei servizi necessari;
- raggiungibilità del database;
- configurazione delle connessioni;
- disponibilità delle RPC;
- presenza dei vincoli richiesti;
- applicazione delle politiche RLS;
- funzionamento dell'autenticazione;
- disponibilità del client Flutter;
- eventuali dipendenze esterne.

Le differenze tra ambiente locale e ambiente remoto devono essere considerate nell'interpretazione dei risultati.

Il superamento di un test locale non dimostra automaticamente il medesimo comportamento in un ambiente differente.

## 13.6 Preparazione dei dati

I dati necessari al collaudo devono essere definiti in relazione alle verifiche previste.

La preparazione deve rispettare le regole di gestione dei dati approvate per Orto Smart.

Devono essere evitati popolamenti provvisori che possano compromettere la pulizia del database operativo.

Quando sono indispensabili dati di test, il loro utilizzo deve avvenire in un contesto controllato e appropriato.

Devono essere valutati:

- stato iniziale;
- dati necessari;
- eventuale isolamento;
- effetti delle operazioni;
- possibilità di ripristino;
- stato finale atteso.

Non devono essere introdotti dati fittizi nel database operativo senza una decisione esplicita che ne autorizzi l'utilizzo.

## 13.7 Pianificazione delle verifiche

Il collaudo complessivo deve essere organizzato in una sequenza verificabile.

La pianificazione deve considerare:

- prerequisiti;
- dipendenze tra funzionalità;
- controlli preliminari;
- test automatici disponibili;
- verifiche database;
- test funzionali;
- test di integrazione;
- controlli di sicurezza;
- regressioni pertinenti;
- valutazione conclusiva.

La sequenza può essere adattata alle caratteristiche della versione da collaudare.

Le modifiche al piano devono essere riconoscibili nella registrazione finale.

## 13.8 Verifiche preliminari

Prima dei flussi integrati devono essere effettuati i controlli preliminari pertinenti.

Possono comprendere:

- analisi statica del codice;
- esecuzione dei test automatici;
- verifica delle migration;
- controllo dei vincoli database;
- disponibilità delle RPC;
- controllo delle autorizzazioni;
- verifica della configurazione;
- avvio dell'applicazione.

Il superamento dei controlli preliminari non equivale al superamento del collaudo complessivo.

Eventuali anomalie devono essere valutate prima di proseguire con le verifiche dipendenti.

## 13.9 Collaudo dei flussi applicativi

I flussi applicativi devono essere verificati considerando le operazioni effettivamente disponibili.

Quando pertinenti al perimetro, possono essere controllati:

- accesso all'applicazione;
- caricamento delle informazioni;
- navigazione tra le sezioni;
- visualizzazione dei dati;
- inserimento dei record;
- modifica dei record;
- gestione delle conferme;
- gestione degli errori;
- aggiornamento dello stato;
- persistenza delle operazioni.

Ogni flusso deve essere valutato rispetto al comportamento atteso.

Una schermata apparentemente corretta non dimostra da sola la correttezza delle scritture o dello stato persistente.

## 13.10 Collaudo delle integrazioni

Le integrazioni devono essere verificate nei punti in cui componenti distinti collaborano per completare un'operazione.

Per Orto Smart, quando pertinenti al perimetro, devono essere considerate le interazioni tra:

- interfaccia Flutter;
- logica applicativa;
- repository;
- client Supabase;
- funzioni RPC;
- database PostgreSQL;
- controlli di autorizzazione;
- gestione delle sessioni e dei lock.

Devono essere verificati sia il risultato applicativo sia gli effetti persistenti.

Le integrazioni non ancora sviluppate non devono essere dichiarate collaudate o operative.

## 13.11 Collaudo dell'integrità dei dati

Il collaudo complessivo deve comprendere, quando applicabile, verifiche sull'integrità dei dati.

Devono essere considerati:

- rispetto dei vincoli;
- correttezza dei riferimenti;
- coerenza delle relazioni;
- aggiornamento delle versioni;
- comportamento delle transazioni;
- assenza di scritture parziali indebite;
- correttezza dello stato finale;
- rispetto delle regole di cancellazione.

Le verifiche devono essere coerenti con il modello dati effettivamente implementato.

Un risultato visualizzato nell'interfaccia non sostituisce il controllo della persistenza quando questo è richiesto.

## 13.12 Collaudo della sicurezza

Il collaudo complessivo deve considerare i controlli di sicurezza applicabili alle funzionalità incluse.

Quando pertinenti, devono essere verificati:

- autenticazione;
- autorizzazione;
- appartenenza al profilo;
- privilegi delle RPC;
- politiche RLS;
- controlli del Write Path;
- validazione delle richieste;
- gestione dei lock;
- rifiuto delle operazioni indebite;
- assenza di modifiche non autorizzate.

Le verifiche devono comprendere anche i casi negativi necessari a dimostrare il corretto rifiuto delle operazioni non consentite.

I criteri specifici sono descritti nel Capitolo 9.

## 13.13 Collaudo delle condizioni anomale

Il collaudo deve valutare, quando pertinente, il comportamento del sistema in condizioni non ordinarie.

Possono essere considerate:

- input non validi;
- dati mancanti;
- richieste duplicate;
- operazioni non autorizzate;
- conflitti di versione;
- lock non disponibili;
- errori delle RPC;
- interruzioni di operazioni;
- indisponibilità di servizi;
- risposte inattese.

Il comportamento atteso deve essere definito in relazione ai contratti approvati.

Un errore intenzionalmente prodotto da un test negativo non costituisce un'anomalia quando il rifiuto osservato è quello previsto.

## 13.14 Verifiche di regressione

Il collaudo complessivo deve includere le verifiche di regressione pertinenti alle modifiche introdotte.

La selezione deve considerare:

- componenti modificati;
- dipendenze applicative;
- tabelle e RPC interessate;
- vincoli e autorizzazioni;
- flussi precedentemente verificati;
- anomalie corrette;
- rischi introdotti dalle modifiche.

I risultati precedenti possono costituire un riferimento, ma non sostituiscono le verifiche necessarie sulla versione corrente.

Le modalità di gestione delle regressioni sono definite nel Capitolo 11.

## 13.15 Registrazione degli esiti

Ogni verifica rilevante deve essere registrata secondo le modalità definite nel Capitolo 12.

La registrazione deve consentire di individuare:

- verifica prevista;
- verifica effettivamente eseguita;
- ambiente e versione;
- risultato atteso;
- risultato osservato;
- esito attribuito;
- eventuale anomalia;
- evidenze disponibili;
- eventuali limitazioni.

Devono essere distinti i test superati, quelli non superati, quelli non eseguiti e quelli non applicabili, secondo la classificazione approvata.

La mancanza di evidenze deve essere considerata nella valutazione conclusiva.

## 13.16 Valutazione delle anomalie residue

Prima della conclusione del collaudo devono essere riesaminate le anomalie ancora aperte.

La valutazione deve considerare:

- natura dell'anomalia;
- gravità e impatto;
- funzionalità coinvolte;
- rischio per i dati;
- rischio per la sicurezza;
- possibilità di utilizzo;
- eventuali limitazioni;
- verifiche non completate.

Non devono essere ignorate anomalie che compromettono i criteri di accettazione.

L'eventuale accettazione con limitazioni deve rispettare le condizioni previste dal Capitolo 10.

## 13.17 Decisione conclusiva del collaudo

La decisione conclusiva deve essere assunta sulla base dei risultati effettivamente documentati.

Deve tenere conto di:

- perimetro collaudato;
- verifiche eseguite;
- risultati ottenuti;
- anomalie residue;
- test non eseguiti;
- eventuali esclusioni;
- rischi identificati;
- criteri di accettazione applicabili.

La decisione deve distinguere il superamento del collaudo dall'eventuale accettazione con limitazioni.

Se le evidenze non sono sufficienti, non deve essere dichiarato un superamento non dimostrato.

La decisione deve essere esplicitamente registrata e riferita alla versione verificata.

## 13.18 Verbale e chiusura del collaudo

La chiusura del collaudo complessivo deve essere accompagnata da una registrazione conclusiva adeguata al perimetro verificato.

Quando pertinente, il verbale deve comprendere:

- identificazione dell'applicazione;
- versione sottoposta a collaudo;
- ambiente utilizzato;
- data o periodo delle verifiche;
- perimetro incluso;
- esclusioni e limitazioni;
- riepilogo dei test;
- risultati principali;
- anomalie residue;
- evidenze di riferimento;
- decisione conclusiva;
- soggetto responsabile della decisione.

Il verbale deve distinguere le verifiche realmente effettuate da quelle soltanto pianificate.

La chiusura documentale non sostituisce le attività tecniche ancora necessarie.

L'eventuale utilizzo operativo dell'applicazione deve essere valutato separatamente, in relazione allo stato effettivo delle funzionalità e alle decisioni approvate.

Il collaudo complessivo costituisce quindi una valutazione documentata di uno specifico stato di Orto Smart, non una certificazione permanente delle versioni successive.

# 14. Manutenzione e aggiornamento del documento

Il presente documento, **DOC-007 — Test e Collaudo**, deve essere mantenuto coerente con l'evoluzione effettiva di **Orto Smart**, con le decisioni architetturali approvate e con le procedure di verifica adottate.

La manutenzione documentale ha lo scopo di preservare l'affidabilità delle istruzioni, dei criteri e dei riferimenti utilizzati durante i test e il collaudo.

Ogni aggiornamento deve distinguere le procedure già applicabili dalle attività previste per sviluppi successivi.

La modifica del documento non costituisce, da sola, prova dell'esecuzione dei test o dell'accettazione di una funzionalità.

## 14.1 Obiettivi della manutenzione

La manutenzione del DOC-007 deve garantire:

- correttezza delle informazioni;
- coerenza con il sistema implementato;
- chiarezza delle procedure;
- tracciabilità delle revisioni;
- aggiornamento dei riferimenti tecnici;
- allineamento con i contratti approvati;
- riconoscibilità delle limitazioni;
- continuità della documentazione.

Il documento deve rimanere utilizzabile per pianificare, eseguire e riesaminare le verifiche pertinenti.

Non devono essere mantenute istruzioni note come superate senza indicarne esplicitamente la condizione.

## 14.2 Eventi che richiedono una revisione

Una revisione deve essere valutata quando intervengono modifiche che incidono sui test, sui criteri di accettazione o sulla loro interpretazione.

Tra gli eventi rilevanti rientrano:

- introduzione di nuove funzionalità;
- modifica dei flussi applicativi;
- variazione dei contratti delle RPC;
- aggiornamento dello schema database;
- modifica di vincoli o trigger;
- cambiamenti delle politiche RLS;
- variazione dei meccanismi di lock;
- introduzione di nuovi test;
- modifica delle procedure di collaudo;
- cambiamenti degli strumenti utilizzati;
- nuove decisioni architetturali approvate;
- individuazione di errori documentali.

Non ogni modifica tecnica richiede necessariamente una nuova versione del DOC-007.

La necessità della revisione deve essere valutata in relazione al suo impatto sulle informazioni documentate.

## 14.3 Coerenza con lo sviluppo effettivo

Gli aggiornamenti devono basarsi sullo stato reale e verificabile del progetto Orto Smart.

Devono essere distinti:

- funzionalità implementate;
- funzionalità sottoposte a test;
- funzionalità approvate;
- funzionalità in sviluppo;
- funzionalità soltanto previste;
- proposte ancora da valutare.

Le ipotesi esplorative e le roadmap informali non costituiscono automaticamente decisioni progettuali approvate.

Non devono essere riportati come risultati effettivi test non eseguiti, implementazioni non completate o comportamenti non verificati.

## 14.4 Fonti per l'aggiornamento

Le revisioni devono utilizzare fonti pertinenti e verificabili.

Quando applicabile, possono essere considerate:

- documentazione ufficiale del progetto;
- decisioni architetturali approvate;
- codice sorgente;
- migration SQL;
- definizioni delle RPC;
- configurazioni effettive;
- test automatici;
- risultati dei collaudi;
- evidenze tecniche;
- commit Git;
- checkpoint delle sessioni di sviluppo.

Le fonti devono essere interpretate in relazione alla loro data, alla versione interessata e al contesto di utilizzo.

In caso di informazioni discordanti, la discrepanza deve essere verificata prima di aggiornare il documento.

## 14.5 Coerenza con gli altri documenti

Il DOC-007 deve mantenere coerenza con gli altri documenti ufficiali di Orto Smart.

Particolare attenzione deve essere riservata ai documenti che descrivono:

- architettura applicativa;
- modello dati;
- sicurezza;
- contratti e Write Path;
- funzionalità implementate;
- decisioni architetturali;
- procedure operative;
- stato dello sviluppo.

I riferimenti incrociati devono essere aggiornati quando cambiano denominazioni, percorsi o contenuti pertinenti.

Non devono essere introdotte regole in contrasto con decisioni già approvate senza un'esplicita revisione delle decisioni interessate.

## 14.6 Aggiornamento delle procedure di test

Quando una funzionalità cambia, deve essere valutata l'adeguatezza delle procedure di verifica esistenti.

La valutazione deve considerare:

- prerequisiti;
- ambiente;
- dati necessari;
- operazioni da eseguire;
- risultati attesi;
- controlli negativi;
- effetti persistenti;
- condizioni di accettazione;
- verifiche di regressione.

Le procedure non più applicabili devono essere aggiornate o chiaramente identificate come superate.

Le nuove procedure devono essere coerenti con i contratti effettivamente approvati e implementati.

## 14.7 Aggiornamento dei test automatici

L'evoluzione dei test automatici può richiedere modifiche alle indicazioni del presente documento.

Quando pertinente, devono essere riesaminati:

- comandi di esecuzione;
- organizzazione delle suite;
- strumenti utilizzati;
- prerequisiti;
- criteri di superamento;
- modalità di registrazione;
- interpretazione dei risultati.

Non deve essere dichiarata la disponibilità di test automatici soltanto perché previsti nella documentazione.

La presenza e il comportamento delle suite devono essere verificati nel repository effettivo.

## 14.8 Aggiornamento delle verifiche database

Le modifiche al database devono essere valutate per il loro impatto sulle procedure di test.

Quando pertinente, devono essere considerati:

- nuove tabelle;
- modifica delle colonne;
- vincoli;
- indici;
- trigger;
- funzioni SQL;
- RPC;
- migration;
- transazioni;
- politiche RLS;
- privilegi e autorizzazioni.

Le istruzioni di verifica devono rimanere coerenti con lo schema effettivo.

Le verifiche che richiedono privilegi particolari devono essere chiaramente distinte da quelle eseguite con ruoli applicativi ordinari.

## 14.9 Aggiornamento delle verifiche di sicurezza

Ogni modifica rilevante ai meccanismi di sicurezza deve determinare un riesame delle verifiche corrispondenti.

Quando pertinente, devono essere considerati:

- autenticazione;
- identità applicativa;
- appartenenza al profilo;
- autorizzazioni;
- politiche RLS;
- privilegi SQL;
- funzioni SECURITY DEFINER;
- Write Path;
- lock;
- gestione delle sessioni;
- accessi concorrenti;
- protezione delle informazioni.

Le verifiche devono comprendere i comportamenti autorizzati e i rifiuti previsti.

L'aggiornamento delle istruzioni non dimostra automaticamente che i controlli di sicurezza siano stati nuovamente eseguiti.

## 14.10 Gestione delle correzioni documentali

Gli errori documentali devono essere corretti senza alterare indebitamente il significato delle decisioni o delle evidenze precedenti.

Le correzioni possono riguardare:

- errori di scrittura;
- riferimenti errati;
- procedure incomplete;
- istruzioni non aggiornate;
- descrizioni ambigue;
- incongruenze tra capitoli;
- informazioni tecniche inesatte.

Quando una correzione modifica il significato di una procedura o di un criterio di accettazione, deve essere trattata come revisione sostanziale.

Non devono essere modificati retroattivamente i risultati di test già registrati per renderli coerenti con una nuova descrizione.

## 14.11 Gestione delle revisioni

Le revisioni del DOC-007 devono essere identificabili e ricostruibili.

Quando pertinente, devono essere registrati:

- versione del documento;
- data della revisione;
- capitoli interessati;
- natura delle modifiche;
- motivazione;
- riferimenti tecnici;
- eventuale approvazione;
- stato del documento.

La numerazione delle versioni deve seguire le convenzioni documentali ufficiali del progetto.

Non devono essere attribuite versioni definitive o approvate senza la corrispondente decisione di approvazione.

## 14.12 Revisione dei capitoli e sottocapitoli

Le modifiche devono preservare la coerenza interna del documento.

Quando si sostituisce un capitolo o un sottocapitolo, deve essere predisposto il testo completo dell'unità documentale interessata.

La revisione deve verificare:

- titolo;
- numerazione;
- completezza del contenuto;
- riferimenti incrociati;
- terminologia;
- coerenza con gli altri capitoli;
- eventuali duplicazioni;
- presenza di contenuti superati.

Devono essere evitate sostituzioni frammentarie che possano produrre contraddizioni o parti residue non più coerenti.

## 14.13 Verifica tecnica del documento

Prima dell'approvazione di una revisione, devono essere effettuati i controlli tecnici pertinenti.

Possono comprendere:

- verifica della struttura Markdown;
- controllo dei titoli;
- controllo della numerazione;
- ricerca di duplicazioni;
- verifica dei riferimenti;
- controllo delle differenze Git;
- verifica di formattazione;
- verifica della codifica del file;
- controllo di eventuali modifiche estranee.

I controlli tecnici devono essere eseguiti sul contenuto effettivamente salvato.

Il superamento di un controllo di formattazione non equivale all'approvazione del contenuto tecnico.

## 14.14 Approvazione delle modifiche

L'approvazione di una revisione deve essere distinta dalla sua preparazione e dal suo inserimento nel file.

Il processo deve consentire di riconoscere:

- contenuto proposto;
- modifiche effettivamente inserite;
- verifiche tecniche eseguite;
- eventuali correzioni richieste;
- decisione di approvazione;
- versione approvata.

Una modifica non deve essere considerata approvata soltanto perché presente nel repository locale.

L'approvazione deve essere esplicita e riferita al contenuto effettivamente esaminato.

## 14.15 Consolidamento nel repository

Dopo l'approvazione, le modifiche documentali possono essere consolidate nel repository secondo il workflow adottato.

Prima del consolidamento devono essere verificati, quando pertinenti:

- file modificati;
- differenze Git;
- assenza di modifiche indesiderate;
- stato del working tree;
- versione documentale;
- coerenza dei riferimenti;
- completamento delle approvazioni.

Commit e push devono essere eseguiti soltanto quando previsti e autorizzati dal workflow.

La presenza di modifiche locali non deve essere confusa con la loro pubblicazione nel repository remoto.

## 14.16 Riesame periodico e continuità

Il DOC-007 deve essere riesaminato quando l'evoluzione di Orto Smart rende necessario aggiornare procedure, criteri o riferimenti.

Il riesame deve considerare:

- stato attuale delle funzionalità;
- modifiche architetturali;
- variazioni del database;
- aggiornamenti della sicurezza;
- nuovi test disponibili;
- anomalie ricorrenti;
- risultati di collaudo;
- modifiche degli strumenti;
- coerenza con gli altri documenti.

Non è necessario dichiarare una periodicità fissa se questa non è stata formalmente stabilita.

Il documento deve continuare a rappresentare una guida affidabile per le verifiche, senza trasformare previsioni o intenzioni in risultati acquisiti.

La manutenzione documentale è parte del processo di qualità di Orto Smart, ma non sostituisce lo sviluppo, i test e il collaudo effettivo dell'applicazione.

# 15. Considerazioni finali

Il presente documento, **DOC-007 — Test e Collaudo**, definisce i principi, le modalità e i criteri di riferimento per la verifica delle funzionalità e dei componenti di **Orto Smart**.

Le procedure descritte hanno lo scopo di sostenere uno sviluppo controllato, la rilevazione tempestiva delle anomalie e la valutazione documentata dei risultati.

La qualità dell'applicazione non deve essere dedotta dalla sola disponibilità di una funzionalità o dall'assenza apparente di errori.

Deve essere valutata attraverso verifiche pertinenti, risultati osservabili ed evidenze coerenti con i contratti approvati.

## 15.1 Centralità della verifica

Ogni funzionalità deve essere valutata in relazione al comportamento effettivamente richiesto.

La verifica deve considerare, quando pertinente:

- correttezza funzionale;
- integrità dei dati;
- coerenza delle operazioni;
- gestione degli errori;
- autorizzazioni;
- sicurezza;
- integrazione tra componenti;
- assenza di regressioni rilevanti.

Il completamento del codice non costituisce da solo prova del corretto funzionamento.

I risultati devono essere sostenuti da controlli adeguati alla natura della funzionalità.

## 15.2 Distinzione tra sviluppo e collaudo

Lo sviluppo, l'esecuzione dei test e l'accettazione dei risultati costituiscono attività distinte.

Una funzionalità implementata può non essere ancora stata sottoposta a tutte le verifiche necessarie.

Un test eseguito può non essere superato.

Una verifica superata può non essere sufficiente per l'accettazione complessiva della funzionalità.

Il documento deve mantenere chiara questa distinzione in tutte le registrazioni e nelle decisioni conclusive.

## 15.3 Sicurezza e integrità dei dati

La sicurezza e l'integrità dei dati costituiscono requisiti fondamentali per Orto Smart.

Le verifiche devono considerare, quando applicabile:

- identità e autenticazione;
- autorizzazioni;
- appartenenza al profilo;
- politiche RLS;
- privilegi SQL;
- Write Path;
- gestione dei lock;
- concorrenza;
- atomicità delle operazioni;
- vincoli di integrità;
- protezione delle informazioni.

Un risultato funzionalmente corretto non deve essere considerato sufficiente quando ottenuto attraverso un percorso che viola i controlli di sicurezza approvati.

## 15.4 Valore dei test negativi

I test negativi sono parte integrante della verifica del sistema.

Essi permettono di accertare che operazioni non valide o non autorizzate vengano rifiutate secondo i contratti previsti.

Il rifiuto atteso di una richiesta indebita costituisce un comportamento corretto.

La valutazione deve verificare, quando pertinente, che il rifiuto non produca modifiche persistenti o effetti collaterali non autorizzati.

I test negativi non devono essere confusi con anomalie applicative quando il comportamento osservato corrisponde a quello previsto.

## 15.5 Tracciabilità delle evidenze

Le evidenze devono permettere di ricostruire le verifiche effettivamente eseguite.

Quando pertinente, devono collegare:

- requisito o contratto;
- ambiente;
- versione;
- procedura;
- risultato atteso;
- risultato osservato;
- esito;
- eventuale anomalia;
- decisione conclusiva.

La tracciabilità deve sostenere la comprensione del risultato senza introdurre documentazione ridondante o informazioni non necessarie.

L'assenza di evidenze sufficienti deve essere riconosciuta come una limitazione della verifica.

## 15.6 Gestione delle anomalie

Le anomalie rilevate devono essere gestite in modo verificabile.

La gestione deve distinguere:

- rilevazione;
- registrazione;
- valutazione;
- analisi;
- correzione;
- nuova verifica;
- eventuali regressioni;
- chiusura.

Una modifica del codice non dimostra automaticamente che l'anomalia sia risolta.

La chiusura deve essere sostenuta da risultati coerenti con il comportamento atteso.

## 15.7 Prevenzione delle regressioni

Le modifiche applicative e database possono influire su comportamenti precedentemente verificati.

Le verifiche di regressione devono essere selezionate in relazione ai componenti modificati, alle dipendenze e ai rischi introdotti.

Quando pertinente, devono essere considerate anche le conseguenze sulle autorizzazioni, sulla persistenza dei dati e sulla concorrenza.

Non deve essere dichiarata una copertura completa se sono stati verificati soltanto alcuni percorsi.

## 15.8 Coerenza tra documentazione e applicazione

Il DOC-007 deve rappresentare procedure e criteri coerenti con lo stato effettivo di Orto Smart.

Le modifiche del sistema possono richiedere un aggiornamento delle procedure di test.

Le informazioni documentali devono distinguere ciò che è implementato da ciò che è soltanto previsto.

Le ipotesi esplorative non costituiscono decisioni progettuali approvate.

Le revisioni devono seguire il processo definito nel Capitolo 14.

## 15.9 Accettazione consapevole

L'accettazione di una funzionalità o di un collaudo deve essere fondata su risultati documentati e criteri riconoscibili.

Devono essere considerate:

- verifiche superate;
- verifiche non superate;
- test non eseguiti;
- test non applicabili;
- anomalie residue;
- limitazioni conosciute;
- rischi ancora presenti;
- perimetro effettivamente verificato.

Un'accettazione con limitazioni deve essere esplicita e coerente con i criteri del Capitolo 10.

Non devono essere attribuiti esiti positivi a verifiche non effettuate.

## 15.10 Evoluzione progressiva del collaudo

Orto Smart è un progetto soggetto a evoluzione.

L'introduzione di nuove funzionalità, componenti e integrazioni può richiedere ulteriori verifiche e un ampliamento del perimetro di collaudo.

I risultati ottenuti su una versione non devono essere automaticamente estesi alle versioni successive.

Ogni valutazione deve riferirsi allo stato effettivamente verificato.

Il collaudo deve accompagnare l'evoluzione dell'applicazione senza anticipare funzionalità non ancora disponibili.

## 15.11 Responsabilità delle decisioni

Le decisioni di accettazione devono essere distinte dalle attività tecniche di preparazione ed esecuzione.

La documentazione deve permettere di riconoscere:

- verifiche effettuate;
- risultati disponibili;
- eventuali limitazioni;
- decisione assunta;
- versione interessata;
- responsabilità della decisione.

La produzione di evidenze tecniche non sostituisce l'approvazione esplicita quando questa è richiesta dal workflow del progetto.

## 15.12 Conclusione

Il DOC-007 costituisce il riferimento documentale per organizzare, eseguire e valutare i test e il collaudo di Orto Smart.

Il suo obiettivo è favorire un processo di sviluppo nel quale ogni risultato sia riconducibile a verifiche effettive e a decisioni consapevoli.

I principi fondamentali rimangono:

- correttezza;
- sicurezza;
- integrità dei dati;
- verificabilità;
- tracciabilità;
- controllo delle modifiche;
- gestione delle anomalie;
- prevenzione delle regressioni;
- coerenza documentale.

Il completamento e l'approvazione del presente manuale non costituiscono, da soli, certificazione di avvenuto collaudo complessivo dell'applicazione.

Il collaudo effettivo deve essere eseguito e documentato secondo il perimetro, le procedure e i criteri di accettazione applicabili alla versione verificata.

La documentazione e le verifiche tecniche devono quindi procedere in modo coerente, nel rispetto del principio di sicurezza e qualità adottato per Orto Smart.
