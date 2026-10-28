// ===== FILE GUIDE: lib/screens/auth/signup_screen.dart
// WHAT IT DOES : Old sign-up screen.
// STATUS       : NOT USED anymore — replaced by the Sign Up tab in login_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/email_policy.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'login_screen.dart';

/// Sign up screen with role selection and form validation.
class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  UserRole _role = UserRole.student;
  bool _obscure = true;
  bool _accepted = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please accept the terms to continue')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Account created'),
        content: Text(
          'Welcome, ${_name.text.trim()}! Your ${_role.label.toLowerCase()} account '
          'is ready. Please sign in to continue.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create account'),
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
                Text(
                  'Join Campus Connect',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 6),
                Text(
                  'Fill in your details to get started',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                SizedBox(height: 24),
                Text(
                  'Register as',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  // Admin accounts cannot be self-registered.
                  children: UserRole.values.where((r) => r != UserRole.admin).map((r) {
                    final selected = r == _role;
                    return ChoiceChip(
                      label: Text(r.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _role = r),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 22),
                AppTextField(
                  label: 'Full name',
                  hint: 'e.g. Ayesha Rahman',
                  icon: Icons.person_outline_rounded,
                  controller: _name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 3) return 'Enter your full name';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'you@campus.edu.pk',
                  icon: Icons.mail_outline_rounded,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: EmailPolicy.validate,
                ),
                SizedBox(height: 16),
                AppTextField(
                  label: 'Phone',
                  hint: '+1 (555) 000-0000',
                  icon: Icons.phone_outlined,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (v.replaceAll(RegExp(r'\D'), '').length < 7) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'At least 6 characters',
                  icon: Icons.lock_outline_rounded,
                  controller: _password,
                  obscure: _obscure,
                  suffix: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm password',
                  hint: 'Re-enter password',
                  icon: Icons.lock_reset_rounded,
                  controller: _confirm,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'I agree to the Terms of Service and Privacy Policy.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                AppButton(
                  label: _loading ? 'Creating account...' : 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  loading: _loading,
                  onPressed: _submit,
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Sign In')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
