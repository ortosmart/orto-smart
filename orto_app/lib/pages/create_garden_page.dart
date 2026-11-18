import 'package:flutter/material.dart';

import '../core/write_authority/garden_write_result.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../data/repositories/garden_repository.dart';

class CreateGardenPage extends StatefulWidget {
  final String profileId;
  final GardenRepository repository;
  final ProfileWriteAuthorityController authority;

  const CreateGardenPage({
    super.key,
    required this.profileId,
    required this.repository,
    required this.authority,
  });

  @override
  State<CreateGardenPage> createState() => _CreateGardenPageState();
}

class _CreateGardenPageState extends State<CreateGardenPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _elevation = TextEditingController();
  final _timezone = TextEditingController(text: 'Europe/Rome');
  final _countryCode = TextEditingController(text: 'IT');
  final _municipality = TextEditingController();
  final _locality = TextEditingController();
  final _streetAddress = TextEditingController();

  bool _saving = false;
  bool _outcomeUnknown = false;
  String? _message;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _latitude,
      _longitude,
      _elevation,
      _timezone,
      _countryCode,
      _municipality,
      _locality,
      _streetAddress,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _requiredText(String? value, int maximum) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Campo obbligatorio.';
    if (text.length > maximum) {
      return 'Massimo $maximum caratteri.';
    }
    return null;
  }

  String? _optionalText(String? value, int maximum) {
    if ((value ?? '').trim().length > maximum) {
      return 'Massimo $maximum caratteri.';
    }
    return null;
  }

  String? _coordinate(String? value, double minimum, double maximum) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null || !number.isFinite) {
      return 'Inserisci un numero valido.';
    }
    if (number < minimum || number > maximum) {
      return 'Valore ammesso: $minimum / $maximum.';
    }
    return null;
  }

  String? _elevationValidator(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number < -100 || number > 5000) {
      return 'Inserisci un intero tra -100 e 5000.';
    }
    return null;
  }

  String? _countryValidator(String? value) {
    final code = (value ?? '').trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
      return 'Inserisci un codice paese di due lettere.';
    }
    return null;
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_saving || _outcomeUnknown) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      final lease = widget.authority.requireLeaseForWrite();
      if (lease.profileId != widget.profileId) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
    } on ProfileWriteAuthorityUnavailableException {
      setState(() {
        _message = 'Autorità di scrittura non disponibile per questo profilo.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      final result = await widget.repository.createGarden(
        profileId: widget.profileId,
        name: _name.text.trim(),
        description: _optionalValue(_description),
        latitude: double.parse(_latitude.text.trim()),
        longitude: double.parse(_longitude.text.trim()),
        elevationM: int.parse(_elevation.text.trim()),
        timezone: _timezone.text.trim(),
        countryCode: _countryCode.text.trim().toUpperCase(),
        municipality: _optionalValue(_municipality),
        locality: _optionalValue(_locality),
        streetAddress: _optionalValue(_streetAddress),
      );

      if (!mounted) return;

      switch (result) {
        case GardenCreated():
          Navigator.of(context).pop(true);
          return;
        case CreateGardenForbidden():
          _message = 'Operazione non autorizzata per questo profilo.';
        case CreateGardenWriteForbidden():
          _message = 'Autorità di scrittura non disponibile.';
        case CreateGardenInvalidInput():
          _message = 'Dati non validi. Controlla i campi inseriti.';
        case CreateGardenDuplicateName():
          _message = 'Esiste già un orto con questo nome.';
      }
    } on ProfileWriteAuthorityUnavailableException {
      if (mounted) {
        _message = 'Autorità di scrittura non disponibile.';
      }
    } on Object {
      if (mounted) {
        _outcomeUnknown = true;
        _message =
            'Non è stato possibile confermare l’esito della creazione. '
            'Torna all’elenco e aggiornalo prima di effettuare '
            'un nuovo tentativo.';
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authority,
      builder: (context, _) {
        final canWrite = widget.authority.canWrite;
        final canSubmit = canWrite && !_saving && !_outcomeUnknown;

        return PopScope(
          canPop: !_saving,
          child: Scaffold(
            appBar: AppBar(title: const Text('Crea orto')),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!canWrite) ...[
                      const Text(
                        'Creazione non disponibile: '
                        'autorità di scrittura non attiva.',
                      ),
                      const SizedBox(height: 12),
                    ],
                    AbsorbPointer(
                      absorbing: _saving,
                      child: Column(
                        children: [
                          _field(
                            _name,
                            'Nome orto *',
                            validator: (v) => _requiredText(v, 40),
                          ),
                          _field(
                            _description,
                            'Descrizione',
                            maxLines: 3,
                            validator: (v) => _optionalText(v, 500),
                          ),
                          _field(
                            _latitude,
                            'Latitudine *',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (v) => _coordinate(v, -90, 90),
                          ),
                          _field(
                            _longitude,
                            'Longitudine *',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (v) => _coordinate(v, -180, 180),
                          ),
                          _field(
                            _elevation,
                            'Altitudine (m) *',
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                            ),
                            validator: _elevationValidator,
                          ),
                          _field(
                            _timezone,
                            'Fuso orario IANA *',
                            validator: (v) => _requiredText(v, 100),
                          ),
                          _field(
                            _countryCode,
                            'Codice paese *',
                            validator: _countryValidator,
                          ),
                          _field(
                            _municipality,
                            'Comune',
                            validator: (v) => _optionalText(v, 100),
                          ),
                          _field(
                            _locality,
                            'Località',
                            validator: (v) => _optionalText(v, 100),
                          ),
                          _field(
                            _streetAddress,
                            'Indirizzo',
                            validator: (v) => _optionalText(v, 150),
                          ),
                        ],
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 8),
                      Text(_message!),
                      const SizedBox(height: 12),
                    ],
                    FilledButton.icon(
                      onPressed: canSubmit ? _save : null,
                      icon: const Icon(Icons.add),
                      label: Text(
                        _saving ? 'Creazione in corso...' : 'Crea orto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
