import 'package:flutter/material.dart';

import '../core/write_authority/bed_write_result.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../data/models/bed.dart';
import '../data/repositories/bed_repository.dart';

class EditBedPage extends StatefulWidget {
  final Bed bed;
  final BedRepository repository;
  final ProfileWriteAuthorityController authority;

  const EditBedPage({
    super.key,
    required this.bed,
    required this.repository,
    required this.authority,
  });

  @override
  State<EditBedPage> createState() => _EditBedPageState();
}

class _EditBedPageState extends State<EditBedPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _notes;

  bool _saving = false;
  bool _outcomeUnknown = false;
  String? _message;

  @override
  void initState() {
    super.initState();

    _number = TextEditingController(text: widget.bed.number.toString());
    _name = TextEditingController(text: widget.bed.name ?? '');
    _notes = TextEditingController(text: widget.bed.notes ?? '');
  }

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _notes.dispose();
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

    try {
      widget.authority.requireLeaseForWrite();
    } on ProfileWriteAuthorityUnavailableException {
      setState(() {
        _message =
            'Autorità di scrittura non disponibile. '
            'I dati inseriti sono conservati.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      final result = await widget.repository.updateBed(
        bedId: widget.bed.id,
        expectedRowVersion: widget.bed.rowVersion,
        number: int.parse(_number.text.trim()),
        name: _optionalText(_name),
        notes: _optionalText(_notes),
      );

      if (!mounted) {
        return;
      }

      if (result is BedUpdated || result is UpdateBedUnchanged) {
        Navigator.of(context).pop(true);
        return;
      }

      final message = switch (result) {
        UpdateBedVersionConflict() =>
          'L’aiuola è stata modificata da un’altra sessione. '
              'Torna indietro e aggiorna i dati prima di riprovare.',
        UpdateBedDuplicateNumber() =>
          'Questo numero è già utilizzato nell’orto.',
        UpdateBedForbidden() =>
          'Non sei autorizzato a modificare questa aiuola.',
        UpdateBedWriteForbidden() =>
          'Il server non ha autorizzato la scrittura.',
        UpdateBedNotFound() => 'L’aiuola non è più disponibile.',
        UpdateBedInvalidInput() =>
          'Il server ha rifiutato i dati. Controlla i valori inseriti.',
        BedUpdated() ||
        UpdateBedUnchanged() => throw StateError('Unexpected update result'),
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
            'Non è stato possibile confermare l’esito della modifica. '
            'Torna alla pagina precedente e aggiorna l’aiuola '
            'prima di effettuare un nuovo tentativo.';
      });
    } finally {
      if (mounted && _saving) {
        setState(() {
          _saving = false;
        });
      }
    }
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
            appBar: AppBar(title: const Text('Modifica aiuola')),
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
                        'Puoi modificare i dati, ma non salvarli.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _number,
                      decoration: const InputDecoration(
                        labelText: 'Numero aiuola',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveInteger,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nome (facoltativo)',
                      ),
                      validator: (value) {
                        final normalized = (value ?? '').trim().replaceAll(
                          RegExp(r'\s+'),
                          ' ',
                        );

                        if (normalized.runes.length > 80) {
                          return 'Il nome può contenere al massimo '
                              '80 caratteri.';
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
                      label: Text(_saving ? 'Salvataggio…' : 'Salva modifiche'),
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
