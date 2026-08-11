import 'agronomic_window.dart';

class CropAgronomicWindowRule {
  const CropAgronomicWindowRule({
    required this.cropId,
    this.varietyId,
    required this.window,
  });

  /// ID della coltura alla quale si applica la regola.
  final String cropId;

  /// ID opzionale della varietà.
  ///
  /// Se nullo, la regola è generale per la coltura.
  /// Se valorizzato, la regola è specifica per quella varietà.
  final String? varietyId;

  /// Finestra agronomica associata.
  final AgronomicWindow window;
}
