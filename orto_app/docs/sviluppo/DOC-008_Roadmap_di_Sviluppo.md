# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 3.1

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 05/11/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 3.1 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 05/11/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|-----------|------------|------------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione della Roadmap di Sviluppo |
| 0.2 | 27/07/2026 | Aggiornamento della roadmap dopo la Sessione S004 |
| 0.3 | 01/08/2026 | Revisione della struttura documentale e aggiornamento della roadmap |
| 1.0 | 01/08/2026 | Revisione completa e approvazione della Roadmap di Sviluppo |
| 1.1 | 08/08/2026 | Aggiornamento del Motore Agronomico e pianificazione delle evoluzioni successive |
| 1.2 | 16/08/2026 | Aggiornamento dopo la Sessione S017: completamento e congelamento della progettazione Database V1, pianificazione dell'implementazione incrementale in Supabase e riallineamento delle priorità di sviluppo |
| 1.3 | 16/08/2026 | Aggiornamento dopo la Sessione S018: completamento dei prerequisiti locali Supabase, consolidamento delle finestre agronomiche multiple e definizione dello STEP 35.3 come punto di avvio della baseline SQL Database V1 |
| 1.4 | 18/08/2026 | Aggiornamento dopo la Sessione S019: prima migration Database V1, implementazione e verifica locale delle Fondazioni, prima matrice di 13 policy RLS e definizione delle RPC sicure e atomiche come prossimo incremento tecnico |
| 1.5 | 28/08/2026 | Aggiornamento dopo la Sessione S023: completamento del protocollo `profile_edit_locks`, Write Path autoritativi di `gardens` e `seasons`, integrazione Flutter della Profile Write Authority e definizione di `beds` e `bed_geometries` come prossimo blocco tecnico |
| 1.6 | 01/09/2026 | Aggiornamento dopo la Sessione S024: completamento del Write Path autoritativo di `beds`, implementazione della geometria storicizzata, integrazione Flutter della creazione dell’aiuola e rinvio della scelta del successivo blocco tecnico |
| 1.7 | 03/09/2026 | Manutenzione straordinaria della Roadmap: normalizzazione del nome dell’autore nei metadati del documento |
| 1.8 | 06/09/2026 | Aggiornamento dopo la Sessione S025: completamento dell’integrazione Flutter dei Write Path autoritativi di `beds`, introduzione delle interfacce di modifica e gestione geometrica, gestione italiana delle date, rilettura autoritativa e verifica con 841/841 test superati |
| 1.9 | 11/09/2026 | Aggiornamento dopo la Sessione S026: implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, nove RPC autoritative, RLS, Profile Write Authority, concorrenza ottimistica, validazioni gerarchiche e agronomiche e definizione della S027 come integrazione Flutter del Catalogo V1 |
| 2.0 | 14/09/2026 | Aggiornamento dopo la Sessione S027: completamento dell'integrazione Flutter del Catalogo V1, introduzione di `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository e result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version`, compatibilità legacy controllata e verifica con 914/914 test; prossimo incremento tecnico non ancora approvato |
| 2.1 | 17/09/2026 | Aggiornamento dopo la Sessione S028: implementazione del modello e Write Path autoritativo di `plantings`, lifecycle server-side, geometria e overlap spaziale/temporale, protezione delle geometrie delle aiuole mediante `blocked_by_plantings`, integrazione Flutter e verifica con 997/997 test; definizione preliminare della S029 come lifecycle e varietà delle coltivazioni, non ancora iniziata |
| 2.2 | 18/09/2026 | Aggiornamento dopo la Sessione S029: completamento della UI del lifecycle di `plantings`, gestione esplicita di `end_date` per gli stati terminali, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`; nessuna modifica al contratto persistente S028; consolidamento preparatorio del futuro Catalogo Agronomico V1 e della possibile S030, non ancora iniziata |
| 2.3 | 27/09/2026 | Aggiornamento dopo la Sessione S030: completamento dell'architettura e del cutover del Catalogo Agronomico V1 globale, introduzione di identità botaniche canoniche, Catalog Authority, fonti e acquisizioni, workflow editoriale, Knowledge agronomica canonica, pubblicazione e Resolver; migrazione finale a `botanical_taxa` → `crops` → `crop_cultivars`, integrazione Flutter, deploy remoto e verifica finale con 953 test superati; riallineamento delle attività future alla fase successiva alla S030 |
| 2.4 | 01/10/2026 | Aggiornamento dopo la Sessione S031: integrazione operativa Flutter del Catalogo Agronomico nelle Impostazioni, gestione dello stato e dell'inizializzazione controllata della Catalog Authority, esposizione delle capability autoritative, consultazione delle colture globali, navigazione gerarchica `Coltura → Cultivar`, caricamento on demand delle cultivar, gestione degli stati di caricamento/assenza dati/errore/retry ed eliminazione del precedente percorso autonomo `Impostazioni → Varietà`; verifica finale con 971 test superati e definizione della ricognizione tecnica delle funzioni, RPC e capability del Catalogo come primo passo della S032 |
| 2.5 | 06/10/2026 | Aggiornamento dopo la Sessione S032: ricognizione e consolidamento del contratto backend del Catalogo Agronomico, verifica della tassonomia botanica globale con rank `ORDER`, `FAMILY`, `GENUS`, `SPECIES`, `SUBSPECIES`, `VARIETY`, `FORMA` e `UNRANKED`, conferma della Cultivar come identità agronomica separata, integrazione Flutter dei Write Path di Tassonomia, Crop e Cultivar, collegamento opzionale `Crop → Taxon`, completamento della UI della Classificazione botanica, gestione della Catalog Authority, concorrenza ottimistica mediante `row_version`, rilettura autoritativa su `version_conflict` ed esiti incerti e verifica finale con `flutter analyze` senza problemi e 1077/1077 test superati; nessuna nuova migration S032 e riallineamento della roadmap futura allo stato effettivamente raggiunto |
| 2.6 | 12/10/2026 | Aggiornamento dopo le Sessioni S033/S033B: completamento della Fase A Flutter dei Registri Agronomici, HUB e pagine dedicate a Classificazione botanica e Colture/Cultivar, verifica con 1107/1107 test Flutter superati e `flutter analyze` senza problemi; ricognizione statica di 21/21 RPC degli ulteriori Registri Agronomici e audit locale dei Write Path di `plantings`, favorevole nel perimetro esaminato e senza correzioni immediate; aggiornamento delle attività FUTURE e registrazione dell'obiettivo iniziale approvato per la S034, non ancora iniziata |
| 2.7 | 17/10/2026 | Aggiornamento dopo S034 e S035: correzione locale SQLSTATE 55000 nel Catalog Registry, applicata al database locale e non al remoto; integrazione Flutter delle Finalità di raccolta, 42 test mirati superati e `flutter analyze` senza problemi; aggiornamento dello stato dei Registri Agronomici e delle verifiche aperte, senza assegnazioni automatiche alla sessione successiva |
| 2.8 | 21/10/2026 | Aggiornamento dopo la Sessione S036: protezione Flutter dalle richieste duplicate di attivazione/disattivazione delle Finalità di raccolta; sei test SQL locali di regressione del Catalog Registry superati; `flutter analyze` senza problemi e 1.292 test Flutter superati; aggiornamento delle verifiche ancora aperte, senza assegnazioni automatiche alla sessione successiva. |
| 2.9 | 26/10/2026 | Aggiornamento dopo S037: audit statici Alias e integrità Taxon/Crop, protezione delle scritture concorrenti in BedPage, verifiche Flutter e definizione dell'obiettivo approvato di primo utilizzo reale per la pianificazione dell'orto 2027 entro il 15/11/2026, subordinato a verifica di fattibilità e senza assegnazioni automatiche alla S038. |
| 3.0 | 03/11/2026 | Aggiornamento dopo la Sessione S038: introduzione del contratto tipizzato e del repository Flutter del Resolver Agronomico; integrazione dei Registri Unità di misura e Parametri agronomici, con 3/7 Registri Agronomici Flutter implementati; applicazione remota della migration correttiva S034 e allineamento di 34/34 migration; verifiche integrative con 178/178 test Flutter mirati superati e `flutter analyze` senza problemi; aggiornamento delle attività FUTURE e dello stato dell'obiettivo di primo utilizzo reale entro il 15/11/2026, ancora subordinato a verifica di fattibilità. |
| 3.1 | 05/11/2026 | Aggiornamento della Roadmap dopo la Sessione S039: introduzione del modello autoritativo di pianificazione stagionale mediante `season_plans` e `planned_plantings`, cinque RPC per il ciclo di vita e l'esecuzione atomica delle coltivazioni pianificate, protezioni geometriche e temporali e collegamento alle coltivazioni reali; registrazione delle undici migration SQL applicate esclusivamente al database locale, delle verifiche statiche SQL, di `flutter analyze` senza problemi e di 1472/1472 test Flutter superati. Aggiornamento delle attività ancora aperte: collaudi SQL dinamici, deployment remoto e integrazione Flutter della pianificazione. Confermato l'obiettivo di primo utilizzo reale entro il 15/11/2026 come traguardo subordinato alla verifica di fattibilità, senza garanzia di completamento e senza assegnazioni automatiche alla sessione successiva. Versioni applicative invariate. |

---

# Indice

## 1. Scopo

## 2. Stato del progetto

## 3. Roadmap generale

3.1 Architettura
3.2 Gestione orto
3.3 Motore Agronomico
3.4 Irrigazione
3.5 Dashboard
3.6 Attività
3.7 Statistiche
3.8 Versioni future

## 4. Prossime attività

---

# 1. Scopo

La **Roadmap di Sviluppo** descrive l'evoluzione prevista del progetto **Orto Smart**.

Il documento rappresenta il riferimento ufficiale per la pianificazione delle attività di sviluppo e viene aggiornato al termine delle principali sessioni di lavoro.

Le funzionalità sono organizzate in macro-aree e classificate in base al loro stato di avanzamento.

---

# 2. Stato del progetto

| Stato | Significato |
|--------|-------------|
| ✅ Completato | Funzionalità implementata e verificata |
| 🚧 In sviluppo | Funzionalità attualmente in lavorazione |
| 📋 Pianificato | Funzionalità prevista nelle prossime versioni |
| 💡 Idea | Possibile sviluppo futuro |

---

# 3. Roadmap generale

## 3.1 Architettura

## 3.1 Architettura

| Funzionalità | Stato |
|---|---|
| Struttura Flutter | ✅ Completato |
| Supabase | ✅ Completato |
| Repository Pattern | ✅ Completato |
| Modelli | ✅ Completato |
| Progettazione Database V1 | ✅ Completato |
| Implementazione Database V1 in Supabase | 🚧 In sviluppo, incrementale |
| Architettura Catalogo Agronomico V1 globale | ✅ Completato |
| Identità botaniche canoniche globali | ✅ Completato |
| Catalog Authority e capability autoritative | ✅ Completato |
| Fonti, acquisizioni e osservazioni agronomiche | ✅ Completato a livello backend |
| Workflow editoriale agronomico backend | ✅ Completato |
| Knowledge agronomica canonica | ✅ Completato |
| Pubblicazione e versionamento della Knowledge | ✅ Completato |
| Resolver canonico del Catalogo Agronomico — backend S030 | ✅ Completato |
| Contratto tipizzato del Resolver Agronomico Flutter — S038 | ✅ Implementato e verificato con test mirati |
| Repository Flutter del Resolver Agronomico e RPC `resolve_agronomic_knowledge` — S038 | ✅ Implementato e verificato con test mirati |
| Integrazione completa del Resolver nei flussi operativi di pianificazione e inserimento | 📋 FUTURE, non completata |
| Cutover canonico `botanical_taxa` → `crops` → `crop_cultivars` | ✅ Completato |
| Integrazione Flutter del Catalogo nelle Impostazioni | ✅ Completato |
| Consultazione delle colture globali | ✅ Completato |
| Navigazione gerarchica `Coltura → Cultivar` | ✅ Completato |
| Caricamento on demand delle cultivar | ✅ Completato |
| Gestione UI di loading, empty state, errore e retry del Catalogo | ✅ Completato |
| Integrazione Flutter Write Path Tassonomia | ✅ Completato |
| Integrazione Flutter Write Path Crop | ✅ Completato |
| Integrazione Flutter Write Path Cultivar | ✅ Completato |
| UI di gestione della Classificazione botanica | ✅ Completato |
| HUB Registri Agronomici Flutter | ✅ Completato |
| Pagina dedicata Classificazione botanica | ✅ Completato |
| UI di gestione Crop | ✅ Completato nella Fase A S033 |
| UI di gestione Cultivar | ✅ Completato nella Fase A S033 |
| Pagina dedicata Colture e Cultivar | ✅ Completato |
| Consolidamento Flutter Fase A Registri Agronomici | ✅ Completato |
| Ricognizione statica delle 21 RPC degli ulteriori Registri Agronomici | ✅ Completato nel perimetro S033B |
| Gestione Flutter delle Finalità di raccolta (`harvest_purposes`) | ✅ Implementata in S035 e consolidata in S036; collaudo integrato ancora aperto |
| Gestione Flutter delle Unità di misura (`measurement_units`) | ✅ Modelli, repository e pagina implementati in S038; verifiche Flutter mirate superate |
| Gestione Flutter dei Parametri agronomici (`agronomic_parameters`) | ✅ Modelli, repository e pagina implementati in S038; verifiche Flutter mirate superate |
| Integrazione amministrativa Flutter dei quattro registri rimanenti (`parameter_enum_values`, `production_contexts`, `protection_contexts`, `training_contexts`) | 📋 FUTURE, da valutare e approvare |
| Correzione `SQLSTATE 55000` delle tre RPC Catalog Registry | ✅ Migration S034 applicata localmente; sei test SQL locali superati in S036; applicazione remota effettuata in S038 |
| Verifica integrata Flutter–Supabase dei registri amministrativi | 📋 Ancora aperta |
| Allineamento migration locali e remote alla chiusura S038 | ✅ 34/34 verificate |
| Audit locale dei Write Path di `plantings` | ✅ Completato nel perimetro S033B |
| Ulteriori verifiche runtime, concorrenza ed end-to-end | 📋 Da valutare secondo necessità |
| UI operativa per alias, fonti, candidati, revisione e pubblicazione | 📋 Pianificato |
| Workflow operativo di aggiornamento/importazione delle fonti | 📋 Pianificato |
| Popolamento verificato del Catalogo Agronomico | 📋 Pianificato |

La tabella distingue i risultati implementativi e le verifiche automatiche dalla validazione operativa integrata. Il superamento dei test Flutter mirati e l'allineamento delle migration non equivalgono a un collaudo completo dei percorsi applicativi con il backend Supabase.

Alla conclusione della S038 risultano integrati a livello Flutter **tre dei sette Registri Agronomici** censiti nella S033B. I quattro rimanenti non sono automaticamente assegnati alla sessione successiva.

### Evoluzione architetturale S030

La S030 ha completato l'architettura del **Catalogo Agronomico V1 globale**, il modello persistente, i Write Path autoritativi previsti dal relativo workflow, la Catalog Authority, il workflow editoriale, la Knowledge canonica, la pubblicazione, il Resolver e il cutover finale al modello:

```text
botanical_taxa
→ crops
→ crop_cultivars
```

### Evoluzione applicativa S031

La S031 ha completato il primo incremento operativo Flutter successivo al cutover, introducendo il percorso:

```text
Impostazioni
→ Catalogo Agronomico
→ Colture
→ Cultivar
```

L'integrazione S031 comprende:

- lettura dello stato della Catalog Authority;
- inizializzazione controllata dell'authority quando consentita dal backend;
- visualizzazione delle capability autoritative;
- consultazione delle colture globali;
- caricamento delle cultivar soltanto dopo la selezione della coltura;
- gestione degli stati di caricamento, assenza dati, errore e retry;
- eliminazione del precedente percorso autonomo `Impostazioni → Varietà`.

### Consolidamento delle identità S032

La S032 ha eseguito la ricognizione tecnica del contratto backend effettivamente disponibile e ha verificato che il Catalogo dispone già dei Write Path autoritativi necessari alla gestione delle identità globali.

La tassonomia botanica globale utilizza i rank canonici:

```text
ORDER
FAMILY
GENUS
SPECIES
SUBSPECIES
VARIETY
FORMA
UNRANKED
```

`CULTIVAR` non costituisce un rank tassonomico. Le cultivar sono identità agronomiche globali separate, persistite in `crop_cultivars`.

La tassonomia supporta una classificazione parziale mediante `parent_taxon_id`: non è necessario introdurre artificialmente tutti i livelli intermedi quando non sono disponibili.

Le regole relative a gerarchia, cicli, stato attivo e dipendenze rimangono autoritative lato backend.

La S032 ha integrato nel livello Flutter i Write Path di:

```text
Tassonomia
Crop
Cultivar
```

e ha completato la gestione UI della **Classificazione botanica**, comprendendo:

- lettura;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- applicazione della capability `can_manage_identity`;
- gestione degli stati di errore;
- rilettura dello stato autoritativo dopo conflitti o esiti incerti.

La terminologia UI consolidata per la tassonomia è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Il collegamento tra Crop e tassonomia è opzionale e segue il contratto:

```text
Crop → Taxon
```

La concorrenza ottimistica utilizza `row_version`.

In presenza di `version_conflict` l'applicazione non deve eseguire overwrite forzati né retry automatici. Deve invece rileggere lo stato autoritativo e presentare all'utente lo stato effettivamente persistito.

La stessa regola di sicurezza si applica quando l'esito di una scrittura è incerto a causa di un errore di comunicazione: il client non deve ripetere automaticamente l'operazione, ma deve prima verificare lo stato autoritativo.

Il backend rimane l'autorità per:

- autorizzazioni;
- capability;
- normalizzazione;
- unicità;
- gerarchia tassonomica;
- prevenzione dei cicli;
- dipendenze;
- stato attivo/inattivo;
- invarianti delle identità.

Flutter non deve duplicare tali regole introducendo vincoli applicativi ulteriori non previsti dal contratto backend.

Alla chiusura della S032 rimanevano ancora da completare le UI di gestione Crop e Cultivar, insieme agli ulteriori flussi amministrativi ed editoriali del Catalogo.

Tale stato è storico: le UI Crop e Cultivar sono state successivamente completate nella Fase A S033.

### Completamento della Fase A Flutter S033

La S033 ha completato la Fase A dei Registri Agronomici Flutter attraverso quattro incrementi:

- **A1 — HUB Registri Agronomici:** integrazione della navigazione;
- **A2 — Classificazione botanica:** estrazione della gestione in una pagina dedicata;
- **A3 — Colture e Cultivar:** gestione applicativa in una pagina dedicata;
- **A4 — Consolidamento:** verifica complessiva della Fase A.

L'organizzazione applicativa risultante è:

```text
HUB Registri Agronomici
    ├── Classificazione botanica
    └── Colture e Cultivar
```

Le interfacce di gestione Crop e Cultivar comprendono, nel perimetro verificato:

- lettura;
- creazione;
- modifica;
- disattivazione;
- riattivazione;
- gestione delle capability;
- gestione dei conflitti e degli esiti incerti;
- rilettura dello stato autoritativo.

Rimangono validi i principi:

```text
backend autoritativo
Catalog Authority
row_version
nessun overwrite forzato
nessun retry automatico dopo esito incerto
rilettura autoritativa
```

La verifica conclusiva S033 ha registrato:

```text
HUB Registri Agronomici       11/11
Colture e Cultivar            38/38
Fase A                        80/80
Suite Flutter complessiva   1107/1107

flutter analyze
No issues found
```

I conteggi delle suite mirate sono parzialmente sovrapposti e non devono essere sommati.

Il completamento della Fase A non equivale al completamento dell'intero sistema amministrativo ed editoriale del Catalogo Agronomico.

### Ricognizione e audit locale S033B

La prosecuzione S033B ha effettuato una ricognizione statica delle RPC degli ulteriori Registri Agronomici.

Sono state censite **21/21 RPC** nel perimetro:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

La disponibilità delle RPC non equivale alla presenza delle corrispondenti interfacce Flutter.

Nel perimetro esaminato non risultavano ancora modelli e repository Flutter dedicati a tali registri.

La S033B ha inoltre esaminato localmente le RPC:

```text
create_planting
update_planting
set_planting_status
```

L'audit ha verificato, nel perimetro esaminato:

- configurazione `SECURITY DEFINER`;
- owner `postgres`;
- privilegi di esecuzione;
- RLS e policy di lettura;
- assenza di scritture dirette per i normali ruoli applicativi;
- trigger di aggiornamento e versionamento;
- meccanismi di Profile Write Authority, lock e concorrenza.

L'esito è stato favorevole limitatamente al perimetro locale verificato.

Non sono stati effettuati nuovi test runtime di scrittura, test di concorrenza, test end-to-end Flutter/Supabase o verifiche sul database remoto.

Non sono emersi difetti dimostrati tali da giustificare correzioni immediate.

La S033B non ha introdotto modifiche persistenti a Flutter, SQL, migration o database.

### Stato architetturale dopo S033/S033B

Alla conclusione dello sviluppo S033/S033B:

- la Fase A Flutter dei Registri Agronomici è completata;
- la gestione di Classificazione botanica, Colture e Cultivar è disponibile nel perimetro implementato;
- il backend canonico del Catalogo Agronomico rimane autoritativo;
- le 21 RPC degli ulteriori Registri Agronomici sono state censite staticamente;
- la corrispondente integrazione Flutter rimane da progettare;
- il workflow editoriale operativo completo rimane FUTURE;
- il popolamento reale del Catalogo non è ancora iniziato;
- l'implementazione complessiva del Database V1 rimane incrementale.

Per la S034 è stato approvato esclusivamente l'obiettivo iniziale di **progettare il sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile**.

La S034 non è ancora iniziata.

Il primo eventuale incremento implementativo dovrà essere valutato separatamente, sulla base delle verifiche e delle decisioni della nuova sessione.

Rimane valido il principio secondo cui:

```text
fonti esterne
→ dati candidati
→ revisione
→ approvazione/pubblicazione
→ Catalogo Agronomico
```

I dati esterni non possono sovrascrivere automaticamente il Catalogo approvato e non devono essere introdotti dati dimostrativi o provvisori nel database operativo.

---

### Aggiornamento tecnico S034 — Correzione del Catalog Registry

La S034 ha realizzato un intervento circoscritto alle RPC `public.update_measurement_unit`, `public.update_agronomic_parameter` e `public.update_parameter_enum_value`, mediante la migration `20261014200459_fix_catalog_registry_semantic_freeze_errors.sql`.

Le RPC restituiscono `semantics_frozen` per `SQLSTATE 55000` soltanto se `SQLERRM` coincide con il messaggio specifico del rispettivo trigger di congelamento semantico; altrimenti propagano l'eccezione. Non sono state introdotte nuove capability. La migration è stata applicata al database Supabase locale, non al remoto. Sono stati eseguiti controlli statici e autorizzativi (3/3); il test dinamico specifico del ramo `SQLSTATE 55000` rimane aperto.

L'obiettivo Flutter inizialmente approvato per S034, riportato nelle sezioni storiche, non è stato realizzato in tale sessione. Commit tecnico S034: `a0f51fff735aefc75b0fd60f74e727f13d6984f0`.

### Aggiornamento applicativo S035 — Finalità di raccolta

La S035 ha implementato a livello Flutter la pagina `HarvestPurposePage` (`lib/pages/harvest_purpose_page.dart`), accessibile da **Impostazioni → Catalogo Agronomico → Finalità di raccolta**. La pagina consente consultazione anche dei record inattivi, creazione, modifica di nome e descrizione, attivazione/disattivazione, ricaricamento e gestione degli stati di errore. Il codice identificativo di una Finalità esistente rimane in sola lettura in modifica.

Le operazioni di scrittura sono condizionate dalla capability applicativa `canManageIdentity`, senza sostituire i controlli autoritativi del backend. La concorrenza ottimistica utilizza `expectedRowVersion`/`row_version`, senza overwrite forzato o ripetizione silenziosa in caso di conflitto. La navigazione è integrata in `lib/pages/agronomic_catalog_page.dart`.

Le verifiche S035 hanno superato **30 test** della pagina Finalità di raccolta e **12 test** della pagina Catalogo Agronomico, per **42 test Flutter mirati**, oltre a `flutter analyze` senza problemi. Non è stato eseguito un collaudo integrato completo Flutter–Supabase. Nessuna migration SQL o modifica del database è stata introdotta in S035. Commit tecnico: `9024e2f0c5f30052371aa8264fa1a5b2ef283efe`.

I sei ulteriori Registri Agronomici diversi dalle Finalità di raccolta restano da valutare per l'integrazione Flutter. Le verifiche ancora aperte non sono assegnate automaticamente a una sessione futura.

### Consolidamento tecnico S036 — Finalità di raccolta e Catalog Registry

La Sessione S036, conclusa nella fase di sviluppo il **21/10/2026 alle 14:36**, ha consolidato il comportamento Flutter delle Finalità di raccolta e verificato localmente la correzione SQL del Catalog Registry introdotta nella S034.

A livello Flutter è stata introdotta una protezione contro le richieste duplicate di attivazione e disattivazione durante un'operazione già in corso. L'intervento riduce il rischio di invii ripetuti, senza sostituire i controlli autoritativi del backend. Commit: `b250b49`.

Sono stati inoltre eseguiti test SQL di regressione relativi alla gestione di `SQLSTATE 55000` nelle tre RPC `public.update_measurement_unit`, `public.update_agronomic_parameter` e `public.update_parameter_enum_value`. Le **sei verifiche su sei sono state superate** nell'ambiente Supabase locale, con rollback delle operazioni di test e senza residui rilevati. Commit: `923c035`.

Le verifiche Flutter finali hanno prodotto:

| Verifica | Esito |
|---|---|
| `flutter analyze` | Nessun problema rilevato |
| Suite automatica Flutter | 1.292 test superati |

I risultati confermano il superamento dei controlli eseguiti nel rispettivo perimetro. **La migration correttiva S034 non risulta applicata al database remoto** e non è stato completato un collaudo integrato di scrittura Flutter–Supabase remoto.

La S036 non ha assegnato automaticamente nuovi interventi alle sessioni successive.

### Aggiornamento tecnico S038 — Resolver Agronomico e Registri Agronomici Flutter

La Sessione S038 si è conclusa nella fase di sviluppo il **29/10/2026 alle ore 10:21**, dopo **13 h 27 min** di lavoro effettivo.

La sessione ha consolidato l'integrazione applicativa del Catalogo Agronomico attraverso tre incrementi principali:

- introduzione del contratto tipizzato Flutter del Resolver Agronomico;
- integrazione Flutter della gestione delle Unità di misura;
- integrazione Flutter della gestione dei Parametri agronomici.

Sono state inoltre effettuate verifiche sul database Supabase e applicata al remoto la migration correttiva del Catalog Registry introdotta nella S034.

#### Contratto tipizzato del Resolver Agronomico

La S038 ha introdotto i modelli Flutter `AgronomicKnowledgeRequest` e `AgronomicKnowledgeResult`, con varianti tipizzate per rappresentare gli esiti del Resolver.

È stato implementato `AgronomicKnowledgeRepository`, che utilizza la RPC backend già esistente:

```text
resolve_agronomic_knowledge
```

È stata inoltre introdotta la verifica dell'identità agronomica mediante `verifyAgronomicKnowledgeIdentity`.

L'intervento non modifica il modello canonico del Catalogo Agronomico e non introduce un secondo Resolver indipendente.

Il backend rimane autoritativo per la risoluzione della Knowledge agronomica.

L'integrazione del Resolver nei flussi operativi di pianificazione e inserimento delle coltivazioni **non è ancora completata**.

#### Gestione Flutter delle Unità di misura e dei Parametri agronomici

La S038 ha introdotto modelli, repository e pagine Flutter dedicati ai registri:

```text
measurement_units
agronomic_parameters
```

Le operazioni di gestione utilizzano le RPC autoritative già disponibili nel backend, senza introdurre scritture dirette alle tabelle.

Sono mantenuti i principi di:

- Catalog Authority e capability server-side;
- Profile Write Authority;
- concorrenza ottimistica mediante `row_version`;
- gestione dei conflitti senza overwrite forzato;
- assenza di retry automatici dopo esiti incerti;
- rilettura dello stato autoritativo quando necessaria.

Le nuove interfacce sono integrate nella navigazione del Catalogo Agronomico.

Alla conclusione della S038, dei sette Registri Agronomici censiti nella S033B risultano integrati a livello Flutter:

1. `harvest_purposes` — Finalità di raccolta, S035;
2. `measurement_units` — Unità di misura, S038;
3. `agronomic_parameters` — Parametri agronomici, S038.

Rimangono senza integrazione amministrativa Flutter completa:

```text
parameter_enum_values
production_contexts
protection_contexts
training_contexts
```

La disponibilità delle RPC backend non equivale al completamento delle relative interfacce applicative.

#### Catalog Registry e allineamento delle migration

Durante la S038 è stata applicata al database Supabase remoto la migration:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La migration era stata introdotta e applicata localmente nella S034 e successivamente sottoposta a sei test SQL locali di regressione, tutti superati nella S036.

Alla conclusione dello sviluppo S038 risultavano **34/34 migration allineate tra ambiente locale e remoto**.

La S038 non ha introdotto nuove migration.

L'applicazione remota della correzione non costituisce, da sola, un collaudo integrato dei percorsi Flutter–Supabase.

#### Verifiche e limiti del collaudo

Nel corso della fase Manuali S038, il **03/11/2026**, sono state eseguite verifiche integrative sul codice della sessione:

| Verifica | Risultato |
|---|---|
| Otto file di test Flutter mirati | **178/178 test superati** |
| `flutter analyze` | **No issues found!** |
| Migration locali e remote alla chiusura dello sviluppo | **34/34 allineate** |

Le verifiche Flutter riguardano i modelli, i repository e le pagine interessati dalla S038.

Non è stata eseguita in tale verifica integrativa l'intera suite Flutter, né un collaudo completo dei flussi di scrittura Flutter–Supabase remoto.

I risultati non autorizzano quindi a dichiarare completata l'integrazione operativa del Resolver, il popolamento del Catalogo Agronomico o la pianificazione reale dell'orto.

#### Risultati e questioni aperte

La S038 ha completato il perimetro implementativo e le verifiche sopra descritti, senza modificare automaticamente le priorità delle sessioni successive.

Rimangono da valutare sulla base dello stato effettivo del progetto:

- integrazione completa del Resolver canonico nei flussi operativi;
- gestione Flutter dei quattro Registri Agronomici rimanenti;
- collaudi integrati Flutter–Supabase pertinenti;
- verifiche necessarie al primo utilizzo reale;
- completezza e approvazione della baseline agronomica destinata alla pianificazione dell'orto 2027.

L'obiettivo approvato il **25/10/2026** di iniziare l'utilizzo reale entro il **15/11/2026** rimane subordinato a una verifica di fattibilità.

Nessuna attività FUTURE viene assegnata automaticamente alla sessione successiva.

## 3.2 Gestione orto

| Funzionalità | Stato |
|--------------|:-----:|
| Elenco aiuole | ✅ Completato |
| Visualizzazione aiuola | ✅ Completato |
| Ordinamento aiuole | ✅ Completato |
| Creazione aiuole | ✅ Completato |
| Modifica dati aiuola | ✅ Completato |
| Attivazione/disattivazione aiuola | ✅ Completato |
| Variazione geometria aiuola | ✅ Completato |
| Correzione storica geometria | ✅ Completato |
| Inserimento coltivazioni | ✅ Completato |
| Modifica coltivazioni | ✅ Completato |
| Modello persistente autoritativo `plantings` | ✅ Completato |
| Write Path autoritativo `plantings` | ✅ Completato |
| Lifecycle server-side delle coltivazioni | ✅ Completato |
| UI lifecycle delle coltivazioni | ✅ Implementata e testata |
| Gestione `end_date` terminale | ✅ Completato |
| Refresh autoritativo su conflitti/transizioni non valide | ✅ Completato |
| Migrazione `plantings` da varietà legacy a cultivar canonica | ✅ Completato |
| Selezione operativa della cultivar nelle coltivazioni | 📋 Pianificato |
| Verifica/ripristino del flusso UI di creazione del primo Garden | 📋 Da verificare |
| Hard delete ordinario delle coltivazioni | 💡 Escluso dal normale flusso / FUTURE amministrativo |

La UI del lifecycle delle coltivazioni è stata implementata e verificata mediante test automatici nella S029. Questo non equivale al completamento dell'intero flusso operativo dell'interfaccia dell'orto.

Nel test manuale conclusivo della S030 il profilo utilizzato non disponeva di un Garden; di conseguenza non è stato possibile raggiungere e verificare manualmente il percorso completo Garden → aiuole → coltivazioni. Rimane quindi aperta la verifica o il ripristino della raggiungibilità UI della creazione del primo Garden.

Dopo il cutover S030, `plantings` utilizza `crop_id` e l'eventuale `cultivar_id`. L'interfaccia di creazione non espone ancora la selezione operativa della cultivar: una nuova coltivazione viene attualmente creata senza cultivar esplicita, mentre in modifica viene preservato l'eventuale `cultivar_id` già presente.

---

## 3.3 Motore Agronomico

| Funzionalità | Stato | Note |
|---|---|---|
| FreeSpaceEngine | ✅ Completato | Calcolo automatico degli spazi liberi nelle aiuole. |
| SuggestionEngine | ✅ Completato | Generazione dei candidati iniziali sulla base degli spazi disponibili. |
| Companion Engine | ✅ Completato | Prima versione del motore delle consociazioni. |
| BedAnalysisService | ✅ Completato | Servizio di coordinamento delle analisi agronomiche delle aiuole. |
| Bed Companion Analyzer | ✅ Completato | Analisi automatica delle compatibilità tra le colture presenti in un'aiuola. |
| RecommendationPipeline | ✅ Completato | Orchestrazione del processo di raccomandazione e coordinamento dei componenti specializzati. |
| Decision Engine | ✅ Completato | Interpretazione delle valutazioni agronomiche e calcolo del punteggio finale delle raccomandazioni. |
| DecisionWeights | ✅ Completato | Configurazione e validazione dei pesi applicati ai criteri spazio, rotazione e consociazione. |
| Motore delle Rotazioni | ✅ Completato | Prima versione operativa integrata nella RecommendationPipeline. |
| Sistema di Punteggio Agronomico | ✅ Completato | Prima versione operativa basata su spazio, rotazione e consociazione con pesi configurabili. |
| FamilyNeedsEngine | ✅ Integrato | Prima versione completata nella S011 e integrata nella RecommendationPipeline nella S012 mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| FamilyConsumptionNeed | ✅ Completato | Modello quantitativo introdotto nella S013 per rappresentare quantità, unità e periodicità del fabbisogno familiare. |
| FamilyConsumptionNeedValidator | ✅ Completato | Validazione dei fabbisogni quantitativi familiari introdotta nella S013. |
| PlannedPlantingBatch | ✅ Completato | Modello introdotto nella S013 per rappresentare un lotto di coltivazione pianificato nel tempo. |
| PlannedPlantingBatchValidator | ✅ Completato | Validazione dei dati necessari alla rappresentazione dei lotti di coltivazione pianificati. |
| SuccessionPlanningEngine | ✅ V1 completata | Prima versione deterministica implementata nella S014: trasforma `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, senza introdurre conversioni agronomiche non supportate. |
| AgronomicWindow | ✅ Completato | Modello annuale introdotto nella S015 per rappresentare finestre agronomiche associate a uno specifico metodo di avvio, con supporto degli intervalli che attraversano il cambio dell'anno. |
| AgronomicWindowValidator | ✅ Completato | Validazione strutturale delle finestre agronomiche introdotta nella S015, comprese le combinazioni mese/giorno e il supporto del 29 febbraio. |
| AgronomicWindowEngine | ✅ V1 completata | Prima versione implementata nella S015 per verificare l'appartenenza temporale alle finestre e la compatibilità dei `PlannedPlantingBatch` in base a metodo di avvio e data. |
| Stagionalità di colture e varietà | ✅ V1 completata | Obiettivo storico S016: le finestre agronomiche sono associabili a colture e varietà secondo il modello applicativo allora vigente. Il riallineamento completo al Catalogo Agronomico S030 resta evolutivo. |
| CropAgronomicWindowRule | ✅ Completato | Modello storico S016 per associare una `AgronomicWindow` a una coltura e, opzionalmente, a una specifica varietà. Il modello precede il cutover canonico S030. |
| AgronomicWindowResolver | ✅ V1 completata | Resolver storico S016 basato sul fallback varietà specifica → coltura generale → nessuna regola. È distinto dal Resolver canonico della Knowledge agronomica introdotto nella S030. |
| AgronomicWindowEvaluation | ✅ Completato | Risultato strutturato introdotto nella S016 per distinguere gli stati `compatible`, `incompatible` e `unknown`, evitando di interpretare l'assenza di dati come incompatibilità. |
| AgronomicWindowService | ✅ V1 completata | Servizio introdotto nella S016 per coordinare `AgronomicWindowResolver` e `AgronomicWindowEngine` nella valutazione stagionale dei `PlannedPlantingBatch`. |
| Progettazione della persistenza delle regole agronomiche | ✅ Completato | Obiettivo S017 completato nell'ambito della progettazione Database V1. L'implementazione e il riallineamento delle regole persistenti al Catalogo Agronomico corrente restano incrementali. |
| Resolver canonico della Knowledge agronomica — backend S030 | ✅ Completato | Resolver autoritativo del Catalogo Agronomico, accessibile tramite la RPC `resolve_agronomic_knowledge`. Non coincide con il Resolver storico delle finestre agronomiche S016. |
| AgronomicKnowledgeRequest | ✅ Implementato in S038 | Contratto tipizzato Flutter per formulare richieste al Resolver canonico. Verificato con test mirati. |
| AgronomicKnowledgeResult | ✅ Implementato in S038 | Modello Flutter degli esiti del Resolver, con varianti tipizzate. Verificato con test mirati. |
| AgronomicKnowledgeRepository | ✅ Implementato in S038 | Repository Flutter che richiama la RPC backend esistente `resolve_agronomic_knowledge`. Verificato con test mirati. |
| verifyAgronomicKnowledgeIdentity | ✅ Implementato in S038 | Verifica applicativa dell'identità agronomica nel perimetro del contratto Flutter del Resolver. |
| Integrazione completa del Resolver S030/S038 nei flussi di pianificazione e inserimento | 📋 FUTURE | Il backend canonico e il relativo contratto Flutter sono disponibili, ma non risulta completato il collegamento operativo con tutti i flussi di pianificazione e inserimento delle coltivazioni. |
| Riallineamento dei motori agronomici storici al Catalogo canonico | 📋 FUTURE | Da valutare progressivamente rispetto a `botanical_taxa`, `crops`, `crop_cultivars`, Knowledge pubblicata e Resolver, evitando nuove dipendenze legacy. |
| Backend canonico delle consociazioni | 📋 Pianificato | Il motore applicativo esiste, ma il backend canonico del Catalogo per le associazioni tra colture non è ancora implementato. |

### Distinzione tra i Resolver agronomici

Il progetto comprende due componenti con finalità differenti.

**Resolver storico delle finestre agronomiche — S016**

`AgronomicWindowResolver` appartiene al modello applicativo storico delle finestre agronomiche. Determina la regola applicabile secondo il fallback varietà specifica → coltura generale → nessuna regola e collabora con `AgronomicWindowEngine` e `AgronomicWindowService`.

**Resolver canonico della Knowledge agronomica — S030/S038**

Il Resolver introdotto nella S030 opera sul Catalogo Agronomico canonico e sulla Knowledge pubblicata. Il backend mantiene la responsabilità autoritativa della risoluzione.

La S038 ha aggiunto il contratto tipizzato Flutter, i modelli degli esiti e il repository di accesso alla RPC esistente, senza creare un secondo motore di risoluzione indipendente.

Questa integrazione tecnica non dimostra ancora il completamento dei flussi operativi di pianificazione e inserimento delle coltivazioni.

### Evoluzione e vincoli

I componenti agronomici realizzati nelle sessioni precedenti alla S030 restano risultati tecnici validi delle rispettive fasi di sviluppo. La loro terminologia storica non viene riscritta retroattivamente.

Il Catalogo Agronomico S030 introduce tuttavia un contratto canonico globale. L'integrazione progressiva dei motori agronomici con `botanical_taxa`, `crops`, `crop_cultivars`, Knowledge pubblicata e Resolver costituisce quindi un'evoluzione successiva e deve evitare nuove dipendenze dal modello legacy.

Alla conclusione della S038:

- il Resolver canonico backend risulta disponibile;
- il contratto e il repository Flutter risultano implementati e verificati nel perimetro dei test mirati;
- il collaudo integrato dei flussi operativi Flutter–Supabase non risulta completato;
- la pianificazione reale dell'orto 2027 non può essere considerata operativa sulla sola base di questi risultati.

Le attività FUTURE restano soggette a valutazione e approvazione nelle sessioni di sviluppo competenti. La presente roadmap non determina automaticamente le attività della sessione successiva.

---

## 3.4 Irrigazione

| Funzionalità | Stato |
|--------------|:-----:|
| Gestione manuale | 🚧 In sviluppo |
| Storico irrigazioni | 📋 Pianificato |
| Zone irrigazione | 📋 Pianificato |
| Raspberry Pi | 📋 Pianificato |
| ESP32 | 📋 Pianificato |
| Sensori del terreno | 📋 Pianificato |
| Irrigazione automatica | 📋 Pianificato |

---

## 3.5 Dashboard

| Funzionalità | Stato |
|--------------|:-----:|
| Dashboard iniziale | 🚧 In sviluppo |
| Meteo | 📋 Pianificato |
| Attività giornaliere | 📋 Pianificato |
| Stato dell'orto | 📋 Pianificato |
| Avvisi | 📋 Pianificato |
| Indicatori | 📋 Pianificato |

---

## 3.6 Attività

| Funzionalità | Stato |
|--------------|:-----:|
| Diario attività | 📋 Pianificato |
| Piano di lavoro | 📋 Pianificato |
| Timer "Inizia lavoro" | 📋 Pianificato |
| Storico lavorazioni | 📋 Pianificato |
| Tempi di lavoro | 📋 Pianificato |

---

## 3.7 Statistiche

| Funzionalità | Stato |
|--------------|:-----:|
| Produzione | 📋 Pianificato |
| Costi | 📋 Pianificato |
| Risparmio economico | 📋 Pianificato |
| Tempo dedicato | 📋 Pianificato |
| Grafici | 📋 Pianificato |

---

## 3.8 Versioni future

### Versione 0.x

Completamento delle funzionalità fondamentali dell'applicazione.

### Versione 1.0

Prima versione stabile destinata all'utilizzo quotidiano.

### Versione 2.0

Consolidamento del Motore Agronomico e introduzione delle principali funzionalità avanzate.

### Versione 3.0

Sistema completo di irrigazione intelligente e integrazione hardware.

### Versione 4.0

Assistente intelligente dedicato alla gestione completa dell'orto.

---

# 4. Prossime attività

Le attività riportate in questa sezione rappresentano le principali direttrici di sviluppo previste per le prossime versioni di Orto Smart.

L'ordine di realizzazione può variare in funzione delle esigenze del progetto e delle decisioni architetturali approvate durante lo sviluppo.

## Stato dopo la Sessione S028

La Sessione S028 ha completato il modello persistente e il **Write Path autoritativo di `plantings`**.

La sequenza tecnica consolidata è ora:

```text
botanical_families
        ↓
crops
        ↓
crop_varieties
        ↓
plantings
```

Tutti e quattro i livelli risultano ora implementati lato PostgreSQL/Supabase.

Il Catalogo V1 dispone inoltre del relativo Repository Layer Flutter.

`plantings` dispone ora del modello persistente, del Write Path autoritativo e dell'integrazione Flutter necessaria alla creazione e modifica delle coltivazioni.

Risultano completati:

- primo blocco Fondazioni della baseline Database V1;

- schema `private`, helper autorizzativi, trigger metadata e prima matrice RLS;

- protocollo server-side completo di `profile_edit_locks`;

- Profile Write Authority server-side;

- integrazione Flutter fail-closed della Profile Write Authority;

- Write Path autoritativo di `gardens`;

- Write Path autoritativo di `seasons`;

- implementazione di:
  - `beds`;
  - `bed_geometries`;
  - `bed_geometry_corrections`;

- Write Path autoritativo di `beds`;

- integrazione Flutter completa dei Write Path disponibili per `beds`;

- Catalogo DB V1 composto da:

```text
botanical_families
crops
crop_varieties
```

- ownership del catalogo a livello Profile;

- condivisione del catalogo tra i Gardens appartenenti allo stesso Profile;

- identificativi UUID per le entità del Catalogo DB V1;

- separazione della Crop Variety come entità autonoma;

- relazione persistente Crop → Botanical Family mediante `botanical_family_id`;

- relazione persistente Crop Variety → Crop mediante `crop_id`;

- `default_start_method` con valori canonici;

- fallback agronomico Crop → Crop Variety;

- gestione quantitativa del fabbisogno idrico;

- gestione strutturata della resa prevista;

- validazioni server-side di gerarchia, temperature, acqua, resa e unicità;

- regole di attivazione, disattivazione e riattivazione coerenti con la gerarchia;

- immutabilità di `crop_varieties.crop_id`;

- assenza di eliminazione fisica applicativa ordinaria del catalogo;

- concorrenza ottimistica mediante `row_version`;

- locking server-side e gerarchico dove necessario;

- nove RPC autoritative del Catalogo V1:

```text
create_botanical_family
update_botanical_family
set_botanical_family_active

create_crop
update_crop
set_crop_active

create_crop_variety
update_crop_variety
set_crop_variety_active
```

- RLS in lettura mediante membership del Profile;

- revoca delle scritture dirette sulle entità protette;

- principio:

> **catalogo corrente + snapshot storico**

- modello Flutter:

```text
BotanicalFamily
```

- riallineamento al Database V1 dei modelli:

```text
Crop
CropVariety
```

- Repository Flutter:

```text
BotanicalFamilyRepository
CropRepository
CropVarietyRepository
```

- letture del Catalogo V1 sotto protezione RLS;

- scritture del Catalogo V1 esclusivamente tramite RPC autoritative;

- integrazione della Profile Write Authority nei Repository del catalogo;

- gestione applicativa di `row_version`;

- result type dedicati e mapping esplicito degli status RPC;

- comportamento fail-closed degli esiti non riconosciuti o non confermabili;

- compatibilità legacy temporanea mediante:

```text
Crop.sowingMethod
Crop.botanicalFamily
heavyFeeder
CropVariety.defaultPlantingMethod
```

La Sessione S028 ha inoltre introdotto:

```text
public.plantings
```

come modello persistente autoritativo delle coltivazioni reali.

Il modello comprende:

```text
id
profile_id
garden_id
season_id
bed_id
crop_id
variety_id
start_method
start_date
end_date
start_position_cm
length_cm
plant_spacing_cm
row_spacing_cm
rows_count
occupied_width_cm
plants_count
seed_quantity_g
status
notes
created_at
updated_at
row_version
```

Sono stati consolidati i quattro metodi persistenti:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il valore:

```text
manual
```

rimane esclusivamente un concetto applicativo relativo al posizionamento e non costituisce un metodo agronomico persistito.

Sono state introdotte le migration:

```text
20260915080700_add_plantings_authoritative_model.sql
20260915081444_add_plantings_write_rpcs.sql
```

e le RPC:

```text
create_planting
update_planting
set_planting_status
```

Il Write Path applicativo segue:

```text
UI
        ↓
PlantingRepository
        ↓
Profile Write Authority
        ↓
RPC autoritativa
        ↓
PostgreSQL
```

Le scritture ordinarie di `plantings` sono quindi RPC-only.

La concorrenza ottimistica utilizza:

```text
row_version
```

e il controllo della versione attesa quando previsto dal contratto della RPC.

La geometria longitudinale utilizza intervalli half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

La disposizione delle file deve rispettare:

```text
(rows_count - 1) * row_spacing_cm <= occupied_width_cm
```

La disposizione delle piante deve rispettare:

```text
(plants_count - 1) * plant_spacing_cm <= length_cm
```

Il controllo utilizza il numero totale di piante.

Una sovrapposizione viene rifiutata quando sono contemporaneamente presenti:

```text
overlap temporale
+
overlap longitudinale
```

La geometria di una coltivazione deve inoltre essere compatibile con tutte le geometrie dell'aiuola temporalmente interessate dalla sua occupazione.

Le RPC:

```text
change_bed_geometry
correct_bed_geometry
```

sono state rafforzate e possono restituire:

```text
blocked_by_plantings
```

quando una variazione geometrica renderebbe incompatibili coltivazioni già persistite.

## Lifecycle di `plantings`

Il lifecycle autoritativo server-side è implementato.

Gli stati previsti sono:

```text
sown
growing
harvest_ready
harvested
finished
removed
```

Le transizioni ammesse sono:

```text
sown          → growing | removed
growing       → harvest_ready | removed
harvest_ready → harvested | removed
harvested     → finished | removed
finished      → nessuna
removed       → nessuna
```

Lo stato:

```text
harvested
```

continua a occupare l'aiuola.

Soltanto:

```text
finished
removed
```

terminano l'occupazione.

Con la Sessione S029 anche l'esperienza UI del lifecycle è stata completata.

`PlantingCard` espone azioni contestuali coerenti con lo stato corrente e inoltra le richieste mediante:

```text
onStatusChange
```

a:

```text
BedPage
```

Il flusso applicativo consolidato è:

```text
PlantingCard
        ↓
BedPage
        ↓
PlantingRepository.setPlantingStatus
        ↓
set_planting_status
        ↓
PostgreSQL
```

Le transizioni intermedie:

```text
sown → growing
growing → harvest_ready
harvest_ready → harvested
```

mantengono:

```text
end_date = null
```

Le transizioni terminali:

```text
harvested → finished
* → removed
```

richiedono invece una conferma esplicita di:

```text
end_date
```

La UI propone inizialmente il giorno corrente, lasciandolo modificabile entro i limiti:

```text
end_date >= start_date
end_date <= giorno corrente
```

La S029 ha inoltre introdotto la rilettura autoritativa delle coltivazioni in presenza degli esiti:

```text
version_conflict
invalid_transition
```

prima di informare l'utente.

PostgreSQL continua a essere l'autorità definitiva per la validità delle transizioni, le autorizzazioni, la concorrenza e la validazione della data terminale.

La Sessione S029 non ha introdotto nuove migration, nuove RPC, modifiche RLS o variazioni del contratto persistente S028.

## Integrazione Flutter S028

Sono stati riallineati al contratto S028:

```text
Planting
PlantingRepository
AddPlantingPage
BedPage
GardenPage
GardenMap
PlantingCard
RotationEngine
```

È stato introdotto:

```text
PlantingWriteResult
```

per il mapping tipizzato degli esiti del Write Path.

`PlantingRepository` espone:

```text
getPlantingsByBed
createPlanting
updatePlanting
setPlantingStatus
```

La pagina di inserimento è stata riallineata ai quattro metodi di avvio persistenti e alle regole di geometria, date e quantità previste dal contratto Database V1.

La verifica finale S028 ha prodotto:

```text
flutter analyze
No issues found!
```

```text
flutter test
997/997 test superati
```

La ricostruzione locale del database è stata verificata mediante:

```text
supabase db reset
```

e il controllo dello schema mediante:

```text
supabase db lint --local
```

senza errori.

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**, poiché la baseline completa delle 52 entità non è ancora fisicamente implementata.

## Integrazione Flutter S029

La Sessione S029 ha completato l'integrazione applicativa del lifecycle di `plantings`.

Sono stati aggiornati principalmente:

```text
PlantingCard
BedPage
test/pages/bed_page_test.dart
```

ed è stato introdotto:

```text
test/widgets/planting_card_test.dart
```

`PlantingCard` espone ora le sole azioni lifecycle coerenti con lo stato corrente.

Sono stati eliminati dal normale flusso:

```text
Elimina
onDelete
planned
```

come elementi del precedente comportamento applicativo.

`BedPage` utilizza:

```text
PlantingRepository.setPlantingStatus
```

senza scritture dirette sulla tabella.

La verifica tecnica finale S029 ha prodotto:

```text
flutter test finale:
1011/1011 test passati

bed_page_test.dart:
30/30 test passati

planting_card_test.dart finale:
9/9 test passati

flutter analyze finale:
No issues found! (ran in 12.8s)
```

Il dato di 1011 test rappresenta la suite completa finale effettivamente eseguita dopo l'aggiunta dell'ultimo test dedicato a `PlantingCard`.

Lo STEP 35.3 – Costruzione baseline SQL Database V1 rimane **in corso**, poiché la baseline completa delle 52 entità non è ancora fisicamente implementata.

## Sessione S029 completata

La pianificazione preliminare:

```text
S029 — Lifecycle e varietà delle coltivazioni
```

ha portato all'effettiva Sessione S029, svolta il:

```text
17/09/2026
```

La fase sviluppo è stata completata in:

```text
1 h 19 min
```

La sessione ha completato:

1. visualizzazione in UI delle sole transizioni lifecycle consentite;

2. utilizzo di:

```text
set_planting_status
```

come Write Path autoritativo delle transizioni;

3. gestione esplicita di:

```text
end_date
```

per:

```text
finished
removed
```

4. proposta del giorno corrente come valore iniziale di `end_date`, mantenendolo modificabile;

5. assenza di chiusura implicita della coltivazione;

6. evidenza applicativa che:

```text
harvested
```

continua a occupare l'aiuola;

7. rilascio dello spazio soltanto mediante:

```text
finished
removed
```

8. gestione degli esiti RPC;

9. gestione di:

```text
version_conflict
invalid_transition
```

10. refresh autoritativo delle coltivazioni dopo tali esiti;

11. test dedicati al lifecycle e alla gestione terminale.

Non è stata invece implementata durante S029 la selezione facoltativa della varietà.

Rimangono quindi aperti:

- selezione della varietà nel flusso operativo delle coltivazioni;
- mantenimento e gestione applicativa della varietà;
- progressiva eliminazione delle dipendenze legacy;
- UI amministrativa completa del Catalogo V1.

La Sessione S029 non ha modificato il Database V1.

Non sono state introdotte:

```text
migration
nuove tabelle
nuove colonne
nuove RPC
modifiche RLS
```

## Hard delete di `plantings`

Il normale flusso operativo non deve prevedere l'eliminazione definitiva di una coltivazione.

Gli stati:

```text
finished
removed
```

rappresentano le chiusure ordinarie del ciclo di vita.

Un eventuale hard delete rimane classificato:

```text
FUTURE
```

e dovrà essere disponibile esclusivamente come correzione amministrativa o tecnica eccezionale per record inseriti per errore.

Non dovrà essere disponibile nel normale flusso operativo dell'orto.

## Catalogo Agronomico

La Sessione S030 ha completato l'architettura tecnica e il cutover del **Catalogo Agronomico V1 globale**.

Il Catalogo è separato dai dati operativi del singolo orto e utilizza identità canoniche globali.

Il modello canonico corrente è basato sulla catena:

```text
botanical_taxa
        ↓
crops
        ↓
crop_cultivars
```

La S030 ha inoltre introdotto e verificato:

- identità botaniche globali;
- normalizzazione canonica dei testi del Catalogo;
- Catalog Authority globale con capability distinte;
- registro dei parametri agronomici;
- vocabolari e contesti agronomici;
- fonti, acquisizioni e osservazioni;
- alias e riconciliazione delle identità;
- workflow editoriale;
- Knowledge agronomica canonica;
- integrità e sicurezza del Catalogo;
- pubblicazione e versionamento;
- Resolver canonico;
- Write Path autoritativi;
- read model canonici;
- cutover finale dal modello legacy;
- integrazione tecnica Flutter necessaria al nuovo contratto.

Il perimetro del Catalogo Agronomico introdotto nella S030 comprende complessivamente **26 tabelle**.

Le precedenti strutture:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

sono state eliminate nel cutover finale.

I `plantings` utilizzano ora:

```text
crop_id
cultivar_id opzionale
```

con riferimento alle identità canoniche del Catalogo.

### Separazione tra fonti esterne e Catalogo approvato

Rimane valido e viene consolidato il principio secondo cui i dati provenienti da fonti esterne non possono diventare automaticamente dati canonici utilizzabili dall'applicazione.

Il flusso previsto è:

```text
Fonte esterna
        ↓
acquisizione / ingestion
        ↓
osservazione / dato candidato
        ↓
revisione editoriale
        ↓
Knowledge canonica
        ↓
pubblicazione
        ↓
Catalogo utilizzabile
```

L'importazione o lo scraping:

```text
NON
```

devono scrivere direttamente o sovrascrivere automaticamente il Catalogo Agronomico approvato.

Le informazioni acquisite devono rimanere tracciabili rispetto alla fonte e attraversare il workflow editoriale previsto prima della pubblicazione.

La funzione operativa di aggiornamento delle fonti rimane prevista in:

```text
Impostazioni
        ↓
Catalogo Agronomico
        ↓
Aggiornamento fonti
```

La relativa UI e il flusso operativo completo di acquisizione, revisione e pubblicazione restano da implementare.

### Popolamento del Catalogo

Il completamento tecnico della S030 non costituisce popolamento agronomico del Catalogo.

Il database deve continuare a rimanere privo di dati dimostrativi, provvisori o inseriti esclusivamente per simulare il funzionamento dell'applicazione.

Prima dell'avvio della gestione reale dell'orto dovrà essere predisposta una baseline del Catalogo Agronomico composta esclusivamente da dati:

- reali;
- verificabili;
- tracciabili rispetto alle fonti;
- revisionati secondo il workflow previsto;
- approvati per l'utilizzo operativo.

La **carota** rimane un possibile primo caso pilota per verificare il processo completo di acquisizione, revisione, pubblicazione e utilizzo dei dati agronomici.

Gli eventuali dati precedentemente raccolti a titolo preparatorio non costituiscono automaticamente dati approvati del Catalogo.

---

## Consolidamento post-S030

Il cutover S030 ha eliminato le principali dipendenze persistenti dal precedente modello personale del Catalogo.

Nel contratto canonico corrente non devono essere reintrodotte nuove dipendenze da:

```text
botanical_families
crop_varieties
CropVariety
variety_id
```

La terminologia tecnica corrente utilizza:

```text
botanical_taxa
crops
crop_cultivars
BotanicalTaxon
Crop
CropCultivar
taxon_id
crop_id
cultivar_id
```

La tassonomia botanica globale utilizza i rank canonici:

```text
ORDER
FAMILY
GENUS
SPECIES
SUBSPECIES
VARIETY
FORMA
UNRANKED
```

`CULTIVAR` non è un rank tassonomico. La Cultivar costituisce un'identità agronomica globale separata e rimane associata alla Crop attraverso il modello `crop_cultivars`.

La gerarchia tassonomica utilizza `parent_taxon_id` e supporta classificazioni parziali. Il client non deve quindi imporre la presenza di tutti i rank intermedi quando il backend non la richiede.

La S031 ha completato un primo consolidamento lato Flutter eliminando il precedente percorso autonomo:

```text
Impostazioni → Varietà
```

e adottando la navigazione gerarchica coerente con il modello canonico:

```text
Impostazioni
→ Catalogo Agronomico
→ Colture
→ Cultivar
```

La consultazione delle cultivar avviene nel contesto della coltura selezionata e il relativo caricamento viene eseguito on demand.

La S032 ha proseguito il consolidamento verificando il contratto autoritativo già disponibile nel backend e integrando nel livello Flutter i Write Path relativi a:

```text
Tassonomia
Crop
Cultivar
```

Per la tassonomia botanica sono utilizzate le RPC autoritative:

```text
create_botanical_taxon
update_botanical_taxon
set_botanical_taxon_active
```

La gestione delle identità è subordinata alle capability della **Catalog Authority**, distinta dalla Profile Write Authority e dal meccanismo `profile_edit_locks`.

La S032 ha inoltre completato nella UI la gestione della **Classificazione botanica**, comprendendo:

- consultazione;
- creazione;
- modifica;
- attivazione;
- disattivazione;
- selezione della classificazione superiore;
- gestione degli errori;
- gestione dei conflitti di versione;
- verifica dello stato autoritativo dopo esiti incerti.

La terminologia UI consolidata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Il collegamento di una Crop alla tassonomia rimane opzionale:

```text
Crop → Taxon
```

La concorrenza ottimistica delle operazioni di modifica utilizza `row_version`.

In caso di `version_conflict`:

```text
nessun overwrite forzato
nessun retry automatico
        ↓
rilettura autoritativa
```

In caso di errore di comunicazione o altro esito incerto dopo l'invio di una scrittura:

```text
nessun retry automatico
        ↓
rilettura autoritativa
        ↓
verifica dello stato effettivamente persistito
```

Il backend rimane autoritativo per le regole relative a:

- autorizzazioni e capability;
- normalizzazione;
- unicità;
- gerarchia tassonomica;
- prevenzione dei cicli;
- parent attivo/inattivo;
- dipendenze attive;
- attivazione e disattivazione;
- invarianti delle identità.

Flutter non deve duplicare tali regole introducendo vincoli ulteriori non previsti dal contratto backend.

La parola italiana **“Varietà”** può continuare a essere utilizzata nell'interfaccia utente quando costituisce la formulazione più naturale per l'utilizzatore, ma non deve determinare la reintroduzione nel modello applicativo o persistente delle precedenti identità `CropVariety` o `variety_id`.

Rimane da completare il riallineamento progressivo dei componenti agronomici e dei consumer applicativi storici che precedono il contratto canonico S030.

In particolare, i motori agronomici sviluppati nelle sessioni precedenti devono essere integrati progressivamente con:

- identità canoniche globali;
- Knowledge agronomica pubblicata;
- Resolver del Catalogo;
- eventuali snapshot operativi necessari alla conservazione storica delle decisioni.

Le nuove evoluzioni non devono introdurre ulteriori dipendenze dal modello legacy.

Il completamento della gestione UI della tassonomia in S032 non equivaleva, in quella fase, al completamento dell'intera UI amministrativa del Catalogo. Le UI di gestione Crop e Cultivar sono state successivamente completate in S033; restano da sviluppare le interfacce relative ad alias, fonti, dati candidati, revisione, pubblicazione e utilizzo operativo del Resolver.

---

## Altri blocchi futuri

Alla conclusione dello sviluppo S038, le attività ancora aperte o classificate FUTURE vengono distinte dai risultati effettivamente completati nelle sessioni precedenti.

Le descrizioni storiche S033/S033B, S034, S035, S036 e S038 conservano valore nei rispettivi perimetri.

L'inserimento di un'attività in questo elenco non ne determina automaticamente l'assegnazione alla sessione successiva.

### Registri Agronomici Flutter

La Fase A dei Registri Agronomici Flutter è stata completata nella S033.

Sono disponibili, nel perimetro implementato e verificato:

- HUB Registri Agronomici;
- pagina dedicata alla Classificazione botanica;
- pagina dedicata alla gestione di Colture e Cultivar;
- operazioni di lettura, creazione, modifica e gestione dello stato attivo delle identità;
- applicazione delle capability della Catalog Authority;
- gestione della concorrenza ottimistica;
- gestione sicura dei conflitti e degli esiti incerti mediante rilettura autoritativa.

Non rimangono pertanto FUTURE le UI di gestione delle Crop e delle Cultivar già completate nella Fase A S033.

La S033B ha censito staticamente 21/21 RPC relative ai sette ulteriori Registri Agronomici:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

Alla conclusione della S038, **tre dei sette registri** risultano integrati a livello Flutter:

| Registro | Sessione | Stato |
|---|---|---|
| `harvest_purposes` | S035, consolidamento S036 | ✅ Modelli, repository e UI implementati; verifiche Flutter superate |
| `measurement_units` | S038 | ✅ Modelli, repository e UI implementati; verifiche Flutter mirate superate |
| `agronomic_parameters` | S038 | ✅ Modelli, repository e UI implementati; verifiche Flutter mirate superate |
| `parameter_enum_values` | — | 📋 Integrazione Flutter FUTURE |
| `production_contexts` | — | 📋 Integrazione Flutter FUTURE |
| `protection_contexts` | — | 📋 Integrazione Flutter FUTURE |
| `training_contexts` | — | 📋 Integrazione Flutter FUTURE |

Per i quattro registri ancora FUTURE rimangono da valutare e, soltanto dopo approvazione, eventualmente realizzare:

- modelli Flutter dedicati;
- repository Flutter e contratti applicativi coerenti con le RPC autoritative;
- interfacce di consultazione e gestione;
- navigazione e integrazione con l'HUB;
- gestione delle autorizzazioni e degli esiti applicativi;
- verifiche specifiche e regressione.

La disponibilità delle RPC backend non equivale al completamento della loro integrazione Flutter.

Per i tre registri implementati rimane distinta la verifica automatica Flutter dal collaudo integrato dei percorsi di scrittura Flutter–Supabase.

La pianificazione iniziale della S034 relativa ai Registri Agronomici rimane un riferimento storico: la S034 ha realizzato la correzione SQL del Catalog Registry; la S035 ha implementato le Finalità di raccolta; la S038 ha aggiunto Unità di misura e Parametri agronomici.

### Catalogo Agronomico e workflow editoriale

Rimangono FUTURE:

- gestione applicativa degli alias e dei relativi flussi di riconciliazione delle identità;
- workflow operativo di acquisizione e aggiornamento delle fonti nel percorso `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- schermate per la gestione delle acquisizioni e dei dati candidati;
- revisione editoriale;
- approvazione e pubblicazione attraverso il backend autoritativo;
- integrazione completa del Resolver canonico nei flussi di pianificazione e inserimento delle coltivazioni;
- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;
- riallineamento progressivo dei motori agronomici storici al Catalogo canonico S030;
- backend canonico delle consociazioni tra colture.

La S038 ha implementato il contratto tipizzato Flutter e il repository di accesso al Resolver canonico già esistente nel backend.

Questo risultato non equivale al completamento dell'integrazione operativa del Resolver nei flussi di pianificazione.

Il workflow delle fonti esterne rimane:

```text
fonte esterna
    ↓
acquisizione
    ↓
dato candidato
    ↓
revisione
    ↓
approvazione / pubblicazione
    ↓
Catalogo Agronomico
```

Nessun dato esterno può sovrascrivere automaticamente il Catalogo approvato.

Non devono essere introdotti dati dimostrativi o provvisori nel database operativo.

### Gestione operativa dell'orto

Rimangono aperte o FUTURE:

- verifica o ripristino della raggiungibilità UI della creazione del primo Garden;
- selezione operativa della cultivar durante la creazione delle coltivazioni;
- verifica separata dello stato del database locale e remoto prima dell'avvio operativo;
- predisposizione di una baseline verificata del Catalogo Agronomico;
- creazione del Garden reale;
- creazione delle 15 aiuole reali;
- apertura della stagione reale;
- registrazione delle coltivazioni reali;
- smoke test con dati operativi reali dopo l'avvio effettivo della gestione dell'orto.

L'avvio operativo dovrà rispettare la sequenza definita nella sezione successiva.

L'obiettivo approvato il **25/10/2026** di iniziare a utilizzare Orto Smart per la pianificazione dell'orto 2027 entro il **15/11/2026** non costituisce una conferma di fattibilità né una dichiarazione di disponibilità operativa.

### Sicurezza, backend e verifiche

La S033B ha effettuato un audit locale dei Write Path di `plantings`:

```text
create_planting
update_planting
set_planting_status
```

L'esito è stato favorevole nel perimetro effettivamente esaminato.

Non sono stati dimostrati difetti tali da giustificare correzioni immediate.

La S034 ha introdotto la migration:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione riguarda la distinzione degli errori semantici `SQLSTATE 55000` nelle tre RPC:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La S036 ha completato **6/6 test SQL locali di regressione**, mentre la S038 ha applicato la migration al database remoto.

Alla conclusione dello sviluppo S038, le migration locali e remote risultavano **34/34 allineate**.

Pertanto non rimangono FUTURE né l'esecuzione dei sei test SQL locali già superati né la prima applicazione remota della migration S034.

Rimangono invece da valutare, secondo necessità:

- test runtime delle operazioni di scrittura;
- collaudi integrati Flutter–Supabase dei Registri Agronomici;
- verifiche della concorrenza e della Profile Write Authority;
- test end-to-end Flutter/Supabase;
- verifiche funzionali del database remoto;
- approfondimenti sui casi limite della geometria e delle validazioni numeriche.

L'esito dell'audit locale e l'allineamento delle migration non costituiscono una certificazione generale della sicurezza dell'applicazione.

Rimangono inoltre FUTURE:

- operazioni amministrative protette su `profile_memberships`;
- prosecuzione dell'implementazione incrementale delle restanti entità del Database V1;
- manutenzione periodica controllata dei dati ISO 3166-1 alpha-2 mediante migration e test verificati, senza aggiornamenti automatici non revisionati.

L'hard delete dei `plantings` rimane escluso dal normale flusso applicativo.

Potrà essere valutato esclusivamente come futura funzione amministrativa o tecnica protetta per correggere record inseriti per errore.

### Ulteriori aree applicative

Rimangono da sviluppare progressivamente:

- irrigazione;
- attività e diario;
- dashboard;
- statistiche;
- ulteriori funzionalità necessarie all'utilizzo operativo dell'orto.

Le priorità e l'estensione dei relativi incrementi dovranno essere definite sulla base dello stato effettivamente raggiunto.

### Risultati rimossi dal perimetro FUTURE

La S031 ha completato:

- integrazione del Catalogo Agronomico nelle Impostazioni;
- lettura dello stato della Catalog Authority;
- inizializzazione controllata dell'authority quando consentita;
- esposizione delle capability autoritative;
- consultazione delle colture globali;
- navigazione gerarchica `Coltura → Cultivar`;
- caricamento on demand delle cultivar;
- gestione degli stati di caricamento, assenza dati, errore e retry;
- eliminazione del precedente percorso autonomo `Impostazioni → Varietà`.

La S032 ha completato:

- ricognizione tecnica dei Write Path delle identità globali;
- verifica del contratto della tassonomia botanica;
- consolidamento dei rank canonici;
- conferma della Cultivar come identità agronomica separata;
- supporto alla classificazione parziale mediante `parent_taxon_id`;
- integrazione Flutter dei Write Path di Tassonomia, Crop e Cultivar;
- supporto al collegamento opzionale `Crop → Taxon`;
- gestione di `row_version`, `version_conflict` ed esiti incerti;
- gestione UI della Classificazione botanica;
- applicazione delle capability autoritative.

La S033 ha completato:

- HUB Registri Agronomici Flutter;
- estrazione della Classificazione botanica in una pagina dedicata;
- gestione di Colture e Cultivar in una pagina dedicata;
- consolidamento della Fase A;
- verifica conclusiva con 80/80 test della Fase A e 1107/1107 test Flutter complessivi superati;
- analisi statica Flutter senza problemi segnalati.

La S033B ha completato, limitatamente al proprio perimetro:

- ricognizione statica di 21/21 RPC degli ulteriori Registri Agronomici;
- ricognizione dell'assenza di modelli e repository Flutter dedicati agli ulteriori registri nella baseline esaminata;
- audit locale dei Write Path di `plantings`;
- verifica dei privilegi, delle RLS e dei principali meccanismi di autorità e concorrenza;
- conclusione dell'audit senza difetti dimostrati che richiedessero correzioni immediate.

La S033B non ha introdotto modifiche persistenti a Flutter, SQL, migration o database.

La S034 ha completato, nel proprio perimetro:

- la correzione delle tre RPC del Catalog Registry per distinguere il congelamento semantico dagli altri errori `SQLSTATE 55000`;
- la migration `20261014200459_fix_catalog_registry_semantic_freeze_errors.sql`, applicata al database locale;
- le verifiche statiche e autorizzative previste, senza test dinamico specifico del ramo corretto durante la S034.

La S035 ha completato, nel proprio perimetro Flutter:

- la pagina di gestione delle Finalità di raccolta e la navigazione dal Catalogo Agronomico;
- consultazione, creazione, modifica e attivazione/disattivazione con capability e concorrenza ottimistica;
- 42 test Flutter mirati superati e `flutter analyze` senza problemi.

La S036 ha completato:

- protezione Flutter contro richieste duplicate di attivazione e disattivazione delle Finalità di raccolta;
- sei test SQL locali di regressione sulla correzione `SQLSTATE 55000`, tutti superati;
- suite Flutter conclusiva con 1.292 test superati;
- `flutter analyze` senza problemi.

La S038 ha completato, nel proprio perimetro:

- modelli tipizzati `AgronomicKnowledgeRequest` e `AgronomicKnowledgeResult`;
- repository Flutter `AgronomicKnowledgeRepository` e accesso alla RPC `resolve_agronomic_knowledge`;
- verifica dell'identità agronomica mediante `verifyAgronomicKnowledgeIdentity`;
- modelli, repository e pagine Flutter di `measurement_units` e `agronomic_parameters`;
- integrazione con le RPC autoritative, le capability e i meccanismi di concorrenza previsti;
- applicazione remota della migration correttiva S034;
- verifica di allineamento delle 34/34 migration locali e remote;
- verifiche Flutter mirate, integrate durante Manuali S038 con 178/178 test superati su otto file e `flutter analyze` senza problemi.

Il collaudo integrato Flutter–Supabase dei registri implementati e l'integrazione completa del Resolver nei flussi operativi rimangono aperti.

### Regole di pianificazione delle sessioni successive

Le attività FUTURE non costituiscono un calendario vincolante.

La scelta delle attività di ogni nuova sessione deve derivare:

1. dal CHECKPOINT DI RICEZIONE;
2. dalla verifica della baseline effettiva;
3. dalle dipendenze tecniche e funzionali;
4. dalle decisioni esplicitamente approvate.

Le roadmap informali ed esplorative rimangono esterne alla roadmap ufficiale, alla progettazione, alla documentazione, ai checkpoint e allo sviluppo operativo.

Non possono determinare automaticamente il contenuto delle sessioni future.

La nuova sessione non viene considerata iniziata fino alla sua apertura esplicita.

---

## Avvio della fase operativa reale

Il completamento tecnico del Catalogo Agronomico S030 non autorizza l'introduzione di dati dimostrativi o provvisori nel database.

La sequenza prevista per il passaggio all'utilizzo reale rimane:

1. verificare che il database locale sia nello stato atteso e privo di dati provvisori;

2. verificare separatamente lo stato del database remoto;

3. predisporre e pubblicare una baseline verificata del Catalogo Agronomico;

4. creare il Garden reale;

5. creare le 15 aiuole reali;

6. aprire la stagione reale;

7. registrare le coltivazioni reali.

Il popolamento operativo deve quindi iniziare soltanto quando il Catalogo dispone di una baseline sufficientemente verificata e approvata.

---

## Prossimo incremento

### Stato alla conclusione dello sviluppo S033/S033B

La **Sessione S033/S033B è conclusa nella fase di sviluppo**.

La S033 ha completato la Fase A Flutter dei Registri Agronomici, proseguendo l'integrazione applicativa del Catalogo Agronomico globale realizzata nelle sessioni precedenti.

I risultati comprendono:

- HUB Registri Agronomici integrato nella navigazione applicativa;
- pagina dedicata alla Classificazione botanica;
- pagina dedicata alla gestione di Colture e Cultivar;
- gestione delle operazioni di lettura, creazione, modifica, attivazione e disattivazione nel perimetro implementato;
- applicazione delle capability della Catalog Authority;
- gestione della concorrenza ottimistica mediante `row_version`;
- gestione di `version_conflict` ed esiti incerti senza overwrite forzati o retry automatici;
- rilettura autoritativa per verificare lo stato effettivamente persistito.

La verifica finale della Fase A ha prodotto:

```text
HUB Registri Agronomici:       11/11
Colture e Cultivar:            38/38
Fase A:                        80/80
Suite Flutter complessiva:   1107/1107

flutter analyze: No issues found
```

I conteggi delle verifiche mirate sono parzialmente sovrapposti e non devono essere sommati.

Il commit tecnico conclusivo dello sviluppo S033 è:

```text
270b27e654e072a1127509e335c13a45fae35d8d
```

La S033B ha successivamente eseguito una ricognizione statica delle RPC degli ulteriori Registri Agronomici.

Sono state censite **21/21 RPC** relative a sette registri:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

La ricognizione ha confermato la disponibilità dei contratti backend nel perimetro esaminato, senza equivalere alla realizzazione delle corrispondenti interfacce Flutter.

La S033B ha inoltre eseguito un audit locale dei Write Path di `plantings`:

```text
create_planting
update_planting
set_planting_status
```

L'esito è stato favorevole limitatamente al perimetro esaminato.

Non sono emersi difetti dimostrati tali da giustificare correzioni immediate.

Non sono stati eseguiti nuovi test runtime delle scritture, test di concorrenza, test end-to-end Flutter/Supabase o verifiche del database remoto.

La S033B non ha introdotto modifiche persistenti a Flutter, SQL, migration o database.

### Obiettivo iniziale approvato per la S034

Per la **Sessione S034** è stato approvato il seguente obiettivo iniziale:

**Progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.**

La S034 non è ancora iniziata.

L'obiettivo iniziale comprende una ricognizione progettuale finalizzata a valutare:

- contratti backend realmente disponibili per gli ulteriori Registri Agronomici;
- organizzazione dei modelli e dei repository Flutter;
- struttura delle schermate;
- navigazione e integrazione con l'HUB Registri Agronomici;
- capability, autorizzazioni e flussi di scrittura consentiti;
- gestione degli errori, dei conflitti e degli esiti incerti;
- dipendenze tecniche e verifiche necessarie.

Questi elementi costituiscono il perimetro iniziale della progettazione, non un elenco di implementazioni già approvate.

Il primo eventuale incremento implementativo dovrà essere valutato e deciso separatamente, sulla base dei risultati della verifica.

Non vengono assegnati automaticamente alla S034 gli ulteriori blocchi FUTURE del Catalogo Agronomico o delle altre aree applicative.

### Condizioni per l'avvio della nuova sessione

La S034 dovrà iniziare con un **CHECKPOINT DI RICEZIONE**.

Prima di introdurre modifiche al progetto sarà necessario verificare:

1. stato del repository Git e allineamento con `origin/main`;
2. ultimo commit effettivamente presente;
3. modifiche locali eventualmente non committate;
4. stato delle migration e del database locale;
5. eventuale stato del database remoto pertinente;
6. contratti backend autoritativi effettivamente disponibili;
7. stato dell'integrazione Flutter;
8. documentazione ufficiale aggiornata;
9. test e verifiche realmente eseguiti;
10. decisioni approvate, questioni aperte ed elementi FUTURE.

La chiusura della fase Manuali S033/S033B rimane distinta dall'avvio della S034.

Il completamento della documentazione non determina automaticamente l'inizio della nuova sessione di sviluppo.

### Quadro operativo aggiornato dopo S036 — Nessuna assegnazione automatica

Lo sviluppo S036 si è concluso il **21/10/2026 alle 14:36**. La gestione Flutter delle Finalità di raccolta, introdotta nella S035, è stata consolidata mediante la protezione dalle richieste duplicate di attivazione/disattivazione.

La S036 ha inoltre completato **sei test SQL locali di regressione su sei** per la gestione di `SQLSTATE 55000` nelle tre RPC del Catalog Registry interessate dalla correzione S034. Pertanto, il test dinamico specifico precedentemente indicato come aperto risulta eseguito e superato **nel perimetro locale verificato**.

Le verifiche Flutter finali hanno superato `flutter analyze` e **1.292 test automatici**.

Restano questioni aperte, da valutare nelle future sessioni ufficiali previa verifica della baseline effettiva:

- collaudo integrato Flutter–Supabase remoto della gestione delle Finalità di raccolta;
- eventuale applicazione al database remoto della migration correttiva S034 relativa a `SQLSTATE 55000`;
- verifica del comportamento remoto dopo un'eventuale applicazione della migration;
- progettazione e integrazione progressiva degli altri sei Registri Agronomici Flutter;
- ulteriori attività FUTURE del Catalogo Agronomico e della gestione dell'orto già censite nelle sezioni precedenti.

I risultati positivi dei test locali non costituiscono prova di deployment remoto né di collaudo integrato completo.

Le sezioni storiche relative all'obiettivo iniziale e alle condizioni di avvio della S034 rimangono documentazione delle decisioni precedenti, non istruzioni operative correnti.

**Nessuna attività è automaticamente approvata o assegnata alla S037.** L'eventuale nuova sessione di sviluppo richiederà apertura esplicita, CHECKPOINT DI RICEZIONE e decisioni autonome fondate sullo stato reale del progetto.

### Quadro operativo dopo S037 e obiettivo di primo utilizzo reale entro il 15/11/2026

La fase di sviluppo della Sessione S037 si è conclusa il **24/10/2026 alle 00:31**, dopo **9 h 32 min** di lavoro effettivo.

La sessione ha prodotto tre risultati distinti:

- **Audit statico degli Alias del Catalogo Agronomico:** verificata la semantica di attivazione indipendente dell'Alias e dell'identità canonica associata, con utilizzabilità subordinata allo stato attivo di entrambi. Nessuna anomalia dimostrata nel perimetro esaminato.
- **Audit statico dell'integrità Taxon/Crop:** esaminati i vincoli referenziali `ON DELETE RESTRICT`, le autorizzazioni RPC, la concorrenza ottimistica mediante `row_version` e la validazione dei riferimenti. Nessuna anomalia dimostrata nel perimetro esaminato.
- **Protezione Flutter delle scritture concorrenti nelle aiuole:** introdotto in `BedPage` il coordinamento dei flussi di scrittura incompatibili tramite `_runExclusiveWriteFlow`, con disabilitazione dei controlli pertinenti durante le operazioni in corso.

Per l'intervento Flutter sono stati superati **32/32 test mirati**, compresi due nuovi test di regressione, e `flutter analyze` non ha segnalato problemi.

Il commit tecnico conclusivo è `594e633` — `fix: impedisce scritture concorrenti nella gestione aiuole`.

La S037 non ha introdotto nuove migration né effettuato deployment remoto. Gli audit statici non sostituiscono test dinamici completi e la protezione applicativa di `BedPage` non sostituisce l'autorità del backend Supabase.

#### Obiettivo approvato il 25/10/2026

Il **25/10/2026** è stato approvato l'obiettivo operativo di **iniziare entro il 15/11/2026 l'utilizzo reale di Orto Smart per la pianificazione dell'orto 2027**.

L'obiettivo non equivale a dichiarare già pronta l'applicazione per l'uso operativo.

Prima dell'avvio effettivo dovrà essere verificata la fattibilità, considerando almeno:

- disponibilità di un Catalogo Agronomico strutturato, verificato e sufficientemente completo per le colture e le varietà da pianificare;
- gestione delle **15 aiuole reali**, con dimensioni di **90 × 700 cm** e vialetti di **50 cm**;
- disponibilità e correttezza dei controlli agronomici pertinenti, comprese le rotazioni;
- possibilità di distinguere la pianificazione delle semine e dei trapianti dagli eventi effettivamente eseguiti;
- utilizzo di dati reali, evitando popolamenti dimostrativi o provvisori nel database operativo;
- verifica dei percorsi applicativi e delle garanzie di sicurezza necessari al primo utilizzo.

L'irrigazione automatizzata, le integrazioni meteorologiche avanzate e la contabilità completa non costituiscono, di per sé, condizioni bloccanti per il primo utilizzo limitato alla pianificazione dell'orto 2027.

#### Verifiche ancora aperte

Restano da valutare o completare, nei rispettivi perimetri:

- test dinamici degli Alias e dei vincoli di integrità Taxon/Crop;
- collaudi integrati dei percorsi di scrittura Flutter–Supabase, ove necessari;
- riconciliazione dello stato delle migration tra ambiente locale e remoto, inclusa la correzione S034;
- valutazione della completezza operativa del Catalogo Agronomico per l'utilizzo reale;
- eventuali ulteriori incrementi indispensabili alla pianificazione dell'orto 2027.

La **verifica di fattibilità dell'obiettivo del 15/11/2026** è individuata come possibile primo argomento di valutazione della S038, ma non costituisce un'attività automaticamente autorizzata.

L'apertura della S038, il relativo perimetro e gli eventuali interventi saranno decisi autonomamente sulla base dello stato reale del progetto, secondo il workflow vigente.

Rimangono prioritari i principi **«Sicurezza prima di tutto»** e **«Presto e bene non conviene»**.

### Quadro operativo dopo S038 — Resolver Agronomico, Registri Flutter e preparazione all'utilizzo reale

La fase di sviluppo della **Sessione S038** si è conclusa il **29/10/2026 alle ore 10:21**, dopo **13 h 27 min** di lavoro effettivo.

La sessione ha prodotto tre risultati applicativi principali:

1. **Resolver Agronomico Flutter:** introduzione dei modelli tipizzati `AgronomicKnowledgeRequest` e `AgronomicKnowledgeResult`, del repository `AgronomicKnowledgeRepository` e dell'accesso alla RPC backend esistente `resolve_agronomic_knowledge`, con verifica dell'identità agronomica.
2. **Unità di misura:** implementazione dei modelli, repository e interfaccia Flutter del registro `measurement_units`, utilizzando i Write Path autoritativi esistenti.
3. **Parametri agronomici:** implementazione dei modelli, repository e interfaccia Flutter del registro `agronomic_parameters`, utilizzando i Write Path autoritativi esistenti.

Le implementazioni rispettano, nei rispettivi perimetri, le capability della Catalog Authority, la Profile Write Authority, la concorrenza ottimistica mediante `row_version` e la gestione controllata degli esiti incerti.

Alla conclusione della S038 risultano integrati a livello Flutter **3 dei 7 Registri Agronomici** censiti nella S033B:

- `harvest_purposes`, implementato nella S035;
- `measurement_units`, implementato nella S038;
- `agronomic_parameters`, implementato nella S038.

Rimangono FUTURE le integrazioni amministrative Flutter di `parameter_enum_values`, `production_contexts`, `protection_contexts` e `training_contexts`.

#### Stato delle migration e del backend

Durante la S038 è stata applicata al database Supabase remoto la migration correttiva S034:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La migration era già stata applicata localmente nella S034 e verificata mediante **6/6 test SQL locali di regressione superati** nella S036.

Alla conclusione dello sviluppo S038 risultavano **34/34 migration allineate tra locale e remoto**.

La S038 non ha introdotto nuove migration.

Il deployment remoto non dimostra, da solo, il corretto completamento dei flussi integrati di scrittura Flutter–Supabase.

#### Verifiche tecniche

Nel corso della fase Manuali S038, il **03/11/2026**, sono stati eseguiti controlli integrativi sul codice:

| Verifica | Esito |
|---|---|
| Otto file di test Flutter mirati | 178/178 superati |
| `flutter analyze` | No issues found! |
| Allineamento migration alla chiusura dello sviluppo | 34/34 |

Queste verifiche non costituiscono l'esecuzione dell'intera suite Flutter né un collaudo end-to-end sul database remoto.

Il Resolver canonico è disponibile a livello backend e il relativo contratto Flutter è stato implementato. Rimane aperta la sua integrazione completa nei flussi operativi di pianificazione e inserimento delle coltivazioni.

#### Obiettivo di utilizzo reale entro il 15/11/2026

Rimane valido l'obiettivo approvato il **25/10/2026** di iniziare entro il **15/11/2026** l'utilizzo reale di Orto Smart per pianificare l'orto 2027.

La S038 non ha dimostrato il completamento di tutte le condizioni necessarie per tale utilizzo.

La fattibilità deve ancora essere verificata sulla baseline effettiva, considerando almeno:

- disponibilità di un Catalogo Agronomico verificato e sufficientemente completo;
- gestione delle 15 aiuole reali;
- disponibilità dei controlli agronomici necessari, comprese le rotazioni;
- distinzione tra pianificazione ed esecuzione effettiva di semine e trapianti;
- percorsi applicativi e garanzie di sicurezza pertinenti;
- assenza di dati dimostrativi o provvisori nel database operativo.

L'obiettivo temporale non autorizza scorciatoie sulla sicurezza, sull'integrità dei dati o sulla verifica del Catalogo Agronomico.

#### Questioni aperte e sessioni successive

Rimangono da valutare:

- collaudi integrati Flutter–Supabase dei Registri Agronomici implementati;
- integrazione operativa del Resolver nei flussi di pianificazione;
- eventuale implementazione dei quattro Registri Agronomici Flutter rimanenti;
- verifiche dinamiche pertinenti sugli Alias e sull'integrità Taxon/Crop;
- verifica della fattibilità del primo utilizzo reale per la pianificazione 2027;
- ulteriori interventi eventualmente indispensabili, da individuare soltanto dopo la verifica della baseline.

La conclusione della S038 non assegna automaticamente alcuna di queste attività alla sessione successiva.

Ogni nuova sessione richiede apertura esplicita, CHECKPOINT DI RICEZIONE, verifica dello stato reale e approvazione del proprio perimetro.

Restano validi i principi **«Sicurezza prima di tutto»** e **«Presto e bene non conviene»**.

### Quadro operativo dopo S039 — Pianificazione stagionale autoritativa e obiettivo di utilizzo reale

La fase di sviluppo della **Sessione S039** si è conclusa il **05/11/2026 alle ore 00:02**, dopo **3 h 35 min** di lavoro effettivo.

Il commit tecnico conclusivo è `5527aa84582a6ecbe6c78c5c9862c315dbbe11e8`.

La S039 ha introdotto nel database Supabase locale le fondamenta autoritative della pianificazione stagionale delle coltivazioni, mantenendo distinta la pianificazione dalle coltivazioni realmente eseguite.

#### Modello persistente della pianificazione

Sono state introdotte le tabelle:

- `season_plans`, per il piano associato alla stagione;
- `planned_plantings`, per le singole coltivazioni pianificate.

Il modello collega la pianificazione al profilo, all'orto, alla stagione, all'aiuola e all'identità agronomica della coltura, con cultivar opzionale.

Le coltivazioni pianificate dispongono di informazioni temporali, geometriche, quantitative e descrittive, oltre al controllo di versione mediante `row_version`.

Il ciclo di vita autoritativo distingue gli stati:

- `draft`: pianificazione modificabile, senza prenotazione dello spazio;
- `confirmed`: pianificazione confermata, con protezione dello spazio previsto;
- `executed`: pianificazione eseguita e collegata alla coltivazione reale;
- `cancelled`: pianificazione annullata.

La presenza di una pianificazione non equivale alla creazione di una coltivazione reale.

#### Write Path autoritativi e protezioni

Sono state introdotte cinque RPC autoritative:

- `create_planned_planting`;
- `update_planned_planting`;
- `confirm_planned_planting`;
- `cancel_planned_planting`;
- `execute_planned_planting`.

Le operazioni rispettano il modello di autorizzazione Profile Write Authority, il controllo di concorrenza ottimistica e le protezioni server-side previste.

Le pianificazioni confermate proteggono gli spazi geometrici e temporali interessati, impedendo operazioni incompatibili sulle geometrie delle aiuole e sulle coltivazioni reali.

I controlli considerano la geometria storicizzata delle aiuole, la copertura temporale richiesta e le sovrapposizioni incompatibili.

L'esecuzione di una pianificazione confermata avviene mediante un'operazione atomica che crea la coltivazione reale, aggiorna lo stato della pianificazione e registra il collegamento tra i due elementi.

In caso di errore, l'operazione deve rispettare le garanzie transazionali del database.

#### Stato delle migration e delle verifiche

La S039 ha introdotto **11 migration SQL**, applicate esclusivamente all'ambiente Supabase locale.

**Non è stato effettuato il deployment delle migration S039 al database remoto.**

Le verifiche documentate alla conclusione dello sviluppo sono:

| Verifica | Esito |
|---|---|
| `flutter analyze` | Superato, nessun problema |
| Suite Flutter completa | 1.472/1.472 test superati |
| Controlli statici SQL e di sicurezza | Eseguiti nel perimetro documentato |
| Test SQL dinamici integrati della pianificazione | Non completati |
| Verifiche dinamiche di concorrenza e rollback | Non completate |
| Deployment remoto delle migration S039 | Non effettuato |
| Integrazione Flutter della pianificazione stagionale | Non completata |

Le verifiche statiche e il superamento della suite Flutter non dimostrano, da soli, il corretto funzionamento end-to-end dei nuovi Write Path SQL.

#### Obiettivo di utilizzo reale per la pianificazione dell'orto 2027

Rimane documentato l'obiettivo approvato il **25/10/2026** di iniziare entro il **15/11/2026** l'utilizzo reale di Orto Smart per pianificare l'orto 2027.

La S039 costituisce un avanzamento tecnico significativo verso tale obiettivo, ma **non dimostra che l'applicazione sia già pronta per l'utilizzo operativo reale**.

La verifica di fattibilità deve continuare a considerare:

- disponibilità e verifica del Catalogo Agronomico necessario;
- gestione corretta delle 15 aiuole reali;
- controlli agronomici pertinenti, comprese le rotazioni;
- integrazione dei percorsi Flutter necessari alla pianificazione;
- collaudo dei Write Path e delle garanzie di sicurezza;
- corretta distinzione tra pianificazione ed esecuzione reale;
- utilizzo esclusivo di dati operativi reali, senza popolamenti dimostrativi o provvisori.

La scadenza obiettivo non autorizza scorciatoie sulla sicurezza, sull'integrità dei dati o sulla qualità delle verifiche.

#### Questioni aperte e continuità

Alla conclusione della S039 rimangono aperti, nei rispettivi perimetri:

- test SQL dinamici integrati delle RPC di pianificazione;
- verifiche di concorrenza, protezioni geometriche e rollback;
- applicazione controllata delle migration S039 al database remoto;
- integrazione operativa Flutter della pianificazione stagionale;
- integrazione completa del Resolver Agronomico nei flussi applicativi pertinenti;
- verifica della fattibilità del primo utilizzo reale per la pianificazione 2027.

Queste questioni descrivono lo stato tecnico residuo e **non costituiscono attività automaticamente assegnate alla S040**.

Ogni nuova sessione richiede apertura esplicita, CHECKPOINT DI RICEZIONE, verifica della baseline effettiva e approvazione autonoma del proprio perimetro.

Restano validi i principi **«Sicurezza prima di tutto»** e **«Presto e bene non conviene»**.

### Vincoli permanenti

Rimangono validi i principi di sicurezza e coerenza progettuale:

- backend autoritativo per autorizzazioni, capability e invarianti persistenti;
- nessun overwrite forzato in presenza di conflitti;
- nessun retry automatico dopo esiti incerti;
- rilettura dello stato autoritativo prima di ulteriori operazioni;
- nessuna introduzione di dati dimostrativi o provvisori nel database operativo;
- popolamento del Catalogo Agronomico soltanto attraverso dati reali, verificati e tracciabili;
- separazione tra dati candidati acquisiti da fonti esterne e dati approvati;
- nessuna sovrascrittura automatica del Catalogo approvato;
- nessuna modifica preventiva non giustificata da un difetto dimostrato o da una decisione approvata.

Le roadmap esplorative informali rimangono completamente esterne alla roadmap ufficiale, alla progettazione, alla documentazione, ai checkpoint e allo sviluppo operativo.

Le attività delle sessioni successive devono essere valutate progressivamente sulla base dello stato reale raggiunto.

**Nessuna nuova sessione di sviluppo è considerata iniziata fino alla sua apertura esplicita.**
