# ARC-003 - Principi di gestione dei dati

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 274-275 e decisioni precedenti
- Natura: principi trasversali approvati

## 1. Dati reali

Non introdurre dati fittizi permanenti
nel database operativo.

I dati di collaudo devono essere isolati
oppure rimossi mediante procedure controllate.

Non cancellare dati reali
senza autorizzazione e verifica delle dipendenze.

Il popolamento agronomico deve rispettare
il processo di approvazione del Catalogo.

## 2. Conservazione dello storico

Distinguere:

- Identita permanente.
- Configurazione corrente.
- Configurazione storica.
- Evento operativo.
- Previsione.
- Correzione.
- Evidenza tecnica.

Non riscrivere automaticamente gli eventi storici
in conseguenza di modifiche alla configurazione.

Utilizzare i riferimenti storici pertinenti
per geometrie, quantita, prezzi e conoscenze.

## 3. Geometrie

La geometria dell'aiuola deve essere
gestita mediante il relativo dominio proprietario.

Riutilizzare le informazioni geometriche
nei processi di pianificazione e coltivazione.

Non sommare automaticamente occupazioni
riferite a periodi differenti.

Non modificare o spostare automaticamente
coltivazioni incompatibili con nuove geometrie.

## 4. Stagioni e temporalita

Distinguere:

- Stagione attiva.
- Stagione consultata.
- Data effettiva dell'evento.
- Data prevista.
- Periodo di validita.
- Data di registrazione.
- Data di correzione.

Il cambio di stagione non deve determinare
automaticamente la conclusione delle coltivazioni.

Non assumere date mancanti.

## 5. Quantita e unita

Riutilizzare i registri canonici delle unita.

Distinguere valore originale e valore normalizzato
quando richiesto dal processo.

Non duplicare conversioni nei singoli domini.

Non convertire automaticamente grandezze
dimensionalmente incompatibili.

Conservare precisione e provenienza
delle informazioni pertinenti.

## 6. Qualita delle informazioni

Distinguere almeno:

- Valore effettivo.
- Valore stimato.
- Valore previsto.
- Valore mancante.
- Valore parziale.
- Valore non aggiornato.
- Valore non applicabile.

Un valore sconosciuto non equivale a zero.

Una conoscenza agronomica sconosciuta
non equivale automaticamente a neutralita.

Uno storico incompleto non equivale
all'assenza di eventi precedenti.

## 7. Prevenzione dei doppi conteggi

Non contabilizzare due volte
lo stesso evento o la stessa quantita.

Distinguere pianificazioni e coltivazioni effettive.

Distinguere raccolto previsto e raccolto reale.

Distinguere tempo trascorso e ore-persona.

Distinguere acqua prelevata, accumulata e distribuita.

Distinguere spesa sostenuta e valorizzazione stimata.

Le aggregazioni devono utilizzare
riferimenti temporali e quantitativi coerenti.

## 8. Fonti agronomiche

Separare acquisizione, revisione e pubblicazione.

Nessuna sovrascrittura automatica
della conoscenza approvata.

Conservare fonti, revisioni e provenienza.

Utilizzare il Resolver come punto comune
di accesso alla conoscenza approvata.

## 9. Meteorologia

La stazione Davis Vantage Pro2,
CumulusMX e il sito meteorologico personale
costituiscono il contesto di riferimento previsto.

Il sito personale rimane l'archivio
autoritativo dello storico meteorologico.

Evitare la duplicazione sistematica
dei dati meteorologici grezzi in Supabase.

Conservare soltanto dati derivati,
riepiloghi e riferimenti realmente necessari.

Le modalita tecniche di accesso alle fonti
rimangono da verificare.

## 10. Efficienza della persistenza

Evitare duplicazioni inutili.

Utilizzare strutture coerenti e compatte.

Separare dati strutturati e allegati.

Considerare costi, capacita e limiti
dei servizi utilizzati.

Non sacrificare integrita, sicurezza
o recuperabilita per ridurre lo spazio.

## 11. Continuita dei dati

Il passaggio dal rilascio A
alla versione definitiva A+B
deve preservare i dati operativi reali.

Non prevedere un azzeramento sistematico
del database tra i due rilasci.
