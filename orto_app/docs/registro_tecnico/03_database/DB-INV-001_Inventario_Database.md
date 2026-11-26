# DB-INV-001 - Inventario database

## Metadati

- Sessione: S046
- Data: 26/11/2026
- Provenienza: STEP 273
- Baseline: 20649de7474765bd1c293b20bfcedab0a9493a14
- Ambiente: Supabase locale
- Stato: inventario iniziale da consolidare mediante RC

## 1. Consistenza rilevata

| Elemento | Quantita |
|---|---:|
| Tabelle applicative public | 38 |
| Tabelle private delle mutazioni | 3 |
| Tabelle applicative complessive | 41 |
| Tabelle del Catalogo Agronomico | 26 |
| Tabelle operative public | 8 |
| Tabelle profili, sicurezza e operatori | 4 |
| Funzioni public rilevate | 104 |
| Funzioni private rilevate | 67 |
| Funzioni complessive rilevate | 171 |
| Tabelle applicative con RLS | 41 |
| Policy RLS rilevate | 40 |

I conteggi rappresentano la fotografia acquisita
durante la ricognizione S046.

Non equivalgono al numero di funzionalita operative.

## 2. Infrastrutture di dominio

Domini con strutture backend gia individuate:

- Profili e appartenenze.
- Operatori.
- Write Authority e lock.
- Orti.
- Aiuole.
- Storico delle geometrie.
- Stagioni.
- Catalogo Agronomico.
- Pianificazioni stagionali.
- Coltivazioni effettive.
- Ricevute e riconciliazione delle mutazioni.

## 3. Sicurezza

RLS rilevata sulle 41 tabelle applicative.

Privilegi authenticated rilevati nello STEP 273:

- SELECT a livello tabella: 37 tabelle.
- INSERT a livello tabella: workers.
- UPDATE a livello tabella: nessuno.
- DELETE a livello tabella: nessuno.
- TRUNCATE a livello tabella: nessuno.

ATTENZIONE:

I privilegi a livello tabella non escludono
concessioni sulle singole colonne.

RC01 ha successivamente confermato privilegi
diretti di aggiornamento su profiles e workers.

Riferimento: NC-RC01-001.

Non utilizzare l'inventario iniziale come prova
dell'assenza assoluta di scritture dirette.

## 4. Domini non ancora operativi

Non risultavano implementazioni operative complete
per i seguenti macroblocchi:

- V1-12 Raccolti.
- V1-13 Attivita, lavori e diario.
- V1-14 Irrigazione.
- V1-19 Gestione economica.
- V1-20 Meteorologia.
- V1-21 Fertilizzazioni e trattamenti.

La presenza di infrastrutture condivise o della
tabella workers non equivale al completamento
dei relativi domini.

## 5. Riconciliazioni di approfondimento

- RC01: identita e profili.
- RC02: Write Authority.
- RC03: RLS, privilegi e RPC.
- RC04: versionamento e concorrenza.
- RC05: journal e ricevute.
- RC06: backup e ripristino.
- RC07: migrazioni.
- RC08: geometrie.
- RC09: stagioni.
- RC10-RC12: Catalogo Agronomico.
- RC14: pianificazioni.
- RC15: coltivazioni.

Le schede specifiche costituiscono la fonte
principale per i dettagli dei singoli componenti.

## 6. Limiti

Inventario recuperato dalla ricognizione STEP 273.

Non contiene ancora la mappa completa
delle 171 funzioni e delle loro dipendenze.

Le verifiche remote devono essere mantenute distinte
dalle evidenze acquisite sul database locale.

Non ripetere i conteggi salvo variazioni dello schema
o necessita di rivalidazione.
