import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM yyyy', 'tr_TR').format(date);
  }

  static String formatDateFull(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 17) return 'İyi öğlenler';
    return 'İyi akşamlar';
  }

  static String formatArea(double m2) {
    if (m2 >= 1000000) {
      return '${(m2 / 1000000).toStringAsFixed(2)} km²';
    }
    if (m2 >= 10000) {
      return '${(m2 / 10000).toStringAsFixed(2)} ha';
    }
    return '${m2.toStringAsFixed(0)} m²';
  }
}
