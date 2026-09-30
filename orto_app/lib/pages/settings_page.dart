import 'package:flutter/material.dart';

import 'agronomic_catalog_page.dart';
import 'documentation_page.dart';
import '../data/repositories/catalog_authority_repository.dart';
import '../data/repositories/crop_repository.dart';

class SettingsPage extends StatelessWidget {
  final CatalogAuthorityRepository? catalogAuthorityRepository;
  final CropRepository? cropRepository;

  const SettingsPage({
    super.key,
    this.catalogAuthorityRepository,
    this.cropRepository,
  });

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
                    cropRepository: cropRepository,
                  ),
                ),
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
