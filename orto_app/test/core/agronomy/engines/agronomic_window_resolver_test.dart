import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/agronomic_window_resolver.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/crop_agronomic_window_rule.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowResolver', () {
    const resolver = AgronomicWindowResolver();

    const generalSpringWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 2,
      startDay: 15,
      endMonth: 5,
      endDay: 31,
    );

    const generalAutumnWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 8,
      startDay: 20,
      endMonth: 10,
      endDay: 15,
    );

    const cultivarSpringWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 1,
      endMonth: 5,
      endDay: 15,
    );

    const cultivarAutumnWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 9,
      startDay: 1,
      endMonth: 10,
      endDay: 1,
    );

    const rules = [
      CropAgronomicWindowRule(cropId: 'lattuga', window: generalSpringWindow),
      CropAgronomicWindowRule(cropId: 'lattuga', window: generalAutumnWindow),
      CropAgronomicWindowRule(
        cropId: 'lattuga',
        cultivarId: 'romana',
        window: cultivarSpringWindow,
      ),
      CropAgronomicWindowRule(
        cropId: 'lattuga',
        cultivarId: 'romana',
        window: cultivarAutumnWindow,
      ),
    ];

    test('restituisce tutte le finestre specifiche della varietà', () {
      final windows = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        cultivarId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(windows, [same(cultivarSpringWindow), same(cultivarAutumnWindow)]);
    });

    test('non mescola finestre generali quando esistono quelle specifiche', () {
      final windows = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        cultivarId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(windows, hasLength(2));
      expect(windows, isNot(contains(same(generalSpringWindow))));
      expect(windows, isNot(contains(same(generalAutumnWindow))));
    });

    test('usa tutte le finestre generali se mancano quelle specifiche', () {
      final windows = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        cultivarId: 'canasta',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(windows, [same(generalSpringWindow), same(generalAutumnWindow)]);
    });

    test(
      'usa tutte le finestre generali quando non è indicata una varietà',
      () {
        final windows = resolver.resolve(
          rules: rules,
          cropId: 'lattuga',
          startMethod: PlannedPlantingStartMethod.directRows,
        );

        expect(windows, [same(generalSpringWindow), same(generalAutumnWindow)]);
      },
    );

    test('ignora le regole di una coltura diversa', () {
      final windows = resolver.resolve(
        rules: rules,
        cropId: 'pomodoro',
        cultivarId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(windows, isEmpty);
    });

    test('ignora le regole con metodo di avvio diverso', () {
      final windows = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        cultivarId: 'romana',
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
      );

      expect(windows, isEmpty);
    });

    test(
      'restituisce lista vuota quando non esiste una regola applicabile',
      () {
        final windows = resolver.resolve(
          rules: const [],
          cropId: 'lattuga',
          cultivarId: 'romana',
          startMethod: PlannedPlantingStartMethod.directRows,
        );

        expect(windows, isEmpty);
      },
    );

    test('risolve tutte le finestre specifiche direttamente da un lotto', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        cultivarId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final windows = resolver.resolveForBatch(rules: rules, batch: batch);

      expect(windows, [same(cultivarSpringWindow), same(cultivarAutumnWindow)]);
    });

    test('usa il fallback generale anche per un lotto pianificato', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        cultivarId: 'canasta',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final windows = resolver.resolveForBatch(rules: rules, batch: batch);

      expect(windows, [same(generalSpringWindow), same(generalAutumnWindow)]);
    });
  });
}
