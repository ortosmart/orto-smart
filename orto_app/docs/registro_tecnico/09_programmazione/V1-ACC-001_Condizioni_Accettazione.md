# V1-ACC-001 - Condizioni di accettazione V1

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: ricognizione STEP 274 e STEP 275.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Classificazione: programmazione e accettazione.
- Stato: consolidamento documentale.
- Collaudo complessivo: NV.

## 2. Finalita

Definire le condizioni necessarie per distinguere:

- disponibilita tecnica dei componenti;
- integrazione funzionale;
- operativita effettiva;
- accettazione del rilascio.

La presenza di codice, tabelle, RPC o interfacce
non costituisce da sola accettazione operativa.

Le condizioni di accettazione non rappresentano
nuove funzionalita aggiunte al perimetro approvato.

## 3. Milestone A

Obiettivo:

Consentire il primo utilizzo reale di Orto Smart,
con particolare riferimento alla configurazione
dell'orto e alla pianificazione della stagione 2027.

Macroblocchi interessati:

- V1-01: identita, autenticazione e profilo.
- V1-02: sicurezza e autorita di scrittura.
- V1-03: backup e ripristino.
- V1-04: migrazioni e allineamento ambienti.
- V1-05: gestione orti.
- V1-06: aiuole e geometrie.
- V1-07: stagioni.
- V1-08: Catalogo Agronomico.
- V1-09: motori agronomici.
- V1-10: pianificazioni stagionali.
- V1-11: coltivazioni effettive.
- V1-15: Dashboard.
- V1-16: impostazioni e amministrazione.
- V1-17: distribuzione e dispositivi.
- V1-18: configurazione e accettazione.

I macroblocchi esclusivamente B non costituiscono
automaticamente impedimenti al rilascio A.

Restano obbligatorie le dipendenze condivise
necessarie al funzionamento della milestone A.

## 4. Condizioni di accettazione A

### ACC-A01 - Identita e accesso

Accesso autorizzato al profilo reale.

Identita client e sessione correttamente gestite.

Separazione fra autorizzazione di accesso
e autorita di scrittura.

### ACC-A02 - Sicurezza e integrita

Rispetto di RLS, RPC autoritative,
Write Authority e controllo delle versioni.

Gestione delle operazioni concorrenti,
degli errori e degli esiti incerti.

Nessuna non conformita bloccante aperta.

### ACC-A03 - Protezione dei dati

Backup verificabile.

Ripristino funzionale collaudato
in ambiente isolato.

Procedure di recupero documentate.

La sola leggibilita del dump non equivale
a un ripristino funzionale riuscito.

### ACC-A04 - Ambiente operativo

Migrazioni necessarie applicate e verificate
nell'ambiente destinato all'utilizzo reale.

Compatibilita fra applicazione e database.

Nessuna distribuzione o migrazione remota
senza autorizzazione esplicita.

### ACC-A05 - Configurazione dell'orto

Orto reale configurabile.

Aiuole reali configurabili.

Geometrie e relative modifiche coerenti.

Conservazione dello storico geometrico.

Nessuna modifica implicita incompatibile
con pianificazioni o coltivazioni esistenti.

### ACC-A06 - Gestione stagionale

Creazione, consultazione e gestione
delle stagioni necessarie.

Distinzione fra stagione attiva
e stagione consultata.

Nessuna chiusura automatica impropria
delle coltivazioni.

Periodo della stagione 2027 da confermare
durante la configurazione reale.

### ACC-A07 - Catalogo Agronomico

Identita agronomiche approvate e verificabili.

Dati necessari alla pianificazione reale.

Fonti e revisioni tracciabili.

Separazione fra dati candidati e approvati.

Nessuna sovrascrittura automatica
da fonti esterne.

### ACC-A08 - Supporto agronomico

Integrazione delle conoscenze approvate
nei processi previsti per la milestone A.

Gestione esplicita dei dati mancanti.

Nessuna equivalenza fra dato sconosciuto
e valore neutro o nullo.

Nessuna modifica operativa automatica
non autorizzata.

### ACC-A09 - Pianificazione stagionale

Percorso funzionale dalla stagione
e dall'aiuola alla pianificazione.

Gestione del lifecycle delle pianificazioni.

Consultazione temporale e spaziale.

Controlli di compatibilita e occupazione.

Distinzione fra pianificazione confermata
e coltivazione realmente eseguita.

### ACC-A10 - Coltivazioni effettive

Creazione e gestione coerente
delle coltivazioni reali.

Esecuzione autoritativa delle pianificazioni.

Prevenzione della doppia esecuzione.

Conservazione del collegamento storico
fra pianificazione e coltivazione.

Nessuna esecuzione fittizia permanente
per dimostrare il funzionamento.

### ACC-A11 - Dashboard e navigazione

Accesso ai percorsi operativi necessari.

Informazioni coerenti con il contesto
dell'orto e della stagione consultata.

Azioni rapide collegate ai processi
autoritativi esistenti.

Nessuna duplicazione della logica di dominio.

### ACC-A12 - Impostazioni e amministrazione

Accesso alle configurazioni necessarie.

Gestione controllata delle correzioni
e degli esiti incerti pertinenti al rilascio.

Nessuna modifica amministrativa
che aggiri i vincoli di sicurezza.

### ACC-A13 - Distribuzione

Applicazione Flutter Web utilizzabile
su PC Windows con Edge e iPad con Safari.

Distribuzione HTTPS verificata.

Compatibilita fra build e schema database.

Identificazione della versione distribuita.

Nessun obbligo di applicazione nativa
o offline avanzato nella milestone A.

### ACC-A14 - Collaudo operativo

Verifica integrata dei percorsi necessari.

Configurazione reale senza dati fittizi
permanenti.

Conservazione delle evidenze di collaudo.

Quando un evento agricolo reale non e'
ancora avvenuto, utilizzare un collaudo
equivalente in ambiente isolato.

### ACC-A15 - Autorizzazione al rilascio

Valutazione finale delle condizioni
di accettazione.

Registrazione delle eventuali limitazioni.

Autorizzazione esplicita del titolare.

Versione del primo rilascio operativo:
da determinare.

## 5. Milestone B

Obiettivo:

Completare la V1 per la gestione quotidiana
dell'orto, preservando tutti i dati reali
acquisiti durante la milestone A.

Macroblocchi esclusivamente B:

- V1-12: raccolti.
- V1-13: attivita, lavoro e diario.
- V1-14: irrigazione.
- V1-19: economia e produttivita.
- V1-20: meteorologia.
- V1-21: fertilizzazioni e trattamenti.

Comprende inoltre il completamento previsto
dei quindici macroblocchi condivisi con A.

## 6. Condizioni di accettazione B

### ACC-B01 - Continuita operativa

Conservazione dei dati reali acquisiti in A.

Migrazioni compatibili con lo storico.

Nessuna necessita di ricreare l'orto
o reinserire arbitrariamente i dati.

### ACC-B02 - Raccolti

Registrazione di eventi reali.

Quantita, unita, finalita e destinazioni
coerenti.

Gestione delle raccolte successive.

Distinzione fra raccolto utilizzabile
e scarti.

Nessuna liberazione automatica dell'aiuola
per effetto della sola raccolta.

### ACC-B03 - Attivita e lavoro

Gestione delle attivita e delle ricorrenze.

Timer di lavoro condiviso fra le interfacce.

Persistenza e recupero delle sessioni.

Distinzione fra tempo trascorso,
tempo netto e ore-persona.

Diario e allegati gestiti correttamente.

### ACC-B04 - Irrigazione

Configurazione delle zone e degli impianti.

Registrazione delle irrigazioni effettive.

Distinzione fra valori nominali,
stimati e misurati.

Nessun doppio conteggio dell'acqua.

Automazione hardware non obbligatoria
per il perimetro V1 approvato.

### ACC-B05 - Economia e produttivita

Registrazione delle spese.

Separazione fra costi correnti
e investimenti.

Valorizzazione dei raccolti.

Indicatori coerenti con periodo,
superficie e unita di misura.

Distinzione fra risparmio potenziale
e spesa realmente evitata.

### ACC-B06 - Meteorologia

Integrazione della fonte meteorologica.

Sito meteorologico personale come
riferimento storico autorevole.

Nessuna duplicazione indiscriminata
dello storico meteorologico grezzo.

Gestione esplicita di dati mancanti,
obsoleti o non disponibili.

### ACC-B07 - Fertilizzazioni e trattamenti

Registrazione di prodotti e interventi.

Conservazione dello storico.

Gestione degli intervalli di sicurezza.

Avvisi coerenti con gli interventi
effettivamente registrati.

Nessuna prescrizione automatica
o certificazione di sicurezza implicita.

### ACC-B08 - Integrazione trasversale

Dashboard completa secondo il perimetro V1.

Impostazioni e amministrazione integrate.

Infrastrutture condivise riutilizzate.

Nessuna duplicazione di timer, registri,
indicatori o motori comuni.

### ACC-B09 - Dispositivi

Verifica sui dispositivi previsti:

- PC.
- iPad.
- iPhone.
- Smartphone Android.
- Tablet Android.

Verifica delle interazioni touch,
della responsivita e dell'accesso Web.

### ACC-B10 - Accettazione definitiva

Completamento delle condizioni applicabili.

Collaudo integrato dei domini.

Verifica di sicurezza e recupero.

Autorizzazione esplicita al rilascio V1.0.

## 7. Regole comuni di accettazione

Classificazione delle non conformita:

- P0: bloccante.
- P1: bloccante per il rilascio pertinente.
- P2: valutazione e accettazione esplicita,
  senza derogare ai requisiti obbligatori.
- P3: registrazione e gestione successiva.

NV non equivale a PASS.

NA richiede motivazione.

Il superamento di un test unitario
non sostituisce un collaudo integrato.

Il collaudo locale non dimostra
automaticamente il funzionamento remoto.

Il completamento percentuale non autorizza
automaticamente il rilascio.

## 8. Evidenze richieste

Per ogni condizione applicabile registrare:

- identificativo;
- macroblocco interessato;
- commit e build;
- ambiente;
- dispositivo, quando pertinente;
- prerequisiti;
- risultato atteso;
- risultato effettivo;
- esito PASS, FAIL, NV o NA;
- riferimento all'evidenza;
- data e ora;
- eventuali non conformita;
- motivazione di eventuali ripetizioni.

Riutilizzare le evidenze gia valide.

Ripetere soltanto i controlli necessari
per modifiche, dipendenze o ambienti diversi.

## 9. Checkpoint di rilascio

Registrare almeno:

- data e ora;
- versione;
- commit;
- identificativo build;
- URL operativo;
- stato delle migrazioni;
- stato dei backup;
- stato del Catalogo Agronomico;
- configurazione reale;
- collaudi e dispositivi;
- non conformita residue;
- limitazioni;
- autorizzazione al rilascio.

## 10. Collegamenti

- V1-REG-001: perimetro dei macroblocchi.
- V1-MET-001: metodo di valutazione.
- V1-EST-001: baseline quantitativa.
- V1-EST-002: raggruppamenti operativi.
- ARC-002: sicurezza e integrita.
- ARC-003: gestione dei dati.
- ARC-004: perimetro dei rilasci.
- DB-MIG-001: stato delle migrazioni.
- TST-S046-001: baseline dei collaudi.
- Schede RC: evidenze delle infrastrutture.

## 11. Limiti del consolidamento

Gli identificativi ACC-A e ACC-B sono
introdotti per organizzare il Registro.

Le condizioni sono una sintesi operativa
delle decisioni recuperate nella S046.

Non costituiscono una trascrizione integrale
delle precedenti conversazioni.

La corrispondenza puntuale con tutte
le fonti storiche non e' stata riverificata.

Eventuali dettagli non confermati restano
da verificare nelle fonti autorevoli.

Nessuna nuova stima introdotta.

Nessuna riduzione delle ore approvate.

Nessuna dichiarazione di accettazione
effettiva della milestone A o B.
