// ===== FILE GUIDE: lib/models/semester.dart
// WHAT IT DOES : Data class for an academic semester.
// MANAGES      : Semester name, start/end dates and which one is active.
// USED BY      : Admin semester management, headers that show the current term.
// ======================================================================

/// An academic semester managed by admin.
class Semester {
  final String id;
  final String name; // e.g. "Spring 2026"
  final String startDate;
  final String endDate;
  bool isActive;

  Semester({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
  });

  Semester copyWith({String? name, String? startDate, String? endDate, bool? isActive}) {
    return Semester(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
