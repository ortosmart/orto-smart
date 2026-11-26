# PRC-004 - Dashboard, impostazioni e distribuzione

## Metadati

- Sessione: S046
- Provenienza: STEP 273-274
- Macroblocchi: V1-15, V1-16, V1-17, V1-18

## 1. Dashboard - V1-15

Stato rilevato: placeholder.

Responsabilita prevista:

- Riepilogo dell'orto.
- Stagione consultata.
- Occupazione delle aiuole.
- Pianificazioni.
- Coltivazioni.
- Attivita.
- Irrigazione.
- Raccolti.
- Indicatori economici.
- Meteorologia.
- Avvisi e anomalie.

La disponibilita delle sezioni dipende
dal perimetro del rilascio.

Riutilizzare le aggregazioni dei domini.

Le azioni rapide devono utilizzare
i percorsi autoritativi esistenti.

Non implementare mutazioni parallele.

Distinguere zero, dato sconosciuto,
parziale, stimato, obsoleto ed errore.

Un errore meteorologico non deve impedire
la consultazione delle altre informazioni.

## 2. Impostazioni - V1-16

Stato rilevato:

- Catalogo Agronomico.
- Documentazione.

Responsabilita previste:

- Configurazione del profilo.
- Registri pertinenti.
- Preferenze.
- Navigazione amministrativa.
- Gestione delle fonti agronomiche.
- Configurazioni dei domini.
- Correzioni controllate.
- Riconciliazione delle anomalie.

Non concentrare indiscriminatamente
tutti i dati in una tabella universale.

Mantenere distinti registri globali,
configurazioni del profilo,
configurazioni tecniche e preferenze.

Le operazioni amministrative devono utilizzare
i contratti autoritativi dei domini.

## 3. Distribuzione - V1-17

Applicazione Flutter Web.

Primo rilascio:

- PC con Edge.
- iPad con Safari.
- Accesso HTTPS.
- Verifica dell'utilizzo sul campo.

Versione definitiva:

- PC.
- iPad.
- iPhone.
- Dispositivi Android.
- Accesso dalla schermata iniziale.

Elementi rilevati:

- Manifest Web con nome predefinito orto_app.
- Orientamento portrait-primary.
- Icone standard.
- Configurazione hosting non individuata
  nei percorsi esaminati.

L'assenza nei percorsi esaminati
non dimostra l'assenza nell'intero repository.

Identificare ogni build mediante:

- Versione.
- Commit.
- Data.
- Compatibilita con lo schema.
- Ambiente di distribuzione.

Conservare una strategia di rollback.

Il rollback della build non equivale
al ripristino del database.

## 4. Accettazione operativa - V1-18

Responsabilita:

- Configurazione reale.
- Verifica dei prerequisiti.
- Collaudo dei percorsi completi.
- Verifica sui dispositivi.
- Gestione delle anomalie.
- Accettazione formale.
- Conservazione dei dati reali.

Percorso principale A:

Profilo
-> Orto
-> Aiuole
-> Stagione
-> Catalogo
-> Pianificazione
-> Conferma
-> Esecuzione reale
-> Coltivazione.

Non creare eventi operativi fittizi
per dimostrare l'accettazione.

Quando un evento reale non e ancora avvenuto,
utilizzare un collaudo equivalente isolato,
distinguendolo dall'accettazione reale.

## 5. Evidenze di rilascio

Registrare:

- Data e ora.
- Versione.
- Commit.
- Build.
- URL.
- Stato delle migrazioni.
- Risultati dei test.
- Dispositivi verificati.
- Backup e recuperabilita.
- Stato del Catalogo.
- Configurazione reale.
- Criticita residue.
- Autorizzazione al rilascio.

## 6. Limiti

Hosting definitivo: NV.

Accettazione operativa complessiva: non acquisita.

Data del primo rilascio: da determinare.

Data del completamento definitivo: da determinare.

Consultare ARC-004 per i vincoli di rilascio.
