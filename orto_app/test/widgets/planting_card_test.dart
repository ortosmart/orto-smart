import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/widgets/planting_card.dart';

Planting _planting(String status) {
  final terminal = status == 'finished' || status == 'removed';

  return Planting(
    id: '11111111-1111-4111-8111-111111111111',
    profileId: '22222222-2222-4222-8222-222222222222',
    gardenId: '33333333-3333-4333-8333-333333333333',
    seasonId: '44444444-4444-4444-8444-444444444444',
    bedId: '55555555-5555-4555-8555-555555555555',
    cropId: '66666666-6666-4666-8666-666666666666',
    varietyId: null,
    startMethod: 'direct_rows',
    startDate: DateTime(2026, 9, 1),
    endDate: terminal ? DateTime(2026, 9, 17) : null,
    startPositionCm: 0,
    lengthCm: 100,
    plantSpacingCm: null,
    rowSpacingCm: 30,
    rowsCount: 2,
    occupiedWidthCm: 30,
    plantsCount: null,
    seedQuantityG: null,
    status: status,
    notes: null,
    createdAt: DateTime.utc(2026, 9, 1, 8),
    updatedAt: DateTime.utc(2026, 9, 1, 8),
    rowVersion: 1,
  );
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required String status,
  VoidCallback? onEdit,
  ValueChanged<String>? onStatusChange,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PlantingCard(
          planting: _planting(status),
          crop: null,
          onEdit: onEdit ?? () {},
          onStatusChange: onStatusChange ?? (_) {},
        ),
      ),
    ),
  );
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<PlantingCardAction>));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sown offers growing and removed actions', (tester) async {
    await _pumpCard(tester, status: 'sown');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Segna in crescita'), findsOneWidget);
    expect(find.text('Rimuovi'), findsOneWidget);

    expect(find.text('Segna pronta alla raccolta'), findsNothing);
    expect(find.text('Segna raccolta'), findsNothing);
    expect(find.text('Termina coltivazione'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('growing offers harvest ready and removed actions', (
    tester,
  ) async {
    await _pumpCard(tester, status: 'growing');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Segna pronta alla raccolta'), findsOneWidget);
    expect(find.text('Rimuovi'), findsOneWidget);

    expect(find.text('Segna in crescita'), findsNothing);
    expect(find.text('Segna raccolta'), findsNothing);
    expect(find.text('Termina coltivazione'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('harvest_ready offers harvested and removed actions', (
    tester,
  ) async {
    await _pumpCard(tester, status: 'harvest_ready');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Segna raccolta'), findsOneWidget);
    expect(find.text('Rimuovi'), findsOneWidget);

    expect(find.text('Segna in crescita'), findsNothing);
    expect(find.text('Segna pronta alla raccolta'), findsNothing);
    expect(find.text('Termina coltivazione'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('harvested offers finished and removed actions', (tester) async {
    await _pumpCard(tester, status: 'harvested');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Termina coltivazione'), findsOneWidget);
    expect(find.text('Rimuovi'), findsOneWidget);

    expect(find.text('Segna in crescita'), findsNothing);
    expect(find.text('Segna pronta alla raccolta'), findsNothing);
    expect(find.text('Segna raccolta'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('finished has no lifecycle actions', (tester) async {
    await _pumpCard(tester, status: 'finished');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Rimuovi'), findsNothing);
    expect(find.text('Termina coltivazione'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('removed has no lifecycle actions', (tester) async {
    await _pumpCard(tester, status: 'removed');
    await _openMenu(tester);

    expect(find.text('Modifica'), findsOneWidget);
    expect(find.text('Rimuovi'), findsNothing);
    expect(find.text('Termina coltivazione'), findsNothing);
    expect(find.text('Elimina'), findsNothing);
  });

  testWidgets('lifecycle action reports target status', (tester) async {
    String? requestedStatus;

    await _pumpCard(
      tester,
      status: 'growing',
      onStatusChange: (status) {
        requestedStatus = status;
      },
    );

    await _openMenu(tester);
    await tester.tap(find.text('Segna pronta alla raccolta'));
    await tester.pumpAndSettle();

    expect(requestedStatus, 'harvest_ready');
  });

  testWidgets('removed action reports removed target status', (tester) async {
    String? requestedStatus;

    await _pumpCard(
      tester,
      status: 'sown',
      onStatusChange: (status) {
        requestedStatus = status;
      },
    );

    await _openMenu(tester);
    await tester.tap(find.text('Rimuovi'));
    await tester.pumpAndSettle();

    expect(requestedStatus, 'removed');
  });
  testWidgets('harvested explains that the bed remains occupied', (
    tester,
  ) async {
    await _pumpCard(tester, status: 'harvested');

    expect(
      find.text(
        'L’aiuola resta occupata finché la coltivazione '
        'non viene terminata o rimossa.',
      ),
      findsOneWidget,
    );
  });
}
