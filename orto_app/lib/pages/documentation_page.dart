import 'package:flutter/material.dart';
import 'user_manual_page.dart';

class DocumentationPage extends StatelessWidget {
  const DocumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentazione')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DocumentationCard(
            icon: Icons.menu_book_outlined,
            title: 'Manuale utente',
            description:
                'Istruzioni per utilizzare Orto Smart e gestire il proprio orto.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const UserManualPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _DocumentationCard(
            icon: Icons.code,
            title: 'Manuale tecnico',
            description:
                'Architettura, database, modelli, repository e motore agronomico.',
            onTap: () {
              _showComingSoon(context, 'Manuale tecnico');
            },
          ),
          const SizedBox(height: 12),
          _DocumentationCard(
            icon: Icons.history_edu_outlined,
            title: 'Diario di sviluppo',
            description:
                'Cronologia delle sessioni, modifiche e funzionalità completate.',
            onTap: () {
              _showComingSoon(context, 'Diario di sviluppo');
            },
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: contenuto in preparazione')),
    );
  }
}

class _DocumentationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DocumentationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
