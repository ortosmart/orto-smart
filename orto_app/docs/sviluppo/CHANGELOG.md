# CHANGELOG

Tutte le modifiche rilevanti del progetto **Orto Smart** vengono documentate in questo file.

Questo documento registra le evoluzioni del software tra una versione e l'altra.

Per il dettaglio delle singole sessioni di lavoro fare riferimento al **DOC-005 – Quaderno di Sviluppo**.

---

# Versione 0.1.0-alpha

**Data:** 27/07/2026

## Aggiunto

- Creato il progetto Flutter.
- Configurato il repository GitHub.
- Integrato Supabase come backend.
- Realizzata la struttura iniziale del database.
- Implementata la gestione di orti, aiuole, colture e stagioni.
- Implementata la gestione delle piantagioni.
- Creata la visualizzazione grafica delle aiuole.
- Implementato il Repository Pattern.
- Sviluppata la prima versione del Motore Agronomico.
- Implementati `FreeSpaceEngine` e `SuggestionEngine`.
- Creata la documentazione tecnica del progetto.
- Creato il **DOC-005 – Quaderno di Sviluppo**.
- Creata la **Roadmap di sviluppo**.

## Modificato

- Ordinamento delle aiuole da 1 a 15.
- Migliorata la rappresentazione grafica delle aiuole.
- Esteso il modello `Planting`.
- Riorganizzata la cartella `docs`.
- Definito il workflow ufficiale di sviluppo.

## Corretto

- Risolti problemi di inserimento delle piantagioni.
- Corrette le Foreign Key del modulo irrigazione.
- Sistemate le policy RLS di Supabase.
- Eliminati gli errori segnalati da `flutter analyze`.
- Corrette anomalie nella visualizzazione grafica delle aiuole.

## Sicurezza

- Abilitata la Row Level Security (RLS) nelle tabelle Supabase.
- Verificate le policy di accesso ai dati.

---

# Regole di aggiornamento

Il CHANGELOG viene aggiornato quando una modifica introduce nuove funzionalità, migliora il comportamento del software, corregge bug o modifica aspetti rilevanti del progetto.

Le modifiche vengono classificate nelle seguenti categorie:

- **Aggiunto**
- **Modificato**
- **Corretto**
- **Rimosso**
- **Sicurezza**

Le attività dettagliate delle singole sessioni vengono invece documentate nel **DOC-005 – Quaderno di Sviluppo**.

---

# Cronologia revisioni

| Versione | Data | Descrizione |
|----------|------------|-------------------------------------------|
| 0.1 | 27/07/2026 | Prima emissione del documento CHANGELOG. |