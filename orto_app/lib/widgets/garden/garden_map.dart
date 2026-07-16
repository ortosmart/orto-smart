import 'package:flutter/material.dart';
import '../../pages/bed_page.dart';

class GardenMap extends StatelessWidget {
  final int bedsCount;

  const GardenMap({
    super.key,
    required this.bedsCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bedsCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.grass),
              title: Text('Aiuola ${index + 1}'),
              subtitle: const Text('Nessuna coltura'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BedPage(
        bedNumber: index + 1,
      ),
    ),
  );
},
            ),
          ),
        );
      },
    );
  }
}