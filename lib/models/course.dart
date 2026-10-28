// ===== FILE GUIDE: lib/models/course.dart
// WHAT IT DOES : Data classes for a course and its passing criteria.
// MANAGES      : Course details (code, title, instructor, credits, schedule, room) and PassingCriteria.
// USED BY      : Course lists, course workspace, faculty hub, admin course management.
// ======================================================================

/// A course offered by the university.
class Course {
  final String id;
  final String code; // e.g. "CSE-201"
  final String title;
  final String facultyId;
  final String facultyName;
  final String description;
  final int credits;
  final int semester;
  final String department;
  final String schedule; // e.g. "Mon & Wed · 10:00 AM"
  final String room;
  final int enrolledCount;
  final String color; // hex accent used on the course card

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.facultyId,
    required this.facultyName,
    required this.description,
    required this.credits,
    required this.semester,
    required this.department,
    required this.schedule,
    required this.room,
    required this.enrolledCount,
    required this.color,
  });

  Course copyWith({
    String? title,
    String? facultyId,
    String? facultyName,
    String? description,
    int? credits,
    int? semester,
    String? schedule,
    String? room,
    int? enrolledCount,
  }) {
    return Course(
      id: id,
      code: code,
      title: title ?? this.title,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      department: department,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      color: color,
    );
  }
}

/// Passing criteria for a course (faculty managed).
class PassingCriteria {
  final String courseId;
  final int attendancePercent;
  final int midtermWeight;
  final int finalWeight;
  final int assignmentWeight;
  final int passMark;

  const PassingCriteria({
    required this.courseId,
    this.attendancePercent = 75,
    this.midtermWeight = 30,
    this.finalWeight = 50,
    this.assignmentWeight = 20,
    this.passMark = 40,
  });

  PassingCriteria copyWith({
    int? attendancePercent,
    int? midtermWeight,
    int? finalWeight,
    int? assignmentWeight,
    int? passMark,
  }) {
    return PassingCriteria(
      courseId: courseId,
      attendancePercent: attendancePercent ?? this.attendancePercent,
      midtermWeight: midtermWeight ?? this.midtermWeight,
      finalWeight: finalWeight ?? this.finalWeight,
      assignmentWeight: assignmentWeight ?? this.assignmentWeight,
      passMark: passMark ?? this.passMark,
    );
  }
}
