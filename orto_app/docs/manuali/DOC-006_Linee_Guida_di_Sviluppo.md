# DOC-006 – Linee Guida di Sviluppo

Versione: 0.1

---

# 1. Scopo

Il presente documento definisce gli standard di sviluppo del progetto Orto Smart.

L'obiettivo è garantire uniformità, qualità del codice, tracciabilità delle modifiche e coerenza della documentazione durante l'intero ciclo di vita del progetto.

---

# 2. Principi del progetto

- Codice semplice e leggibile.
- Una responsabilità per ogni classe.
- Evitare duplicazioni.
- Preferire componenti riutilizzabili.
- Documentare ogni modifica significativa.
- Privilegiare la manutenibilità rispetto alla complessità.

---

# 3. Architettura

Principi adottati:

- Repository Pattern
- Modelli separati dalla UI
- Business Logic separata dall'interfaccia
- Motore agronomico indipendente dalla UI
- Database normalizzato
- Utilizzo di Supabase come backend

---

# 4. Convenzioni di sviluppo

## Nomi dei file

snake_case

Esempio

free_space_engine.dart

---

## Nomi delle classi

PascalCase

Esempio

FreeSpaceEngine

---

## Variabili

camelCase

Esempio

availableLength

---

## Costanti

camelCase oppure static const secondo gli standard Dart.

---

# 5. Organizzazione del progetto

Descrizione della struttura delle cartelle.

lib/
core/
data/
pages/
widgets/
services/
docs/

Per ogni cartella verrà descritto il suo scopo.

---

# 6. Workflow di sviluppo

Ogni nuova funzionalità segue il seguente processo.

1. Analisi
2. Progettazione
3. Implementazione
4. Test
5. flutter analyze
6. flutter test
7. Commit Git
8. Push GitHub
9. Aggiornamento documentazione

La sessione non è considerata conclusa finché la documentazione non è aggiornata.

---

# 7. Gestione Git

Regole per:

- commit
- branch
- push
- versioni

Formato consigliato dei messaggi di commit.

---

# 8. Gestione della documentazione

Documenti ufficiali.

DOC-001 Manuale Tecnico

DOC-005 Quaderno di Sviluppo

DOC-006 Linee Guida di Sviluppo

DOC-008 Roadmap

CHANGELOG

VERSION

Quando aggiornare ciascun documento.

---

# 9. Standard di qualità

Prima di ogni commit verificare:

- flutter analyze
- flutter test
- nessun warning
- nessun codice inutilizzato
- documentazione aggiornata

---

# 10. Evoluzione del progetto

Principi da mantenere durante tutta la crescita di Orto Smart.

- evitare codice duplicato;
- mantenere il motore agronomico modulare;
- progettare pensando alle future espansioni;
- ottimizzare lo spazio occupato nel database;
- evitare dati ridondanti;
- mantenere compatibilità con il piano gratuito di Supabase quando possibile.

---

# 11. Revisioni

| Versione | Data | Descrizione |
|-----------|------------|----------------|
| 0.1 | 27/07/2026 | Prima versione del documento. |