import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/widgets/garden/bed_card.dart';
import 'package:orto_app/widgets/garden/garden_map.dart';

const _gardenId = '11111111-1111-4111-8111-111111111111';
const _bedId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _bedMap({
  String bedId = _bedId,
  String geometryId = _geometryId,
  String gardenId = _gardenId,
  int number = 1,
}) {
  return {
    'id': bedId,
    'garden_id': gardenId,
    'number': number,
    'name': 'Aiuola di prova $number',
    'notes': null,
    'is_active': true,
    'row_version': 1,
    'bed_geometries': [
      {
        'id': geometryId,
        'bed_id': bedId,
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'row_version': 1,
      },
    ],
  };
}

Widget _testApp({
  required BedRepository repository,
  String gardenId = _gardenId,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: GardenMap(gardenId: gardenId, repository: repository),
      ),
    ),
  );
}

void main() {
  group('GardenMap', () {
    testWidgets('shows loading until the beds response arrives', (
      tester,
    ) async {
      final response = Completer<List<Map<String, dynamic>>>();
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) {
        requestedGardens.add(gardenId);
        return response.future;
      });

      await tester.pumpWidget(_testApp(repository: repository));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BedCard), findsNothing);
      expect(
        find.text('Nessuna aiuola abilitata in questo orto.'),
        findsNothing,
      );
      expect(requestedGardens, [_gardenId]);

      response.complete([_bedMap()]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(BedCard), findsOneWidget);
      expect(tester.widget<BedCard>(find.byType(BedCard)).bed.id, _bedId);
      expect(requestedGardens, [_gardenId]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an empty state when no beds are returned', (
      tester,
    ) async {
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return [];
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Nessuna aiuola abilitata in questo orto.'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(BedCard), findsNothing);
      expect(find.text('Riprova'), findsNothing);
      expect(requestedGardens, [_gardenId]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays beds in ascending numerical order', (tester) async {
      const secondBedId = '44444444-4444-4444-8444-444444444444';
      const secondGeometryId = '55555555-5555-4555-8555-555555555555';

      final source = [
        _bedMap(bedId: secondBedId, geometryId: secondGeometryId, number: 2),
        _bedMap(),
      ];
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);
        return source;
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      final cards = tester.widgetList<BedCard>(find.byType(BedCard)).toList();

      expect(cards, hasLength(2));
      expect(cards.map((card) => card.bed.number), [1, 2]);
      expect(cards.map((card) => card.bed.id), [_bedId, secondBedId]);
      expect(cards.every((card) => card.bed.gardenId == _gardenId), isTrue);
      expect(
        tester.getTopLeft(find.byType(BedCard).at(0)).dy,
        lessThan(tester.getTopLeft(find.byType(BedCard).at(1)).dy),
      );
      expect(source.map((row) => row['number']), [2, 1]);
      expect(requestedGardens, [_gardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('hides previous beds while the new garden loads', (
      tester,
    ) async {
      const secondGardenId = '66666666-6666-4666-8666-666666666666';
      const secondBedId = '44444444-4444-4444-8444-444444444444';
      const secondGeometryId = '55555555-5555-4555-8555-555555555555';

      final secondResponse = Completer<List<Map<String, dynamic>>>();
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);

        if (gardenId == _gardenId) {
          return [_bedMap()];
        }

        if (gardenId == secondGardenId) {
          return secondResponse.future;
        }

        throw StateError('Unexpected Garden in test');
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byType(BedCard), findsOneWidget);
      expect(tester.widget<BedCard>(find.byType(BedCard)).bed.id, _bedId);

      final originalMapState = tester.state(find.byType(GardenMap));

      await tester.pumpWidget(
        _testApp(repository: repository, gardenId: secondGardenId),
      );
      await tester.pump();

      expect(tester.state(find.byType(GardenMap)), same(originalMapState));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BedCard), findsNothing);
      expect(find.text('Aiuola di prova 1'), findsNothing);
      expect(
        find.text('Nessuna aiuola abilitata in questo orto.'),
        findsNothing,
      );
      expect(requestedGardens, [_gardenId, secondGardenId]);

      secondResponse.complete([
        _bedMap(
          bedId: secondBedId,
          geometryId: secondGeometryId,
          gardenId: secondGardenId,
          number: 2,
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(BedCard), findsOneWidget);
      expect(find.text('Aiuola di prova 1'), findsNothing);

      final card = tester.widget<BedCard>(find.byType(BedCard));

      expect(card.bed.id, secondBedId);
      expect(card.bed.gardenId, secondGardenId);
      expect(card.bed.number, 2);
      expect(requestedGardens, [_gardenId, secondGardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('ignores an old garden response arriving after the new one', (
      tester,
    ) async {
      const secondGardenId = '66666666-6666-4666-8666-666666666666';
      const secondBedId = '44444444-4444-4444-8444-444444444444';
      const secondGeometryId = '55555555-5555-4555-8555-555555555555';

      final firstResponse = Completer<List<Map<String, dynamic>>>();
      final secondResponse = Completer<List<Map<String, dynamic>>>();
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) {
        requestedGardens.add(gardenId);

        if (gardenId == _gardenId) {
          return firstResponse.future;
        }

        if (gardenId == secondGardenId) {
          return secondResponse.future;
        }

        throw StateError('Unexpected Garden in test');
      });

      await tester.pumpWidget(_testApp(repository: repository));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(requestedGardens, [_gardenId]);

      final originalMapState = tester.state(find.byType(GardenMap));

      await tester.pumpWidget(
        _testApp(repository: repository, gardenId: secondGardenId),
      );
      await tester.pump();

      expect(tester.state(find.byType(GardenMap)), same(originalMapState));
      expect(find.byType(BedCard), findsNothing);
      expect(requestedGardens, [_gardenId, secondGardenId]);

      secondResponse.complete([
        _bedMap(
          bedId: secondBedId,
          geometryId: secondGeometryId,
          gardenId: secondGardenId,
          number: 2,
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(BedCard), findsOneWidget);
      expect(tester.widget<BedCard>(find.byType(BedCard)).bed.id, secondBedId);

      firstResponse.complete([_bedMap()]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(BedCard), findsOneWidget);
      expect(find.text('Aiuola di prova 1'), findsNothing);

      final card = tester.widget<BedCard>(find.byType(BedCard));

      expect(card.bed.id, secondBedId);
      expect(card.bed.gardenId, secondGardenId);
      expect(card.bed.number, 2);
      expect(requestedGardens, [_gardenId, secondGardenId]);
      expect(tester.takeException(), isNull);
    });
    testWidgets('shows a generic error and retries only when requested', (
      tester,
    ) async {
      const technicalDetail = 'Synthetic internal beds failure';
      final requestedGardens = <String>[];

      final repository = BedRepository.withLoader((gardenId) async {
        requestedGardens.add(gardenId);

        if (requestedGardens.length == 1) {
          throw StateError(technicalDetail);
        }

        return [_bedMap()];
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare le aiuole.'),
        findsOneWidget,
      );
      expect(find.textContaining(technicalDetail), findsNothing);
      expect(find.text('Riprova'), findsOneWidget);
      expect(find.byType(BedCard), findsNothing);
      expect(
        find.text('Nessuna aiuola abilitata in questo orto.'),
        findsNothing,
      );
      expect(requestedGardens, [_gardenId]);

      await tester.pump(const Duration(seconds: 1));

      expect(requestedGardens, [_gardenId]);

      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare le aiuole.'),
        findsNothing,
      );
      expect(find.text('Riprova'), findsNothing);
      expect(find.byType(BedCard), findsOneWidget);
      expect(tester.widget<BedCard>(find.byType(BedCard)).bed.id, _bedId);
      expect(requestedGardens, [_gardenId, _gardenId]);
      expect(tester.takeException(), isNull);
    });
  });
}
