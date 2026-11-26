# TST-S046-001 - Baseline dei collaudi

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 271 e checkpoint S045
- Commit: 20649de7474765bd1c293b20bfcedab0a9493a14
- Ambiente: sviluppo locale
- Livello: E4 limitatamente alle verifiche eseguite

## 1. Verifiche iniziali S046

| Controllo | Risultato |
|---|---|
| flutter analyze | PASS |
| Problemi rilevati | 0 |
| Durata analyze | 18,7 secondi |
| flutter test | PASS |
| Test superati | 1956/1956 |
| Durata test | 2 minuti e 59 secondi |
| Allineamento Git | Confermato |
| Working tree iniziale | Pulito |

## 2. Evidenze integrate provenienti da S045

Ambiente: Microsoft Edge e Supabase locale.

Ciclo delle mutazioni delle pianificazioni stagionali:

- Creazione: verificata.
- Aggiornamento: verificato.
- Conferma: verificata.
- Esecuzione: verificata.
- Annullamento: verificato.

Risultato: 5/5 operazioni.

Ricevute COMPLETED rilevate: 6.

Evidenze acquisite:

- Pianificazione eseguita collegata alla coltivazione.
- Pianificazione annullata senza coltivazione collegata.
- Recupero mediante una RPC di lettura.
- Nessuna nuova mutazione durante il recupero.
- Nessuna operazione residua da verificare.
- Rimozione dei nove record temporanei del collaudo.
- Conservazione dell'orto preesistente.
- Conservazione delle sei ricevute locali.

## 3. Limiti delle evidenze

Il superamento dei 1956 test non equivale
all'accettazione operativa dell'intera applicazione.

Le verifiche integrate S045 riguardano
il ciclo delle mutazioni delle pianificazioni
nell'ambiente locale utilizzato.

Non attestano automaticamente:

- Operativita sul database remoto.
- Compatibilita completa con iPad Safari.
- Copertura di tutti i domini V1.
- Assenza di condizioni di concorrenza non collaudate.
- Accettazione operativa con dati reali.

## 4. Riutilizzo futuro

Consultare questa scheda prima di ripetere
collaudi gia acquisiti.

Ripetere le verifiche quando necessario per:

- Modifiche ai componenti interessati.
- Regressione.
- Variazione dell'ambiente.
- Variazione delle migrazioni.
- Nuove integrazioni.
- Accettazione del rilascio.

Mantenere distinti i test unitari, widget,
SQL, integrati e operativi.
