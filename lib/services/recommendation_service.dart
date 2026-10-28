// ===== FILE GUIDE: lib/services/recommendation_service.dart
// WHAT IT DOES : Course recommendation logic.
// MANAGES      : Scores courses using interests, prerequisite results, department and semester, with reasons. Never enrolls anyone.
// USED BY      : Courses for You screen.
// ======================================================================

import '../data/dummy_data.dart';
import 'my_data.dart';
import '../models/course.dart';
import 'academic_service.dart';
import 'app_settings.dart';

/// A suggested course with the reasons behind it.
class CourseRecommendation {
  final Course course;
  final int score;
  final List<String> reasons;
  final bool prerequisitesMet;

  const CourseRecommendation({
    required this.course,
    required this.score,
    required this.reasons,
    required this.prerequisitesMet,
  });
}

/// Scores courses the student is not enrolled in using their interests,
/// prerequisite progress and related grades. Never enrolls automatically.
class RecommendationService {
  RecommendationService._();

  static List<CourseRecommendation> recommend() {
    final enrolled = MyData.courseIds.toSet();
    final me = MyData.user;
    final results = <CourseRecommendation>[];
    for (final c in DummyData.courses) {
      if (enrolled.contains(c.id)) continue;
      final reasons = <String>[];
      var score = 0;

      final tags = DummyData.courseTags[c.id] ?? const [];
      final matches = tags.where(AppSettings.interests.contains).toList();
      if (matches.isNotEmpty) {
        score += 3 * matches.length;
        reasons.add('Matches your interest in ${matches.join(' & ')}');
      }

      final prereqs = DummyData.prerequisites[c.id] ?? const [];
      var met = true;
      for (final p in prereqs) {
        final pc = DummyData.courseById(p);
        final pct = AcademicService.coursePercent(p);
        if (pct != null && pct >= 70) {
          score += 2;
          reasons.add('Strong result in prerequisite ${pc?.code} (${pct.round()}%)');
        } else {
          met = false;
          reasons.add('Needs ${pc?.code ?? p} first');
        }
      }

      if (c.department == me.department || c.department == 'Software Engineering') {
        score += 1;
        reasons.add('Counts toward your ${me.program ?? 'program'}');
      } else {
        score -= 2;
        reasons.add('Outside your department (${c.department})');
      }

      final sem = me.semester ?? 0;
      if (c.semester == sem + 1) {
        score += 1;
        reasons.add('Planned for semester ${c.semester} — next term');
      }

      results.add(CourseRecommendation(course: c, score: score, reasons: reasons, prerequisitesMet: met));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
