// ===== FILE GUIDE: lib/models/timetable.dart
// WHAT IT DOES : Data class for one weekly class slot.
// MANAGES      : Day, start/end time, course, type (Lecture/Lab/Tutorial) and room.
// USED BY      : schedule_service.dart and the timetable screen.
// ======================================================================

/// A single scheduled class slot in a weekly timetable.
///
/// Course details (code, title, colour, faculty) are resolved from the course
/// id at render time, so the entry stays lightweight.
class TimetableEntry {
  final String day; // e.g. "Mon"
  final String start; // e.g. "10:00 AM"
  final String end; // e.g. "11:30 AM"
  final String courseId;
  final String type; // Lecture | Lab | Tutorial
  final String room;

  const TimetableEntry({
    required this.day,
    required this.start,
    required this.end,
    required this.courseId,
    required this.type,
    required this.room,
  });
}
