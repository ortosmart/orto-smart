import 'package:flutter/material.dart';

import '../data/models/bed.dart';
import '../data/models/crop.dart';
import '../data/models/planting.dart';

class BedLayoutWidget extends StatelessWidget {
  final Bed bed;
  final List<Planting> plantings;
  final Map<String, Crop> cropsById;

  const BedLayoutWidget({
    super.key,
    required this.bed,
    required this.plantings,
    required this.cropsById,
  });

  @override
  Widget build(BuildContext context) {
    final bedLengthCm = bed.lengthCm.toDouble();

    if (bedLengthCm <= 0) {
      return const Text(
        'La lunghezza dell’aiuola non è valida.',
      );
    }

    final occupiedLengthCm = _calculateOccupiedLength(
      bedLengthCm,
    );

    final freeLengthCm =
        (bedLengthCm - occupiedLengthCm).clamp(
      0.0,
      bedLengthCm,
    );

    final occupationPercentage =
        occupiedLengthCm / bedLengthCm * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disposizione colture',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            return Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                border: Border.all(
                  color: Colors.brown.shade400,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  for (final planting in plantings)
                    _buildPlantingBlock(
                      planting: planting,
                      bedLengthCm: bedLengthCm,
                      availableWidth: availableWidth,
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0 cm'),
            Text('${bed.lengthCm} cm'),
          ],
        ),
        if (plantings.isEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Nessuna coltura presente in questa aiuola.',
          ),
        ],
        const SizedBox(height: 20),
        _buildOccupationCard(
          context: context,
          totalLengthCm: bedLengthCm,
          occupiedLengthCm: occupiedLengthCm,
          freeLengthCm: freeLengthCm,
          occupationPercentage: occupationPercentage,
        ),
      ],
    );
  }

  Widget _buildOccupationCard({
    required BuildContext context,
    required double totalLengthCm,
    required double occupiedLengthCm,
    required double freeLengthCm,
    required double occupationPercentage,
  }) {
    final progressValue =
        (occupationPercentage / 100).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Occupazione aiuola',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              label: 'Lunghezza totale',
              value: '${totalLengthCm.round()} cm',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'Occupati',
              value: '${occupiedLengthCm.round()} cm',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'Liberi',
              value: '${freeLengthCm.round()} cm',
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              label: 'Occupazione',
              value:
                  '${occupationPercentage.toStringAsFixed(1)}%',
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    final style = TextStyle(
      fontWeight:
          emphasize ? FontWeight.bold : FontWeight.normal,
      fontSize: emphasize ? 16 : null,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
        Text(
          value,
          style: style,
        ),
      ],
    );
  }

  double _calculateOccupiedLength(
    double bedLengthCm,
  ) {
    final intervals = <_BedInterval>[];

    for (final planting in plantings) {
      final start = planting.startPositionCm.toDouble().clamp(
            0.0,
            bedLengthCm,
          );

      final end =
          (planting.startPositionCm + planting.lengthCm)
              .toDouble()
              .clamp(
                0.0,
                bedLengthCm,
              );

      if (end > start) {
        intervals.add(
          _BedInterval(
            start: start,
            end: end,
          ),
        );
      }
    }

    if (intervals.isEmpty) {
      return 0;
    }

    intervals.sort(
      (first, second) =>
          first.start.compareTo(second.start),
    );

    var occupiedLength = 0.0;
    var currentStart = intervals.first.start;
    var currentEnd = intervals.first.end;

    for (final interval in intervals.skip(1)) {
      if (interval.start <= currentEnd) {
        if (interval.end > currentEnd) {
          currentEnd = interval.end;
        }
      } else {
        occupiedLength += currentEnd - currentStart;
        currentStart = interval.start;
        currentEnd = interval.end;
      }
    }

    occupiedLength += currentEnd - currentStart;

    return occupiedLength.clamp(
      0.0,
      bedLengthCm,
    );
  }

  Widget _buildPlantingBlock({
    required Planting planting,
    required double bedLengthCm,
    required double availableWidth,
  }) {
    final startPositionCm =
        planting.startPositionCm.toDouble();

    final plantingLengthCm =
        planting.lengthCm.toDouble();

    final safeStart = startPositionCm.clamp(
      0.0,
      bedLengthCm,
    );

    final safeEnd =
        (safeStart + plantingLengthCm).clamp(
      0.0,
      bedLengthCm,
    );

    final left =
        safeStart / bedLengthCm * availableWidth;

    final width = (safeEnd - safeStart) /
        bedLengthCm *
        availableWidth;

    if (width <= 0) {
      return const SizedBox.shrink();
    }

    final crop = cropsById[planting.cropId];
    final cropName = crop?.name ?? 'Coltura';
    final cropColor = _cropColor(cropName);

    return Positioned(
      left: left,
      top: 8,
      bottom: 8,
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: cropColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cropColor.withValues(
              alpha: 0.75,
            ),
          ),
        ),
        child: Tooltip(
          message:
              '$cropName\n'
              'Posizione: ${planting.startPositionCm} cm\n'
              'Lunghezza: ${planting.lengthCm} cm\n'
              'Fine: '
              '${planting.startPositionCm + planting.lengthCm} cm',
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              cropName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _cropColor(String cropName) {
    final normalizedName =
        cropName.trim().toLowerCase();

    if (normalizedName.contains('pomodoro')) {
      return Colors.red.shade500;
    }

    if (normalizedName.contains('lattuga')) {
      return Colors.lightGreen.shade600;
    }

    if (normalizedName.contains('zucchin')) {
      return Colors.green.shade700;
    }

    if (normalizedName.contains('basilico')) {
      return Colors.teal.shade700;
    }

    if (normalizedName.contains('carota')) {
      return Colors.orange.shade600;
    }

    if (normalizedName.contains('cipolla')) {
      return Colors.deepPurple.shade400;
    }

    return Colors.blueGrey.shade600;
  }
}

class _BedInterval {
  final double start;
  final double end;

  const _BedInterval({
    required this.start,
    required this.end,
  });
}