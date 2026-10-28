// ===== FILE GUIDE: lib/screens/auth/forgot_password_screen.dart
// WHAT IT DOES : Old forgot-password screen.
// STATUS       : NOT USED anymore — replaced by the Forgot tab in login_screen.dart + reset_password_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../services/email_policy.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Forgot password screen — requests a reset link by email.
class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _loading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.mark_email_read_rounded, size: 44, color: AppColors.success),
        title: Text('Check your email'),
        content: Text(
          'If an account exists for ${_email.text.trim()}, a password reset link '
          'has been sent.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(18)),
                  child: Icon(Icons.lock_reset_rounded, size: 32, color: AppColors.warning),
                ),
                SizedBox(height: 22),
                Text(
                  'Forgot your password?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter the email associated with your account and we\'ll send '
                  'you a link to reset it.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
                SizedBox(height: 28),
                AppTextField(
                  label: 'Email',
                  hint: 'you@campus.edu.pk',
                  icon: Icons.mail_outline_rounded,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: EmailPolicy.validate,
                ),
                SizedBox(height: 24),
                AppButton(
                  label: _loading ? 'Sending...' : 'Send Reset Link',
                  icon: Icons.send_rounded,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
