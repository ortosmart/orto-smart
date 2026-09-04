import 'companion_rule.dart';

class CompanionResult {
  final bool compatible;
  final CompanionCompatibility compatibility;
  final String message;

  const CompanionResult({
    required this.compatible,
    required this.compatibility,
    required this.message,
  });
}
