import 'package:flutter/material.dart';

import '../data/models/catalog_capabilities.dart';
import '../data/repositories/catalog_authority_repository.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/crop_cultivar_repository.dart';
import '../data/repositories/botanical_taxon_repository.dart';
import '../data/repositories/harvest_purpose_repository.dart';
import 'botanical_classification_page.dart';
import 'crops_and_cultivars_page.dart';
import 'harvest_purpose_page.dart';

class AgronomicCatalogPage extends StatefulWidget {
  final CatalogAuthorityRepository? repository;
  final BotanicalTaxonRepository? taxonRepository;
  final CropRepository? cropRepository;
  final CropCultivarRepository? cultivarRepository;
  final HarvestPurposeRepository? harvestPurposeRepository;

  const AgronomicCatalogPage({
    super.key,
    this.repository,
    this.taxonRepository,
    this.cropRepository,
    this.cultivarRepository,
    this.harvestPurposeRepository,
  });

  @override
  State<AgronomicCatalogPage> createState() => _AgronomicCatalogPageState();
}

class _AgronomicCatalogPageState extends State<AgronomicCatalogPage> {
  late CatalogAuthorityRepository _repository;
  late Future<CatalogCapabilities> _capabilitiesFuture;

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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Classificazione botanica'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => BotanicalClassificationPage(
                        capabilities: capabilities,
                        repository: widget.taxonRepository,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Colture e Cultivar'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => CropsAndCultivarsPage(
                        capabilities: capabilities,
                        taxonRepository: widget.taxonRepository,
                        cropRepository: widget.cropRepository,
                        cultivarRepository: widget.cultivarRepository,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Finalità di raccolta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => HarvestPurposePage(
                        capabilities: capabilities,
                        repository: widget.harvestPurposeRepository,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
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
