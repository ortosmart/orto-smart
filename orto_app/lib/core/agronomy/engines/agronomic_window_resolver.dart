import '../models/agronomic_window.dart';
import '../models/crop_agronomic_window_rule.dart';
import '../models/planned_planting_batch.dart';

class AgronomicWindowResolver {
  const AgronomicWindowResolver();

  AgronomicWindow? resolve({
    required List<CropAgronomicWindowRule> rules,
    required String cropId,
    String? varietyId,
    required PlannedPlantingStartMethod startMethod,
  }) {
    final applicableRules = rules.where(
      (rule) => rule.cropId == cropId && rule.window.startMethod == startMethod,
    );

    if (varietyId != null) {
      for (final rule in applicableRules) {
        if (rule.varietyId == varietyId) {
          return rule.window;
        }
      }
    }

    for (final rule in applicableRules) {
      if (rule.varietyId == null) {
        return rule.window;
      }
    }

    return null;
  }

  AgronomicWindow? resolveForBatch({
    required List<CropAgronomicWindowRule> rules,
    required PlannedPlantingBatch batch,
  }) {
    return resolve(
      rules: rules,
      cropId: batch.cropId,
      varietyId: batch.varietyId,
      startMethod: batch.startMethod,
    );
  }
}
