import 'package:flutter/material.dart';

import 'agronomic_catalog_page.dart';
import 'documentation_page.dart';
import 'cultivars_page.dart';
import '../data/repositories/catalog_authority_repository.dart';

class SettingsPage extends StatelessWidget {
  final CatalogAuthorityRepository? catalogAuthorityRepository;

  const SettingsPage({super.key, this.catalogAuthorityRepository});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Impostazioni',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Catalogo Agronomico'),
            subtitle: const Text('Gestisci il catalogo agronomico globale'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AgronomicCatalogPage(
                    repository: catalogAuthorityRepository,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.eco),
            title: const Text('Varietà'),
            subtitle: const Text('Gestisci le varietà delle colture'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const CultivarsPage()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Documentazione'),
            subtitle: const Text(
              'Manuale utente, manuale tecnico e diario di sviluppo',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const DocumentationPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
