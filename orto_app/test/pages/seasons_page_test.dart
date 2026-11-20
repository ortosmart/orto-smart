import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/season_repository.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/pages/planned_plantings_page.dart';
import 'package:orto_app/pages/seasons_page.dart';

void main() {
  const gardenId = 'garden-1';

  Map<String, dynamic> season({
    required String id,
    required int year,
    required String name,
    required bool active,
  }) {
    return {
      'id': id,
      'garden_id': gardenId,
      'year': year,
      'name': name,
      'start_date': '$year-01-01',
      'end_date': null,
      'is_active': active,
      'notes': null,
      'row_version': 1,
    };
  }

  SeasonRepository repository(
    Future<List<Map<String, dynamic>>> Function(String) loader,
  ) {
    return SeasonRepository.withProviders(
      (_) async => <String, dynamic>{},
      (_, _) async => <String, dynamic>{},
      null,
      loader,
    );
  }

  Future<void> showPage(WidgetTester tester, SeasonRepository repo) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SeasonsPage(
          gardenId: gardenId,
          gardenName: 'Orto principale',
          repository: repo,
        ),
      ),
    );
  }

  testWidgets('opens planned plantings for selected season', (tester) async {
    String? requestedSeasonId;

    final plannedRepository = PlannedPlantingRepository.withProviders(
      (_, _) async => <String, dynamic>{},
      null,
      loadPlannedPlantings: (seasonId) async {
        requestedSeasonId = seasonId;
        return <Map<String, dynamic>>[];
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SeasonsPage(
          gardenId: gardenId,
          gardenName: 'Orto principale',
          repository: repository(
            (_) async => [
              season(
                id: 'season-2026',
                year: 2026,
                name: 'Corrente',
                active: true,
              ),
            ],
          ),
          plannedPlantingRepository: plannedRepository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('2026 - Corrente'));
    await tester.pumpAndSettle();

    expect(find.byType(PlannedPlantingsPage), findsOneWidget);
    expect(find.text('Pianificazioni - 2026 - Corrente'), findsOneWidget);
    expect(requestedSeasonId, 'season-2026');
    expect(
      find.text('Nessuna pianificazione presente per questa stagione.'),
      findsOneWidget,
    );
  });
  testWidgets('shows loading indicator while fetching seasons', (tester) async {
    final completer = Completer<List<Map<String, dynamic>>>();

    await showPage(tester, repository((_) => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows garden name and available seasons', (tester) async {
    await showPage(
      tester,
      repository(
        (_) async => [
          season(
            id: 'season-2026',
            year: 2026,
            name: 'Stagione 2026',
            active: true,
          ),
          season(
            id: 'season-2025',
            year: 2025,
            name: 'Stagione 2025',
            active: false,
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stagioni - Orto principale'), findsOneWidget);
    expect(find.text('2026 - Stagione 2026'), findsOneWidget);
    expect(find.text('2025 - Stagione 2025'), findsOneWidget);
  });

  testWidgets('distinguishes active and inactive seasons', (tester) async {
    await showPage(
      tester,
      repository(
        (_) async => [
          season(id: 'season-2026', year: 2026, name: 'Corrente', active: true),
          season(
            id: 'season-2025',
            year: 2025,
            name: 'Precedente',
            active: false,
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stagione attiva'), findsOneWidget);
    expect(find.text('Stagione non attiva'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('shows empty state when no seasons exist', (tester) async {
    await showPage(tester, repository((_) async => []));

    await tester.pumpAndSettle();

    expect(
      find.text('Nessuna stagione presente per questo orto.'),
      findsOneWidget,
    );
  });

  testWidgets('shows generic error and retry button', (tester) async {
    await showPage(
      tester,
      repository((_) async => throw StateError('Database unavailable')),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Non è stato possibile caricare le stagioni.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('Database unavailable'), findsNothing);
  });

  testWidgets('retry reloads seasons after an error', (tester) async {
    var calls = 0;

    await showPage(
      tester,
      repository((_) async {
        calls++;

        if (calls == 1) {
          throw StateError('Temporary failure');
        }

        return [
          season(id: 'season-2026', year: 2026, name: 'Corrente', active: true),
        ];
      }),
    );

    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('Riprova'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('2026 - Corrente'), findsOneWidget);
    expect(find.text('Riprova'), findsNothing);
  });
}
