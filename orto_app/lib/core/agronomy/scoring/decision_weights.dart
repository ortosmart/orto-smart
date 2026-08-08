/// Definisce i pesi utilizzati per calcolare
/// il punteggio finale di una raccomandazione agronomica.
class DecisionWeights {
  const DecisionWeights({
    required this.space,
    required this.rotation,
    required this.association,
  });

  /// Configurazione predefinita usata dal DecisionEngine.
  static const standard = DecisionWeights(
    space: 0.4,
    rotation: 0.3,
    association: 0.3,
  );

  /// Peso assegnato all'adeguatezza dello spazio.
  final double space;

  /// Peso assegnato alla rotazione colturale.
  final double rotation;

  /// Peso assegnato alle consociazioni.
  final double association;

  /// Somma complessiva dei pesi.
  double get total => space + rotation + association;

  /// Indica se tutti i pesi sono validi e la loro somma è pari a 1.
  bool get isValid {
    const tolerance = 0.000001;

    return space >= 0 &&
        rotation >= 0 &&
        association >= 0 &&
        (total - 1.0).abs() <= tolerance;
  }
}
