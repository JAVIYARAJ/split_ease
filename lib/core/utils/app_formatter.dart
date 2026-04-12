import 'package:intl/intl.dart';

class AppFormatter {
  // Prevent instantiation
  AppFormatter._();

  /// Formats a number to Indian Currency string (₹)
  /// Example: 123456.78 -> ₹1,23,456.78
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Formats a number with comma separation based on Indian locale
  /// Example: 123456 -> 1,23,456
  static String formatNumber(num number) {
    return NumberFormat('#,##,##0.##', 'en_IN').format(number);
  }

  /// Shorthand formatter for large numbers (Compassionate notation)
  /// Example: 1500 -> 1.5K, 1500000 -> 1.5M
  static String formatCompact(num number) {
    return NumberFormat.compact(locale: 'en_IN').format(number);
  }
}
