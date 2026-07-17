import 'package:flutter/material.dart';

import '../../data/models/bed.dart';

class BedCard extends StatelessWidget {
  final Bed bed;
  final VoidCallback onTap;

  const BedCard({
    super.key,
    required this.bed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomName =
        bed.name != null && bed.name!.trim().isNotEmpty;

    final irrigationText = bed.irrigationZone == null
        ? 'Zona irrigazione non impostata'
        : 'Zona irrigazione ${bed.irrigationZone}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 7),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.grass,
                  size: 30,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bed.code,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: bed.isActive
                                ? Colors.green.shade100
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bed.isActive ? 'Attiva' : 'Disattiva',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: bed.isActive
                                  ? Colors.green.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCustomName
                          ? bed.name!
                          : 'Aiuola ${bed.number}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.straighten,
                          size: 19,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${bed.widthCm} × ${bed.lengthCm} cm',
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 19,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(irrigationText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}