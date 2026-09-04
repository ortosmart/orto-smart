class FreeSpace {
  final int startCm;
  final int lengthCm;

  const FreeSpace({required this.startCm, required this.lengthCm});

  int get endCm => startCm + lengthCm;

  bool get isValid => lengthCm > 0;

  @override
  String toString() {
    return 'FreeSpace($startCm - $endCm, length: $lengthCm cm)';
  }
}
