import 'package:flutter/material.dart';

import '../../data/models/crop.dart';
import '../../data/models/rotation_result.dart';

class RotationCard extends StatelessWidget {
  final Crop? selectedCrop;
  final RotationResult? result;
  final bool isLoading;
  final bool hasLoadingError;

  const RotationCard({
    super.key,
    required this.selectedCrop,
    required this.result,
    required this.isLoading,
    required this.hasLoadingError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedCrop == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(),
              SizedBox(height: 12),
              Text(
                'Seleziona una coltura per ricevere la valutazione '
                'della rotazione.',
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Valutazione della rotazione in corso...')),
            ],
          ),
        ),
      );
    }

    if (hasLoadingError || result == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'La valutazione della rotazione non è disponibile.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    late final IconData statusIcon;
    late final Color statusColor;
    late final String statusLabel;

    switch (result!.rating) {
      case RotationRating.recommended:
        statusIcon = Icons.check_circle;
        statusColor = theme.colorScheme.primary;
        statusLabel = 'Consigliata';
        break;
      case RotationRating.acceptable:
        statusIcon = Icons.info;
        statusColor = theme.colorScheme.tertiary;
        statusLabel = 'Accettabile';
        break;
      case RotationRating.discouraged:
        statusIcon = Icons.warning_amber_rounded;
        statusColor = theme.colorScheme.error;
        statusLabel = 'Sconsigliata';
        break;
      case RotationRating.unknown:
        statusIcon = Icons.help_outline;
        statusColor = theme.colorScheme.outline;
        statusLabel = 'Dati insufficienti';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${result!.score}/100',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Famiglia botanica: '
              '${selectedCrop!.botanicalFamily ?? 'non disponibile'}',
              style: theme.textTheme.bodySmall,
            ),
            if (result!.requiredRotationSeasons != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rotazione consigliata: '
                '${result!.requiredRotationSeasons} stagioni',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const Divider(height: 24),
            ...result!.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.chevron_right, size: 20, color: statusColor),
                    const SizedBox(width: 6),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.autorenew),
        const SizedBox(width: 8),
        Text(
          'Rotazione colturale',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
