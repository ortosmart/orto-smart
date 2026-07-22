import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models/bed.dart';
import '../data/models/bed_analysis_result.dart';
import '../data/models/crop.dart';
import '../data/models/planting.dart';
import '../data/models/rotation_result.dart';
import '../data/models/association_result.dart';
import '../data/models/crop_association.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/crop_association_repository.dart';
import '../data/repositories/planting_repository.dart';
import '../data/repositories/season_repository.dart';
import '../services/agronomic_engine.dart';
import '../services/bed_analyzer.dart';
import '../services/rotation_engine.dart';
import '../services/association_engine.dart';
import '../widgets/bed_preview_widget.dart';
import '../data/models/suggestion_result.dart';

enum _PositionMode { automatic, manual }

class AddPlantingPage extends StatefulWidget {
  final Bed bed;
  final Planting? planting;
  final CropSuggestion? suggestion;

  const AddPlantingPage({
    super.key,
    required this.bed,
    this.planting,
    this.suggestion,
  });

  bool get isEditing => planting != null;

  bool get isUsingSuggestion =>
      planting == null && suggestion != null;

  @override
  State<AddPlantingPage> createState() => _AddPlantingPageState();
}

class _AddPlantingPageState extends State<AddPlantingPage> {
  static const int _bedLengthCm = 700;
  static const int _bedWidthCm = 90;

  final _formKey = GlobalKey<FormState>();

  final _plantsCountController = TextEditingController();
  final _plantSpacingController = TextEditingController();
  final _rowSpacingController = TextEditingController();
  final _startPositionController = TextEditingController();
  final _manualLengthController = TextEditingController();
  final _occupiedWidthController = TextEditingController();
  final _seedQuantityController = TextEditingController();
  final _notesController = TextEditingController();

  final CropRepository _cropRepository = CropRepository();
  final CropAssociationRepository _associationRepository = CropAssociationRepository();
  final SeasonRepository _seasonRepository = SeasonRepository();
  final PlantingRepository _plantingRepository = PlantingRepository();

  late Future<List<Crop>> _cropsFuture;

  List<Planting> _existingPlantings = const [];
  Map<String, String> _cropNamesById = const {};
  Map<String, Crop> _cropsById = const {};

  Crop? _selectedCrop;
  RotationResult? _rotationResult;
  AssociationResult? _associationResult;
  List<CropAssociation> _associations = const [];
  String _plantingMethod = 'transplant';
  String? _saveError;
  String? _existingPlantingsError;

  DateTime _sowingDate = DateTime.now();

  bool _isSaving = false;
  bool _loadingCropDefaults = false;
  bool _isLoadingExistingPlantings = true;
  bool _isApplyingAutomaticPosition = false;
  _PositionMode _positionMode = _PositionMode.automatic;

  bool get _isAutomaticPosition =>
      _positionMode == _PositionMode.automatic;

  bool get _isEditing => widget.isEditing;

  Planting? get _editingPlanting => widget.planting;
  CropSuggestion? get _suggestion => widget.suggestion;

  @override
  void initState() {
    super.initState();

    _initializeEditingValues();
    _cropsFuture = _loadCrops();
    _loadExistingPlantings();
    _loadAssociations();

    _plantsCountController.addListener(_refreshCalculations);
    _plantSpacingController.addListener(_refreshCalculations);
    _rowSpacingController.addListener(_refreshCalculations);
    _startPositionController.addListener(_refreshPositionCalculations);
    _manualLengthController.addListener(_refreshCalculations);
    _occupiedWidthController.addListener(_refreshCalculations);
    _seedQuantityController.addListener(_refreshCalculations);
  }

  void _initializeEditingValues() {
  final planting = _editingPlanting;

  if (planting != null) {
    _plantingMethod = planting.plantingMethod;
    _sowingDate = planting.sowingDate;
    _positionMode = _PositionMode.manual;

    _startPositionController.text =
        planting.startPositionCm.toString();

    _manualLengthController.text =
        planting.lengthCm.toString();

    _plantsCountController.text =
        planting.plantsCount?.toString() ?? '';

    _plantSpacingController.text =
        planting.plantSpacingCm?.toString() ?? '';

    _rowSpacingController.text =
        planting.rowSpacingCm?.toString() ?? '';

    _occupiedWidthController.text =
        planting.occupiedWidthCm?.toString() ?? '';

    _seedQuantityController.text =
        planting.seedQuantityGrams?.toString() ?? '';

    _notesController.text = planting.notes ?? '';

    return;
  }

  final suggestion = _suggestion;

  if (suggestion == null) {
    return;
  }

  _positionMode = _PositionMode.manual;

  _startPositionController.text =
      suggestion.startPositionCm.toString();

  _manualLengthController.text =
      suggestion.lengthCm.toString();

  _plantsCountController.text =
      suggestion.plantsCount.toString();
}

  @override
  void dispose() {
    _plantsCountController.removeListener(_refreshCalculations);
    _plantSpacingController.removeListener(_refreshCalculations);
    _rowSpacingController.removeListener(_refreshCalculations);
    _startPositionController.removeListener(_refreshPositionCalculations);
    _manualLengthController.removeListener(_refreshCalculations);
    _occupiedWidthController.removeListener(_refreshCalculations);
    _seedQuantityController.removeListener(_refreshCalculations);

    _plantsCountController.dispose();
    _plantSpacingController.dispose();
    _rowSpacingController.dispose();
    _startPositionController.dispose();
    _manualLengthController.dispose();
    _occupiedWidthController.dispose();
    _seedQuantityController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<List<Crop>> _loadCrops() async {
  final crops = await _cropRepository.getCrops();

  final requestedCropId =
      _editingPlanting?.cropId ?? _suggestion?.crop.id;

  Crop? initialCrop;

  if (requestedCropId != null) {
    for (final crop in crops) {
      if (crop.id == requestedCropId) {
        initialCrop = crop;
        break;
      }
    }
  }

  if (mounted) {
    setState(() {
      _cropNamesById = {
        for (final crop in crops) crop.id: crop.name,
      };

      _cropsById = {
        for (final crop in crops) crop.id: crop,
      };

      _selectedCrop = initialCrop;

      if (widget.isUsingSuggestion && initialCrop != null) {
        _plantingMethod =
            _normalizePlantingMethod(initialCrop.sowingMethod);

        if (_plantSpacingController.text.isEmpty) {
          _plantSpacingController.text =
              initialCrop.plantSpacingCm?.toString() ?? '';
        }

        if (_rowSpacingController.text.isEmpty) {
          _rowSpacingController.text =
              initialCrop.rowSpacingCm?.toString() ?? '';
        }
      }
    });
  }

  _evaluateRotation();
  _evaluateAssociation();

  return crops;
}

  Future<void> _loadExistingPlantings() async {
    try {
      final plantings = await _plantingRepository.getPlantingsByBed(
        widget.bed.id,
      );

      if (!mounted) {
        return;
      }

      final editingId = _editingPlanting?.id;
      final otherPlantings = editingId == null
          ? plantings
          : plantings
              .where((planting) => planting.id != editingId)
              .toList();

      setState(() {
        _existingPlantings = otherPlantings;
        _existingPlantingsError = null;
        _isLoadingExistingPlantings = false;
      });

      _applyAutomaticPositionIfPossible();
      _evaluateRotation();
    } catch (error, stackTrace) {
      debugPrint(
        'Errore durante il caricamento delle colture esistenti: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _existingPlantings = const [];
        _existingPlantingsError = error.toString();
        _isLoadingExistingPlantings = false;
      });
    }
  }

Future<void> _loadAssociations() async {
  try {
    final associations =
        await _associationRepository.getAllAssociations();

    if (!mounted) {
      return;
    }

    setState(() {
      _associations = associations;
    });

    _evaluateAssociation();
  } catch (e, stackTrace) {
    debugPrint('Errore caricamento consociazioni: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

void _evaluateAssociation() {
  final selectedCrop = _selectedCrop;

  if (!mounted) {
    return;
  }

  if (selectedCrop == null ||
      _isLoadingExistingPlantings ||
      _existingPlantingsError != null ||
      _cropsById.isEmpty) {
    if (_associationResult != null) {
      setState(() {
        _associationResult = null;
      });
    }

    return;
  }

  final result = AssociationEngine.evaluate(
    candidateCrop: selectedCrop,
    existingPlantings: _existingPlantings,
    associations: _associations,
    cropsById: _cropsById,
  );

  setState(() {
    _associationResult = result;
  });
}

  void _evaluateRotation() {
    final selectedCrop = _selectedCrop;

    if (!mounted) {
      return;
    }

    if (selectedCrop == null ||
        _isLoadingExistingPlantings ||
        _existingPlantingsError != null ||
        _cropsById.isEmpty) {
      if (_rotationResult != null) {
        setState(() {
          _rotationResult = null;
        });
      }
      return;
    }

    final result = RotationEngine.evaluate(
      candidateCrop: selectedCrop,
      history: _existingPlantings,
      cropsById: _cropsById,
      referenceDate: _sowingDate,
    );

    setState(() {
      _rotationResult = result;
    });
  }

  void _refreshCalculations() {
    if (!mounted ||
        _loadingCropDefaults ||
        _isApplyingAutomaticPosition) {
      return;
    }

    setState(() {
      _saveError = null;
    });

    _applyAutomaticPositionIfPossible();
  }

  void _refreshPositionCalculations() {
    if (!mounted || _isApplyingAutomaticPosition) {
      return;
    }

    setState(() {
      _saveError = null;
    });
  }

  void _applyAutomaticPositionIfPossible() {
    if (!mounted ||
        _isApplyingAutomaticPosition ||
        !_isAutomaticPosition ||
        _isLoadingExistingPlantings ||
        _existingPlantingsError != null ||
        _calculatedLengthCm <= 0) {
      return;
    }

    final analysis = _bedAnalysis;

    if (analysis == null) {
      return;
    }

    final bestSpace = _findBestSpace(analysis);

    if (bestSpace == null) {
      return;
    }

    final suggestedPosition =
        bestSpace.startCm.round().toString();

    if (_startPositionController.text == suggestedPosition) {
      return;
    }

    _isApplyingAutomaticPosition = true;
    _startPositionController.value = TextEditingValue(
      text: suggestedPosition,
      selection: TextSelection.collapsed(
        offset: suggestedPosition.length,
      ),
    );
    _isApplyingAutomaticPosition = false;

    setState(() {
      _saveError = null;
    });
  }

  void _handleStartPositionChanged(String value) {
    if (!mounted || _isApplyingAutomaticPosition) {
      return;
    }

    final isEmpty = value.trim().isEmpty;

    setState(() {
      _positionMode = isEmpty
          ? _PositionMode.automatic
          : _PositionMode.manual;
      _saveError = null;
    });

    if (isEmpty) {
      _applyAutomaticPositionIfPossible();
    }
  }

  void _enableAutomaticPosition() {
    if (_isSaving) {
      return;
    }

    setState(() {
      _positionMode = _PositionMode.automatic;
      _saveError = null;
    });

    _applyAutomaticPositionIfPossible();
  }

  Widget _buildPositionModeCard(BuildContext context) {
    final theme = Theme.of(context);
    final isAutomatic = _isAutomaticPosition;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isAutomatic
                  ? Icons.auto_awesome_outlined
                  : Icons.pan_tool_alt_outlined,
              color: isAutomatic
                  ? theme.colorScheme.primary
                  : theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAutomatic
                        ? 'Posizionamento automatico'
                        : 'Posizionamento manuale',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAutomatic
                        ? 'Orto Smart usa il primo spazio disponibile '
                            'abbastanza grande per la nuova coltura.'
                        : 'La posizione scelta viene rispettata anche '
                            'se cambiano quantità o distanze.',
                  ),
                  if (!isAutomatic) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : _enableAutomaticPosition,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Torna al posizionamento automatico',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _parsePositiveInt(String value) {
    final parsedValue = int.tryParse(value.trim());

    if (parsedValue == null || parsedValue <= 0) {
      return null;
    }

    return parsedValue;
  }

  int _parseNonNegativeInt(String value) {
    final parsedValue = int.tryParse(value.trim());

    if (parsedValue == null || parsedValue < 0) {
      return 0;
    }

    return parsedValue;
  }

  double? _parsePositiveDouble(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    final parsedValue = double.tryParse(normalizedValue);

    if (parsedValue == null || parsedValue <= 0) {
      return null;
    }

    return parsedValue;
  }

  String _normalizePlantingMethod(String? sowingMethod) {
    final value = sowingMethod?.trim().toLowerCase() ?? '';

    if (value.contains('trapiant') ||
        value.contains('piantin') ||
        value == 'transplant') {
      return 'transplant';
    }

    if (value.contains('spaglio') ||
        value.contains('broadcast') ||
        value.contains('sparsa')) {
      return 'broadcast';
    }

    if (value.contains('fila') ||
        value.contains('row') ||
        value.contains('semin')) {
      return 'rows';
    }

    return 'transplant';
  }

  void _selectCrop(Crop? crop) {
    _loadingCropDefaults = true;

    _selectedCrop = crop;

    if (crop == null) {
      _plantSpacingController.clear();
      _rowSpacingController.clear();
      _plantingMethod = 'transplant';
    } else {
      _plantingMethod = _normalizePlantingMethod(crop.sowingMethod);

      _plantSpacingController.text =
          crop.plantSpacingCm?.toString() ?? '';

      _rowSpacingController.text =
          crop.rowSpacingCm?.toString() ?? '';
    }

    _loadingCropDefaults = false;

    setState(() {
      _saveError = null;
      _positionMode = _isEditing
          ? _PositionMode.manual
          : _PositionMode.automatic;
    });

    _applyAutomaticPositionIfPossible();
    _evaluateRotation();
    _evaluateAssociation();
  }

  bool get _usesPlantCount {
    return _plantingMethod == 'transplant' ||
        _plantingMethod == 'rows';
  }

  bool get _isBroadcast {
    return _plantingMethod == 'broadcast';
  }

  int get _startPositionCm {
    return _parseNonNegativeInt(_startPositionController.text);
  }

  int? get _plantsCount {
    return _parsePositiveInt(_plantsCountController.text);
  }

  int? get _plantSpacingCm {
    return _parsePositiveInt(_plantSpacingController.text);
  }

  int? get _rowSpacingCm {
    return _parsePositiveInt(_rowSpacingController.text);
  }

  int get _calculatedRowsCount {
    if (!_usesPlantCount) {
      return 1;
    }

    final rowSpacing = _rowSpacingCm;

    if (rowSpacing == null || rowSpacing <= 0) {
      return 1;
    }

    return math.max(
      1,
      ((_bedWidthCm - 1) ~/ rowSpacing) + 1,
    );
  }

  int get _plantsPerRow {
    final plantsCount = _plantsCount;

    if (plantsCount == null) {
      return 0;
    }

    return (plantsCount / _calculatedRowsCount).ceil();
  }

  int get _calculatedLengthCm {
    if (_isBroadcast || _plantingMethod == 'manual') {
      return _parsePositiveInt(_manualLengthController.text) ?? 0;
    }

    final plantsPerRow = _plantsPerRow;
    final plantSpacing = _plantSpacingCm;

    if (plantsPerRow <= 0 || plantSpacing == null) {
      return 0;
    }

    if (plantsPerRow == 1) {
      return plantSpacing;
    }

    return AgronomicEngine.calculateOccupiedLength(
      plants: plantsPerRow,
      spacingCm: plantSpacing.toDouble(),
    ).round();
  }

  int get _occupiedWidthCm {
    final manuallyEnteredWidth =
        _parsePositiveInt(_occupiedWidthController.text);

    if (_isBroadcast || _plantingMethod == 'manual') {
      return manuallyEnteredWidth ?? _bedWidthCm;
    }

    if (_calculatedRowsCount <= 1) {
      return math.min(
        _rowSpacingCm ?? _bedWidthCm,
        _bedWidthCm,
      );
    }

    final rowSpacing = _rowSpacingCm ?? 0;
    final calculatedWidth =
        ((_calculatedRowsCount - 1) * rowSpacing) + 1;

    return math.min(calculatedWidth, _bedWidthCm);
  }

  int get _endPositionCm {
    return _startPositionCm + _calculatedLengthCm;
  }

  int get _remainingLengthCm {
    return _bedLengthCm - _endPositionCm;
  }

  List<Planting> get _overlappingPlantings {
    if (_calculatedLengthCm <= 0) {
      return const [];
    }

    return _existingPlantings.where((planting) {
      final existingStartCm = planting.startPositionCm;
      final existingEndCm =
          planting.startPositionCm + planting.lengthCm;

      return _startPositionCm < existingEndCm &&
          _endPositionCm > existingStartCm;
    }).toList();
  }

  bool get _hasOverlap {
    return _overlappingPlantings.isNotEmpty;
  }

  bool get _fitsInsideBedBounds {
    return _calculatedLengthCm > 0 &&
        _startPositionCm >= 0 &&
        _endPositionCm <= _bedLengthCm &&
        _occupiedWidthCm <= _bedWidthCm;
  }

  bool get _fitsInBed {
    return _fitsInsideBedBounds && !_hasOverlap;
  }

  BedAnalysisResult? get _bedAnalysis {
    if (_isLoadingExistingPlantings ||
        _existingPlantingsError != null ||
        _calculatedLengthCm <= 0) {
      return null;
    }

    return BedAnalyzer.analyze(
      bedLengthCm: _bedLengthCm.toDouble(),
      requiredLengthCm: _calculatedLengthCm.toDouble(),
      plantings: _existingPlantings,
    );
  }

  dynamic _findBestSpace(BedAnalysisResult analysis) {
    final suitableSpaces = analysis.freeSpaces
        .where(
          (space) => space.lengthCm >= _calculatedLengthCm,
        )
        .toList();

    if (suitableSpaces.isEmpty) {
      return null;
    }

    suitableSpaces.sort((first, second) {
      final firstWaste =
          first.lengthCm - _calculatedLengthCm;
      final secondWaste =
          second.lengthCm - _calculatedLengthCm;

      final wasteComparison = firstWaste.compareTo(secondWaste);

      if (wasteComparison != 0) {
        return wasteComparison;
      }

      return first.startCm.compareTo(second.startCm);
    });

    return suitableSpaces.first;
  }

  double _remainingSpaceAfterInsertion(dynamic space) {
    return math.max(
      0,
      space.lengthCm - _calculatedLengthCm,
    ).toDouble();
  }

  String get _methodLabel {
    switch (_plantingMethod) {
      case 'transplant':
        return 'Trapianto';
      case 'rows':
        return 'Semina a file';
      case 'broadcast':
        return 'Semina a spaglio';
      case 'manual':
        return 'Inserimento manuale';
      default:
        return _plantingMethod;
    }
  }

  String _formatCentimeters(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  Future<void> _selectSowingDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _sowingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _sowingDate = selectedDate;
    });

    _evaluateRotation();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCrop == null) {
      setState(() {
        _saveError = 'Seleziona una coltura.';
      });
      return;
    }

    if (_calculatedLengthCm <= 0) {
      setState(() {
        _saveError =
            'La lunghezza occupata deve essere maggiore di zero.';
      });
      return;
    }

    if (!_fitsInsideBedBounds) {
      setState(() {
        _saveError =
            'La coltura supera i limiti dell’aiuola.';
      });
      return;
    }

    if (_hasOverlap) {
      final overlappingNames = _overlappingPlantings
          .map(
            (planting) =>
                _cropNamesById[planting.cropId] ?? 'coltura esistente',
          )
          .toSet()
          .join(', ');

      setState(() {
        _saveError =
            'La posizione scelta si sovrappone a: $overlappingNames. '
            'Sposta l’inizio dalla testata oppure usa la posizione '
            'consigliata.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final editingPlanting = _editingPlanting;
      final seasonId = editingPlanting?.seasonId ??
          (await _seasonRepository.getActiveSeason()).id;

      final notesText = _notesController.text.trim();

      final planting = Planting(
        id: editingPlanting?.id,
        seasonId: seasonId,
        bedId: widget.bed.id,
        cropId: _selectedCrop!.id,
        varietyId: editingPlanting?.varietyId,
        startPositionCm: _startPositionCm,
        lengthCm: _calculatedLengthCm,
        plantingMethod: _plantingMethod,
        plantSpacingCm:
            _usesPlantCount ? _plantSpacingCm : null,
        rowSpacingCm:
            _usesPlantCount ? _rowSpacingCm : null,
        rowsCount:
            _usesPlantCount ? _calculatedRowsCount : null,
        occupiedWidthCm: _occupiedWidthCm,
        seedQuantityGrams: _isBroadcast
            ? _parsePositiveDouble(_seedQuantityController.text)
            : null,
        sowingDate: _sowingDate,
        plantsCount: _usesPlantCount ? _plantsCount : null,
        status: editingPlanting?.status ?? 'growing',
        notes: notesText.isEmpty ? null : notesText,
      );

      if (_isEditing) {
        await _plantingRepository.updatePlanting(planting);
      } else {
        await _plantingRepository.addPlanting(planting);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('Errore durante il salvataggio: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _saveError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildRotationCard(BuildContext context) {
    final selectedCrop = _selectedCrop;
    final result = _rotationResult;
    final theme = Theme.of(context);

    if (selectedCrop == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                'Rotazione colturale',
                Icons.autorenew,
              ),
              const SizedBox(height: 12),
              const Text(
                'Seleziona una coltura per ricevere la valutazione '
                'della rotazione.',
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingExistingPlantings) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Valutazione della rotazione in corso...'),
              ),
            ],
          ),
        ),
      );
    }

    if (_existingPlantingsError != null || result == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'La valutazione della rotazione non è disponibile.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    late final IconData statusIcon;
    late final Color statusColor;
    late final String statusLabel;

    switch (result.rating) {
      case RotationRating.recommended:
        statusIcon = Icons.check_circle;
        statusColor = theme.colorScheme.primary;
        statusLabel = 'Consigliata';
        break;
      case RotationRating.acceptable:
        statusIcon = Icons.info;
        statusColor = theme.colorScheme.tertiary;
        statusLabel = 'Accettabile';
        break;
      case RotationRating.discouraged:
        statusIcon = Icons.warning_amber_rounded;
        statusColor = theme.colorScheme.error;
        statusLabel = 'Sconsigliata';
        break;
      case RotationRating.unknown:
        statusIcon = Icons.help_outline;
        statusColor = theme.colorScheme.outline;
        statusLabel = 'Dati insufficienti';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              'Rotazione colturale',
              Icons.autorenew,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${result.score}/100',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Famiglia botanica: '
              '${selectedCrop.botanicalFamily ?? 'non disponibile'}',
              style: theme.textTheme.bodySmall,
            ),
            if (result.requiredRotationSeasons != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rotazione consigliata: '
                '${result.requiredRotationSeasons} stagioni',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const Divider(height: 24),
            ...result.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildAssociationCard(BuildContext context) {
  final result = _associationResult;
  final theme = Theme.of(context);

  if (_selectedCrop == null) {
    return const SizedBox.shrink();
  }

  if (_isLoadingExistingPlantings) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Analisi delle consociazioni...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (result == null) {
    return const SizedBox.shrink();
  }

  IconData icon;
  Color color;
  String titolo;

  switch (result.rating) {
    case AssociationRating.excellent:
      icon = Icons.verified;
      color = Colors.green;
      titolo = 'Consociazione eccellente';
      break;

    case AssociationRating.good:
      icon = Icons.thumb_up;
      color = Colors.lightGreen;
      titolo = 'Consociazione buona';
      break;

    case AssociationRating.acceptable:
      icon = Icons.info;
      color = Colors.orange;
      titolo = 'Consociazione accettabile';
      break;

    case AssociationRating.poor:
      icon = Icons.warning_amber_rounded;
      color = Colors.deepOrange;
      titolo = 'Consociazione sfavorevole';
      break;

    case AssociationRating.incompatible:
      icon = Icons.cancel;
      color = theme.colorScheme.error;
      titolo = 'Colture incompatibili';
      break;

    case AssociationRating.unknown:
      icon = Icons.help_outline;
      color = theme.colorScheme.outline;
      titolo = 'Dati insufficienti';
      break;
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            'Consociazioni',
            Icons.groups_outlined,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titolo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${result.score}/100',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...result.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(reason),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSpaceSuggestionCard(BuildContext context) {
    if (_isLoadingExistingPlantings) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Calcolo degli spazi disponibili...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_existingPlantingsError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Impossibile analizzare gli spazi disponibili.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(_existingPlantingsError!),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoadingExistingPlantings = true;
                    _existingPlantingsError = null;
                  });

                  _loadExistingPlantings();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (_calculatedLengthCm <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                'Spazi disponibili',
                Icons.auto_awesome_outlined,
              ),
              const SizedBox(height: 12),
              const Text(
                'Inserisci i dati della coltura per ricevere '
                'un suggerimento automatico.',
              ),
            ],
          ),
        ),
      );
    }

    final analysis = _bedAnalysis;

    if (analysis == null) {
      return const SizedBox.shrink();
    }

    final bestSpace = _findBestSpace(analysis);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              'Spazi disponibili',
              Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: 8),
            Text(
              'Colture già presenti: ${_existingPlantings.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (analysis.freeSpaces.isEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Non risultano spazi liberi nell’aiuola.',
                    ),
                  ),
                ],
              )
            else
              ...analysis.freeSpaces.map(
                (freeSpace) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatCentimeters(freeSpace.startCm)} – '
                          '${_formatCentimeters(freeSpace.endCm)} cm',
                        ),
                      ),
                      Text(
                        '${_formatCentimeters(freeSpace.lengthCm)} cm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 24),
            if (bestSpace != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Miglior spazio: '
                      '${_formatCentimeters(bestSpace.startCm)} – '
                      '${_formatCentimeters(bestSpace.endCm)} cm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Scelto perché lascia soltanto '
                '${_formatCentimeters(
                  _remainingSpaceAfterInsertion(bestSpace),
                )} cm inutilizzati nello spazio disponibile.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                _isAutomaticPosition
                    ? 'La posizione migliore è stata applicata automaticamente.'
                    : 'Hai scelto manualmente la posizione.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      analysis.message ??
                          'Nessuno spazio è abbastanza grande '
                              'per questa coltura.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationCard(BuildContext context) {
    if (_calculatedLengthCm <= 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Inserisci i dati per visualizzare il calcolo.',
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              'Calcolo automatico',
              Icons.calculate_outlined,
            ),
            const SizedBox(height: 16),
            if (_usesPlantCount) ...[
              _CalculationRow(
                label: 'Numero di file',
                value: '$_calculatedRowsCount',
              ),
              _CalculationRow(
                label: 'Piante per fila',
                value: '$_plantsPerRow',
              ),
            ],
            _CalculationRow(
              label: 'Lunghezza occupata',
              value: '$_calculatedLengthCm cm',
            ),
            _CalculationRow(
              label: 'Larghezza occupata',
              value: '$_occupiedWidthCm cm',
            ),
            _CalculationRow(
              label: 'Posizione finale',
              value: '$_endPositionCm cm',
            ),
            _CalculationRow(
              label: 'Spazio libero successivo',
              value: _remainingLengthCm >= 0
                  ? '$_remainingLengthCm cm'
                  : 'superamento di ${-_remainingLengthCm} cm',
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  _fitsInBed
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  color: _fitsInBed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fitsInBed
                        ? 'La coltura entra correttamente nello spazio libero.'
                        : _hasOverlap
                            ? 'La coltura si sovrappone a una coltura già presente.'
                            : 'La coltura supera i limiti dell’aiuola.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _fitsInBed
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Modifica coltura - Aiuola ${widget.bed.number}'
              : 'Aggiungi coltura - Aiuola ${widget.bed.number}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.grid_view_outlined),
                  title: Text(widget.bed.code),
                  subtitle: const Text(
                    'Dimensioni: 90 × 700 cm',
                  ),
                ),
              ),

if (widget.isUsingSuggestion) ...[
  const SizedBox(height: 12),
  Card(
    child: ListTile(
      leading: const Icon(
        Icons.auto_awesome,
      ),
      title: const Text(
        'Suggerimento applicato',
      ),
      subtitle: Text(
        '${_suggestion!.crop.name} · '
        '${_suggestion!.score}/100\n'
        'Posizione ${_suggestion!.startPositionCm} cm · '
        '${_suggestion!.plantsCount} piante',
      ),
    ),
  ),
],              
              const SizedBox(height: 16),
              _buildSectionTitle(
                context,
                'Coltura',
                Icons.eco_outlined,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Crop>>(
                future: _cropsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(
                          'Errore nel caricamento delle colture:\n'
                          '${snapshot.error}',
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _cropsFuture = _loadCrops();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Riprova'),
                        ),
                      ],
                    );
                  }

                  final crops = snapshot.data ?? [];

                  if (crops.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nessuna coltura disponibile nella tabella crops.',
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCrop?.id,
                    decoration: const InputDecoration(
                      labelText: 'Coltura',
                      border: OutlineInputBorder(),
                    ),
                    items: crops.map((crop) {
                      return DropdownMenuItem<String>(
                        value: crop.id,
                        child: Text(crop.name),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (cropId) {
                            Crop? selectedCrop;

                            for (final crop in crops) {
                              if (crop.id == cropId) {
                                selectedCrop = crop;
                                break;
                              }
                            }

                            _selectCrop(selectedCrop);
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Seleziona una coltura';
                      }

                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildRotationCard(context),
              const SizedBox(height: 12),
              _buildAssociationCard(context),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _plantingMethod,
                decoration: const InputDecoration(
                  labelText: 'Metodo di coltivazione',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'transplant',
                    child: Text('Trapianto'),
                  ),
                  DropdownMenuItem(
                    value: 'rows',
                    child: Text('Semina a file'),
                  ),
                  DropdownMenuItem(
                    value: 'broadcast',
                    child: Text('Semina a spaglio'),
                  ),
                  DropdownMenuItem(
                    value: 'manual',
                    child: Text('Inserimento manuale'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _plantingMethod = value;
                          _saveError = null;
                          _positionMode = _isEditing
                              ? _PositionMode.manual
                              : _PositionMode.automatic;
                        });

                        _applyAutomaticPositionIfPossible();
                      },
              ),
              const SizedBox(height: 8),
              Text(
                'Metodo selezionato: $_methodLabel',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _isSaving ? null : _selectSowingDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_sowingDate)),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Posizione nell’aiuola',
                Icons.straighten,
              ),
              const SizedBox(height: 12),
              _buildPositionModeCard(context),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startPositionController,
                enabled: !_isSaving,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Inizio dalla testata',
                  suffixText: 'cm',
                  helperText: _isAutomaticPosition
                      ? 'Compilata dal motore agronomico'
                      : 'Modificata manualmente',
                  border: const OutlineInputBorder(),
                ),
                onChanged: _handleStartPositionChanged,
                validator: (value) {
                  final parsedValue =
                      int.tryParse(value?.trim() ?? '');

                  if (parsedValue == null || parsedValue < 0) {
                    return 'Inserisci una posizione valida';
                  }

                  if (parsedValue >= _bedLengthCm) {
                    return 'La posizione deve essere inferiore a 700 cm';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_usesPlantCount) ...[
                _buildSectionTitle(
                  context,
                  'Sesto di impianto',
                  Icons.apps_outlined,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plantsCountController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Numero di piante',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final plantsCount =
                        int.tryParse(value?.trim() ?? '');

                    if (plantsCount == null || plantsCount <= 0) {
                      return 'Inserisci il numero di piante';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _plantSpacingController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tra le piante',
                          suffixText: 'cm',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final spacing =
                              int.tryParse(value?.trim() ?? '');

                          if (spacing == null || spacing <= 0) {
                            return 'Dato non valido';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _rowSpacingController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tra le file',
                          suffixText: 'cm',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final spacing =
                              int.tryParse(value?.trim() ?? '');

                          if (spacing == null || spacing <= 0) {
                            return 'Dato non valido';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le distanze vengono proposte dalla coltura, '
                  'ma puoi modificarle liberamente.',
                ),
              ] else ...[
                _buildSectionTitle(
                  context,
                  'Area occupata',
                  Icons.crop_square,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _manualLengthController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Lunghezza occupata',
                    suffixText: 'cm',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final length =
                        int.tryParse(value?.trim() ?? '');

                    if (length == null || length <= 0) {
                      return 'Inserisci la lunghezza occupata';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _occupiedWidthController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Larghezza occupata',
                    suffixText: 'cm',
                    helperText:
                        'Lascia vuoto per utilizzare tutta la larghezza',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final width = int.tryParse(value.trim());

                    if (width == null ||
                        width <= 0 ||
                        width > _bedWidthCm) {
                      return 'Inserisci un valore tra 1 e 90 cm';
                    }

                    return null;
                  },
                ),
                if (_isBroadcast) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _seedQuantityController,
                    enabled: !_isSaving,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantità di seme',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }

                      if (_parsePositiveDouble(value) == null) {
                        return 'Inserisci una quantità valida';
                      }

                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
              _buildCalculationCard(context),
              const SizedBox(height: 12),
              _buildSpaceSuggestionCard(context),
              const SizedBox(height: 12),
              BedPreviewWidget(
                bedLengthCm: _bedLengthCm,
                existingPlantings: _existingPlantings,
                cropNamesById: _cropNamesById,
                newCropName: _selectedCrop?.name,
                newStartCm: _startPositionCm,
                newLengthCm: _calculatedLengthCm,
                newPlantingFits: _fitsInBed,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                enabled: !_isSaving,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (_saveError != null) ...[
                Card(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      'Errore durante il salvataggio:\n\n'
                      '$_saveError',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onErrorContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Salvataggio...'
                        : _isEditing
                            ? 'Salva modifiche'
                            : 'Salva coltura',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  final String label;
  final String value;

  const _CalculationRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}