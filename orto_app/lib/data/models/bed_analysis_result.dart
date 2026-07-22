import '../../services/free_space.dart';

/// Risultato dell'analisi degli spazi disponibili in un'aiuola.
class BedAnalysisResult {
  /// Tutti gli spazi liberi individuati nell'aiuola.
  final List<FreeSpace> freeSpaces;

  /// Lo spazio consigliato per la nuova coltura.
  final FreeSpace? suggestedSpace;

  /// Indica se è stata rilevata una sovrapposizione.
  final bool hasOverlap;

  /// Messaggio informativo o di avviso per l'utente.
  final String? message;

  const BedAnalysisResult({
    required this.freeSpaces,
    required this.suggestedSpace,
    this.hasOverlap = false,
    this.message,
  });

  /// Indica se nell'aiuola esiste almeno uno spazio libero.
  bool get hasFreeSpace => freeSpaces.isNotEmpty;
}