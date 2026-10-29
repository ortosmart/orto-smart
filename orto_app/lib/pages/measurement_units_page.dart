import 'package:flutter/material.dart';

import '../core/write_authority/measurement_unit_write_result.dart';
import '../data/models/catalog_capabilities.dart';
import '../data/models/measurement_unit.dart';
import '../data/repositories/measurement_unit_repository.dart';

class MeasurementUnitsPage extends StatefulWidget {
  final CatalogCapabilities capabilities;
  final MeasurementUnitRepository? repository;

  const MeasurementUnitsPage({
    super.key,
    required this.capabilities,
    this.repository,
  });

  @override
  State<MeasurementUnitsPage> createState() => _MeasurementUnitsPageState();
}

class _MeasurementUnitsPageState extends State<MeasurementUnitsPage> {
  late final MeasurementUnitRepository _repository;
  late Future<List<MeasurementUnit>> _unitsFuture;

  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MeasurementUnitRepository();
    _unitsFuture = _loadUnits();
  }

  Future<List<MeasurementUnit>> _loadUnits() {
    return _repository.getMeasurementUnits(activeOnly: !_showInactive);
  }

  void _reload() {
    setState(() {
      _unitsFuture = _loadUnits();
    });
  }

  Future<void> _openEditor({MeasurementUnit? unit}) async {
    if (!widget.capabilities.canManageIdentity) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _MeasurementUnitEditorDialog(unit: unit, repository: _repository),
    );

    if (result == true && mounted) {
      _reload();
    }
  }

  Future<void> _toggleActive(MeasurementUnit unit) async {
    if (!widget.capabilities.canManageIdentity) return;

    final action = unit.isActive ? 'disattivare' : 'attivare';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma $action unità'),
        content: Text('Vuoi $action l’unità "${unit.name}" (${unit.code})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await _repository.setMeasurementUnitActive(
        measurementUnitId: unit.id,
        expectedRowVersion: unit.rowVersion,
        isActive: !unit.isActive,
      );

      if (!mounted) return;

      final message = switch (result) {
        MeasurementUnitActiveChanged() => 'Stato dell’unità aggiornato.',
        SetMeasurementUnitActiveUnchanged() =>
          'L’unità è già nello stato richiesto.',
        SetMeasurementUnitActiveVersionConflict() =>
          'L’unità è stata modificata da un’altra operazione. Ricarica i dati.',
        SetMeasurementUnitActiveForbidden() =>
          'Non sei autorizzato a modificare questa unità.',
        SetMeasurementUnitActiveInvalidInput() => 'La richiesta non è valida.',
        SetMeasurementUnitActiveNotFound() => 'L’unità non è più disponibile.',
        SetMeasurementUnitActiveDependents() =>
          'L’unità ha record dipendenti e non può essere disattivata.',
      };

      _showMessage(message);
      _reload();
    } catch (_) {
      if (mounted) {
        _showMessage('Errore durante l’aggiornamento dell’unità.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.capabilities.canManageIdentity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unità di misura'),
        actions: [
          IconButton(
            tooltip: 'Ricarica',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Nuova unità'),
            )
          : null,
      body: FutureBuilder<List<MeasurementUnit>>(
        future: _unitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _LoadError(onRetry: _reload);
          }

          final units = snapshot.data ?? const <MeasurementUnit>[];

          return Column(
            children: [
              SwitchListTile(
                title: const Text('Mostra unità disattivate'),
                value: _showInactive,
                onChanged: (value) {
                  setState(() {
                    _showInactive = value;
                    _unitsFuture = _loadUnits();
                  });
                },
              ),
              Expanded(
                child: units.isEmpty
                    ? const Center(
                        child: Text('Nessuna unità di misura trovata.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: units.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final unit = units[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              unit.isActive
                                  ? Icons.straighten
                                  : Icons.do_not_disturb_on_outlined,
                            ),
                            title: Text('${unit.name} (${unit.symbol})'),
                            subtitle: Text(
                              '${unit.code} · ${unit.quantityKind}\n'
                              'Fattore: ${unit.toBaseFactor} · '
                              'Offset: ${unit.toBaseOffset}'
                              '${unit.isActive ? '' : '\nDisattivata'}',
                            ),
                            isThreeLine: !unit.isActive,
                            trailing: PopupMenuButton<String>(
                              enabled: canManage,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _openEditor(unit: unit);
                                } else if (action == 'toggle') {
                                  _toggleActive(unit);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Modifica'),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(
                                    unit.isActive ? 'Disattiva' : 'Attiva',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeasurementUnitEditorDialog extends StatefulWidget {
  final MeasurementUnit? unit;
  final MeasurementUnitRepository repository;

  const _MeasurementUnitEditorDialog({
    required this.unit,
    required this.repository,
  });

  @override
  State<_MeasurementUnitEditorDialog> createState() =>
      _MeasurementUnitEditorDialogState();
}

class _MeasurementUnitEditorDialogState
    extends State<_MeasurementUnitEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _quantityKindController;
  late final TextEditingController _factorController;
  late final TextEditingController _offsetController;
  late final TextEditingController _descriptionController;

  bool _saving = false;

  bool get _editing => widget.unit != null;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;

    _codeController = TextEditingController(text: unit?.code ?? '');
    _nameController = TextEditingController(text: unit?.name ?? '');
    _symbolController = TextEditingController(text: unit?.symbol ?? '');
    _quantityKindController = TextEditingController(
      text: unit?.quantityKind ?? '',
    );
    _factorController = TextEditingController(
      text: unit?.toBaseFactor.toString() ?? '1',
    );
    _offsetController = TextEditingController(
      text: unit?.toBaseOffset.toString() ?? '0',
    );
    _descriptionController = TextEditingController(
      text: unit?.description ?? '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _quantityKindController.dispose();
    _factorController.dispose();
    _offsetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label, int maxLength) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Inserisci $label.';
    if (text.length > maxLength) return 'Massimo $maxLength caratteri.';

    return null;
  }

  String? _validateCode(String? value) {
    final error = _requiredText(value, 'il codice', 50);
    if (error != null) return error;

    if (!RegExp(r'^[A-Z][A-Z0-9_]{0,49}$').hasMatch(value!.trim())) {
      return 'Usa lettere maiuscole, numeri e underscore.';
    }

    return null;
  }

  String? _validateQuantityKind(String? value) {
    final error = _requiredText(value, 'la dimensione fisica', 80);
    if (error != null) return error;

    if (!RegExp(r'^[A-Z][A-Z0-9_]{0,79}$').hasMatch(value!.trim())) {
      return 'Usa lettere maiuscole, numeri e underscore.';
    }

    return null;
  }

  String? _validateNumber(
    String? value, {
    required String label,
    required bool positive,
  }) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    final number = num.tryParse(text);

    if (number == null || !number.isFinite) {
      return 'Inserisci un numero valido per $label.';
    }

    if (positive && number <= 0) {
      return '$label deve essere maggiore di zero.';
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final unit = widget.unit;
    final factor = num.parse(
      _factorController.text.trim().replaceAll(',', '.'),
    );
    final offset = num.parse(
      _offsetController.text.trim().replaceAll(',', '.'),
    );
    final description = _descriptionController.text.trim();

    try {
      final result = unit == null
          ? await widget.repository.createMeasurementUnit(
              code: _codeController.text.trim(),
              name: _nameController.text.trim(),
              symbol: _symbolController.text.trim(),
              quantityKind: _quantityKindController.text.trim(),
              toBaseFactor: factor,
              toBaseOffset: offset,
              description: description.isEmpty ? null : description,
            )
          : await widget.repository.updateMeasurementUnit(
              measurementUnitId: unit.id,
              expectedRowVersion: unit.rowVersion,
              code: _codeController.text.trim(),
              name: _nameController.text.trim(),
              symbol: _symbolController.text.trim(),
              quantityKind: _quantityKindController.text.trim(),
              toBaseFactor: factor,
              toBaseOffset: offset,
              description: description.isEmpty ? null : description,
            );

      if (!mounted) return;

      final message = switch (result) {
        MeasurementUnitCreated() => 'Unità di misura creata.',
        CreateMeasurementUnitForbidden() || UpdateMeasurementUnitForbidden() =>
          'Non sei autorizzato a eseguire questa operazione.',
        CreateMeasurementUnitInvalidInput() ||
        UpdateMeasurementUnitInvalidInput() =>
          'I dati inseriti non sono validi.',
        CreateMeasurementUnitDuplicateCode() ||
        UpdateMeasurementUnitDuplicateCode() => 'Il codice è già utilizzato.',
        MeasurementUnitUpdated() => 'Unità di misura aggiornata.',
        UpdateMeasurementUnitUnchanged() => 'Nessuna modifica da salvare.',
        UpdateMeasurementUnitVersionConflict() =>
          'L’unità è stata modificata. Ricarica i dati prima di riprovare.',
        UpdateMeasurementUnitNotFound() => 'L’unità non è più disponibile.',
        UpdateMeasurementUnitSemanticsFrozen() =>
          'Le proprietà semantiche non sono modificabili perché già utilizzate.',
        UpdateMeasurementUnitInUse() =>
          'L’unità è utilizzata da altri record e non può essere modificata.',
        _ => 'Risposta non riconosciuta dal server.',
      };

      final succeeded =
          result is MeasurementUnitCreated ||
          result is MeasurementUnitUpdated ||
          result is UpdateMeasurementUnitUnchanged;

      if (!succeeded) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Errore durante il salvataggio dell’unità.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _editing ? 'Modifica unità di misura' : 'Nuova unità di misura',
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  enabled: !_editing,
                  decoration: const InputDecoration(
                    labelText: 'Codice',
                    helperText: 'Codice tecnico stabile, in maiuscolo.',
                  ),
                  validator: _validateCode,
                ),
                TextFormField(
                  controller: _nameController,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) => _requiredText(value, 'il nome', 120),
                ),
                TextFormField(
                  controller: _symbolController,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Simbolo'),
                  validator: (value) => _requiredText(value, 'il simbolo', 30),
                ),
                TextFormField(
                  controller: _quantityKindController,
                  enabled: !_editing,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Dimensione fisica',
                    helperText: 'Ad esempio TIME, MASS o LENGTH.',
                  ),
                  validator: _validateQuantityKind,
                ),
                TextFormField(
                  controller: _factorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Fattore di conversione verso la base',
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    label: 'il fattore',
                    positive: true,
                  ),
                ),
                TextFormField(
                  controller: _offsetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Offset di conversione',
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    label: 'l’offset',
                    positive: false,
                  ),
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione facoltativa',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.length > 1000) {
                      return 'Massimo 1000 caratteri.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Errore durante il caricamento delle unità di misura.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
