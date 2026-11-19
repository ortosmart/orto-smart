# ORTO SMART

### DOCUMENTO OPERATIVO V1

# Stato Operativo Orto Smart

**Versione:** 1.0
**Stato:** In sviluppo
**Prima emissione:** 19/11/2026
**Ultimo aggiornamento:** 19/11/2026
**Sessione di riferimento:** S043
**Repository:** ortosmart/orto-smart

---

# Informazioni sul documento

| Campo | Valore |
|---|---|
| Titolo | Stato Operativo Orto Smart |
| Versione | 1.0 |
| Stato | In sviluppo |
| Progetto | Orto Smart |
| Repository | ortosmart/orto-smart |
| Prima emissione | 19/11/2026 |
| Ultimo aggiornamento | 19/11/2026 |
| Sessione | S043 |

---

# Cronologia delle revisioni

| Versione | Data | Descrizione |
|---|---|---|
| 1.0 | 19/11/2026 | Prima emissione del documento operativo unico della V1 |

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

Il presente documento costituisce il riferimento operativo sintetico
per lo sviluppo della V1 di Orto Smart.

È gestito nella chat ufficiale di sviluppo e aggiornato ogni una
o due sessioni, oppure quando intervengono modifiche significative.

Non sostituisce retroattivamente i manuali ufficiali esistenti.

Il documento DOC-000_Standard_Documentale.md mantiene il proprio
codice e la propria funzione.

I checkpoint delle sessioni conservano separatamente la struttura
approvata di dieci sezioni e ventiquattro indicatori grafici.

---

# 2. Baseline Git e qualità

## 2.1 Repository

- Repository: ortosmart/orto-smart
- Branch: main
- Ultimo commit pubblicato noto: 64e8981
- Descrizione: S043: implementa e collauda conferma pianificazioni
- Push GitHub: completato nella S043

La pulizia del working tree dopo il push deve essere verificata
con un controllo Git dedicato.

## 2.2 Verifiche

- flutter analyze completo: PASS
- flutter test completo: 1563/1563 PASS
- Test repository pianificazioni: 61/61 PASS
- git diff --cached --check del blocco Flutter: PASS

I risultati si riferiscono al blocco di sviluppo verificato
prima del commit 64e8981.

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

- Gestione orti.
- Gestione aiuole e geometrie.
- Gestione stagioni.
- Catalogo Agronomico V1.
- Pianificazioni stagionali.
- Gestione coltivazioni.
- Dashboard.
- Irrigazione.
- Attività e registrazioni operative.
- Impostazioni e sicurezza.

Il livello di completamento varia tra i componenti.

## 5.2 Indicatori generali del checkpoint S043.570

- Completamento tecnico stimato V1: 71,5%.
- Preparazione operativa stimata V1: 40%.
- Percorso B complessivo: 31%.

Le percentuali sono indicatori di avanzamento progettuale,
non misure automatiche del codice realizzato.

---

# 6. Pianificazioni stagionali

## 6.1 Lifecycle SQL

Il lifecycle comprende:

- creazione della bozza;
- aggiornamento;
- conferma;
- annullamento;
- esecuzione.

Sono previste RPC autoritative e verifiche di autorizzazione,
versionamento, geometria e sovrapposizione.

## 6.2 Integrazione Flutter

La creazione e l'aggiornamento dispongono di repository Flutter.

Nella S043 è stata implementata e collaudata
confirmPlannedPlanting().

Il blocco comprende:

- risultati Dart tipizzati;
- invocazione RPC confirm_planned_planting;
- acquisizione della Write Authority;
- gestione degli stati SQL;
- diciotto test aggiuntivi.

Commit: 64e8981.

## 6.3 Funzioni ancora da integrare

- cancelPlannedPlanting().
- executePlannedPlanting().
- Interfaccia utente del lifecycle.
- Collaudo integrato Flutter-Supabase.
- Percorso operativo completo di primo utilizzo.

---

# 7. Decisioni e vincoli

## 7.1 Decisioni consolidate

- Catalogo Agronomico strutturato e verificato.
- Fonti esterne trattate come dati candidati.
- Nessuna sovrascrittura automatica dei dati approvati.
- Separazione tra dati di prova e dati operativi reali.
- Scritture protette tramite autorità server.
- Sviluppo guidato da verifiche e risultati effettivi.

## 7.2 Gestione documentale temporanea V1

Durante la preparazione della V1 viene mantenuto
un unico documento operativo sintetico.

Gli aggiornamenti ordinari dei manuali tradizionali
sono sospesi fino alla pubblicazione della V1.

Lo storico documentale esistente rimane preservato.

---

# 8. Attività aperte

Le attività da valutare e completare comprendono:

1. Integrazione Flutter dell'annullamento.
2. Integrazione Flutter dell'esecuzione.
3. Test dei rispettivi repository.
4. Interfaccia operativa delle pianificazioni.
5. Verifica delle migrazioni S039 prima dell'eventuale distribuzione.
6. Collaudo integrato Flutter-Supabase.
7. Preparazione dei dati reali.
8. Verifica del percorso minimo di primo utilizzo.
9. Valutazione delle funzioni indispensabili alla V1.
10. Verifica delle procedure di backup e ripristino.

L'ordine operativo deve essere confermato durante lo sviluppo.

---

# 9. Tempi di sviluppo e stime

## 9.1 Consuntivo S043 noto

Fino al 19/11/2026 alle 12:27:

- Sviluppo netto confermato: 7 ore e 46 minuti.
- Pause confermate: 18 ore e 59 minuti.
- Ripresa sviluppo: 19/11/2026 alle 13:09.
- Segmento successivo: ancora aperto nel checkpoint.

Il tempo del segmento aperto non è conteggiato.

## 9.2 Stime dei percorsi

| Percorso | Ore iniziali | Ore consuntivate | Residuo contabile | Residuo operativo stimato |
|---|---|---|---|---|
| A | Da recuperare | Da recuperare | Da verificare | Da verificare |
| B | Da recuperare | Da recuperare | Da verificare | 20-35 ore |
| Altri percorsi originari | Da identificare | Da recuperare | Da verificare | Da verificare |
| Totale | Da riconciliare | Da riconciliare | Da verificare | Da verificare |

La stima di 20-35 ore per il Percorso B deriva
dall'ultimo riferimento storico disponibile S043.440.

La stima non è stata ancora ricalcolata dopo il completamento
del metodo Flutter di conferma.

Per la fase B1 risultava una stima residua di 1-4 ore.

Non devono essere inventati valori mancanti.

---

# 10. Preparazione alla V1

L'obiettivo iniziale del 15/11/2026 è stato superato.

La finestra indicativa del 16-22/11/2026
non costituisce una data di pubblicazione garantita.

La pubblicazione dipende dalla verifica del percorso
operativo minimo e dai collaudi effettivi.

Non è stata approvata una nuova data ufficiale.

---

# 11. Riferimenti e checkpoint
12. Mappa tecnica per la ripresa dello sviluppo

## 11.1 Riferimenti tecnici

- DOC-000_Standard_Documentale.md
- Documentazione tecnica ufficiale già presente nel repository.
- Migrazioni SQL e test locali.
- Codice Flutter e relativi test.

## 11.2 Checkpoint di riferimento

- S043.560: baseline precedente al collaudo della conferma.
- S043.570: conferma Flutter collaudata.
- S043.574: commit 64e8981.
- S043.575: push completato.
- S043.577: verifica dello standard documentale.

Il presente documento registra esclusivamente
lo stato consolidato e non sostituisce i checkpoint analitici.

---

# 12. Mappa tecnica per la ripresa dello sviluppo

## 12.1 Pianificazioni stagionali

### Repository e contratti Flutter

| Funzione | File |
|---|---|
| Accesso ai dati e RPC | `lib/data/repositories/planned_planting_repository.dart` |
| Risultati tipizzati delle scritture | `lib/core/write_authority/planned_planting_write_result.dart` |
| Modello batch | `lib/core/agronomy/models/planned_planting_batch.dart` |
| Validazione batch | `lib/core/agronomy/planned_planting_batch_validator.dart` |
| Test repository | `test/data/repositories/planned_planting_repository_test.dart` |

### RPC e migrazioni

| Operazione | Migrazione |
|---|---|
| Aggiornamento | `20261104220000_add_update_planned_planting_rpc.sql` |
| Correzione geometria creazione | `20261104221500_fix_create_planned_planting_geometry.sql` |
| Conferma | `20261104223000_add_confirm_planned_planting_rpc.sql` |
| Protezione pianificazioni confermate | `20261104224500_protect_confirmed_planned_planting_updates.sql` |
| Annullamento | `20261104233000_add_cancel_planned_planting_rpc.sql` |
| Esecuzione atomica | `20261105000000_add_atomic_planned_planting_execution.sql` |

Tutte le migrazioni indicate si trovano in `supabase/migrations/`.

### Collaudi

- Test Flutter: `test/data/repositories/planned_planting_repository_test.dart`.
- Collaudo SQL: `supabase/tests/s040_planned_planting_lifecycle.sql`.
- Baseline Flutter verificata: 1563 test superati.
- Ultimo commit pubblicato: `64e8981`.

### Stato di implementazione

- Creazione pianificazione: repository Flutter già presente.
- Aggiornamento pianificazione: repository Flutter già presente.
- Conferma pianificazione: implementata e collaudata in S043.
- Annullamento pianificazione: integrazione Flutter da completare.
- Esecuzione pianificazione: integrazione Flutter da completare.
- Interfaccia lifecycle: da completare.
- Collaudo integrato con Supabase: da completare.

### Regola per le sessioni successive

Prima di sviluppare una nuova funzione:

1. Consultare questa mappa tecnica.
2. Riutilizzare i contratti e i componenti già verificati.
3. Esaminare soltanto le parti di codice necessarie alla modifica.
4. Eseguire i test pertinenti e le verifiche finali.
5. Aggiornare esclusivamente le sezioni operative interessate.

Non ripetere ricognizioni generali del progetto in assenza di
modifiche, anomalie o discrepanze concrete.

## 12.2 Prossimo intervento

Implementare `cancelPlannedPlanting()` nel repository Flutter,
rispettando il contratto della RPC SQL esistente e la Write Authority.

Procedere successivamente con i test specifici e il collaudo.

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
