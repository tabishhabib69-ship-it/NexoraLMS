// ===== FILE GUIDE: lib/services/schedule_service.dart
// WHAT IT DOES : Timetable helpers.
// MANAGES      : Time parsing/formatting, classes on a day, Done/Now/Next status, clash detection for new events.
// USED BY      : Timetable screen, dashboard insights, faculty dashboard.
// ======================================================================

import '../data/dummy_data.dart';
import 'my_data.dart';
import '../models/academics.dart';
import '../models/timetable.dart';

enum SlotStatus { done, now, next, later }

/// Timetable helpers: time parsing, live class status and overlap checks.
class ScheduleService {
  ScheduleService._();

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String dayKey(DateTime d) => _days[d.weekday - 1];

  /// Parses "08:00 AM" / "01:30 PM" into minutes after midnight.
  static int minutesOf(String time) {
    final parts = time.trim().split(' ');
    final hm = parts.first.split(':');
    var h = int.parse(hm[0]);
    final m = int.parse(hm[1]);
    final pm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    if (pm && h != 12) h += 12;
    if (!pm && h == 12) h = 0;
    return h * 60 + m;
  }

  static String formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
  }

  static List<TimetableEntry> classesOn(DateTime day) {
    final source = MyData.timetable;
    final key = dayKey(day);
    final list = source.where((e) => e.day == key).toList()
      ..sort((a, b) => minutesOf(a.start).compareTo(minutesOf(b.start)));
    return list;
  }

  static List<CalendarEvent> eventsOn(DateTime day) =>
      DummyData.events
          .where(
            (e) =>
                e.ownerId == MyData.id && e.date.year == day.year && e.date.month == day.month && e.date.day == day.day,
          )
          .toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  /// Status of a class on [day]: only today's classes can be Now/Next; past
  /// days are done and future days are later.
  static SlotStatus statusOf(TimetableEntry e, DateTime day, List<TimetableEntry> sameDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    if (d.isBefore(today)) return SlotStatus.done;
    if (d.isAfter(today)) return SlotStatus.later;
    final mins = now.hour * 60 + now.minute;
    final start = minutesOf(e.start);
    final end = minutesOf(e.end);
    if (mins >= end) return SlotStatus.done;
    if (mins >= start) return SlotStatus.now;
    final firstUpcoming = sameDay.firstWhere((x) => minutesOf(x.start) > mins, orElse: () => e);
    return identical(firstUpcoming, e) ? SlotStatus.next : SlotStatus.later;
  }

  /// Returns a description of what [start]..[end] on [day] clashes with, or null.
  static String? clashFor(DateTime day, int start, int end) {
    for (final c in classesOn(day)) {
      if (start < minutesOf(c.end) && end > minutesOf(c.start)) {
        final course = DummyData.courseById(c.courseId);
        return '${course?.code ?? 'a class'} (${c.start} – ${c.end})';
      }
    }
    for (final ev in eventsOn(day)) {
      if (start < ev.endMinutes && end > ev.startMinutes) return '"${ev.title}"';
    }
    return null;
  }
}
