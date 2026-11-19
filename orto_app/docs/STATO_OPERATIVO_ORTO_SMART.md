# ORTO SMART

### DOCUMENTO OPERATIVO V1

# Stato Operativo Orto Smart

**Versione:** 1.1 — Bozza
**Stato:** In sviluppo
**Prima emissione:** 19/11/2026
**Ultimo aggiornamento:** Da confermare alla pubblicazione
**Sessione di riferimento:** S044
**Repository:** ortosmart/orto-smart

---

# Informazioni sul documento

| Campo | Valore |
|---|---|
| Titolo | Stato Operativo Orto Smart |
| Versione | 1.1 — Bozza |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 19/11/2026 |
| Ultimo aggiornamento | Da confermare alla pubblicazione |
| Sessione | S044 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|---|---|---|
| 1.0 | 19/11/2026 | Prima emissione del documento operativo unico della V1 |
| 1.1 | Da confermare | Aggiornamento baseline S044, completamento B1, decisioni interfaccia, attività residue, stime e mappa tecnica |

---

# Indice

1. Scopo e modalità di aggiornamento
2. Baseline Git e qualità
3. Architettura e sicurezza
4. Database e migrazioni
5. Stato funzionale
6. Pianificazioni stagionali
7. Decisioni e vincoli
8. Attività aperte
9. Tempi di sviluppo e stime
10. Preparazione alla V1
11. Riferimenti e checkpoint
12. Mappa tecnica per la ripresa dello sviluppo

---

# 1. Scopo e modalità di aggiornamento

Il presente documento costituisce il riferimento operativo sintetico per lo sviluppo della V1 di Orto Smart. È gestito nella chat ufficiale di sviluppo e aggiornato ogni una o due sessioni, oppure quando intervengono modifiche significative.

Non sostituisce retroattivamente i manuali ufficiali esistenti. `DOC-000_Standard_Documentale.md` mantiene il proprio codice e la propria funzione. I checkpoint conservano separatamente la struttura approvata di dieci sezioni e ventiquattro indicatori grafici.

## 1.1 Memoria tecnica operativa

Il documento serve a riprendere lo sviluppo senza ricostruire ripetutamente struttura, componenti, contratti Flutter–Supabase, decisioni approvate, test, attività residue e prossimo intervento. Deve indicare i percorsi dei file rilevanti senza duplicarne interamente il contenuto.

## 1.2 Regole di aggiornamento

Aggiornare solo quanto effettivamente cambiato; distinguere implementato e verificato, implementato non collaudato, progettato/approvato, aperto e futuro. Non trasformare ipotesi o stime in risultati verificati.

---

# 2. Baseline Git e qualità

## 2.1 Repository

- Repository: `ortosmart/orto-smart`; applicazione Flutter nella cartella `orto_app`.
- Branch: `main`.
- HEAD verificato S044: `5678d49aeadf963cd715d8ba64e45bf8daee85fd`.
- Riferimento locale `origin/main`: identico a HEAD.
- Working tree alla verifica iniziale S044.001: pulito.
- Stato successivo: documento operativo V1.1 modificato e non ancora pubblicato; verificare nuovamente Git prima del commit.
- Ultimo commit che ha modificato il documento prima della bozza 1.1: `0a0cc81` — «S043: consolida stato operativo V1 e mappa tecnica».

La coincidenza con `origin/main` riguarda il riferimento locale: nella S044 non è stata effettuata una nuova interrogazione diretta del server GitHub.

## 2.2 Verifiche S044

| Verifica | Esito | STEP |
|---|---|---|
| `git status` | PASS — working tree pulito | S044.001 |
| `git rev-parse HEAD` | PASS — `5678d49` | S044.004 |
| `git rev-parse origin/main` | PASS — coincide con HEAD | S044.005 |
| `flutter analyze` | PASS — nessun problema | S044.006 |
| `flutter test` | PASS — 1.600/1.600 | S044.007 |
| `flutter test test/data/repositories/planned_planting_repository_test.dart` | PASS — 98/98 | S044.008 |
| `git diff --check` | PASS — nessun errore | S044.009 |

I 98 test specifici sono inclusi nella suite complessiva di 1.600 test e non vanno sommati.

## 2.3 Regola di verifica della baseline

All'inizio della sessione verificare lo stato Git e la qualità pertinente. Prima di una modifica: consultare questo documento, individuare il componente, leggere solo il codice necessario, rispettare i contratti, eseguire i test appropriati e aggiornare solo le sezioni cambiate. Non ripetere ricognizioni generali senza modifiche, anomalie o lacune concrete.
Dopo ogni commit e push, verificare con un controllo Git dedicato che il working tree sia pulito e che il riferimento locale `origin/main` coincida con `HEAD`.

---

# 3. Architettura e sicurezza

## 3.1 Tecnologie

- Flutter e Dart per il client.
- Supabase e PostgreSQL per il backend.
- Repository GitHub ortosmart/orto-smart.
- Applicazione V1 inizialmente monoutente.

## 3.2 Autorità di scrittura

Le operazioni protette utilizzano:

- autenticazione e autorizzazione;
- Row Level Security;
- RPC autoritative;
- Profile Write Authority;
- lock di modifica;
- identificativi client e sessione;
- controllo delle versioni dei record.

Le operazioni di scrittura devono rispettare il contratto
autoritativo del server.

---

# 4. Database e migrazioni

## 4.1 Baseline nota

- Migrazioni locali: 45.
- Migrazioni remote: 34.
- Migrazioni S039 non distribuite sul remoto: 11.

Questi valori provengono dal checkpoint ufficiale S043.570.

## 4.2 Regole operative

- Nessuna migrazione remota senza autorizzazione.
- Nessun dato fittizio permanente.
- Nessun popolamento agronomico non approvato.
- Collaudi SQL locali separati dall'ambiente remoto.

---

# 5. Stato funzionale

## 5.1 Componenti disponibili o in sviluppo

- Gestione orti, aiuole e geometrie, stagioni.
- Catalogo Agronomico V1 e pianificazioni stagionali.
- Coltivazioni e loro visualizzazione.
- Dashboard, irrigazione, attività, registrazioni operative, impostazioni e sicurezza.

Il livello di completamento varia tra i componenti; le percentuali sono indicatori progettuali, non misure automatiche del codice.

## 5.2 Indicatori generali — S044.010

| Indicatore | Avanzamento |
|---|---:|
| Completamento tecnico V1 | 73% |
| Prontezza operativa V1 | 40% |
| Percorso B complessivo | 38% |

## 5.3 Sedici aree V1

| Area | Avanzamento |
|---|---:|
| Gestione orti | 85% |
| Gestione aiuole | 85% |
| Gestione stagioni | 75% |
| Catalogo Agronomico | 75% |
| Pianificazioni | 72% |
| Conferma ed esecuzione Flutter | 65% |
| Visualizzazione coltivazioni | 65% |
| Raccolti | 15% |
| Registrazione lavori | 20% |
| Irrigazione manuale | 15% |
| Dashboard | 35% |
| Sicurezza e Write Authority | 85% |
| Migrazioni S039 remote | 0% |
| Collaudo primo utilizzo | 0% |
| Preparazione dati reali | 0% |
| Backup e ripristino | 0% |

---

# 6. Pianificazioni stagionali

## 6.1 Lifecycle SQL

Il lifecycle comprende creazione bozza, aggiornamento, conferma, annullamento ed esecuzione. Le RPC sono autoritative e verificano autorizzazioni, `row_version`, geometrie, sovrapposizioni e transizioni di stato. L'annullamento conserva lo storico; l'esecuzione crea la coltivazione atomicamente e impedisce la doppia esecuzione.

## 6.2 Integrazione Flutter

Il repository Flutter dispone delle cinque operazioni di scrittura, implementate e collaudate:

| Metodo | Stato |
|---|---|
| `createPlannedPlanting()` | Completato |
| `updatePlannedPlanting()` | Completato |
| `confirmPlannedPlanting()` | Completato |
| `cancelPlannedPlanting()` | Completato |
| `executePlannedPlanting()` | Completato |

La componente B1 riguarda esclusivamente il repository di **scrittura**; non implica il completamento dell'interfaccia o delle letture. Test repository S044: 98/98 PASS.

## 6.3 Funzioni ancora da integrare

- Metodi di lettura delle pianificazioni.
- Modello Flutter persistente per `planned_plantings` (distinto dal modello agronomico `PlannedPlantingBatch`).
- Consultazione di tutte le stagioni: il repository attuale dispone della lettura della stagione attiva, ma non ancora dell'elenco completo.
- Interfaccia lifecycle, elenco per aiuola e calendario.
- Gestione UI degli errori e dei conflitti di versione.
- Collaudo integrato Flutter–Supabase e percorso operativo completo di primo utilizzo.

## 6.4 Decisioni funzionali interfaccia — S043

| Tema | Scelta consolidata |
|---|---|
| Collocazione | Orto → Stagioni → Pianificazione |
| Visualizzazione | Combinata: elenco per aiuola e calendario |
| Stagioni | Tutte consultabili, attiva evidenziata |
| Creazione lotti | Dalla stagione e dall'aiuola |

Queste scelte orientano la progettazione; non rappresentano funzionalità UI già implementate.

---

# 7. Decisioni e vincoli

## 7.1 Decisioni consolidate

- Catalogo Agronomico strutturato, verificato e gestito con autorità definita.
- Fonti esterne e scraping producono dati candidati da revisionare, senza sovrascrivere il catalogo approvato.
- Nessun dato fittizio permanente; separazione tra test locali e dati reali.
- Scritture protette da RPC, RLS, Profile Write Authority, lock e versionamento.
- Conservazione dello storico delle pianificazioni e atomicità dell'esecuzione.
- Interfaccia pianificazioni secondo le quattro scelte riportate al §6.4.
- Nessuna distribuzione remota delle migrazioni S039 senza autorizzazione.

## 7.2 Gestione documentale temporanea V1

Durante la preparazione V1 viene mantenuto un documento operativo sintetico. Gli aggiornamenti ordinari dei manuali tradizionali sono sospesi fino alla pubblicazione V1; lo storico resta preservato. Aggiornare il documento ogni una o due sessioni, o in caso di cambiamenti importanti.

## 7.3 Evitare ricognizioni ripetitive

Non riaprire decisioni approvate e non rileggere integralmente strutture già documentate. Riesaminare solo quando il codice cambia, emerge un errore o una discrepanza, manca un dettaglio indispensabile o una nuova funzione richiede un contratto specifico. Mantenere analisi mirate e tracciabili.

---

# 8. Attività aperte

## 8.1 Percorso B

1. Definire il modello Flutter persistente delle pianificazioni.
2. Individuare e implementare i metodi di lettura necessari.
3. Integrare la consultazione di tutte le stagioni.
4. Progettare l'interfaccia delle pianificazioni rispettando §6.4.
5. Implementare elenco per aiuola e calendario.
6. Collegare creazione, aggiornamento, conferma, annullamento ed esecuzione alla UI.
7. Gestire errori, conflitti di versione e aggiornamento dati.
8. Eseguire collaudo integrato Flutter–Supabase.
9. Verificare il percorso minimo di primo utilizzo.

## 8.2 Preparazione V1

- Valutare le 11 migrazioni S039 prima dell'eventuale distribuzione autorizzata.
- Preparare dati reali approvati, senza seed permanenti di prova.
- Identificare le funzionalità indispensabili al primo utilizzo.
- Verificare backup e ripristino.
- Rivalutare la prontezza operativa sui risultati dei collaudi.

L'ordine operativo va confermato nelle sessioni di sviluppo; questo elenco non costituisce autorizzazione automatica alle modifiche.

---

# 9. Tempi di sviluppo e stime

## 9.1 Consuntivo S043

- Sviluppo netto: **12 h 06 min**.
- Sospensioni: **18 h 59 min**.
- Ultima sospensione: **19/11/2026 ore 17:29**.
- Non risulta una dichiarazione di chiusura definitiva della S043.

## 9.2 Sessione S044

- Apertura: **19/11/2026 ore 20:46**.
- Baseline verificata: checkpoint S044.010.
- Consuntivo netto: da calcolare alla sospensione o chiusura dell'intervallo.

## 9.3 Stime dei percorsi

| Percorso | Ore iniziali | Ore consuntivate | Residuo contabile | Residuo operativo stimato |
|---|---|---|---|---|
| A | Da recuperare | Da recuperare | Da verificare | Da verificare |
| B | Da recuperare | Da recuperare | Da verificare | Da rivalutare |
| Altri percorsi originari | Da identificare | Da recuperare | Da verificare | Da verificare |
| Totale | Da riconciliare | Da riconciliare | Da verificare | Da verificare |

### Evoluzione storica Percorso B

| Checkpoint | B1 residuo | Percorso B residuo |
|---|---|---|
| S043.320 | 6–9 h | 25–40 h |
| S043.390 | 3–6 h | 22–37 h |
| S043.440 | 1–4 h | 20–35 h |
| S043.650 | Completato | Da rivalutare |
| S043.720 | Completato | Da rivalutare |
| S044.000 | Completato | Da rivalutare |
| S044.010 | Completato | Da rivalutare |

### Stime iniziali delle componenti residue

| Componente | Stima storica |
|---|---:|
| Interfaccia Flutter | 9–15 h |
| Collaudo integrato | 6–10 h |
| Primo utilizzo operativo | 4–6 h |
| **Somma storica indicativa** | **19–31 h** |

La somma non è una previsione aggiornata. Rivalutare dopo la definizione del perimetro dell'interfaccia.

## 9.4 Consuntivo storico generale

Ultimo progressivo ufficiale disponibile alla S041: sviluppo **248 h 39 min**, manuali **98 h 54 min**, totale **347 h 33 min**. Il consuntivo S042 resta da riconciliare: non calcolare un nuovo progressivo generale senza i dati mancanti.

---

# 10. Preparazione alla V1

L'obiettivo iniziale del 15/11/2026 è stato superato. La finestra indicativa 16–22/11/2026 non è una data di pubblicazione garantita. La pubblicazione dipende dal percorso operativo minimo e dai collaudi effettivi. Non è stata approvata una nuova data ufficiale.

Privilegiare affidabilità e completezza delle funzioni indispensabili rispetto all'introduzione accelerata di nuove funzionalità.

---

# 11. Riferimenti e checkpoint

## 11.1 Riferimenti tecnici

- `DOC-000_Standard_Documentale.md`.
- Documentazione tecnica ufficiale già presente nel repository.
- Migrazioni SQL e test locali.
- Codice Flutter e relativi test.
- `docs/STATO_OPERATIVO_ORTO_SMART.md`.

## 11.2 Checkpoint di riferimento

- S043.560: baseline precedente al collaudo della conferma.
- S043.570: conferma Flutter collaudata.
- S043.574: commit `64e8981`.
- S043.575: push completato.
- S043.577: verifica standard documentale.
- S043.650: completamento B1 e verifiche tecniche.
- S043.720: checkpoint ufficiale di avanzamento.
- S043.725: ultimo STEP documentato della S043.
- S044.000: apertura e ricezione baseline.
- S044.010: verifiche Git, Flutter e repository confermate.

Il documento registra lo stato consolidato, senza sostituire i checkpoint analitici.

---

# 12. Mappa tecnica per la ripresa dello sviluppo

## 12.1 Pianificazioni stagionali

### Repository e contratti Flutter

| Componente | File | Responsabilità |
|---|---|---|
| Repository pianificazioni | `lib/data/repositories/planned_planting_repository.dart` | Operazioni e RPC pianificazioni |
| Risultati tipizzati scritture | `lib/core/write_authority/planned_planting_write_result.dart` | Contratti risultati di scrittura |
| Modello batch agronomico | `lib/core/agronomy/models/planned_planting_batch.dart` | Batch agronomici, **non** record persistenti |
| Validatore batch | `lib/core/agronomy/planned_planting_batch_validator.dart` | Validazione agronomica batch |
| Test repository | `test/data/repositories/planned_planting_repository_test.dart` | Test delle operazioni repository |

Il `SeasonRepository` consente di recuperare la stagione attiva; manca il metodo per elencare tutte le stagioni. Il percorso esatto del file va verificato solo al momento dell'intervento, senza ipotizzarlo.

### RPC e migrazioni

| Operazione | Migrazione |
|---|---|
| Aggiornamento | `20261104220000_add_update_planned_planting_rpc.sql` |
| Correzione geometria creazione | `20261104221500_fix_create_planned_planting_geometry.sql` |
| Conferma | `20261104223000_add_confirm_planned_planting_rpc.sql` |
| Protezione pianificazioni confermate | `20261104224500_protect_confirmed_planned_planting_updates.sql` |
| Annullamento | `20261104233000_add_cancel_planned_planting_rpc.sql` |
| Esecuzione atomica | `20261105000000_add_atomic_planned_planting_execution.sql` |

Migrazioni in `supabase/migrations/`; collaudo SQL in `supabase/tests/s040_planned_planting_lifecycle.sql`.

### Collaudi

- Test Flutter completi: 1.600/1.600 PASS in S044.
- Test repository: 98/98 PASS in S044.
- `flutter analyze`: PASS in S044.
- HEAD verificato: `5678d49`.
- Collaudo SQL lifecycle: eseguito in sessioni precedenti, non ripetuto nella S044.
- Collaudo integrato Flutter–Supabase: **da eseguire**.

### Stato di implementazione

| Funzione | Stato |
|---|---|
| Creazione pianificazione — repository di scrittura | Completata e collaudata |
| Aggiornamento pianificazione — repository di scrittura | Completata e collaudata |
| Conferma pianificazione — repository di scrittura | Completata e collaudata |
| Annullamento pianificazione — repository di scrittura | Completata e collaudata |
| Esecuzione pianificazione — repository di scrittura | Completata e collaudata |
| Metodi di lettura pianificazioni | Mancanti |
| Modello persistente Flutter | Mancante |
| Elenco completo stagioni | Mancante |
| Interfaccia lifecycle | Mancante |
| Collaudo integrato con Supabase | Mancante |

### Contratti e vincoli da preservare

RPC autoritative, Profile Write Authority, client/session identity, lock token, `row_version`, RLS, transizioni valide, protezioni geometriche, atomicità, prevenzione doppia esecuzione e conservazione dello storico.

### Regola per le sessioni successive

1. Consultare questa mappa prima di iniziare.
2. Riutilizzare componenti e contratti verificati.
3. Leggere solo i file necessari al cambiamento.
4. Eseguire test mirati e controlli finali.
5. Aggiornare solo le sezioni effettivamente mutate.

Non ripetere ricognizioni generali senza modifiche, anomalie o discrepanze concrete.

## 12.2 Prossimo intervento

**Progettazione Flutter dell'interfaccia pianificazioni**, senza presupporre modifiche già autorizzate.

- Percorso: **Orto → Stagioni → Pianificazione**.
- Vista combinata: elenco per aiuola e calendario.
- Stagioni tutte consultabili, attiva evidenziata.
- Creazione lotti dalla stagione e dall'aiuola.
- Dipendenze: letture repository, modello persistente, elenco stagioni, integrazione risultati RPC nella UI.

**Ripresa operativa:** consultare questa sezione, individuare la prima dipendenza concreta, verificare solo i file coinvolti, proporre una modifica circoscritta, attendere autorizzazione, implementare e collaudare.

Nessuna distribuzione delle migrazioni sul remoto è autorizzata.

---

# Considerazioni finali

Lo sviluppo della V1 prosegue sulla base dei risultati
verificati e delle decisioni approvate.

Le attività ancora aperte non devono essere considerate
completate fino al relativo collaudo.

Il documento sarà aggiornato in modo incrementale,
evitando duplicazioni e ricostruzioni non necessarie.
---
