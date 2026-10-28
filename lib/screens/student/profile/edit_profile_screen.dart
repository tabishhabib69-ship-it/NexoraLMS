// ===== FILE GUIDE: lib/screens/student/profile/edit_profile_screen.dart
// WHAT IT DOES : Edit profile form.
// MANAGES      : Updates name, email, phone, department and bio of the signed-in user.
// USED BY      : Student profile, faculty profile, Settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/user.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/user_avatar.dart';

/// Edit the signed-in user's profile details.
class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _email = TextEditingController(text: widget.user.email);
  late final _phone = TextEditingController(text: widget.user.phone);
  late final _department = TextEditingController(text: widget.user.department ?? '');
  late final _bio = TextEditingController(text: widget.user.bio ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _department.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(Duration(milliseconds: 700));

    final updated = widget.user.copyWith(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      department: _department.text.trim(),
      bio: _bio.text.trim(),
    );
    AuthService.moveAccount(widget.user.email, updated.email);
    SessionService.update(updated);
    final index = DummyData.users.indexWhere((u) => u.id == updated.id);
    if (index != -1) DummyData.users[index] = updated;

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    Navigator.pop(context);
  }

  void _changePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile photos are not supported in the demo build — your initials are shown instead.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(18),
          children: [
            Center(
              child: Stack(
                children: [
                  UserAvatar(
                    name: _name.text.isEmpty ? widget.user.name : _name.text,
                    colorHex: widget.user.avatarColor,
                    size: 96,
                    fontSize: 34,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _changePhoto,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 17, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _changePhoto,
                icon: Icon(Icons.photo_library_outlined, size: 18),
                label: Text('Change photo'),
              ),
            ),
            SizedBox(height: 14),
            AppTextField(
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              controller: _name,
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Enter your full name' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              icon: Icons.mail_outline_rounded,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Phone',
              icon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.replaceAll(RegExp(r'\D'), '').length < 7) ? 'Enter a valid phone number' : null,
            ),
            SizedBox(height: 16),
            AppTextField(label: 'Department', icon: Icons.apartment_rounded, controller: _department),
            SizedBox(height: 16),
            AppTextField(
              label: 'Bio',
              hint: 'Tell others a little about yourself',
              controller: _bio,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.user.role == UserRole.student
                          ? 'Student ID, semester and program are managed by the registrar.'
                          : 'Some fields are managed by the administration.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            AppButton(
              label: _saving ? 'Saving...' : 'Save Changes',
              icon: Icons.save_rounded,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
