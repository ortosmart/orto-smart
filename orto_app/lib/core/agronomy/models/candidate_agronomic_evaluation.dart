import '../../../data/models/association_result.dart';
import '../../../data/models/rotation_result.dart';
import 'suggestion_candidate.dart';

/// Riunisce le valutazioni agronomiche associate
/// a una possibilità tecnica di impianto.
class CandidateAgronomicEvaluation {
  const CandidateAgronomicEvaluation({
    required this.candidate,
    required this.spaceScore,
    required this.rotationResult,
    required this.associationResult,
  });

  /// Possibilità tecnica prodotta dal SuggestionEngine.
  final SuggestionCandidate candidate;

  /// Valutazione dell'adeguatezza dello spazio, da 0 a 100.
  final int spaceScore;

  /// Valutazione della rotazione colturale.
  final RotationResult rotationResult;

  /// Valutazione delle consociazioni.
  final AssociationResult associationResult;
}
