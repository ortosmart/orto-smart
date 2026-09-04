import 'package:flutter/material.dart';

import '../core/agronomy/models/bed_companion_analysis.dart';
import '../core/agronomy/models/companion_rule.dart';
import '../data/models/crop.dart';

/// Visualizza il riepilogo e il dettaglio delle consociazioni
/// tra le colture presenti in un'aiuola.
///
/// Il widget non esegue calcoli agronomici: riceve un'analisi già
/// elaborata da [BedAnalysisService].
class CompanionAnalysisWidget extends StatelessWidget {
  final BedCompanionAnalysis analysis;
  final Map<String, Crop> cropsById;

  const CompanionAnalysisWidget({
    super.key,
    required this.analysis,
    required this.cropsById,
  });

  @override
  Widget build(BuildContext context) {
    if (analysis.totalPairs == 0) {
      return const _EmptyCompanionAnalysisCard();
    }

    final theme = Theme.of(context);
    final hasIncompatibilities = analysis.hasIncompatibilities;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: hasIncompatibilities
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consociazioni',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasIncompatibilities
                            ? 'Sono presenti consociazioni da verificare.'
                            : 'Non sono state rilevate incompatibilità.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  icon: Icons.compare_arrows,
                  label: '${analysis.totalPairs} coppie analizzate',
                ),
                _SummaryChip(
                  icon: Icons.check_circle_outline,
                  label: '${analysis.compatiblePairs} compatibili',
                ),
                _SummaryChip(
                  icon: Icons.warning_amber_rounded,
                  label: '${analysis.incompatiblePairs} da verificare',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),
            ...analysis.pairs.map((pair) {
              final cropAName = _cropName(pair.cropAId);
              final cropBName = _cropName(pair.cropBId);
              final presentation = _presentationFor(
                context,
                pair.result.compatibility,
              );

              return _CompanionPairTile(
                cropAName: cropAName,
                cropBName: cropBName,
                message: pair.result.message,
                presentation: presentation,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _cropName(String cropId) {
    final cropName = cropsById[cropId]?.name.trim();

    if (cropName == null || cropName.isEmpty) {
      return 'Coltura sconosciuta';
    }

    return cropName;
  }

  _CompatibilityPresentation _presentationFor(
    BuildContext context,
    CompanionCompatibility compatibility,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (compatibility) {
      CompanionCompatibility.excellent => _CompatibilityPresentation(
        label: 'Eccellente',
        icon: Icons.stars_rounded,
        color: colorScheme.primary,
      ),
      CompanionCompatibility.good => _CompatibilityPresentation(
        label: 'Buona',
        icon: Icons.check_circle_outline,
        color: colorScheme.secondary,
      ),
      CompanionCompatibility.neutral => _CompatibilityPresentation(
        label: 'Neutrale',
        icon: Icons.info_outline,
        color: colorScheme.onSurfaceVariant,
      ),
      CompanionCompatibility.bad => _CompatibilityPresentation(
        label: 'Sconsigliata',
        icon: Icons.warning_amber_rounded,
        color: colorScheme.error,
      ),
      CompanionCompatibility.incompatible => _CompatibilityPresentation(
        label: 'Incompatibile',
        icon: Icons.cancel_outlined,
        color: colorScheme.error,
      ),
    };
  }
}

class _CompanionPairTile extends StatelessWidget {
  final String cropAName;
  final String cropBName;
  final String message;
  final _CompatibilityPresentation presentation;

  const _CompanionPairTile({
    required this.cropAName,
    required this.cropBName,
    required this.message,
    required this.presentation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(presentation.icon, color: presentation.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cropAName ↔ $cropBName',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  presentation.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: presentation.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _EmptyCompanionAnalysisCard extends StatelessWidget {
  const _EmptyCompanionAnalysisCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.eco_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consociazioni',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Servono almeno due colture per analizzare '
                    'le consociazioni dell’aiuola.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityPresentation {
  final String label;
  final IconData icon;
  final Color color;

  const _CompatibilityPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });
}
