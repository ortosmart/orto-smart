import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/profile/profile_context_scope.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';
import 'package:orto_app/pages/garden_page.dart';
import 'package:orto_app/widgets/garden/garden_map.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';

Map<String, dynamic> _gardenMap() {
  return {
    'id': _gardenId,
    'profile_id': _profileId,
    'name': 'Orto di prova',
    'description': 'Descrizione di prova',
    'is_active': true,
    'row_version': 1,
  };
}

Widget _testApp({
  required GardenRepository gardenRepository,
  required BedRepository bedRepository,
  String profileId = _profileId,
}) {
  return MaterialApp(
    home: ProfileContextScope(
      profileContext: ProfileContext(
        profileId: profileId,
        role: ProfileMemberRole.owner,
      ),
      child: Scaffold(
        body: GardenPage(
          repository: gardenRepository,
          bedRepository: bedRepository,
        ),
      ),
    ),
  );
}

void main() {
  group('GardenPage', () {
    testWidgets('shows loading while gardens are being fetched', (
      tester,
    ) async {
      final completer = Completer<List<Map<String, dynamic>>>();
      final requestedProfiles = <String>[];
      var bedLoads = 0;

      final gardenRepository = GardenRepository.withLoader((profileId) {
        requestedProfiles.add(profileId);
        return completer.future;
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        bedLoads += 1;
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GardenMap), findsNothing);
      expect(
        find.text('Nessun orto trovato per questo profilo.'),
        findsNothing,
      );
      expect(requestedProfiles, [_profileId]);
      expect(bedLoads, 0);

      completer.complete([]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.text('Nessun orto trovato per questo profilo.'),
        findsOneWidget,
      );
      expect(bedLoads, 0);
    });

    testWidgets('shows the empty state without loading beds', (tester) async {
      final requestedProfiles = <String>[];
      var bedLoads = 0;

      final gardenRepository = GardenRepository.withLoader((profileId) async {
        requestedProfiles.add(profileId);
        return [];
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        bedLoads += 1;
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Nessun orto trovato per questo profilo.'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.byType(GardenMap), findsNothing);
      expect(requestedProfiles, [_profileId]);
      expect(bedLoads, 0);
    });

    testWidgets('shows a single garden and loads only its beds', (
      tester,
    ) async {
      final requestedProfiles = <String>[];
      final requestedGardens = <String>[];

      final gardenRepository = GardenRepository.withLoader((profileId) async {
        requestedProfiles.add(profileId);
        return [_gardenMap()];
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Orto di prova'), findsOneWidget);
      expect(find.text('Descrizione di prova'), findsOneWidget);
      expect(find.text('Aiuole'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.byType(GardenMap), findsOneWidget);
      expect(
        find.text('Nessuna aiuola abilitata in questo orto.'),
        findsOneWidget,
      );

      final gardenMap = tester.widget<GardenMap>(find.byType(GardenMap));

      expect(gardenMap.gardenId, _gardenId);
      expect(gardenMap.repository, same(bedRepository));
      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, [_gardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('requires a selection and loads beds for the selected garden', (
      tester,
    ) async {
      const secondGardenId = '33333333-3333-4333-8333-333333333333';
      final requestedProfiles = <String>[];
      final requestedGardens = <String>[];

      final gardenRepository = GardenRepository.withLoader((profileId) async {
        requestedProfiles.add(profileId);
        return [
          {
            ..._gardenMap(),
            'name': 'Orto nord',
            'description': 'Descrizione nord',
          },
          {
            ..._gardenMap(),
            'id': secondGardenId,
            'name': 'Orto sud',
            'description': 'Descrizione sud',
          },
        ];
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(
        find.text('Seleziona un orto per visualizzarne le aiuole.'),
        findsOneWidget,
      );
      expect(find.byType(GardenMap), findsNothing);
      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, isEmpty);

      final initialDropdown = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      expect(initialDropdown.value, isNull);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Orto sud').last);
      await tester.pumpAndSettle();

      expect(requestedGardens, [secondGardenId]);
      expect(find.text('Descrizione sud'), findsOneWidget);
      expect(find.text('Descrizione nord'), findsNothing);
      expect(
        find.text('Seleziona un orto per visualizzarne le aiuole.'),
        findsNothing,
      );
      expect(find.byType(GardenMap), findsOneWidget);
      expect(
        tester.widget<GardenMap>(find.byType(GardenMap)).gardenId,
        secondGardenId,
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Orto nord').last);
      await tester.pumpAndSettle();

      expect(requestedGardens, [secondGardenId, _gardenId]);
      expect(requestedProfiles, [_profileId]);
      expect(find.text('Descrizione nord'), findsOneWidget);
      expect(find.text('Descrizione sud'), findsNothing);
      expect(find.byType(GardenMap), findsOneWidget);
      expect(
        tester.widget<GardenMap>(find.byType(GardenMap)).gardenId,
        _gardenId,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('hides the previous garden while the new profile loads', (
      tester,
    ) async {
      const secondProfileId = '44444444-4444-4444-8444-444444444444';
      const secondGardenId = '55555555-5555-4555-8555-555555555555';

      final secondProfileResponse = Completer<List<Map<String, dynamic>>>();
      final requestedProfiles = <String>[];
      final requestedGardens = <String>[];

      final gardenRepository = GardenRepository.withLoader((profileId) async {
        requestedProfiles.add(profileId);

        if (profileId == _profileId) {
          return [_gardenMap()];
        }

        if (profileId == secondProfileId) {
          return secondProfileResponse.future;
        }

        throw StateError('Unexpected Profile in test');
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Orto di prova'), findsOneWidget);
      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, [_gardenId]);

      final originalPageState = tester.state(find.byType(GardenPage));

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
          profileId: secondProfileId,
        ),
      );
      await tester.pump();

      expect(tester.state(find.byType(GardenPage)), same(originalPageState));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Orto di prova'), findsNothing);
      expect(find.text('Descrizione di prova'), findsNothing);
      expect(find.byType(GardenMap), findsNothing);
      expect(requestedProfiles, [_profileId, secondProfileId]);
      expect(requestedGardens, [_gardenId]);

      secondProfileResponse.complete([
        {
          ..._gardenMap(),
          'id': secondGardenId,
          'profile_id': secondProfileId,
          'name': 'Orto secondo profilo',
          'description': 'Descrizione secondo profilo',
        },
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Orto di prova'), findsNothing);
      expect(find.text('Descrizione di prova'), findsNothing);
      expect(find.text('Orto secondo profilo'), findsOneWidget);
      expect(find.text('Descrizione secondo profilo'), findsOneWidget);
      expect(find.byType(GardenMap), findsOneWidget);
      expect(
        tester.widget<GardenMap>(find.byType(GardenMap)).gardenId,
        secondGardenId,
      );
      expect(requestedProfiles, [_profileId, secondProfileId]);
      expect(requestedGardens, [_gardenId, secondGardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('ignores an old profile response arriving after the new one', (
      tester,
    ) async {
      const secondProfileId = '44444444-4444-4444-8444-444444444444';
      const secondGardenId = '55555555-5555-4555-8555-555555555555';

      final firstResponse = Completer<List<Map<String, dynamic>>>();
      final secondResponse = Completer<List<Map<String, dynamic>>>();
      final requestedProfiles = <String>[];
      final requestedGardens = <String>[];

      final gardenRepository = GardenRepository.withLoader((profileId) {
        requestedProfiles.add(profileId);

        if (profileId == _profileId) {
          return firstResponse.future;
        }

        if (profileId == secondProfileId) {
          return secondResponse.future;
        }

        throw StateError('Unexpected Profile in test');
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, isEmpty);

      final originalPageState = tester.state(find.byType(GardenPage));

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
          profileId: secondProfileId,
        ),
      );
      await tester.pump();

      expect(tester.state(find.byType(GardenPage)), same(originalPageState));
      expect(requestedProfiles, [_profileId, secondProfileId]);
      expect(requestedGardens, isEmpty);

      secondResponse.complete([
        {
          ..._gardenMap(),
          'id': secondGardenId,
          'profile_id': secondProfileId,
          'name': 'Orto nuovo profilo',
          'description': 'Descrizione nuovo profilo',
        },
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Orto nuovo profilo'), findsOneWidget);
      expect(find.text('Orto di prova'), findsNothing);
      expect(requestedGardens, [secondGardenId]);

      firstResponse.complete([_gardenMap()]);
      await tester.pumpAndSettle();

      expect(find.text('Orto nuovo profilo'), findsOneWidget);
      expect(find.text('Descrizione nuovo profilo'), findsOneWidget);
      expect(find.text('Orto di prova'), findsNothing);
      expect(find.text('Descrizione di prova'), findsNothing);
      expect(find.byType(GardenMap), findsOneWidget);
      expect(
        tester.widget<GardenMap>(find.byType(GardenMap)).gardenId,
        secondGardenId,
      );
      expect(requestedProfiles, [_profileId, secondProfileId]);
      expect(requestedGardens, [secondGardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('shows a generic error and retries only when requested', (
      tester,
    ) async {
      const technicalDetail = 'Synthetic internal loader failure';
      final requestedProfiles = <String>[];
      final requestedGardens = <String>[];

      final gardenRepository = GardenRepository.withLoader((profileId) async {
        requestedProfiles.add(profileId);

        if (requestedProfiles.length == 1) {
          throw StateError(technicalDetail);
        }

        return [_gardenMap()];
      });

      final bedRepository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(
        _testApp(
          gardenRepository: gardenRepository,
          bedRepository: bedRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare gli orti.'),
        findsOneWidget,
      );
      expect(find.textContaining(technicalDetail), findsNothing);
      expect(find.text('Riprova'), findsOneWidget);
      expect(find.byType(GardenMap), findsNothing);
      expect(
        find.text('Nessun orto trovato per questo profilo.'),
        findsNothing,
      );
      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, isEmpty);

      await tester.pump(const Duration(seconds: 1));

      expect(requestedProfiles, [_profileId]);
      expect(requestedGardens, isEmpty);

      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare gli orti.'),
        findsNothing,
      );
      expect(find.text('Riprova'), findsNothing);
      expect(find.text('Orto di prova'), findsOneWidget);
      expect(find.byType(GardenMap), findsOneWidget);
      expect(requestedProfiles, [_profileId, _profileId]);
      expect(requestedGardens, [_gardenId]);
      expect(tester.takeException(), isNull);
    });
  });
}
