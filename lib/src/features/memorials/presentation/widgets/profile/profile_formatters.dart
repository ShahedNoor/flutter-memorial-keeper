/// Formats a DateTime into a readable memorial date string.
String formatMemorialDate(DateTime? dt) {
  if (dt == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String formatTimeSincePassing(DateTime? dt, int? year) {
  final passingDate = dt ?? (year != null ? DateTime(year, 1, 1) : null);
  if (passingDate == null) return '';

  final now = DateTime.now();
  final difference = now.difference(passingDate);
  final years = (difference.inDays / 365.25).floor();

  if (years >= 1) {
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
  final months = (difference.inDays / 30.4).floor();
  if (months >= 1) {
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }
  final days = difference.inDays;
  return '$days ${days == 1 ? 'day' : 'days'} ago';
}
