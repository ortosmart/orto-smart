import 'models/agronomic_window.dart';

class AgronomicWindowValidationResult {
  final bool isValid;
  final String? errorMessage;

  const AgronomicWindowValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  const AgronomicWindowValidationResult.valid() : this._(isValid: true);

  const AgronomicWindowValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

class AgronomicWindowValidator {
  const AgronomicWindowValidator._();

  static AgronomicWindowValidationResult validate(AgronomicWindow window) {
    if (!_isValidMonthDay(window.startMonth, window.startDay)) {
      return const AgronomicWindowValidationResult.invalid(
        'La data iniziale della finestra agronomica non è valida.',
      );
    }

    if (!_isValidMonthDay(window.endMonth, window.endDay)) {
      return const AgronomicWindowValidationResult.invalid(
        'La data finale della finestra agronomica non è valida.',
      );
    }

    return const AgronomicWindowValidationResult.valid();
  }

  static bool _isValidMonthDay(int month, int day) {
    if (month < 1 || month > 12 || day < 1) {
      return false;
    }

    final date = DateTime(2000, month, day);

    return date.month == month && date.day == day;
  }
}
