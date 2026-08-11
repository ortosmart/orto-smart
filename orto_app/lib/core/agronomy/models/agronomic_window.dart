import 'planned_planting_batch.dart';

class AgronomicWindow {
  const AgronomicWindow({
    required this.startMethod,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
  });

  /// Modalità di avvio alla quale si applica la finestra.
  final PlannedPlantingStartMethod startMethod;

  /// Mese iniziale della finestra agronomica.
  final int startMonth;

  /// Giorno iniziale della finestra agronomica.
  final int startDay;

  /// Mese finale della finestra agronomica.
  final int endMonth;

  /// Giorno finale della finestra agronomica.
  final int endDay;
}
