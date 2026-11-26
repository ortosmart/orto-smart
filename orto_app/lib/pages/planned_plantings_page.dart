import 'package:flutter/material.dart';

import '../core/write_authority/planned_planting_write_result.dart';
import '../core/write_authority/route_write_availability.dart';
import '../data/models/bed.dart';
import '../data/models/crop.dart';
import '../data/models/crop_cultivar.dart';
import '../data/models/planned_planting.dart';
import '../data/models/season.dart';
import '../data/repositories/bed_repository.dart';
import '../data/repositories/crop_cultivar_repository.dart';
import '../data/repositories/crop_repository.dart';
import 'planned_planting_form_page.dart';
import '../data/repositories/planned_planting_repository.dart';

typedef PlannedPlantingFormOptions = ({
  List<Bed> beds,
  List<Crop> crops,
  List<CropCultivar> cultivars,
});

class PlannedPlantingsPage extends StatefulWidget {
  final String seasonId;
  final String seasonName;
  final Season? season;
  final Future<PlannedPlantingFormOptions> Function(String gardenId)?
  loadFormOptions;
  final PlannedPlantingRepository repository;
  final RouteWriteAvailability? writeAvailability;

  const PlannedPlantingsPage({
    super.key,
    required this.seasonId,
    required this.seasonName,
    this.season,
    this.loadFormOptions,
    required this.repository,
    this.writeAvailability,
  });

  @override
  State<PlannedPlantingsPage> createState() => _PlannedPlantingsPageState();
}

class _PlannedPlantingsPageState extends State<PlannedPlantingsPage> {
  late Future<List<PlannedPlanting>> _plantingsFuture;
  bool _mutationInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadPlantings();
  }

  void _loadPlantings() {
    _plantingsFuture = widget.repository.getPlannedPlantingsBySeason(
      widget.seasonId,
    );
  }

  @override
  void didUpdateWidget(covariant PlannedPlantingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.seasonId != widget.seasonId ||
        !identical(oldWidget.repository, widget.repository)) {
      _loadPlantings();
    }
  }

  void _retry() {
    setState(_loadPlantings);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _statusLabel(String status) {
    return switch (status) {
      'draft' => 'Bozza',
      'confirmed' => 'Confermata',
      'executed' => 'Eseguita',
      'cancelled' => 'Annullata',
      _ => status,
    };
  }

  Widget _buildPlantingsList(List<PlannedPlanting> plantings) {
    final availability = widget.writeAvailability;

    Widget buildList(bool canWrite) {
      return FutureBuilder<bool>(
        future: canWrite && !_mutationInProgress
            ? widget.repository.canStartMutation()
            : null,
        builder: (context, snapshot) {
          final canStart =
              canWrite &&
              !_mutationInProgress &&
              snapshot.connectionState == ConnectionState.done &&
              snapshot.data == true;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantings.length,
            itemBuilder: (context, index) {
              final planting = plantings[index];

              return Card(
                child: ListTile(
                  trailing: _buildMutationMenu(planting, canStart),
                  title: Text(
                    'Pianificazione del ${_formatDate(planting.plannedStartDate)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stato: ${_statusLabel(planting.status)}'),
                      Text(
                        'Posizione: ${planting.startPositionCm} cm - '
                        'Lunghezza: ${planting.lengthCm} cm',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    if (availability == null) return buildList(false);
    return AnimatedBuilder(
      animation: availability,
      builder: (context, child) => buildList(availability.canWrite),
    );
  }

  Widget? _buildMutationMenu(PlannedPlanting planting, bool canStart) {
    final isDraft = planting.status == 'draft';
    final isConfirmed = planting.status == 'confirmed';
    if (!isDraft && !isConfirmed) return null;
    return PopupMenuButton<String>(
      enabled: canStart,
      tooltip: 'Azioni pianificazione',
      onSelected: (action) async {
        if (action == 'edit') {
          await _openPlanningForm(planting);
        } else if (action == 'execute') {
          await _selectExecutionDate(planting);
        } else {
          await _runLifecycleMutation(planting, action);
        }
      },
      itemBuilder: (context) => [
        if (widget.season != null)
          const PopupMenuItem(value: 'edit', child: Text('Modifica')),
        if (isDraft)
          const PopupMenuItem(value: 'confirm', child: Text('Conferma')),
        if (isConfirmed)
          const PopupMenuItem(value: 'execute', child: Text('Esegui')),
        const PopupMenuItem(value: 'cancel', child: Text('Annulla')),
      ],
    );
  }

  Widget _buildCreatePlanningButton() {
    final season = widget.season;
    final availability = widget.writeAvailability;
    if (season == null || availability == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: availability,
      builder: (context, child) => FutureBuilder<bool>(
        future: availability.canWrite && !_mutationInProgress
            ? widget.repository.canStartMutation()
            : null,
        builder: (context, snapshot) => Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed:
                  availability.canWrite &&
                      !_mutationInProgress &&
                      snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == true
                  ? () => _openPlanningForm()
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Nuova pianificazione'),
            ),
          ),
        ),
      ),
    );
  }

  Future<PlannedPlantingFormOptions> _loadFormOptions(String gardenId) async {
    final injected = widget.loadFormOptions;
    if (injected != null) return injected(gardenId);
    return (
      beds: await BedRepository().getBeds(gardenId: gardenId),
      crops: await CropRepository().getCrops(activeOnly: false),
      cultivars: await CropCultivarRepository().getAllCultivars(
        activeOnly: false,
      ),
    );
  }

  Future<void> _openPlanningForm([PlannedPlanting? planting]) async {
    final season = widget.season;
    if (season == null ||
        season.id != widget.seasonId ||
        _mutationInProgress ||
        widget.writeAvailability?.canWrite != true) {
      return;
    }
    final repository = widget.repository;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    bool isCurrent() =>
        mounted &&
        identical(widget.repository, repository) &&
        widget.seasonId == season.id;
    setState(() => _mutationInProgress = true);
    var attempted = false;
    try {
      if (!await repository.canStartMutation() || !isCurrent()) return;
      final (:beds, :crops, :cultivars) = await _loadFormOptions(
        season.gardenId,
      );
      if (!navigator.mounted ||
          !isCurrent() ||
          widget.writeAvailability?.canWrite != true) {
        return;
      }
      final data = await navigator.push<PlannedPlantingFormData>(
        MaterialPageRoute(
          builder: (_) => PlannedPlantingFormPage(
            season: season,
            beds: beds,
            crops: crops,
            cultivars: cultivars,
            planting: planting,
          ),
        ),
      );
      if (data == null ||
          !isCurrent() ||
          widget.writeAvailability?.canWrite != true ||
          !await repository.canStartMutation() ||
          !isCurrent() ||
          widget.writeAvailability?.canWrite != true) {
        return;
      }
      attempted = true;
      final success = planting == null
          ? await repository.createPlannedPlanting(
                  gardenId: season.gardenId,
                  seasonId: season.id,
                  bedId: data.bedId,
                  cropId: data.cropId,
                  cultivarId: data.cultivarId,
                  startMethod: data.startMethod,
                  startDate: data.startDate,
                  endDate: data.endDate,
                  startPositionCm: data.startPositionCm,
                  lengthCm: data.lengthCm,
                  occupiedWidthCm: data.occupiedWidthCm,
                  plantSpacingCm: data.plantSpacingCm,
                  rowSpacingCm: data.rowSpacingCm,
                  rowsCount: data.rowsCount,
                  plantsCount: data.plantsCount,
                  seedQuantityG: data.seedQuantityG,
                  notes: data.notes,
                )
                is CreatePlannedPlantingCreated
          : await repository.updatePlannedPlanting(
                  plannedPlantingId: planting.id,
                  expectedRowVersion: planting.rowVersion,
                  bedId: data.bedId,
                  cropId: data.cropId,
                  cultivarId: data.cultivarId,
                  startMethod: data.startMethod,
                  startDate: data.startDate,
                  endDate: data.endDate,
                  startPositionCm: data.startPositionCm,
                  lengthCm: data.lengthCm,
                  occupiedWidthCm: data.occupiedWidthCm,
                  plantSpacingCm: data.plantSpacingCm,
                  rowSpacingCm: data.rowSpacingCm,
                  rowsCount: data.rowsCount,
                  plantsCount: data.plantsCount,
                  seedQuantityG: data.seedQuantityG,
                  notes: data.notes,
                )
                is UpdatePlannedPlantingUpdated;
      if (isCurrent() && messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Pianificazione salvata.'
                  : 'Salvataggio rifiutato. Verifica i dati della pianificazione.',
            ),
          ),
        );
      }
    } on Object {
      if (isCurrent() && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Operazione non completata. Verifica lo stato prima di riprovare.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _mutationInProgress = false;
          if (attempted && isCurrent()) _loadPlantings();
        });
      }
    }
  }

  Future<void> _selectExecutionDate(PlannedPlanting planting) async {
    if (_mutationInProgress || widget.writeAvailability?.canWrite != true) {
      return;
    }
    final repository = widget.repository;
    final seasonId = widget.seasonId;
    final picked = await showDatePicker(
      context: context,
      initialDate: planting.plannedStartDate,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      helpText: 'Data effettiva di inizio',
    );
    if (picked == null ||
        !mounted ||
        !identical(widget.repository, repository) ||
        widget.seasonId != seasonId) {
      return;
    }
    await _runLifecycleMutation(
      planting,
      'execute',
      effectiveStartDate: picked,
    );
  }

  Future<void> _runLifecycleMutation(
    PlannedPlanting planting,
    String action, {
    DateTime? effectiveStartDate,
  }) async {
    if (_mutationInProgress || widget.writeAvailability?.canWrite != true) {
      return;
    }
    final repository = widget.repository;
    final seasonId = widget.seasonId;
    bool isCurrent() =>
        mounted &&
        identical(widget.repository, repository) &&
        widget.seasonId == seasonId;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _mutationInProgress = true);
    var attempted = false;
    try {
      if (!await repository.canStartMutation() ||
          !isCurrent() ||
          widget.writeAvailability?.canWrite != true) {
        return;
      }
      attempted = true;
      final success = switch (action) {
        'confirm' =>
          await repository.confirmPlannedPlanting(
                plannedPlantingId: planting.id,
                expectedRowVersion: planting.rowVersion,
              )
              is ConfirmPlannedPlantingConfirmed,
        'cancel' =>
          await repository.cancelPlannedPlanting(
                plannedPlantingId: planting.id,
                expectedRowVersion: planting.rowVersion,
              )
              is CancelPlannedPlantingCancelled,
        'execute' =>
          await repository.executePlannedPlanting(
                plannedPlantingId: planting.id,
                expectedRowVersion: planting.rowVersion,
                effectiveStartDate: effectiveStartDate!,
              )
              is ExecutePlannedPlantingExecuted,
        _ => false,
      };
      final successMessage = switch (action) {
        'confirm' => 'Pianificazione confermata.',
        'cancel' => 'Pianificazione annullata.',
        _ => 'Pianificazione eseguita.',
      };
      if (!isCurrent() || !messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? successMessage
                : 'Operazione non accettata. Verifica lo stato della pianificazione.',
          ),
        ),
      );
    } on Object {
      if (!isCurrent() || !messenger.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Operazione non completata. Verifica lo stato prima di riprovare.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _mutationInProgress = false;
          if (attempted && isCurrent()) _loadPlantings();
        });
      }
    }
  }

  Future<void> _verifyPendingMutation() async {
    if (_mutationInProgress || widget.writeAvailability?.canWrite != true) {
      return;
    }

    final repository = widget.repository;
    final seasonId = widget.seasonId;
    final messenger = ScaffoldMessenger.of(context);

    bool isCurrent() =>
        mounted &&
        identical(widget.repository, repository) &&
        widget.seasonId == seasonId;

    setState(() => _mutationInProgress = true);
    try {
      final receipt = await repository.recoverPendingMutationForSeason(
        seasonId,
      );
      if (!isCurrent()) return;

      if (receipt != null) {
        setState(_loadPlantings);
      }
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            receipt == null
                ? 'Nessuna operazione da verificare.'
                : 'Esito verificato. Elenco pianificazioni aggiornato.',
          ),
        ),
      );
    } on Object {
      if (!isCurrent() || !messenger.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Verifica non riuscita. Puoi riprovare con Verifica esito.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _mutationInProgress = false);
      }
    }
  }

  Widget _buildWriteAvailabilityStatus(BuildContext context) {
    final availability = widget.writeAvailability;

    Widget buildStatus(bool canWrite) {
      final colors = Theme.of(context).colorScheme;
      final color = canWrite ? colors.primary : colors.onSurfaceVariant;

      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                canWrite ? Icons.lock_open : Icons.lock_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  canWrite ? 'Scrittura disponibile' : 'Modalità sola lettura',
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (availability == null) {
      return buildStatus(false);
    }

    return AnimatedBuilder(
      animation: availability,
      builder: (context, child) {
        return buildStatus(availability.canWrite);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pianificazioni - ${widget.seasonName}')),
      body: Column(
        children: [
          _buildWriteAvailabilityStatus(context),
          if (widget.season != null && widget.writeAvailability != null)
            ListenableBuilder(
              listenable: widget.writeAvailability!,
              builder: (context, child) {
                return TextButton(
                  onPressed:
                      widget.writeAvailability!.canWrite && !_mutationInProgress
                      ? _verifyPendingMutation
                      : null,
                  child: const Text('Verifica esito'),
                );
              },
            ),
          _buildCreatePlanningButton(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<PlannedPlanting>>(
              future: _plantingsFuture,
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
                          'Non è stato possibile caricare le pianificazioni.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Riprova'),
                        ),
                      ],
                    ),
                  );
                }

                final plantings = snapshot.data ?? [];

                if (plantings.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nessuna pianificazione presente per questa stagione.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return _buildPlantingsList(plantings);
              },
            ),
          ),
        ],
      ),
    );
  }
}
