import 'package:flutter/material.dart';

import '../../data/models/garden.dart';

class GardenCard extends StatelessWidget {
  final Garden garden;

  const GardenCard({super.key, required this.garden});

  @override
  Widget build(BuildContext context) {
    final description = garden.description;

    return Card(
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.grass, color: Colors.white),
        ),
        title: Text(
          garden.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: description == null || description.trim().isEmpty
            ? null
            : Text(description),
      ),
    );
  }
}
