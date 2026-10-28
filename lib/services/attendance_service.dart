// ===== FILE GUIDE: lib/services/attendance_service.dart
// WHAT IT DOES : Attendance maths.
// MANAGES      : Percentage, how many classes you can still miss, how many you must attend to reach 75%, and good / at-risk / critical status.
// USED BY      : Performance screen, dashboard insights, faculty rosters and attendance.
// ======================================================================

import '../models/attendance.dart';

/// Result of an attendance computation for a single student/course.
class AttendanceSummary {
  final int totalClasses;
  final int attended;
  final int missed;
  final double percentage; // 0 - 100
  final int remainingAllowed; // extra classes that can be missed, keeping >= 75%
  final int neededToReach; // consecutive classes to attend to reach >= 75%
  final AttendanceStatus status;

  const AttendanceSummary({
    required this.totalClasses,
    required this.attended,
    required this.missed,
    required this.percentage,
    required this.remainingAllowed,
    required this.neededToReach,
    required this.status,
  });
}

enum AttendanceStatus { good, warning, critical }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.good:
        return 'Good Standing';
      case AttendanceStatus.warning:
        return 'At Risk';
      case AttendanceStatus.critical:
        return 'Below Required';
    }
  }
}

/// Pure, dynamic attendance calculations.
///
/// The minimum required attendance is fixed at 75%, but every other number is
/// derived from the real counts — nothing is hard-coded to 75%.
class AttendanceService {
  AttendanceService._();

  static const int requiredPercent = 75;

  // Percentage bands (based on the real computed percentage).
  static const double _warningThreshold = 80; // >= required but close to it

  /// Attendance % = (attended / total) * 100
  static double percentage({required int attended, required int total}) {
    if (total <= 0) return 0;
    return (attended / total) * 100;
  }

  /// Extra classes the student may still MISS while staying at/above 75%.
  ///
  /// Missing a future class grows the total but not the attended count:
  ///   attended / (total + x) >= 0.75  =>  x <= attended/0.75 - total
  static int remainingAllowedAbsences({required int attended, required int total}) {
    if (total <= 0) return 0;
    final allowed = (attended / (requiredPercent / 100)) - total;
    return allowed > 0 ? allowed.floor() : 0;
  }

  /// Consecutive classes the student must ATTEND to climb back to >= 75%.
  ///
  /// Attending grows both attended and total:
  ///   (attended + y) / (total + y) >= 0.75  =>  y >= (0.75*total - attended)/0.25
  static int classesNeededToReach({required int attended, required int total}) {
    if (total <= 0) return 0;
    final pct = percentage(attended: attended, total: total);
    if (pct >= requiredPercent) return 0;
    final needed = ((requiredPercent / 100) * total - attended) / (1 - requiredPercent / 100);
    return needed > 0 ? needed.ceil() : 0;
  }

  static AttendanceStatus statusFor(double pct) {
    if (pct >= _warningThreshold) return AttendanceStatus.good;
    if (pct >= requiredPercent) return AttendanceStatus.warning;
    return AttendanceStatus.critical;
  }

  /// Full dynamic summary for a record.
  static AttendanceSummary summarize(AttendanceRecord record) {
    final pct = percentage(attended: record.attended, total: record.totalClasses);
    final remaining = remainingAllowedAbsences(attended: record.attended, total: record.totalClasses);
    final needed = classesNeededToReach(attended: record.attended, total: record.totalClasses);
    return AttendanceSummary(
      totalClasses: record.totalClasses,
      attended: record.attended,
      missed: record.missed,
      percentage: pct,
      remainingAllowed: remaining,
      neededToReach: needed,
      status: statusFor(pct),
    );
  }

  /// Aggregate summary across several records (e.g. all a student's courses).
  static AttendanceSummary aggregate(List<AttendanceRecord> records) {
    final total = records.fold<int>(0, (s, r) => s + r.totalClasses);
    final attended = records.fold<int>(0, (s, r) => s + r.attended);
    final rec = AttendanceRecord(studentId: '', courseId: '', totalClasses: total, attended: attended);
    return summarize(rec);
  }

  /// True when the student is within one absence band of dropping below 75%.
  static bool shouldWarn(AttendanceSummary s) {
    return s.status == AttendanceStatus.warning || s.status == AttendanceStatus.critical || s.remainingAllowed <= 2;
  }

  /// A short human-readable hint for dashboards.
  static String hint(AttendanceSummary s) {
    if (s.status == AttendanceStatus.critical) {
      return 'Attend the next ${s.neededToReach} classes to reach $requiredPercent%.';
    }
    if (s.status == AttendanceStatus.warning) {
      return 'Close to the $requiredPercent% limit — you can miss ${s.remainingAllowed} more class${s.remainingAllowed == 1 ? '' : 'es'}.';
    }
    return 'You can still miss ${s.remainingAllowed} more class${s.remainingAllowed == 1 ? '' : 'es'} and stay above $requiredPercent%.';
  }

  /// Convenience: clamp 0..100.
  static double clampPct(double v) => v.clamp(0, 100).toDouble();
}
