import 'agronomic_window.dart';

enum AgronomicWindowEvaluationStatus { compatible, incompatible, unknown }

class AgronomicWindowEvaluation {
  const AgronomicWindowEvaluation({
    required this.status,
    required this.reasons,
    this.window,
  });

  final AgronomicWindowEvaluationStatus status;
  final List<String> reasons;
  final AgronomicWindow? window;

  bool get isCompatible => status == AgronomicWindowEvaluationStatus.compatible;

  bool get isIncompatible =>
      status == AgronomicWindowEvaluationStatus.incompatible;

  bool get isUnknown => status == AgronomicWindowEvaluationStatus.unknown;

  factory AgronomicWindowEvaluation.compatible({
    required AgronomicWindow window,
    String reason = 'Il lotto rientra nella finestra agronomica prevista.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.compatible,
      window: window,
      reasons: List.unmodifiable([reason]),
    );
  }

  factory AgronomicWindowEvaluation.incompatible({
    required AgronomicWindow window,
    String reason = 'Il lotto non rientra nella finestra agronomica prevista.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.incompatible,
      window: window,
      reasons: List.unmodifiable([reason]),
    );
  }

  factory AgronomicWindowEvaluation.unknown({
    String reason =
        'Non esistono dati sufficienti per valutare la finestra agronomica.',
  }) {
    return AgronomicWindowEvaluation(
      status: AgronomicWindowEvaluationStatus.unknown,
      reasons: List.unmodifiable([reason]),
    );
  }
}
