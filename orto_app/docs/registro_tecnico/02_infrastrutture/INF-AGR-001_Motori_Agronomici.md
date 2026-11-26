# INF-AGR-001 - Motori agronomici

## Metadati

- Proprietario: V1-09
- Riconciliazione: RC13
- Sessione: S046
- Provenienza: STEP 273-274
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Stato: implementazione parziale

## 1. Componenti individuati

| Componente | Responsabilita |
|---|---|
| RotationEngine | Valutazione della rotazione |
| AssociationEngine | Valutazione delle associazioni |
| DecisionEngine | Combinazione delle valutazioni |
| RecommendationPipeline | Coordinamento raccomandazioni |
| CropAssociationRepository | Acquisizione associazioni |

## 2. RotationEngine

Comportamenti rilevati:

- Valore fallback pari a 3.
- Esclusione dei dati privi di famiglia botanica.
- Valutazione basata sulla differenza degli anni.
- Punteggio 100 in assenza di storico.

Questi comportamenti descrivono
l'implementazione rilevata, non nuove regole approvate.

Da approfondire:

- Utilizzo delle identita botaniche canoniche.
- Relazione tra anni, stagioni e date effettive.
- Distinzione tra storico assente e incompleto.
- Gestione delle informazioni non disponibili.

## 3. AssociationEngine

Comportamento rilevato:

- Valore 50 per associazione sconosciuta.

Da verificare rispetto al requisito approvato
di distinguere conoscenza assente da neutralita.

CropAssociationRepository risultava restituire
liste vuote nei percorsi esaminati.

## 4. DecisionEngine

Pesi rilevati:

- 0,4
- 0,3
- 0,3

La corrispondenza esatta dei pesi ai criteri
deve essere acquisita nella scheda RC13.

Non assumere che i pesi siano definitivi
o agronomicamente validati.

## 5. RecommendationPipeline

Comportamenti e limitazioni rilevati:

- familyNeeds non popolato.
- Resolver non integrato.
- Finestre agronomiche non integrate.
- Valutazione temporale per data non integrata.

## 6. Architettura approvata

V1-08 gestisce la conoscenza agronomica.

V1-09 interpreta la conoscenza e produce
valutazioni e raccomandazioni.

V1-10 e V1-11 utilizzano le valutazioni
nei rispettivi processi funzionali.

Non duplicare le regole agronomiche
nei singoli domini o nelle pagine Flutter.

## 7. Funzioni da consolidare

- Valutazione spaziale.
- Valutazione temporale.
- Rotazione botanica.
- Associazioni.
- Finestre agronomiche.
- Successioni.
- Fabbisogni familiari.
- Previsioni produttive.

Fabbisogni familiari e previsioni produttive
appartengono al perimetro aggiuntivo B.

## 8. Vincoli

- Non inventare dati agronomici.
- Non interpretare automaticamente
  un dato sconosciuto come neutrale.
- Non assumere che storico incompleto
  equivalga ad assenza di coltivazioni precedenti.
- Restituire esiti strutturati.
- Conservare la provenienza delle conoscenze.
- Non effettuare mutazioni operative automatiche.

## 9. Indicazioni per lo sviluppo futuro

RIUTILIZZARE:

- Componenti dei motori gia individuati.
- Contratti esistenti, dopo verifica mirata.

INTEGRARE:

- Resolver.
- Identita botaniche canoniche.
- Associazioni approvate.
- Storico effettivo.
- Geometrie e date.

VERIFICARE:

- Fallback.
- Punteggi.
- Pesi.
- Casi di conoscenza incompleta.
- Copertura dei test.

SVILUPPARE:

- Soltanto le capacita effettivamente mancanti
  dopo la riconciliazione RC13.

Non ricostruire integralmente i motori
senza motivazione tecnica documentata.

## 10. Limiti

Questa scheda recupera le evidenze STEP 273-274.

Non sostituisce la verifica dei contratti
e dei sorgenti specifici quando verranno modificati.

Livello complessivo del dominio:
da consolidare in RC13.
