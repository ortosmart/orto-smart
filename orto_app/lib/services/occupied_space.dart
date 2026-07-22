/// Rappresenta un tratto occupato all'interno di un'aiuola.
class OccupiedSpace {
  /// Posizione iniziale del tratto occupato, espressa in centimetri.
  final double startCm;

  /// Posizione finale del tratto occupato, espressa in centimetri.
  final double endCm;

  const OccupiedSpace({
    required this.startCm,
    required this.endCm,
  });

  /// Lunghezza del tratto occupato, espressa in centimetri.
  double get lengthCm => endCm - startCm;

  /// Indica se il tratto ha valori coerenti.
  bool get isValid => startCm >= 0 && endCm > startCm;

  @override
  String toString() {
    return 'OccupiedSpace('
        'start: $startCm cm, '
        'end: $endCm cm, '
        'length: $lengthCm cm'
        ')';
  }
}