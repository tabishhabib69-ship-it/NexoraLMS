// ===== FILE GUIDE: lib/models/user.dart
// WHAT IT DOES : Data class for a user and the user roles.
// MANAGES      : Student / Faculty / Admin role, profile fields and initials for avatars.
// USED BY      : Login, profiles, role guard, admin user management, everywhere a name is shown.
// ======================================================================

/// Roles supported by the Campus Connect application.
enum UserRole { student, faculty, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'faculty':
        return UserRole.faculty;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

/// A user of the application. Students, faculty and admins share this model;
/// role-specific fields are optional and used only where relevant.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String avatarColor; // hex color used to render the avatar initials
  final String? department;
  final String? designation; // faculty
  final String? studentId; // student
  final int? semester; // student
  final String? program; // student e.g. "B.Sc. in CSE"
  final String? bio;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarColor,
    this.department,
    this.designation,
    this.studentId,
    this.semester,
    this.program,
    this.bio,
  });

  /// Initials without academic titles ("Dr. Sarah Khan" → "SK").
  String get initials {
    final parts = name.replaceAll(RegExp(r'^(Dr|Prof|Mr|Ms|Mrs)\.?\s+'), '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? designation,
    int? semester,
    String? program,
    String? bio,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      avatarColor: avatarColor,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      studentId: studentId ?? studentId,
      semester: semester ?? this.semester,
      program: program ?? this.program,
      bio: bio ?? this.bio,
    );
  }
}
