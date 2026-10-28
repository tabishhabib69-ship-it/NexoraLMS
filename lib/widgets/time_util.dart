// ===== FILE GUIDE: lib/widgets/time_util.dart
// WHAT IT DOES : Date/time text helpers.
// MANAGES      : "2h ago", clock time, "Wednesday, Oct 28", "Today/Yesterday" labels.
// USED BY      : Most screens that show dates.
// ======================================================================

/// Human-friendly relative time for feed/notification timestamps.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

String formatClock(DateTime date) {
  final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final m = date.minute.toString().padLeft(2, '0');
  final ap = date.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// "Friday, Sep 18"
String formatLongDay(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

/// "Sep 18"
String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// "Sep 18 · 11:59 PM"
String formatDateTime(DateTime d) => '${formatShortDate(d)} · ${formatClock(d)}';

/// "Today", "Yesterday" or "Sep 18" — used for chat date separators.
String formatDayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return formatShortDate(d);
}
