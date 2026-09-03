class CivilDate {
  const CivilDate._();

  static DateTime? parseItalian(String text) {
    final value = text.trim();

    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return null;
    }

    final day = int.parse(value.substring(0, 2));
    final month = int.parse(value.substring(3, 5));
    final year = int.parse(value.substring(6, 10));

    if (year < 1) {
      return null;
    }

    final date = DateTime.utc(year, month, day);

    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    return date;
  }

  static String formatItalian(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');

    return '$day/$month/$year';
  }
}
