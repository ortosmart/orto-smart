# Orto Smart

Orto Smart è un'applicazione Flutter e Supabase per la gestione dell'orto.
Il repository è `ortosmart/orto-smart`. L'app Flutter è in `orto_app`.

## Autorizzazioni operative

- Gestire una sola attività tecnica per volta. Consultare autonomamente
  i file locali pertinenti e svolgere le verifiche di sola lettura autorizzate.
- Ottenere un'autorizzazione esplicita prima di scrivere o modificare
  file, codice, documentazione o dati. Presentare prima la proposta quando
  il titolare o il checkpoint di sessione lo richiede.
- Eseguire analisi e test previa autorizzazione, fino a diversa indicazione
  del titolare. Accedere a Internet solo con autorizzazione.
- Richiedere autorizzazioni distinte per commit e push. Verificare il
  perimetro delle modifiche prima del versionamento e preservare il lavoro
  presente nel working tree.
- Applicare migrazioni solo con autorizzazione esplicita per l'ambiente
  interessato. Richiedere autorizzazione per qualsiasi modifica al database
  remoto. Evitare cancellazioni o sovrascritture indiscriminate e dati
  fittizi permanenti.
- Usare le autorizzazioni dell'ambiente applicabili all'azione richiesta.
  Queste istruzioni definiscono il flusso operativo e non costituiscono
  un blocco tecnico delle scritture. Verificare i permessi senza tentare
  modifiche non autorizzate.

## Continuità delle sessioni

- Ripartire dal checkpoint approvato. Verificare percorso, branch, HEAD,
  riferimenti Git pertinenti e working tree. Segnalare divergenze,
  verifiche pendenti e informazioni mancanti.
- Consultare il Registro e le fonti interessate. Riutilizzare osservazioni,
  decisioni e collaudi già acquisiti quando la baseline resta applicabile.
  Preservare le modifiche attese e riprendere dal primo punto aperto.
- Distinguere attività pianificate, eseguite, verificate e accettate.
  Registrare il tempo effettivamente lavorato dopo ogni trasferimento,
  senza duplicare gli intervalli già contabilizzati.
- In chiusura, secondo le autorizzazioni ricevute, aggiornare le schede
  pertinenti, lo stato e i consuntivi. Verificare la persistenza dei
  documenti e predisporre il checkpoint con baseline, evidenze, decisioni,
  criticità, attività residue e punto di ripresa.

### Ricezione e consuntivi

- All'apertura o al passaggio di conversazione, recuperare tutte le
  pendenze e verificare il punto di ripresa, i consuntivi, il riferimento
  effettivo su GitHub e le registrazioni in Coordinamento, secondo le
  autorizzazioni disponibili. Segnalare le verifiche aperte e motivare
  l'eventuale riesecuzione dei collaudi.
- Registrare gli intervalli per sessione, giornata e conversazione,
  distinguendo apertura, sospensione, ripresa, chiusura, tempo lordo,
  tempo netto e ore confermate o provvisorie. Verificare la quadratura
  con il progressivo generale e dichiarare definitivi solo i valori
  confermati.

### Consolida e sospendi

Applicare la procedura alla ricezione del comando «Consolida e sospendi»
o al raggiungimento della soglia prevista. Usarla anche in occasione di
sospensioni significative, chiusure o passaggi di conversazione.

1. Interrompere l'avvio di nuove attività.
2. Portare l'operazione in corso a un punto sicuro, quando possibile.
3. Preservare tutte le modifiche locali.
4. Raccogliere e registrare le evidenze acquisite.
5. Verificare Git, staging e working tree.
6. Aggiornare le pendenze secondo le autorizzazioni disponibili.
7. Predisporre il checkpoint con baseline, evidenze, decisioni,
   criticità, pendenze e stato di pubblicazione e sincronizzazione.
8. Registrare gli intervalli disponibili e il relativo stato di conferma.
9. Indicare il punto esatto di ripresa.
10. Sospendere le attività.

Se il checkpoint persistente non può essere completato, produrre subito
un checkpoint sintetico e copiabile nella conversazione. Modifiche,
staging, commit, push e scritture esterne richiedono le autorizzazioni
applicabili all'azione.

## Registro tecnico ed evidenze

- Mantenere la documentazione attiva in `orto_app/docs/registro_tecnico`.
  Conservare i Manuali Orto Smart come documentazione storica.
- Consultare prioritariamente `ARC-REG-001`, `README`, `STATO_CORRENTE`
  e `RC-REG-001`. Seguire lo standard per metadati, identificativi,
  struttura delle schede, classificazione e riferimenti.
- Conservare ogni conoscenza nella scheda di competenza e richiamarla
  tramite riferimenti. Preservare lo storico delle decisioni e la loro
  provenienza. Proteggere token, password e credenziali.
- Usare codice e migrazioni come fonti primarie dell'implementazione.
  Verificare lo stato effettivo del database nell'ambiente pertinente
  quando autorizzato. La corrispondenza delle versioni delle migrazioni
  documenta l'allineamento delle versioni. L'equivalenza funzionale
  richiede evidenze dedicate.
- Ricondurre le evidenze a file, commit, ambiente, sessione e test.
  Distinguere verifica statica, test simulato, collaudo integrato e
  accettazione operativa. Indicare le verifiche mancanti senza inventare
  risultati, avanzamenti o accettazioni.
- Applicare i livelli E0–E5, NV e NA secondo `ARC-REG-001` e classificare
  ogni esito come RIUTILIZZARE, INTEGRARE, VERIFICARE o SVILUPPARE.
  Consultare il Registro prima di progettare componenti nuovi. Conservare
  la matrice D01–D14 nelle riconciliazioni che la prevedono. Formalizzare
  una non conformità sulla base di evidenze adeguate, mantenendo distinte
  le osservazioni tecniche da approfondire.

### Controllo di uscita dalla riconciliazione

- Registrare stati distinti per ogni riconciliazione, attività tecnica
  o blocco significativo. Prima di passare alla riconciliazione
  successiva, presentare una scheda sintetica con queste dieci voci:
  conclusione tecnica, approvazione del titolare, consolidamento
  documentale locale, aggiornamento degli indici e dei riepiloghi,
  pubblicazione GitHub, sincronizzazione con Coordinamento, accettazione
  operativa, riconciliazione quantitativa, pendenze precedenti ancora
  aperte e punto esatto di ripresa.
- Per ciascuna voce indicare, secondo pertinenza, **completato**,
  **pendente**, **non verificato** o **non applicabile**, con un riscontro
  o una motivazione. Per il punto di ripresa riportare il riferimento
  preciso. Ogni stato richiede evidenze proprie.
- Registrare controlli, risultati, livelli di evidenza, limitazioni e
  verifiche residue. Acquisire l'approvazione richiesta e aggiornare,
  secondo le autorizzazioni ricevute, le schede di competenza,
  `RC-REG-001`, `STATO_CORRENTE`, `README` e gli indici pertinenti.
  Ricavare i conteggi dalle singole riconciliazioni effettivamente
  concluse. Mantenere separati conteggi, maturità funzionale,
  STEP 275 e stime quantitative.
- Verificare la coerenza dei contenuti con le fonti di competenza:
  conteggi, stato quantitativo, percentuali formalizzate, migrazioni,
  ultimo commit verificato, pubblicazione, punto di ripresa, consuntivi,
  inventario e collegamenti alle evidenze. Distinguere i dati correnti
  dalle fotografie storiche e conservare queste ultime con data e contesto.

### Pendenze di consolidamento

- Al termine di ogni riconciliazione, verificare cumulativamente
  tutte le pendenze aperte e le riconciliazioni concluse nella sessione.
  Controllare attestazioni solo locali, file non tracciati, modifiche
  non consolidate o escluse dai commit, riepiloghi superati, registrazioni
  mancanti in Coordinamento e consuntivi incompleti.
- Mantenere l'elenco persistente in `STATO_CORRENTE` e richiamarlo
  nel checkpoint. Per ogni pendenza riportare sessione, STEP o RC, data,
  stato tecnico, documenti interessati, stato del working tree, commit,
  push e sincronizzazione, motivo, prossima azione, responsabile
  (Codex, ChatGPT o titolare), momento o condizione prevista e criterio
  di verifica della risoluzione.
- Preservare le pendenze nel checkpoint in caso di rinvio o passaggio
  alla riconciliazione successiva. Aggiornare lo stato a risolto solo
  dopo aver verificato il criterio previsto.

## Pubblicazione e sincronizzazione

- Prima di proporre un commit, verificare HEAD, staging e working tree,
  inclusi i file non tracciati. Indicare file e blocchi inclusi,
  modifiche escluse ed evidenze ancora da pubblicare. Eseguire i
  controlli pertinenti secondo le autorizzazioni previste.
- Dopo il push, verificare HEAD, `origin/main` e il riferimento remoto
  effettivo. Verificare presenza e coerenza dei file pubblicati,
  controllare separatamente le modifiche locali fuori dal commit
  e aggiornare lo stato delle pendenze.
- Alla conclusione di una riconciliazione significativa, di un blocco
  di dieci STEP, di una sospensione significativa o di una chiusura,
  verificare le registrazioni in Orto Smart · Coordinamento. Preparare
  gli aggiornamenti mancanti o superati, evitare duplicazioni e
  rileggere le registrazioni dopo il salvataggio autorizzato.
- Se le funzioni di Coordinamento sono indisponibili, preparare un
  resoconto copiabile per ChatGPT con le singole registrazioni da
  inserire o modificare. Mantenere aperta la pendenza fino alla
  conferma verificabile della sincronizzazione.
- Prima di dichiarare una sessione integralmente consolidata, verificare
  la coerenza tra repository locale, Registro tecnico, GitHub,
  Coordinamento, checkpoint e consuntivi. Per ogni differenza indicare
  il dato, la fonte verificata e l'azione residua. La sessione può essere
  sospesa o chiusa con pendenze esplicite. Il consolidamento integrale
  richiede la risoluzione verificata delle pendenze documentali, di
  pubblicazione e di sincronizzazione.

## Monitoraggio e stime

- Eseguire un controllo sistematico ogni dieci STEP. Mantenere barre
  orizzontali colorate per STEP, sottostep, blocco di dieci STEP,
  riconciliazione corrente e generale, consolidamento documentale,
  collaudi, criticità risolte e residue, tempo giornaliero e consuntivi di
  sessione e generali, ore residue della sola riconciliazione e baseline A/B.
  Recuperare gli altri indicatori stabiliti dal Registro e dai checkpoint.
  Mostrare il valore o lo stato quando manca una scala verificata.
- Distinguere gli indicatori di avanzamento tecnico, consolidamento
  documentale, pubblicazione GitHub, sincronizzazione con Coordinamento,
  riconciliazione quantitativa, pendenze e consuntivi giornalieri, di
  sessione e generali. Usare barre orizzontali colorate continue, senza
  segmenti, quando l'interfaccia lo consente. Dichiarare la base di
  calcolo di ogni percentuale.
- Tenere separati baseline A/B, configurazione reale, stima della sola
  riconciliazione e consuntivi. Consultare le tabelle complete V1-EST
  prima di aggiornamenti quantitativi. Documentare le variazioni approvate
  ed evitare deduzioni o conteggi duplicati tra riconciliazioni correlate.

### Risorse disponibili

Applicare le soglie solo quando la quota residua è accessibile o
comunicata dal titolare.

| Quota residua | Azione |
|---|---|
| Oltre il 20% | Operatività normale. |
| Oltre il 10% e fino al 20% | Attenzione. Valutare le attività successive. |
| Oltre il 5% e fino al 10% | Preallarme. Preparare il consolidamento. |
| Fino al 5% | Attivare «Consolida e sospendi». |

Se la quota è indisponibile, dichiarare il limite e mantenere disponibile
il comando manuale. Riportare percentuali e monitoraggio automatico
solo quando effettivamente disponibili.
