import 'package:flutter/material.dart';

import '../../core/write_authority/profile_write_authority_controller.dart';
import '../../core/write_authority/profile_write_authority_scope.dart';
import '../../data/models/bed.dart';
import '../../data/repositories/bed_repository.dart';
import '../../data/repositories/crop_association_repository.dart';
import '../../data/repositories/crop_repository.dart';
import '../../data/repositories/planting_repository.dart';
import '../../pages/bed_page.dart';
import '../../pages/create_bed_page.dart';
import 'bed_card.dart';

class GardenMap extends StatefulWidget {
  final String? profileId;
  final String gardenId;
  final BedRepository? repository;
  final PlantingRepository? plantingRepository;
  final CropRepository? cropRepository;
  final CropAssociationRepository? cropAssociationRepository;

  const GardenMap({
    super.key,
    this.profileId,
    required this.gardenId,
    this.repository,
    this.plantingRepository,
    this.cropRepository,
    this.cropAssociationRepository,
  });

  @override
  State<GardenMap> createState() => _GardenMapState();
}

class _GardenMapState extends State<GardenMap> {
  late BedRepository _repository;
  late Future<List<Bed>> _bedsFuture;

  ProfileWriteAuthorityController? _writeAuthority;
  bool _repositoryInitialized = false;
  bool _creationPageOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authority = ProfileWriteAuthorityScope.maybeOf(context);
    final authorityChanged = !identical(authority, _writeAuthority);

    _writeAuthority = authority;

    if (!_repositoryInitialized ||
        (authorityChanged && widget.repository == null)) {
      _repository =
          widget.repository ??
          BedRepository(requireLeaseForWrite: authority?.requireLeaseForWrite);

      _repositoryInitialized = true;
      _bedsFuture = _repository.getBeds(gardenId: widget.gardenId);
    }
  }

  @override
  void didUpdateWidget(covariant GardenMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final repositoryChanged = !identical(
      oldWidget.repository,
      widget.repository,
    );

    if (repositoryChanged) {
      _repository =
          widget.repository ??
          BedRepository(
            requireLeaseForWrite: _writeAuthority?.requireLeaseForWrite,
          );
    }

    if (oldWidget.profileId != widget.profileId ||
        oldWidget.gardenId != widget.gardenId ||
        repositoryChanged) {
      _bedsFuture = _repository.getBeds(gardenId: widget.gardenId);
    }
  }

  void _retry() {
    setState(() {
      _bedsFuture = _repository.getBeds(gardenId: widget.gardenId);
    });
  }

  Future<void> _openCreateBed() async {
    final profileId = widget.profileId;
    final gardenId = widget.gardenId;
    final authority = _writeAuthority;
    final repository = _repository;

    if (_creationPageOpen ||
        profileId == null ||
        profileId.trim().isEmpty ||
        authority == null) {
      return;
    }

    try {
      final lease = authority.requireLeaseForWrite();

      if (lease.profileId != profileId) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
    } on ProfileWriteAuthorityUnavailableException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Autorità di scrittura non disponibile per questo profilo.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _creationPageOpen = true;
    });

    try {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CreateBedPage(
            profileId: profileId,
            gardenId: gardenId,
            repository: repository,
            authority: authority,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creationPageOpen = false;

          // Rileggiamo anche dopo un esito incerto, ma senza
          // aggiornare un contesto diverso da quello di partenza.
          if (widget.profileId == profileId &&
              widget.gardenId == gardenId &&
              identical(_repository, repository) &&
              identical(_writeAuthority, authority)) {
            _bedsFuture = repository.getBeds(gardenId: gardenId);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bed>>(
      key: ValueKey((widget.profileId, widget.gardenId)),
      future: _bedsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Non è stato possibile caricare le aiuole.',
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

        final beds = List<Bed>.of(snapshot.data ?? const <Bed>[])
          ..sort((a, b) => a.number.compareTo(b.number));

        final hasProfile = widget.profileId?.trim().isNotEmpty == true;
        final canCreate =
            hasProfile &&
            (_writeAuthority?.canWrite ?? false) &&
            !_creationPageOpen;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasProfile) ...[
              FilledButton.icon(
                onPressed: canCreate ? _openCreateBed : null,
                icon: const Icon(Icons.add),
                label: const Text('Crea aiuola'),
              ),
              if (!(_writeAuthority?.canWrite ?? false)) ...[
                const SizedBox(height: 8),
                const Text(
                  'Creazione non disponibile: '
                  'autorità di scrittura non attiva.',
                ),
              ],
              const SizedBox(height: 12),
            ],
            if (beds.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Nessuna aiuola abilitata in questo orto.'),
                ),
              )
            else
              ListView.builder(
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
                            bed: bed,
                            repository: _repository,
                            plantingRepository: widget.plantingRepository,
                            cropRepository: widget.cropRepository,
                            cropAssociationRepository:
                                widget.cropAssociationRepository,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
