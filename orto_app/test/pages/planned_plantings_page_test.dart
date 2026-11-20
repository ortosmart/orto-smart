import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/pages/planned_plantings_page.dart';

void main() {
  const seasonId = 'season-2026';

  PlannedPlantingRepository repository(
    Future<List<Map<String, dynamic>>> Function(String) loader,
  ) {
    return PlannedPlantingRepository.withProviders(
      (_, _) async => <String, dynamic>{},
      null,
      loadPlannedPlantings: loader,
    );
  }

  Future<void> showPage(
    WidgetTester tester,
    PlannedPlantingRepository repo,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlannedPlantingsPage(
          seasonId: seasonId,
          seasonName: '2026 - Corrente',
          repository: repo,
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while fetching planned plantings', (
    tester,
  ) async {
    final completer = Completer<List<Map<String, dynamic>>>();

    await showPage(tester, repository((_) => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows season title and empty state', (tester) async {
    await showPage(tester, repository((_) async => []));

    await tester.pumpAndSettle();

    expect(find.text('Pianificazioni - 2026 - Corrente'), findsOneWidget);
    expect(
      find.text('Nessuna pianificazione presente per questa stagione.'),
      findsOneWidget,
    );
  });

  testWidgets('shows generic error and retry button', (tester) async {
    await showPage(
      tester,
      repository((_) async => throw StateError('Database unavailable')),
    );

    await tester.pumpAndSettle();

    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('Database unavailable'), findsNothing);
  });

  testWidgets('shows a populated planned plantings list', (tester) async {
    await showPage(
      tester,
      repository((requestedSeasonId) async {
        expect(requestedSeasonId, seasonId);

        return [
          <String, dynamic>{
            'id': '11111111-1111-4111-8111-111111111111',
            'season_plan_id': '22222222-2222-4222-8222-222222222222',
            'profile_id': '33333333-3333-4333-8333-333333333333',
            'garden_id': '44444444-4444-4444-8444-444444444444',
            'season_id': seasonId,
            'bed_id': '66666666-6666-4666-8666-666666666666',
            'crop_id': '77777777-7777-4777-8777-777777777777',
            'cultivar_id': '88888888-8888-4888-8888-888888888888',
            'start_method': 'direct_rows',
            'planned_start_date': '2026-11-20',
            'planned_end_date': '2026-12-20',
            'start_position_cm': 100,
            'length_cm': 250,
            'occupied_width_cm': 40,
            'plant_spacing_cm': 30,
            'row_spacing_cm': 40,
            'rows_count': 2,
            'plants_count': 8,
            'seed_quantity_g': 12.5,
            'status': 'draft',
            'executed_planting_id': null,
            'notes': 'Pianificazione di test',
            'created_at': '2026-11-19T10:00:00+00:00',
            'updated_at': '2026-11-19T10:30:00+00:00',
            'row_version': 3,
          },
        ];
      }),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pianificazione del 20/11/2026'), findsOneWidget);
    expect(find.text('Stato: Bozza'), findsOneWidget);
    expect(find.text('Posizione: 100 cm - Lunghezza: 250 cm'), findsOneWidget);
    expect(
      find.text('Nessuna pianificazione presente per questa stagione.'),
      findsNothing,
    );
  });
  testWidgets('retry reloads planned plantings after an error', (tester) async {
    var calls = 0;

    await showPage(
      tester,
      repository((_) async {
        calls++;

        if (calls == 1) {
          throw StateError('Temporary failure');
        }

        return <Map<String, dynamic>>[];
      }),
    );

    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('Riprova'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(
      find.text('Nessuna pianificazione presente per questa stagione.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsNothing);
  });
}
