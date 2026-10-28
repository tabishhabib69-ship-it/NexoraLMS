// ===== FILE GUIDE: lib/screens/auth/reset_password_screen.dart
// WHAT IT DOES : Second step of password reset (demo code + new password).
// MANAGES      : Code and password validation; explains that no email is sent in the demo.
// USED BY      : login_screen.dart (Forgot tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/uni_widgets.dart';
import 'login_screen.dart';
import '../../services/session_service.dart';

/// Second step of the password reset: verification code + new password.
///
/// No backend is configured, so no email is sent — the demo code is shown on
/// screen and the password is not actually changed anywhere.
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  static const String demoCode = '246810';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    if (!AuthService.setPassword(widget.email, _password.text)) {
      showSnack(context, 'No account found for this email.');
      return;
    }
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
        title: Text('Password updated'),
        content: Text('Sign in with your new password. (Saved on this device for the demo.)'),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text('Back to Login'))],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
              SizedBox(height: 22),
              Text(
                'Set a new password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text('For ${widget.email}', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              SizedBox(height: 18),
              InfoBanner(
                tone: BannerTone.warning,
                title: 'Demo mode — no email sent',
                text: 'A real build would email a code. Use the demo code ${ResetPasswordScreen.demoCode}.',
              ),
              SizedBox(height: 22),
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(labelText: 'Verification code', counterText: ''),
                validator: (v) => v?.trim() != ResetPasswordScreen.demoCode ? 'Incorrect code' : null,
              ),
              SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
              ),
              SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Confirm new password'),
                validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              ),
              SizedBox(height: 26),
              GradientButton(label: 'Reset Password', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
