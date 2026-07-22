import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models/planting.dart';

class BedPreviewWidget extends StatelessWidget {
  final int bedLengthCm;
  final List<Planting> existingPlantings;
  final Map<String, String> cropNamesById;

  final String? newCropName;
  final int newStartCm;
  final int newLengthCm;
  final bool newPlantingFits;

  const BedPreviewWidget({
    super.key,
    required this.bedLengthCm,
    required this.existingPlantings,
    required this.cropNamesById,
    required this.newStartCm,
    required this.newLengthCm,
    required this.newPlantingFits,
    this.newCropName,
  });

  bool get _hasNewPlanting => newLengthCm > 0;

  int get _safeBedLengthCm => math.max(1, bedLengthCm);

  List<_TimelineEntry> get _existingEntries {
    return existingPlantings.map((planting) {
      return _TimelineEntry(
        label: _cropNameFor(planting),
        startCm: planting.startPositionCm,
        lengthCm: planting.lengthCm,
        isPreview: false,
        hasError: false,
      );
    }).toList();
  }

  _TimelineEntry? get _previewEntry {
    if (!_hasNewPlanting) {
      return null;
    }

    final cropName = newCropName?.trim();

    return _TimelineEntry(
      label: cropName != null && cropName.isNotEmpty
          ? cropName
          : 'Nuova coltura',
      startCm: newStartCm,
      lengthCm: newLengthCm,
      isPreview: true,
      hasError: !newPlantingFits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewEntry = _previewEntry;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildScale(context),
            const SizedBox(height: 8),
            _BedTimeline(
              bedLengthCm: _safeBedLengthCm,
              existingEntries: _existingEntries,
              previewEntry: previewEntry,
            ),
            const SizedBox(height: 14),
            if (existingPlantings.isEmpty && !_hasNewPlanting)
              _buildEmptyMessage(context),
            if (!_hasNewPlanting)
              _buildNewPlantingPlaceholder(context)
            else
              _buildPreviewResult(context),
          ],
        ),
      ),
    );
  }

  String _cropNameFor(Planting planting) {
    final cropName = cropNamesById[planting.cropId];

    if (cropName == null || cropName.trim().isEmpty) {
      return 'Coltura ${planting.cropId}';
    }

    return cropName.trim();
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final existingCount = existingPlantings.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.view_timeline_outlined,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anteprima aiuola',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$bedLengthCm cm · '
                '$existingCount ${existingCount == 1 ? 'coltura' : 'colture'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScale(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final scaleValues = _buildScaleValues();

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < scaleValues.length; index++)
              Expanded(
                child: Align(
                  alignment: index == 0
                      ? Alignment.centerLeft
                      : index == scaleValues.length - 1
                          ? Alignment.centerRight
                          : Alignment.center,
                  child: Text(
                    '${scaleValues[index]}',
                    style: textStyle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 8,
          child: CustomPaint(
            size: const Size(double.infinity, 8),
            painter: _TimelineScalePainter(
              divisions: math.max(1, scaleValues.length - 1),
              lineColor:
                  Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }

  List<int> _buildScaleValues() {
    final values = <int>[];
    const preferredStepCm = 100;

    for (
      var value = 0;
      value < _safeBedLengthCm;
      value += preferredStepCm
    ) {
      values.add(value);
    }

    if (values.isEmpty || values.last != _safeBedLengthCm) {
      values.add(_safeBedLengthCm);
    }

    return values;
  }
    Widget _buildEmptyMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'In questa aiuola non risultano ancora colture presenti.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPlantingPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Inserisci coltura, quantità e distanze per visualizzare '
        'la nuova posizione.',
      ),
    );
  }

  Widget _buildPreviewResult(BuildContext context) {
    final theme = Theme.of(context);
    final endCm = newStartCm + newLengthCm;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          newPlantingFits
              ? Icons.check_circle_outline
              : Icons.warning_amber_rounded,
          size: 20,
          color: newPlantingFits
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            newPlantingFits
                ? 'Nuova coltura: da $newStartCm cm a $endCm cm.'
                : 'La nuova coltura non può essere inserita '
                    'nella posizione selezionata.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: newPlantingFits
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineEntry {
  final String label;
  final int startCm;
  final int lengthCm;
  final bool isPreview;
  final bool hasError;

  const _TimelineEntry({
    required this.label,
    required this.startCm,
    required this.lengthCm,
    required this.isPreview,
    required this.hasError,
  });
}

class _BedTimeline extends StatelessWidget {
  static const double _timelineHeight = 64;

  final int bedLengthCm;
  final List<_TimelineEntry> existingEntries;
  final _TimelineEntry? previewEntry;

  const _BedTimeline({
    required this.bedLengthCm,
    required this.existingEntries,
    required this.previewEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Container(
          height: _timelineHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (final entry in existingEntries)
                _buildPositionedEntry(
                  context: context,
                  entry: entry,
                  availableWidth: availableWidth,
                ),
              if (previewEntry != null)
                _buildPositionedEntry(
                  context: context,
                  entry: previewEntry!,
                  availableWidth: availableWidth,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionedEntry({
    required BuildContext context,
    required _TimelineEntry entry,
    required double availableWidth,
  }) {
    final safeStartCm = entry.startCm.clamp(0, bedLengthCm);
    final safeEndCm = (entry.startCm + entry.lengthCm).clamp(
      0,
      bedLengthCm,
    );

    final visibleLengthCm = math.max(
      0,
      safeEndCm - safeStartCm,
    );

    if (visibleLengthCm <= 0) {
      return const SizedBox.shrink();
    }

    final left = availableWidth * (safeStartCm / bedLengthCm);

    final calculatedWidth =
        availableWidth * (visibleLengthCm / bedLengthCm);

    final width = math.max(3.0, calculatedWidth);

    final maxAvailableWidth = math.max(
      0.0,
      availableWidth - left,
    );

    final visibleWidth = math.min(width, maxAvailableWidth);

    return Positioned(
      left: left,
      top: entry.isPreview ? 5 : 7,
      bottom: entry.isPreview ? 5 : 7,
      width: visibleWidth,
      child: _TimelineBlock(entry: entry),
    );
  }
}

class _TimelineBlock extends StatelessWidget {
  final _TimelineEntry entry;

  const _TimelineBlock({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = entry.hasError
        ? theme.colorScheme.errorContainer
        : entry.isPreview
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer;

    final foregroundColor = entry.hasError
        ? theme.colorScheme.onErrorContainer
        : entry.isPreview
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSecondaryContainer;

    final borderColor = entry.hasError
        ? theme.colorScheme.error
        : entry.isPreview
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary;

    return Tooltip(
      message:
          '${entry.label}\n'
          '${entry.startCm}–${entry.startCm + entry.lengthCm} cm\n'
          'Lunghezza: ${entry.lengthCm} cm',
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: entry.isPreview ? 2 : 1,
          ),
        ),
        child: Text(
          entry.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: entry.isPreview
                ? FontWeight.bold
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
class _TimelineScalePainter extends CustomPainter {
  final int divisions;
  final Color lineColor;

  const _TimelineScalePainter({
    required this.divisions,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      paint,
    );

    if (divisions <= 0) {
      return;
    }

    for (var index = 0; index <= divisions; index++) {
      final x = size.width * (index / divisions);

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineScalePainter oldDelegate) {
    return oldDelegate.divisions != divisions ||
        oldDelegate.lineColor != lineColor;
  }
}