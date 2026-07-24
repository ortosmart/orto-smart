import 'package:flutter/material.dart';

class CalculationCard extends StatelessWidget {
  final bool usesPlantCount;
  final int calculatedRowsCount;
  final int plantsPerRow;
  final int calculatedLengthCm;
  final int occupiedWidthCm;
  final int endPositionCm;
  final int remainingLengthCm;
  final bool fitsInBed;
  final bool hasOverlap;

  const CalculationCard({
    super.key,
    required this.usesPlantCount,
    required this.calculatedRowsCount,
    required this.plantsPerRow,
    required this.calculatedLengthCm,
    required this.occupiedWidthCm,
    required this.endPositionCm,
    required this.remainingLengthCm,
    required this.fitsInBed,
    required this.hasOverlap,
  });

  @override
  Widget build(BuildContext context) {
    if (calculatedLengthCm <= 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Inserisci i dati per visualizzare il calcolo.'),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined),
                const SizedBox(width: 8),
                Text('Calcolo automatico', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (usesPlantCount) ...[
              _CalculationRow(
                label: 'Numero di file',
                value: '$calculatedRowsCount',
              ),
              _CalculationRow(label: 'Piante per fila', value: '$plantsPerRow'),
            ],
            _CalculationRow(
              label: 'Lunghezza occupata',
              value: '$calculatedLengthCm cm',
            ),
            _CalculationRow(
              label: 'Larghezza occupata',
              value: '$occupiedWidthCm cm',
            ),
            _CalculationRow(
              label: 'Posizione finale',
              value: '$endPositionCm cm',
            ),
            _CalculationRow(
              label: 'Spazio libero successivo',
              value: remainingLengthCm >= 0
                  ? '$remainingLengthCm cm'
                  : 'superamento di ${-remainingLengthCm} cm',
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  fitsInBed ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: fitsInBed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fitsInBed
                        ? 'La coltura entra correttamente nello spazio libero.'
                        : hasOverlap
                        ? 'La coltura si sovrappone a una coltura già presente.'
                        : 'La coltura supera i limiti dell’aiuola.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: fitsInBed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  final String label;
  final String value;

  const _CalculationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
