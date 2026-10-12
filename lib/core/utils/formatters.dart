import 'package:intl/intl.dart';
import '../config/app_constants.dart';

/// Formatting utilities for currency, dates, numbers
class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compactNumberFormat = NumberFormat.compact();
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatCurrency(num amount) => _currencyFormat.format(amount);
  static String formatCoins(num amount) => '${NumberFormat('#,##0').format(amount)} ${AppConstants.pointsName}';
  static String formatCompact(num number) => _compactNumberFormat.format(number);
  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
}
