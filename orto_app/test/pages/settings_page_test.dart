import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/catalog_authority_repository.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';
import 'package:orto_app/pages/agronomic_catalog_page.dart';
import 'package:orto_app/pages/settings_page.dart';

void main() {
  testWidgets('opens Agronomic Catalog from Settings', (tester) async {
    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(functionName, 'get_my_catalog_capabilities');
      expect(parameters, isEmpty);

      return {
        'status': 'ok',
        'can_manage_identity': true,
        'can_ingest': true,
        'can_review': true,
        'can_publish': true,
        'row_version': 1,
      };
    });
    final cropRepository = CropRepository.withLoader(
      ({bool activeOnly = true}) async => [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsPage(
            catalogAuthorityRepository: repository,
            cropRepository: cropRepository,
          ),
        ),
      ),
    );

    expect(find.text('Catalogo Agronomico'), findsOneWidget);

    await tester.tap(find.text('Catalogo Agronomico'));
    await tester.pumpAndSettle();

    expect(find.byType(AgronomicCatalogPage), findsOneWidget);
    expect(find.text('Authority attiva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
