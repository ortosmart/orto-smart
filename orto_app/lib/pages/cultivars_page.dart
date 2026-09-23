import 'package:flutter/material.dart';

import '../data/models/crop.dart';
import '../data/models/crop_cultivar.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/crop_cultivar_repository.dart';

class CultivarsPage extends StatefulWidget {
  const CultivarsPage({super.key});

  @override
  State<CultivarsPage> createState() => _CultivarsPageState();
}

class _CultivarsPageState extends State<CultivarsPage> {
  final CropRepository _cropRepository = CropRepository();
  final CropCultivarRepository _cultivarRepository = CropCultivarRepository();

  late Future<_CultivarsPageData> _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _pageDataFuture = _fetchData();
  }

  Future<_CultivarsPageData> _fetchData() async {
    final results = await Future.wait([
      _cropRepository.getCrops(),
      _cultivarRepository.getAllCultivars(),
    ]);

    return _CultivarsPageData(
      crops: results[0] as List<Crop>,
      cultivars: results[1] as List<CropCultivar>,
    );
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _pageDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Varietà')),
      body: FutureBuilder<_CultivarsPageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
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

          if (data.cultivars.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.eco_outlined, size: 64),
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
                      'Il catalogo globale non contiene ancora cultivar.',
                    ),
                  ),
                ],
              ),
            );
          }

          final cropsById = {for (final crop in data.crops) crop.id: crop};

          final cultivarsByCrop = <String, List<CropCultivar>>{};

          for (final cultivar in data.cultivars) {
            final cropId = cultivar.cropId.toString();

            cultivarsByCrop.putIfAbsent(cropId, () => []).add(cultivar);
          }

          final cropIds = cultivarsByCrop.keys.toList()
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
                final cultivars = cultivarsByCrop[cropId] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(child: Icon(Icons.grass)),
                    title: Text(
                      crop?.name ?? 'Coltura sconosciuta',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${cultivars.length} varietà'),
                    children: cultivars.map((cultivar) {
                      return ListTile(
                        leading: const Icon(Icons.eco_outlined),
                        title: Text(cultivar.name),
                        subtitle: _buildSubtitle(cultivar),
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

  Widget? _buildSubtitle(CropCultivar cultivar) {
    final details = <String>[];

    if (cultivar.verificationStatus != 'VERIFIED') {
      details.add(cultivar.verificationStatus);
    }

    if (cultivar.description != null) {
      details.add(cultivar.description!);
    }

    if (details.isEmpty) {
      return null;
    }

    return Text(details.join(' · '));
  }
}

class _CultivarsPageData {
  final List<Crop> crops;
  final List<CropCultivar> cultivars;

  const _CultivarsPageData({required this.crops, required this.cultivars});
}
