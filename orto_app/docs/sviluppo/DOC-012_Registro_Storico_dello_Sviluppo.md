# ORTO SMART

### DOC-012

# Registro Storico dello Sviluppo

**Versione:** 4.7

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 29/07/2026

**Ultimo aggiornamento:** 26/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-012 |
| Titolo | Registro Storico dello Sviluppo |
| Versione | 4.7 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 29/07/2026 |
| Ultimo aggiornamento | 26/10/2026 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|----------|------|-------------|
| 1.0 | 29/07/2026 | Prima emissione del documento |
| 2.0 | 05/08/2026 | Revisione strutturale del documento, trasformazione del Registro Storico in cruscotto dell'evoluzione del progetto e uniformazione allo Standard Documentale |
| 2.1 | 08/08/2026 | Aggiornamento del Registro Storico con la Sessione S010 e consolidamento dell'evoluzione del sistema decisionale del Motore Agronomico |
| 2.2 | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S011 e introduzione della prima versione del FamilyNeedsEngine |
| 2.3 | 09/08/2026 | Aggiornamento del Registro Storico con la Sessione S012 e integrazione del FamilyNeedsEngine nella RecommendationPipeline |
| 2.4 | 10/08/2026 | Aggiornamento del Registro Storico con la Sessione S013 e predisposizione delle fondamenta del futuro SuccessionPlanningEngine |
| 2.5 | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S014 e prima implementazione del SuccessionPlanningEngine |
| 2.6 | 11/08/2026 | Aggiornamento del Registro Storico con la Sessione S015 e introduzione della prima infrastruttura delle finestre agronomiche |
| 2.7 | 12/08/2026 | Aggiornamento del Registro Storico con la Sessione S016 e associazione delle finestre agronomiche a colture e varietà |
| 2.8 | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S017, completamento e congelamento della baseline Database V1 e consolidamento dei tempi complessivi di sviluppo e documentazione |
| 2.9 | 16/08/2026 | Aggiornamento del Registro Storico con la Sessione S018: supporto alle finestre agronomiche multiple, predisposizione dell'ambiente locale Supabase e riallineamento degli indicatori evolutivi |
| 3.0 | 25/08/2026 | Aggiornamento del Registro Storico con le Sessioni S019, S020, S021 e S022, consolidamento dei tempi di sviluppo e documentazione e aggiornamento degli indicatori evolutivi |
| 3.1 | 28/08/2026 | Aggiornamento del Registro Storico con la Sessione S023, consolidamento dei Write Path autoritativi di `gardens` e `seasons`, integrazione Flutter della Profile Write Authority e riallineamento definitivo dei tempi S020–S023 |
| 3.2 | 01/09/2026 | Aggiornamento del Registro Storico con la Sessione S024: Write Path autoritativo di `beds`, geometria storicizzata, integrazione Flutter, versione 0.1.15-alpha e riallineamento degli indicatori evolutivi |
| 3.3 | 03/09/2026 | Manutenzione straordinaria del Registro Storico: consolidamento dei tempi complessivi delle Sessioni S001–S024, classificazione documentale della S007, riallineamento dei progressivi e aggiornamento del totale progetto a 167 h 51 min |
| 3.4 | 06/09/2026 | Aggiornamento del Registro Storico con la Sessione S025: completamento dell'integrazione Flutter dei Write Path autoritativi di `beds`, introduzione delle interfacce operative, gestione italiana delle date, verifica con 841/841 test superati e riallineamento degli indicatori al totale progetto di 174 h 47 min |
| 3.5 | 12/09/2026 | Aggiornamento con la Sessione S026: implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties`, nove RPC autoritative, sicurezza e concorrenza server-side, versione 0.1.17-alpha, definizione della S027 come integrazione Flutter del Catalogo V1 e consolidamento finale della S026 a 8 h 55 min |
| 3.6 | 14/09/2026 | Aggiornamento con la Sessione S027: completamento dell'integrazione Flutter del Catalogo V1, introduzione di `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, Repository e result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, 914/914 test superati, versione 0.1.18-alpha e chiusura definitiva della Sessione S027 a 2 h 33 min con totale progetto di 186 h 15 min |
| 3.7 | 17/09/2026 | Aggiornamento con la Sessione S028: implementazione del modello persistente e Write Path autoritativo di `plantings`, lifecycle server-side, geometria e overlap spazio-temporale, protezione delle geometrie delle aiuole mediante `blocked_by_plantings`, integrazione Flutter, 997/997 test superati, versione `0.1.19-alpha` / `0.1.19-alpha+4`; Sessione S028 conclusa in 11 h 20 min complessivi, di cui 9 h 04 min di sviluppo e 2 h 16 min di documentazione, con totale progetto pari a 197 h 35 min |
| 3.8 | 18/09/2026 | Aggiornamento e chiusura della Sessione S029: completamento della UI del lifecycle di `plantings`, gestione esplicita di `end_date` per gli stati terminali, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`, suite completa finale verificata con 1011/1011 test superati; Sessione S029 conclusa in 4 h 09 min complessivi, di cui 1 h 19 min di sviluppo e 2 h 50 min di documentazione, con totale progetto pari a 201 h 44 min |
| 3.9 | 28/09/2026 | Aggiornamento e chiusura della Sessione S030: completamento del Catalogo Agronomico globale attraverso 11 tranche tecniche, introduzione delle identità botaniche globali, Catalog Authority, fonti e osservazioni, workflow editoriale, Knowledge agronomica canonica, pubblicazione e Resolver, cutover finale Database + Flutter, 26 tabelle nel perimetro Catalogo e 953 test Flutter superati; Sessione S030 conclusa in 27 h 19 min complessivi, di cui 21 h 06 min di sviluppo e 6 h 13 min di documentazione, con totale progetto pari a 229 h 03 min |
| 4.0 | 01/10/2026 | Aggiornamento e chiusura della Sessione S031: integrazione operativa Flutter del Catalogo Agronomico nel percorso `Impostazioni → Catalogo Agronomico → Colture → Cultivar`, integrazione della Catalog Authority e delle relative capability, inizializzazione esplicita e confermata dell'authority, consultazione delle colture globali, caricamento on demand delle cultivar, gestione degli stati UI e rimozione del precedente percorso autonomo `Impostazioni → Varietà`; 971 test Flutter superati, nessuna nuova migration, Sessione S031 conclusa in 6 h 06 min complessivi, di cui 4 h 03 min di sviluppo e 2 h 03 min di documentazione, con totale progetto pari a 235 h 09 min; versione pubblica invariata a `0.1.21-alpha` e versione Flutter invariata a `0.1.21-alpha+6`. |
| 4.1 | 06/10/2026 | Aggiornamento e chiusura della Sessione S032: ricognizione del contratto autoritativo del Catalogo, integrazione Flutter dei Write Path di Taxon, Crop e Cultivar, completamento della UI di gestione della Classificazione botanica, concorrenza mediante `row_version`, gestione fail-safe di `version_conflict` ed esiti incerti e verifica finale con 1077/1077 test; Sessione S032 conclusa in 11 h 30 min complessivi, di cui 7 h 58 min di sviluppo e 3 h 32 min di documentazione; chiusura documentale il 06/10/2026 alle 14:30; totale progetto pari a 246 h 39 min; versione pubblica invariata a `0.1.21-alpha` e versione Flutter invariata a `0.1.21-alpha+6`. |
| 4.2 | 12/10/2026 | Aggiornamento del Registro Storico con lo sviluppo S033/S033B: completamento della Fase A Flutter dei Registri Agronomici, introduzione dell'HUB e delle pagine dedicate a Classificazione botanica e Colture/Cultivar, verifica finale con 1107/1107 test Flutter superati, ricognizione statica di 21/21 RPC dei Registri Agronomici e audit locale dei Write Path di `plantings` con esito favorevole nel perimetro esaminato; aggiornamento degli indicatori storici, delle milestone, degli indicatori evolutivi, degli elementi FUTURE e delle regole di registrazione delle ore. Fase sviluppo conclusa in 22 h 43 min; fase Manuali ancora in corso, con cronologia e progressivi definitivi da consolidare alla chiusura documentale. |
| 4.3 | 13/10/2026 | Consolidamento definitivo della Sessione S033/S033B dopo la chiusura della fase Manuali alle 21:34 del 13/10/2026; aggiornamento coordinato degli indicatori storici ed evolutivi, della cronologia sintetica, dei progressivi e dello stato delle milestone. Consuntivo definitivo S033/S033B di 24 h 35 min, composto da 22 h 43 min di sviluppo e 1 h 52 min di documentazione; progressivo complessivo del progetto pari a 271 h 14 min, di cui 203 h 23 min di sviluppo e 67 h 51 min di documentazione. Confermata la conclusione integrale della S033/S033B, con S033B come prosecuzione tecnica non autonoma; S034 non ancora avviata. |
| 4.4 | 15/10/2026 | Aggiornamento del Registro Storico con la Sessione S034: correzione della gestione delle eccezioni di congelamento semantico nelle RPC `update_measurement_unit`, `update_agronomic_parameter` e `update_parameter_enum_value`; gestione selettiva di `SQLSTATE 55000` tramite confronto esatto di `SQLERRM`, con propagazione delle eccezioni non riconosciute. Migration applicata al database locale; verifiche statiche e autorizzative superate, test dinamico specifico non eseguito e migration remota non applicata. Sviluppo S034 concluso con 5 h 11 min; fase Manuali S034 ancora in corso, con progressivi complessivi definitivi da consolidare alla chiusura documentale. |
| 4.5 | 17/10/2026 | S035: integrazione Flutter delle Finalità di raccolta, 42 test specifici superati, analisi Flutter senza problemi; sviluppo 2 h 23 min, progressivo sviluppo 210 h 57 min; Manuali in corso. |
| 4.6 | 21/10/2026 | Aggiornamento del Registro Storico con il consolidamento documentale della Sessione S036: protezione Flutter dalle richieste duplicate di attivazione e disattivazione delle Finalità di raccolta, verifiche SQL locali di regressione con 6/6 controlli superati, flutter analyze senza problemi e 1.292/1.292 test Flutter superati; registrazione dei commit b250b49 e 923c035, dei limiti del collaudo remoto e delle attività ancora aperte, senza attribuire alla sessione modifiche al database remoto non effettuate. |
| 4.7 | 26/10/2026 | Aggiornamento storico S037: audit statici Alias e Taxon/Crop, protezione delle scritture concorrenti in BedPage, verifiche Flutter, consuntivo sviluppo e obiettivo di primo utilizzo reale per l'orto 2027 |

---

# Indice

## 1. Scopo

## 2. Indicatori storici del progetto

## 3. Cronologia sintetica dello sviluppo

## 4. Milestone del progetto

## 5. Indicatori evolutivi

## 6. Regole di aggiornamento

## 7. Evoluzione futura

## 8. Considerazioni finali

---

# 1. Scopo

Il Registro Storico dello Sviluppo documenta l'evoluzione del progetto Orto Smart dal punto di vista storico e quantitativo.

Il documento ha lo scopo di mantenere una visione d'insieme dell'intero progetto, registrando nel tempo:

- la cronologia sintetica dello sviluppo;
- il tempo complessivamente dedicato al progetto;
- le principali milestone;
- l'evoluzione dell'architettura;
- la crescita della documentazione.

A differenza del DOC-005 – Quaderno di Sviluppo, che descrive in dettaglio le singole sessioni, il presente documento rappresenta una sintesi storica dell'intero progetto.

Il Registro Storico dello Sviluppo costituisce il riferimento ufficiale per il monitoraggio dell'evoluzione di Orto Smart.

# 2. Indicatori storici del progetto

Il presente capitolo riassume gli indicatori storici che descrivono lo stato evolutivo del progetto Orto Smart.

Gli indicatori riportati costituiscono una fotografia sintetica del progetto alla data dell'ultimo aggiornamento del presente documento e consentono di monitorarne la crescita nel tempo.

Le informazioni riportate vengono aggiornate sulla base delle sessioni di sviluppo effettivamente concluse e delle fasi documentali consolidate, mantenendo la coerenza con il Quaderno di Sviluppo (DOC-005), il Workflow Operativo (DOC-009) e le Decisioni Architetturali (DOC-011).

Manuali S036 conclusi il 21/10/2026 alle 22:39, tempo 6 h 29 min, totale sessione 13 h 03 min

## 2.1 Stato attuale del progetto

Alla data del **16/10/2026**, la Sessione S034 risulta definitivamente conclusa sia nella fase di sviluppo sia nella fase documentale.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

La fase Manuali S034 è stata dichiarata conclusa il **15/10/2026 alle 23:45**, con **3 h 42 min** di lavoro documentale effettivo.

Il tempo complessivo definitivo della S034 è **8 h 53 min**.

La S034 costituisce pertanto l'ultima sessione completamente conclusa. Il totale definitivo del progetto è **280 h 07 min**.

### Indicatori correnti

| Indicatore | Valore |
|------------|--------|
| Sessioni completamente concluse | 34 — S001–S034, con S033B come prosecuzione della S033 |
| Fasi sviluppo completate | 34 — S001–S034 |
| Ore di sviluppo consolidate | 208 h 34 min |
| Ore di documentazione consolidate | 71 h 33 min |
| Totale definitivo progetto alla chiusura S033/S033B | 271 h 14 min |
| Durata sviluppo S034 | 5 h 11 min |
| Durata documentazione S034 | 3 h 42 min |
| Durata complessiva definitiva S034 | 8 h 53 min |
| Totale definitivo progetto alla chiusura S034 | 280 h 07 min |
| Progressivo storico dopo il solo sviluppo S034 | 276 h 25 min |
| Ultima sessione completamente conclusa | S034 |
| Ultima fase sviluppo completata | S034 |
| Ultima fase documentale completata | Manuali S034 |
| Prossima sessione di sviluppo | Da definire secondo il workflow di sviluppo |
| Versione pubblica corrente | `0.1.21-alpha` |
| Versione Flutter corrente | `0.1.21-alpha+6` |

Il progressivo storico di **276 h 25 min** rappresenta lo stato raggiunto dopo il completamento dello sviluppo S034 e prima del consolidamento della relativa documentazione.

Il valore corrente definitivo è invece **280 h 07 min**.

### Chiusura storica S032

La fase sviluppo S032 si è svolta dal 01/10/2026 alle 13:18 al 04/10/2026 alle 13:17, attraverso più intervalli effettivi di lavoro e sospensione registrati nel Quaderno di Sviluppo (DOC-005).

Il tempo di sviluppo consolidato della Sessione S032 è:

```text
7 h 58 min
```

La fase Manuali S032 è iniziata il 04/10/2026 alle 22:40 ed è stata conclusa il 06/10/2026 alle 14:30.

Gli intervalli documentali definitivi sono:

```text
04/10/2026   22:40 → 22:58   0 h 18 min
05/10/2026   nessun lavoro   0 h 00 min
06/10/2026   09:59 → 10:55   0 h 56 min
06/10/2026   11:54 → 12:20   0 h 26 min
06/10/2026   12:38 → 14:30   1 h 52 min
---------------------------------------
Totale                         3 h 32 min
```

Gli intervalli compresi tra sospensioni e successive riprese sono esclusi dal conteggio.

Il tempo definitivo della S032 è:

| Attività | Durata |
|----------|-------:|
| Sviluppo | 7 h 58 min |
| Documentazione | 3 h 32 min |
| **Totale S032** | **11 h 30 min** |

I progressivi definitivi alla chiusura della S032 sono:

```text
Sviluppo complessivo        180 h 40 min
Documentazione complessiva   65 h 59 min
----------------------------------------
Totale progetto             246 h 39 min
```

Il progressivo complessivo deriva da:

```text
235 h 09 min   totale progetto alla chiusura S031
+11 h 30 min   totale Sessione S032
-----------------------------------------------
246 h 39 min   totale progetto alla chiusura S032
```

### Chiusura storica S033/S033B

La Sessione S033/S033B risulta definitivamente conclusa sia nella fase di sviluppo sia nella fase documentale.

La fase sviluppo S033/S033B è stata conclusa il **12/10/2026 alle 16:42**, con **22 h 43 min** di lavoro effettivo.

La fase Manuali S033/S033B è stata conclusa il **13/10/2026 alle 21:34**, con **1 h 52 min** di documentazione effettiva.

Il consuntivo definitivo della sessione è:

| Attività | Durata |
|----------|-------:|
| Sviluppo | 22 h 43 min |
| Documentazione | 1 h 52 min |
| **Totale S033/S033B** | **24 h 35 min** |

La prosecuzione tecnica S033B è parte integrante della S033 e non costituisce una sessione autonoma.

Il progressivo definitivo alla chiusura della S033/S033B è:

```text
Sviluppo complessivo        203 h 23 min
Documentazione complessiva   67 h 51 min
----------------------------------------
Totale progetto             271 h 14 min
```

Il precedente valore di **269 h 22 min** rappresenta esclusivamente il progressivo storico raggiunto dopo la conclusione dello sviluppo S033/S033B, prima del consolidamento delle ore documentali. Non costituisce più il totale definitivo corrente del progetto.

### Chiusura definitiva S034

La Sessione S034 ha completato la propria fase di sviluppo con un intervento circoscritto alla gestione delle eccezioni di congelamento semantico nel Catalog Registry.

L'intervento ha riguardato le seguenti funzioni:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La migration realizzata è:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione distingue l'eccezione PostgreSQL `SQLSTATE 55000` relativa al congelamento semantico dagli altri errori che possono utilizzare lo stesso codice SQLSTATE.

Le RPC interessate confrontano `SQLERRM` con il messaggio specifico emesso dal rispettivo trigger. Quando il messaggio corrisponde esattamente a quello atteso, la RPC restituisce:

```text
{"status":"semantics_frozen"}
```

Le eccezioni non riconosciute vengono propagate senza essere convertite automaticamente in un esito di congelamento semantico.

La migration è stata applicata al database Supabase locale. Non è stata applicata al database remoto durante la sessione.

Le verifiche effettuate comprendono:

- confronto statico delle tre RPC con le definizioni originali;
- verifica della coerenza dei trigger di congelamento semantico;
- tre controlli autorizzativi superati su tre;
- controllo `git diff --cached --check` superato.

Il test dinamico specifico del ramo `SQLSTATE 55000` non è stato eseguito. Il relativo esito non può quindi essere dichiarato superato.

Il commit conclusivo dello sviluppo S034 è:

```text
a0f51fff735aefc75b0fd60f74e727f13d6984f0
S034 Fix gestione SQLSTATE 55000 nel Catalog Registry
```

Il push su GitHub è stato completato e `HEAD` risulta allineato a `origin/main` alla chiusura dello sviluppo.

Alla verifica conclusiva dello sviluppo, l'unico elemento non tracciato segnalato era la cartella locale `.vscode/`, da mantenere fuori dal commit.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con un tempo netto di **5 h 11 min**.

La fase Manuali S034 è stata conclusa ufficialmente il **15/10/2026 alle 23:45**, con un tempo netto di **3 h 42 min**.

Il consuntivo definitivo della sessione è:

| Attività | Durata |
|----------|-------:|
| Sviluppo | 5 h 11 min |
| Documentazione | 3 h 42 min |
| **Totale S034** | **8 h 53 min** |

Il progressivo storico dopo il completamento del solo sviluppo S034 era:

```text
Totale progetto alla chiusura S033/S033B   271 h 14 min
+ Sviluppo S034                              5 h 11 min
-----------------------------------------------------
Progressivo storico intermedio             276 h 25 min
```

Il progressivo definitivo alla chiusura della S034 è:

```text
Totale progetto alla chiusura S033/S033B   271 h 14 min
+ Sviluppo S034                              5 h 11 min
+ Documentazione S034                        3 h 42 min
-----------------------------------------------------
Totale definitivo progetto                 280 h 07 min
```

La ripartizione definitiva del progetto è:

```text
Sviluppo complessivo        208 h 34 min
Documentazione complessiva   71 h 33 min
----------------------------------------
Totale progetto             280 h 07 min
```

La versione pubblica e la versione Flutter rimangono invariate:

```text
Versione pubblica   0.1.21-alpha
Versione Flutter    0.1.21-alpha+6
```

La chiusura della S034 riguarda il perimetro effettivamente completato e verificato. Non implica l'esecuzione dei test rimasti aperti né l'applicazione della migration al database remoto.

### Baseline architetturale ereditata dalla S032

La Sessione S032 ha completato la ricognizione del contratto backend del Catalogo Agronomico globale e l'integrazione Flutter dei Write Path autoritativi di Taxon, Crop e Cultivar.

La tassonomia botanica globale utilizza i rank:

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

`CULTIVAR` non costituisce un rank tassonomico: la Cultivar è un'identità agronomica globale separata.

La gerarchia botanica utilizza `parent_taxon_id` e ammette classificazioni parziali senza richiedere la creazione artificiale di tutti i livelli intermedi.

Per Taxon, Crop e Cultivar, la concorrenza ottimistica applicativa utilizza `row_version`.

In presenza di `version_conflict`, il client non forza sovrascritture né ripete automaticamente la scrittura. In presenza di un esito incerto, il client rilegge lo stato autoritativo dal backend senza effettuare retry automatici potenzialmente duplicativi.

Le regole di integrità e le invarianti persistenti rimangono autoritative lato server.

La terminologia applicativa approvata per la tassonomia è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

Restano distinti i meccanismi di autorizzazione:

```text
Catalog Authority
```

e:

```text
Profile Write Authority / profile_edit_locks
```

Il Catalogo Agronomico globale non appartiene al profilo operativo del singolo orto.

La S032 ha concluso la propria fase sviluppo con:

```text
flutter analyze
    No issues found

flutter test
    1077 test superati
```

Il commit tecnico conclusivo della fase sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

### S033 — Fase A Registri Agronomici Flutter

La Sessione S033 ha completato la **Fase A di sviluppo Flutter dei Registri Agronomici**, proseguendo l'evoluzione applicativa del Catalogo Agronomico senza trasferire al client l'autorità delle regole persistenti.

Le attività completate comprendono:

- **A1 — HUB Registri Agronomici:** organizzazione del percorso applicativo e della navigazione;
- **A2 — Classificazione botanica:** estrazione della gestione tassonomica in una pagina dedicata;
- **A3 — Colture e Cultivar:** estrazione della gestione delle identità agronomiche in una pagina dedicata, con consultazione e operazioni amministrative autorizzate;
- **A4 — Consolidamento:** verifiche statiche, test e controllo finale dell'integrazione Flutter.

La gestione delle identità botaniche e agronomiche è stata organizzata in percorsi applicativi distinti, mantenendo le dipendenze e i controlli di autorizzazione previsti dalla baseline.

La gestione Flutter di Colture e Cultivar comprende i flussi di creazione, modifica e attivazione/disattivazione nel perimetro delle capability autorizzate.

Gli esiti incerti e i conflitti non determinano scritture automatiche di recupero: lo stato persistente viene riletto dall'autorità backend prima di consentire ulteriori decisioni operative.

Le verifiche conclusive S033 hanno restituito:

```text
HUB Registri Agronomici       11/11 test
Colture e Cultivar            38/38 test
Fase A                        80/80 test
Suite Flutter complessiva   1107/1107 test

flutter analyze
    No issues found

git diff --check
    Nessuna anomalia
```

I gruppi di test indicati appartengono a perimetri parzialmente sovrapposti e **non devono essere sommati tra loro**.

La versione pubblica e la versione Flutter sono rimaste invariate:

```text
Versione pubblica   0.1.21-alpha
Versione Flutter    0.1.21-alpha+6
```

I commit tecnici della S033 comprendono:

```text
8a864ee  Integra gestione Colture Catalogo Agronomico
015f899  Integra gestione Cultivar Catalogo Agronomico
841763b  Estrae Classificazione botanica dal Catalogo Agronomico
270b27e  Estrae Colture e Cultivar dal Catalogo Agronomico
```

Il commit HEAD conclusivo dello sviluppo è:

```text
270b27e654e072a1127509e335c13a45fae35d8d
Estrae Colture e Cultivar dal Catalogo Agronomico
```

Alla chiusura dello sviluppo il branch `main` risultava allineato a `origin/main` e il working tree risultava pulito.

### S033B — Ricognizione backend dei Registri Agronomici

La fase S033B ha svolto una ricognizione del backend già disponibile per i Registri Agronomici.

Nel perimetro esaminato sono state censite **21 RPC su 21**, relative alle seguenti entità:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

La ricognizione ha identificato il contratto autoritativo già presente e le dipendenze da considerare nella successiva progettazione Flutter.

Nel perimetro Flutter esaminato non risultavano ancora implementati i corrispondenti modelli e repository applicativi dedicati a questi Registri.

La ricognizione non costituisce implementazione della Fase B Flutter.

### S033B — Audit locale del Write Path di plantings

La S033B ha inoltre esaminato il perimetro locale disponibile delle funzioni autoritative di `plantings`:

```text
create_planting
update_planting
set_planting_status
```

Le verifiche hanno riguardato, nel perimetro osservato:

- proprietà e configurazione `SECURITY DEFINER` delle funzioni;
- privilegi di esecuzione e assenza di overload rilevati;
- abilitazione RLS e policy SELECT;
- assenza di privilegi diretti di scrittura per i ruoli applicativi ordinari;
- trigger di aggiornamento e `row_version`;
- controlli della Profile Write Authority;
- meccanismi di lock, lease e takeover;
- generazione e gestione server-side dei token di lock.

L'esito della ricognizione è stato **favorevole limitatamente al perimetro esaminato**, senza evidenza di difetti dimostrati che richiedessero correzioni immediate.

Questa conclusione **non costituisce una certificazione generale di sicurezza**.

Non sono stati eseguiti nuovi test runtime di scrittura, test di concorrenza, test end-to-end Flutter/Supabase o verifiche del database remoto nell'ambito dell'audit S033B.

La S033B non ha introdotto modifiche Flutter, SQL, migration o modifiche persistenti al database.

È stata effettuata soltanto la pulizia di uno snippet SQL temporaneo, secondo la decisione approvata.

### Decisioni e continuità progettuale

Le decisioni consolidate con S033/S033B comprendono:

- completamento della Fase A Flutter dei Registri Agronomici;
- accettazione delle verifiche finali nel perimetro effettivamente testato;
- esito favorevole dell'audit locale di `plantings`, limitatamente alle verifiche eseguite;
- nessuna correzione preventiva del backend in assenza di un difetto dimostrato;
- conservazione della separazione tra autorità backend e responsabilità del client Flutter;
- chiusura dello sviluppo S033/S033B il 12/10/2026 alle 16:42.

La S034 ha introdotto la correzione circoscritta della gestione delle eccezioni di congelamento semantico nel Catalog Registry.

La S034 risulta definitivamente conclusa, con chiusura dello sviluppo il **15/10/2026 alle 13:58** e chiusura della documentazione il **15/10/2026 alle 23:45**.

La conclusione della S034 non determina automaticamente il perimetro operativo delle sessioni future, che resta soggetto a valutazione e decisione autonoma.

### Elementi FUTURE e verifiche ancora aperte

Rimangono FUTURE o da valutare nelle successive sessioni:

- implementazione Flutter dei Registri Agronomici oltre la Fase A;
- gestione applicativa degli alias del Catalogo;
- acquisizione e aggiornamento delle fonti agronomiche;
- gestione dei dati candidati e revisione editoriale;
- pubblicazione e integrazione del Resolver nei flussi operativi;
- backend canonico delle consociazioni;
- selezione esplicita della Cultivar nella creazione dei planting;
- ulteriori test runtime dei Write Path di `plantings`;
- verifiche di concorrenza della Profile Write Authority;
- test end-to-end Flutter/Supabase e verifica del database remoto;
- eventuali approfondimenti di hardening, solo previa dimostrazione e valutazione del problema;
- hard delete dei planting esclusivamente come correzione amministrativa o tecnica eccezionale;
- completamento delle ulteriori funzionalità operative dell'orto secondo le decisioni delle sessioni future.

Restano inoltre aperte, per la correzione S034:

- esecuzione del test dinamico specifico del ramo `SQLSTATE 55000`;
- eventuale applicazione della migration al database remoto, subordinata a una decisione operativa successiva.

Queste attività non sono considerate automaticamente autorizzate o completate.

Il popolamento reale del Catalogo con dati agronomici rimane subordinato a un workflow sufficientemente sicuro, verificato e tracciabile.

Il database deve continuare a rimanere privo di dati demo o provvisori fino all'avvio della gestione reale dell'orto.

Le roadmap informali o esplorative non costituiscono baseline progettuale, decisione operativa né autorizzazione a modificare lo sviluppo o la documentazione ufficiale.

### Aggiornamento indicatori S035 — Sviluppo concluso, Manuali in corso

La fase sviluppo S035 si è conclusa il **16/10/2026 alle 23:39**, con **2 h 23 min** di lavoro effettivo. La fase Manuali S035 è ancora in corso.

| Indicatore | Valore |
|---|---:|
| Fasi sviluppo completate | 35 — S001–S035 |
| Ultima fase sviluppo completata | S035 |
| Ultima sessione completamente conclusa | S034 |
| Sviluppo S035 | 2 h 23 min |
| Sviluppo complessivo consolidato | 210 h 57 min |
| Documentazione consolidata fino a S034 | 71 h 33 min |
| Totale definitivo alla chiusura S034 | 280 h 07 min |
| Progressivo intermedio dopo il solo sviluppo S035 | 282 h 30 min |

Il progressivo di **282 h 30 min** non è il totale definitivo della S035: esclude le ore Manuali S035, da consolidare nel DOC-010. I consuntivi S034 restano invariati.

---

# 3. Cronologia sintetica dello sviluppo

La cronologia sintetica riporta, in ordine cronologico, le principali sessioni che hanno caratterizzato l'evoluzione del progetto Orto Smart.

Per ciascuna sessione completamente conclusa vengono indicati l'evento principale e il tempo complessivo della sessione, comprensivo dello sviluppo e della documentazione quando entrambi presenti.

La Sessione S032 è stata completamente conclusa con **7 h 58 min di sviluppo** e **3 h 32 min di documentazione**, per un totale di **11 h 30 min**.

La successiva Sessione **S033/S033B è stata completamente conclusa il 13/10/2026**, con **22 h 43 min di sviluppo** e **1 h 52 min di documentazione**, per un totale definitivo di **24 h 35 min**.

La prosecuzione tecnica S033B è parte integrante della S033 e non costituisce una sessione autonoma.

Il progressivo definitivo del progetto alla chiusura della S033/S033B è **271 h 14 min**.

La Sessione **S034 è stata completamente conclusa il 15/10/2026**, con chiusura dello sviluppo alle **13:58** e chiusura ufficiale della fase Manuali alle **23:45**.

Il consuntivo definitivo della S034 comprende **5 h 11 min di sviluppo** e **3 h 42 min di documentazione**, per un totale di **8 h 53 min**.

Il progressivo definitivo del progetto alla chiusura della S034 è **280 h 07 min**.

| Sessione | Attività principale | Ore sessione | Totale progressivo |
|-----------|---------------------|-------------:|-------------------:|
| **S001** | Avvio del progetto Orto Smart | **6 h 00 min** | **6 h 00 min** |
| **S002** | Evoluzione dell'architettura e integrazione Supabase | **7 h 00 min** | **13 h 00 min** |
| **S003** | Realizzazione del FreeSpace Engine e del Suggestion Engine | **8 h 00 min** | **21 h 00 min** |
| **S004** | Sviluppo del Companion Engine e refactoring dell'architettura | **5 h 00 min** | **26 h 00 min** |
| **S005** | Introduzione del BedAnalysisService e integrazione dell'analisi agronomica | **4 h 00 min** | **30 h 00 min** |
| **S006** | Decision Engine, integrazione dell'analisi agronomica e completamento della documentazione di progetto | **4 h 00 min** | **34 h 00 min** |
| **S007** | Revisione e consolidamento della documentazione tecnica | **11 h 00 min*** | **45 h 00 min** |
| **S008** | Censimento e consolidamento della documentazione residua | **4 h 16 min** | **49 h 16 min** |
| **S009** | Evoluzione dell'architettura del Motore Agronomico e introduzione della RecommendationPipeline | **5 h 22 min** | **54 h 38 min** |
| **S010** | Configurazione dei pesi del DecisionEngine mediante DecisionWeights | **4 h 54 min** | **59 h 32 min** |
| **S011** | Prima implementazione del FamilyNeedsEngine per la valutazione delle priorità e dei fabbisogni familiari | **2 h 27 min** | **61 h 59 min** |
| **S012** | Integrazione del FamilyNeedsEngine nella RecommendationPipeline mediante ordinamento gerarchico delle raccomandazioni | **1 h 42 min** | **63 h 41 min** |
| **S013** | Introduzione dei fabbisogni quantitativi familiari e dei lotti pianificati come fondamenta del futuro SuccessionPlanningEngine | **2 h 07 min** | **65 h 48 min** |
| **S014** | Prima implementazione del SuccessionPlanningEngine per la generazione temporale validata dei lotti di coltivazione | **2 h 46 min** | **68 h 34 min** |
| **S015** | Prima implementazione delle finestre agronomiche mediante AgronomicWindow, AgronomicWindowValidator e AgronomicWindowEngine | **1 h 59 min** | **70 h 33 min** |
| **S016** | Associazione delle finestre agronomiche a colture e varietà e introduzione della valutazione stagionale dei lotti pianificati | **2 h 02 min** | **72 h 35 min** |
| **S017** | Progettazione completa e congelamento della baseline Database V1 | **25 h 14 min** | **97 h 49 min** |
| **S018** | Supporto alle finestre agronomiche multiple e predisposizione dell'ambiente locale Supabase | **3 h 56 min** | **101 h 45 min** |
| **S019** | Prima migration Database V1, implementazione delle Fondazioni e prima sicurezza RLS | **8 h 13 min** | **109 h 58 min** |
| **S020** | Hardening di `profile_edit_locks` e implementazione delle RPC server-side per il protocollo di takeover | **6 h 54 min** | **116 h 52 min** |
| **S021** | Completamento e hardening del protocollo `profile_edit_locks` e verifica delle transizioni concorrenti | **9 h 57 min** | **126 h 49 min** |
| **S022** | Primo Write Path autoritativo di Categoria A per `gardens` | **9 h 34 min** | **136 h 23 min** |
| **S023** | Profile Write Authority applicativa, hardening concorrente di `gardens` e Write Path autoritativo di `seasons` | **13 h 25 min** | **149 h 48 min** |
| **S024** | Write Path autoritativo di `beds`, geometria storicizzata e integrazione Flutter della creazione dell'aiuola | **18 h 03 min** | **167 h 51 min** |
| **S025** | Completamento dell'integrazione Flutter dei Write Path autoritativi di `beds` | **6 h 56 min** | **174 h 47 min** |
| **S026** | Implementazione del Catalogo DB V1 `botanical_families` → `crops` → `crop_varieties` e dei relativi Write Path autoritativi | **8 h 55 min** | **183 h 42 min** |
| **S027** | Integrazione Flutter del Catalogo V1 | **2 h 33 min** | **186 h 15 min** |
| **S028** | Implementazione del modello e Write Path autoritativo di `plantings` | **11 h 20 min** | **197 h 35 min** |
| **S029** | Completamento della UI del lifecycle di `plantings` | **4 h 09 min** | **201 h 44 min** |
| **S030** | Implementazione del Catalogo Agronomico globale e cutover finale Database + Flutter | **27 h 19 min** | **229 h 03 min** |
| **S031** | Integrazione operativa Flutter del Catalogo Agronomico e navigazione gerarchica Coltura → Cultivar | **6 h 06 min** | **235 h 09 min** |
| **S032** | Write Path Flutter di Taxon, Crop e Cultivar e gestione completa della Classificazione botanica | **11 h 30 min** | **246 h 39 min** |
| **S033/S033B** | Completamento della Fase A Flutter dei Registri Agronomici, HUB e pagine Classificazione botanica e Colture/Cultivar; ricognizione statica delle 21 RPC dei Registri Agronomici e audit locale dei Write Path di `plantings` | **24 h 35 min** | **271 h 14 min** |
| **S034** | Correzione delle eccezioni di congelamento semantico in tre RPC del Catalog Registry; migration applicata al database locale; sviluppo e Manuali conclusi | **8 h 53 min** | **280 h 07 min** |

* La durata della S007 costituisce un valore storico consolidato riferito esclusivamente alla revisione e al consolidamento documentale. Non sono disponibili gli intervalli puntuali originari.

La riga S034 rappresenta il consuntivo definitivo della sessione, comprensivo dello sviluppo e della documentazione ufficialmente conclusa.

Per le Sessioni S004, S005 e S006 è disponibile il tempo complessivo storico della sessione, ma non la ripartizione attendibile tra sviluppo e documentazione.

Per la Sessione S026 il tempo complessivo di **8 h 55 min** è composto da:

```text
Sviluppo        7 h 04 min
Documentazione  1 h 51 min
-------------------------
Totale          8 h 55 min
```

Per la Sessione S027 il tempo complessivo di **2 h 33 min** è composto da:

```text
Sviluppo        1 h 18 min
Documentazione  1 h 15 min
-------------------------
Totale          2 h 33 min
```

Per la Sessione S028 il tempo complessivo di **11 h 20 min** è composto da:

```text
Sviluppo        9 h 04 min
Documentazione  2 h 16 min
-------------------------
Totale         11 h 20 min
```

Per la Sessione S029 il tempo complessivo di **4 h 09 min** è composto da:

```text
Sviluppo        1 h 19 min
Documentazione  2 h 50 min
-------------------------
Totale          4 h 09 min
```

La fase Manuali S029 si è svolta il 18/09/2026 secondo gli intervalli:

```text
09:03 → 10:41   1 h 38 min
11:31 → 12:43   1 h 12 min
---------------------------
Totale          2 h 50 min
```

La pausa dichiarata dalle 10:41 alle 11:31 è esclusa dal conteggio.

Per la Sessione S030 il tempo complessivo di **27 h 19 min** è composto da:

```text
Sviluppo        21 h 06 min
Documentazione   6 h 13 min
--------------------------
Totale          27 h 19 min
```

La fase sviluppo S030 si è svolta dal 18/09/2026 al 23/09/2026 ed è stata chiusa alle 22:23 del 23/09/2026.

La fase Manuali S030 si è svolta secondo gli intervalli:

```text
23/09/2026   22:48 → 23:14   0 h 26 min
24/09/2026   09:02 → 12:54   3 h 52 min
27/09/2026   21:00 → 22:32   1 h 32 min
28/09/2026   11:22 → 11:45   0 h 23 min
---------------------------------------
Totale                         6 h 13 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

Il totale progressivo definitivo del progetto alla chiusura della S030 è:

```text
229 h 03 min
```

Per la Sessione S031 il tempo complessivo di **6 h 06 min** è composto da:

```text
Sviluppo         4 h 03 min
Documentazione   2 h 03 min
--------------------------
Totale           6 h 06 min
```

La fase sviluppo S031 si è svolta secondo gli intervalli consolidati nel Quaderno di Sviluppo (DOC-005) ed è stata chiusa alle **11:33 del 30/09/2026**, con un tempo netto complessivo di **4 h 03 min**.

La fase Manuali S031 si è svolta secondo gli intervalli:

```text
30/09/2026   11:37 → 12:00   0 h 23 min
01/10/2026   09:16 → 09:58   0 h 42 min
01/10/2026   11:09 → 12:07   0 h 58 min
---------------------------------------
Totale                         2 h 03 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

La fase documentale S031 è stata conclusa alle **12:07 del 01/10/2026**.

Il totale progressivo definitivo del progetto alla chiusura della S031 è:

```text
235 h 09 min
```

Per la Sessione S032 il tempo complessivo definitivo di **11 h 30 min** è composto da:

```text
Sviluppo         7 h 58 min
Documentazione   3 h 32 min
--------------------------
Totale          11 h 30 min
```

La fase sviluppo S032 si è svolta dal **01/10/2026 alle 13:18** al **04/10/2026 alle 13:17**, attraverso gli intervalli effettivi registrati nel Quaderno di Sviluppo (DOC-005), per un tempo netto complessivo di **7 h 58 min**.

La fase Manuali S032 si è svolta secondo gli intervalli:

```text
04/10/2026   22:40 → 22:58   0 h 18 min
05/10/2026   nessun lavoro   0 h 00 min
06/10/2026   09:59 → 10:55   0 h 56 min
06/10/2026   11:54 → 12:20   0 h 26 min
06/10/2026   12:38 → 14:30   1 h 52 min
---------------------------------------
Totale                         3 h 32 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

La fase documentale S032 è stata conclusa alle **14:30 del 06/10/2026**.

Il totale progressivo definitivo del progetto alla chiusura della S032 è:

```text
246 h 39 min
```

Per la Sessione S033/S033B il tempo complessivo definitivo di **24 h 35 min** è composto da:

```text
Sviluppo        22 h 43 min
Documentazione   1 h 52 min
--------------------------
Totale          24 h 35 min
```

La fase sviluppo S033/S033B, comprensiva della prosecuzione tecnica S033B, è stata conclusa il **12/10/2026 alle 16:42**, per un tempo netto complessivo di **22 h 43 min**, secondo gli intervalli effettivi registrati nel Quaderno di Sviluppo (DOC-005).

La fase Manuali S033/S033B è iniziata il **12/10/2026 alle 16:52** e si è svolta secondo gli intervalli:

```text
12/10/2026   16:52 → 17:02   0 h 10 min
12/10/2026   19:04 → 20:03   0 h 59 min
13/10/2026   10:32 → 10:54   0 h 22 min
13/10/2026   21:13 → 21:34   0 h 21 min
---------------------------------------
Totale                         1 h 52 min
```

Gli intervalli tra le sospensioni e le successive riprese sono esclusi dal conteggio.

La fase documentale S033/S033B è stata conclusa alle **21:34 del 13/10/2026**.

Il totale progressivo definitivo del progetto alla chiusura della S033/S033B deriva da:

```text
246 h 39 min   totale progetto alla chiusura S032
+24 h 35 min   totale Sessione S033/S033B
-----------------------------------------------
271 h 14 min   totale progetto alla chiusura S033/S033B
```

Il totale progressivo definitivo del progetto alla chiusura della S033/S033B è:

```text
271 h 14 min
```

La ripartizione complessiva aggiornata alla chiusura S033/S033B è:

```text
Sviluppo complessivo        203 h 23 min
Documentazione complessiva   67 h 51 min
----------------------------------------
Totale progetto             271 h 14 min
```

La S033/S033B risulta completamente conclusa.

### Chiusura definitiva S034

La Sessione S034 risulta definitivamente conclusa sia nella fase sviluppo sia nella fase Manuali.

La fase sviluppo si è svolta secondo gli intervalli:

```text
13/10/2026   22:25 → 23:48   1 h 23 min
14/10/2026   18:50 → 20:08   1 h 18 min
14/10/2026   20:48 → 22:18   1 h 30 min
15/10/2026   12:58 → 13:58   1 h 00 min
---------------------------------------
Totale                         5 h 11 min
```

Le pause tra gli intervalli sono escluse dal conteggio.

L'intervento ha riguardato la gestione delle eccezioni di congelamento semantico nelle RPC:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La migration realizzata è:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione distingue i casi di congelamento semantico riconosciuti mediante confronto esatto di `SQLERRM` per `SQLSTATE 55000`, senza convertire automaticamente in `semantics_frozen` altre eccezioni che utilizzano il medesimo SQLSTATE.

La migration è stata applicata al database Supabase locale, ma non al database remoto.

Sono state superate le verifiche statiche e autorizzative previste nel perimetro esaminato. Il test dinamico specifico del ramo `SQLSTATE 55000` non è stato eseguito.

Il commit conclusivo dello sviluppo è:

```text
a0f51fff735aefc75b0fd60f74e727f13d6984f0
```

Il commit è stato pubblicato su GitHub, con `HEAD` allineato a `origin/main` alla verifica conclusiva dello sviluppo.

Il progressivo storico dopo la sola fase sviluppo S034 deriva da:

```text
271 h 14 min   totale definitivo alla chiusura S033/S033B
+ 5 h 11 min   sviluppo S034
---------------------------------------------------------
276 h 25 min   progressivo storico dopo lo sviluppo S034
```

La fase Manuali S034 è iniziata il **15/10/2026 alle 14:27** e si è svolta secondo gli intervalli:

```text
15/10/2026   14:27 → 14:42   0 h 15 min
15/10/2026   19:10 → 20:31   1 h 21 min
15/10/2026   21:39 → 23:45   2 h 06 min
---------------------------------------
Totale                         3 h 42 min
```

Gli intervalli di sospensione sono esclusi dal conteggio.

La fase documentale S034 è stata dichiarata conclusa ufficialmente il **15/10/2026 alle 23:45**.

La successiva sospensione della conversazione alle **23:54** non modifica l'orario di chiusura ufficiale né il consuntivo della fase Manuali.

Il consuntivo definitivo della Sessione S034 è:

```text
Sviluppo         5 h 11 min
Documentazione   3 h 42 min
--------------------------
Totale           8 h 53 min
```

Il progressivo definitivo del progetto alla chiusura S034 deriva da:

```text
271 h 14 min   totale definitivo alla chiusura S033/S033B
+ 8 h 53 min   totale Sessione S034
---------------------------------------------------------
280 h 07 min   totale definitivo alla chiusura S034
```

La ripartizione complessiva definitiva è:

```text
Sviluppo complessivo        208 h 34 min
Documentazione complessiva   71 h 33 min
----------------------------------------
Totale progetto             280 h 07 min
```

La S034 risulta completamente conclusa.

La chiusura della sessione non implica il completamento del test dinamico specifico del ramo `SQLSTATE 55000` né l'applicazione della migration al database remoto. Entrambe le attività rimangono aperte e soggette alle decisioni delle successive sessioni.

---

### S035 — Finalità di raccolta: integrazione Flutter

Il **16/10/2026** si è conclusa la fase sviluppo S035 dedicata alla gestione Flutter delle Finalità di raccolta nei Registri Agronomici. Superati **42 test specifici** (30 + 12); `flutter analyze` senza problemi.

Commit conclusivo pubblicato su GitHub: `9024e2f0c5f30052371aa8264fa1a5b2ef283efe`.

Nessuna modifica al database nella S035. Restano aperti i test integrati Flutter–Supabase, il test dinamico specifico del ramo `SQLSTATE 55000` e la valutazione dell'applicazione remota della migration S034.

**Sviluppo:** 2 h 23 min. **Progressivo sviluppo:** 210 h 57 min. **Manuali:** in corso.

---

### S036 — Protezione RPC Flutter e regressione SQL locale

Il **21/10/2026 alle 14:36** si è conclusa la fase sviluppo S036, con **6 h 34 min** di lavoro effettivo.

La sessione ha consolidato la gestione Flutter delle Finalità di raccolta, introducendo una protezione contro l'invio di richieste RPC duplicate durante le operazioni di attivazione e disattivazione già in corso.

È stata inoltre completata la verifica dinamica locale del comportamento `SQLSTATE 55000` introdotto dalla migration S034, mediante test SQL di regressione sulle tre RPC interessate.

**Verifiche concluse:**

- **6/6 test SQL locali** superati, con rollback e senza persistenza di dati di prova.
- **1.292/1.292 test Flutter** superati.
- `flutter analyze` completato senza problemi.

**Commit di riferimento:**

- `b250b49` — protezione Flutter contro le richieste RPC duplicate.
- `923c035` — test SQL locali di regressione.

**Stato database:** la migration `20261014200459_fix_catalog_registry_semantic_freeze_errors.sql` risulta applicata nell'ambiente locale, ma non ancora nell'ambiente remoto.

**Verifiche ancora aperte:** applicazione remota della migration S034 e test integrato del percorso di scrittura Flutter–Supabase remoto.

**Sviluppo S036:** 6 h 34 min. **Progressivo sviluppo:** 217 h 31 min.

Manuali S036 conclusi il 21/10/2026 alle 22:39, tempo 6 h 29 min, totale sessione 13 h 03 min

### S037 — Integrità del Catalogo e protezione delle scritture concorrenti

La Sessione S037 si è svolta dal **22/10/2026 alle 17:27** al **24/10/2026 alle 00:31**, per un tempo netto di sviluppo di **9 h 32 min**.

La sessione ha affrontato tre ambiti:

- **Soluzione A:** audit statico della semantica di attivazione degli Alias del Catalogo Agronomico.
- **Soluzione B:** audit statico dei vincoli di integrità storica Taxon/Crop.
- **Soluzione C:** protezione Flutter dalle operazioni di scrittura concorrenti nella gestione delle aiuole.

Gli audit statici delle Soluzioni A e B non hanno evidenziato anomalie dimostrate nel perimetro esaminato. Non sono stati eseguiti nuovi test dinamici completi e non sono state introdotte modifiche correttive al database.

La Soluzione C ha introdotto in `BedPage` la gestione centralizzata dei flussi di scrittura mediante `_runExclusiveWriteFlow`, impedendo l'avvio simultaneo di operazioni incompatibili nella stessa pagina.

**Verifiche concluse:**

- **32/32 test Flutter mirati** superati in `test/pages/bed_page_test.dart`.
- Due nuovi test di regressione.
- `flutter analyze` completato senza problemi.
- `git diff --cached --check` superato.

**Commit di riferimento:** `594e633` — `fix: impedisce scritture concorrenti nella gestione aiuole`.

La sessione non ha prodotto nuove migration né effettuato deployment sul database remoto.

**Sviluppo S037:** 9 h 32 min. **Progressivo sviluppo:** 227 h 03 min.

La fase Manuali S037 è iniziata il **26/10/2026 alle 11:25** e il suo consuntivo definitivo sarà registrato soltanto dopo la chiusura dichiarata.

Il **25/10/2026** è stato approvato l'obiettivo di iniziare l'utilizzo reale di Orto Smart per la pianificazione dell'orto 2027 **entro il 15/11/2026**.

La fattibilità dell'obiettivo deve ancora essere verificata. Nessuna attività tecnica della S038 è automaticamente autorizzata.

---

## 3.1 Lettura della cronologia

La cronologia sintetica riportata nel presente capitolo costituisce uno strumento di consultazione rapida dell'evoluzione del progetto.

Essa consente di:

- ricostruire le principali tappe dello sviluppo;
- monitorare la crescita del progetto nel tempo;
- valutare l'impegno complessivamente dedicato allo sviluppo;
- mantenere uno storico sintetico delle attività svolte;
- distinguere i progressivi definitivi dalle registrazioni provvisorie delle sessioni con documentazione ancora in corso.

---

# 4. Milestone del progetto

Le milestone rappresentano i principali traguardi che hanno segnato l'evoluzione del progetto Orto Smart.

A differenza della cronologia delle sessioni, che documenta lo svolgimento delle attività nel tempo, le milestone evidenziano i cambiamenti che hanno avuto un impatto significativo sull'architettura, sulle funzionalità, sull'organizzazione o sulla documentazione del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la crescita complessiva di Orto Smart.

La registrazione di una milestone tecnica attesta il raggiungimento del traguardo nel perimetro effettivamente verificato e non implica necessariamente la conclusione della relativa fase documentale.

| Sessione | Milestone | Descrizione |
|-----------|-----------|-------------|
| **S001** | Avvio del progetto | Definizione degli obiettivi e creazione della struttura iniziale dell'applicazione. |
| **S002** | Integrazione Supabase | Collegamento dell'app al database e definizione della prima architettura dati. |
| **S003** | Primo Motore Agronomico | Completamento del FreeSpace Engine e del Suggestion Engine. |
| **S004** | Companion Engine | Introduzione del motore delle consociazioni e refactoring dell'architettura agronomica. |
| **S005** | BedAnalysisService | Centralizzazione dell'analisi agronomica tramite un servizio dedicato. |
| **S006** | Decision Engine | Introduzione del Decision Engine, integrazione dell'analisi agronomica nell'interfaccia utente e consolidamento del Workflow Operativo e della documentazione tecnica. |
| **S007** | Revisione e consolidamento della documentazione tecnica | Revisione organica dei principali documenti del progetto, definizione del workflow documentale e consolidamento del sistema documentale ufficiale di Orto Smart. |
| **S008** | Consolidamento del sistema documentale del progetto | Completata la revisione della documentazione ufficiale del progetto, definito il ruolo di ciascun documento e consolidato il sistema documentale di Orto Smart. |
| **S009** | RecommendationPipeline | Completata la nuova architettura del processo di raccomandazione mediante l'introduzione della RecommendationPipeline come componente di orchestrazione del Motore Agronomico. |
| **S010** | DecisionWeights | Introduzione della configurazione separata e validata dei pesi del DecisionEngine, rendendo il sistema decisionale configurabile e predisposto all'integrazione futura di ulteriori criteri agronomici. |
| **S011** | FamilyNeedsEngine | Prima implementazione del motore dedicato alla valutazione delle priorità e dei fabbisogni familiari, mantenuto separato dalla futura pianificazione quantitativa e temporale delle coltivazioni. |
| **S012** | Integrazione FamilyNeedsEngine nella RecommendationPipeline | Integrazione delle esigenze familiari nel processo di raccomandazione mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico, mantenendo invariato il punteggio agronomico del DecisionEngine. |
| **S013** | Fondamenta del SuccessionPlanningEngine | Introduzione di `FamilyConsumptionNeed`, `FamilyConsumptionNeedValidator`, `PlannedPlantingBatch` e `PlannedPlantingBatchValidator` come fondamenta dati e di validazione per la futura pianificazione quantitativa e temporale delle coltivazioni. |
| **S014** | Prima versione del SuccessionPlanningEngine | Implementazione della prima versione deterministica del `SuccessionPlanningEngine`, capace di trasformare un `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, rifiutando le conversioni tra fabbisogno familiare e quantità di impianto non supportate dai dati agronomici disponibili. |
| **S015** | Prima infrastruttura delle finestre agronomiche | Introduzione di `AgronomicWindow`, `AgronomicWindowValidator` e `AgronomicWindowEngine` per rappresentare finestre agronomiche annuali e verificare separatamente la compatibilità temporale dei lotti pianificati in base al metodo di avvio e alla data. |
| **S016** | Stagionalità di colture e varietà | Introduzione di `CropAgronomicWindowRule`, `AgronomicWindowResolver`, `AgronomicWindowEvaluation` e `AgronomicWindowService` per associare le finestre agronomiche a colture e varietà, applicare il fallback varietà → coltura e distinguere `compatible`, `incompatible` e `unknown`. |
| **S017** | Baseline Database V1 | Completamento e congelamento della progettazione logica e architetturale del Database V1: 52 entità di dominio, struttura tecnica `profile_edit_locks`, ownership, modello di accesso familiare single-writer, temporalità, storicizzazione, invarianti, sicurezza, convenzioni dei dati e strategia di futura implementazione SQL/Supabase. |
| **S018** | Finestre agronomiche multiple e ambiente Supabase locale | Estensione della valutazione agronomica al supporto di più finestre applicabili, con fallback tra livelli di specificità, e predisposizione dell'ambiente locale WSL 2, Docker Desktop e Supabase CLI per l'implementazione incrementale della baseline Database V1 mediante migration versionate. |
| **S019** | Primo incremento fisico Database V1 | Creazione della prima migration `20260817103916_database_v1_baseline.sql`, implementazione del blocco Fondazioni (`profiles`, `profile_memberships`, `gardens`, `workers`, `seasons`, `profile_edit_locks`), introduzione dello schema `private`, helper autorizzativi, trigger metadata, prima matrice di 13 policy RLS e verifica locale positiva e negativa della sicurezza. |
| **S020** | RPC sicure per `profile_edit_locks` | Implementazione e verifica delle RPC server-side per la gestione del lock e del takeover, con hardening della sicurezza, dei token, dei lease e delle transizioni concorrenti. |
| **S021** | Hardening del protocollo `profile_edit_locks` | Completamento e audit del protocollo completo di `profile_edit_locks`, con verifica delle transizioni concorrenti mediante `FOR UPDATE`, rivalidazione server-side e trasferimento atomico del lock. |
| **S022** | Primo Write Path autoritativo di Categoria A | Introduzione del primo Write Path autoritativo del Database V1 per `gardens`, con `Profile Write Authority`, RPC `create_garden` e `update_garden`, revoca delle scritture dirette da parte di `authenticated`, validazioni server-side e verifica del comportamento concorrente. |
| **S023** | Profile Write Authority applicativa e Write Path di `seasons` | Rafforzato `update_garden` contro i lost update, implementato il Write Path autoritativo di `seasons`, introdotte l'identità tecnica del client e della sessione e integrati controller, scheduler, scope e gate fail-closed della Profile Write Authority nel ciclo applicativo Flutter. |
| **S024** | Write Path autoritativo di `beds` | Implementati `beds`, `bed_geometries` e `bed_geometry_corrections`, introdotte cinque RPC autoritative, integrati `BedRepository`, `ProfileContextScope` e `CreateBedPage`, parametrizzata la configurazione Supabase e verificati 781/781 test. |
| **S025** | Completamento UI del Write Path autoritativo di `beds` | Integrate modifica dei dati, attivazione e disattivazione, variazione geometrica ordinaria e correzione storica; introdotto `CivilDate`, mantenuta la separazione semantica delle operazioni geometriche, applicate rilettura autoritativa e gestione fail-closed e verificati 841/841 test. |
| **S026** | Catalogo DB V1 | Implementate `botanical_families`, `crops` e `crop_varieties` come catalogo Profile-owned con UUID, gerarchia e fallback Crop → Crop Variety, blocchi agronomici per acqua e resa, nove RPC autoritative, RLS in lettura, revoca delle scritture dirette, Profile Write Authority, concorrenza ottimistica e principio **catalogo corrente + snapshot storico**. |
| **S027** | Integrazione Flutter del Catalogo V1 | Integrato nel client Flutter il Catalogo V1 mediante `BotanicalFamily`, riallineamento di `Crop` e `CropVariety`, `BotanicalFamilyRepository`, `CropRepository` e `CropVarietyRepository`, result type dedicati, letture RLS, scritture RPC-only, Profile Write Authority fail-closed, gestione `row_version` e compatibilità legacy controllata; verificati 124 test mirati e 914/914 test complessivi. |
| **S028** | Write Path autoritativo di `plantings` | Implementato il modello persistente autoritativo delle coltivazioni reali, introdotte le RPC `create_planting`, `update_planting` e `set_planting_status`, lifecycle server-side, geometria half-open, controllo congiunto degli overlap temporali e longitudinali, compatibilità con la geometria storicizzata delle aiuole, esito `blocked_by_plantings`, Profile Write Authority, concorrenza ottimistica mediante `row_version`, integrazione Flutter e verifica finale con 997/997 test. |
| **S029** | Lifecycle operativo delle coltivazioni | Completata la UI del lifecycle di `plantings`, introdotte azioni contestuali in `PlantingCard`, gestione esplicita di `end_date` per `finished` e `removed`, mantenimento dell'occupazione nello stato `harvested`, refresh autoritativo su `version_conflict` e `invalid_transition`; nessuna modifica al contratto persistente S028. |
| **S030** | Catalogo Agronomico globale | Completata attraverso 11 tranche tecniche la nuova architettura globale del Catalogo Agronomico: identità botaniche globali, registro dei parametri agronomici, vocabolari e contesti, fonti/acquisizioni/osservazioni, alias e riconciliazione, workflow editoriale, Knowledge agronomica canonica, Catalog Authority e sicurezza, pubblicazione/versionamento, Resolver e read model, fino al cutover finale Database + Flutter. Il perimetro Catalogo comprende 26 tabelle; le vecchie strutture `botanical_families`, `catalog_crops_s030` e `crop_varieties` sono state rimosse e il contratto operativo è stato riallineato a `botanical_taxa`, `crops`, `crop_cultivars` e `cultivar_id`. |
| **S031** | Integrazione operativa Flutter del Catalogo Agronomico | Completata l'integrazione applicativa del Catalogo Agronomico globale nel percorso `Impostazioni → Catalogo Agronomico → Colture → Cultivar`; integrate la lettura delle capability della Catalog Authority e l'inizializzazione esplicita e confermata dell'authority, la consultazione delle colture globali, il caricamento on demand delle cultivar e gli stati loading/empty/error/retry; eliminato il precedente percorso autonomo `Impostazioni → Varietà`, mantenendo la gerarchia canonica Crop → Cultivar e il backend autoritativo. Nessuna nuova migration; verifica finale con 971 test Flutter superati. |
| **S032** | Write Path delle identità del Catalogo e gestione della Classificazione botanica | Verificato il contratto backend autoritativo del Catalogo e integrati nel client Flutter i Write Path di Taxon, Crop e Cultivar. Consolidato il contratto tassonomico globale con rank `ORDER`, `FAMILY`, `GENUS`, `SPECIES`, `SUBSPECIES`, `VARIETY`, `FORMA`, `UNRANKED`, esclusione di `CULTIVAR` dai rank, tassonomia parziale mediante `parent_taxon_id` e collegamento opzionale Crop → Taxon. Completata la UI della Classificazione botanica con lettura, creazione, modifica, disattivazione e riattivazione, capability della Catalog Authority, concorrenza mediante `row_version`, nessun overwrite o retry automatico su `version_conflict` o esito incerto e rilettura autoritativa dello stato. Nessuna nuova migration nel blocco conclusivo; verifica finale con 1077/1077 test Flutter superati. |
| **S033** | Fase A Registri Agronomici Flutter | Completati l'HUB Registri Agronomici e l'organizzazione delle pagine dedicate alla Classificazione botanica e alla gestione di Colture e Cultivar. Consolidati i flussi Flutter di consultazione e gestione autorizzata delle identità globali, preservando la Catalog Authority, le invarianti server-side, la concorrenza ottimistica e la gestione fail-safe degli esiti incerti. Completata la Fase A con 80/80 test nel relativo perimetro e 1107/1107 test nella suite Flutter complessiva; `flutter analyze` senza problemi. Nessun incremento della versione pubblica o Flutter. |
| **S033B** | Ricognizione backend Registri Agronomici e audit locale di `plantings` | Censite 21/21 RPC dei Registri Agronomici relative a unità di misura, parametri agronomici, valori enumerati e contesti di produzione, protezione, allevamento e destinazione del raccolto. Eseguito audit locale delle RPC `create_planting`, `update_planting` e `set_planting_status`, dei privilegi, della RLS e dei controlli di Profile Write Authority. Esito favorevole limitatamente al perimetro esaminato, senza nuovi test runtime di scrittura, concorrenza o end-to-end e senza verifica del database remoto. Nessuna modifica Flutter, SQL, migration o persistente al database; nessuna correzione preventiva in assenza di difetti dimostrati. |
| **S034** | Correzione della gestione del congelamento semantico nel Catalog Registry | Corrette le RPC `update_measurement_unit`, `update_agronomic_parameter` e `update_parameter_enum_value` mediante gestione selettiva di `SQLSTATE 55000` e confronto esatto di `SQLERRM` con il messaggio del rispettivo trigger. Solo i casi riconosciuti restituiscono `semantics_frozen`; le altre eccezioni vengono propagate. Migration `20261014200459_fix_catalog_registry_semantic_freeze_errors.sql` applicata al database locale, non al remoto. Verifiche statiche e autorizzative superate nel perimetro esaminato; test dinamico specifico del ramo `SQLSTATE 55000` non eseguito. Sviluppo concluso il 15/10/2026 alle 13:58 e Manuali conclusi ufficialmente il 15/10/2026 alle 23:45. Sessione completamente chiusa, per un totale di 8 h 53 min. |
| **S035** | Gestione Flutter delle Finalità di raccolta | Integrata nel client Flutter la gestione delle Finalità di raccolta nei Registri Agronomici. Superati 42 test specifici e `flutter analyze` senza problemi. Sviluppo e Manuali conclusi; il funzionamento integrato Flutter–Supabase remoto resta da verificare. |
| **S036** | Protezione RPC Flutter e regressione SQL locale | Introdotta la protezione contro richieste RPC duplicate durante l'attivazione e la disattivazione delle Finalità di raccolta. Superati 6/6 test SQL locali di regressione sul comportamento `SQLSTATE 55000`, con rollback, e 1.292/1.292 test Flutter; `flutter analyze` senza problemi. La migration S034 rimane non applicata al database remoto e il test integrato Flutter–Supabase remoto resta aperto. |

---

## 4.1 Significato delle milestone

Le milestone identificano gli eventi che hanno segnato un'evoluzione significativa del progetto.

Esse costituiscono i principali punti di riferimento per ricostruire la storia tecnica di Orto Smart e rappresentano i momenti in cui sono state introdotte nuove funzionalità, nuovi componenti architetturali o importanti cambiamenti organizzativi.

La registrazione di una milestone tecnica non implica necessariamente che la relativa sessione sia già completamente chiusa sotto il profilo documentale.

### Evoluzione del Catalogo Agronomico S030–S032

La milestone tecnica della Sessione S030 ha completato il passaggio dal precedente Catalogo V1 Profile-owned a un Catalogo Agronomico globale, multisource, tracciabile, versionabile, contestualizzabile ed editorialmente controllato, mantenuto separato dai dati operativi del singolo orto.

La relativa fase documentale S030 è conclusa.

La milestone tecnica della Sessione S031 ha portato il Catalogo Agronomico globale nel normale percorso applicativo delle Impostazioni, rendendo operativa la consultazione gerarchica:

```text
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La S031 ha inoltre integrato nell'interfaccia lo stato della Catalog Authority e le relative capability, mantenendo l'inizializzazione dell'authority come operazione esplicita e confermata e non come effetto automatico dell'apertura della pagina.

La relativa fase documentale S031 è conclusa.

La S031 non ha modificato il contratto persistente definito dalla S030 e non ha introdotto nuove migration: ha rappresentato l'incremento applicativo che ha reso consultabile nel client Flutter il Catalogo globale realizzato nella sessione precedente.

La milestone tecnica della Sessione S032 ha completato un ulteriore passaggio: dalla sola consultazione del Catalogo alla prima gestione applicativa completa di una sua identità globale.

La ricognizione iniziale della S032 ha verificato che il backend disponeva già dei Write Path autoritativi necessari per Taxon, Crop e Cultivar e di un contratto tassonomico più avanzato rispetto alla precedente roadmap esplorativa.

La S032 ha quindi integrato nel livello Flutter:

```text
Taxon Write Path
Crop Write Path
Cultivar Write Path
```

e ha completato la gestione della:

```text
Classificazione botanica
```

attraverso:

```text
consultazione
creazione
modifica
disattivazione
riattivazione
```

La gestione rimane subordinata alle capability della Catalog Authority.

Il contratto tassonomico consolidato nella S032 stabilisce inoltre che:

- `CULTIVAR` non è un rank tassonomico;
- la Cultivar è un'identità agronomica globale separata;
- la gerarchia botanica utilizza `parent_taxon_id`;
- la tassonomia può essere parziale;
- il collegamento Crop → Taxon è opzionale;
- il database rimane autoritativo per gerarchia, dipendenze, cicli, stato attivo e invarianti.

La concorrenza applicativa utilizza `row_version`.

In presenza di `version_conflict` non vengono effettuati overwrite forzati o retry automatici.

In presenza di un esito incerto di una scrittura il client non ripete automaticamente l'operazione, ma rilegge lo stato autoritativo dal backend.

Alla chiusura della S032 la completa UI amministrativa di Crop e Cultivar rimaneva un incremento successivo. Tale incremento è stato successivamente completato nella Fase A della S033.

La fase documentale S032 è conclusa. La Sessione S032 risulta pertanto completamente chiusa, sia nella fase di sviluppo sia nella fase documentale, alle **14:30 del 06/10/2026**.

La conclusione della S032 non equivale al completamento dell'intero workflow editoriale e amministrativo del Catalogo.

### S033 — Completamento della Fase A Flutter

La milestone tecnica S033 ha completato la Fase A Registri Agronomici Flutter.

L'incremento ha organizzato le funzionalità già integrate in una struttura applicativa più chiara, articolata in:

```text
HUB Registri Agronomici
    ├── Classificazione botanica
    └── Colture e Cultivar
```

La gestione della Classificazione botanica è stata collocata in una pagina dedicata, separandola dalla gestione di Colture e Cultivar.

La gestione applicativa di Colture e Cultivar è stata completata nel perimetro della Fase A, con consultazione, creazione, modifica, disattivazione e riattivazione subordinate alle capability della Catalog Authority.

La separazione delle pagine non modifica l'autorità dei contratti persistenti e non introduce regole client-side sostitutive delle invarianti server-side.

In caso di conflitto di versione o di esito incerto della scrittura, il client mantiene il comportamento fail-safe già definito, evitando overwrite e retry automatici e privilegiando la rilettura dello stato autoritativo.

La verifica finale S033 ha confermato:

```text
HUB Registri Agronomici       11/11
Colture e Cultivar            38/38
Fase A                        80/80
Suite Flutter complessiva   1107/1107

flutter analyze
    No issues found
```

I conteggi delle suite parziali si riferiscono a perimetri sovrapposti e non sono additivi.

La Fase A è conclusa, senza incremento della versione pubblica `0.1.21-alpha` né della versione Flutter `0.1.21-alpha+6`.

### S033B — Ricognizione del backend dei Registri Agronomici

La S033B ha verificato staticamente la disponibilità del contratto backend dei Registri Agronomici.

La ricognizione ha censito 21/21 RPC nel perimetro delle seguenti entità:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

Il censimento ha consentito di distinguere il backend già disponibile dalle componenti Flutter ancora da progettare.

Nel perimetro Flutter esaminato non risultavano implementati i modelli e repository dedicati a tali Registri.

La milestone riguarda pertanto la **ricognizione del contratto backend**, non l'implementazione del relativo sottosistema Flutter.

### S033B — Audit locale del Write Path di plantings

La S033B ha inoltre condotto un audit locale delle funzioni autoritative:

```text
create_planting
update_planting
set_planting_status
```

La verifica ha riguardato il contratto di esecuzione, i privilegi, la configurazione `SECURITY DEFINER`, la RLS, la policy di lettura, i trigger di aggiornamento, la concorrenza ottimistica e i meccanismi di Profile Write Authority.

L'esito è stato favorevole **nel solo perimetro effettivamente esaminato**.

Non sono stati eseguiti nuovi test runtime delle scritture, test di concorrenza, test end-to-end Flutter/Supabase o verifiche del database remoto.

L'esito non rappresenta una certificazione generale di sicurezza e non autorizza a considerare superflue eventuali verifiche successive.

Non sono emersi difetti dimostrati tali da richiedere correzioni immediate.

La S033B non ha introdotto modifiche Flutter, SQL, migration o persistenti al database.

### S034 — Correzione del Catalog Registry

La milestone tecnica S034 riguarda la correzione della gestione delle eccezioni di congelamento semantico nelle tre RPC autoritative:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La migration introdotta è:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione gestisce `SQLSTATE 55000` confrontando esattamente `SQLERRM` con il messaggio di congelamento semantico previsto dal rispettivo trigger.

Soltanto quando la corrispondenza è esatta viene restituito:

```json
{"status":"semantics_frozen"}
```

Le eccezioni non riconosciute vengono propagate, senza trasformarle automaticamente in un risultato di congelamento semantico.

La migration è stata applicata al database Supabase locale.

**Non è stata applicata al database remoto.**

Le verifiche della S034 hanno compreso:

- confronto statico delle tre RPC e dei tre trigger interessati;
- verifica dei tre controlli autorizzativi, tutti superati;
- controllo `git diff --cached --check` superato.

Il test dinamico specifico del ramo `SQLSTATE 55000` **non è stato eseguito**. La milestone non equivale pertanto alla validazione dinamica completa della correzione.

Il commit conclusivo dello sviluppo S034 è:

```text
a0f51fff735aefc75b0fd60f74e727f13d6984f0
```

Il commit è stato pubblicato su GitHub e, alla verifica conclusiva dello sviluppo, `HEAD` risultava allineato a `origin/main`.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

La fase Manuali S034 è stata dichiarata ufficialmente conclusa il **15/10/2026 alle 23:45**, con **3 h 42 min** di lavoro effettivo.

Il consuntivo definitivo della Sessione S034 è:

```text
Sviluppo         5 h 11 min
Documentazione   3 h 42 min
--------------------------
Totale           8 h 53 min
```

La Sessione S034 è pertanto completamente conclusa sotto il profilo dello sviluppo e della documentazione.

L'obiettivo inizialmente approvato per S034 riguardava la progettazione del sottosistema Flutter dei Registri Agronomici. Tale obiettivo rimane documentato come previsione storica, ma **non viene dichiarato completato** sulla base dell'intervento SQL effettivamente realizzato.

### S035 — Gestione Flutter delle Finalità di raccolta

La milestone S035 riguarda l'integrazione Flutter della gestione delle Finalità di raccolta (`harvest_purposes`) nell'ambito dei Registri Agronomici.

L'intervento ha reso disponibile il relativo percorso applicativo, mantenendo il backend Supabase quale autorità per le operazioni di scrittura e per l'applicazione delle invarianti.

Le verifiche della sessione hanno confermato:

- 42 test Flutter specifici superati;
- `flutter analyze` completato senza problemi.

La milestone tecnica non costituisce una certificazione del funzionamento integrato Flutter–Supabase remoto, per il quale restano necessarie verifiche dedicate.

La fase sviluppo S035 è stata completata in **2 h 23 min**.

La fase Manuali S035 è stata dichiarata conclusa il **18/10/2026 alle 21:38**, con **5 h 48 min** di lavoro effettivo.

Il consuntivo definitivo della sessione è:

```text
Sviluppo         2 h 23 min
Documentazione   5 h 48 min
--------------------------
Totale           8 h 11 min
```

La Sessione S035 risulta pertanto completamente conclusa sotto il profilo dello sviluppo e della documentazione, nei rispettivi perimetri verificati.

### S036 — Protezione RPC Flutter e regressione SQL locale

La milestone tecnica S036 ha consolidato la gestione Flutter delle Finalità di raccolta, introducendo una protezione contro l'invio di richieste RPC duplicate durante le operazioni di attivazione e disattivazione già in corso.

L'intervento riguarda il comportamento applicativo durante una richiesta pendente e non sostituisce le verifiche autoritative del backend Supabase.

La sessione ha inoltre completato la verifica dinamica locale della gestione di `SQLSTATE 55000` introdotta nella S034 dalla migration:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La regressione SQL ha interessato le tre RPC autoritative:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

Le verifiche concluse nella S036 comprendono:

- **6/6 test SQL locali** superati, con rollback e senza persistenza dei dati di prova;
- **1.292/1.292 test Flutter** superati;
- `flutter analyze` completato senza problemi.

I commit di riferimento sono:

```text
b250b49  Protezione Flutter contro le richieste RPC duplicate
923c035  Test SQL locali di regressione
```

La migration S034 risulta applicata al database Supabase locale, ma **non ancora al database remoto**.

Rimangono pertanto aperte l'applicazione remota della migration, previa decisione operativa, e la verifica integrata del percorso di scrittura Flutter–Supabase remoto.

La fase sviluppo S036 è stata conclusa il **21/10/2026 alle 14:36**, con **6 h 34 min** di lavoro effettivo.

Il progressivo complessivo dello sviluppo raggiunge **217 h 31 min**.

La fase Manuali S036 è ancora in corso. Il consuntivo definitivo della sessione e il progressivo complessivo del progetto saranno registrati dopo la sua chiusura ufficiale.

### S037 — Verifiche di integrità e protezione delle scritture concorrenti

La milestone tecnica S037 ha consolidato la gestione delle operazioni di scrittura nella pagina Flutter delle aiuole e ha effettuato due audit statici del Catalogo Agronomico globale.

#### Audit Alias del Catalogo Agronomico

È stata verificata staticamente la relazione tra lo stato `is_active` degli Alias e quello delle identità canoniche associate.

La regola esaminata prevede che l'Alias sia utilizzabile soltanto quando risultano attivi sia l'Alias sia il Taxon o Crop di riferimento.

Sono stati esaminati i percorsi pertinenti di `BotanicalTaxonRepository`, `CropRepository` e `public.crop_catalog_read`.

Nel perimetro ispezionato non sono state dimostrate violazioni.

Non sono stati eseguiti nuovi test dinamici completi degli Alias.

#### Audit integrità Taxon/Crop

La verifica statica ha riguardato:

- vincoli referenziali `ON DELETE RESTRICT`;
- autorizzazioni delle RPC;
- concorrenza ottimistica mediante `row_version`;
- validazione dei riferimenti.

Non sono state dimostrate anomalie nel perimetro esaminato.

Non sono state introdotte nuove restrizioni o modifiche persistenti al Catalogo.

#### Protezione delle scritture concorrenti in BedPage

È stato introdotto il meccanismo `_runExclusiveWriteFlow`, che coordina le operazioni di scrittura incompatibili all'interno della stessa pagina Flutter.

L'intervento ha interessato:

```text
lib/pages/bed_page.dart
lib/widgets/planting_card.dart
test/pages/bed_page_test.dart
```

Sono stati aggiunti due test di regressione.

Le verifiche hanno prodotto i seguenti risultati:

| Verifica | Esito |
|---|---|
| Test mirati `BedPage` | 32/32 superati |
| Nuovi test di regressione | 2 |
| `flutter analyze` | Nessun problema |
| `git diff --cached --check` | Superato |

La protezione applicativa non sostituisce i controlli autoritativi del backend e non costituisce un collaudo multi-client.

#### Stato del database e limiti

La S037 non ha introdotto nuove migration né effettuato deployment remoto.

Rimangono da verificare la riconciliazione delle migration locali e remote e lo stato della correzione S034 relativa a `SQLSTATE 55000`.

I sei test SQL locali relativi a tale correzione appartengono alla **S036**, non alla S037.

Non risultano completati nuovi test dinamici integrali degli Alias o dell'integrità Taxon/Crop, né un collaudo integrato completo Flutter–Supabase remoto.

#### Versionamento e tempi

Il commit tecnico di riferimento è:

```text
594e633  fix: impedisce scritture concorrenti nella gestione aiuole
```

La fase sviluppo è stata conclusa il **24/10/2026 alle 00:31**, con **9 h 32 min** di lavoro effettivo.

Il progressivo cumulativo dello sviluppo raggiunge **227 h 03 min**.

Il tempo della fase Manuali S037 sarà consolidato separatamente nel DOC-010.

#### Obiettivo operativo per l'orto 2027

Il **25/10/2026**, dopo la conclusione dello sviluppo S037, è stato approvato l'obiettivo di iniziare la pianificazione reale dell'orto 2027 mediante Orto Smart **entro il 15/11/2026**.

La verifica di fattibilità dovrà considerare:

- disponibilità e completezza operativa del Catalogo Agronomico;
- gestione delle 15 aiuole reali;
- stato del motore delle rotazioni;
- pianificazione delle colture e delle varietà;
- distinzione tra operazioni pianificate ed eventi effettivamente eseguiti.

La scadenza costituisce un obiettivo approvato, non una fattibilità già dimostrata.

La verifica di fattibilità è proposta come prima attività della S038, ma richiede una decisione operativa specifica.

L'automazione dell'irrigazione, le integrazioni meteorologiche avanzate e la contabilità completa non sono considerate condizioni bloccanti per il primo utilizzo finalizzato alla pianificazione.

Rimangono validi i principi **«Sicurezza prima di tutto»** e **«Presto e bene non conviene»**.

### Stato delle milestone e continuità

Lo sviluppo S033/S033B è stato concluso il **12/10/2026 alle 16:42**, per un tempo netto complessivo di **22 h 43 min**.

La relativa fase Manuali è stata conclusa il **13/10/2026 alle 21:34**, per un tempo complessivo di **1 h 52 min**.

La Sessione S033/S033B risulta pertanto **completamente conclusa**, sia sotto il profilo tecnico sia sotto quello documentale, con un consuntivo definitivo di **24 h 35 min**.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

La fase Manuali S034 è stata conclusa ufficialmente il **15/10/2026 alle 23:45**, con **3 h 42 min** di lavoro effettivo.

La Sessione S034 risulta completamente conclusa, con un consuntivo definitivo di **8 h 53 min**.

Il progressivo definitivo del progetto alla chiusura della S033/S033B è **271 h 14 min**.

Il progressivo storico intermedio, dopo la sola fase sviluppo S034, era **276 h 25 min**.

Alla chiusura definitiva della S034 il progressivo del progetto è **280 h 07 min**, ripartito in:

```text
Sviluppo complessivo        208 h 34 min
Documentazione complessiva   71 h 33 min
----------------------------------------
Totale progetto             280 h 07 min
```

La fase sviluppo S035 è stata completata in **2 h 23 min**.

La fase Manuali S035 è stata conclusa il **18/10/2026 alle 21:38**, con **5 h 48 min** di lavoro effettivo.

La Sessione S035 risulta completamente conclusa, con un consuntivo definitivo di **8 h 11 min**.

Alla chiusura definitiva della S035 il progressivo del progetto è **288 h 18 min**, ripartito in:

```text
Sviluppo complessivo        210 h 57 min
Documentazione complessiva   77 h 21 min
----------------------------------------
Totale progetto             288 h 18 min
```

Il successivo intervento documentale sul DOC-010, effettuato il **18/10/2026 dalle 21:47 alle 22:07** per **20 min**, è distinto dal consuntivo definitivo S035 e non ne modifica la chiusura.

Considerando separatamente i 20 minuti dell'intervento DOC-010 successivo alla chiusura S035, il progressivo storico raggiunge **288 h 38 min**: **210 h 57 min** di sviluppo e **77 h 41 min** di documentazione.

La fase sviluppo S036 è stata conclusa il **21/10/2026 alle 14:36**, con **6 h 34 min** di lavoro effettivo.

Il progressivo intermedio del progetto, dopo la conclusione dello sviluppo S036 e prima del consolidamento dei Manuali S036, è **295 h 12 min**, ripartito in:

```text
Sviluppo complessivo        217 h 31 min
Documentazione precedente   77 h 41 min
----------------------------------------
Totale intermedio          295 h 12 min
```

La fase Manuali S036 è ancora aperta. Il relativo tempo effettivo sarà consolidato soltanto alla chiusura documentale dichiarata.

Le milestone tecniche raggiunte nei rispettivi perimetri non implicano il completamento delle funzionalità ancora classificate FUTURE.

Le attività ancora aperte comprendono, tra le altre:

- prosecuzione del sottosistema Flutter dei Registri Agronomici oltre le funzionalità già implementate;
- gestione applicativa degli alias;
- acquisizione e aggiornamento delle fonti;
- gestione dei dati candidati e revisione editoriale;
- pubblicazione;
- integrazione completa del Resolver nei flussi operativi;
- backend canonico delle consociazioni;
- selezione esplicita della Cultivar nella creazione dei planting;
- ulteriori verifiche runtime, di concorrenza ed end-to-end dei Write Path;
- eventuale applicazione della migration S034 al database remoto, previa decisione operativa;
- verifica integrata Flutter–Supabase remoto dei percorsi applicativi interessati;
- eventuali interventi di hardening soltanto a seguito di evidenze tecniche verificate.

L'obiettivo Flutter inizialmente approvato per la S034 rimane una registrazione storica:

> Progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.

La sua eventuale prosecuzione dovrà essere valutata e approvata separatamente, sulla base dello stato effettivo del progetto.

Nessuna attività FUTURE viene automaticamente autorizzata dalla conclusione delle milestone S034, S035 e S036.

---

# 5. Indicatori evolutivi

Il presente capitolo raccoglie gli indicatori che consentono di monitorare l'evoluzione del progetto nel tempo.

Gli indicatori storici riportati nel capitolo 2 descrivono lo stato consolidato alla data di aggiornamento del Registro, mentre gli indicatori evolutivi permettono di ricostruire la crescita di Orto Smart sotto il profilo organizzativo, tecnico e documentale.

## Fotografia storica al 13/10/2026 — chiusura S033/S033B

I valori e le indicazioni di stato riportati nella tabella seguente si riferiscono alla chiusura della Sessione S033/S033B, avvenuta prima dell'avvio della S034. Devono pertanto essere interpretati come dati storici consolidati a tale data, non come rappresentazione dello stato corrente del progetto.

Alla data del **13/10/2026**, le Sessioni **S001–S033** risultano completamente concluse, sia nella fase di sviluppo sia nella relativa fase documentale. La prosecuzione tecnica **S033B** è parte integrante della S033 e non costituisce una sessione autonoma.

Lo sviluppo S033/S033B è stato concluso il **12/10/2026 alle 16:42**, mentre la relativa fase Manuali è stata conclusa il **13/10/2026 alle 21:34**.

I progressivi definitivi alla chiusura della S032 rimangono invariati e costituiscono la base storica per il consolidamento della S033/S033B.

| Indicatore | Valore al 13/10/2026 |
|------------|----------------------|
| Sessioni completamente concluse | 33 — S001–S033, con S033B come prosecuzione della S033 |
| Fasi sviluppo completate | 33 — S001–S033 |
| Ore di sviluppo consolidate | 203 h 23 min |
| Ore di documentazione consolidate | 67 h 51 min |
| Totale definitivo progetto alla chiusura S032 | 246 h 39 min |
| Durata complessiva Sessione S033/S033B | 24 h 35 min |
| Totale definitivo progetto alla chiusura S033/S033B | 271 h 14 min |
| Motori agronomici completati | 5 |
| Documenti ufficiali approvati | 10 |
| Ultima sessione completamente conclusa | S033/S033B |
| Ultima fase sviluppo completata | S033/S033B |
| Ultima fase documentale completata | Manuali S033/S033B |
| Prossima sessione di sviluppo alla data della fotografia | S034, non ancora iniziata |
| Versione pubblica corrente alla data della fotografia | 0.1.21-alpha |
| Versione Flutter corrente alla data della fotografia | 0.1.21-alpha+6 |

Le **180 h 40 min** di sviluppo consolidate alla chiusura della S032 comprendono le **7 h 58 min** della relativa fase sviluppo.

Le **65 h 59 min** di documentazione consolidate alla chiusura della S032 comprendono le **3 h 32 min** della fase Manuali S032, conclusa alle **14:30 del 06/10/2026**.

Il totale definitivo del progetto alla chiusura della S032 è:

```text
Sviluppo        180 h 40 min
Documentazione   65 h 59 min
---------------------------
Totale          246 h 39 min
```

La Sessione S033/S033B ha aggiunto **22 h 43 min di sviluppo** e **1 h 52 min di documentazione**, per un totale di **24 h 35 min**.

Il progressivo definitivo aggiornato alla chiusura della S033/S033B è:

```text
Sviluppo S001–S032              180 h 40 min
Sviluppo S033/S033B              22 h 43 min
--------------------------------------------
Sviluppo complessivo            203 h 23 min

Documentazione fino alla S032    65 h 59 min
Documentazione S033/S033B         1 h 52 min
--------------------------------------------
Documentazione complessiva       67 h 51 min
```

Il totale complessivo definitivo del progetto alla chiusura della S033/S033B è:

```text
Sviluppo complessivo        203 h 23 min
Documentazione complessiva   67 h 51 min
----------------------------------------
Totale progetto             271 h 14 min
```

Il precedente progressivo di **269 h 22 min** rappresenta esclusivamente lo stato intermedio successivo alla chiusura dello sviluppo S033/S033B, prima del consolidamento della relativa documentazione.

Alla data di questa fotografia, la Sessione S033/S033B era definitivamente conclusa e la S034 non era ancora iniziata. L'obiettivo iniziale approvato per la S034 era la progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.

## Stato consolidato al 15/10/2026 — chiusura definitiva S034

La Sessione S034 è stata successivamente avviata e conclusa.

L'attività tecnica effettivamente realizzata ha riguardato la correzione della gestione del congelamento semantico nelle RPC autoritative del Catalog Registry.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, mentre la fase Manuali S034 è stata dichiarata ufficialmente conclusa il **15/10/2026 alle 23:45**.

| Indicatore | Valore alla chiusura S034 |
|------------|---------------------------|
| Sessioni completamente concluse | 34 — S001–S034, con S033B come prosecuzione della S033 |
| Fasi sviluppo completate | 34 — S001–S034 |
| Ultima sessione completamente conclusa | S034 |
| Ultima fase sviluppo completata | S034 |
| Ultima fase documentale completata | Manuali S034 |
| Durata sviluppo S034 | 5 h 11 min |
| Durata documentazione S034 | 3 h 42 min |
| Durata complessiva S034 | 8 h 53 min |
| Ore di sviluppo consolidate | 208 h 34 min |
| Ore di documentazione consolidate | 71 h 33 min |
| Totale definitivo progetto | 280 h 07 min |
| Versione pubblica | 0.1.21-alpha |
| Versione Flutter | 0.1.21-alpha+6 |

Il consuntivo definitivo della Sessione S034 è:

```text
Sviluppo S034          5 h 11 min
Documentazione S034    3 h 42 min
---------------------------------
Totale S034            8 h 53 min
```

Il progressivo complessivo del progetto alla chiusura della S034 è:

```text
Sviluppo complessivo        208 h 34 min
Documentazione complessiva   71 h 33 min
----------------------------------------
Totale progetto             280 h 07 min
```

Il progressivo di **276 h 25 min** rappresenta esclusivamente lo stato intermedio successivo alla chiusura dello sviluppo S034, prima del consolidamento della relativa documentazione.

La conclusione della S034 non implica il completamento del sottosistema Flutter dei Registri Agronomici, né l'esecuzione del test dinamico specifico del ramo `SQLSTATE 55000`.

La migration S034 risulta applicata al database locale, non al database remoto.

Le attività successive rimangono soggette a valutazione e approvazione autonoma nelle sessioni ufficiali di sviluppo.

## Stato evolutivo S035 — 16/10/2026

La S035 ha integrato la gestione Flutter delle Finalità di raccolta. Superati 42 test specifici; analisi statica Flutter senza problemi. Commit di sviluppo pubblicato: `9024e2f0c5f30052371aa8264fa1a5b2ef283efe`.

**Progressivo sviluppo:** 210 h 57 min. **Progressivo intermedio del progetto dopo il solo sviluppo S035:** 282 h 30 min. **Totale definitivo alla chiusura S034:** 280 h 07 min.

Restano aperti i test integrati Flutter–Supabase, il test dinamico `SQLSTATE 55000` e la valutazione della migration remota S034. Manuali S035 ancora in corso.

---

## Evoluzione funzionale S028–S034

La S028 ha completato il modello persistente e il Write Path autoritativo di `plantings`.

La S029 ha completato il livello applicativo del lifecycle delle coltivazioni.

La S030 ha completato una revisione architetturale del Catalogo Agronomico, sostituendo il precedente modello Profile-owned introdotto nelle S026–S027 con un modello globale separato dai dati operativi del singolo orto.

La S031 ha completato l'integrazione operativa Flutter del Catalogo Agronomico globale nel percorso:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La S031 ha inoltre integrato:

- lettura dello stato e delle capability della Catalog Authority;
- inizializzazione iniziale dell'authority mediante azione esplicita e confermata dall'utente;
- consultazione delle colture globali;
- caricamento delle cultivar on demand dopo la selezione della coltura;
- stati applicativi di loading, empty, error e retry;
- rimozione del precedente accesso autonomo `Impostazioni → Varietà`;
- mantenimento della gerarchia canonica Crop → Cultivar e del backend autoritativo.

La S032 ha completato:

- ricognizione del contratto backend autoritativo delle identità del Catalogo;
- integrazione Flutter del Write Path della tassonomia botanica;
- integrazione Flutter del Write Path Crop;
- integrazione Flutter del Write Path Cultivar;
- lettura della Classificazione botanica;
- creazione e modifica delle voci botaniche;
- disattivazione e riattivazione delle voci botaniche;
- gestione delle operazioni mediante capability della Catalog Authority;
- concorrenza ottimistica mediante `row_version`;
- rilettura autoritativa in presenza di `version_conflict` o esito incerto della scrittura;
- verifica finale con 1077/1077 test Flutter superati.

La S033 ha completato la **Fase A Registri Agronomici Flutter**, attraverso quattro incrementi:

- **A1 — HUB Registri Agronomici:** integrazione del punto di accesso e della navigazione applicativa;
- **A2 — Classificazione botanica:** estrazione della gestione in una pagina dedicata;
- **A3 — Colture e Cultivar:** completamento della gestione applicativa in una pagina dedicata, con operazioni autorizzate di creazione, modifica, disattivazione e riattivazione;
- **A4 — Consolidamento:** verifica dell'integrazione e della compatibilità con i contratti autoritativi esistenti.

La nuova organizzazione applicativa separa le responsabilità delle pagine:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
HUB Registri Agronomici
    ├── Classificazione botanica
    └── Colture e Cultivar
```

La Fase A mantiene la Catalog Authority come riferimento autorizzativo e il database come fonte autoritativa delle invarianti.

In presenza di `version_conflict` o di esito incerto di una scrittura, il client non esegue overwrite forzati o retry automatici, ma prevede la rilettura dello stato autoritativo.

La verifica tecnica finale S033 ha registrato:

```text
HUB Registri Agronomici       11/11
Colture e Cultivar            38/38
Fase A                        80/80
Suite Flutter complessiva   1107/1107

flutter analyze
    No issues found
```

I gruppi di test indicati hanno perimetri parzialmente sovrapposti: i relativi conteggi non devono essere sommati.

La S033B ha svolto una ricognizione statica del backend dei Registri Agronomici, censendo **21/21 RPC** relative a:

- `measurement_units`;
- `agronomic_parameters`;
- `parameter_enum_values`;
- `production_contexts`;
- `protection_contexts`;
- `training_contexts`;
- `harvest_purposes`.

La ricognizione ha confermato la disponibilità del contratto backend nel perimetro esaminato, senza equivalere all'implementazione delle corrispondenti funzionalità Flutter.

La S033B ha inoltre eseguito un audit locale dei Write Path di `plantings`:

- `create_planting`;
- `update_planting`;
- `set_planting_status`.

L'audit ha esaminato privilegi di esecuzione, configurazione `SECURITY DEFINER`, RLS, policy di lettura, trigger e meccanismi di Profile Write Authority.

L'esito è risultato favorevole **limitatamente alle verifiche locali effettivamente svolte**.

Non sono stati eseguiti nuovi test runtime di scrittura, test di concorrenza, test end-to-end Flutter/Supabase o verifiche del database remoto.

Non sono emersi difetti dimostrati che richiedessero una correzione immediata. La S033B non ha introdotto modifiche Flutter, SQL, migration o persistenti al database.

### S034 — Correzione della gestione del congelamento semantico

La S034 ha introdotto una correzione circoscritta al backend dei Registri Agronomici, relativa alla gestione delle eccezioni di congelamento semantico.

L'intervento ha interessato tre RPC:

- `public.update_measurement_unit`;
- `public.update_agronomic_parameter`;
- `public.update_parameter_enum_value`.

La migration realizzata è:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione intercetta `SQLSTATE 55000` e verifica che `SQLERRM` corrisponda esattamente al messaggio di congelamento semantico previsto dal rispettivo trigger.

Soltanto in caso di corrispondenza viene restituito l'esito:

```json
{"status":"semantics_frozen"}
```

Le altre eccezioni, comprese quelle che utilizzano `SQLSTATE 55000` con un messaggio differente, vengono propagate.

La migration è stata applicata esclusivamente al database Supabase locale. **Il database remoto non è stato aggiornato.**

Le verifiche eseguite hanno confermato:

- **3/3** confronti statici tra RPC e trigger;
- **3/3** verifiche autorizzative;
- superamento del controllo `git diff --cached --check`.

Il test dinamico specifico del ramo `SQLSTATE 55000` non è stato eseguito e non deve essere considerato superato.

La S034 non ha introdotto nuove funzionalità Flutter e non ha completato la progettazione del sottosistema Flutter dei Registri Agronomici, che costituiva l'obiettivo inizialmente approvato per la sessione.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con un tempo netto di **5 h 11 min**.

Il commit conclusivo è:

```text
a0f51fff735aefc75b0fd60f74e727f13d6984f0
```

Alla chiusura dello sviluppo, il commit risultava pubblicato su GitHub e il ramo `main` allineato a `origin/main`.

La fase Manuali S034 è stata dichiarata ufficialmente conclusa il **15/10/2026 alle 23:45**, con un tempo netto di **3 h 42 min**.

Il consuntivo definitivo della Sessione S034 è:

```text
Sviluppo          5 h 11 min
Documentazione    3 h 42 min
---------------------------
Totale            8 h 53 min
```

La Sessione S034 risulta pertanto **completamente conclusa**, sia sotto il profilo dello sviluppo sia sotto quello documentale.

Il progressivo definitivo del progetto alla chiusura S034 è di **280 h 07 min**, suddiviso in **208 h 34 min di sviluppo** e **71 h 33 min di documentazione**.

---

## Stato evolutivo delle funzionalità

Il quadro tecnico seguente rappresenta la situazione consolidata alla conclusione dello sviluppo S034 del **15/10/2026**. Gli aggiornamenti introdotti dalla S035 sono riportati nelle sezioni dedicate, senza alterare la fotografia storica S034.

La Sessione S034 è completamente conclusa; la fase sviluppo S035 è conclusa, mentre la fase Manuali S035 è ancora in corso.

```text
public.plantings
        COMPLETATO — modello persistente

Write Path autoritativo di plantings
        COMPLETATO

Lifecycle server-side di plantings
        COMPLETATO

UI di creazione e modifica di plantings
        COMPLETATA

UI lifecycle di plantings
        COMPLETATA

Gestione end_date terminale
        COMPLETATA

Refresh autoritativo su conflitti/transizioni non valide
        COMPLETATO

Catalogo Agronomico globale
        COMPLETATO — perimetro backend S030

Identità botaniche globali
        COMPLETATE — backend

Fonti, acquisizioni e osservazioni
        COMPLETATE — strutture backend S030

Workflow editoriale backend
        COMPLETATO — perimetro S030

Knowledge agronomica canonica
        COMPLETATA — strutture backend S030

Catalog Authority
        COMPLETATA — backend

Pubblicazione e Resolver backend
        COMPLETATI — perimetro S030

Cutover finale Database + Flutter
        COMPLETATO

Integrazione operativa Catalogo Agronomico nelle Impostazioni
        COMPLETATA

Lettura capability Catalog Authority nella UI
        COMPLETATA

Inizializzazione iniziale Catalog Authority esplicita e confermata
        COMPLETATA

Consultazione colture globali
        COMPLETATA

Navigazione gerarchica Coltura → Cultivar
        COMPLETATA

Caricamento cultivar on demand
        COMPLETATO

Gestione loading / empty / error / retry del Catalogo
        COMPLETATA

Rimozione del percorso autonomo Impostazioni → Varietà
        COMPLETATA

Write Path Flutter Taxon
        COMPLETATO

Write Path Flutter Crop
        COMPLETATO

Write Path Flutter Cultivar
        COMPLETATO

UI completa Classificazione botanica
        COMPLETATA — perimetro S032/S033

HUB Registri Agronomici
        COMPLETATO — Fase A S033

Pagina dedicata Classificazione botanica
        COMPLETATA — Fase A S033

UI gestione Crop
        COMPLETATA — perimetro Fase A S033

UI gestione Cultivar
        COMPLETATA — perimetro Fase A S033

Verifica Flutter Fase A
        COMPLETATA — 80/80 test S033

Verifica Flutter complessiva S033
        COMPLETATA — 1107/1107 test S033

Ricognizione backend Registri Agronomici
        COMPLETATA — 21/21 RPC censite in S033B

Audit locale Write Path plantings
        CONCLUSO — esito favorevole nel perimetro S033B esaminato

Correzione gestione congelamento semantico Catalog Registry
        COMPLETATA — sviluppo SQL S034

RPC update_measurement_unit
        CORRETTA — gestione selettiva SQLSTATE 55000

RPC update_agronomic_parameter
        CORRETTA — gestione selettiva SQLSTATE 55000

RPC update_parameter_enum_value
        CORRETTA — gestione selettiva SQLSTATE 55000

Migration S034
        APPLICATA — database Supabase locale

Migration S034 sul database remoto
        NON APPLICATA

Verifiche statiche RPC/trigger S034
        SUPERATE — 3/3

Verifiche autorizzative S034
        SUPERATE — 3/3

Test dinamico specifico SQLSTATE 55000
        NON ESEGUITO

Modelli, repository e UI Flutter degli altri Registri Agronomici
        FUTURE — da progettare e implementare

Selezione esplicita della Cultivar nella UI di creazione planting
        FUTURE

Backend canonico delle consociazioni
        FUTURE

UI workflow alias / fonti / candidati / revisione / pubblicazione
        FUTURE

Integrazione completa del Resolver nei flussi operativi
        FUTURE

Ulteriori verifiche runtime, concorrenza ed end-to-end
        FUTURE
```

La baseline complessiva Database V1 rimane:

```text
IN CORSO
```

poiché non tutte le 52 entità di dominio progettate nella S017 sono ancora fisicamente implementate.

La S030 ha completato il nuovo perimetro persistente e autoritativo del Catalogo Agronomico globale.

La S031 ha completato l'integrazione operativa del Catalogo nel client Flutter senza modificare il relativo perimetro persistente.

La S032 ha integrato nel client i Write Path autoritativi già disponibili per Taxon, Crop e Cultivar e ha completato la UI di gestione della Classificazione botanica.

La S033 ha consolidato la Fase A Flutter attraverso l'HUB Registri Agronomici e la separazione delle pagine dedicate a Classificazione botanica e Colture/Cultivar, completando la gestione di queste ultime nel perimetro approvato.

La S033B ha verificato staticamente una parte del backend dei Registri Agronomici e del Write Path di `plantings`, senza introdurre modifiche persistenti e senza estendere l'esito dell'audit oltre il perimetro verificato.

La conclusione della Sessione S033/S033B non equivale al completamento dell'intera baseline Database V1 né dell'intero workflow amministrativo/editoriale del Catalogo Agronomico.

La fase sviluppo S033/S033B è stata conclusa il **12/10/2026 alle 16:42**, con **22 h 43 min** di lavoro effettivo.

La fase Manuali S033/S033B è stata conclusa il **13/10/2026 alle 21:34**, con **1 h 52 min** di lavoro documentale.

La Sessione S033/S033B risulta pertanto **completamente conclusa**, con una durata definitiva di **24 h 35 min** e un progressivo complessivo del progetto pari a **271 h 14 min**.

### Aggiornamento tecnico S034

La fase sviluppo S034 ha corretto la gestione delle eccezioni di congelamento semantico nelle tre RPC:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La correzione è contenuta nella migration:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La gestione di `SQLSTATE 55000` è subordinata al confronto esatto di `SQLERRM` con il messaggio di congelamento semantico del rispettivo trigger.

Soltanto quando tale confronto ha esito positivo la RPC restituisce:

```json
{"status":"semantics_frozen"}
```

Le altre eccezioni vengono propagate.

La migration è stata applicata **esclusivamente al database Supabase locale** e non al database remoto.

Le verifiche statiche RPC/trigger e le verifiche autorizzative hanno avuto esito positivo, rispettivamente **3/3** e **3/3**.

Il test dinamico specifico del ramo `SQLSTATE 55000` **non è stato eseguito**. Pertanto la correzione non deve essere considerata dinamicamente validata in tale scenario.

Non sono state introdotte nuove funzionalità Flutter durante la S034.

La suite Flutter complessiva di **1107/1107 test superati** si riferisce alla S033 e non è stata rieseguita nella S034.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

La fase Manuali S034 è stata avviata il **15/10/2026 alle 14:27** e dichiarata conclusa il **15/10/2026 alle 23:45**, con **3 h 42 min** di lavoro documentale effettivo.

Il consuntivo definitivo della Sessione S034 è:

| Attività | Durata |
|---|---:|
| Sviluppo S034 | 5 h 11 min |
| Manuali S034 | 3 h 42 min |
| **Totale Sessione S034** | **8 h 53 min** |

Il progressivo temporale definitivo del progetto Orto Smart alla chiusura della S034 è:

| Voce | Durata |
|---|---:|
| Sviluppo complessivo | 208 h 34 min |
| Documentazione complessiva | 71 h 33 min |
| **Totale progetto** | **280 h 07 min** |

L'obiettivo inizialmente approvato per la S034, relativo alla progettazione del sottosistema Flutter dei Registri Agronomici, non è stato completato dall'intervento SQL effettuato.

La sua eventuale prosecuzione dovrà essere valutata separatamente, senza automatismi.

---

## Catalogo Agronomico globale

Il Catalogo Agronomico risultante dalla S030 è:

- globale;
- multisource;
- tracciabile;
- versionabile;
- contestualizzabile;
- editorialmente controllato;
- separato dai dati operativi del singolo orto.

Il perimetro Catalogo realizzato nella S030 comprende:

```text
26 tabelle
```

Le identità botaniche globali sono rappresentate mediante:

```text
botanical_taxa
```

Nella ricostruzione storica della S030 erano riportati i seguenti rank:

```text
FAMILY
GENUS
SPECIES
VARIETY
CULTIVAR
```

Tale elenco appartiene alla ricostruzione della fase S030 e **non rappresenta il contratto tassonomico corrente**.

La successiva ricognizione autoritativa S032, consolidata nel DOC-005 e nella DEC-015 del DOC-011, ha verificato che i rank tassonomici correnti sono:

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

**`CULTIVAR` non è un rank tassonomico.** La Cultivar costituisce un'identità agronomica globale separata, gestita mediante `crop_cultivars`.

La gerarchia botanica utilizza `parent_taxon_id` e consente classificazioni parziali, senza richiedere la creazione artificiale di tutti i livelli intermedi.

La normalizzazione testuale del Catalogo è centralizzata mediante:

```text
private.normalize_catalog_text(text)
```

e applica normalizzazione Unicode, trim, spazi singoli e forma normalizzata per il confronto.

Le identità agronomiche operative canoniche sono rappresentate da:

```text
crops
crop_cultivars
```

Il precedente modello Profile-owned:

```text
botanical_families
crops
crop_varieties
```

appartiene allo storico delle S026–S027 e non rappresenta più il contratto corrente del Catalogo.

Al cutover finale S030 sono state rimosse le strutture legacy:

```text
botanical_families
catalog_crops_s030
crop_varieties
```

Il contratto corrente di `plantings` utilizza:

```text
crop_id
cultivar_id
```

con:

```text
crop_id → crops(id)
```

e vincolo composto:

```text
(cultivar_id, crop_id)
        →
crop_cultivars(id, crop_id)
```

Il precedente:

```text
variety_id
```

è stato rimosso dal contratto persistente corrente.

## Catalog Authority e sicurezza

La S030 ha introdotto una Catalog Authority globale con capability distinte per:

```text
identity management
ingestion
review
publishing
```

Le capability dell'utente autenticato possono essere lette mediante:

```text
get_my_catalog_capabilities()
```

L'inizializzazione esplicita dell'authority è disponibile mediante:

```text
claim_initial_catalog_authority()
```

La claim:

- non viene eseguita automaticamente dal client;
- è consentita soltanto all'owner idoneo quando l'authority non è ancora inizializzata;
- è idempotente;
- non consente una nuova acquisizione dell'authority già inizializzata.

Le RPC sensibili seguono il modello:

```text
SECURITY DEFINER
search_path vuoto
nessun EXECUTE ad anon
EXECUTE esplicito ad authenticated dove previsto
autorizzazione server-side
```

RLS, privilegi espliciti e Write Path controllati rimangono principi fondamentali dell'architettura.

## Fonti, ingestion e workflow editoriale

La S030 ha implementato il perimetro necessario a mantenere separati:

```text
fonte esterna
        ↓
acquisizione / ingestion
        ↓
osservazione / dato candidato
        ↓
revisione editoriale
        ↓
Knowledge agronomica canonica
        ↓
pubblicazione
        ↓
Resolver / read model
```

I dati provenienti da fonti esterne non possono sovrascrivere automaticamente il Catalogo approvato.

L'importazione produce dati candidati da sottoporre al processo editoriale.

Il principio rimane:

```text
dato esterno ≠ dato automaticamente approvato
```

Il workflow consente di mantenere tracciabilità tra fonti, osservazioni, revisioni e contenuto canonico.

La catena delle revisioni utilizza:

```text
previous_revision_id
```

per mantenere una relazione esplicita con la revisione precedente.

Il modello editoriale consolidato prevede inoltre che:

- CREATE possa reintrodurre in modo controllato contenuto precedentemente ritirato;
- il semantic freeze inizi dal primo artefatto immutabile;
- `NOT_MAPPABLE` sia ammesso soltanto per `CONFLICTING` e `CONTEXTUAL`;
- WITHDRAW conservi il contenuto canonico necessario alla tracciabilità.

## Knowledge, pubblicazione e Resolver

La Knowledge agronomica canonica è separata dalle identità botaniche e dalle osservazioni provenienti dalle fonti.

La S030 ha completato il percorso tecnico fino alla pubblicazione e al Resolver.

I read model canonici esposti al client sono:

```text
crop_catalog_read
crop_cultivar_catalog_read
```

entrambi configurati con:

```text
security_invoker = true
```

Il Resolver può fornire dati agronomici utilizzabili dai flussi applicativi, ma non deve modificare automaticamente i dati operativi già persistiti.

I valori agronomici registrati su un planting rimangono snapshot operativi.

Il principio applicativo è:

```text
Resolver propone
utente conferma
dato operativo viene registrato
```

e non:

```text
Resolver modifica automaticamente planting esistenti
```

## Integrazione Flutter S030

Il client Flutter è stato riallineato al nuovo Catalogo globale.

Sono stati introdotti:

```text
CatalogCapabilities
CropCultivar
CatalogAuthorityRepository
CropCultivarRepository
```

`CropRepository` legge dal read model:

```text
crop_catalog_read
```

`CropCultivarRepository` legge dal read model:

```text
crop_cultivar_catalog_read
```

`CatalogAuthorityRepository` espone la lettura delle capability e la claim esplicita dell'authority.

Sono stati rimossi dal contratto corrente i componenti legacy relativi al Catalogo Profile-owned, compresi:

```text
BotanicalFamily
CropVariety
CropVarietyRepository
varietyId
variety_id
```

quando utilizzati come elementi del contratto applicativo corrente.

La terminologia tecnica corrente utilizza:

```text
cultivar
cultivarId
cultivar_id
CropCultivar
```

L'interfaccia italiana può continuare a utilizzare il termine:

```text
Varietà
```

come etichetta comprensibile all'utente.

Il motore delle rotazioni confronta l'UUID canonico della famiglia botanica; il nome della famiglia rimane informazione di visualizzazione.

## Integrazione operativa Flutter S031

La S031 ha completato l'integrazione operativa del Catalogo Agronomico globale nell'interfaccia Flutter, partendo dal contratto applicativo e dai repository predisposti nella S030.

Il percorso applicativo corrente è:

```text
Impostazioni
    ↓
Catalogo Agronomico
    ↓
Colture
    ↓
Cultivar
```

La pagina del Catalogo Agronomico integra `CatalogAuthorityRepository` per leggere lo stato e le capability della Catalog Authority.

L'inizializzazione iniziale dell'authority rimane un'operazione esplicita.

Il client:

```text
apre il Catalogo
        ↓
legge le capability
        ↓
verifica lo stato dell'authority
        ↓
propone l'inizializzazione soltanto quando applicabile
        ↓
richiede conferma esplicita dell'utente
        ↓
esegue claim_initial_catalog_authority()
```

La claim non viene quindi eseguita automaticamente all'apertura della pagina.

La consultazione delle identità agronomiche segue la gerarchia canonica:

```text
Crop
    ↓
CropCultivar
```

Le colture globali vengono lette tramite il read model:

```text
crop_catalog_read
```

e presentate nella sezione:

```text
Catalogo Agronomico → Colture
```

Le cultivar non vengono caricate indiscriminatamente insieme all'intero Catalogo.

Dopo la selezione di una coltura, il client carica on demand le cultivar associate mediante `CropCultivarRepository` e il read model:

```text
crop_cultivar_catalog_read
```

La UI gestisce esplicitamente gli stati:

```text
loading
empty
error
retry
```

sia per la consultazione delle colture sia, dove applicabile, per il caricamento delle cultivar.

La S031 consolida quindi nell'interfaccia la relazione:

```text
Coltura
    ↓
Cultivar appartenenti alla coltura
```

evitando di rappresentare le cultivar come un catalogo autonomo e scollegato dalla coltura di appartenenza.

Per questo motivo il precedente accesso separato:

```text
Impostazioni → Varietà
```

è stato rimosso.

Il termine tecnico canonico rimane:

```text
Cultivar
```

mentre eventuali etichette italiane rivolte all'utente possono continuare a utilizzare terminologia comprensibile senza modificare il contratto tecnico sottostante.

La S031 non introduce nuove migration e non modifica il modello persistente del Catalogo definito dalla S030.

Il backend rimane autoritativo e la UI non introduce Write Path diretti o scorciatoie che aggirino Catalog Authority, capability, normalizzazione, unicità, tassonomia o tracciabilità.

La S031 non ha introdotto dati dimostrativi, provvisori o di esempio nel Catalogo.

Il popolamento reale del Catalogo rimane subordinato alla disponibilità di un workflow sicuro, verificato e tracciabile per la gestione delle identità e dei dati agronomici.

La verifica finale della S031 ha confermato:

```text
flutter analyze
        ✅ nessun problema

flutter test
        ✅ 971 test superati

nuove migration
        0
```

Il commit conclusivo della fase sviluppo S031 è:

```text
b436d663e46149202e081a3079eb162567fb0909
```

con messaggio:

```text
Rimuove gestione separata delle cultivar
```

Alla chiusura della fase sviluppo S031 il branch `main` risultava allineato a `origin/main` e il working tree risultava pulito.

## Gestione delle identità del Catalogo e Classificazione botanica S032

La S032 ha proseguito l'integrazione Flutter del Catalogo Agronomico partendo da una ricognizione del contratto backend effettivamente disponibile.

La ricognizione ha confermato che il backend dispone già dei Write Path autoritativi necessari per:

```text
Taxon
Crop
Cultivar
```

e che la precedente roadmap S032–S042+ aveva carattere esplorativo e non costituiva una sequenza tecnica vincolante.

### Contratto tassonomico

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

`CULTIVAR` non appartiene all'insieme dei rank tassonomici.

La Cultivar costituisce un'identità agronomica globale separata e viene gestita mediante:

```text
crop_cultivars
```

La gerarchia tassonomica utilizza:

```text
parent_taxon_id
```

e supporta una classificazione parziale.

Il client Flutter non impone quindi la presenza artificiale di tutti i livelli tassonomici intermedi.

Il collegamento:

```text
Crop → Taxon
```

rimane opzionale.

### Authority e Write Path

La Catalog Authority rimane distinta dalla Profile Write Authority e dal protocollo `profile_edit_locks`.

La gestione delle identità globali del Catalogo utilizza capability specifiche, in particolare:

```text
can_manage_identity
```

La S032 ha integrato nel client Flutter i Write Path per:

```text
BotanicalTaxon
Crop
CropCultivar
```

mantenendo il backend come autorità per:

- autorizzazione;
- capability;
- normalizzazione;
- unicità;
- gerarchia;
- cicli;
- dipendenze;
- stato attivo;
- concorrenza.

### Concorrenza e rilettura autoritativa

Le operazioni di modifica utilizzano:

```text
row_version
```

per la concorrenza ottimistica.

In presenza di:

```text
version_conflict
```

il client:

```text
non forza l'overwrite
non esegue retry automatico
rilegge lo stato autoritativo
```

Lo stesso principio viene applicato quando l'esito di una scrittura è incerto.

Un'eccezione di rete successiva all'invio della richiesta non autorizza il client a ripetere automaticamente la scrittura, perché l'operazione potrebbe essere già stata applicata dal server.

### UI della Classificazione botanica

La terminologia applicativa approvata è:

```text
Classificazione botanica
Voce botanica
Classificazione superiore
```

La pagina del Catalogo consente:

- lettura delle voci botaniche;
- creazione;
- modifica;
- disattivazione;
- riattivazione.

Le operazioni di gestione sono disponibili soltanto quando le capability della Catalog Authority lo consentono.

La disattivazione richiede una conferma esplicita.

La riattivazione non replica nel client la logica delle dipendenze del database.

In particolare Flutter non tenta di duplicare le regole server-side relative a:

- dipendenze attive;
- parent inattivo;
- cicli;
- validità della gerarchia;
- unicità.

Il backend rimane autoritativo.


### Progressione della UI del Catalogo

La progressione applicativa del Catalogo Agronomico segue la gerarchia delle identità globali:

```text
Taxonomy
    ↓
Crop
    ↓
Cultivar
```

Alla chiusura della S032, la gestione completa della Classificazione botanica era stata realizzata.

Nella stessa sessione erano stati integrati i Write Path Flutter di Crop e Cultivar, mentre le rispettive interfacce complete di gestione rimanevano un incremento successivo.

**Questa descrizione rappresenta lo stato storico alla chiusura della S032.**

La successiva Sessione S033 ha completato tale incremento nell'ambito della Fase A Registri Agronomici Flutter, introducendo:

- l'HUB Registri Agronomici;
- una pagina dedicata alla Classificazione botanica;
- una pagina dedicata alla gestione di Colture e Cultivar;
- i flussi autorizzati di consultazione, creazione, modifica, disattivazione e riattivazione di Colture e Cultivar.

Pertanto, **alla chiusura dello sviluppo S033/S033B, la gestione Flutter di Colture e Cultivar risulta completata nel perimetro della Fase A**, mentre rimangono FUTURE gli ulteriori Registri Agronomici e le altre funzionalità del workflow amministrativo/editoriale del Catalogo.

La progressione applicativa conserva la Catalog Authority e il backend come autorità per le capability, le invarianti persistenti e la concorrenza.

### Verifica tecnica S032

La verifica finale della fase sviluppo S032 ha confermato:

```text
Catalog page test suite
        61/61 test superati

flutter analyze
        No issues found

flutter test
        1077/1077 test superati
```

Il commit tecnico conclusivo della fase sviluppo S032 è:

```text
842a6b6468964300d43d0edac1d8853c3a4bb908
Integra gestione stato tassonomia nel Catalogo Agronomico
```

Alla chiusura della fase sviluppo S032 il branch `main` risultava allineato a `origin/main` e il working tree risultava pulito.

La S032 non ha introdotto dati demo o provvisori nel Catalogo.

Il popolamento reale continua a essere subordinato a un workflow sicuro, verificato e tracciabile.

## Fase A Registri Agronomici Flutter S033

La Sessione S033 ha completato la Fase A dell'integrazione Flutter dei Registri Agronomici, proseguendo il lavoro sulle identità globali del Catalogo avviato nelle Sessioni S031 e S032.

L'obiettivo della Fase A è stato organizzare e completare la gestione applicativa di Classificazione botanica, Colture e Cultivar, mantenendo il backend autoritativo e le capability della Catalog Authority come riferimenti per tutte le operazioni di modifica.

### Organizzazione della Fase A

La Fase A è stata articolata in quattro incrementi:

- **A1 — HUB Registri Agronomici:** predisposizione e integrazione del punto di accesso e della navigazione;
- **A2 — Classificazione botanica:** estrazione della gestione tassonomica in una pagina dedicata;
- **A3 — Colture e Cultivar:** completamento della gestione applicativa in una pagina dedicata;
- **A4 — Consolidamento:** verifica complessiva del comportamento Flutter e dei contratti già disponibili.

La struttura applicativa risultante separa:

```text
HUB Registri Agronomici
    ├── Classificazione botanica
    └── Colture e Cultivar
```

Questa separazione riguarda la presentazione e l'organizzazione delle funzionalità Flutter, senza introdurre un nuovo contratto persistente.

### Gestione delle identità globali

La gestione di Classificazione botanica, Colture e Cultivar mantiene:

- lettura dello stato autoritativo;
- creazione e modifica attraverso i Write Path esistenti;
- disattivazione e riattivazione subordinate alle capability;
- concorrenza ottimistica mediante `row_version`;
- nessun overwrite forzato in caso di `version_conflict`;
- nessun retry automatico in presenza di un esito incerto;
- rilettura dello stato autoritativo quando necessaria.

Le validazioni e le invarianti persistenti rimangono di competenza del backend.

La Fase A non trasferisce al client Flutter l'autorità su unicità, gerarchia tassonomica, dipendenze o autorizzazioni.

### Verifica tecnica S033

La verifica finale ha registrato:

```text
HUB Registri Agronomici       11/11
Colture e Cultivar            38/38
Fase A                        80/80
Suite Flutter complessiva   1107/1107

flutter analyze
    No issues found
```

I conteggi delle suite mirate sono parzialmente sovrapposti e non devono essere sommati.

I commit tecnici principali della S033 sono:

```text
8a864ee  Integra gestione Colture Catalogo Agronomico
015f899  Integra gestione Cultivar Catalogo Agronomico
841763b  Estrae Classificazione botanica dal Catalogo Agronomico
270b27e  Estrae Colture e Cultivar dal Catalogo Agronomico
```

Il commit tecnico conclusivo è:

```text
270b27e654e072a1127509e335c13a45fae35d8d
```

La versione pubblica dell'applicazione rimane `0.1.21-alpha` e la versione Flutter rimane `0.1.21-alpha+6`.

La Fase A è conclusa, ma non rappresenta il completamento di tutti i Registri Agronomici o dell'intero workflow editoriale del Catalogo.

---

## Ricognizione backend e audit locale S033B

La prosecuzione S033B ha effettuato una ricognizione tecnica del backend dei Registri Agronomici e un audit locale dei Write Path di `plantings`.

Le verifiche hanno avuto carattere conoscitivo e di controllo. Non hanno comportato nuove implementazioni Flutter, SQL, migration o modifiche persistenti al database.

### Ricognizione delle RPC dei Registri Agronomici

La ricognizione statica ha censito **21/21 RPC** nel perimetro dei seguenti registri:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

Il risultato conferma la disponibilità del contratto backend esaminato.

Non equivale tuttavia alla verifica runtime di tutte le operazioni né alla realizzazione delle corrispondenti interfacce Flutter.

Nel perimetro Flutter verificato non risultavano ancora presenti modelli e repository dedicati a tali registri.

La loro integrazione applicativa rimane pertanto un incremento successivo.

### Audit locale del Write Path di plantings

L'audit locale ha esaminato le RPC autoritative:

```text
create_planting
update_planting
set_planting_status
```

Nel perimetro verificato sono stati rilevati:

- funzioni `SECURITY DEFINER` con owner `postgres`;
- privilegio di esecuzione per `authenticated`;
- assenza del privilegio di esecuzione per `anon` e `service_role`;
- assenza di overload delle tre RPC esaminate;
- RLS attiva su `plantings`;
- policy di lettura `plantings_select_member` tramite `private.can_access_garden(garden_id)`;
- assenza di policy di scrittura diretta per i normali ruoli applicativi;
- trigger `plantings_set_updated_at_and_row_version`;
- controlli server-side collegati alla Profile Write Authority, ai lock e alla concorrenza ottimistica.

La ricognizione ha inoltre esaminato il trattamento dei token del protocollo di lock, con generazione server-side di materiale casuale e utilizzo di hash SHA-256 nel perimetro osservato.

### Limiti ed esito dell'audit

L'esito dell'audit è stato **favorevole limitatamente al perimetro locale effettivamente verificato**.

Non sono stati effettuati nuovi:

- test runtime di scrittura;
- test di concorrenza;
- test end-to-end Flutter/Supabase;
- controlli sul database remoto.

L'esito non costituisce una certificazione generale della sicurezza del Write Path.

Non sono emersi difetti dimostrati tali da giustificare modifiche correttive immediate.

È stato pertanto mantenuto il principio di non introdurre correzioni preventive in assenza di un problema tecnico riproducibile o adeguatamente dimostrato.


### Stato conclusivo S033/S033B

La fase sviluppo S033/S033B è stata conclusa il **12/10/2026 alle 16:42**, con un tempo netto complessivo di **22 h 43 min**.

La fase Manuali S033/S033B è stata conclusa il **13/10/2026 alle 21:34**, con un tempo netto complessivo di **1 h 52 min**.

La Sessione S033/S033B risulta definitivamente conclusa, con una durata complessiva di **24 h 35 min**.

Il progressivo definitivo del progetto alla chiusura della S033/S033B è **271 h 14 min**, ripartito in **203 h 23 min di sviluppo** e **67 h 51 min di documentazione**.

L'obiettivo inizialmente approvato per la S034 era la progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.

La successiva Sessione S034 ha invece realizzato una correzione circoscritta al backend dei Registri Agronomici, relativa alla gestione delle eccezioni di congelamento semantico nelle RPC:

- `public.update_measurement_unit`;
- `public.update_agronomic_parameter`;
- `public.update_parameter_enum_value`.

La correzione è contenuta nella migration `20261014200459_fix_catalog_registry_semantic_freeze_errors.sql`, applicata esclusivamente al database Supabase locale.

La fase sviluppo S034 si è conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

La S034 non ha completato l'obiettivo iniziale di progettazione Flutter e non ha introdotto nuove funzionalità Flutter.

La fase Manuali S034 è ancora in corso.

La ricognizione S033B e la correzione S034 costituiscono attività distinte: l'esito favorevole dell'audit S033B non deve essere interpretato come validazione della successiva modifica SQL.

La prosecuzione dello sviluppo Flutter dei Registri Agronomici rimane da valutare sulla base dello stato effettivo del progetto, senza approvazioni automatiche.

## Plantings dopo il cutover S030

Il Repository Layer Flutter relativo alle coltivazioni continua a comprendere:

```text
PlantingRepository
```

con:

```text
getPlantingsByBed
createPlanting
updatePlanting
setPlantingStatus
```

Le scritture applicative ordinarie di `plantings` continuano a utilizzare esclusivamente RPC autoritative.

Restano validi i principi consolidati nelle S028–S029:

- Profile Write Authority fail-closed;
- concorrenza ottimistica mediante `row_version`;
- result type dedicati;
- mapping esplicito degli status RPC;
- lifecycle autoritativo;
- geometria longitudinale half-open;
- controllo congiunto degli overlap temporali e longitudinali;
- compatibilità con la geometria storicizzata delle aiuole;
- protezione delle modifiche geometriche mediante `blocked_by_plantings`;
- assenza di hard delete nel normale flusso operativo;
- `end_date = null` durante le transizioni intermedie;
- conferma esplicita di `end_date` per `finished` e `removed`;
- mantenimento dell'occupazione nello stato `harvested`;
- rilascio dello spazio soltanto negli stati `finished` e `removed`;
- refresh autoritativo su `version_conflict` e `invalid_transition`.

I quattro metodi di avvio canonici rimangono:

```text
purchased_seedlings
nursery_then_transplant
direct_rows
direct_broadcast
```

Il lifecycle autoritativo rimane:

```text
sown
growing
harvest_ready
harvested
finished
removed
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

La geometria longitudinale utilizza intervalli half-open:

```text
[start_position_cm, start_position_cm + length_cm)
```

Il conflitto tra coltivazioni viene rilevato soltanto quando sono contemporaneamente presenti:

```text
overlap temporale
+
overlap longitudinale
```

Le modifiche alla geometria delle aiuole possono essere bloccate mediante:

```text
blocked_by_plantings
```

quando risultano incompatibili con coltivazioni già persistite.

Il normale flusso operativo non prevede hard delete di `plantings`.

Un eventuale hard delete rimane classificato:

```text
FUTURE
```

e dovrà essere limitato a correzioni amministrative o tecniche eccezionali.

`AddPlantingPage` non espone ancora un selettore operativo esplicito del cultivar.

Nel flusso di creazione corrente:

```text
cultivarId = null
```

mentre nel flusso di modifica viene preservato l'eventuale:

```text
planting.cultivarId
```

La selezione esplicita del cultivar nella UI di creazione rimane quindi FUTURE.

## Consociazioni

Il motore applicativo delle consociazioni rimane disponibile.

Non esiste ancora un backend canonico S030 equivalente alla precedente relazione di catalogo per le consociazioni.

Nello stato corrente:

```text
CropAssociationRepository
```

restituisce insiemi vuoti anziché interrogare una relazione canonica non ancora esistente.

La realizzazione del backend canonico delle consociazioni rimane:

```text
FUTURE
```

## Verifiche tecniche S030

La migration conclusiva della S030 è:

```text
20260923154831_finalize_global_catalog_cutover.sql
```

Il reset completo del database locale mediante:

```text
supabase db reset
```

è stato completato con successo applicando da zero l'intera catena delle migration.

Il lint del database ha restituito, sia sul perimetro verificato localmente sia sul remoto:

```text
No schema errors found
```

Gli acceptance test delle Tranche 10 e 11 sono stati superati e le relative fixture sono state sottoposte a rollback.

La verifica Flutter finale ha prodotto:

```text
dart format lib test
Formatted 174 files

flutter analyze
No issues found

flutter test
953 test superati
```

Il valore:

```text
Formatted 174 files
```

rappresenta l'output del comando di formattazione e non implica che tutti i 174 file siano stati modificati.

Lo smoke test Edge ha verificato:

- Dashboard raggiungibile;
- assenza di eccezioni;
- assenza di errori rossi;
- pagina Varietà raggiungibile;
- stato vuoto “Nessuna varietà presente” corretto;
- assenza del precedente pulsante di aggiunta varietà;
- gestione corretta del profilo senza Garden;
- impossibilità di eseguire il test manuale di aiuole e planting esclusivamente per assenza di un Garden nel profilo utilizzato.

La migration finale è stata applicata anche al database remoto.

Alla verifica conclusiva della fase sviluppo:

```text
local  = 20260923154831
remote = 20260923154831
```

Il commit tecnico conclusivo è:

```text
f9f5830796ecc16a14ef1b3fb4ce26bd081846b5
Completa il cutover del catalogo agronomico globale
```

## Timing e progressivi S030

La fase sviluppo S030 è conclusa con:

```text
21 h 06 min
```

La fase Manuali S030 è conclusa con:

```text
6 h 13 min
```

Il tempo complessivo della Sessione S030 è:

```text
Sviluppo        21 h 06 min
Documentazione   6 h 13 min
--------------------------
Totale          27 h 19 min
```

I progressivi definitivi alla chiusura della S030 sono:

```text
Sviluppo complessivo        168 h 39 min
Documentazione complessiva   60 h 24 min
----------------------------------------
Totale progetto             229 h 03 min
```

La Sessione S030 è quindi conclusa sia nella fase di sviluppo sia nella fase documentale.

## Elementi FUTURE dopo S033/S033B — aggiornamento S034

La conclusione delle fasi di sviluppo S033/S033B e S034 non implica il completamento dell'intero progetto Orto Smart, della baseline Database V1 o dell'intero sistema amministrativo ed editoriale del Catalogo Agronomico.

Le Sessioni S030–S034 hanno realizzato la seguente progressione tecnica:

```text
S030
Catalogo Agronomico globale e cutover Database + Flutter
    ↓
S031
Consultazione operativa del Catalogo in Flutter
    ↓
S032
Write Path Flutter delle identità Taxon, Crop e Cultivar
Gestione della Classificazione botanica
    ↓
S033
HUB Registri Agronomici
Pagine dedicate Classificazione botanica e Colture/Cultivar
Completamento della Fase A Flutter
    ↓
S033B
Ricognizione statica delle RPC dei Registri Agronomici
Audit locale del Write Path di plantings
    ↓
S034
Correzione della gestione delle eccezioni di congelamento
semantico in tre RPC del Catalog Registry
Migration applicata al database locale
Sviluppo concluso; documentazione ancora in corso
```

### Funzionalità non più FUTURE

Risultano completati nei rispettivi perimetri approvati e verificati:

- ricognizione dei Write Path delle identità globali del Catalogo;
- Write Path Flutter Taxon;
- Write Path Flutter Crop;
- Write Path Flutter Cultivar;
- gestione applicativa della Classificazione botanica;
- HUB Registri Agronomici;
- pagina dedicata alla Classificazione botanica;
- pagina dedicata alla gestione di Colture e Cultivar;
- UI di creazione, modifica, disattivazione e riattivazione di Crop e Cultivar nel perimetro della Fase A;
- consolidamento della Fase A con 80/80 test superati;
- verifica della suite Flutter complessiva con 1107/1107 test superati nella S033;
- ricognizione statica di 21/21 RPC dei Registri Agronomici;
- audit locale dei Write Path di `plantings`, con esito favorevole limitatamente al perimetro esaminato;
- correzione S034 della gestione delle eccezioni di congelamento semantico nelle tre RPC `update_measurement_unit`, `update_agronomic_parameter` e `update_parameter_enum_value`;
- applicazione della migration S034 al database Supabase locale;
- verifiche statiche e autorizzative S034 superate nei rispettivi perimetri.

La ricognizione delle RPC e l'audit locale non equivalgono alla realizzazione delle relative interfacce Flutter né a una certificazione generale di sicurezza.

I 1107/1107 test Flutter superati appartengono alla verifica S033. La suite Flutter non è stata rieseguita durante la S034.

La correzione S034 non può essere considerata integralmente verificata a runtime, poiché il test dinamico specifico del ramo `SQLSTATE 55000` non è stato eseguito.

### Elementi ancora FUTURE

Rimangono aperti, tra gli altri:

- progettazione e successiva implementazione Flutter degli ulteriori Registri Agronomici;
- modelli, repository e interfacce applicative per unità di misura, parametri agronomici, valori enumerati e contesti;
- gestione applicativa degli alias;
- workflow operativo di acquisizione e aggiornamento delle fonti in `Impostazioni → Catalogo Agronomico → Aggiornamento fonti`;
- gestione dei dati candidati;
- schermate di revisione editoriale;
- gestione applicativa della pubblicazione;
- integrazione completa del Resolver nei flussi operativi;
- backend canonico delle consociazioni;
- selezione esplicita della Cultivar nel flusso di creazione dei planting;
- popolamento editoriale del Catalogo con dati agronomici reali, verificabili e tracciabili;
- smoke test con dati operativi reali;
- verifiche runtime, di concorrenza ed end-to-end dei Write Path nei perimetri ancora da validare;
- eventuali approfondimenti di hardening del Write Path di `plantings`, esclusivamente sulla base di evidenze tecniche;
- manutenzione periodica ISO 3166-1 alpha-2 mediante migration e test verificati, mai automatica;
- verifica o ripristino del percorso UI per la creazione del primo Garden;
- completamento delle ulteriori entità previste dalla baseline Database V1;
- hard delete amministrativo o tecnico eccezionale dei planting, escluso dal normale flusso operativo.

Restano inoltre aperte, relativamente alla correzione S034:

- esecuzione del test dinamico specifico del ramo `SQLSTATE 55000`;
- eventuale applicazione della migration S034 al database remoto, subordinata a una successiva decisione operativa.

Queste attività non sono considerate automaticamente approvate, autorizzate o completate.

Le verifiche statiche S033B non hanno dimostrato difetti tali da richiedere una correzione immediata nei Write Path di `plantings`.

Non devono quindi essere introdotte modifiche preventive al backend senza un problema verificato o una decisione progettuale successiva.

### Obiettivo iniziale approvato per S034 e consuntivo effettivo

Prima dell'avvio della Sessione S034 era stato approvato il seguente obiettivo iniziale:

> Progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.

L'attività inizialmente prevista comprendeva:

- verifica del contratto backend effettivamente disponibile;
- ricognizione dell'architettura Flutter esistente;
- definizione delle responsabilità di modelli, repository e interfacce;
- individuazione dei flussi autorizzativi e delle regole di gestione degli esiti;
- valutazione separata del primo eventuale incremento implementativo.

Questo obiettivo viene conservato come registrazione storica della pianificazione precedente alla sessione.

Il consuntivo effettivo dello sviluppo S034 documenta invece un intervento circoscritto al backend del Catalog Registry, relativo alle tre RPC:

```text
public.update_measurement_unit
public.update_agronomic_parameter
public.update_parameter_enum_value
```

La migration realizzata è:

```text
20261014200459_fix_catalog_registry_semantic_freeze_errors.sql
```

La correzione introduce una gestione selettiva delle eccezioni PostgreSQL `SQLSTATE 55000`.

Ciascuna RPC confronta `SQLERRM` con il messaggio specifico previsto per il congelamento semantico dal rispettivo trigger.

Soltanto in caso di corrispondenza esatta viene restituito:

```json
{"status":"semantics_frozen"}
```

Gli altri errori con lo stesso SQLSTATE non vengono automaticamente convertiti in `semantics_frozen`, ma sono propagati.

La migration è stata applicata al database Supabase locale e non al database remoto.

Durante la S034 sono state superate le verifiche statiche delle tre RPC e dei relativi trigger, i tre controlli autorizzativi previsti e il controllo `git diff --cached --check`.

Non è stato eseguito il test dinamico specifico del ramo `SQLSTATE 55000`.

La fase sviluppo S034 è stata conclusa il **15/10/2026 alle 13:58**, con **5 h 11 min** di lavoro effettivo.

Il commit conclusivo dello sviluppo è:

```text
a0f51fff735aefc75b0fd60f74e727f13d6984f0
```

Il commit è stato pubblicato su GitHub e, alla verifica conclusiva, `HEAD` risultava allineato a `origin/main`.

La versione pubblica `0.1.21-alpha` e la versione Flutter `0.1.21-alpha+6` sono rimaste invariate.

La fase Manuali S034 è ancora in corso. Il consuntivo documentale e il totale definitivo della sessione saranno consolidati soltanto dopo la dichiarazione esplicita di chiusura.

Il completamento dello sviluppo S034 non implica l'avvenuto completamento dell'obiettivo Flutter originariamente previsto, né autorizza automaticamente il suo trasferimento o la sua esecuzione in una sessione successiva.

Le attività delle sessioni future saranno definite autonomamente sulla base dello stato effettivo del progetto e delle decisioni operative che verranno approvate.

### Principi da preservare

Nell'evoluzione successiva devono essere mantenuti i principi consolidati:

```text
backend autoritativo
Catalog Authority
can_manage_identity
capability specifiche per le operazioni autorizzate
Profile Write Authority per i Write Path pertinenti
normalizzazione
unicità
tassonomia globale
CULTIVAR separato dai rank tassonomici
tassonomia parziale
Crop → Taxon opzionale
row_version
nessun overwrite forzato
nessun retry automatico dopo esito incerto
rilettura autoritativa
tracciabilità
gerarchia Crop → Cultivar
separazione dati candidati / dati approvati
```

Il workflow editoriale futuro deve mantenere la separazione:

```text
Aggiornamento fonti
        ↓
acquisizione dati candidati
        ↓
revisione
        ↓
approvazione / pubblicazione
        ↓
Catalogo Agronomico
```

I dati provenienti da fonti esterne non devono sovrascrivere automaticamente il Catalogo approvato.

### Avvio della gestione reale dell'orto

Il database deve rimanere privo di dati demo, provvisori o di prova fino all'avvio della gestione reale dell'orto.

Il popolamento reale del Catalogo dovrà iniziare soltanto quando il relativo workflow sarà sufficientemente sicuro, verificato e tracciabile da consentire l'inserimento di dati reali e agronomicamente controllati.

La sequenza operativa prevista per l'avvio reale rimane:

```text
1. verifica database locale pulito
2. verifica separata dello stato del database remoto
3. caricamento del Catalogo Agronomico verificato
4. creazione del Garden reale
5. creazione delle 15 aiuole reali
6. apertura della stagione reale
7. registrazione dei planting reali
```

Il popolamento reale del Catalogo dovrà avvenire soltanto su una baseline agronomica verificata e approvata.

---

# 6. Regole di aggiornamento

Il Registro Storico dello Sviluppo deve essere aggiornato in occasione del consolidamento documentale di ogni sessione di sviluppo.

Per ogni nuova sessione dovranno essere aggiornati, ove necessario, i seguenti elementi:

- gli indicatori storici del progetto;
- la cronologia sintetica dello sviluppo;
- gli indicatori evolutivi;
- le milestone, qualora la sessione introduca un cambiamento significativo;
- il tempo di sviluppo consolidato;
- il tempo dedicato alla documentazione;
- i progressivi complessivi del progetto;
- le informazioni di sintesi del progetto.

La chiusura della fase sviluppo e la chiusura della fase Manuali costituiscono due eventi distinti.

La conclusione dello sviluppo consente di consolidare le attività tecniche e il relativo tempo di lavoro, ma non determina automaticamente la conclusione dell'aggiornamento documentale.

I progressivi definitivi della sessione devono comprendere anche il tempo effettivamente dedicato alla documentazione, una volta dichiarata conclusa la relativa fase.

Prima della chiusura documentale dovrà essere verificata la coerenza tra:

- Registro Storico dello Sviluppo (DOC-012);
- Quaderno di Sviluppo (DOC-005);
- Workflow Operativo (DOC-009);
- Changelog;
- restante documentazione ufficiale interessata.

Gli aggiornamenti devono preservare i dati storici consolidati e distinguere chiaramente le funzionalità completate, le attività ancora aperte e gli elementi FUTURE.

Le attività soltanto ipotetiche o esplorative, esterne alla progettazione ufficiale, non devono essere recepite come decisioni o impegni operativi del progetto.

## 6.1 Registrazione delle ore

Le ore di lavoro devono essere registrate distinguendo il tempo effettivamente dedicato allo sviluppo software da quello dedicato alla documentazione.

La registrazione deve basarsi sugli orari comunicati e consolidati nel corso delle rispettive fasi di lavoro.

Devono essere rispettati i seguenti principi:

- registrazione degli orari effettivi di inizio, sospensione, ripresa e chiusura;
- esclusione delle pause dal tempo netto di lavoro;
- separazione tra sviluppo software e documentazione;
- conservazione dei progressivi già consolidati;
- assenza di stime arbitrarie per intervalli non documentati;
- consolidamento del tempo di sviluppo alla chiusura della relativa fase;
- consolidamento del tempo documentale soltanto dopo la chiusura dichiarata della fase Manuali;
- aggiornamento del totale complessivo dopo la disponibilità di entrambi i valori definitivi.

La registrazione delle ore deve utilizzare, ove applicabile, la seguente struttura:

| Attività | Tempo |
|----------|------:|
| Sviluppo software | Ore e minuti effettivi |
| Documentazione | Ore e minuti effettivi |
| Totale sessione | Somma dei due valori

# 7. Evoluzione futura

Il Registro Storico dello Sviluppo è un documento destinato ad evolversi insieme al progetto Orto Smart.

Con la crescita del software potranno essere introdotti nuovi indicatori e nuovi strumenti di analisi, mantenendo il ruolo del documento come riferimento storico dell'evoluzione tecnica, organizzativa e documentale del progetto.

Tra le possibili estensioni future rientrano, a titolo esemplificativo:

- andamento delle ore di sviluppo e documentazione;
- numero di commit per sessione;
- numero di test automatici;
- principali release del software;
- crescita della documentazione;
- evoluzione dei motori agronomici;
- decisioni architetturali introdotte;
- statistiche sull'evoluzione complessiva del progetto.

L'obiettivo è mantenere il presente documento come il principale riferimento storico per monitorare la crescita di Orto Smart nel lungo periodo.

---

# 8. Considerazioni finali

Il Registro Storico dello Sviluppo rappresenta il riferimento ufficiale per la ricostruzione dell'evoluzione del progetto Orto Smart.

Il documento raccoglie gli indicatori storici, le principali milestone e gli elementi che consentono di monitorare nel tempo la crescita del progetto sotto il profilo tecnico, organizzativo e documentale.

Insieme al Quaderno di Sviluppo (DOC-005), al Workflow Operativo (DOC-009) e alle Decisioni Architetturali (DOC-011), il presente documento contribuisce a garantire la tracciabilità e la memoria storica del progetto.

Il Registro Storico dello Sviluppo dovrà essere aggiornato con continuità, mantenendo coerenza con la restante documentazione e accompagnando l'evoluzione di Orto Smart durante tutto il suo ciclo di vita.