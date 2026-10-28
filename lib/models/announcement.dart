// ===== FILE GUIDE: lib/models/announcement.dart
// WHAT IT DOES : Data class for an announcement (course or university-wide).
// MANAGES      : Title, body, author, course, pinned flag and priority (normal / important / urgent).
// USED BY      : Dashboards, feed official notice, faculty and admin announcement screens.
// ======================================================================

enum AnnouncementPriority { normal, important, urgent }

/// An announcement posted by faculty (course-level) or admin (university-level).
class Announcement {
  final String id;
  final String title;
  final String body;
  final String authorName;
  final String authorRole; // "Faculty" / "Admin"
  final String? courseId; // null => university-wide
  final String? courseCode;
  final DateTime date;
  final bool pinned;
  final AnnouncementPriority priority;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.authorRole,
    required this.date,
    this.courseId,
    this.courseCode,
    this.pinned = false,
    this.priority = AnnouncementPriority.normal,
  });

  Announcement copyWith({String? title, String? body, DateTime? date, bool? pinned}) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorName: authorName,
      authorRole: authorRole,
      date: date ?? this.date,
      courseId: courseId,
      courseCode: courseCode,
      pinned: pinned ?? this.pinned,
      priority: priority,
    );
  }
}
