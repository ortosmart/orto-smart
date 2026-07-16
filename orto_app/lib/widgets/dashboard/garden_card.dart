import 'package:flutter/material.dart';

import '../../data/models/garden.dart';

class GardenCard extends StatelessWidget {
  final Garden garden;

  const GardenCard({
    super.key,
    required this.garden,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.grass,
            color: Colors.white,
          ),
        ),
        title: Text(
          garden.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${garden.bedsCount} aiuole • ${garden.bedWidthCm} × ${garden.bedLengthCm} cm',
        ),
      ),
    );
  }
}