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
import '../core/write_authority/catalog_crop_write_result.dart';
import '../core/write_authority/crop_cultivar_write_result.dart';

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
  final Set<String> _cropsWithPendingActiveChange = <String>{};
  final Set<String> _cultivarsWithPendingActiveChange = <String>{};

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

  Future<void> _openCreateCropDialog() async {
    final taxa = await _taxonRepository!.getTaxa(activeOnly: true);

    if (!mounted) {
      return;
    }

    if (taxa.isEmpty) {
      await _showCropActiveChangeError(
        'Non è possibile creare una coltura perché non sono presenti '
        'classificazioni botaniche attive.',
      );
      return;
    }
    var canonicalName = '';
    var selectedTaxonId = taxa.first.id;
    var description = '';
    var isSubmitting = false;
    String? errorMessage;
    var requiresAuthoritativeReload = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedCanonicalName = canonicalName.trim();

              if (normalizedCanonicalName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome della coltura è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await _cropRepository!.createCrop(
                  taxonId: selectedTaxonId,
                  canonicalName: normalizedCanonicalName,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case CatalogCropCreated():
                    Navigator.of(dialogContext).pop();

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _cropsFuture = _cropRepository!.getCrops(
                        activeOnly: false,
                      );
                    });

                  case CreateCatalogCropForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage = 'Non sei autorizzato a creare colture.';
                    });

                  case CreateCatalogCropInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });

                  case CreateCatalogCropTaxonNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione botanica selezionata non è più disponibile.';
                    });

                  case CreateCatalogCropDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione botanica selezionata non è più attiva.';
                    });

                  case CreateCatalogCropDuplicateCanonicalName():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Esiste già una coltura con questo nome nel Catalogo Agronomico.';
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
                      'Non è stato possibile verificare l\'esito della creazione. '
                      'Chiudi questa finestra: i dati verranno ricaricati prima di '
                      'un nuovo tentativo.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Nuova coltura'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
                      onChanged: (value) {
                        canonicalName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome coltura',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTaxonId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Classificazione botanica',
                      ),
                      items: [
                        for (final taxon in taxa)
                          DropdownMenuItem<String>(
                            value: taxon.id,
                            child: Text(
                              '${taxon.rank} · ${taxon.scientificName}',
                            ),
                          ),
                      ],
                      onChanged: isSubmitting || requiresAuthoritativeReload
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedTaxonId = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
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
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
    if (requiresAuthoritativeReload && mounted) {
      setState(() {
        _cropsFuture = _cropRepository!.getCrops(activeOnly: false);
      });
    }
  }

  Future<void> _openEditCropDialog(Crop crop) async {
    final rowVersion = crop.rowVersion;
    final currentTaxonId = crop.taxonId;

    if (rowVersion == null || rowVersion < 1 || currentTaxonId == null) {
      await _showCropActiveChangeError(
        'Non è possibile modificare la coltura perché i dati necessari '
        'non sono disponibili.',
      );
      return;
    }

    final taxa = await _taxonRepository!.getTaxa(activeOnly: false);

    if (!mounted) {
      return;
    }

    final selectableTaxa = taxa
        .where((taxon) => taxon.isActive || taxon.id == currentTaxonId)
        .toList();

    final currentTaxonExists = selectableTaxa.any(
      (taxon) => taxon.id == currentTaxonId,
    );

    if (!currentTaxonExists) {
      await _showCropActiveChangeError(
        'La classificazione botanica attualmente collegata alla coltura '
        'non è più disponibile.',
      );
      return;
    }
    var canonicalName = crop.name;
    var description = crop.description ?? '';
    var selectedTaxonId = currentTaxonId;
    var isSubmitting = false;
    String? errorMessage;
    var requiresAuthoritativeReload = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedCanonicalName = canonicalName.trim();

              if (normalizedCanonicalName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome della coltura è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await _cropRepository!.updateCrop(
                  catalogCropId: crop.id,
                  expectedRowVersion: rowVersion,
                  taxonId: selectedTaxonId,
                  canonicalName: normalizedCanonicalName,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case CatalogCropUpdated():
                  case UpdateCatalogCropUnchanged():
                    Navigator.of(dialogContext).pop();

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _cropsFuture = _cropRepository!.getCrops(
                        activeOnly: false,
                      );
                    });

                  case UpdateCatalogCropVersionConflict():
                    setDialogState(() {
                      isSubmitting = false;
                      requiresAuthoritativeReload = true;
                      errorMessage =
                          'La coltura è stata modificata nel frattempo. '
                          'Ricarica i dati prima di effettuare una nuova modifica.';
                    });

                  case UpdateCatalogCropForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Non sei autorizzato a modificare la coltura.';
                    });

                  case UpdateCatalogCropInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });

                  case UpdateCatalogCropNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La coltura da modificare non è più disponibile.';
                    });

                  case UpdateCatalogCropTaxonNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione botanica selezionata '
                          'non è più disponibile.';
                    });

                  case UpdateCatalogCropDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La classificazione botanica selezionata non è attiva.';
                    });

                  case UpdateCatalogCropDuplicateCanonicalName():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage = 'Esiste già una coltura con questo nome.';
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
              title: const Text('Modifica coltura'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: canonicalName,
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        canonicalName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome coltura',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTaxonId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Classificazione botanica',
                      ),
                      items: [
                        for (final taxon in selectableTaxa)
                          DropdownMenuItem<String>(
                            value: taxon.id,
                            child: Text(
                              '${taxon.rank} · ${taxon.scientificName}'
                              '${taxon.isActive ? '' : ' · Inattiva'}',
                            ),
                          ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedTaxonId = value;
                                });
                              }
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
        _cropsFuture = _cropRepository!.getCrops(activeOnly: false);
      });
    }
  }

  Future<void> _showCropActiveChangeError(String message) async {
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

  Future<void> _setCropActive(Crop crop, bool isActive) async {
    if (_cropsWithPendingActiveChange.contains(crop.id)) {
      return;
    }
    final rowVersion = crop.rowVersion;

    if (rowVersion == null || rowVersion < 1) {
      await _showCropActiveChangeError(
        'Non è possibile modificare lo stato della coltura perché '
        'la versione del dato non è disponibile.',
      );
      return;
    }
    setState(() {
      _cropsWithPendingActiveChange.add(crop.id);
    });

    try {
      final result = await _cropRepository!.setCropActive(
        catalogCropId: crop.id,
        expectedRowVersion: rowVersion,
        isActive: isActive,
      );

      if (!mounted) {
        return;
      }

      if (result is CatalogCropActiveChanged ||
          result is SetCatalogCropActiveUnchanged) {
        setState(() {
          _cropsFuture = _cropRepository!.getCrops(activeOnly: false);
        });
      }

      if (result is SetCatalogCropActiveDependents) {
        await _showCropActiveChangeError(
          'Impossibile disattivare la coltura: sono presenti '
          '${result.dependentCount} cultivar attive collegate.',
        );
      }

      if (result is SetCatalogCropActiveDependencyInactive) {
        await _showCropActiveChangeError(
          'Impossibile riattivare la coltura perché la classificazione '
          'botanica collegata non è attiva.',
        );
      }

      if (result is SetCatalogCropActiveForbidden) {
        await _showCropActiveChangeError(
          'Non sei autorizzato a modificare lo stato della coltura.',
        );
      }

      if (result is SetCatalogCropActiveInvalidInput) {
        await _showCropActiveChangeError(
          'La richiesta di modifica dello stato della coltura non è valida.',
        );
      }

      if (result is SetCatalogCropActiveNotFound) {
        await _showCropActiveChangeError('La coltura non è più disponibile.');
      }

      if (result is SetCatalogCropActiveVersionConflict) {
        setState(() {
          _cropsFuture = _cropRepository!.getCrops(activeOnly: false);
        });

        await _showCropActiveChangeError(
          'La coltura è stata modificata. '
          'I dati sono stati ricaricati prima di effettuare una nuova operazione.',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cropsFuture = _cropRepository!.getCrops(activeOnly: false);
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
          _cropsWithPendingActiveChange.remove(crop.id);
        });
      }
    }
  }

  Future<void> _confirmDeactivateCrop(Crop crop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Disattivare la coltura?'),
          content: const Text(
            'La coltura rimarrà nel catalogo ma non sarà più attiva.',
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

    await _setCropActive(crop, false);
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _showCultivarActiveChangeError(String message) async {
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

  Future<bool> _setCultivarActive(
    CropCultivar cultivar,
    bool isActive,
    CropCultivarRepository repository,
  ) async {
    if (_cultivarsWithPendingActiveChange.contains(cultivar.id)) {
      return false;
    }

    if (cultivar.rowVersion < 1) {
      await _showCultivarActiveChangeError(
        'Non è possibile modificare lo stato della cultivar perché '
        'la versione del dato non è disponibile.',
      );
      return false;
    }

    setState(() {
      _cultivarsWithPendingActiveChange.add(cultivar.id);
    });

    var reloadRequired = false;

    try {
      final result = await repository.setCultivarActive(
        cropCultivarId: cultivar.id,
        expectedRowVersion: cultivar.rowVersion,
        isActive: isActive,
      );

      if (!mounted) {
        return false;
      }

      if (result is CropCultivarActiveChanged ||
          result is SetCropCultivarActiveUnchanged) {
        reloadRequired = true;
      }

      if (result is SetCropCultivarActiveDependencyInactive) {
        await _showCultivarActiveChangeError(
          'Impossibile riattivare la cultivar perché la coltura '
          'collegata non è attiva.',
        );
      }

      if (result is SetCropCultivarActiveForbidden) {
        await _showCultivarActiveChangeError(
          'Non sei autorizzato a modificare lo stato della cultivar.',
        );
      }

      if (result is SetCropCultivarActiveInvalidInput) {
        await _showCultivarActiveChangeError(
          'La richiesta di modifica dello stato della cultivar non è valida.',
        );
      }

      if (result is SetCropCultivarActiveNotFound) {
        await _showCultivarActiveChangeError(
          'La cultivar non è più disponibile.',
        );
      }

      if (result is SetCropCultivarActiveVersionConflict) {
        reloadRequired = true;

        await _showCultivarActiveChangeError(
          'La cultivar è stata modificata. '
          'I dati verranno ricaricati prima di effettuare una nuova operazione.',
        );
      }
    } catch (_) {
      if (!mounted) {
        return false;
      }

      reloadRequired = true;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Stato da verificare'),
            content: const Text(
              'Non è stato possibile verificare l\'esito dell\'operazione. '
              'I dati verranno ricaricati prima di consentire una nuova modifica.',
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
          _cultivarsWithPendingActiveChange.remove(cultivar.id);
        });
      }
    }

    return reloadRequired;
  }

  Future<bool> _confirmDeactivateCultivar(
    CropCultivar cultivar,
    CropCultivarRepository repository,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Disattivare la cultivar?'),
          content: const Text(
            'La cultivar rimarrà nel catalogo ma non sarà più attiva.',
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
      return false;
    }

    return _setCultivarActive(cultivar, false, repository);
  }

  Future<bool> _openCreateCultivarDialog(
    Crop crop,
    CropCultivarRepository repository,
  ) async {
    var canonicalName = '';
    var verificationStatus = 'PROVISIONAL';
    var description = '';
    var isSubmitting = false;
    String? errorMessage;
    var requiresAuthoritativeReload = false;
    var created = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedCanonicalName = canonicalName.trim();

              if (normalizedCanonicalName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome della cultivar è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await repository.createCultivar(
                  cropId: crop.id,
                  canonicalName: normalizedCanonicalName,
                  verificationStatus: verificationStatus,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case CropCultivarCreated():
                    created = true;
                    Navigator.of(dialogContext).pop();

                  case CreateCropCultivarForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage = 'Non sei autorizzato a creare cultivar.';
                    });

                  case CreateCropCultivarInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });

                  case CreateCropCultivarCropNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La coltura associata non è più disponibile.';
                    });

                  case CreateCropCultivarDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage = 'La coltura associata non è più attiva.';
                    });

                  case CreateCropCultivarDuplicateCanonicalName():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Esiste già una cultivar con questo nome per questa coltura.';
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
                      'Non è stato possibile verificare l\'esito della creazione. '
                      'Chiudi questa finestra: i dati verranno ricaricati prima '
                      'di un nuovo tentativo.';
                });
              }
            }

            return AlertDialog(
              title: Text('Nuova cultivar · ${crop.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
                      onChanged: (value) {
                        canonicalName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome cultivar',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: verificationStatus,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Stato identità',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'VERIFIED',
                          child: Text('Verificata'),
                        ),
                        DropdownMenuItem(
                          value: 'PROVISIONAL',
                          child: Text('Provvisoria'),
                        ),
                        DropdownMenuItem(
                          value: 'AMBIGUOUS',
                          child: Text('Ambigua'),
                        ),
                      ],
                      onChanged: isSubmitting || requiresAuthoritativeReload
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  verificationStatus = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
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
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );

    return created || requiresAuthoritativeReload;
  }

  Future<bool> _openEditCultivarDialog(
    CropCultivar cultivar,
    CropCultivarRepository repository,
  ) async {
    if (cultivar.rowVersion < 1) {
      await _showCultivarActiveChangeError(
        'Non è possibile modificare la cultivar perché '
        'la versione del dato non è disponibile.',
      );
      return false;
    }

    var canonicalName = cultivar.name;
    var verificationStatus = cultivar.verificationStatus;
    var description = cultivar.description ?? '';
    var isSubmitting = false;
    String? errorMessage;
    var requiresAuthoritativeReload = false;
    var saved = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final normalizedCanonicalName = canonicalName.trim();

              if (normalizedCanonicalName.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Il nome della cultivar è obbligatorio.';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final result = await repository.updateCultivar(
                  cropCultivarId: cultivar.id,
                  expectedRowVersion: cultivar.rowVersion,
                  cropId: cultivar.cropId,
                  canonicalName: normalizedCanonicalName,
                  verificationStatus: verificationStatus,
                  description: _optionalText(description),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                switch (result) {
                  case CropCultivarUpdated():
                  case UpdateCropCultivarUnchanged():
                    saved = true;
                    Navigator.of(dialogContext).pop();

                  case UpdateCropCultivarVersionConflict():
                    setDialogState(() {
                      isSubmitting = false;
                      requiresAuthoritativeReload = true;
                      errorMessage =
                          'La cultivar è stata modificata nel frattempo. '
                          'Ricarica i dati prima di effettuare una nuova modifica.';
                    });

                  case UpdateCropCultivarForbidden():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Non sei autorizzato a modificare la cultivar.';
                    });

                  case UpdateCropCultivarInvalidInput():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'I dati inseriti non sono validi. Controlla i campi.';
                    });

                  case UpdateCropCultivarNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La cultivar da modificare non è più disponibile.';
                    });

                  case UpdateCropCultivarCropNotFound():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'La coltura associata non è più disponibile.';
                    });

                  case UpdateCropCultivarDependencyInactive():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage = 'La coltura associata non è attiva.';
                    });

                  case UpdateCropCultivarDuplicateCanonicalName():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'Esiste già una cultivar con questo nome per questa coltura.';
                    });

                  case UpdateCropCultivarIdentityInUse():
                    setDialogState(() {
                      isSubmitting = false;
                      errorMessage =
                          'L\'identità della cultivar è già utilizzata e non può '
                          'essere trasferita a un\'altra coltura.';
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
                      'Chiudi questa finestra: i dati verranno ricaricati prima '
                      'di un nuovo tentativo.';
                });
              }
            }

            return AlertDialog(
              title: const Text('Modifica cultivar'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: canonicalName,
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
                      onChanged: (value) {
                        canonicalName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome cultivar',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: verificationStatus,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Stato identità',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'VERIFIED',
                          child: Text('Verificata'),
                        ),
                        DropdownMenuItem(
                          value: 'PROVISIONAL',
                          child: Text('Provvisoria'),
                        ),
                        DropdownMenuItem(
                          value: 'AMBIGUOUS',
                          child: Text('Ambigua'),
                        ),
                      ],
                      onChanged: isSubmitting || requiresAuthoritativeReload
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  verificationStatus = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: description,
                      enabled: !isSubmitting && !requiresAuthoritativeReload,
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

    return saved || requiresAuthoritativeReload;
  }

  Future<void> _openCropCultivars(
    Crop crop,
    CatalogCapabilities capabilities,
  ) async {
    final repository = widget.cultivarRepository ?? CropCultivarRepository();

    try {
      final cultivars = await repository.getCultivarsByCrop(
        crop.id,
        activeOnly: false,
      );

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
                          trailing: capabilities.canManageIdentity
                              ? Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(dialogContext).pop();

                                        final reloadRequired =
                                            await _openEditCultivarDialog(
                                              cultivar,
                                              repository,
                                            );

                                        if (!mounted) {
                                          return;
                                        }

                                        if (reloadRequired) {
                                          await _openCropCultivars(
                                            crop,
                                            capabilities,
                                          );
                                        }
                                      },
                                      child: const Text('Modifica'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _cultivarsWithPendingActiveChange
                                              .contains(cultivar.id)
                                          ? null
                                          : () async {
                                              Navigator.of(dialogContext).pop();

                                              final reloadRequired =
                                                  cultivar.isActive
                                                  ? await _confirmDeactivateCultivar(
                                                      cultivar,
                                                      repository,
                                                    )
                                                  : await _setCultivarActive(
                                                      cultivar,
                                                      true,
                                                      repository,
                                                    );

                                              if (!mounted) {
                                                return;
                                              }

                                              if (reloadRequired) {
                                                await _openCropCultivars(
                                                  crop,
                                                  capabilities,
                                                );
                                              }
                                            },
                                      child: Text(
                                        cultivar.isActive
                                            ? 'Disattiva'
                                            : 'Riattiva',
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                    ],
                  ),
            actions: [
              if (capabilities.canManageIdentity)
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    final reloadRequired = await _openCreateCultivarDialog(
                      crop,
                      repository,
                    );

                    if (!mounted) {
                      return;
                    }

                    if (reloadRequired) {
                      await _openCropCultivars(crop, capabilities);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuova cultivar'),
                ),
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
                  _openCropCultivars(crop, capabilities);
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

  String _cultivarVerificationStatusLabel(String status) {
    switch (status) {
      case 'VERIFIED':
        return 'Verificata';
      case 'PROVISIONAL':
        return 'Provvisoria';
      case 'AMBIGUOUS':
        return 'Ambigua';
      default:
        return status;
    }
  }

  Widget? _buildCultivarSubtitle(CropCultivar cultivar) {
    final details = <String>[
      _cultivarVerificationStatusLabel(cultivar.verificationStatus),
    ];

    if (cultivar.description != null) {
      details.add(cultivar.description!);
    }

    if (!cultivar.isActive) {
      details.add('Inattiva');
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
          _cropsFuture ??= _cropRepository!.getCrops(activeOnly: false);

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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Colture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (capabilities.canManageIdentity)
                      FilledButton.icon(
                        onPressed: _openCreateCropDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nuova coltura'),
                      ),
                  ],
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
                      onTap: () => _openCropCultivars(crop, capabilities),
                      title: Text(crop.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (crop.scientificName != null)
                            Text(crop.scientificName!),
                          if (crop.botanicalFamilyName != null)
                            Text(crop.botanicalFamilyName!),
                          if (!crop.isActive) const Text('Inattiva'),
                        ],
                      ),
                      trailing: capabilities.canManageIdentity
                          ? Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () => _openEditCropDialog(crop),
                                  child: const Text('Modifica'),
                                ),
                                TextButton(
                                  onPressed:
                                      _cropsWithPendingActiveChange.contains(
                                        crop.id,
                                      )
                                      ? null
                                      : () {
                                          if (crop.isActive) {
                                            _confirmDeactivateCrop(crop);
                                          } else {
                                            _setCropActive(crop, true);
                                          }
                                        },
                                  child: Text(
                                    crop.isActive ? 'Disattiva' : 'Riattiva',
                                  ),
                                ),
                              ],
                            )
                          : null,
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
