import 'package:flutter/material.dart';
import 'user_manual/introduction_page.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manuale Utente')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Indice',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.looks_one),
            title: const Text('1. Introduzione'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const IntroductionPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.looks_two),
            title: Text('2. Primo avvio'),
          ),
          ListTile(leading: Icon(Icons.looks_3), title: Text('3. Dashboard')),
          ListTile(
            leading: Icon(Icons.looks_4),
            title: Text('4. Gestione Orto'),
          ),
          ListTile(leading: Icon(Icons.looks_5), title: Text('5. Aiuole')),
          ListTile(leading: Icon(Icons.looks_6), title: Text('6. Colture')),
          ListTile(leading: Icon(Icons.filter_7), title: Text('7. Varietà')),
          ListTile(
            leading: Icon(Icons.filter_8),
            title: Text('8. Irrigazione'),
          ),
          ListTile(leading: Icon(Icons.filter_9), title: Text('9. Raccolti')),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('10. Domande frequenti'),
          ),
        ],
      ),
    );
  }
}
