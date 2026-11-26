# DUP-B-001 - Sovrapposizioni Milestone B

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: STEP 275.6.3.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Aree approvate qualitativamente: 12/12.
- Aree riconciliate quantitativamente: 0/12.
- Riduzioni approvate: 0 minuti.
- Incrementi approvati: 0 minuti.

## 2. Principi generali

Le infrastrutture condivise devono essere
sviluppate una sola volta e riutilizzate
nei diversi domini operativi.

Le integrazioni specifiche rimangono
responsabilita dei singoli domini.

La condivisione non implica necessariamente
una sola tabella o una sola RPC.

Devono essere rispettate le differenze
semantiche, operative e di sicurezza.

Le infrastrutture descritte rappresentano
responsabilita funzionali condivise.

La loro presenza nel Registro non attesta
che siano gia implementate.

## 3. DUP-B01 - Registri e configurazioni

Ambiti condivisi:

- Registri canonici globali.
- Categorie gestionali del profilo.
- Configurazioni tecniche.
- Preferenze dell'utilizzatore.
- Amministrazione.

Separare i registri agronomici globali
dai dati gestionali del singolo profilo.

Mantenere le configurazioni tecniche
nei rispettivi domini.

Non utilizzare una tabella universale
per informazioni semanticamente diverse.

Conservare identita e riferimenti storici.

Non sovrascrivere retroattivamente
le informazioni utilizzate in passato.

Le impostazioni costituiscono un punto
di accesso alle configurazioni,
non una persistenza parallela.

Riferimenti principali:

V1-01, V1-08, V1-16 e domini operativi.

Stato quantitativo: aperto.

## 4. DUP-B02 - Timer e registrazione del lavoro

Macroblocco principale: V1-13.

Interfacce utilizzatrici:

- Dashboard.
- Attivita.
- Domini operativi interessati.

Prevedere un unico processo autoritativo
di registrazione del tempo di lavoro.

Il timer non deve essere duplicato
fra Dashboard e Attivita.

Funzioni condivise:

- Inizio lavoro.
- Sospensione.
- Ripresa.
- Conclusione anche durante una sospensione.
- Persistenza della sessione.
- Recupero dopo interruzione.
- Correzione controllata.

Distinguere:

- Tempo trascorso.
- Tempo netto lavorato.
- Ore-persona.
- Tempo di funzionamento delle attrezzature.
- Durata prevista.

Non consentire sovrapposizioni incompatibili
per il medesimo operatore.

Consentire il lavoro contemporaneo
di operatori differenti.

Non inventare l'orario di conclusione
di una sessione interrotta.

Consentire lavoro non ancora attribuito
a una specifica attivita.

La durata di irrigazione non equivale
automaticamente al tempo di lavoro umano.

Stato quantitativo: aperto.

## 5. DUP-B03 - Ricorrenze e programmazione

Prevedere infrastrutture comuni
per la gestione delle ricorrenze.

Ambiti utilizzatori:

- V1-09: finestre e successioni.
- V1-10: pianificazioni.
- V1-13: attivita.
- V1-14: irrigazione.
- V1-21: interventi.
- V1-15: riepiloghi e avvisi.

Distinguere:

- Modello di ricorrenza.
- Singola occorrenza.
- Evento effettivamente eseguito.

Le modifiche future non devono
alterare impropriamente lo storico.

Distinguere occorrenze:

- Previste.
- Eseguite.
- Non eseguite.
- Saltate.
- Annullate.

Evitare duplicazioni in caso
di rigenerazione o ripetizione.

La generazione di un'attivita
non equivale alla sua esecuzione.

Nessuna esecuzione automatica
senza autorizzazione pertinente.

Gli intervalli di sicurezza dei trattamenti
rimangono concettualmente distinti
dalle ricorrenze ordinarie.

Non conteggiare due volte eventi
collegati a una medesima attivita.

Stato quantitativo: aperto.

## 6. DUP-B04 - Unita di misura e conversioni

Riutilizzare il registro canonico
delle unita di misura.

Prevedere un servizio comune
per le conversioni compatibili.

Ambiti interessati:

- Catalogo Agronomico.
- Pianificazioni.
- Coltivazioni.
- Raccolti.
- Irrigazione.
- Fertilizzazioni e trattamenti.
- Economia e produttivita.

Conservare il significato della grandezza.

Non convertire automaticamente
grandezze dimensionalmente incompatibili.

Conservare il valore originale
quando necessario alla tracciabilita.

Distinguere valori mancanti e valori zero.

Evitare conversioni implementate
separatamente in ogni interfaccia.

La presenza del registro delle unita
non dimostra che il servizio comune
di conversione sia gia completo.

Stato quantitativo: aperto.

## 7. DUP-B05 - Geometrie storiche e superfici

Riutilizzare le infrastrutture
di V1-06 e DUP-A03.

Ambiti interessati:

- Raccolti.
- Lavoro.
- Irrigazione.
- Fertilizzazioni.
- Economia e produttivita.
- Dashboard.

Utilizzare la geometria pertinente
alla data dell'evento considerato.

Non applicare retroattivamente
la geometria corrente a tutti gli eventi.

Condividere i calcoli delle superfici.

Mantenere distinte le regole
di attribuzione specifiche dei domini.

Non sommare superfici sovrapposte
senza considerare il significato
temporale e spaziale dell'indicatore.

Stato quantitativo: aperto.

## 8. DUP-B06 - Previsioni e consuntivi

Prevedere una logica condivisa
di confronto fra previsto ed effettivo.

Ambiti interessati:

- Pianificazioni.
- Coltivazioni.
- Raccolti.
- Attivita e lavoro.
- Irrigazione.
- Economia.
- Fertilizzazioni e trattamenti.

Mantenere distinti:

- Previsione.
- Pianificazione approvata.
- Evento effettivo.
- Consuntivo.
- Scostamento.

Una previsione non costituisce
un evento realmente avvenuto.

Una modifica della previsione
non deve alterare il consuntivo.

I valori mancanti non devono
essere sostituiti arbitrariamente.

Condividere i criteri di confronto,
mantenendo le formule specifiche
necessarie ai singoli domini.

Stato quantitativo: aperto.

## 9. DUP-B07 - Economia e produttivita

Macroblocco principale: V1-19.

Utilizzare indicatori condivisi
alimentati dai domini autorevoli.

Fonti funzionali:

- Raccolti.
- Superfici e geometrie.
- Tempo di lavoro.
- Irrigazione.
- Spese.
- Fertilizzazioni e trattamenti.

Distinguere:

- Costi correnti.
- Investimenti.
- Valore effettivo.
- Valore previsto.
- Risparmio potenziale.
- Spesa realmente evitata.

Indicatori pertinenti:

- kg/m2.
- kg/ora-persona.
- euro/m2.
- euro/ora-persona.
- costo corrente/kg.
- costo totale/kg.
- litri/kg.

Utilizzare periodi, superfici
e quantita coerenti.

Non introdurre allocazioni arbitrarie.

Conservare i riferimenti storici
dei prezzi utilizzati.

La Dashboard deve utilizzare
gli indicatori condivisi,
non ricalcolarli con logiche parallele.

Stato quantitativo: aperto.

## 10. DUP-B08 - Fertirrigazione

Ambiti principali:

- V1-14: irrigazione.
- V1-21: fertilizzazioni e trattamenti.
- V1-13: lavoro.
- V1-19: economia.

Prevedere un unico processo operativo
per l'intervento di fertirrigazione.

Mantenere distinte le responsabilita:

- Acqua: dominio irrigazione.
- Prodotto: dominio fertilizzazioni.
- Lavoro umano: dominio attivita.
- Spesa: dominio economia.

Conservare i collegamenti
fra le informazioni pertinenti.

Non duplicare l'intervento reale.

Non conteggiare due volte acqua,
prodotti, lavoro o spese.

La condivisione del processo
non richiede una tabella universale.

Stato quantitativo: aperto.

## 11. DUP-B09 - Intervalli di sicurezza

Macroblocco principale: V1-21.

Ambiti utilizzatori:

- Raccolti.
- Coltivazioni.
- Attivita.
- Dashboard.

Prevedere un unico motore autoritativo
per gli intervalli di sicurezza.

Utilizzare gli interventi effettivi
e i riferimenti storici pertinenti.

Considerare la scadenza applicabile
piu restrittiva fra quelle pertinenti.

Distinguere dato mancante
e assenza di intervallo.

Una raccolta realmente avvenuta
durante un intervallo deve poter
essere registrata come evento reale,
con avviso e conferma appropriati.

La registrazione non costituisce
autorizzazione al consumo.

Nessuna certificazione implicita
della sicurezza del prodotto.

Non duplicare il calcolo degli intervalli
nelle diverse interfacce.

Stato quantitativo: aperto.

## 12. DUP-B10 - Servizio meteorologico

Macroblocco principale: V1-20.

Prevedere un servizio meteorologico
condiviso fra i domini utilizzatori.

Fonte storica autorevole:

- Davis Vantage Pro2.
- CumulusMX.
- Sito meteorologico personale.

Il sito personale costituisce
il riferimento dello storico.

Evitare la duplicazione indiscriminata
dei dati meteorologici grezzi in Supabase.

Conservare soltanto le informazioni
derivate e i riferimenti necessari.

Distinguere:

- Dato disponibile e aggiornato.
- Dato obsoleto.
- Dato parziale.
- Fonte non raggiungibile.
- Servizio disabilitato.

Eventuali fonti alternative devono
essere identificabili e pertinenti.

Non mescolare silenziosamente
dati provenienti da fonti differenti.

Nessuna irrigazione automatica
basata soltanto su un dato meteorologico.

URL, API e compatibilita tecnica
della fonte da verificare.

Stato quantitativo: aperto.

## 13. DUP-B11 - Allegati e archiviazione

Prevedere infrastrutture comuni
per fotografie e allegati.

Ambiti interessati:

- Diario.
- Coltivazioni.
- Attivita.
- Raccolti.
- Interventi.
- Backup e recupero.

Evitare servizi di archiviazione
duplicati per ogni dominio.

Conservare riferimenti coerenti
fra record e oggetti archiviati.

Rispettare la separazione dei profili
e le autorizzazioni di accesso.

Utilizzare archiviazione privata
per i contenuti del profilo.

Considerare dimensioni, conservazione,
integrita e recuperabilita degli allegati.

Evitare duplicazioni non necessarie.

Le operazioni sullo Storage non devono
essere considerate automaticamente
parte della transazione PostgreSQL.

Prevedere compensazione e riconciliazione
quando necessarie.

Stato quantitativo: aperto.

## 14. DUP-B12 - Amministrazione e riconciliazione

Responsabilita principali:

- V1-02: infrastrutture di integrita.
- V1-16: interfacce amministrative.
- Domini: RPC e vincoli specifici.

Operazioni da distinguere:

- Correzione.
- Annullamento.
- Disattivazione.
- Riattivazione.
- Archiviazione.
- Eliminazione fisica eccezionale.
- Riconciliazione.
- Ripristino.

Classificare le operazioni come:

- Ordinarie.
- Controllate.
- Eccezionali.
- Di recupero.

Non introdurre una RPC universale
di modifica o eliminazione.

Mantenere il comportamento fail-closed.

Per le operazioni pertinenti prevedere:

- Anteprima.
- Motivazione.
- Conferma.
- Backup quando necessario.
- Verifica delle dipendenze.
- Verifica della Write Authority.
- Controllo delle versioni.
- Riesame autoritativo nella transazione.

Non eliminare fisicamente dati
incompatibili con i vincoli storici.

Non dichiarare riuscita un'operazione
con esito ancora incerto.

Riutilizzare journal e ricevute.

Non duplicare journal e audit
senza una responsabilita distinta.

Non conservare segreti nei registri.

La compensazione di operazioni Storage
non equivale al rollback PostgreSQL.

Prevedere il centro di riconciliazione
nelle impostazioni amministrative,
con segnalazioni pertinenti in Dashboard.

Stato quantitativo: aperto.

## 15. Regole di riconciliazione

Per ciascuna area registrare:

- Identificativo DUP.
- Infrastruttura comune.
- Responsabilita funzionale.
- Macroblocchi utilizzatori.
- Riferimenti alle stime originarie.
- Evidenze tecniche.
- Lavoro gia realizzato.
- Lavoro gia escluso dalle stime.
- Eventuale duplicazione dimostrata.
- Integrazioni specifiche residue.
- Eventuale riduzione.
- Eventuale incremento.
- Motivazione.
- Approvazione.

Riutilizzare le infrastrutture
disponibili e verificate.

Non considerare gia realizzati
componenti soltanto progettati.

Non eliminare dalle stime
le integrazioni ancora necessarie.

Non sottrarre due volte
la stessa attivita.

## 16. Stato complessivo

- Aree esaminate: 12/12.
- Aree approvate qualitativamente: 12/12.
- Aree riconciliate quantitativamente: 0/12.
- Riduzioni autorizzate: 0 minuti.
- Incrementi autorizzati: 0 minuti.

Baseline B invariata: 2055:45.

Baseline V1 invariata: 2734:18.

Configurazione reale A separata: 43:20.

Configurazione aggiuntiva B: NV.

## 17. Collegamenti

- ARC-REG-001.
- V1-REG-001.
- V1-MET-001.
- V1-EST-001.
- V1-EST-002.
- V1-ACC-001.
- DUP-A-001.
- PRC-003.
- PRC-004.
- Schede delle riconciliazioni RC.

## 18. Limiti del consolidamento

Documento ricostruito dalle conoscenze
recuperate durante la sessione S046.

Non costituisce trascrizione integrale
delle conversazioni originarie.

Le responsabilita condivise descritte
non attestano implementazioni completate.

Le soluzioni tecniche specifiche
rimangono soggette alle decisioni
delle future sessioni operative.

La riconciliazione delle stime PERT
originarie rimane da completare.

Nessuna variazione quantitativa introdotta.
