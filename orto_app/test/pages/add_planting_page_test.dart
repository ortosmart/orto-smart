import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/models/bed.dart';
import 'package:orto_app/data/models/bed_geometry.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/crop_association.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/data/repositories/crop_association_repository.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/data/repositories/season_repository.dart';
import 'package:orto_app/pages/add_planting_page.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _bedId = '33333333-3333-4333-8333-333333333333';
const _cropId = '44444444-4444-4444-8444-444444444444';
const _seasonId = '55555555-5555-4555-8555-555555555555';

class _ScheduledTask implements ScheduledWriteAuthorityTask {
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  void cancel() {
    _active = false;
  }
}

class _Scheduler implements WriteAuthorityScheduler {
  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    return _ScheduledTask();
  }
}

class _CropRepositoryFake extends Fake implements CropRepository {
  @override
  Future<List<Crop>> getCrops({bool activeOnly = true}) async {
    return const [
      Crop(
        id: _cropId,
        profileId: _profileId,
        name: 'Pomodoro',
        defaultStartMethod: 'direct_rows',
        rowSpacingCm: 40,
        plantSpacingCm: 30,
        isActive: true,
        rowVersion: 1,
      ),
    ];
  }
}

class _CropAssociationRepositoryFake extends Fake
    implements CropAssociationRepository {
  @override
  Future<List<CropAssociation>> getAllAssociations() async {
    return const [];
  }
}

class _SeasonRepositoryFake extends Fake implements SeasonRepository {}

Bed _bed() {
  return Bed(
    id: _bedId,
    gardenId: _gardenId,
    number: 1,
    name: 'Aiuola test',
    isActive: true,
    rowVersion: 1,
    geometry: BedGeometry(
      id: '66666666-6666-4666-8666-666666666666',
      bedId: _bedId,
      widthCm: 90,
      lengthCm: 700,
      validFrom: DateTime.utc(2026, 1, 1),
      rowVersion: 1,
    ),
  );
}

Planting _directRowsPlanting({
  int rowsCount = 2,
  int rowSpacingCm = 40,
  int? plantsCount = 5,
  int? plantSpacingCm = 30,
  int lengthCm = 200,
}) {
  return Planting(
    id: '77777777-7777-4777-8777-777777777777',
    profileId: _profileId,
    gardenId: _gardenId,
    seasonId: _seasonId,
    bedId: _bedId,
    cropId: _cropId,
    cultivarId: null,
    startMethod: 'direct_rows',
    startDate: DateTime(2026, 9, 15),
    endDate: null,
    startPositionCm: 0,
    lengthCm: lengthCm,
    plantSpacingCm: plantSpacingCm,
    rowSpacingCm: rowSpacingCm,
    rowsCount: rowsCount,
    occupiedWidthCm: (rowsCount - 1) * rowSpacingCm,
    plantsCount: plantsCount,
    seedQuantityG: null,
    status: 'sown',
    notes: null,
    createdAt: DateTime.utc(2026, 9, 15, 8),
    updatedAt: DateTime.utc(2026, 9, 15, 8),
    rowVersion: 1,
  );
}

Finder _field(String label) {
  return find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    ),
    matching: find.byType(TextFormField),
  );
}

Future<void> _submit(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final button = find.byType(FilledButton);

  await Scrollable.ensureVisible(
    tester.element(button.last),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();

  await tester.tap(button.last);
  await tester.pumpAndSettle();
}

void main() {
  late ProfileWriteAuthorityController authority;
  late PlantingRepository plantingRepository;

  setUp(() async {
    final now = DateTime.utc(2026, 9, 16, 12);

    plantingRepository = PlantingRepository.withLoader(
      (_) async => <Map<String, dynamic>>[],
    );

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-add-planting-test',
          'expires_at': '2026-09-16T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: _profileId,
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '88888888-8888-4888-8888-888888888888',
        sessionId: '99999999-9999-4999-8999-999999999999',
      ),
    );
  });

  Future<void> openPage(WidgetTester tester, {Planting? planting}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddPlantingPage(
          bed: _bed(),
          planting: planting ?? _directRowsPlanting(),
          repository: plantingRepository,
          authority: authority,
          cropRepository: _CropRepositoryFake(),
          associationRepository: _CropAssociationRepositoryFake(),
          seasonRepository: _SeasonRepositoryFake(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('date picker does not allow dates after today', (tester) async {
    await openPage(tester);

    final dateLabel = find.text('Data');

    await Scrollable.ensureVisible(
      tester.element(dateLabel),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();

    final dateInkWell = find.ancestor(
      of: dateLabel,
      matching: find.byType(InkWell),
    );

    expect(dateInkWell, findsOneWidget);

    await tester.tap(dateInkWell);
    await tester.pumpAndSettle();

    final calendarFinder = find.byType(CalendarDatePicker);

    expect(calendarFinder, findsOneWidget);

    final calendar = tester.widget<CalendarDatePicker>(calendarFinder);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    expect(calendar.lastDate, today);
  });

  testWidgets('rows wider than bed are rejected by form validation', (
    tester,
  ) async {
    await openPage(tester);

    await tester.enterText(_field('Numero di file'), '4');
    await tester.enterText(_field('Tra le file'), '40');

    await _submit(tester);

    expect(
      find.text('Le file richiedono 120 cm, ma l\'aiuola è larga 90 cm'),
      findsOneWidget,
    );
  });

  testWidgets('plant spacing cannot require more than occupied length', (
    tester,
  ) async {
    await openPage(tester);

    await tester.enterText(_field('Numero di piante (facoltativo)'), '5');
    await tester.enterText(
      _field('Distanza tra le piante (facoltativa)'),
      '30',
    );
    await tester.enterText(_field('Lunghezza occupata'), '100');

    await _submit(tester);

    expect(find.text('Le piante richiedono almeno 120 cm'), findsOneWidget);
  });

  testWidgets('calculation card keeps plants per row informational', (
    tester,
  ) async {
    await openPage(
      tester,
      planting: _directRowsPlanting(
        rowsCount: 2,
        plantsCount: 5,
        plantSpacingCm: 30,
        lengthCm: 200,
      ),
    );

    expect(find.text('Piante per fila'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('200 cm'), findsWidgets);
  });
}
