import 'package:flutter/material.dart';

import '../data/models/bed.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';
import '../data/models/suggestion_result.dart';
import '../data/repositories/crop_association_repository.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/planting_repository.dart';
import '../services/bed_analyzer.dart';
import '../services/suggestion_engine.dart';
import '../widgets/bed_layout_widget.dart';
import '../widgets/planting_card.dart';
import 'add_planting_page.dart';

class BedPage extends StatefulWidget {
  final Bed bed;

  const BedPage({
    super.key,
    required this.bed,
  });

  @override
  State<BedPage> createState() => _BedPageState();
}

class _BedPageState extends State<BedPage> {
  final PlantingRepository _plantingRepository = PlantingRepository();
  final CropRepository _cropRepository = CropRepository();
  final CropAssociationRepository _cropAssociationRepository =
      CropAssociationRepository();

  late Future<_BedPageData> _bedPageDataFuture;

  Bed get bed => widget.bed;

  @override
  void initState() {
    super.initState();
    _bedPageDataFuture = _loadBedPageData();
  }

  Future<_BedPageData> _loadBedPageData() async {
    final results = await Future.wait([
      _plantingRepository.getPlantingsByBed(bed.id),
      _cropRepository.getCrops(),
      _cropAssociationRepository.getAllAssociations(),
    ]);

    final plantings = results[0] as List<Planting>;
    final crops = results[1] as List<Crop>;
    final associations = results[2] as List<CropAssociation>;

    final cropsById = <String, Crop>{
      for (final crop in crops) crop.id: crop,
    };

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
      MaterialPageRoute(
        builder: (context) => AddPlantingPage(
          bed: bed,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshPlantings();
    }
  }

  Future<void> _editPlanting(Planting planting) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddPlantingPage(
          bed: bed,
          planting: planting,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshPlantings();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coltura modificata correttamente.'),
        ),
      );
    }
  }

  Future<void> _deletePlanting(
    Planting planting,
    Crop? crop,
  ) async {
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
        SnackBar(
          content: Text('$cropName eliminata correttamente.'),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Errore durante l’eliminazione della coltura: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l’eliminazione: $error'),
        ),
      );
    }
  }

  Future<void> _showCropSuggestions(_BedPageData data) async {
    final bedAnalysis = BedAnalyzer.analyze(
      bedLengthCm: bed.lengthCm.toDouble(),
      requiredLengthCm: 0,
      plantings: data.plantings,
    );

    final result = SuggestionEngine.generateSuggestions(
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
        return a.crop.name.toLowerCase().compareTo(
              b.crop.name.toLowerCase(),
            );
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
                    style: Theme.of(sheetContext)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Analizzate ${result.analyzedCropsCount} colture.',
                  ),
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

                                  final result = await Navigator.of(context).push<bool>(
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

  @override
  Widget build(BuildContext context) {
    final irrigationText = bed.irrigationZone == null
        ? 'Zona irrigazione non impostata'
        : 'Zona irrigazione ${bed.irrigationZone}';

    return Scaffold(
      appBar: AppBar(
        title: Text('${bed.code} - Aiuola ${bed.number}'),
        actions: [
          IconButton(
            onPressed: _refreshPlantings,
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlantings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              bed.name != null && bed.name!.trim().isNotEmpty
                  ? bed.name!
                  : 'Aiuola ${bed.number}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              bed.code,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.straighten),
                title: const Text('Dimensioni'),
                subtitle: Text('${bed.widthCm} × ${bed.lengthCm} cm'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: const Text('Irrigazione'),
                subtitle: Text(irrigationText),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BedLayoutWidget(
                      bed: bed,
                      plantings: data.plantings,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
