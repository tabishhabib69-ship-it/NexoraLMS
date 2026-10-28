// ===== FILE GUIDE: lib/services/my_data.dart
// WHAT IT DOES : Gives each signed-in user only their OWN data.
// MANAGES      : My courses, attendance, grades, term results, assignment status, timetable,
//                conversations and notifications — scoped to the current user's id.
// USED BY      : Student and faculty screens and the academic/schedule/recommendation services.
// ======================================================================

import '../data/dummy_data.dart';
import '../models/academics.dart';
import '../models/attendance.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/timetable.dart';
import '../models/user.dart';
import 'session_service.dart';
import '../models/post.dart';

/// Data belonging to the signed-in user.
///
/// Every screen reads personal records through here, so one user can never
/// see another user's attendance, grades, chats or notifications.
class MyData {
  MyData._();

  static AppUser get user => SessionService.currentUser ?? DummyData.student;
  static String get id => user.id;

  /// The seeded sample student whose full academic history exists in the demo data.
  static bool get _isSampleStudent => id == DummyData.student.id;

  /// Courses I study (students) or teach (faculty).
  static List<String> get courseIds {
    if (user.role == UserRole.faculty) {
      return [
        for (final c in DummyData.courses)
          if (c.facultyId == id) c.id,
      ];
    }
    if (_isSampleStudent) return DummyData.studentCourseIds;
    return [
      for (final entry in DummyData.courseAttendance.entries)
        if (entry.value.any((r) => r.studentId == id)) entry.key,
    ];
  }

  static List<AttendanceRecord> get attendance {
    if (_isSampleStudent) return DummyData.studentAttendance;
    return [
      for (final list in DummyData.courseAttendance.values)
        for (final r in list)
          if (r.studentId == id) r,
    ];
  }

  static List<GradeItem> get grades => _isSampleStudent ? DummyData.grades : const [];

  static List<TermResult> get termResults => _isSampleStudent ? DummyData.termResults : const [];

  /// My view of an assignment. The sample student's progress is stored on the
  /// assignment itself; everyone else's comes from the faculty submissions map.
  static Assignment assignmentFor(Assignment a) {
    if (_isSampleStudent) return a;
    final subs = DummyData.submissions[a.id] ?? const {};
    final submitted = subs.containsKey(id);
    final mark = subs[id];
    final graded = submitted && mark != null && DummyData.publishedGrades.contains(a.id);
    return Assignment(
      id: a.id,
      courseId: a.courseId,
      title: a.title,
      instructions: a.instructions,
      due: a.due,
      totalMarks: a.totalMarks,
      type: a.type,
      status: graded
          ? SubmissionStatus.graded
          : submitted
          ? SubmissionStatus.submitted
          : SubmissionStatus.pending,
      submittedAt: submitted ? a.due : null,
      attachmentName: submitted ? 'Submitted file' : null,
      obtained: graded ? mark : null,
      feedback: graded ? DummyData.gradeFeedback['${a.id}:$id'] : null,
    );
  }

  /// Records my submission for [a] in the shared store.
  static void submit(Assignment a, String fileName) {
    a.status = SubmissionStatus.submitted;
    a.submittedAt = DateTime.now();
    a.attachmentName = fileName;
    // Faculty see it in their grading queue.
    DummyData.submissions.putIfAbsent(a.id, () => {})[id] = null;
  }

  /// Weekly timetable: my enrolled / taught courses only.
  static List<TimetableEntry> get timetable {
    final mine = courseIds.toSet();
    final source = user.role == UserRole.faculty
        ? [...DummyData.facultyTimetable, ...DummyData.studentTimetable]
        : DummyData.studentTimetable;
    final seen = <String>{};
    return [
      for (final e in source)
        if (mine.contains(e.courseId) && seen.add('${e.day}${e.start}${e.courseId}')) e,
    ];
  }

  // -------------------------------------------------------------- bookmarks
  static Set<String> get savedMaterials => DummyData.savedMaterials.putIfAbsent(id, () => {});

  static bool likes(Post p) => p.likedBy.contains(id);
  static bool saved(Post p) => p.savedBy.contains(id);

  static void toggleLike(Post p) {
    if (p.likedBy.remove(id)) {
      p.likes--;
    } else {
      p.likedBy.add(id);
      p.likes++;
    }
  }

  static void toggleSave(Post p) => p.savedBy.remove(id) ? null : p.savedBy.add(id);

  // ------------------------------------------------------------ connections
  static Set<String> get connections => DummyData.connections.putIfAbsent(id, () => {});

  /// People waiting for me to accept their request.
  static Set<String> get incomingRequests => DummyData.connectionRequests.putIfAbsent(id, () => {});

  /// Whether I already sent [userId] a request.
  static bool requestedTo(String userId) => DummyData.connectionRequests[userId]?.contains(id) ?? false;

  static void sendRequest(String userId) => DummyData.connectionRequests.putIfAbsent(userId, () => {}).add(id);

  static void cancelRequest(String userId) => DummyData.connectionRequests[userId]?.remove(id);

  static void acceptRequest(String userId) {
    incomingRequests.remove(userId);
    connections.add(userId);
    DummyData.connections.putIfAbsent(userId, () => {}).add(id);
  }

  static void declineRequest(String userId) => incomingRequests.remove(userId);

  static List<Conversation> get conversations => [
    for (final c in DummyData.conversations)
      if (c.ownerId == id) c,
  ];

  static List<AppNotification> get notifications => [
    for (final n in DummyData.notifications)
      if (n.recipientId == null || n.recipientId == id) n,
  ];
}
