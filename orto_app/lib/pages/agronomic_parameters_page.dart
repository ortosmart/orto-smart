import 'package:flutter/material.dart';

import '../core/write_authority/agronomic_parameter_write_result.dart';
import '../data/models/agronomic_parameter.dart';
import '../data/models/catalog_capabilities.dart';
import '../data/models/measurement_unit.dart';
import '../data/repositories/agronomic_parameter_repository.dart';
import '../data/repositories/measurement_unit_repository.dart';

class AgronomicParametersPage extends StatefulWidget {
  final CatalogCapabilities capabilities;
  final AgronomicParameterRepository? repository;
  final MeasurementUnitRepository? measurementUnitRepository;

  const AgronomicParametersPage({
    super.key,
    required this.capabilities,
    this.repository,
    this.measurementUnitRepository,
  });

  @override
  State<AgronomicParametersPage> createState() =>
      _AgronomicParametersPageState();
}

class _AgronomicParametersPageState extends State<AgronomicParametersPage> {
  late final AgronomicParameterRepository _repository;
  late Future<List<AgronomicParameter>> _parametersFuture;

  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AgronomicParameterRepository();
    _parametersFuture = _loadParameters();
  }

  Future<List<AgronomicParameter>> _loadParameters() {
    return _repository.getAgronomicParameters(activeOnly: !_showInactive);
  }

  void _reload() {
    setState(() {
      _parametersFuture = _loadParameters();
    });
  }

  Future<void> _openEditor({AgronomicParameter? parameter}) async {
    if (!widget.capabilities.canManageIdentity) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AgronomicParameterEditorDialog(
        parameter: parameter,
        repository: _repository,
        measurementUnitRepository: widget.measurementUnitRepository,
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _reload();
    }
  }

  Future<void> _setParameterActive(AgronomicParameter parameter) async {
    if (!widget.capabilities.canManageIdentity) return;

    final action = parameter.isActive ? 'disattivare' : 'attivare';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          parameter.isActive ? 'Disattiva parametro' : 'Attiva parametro',
        ),
        content: Text('Vuoi $action il parametro "${parameter.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      final result = await _repository.setAgronomicParameterActive(
        agronomicParameterId: parameter.id,
        expectedRowVersion: parameter.rowVersion,
        isActive: !parameter.isActive,
      );

      if (!mounted) return;

      if (result is AgronomicParameterActiveChanged ||
          result is SetAgronomicParameterActiveUnchanged) {
        _reload();
        return;
      }

      final message = switch (result) {
        SetAgronomicParameterActiveVersionConflict() =>
          'Il parametro è stato modificato altrove. Ricarica i dati.',
        SetAgronomicParameterActiveForbidden() => 'Operazione non autorizzata.',
        SetAgronomicParameterActiveInvalidInput() => 'Dati non validi.',
        SetAgronomicParameterActiveNotFound() => 'Parametro non trovato.',
        SetAgronomicParameterActiveDependents() =>
          'Impossibile disattivare il parametro: esistono dipendenze attive.',
        SetAgronomicParameterActiveDependencyInactive() =>
          'Impossibile attivare il parametro: una dipendenza è disattivata.',
        _ => 'Impossibile modificare lo stato del parametro.',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Errore durante l’operazione. Verifica la connessione e riprova.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.capabilities.canManageIdentity;

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Nuovo parametro'),
            )
          : null,
      appBar: AppBar(
        title: const Text('Parametri agronomici'),
        actions: [
          IconButton(
            tooltip: 'Ricarica',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<AgronomicParameter>>(
        future: _parametersFuture,
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
                    'Errore durante il caricamento dei parametri agronomici.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          final parameters = snapshot.data ?? const <AgronomicParameter>[];

          return Column(
            children: [
              SwitchListTile(
                title: const Text('Mostra parametri disattivati'),
                value: _showInactive,
                onChanged: (value) {
                  setState(() {
                    _showInactive = value;
                    _parametersFuture = _loadParameters();
                  });
                },
              ),
              Expanded(
                child: parameters.isEmpty
                    ? const Center(
                        child: Text('Nessun parametro agronomico trovato.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: parameters.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final parameter = parameters[index];

                          return ListTile(
                            leading: Icon(
                              parameter.isActive
                                  ? Icons.tune
                                  : Icons.do_not_disturb_on_outlined,
                            ),
                            title: Text(parameter.name),
                            trailing: canManage
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Modifica parametro',
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () =>
                                            _openEditor(parameter: parameter),
                                      ),
                                      IconButton(
                                        tooltip: parameter.isActive
                                            ? 'Disattiva parametro'
                                            : 'Attiva parametro',
                                        icon: Icon(
                                          parameter.isActive
                                              ? Icons.block_outlined
                                              : Icons.check_circle_outline,
                                        ),
                                        onPressed: () =>
                                            _setParameterActive(parameter),
                                      ),
                                    ],
                                  )
                                : null,
                            subtitle: Text(
                              '${parameter.code} · '
                              '${parameter.valueSchema} · '
                              '${parameter.knowledgeScope}'
                              '${parameter.isActive ? '' : '\nDisattivato'}',
                            ),
                            isThreeLine: !parameter.isActive,
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

class _AgronomicParameterEditorDialog extends StatefulWidget {
  final AgronomicParameter? parameter;
  final AgronomicParameterRepository repository;
  final MeasurementUnitRepository? measurementUnitRepository;

  const _AgronomicParameterEditorDialog({
    required this.parameter,
    required this.repository,
    this.measurementUnitRepository,
  });

  @override
  State<_AgronomicParameterEditorDialog> createState() =>
      _AgronomicParameterEditorDialogState();
}

class _AgronomicParameterEditorDialogState
    extends State<_AgronomicParameterEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _saveError;
  late final MeasurementUnitRepository _unitRepository;
  late final Future<List<MeasurementUnit>> _unitsFuture;

  String? _quantityKind;
  String? _canonicalUnitId;

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _valueSchema;
  late String _knowledgeScope;

  late bool _allowsCrop;
  late bool _allowsCultivar;
  late bool _allowsProductionContext;
  late bool _allowsProtectionContext;
  late bool _allowsTrainingContext;
  late bool _allowsHarvestPurpose;

  @override
  void initState() {
    super.initState();

    final parameter = widget.parameter;
    _unitRepository =
        widget.measurementUnitRepository ?? MeasurementUnitRepository();
    _unitsFuture = _unitRepository.getMeasurementUnits(activeOnly: false);

    _quantityKind = parameter?.quantityKind;
    _canonicalUnitId = parameter?.canonicalUnitId;

    _codeController = TextEditingController(text: parameter?.code ?? '');
    _nameController = TextEditingController(text: parameter?.name ?? '');
    _descriptionController = TextEditingController(
      text: parameter?.description ?? '',
    );
    _valueSchema = parameter?.valueSchema ?? 'BOOLEAN';
    _knowledgeScope = parameter?.knowledgeScope ?? 'INTRINSIC';

    _allowsCrop = parameter?.allowsCrop ?? true;
    _allowsCultivar = parameter?.allowsCultivar ?? false;

    _allowsProductionContext = parameter?.allowsProductionContext ?? false;
    _allowsProtectionContext = parameter?.allowsProtectionContext ?? false;
    _allowsTrainingContext = parameter?.allowsTrainingContext ?? false;
    _allowsHarvestPurpose = parameter?.allowsHarvestPurpose ?? false;
  }

  Future<void> _saveParameter() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final validationError = _validateParameter();

    if (validationError != null) {
      setState(() {
        _saveError = validationError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      if (widget.parameter == null) {
        final result = await widget.repository.createAgronomicParameter(
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          valueSchema: _valueSchema,
          knowledgeScope: _knowledgeScope,
          quantityKind: _isNumericSchema ? _quantityKind : null,
          canonicalUnitId: _isNumericSchema ? _canonicalUnitId : null,
          allowsCrop: _allowsCrop,
          allowsCultivar: _allowsCultivar,
          allowsProductionContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsProductionContext,
          allowsProtectionContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsProtectionContext,
          allowsTrainingContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsTrainingContext,
          allowsHarvestPurpose:
              _knowledgeScope == 'CONTEXTUAL' && _allowsHarvestPurpose,
        );

        if (!mounted) return;

        if (result is AgronomicParameterCreated) {
          Navigator.of(context).pop(true);
          return;
        }

        setState(() {
          _saveError = switch (result) {
            CreateAgronomicParameterForbidden() =>
              'Operazione non autorizzata.',
            CreateAgronomicParameterInvalidInput() =>
              'Dati non validi. Verifica i campi.',
            CreateAgronomicParameterDuplicateCode() =>
              'Esiste già un parametro con questo codice.',
            CreateAgronomicParameterUnitNotFound() =>
              'Unità canonica non trovata.',
            CreateAgronomicParameterDependencyInactive() =>
              'Una dipendenza del parametro è disattivata.',
            _ => 'Impossibile creare il parametro.',
          };
        });
      } else {
        final parameter = widget.parameter!;

        final result = await widget.repository.updateAgronomicParameter(
          agronomicParameterId: parameter.id,
          expectedRowVersion: parameter.rowVersion,
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          valueSchema: _valueSchema,
          knowledgeScope: _knowledgeScope,
          quantityKind: _isNumericSchema ? _quantityKind : null,
          canonicalUnitId: _isNumericSchema ? _canonicalUnitId : null,
          allowsCrop: _allowsCrop,
          allowsCultivar: _allowsCultivar,
          allowsProductionContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsProductionContext,
          allowsProtectionContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsProtectionContext,
          allowsTrainingContext:
              _knowledgeScope == 'CONTEXTUAL' && _allowsTrainingContext,
          allowsHarvestPurpose:
              _knowledgeScope == 'CONTEXTUAL' && _allowsHarvestPurpose,
        );

        if (!mounted) return;

        if (result is AgronomicParameterUpdated ||
            result is UpdateAgronomicParameterUnchanged) {
          Navigator.of(context).pop(true);
          return;
        }

        setState(() {
          _saveError = switch (result) {
            UpdateAgronomicParameterVersionConflict() =>
              'Il parametro è stato modificato altrove. '
                  'Chiudi e ricarica i dati.',
            UpdateAgronomicParameterForbidden() =>
              'Operazione non autorizzata.',
            UpdateAgronomicParameterInvalidInput() =>
              'Dati non validi. Verifica i campi.',
            UpdateAgronomicParameterNotFound() => 'Parametro non trovato.',
            UpdateAgronomicParameterUnitNotFound() =>
              'Unità canonica non trovata.',
            UpdateAgronomicParameterDependencyInactive() =>
              'Una dipendenza del parametro è disattivata.',
            UpdateAgronomicParameterSemanticsFrozen() =>
              'Le caratteristiche semantiche di questo parametro '
                  'non possono più essere modificate.',
            UpdateAgronomicParameterEnumValuesExist() =>
              'Non è possibile modificare la tipologia: '
                  'sono già presenti valori enumerati.',
            UpdateAgronomicParameterDuplicateCode() =>
              'Esiste già un parametro con questo codice.',
            _ => 'Impossibile aggiornare il parametro.',
          };
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saveError =
            'Errore durante il salvataggio. '
            'Verifica la connessione e riprova.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateParameter() {
    if (!_allowsCrop && !_allowsCultivar) {
      return 'Seleziona almeno un livello: coltura o varietà.';
    }

    if (_isNumericSchema) {
      if (_quantityKind == null || _quantityKind!.trim().isEmpty) {
        return 'Seleziona la grandezza fisica.';
      }

      if (_canonicalUnitId == null) {
        return 'Seleziona l’unità canonica.';
      }
    }

    if (_knowledgeScope == 'CONTEXTUAL') {
      if (!_allowsProductionContext &&
          !_allowsProtectionContext &&
          !_allowsTrainingContext &&
          !_allowsHarvestPurpose) {
        return 'Seleziona almeno un contesto di applicazione.';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNumericSchema =>
      _valueSchema == 'NUMERIC_SCALAR' || _valueSchema == 'NUMERIC_RANGE';
  List<String> _availableQuantityKinds(List<MeasurementUnit> units) {
    final kinds = units
        .where((unit) => unit.isActive)
        .map((unit) => unit.quantityKind)
        .toSet();

    if (_quantityKind != null) {
      kinds.add(_quantityKind!);
    }

    return kinds.toList()..sort();
  }

  List<MeasurementUnit> _compatibleUnits(List<MeasurementUnit> units) {
    if (_quantityKind == null) {
      return [];
    }

    return units.where((unit) {
      if (unit.quantityKind != _quantityKind) {
        return false;
      }

      return unit.isActive || unit.id == _canonicalUnitId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.parameter == null
            ? 'Nuovo parametro agronomico'
            : 'Modifica parametro agronomico',
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isNumericSchema)
                  FutureBuilder<List<MeasurementUnit>>(
                    future: _unitsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LinearProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Impossibile caricare le unità di misura.',
                        );
                      }

                      final units = snapshot.data ?? <MeasurementUnit>[];
                      final kinds = _availableQuantityKinds(units);

                      return DropdownButtonFormField<String>(
                        key: ValueKey('quantity-kind-$_quantityKind'),
                        initialValue: _quantityKind,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Grandezza fisica',
                        ),
                        items: kinds
                            .map(
                              (kind) => DropdownMenuItem(
                                value: kind,
                                child: Text(kind),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (_quantityKind != value) {
                              _quantityKind = value;
                              _canonicalUnitId = null;
                            }
                          });
                        },
                      );
                    },
                  ),
                if (_isNumericSchema && _quantityKind != null)
                  FutureBuilder<List<MeasurementUnit>>(
                    future: _unitsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LinearProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Impossibile caricare le unità canoniche.',
                        );
                      }

                      final units = _compatibleUnits(
                        snapshot.data ?? <MeasurementUnit>[],
                      );

                      final selectedId =
                          units.any((unit) => unit.id == _canonicalUnitId)
                          ? _canonicalUnitId
                          : null;

                      return DropdownButtonFormField<String>(
                        key: ValueKey(
                          'canonical-unit-$_quantityKind-$selectedId',
                        ),
                        initialValue: selectedId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Unità canonica',
                        ),
                        items: units.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit.id,
                            enabled: unit.isActive,
                            child: Text(
                              '${unit.name} (${unit.symbol})'
                              '${unit.isActive ? '' : ' — disattivata'}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _canonicalUnitId = value;
                          });
                        },
                      );
                    },
                  ),
                DropdownButtonFormField<String>(
                  initialValue: _valueSchema,
                  decoration: const InputDecoration(
                    labelText: 'Tipologia del valore',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'NUMERIC_SCALAR',
                      child: Text('Numerico singolo'),
                    ),
                    DropdownMenuItem(
                      value: 'NUMERIC_RANGE',
                      child: Text('Intervallo numerico'),
                    ),
                    DropdownMenuItem(value: 'BOOLEAN', child: Text('Sì / No')),
                    DropdownMenuItem(
                      value: 'ENUM',
                      child: Text('Valore da elenco'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _valueSchema = value;

                      if (!_isNumericSchema) {
                        _quantityKind = null;
                        _canonicalUnitId = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Applicabile alle colture'),
                  value: _allowsCrop,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _allowsCrop = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Applicabile alle varietà'),
                  value: _allowsCultivar,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _allowsCultivar = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_knowledgeScope == 'CONTEXTUAL') ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contesti agronomici applicabili',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Contesto produttivo'),
                    value: _allowsProductionContext,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _allowsProductionContext = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Contesto di protezione'),
                    value: _allowsProtectionContext,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _allowsProtectionContext = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Contesto di allevamento'),
                    value: _allowsTrainingContext,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _allowsTrainingContext = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Destinazione del raccolto'),
                    value: _allowsHarvestPurpose,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _allowsHarvestPurpose = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _knowledgeScope,
                  decoration: const InputDecoration(
                    labelText: 'Ambito della conoscenza',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'INTRINSIC',
                      child: Text('Intrinseco'),
                    ),
                    DropdownMenuItem(
                      value: 'CONTEXTUAL',
                      child: Text('Contestuale'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _knowledgeScope = value;
                      if (value == 'INTRINSIC') {
                        _allowsProductionContext = false;
                        _allowsProtectionContext = false;
                        _allowsTrainingContext = false;
                        _allowsHarvestPurpose = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Codice parametro',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il codice';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome parametro',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione (facoltativa)',
                  ),
                  maxLines: 3,
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _saveError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Chiudi'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveParameter,
          child: _isSaving
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
