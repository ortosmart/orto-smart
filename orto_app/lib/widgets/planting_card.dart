import 'package:flutter/material.dart';

import '../data/models/crop.dart';
import '../data/models/planting.dart';

enum PlantingCardAction {
  edit,
  growing,
  harvestReady,
  harvested,
  finished,
  removed,
}

class PlantingCard extends StatelessWidget {
  final Planting planting;
  final Crop? crop;
  final VoidCallback onEdit;
  final ValueChanged<String>? onStatusChange;

  const PlantingCard({
    super.key,
    required this.planting,
    required this.crop,
    required this.onEdit,
    this.onStatusChange,
  });

  String get _cropName {
    final name = crop?.name.trim();

    if (name == null || name.isEmpty) {
      return 'Coltura non disponibile';
    }

    return name;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _statusText(String status) {
    switch (status) {
      case 'growing':
        return 'In crescita';
      case 'sown':
        return 'Seminata';
      case 'harvest_ready':
        return 'Pronta alla raccolta';
      case 'harvested':
        return 'Raccolta';
      case 'finished':
        return 'Terminata';
      case 'removed':
        return 'Rimossa';
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'growing':
        return Icons.eco;
      case 'sown':
        return Icons.grass;
      case 'harvest_ready':
        return Icons.agriculture_outlined;
      case 'harvested':
        return Icons.shopping_basket_outlined;
      case 'finished':
        return Icons.check_circle_outline;
      case 'removed':
        return Icons.remove_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  void _handleAction(PlantingCardAction action) {
    switch (action) {
      case PlantingCardAction.edit:
        onEdit();

      case PlantingCardAction.growing:
        onStatusChange?.call('growing');

      case PlantingCardAction.harvestReady:
        onStatusChange?.call('harvest_ready');

      case PlantingCardAction.harvested:
        onStatusChange?.call('harvested');

      case PlantingCardAction.finished:
        onStatusChange?.call('finished');

      case PlantingCardAction.removed:
        onStatusChange?.call('removed');
    }
  }

  List<PopupMenuEntry<PlantingCardAction>> _menuItems() {
    final items = <PopupMenuEntry<PlantingCardAction>>[
      const PopupMenuItem<PlantingCardAction>(
        value: PlantingCardAction.edit,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.edit_outlined),
          title: Text('Modifica'),
        ),
      ),
    ];

    switch (planting.status) {
      case 'sown':
        items.addAll(const [
          PopupMenuDivider(),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.growing,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.eco_outlined),
              title: Text('Segna in crescita'),
            ),
          ),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.removed,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.remove_circle_outline),
              title: Text('Rimuovi'),
            ),
          ),
        ]);

      case 'growing':
        items.addAll(const [
          PopupMenuDivider(),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.harvestReady,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.agriculture_outlined),
              title: Text('Segna pronta alla raccolta'),
            ),
          ),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.removed,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.remove_circle_outline),
              title: Text('Rimuovi'),
            ),
          ),
        ]);

      case 'harvest_ready':
        items.addAll(const [
          PopupMenuDivider(),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.harvested,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.shopping_basket_outlined),
              title: Text('Segna raccolta'),
            ),
          ),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.removed,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.remove_circle_outline),
              title: Text('Rimuovi'),
            ),
          ),
        ]);

      case 'harvested':
        items.addAll(const [
          PopupMenuDivider(),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.finished,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline),
              title: Text('Termina coltivazione'),
            ),
          ),
          PopupMenuItem<PlantingCardAction>(
            value: PlantingCardAction.removed,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.remove_circle_outline),
              title: Text('Rimuovi'),
            ),
          ),
        ]);

      case 'finished':
      case 'removed':
        break;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final startCm = planting.startPositionCm;
    final endCm = planting.startPositionCm + planting.lengthCm;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.eco)),
            title: Text(
              _cropName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Inizio: ${_formatDate(planting.startDate)}'),
            trailing: PopupMenuButton<PlantingCardAction>(
              tooltip: 'Azioni coltura',
              onSelected: _handleAction,
              itemBuilder: (context) => _menuItems(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.straighten),
            title: const Text('Posizione nell’aiuola'),
            subtitle: Text(
              '$startCm–$endCm cm · ${planting.lengthCm} cm occupati',
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.numbers),
            title: Text(
              planting.plantsCount == null
                  ? 'Numero di piante non indicato'
                  : '${planting.plantsCount} piante',
            ),
          ),
          ListTile(
            dense: true,
            leading: Icon(_statusIcon(planting.status)),
            title: Text(_statusText(planting.status)),
            subtitle: planting.status == 'harvested'
                ? const Text(
                    'L’aiuola resta occupata finché la coltivazione '
                    'non viene terminata o rimossa.',
                  )
                : null,
          ),
          if (planting.notes != null && planting.notes!.trim().isNotEmpty)
            ListTile(
              dense: true,
              leading: const Icon(Icons.notes),
              title: Text(planting.notes!),
            ),
        ],
      ),
    );
  }
}
