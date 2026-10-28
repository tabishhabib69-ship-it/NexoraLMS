// ===== FILE GUIDE: lib/models/notification.dart
// WHAT IT DOES : Data class for an in-app notification.
// MANAGES      : Notification type (assignment, exam, message, ...), text, date and read/unread state.
// USED BY      : Notification centre, plus faculty/admin actions that create notifications.
// ======================================================================

enum NotificationType { announcement, faculty, message, university, attendance, assignment, exam }

extension NotificationTypeX on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.faculty:
        return 'Faculty Update';
      case NotificationType.message:
        return 'Message';
      case NotificationType.university:
        return 'University';
      case NotificationType.attendance:
        return 'Attendance';
      case NotificationType.assignment:
        return 'Assignment';
      case NotificationType.exam:
        return 'Exam';
    }
  }
}

/// A notification shown in the student notification centre.
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime date;
  bool read;

  /// Who receives it; null means every student.
  final String? recipientId;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
    this.recipientId,
  });
}
