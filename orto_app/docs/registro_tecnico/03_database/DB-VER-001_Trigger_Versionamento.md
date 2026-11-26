# DB-VER-001 - Trigger e versionamento

## 1. Identificazione

- Versione: 1.0.
- Sessione: S046.
- Data: 26/11/2026.
- Origine: RC01, controllo 06.
- Macroblocco principale: V1-02.
- Baseline Git: 20649de7474765bd1c293b20bfcedab0a9493a14.
- Ambiente: PostgreSQL locale.
- Evidenza strutturale: E3.
- Ambiente remoto: NV.

## 2. Funzione comune

Simbolo:

public.set_updated_at_and_row_version()

Fonte originaria:

supabase/migrations/20260817103916_database_v1_baseline.sql

Caratteristiche rilevate:

- SECURITY INVOKER.
- search_path vuoto.
- Utilizzo nei trigger BEFORE UPDATE.

Comportamento:

- updated_at impostato a now().
- row_version impostato al valore
  precedente incrementato di 1.

La funzione gestisce metadati
di aggiornamento e versione.

## 3. Trigger nella migrazione originaria

Tabelle interessate:

- profiles.
- profile_memberships.
- gardens.
- workers.
- seasons.

L'inventario complessivo dei trigger
attualmente installati in tutti
i domini appartiene alla RC04.

## 4. Trigger verificati in RC01

Tabelle esaminate nel database locale:

- profiles.
- profile_memberships.
- workers.

Risultati:

- Tre trigger BEFORE UPDATE.
- Stato di abilitazione O.
- Funzione comune di aggiornamento
  e incremento della versione.

Lo stato O indica il normale
funzionamento del trigger
in modalita origin e local.

Non sono stati rilevati trigger
INSERT non interni sulle tre
tabelle esaminate.

## 5. Limiti del versionamento

Incrementare row_version
non equivale a verificare
la versione attesa dal client.

La funzione comune non verifica:

- Possesso dell'edit lock.
- Identita della sessione.
- Token di autorita.
- Versione attesa.
- Compatibilita semantica
  della modifica.

Queste responsabilita devono
essere gestite dai percorsi
autoritativi pertinenti.

Il trigger non sostituisce
una RPC di mutazione.

## 6. Integrazione con Write Authority

Separare le responsabilita:

- Autenticazione.
- Autorizzazione sul profilo.
- Autorita di scrittura.
- Controllo della versione attesa.
- Validazione di dominio.
- Aggiornamento dei metadati.

L'incremento automatico della versione
deve essere considerato quando
si progettano o modificano le RPC.

Evitare incrementi duplicati
non previsti dal contratto.

Il comportamento effettivo delle RPC
deve essere verificato nella RC04.

## 7. Osservazioni aperte

- Controllo delle versioni attese.
- Concorrenza fra mutazioni.
- Aggiornamenti diretti.
- Metadati durante INSERT.
- Comportamento delle RPC esistenti.
- Incrementi effettivi della versione.
- Rollback e atomicita.

Riferimento:

NC-RC01-001.

La verifica strutturale del trigger
non dimostra la protezione completa
dalle scritture concorrenti.

## 8. Riutilizzo

RIUTILIZZARE:

La funzione comune di gestione
dei metadati quando compatibile
con il contratto del dominio.

INTEGRARE:

Controllo della versione attesa
nei percorsi autoritativi pertinenti.

VERIFICARE:

- Trigger effettivamente installati.
- Interazioni con le RPC.
- Concorrenza.
- Incrementi e rollback.
- Comportamento remoto.

Non creare nuove funzioni equivalenti
senza verificare prima quelle esistenti.

## 9. Collegamenti e limiti

- DB-PROF-001.
- DB-SEC-001.
- ARC-002.
- RC02.
- RC03.
- RC04.
- NC-RC01-001.

Le evidenze sono limitate
alla ricognizione strutturale RC01.

Nessun nuovo collaudo funzionale
di concorrenza eseguito.

Nessuna modifica al database introdotta.
