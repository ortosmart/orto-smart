import 'package:flutter/material.dart';

class BedPage extends StatelessWidget {
  final int bedNumber;

  const BedPage({
    super.key,
    required this.bedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aiuola $bedNumber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aiuola $bedNumber',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Card(
              child: ListTile(
                leading: Icon(Icons.eco),
                title: Text('Coltura'),
                subtitle: Text('Non impostata'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Data semina'),
                subtitle: Text('Non impostata'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.water_drop),
                title: Text('Irrigazione'),
                subtitle: Text('Nessun dato'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.photo),
                title: Text('Fotografie'),
                subtitle: Text('0 immagini'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}