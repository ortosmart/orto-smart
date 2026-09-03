import 'dart:async';

import 'package:flutter/material.dart';

import '../core/write_authority/bed_write_result.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../data/models/bed.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';
import '../data/models/suggestion_result.dart';
import '../data/repositories/bed_repository.dart';
import '../data/repositories/crop_association_repository.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/planting_repository.dart';
import '../services/bed_analysis_service.dart';
import '../widgets/bed_layout_widget.dart';
import '../widgets/companion_analysis_widget.dart';
import '../widgets/planting_card.dart';
import 'add_planting_page.dart';
import 'edit_bed_page.dart';
import 'change_bed_geometry_page.dart';
import 'correct_bed_geometry_page.dart';

class BedPage extends StatefulWidget {
  final Bed bed;
  final ProfileWriteAuthorityController? authority;
  final BedRepository? repository;
  final PlantingRepository? plantingRepository;
  final CropRepository? cropRepository;
  final CropAssociationRepository? cropAssociationRepository;

  const BedPage({
    super.key,
    required this.bed,
    this.authority,
    this.repository,
    this.plantingRepository,
    this.cropRepository,
    this.cropAssociationRepository,
  });

  @override
  State<BedPage> createState() => _BedPageState();
}

class _BedPageState extends State<BedPage> {
  late PlantingRepository _plantingRepository;
  late CropRepository _cropRepository;
  late CropAssociationRepository _cropAssociationRepository;

  late BedRepository _bedRepository;
  late Bed _bed;
  late Future<_BedPageData> _bedPageDataFuture;

  bool _isLoadingBed = true;
  bool _bedLoadFailed = false;
  bool _bedAvailable = false;
  int _bedLoadGeneration = 0;

  Bed get bed => _bed;

  @override
  void initState() {
    super.initState();

    _bedRepository = widget.repository ?? BedRepository();
    _plantingRepository = widget.plantingRepository ?? PlantingRepository();
    _cropRepository = widget.cropRepository ?? CropRepository();
    _cropAssociationRepository =
        widget.cropAssociationRepository ?? CropAssociationRepository();
    _bed = widget.bed;

    unawaited(_reloadBed());
  }

  @override
  void didUpdateWidget(covariant BedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final repositoryChanged = !identical(
      oldWidget.repository,
      widget.repository,
    );
    final plantingRepositoryChanged = !identical(
      oldWidget.plantingRepository,
      widget.plantingRepository,
    );
    final cropRepositoryChanged = !identical(
      oldWidget.cropRepository,
      widget.cropRepository,
    );
    final associationRepositoryChanged = !identical(
      oldWidget.cropAssociationRepository,
      widget.cropAssociationRepository,
    );

    if (repositoryChanged) {
      _bedRepository = widget.repository ?? BedRepository();
    }

    if (plantingRepositoryChanged) {
      _plantingRepository = widget.plantingRepository ?? PlantingRepository();
    }

    if (cropRepositoryChanged) {
      _cropRepository = widget.cropRepository ?? CropRepository();
    }

    if (associationRepositoryChanged) {
      _cropAssociationRepository =
          widget.cropAssociationRepository ?? CropAssociationRepository();
    }

    if (oldWidget.bed.id != widget.bed.id ||
        oldWidget.bed.gardenId != widget.bed.gardenId ||
        repositoryChanged ||
        plantingRepositoryChanged ||
        cropRepositoryChanged ||
        associationRepositoryChanged) {
      unawaited(_reloadBed());
    }
  }

  Future<void> _reloadBed() async {
    final generation = ++_bedLoadGeneration;
    final gardenId = widget.bed.gardenId;
    final bedId = widget.bed.id;

    setState(() {
      _isLoadingBed = true;
      _bedLoadFailed = false;
      _bedAvailable = false;
    });

    try {
      final loaded = await _bedRepository.getBed(
        gardenId: gardenId,
        bedId: bedId,
      );

      if (!mounted || generation != _bedLoadGeneration) {
        return;
      }

      setState(() {
        _isLoadingBed = false;
        _bedAvailable = loaded != null;

        if (loaded != null) {
          _bed = loaded;
          _bedPageDataFuture = _loadBedPageData();
        }
      });
    } on Object {
      if (!mounted || generation != _bedLoadGeneration) {
        return;
      }

      setState(() {
        _isLoadingBed = false;
        _bedLoadFailed = true;
        _bedAvailable = false;
      });
    }
  }

  Future<_BedPageData> _loadBedPageData() {
    final future = _fetchBedPageData();

    // Il caricamento può fallire prima del prossimo build.
    // Registriamo subito un gestore, lasciando il Future originale
    // al FutureBuilder affinché possa mostrare l'errore.
    unawaited(
      future.then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {},
      ),
    );

    return future;
  }

  Future<_BedPageData> _fetchBedPageData() async {
    final results = await Future.wait([
      _plantingRepository.getPlantingsByBed(bed.id),
      _cropRepository.getCrops(),
      _cropAssociationRepository.getAllAssociations(),
    ]);

    final plantings = results[0] as List<Planting>;
    final crops = results[1] as List<Crop>;
    final associations = results[2] as List<CropAssociation>;

    final cropsById = <String, Crop>{for (final crop in crops) crop.id: crop};

    return _BedPageData(
      plantings: plantings,
      crops: crops,
      cropsById: cropsById,
      associations: associations,
    );
  }

  Future<void> _refreshPlantings() async {
    setState(() {
      _bedPageDataFuture = _loadBedPageData();
    });

    await _bedPageDataFuture;
  }

  Future<void> _openAddPlantingPage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddPlantingPage(bed: bed)),
    );

    if (result == true && mounted) {
      await _refreshPlantings();
    }
  }

  Future<void> _editPlanting(Planting planting) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddPlantingPage(bed: bed, planting: planting),
      ),
    );

    if (result == true && mounted) {
      await _refreshPlantings();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coltura modificata correttamente.')),
      );
    }
  }

  Future<void> _deletePlanting(Planting planting, Crop? crop) async {
    final plantingId = planting.id;

    if (plantingId == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossibile eliminare la coltura: id non disponibile.',
          ),
        ),
      );
      return;
    }

    final cropName = crop?.name.trim().isNotEmpty == true
        ? crop!.name
        : 'Coltura';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare la coltura?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cropName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                planting.plantsCount == null
                    ? 'Numero di piante non indicato'
                    : '${planting.plantsCount} piante',
              ),
              const SizedBox(height: 12),
              const Text(
                'Questa operazione eliminerà definitivamente '
                'la coltura dall’aiuola.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _plantingRepository.deletePlanting(plantingId);

      if (!mounted) {
        return;
      }

      await _refreshPlantings();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$cropName eliminata correttamente.')),
      );
    } catch (error, stackTrace) {
      debugPrint('Errore durante l’eliminazione della coltura: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l’eliminazione: $error')),
      );
    }
  }

  Future<void> _showCropSuggestions(_BedPageData data) async {
    final bedAnalysis = BedAnalysisService.analyzeSpace(
      bedLengthCm: bed.lengthCm.toDouble(),
      requiredLengthCm: 0,
      plantings: data.plantings,
    );

    final result = BedAnalysisService.generateSuggestions(
      availableCrops: data.crops,
      existingPlantings: data.plantings,
      cropsById: data.cropsById,
      associations: data.associations,
      bedAnalysis: bedAnalysis,
    );

    final suggestions = [...result.suggestions]
      ..sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return a.crop.name.toLowerCase().compareTo(b.crop.name.toLowerCase());
      });

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.88,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Colture suggerite',
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Analizzate ${result.analyzedCropsCount} colture.'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: suggestions.isEmpty
                        ? const _NoSuggestionsCard()
                        : ListView.separated(
                            itemCount: suggestions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _SuggestionCard(
                                position: index + 1,
                                suggestion: suggestions[index],
                                onUseSuggestion: () async {
                                  Navigator.of(sheetContext).pop();

                                  final result = await Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => AddPlantingPage(
                                            bed: bed,
                                            suggestion: suggestions[index],
                                          ),
                                        ),
                                      );

                                  if (result == true && mounted) {
                                    await _refreshPlantings();
                                  }
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _setBedActive(bool isActive) async {
    final authority = widget.authority;

    if (authority == null) {
      return;
    }

    try {
      authority.requireLeaseForWrite();

      final result = await _bedRepository.setBedActive(
        bedId: bed.id,
        expectedRowVersion: bed.rowVersion,
        isActive: isActive,
      );

      if (!mounted) {
        return;
      }

      switch (result) {
        case BedActiveUpdated():
        case SetBedActiveUnchanged():
          await _reloadBed();
          break;

        case SetBedActiveVersionConflict():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'L’aiuola è stata modificata da un’altra sessione. '
                'Aggiorna i dati prima di riprovare.',
              ),
            ),
          );
          break;

        case SetBedActiveForbidden():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Non sei autorizzato a modificare questa aiuola.'),
            ),
          );
          break;

        case SetBedActiveWriteForbidden():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Il server non ha autorizzato la scrittura.'),
            ),
          );
          break;

        case SetBedActiveNotFound():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L’aiuola non è più disponibile.')),
          );
          break;

        case SetBedActiveInvalidInput():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Il server ha rifiutato la modifica dello stato.'),
            ),
          );
          break;
      }
    } on ProfileWriteAuthorityUnavailableException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autorità di scrittura non disponibile.')),
      );
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Non è stato possibile confermare l’esito della modifica.',
          ),
        ),
      );
    }
  }

  Future<void> _openEditBedPage() async {
    final authority = widget.authority;

    if (authority == null) {
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditBedPage(
          bed: bed,
          repository: _bedRepository,
          authority: authority,
        ),
      ),
    );

    if (result == true && mounted) {
      await _reloadBed();
    }
  }

  Future<void> _openChangeBedGeometryPage() async {
    final authority = widget.authority;

    if (authority == null) {
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeBedGeometryPage(
          bed: bed,
          repository: _bedRepository,
          authority: authority,
        ),
      ),
    );

    if (result == true && mounted) {
      await _reloadBed();
    }
  }

  Future<void> _openCorrectBedGeometryPage() async {
    final authority = widget.authority;

    if (authority == null) {
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CorrectBedGeometryPage(
          bed: bed,
          repository: _bedRepository,
          authority: authority,
        ),
      ),
    );

    if (result == true && mounted) {
      await _reloadBed();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBed || _bedLoadFailed || !_bedAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aiuola')),
        body: Center(
          child: _isLoadingBed
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _bedLoadFailed
                            ? 'Non è stato possibile caricare l’aiuola.'
                            : 'Aiuola non disponibile nell’orto richiesto.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _reloadBed,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${bed.code} - Aiuola ${bed.number}'),
        actions: [
          IconButton(
            onPressed: widget.authority == null ? null : _openEditBedPage,
            tooltip: 'Modifica aiuola',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _reloadBed,
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadBed,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              bed.name != null && bed.name!.trim().isNotEmpty
                  ? bed.name!
                  : 'Aiuola ${bed.number}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(bed.code, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.straighten),
                title: const Text('Dimensioni'),
                subtitle: Text('${bed.widthCm} × ${bed.lengthCm} cm'),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.authority == null
                    ? null
                    : _openChangeBedGeometryPage,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history_outlined),
                title: const Text('Correggi geometria'),
                subtitle: const Text('Rettifica dati storici della geometria'),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.authority == null
                    ? null
                    : _openCorrectBedGeometryPage,
              ),
            ),
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  bed.isActive
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                ),
                title: const Text('Stato aiuola'),
                subtitle: Text(bed.isActive ? 'Attiva' : 'Disattivata'),
                value: bed.isActive,
                onChanged: widget.authority == null ? null : _setBedActive,
              ),
            ),
            if (bed.notes != null && bed.notes!.trim().isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notes),
                  title: const Text('Note'),
                  subtitle: Text(bed.notes!),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Colture presenti',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<_BedPageData>(
              future: _bedPageDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SelectableText(
                            'Errore nel caricamento delle colture:\n\n'
                            '${snapshot.error}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _refreshPlantings,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Riprova'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox.shrink();
                }

                final companionAnalysis = BedAnalysisService.analyzeCompanions(
                  plantings: data.plantings,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BedLayoutWidget(
                      bed: bed,
                      plantings: data.plantings,
                      cropsById: data.cropsById,
                    ),

                    const SizedBox(height: 16),

                    CompanionAnalysisWidget(
                      analysis: companionAnalysis,
                      cropsById: data.cropsById,
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: () => _showCropSuggestions(data),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Suggerisci colture'),
                    ),
                    const SizedBox(height: 24),
                    if (data.plantings.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Nessuna coltura inserita in questa aiuola.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    else
                      ...data.plantings.map((planting) {
                        final crop = data.cropsById[planting.cropId];
                        return PlantingCard(
                          planting: planting,
                          crop: crop,
                          onEdit: () => _editPlanting(planting),
                          onDelete: () => _deletePlanting(planting, crop),
                        );
                      }),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddPlantingPage,
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi coltura'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final int position;
  final CropSuggestion suggestion;
  final VoidCallback onUseSuggestion;

  const _SuggestionCard({
    required this.position,
    required this.suggestion,
    required this.onUseSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('$position')),
        title: Text(
          suggestion.crop.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${suggestion.ratingLabel} · '
          '${suggestion.plantsCount} piante · '
          '${suggestion.rowsCount} file',
        ),
        trailing: Text(
          '${suggestion.score}/100',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            'Posizione: ${suggestion.startPositionCm}–'
            '${suggestion.endPositionCm} cm',
          ),
          const SizedBox(height: 4),
          Text('Lunghezza: ${suggestion.lengthCm} cm'),
          const SizedBox(height: 8),
          Text(
            'Spazio: ${suggestion.spaceScore}/100 · '
            'Rotazione: ${suggestion.rotationScore}/100 · '
            'Consociazione: ${suggestion.associationScore}/100',
          ),
          const SizedBox(height: 12),
          ...suggestion.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onUseSuggestion,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('🌱 Usa questo suggerimento'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSuggestionsCard extends StatelessWidget {
  const _NoSuggestionsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 40),
            SizedBox(height: 12),
            Text(
              'Nessuna coltura compatibile con gli spazi liberi.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BedPageData {
  final List<Planting> plantings;
  final List<Crop> crops;
  final Map<String, Crop> cropsById;
  final List<CropAssociation> associations;

  const _BedPageData({
    required this.plantings,
    required this.crops,
    required this.cropsById,
    required this.associations,
  });
}
