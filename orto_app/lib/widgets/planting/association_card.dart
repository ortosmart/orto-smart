import 'package:flutter/material.dart';

import '../../data/models/association_result.dart';

class AssociationCard extends StatelessWidget {
  final bool hasSelectedCrop;
  final bool isLoading;
  final AssociationResult? result;

  const AssociationCard({
    super.key,
    required this.hasSelectedCrop,
    required this.isLoading,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasSelectedCrop) {
      return const SizedBox.shrink();
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
              Expanded(child: Text('Analisi delle consociazioni...')),
            ],
          ),
        ),
      );
    }

    final associationResult = result;

    if (associationResult == null) {
      return const SizedBox.shrink();
    }

    late final IconData icon;
    late final Color color;
    late final String title;

    switch (associationResult.rating) {
      case AssociationRating.excellent:
        icon = Icons.verified;
        color = Colors.green;
        title = 'Consociazione eccellente';
        break;

      case AssociationRating.good:
        icon = Icons.thumb_up;
        color = Colors.lightGreen;
        title = 'Consociazione buona';
        break;

      case AssociationRating.acceptable:
        icon = Icons.info;
        color = Colors.orange;
        title = 'Consociazione accettabile';
        break;

      case AssociationRating.poor:
        icon = Icons.warning_amber_rounded;
        color = Colors.deepOrange;
        title = 'Consociazione sfavorevole';
        break;

      case AssociationRating.incompatible:
        icon = Icons.cancel;
        color = theme.colorScheme.error;
        title = 'Colture incompatibili';
        break;

      case AssociationRating.unknown:
        icon = Icons.help_outline;
        color = theme.colorScheme.outline;
        title = 'Dati insufficienti';
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
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${associationResult.score}/100',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...associationResult.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.chevron_right, size: 20, color: color),
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
        const Icon(Icons.groups_outlined),
        const SizedBox(width: 8),
        Text('Consociazioni', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
