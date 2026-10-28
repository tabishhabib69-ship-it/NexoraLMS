// ===== FILE GUIDE: lib/models/academics.dart
// WHAT IT DOES : Data classes for academic records.
// MANAGES      : Assignment, Exam, GradeItem, TermResult, CalendarEvent, AchievementBadge, EnrollmentRequest, StudyGroup, AuditEntry, FaqItem.
// USED BY      : dummy_data.dart, assignments, planner, grading, enrollment and admin screens.
// ======================================================================

/// Academic records used by the LMS, planner, faculty and admin modules.
library;

enum TaskType { assignment, quiz }

enum SubmissionStatus { pending, submitted, graded }

extension SubmissionStatusX on SubmissionStatus {
  String get label {
    switch (this) {
      case SubmissionStatus.pending:
        return 'Pending';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.graded:
        return 'Graded';
    }
  }
}

/// An assignment or quiz set by faculty for a course.
class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String instructions;
  final DateTime due;
  final int totalMarks;
  final TaskType type;
  SubmissionStatus status;
  DateTime? submittedAt;
  String? attachmentName;
  double? obtained;
  String? feedback;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.instructions,
    required this.due,
    required this.totalMarks,
    this.type = TaskType.assignment,
    this.status = SubmissionStatus.pending,
    this.submittedAt,
    this.attachmentName,
    this.obtained,
    this.feedback,
  });

  bool get isOverdue => status == SubmissionStatus.pending && due.isBefore(DateTime.now());
}

/// A scheduled midterm / final exam.
class Exam {
  final String id;
  final String courseId;
  final String title;
  final DateTime date;
  final String venue;
  final String seat;

  const Exam({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.venue,
    required this.seat,
  });
}

/// One graded component (quiz, assignment, midterm) of a course.
class GradeItem {
  final String courseId;
  final String title;
  final double obtained;
  final double total;
  final String? feedback;

  const GradeItem({
    required this.courseId,
    required this.title,
    required this.obtained,
    required this.total,
    this.feedback,
  });
}

/// A completed term with its GPA (for the GPA trend chart).
class TermResult {
  final String term;
  final double gpa;
  final int credits;

  const TermResult({required this.term, required this.gpa, required this.credits});
}

/// A personal study event the student adds to their calendar.
class CalendarEvent {
  final String id;
  final String title;
  final DateTime date; // day only
  final int startMinutes; // minutes after midnight
  final int endMinutes;
  final String note;
  final String ownerId;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    this.note = '',
    required this.ownerId,
  });
}

/// An achievement badge shown on the student profile.
class AchievementBadge {
  final String title;
  final String subtitle;
  final String icon; // key resolved to an IconData by the UI
  final String tone; // 'amber' | 'wine' | 'ink' | 'sand'

  const AchievementBadge({required this.title, required this.subtitle, required this.icon, required this.tone});
}

enum RequestStatus { pending, accepted, declined }

/// A student's request to join a course (faculty Enrollment Manager).
class EnrollmentRequest {
  final String id;
  final String studentId;
  final String courseId;
  final double gpa;
  final String message;
  RequestStatus status;

  EnrollmentRequest({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.gpa,
    required this.message,
    this.status = RequestStatus.pending,
  });
}

/// A student study group with its own group chat.
class StudyGroup {
  final String id;
  final String name;
  final String courseId;
  final List<String> memberIds;
  final String description;
  final String meeting;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.courseId,
    required this.memberIds,
    required this.description,
    required this.meeting,
  });
}

/// An entry in the admin audit / activity history.
class AuditEntry {
  final String action;
  final String detail;
  final String actor;
  final DateTime time;

  const AuditEntry({required this.action, required this.detail, required this.actor, required this.time});
}

/// A help-centre question and answer.
class FaqItem {
  final String question;
  final String answer;

  const FaqItem(this.question, this.answer);
}
