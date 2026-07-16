import 'package:flutter/material.dart';

import '../data/models/garden.dart';
import '../data/repositories/garden_repository.dart';
import '../widgets/garden/garden_map.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  final GardenRepository _repository = GardenRepository();

  late Future<Garden?> _gardenFuture;

  @override
  void initState() {
    super.initState();
    _gardenFuture = _repository.getGarden();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Garden?>(
      future: _gardenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Errore:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final garden = snapshot.data;

        if (garden == null) {
          return const Center(
            child: Text(
              'Nessun orto trovato.',
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garden.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (garden.description != null &&
                      garden.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(garden.description!),
                  ],

                  const SizedBox(height: 24),

                  Text(
                    'Numero aiuole: ${garden.bedsCount}',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Dimensioni aiuola: ${garden.bedWidthCm} × ${garden.bedLengthCm} cm',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Larghezza sentiero: ${garden.pathWidthCm} cm',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  const SizedBox(height: 16),

                  const Text(
                    'Aiuole',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GardenMap(
                    bedsCount: garden.bedsCount,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}