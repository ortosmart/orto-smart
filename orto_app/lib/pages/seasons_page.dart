import 'package:flutter/material.dart';

import '../data/models/season.dart';
import '../data/repositories/season_repository.dart';

class SeasonsPage extends StatefulWidget {
  final String gardenId;
  final String gardenName;
  final SeasonRepository? repository;

  const SeasonsPage({
    super.key,
    required this.gardenId,
    required this.gardenName,
    this.repository,
  });

  @override
  State<SeasonsPage> createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
  late SeasonRepository _repository;
  late Future<List<Season>> _seasonsFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SeasonRepository();
    _loadSeasons();
  }

  void _loadSeasons() {
    _seasonsFuture = _repository.getSeasonsByGarden(
      gardenId: widget.gardenId,
    );
  }

  @override
  void didUpdateWidget(covariant SeasonsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.gardenId != widget.gardenId ||
        !identical(oldWidget.repository, widget.repository)) {
      _repository = widget.repository ?? SeasonRepository();
      _loadSeasons();
    }
  }

  void _retry() {
    setState(_loadSeasons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stagioni - ${widget.gardenName}'),
      ),
      body: FutureBuilder<List<Season>>(
        future: _seasonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Non è stato possibile caricare le stagioni.',
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

          final seasons = snapshot.data ?? [];

          if (seasons.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna stagione presente per questo orto.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];

              return Card(
                child: ListTile(
                  title: Text('${season.year} - ${season.name}'),
                  subtitle: Text(
                    season.isActive
                        ? 'Stagione attiva'
                        : 'Stagione non attiva',
                  ),
                  trailing: season.isActive
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
