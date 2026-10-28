// ===== FILE GUIDE: lib/services/academic_service.dart
// WHAT IT DOES : Calculates academic numbers from the demo data.
// MANAGES      : Course %, letter grade, grade points, CGPA, completed credits, upcoming tasks/exams, countdown text ("Tomorrow", "3 days").
// USED BY      : Dashboard, courses, assignments, Performance, planner, recommendations.
// ======================================================================

import '../data/dummy_data.dart';
import 'my_data.dart';
import '../models/academics.dart';
import '../models/course.dart';

/// Derived academic figures (marks, letter grades, GPA, deadlines).
///
/// Everything is computed from [DummyData] so the numbers stay consistent
/// across screens. Grades are sample data, not official university records.
class AcademicService {
  AcademicService._();

  static List<Course> get studentCourses => [
    for (final id in MyData.courseIds)
      if (DummyData.courseById(id) != null) DummyData.courseById(id)!,
  ];

  static List<GradeItem> gradesFor(String courseId) => MyData.grades.where((g) => g.courseId == courseId).toList();

  /// Running percentage across graded items, or null when nothing is graded.
  static double? coursePercent(String courseId) {
    final items = gradesFor(courseId);
    if (items.isEmpty) return null;
    final got = items.fold<double>(0, (s, g) => s + g.obtained);
    final total = items.fold<double>(0, (s, g) => s + g.total);
    return total == 0 ? null : got / total * 100;
  }

  static String letterFor(double pct) {
    if (pct >= 86) return 'A';
    if (pct >= 82) return 'A-';
    if (pct >= 78) return 'B+';
    if (pct >= 74) return 'B';
    if (pct >= 70) return 'B-';
    if (pct >= 66) return 'C+';
    if (pct >= 62) return 'C';
    if (pct >= 58) return 'C-';
    if (pct >= 50) return 'D';
    return 'F';
  }

  static double gradePointFor(double pct) {
    const map = {
      'A': 4.0,
      'A-': 3.7,
      'B+': 3.3,
      'B': 3.0,
      'B-': 2.7,
      'C+': 2.3,
      'C': 2.0,
      'C-': 1.7,
      'D': 1.0,
      'F': 0.0,
    };
    return map[letterFor(pct)]!;
  }

  /// Credit-weighted CGPA over completed terms.
  static double get cgpa {
    final terms = MyData.termResults;
    final credits = terms.fold<int>(0, (s, t) => s + t.credits);
    if (credits == 0) return 0;
    return terms.fold<double>(0, (s, t) => s + t.gpa * t.credits) / credits;
  }

  static int get completedCredits => MyData.termResults.fold<int>(0, (s, t) => s + t.credits);

  /// Projected GPA for the current term from running course percentages.
  static double? get projectedTermGpa {
    double points = 0;
    int credits = 0;
    for (final c in studentCourses) {
      final pct = coursePercent(c.id);
      if (pct == null) continue;
      points += gradePointFor(pct) * c.credits;
      credits += c.credits;
    }
    return credits == 0 ? null : points / credits;
  }

  /// Student's tasks, soonest first. Pending items before finished ones.
  static List<Assignment> get studentTasks {
    final mine = MyData.courseIds.toSet();
    final list = [
      for (final a in DummyData.assignments)
        if (mine.contains(a.courseId)) MyData.assignmentFor(a),
    ];
    list.sort((a, b) {
      final ap = a.status == SubmissionStatus.pending ? 0 : 1;
      final bp = b.status == SubmissionStatus.pending ? 0 : 1;
      if (ap != bp) return ap - bp;
      return a.due.compareTo(b.due);
    });
    return list;
  }

  static List<Assignment> get upcomingTasks =>
      studentTasks.where((a) => a.status == SubmissionStatus.pending && a.due.isAfter(DateTime.now())).toList();

  static List<Exam> get upcomingExams {
    final mine = MyData.courseIds.toSet();
    final list = DummyData.exams.where((e) => mine.contains(e.courseId) && e.date.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Human countdown such as "Due in 2h", "Due tomorrow", "3 days left".
  static String countdown(DateTime when) {
    final now = DateTime.now();
    final diff = when.difference(now);
    if (diff.isNegative) {
      final late = now.difference(when);
      return late.inDays >= 1 ? 'Overdue by ${late.inDays}d' : 'Overdue';
    }
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes} min';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(when.year, when.month, when.day);
    final days = day.difference(today).inDays;
    if (days == 0) return 'In ${diff.inHours}h';
    if (days == 1) return 'Tomorrow';
    return '$days days';
  }
}
