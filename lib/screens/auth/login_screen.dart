// ===== FILE GUIDE: lib/screens/auth/login_screen.dart
// WHAT IT DOES : Sign-in hub (PDF page 1) with Login / Sign Up / Forgot tabs.
// MANAGES      : Login validation and role routing (student, faculty, admin-by-credentials only), sign-up form, forgot-password step.
// USED BY      : Splash, onboarding, logout, role guard.
// ======================================================================

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/app_settings.dart';
import '../../services/email_policy.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uni_logo.dart';
import '../../widgets/uni_widgets.dart';
import '../admin/admin_shell.dart';
import '../faculty/faculty_shell.dart';
import '../student/student_shell.dart';
import 'reset_password_screen.dart';

/// Sign-in hub from the PDF: dark hero with the logo and a frosted card with
/// Login / Sign Up / Forgot tabs.
///
/// Students and faculty sign in with any `.edu.pk` email in this demo; the
/// admin panel opens only for the dedicated admin credentials.
class LoginScreen extends StatefulWidget {
  final int initialTab;

  const LoginScreen({super.key, this.initialTab = 0});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int _tab = widget.initialTab;
  String? _prefillEmail;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Color(0xFF262224),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      SizedBox(height: 36),
                      UniLogo(size: 88),
                      SizedBox(height: 18),
                      Text(
                        'Uni-Sphere',
                        style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'YOUR CAMPUS, REIMAGINED',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.5,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.fromLTRB(22, 22, 22, 28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36), bottom: Radius.circular(8)),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _GlassTabs(index: _tab, onChanged: (i) => setState(() => _tab = i)),
                            SizedBox(height: 22),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 220),
                              child: switch (_tab) {
                                1 => _SignUpForm(
                                  key: ValueKey('signup'),
                                  onCreated: (email) => setState(() {
                                    _prefillEmail = email;
                                    _tab = 0;
                                  }),
                                ),
                                2 => _ForgotForm(key: ValueKey('forgot')),
                                _ => _LoginForm(
                                  key: ValueKey('login$_prefillEmail'),
                                  prefillEmail: _prefillEmail,
                                  onForgot: () => setState(() => _tab = 2),
                                  onSignUp: () => setState(() => _tab = 1),
                                ),
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ tabs --

class _GlassTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _GlassTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['Login', 'Sign Up', 'Forgot?'];
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: i == index ? FontWeight.w800 : FontWeight.w600,
                        color: i == index ? Color(0xFF242021) : Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ form parts --

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.75),
      ),
    ),
  );
}

/// Light rounded input that stays readable on the dark hero in both themes.
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final TextInputAction action;
  final List<String>? autofill;

  const _GlassField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.action = TextInputAction.next,
    this.autofill,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: action,
      autofillHints: autofill,
      style: TextStyle(color: Color(0xFF242021), fontSize: 16),
      cursorColor: Color(0xFF8A4A52),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xFFA79BAA)),
        filled: true,
        fillColor: Color(0xFFF4F1F1),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: suffix,
        suffixIconColor: Color(0xFF6E6668),
        errorStyle: TextStyle(color: Color(0xFFFFC9CE), fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFF2EC4A0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFFFF9AA4), width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFFFF9AA4), width: 2),
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  const _RolePicker({required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final r in [UserRole.student, UserRole.faculty])
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: r == UserRole.student ? 10 : 0),
              child: Semantics(
                button: true,
                selected: r == role,
                child: GestureDetector(
                  onTap: () => onChanged(r),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: r == role ? Colors.white.withValues(alpha: 0.22) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: r == role ? 0.6 : 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          r == UserRole.student ? Icons.school_outlined : Icons.co_present_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          r.label,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String? _validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password is required';
  if (v.length < 6) return 'Use at least 6 characters';
  return null;
}

// ----------------------------------------------------------------- login --

class _LoginForm extends StatefulWidget {
  final String? prefillEmail;
  final VoidCallback onForgot;
  final VoidCallback onSignUp;

  const _LoginForm({super.key, this.prefillEmail, required this.onForgot, required this.onSignUp});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.prefillEmail ?? '');
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = AppSettings.rememberMe;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 700)); // simulated auth round-trip
    if (!mounted) return;
    setState(() => _loading = false);

    final result = AuthService.signIn(_email.text, _password.text);
    if (!result.ok) {
      showSnack(context, result.error!);
      return;
    }
    final user = result.user!;
    _enter(user, switch (user.role) {
      UserRole.admin => AdminShell(),
      UserRole.faculty => FacultyShell(),
      UserRole.student => StudentShell(),
    });
  }

  void _enter(AppUser user, Widget home) {
    AppSettings.rememberMe = _remember;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => home), (_) => false);
    showSnack(context, 'Welcome back, ${user.name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s+'), '').split(' ').first}!');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              'Sign in with your university email',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            SizedBox(height: 20),
            _FieldLabel('Email address'),
            _GlassField(
              controller: _email,
              hint: 'student@riphah.edu.pk',
              keyboardType: TextInputType.emailAddress,
              validator: EmailPolicy.validate,
              autofill: [AutofillHints.email],
            ),
            SizedBox(height: 14),
            _FieldLabel('Password'),
            _GlassField(
              controller: _password,
              hint: '••••••••••',
              obscure: _obscure,
              validator: _validatePassword,
              action: TextInputAction.done,
              autofill: [AutofillHints.password],
              suffix: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.6),
                  activeColor: Color(0xFF2EC4A0),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _remember = !_remember),
                    child: Text('Remember me', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                  ),
                ),
                TextButton(
                  onPressed: widget.onForgot,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(color: Color(0xFF8FE3CF), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GradientButton(label: 'Sign In', icon: Icons.arrow_forward_rounded, loading: _loading, onPressed: _login),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
                TextButton(
                  onPressed: widget.onSignUp,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Color(0xFF8FE3CF), fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _DemoHint(),
          ],
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Colors.white.withValues(alpha: 0.8)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only registered accounts can sign in. New here? Create an account in Sign Up. '
              'Accounts are stored on this device for the demo (no server yet).',
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- sign up --

class _SignUpForm extends StatefulWidget {
  final ValueChanged<String> onCreated;

  const _SignUpForm({super.key, required this.onCreated});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _id = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.student;
  bool _obscure = true;
  bool _terms = false;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _id, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String what) => (v == null || v.trim().isEmpty) ? '$what is required' : null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_terms) {
      showSnack(context, 'Please accept the terms to continue');
      return;
    }
    final email = _email.text.trim().toLowerCase();
    if (AuthService.isRegistered(email)) {
      showSnack(context, 'An account with this email already exists — sign in instead.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);

    final name = '${_first.text.trim()} ${_last.text.trim()}';
    final error = AuthService.register(
      AppUser(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        name: _role == UserRole.faculty ? 'Dr. $name' : name,
        email: email,
        phone: '',
        role: _role,
        avatarColor: '#8A4A52',
        department: 'Computer Science',
        studentId: _role == UserRole.student ? _id.text.trim().toUpperCase() : null,
        semester: _role == UserRole.student ? 1 : null,
        designation: _role == UserRole.faculty ? 'Lecturer' : null,
      ),
      _password.text,
    );
    if (error != null) {
      showSnack(context, error);
      return;
    }
    showSnack(context, 'Account created. Sign in with your new email and password.');
    widget.onCreated(email);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RolePicker(role: _role, onChanged: (r) => setState(() => _role = r)),
          SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('First name'),
                    _GlassField(controller: _first, hint: 'Zara', validator: (v) => _required(v, 'First name')),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Last name'),
                    _GlassField(controller: _last, hint: 'Ahmed', validator: (v) => _required(v, 'Last name')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _FieldLabel('University email'),
          _GlassField(
            controller: _email,
            hint: 'name@riphah.edu.pk',
            keyboardType: TextInputType.emailAddress,
            validator: EmailPolicy.validate,
          ),
          SizedBox(height: 14),
          _FieldLabel(_role == UserRole.student ? 'Student ID' : 'Faculty ID'),
          _GlassField(
            controller: _id,
            hint: _role == UserRole.student ? 'CS-24-0001' : 'FAC-0001',
            validator: (v) {
              final r = _required(v, 'ID');
              if (r != null) return r;
              if (!RegExp(r'^[A-Za-z]{2,4}-\d{2,4}(-\d{3,4})?$').hasMatch(v!.trim())) {
                return 'Use the format ${_role == UserRole.student ? 'CS-24-0001' : 'FAC-0001'}';
              }
              return null;
            },
          ),
          SizedBox(height: 14),
          _FieldLabel('Password'),
          _GlassField(
            controller: _password,
            hint: 'At least 6 characters',
            obscure: _obscure,
            validator: _validatePassword,
            suffix: IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          SizedBox(height: 14),
          _FieldLabel('Confirm password'),
          _GlassField(
            controller: _confirm,
            hint: 'Re-enter password',
            obscure: _obscure,
            action: TextInputAction.done,
            validator: (v) => v != _password.text ? 'Passwords do not match' : null,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.6),
                activeColor: Color(0xFF2EC4A0),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _terms = !_terms),
                  child: Text(
                    'I agree to the Terms of Use and Privacy Policy',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GradientButton(label: 'Create Account', loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- forgot --

class _ForgotForm extends StatefulWidget {
  const _ForgotForm({super.key});

  @override
  State<_ForgotForm> createState() => _ForgotFormState();
}

class _ForgotFormState extends State<_ForgotForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!AuthService.isRegistered(_email.text)) {
      showSnack(context, 'No account found for this email.');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: _email.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Enter the university email linked to your account.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.4),
          ),
          SizedBox(height: 18),
          _FieldLabel('Email address'),
          _GlassField(
            controller: _email,
            hint: 'student@riphah.edu.pk',
            keyboardType: TextInputType.emailAddress,
            validator: EmailPolicy.validate,
            action: TextInputAction.done,
          ),
          SizedBox(height: 20),
          GradientButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: _continue),
          SizedBox(height: 16),
          Text(
            'Demo build: no email is sent. You will set a new password on the next screen with a demo code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
