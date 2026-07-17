import 'package:flutter/material.dart';

import '../../data/models/bed.dart';
import '../../data/repositories/bed_repository.dart';
import '../../pages/bed_page.dart';
import 'bed_card.dart';

class GardenMap extends StatefulWidget {
  const GardenMap({super.key});

  @override
  State<GardenMap> createState() => _GardenMapState();
}

class _GardenMapState extends State<GardenMap> {
  final BedRepository _repository = BedRepository();

  late Future<List<Bed>> _bedsFuture;

  @override
  void initState() {
    super.initState();
    _bedsFuture = _repository.getBeds();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bed>>(
      future: _bedsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Errore nel caricamento delle aiuole:\n'
              '${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final beds = snapshot.data ?? [];

        if (beds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('Nessuna aiuola trovata.'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: beds.length,
          itemBuilder: (context, index) {
            final bed = beds[index];

            return BedCard(
              bed: bed,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BedPage(
                      bedNumber: bed.number,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}