import 'package:flutter/material.dart';

import '../../data/models/bed_analysis_result.dart';

class SpaceSuggestionCard extends StatelessWidget {
  final bool isLoading;
  final String? loadingError;
  final int calculatedLengthCm;
  final int existingPlantingsCount;
  final BedAnalysisResult? analysis;
  final dynamic bestSpace;
  final bool isAutomaticPosition;
  final VoidCallback onRetry;
  final String Function(double value) formatCentimeters;
  final double Function(dynamic space) remainingSpaceAfterInsertion;

  const SpaceSuggestionCard({
    super.key,
    required this.isLoading,
    required this.loadingError,
    required this.calculatedLengthCm,
    required this.existingPlantingsCount,
    required this.analysis,
    required this.bestSpace,
    required this.isAutomaticPosition,
    required this.onRetry,
    required this.formatCentimeters,
    required this.remainingSpaceAfterInsertion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Expanded(child: Text('Calcolo degli spazi disponibili...')),
            ],
          ),
        ),
      );
    }

    if (loadingError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Impossibile analizzare gli spazi disponibili.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(loadingError!),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (calculatedLengthCm <= 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(),
              SizedBox(height: 12),
              Text(
                'Inserisci i dati della coltura per ricevere '
                'un suggerimento automatico.',
              ),
            ],
          ),
        ),
      );
    }

    final currentAnalysis = analysis;

    if (currentAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(),
            const SizedBox(height: 8),
            Text(
              'Colture già presenti: $existingPlantingsCount',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (currentAnalysis.freeSpaces.isEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Non risultano spazi liberi nell’aiuola.'),
                  ),
                ],
              )
            else
              ...currentAnalysis.freeSpaces.map(
                (freeSpace) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${formatCentimeters(freeSpace.startCm)} – '
                          '${formatCentimeters(freeSpace.endCm)} cm',
                        ),
                      ),
                      Text(
                        '${formatCentimeters(freeSpace.lengthCm)} cm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 24),
            if (bestSpace != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Miglior spazio: '
                      '${formatCentimeters(bestSpace.startCm)} – '
                      '${formatCentimeters(bestSpace.endCm)} cm',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Scelto perché lascia soltanto '
                '${formatCentimeters(remainingSpaceAfterInsertion(bestSpace))} cm inutilizzati nello spazio disponibile.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                isAutomaticPosition
                    ? 'La posizione migliore è stata applicata automaticamente.'
                    : 'Hai scelto manualmente la posizione.',
                style: theme.textTheme.bodySmall,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentAnalysis.message ??
                          'Nessuno spazio è abbastanza grande '
                              'per questa coltura.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome_outlined),
        const SizedBox(width: 8),
        Text(
          'Spazi disponibili',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
