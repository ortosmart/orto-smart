import '../agronomic_window_validator.dart';
import '../models/agronomic_window.dart';
import '../models/planned_planting_batch.dart';

class AgronomicWindowEngine {
  const AgronomicWindowEngine();

  bool contains({required AgronomicWindow window, required DateTime date}) {
    final validation = AgronomicWindowValidator.validate(window);

    if (!validation.isValid) {
      throw ArgumentError(
        validation.errorMessage ?? 'La finestra agronomica non è valida.',
      );
    }

    final target = _monthDayValue(date.month, date.day);
    final start = _monthDayValue(window.startMonth, window.startDay);
    final end = _monthDayValue(window.endMonth, window.endDay);

    if (start <= end) {
      return target >= start && target <= end;
    }

    return target >= start || target <= end;
  }

  bool isBatchCompatible({
    required AgronomicWindow window,
    required PlannedPlantingBatch batch,
  }) {
    if (batch.startMethod != window.startMethod) {
      return false;
    }

    return contains(window: window, date: batch.plannedDate);
  }

  int _monthDayValue(int month, int day) {
    return (month * 100) + day;
  }
}
