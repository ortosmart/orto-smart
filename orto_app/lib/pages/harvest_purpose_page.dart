import 'package:flutter/material.dart';

import '../core/write_authority/harvest_purpose_write_result.dart';
import '../data/models/catalog_capabilities.dart';
import '../data/models/harvest_purpose.dart';
import '../data/repositories/harvest_purpose_repository.dart';

class HarvestPurposePage extends StatefulWidget {
  final CatalogCapabilities capabilities;
  final HarvestPurposeRepository? repository;

  const HarvestPurposePage({
    super.key,
    required this.capabilities,
    this.repository,
  });

  @override
  State<HarvestPurposePage> createState() => _HarvestPurposePageState();
}

class _HarvestPurposePageState extends State<HarvestPurposePage> {
  late final HarvestPurposeRepository _repository;
  late Future<List<HarvestPurpose>> _purposesFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HarvestPurposeRepository();
    _reload();
  }

  void _reload() {
    _purposesFuture = _repository.getHarvestPurposes(activeOnly: false);
  }

  void _refresh() {
    setState(_reload);
  }

  Future<void> _openCreateDialog() async {
    if (!widget.capabilities.canManageIdentity) return;

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateHarvestPurposeDialog(repository: _repository),
    );

    if (created == true && mounted) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finalità di raccolta creata.')),
      );
    }
  }

  Future<void> _openEditDialog(HarvestPurpose purpose) async {
    if (!widget.capabilities.canManageIdentity) return;

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditHarvestPurposeDialog(
        repository: _repository,
        purpose: purpose,
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finalità di raccolta modificata.')),
      );
    }
  }

  Future<void> _setPurposeActive(HarvestPurpose purpose) async {
    if (!widget.capabilities.canManageIdentity) return;

    try {
      final result = await _repository.setHarvestPurposeActive(
        harvestPurposeId: purpose.id,
        expectedRowVersion: purpose.rowVersion,
        isActive: !purpose.isActive,
      );

      if (!mounted) return;

      String? message;
      var refresh = false;

      switch (result) {
        case HarvestPurposeActiveChanged():
          message = result.isActive
              ? 'Finalità di raccolta attivata.'
              : 'Finalità di raccolta disattivata.';
          refresh = true;
        case SetHarvestPurposeActiveUnchanged():
          message = 'Nessuna modifica necessaria.';
          refresh = true;
        case SetHarvestPurposeActiveVersionConflict():
          message =
              'La finalità è stata modificata altrove. Aggiornare l’elenco.';
        case SetHarvestPurposeActiveForbidden():
          message = 'Operazione non autorizzata.';
        case SetHarvestPurposeActiveInvalidInput():
          message = 'I dati dell’operazione non sono validi.';
        case SetHarvestPurposeActiveNotFound():
          message = 'La finalità non è più disponibile. Aggiornare l’elenco.';
        case SetHarvestPurposeActiveDependents():
          message =
              'Impossibile disattivare la finalità: esistono elementi dipendenti.';
      }

      if (refresh) {
        _refresh();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Errore durante l’aggiornamento dello stato. Verificare e riprovare.',
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalità di raccolta'),
        actions: [
          if (widget.capabilities.canManageIdentity)
            IconButton(
              tooltip: 'Nuova finalità',
              icon: const Icon(Icons.add),
              onPressed: _openCreateDialog,
            ),
          IconButton(
            tooltip: 'Aggiorna elenco',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<HarvestPurpose>>(
        future: _purposesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Errore durante il caricamento delle finalità di raccolta.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _refresh,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          final purposes = snapshot.data!;

          if (purposes.isEmpty) {
            return const Center(
              child: Text('Nessuna finalità di raccolta presente.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: purposes.length,
            itemBuilder: (context, index) {
              final purpose = purposes[index];

              return Card(
                child: ListTile(
                  title: Text(purpose.name),
                  trailing: widget.capabilities.canManageIdentity
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Modifica finalità',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openEditDialog(purpose),
                            ),
                            IconButton(
                              tooltip: purpose.isActive
                                  ? 'Disattiva finalità'
                                  : 'Attiva finalità',
                              icon: Icon(
                                purpose.isActive
                                    ? Icons.toggle_on_outlined
                                    : Icons.toggle_off_outlined,
                              ),
                              onPressed: () => _setPurposeActive(purpose),
                            ),
                          ],
                        )
                      : null,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Codice: ${purpose.code}'),
                      if (purpose.description != null)
                        Text(purpose.description!),
                      Text(purpose.isActive ? 'Attiva' : 'Non attiva'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateHarvestPurposeDialog extends StatefulWidget {
  final HarvestPurposeRepository repository;

  const _CreateHarvestPurposeDialog({required this.repository});

  @override
  State<_CreateHarvestPurposeDialog> createState() =>
      _CreateHarvestPurposeDialogState();
}

class _CreateHarvestPurposeDialogState
    extends State<_CreateHarvestPurposeDialog> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      setState(() {
        _errorMessage = 'Codice e nome sono obbligatori.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.createHarvestPurpose(
        code: code,
        name: name,
        description: description.isEmpty ? null : description,
      );

      if (!mounted) return;

      switch (result) {
        case HarvestPurposeCreated():
          Navigator.of(context).pop(true);
          return;
        case CreateHarvestPurposeDuplicateCode():
          _errorMessage = 'Il codice è già utilizzato.';
        case CreateHarvestPurposeInvalidInput():
          _errorMessage = 'I dati inseriti non sono validi.';
        case CreateHarvestPurposeForbidden():
          _errorMessage = 'Operazione non autorizzata.';
      }
    } catch (_) {
      if (!mounted) return;
      _errorMessage =
          'Errore durante la creazione. Verificare e riprovare.';
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova finalità di raccolta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeController,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Codice *'),
            ),
            TextField(
              controller: _nameController,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: _descriptionController,
              enabled: !_saving,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (_saving) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: const Text('Crea'),
        ),
      ],
    );
  }
}

class _EditHarvestPurposeDialog extends StatefulWidget {
  final HarvestPurposeRepository repository;
  final HarvestPurpose purpose;

  const _EditHarvestPurposeDialog({
    required this.repository,
    required this.purpose,
  });

  @override
  State<_EditHarvestPurposeDialog> createState() =>
      _EditHarvestPurposeDialogState();
}

class _EditHarvestPurposeDialogState
    extends State<_EditHarvestPurposeDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _saving = false;
  bool _versionConflict = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.purpose.name);
    _descriptionController = TextEditingController(
      text: widget.purpose.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || _versionConflict) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Il nome è obbligatorio.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.updateHarvestPurpose(
        harvestPurposeId: widget.purpose.id,
        expectedRowVersion: widget.purpose.rowVersion,
        name: name,
        description: description.isEmpty ? null : description,
      );

      if (!mounted) return;

      switch (result) {
        case HarvestPurposeUpdated():
          Navigator.of(context).pop(true);
          return;
        case UpdateHarvestPurposeUnchanged():
          Navigator.of(context).pop(false);
          return;
        case UpdateHarvestPurposeVersionConflict():
          setState(() {
            _versionConflict = true;
            _errorMessage =
                'I dati sono stati modificati altrove. '
                'Chiudere la finestra e aggiornare l’elenco.';
          });
          return;
        case UpdateHarvestPurposeForbidden():
          _errorMessage = 'Operazione non autorizzata.';
        case UpdateHarvestPurposeInvalidInput():
          _errorMessage = 'I dati inseriti non sono validi.';
        case UpdateHarvestPurposeNotFound():
          _errorMessage =
              'La finalità non è più disponibile. Aggiornare l’elenco.';
      }
    } catch (_) {
      if (!mounted) return;
      _errorMessage =
          'Errore durante la modifica. Verificare e riprovare.';
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica finalità di raccolta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Codice: ${widget.purpose.code}'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: _descriptionController,
              enabled: !_saving,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (_saving) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: (_saving || _versionConflict) ? null : _submit,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
