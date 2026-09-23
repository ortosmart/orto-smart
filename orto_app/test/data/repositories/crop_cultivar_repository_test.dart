import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/crop_cultivar_repository.dart';

const _cropId = '33333333-3333-4333-8333-333333333333';
const _cultivarId = '44444444-4444-4444-8444-444444444444';

Map<String, dynamic> _cultivarMap({bool isActive = true}) => {
  'cultivar_id': _cultivarId,
  'crop_id': _cropId,
  'crop_canonical_name': 'Pomodoro',
  'canonical_name': 'San Marzano',
  'verification_status': 'VERIFIED',
  'description': 'Cultivar di prova',
  'is_active': isActive,
  'row_version': 2,
  'created_at': '2026-09-11T08:30:00+00:00',
  'updated_at': '2026-09-11T09:45:00+00:00',
};

void main() {
  group('CropCultivarRepository', () {
    test('maps the canonical Cultivar read model', () async {
      final repository = CropCultivarRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [_cultivarMap()],
      );

      final cultivar = (await repository.getAllCultivars()).single;
      expect(cultivar.id, _cultivarId);
      expect(cultivar.cropId, _cropId);
      expect(cultivar.cropName, 'Pomodoro');
      expect(cultivar.name, 'San Marzano');
      expect(cultivar.verificationStatus, 'VERIFIED');
      expect(cultivar.isActive, isTrue);
      expect(cultivar.rowVersion, 2);
    });

    test('passes crop and active filters to the loader', () async {
      String? requestedCrop;
      bool? requestedActive;
      final repository = CropCultivarRepository.withLoader(({
        String? cropId,
        bool activeOnly = true,
      }) async {
        requestedCrop = cropId;
        requestedActive = activeOnly;
        return [];
      });

      await repository.getCultivarsByCrop(_cropId, activeOnly: false);
      expect(requestedCrop, _cropId);
      expect(requestedActive, isFalse);
    });

    test('rejects a malformed canonical response', () async {
      final map = _cultivarMap()..remove('cultivar_id');
      final repository = CropCultivarRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [map],
      );

      await expectLater(repository.getAllCultivars(), throwsFormatException);
    });
  });
}
