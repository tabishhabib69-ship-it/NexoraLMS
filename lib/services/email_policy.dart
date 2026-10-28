// ===== FILE GUIDE: lib/services/email_policy.dart
// WHAT IT DOES : University email rule.
// MANAGES      : Only .edu.pk emails are accepted (form validator).
// USED BY      : Login, sign up, reset password, admin add/edit user.
// ======================================================================

/// University email policy: only institutional `.edu.pk` addresses are allowed
/// to register or sign in. Any other domain (e.g. `.com`, `.edu`) is rejected.
class EmailPolicy {
  EmailPolicy._();

  static const String allowedSuffix = '.edu.pk';

  static bool isUniversityEmail(String email) => email.trim().toLowerCase().endsWith(allowedSuffix);

  /// Form validator. Returns an error message when the email is missing,
  /// malformed, or not a `.edu.pk` institutional address; otherwise null.
  static String? validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    if (!isUniversityEmail(v)) {
      return 'Only .edu.pk university emails are allowed';
    }
    return null;
  }
}
