import 'package:flutter/material.dart';

import '../core/write_authority/botanical_taxon_write_result.dart';
import '../data/models/catalog_capabilities.dart';
import '../data/models/botanical_taxon.dart';
import '../data/repositories/botanical_taxon_repository.dart';

class BotanicalClassificationPage extends StatefulWidget {
  final CatalogCapabilities capabilities;
  final BotanicalTaxonRepository? repository;

  const BotanicalClassificationPage({
    super.key,
    required this.capabilities,
    this.repository,
  });

  @override
  State<BotanicalClassificationPage> createState() =>
      _BotanicalClassificationPageState();
}

class _BotanicalClassificationPageState
    extends State<BotanicalClassificationPage> {
  late BotanicalTaxonRepository _repository;
  late Future<List<BotanicalTaxon>> _taxaFuture;

  final Set<String> _taxaWithPendingActiveChange = <String>{};

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
    var requiresAuthoritativeReload = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (requiresAuthoritativeReload) {
                return;
              }

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
                final result = await _repository.createTaxon(
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
                      _taxaFuture = _repository.getTaxa(activeOnly: false);
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
                  requiresAuthoritativeReload = true;
                  errorMessage =
                      'Non è stato possibile verificare l\'esito della creazione. '
                      'Chiudi questa finestra: i dati verranno ricaricati prima di '
                      'un nuovo tentativo.';
                });
              }
            }

            final writeBlocked = isSubmitting || requiresAuthoritativeReload;

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
                      onChanged: writeBlocked
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
                      enabled: !writeBlocked,
                      onChanged: (value) {
                        scientificName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome scientifico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !writeBlocked,
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
                      onChanged: writeBlocked
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
                      onChanged: writeBlocked
                          ? null
                          : (value) {
                              setDialogState(() {
                                isHybrid = value ?? false;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: !writeBlocked,
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
                  onPressed: writeBlocked ? null : submit,
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

    if (requiresAuthoritativeReload && mounted) {
      setState(() {
        _taxaFuture = _repository.getTaxa(activeOnly: false);
      });
    }
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
      final result = await _repository.setTaxonActive(
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
          _taxaFuture = _repository.getTaxa(activeOnly: false);
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
          _taxaFuture = _repository.getTaxa(activeOnly: false);
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
        _taxaFuture = _repository.getTaxa(activeOnly: false);
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
                final result = await _repository.updateTaxon(
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
                      _taxaFuture = _repository.getTaxa(activeOnly: false);
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
        _taxaFuture = _repository.getTaxa(activeOnly: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BotanicalTaxonRepository();
    _taxaFuture = _repository.getTaxa(activeOnly: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classificazione botanica')),
      body: FutureBuilder<List<BotanicalTaxon>>(
        future: _taxaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Errore durante il caricamento della classificazione botanica.',
              ),
            );
          }
          final taxa = snapshot.data ?? const <BotanicalTaxon>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.capabilities.canManageIdentity) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () => _openCreateTaxonDialog(taxa),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuova voce botanica'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (taxa.isEmpty)
                const Text(
                  'Nessuna voce presente nella classificazione botanica.',
                )
              else
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
                    trailing: widget.capabilities.canManageIdentity
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed:
                                    _taxaWithPendingActiveChange.contains(
                                      taxon.id,
                                    )
                                    ? null
                                    : () => _openEditTaxonDialog(taxon, taxa),
                                child: const Text('Modifica'),
                              ),
                              if (_taxaWithPendingActiveChange.contains(
                                taxon.id,
                              ))
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: taxon.isActive
                                      ? () => _confirmDeactivateTaxon(taxon)
                                      : () => _setTaxonActive(taxon, true),
                                  child: Text(
                                    taxon.isActive ? 'Disattiva' : 'Riattiva',
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
    );
  }
}
