import 'agronomic_window.dart';

enum AgronomicWindowEvaluationStatus { compatible, incompatible, unknown }

class AgronomicWindowEvaluation {
  const AgronomicWindowEvaluation({
    required this.status,
    required this.reasons,
    required this.evaluatedWindows,
    this.matchedWindow,
  });

  final AgronomicWindowEvaluationStatus status;
  final List<String> reasons;

  /// Finestra che ha reso compatibile il lotto.
  ///
  /// È valorizzata solo quando lo stato è [compatible].
  final AgronomicWindow? matchedWindow;

  /// Tutte le finestre considerate durante la valutazione.
  final List<AgronomicWindow> evaluatedWindows;

  bool get isCompatible => status == AgronomicWindowEvaluationStatus.compatible;

  bool get isIncompatible =>
      status == AgronomicWindowEvaluationStatus.incompatible;

  bool get isUnknown => status == AgronomicWindowEvaluationStatus.unknown;

  factory AgronomicWindowEvaluation.compatible({
    required AgronomicWindow matchedWindow,
    required List<AgronomicWindow> evaluatedWindows,
    String reason = 'Il lotto rientra in una finestra agronomica prevista.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.compatible,
      matchedWindow: matchedWindow,
      evaluatedWindows: List.unmodifiable(evaluatedWindows),
      reasons: List.unmodifiable([reason]),
    );
  }

  factory AgronomicWindowEvaluation.incompatible({
    required List<AgronomicWindow> evaluatedWindows,
    String reason =
        'Il lotto non rientra in nessuna delle finestre agronomiche previste.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.incompatible,
      evaluatedWindows: List.unmodifiable(evaluatedWindows),
      reasons: List.unmodifiable([reason]),
    );
  }

  factory AgronomicWindowEvaluation.unknown({
    String reason =
        'Non esistono dati sufficienti per valutare la finestra agronomica.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.unknown,
      evaluatedWindows: const [],
      reasons: List.unmodifiable([reason]),
    );
  }
}
