# ORTO SMART

### DOC-008

# Roadmap di Sviluppo

**Versione:** 2.6

**Stato:** Approvato

**Autore:** Renzo Siega

**Progetto:** Orto Smart

**Data prima emissione:** 27/07/2026

**Ultimo aggiornamento:** 12/10/2026

**Repository:** `ortosmart/orto-smart`

---

# Informazioni sul documento

| Campo | Valore |
|--------|--------|
| Documento | DOC-008 |
| Titolo | Roadmap di Sviluppo |
| Versione | 2.6 |
| Stato | Approvato |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 27/07/2026 |
| Ultimo aggiornamento | 12/10/2026 |

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

| Funzionalità | Stato |
|--------------|:-----:|
| Struttura Flutter | ✅ Completato |
| Supabase | ✅ Completato |
| Repository Pattern | ✅ Completato |
| Modelli | ✅ Completato |
| Progettazione Database V1 | ✅ Completato |
| Implementazione Database V1 in Supabase | 🚧 In sviluppo |
| Architettura Catalogo Agronomico V1 globale | ✅ Completato |
| Identità botaniche canoniche globali | ✅ Completato |
| Catalog Authority e capability autoritative | ✅ Completato |
| Fonti, acquisizioni e osservazioni agronomiche | ✅ Completato |
| Workflow editoriale agronomico backend | ✅ Completato |
| Knowledge agronomica canonica | ✅ Completato |
| Pubblicazione e versionamento della Knowledge | ✅ Completato |
| Resolver del Catalogo Agronomico | ✅ Completato |
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
| Modelli, repository e UI Flutter degli ulteriori Registri Agronomici | 📋 Da progettare e implementare |
| Audit locale dei Write Path di `plantings` | ✅ Completato nel perimetro S033B |
| Ulteriori verifiche runtime, concorrenza ed end-to-end | 📋 Da valutare |
| UI operativa per alias, fonti, candidati, revisione e pubblicazione | 📋 Pianificato |
| Workflow operativo di aggiornamento/importazione delle fonti | 📋 Pianificato |
| Popolamento verificato del Catalogo Agronomico | 📋 Pianificato |

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

| Funzionalità                       |       Stato       | Note                                                                                                                                                                                       |
| ---------------------------------- | :---------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| FreeSpaceEngine                    |   ✅ Completato    | Calcolo automatico degli spazi liberi nelle aiuole.                                                                                                                                        |
| SuggestionEngine                   |   ✅ Completato    | Generazione dei candidati iniziali sulla base degli spazi disponibili.                                                                                                                     |
| Companion Engine                   |   ✅ Completato    | Prima versione del motore delle consociazioni.                                                                                                                                             |
| BedAnalysisService                 |   ✅ Completato    | Servizio di coordinamento delle analisi agronomiche delle aiuole.                                                                                                                          |
| Bed Companion Analyzer             |   ✅ Completato    | Analisi automatica delle compatibilità tra le colture presenti in un'aiuola.                                                                                                               |
| RecommendationPipeline             |   ✅ Completato    | Orchestrazione del processo di raccomandazione e coordinamento dei componenti specializzati.                                                                                               |
| Decision Engine                    |   ✅ Completato    | Interpretazione delle valutazioni agronomiche e calcolo del punteggio finale delle raccomandazioni.                                                                                        |
| DecisionWeights                    |   ✅ Completato    | Configurazione e validazione dei pesi applicati ai criteri spazio, rotazione e consociazione.                                                                                              |
| Motore delle Rotazioni             |   ✅ Completato    | Prima versione operativa integrata nella RecommendationPipeline.                                                                                                                           |
| Sistema di Punteggio Agronomico    |   ✅ Completato    | Prima versione operativa basata su spazio, rotazione e consociazione con pesi configurabili.                                                                                               |
| FamilyNeedsEngine                  |    ✅ Integrato    | Prima versione completata nella S011 e integrata nella RecommendationPipeline nella S012 mediante ordinamento gerarchico per fascia agronomica, priorità familiare e punteggio agronomico. |
| FamilyConsumptionNeed              |   ✅ Completato    | Modello quantitativo introdotto nella S013 per rappresentare quantità, unità e periodicità del fabbisogno familiare.                                                                       |
| FamilyConsumptionNeedValidator     |   ✅ Completato    | Validazione dei fabbisogni quantitativi familiari introdotta nella S013.                                                                                                                   |
| PlannedPlantingBatch               |   ✅ Completato    | Modello introdotto nella S013 per rappresentare un lotto di coltivazione pianificato nel tempo.                                                                                            |
| PlannedPlantingBatchValidator      |   ✅ Completato    | Validazione dei dati necessari alla rappresentazione dei lotti di coltivazione pianificati.                                                                                                |
| SuccessionPlanningEngine           | ✅ V1 completata | Prima versione deterministica implementata nella S014: trasforma `FamilyConsumptionNeed` in una sequenza temporale validata di `PlannedPlantingBatch`, senza introdurre conversioni agronomiche non supportate. |
| AgronomicWindow                    | ✅ Completato    | Modello annuale introdotto nella S015 per rappresentare finestre agronomiche associate a uno specifico metodo di avvio, con supporto degli intervalli che attraversano il cambio dell'anno. |
| AgronomicWindowValidator           | ✅ Completato    | Validazione strutturale delle finestre agronomiche introdotta nella S015, comprese le combinazioni mese/giorno e il supporto del 29 febbraio. |
| AgronomicWindowEngine              | ✅ V1 completata | Prima versione implementata nella S015 per verificare l'appartenenza temporale alle finestre e la compatibilità dei `PlannedPlantingBatch` in base a metodo di avvio e data. |
| Stagionalità di colture e varietà | ✅ V1 completata | Obiettivo storico S016: le finestre agronomiche sono associabili a colture e varietà secondo il modello applicativo allora vigente. Il riallineamento completo al Catalogo Agronomico S030 resta evolutivo. |
| CropAgronomicWindowRule | ✅ Completato | Modello storico S016 per associare una `AgronomicWindow` a una coltura e, opzionalmente, a una specifica varietà. Il modello precede il cutover canonico S030. |
| AgronomicWindowResolver | ✅ V1 completata | Resolver storico S016 basato sul fallback varietà specifica → coltura generale → nessuna regola. È distinto dal Resolver del Catalogo Agronomico introdotto nella S030. |
| AgronomicWindowEvaluation | ✅ Completato | Risultato strutturato introdotto nella S016 per distinguere gli stati `compatible`, `incompatible` e `unknown`, evitando di interpretare l'assenza di dati come incompatibilità. |
| AgronomicWindowService | ✅ V1 completata | Servizio introdotto nella S016 per coordinare `AgronomicWindowResolver` e `AgronomicWindowEngine` nella valutazione stagionale dei `PlannedPlantingBatch`. |
| Progettazione della persistenza delle regole agronomiche | ✅ Completato | Obiettivo S017 completato nell'ambito della progettazione Database V1. L'implementazione e il riallineamento delle regole persistenti al Catalogo Agronomico corrente restano incrementali. |
| Integrazione completa del Resolver S030 nei flussi di pianificazione e inserimento | 📋 Pianificato | Il Resolver canonico è disponibile a livello di Catalogo; la sua integrazione completa nei flussi operativi rimane FUTURE. |
| Backend canonico delle consociazioni | 📋 Pianificato | Il motore applicativo esiste, ma il backend canonico del Catalogo per le associazioni tra colture non è ancora implementato. |

I componenti agronomici realizzati nelle sessioni precedenti alla S030 restano risultati tecnici validi delle rispettive fasi di sviluppo. La loro terminologia storica non viene riscritta retroattivamente.

Il Catalogo Agronomico S030 introduce tuttavia un nuovo contratto canonico globale. L'integrazione progressiva dei motori agronomici con `botanical_taxa`, `crops`, `crop_cultivars`, Knowledge pubblicata e Resolver costituisce quindi un'evoluzione successiva e deve evitare nuove dipendenze dal modello legacy.

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

Il completamento della gestione UI della tassonomia in S032 non equivale al completamento dell'intera UI amministrativa del Catalogo. Restano da completare, tra gli altri, i flussi applicativi completi di gestione delle Crop e delle Cultivar e le interfacce relative ad alias, fonti, dati candidati, revisione, pubblicazione e utilizzo operativo del Resolver.

---

## Altri blocchi futuri

Alla conclusione dello sviluppo S033/S033B, le attività ancora aperte o classificate FUTURE vengono distinte dai risultati già completati nelle sessioni precedenti.

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

La S033B ha censito staticamente 21/21 RPC relative ai seguenti ulteriori Registri Agronomici:

```text
measurement_units
agronomic_parameters
parameter_enum_values
production_contexts
protection_contexts
training_contexts
harvest_purposes
```

Rimangono da progettare e successivamente valutare per l'implementazione:

- modelli Flutter dedicati agli ulteriori Registri Agronomici;
- repository Flutter e contratti applicativi coerenti con le RPC autoritative;
- interfacce di consultazione e gestione;
- navigazione e integrazione con l'HUB;
- gestione delle autorizzazioni e degli esiti applicativi;
- verifiche specifiche e regressione.

La disponibilità delle RPC backend non equivale al completamento della loro integrazione Flutter.

Per la S034 è stato approvato esclusivamente l'obiettivo iniziale di progettazione del sottosistema Flutter dei Registri Agronomici, previa verifica della baseline backend effettivamente disponibile.

La S034 non è ancora iniziata e il suo primo eventuale incremento implementativo dovrà essere valutato separatamente.

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

### Sicurezza, backend e verifiche

La S033B ha effettuato un audit locale dei Write Path di `plantings`:

```text
create_planting
update_planting
set_planting_status
```

L'esito è stato favorevole nel perimetro effettivamente esaminato.

Non sono stati dimostrati difetti tali da giustificare correzioni immediate.

Rimangono possibili verifiche successive, da valutare secondo necessità:

- test runtime delle operazioni di scrittura;
- verifiche della concorrenza e della Profile Write Authority;
- test end-to-end Flutter/Supabase;
- verifiche del database remoto;
- approfondimenti sui casi limite della geometria e delle validazioni numeriche.

L'esito dell'audit locale non costituisce una certificazione generale della sicurezza dell'applicazione.

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
