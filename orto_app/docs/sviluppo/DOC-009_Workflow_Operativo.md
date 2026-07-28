# DOC-009 – Workflow Operativo

## Scopo del documento

Il presente documento definisce il workflow operativo ufficiale da seguire durante ogni sessione di sviluppo del progetto **Orto Smart**.

L'obiettivo è garantire un metodo di lavoro uniforme, ridurre il rischio di dimenticare attività importanti e mantenere costantemente allineati codice, documentazione e repository Git.

Le regole generali del progetto sono riportate nel **DOC-006 – Linee Guida di Sviluppo**.

---

# Workflow di una sessione di sviluppo

## 1. Apertura della sessione

Prima di iniziare lo sviluppo:

- Verificare lo stato del repository Git.
- Identificare la sessione di sviluppo (S001, S002, ...).
- Definire gli obiettivi della sessione.
- Verificare lo stato della documentazione.

---

## 2. Analisi iniziale

Prima di modificare il codice:

- Analizzare il problema da risolvere.
- Valutare eventuali impatti sull'architettura.
- Individuare i file interessati.
- Pianificare l'intervento.

---

## 3. Sviluppo

Durante lo sviluppo:

- Implementare una modifica alla volta.
- Mantenere il codice semplice e leggibile.
- Evitare duplicazioni.
- Rispettare l'architettura del progetto.
- Documentare eventuali decisioni importanti.

---

## 4. Verifica del codice

Al termine dello sviluppo eseguire sempre:

```bash
dart format .
flutter analyze
flutter test
```

Correggere eventuali errori prima di proseguire.

---

## 5. Verifica dell'applicazione

Verificare il corretto funzionamento dell'applicazione eseguendo i test manuali necessari.

Nessuna sessione può essere considerata conclusa senza una verifica funzionale.

---

## 6. Aggiornamento della documentazione

Aggiornare, se necessario:

- DOC-001 – Manuale Tecnico
- DOC-003 – CHANGELOG
- DOC-005 – Quaderno di Sviluppo
- DOC-011 – Decisioni Architetturali
- DOC-008 – Roadmap di Sviluppo
- Altri documenti eventualmente interessati

---

## 7. Verifica finale

Prima del commit verificare che:

- Il progetto compili correttamente.
- Tutti i test siano superati.
- La documentazione sia aggiornata.
- Non siano presenti file temporanei o inutilizzati.

---

## 8. Commit Git

Eseguire:

```bash
git status
git add .
git commit -m "Messaggio del commit"
```

### Regole

- I messaggi di commit devono essere scritti in italiano.
- Ogni commit deve descrivere chiaramente il lavoro svolto.

---

## 9. Push su GitHub

Eseguire:

```bash
git push
```

Verificare che il push venga completato correttamente.

---

## 10. Chiusura della sessione

Una sessione può essere considerata conclusa solamente quando:

- Lo sviluppo è terminato.
- Tutti i test sono stati superati.
- La documentazione è aggiornata.
- Il commit è stato eseguito.
- Il push su GitHub è stato completato.

Solo dopo questi controlli è possibile aprire la sessione successiva.

---

# Regole fondamentali

- Una sessione mantiene lo stesso numero fino al suo completamento.
- La sessione successiva viene aperta solo dopo la chiusura ufficiale della precedente.
- Il codice e la documentazione devono rimanere sempre sincronizzati.
- Le decisioni architetturali devono essere registrate nel DOC-011.
- Le modifiche rilevanti devono essere riportate nel CHANGELOG.
- Le attività della sessione devono essere documentate nel Quaderno di Sviluppo.

---

# Checklist rapida

- [ ] Apertura della sessione
- [ ] Analisi iniziale
- [ ] Sviluppo
- [ ] `dart format`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Verifica manuale
- [ ] Aggiornamento documentazione
- [ ] `git status`
- [ ] `git add`
- [ ] `git commit`
- [ ] `git push`
- [ ] Chiusura ufficiale della sessione