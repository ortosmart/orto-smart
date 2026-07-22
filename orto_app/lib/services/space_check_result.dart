class SpaceCheckResult {
  final bool fits;
  final double occupiedLengthCm;
  final double availableLengthCm;
  final double freeLengthCm;
  final String message;

  const SpaceCheckResult({
    required this.fits,
    required this.occupiedLengthCm,
    required this.availableLengthCm,
    required this.freeLengthCm,
    required this.message,
  });
}