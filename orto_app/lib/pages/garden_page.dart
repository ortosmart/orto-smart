import 'package:flutter/material.dart';

import '../core/profile/profile_context_scope.dart';
import '../data/models/garden.dart';
import '../data/repositories/bed_repository.dart';
import '../data/repositories/garden_repository.dart';
import '../widgets/garden/garden_map.dart';

class GardenPage extends StatefulWidget {
  final GardenRepository? repository;
  final BedRepository? bedRepository;

  const GardenPage({super.key, this.repository, this.bedRepository});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late GardenRepository _repository;

  String? _profileId;
  String? _selectedGardenId;
  late Future<List<Garden>> _gardensFuture;

  @override
  void initState() {
    super.initState();

    _repository = widget.repository ?? GardenRepository();
  }

  @override
  void didUpdateWidget(covariant GardenPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.repository, widget.repository)) {
      _repository = widget.repository ?? GardenRepository();
      _selectedGardenId = null;

      final profileId = _profileId;

      if (profileId != null) {
        _gardensFuture = _repository.getGardens(profileId: profileId);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final profile = ProfileContextScope.of(context);

    if (_profileId != profile.profileId) {
      _profileId = profile.profileId;
      _selectedGardenId = null;
      _gardensFuture = _repository.getGardens(profileId: profile.profileId);
    }
  }

  void _retry() {
    final profileId = _profileId;

    if (profileId == null) {
      return;
    }

    setState(() {
      _gardensFuture = _repository.getGardens(profileId: profileId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Garden>>(
      key: ValueKey(_profileId),
      future: _gardensFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Non è stato possibile caricare gli orti.',
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
            ),
          );
        }

        final gardens = snapshot.data ?? [];

        if (gardens.isEmpty) {
          return const Center(
            child: Text(
              'Nessun orto trovato per questo profilo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        Garden? selectedGarden;

        if (gardens.length == 1) {
          selectedGarden = gardens.single;
        } else {
          for (final garden in gardens) {
            if (garden.id == _selectedGardenId) {
              selectedGarden = garden;
              break;
            }
          }
        }

        final garden = selectedGarden;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (gardens.length > 1) ...[
                const Text(
                  'Seleziona un orto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: garden?.id,
                  hint: const Text('Scegli l’orto da visualizzare'),
                  items: [
                    for (final item in gardens)
                      DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(
                          item.isActive
                              ? item.name
                              : '${item.name} (disabilitato)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (gardenId) {
                    setState(() {
                      _selectedGardenId = gardenId;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (garden == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Seleziona un orto per visualizzarne le aiuole.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Card(
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
                        if (!garden.isActive) ...[
                          const SizedBox(height: 8),
                          const Text('Orto disabilitato'),
                        ],
                        if (garden.description != null &&
                            garden.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(garden.description!),
                        ],
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
                          key: ValueKey(garden.id),
                          gardenId: garden.id,
                          profileId: _profileId,
                          repository: widget.bedRepository,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
