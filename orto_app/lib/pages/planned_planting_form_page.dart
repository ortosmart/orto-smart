import 'package:flutter/material.dart';

import '../data/models/bed.dart';
import '../data/models/crop.dart';
import '../data/models/crop_cultivar.dart';
import '../data/models/planned_planting.dart';
import '../data/models/season.dart';

typedef PlannedPlantingFormData = ({
  String bedId,
  String cropId,
  String? cultivarId,
  String startMethod,
  DateTime startDate,
  DateTime? endDate,
  int startPositionCm,
  int lengthCm,
  int occupiedWidthCm,
  int? plantSpacingCm,
  int? rowSpacingCm,
  int? rowsCount,
  int? plantsCount,
  double? seedQuantityG,
  String? notes,
});

class PlannedPlantingFormPage extends StatefulWidget {
  const PlannedPlantingFormPage({
    super.key,
    required this.season,
    required this.beds,
    required this.crops,
    required this.cultivars,
    this.planting,
  });

  final Season season;
  final List<Bed> beds;
  final List<Crop> crops;
  final List<CropCultivar> cultivars;
  final PlannedPlanting? planting;

  @override
  State<PlannedPlantingFormPage> createState() =>
      _PlannedPlantingFormPageState();
}

class _PlannedPlantingFormPageState extends State<PlannedPlantingFormPage> {
  static const _methods = {
    'purchased_seedlings': 'Piantine acquistate',
    'nursery_then_transplant': 'Semina in vivaio e trapianto',
    'direct_rows': 'Semina diretta in file',
    'direct_broadcast': 'Semina diretta a spaglio',
  };

  final _form = GlobalKey<FormState>();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _values = <String, String>{};

  String? _bedId;
  String? _cropId;
  String? _cultivarId;
  String? _method;

  @override
  void initState() {
    super.initState();
    final planting = widget.planting;
    _bedId = planting?.bedId;
    _cropId = planting?.cropId;
    _cultivarId = planting?.cultivarId;
    _method = planting?.startMethod;
    _start.text = _dateText(
      planting?.plannedStartDate ?? widget.season.startDate,
    );
    _end.text = _dateText(planting?.plannedEndDate);
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  static String _dateText(DateTime? date) {
    if (date == null) return '';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime? _parseDate(String value) {
    final text = value.trim();
    final date = DateTime.tryParse(text);
    return date != null && _dateText(date) == text ? date : null;
  }

  String? _validateDate(String? value, {required bool isEnd}) {
    final text = value?.trim() ?? '';
    if (isEnd && text.isEmpty) return null;

    final date = _parseDate(text);
    if (date == null) return 'Inserisci una data valida (AAAA-MM-GG).';

    final first = DateUtils.dateOnly(widget.season.startDate);
    final seasonEnd = widget.season.endDate;
    final last = seasonEnd == null ? null : DateUtils.dateOnly(seasonEnd);
    if (date.isBefore(first) || (last != null && date.isAfter(last))) {
      return 'La data deve rientrare nella stagione.';
    }

    final start = _parseDate(_start.text);
    if (isEnd && start != null && date.isBefore(start)) {
      return 'La fine deve essere uguale o successiva all’inizio.';
    }
    return null;
  }

  Widget _integerField(
    String key,
    String label,
    int? initial, {
    int minimum = 1,
    bool required = false,
  }) {
    return TextFormField(
      initialValue: initial?.toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty && !required) return null;
        final number = int.tryParse(text);
        return number == null || number < minimum
            ? 'Inserisci un intero maggiore o uguale a $minimum.'
            : null;
      },
      onSaved: (value) => _values[key] = value?.trim() ?? '',
    );
  }

  Widget _requiredChoice({
    required String label,
    required String? selected,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: options.containsKey(selected) ? selected : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in options.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleziona un valore.' : null,
    );
  }

  void _save() {
    final form = _form.currentState!;
    if (!form.validate()) return;
    form.save();

    int? optionalInt(String key) => int.tryParse(_values[key] ?? '');
    final notes = _values['notes'];
    final data = (
      bedId: _bedId!,
      cropId: _cropId!,
      cultivarId: _cultivarId,
      startMethod: _method!,
      startDate: _parseDate(_start.text)!,
      endDate: _parseDate(_end.text),
      startPositionCm: optionalInt('position')!,
      lengthCm: optionalInt('length')!,
      occupiedWidthCm: optionalInt('width')!,
      plantSpacingCm: optionalInt('plantSpacing'),
      rowSpacingCm: optionalInt('rowSpacing'),
      rowsCount: optionalInt('rows'),
      plantsCount: optionalInt('plants'),
      seedQuantityG: double.tryParse(_values['seed'] ?? ''),
      notes: notes == null || notes.isEmpty ? null : notes,
    );
    Navigator.of(context).pop<PlannedPlantingFormData>(data);
  }

  @override
  Widget build(BuildContext context) {
    final planting = widget.planting;
    final beds = {
      for (final bed in widget.beds)
        if (bed.isActive || bed.id == planting?.bedId)
          bed.id: bed.name == null ? bed.code : '${bed.code} · ${bed.name}',
    };
    final crops = {
      for (final crop in widget.crops)
        if (crop.isActive || crop.id == planting?.cropId) crop.id: crop.name,
    };
    final cultivars = {
      for (final cultivar in widget.cultivars)
        if (cultivar.cropId == _cropId &&
            (cultivar.isActive || cultivar.id == planting?.cultivarId))
          cultivar.id: cultivar.name,
    };
    final selectedCultivarAvailable =
        _cultivarId == null || cultivars.containsKey(_cultivarId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          planting == null ? 'Nuova pianificazione' : 'Modifica pianificazione',
        ),
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _requiredChoice(
                label: 'Aiuola',
                selected: _bedId,
                options: beds,
                onChanged: (value) => setState(() => _bedId = value),
              ),
              _requiredChoice(
                label: 'Coltura',
                selected: _cropId,
                options: crops,
                onChanged: (value) {
                  setState(() {
                    if (_cropId != value) _cultivarId = null;
                    _cropId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                key: ValueKey(_cropId),
                initialValue: selectedCultivarAvailable
                    ? (_cultivarId ?? '')
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cultivar'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Nessuna')),
                  for (final entry in cultivars.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: _cropId == null
                    ? null
                    : (value) => setState(
                        () => _cultivarId = value == '' ? null : value,
                      ),
                validator: (_) => selectedCultivarAvailable
                    ? null
                    : 'Cultivar salvata indisponibile. Seleziona una voce.',
              ),
              _requiredChoice(
                label: 'Metodo di avvio',
                selected: _method,
                options: _methods,
                onChanged: (value) => setState(() => _method = value),
              ),
              TextFormField(
                controller: _start,
                decoration: const InputDecoration(
                  labelText: 'Data di inizio (AAAA-MM-GG)',
                ),
                validator: (value) => _validateDate(value, isEnd: false),
              ),
              TextFormField(
                controller: _end,
                decoration: const InputDecoration(
                  labelText: 'Data di fine facoltativa (AAAA-MM-GG)',
                ),
                validator: (value) => _validateDate(value, isEnd: true),
              ),
              _integerField(
                'position',
                'Posizione iniziale (cm)',
                planting?.startPositionCm ?? 0,
                minimum: 0,
                required: true,
              ),
              _integerField(
                'length',
                'Lunghezza (cm)',
                planting?.lengthCm,
                required: true,
              ),
              _integerField(
                'width',
                'Larghezza occupata (cm)',
                planting?.occupiedWidthCm,
                required: true,
              ),
              _integerField(
                'plantSpacing',
                'Distanza tra piante (cm)',
                planting?.plantSpacingCm,
              ),
              _integerField(
                'rowSpacing',
                'Distanza tra file (cm)',
                planting?.rowSpacingCm,
              ),
              _integerField('rows', 'Numero di file', planting?.rowsCount),
              _integerField(
                'plants',
                'Numero di piante',
                planting?.plantsCount,
              ),
              TextFormField(
                initialValue: planting?.seedQuantityG?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Quantità di seme (g)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final number = double.tryParse(text.replaceAll(',', '.'));
                  return number == null || !number.isFinite || number <= 0
                      ? 'Inserisci una quantità positiva.'
                      : null;
                },
                onSaved: (value) => _values['seed'] = (value?.trim() ?? '')
                    .replaceAll(',', '.'),
              ),
              TextFormField(
                initialValue: planting?.notes,
                maxLength: 1000,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note'),
                onSaved: (value) => _values['notes'] = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: const Text('Salva')),
            ],
          ),
        ),
      ),
    );
  }
}
