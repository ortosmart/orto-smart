import 'package:flutter/material.dart';

import '../core/date/civil_date.dart';
import '../core/write_authority/bed_write_result.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../data/models/bed.dart';
import '../data/repositories/bed_repository.dart';

class ChangeBedGeometryPage extends StatefulWidget {
  final Bed bed;
  final BedRepository repository;
  final ProfileWriteAuthorityController authority;

  const ChangeBedGeometryPage({
    super.key,
    required this.bed,
    required this.repository,
    required this.authority,
  });

  @override
  State<ChangeBedGeometryPage> createState() => _ChangeBedGeometryPageState();
}

class _ChangeBedGeometryPageState extends State<ChangeBedGeometryPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _widthCm;
  late final TextEditingController _lengthCm;
  late final TextEditingController _validFrom;

  bool _saving = false;
  bool _outcomeUnknown = false;
  String? _message;

  @override
  void initState() {
    super.initState();

    _widthCm = TextEditingController(text: widget.bed.widthCm.toString());
    _lengthCm = TextEditingController(text: widget.bed.lengthCm.toString());
    _validFrom = TextEditingController(
      text: CivilDate.formatItalian(widget.bed.geometry.validFrom),
    );
  }

  @override
  void dispose() {
    _widthCm.dispose();
    _lengthCm.dispose();
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

  String? _validCivilDate(String? text) {
    if (CivilDate.parseItalian(text ?? '') == null) {
      return 'Inserisci una data valida: GG/MM/AAAA.';
    }

    return null;
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
      final result = await widget.repository.changeBedGeometry(
        bedId: widget.bed.id,
        expectedRowVersion: widget.bed.rowVersion,
        widthCm: int.parse(_widthCm.text.trim()),
        lengthCm: int.parse(_lengthCm.text.trim()),
        validFrom: CivilDate.parseItalian(_validFrom.text)!,
      );

      if (!mounted) {
        return;
      }

      if (result is BedGeometryChanged ||
          result is ChangeBedGeometryUnchanged) {
        Navigator.of(context).pop(true);
        return;
      }

      final message = switch (result) {
        BedGeometryCorrectionRequired() =>
          'La data indicata richiede una correzione della geometria '
              'storica. Torna indietro e usa la funzione di correzione.',
        ChangeBedGeometryVersionConflict() =>
          'L’aiuola è stata modificata da un’altra sessione. '
              'Torna indietro e aggiorna i dati prima di riprovare.',
        ChangeBedGeometryForbidden() =>
          'Non sei autorizzato a modificare la geometria di questa aiuola.',
        ChangeBedGeometryWriteForbidden() =>
          'Il server non ha autorizzato la scrittura.',
        ChangeBedGeometryNotFound() => 'L’aiuola non è più disponibile.',
        ChangeBedGeometryInvalidInput() =>
          'Il server ha rifiutato i dati. Controlla i valori inseriti.',
        BedGeometryChanged() || ChangeBedGeometryUnchanged() =>
          throw StateError('Unexpected geometry change result'),
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
            appBar: AppBar(title: const Text('Modifica geometria')),
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
                      controller: _widthCm,
                      decoration: const InputDecoration(
                        labelText: 'Larghezza (cm)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveInteger,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lengthCm,
                      decoration: const InputDecoration(
                        labelText: 'Lunghezza (cm)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveInteger,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _validFrom,
                      decoration: const InputDecoration(
                        labelText: 'Geometria valida dal',
                        helperText: 'GG/MM/AAAA',
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: _validCivilDate,
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
                      label: Text(
                        _saving ? 'Salvataggio…' : 'Salva nuova geometria',
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
