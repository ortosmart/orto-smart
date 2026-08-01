import '../../../data/models/crop.dart';
import 'free_space.dart';

class SuggestionCandidate {
  const SuggestionCandidate({
    required this.crop,
    required this.freeSpace,
    required this.maxPlants,
    required this.rows,
    required this.availableLengthCm,
    required this.requiredLengthCm,
  });

  /// Coltura candidata.
  final Crop crop;

  /// Spazio libero utilizzato.
  final FreeSpace freeSpace;

  /// Numero massimo di piante inseribili nello spazio.
  final int maxPlants;

  /// Numero di file possibili.
  final int rows;

  /// Lunghezza disponibile nello spazio selezionato.
  final int availableLengthCm;

  /// Lunghezza necessaria per la configurazione proposta.
  final int requiredLengthCm;
}
