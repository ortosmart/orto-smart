/// Rappresenta uno spazio libero all'interno di un'aiuola.
class FreeSpace {
  /// Posizione iniziale dello spazio libero (cm)
  final double startCm;

  /// Posizione finale dello spazio libero (cm)
  final double endCm;

  const FreeSpace({
    required this.startCm,
    required this.endCm,
  });

  /// Lunghezza dello spazio libero (cm)
  double get lengthCm => endCm - startCm;

  /// Indica se lo spazio è valido
  bool get isValid => endCm > startCm;

  @override
  String toString() {
    return 'FreeSpace(start: $startCm cm, end: $endCm cm, length: $lengthCm cm)';
  }
}