class DateHelper {
  /// Returns a readable date string e.g. "Mon, 06 Apr 2026  14:35"
  static String format(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months   = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final wd  = weekdays[dt.weekday - 1];
      final mon = months[dt.month - 1];
      final day = dt.day.toString().padLeft(2, '0');
      final h   = dt.hour.toString().padLeft(2, '0');
      final m   = dt.minute.toString().padLeft(2, '0');
      return '$wd, $day $mon ${dt.year}  $h:$m';
    } catch (_) {
      return isoString;
    }
  }

  /// Returns a short date only e.g. "06 Apr 2026"
  static String shortDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoString;
    }
  }

  /// Returns today's date as ISO string prefix e.g. "2026-04-06"
  static String todayPrefix() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
