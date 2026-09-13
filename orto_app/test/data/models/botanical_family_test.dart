import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/botanical_family.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _familyId = '22222222-2222-4222-8222-222222222222';

void main() {
  group('BotanicalFamily.fromMap', () {
    test('maps the complete Catalog V1 BotanicalFamily', () {
      final family = BotanicalFamily.fromMap({
        'id': _familyId,
        'profile_id': _profileId,
        'name': 'Solanaceae',
        'scientific_name': 'Solanaceae',
        'description': 'Famiglia botanica di prova',
        'is_active': true,
        'row_version': 3,
        'created_at': '2026-09-11T08:30:00+00:00',
        'updated_at': '2026-09-11T09:45:00+00:00',
      });

      expect(family.id, _familyId);
      expect(family.profileId, _profileId);
      expect(family.name, 'Solanaceae');
      expect(family.scientificName, 'Solanaceae');
      expect(family.description, 'Famiglia botanica di prova');
      expect(family.isActive, isTrue);
      expect(family.rowVersion, 3);
      expect(family.createdAt, DateTime.parse('2026-09-11T08:30:00+00:00'));
      expect(family.updatedAt, DateTime.parse('2026-09-11T09:45:00+00:00'));
    });

    test('preserves nullable descriptive fields', () {
      final family = BotanicalFamily.fromMap({
        'id': _familyId,
        'profile_id': _profileId,
        'name': 'Famiglia senza dettagli',
        'scientific_name': null,
        'description': null,
        'is_active': false,
        'row_version': 1,
        'created_at': '2026-09-11T08:30:00+00:00',
        'updated_at': '2026-09-11T08:30:00+00:00',
      });

      expect(family.scientificName, isNull);
      expect(family.description, isNull);
      expect(family.isActive, isFalse);
      expect(family.rowVersion, 1);
    });
  });
}
