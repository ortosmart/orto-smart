import 'package:flutter/material.dart';

import '../core/date/civil_date.dart';
import '../core/write_authority/bed_write_result.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../data/repositories/bed_repository.dart';

class CreateBedPage extends StatefulWidget {
  final String profileId;
  final String gardenId;
  final BedRepository repository;
  final ProfileWriteAuthorityController authority;

  const CreateBedPage({
    super.key,
    required this.profileId,
    required this.gardenId,
    required this.repository,
    required this.authority,
  });

  @override
  State<CreateBedPage> createState() => _CreateBedPageState();
}

class _CreateBedPageState extends State<CreateBedPage> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  final _width = TextEditingController();
  final _length = TextEditingController();
  final _validFrom = TextEditingController();

  bool _saving = false;
  bool _outcomeUnknown = false;
  String? _message;

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _notes.dispose();
    _width.dispose();
    _length.dispose();
    _validFrom.dispose();
    super.dispose();
  }

  String? _positiveInteger(String? text) {
    final value = int.tryParse((text ?? '').trim());

    if (value == null || value <= 0 || value > 2147483647) {
      return 'Inserisci un intero positivo, massimo 2147483647.';
    }

    return null;
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_saving || _outcomeUnknown) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authority = widget.authority;

    try {
      final lease = authority.requireLeaseForWrite();

      if (lease.profileId != widget.profileId) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
    } on ProfileWriteAuthorityUnavailableException {
      setState(() {
        _message =
            'Autorità di scrittura non disponibile per questo profilo. '
            'I dati inseriti sono conservati.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      final result = await widget.repository.createBed(
        gardenId: widget.gardenId,
        number: int.parse(_number.text.trim()),
        name: _optionalText(_name),
        notes: _optionalText(_notes),
        widthCm: int.parse(_width.text.trim()),
        lengthCm: int.parse(_length.text.trim()),
        validFrom: _validFrom.text.trim().isEmpty
            ? null
            : CivilDate.parseItalian(_validFrom.text)!,
      );

      if (!mounted) {
        return;
      }

      if (result is BedCreated) {
        if (result.gardenId != widget.gardenId) {
          throw const BedWriteProtocolException();
        }

        setState(() {
          _saving = false;
        });
        Navigator.of(context).pop(true);
        return;
      }

      final message = switch (result) {
        CreateBedDuplicateNumber() =>
          'Questo numero è già utilizzato nell’orto, '
              'anche eventualmente da un’aiuola disabilitata.',
        CreateBedForbidden() =>
          'Non sei autorizzato a creare aiuole in questo orto.',
        CreateBedWriteForbidden() =>
          'Il server non ha autorizzato la scrittura. '
              'Verifica l’autorità prima di riprovare.',
        CreateBedNotFound() => 'L’orto non è disponibile per questo profilo.',
        CreateBedInvalidInput() =>
          'Il server ha rifiutato i dati. Controlla i valori inseriti.',
        BedCreated() => throw StateError('Unexpected creation result'),
      };

      setState(() {
        _message = message;
      });
    } on ProfileWriteAuthorityUnavailableException {
      if (!mounted) {
        return;
      }

      setState(() {
        _message =
            'L’autorità di scrittura non è più disponibile. '
            'I dati inseriti sono conservati.';
      });
    } on Object {
      if (!mounted) {
        return;
      }

      setState(() {
        _outcomeUnknown = true;
        _message =
            'Non è stato possibile confermare l’esito della creazione. '
            'Torna alla lista e aggiornala per verificare se l’aiuola '
            'è stata creata prima di effettuare un nuovo tentativo.';
      });
    } finally {
      if (mounted && _saving) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _integerField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: _positiveInteger,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authority,
      builder: (context, child) {
        final canWrite = widget.authority.canWrite;
        final canSubmit = canWrite && !_saving && !_outcomeUnknown;

        return PopScope(
          canPop: !_saving,
          child: Scaffold(
            appBar: AppBar(title: const Text('Crea aiuola')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!canWrite) ...[
                      const Text(
                        'Scrittura non disponibile. '
                        'Puoi compilare i dati, ma non salvarli.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    AbsorbPointer(
                      absorbing: _saving,
                      child: Column(
                        children: [
                          _integerField(
                            controller: _number,
                            label: 'Numero aiuola',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'Nome (facoltativo)',
                            ),
                            validator: (value) {
                              final normalized = (value ?? '')
                                  .trim()
                                  .replaceAll(RegExp(r'\s+'), ' ');

                              if (normalized.runes.length > 80) {
                                return 'Il nome può contenere al massimo '
                                    '80 caratteri.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _integerField(
                            controller: _width,
                            label: 'Larghezza (cm)',
                          ),
                          const SizedBox(height: 12),
                          _integerField(
                            controller: _length,
                            label: 'Lunghezza (cm)',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _validFrom,
                            decoration: const InputDecoration(
                              labelText: 'Geometria valida dal',
                              helperText:
                                  'Vuoto = oggi nel fuso dell’orto.\n'
                                  'Altrimenti GG/MM/AAAA; non sono ammesse '
                                  'date future.',
                              helperMaxLines: 3,
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();

                              if (text.isEmpty) {
                                return null;
                              }

                              if (CivilDate.parseItalian(text) == null) {
                                return 'Inserisci una data valida: GG/MM/AAAA.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notes,
                            decoration: const InputDecoration(
                              labelText: 'Note (facoltative)',
                            ),
                            minLines: 2,
                            maxLines: 4,
                            validator: (value) {
                              if ((value ?? '').trim().runes.length > 1000) {
                                return 'Le note possono contenere al massimo '
                                    '1000 caratteri.';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      Text(_message!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: canSubmit ? _save : null,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Salvataggio…' : 'Crea aiuola'),
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
