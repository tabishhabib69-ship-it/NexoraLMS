// ===== FILE GUIDE: lib/services/session_service.dart
// WHAT IT DOES : Sign-in, sign-up and session handling (local, no backend).
// MANAGES      : Who is signed in, the on-device account store (email → password), login checks
//                (unknown email / wrong password / suspended), registration, password changes.
// USED BY      : Login, sign up, reset password, admin user management, role guard, logout.
// ======================================================================

import '../data/dummy_data.dart';
import '../models/user.dart';

/// Result of a sign-in attempt: either a user or an error message.
class AuthResult {
  final AppUser? user;
  final String? error;

  const AuthResult.ok(AppUser this.user) : error = null;
  const AuthResult.fail(String this.error) : user = null;

  bool get ok => user != null;
}

/// Local authentication for this backend-free build.
///
/// Only registered accounts can sign in, and only with their own password.
/// Accounts live in memory for the running app (sample accounts are seeded
/// from [DummyData]); a real deployment must replace this with a server-side
/// auth provider — passwords must never be stored in the app.
class AuthService {
  AuthService._();

  /// Passwords set at runtime (sign-up, reset, admin-created accounts).
  static final Map<String, String> _passwords = {};

  /// Sample-account passwords, documented in README for demos.
  static const String demoPassword = 'Demo@1234';
  static const String demoAdminPassword = 'Admin@2026';

  static String _key(String email) => email.trim().toLowerCase();

  static AppUser? userByEmail(String email) {
    final k = _key(email);
    for (final u in DummyData.users) {
      if (u.email.toLowerCase() == k) return u;
    }
    return null;
  }

  static bool isRegistered(String email) => userByEmail(email) != null;

  static String? _passwordFor(AppUser u) {
    final custom = _passwords[_key(u.email)];
    if (custom != null) return custom;
    if (DummyData.seedUserIds.contains(u.id)) {
      return u.role == UserRole.admin ? demoAdminPassword : demoPassword;
    }
    return null;
  }

  /// Checks the credentials and, on success, starts the session.
  static AuthResult signIn(String email, String password) {
    final user = userByEmail(email);
    if (user == null) return AuthResult.fail('No account found for this email. Please sign up first.');
    if (_passwordFor(user) != password) return AuthResult.fail('Incorrect password. Please try again.');
    if (DummyData.suspendedUserIds.contains(user.id)) {
      return AuthResult.fail('This account is suspended. Contact the registrar office.');
    }
    SessionService.signIn(user);
    return AuthResult.ok(user);
  }

  /// Registers a new account. Returns an error message or null on success.
  static String? register(AppUser user, String password) {
    if (isRegistered(user.email)) return 'An account with this email already exists — sign in instead.';
    DummyData.users.add(user);
    _passwords[_key(user.email)] = password;
    return null;
  }

  /// Sets a new password for a registered account (reset / admin).
  static bool setPassword(String email, String password) {
    if (!isRegistered(email)) return false;
    _passwords[_key(email)] = password;
    return true;
  }

  /// Changes the signed-in user's password after checking the current one.
  static String? changePassword(String email, String current, String next) {
    final user = userByEmail(email);
    if (user == null) return 'Account not found.';
    if (_passwordFor(user) != current) return 'Current password is incorrect.';
    if (next.length < 8) return 'New password must be at least 8 characters.';
    if (next == current) return 'New password must be different.';
    _passwords[_key(email)] = next;
    return null;
  }

  /// Keeps the account's password when its email is edited.
  static void moveAccount(String oldEmail, String newEmail) {
    if (_key(oldEmail) == _key(newEmail)) return;
    final user = userByEmail(oldEmail);
    final pw = user == null ? _passwords[_key(oldEmail)] : _passwordFor(user);
    _passwords.remove(_key(oldEmail));
    if (pw != null) _passwords[_key(newEmail)] = pw;
  }

  static void forget(String email) => _passwords.remove(_key(email));

  /// Drops runtime passwords (used by the demo-data reset).
  static void reset() => _passwords.clear();
}

/// Holds the currently signed-in user for the running app session.
class SessionService {
  SessionService._();

  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static void signIn(AppUser user) => _currentUser = user;

  /// Refreshes the session copy after the user's profile is edited.
  static void update(AppUser user) {
    if (_currentUser?.id == user.id) _currentUser = user;
  }

  static void signOut() => _currentUser = null;
}
