import 'package:flutter/material.dart';

import '../data/models/catalog_capabilities.dart';
import '../data/repositories/catalog_authority_repository.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/crop_cultivar_repository.dart';
import '../data/repositories/botanical_taxon_repository.dart';
import '../data/models/crop.dart';
import '../data/models/crop_cultivar.dart';
import '../data/models/botanical_taxon.dart';
import '../core/write_authority/botanical_taxon_write_result.dart';

class AgronomicCatalogPage extends StatefulWidget {
  final CatalogAuthorityRepository? repository;
  final BotanicalTaxonRepository? taxonRepository;
  final CropRepository? cropRepository;
  final CropCultivarRepository? cultivarRepository;

  const AgronomicCatalogPage({
    super.key,
    this.repository,
    this.taxonRepository,
    this.cropRepository,
    this.cultivarRepository,
  });

  @override
  State<AgronomicCatalogPage> createState() => _AgronomicCatalogPageState();
}

class _AgronomicCatalogPageState extends State<AgronomicCatalogPage> {
  late CatalogAuthorityRepository _repository;
  BotanicalTaxonRepository? _taxonRepository;
  CropRepository? _cropRepository;
  late Future<CatalogCapabilities> _capabilitiesFuture;
  Future<List<BotanicalTaxon>>? _taxaFuture;
  Future<List<Crop>>? _cropsFuture;
  final Set<String> _taxaWithPendingActiveChange = <String>{};

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

  Future<void> _openCreateTaxonDialog(
    List<BotanicalTaxon> availableTaxa,
  ) async {
    const ranks = [
      'ORDER',
      'FAMILY',
      'GENUS',
      'SPECIES',
      'SUBSPECIES',
      'VARIETY',
      'FORMA',
      'UNRANKED',
    ];

    var scientificName = '';
    var authorship = '';
    var description = '';

    var selectedRank = 'SPECIES';
    String? selectedParentTaxonId;
    var isHybrid = false;
    var isSubmitting = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedScientificName = scientificName.trim();

              if (normalizedScientificName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome scientifico è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await _taxonRepository!.createTaxon(
                  parentTaxonId: selectedParentTaxonId,
                  rank: selectedRank,
                  scientificName: normalizedScientificName,
                  authorship: _optionalText(authorship),
                  isHybrid: isHybrid,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case BotanicalTaxonCreated():
                    Navigator.of(dialogContext).pop();

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _taxaFuture = _taxonRepository!.getTaxa(
                        activeOnly: false,
                      );
                    });

                  case CreateBotanicalTaxonForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Non sei autorizzato a creare voci nella classificazione botanica.';
                    });

                  case CreateBotanicalTaxonInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });

                  case CreateBotanicalTaxonParentNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione superiore selezionata non è più disponibile.';
                    });

                  case CreateBotanicalTaxonDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione superiore selezionata non è attiva.';
                    });

                  case CreateBotanicalTaxonDuplicateIdentity():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Esiste già una voce con questa classificazione botanica.';
                    });
                }
              } catch (_) {
                if (!dialogContext.mounted) {
                  return;
                }

                setDialogState(() {
                  isSubmitting = false;
                  errorMessage =
                      'Errore durante la creazione della voce botanica. Riprova.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Nuova voce botanica'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRank,
                      decoration: const InputDecoration(labelText: 'Rango'),
                      items: [
                        for (final rank in ranks)
                          DropdownMenuItem(value: rank, child: Text(rank)),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedRank = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        scientificName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome scientifico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        authorship = value;
                      },
                      decoration: const InputDecoration(labelText: 'Autore'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedParentTaxonId,
                      decoration: const InputDecoration(
                        labelText: 'Classificazione superiore',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nessuno'),
                        ),
                        for (final taxon in availableTaxa)
                          DropdownMenuItem<String?>(
                            value: taxon.id,
                            child: Text(
                              '${taxon.rank} · ${taxon.scientificName}',
                            ),
                          ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedParentTaxonId = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ibrido'),
                      value: isHybrid,
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setDialogState(() {
                                isHybrid = value ?? false;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !isSubmitting,
                      maxLines: 3,
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Descrizione',
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(errorMessage!),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crea'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTaxonActiveChangeError(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Operazione non completata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showActiveTaxonDependents(
    SetBotanicalTaxonActiveDependents result,
  ) async {
    final dependencies = <String>[];

    if (result.activeChildTaxaCount > 0) {
      dependencies.add(
        '${result.activeChildTaxaCount} classificazioni botaniche attive',
      );
    }

    if (result.activeCropsCount > 0) {
      dependencies.add('${result.activeCropsCount} colture attive');
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Impossibile disattivare la classificazione botanica',
          ),
          content: Text(
            'Prima di disattivare questa voce devi gestire le dipendenze attive: '
            '${dependencies.join(', ')}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setTaxonActive(BotanicalTaxon taxon, bool isActive) async {
    if (_taxaWithPendingActiveChange.contains(taxon.id)) {
      return;
    }

    setState(() {
      _taxaWithPendingActiveChange.add(taxon.id);
    });

    try {
      final result = await _taxonRepository!.setTaxonActive(
        botanicalTaxonId: taxon.id,
        expectedRowVersion: taxon.rowVersion,
        isActive: isActive,
      );

      if (!mounted) {
        return;
      }

      if (result is BotanicalTaxonActiveChanged ||
          result is SetBotanicalTaxonActiveUnchanged) {
        setState(() {
          _taxaFuture = _taxonRepository!.getTaxa(activeOnly: false);
        });
      }
      if (result is SetBotanicalTaxonActiveDependents) {
        await _showActiveTaxonDependents(result);
      }
      if (result is SetBotanicalTaxonActiveDependencyInactive) {
        if (!mounted) {
          return;
        }

        await showDialog<void>(
          context: context,

          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                'Impossibile riattivare la classificazione botanica',
              ),
              content: const Text(
                'La classificazione superiore deve essere riattivata prima '
                'di poter riattivare questa voce.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      if (result is SetBotanicalTaxonActiveForbidden) {
        await _showTaxonActiveChangeError(
          'Non sei autorizzato a modificare lo stato della classificazione botanica.',
        );
      }

      if (result is SetBotanicalTaxonActiveInvalidInput) {
        await _showTaxonActiveChangeError(
          'La richiesta di modifica dello stato della classificazione botanica non è valida.',
        );
      }

      if (result is SetBotanicalTaxonActiveNotFound) {
        await _showTaxonActiveChangeError(
          'La classificazione botanica non è più disponibile.',
        );
      }
      if (result is SetBotanicalTaxonActiveVersionConflict) {
        setState(() {
          _taxaFuture = _taxonRepository!.getTaxa(activeOnly: false);
        });

        await _showTaxonActiveChangeError(
          'La classificazione botanica è stata modificata. '
          'I dati sono stati ricaricati prima di effettuare una nuova operazione.',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _taxaFuture = _taxonRepository!.getTaxa(activeOnly: false);
      });

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Stato da verificare'),
            content: const Text(
              'Non è stato possibile verificare l\'esito dell\'operazione. '
              'I dati sono stati ricaricati prima di consentire una nuova modifica.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _taxaWithPendingActiveChange.remove(taxon.id);
        });
      }
    }
  }

  Future<void> _confirmDeactivateTaxon(BotanicalTaxon taxon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Disattivare la classificazione botanica?'),
          content: const Text(
            'La voce botanica rimarrà nel catalogo ma non sarà più attiva.',
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

    await _setTaxonActive(taxon, false);
  }

  Future<void> _openEditTaxonDialog(
    BotanicalTaxon taxon,
    List<BotanicalTaxon> availableTaxa,
  ) async {
    const ranks = [
      'ORDER',
      'FAMILY',
      'GENUS',
      'SPECIES',
      'SUBSPECIES',
      'VARIETY',
      'FORMA',
      'UNRANKED',
    ];

    var scientificName = taxon.scientificName;
    var authorship = taxon.authorship ?? '';
    var description = taxon.description ?? '';

    var selectedRank = taxon.rank;
    var selectedParentTaxonId = taxon.parentTaxonId;
    var isHybrid = taxon.isHybrid;
    var isSubmitting = false;
    String? errorMessage;
    var requiresAuthoritativeReload = false;

    final possibleParents = availableTaxa
        .where((candidate) => candidate.id != taxon.id)
        .toList();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedScientificName = scientificName.trim();

              if (normalizedScientificName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome scientifico è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await _taxonRepository!.updateTaxon(
                  botanicalTaxonId: taxon.id,
                  expectedRowVersion: taxon.rowVersion,
                  parentTaxonId: selectedParentTaxonId,
                  rank: selectedRank,
                  scientificName: normalizedScientificName,
                  authorship: _optionalText(authorship),
                  isHybrid: isHybrid,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case BotanicalTaxonUpdated():
                  case UpdateBotanicalTaxonUnchanged():
                    Navigator.of(dialogContext).pop();

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _taxaFuture = _taxonRepository!.getTaxa(
                        activeOnly: false,
                      );
                    });
                  case UpdateBotanicalTaxonVersionConflict():
                    setDialogState(() {
                      isSubmitting = false;
                      requiresAuthoritativeReload = true;
                      errorMessage =
                          'La classificazione botanica è stata modificata nel frattempo. '
                          'Ricarica i dati prima di effettuare una nuova modifica.';
                    });
                  case UpdateBotanicalTaxonForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Non sei autorizzato a modificare la classificazione botanica.';
                    });
                  case UpdateBotanicalTaxonInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });
                  case UpdateBotanicalTaxonNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La voce botanica da modificare non è più disponibile.';
                    });
                  case UpdateBotanicalTaxonParentNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione superiore selezionata non è più disponibile.';
                    });
                  case UpdateBotanicalTaxonDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione superiore selezionata non è attiva.';
                    });
                  case UpdateBotanicalTaxonDuplicateIdentity():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Esiste già una voce con questa classificazione botanica.';
                    });
                }
              } catch (_) {
                if (!dialogContext.mounted) {
                  return;
                }

                setDialogState(() {
                  isSubmitting = false;
                  requiresAuthoritativeReload = true;
                  errorMessage =
                      'Non è stato possibile verificare l\'esito del salvataggio. '
                      'Ricarica i dati prima di effettuare una nuova modifica.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Modifica classificazione botanica'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRank,
                      decoration: const InputDecoration(labelText: 'Rango'),
                      items: [
                        for (final rank in ranks)
                          DropdownMenuItem(value: rank, child: Text(rank)),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedRank = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: scientificName,
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        scientificName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome scientifico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: authorship,
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        authorship = value;
                      },
                      decoration: const InputDecoration(labelText: 'Autore'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedParentTaxonId,
                      decoration: const InputDecoration(
                        labelText: 'Classificazione superiore',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nessuno'),
                        ),
                        for (final parent in possibleParents)
                          DropdownMenuItem<String?>(
                            value: parent.id,
                            child: Text(
                              '${parent.rank} · ${parent.scientificName}',
                            ),
                          ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedParentTaxonId = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ibrido'),
                      value: isHybrid,
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setDialogState(() {
                                isHybrid = value ?? false;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: description,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Descrizione',
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(errorMessage!),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: isSubmitting || requiresAuthoritativeReload
                      ? null
                      : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );

    if (requiresAuthoritativeReload && mounted) {
      setState(() {
        _taxaFuture = _taxonRepository!.getTaxa(activeOnly: false);
      });
    }
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _openCropCultivars(Crop crop) async {
    final repository = widget.cultivarRepository ?? CropCultivarRepository();

    try {
      final cultivars = await repository.getCultivarsByCrop(crop.id);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Cultivar di ${crop.name}'),
            content: cultivars.isEmpty
                ? const Text('Nessuna cultivar presente.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final CropCultivar cultivar in cultivars)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(cultivar.name),
                          subtitle: _buildCultivarSubtitle(cultivar),
                        ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Chiudi'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Errore'),
            content: const Text(
              'Errore durante il caricamento delle cultivar.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _openCropCultivars(crop);
                },
                child: const Text('Riprova'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Chiudi'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget? _buildCultivarSubtitle(CropCultivar cultivar) {
    final details = <String>[];

    if (cultivar.verificationStatus != 'VERIFIED') {
      details.add(cultivar.verificationStatus);
    }

    if (cultivar.description != null) {
      details.add(cultivar.description!);
    }

    if (details.isEmpty) {
      return null;
    }

    return Text(details.join(' · '));
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
          _taxonRepository ??=
              widget.taxonRepository ?? BotanicalTaxonRepository();
          _taxaFuture ??= _taxonRepository!.getTaxa(activeOnly: false);
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tassonomia botanica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (capabilities.canManageIdentity)
                      FilledButton.icon(
                        onPressed: () {
                          final taxa = _taxaFuture;

                          if (taxa == null) {
                            return;
                          }

                          taxa.then((availableTaxa) {
                            if (!mounted) {
                              return;
                            }

                            _openCreateTaxonDialog(availableTaxa);
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nuova voce botanica'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<BotanicalTaxon>>(
                  future: _taxaFuture,
                  builder: (context, taxaSnapshot) {
                    if (taxaSnapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (taxaSnapshot.hasError) {
                      return const Text(
                        'Errore durante il caricamento della tassonomia botanica.',
                      );
                    }

                    final taxa = taxaSnapshot.data!;

                    if (taxa.isEmpty) {
                      return const Text(
                        'Nessuna voce presente nella tassonomia botanica.',
                      );
                    }

                    return Column(
                      children: [
                        for (final taxon in taxa)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(taxon.scientificName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  taxon.authorship == null
                                      ? taxon.rank
                                      : '${taxon.rank} · ${taxon.authorship}',
                                ),
                                if (!taxon.isActive) const Text('Inattiva'),
                              ],
                            ),
                            trailing: capabilities.canManageIdentity
                                ? Wrap(
                                    spacing: 4,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _openEditTaxonDialog(taxon, taxa);
                                        },
                                        child: const Text('Modifica'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            _taxaWithPendingActiveChange
                                                .contains(taxon.id)
                                            ? null
                                            : taxon.isActive
                                            ? () =>
                                                  _confirmDeactivateTaxon(taxon)
                                            : () =>
                                                  _setTaxonActive(taxon, true),
                                        child: Text(
                                          taxon.isActive
                                              ? 'Disattiva'
                                              : 'Riattiva',
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                      ],
                    );
                  },
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
              } else {
                for (final crop in cropsSnapshot.data!) {
                  children.add(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => _openCropCultivars(crop),
                      title: Text(crop.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (crop.scientificName != null)
                            Text(crop.scientificName!),
                          if (crop.botanicalFamilyName != null)
                            Text(crop.botanicalFamilyName!),
                        ],
                      ),
                    ),
                  );
                }
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
