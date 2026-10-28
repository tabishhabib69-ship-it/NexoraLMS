// ===== FILE GUIDE: lib/models/attendance.dart
// WHAT IT DOES : Data classes for attendance.
// MANAGES      : AttendanceRecord (classes held / attended) and AttendanceSession (one marking row).
// USED BY      : attendance_service.dart, Performance screen, faculty attendance and rosters.
// ======================================================================

/// Attendance record for one student in one course.
///
/// Holds raw counts only — the percentage and all derived figures are computed
/// dynamically by [AttendanceService] so they always reflect the real data.
class AttendanceRecord {
  final String studentId;
  final String courseId;
  final int totalClasses;
  final int attended;

  const AttendanceRecord({
    required this.studentId,
    required this.courseId,
    required this.totalClasses,
    required this.attended,
  });

  int get missed => totalClasses - attended;

  AttendanceRecord copyWith({int? totalClasses, int? attended}) {
    return AttendanceRecord(
      studentId: studentId,
      courseId: courseId,
      totalClasses: totalClasses ?? this.totalClasses,
      attended: attended ?? this.attended,
    );
  }
}

/// One class session used by faculty when marking attendance.
class AttendanceSession {
  final String studentId;
  final String studentName;
  bool present;

  AttendanceSession({required this.studentId, required this.studentName, this.present = true});
}
