import 'package:flutter/material.dart';

import '../data/models/planned_planting.dart';
import '../data/repositories/planned_planting_repository.dart';

class PlannedPlantingsPage extends StatefulWidget {
  final String seasonId;
  final String seasonName;
  final PlannedPlantingRepository repository;

  const PlannedPlantingsPage({
    super.key,
    required this.seasonId,
    required this.seasonName,
    required this.repository,
  });

  @override
  State<PlannedPlantingsPage> createState() => _PlannedPlantingsPageState();
}

class _PlannedPlantingsPageState extends State<PlannedPlantingsPage> {
  late Future<List<PlannedPlanting>> _plantingsFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pianificazioni - ${widget.seasonName}')),
      body: FutureBuilder<List<PlannedPlanting>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantings.length,
            itemBuilder: (context, index) {
              final planting = plantings[index];

              return Card(
                child: ListTile(
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
      ),
    );
  }
}
