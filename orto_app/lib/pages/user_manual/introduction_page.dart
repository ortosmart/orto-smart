import 'package:flutter/material.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1. Introduzione')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Benvenuto in Orto Smart',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Text(
            'Orto Smart è un\'applicazione progettata per accompagnare '
            'l\'orticoltore nella gestione completa del proprio orto, dalla '
            'progettazione delle aiuole fino alla raccolta dei prodotti.',
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 20),

          Text(
            'Con Orto Smart puoi:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Gestire orti e aiuole'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Pianificare colture e varietà'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Registrare semine e raccolti'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Monitorare irrigazione e meteo'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Ricevere suggerimenti agronomici'),
          ),

          SizedBox(height: 24),

          Text(
            'Obiettivo del progetto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          Text(
            'L\'obiettivo di Orto Smart è creare un sistema intelligente '
            'che aiuti il coltivatore a prendere decisioni migliori, '
            'conservando l\'esperienza maturata stagione dopo stagione.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
