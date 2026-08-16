import '../models/agronomic_window.dart';
import '../models/crop_agronomic_window_rule.dart';
import '../models/planned_planting_batch.dart';

class AgronomicWindowResolver {
  const AgronomicWindowResolver();

  List<AgronomicWindow> resolve({
    required List<CropAgronomicWindowRule> rules,
    required String cropId,
    String? varietyId,
    required PlannedPlantingStartMethod startMethod,
  }) {
    final applicableRules = rules.where(
      (rule) => rule.cropId == cropId && rule.window.startMethod == startMethod,
    );

    if (varietyId != null) {
      final varietyWindows = applicableRules
          .where((rule) => rule.varietyId == varietyId)
          .map((rule) => rule.window)
          .toList();

      if (varietyWindows.isNotEmpty) {
        return varietyWindows;
      }
    }

    return applicableRules
        .where((rule) => rule.varietyId == null)
        .map((rule) => rule.window)
        .toList();
  }

  List<AgronomicWindow> resolveForBatch({
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
