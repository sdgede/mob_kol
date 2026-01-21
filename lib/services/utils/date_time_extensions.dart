/// Extension methods for DateTime formatting and manipulation
extension DateTimeExtension on DateTime {
  /// Format DateTime to string in DD/MM/YYYY HH:MM format
  ///
  /// Parameters:
  /// - [convertToTimezone]: Optional timezone offset in hours (e.g., 8 for GMT+8)
  ///   If null, uses the DateTime as-is
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatDateTime(); // "28/12/2024 00:43"
  /// DateTime.utc(2024, 12, 28, 0, 0).formatDateTime(convertToTimezone: 8); // "28/12/2024 08:00"
  /// ```
  String formatDateTime({int? convertToTimezone}) {
    DateTime dateTime = this;

    // Convert to specified timezone if provided
    if (convertToTimezone != null) {
      // If DateTime is in UTC, add the timezone offset
      if (isUtc) {
        dateTime = add(Duration(hours: convertToTimezone));
      } else {
        // If DateTime is local, first convert to UTC then add offset
        final utcTime = toUtc();
        dateTime = utcTime.add(Duration(hours: convertToTimezone));
      }
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  /// Format DateTime to string with custom format
  ///
  /// Supported patterns:
  /// - dd: Day with leading zero
  /// - MM: Month with leading zero
  /// - MMMM: Full month name
  /// - yyyy: Full year
  /// - HH: Hour (24h) with leading zero
  /// - mm: Minute with leading zero
  /// - ss: Second with leading zero
  String format(String pattern, {int? convertToTimezone}) {
    DateTime dateTime = this;

    // Convert to specified timezone if provided
    if (convertToTimezone != null) {
      if (isUtc) {
        dateTime = add(Duration(hours: convertToTimezone));
      } else {
        final utcTime = toUtc();
        dateTime = utcTime.add(Duration(hours: convertToTimezone));
      }
    }

    final List<String> months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

    return pattern.replaceAll('dd', dateTime.day.toString().padLeft(2, '0')).replaceAll('MMMM', months[dateTime.month]).replaceAll('MM', dateTime.month.toString().padLeft(2, '0')).replaceAll('yyyy', dateTime.year.toString()).replaceAll('HH', dateTime.hour.toString().padLeft(2, '0')).replaceAll('mm', dateTime.minute.toString().padLeft(2, '0')).replaceAll('ss', dateTime.second.toString().padLeft(2, '0'));
  }

  /// Format to relative time (e.g., "2 jam lalu")
  String toRelativeTime() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} tahun lalu';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} bulan lalu';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Format DateTime to local timezone and return as string
  ///
  /// Automatically converts UTC time to device's local timezone
  String formatToLocal() {
    final localTime = isUtc ? toLocal() : this;
    return localTime.formatDateTime();
  }
}

/// Helper class for DateTime utilities
class DateTimeUtils {
  DateTimeUtils._();

  /// Get device timezone offset in hours
  ///
  /// Example: Returns 8 for GMT+8, -5 for GMT-5
  static int get deviceTimezone => DateTime.now().timeZoneOffset.inHours;

  /// Get device timezone offset as Duration
  static Duration get deviceTimezoneOffset => DateTime.now().timeZoneOffset;

  /// Get device timezone name (e.g., "GMT+8" or "GMT-5")
  static String get deviceTimezoneName {
    final offset = deviceTimezone;
    final sign = offset >= 0 ? '+' : '';
    return 'GMT$sign$offset';
  }
}
