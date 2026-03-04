import 'package:intl/intl.dart';

class DateHelper {

  static String formatDate(DateTime date) {
    return DateFormat("d MMM yyyy", "id_ID").format(date);
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} detik yang lalu";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} menit yang lalu";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} jam yang lalu";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} hari yang lalu";
    } else {
      return DateFormat("d MMM yyyy", "id_ID").format(date);
    }
  }
}