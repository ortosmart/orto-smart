import 'package:flutter/material.dart';

import '../data/models/catalog_capabilities.dart';
import '../data/repositories/catalog_authority_repository.dart';
import '../data/repositories/crop_repository.dart';
import '../data/models/crop.dart';

class AgronomicCatalogPage extends StatefulWidget {
  final CatalogAuthorityRepository? repository;
  final CropRepository? cropRepository;

  const AgronomicCatalogPage({super.key, this.repository, this.cropRepository});

  @override
  State<AgronomicCatalogPage> createState() => _AgronomicCatalogPageState();
}

class _AgronomicCatalogPageState extends State<AgronomicCatalogPage> {
  late CatalogAuthorityRepository _repository;
  CropRepository? _cropRepository;
  late Future<CatalogCapabilities> _capabilitiesFuture;
  Future<List<Crop>>? _cropsFuture;

  bool _authorityAlreadyClaimed = false;
  bool _authorityInitializationForbidden = false;
  bool _authorityInitializationError = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CatalogAuthorityRepository();
    _capabilitiesFuture = _repository.getMyCapabilities();
  }

  Future<void> _confirmInitialization() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Inizializzare il Catalogo Agronomico?'),
          content: const Text(
            'L’operazione richiede l’autorizzazione del database. '
            'L’idoneità dell’utente sarà verificata dal server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    ClaimInitialCatalogAuthorityStatus result;

    try {
      result = await _repository.claimInitialAuthority();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _authorityInitializationError = true;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    if (result == ClaimInitialCatalogAuthorityStatus.claimed ||
        result == ClaimInitialCatalogAuthorityStatus.alreadyInitialized) {
      setState(() {
        _capabilitiesFuture = _repository.getMyCapabilities();
      });
    }
    if (result == ClaimInitialCatalogAuthorityStatus.alreadyClaimed) {
      setState(() {
        _authorityAlreadyClaimed = true;
      });
    }
    if (result == ClaimInitialCatalogAuthorityStatus.forbidden) {
      setState(() {
        _authorityInitializationForbidden = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogo Agronomico')),
      body: FutureBuilder<CatalogCapabilities>(
        future: _capabilitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Errore durante il caricamento del Catalogo.'),
            );
          }

          final capabilities = snapshot.data!;
          if (_authorityInitializationError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Text(
                  'Errore durante l’inizializzazione del Catalogo.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Non è stato possibile completare l’operazione. Riprova più tardi.',
                ),
              ],
            );
          }
          if (_authorityAlreadyClaimed) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Text(
                  'Authority già assegnata',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'L’autorità globale del Catalogo Agronomico è già stata assegnata.',
                ),
              ],
            );
          }
          if (_authorityInitializationForbidden) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Text(
                  'Inizializzazione non autorizzata',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Non sei autorizzato a inizializzare l’Authority globale del Catalogo Agronomico.',
                ),
              ],
            );
          }
          if (capabilities.rowVersion == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Catalogo non inizializzato',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'L’autorità globale del Catalogo Agronomico non risulta inizializzata.',
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _confirmInitialization,
                    child: const Text('Inizializza Catalogo'),
                  ),
                ),
              ],
            );
          }
          _cropRepository ??= widget.cropRepository ?? CropRepository();
          _cropsFuture ??= _cropRepository!.getCrops();

          return FutureBuilder<List<Crop>>(
            future: _cropsFuture,
            builder: (context, cropsSnapshot) {
              final children = <Widget>[
                const Text(
                  'Authority attiva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _CapabilityTile(
                  label: 'Gestione identità',
                  enabled: capabilities.canManageIdentity,
                ),
                _CapabilityTile(
                  label: 'Acquisizione dati',
                  enabled: capabilities.canIngest,
                ),
                _CapabilityTile(
                  label: 'Revisione',
                  enabled: capabilities.canReview,
                ),
                _CapabilityTile(
                  label: 'Pubblicazione',
                  enabled: capabilities.canPublish,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Colture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ];

              if (cropsSnapshot.connectionState != ConnectionState.done) {
                children.add(const Center(child: CircularProgressIndicator()));
              } else if (cropsSnapshot.hasError) {
                children.add(
                  const Text('Errore durante il caricamento delle colture.'),
                );
              } else if (cropsSnapshot.data!.isEmpty) {
                children.add(
                  const Text(
                    'Nessuna coltura presente nel Catalogo Agronomico.',
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: children,
              );
            },
          );
        },
      ),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  final String label;
  final bool enabled;

  const _CapabilityTile({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        enabled ? Icons.check_circle_outline : Icons.remove_circle_outline,
      ),
      title: Text(label),
    );
  }
}
