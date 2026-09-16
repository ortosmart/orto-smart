import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../core/write_authority/planting_write_result.dart';

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
import '../widgets/planting/position_mode_card.dart';
import '../widgets/planting/calculation_card.dart';
import '../widgets/planting/space_suggestion_card.dart';
import '../widgets/planting/rotation_card.dart';
import '../widgets/planting/association_card.dart';

enum _PositionMode { automatic, manual }

class AddPlantingPage extends StatefulWidget {
  final Bed bed;
  final Planting? planting;
  final CropSuggestion? suggestion;
  final PlantingRepository repository;
  final ProfileWriteAuthorityController authority;
  final CropRepository? cropRepository;
  final CropAssociationRepository? associationRepository;
  final SeasonRepository? seasonRepository;

  const AddPlantingPage({
    super.key,
    required this.bed,
    required this.repository,
    required this.authority,
    this.planting,
    this.suggestion,
    this.cropRepository,
    this.associationRepository,
    this.seasonRepository,
  });

  bool get isEditing => planting != null;

  bool get isUsingSuggestion => planting == null && suggestion != null;

  @override
  State<AddPlantingPage> createState() => _AddPlantingPageState();
}

class _AddPlantingPageState extends State<AddPlantingPage> {
  int get _bedLengthCm => widget.bed.lengthCm;
  int get _bedWidthCm => widget.bed.widthCm;
  final _formKey = GlobalKey<FormState>();

  final _plantsCountController = TextEditingController();
  final _plantSpacingController = TextEditingController();
  final _rowSpacingController = TextEditingController();
  final _rowsCountController = TextEditingController();
  final _startPositionController = TextEditingController();
  final _manualLengthController = TextEditingController();
  final _occupiedWidthController = TextEditingController();
  final _seedQuantityController = TextEditingController();
  final _notesController = TextEditingController();

  late final CropRepository _cropRepository;
  late final CropAssociationRepository _associationRepository;
  late final SeasonRepository _seasonRepository;

  late Future<List<Crop>> _cropsFuture;

  List<Planting> _existingPlantings = const [];
  Map<String, String> _cropNamesById = const {};
  Map<String, Crop> _cropsById = const {};

  Crop? _selectedCrop;
  RotationResult? _rotationResult;
  AssociationResult? _associationResult;
  List<CropAssociation> _associations = const [];
  String _startMethod = 'purchased_seedlings';
  String? _saveError;
  String? _existingPlantingsError;

  DateTime _startDate = DateTime.now();

  bool _isSaving = false;
  bool _loadingCropDefaults = false;
  bool _isLoadingExistingPlantings = true;
  bool _isApplyingAutomaticPosition = false;
  _PositionMode _positionMode = _PositionMode.automatic;

  bool get _isAutomaticPosition => _positionMode == _PositionMode.automatic;

  bool get _isEditing => widget.isEditing;

  Planting? get _editingPlanting => widget.planting;
  CropSuggestion? get _suggestion => widget.suggestion;
  PlantingRepository get _plantingRepository => widget.repository;

  @override
  void initState() {
    super.initState();
    _cropRepository = widget.cropRepository ?? CropRepository();
    _associationRepository =
        widget.associationRepository ?? CropAssociationRepository();
    _seasonRepository = widget.seasonRepository ?? SeasonRepository();

    _initializeEditingValues();
    _cropsFuture = _loadCrops();
    _loadExistingPlantings();
    _loadAssociations();

    _plantsCountController.addListener(_refreshCalculations);
    _plantSpacingController.addListener(_refreshCalculations);
    _rowSpacingController.addListener(_refreshCalculations);
    _rowsCountController.addListener(_refreshCalculations);
    _startPositionController.addListener(_refreshPositionCalculations);
    _manualLengthController.addListener(_refreshCalculations);
    _occupiedWidthController.addListener(_refreshCalculations);
    _seedQuantityController.addListener(_refreshCalculations);
  }

  void _initializeEditingValues() {
    final planting = _editingPlanting;

    if (planting != null) {
      _startMethod = planting.startMethod;
      _startDate = planting.startDate;
      _positionMode = _PositionMode.manual;

      _startPositionController.text = planting.startPositionCm.toString();

      _manualLengthController.text = planting.lengthCm.toString();

      _plantsCountController.text = planting.plantsCount?.toString() ?? '';

      _plantSpacingController.text = planting.plantSpacingCm?.toString() ?? '';

      _rowSpacingController.text = planting.rowSpacingCm?.toString() ?? '';

      _rowsCountController.text = planting.rowsCount?.toString() ?? '';

      _occupiedWidthController.text = planting.occupiedWidthCm.toString();

      _seedQuantityController.text = planting.seedQuantityG?.toString() ?? '';

      _notesController.text = planting.notes ?? '';

      return;
    }

    final suggestion = _suggestion;

    if (suggestion == null) {
      return;
    }

    _positionMode = _PositionMode.manual;

    _startPositionController.text = suggestion.startPositionCm.toString();

    _manualLengthController.text = suggestion.lengthCm.toString();

    _plantsCountController.text = suggestion.plantsCount.toString();
  }

  @override
  void dispose() {
    _plantsCountController.removeListener(_refreshCalculations);
    _plantSpacingController.removeListener(_refreshCalculations);
    _rowSpacingController.removeListener(_refreshCalculations);
    _rowsCountController.removeListener(_refreshCalculations);
    _rowsCountController.dispose();
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

    final requestedCropId = _editingPlanting?.cropId ?? _suggestion?.crop.id;

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
        _cropNamesById = {for (final crop in crops) crop.id: crop.name};

        _cropsById = {for (final crop in crops) crop.id: crop};

        _selectedCrop = initialCrop;

        if (widget.isUsingSuggestion && initialCrop != null) {
          _startMethod = _defaultStartMethodForCrop(initialCrop);

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
          : plantings.where((planting) => planting.id != editingId).toList();

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
      final associations = await _associationRepository.getAllAssociations();

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
      referenceDate: _startDate,
    );

    setState(() {
      _rotationResult = result;
    });
  }

  void _refreshCalculations() {
    if (!mounted || _loadingCropDefaults || _isApplyingAutomaticPosition) {
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
      if (_startPositionController.text.isEmpty) {
        return;
      }

      _isApplyingAutomaticPosition = true;
      _startPositionController.clear();
      _isApplyingAutomaticPosition = false;

      setState(() {
        _saveError = null;
      });

      return;
    }

    final suggestedPosition = bestSpace.startCm.round().toString();

    if (_startPositionController.text == suggestedPosition) {
      return;
    }

    _isApplyingAutomaticPosition = true;
    _startPositionController.value = TextEditingValue(
      text: suggestedPosition,
      selection: TextSelection.collapsed(offset: suggestedPosition.length),
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
      _positionMode = isEmpty ? _PositionMode.automatic : _PositionMode.manual;
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

  String _defaultStartMethodForCrop(Crop crop) {
    final method = crop.defaultStartMethod;

    if (method != null && Planting.allowedStartMethods.contains(method)) {
      return method;
    }

    return 'purchased_seedlings';
  }

  void _selectCrop(Crop? crop) {
    _loadingCropDefaults = true;

    _selectedCrop = crop;

    if (crop == null) {
      _plantSpacingController.clear();
      _rowSpacingController.clear();
      _startMethod = 'purchased_seedlings';
    } else {
      _startMethod = _defaultStartMethodForCrop(crop);

      _plantSpacingController.text = crop.plantSpacingCm?.toString() ?? '';

      _rowSpacingController.text = crop.rowSpacingCm?.toString() ?? '';
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

  bool get _requiresPlantCount {
    return _startMethod == 'purchased_seedlings' ||
        _startMethod == 'nursery_then_transplant';
  }

  bool get _supportsPlantCount {
    return _requiresPlantCount || _startMethod == 'direct_rows';
  }

  bool get _requiresPlantSpacing {
    return _requiresPlantCount;
  }

  bool get _supportsPlantSpacing {
    return _requiresPlantCount || _startMethod == 'direct_rows';
  }

  bool get _requiresRows {
    return _startMethod == 'direct_rows';
  }

  bool get _supportsRows {
    return _requiresPlantCount || _startMethod == 'direct_rows';
  }

  bool get _isDirectRows {
    return _startMethod == 'direct_rows';
  }

  bool get _isBroadcast {
    return _startMethod == 'direct_broadcast';
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
    final rowsCount = _parsePositiveInt(_rowsCountController.text);

    if (rowsCount != null) {
      return rowsCount;
    }

    return 1;
  }

  int get _plantsPerRow {
    final plantsCount = _plantsCount;

    if (plantsCount == null) {
      return 0;
    }

    return (plantsCount / _calculatedRowsCount).ceil();
  }

  int get _calculatedLengthCm {
    if (_isBroadcast ||
        _isDirectRows ||
        _positionMode == _PositionMode.manual) {
      return _parsePositiveInt(_manualLengthController.text) ?? 0;
    }

    final plantsCount = _plantsCount;
    final plantSpacing = _plantSpacingCm;

    if (plantsCount == null || plantSpacing == null) {
      return 0;
    }

    if (plantsCount == 1) {
      return plantSpacing;
    }

    return AgronomicEngine.calculateOccupiedLength(
      plants: plantsCount,
      spacingCm: plantSpacing.toDouble(),
    ).round();
  }

  int get _occupiedWidthCm {
    final manuallyEnteredWidth = _parsePositiveInt(
      _occupiedWidthController.text,
    );

    if (_isBroadcast) {
      return manuallyEnteredWidth ?? _bedWidthCm;
    }

    final rowsCount = _parsePositiveInt(_rowsCountController.text);
    final rowSpacing = _rowSpacingCm;

    if (rowsCount != null && rowSpacing != null) {
      final calculatedWidth = (rowsCount - 1) * rowSpacing;

      return math.max(calculatedWidth, 1);
    }

    if (_positionMode == _PositionMode.manual) {
      return manuallyEnteredWidth ?? _bedWidthCm;
    }

    return _bedWidthCm;
  }

  int get _endPositionCm {
    return _startPositionCm + _calculatedLengthCm;
  }

  int get _remainingLengthCm {
    return _bedLengthCm - _endPositionCm;
  }

  List<Planting> get _temporallyRelevantPlantings {
    final candidateStart = _startDate;
    final candidateEnd = _editingPlanting?.endDate;

    return _existingPlantings.where((planting) {
      final existingStart = planting.startDate;
      final existingEnd = planting.endDate;

      final candidateStartsBeforeExistingEnds =
          existingEnd == null || candidateStart.isBefore(existingEnd);

      final existingStartsBeforeCandidateEnds =
          candidateEnd == null || existingStart.isBefore(candidateEnd);

      return candidateStartsBeforeExistingEnds &&
          existingStartsBeforeCandidateEnds;
    }).toList();
  }

  List<Planting> get _overlappingPlantings {
    if (_calculatedLengthCm <= 0) {
      return const [];
    }

    return _temporallyRelevantPlantings.where((planting) {
      final existingStartCm = planting.startPositionCm;
      final existingEndCm = planting.startPositionCm + planting.lengthCm;

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
      plantings: _temporallyRelevantPlantings,
    );
  }

  dynamic _findBestSpace(BedAnalysisResult analysis) {
    final suitableSpaces = analysis.freeSpaces
        .where((space) => space.lengthCm >= _calculatedLengthCm)
        .toList();

    if (suitableSpaces.isEmpty) {
      return null;
    }

    suitableSpaces.sort((first, second) {
      final firstWaste = first.lengthCm - _calculatedLengthCm;
      final secondWaste = second.lengthCm - _calculatedLengthCm;

      final wasteComparison = firstWaste.compareTo(secondWaste);

      if (wasteComparison != 0) {
        return wasteComparison;
      }

      return first.startCm.compareTo(second.startCm);
    });

    return suitableSpaces.first;
  }

  double _remainingSpaceAfterInsertion(dynamic space) {
    return math.max(0, space.lengthCm - _calculatedLengthCm).toDouble();
  }

  String get _methodLabel {
    switch (_startMethod) {
      case 'purchased_seedlings':
        return 'Piantine acquistate';
      case 'nursery_then_transplant':
        return 'Semina in semenzaio e trapianto';
      case 'direct_rows':
        return 'Semina diretta a file';
      case 'direct_broadcast':
        return 'Semina diretta a spaglio';
      default:
        return _startMethod;
    }
  }

  String _formatCentimeters(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(today) ? today : _startDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _startDate = selectedDate;
      _saveError = null;
    });

    _applyAutomaticPositionIfPossible();
    _evaluateRotation();
    _evaluateAssociation();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedCrop = _selectedCrop;

    if (selectedCrop == null) {
      setState(() {
        _saveError = 'Seleziona una coltura.';
      });
      return;
    }

    if (_calculatedLengthCm <= 0) {
      setState(() {
        _saveError = 'La lunghezza occupata deve essere maggiore di zero.';
      });
      return;
    }

    if (!_fitsInsideBedBounds) {
      setState(() {
        _saveError = 'La coltura supera i limiti dell’aiuola.';
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
      widget.authority.requireLeaseForWrite();

      final editingPlanting = _editingPlanting;
      final seasonId =
          editingPlanting?.seasonId ??
          (await _seasonRepository.getActiveSeason()).id;

      final notesText = _notesController.text.trim();

      final plantSpacingCm = _supportsPlantSpacing ? _plantSpacingCm : null;

      final rowSpacingCm = _supportsRows ? _rowSpacingCm : null;

      final rowsCount = _supportsRows && rowSpacingCm != null
          ? _calculatedRowsCount
          : null;

      final plantsCount = _supportsPlantCount ? _plantsCount : null;

      final seedQuantityG = _isBroadcast
          ? _parsePositiveDouble(_seedQuantityController.text)
          : null;

      if (_isEditing) {
        final planting = editingPlanting!;

        final result = await _plantingRepository.updatePlanting(
          plantingId: planting.id,
          expectedRowVersion: planting.rowVersion,
          seasonId: seasonId,
          cropId: selectedCrop.id,
          varietyId: planting.varietyId,
          startMethod: _startMethod,
          startDate: _startDate,
          startPositionCm: _startPositionCm,
          lengthCm: _calculatedLengthCm,
          plantSpacingCm: plantSpacingCm,
          rowSpacingCm: rowSpacingCm,
          rowsCount: rowsCount,
          occupiedWidthCm: _occupiedWidthCm,
          plantsCount: plantsCount,
          seedQuantityG: seedQuantityG,
          notes: notesText.isEmpty ? null : notesText,
        );

        if (!mounted) {
          return;
        }

        switch (result) {
          case PlantingUpdated():
          case UpdatePlantingUnchanged():
            Navigator.of(context).pop(true);
            return;

          case UpdatePlantingVersionConflict():
            setState(() {
              _saveError =
                  'La coltura è stata modificata da un’altra sessione. '
                  'Aggiorna i dati prima di riprovare.';
            });
            return;

          case UpdatePlantingForbidden():
            setState(() {
              _saveError = 'Non sei autorizzato a modificare questa coltura.';
            });
            return;

          case UpdatePlantingWriteForbidden():
            setState(() {
              _saveError = 'Il server non ha autorizzato la scrittura.';
            });
            return;

          case UpdatePlantingNotFound():
            setState(() {
              _saveError = 'La coltura non è più disponibile.';
            });
            return;

          case UpdatePlantingInvalidInput():
            setState(() {
              _saveError =
                  'I dati inseriti non sono validi per il metodo selezionato.';
            });
            return;

          case UpdatePlantingBlockedByInactiveCrop():
            setState(() {
              _saveError = 'La coltura selezionata non è più attiva.';
            });
            return;

          case UpdatePlantingBlockedByInactiveVariety():
            setState(() {
              _saveError = 'La varietà selezionata non è più attiva.';
            });
            return;

          case UpdatePlantingStartMethodLocked():
            setState(() {
              _saveError =
                  'Lo stato attuale non consente di modificare '
                  'il metodo di avvio.';
            });
            return;

          case UpdatePlantingStartDateLocked():
            setState(() {
              _saveError =
                  'Lo stato attuale non consente di modificare '
                  'la data di inizio.';
            });
            return;

          case UpdatePlantingOutsideBedGeometry():
            setState(() {
              _saveError =
                  'La coltura non rientra nella geometria '
                  'dell’aiuola valida nel periodo indicato.';
            });
            return;

          case UpdatePlantingOverlap():
            setState(() {
              _saveError =
                  'La coltura si sovrappone a un’altra occupazione '
                  'registrata nell’aiuola.';
            });
            return;
        }
      }

      final result = await _plantingRepository.createPlanting(
        gardenId: widget.bed.gardenId,
        seasonId: seasonId,
        bedId: widget.bed.id,
        cropId: selectedCrop.id,
        varietyId: null,
        startMethod: _startMethod,
        startDate: _startDate,
        startPositionCm: _startPositionCm,
        lengthCm: _calculatedLengthCm,
        plantSpacingCm: plantSpacingCm,
        rowSpacingCm: rowSpacingCm,
        rowsCount: rowsCount,
        occupiedWidthCm: _occupiedWidthCm,
        plantsCount: plantsCount,
        seedQuantityG: seedQuantityG,
        notes: notesText.isEmpty ? null : notesText,
      );

      if (!mounted) {
        return;
      }

      switch (result) {
        case PlantingCreated():
          Navigator.of(context).pop(true);
          return;

        case CreatePlantingForbidden():
          setState(() {
            _saveError =
                'Non sei autorizzato a inserire una coltura '
                'in questa aiuola.';
          });
          return;

        case CreatePlantingWriteForbidden():
          setState(() {
            _saveError = 'Il server non ha autorizzato la scrittura.';
          });
          return;

        case CreatePlantingNotFound():
          setState(() {
            _saveError =
                'Uno dei dati collegati alla coltura non è più disponibile.';
          });
          return;

        case CreatePlantingInvalidInput():
          setState(() {
            _saveError =
                'I dati inseriti non sono validi per il metodo selezionato.';
          });
          return;

        case CreatePlantingBlockedByInactiveGarden():
          setState(() {
            _saveError = 'L’orto non è attivo.';
          });
          return;

        case CreatePlantingBlockedByInactiveBed():
          setState(() {
            _saveError = 'L’aiuola non è attiva.';
          });
          return;

        case CreatePlantingBlockedByInactiveCrop():
          setState(() {
            _saveError = 'La coltura selezionata non è più attiva.';
          });
          return;

        case CreatePlantingBlockedByInactiveVariety():
          setState(() {
            _saveError = 'La varietà selezionata non è più attiva.';
          });
          return;

        case CreatePlantingOutsideBedGeometry():
          setState(() {
            _saveError =
                'La coltura non rientra nella geometria '
                'dell’aiuola valida nel periodo indicato.';
          });
          return;

        case CreatePlantingOverlap():
          setState(() {
            _saveError =
                'La coltura si sovrappone a un’altra occupazione '
                'registrata nell’aiuola.';
          });
          return;
      }
    } on ProfileWriteAuthorityUnavailableException {
      if (!mounted) {
        return;
      }

      setState(() {
        _saveError = 'Autorità di scrittura non disponibile.';
      });
    } on Object catch (error, stackTrace) {
      debugPrint('Errore durante il salvataggio: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _saveError =
            'Non è stato possibile confermare l’esito del salvataggio.';
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
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
                  subtitle: Text('Dimensioni: $_bedWidthCm × $_bedLengthCm cm'),
                ),
              ),

              if (widget.isUsingSuggestion) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: const Text('Suggerimento applicato'),
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
              _buildSectionTitle(context, 'Coltura', Icons.eco_outlined),
              const SizedBox(height: 12),
              FutureBuilder<List<Crop>>(
                future: _cropsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
              RotationCard(
                selectedCrop: _selectedCrop,
                result: _rotationResult,
                isLoading: _isLoadingExistingPlantings,
                hasLoadingError: _existingPlantingsError != null,
              ),
              const SizedBox(height: 12),
              AssociationCard(
                hasSelectedCrop: _selectedCrop != null,
                isLoading: _isLoadingExistingPlantings,
                result: _associationResult,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _startMethod,
                decoration: const InputDecoration(
                  labelText: 'Metodo di coltivazione',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'purchased_seedlings',
                    child: Text('Piantine acquistate'),
                  ),
                  DropdownMenuItem(
                    value: 'nursery_then_transplant',
                    child: Text('Semina in semenzaio e trapianto'),
                  ),
                  DropdownMenuItem(
                    value: 'direct_rows',
                    child: Text('Semina diretta a file'),
                  ),
                  DropdownMenuItem(
                    value: 'direct_broadcast',
                    child: Text('Semina diretta a spaglio'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _startMethod = value;
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
                onTap: _isSaving ? null : _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_startDate)),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Posizione nell’aiuola',
                Icons.straighten,
              ),
              const SizedBox(height: 12),
              PositionModeCard(
                isAutomatic: _isAutomaticPosition,
                isSaving: _isSaving,
                onEnableAutomaticPosition: _enableAutomaticPosition,
              ),
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
                  final parsedValue = int.tryParse(value?.trim() ?? '');

                  if (parsedValue == null || parsedValue < 0) {
                    return 'Inserisci una posizione valida';
                  }

                  if (parsedValue >= _bedLengthCm) {
                    return 'La posizione deve essere inferiore a $_bedLengthCm cm';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (!_isBroadcast) ...[
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
                  decoration: InputDecoration(
                    labelText: _requiresPlantCount
                        ? 'Numero di piante'
                        : 'Numero di piante (facoltativo)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      if (_requiresPlantCount) {
                        return 'Inserisci il numero di piante';
                      }
                      return null;
                    }

                    final plantsCount = int.tryParse(text);

                    if (plantsCount == null || plantsCount <= 0) {
                      return 'Inserisci un numero valido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plantSpacingController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _requiresPlantSpacing
                        ? 'Distanza tra le piante'
                        : 'Distanza tra le piante (facoltativa)',
                    suffixText: 'cm',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      if (_requiresPlantSpacing) {
                        return 'Inserisci la distanza tra le piante';
                      }
                      return null;
                    }

                    final spacing = int.tryParse(text);

                    if (spacing == null || spacing <= 0) {
                      return 'Inserisci una distanza valida';
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
                        controller: _rowsCountController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _requiresRows
                              ? 'Numero di file'
                              : 'Numero di file (facoltativo)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final rowSpacingText = _rowSpacingController.text
                              .trim();

                          if (text.isEmpty) {
                            if (_requiresRows || rowSpacingText.isNotEmpty) {
                              return 'Indica il numero di file';
                            }
                            return null;
                          }

                          final rowsCount = int.tryParse(text);

                          if (rowsCount == null || rowsCount <= 0) {
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
                        decoration: InputDecoration(
                          labelText: _requiresRows
                              ? 'Tra le file'
                              : 'Tra le file (facoltativo)',
                          suffixText: 'cm',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final rowsCountText = _rowsCountController.text
                              .trim();

                          if (text.isEmpty) {
                            if (_requiresRows || rowsCountText.isNotEmpty) {
                              return 'Indica la distanza tra le file';
                            }
                            return null;
                          }

                          final spacing = int.tryParse(text);

                          if (spacing == null || spacing <= 0) {
                            return 'Dato non valido';
                          }

                          if (rowsCountText.isEmpty) {
                            return 'Indica anche il numero di file';
                          }

                          final rowsCount = int.tryParse(rowsCountText);

                          if (rowsCount == null || rowsCount <= 0) {
                            return 'Numero di file non valido';
                          }

                          final requiredWidth = (rowsCount - 1) * spacing;

                          if (requiredWidth > _bedWidthCm) {
                            return 'Le file richiedono $requiredWidth cm, '
                                'ma l\'aiuola è larga $_bedWidthCm cm';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_isDirectRows) ...[
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
                      final length = int.tryParse(value?.trim() ?? '');

                      if (length == null || length <= 0) {
                        return 'Inserisci la lunghezza occupata';
                      }
                      final plantsCount = _plantsCount;
                      final plantSpacing = _plantSpacingCm;

                      if (plantsCount != null && plantSpacing != null) {
                        final requiredLength = (plantsCount - 1) * plantSpacing;

                        if (requiredLength > length) {
                          return 'Le piante richiedono almeno $requiredLength cm';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Le distanze proposte dalla coltura possono essere modificate.',
                ),
              ] else ...[
                _buildSectionTitle(context, 'Area occupata', Icons.crop_square),
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
                    final length = int.tryParse(value?.trim() ?? '');

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
                      return 'Inserisci la quantità di seme';
                    }

                    final width = int.tryParse(value.trim());

                    if (width == null || width <= 0 || width > _bedWidthCm) {
                      return 'Inserisci un valore tra 1 e $_bedWidthCm cm';
                    }

                    return null;
                  },
                ),
                if (_isBroadcast) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _seedQuantityController,
                    enabled: !_isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
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
              CalculationCard(
                usesPlantCount: _supportsPlantCount,
                calculatedRowsCount: _calculatedRowsCount,
                plantsPerRow: _plantsPerRow,
                calculatedLengthCm: _calculatedLengthCm,
                occupiedWidthCm: _occupiedWidthCm,
                endPositionCm: _endPositionCm,
                remainingLengthCm: _remainingLengthCm,
                fitsInBed: _fitsInBed,
                hasOverlap: _hasOverlap,
              ),
              const SizedBox(height: 12),
              SpaceSuggestionCard(
                isLoading: _isLoadingExistingPlantings,
                loadingError: _existingPlantingsError,
                calculatedLengthCm: _calculatedLengthCm,
                existingPlantingsCount: _temporallyRelevantPlantings.length,
                analysis: _bedAnalysis,
                bestSpace: _bedAnalysis == null
                    ? null
                    : _findBestSpace(_bedAnalysis!),
                isAutomaticPosition: _isAutomaticPosition,
                onRetry: () {
                  setState(() {
                    _isLoadingExistingPlantings = true;
                    _existingPlantingsError = null;
                  });

                  _loadExistingPlantings();
                },
                formatCentimeters: _formatCentimeters,
                remainingSpaceAfterInsertion: _remainingSpaceAfterInsertion,
              ),
              const SizedBox(height: 12),
              BedPreviewWidget(
                bedLengthCm: _bedLengthCm,
                existingPlantings: _temporallyRelevantPlantings,
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
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      'Errore durante il salvataggio:\n\n'
                      '$_saveError',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
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
