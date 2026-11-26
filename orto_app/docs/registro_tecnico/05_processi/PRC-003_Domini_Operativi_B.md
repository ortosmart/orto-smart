# PRC-003 - Domini operativi aggiuntivi B

## Metadati

- Sessione: S046
- Provenienza: STEP 274
- Natura: requisiti funzionali approvati
- Stato: implementazioni operative da realizzare
- Macroblocchi: V1-12, V1-13, V1-14, V1-19, V1-20, V1-21

## 1. Regola generale

Questi sei macroblocchi appartengono
al perimetro aggiuntivo B.

La disponibilita di infrastrutture comuni
non equivale alla loro implementazione operativa.

Riutilizzare identita, sicurezza, registri,
unita, geometrie, temporalita e servizi comuni.

Non creare implementazioni parallele.

## 2. V1-12 - Raccolti

Responsabilita:

- Registrazione dei raccolti effettivi.
- Data e quantita.
- Collegamento alla coltivazione.
- Unita originale e normalizzata.
- Operatore.
- Finalita e destinazione.
- Quantita utilizzabile e scarto.
- Correzioni controllate.
- Storico.

Supportare raccolti multipli.

Non superare la quantita disponibile
nelle attribuzioni delle destinazioni.

Distinguere previsione e raccolto effettivo.

Non liberare automaticamente l'aiuola.

Integrare avvisi relativi agli intervalli
di sicurezza senza cancellare gli eventi reali.

Riutilizzare HarvestPurpose e MeasurementUnit.

## 3. V1-13 - Attivita, lavori e diario

Responsabilita:

- Attivita programmate.
- Ricorrenze.
- Registrazione dei lavori.
- Operatori.
- Diario.
- Fotografie e allegati.
- Timer di lavoro.

Un solo timer autoritativo,
utilizzabile da Dashboard e Attivita.

Calcolare il tempo mediante timestamp
e intervalli effettivi.

Supportare avvio, pausa, ripresa e conclusione.

Escludere le pause dal tempo netto.

Consentire registrazioni manuali
e correzioni controllate.

Distinguere:

- Tempo trascorso.
- Tempo netto.
- Ore-persona.
- Durata dell'intervento.
- Durata di funzionamento delle attrezzature.

Non duplicare le ore dello stesso operatore
mediante registrazioni sovrapposte.

Operatori differenti possono lavorare
contemporaneamente.

Riutilizzare l'entita workers.

Gli allegati devono utilizzare
un'infrastruttura comune e protetta.

## 4. V1-14 - Irrigazione

Responsabilita:

- Zone logiche.
- Configurazioni di irrigazione.
- Interventi manuali.
- Durate.
- Portate.
- Volumi.
- Storico delle configurazioni.
- Collegamenti alle aiuole.

Contesto previsto:

- Pozzo.
- Serbatoi di accumulo.
- Elettrovalvole.
- Irrigazione a goccia.
- Irrigazione mediante altri erogatori.
- Evoluzione futura verso Raspberry Pi ed ESP32.

Formula per volume nominale:

Volume in litri =
somma delle portate in litri/ora
moltiplicata per i minuti e divisa per 60.

Distinguere volume nominale e misurato.

Non interpretare portate sconosciute come zero.

Non contabilizzare due volte
prelievo, accumulo e distribuzione.

Non attribuire arbitrariamente acqua
alle singole coltivazioni.

L'automazione hardware avanzata
non e automaticamente inclusa nella V1.

## 5. V1-19 - Gestione economica

Responsabilita:

- Spese.
- Investimenti.
- Categorie.
- Valorizzazione dei raccolti.
- Indicatori economici.
- Indicatori di produttivita.

Distinguere:

- Spese correnti e investimenti.
- Valore effettivo e previsto.
- Prodotto utilizzabile e scarto.
- Autoconsumo e altre destinazioni.

Il valore dell'autoconsumo rappresenta
un risparmio potenziale, non necessariamente
una spesa realmente evitata.

Conservare il riferimento storico dei prezzi.

Non interpretare un prodotto non valorizzato
come prodotto di valore zero.

Indicatori previsti:

- kg/m2
- kg/ora-persona
- euro/m2
- euro/ora-persona
- costo corrente euro/kg
- costo complessivo euro/kg
- litri/kg

Utilizzare periodi e geometrie coerenti.

Non introdurre attribuzioni arbitrarie
o indicatori di profitto non supportati.

## 6. V1-20 - Meteorologia

Fonte principale prevista:

Davis Vantage Pro2 -> CumulusMX
-> sito meteorologico personale.

Il sito personale costituisce
l'archivio autoritativo dello storico.

Evitare la duplicazione sistematica
dei dati grezzi in Supabase.

Conservare informazioni derivate
realmente necessarie ai processi agronomici.

Distinguere dati aggiornati, obsoleti,
parziali, indisponibili e disabilitati.

Eventuali fonti alternative devono essere
identificate e valutate per rappresentativita.

Non mescolare fonti senza evidenza.

Non attivare automaticamente l'irrigazione
in base alla sola disponibilita dei dati meteo.

URL, API e compatibilita CORS: NV.

## 7. V1-21 - Fertilizzazioni e trattamenti

Responsabilita:

- Prodotti.
- Composizioni.
- Revisioni.
- Fertilizzazioni.
- Trattamenti.
- Quantita.
- Intervalli di sicurezza.
- Avvisi relativi ai raccolti.
- Storico.

Conservare i riferimenti storici
ai prodotti e alle condizioni applicate.

Non generare prescrizioni automatiche
non supportate dalla conoscenza approvata.

Non interpretare un intervallo sconosciuto
come intervallo pari a zero.

Una raccolta realmente avvenuta durante
un intervallo di sicurezza deve essere
registrabile con le protezioni previste.

La registrazione non certifica
la sicurezza del consumo.

## 8. Integrazioni trasversali

Fertirrigazione:

- Acqua: V1-14.
- Prodotto: V1-21.
- Lavoro: V1-13.
- Spesa: V1-19.

Utilizzare un flusso operativo coordinato.

Non duplicare eventi e quantita
nei domini coinvolti.

## 9. Stato delle evidenze

Le capacita descritte sono requisiti approvati,
non attestazioni di implementazione.

Le infrastrutture riutilizzabili saranno
catalogate mediante le riconciliazioni RC.

I dettagli quantitativi delle sovrapposizioni
saranno conservati nella sezione 08_riutilizzo.
