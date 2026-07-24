import 'package:flutter/material.dart';

class PositionModeCard extends StatelessWidget {
  final bool isAutomatic;
  final bool isSaving;
  final VoidCallback onEnableAutomaticPosition;

  const PositionModeCard({
    super.key,
    required this.isAutomatic,
    required this.isSaving,
    required this.onEnableAutomaticPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isAutomatic
                  ? Icons.auto_awesome_outlined
                  : Icons.pan_tool_alt_outlined,
              color: isAutomatic
                  ? theme.colorScheme.primary
                  : theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAutomatic
                        ? 'Posizionamento automatico'
                        : 'Posizionamento manuale',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAutomatic
                        ? 'Orto Smart usa il primo spazio disponibile '
                              'abbastanza grande per la nuova coltura.'
                        : 'La posizione scelta viene rispettata anche '
                              'se cambiano quantità o distanze.',
                  ),
                  if (!isAutomatic) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isSaving ? null : onEnableAutomaticPosition,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Torna al posizionamento automatico'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
