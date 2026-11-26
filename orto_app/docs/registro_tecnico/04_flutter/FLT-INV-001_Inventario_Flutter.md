# FLT-INV-001 - Inventario architettura Flutter

## Metadati

- Sessione: S046
- Provenienza: STEP 273
- Data: 26/11/2026
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Stato: inventario iniziale

## 1. Consistenza

File rilevati nella directory lib: 155.

Il numero di file non rappresenta una misura
della maturita funzionale dell'applicazione.

## 2. Infrastrutture disponibili

- Inizializzazione Supabase.
- Autenticazione.
- AuthGate.
- Identita persistente del client.
- Identita della sessione.
- ProfileContext.
- ProfileSessionGate.
- ProfileWriteAuthorityController.
- ProfileWriteAuthorityScope.
- Scheduler della Write Authority.
- Repository dei lock.
- Modelli e repository di dominio.
- Coordinamento delle mutazioni.
- Journal persistente delle mutazioni.
- Servizio delle mutazioni delle pianificazioni.
- Trasporto delle mutazioni delle pianificazioni.

Le schede RC01, RC02 e RC05 devono contenere
i contratti e i percorsi esatti dei componenti.

## 3. Copertura dei percorsi funzionali esaminati

| Dominio | Backend | Repository | UI |
|---|---:|---:|---:|
| Orti | 3/3 | 2/3 | 2/3 |
| Aiuole | 7/7 | 7/7 | 7/7 |
| Stagioni | 5/5 | 5/5 | 2/5 |
| Pianificazioni | 6/6 | 6/6 | 6/6 |
| Coltivazioni | 4/4 | 4/4 | 4/4 |
| Totale | 25/25 | 24/25 | 21/25 |

I conteggi riguardano il perimetro delle operazioni
selezionate durante la ricognizione STEP 273.

Non costituiscono accettazione operativa
dei domini completi.

Le due RPC di recupero delle pianificazioni
sono considerate separatamente dal conteggio.

## 4. Integrazioni mancanti individuate

Orti:

- RPC di aggiornamento disponibile.
- Integrazione repository e UI da completare.

Stagioni:

- Creazione tramite UI da completare.
- Modifica tramite UI da completare.
- Attivazione tramite UI da completare.

Pianificazioni:

- Ciclo delle mutazioni integrato localmente.
- Presentazione funzionale ancora incompleta.
- Calendario e raggruppamento da completare.
- Informazioni agronomiche e spaziali da integrare.
- Accettazione operativa ancora aperta.

Coltivazioni:

- Percorsi selezionati disponibili.
- Verifiche agronomiche e operative da consolidare.

## 5. Navigazione

| Sezione | Stato rilevato |
|---|---|
| Dashboard | Placeholder |
| Orto | Funzionalita parzialmente integrate |
| Irrigazione | Placeholder |
| Attivita | Placeholder |
| Impostazioni | Catalogo e Documentazione |

Il manuale utente risultava limitato
alla parte introduttiva, 1 sezione su 10.

## 6. Catalogo Agronomico

Consultare:

../02_infrastrutture/INF-CAT-001_Catalogo_Agronomico.md

## 7. Motori agronomici

Consultare:

../02_infrastrutture/INF-AGR-001_Motori_Agronomici.md

## 8. Riutilizzo futuro

Prima di creare nuovi repository, servizi,
controller o componenti di sicurezza:

- Consultare le schede delle infrastrutture.
- Individuare il contratto gia disponibile.
- Verificare le variazioni dei sorgenti.
- Distinguere riutilizzo e integrazione.
- Evitare implementazioni parallele.

## 9. Limiti

I dettagli delle firme e dei percorsi
non ancora acquisiti devono rimanere NV.

Non dedurre la completezza funzionale
dalla sola presenza di classi o pagine.
