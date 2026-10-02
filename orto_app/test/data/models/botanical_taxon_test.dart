import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/botanical_taxon.dart';

const _parentTaxonId = '11111111-1111-4111-8111-111111111111';
const _taxonId = '22222222-2222-4222-8222-222222222222';

Map<String, dynamic> _taxonMap() => {
  'id': _taxonId,
  'parent_taxon_id': _parentTaxonId,
  'rank': 'SPECIES',
  'scientific_name': 'Solanum lycopersicum',
  'authorship': 'L.',
  'is_hybrid': false,
  'description': 'Specie botanica di riferimento per il pomodoro.',
  'is_active': true,
  'row_version': 3,
  'created_at': '2026-09-20T08:30:00+00:00',
  'updated_at': '2026-09-20T09:45:00+00:00',
};

void main() {
  group('BotanicalTaxon.fromMap', () {
    test('maps a canonical botanical_taxa row', () {
      final taxon = BotanicalTaxon.fromMap(_taxonMap());

      expect(taxon.id, _taxonId);
      expect(taxon.parentTaxonId, _parentTaxonId);
      expect(taxon.rank, 'SPECIES');
      expect(taxon.scientificName, 'Solanum lycopersicum');
      expect(taxon.authorship, 'L.');
      expect(taxon.isHybrid, isFalse);
      expect(
        taxon.description,
        'Specie botanica di riferimento per il pomodoro.',
      );
      expect(taxon.isActive, isTrue);
      expect(taxon.rowVersion, 3);
      expect(taxon.createdAt, DateTime.utc(2026, 9, 20, 8, 30));
      expect(taxon.updatedAt, DateTime.utc(2026, 9, 20, 9, 45));
    });

    test('accepts nullable optional fields', () {
      final map = _taxonMap()
        ..['parent_taxon_id'] = null
        ..['authorship'] = null
        ..['description'] = null;

      final taxon = BotanicalTaxon.fromMap(map);

      expect(taxon.parentTaxonId, isNull);
      expect(taxon.authorship, isNull);
      expect(taxon.description, isNull);
    });

    test('preserves an inactive taxon', () {
      final map = _taxonMap()..['is_active'] = false;

      final taxon = BotanicalTaxon.fromMap(map);

      expect(taxon.isActive, isFalse);
    });

    test('rejects a missing required field', () {
      final map = _taxonMap()..remove('scientific_name');

      expect(
        () => BotanicalTaxon.fromMap(map),
        throwsFormatException,
      );
    });

    test('rejects an invalid row version', () {
      final map = _taxonMap()..['row_version'] = 0;

      expect(
        () => BotanicalTaxon.fromMap(map),
        throwsFormatException,
      );
    });

    test('rejects an invalid timestamp', () {
      final map = _taxonMap()..['updated_at'] = 'not-a-date';

      expect(
        () => BotanicalTaxon.fromMap(map),
        throwsFormatException,
      );
    });
  });
}
