import '../models/agronomic_window.dart';
import '../models/crop_agronomic_window_rule.dart';
import '../models/planned_planting_batch.dart';

class AgronomicWindowResolver {
  const AgronomicWindowResolver();

  List<AgronomicWindow> resolve({
    required List<CropAgronomicWindowRule> rules,
    required String cropId,
    String? cultivarId,
    required PlannedPlantingStartMethod startMethod,
  }) {
    final applicableRules = rules.where(
      (rule) => rule.cropId == cropId && rule.window.startMethod == startMethod,
    );

    if (cultivarId != null) {
      final cultivarWindows = applicableRules
          .where((rule) => rule.cultivarId == cultivarId)
          .map((rule) => rule.window)
          .toList();

      if (cultivarWindows.isNotEmpty) {
        return cultivarWindows;
      }
    }

    return applicableRules
        .where((rule) => rule.cultivarId == null)
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
      cultivarId: batch.cultivarId,
      startMethod: batch.startMethod,
    );
  }
}
