// ===== FILE GUIDE: lib/screens/admin/users/add_edit_user_screen.dart
// WHAT IT DOES : Add or edit one user.
// MANAGES      : User details, role and validation.
// USED BY      : User Management, admin dashboard (Hire Teacher).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../services/email_policy.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../services/session_service.dart';

/// Add a new user or edit an existing one, including role management.
/// Returns the resulting [AppUser].
class AddEditUserScreen extends StatefulWidget {
  final AppUser? existing;
  final UserRole? presetRole;
  AddEditUserScreen({super.key, this.existing, this.presetRole});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _email = TextEditingController(text: widget.existing?.email ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _department = TextEditingController(text: widget.existing?.department ?? '');
  late final _designation = TextEditingController(text: widget.existing?.designation ?? '');
  late final _studentId = TextEditingController(text: widget.existing?.studentId ?? '');
  late final _program = TextEditingController(text: widget.existing?.program ?? '');
  late final _semester = TextEditingController(text: widget.existing?.semester?.toString() ?? '');
  final _password = TextEditingController();

  late UserRole _role = widget.existing?.role ?? widget.presetRole ?? UserRole.student;

  bool get _isEdit => widget.existing != null;

  static final _palette = ['#8A4A52', '#B5A57C', '#2E2729', '#E0962A', '#5C8FA3', '#4E9B78'];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _department.dispose();
    _designation.dispose();
    _studentId.dispose();
    _program.dispose();
    _semester.dispose();
    _password.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final emailChanged = !_isEdit || widget.existing!.email.toLowerCase() != email.toLowerCase();
    if (emailChanged && AuthService.isRegistered(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Another account already uses this email.')));
      return;
    }
    final user = AppUser(
      id: widget.existing?.id ?? 'u${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      role: _role,
      avatarColor: widget.existing?.avatarColor ?? _palette[_name.text.trim().length % _palette.length],
      department: _department.text.trim().isEmpty ? null : _department.text.trim(),
      designation: _designation.text.trim().isEmpty ? null : _designation.text.trim(),
      studentId: _studentId.text.trim().isEmpty ? null : _studentId.text.trim(),
      program: _program.text.trim().isEmpty ? null : _program.text.trim(),
      semester: int.tryParse(_semester.text.trim()),
    );
    if (_isEdit) {
      AuthService.moveAccount(widget.existing!.email, user.email);
    } else {
      // New accounts are registered with the temporary password the admin shares with the user.
      AuthService.register(user, _password.text);
    }
    Navigator.pop(context, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit User' : (_role == UserRole.faculty ? 'Hire Teacher' : 'Add User'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(18),
          children: [
            Text(
              'Role',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 10),
            Row(
              children: UserRole.values.map((r) {
                final selected = r == _role;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _role = r),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 160),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            r.label,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 22),
            AppTextField(
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              controller: _name,
              validator: (v) => (v == null || v.trim().length < 3) ? 'Enter a full name' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              icon: Icons.mail_outline_rounded,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: EmailPolicy.validate,
            ),
            if (!_isEdit) ...[
              SizedBox(height: 16),
              AppTextField(
                label: 'Temporary password',
                hint: 'Share it with the user privately',
                icon: Icons.lock_outline_rounded,
                controller: _password,
                obscure: true,
                validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters' : null,
              ),
            ],
            SizedBox(height: 16),
            AppTextField(
              label: 'Phone',
              icon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.replaceAll(RegExp(r'\D'), '').length < 7) ? 'Enter a valid phone' : null,
            ),
            SizedBox(height: 16),
            AppTextField(label: 'Department', icon: Icons.apartment_rounded, controller: _department),

            // Role-specific fields
            if (_role == UserRole.faculty) ...[
              SizedBox(height: 16),
              AppTextField(
                label: 'Designation',
                hint: 'e.g. Associate Professor',
                icon: Icons.badge_rounded,
                controller: _designation,
              ),
            ],
            if (_role == UserRole.student) ...[
              SizedBox(height: 16),
              AppTextField(
                label: 'Student ID',
                hint: 'e.g. CSE-2021-0147',
                icon: Icons.badge_rounded,
                controller: _studentId,
              ),
              SizedBox(height: 16),
              AppTextField(
                label: 'Program',
                hint: 'e.g. B.Sc. in CSE',
                icon: Icons.school_rounded,
                controller: _program,
              ),
              SizedBox(height: 16),
              AppTextField(
                label: 'Semester',
                hint: 'e.g. 6',
                icon: Icons.calendar_month_rounded,
                controller: _semester,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
            ],
            SizedBox(height: 26),
            AppButton(
              label: _isEdit ? 'Save Changes' : (_role == UserRole.faculty ? 'Hire Teacher' : 'Add User'),
              icon: _isEdit ? Icons.save_rounded : Icons.person_add_alt_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
