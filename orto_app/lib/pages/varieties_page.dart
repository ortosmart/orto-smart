import 'package:flutter/material.dart';

import '../data/models/crop.dart';
import '../data/models/crop_variety.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/crop_variety_repository.dart';
import 'add_variety_page.dart';

class VarietiesPage extends StatefulWidget {
  const VarietiesPage({super.key});

  @override
  State<VarietiesPage> createState() => _VarietiesPageState();
}

class _VarietiesPageState extends State<VarietiesPage> {
  final CropRepository _cropRepository = CropRepository();
  final CropVarietyRepository _varietyRepository =
      CropVarietyRepository();

  late Future<_VarietiesPageData> _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _pageDataFuture = _fetchData();
  }

  Future<_VarietiesPageData> _fetchData() async {
    final results = await Future.wait([
      _cropRepository.getCrops(),
      _varietyRepository.getAllVarieties(),
    ]);

    return _VarietiesPageData(
      crops: results[0] as List<Crop>,
      varieties: results[1] as List<CropVariety>,
    );
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _pageDataFuture;
  }

  Future<void> _openAddVarietyPage() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AddVarietyPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_loadData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Varietà'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuova varietà',
            onPressed: _openAddVarietyPage,
          ),
        ],
      ),
      body: FutureBuilder<_VarietiesPageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Errore durante il caricamento delle varietà.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(_loadData);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          if (data.varieties.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 140),
                  const Icon(
                    Icons.eco_outlined,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Nessuna varietà presente.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Premi + per inserire la prima varietà.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _openAddVarietyPage,
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi varietà'),
                    ),
                  ),
                ],
              ),
            );
          }

          final cropsById = {
            for (final crop in data.crops) crop.id: crop,
          };

          final varietiesByCrop = <String, List<CropVariety>>{};

          for (final variety in data.varieties) {
            final cropId = variety.cropId.toString();

            varietiesByCrop
                .putIfAbsent(cropId, () => [])
                .add(variety);
          }

          final cropIds = varietiesByCrop.keys.toList()
            ..sort((a, b) {
              final nameA = cropsById[a]?.name ?? '';
              final nameB = cropsById[b]?.name ?? '';
              return nameA.compareTo(nameB);
            });

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cropIds.length,
              itemBuilder: (context, index) {
                final cropId = cropIds[index];
                final crop = cropsById[cropId];
                final varieties = varietiesByCrop[cropId] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.grass),
                    ),
                    title: Text(
                      crop?.name ?? 'Coltura sconosciuta',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('${varieties.length} varietà'),
                    children: varieties.map((variety) {
                      return ListTile(
                        leading: const Icon(Icons.eco_outlined),
                        title: Text(variety.name),
                        subtitle: _buildSubtitle(variety),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget? _buildSubtitle(CropVariety variety) {
    final details = <String>[];

    if (variety.defaultPlantingMethod != null) {
      details.add(
        _formatPlantingMethod(
          variety.defaultPlantingMethod!,
        ),
      );
    }

    if (variety.plantSpacingCm != null) {
      details.add('${variety.plantSpacingCm} cm tra le piante');
    }

    if (variety.harvestDays != null) {
      details.add('${variety.harvestDays} giorni al raccolto');
    }

    if (details.isEmpty) {
      return null;
    }

    return Text(details.join(' · '));
  }

  String _formatPlantingMethod(String value) {
    switch (value) {
      case 'sowing':
        return 'Semina';
      case 'transplant':
        return 'Trapianto';
      case 'broadcast':
        return 'Semina a spaglio';
      default:
        return value;
    }
  }
}

class _VarietiesPageData {
  final List<Crop> crops;
  final List<CropVariety> varieties;

  const _VarietiesPageData({
    required this.crops,
    required this.varieties,
  });
}