import 'dart:async';

import 'package:flutter/material.dart';

import '../core/profile/profile_context.dart';
import '../core/profile/profile_context_scope.dart';
import '../core/write_authority/planning_route_lifetime.dart';
import '../core/write_authority/profile_edit_lock.dart';
import '../core/write_authority/profile_write_authority_controller.dart';
import '../core/write_authority/profile_write_authority_scope.dart';
import '../core/write_authority/route_write_availability.dart';
import 'create_garden_page.dart';
import 'seasons_page.dart';
import '../data/models/garden.dart';
import '../data/repositories/bed_repository.dart';
import '../data/repositories/garden_repository.dart';
import '../data/repositories/planned_planting_repository.dart';
import '../data/repositories/season_repository.dart';
import '../widgets/garden/garden_map.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';

class GardenPage extends StatefulWidget {
  final GardenRepository? repository;
  final BedRepository? bedRepository;
  final PlantingRepository? plantingRepository;
  final SeasonRepository? seasonRepository;
  final PlannedPlantingRepository? plannedPlantingRepository;
  final PlannedPlantingRpcInvoker? plannedPlantingRpcInvoker;
  final PlannedPlantingListLoader? plannedPlantingListLoader;

  const GardenPage({
    super.key,
    this.repository,
    this.bedRepository,
    this.plantingRepository,
    this.seasonRepository,
    this.plannedPlantingRepository,
    this.plannedPlantingRpcInvoker,
    this.plannedPlantingListLoader,
  }) : assert(
         (plannedPlantingRpcInvoker == null) ==
             (plannedPlantingListLoader == null),
         'Both planning transport providers must be supplied together.',
       );

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late GardenRepository _repository;
  ProfileWriteAuthorityController? _writeAuthority;
  bool _creationPageOpen = false;

  final Set<RouteWriteAvailability> _planningRouteAvailabilities = {};
  bool _planningRouteRefreshScheduled = false;
  bool _planningRouteContextDisposed = false;

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
      _repository =
          widget.repository ??
          GardenRepository(
            requireLeaseForWrite: _writeAuthority?.requireLeaseForWrite,
          );
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
    final authority = ProfileWriteAuthorityScope.maybeOf(context);
    final authorityChanged = !identical(authority, _writeAuthority);

    _writeAuthority = authority;

    if (authorityChanged && widget.repository == null) {
      _repository = GardenRepository(
        requireLeaseForWrite: authority?.requireLeaseForWrite,
      );
    }

    if (_profileId != profile.profileId) {
      _profileId = profile.profileId;
      _selectedGardenId = null;
      _gardensFuture = _repository.getGardens(profileId: profile.profileId);
    } else if (authorityChanged && widget.repository == null) {
      _gardensFuture = _repository.getGardens(profileId: profile.profileId);
    }

    _schedulePlanningRouteRefresh();
  }

  void _schedulePlanningRouteRefresh() {
    if (_planningRouteRefreshScheduled ||
        _planningRouteAvailabilities.isEmpty) {
      return;
    }

    _planningRouteRefreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _planningRouteRefreshScheduled = false;

      for (final availability in _planningRouteAvailabilities.toList()) {
        if (_planningRouteAvailabilities.contains(availability)) {
          availability.refresh();
        }
      }
    });

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _planningRouteContextDisposed = true;
    _schedulePlanningRouteRefresh();
    super.dispose();
  }

  PlannedPlantingRepository _createPlanningRouteRepository({
    required bool readOnly,
    required PlannedPlantingWriteAuthorityProvider requireLeaseForWrite,
  }) {
    final rpcInvoker = widget.plannedPlantingRpcInvoker;
    final listLoader = widget.plannedPlantingListLoader;
    final injectedRepository = widget.plannedPlantingRepository;

    if ((rpcInvoker == null) != (listLoader == null)) {
      throw StateError(
        'Both planning transport providers must be supplied together.',
      );
    }

    if (rpcInvoker != null && injectedRepository != null) {
      throw StateError(
        'Planning repository and transport providers cannot be combined.',
      );
    }

    if (rpcInvoker != null && listLoader != null) {
      final repository = PlannedPlantingRepository.withProviders(
        rpcInvoker,
        readOnly ? null : requireLeaseForWrite,
        loadPlannedPlantings: listLoader,
      );

      return readOnly ? repository.asReadOnly() : repository;
    }

    if (readOnly) {
      return injectedRepository?.asReadOnly() ??
          PlannedPlantingRepository.readOnly();
    }

    return PlannedPlantingRepository(
      requireLeaseForWrite: requireLeaseForWrite,
      mutationService: context
          .getInheritedWidgetOfExactType<ProfileWriteAuthorityScope>()
          ?.seasonalPlanningMutations,
    );
  }

  bool _isPlanningRouteContextValid({
    required ProfileWriteAuthorityController? authority,
    required String? profileId,
  }) {
    if (_planningRouteContextDisposed ||
        !mounted ||
        authority == null ||
        profileId == null) {
      return false;
    }

    if (!identical(_writeAuthority, authority) || _profileId != profileId) {
      return false;
    }

    try {
      final activeProfile = ProfileContextScope.read(context);

      return identical(ProfileWriteAuthorityScope.read(context), authority) &&
          activeProfile.profileId == profileId &&
          activeProfile.role == ProfileMemberRole.owner;
    } on Object {
      return false;
    }
  }

  Future<void> _openCreateGarden() async {
    final profileId = _profileId;
    final authority = _writeAuthority;
    final repository = _repository;

    if (_creationPageOpen || profileId == null || authority == null) {
      return;
    }

    try {
      final lease = authority.requireLeaseForWrite();
      if (lease.profileId != profileId) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
    } on ProfileWriteAuthorityUnavailableException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Autorit\u00E0 di scrittura non disponibile per questo profilo.',
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
          builder: (_) => CreateGardenPage(
            profileId: profileId,
            repository: repository,
            authority: authority,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creationPageOpen = false;
          if (_profileId == profileId &&
              identical(_repository, repository) &&
              identical(_writeAuthority, authority)) {
            _gardensFuture = repository.getGardens(profileId: profileId);
          }
        });
      }
    }
  }

  Widget _createGardenControl() {
    final authority = _writeAuthority;

    Widget buildControl() {
      final canWrite = authority?.canWrite ?? false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: canWrite && !_creationPageOpen
                ? _openCreateGarden
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Crea orto'),
          ),
          if (!canWrite) ...[
            const SizedBox(height: 8),
            const Text(
              'Creazione non disponibile: '
              'autorit\u00E0 di scrittura non attiva.',
            ),
          ],
        ],
      );
    }

    if (authority == null) {
      return buildControl();
    }

    return AnimatedBuilder(
      animation: authority,
      builder: (context, child) => buildControl(),
    );
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
                    'Non \u00E8 stato possibile caricare gli orti.',
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nessun orto trovato per questo profilo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  _createGardenControl(),
                ],
              ),
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
              _createGardenControl(),
              const SizedBox(height: 16),
              if (gardens.length > 1) ...[
                const Text(
                  'Seleziona un orto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: garden?.id,
                  hint: const Text('Scegli l\u2019orto da visualizzare'),
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
                        OutlinedButton.icon(
                          onPressed: () {
                            final authority = _writeAuthority;
                            final profileId = _profileId;
                            final currentProfile = ProfileContextScope.of(
                              context,
                            );
                            ProfileEditLockLease? initialLease;
                            if (authority != null &&
                                profileId != null &&
                                currentProfile.profileId == profileId &&
                                currentProfile.canWrite) {
                              try {
                                initialLease = authority.requireLeaseForWrite();
                              } on ProfileWriteAuthorityUnavailableException {
                                initialLease = null;
                              }
                            }
                            final initialIdentity = initialLease?.identity;
                            final initialToken = initialLease?.lockToken;

                            MaterialPageRoute<void>? originatingRoute;

                            final writeAvailability = RouteWriteAvailability(
                              authority: authority,
                              originalLease: initialLease,
                              isContextValid: () =>
                                  (originatingRoute?.isActive ?? true) &&
                                  initialLease?.profileId == profileId &&
                                  _isPlanningRouteContextValid(
                                    authority: authority,
                                    profileId: profileId,
                                  ),
                            );

                            final lifetime = PlanningRouteLifetime(
                              availability: writeAvailability,
                            );

                            late final MaterialPageRoute<void> route;

                            try {
                              final seasonRepository = widget.seasonRepository;

                              final planningReadOnly =
                                  !writeAvailability.canWrite ||
                                  initialLease == null ||
                                  initialIdentity == null ||
                                  initialToken == null ||
                                  profileId == null ||
                                  initialLease.profileId != profileId;

                              if (planningReadOnly) {
                                writeAvailability.invalidate();
                              }

                              final plannedRepository = _createPlanningRouteRepository(
                                readOnly: planningReadOnly,
                                requireLeaseForWrite: () {
                                  if (initialIdentity == null ||
                                      !writeAvailability.canWrite ||
                                      !_isPlanningRouteContextValid(
                                        authority: authority,
                                        profileId: profileId,
                                      )) {
                                    throw const ProfileWriteAuthorityUnavailableException();
                                  }
                                  final currentLease = authority!
                                      .requireLeaseForWrite();
                                  if (currentLease.profileId != profileId ||
                                      currentLease.lockToken != initialToken ||
                                      currentLease.identity.clientInstanceId !=
                                          initialIdentity.clientInstanceId ||
                                      currentLease.identity.sessionId !=
                                          initialIdentity.sessionId) {
                                    throw const ProfileWriteAuthorityUnavailableException();
                                  }
                                  return currentLease;
                                },
                              );
                              route = MaterialPageRoute<void>(
                                builder: (_) => SeasonsPage(
                                  gardenId: garden.id,
                                  gardenName: garden.name,
                                  repository: seasonRepository,
                                  plannedPlantingRepository: plannedRepository,
                                  writeAvailability: writeAvailability,
                                  planningRouteLifetime: lifetime,
                                ),
                              );

                              _planningRouteAvailabilities.add(
                                writeAvailability,
                              );

                              Navigator.of(context).push(route);
                            } on Object {
                              _planningRouteAvailabilities.remove(
                                writeAvailability,
                              );
                              lifetime.close();
                              rethrow;
                            }

                            originatingRoute = route;

                            unawaited(
                              route.popped.then<void>((_) {
                                writeAvailability.invalidate();
                              }),
                            );

                            unawaited(
                              route.completed.then<void>((_) {
                                _planningRouteAvailabilities.remove(
                                  writeAvailability,
                                );
                                lifetime.close();
                              }),
                            );

                            try {
                              writeAvailability.refresh();
                            } on Object {
                              writeAvailability.invalidate();
                              rethrow;
                            }
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Stagioni'),
                        ),
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
                          plantingRepository: widget.plantingRepository,
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
