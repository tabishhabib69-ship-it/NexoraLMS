// ===== FILE GUIDE: lib/screens/faculty/announcements/create_announcement_screen.dart
// WHAT IT DOES : Create / edit one announcement.
// MANAGES      : Title, body, course and pin option.
// USED BY      : faculty_announcements_screen.dart.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/announcement.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../services/my_data.dart';

/// Create or edit a course announcement. Returns the [Announcement].
class CreateAnnouncementScreen extends StatefulWidget {
  final Announcement? existing;
  CreateAnnouncementScreen({super.key, this.existing});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');

  late String? _courseId = widget.existing?.courseId;
  late bool _pinned = widget.existing?.pinned ?? false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _courseId ??= MyData.courseIds.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final course = DummyData.courseById(_courseId ?? '');
    final author = SessionService.currentUser ?? DummyData.faculty;
    final announcement = Announcement(
      id: widget.existing?.id ?? 'an${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      body: _body.text.trim(),
      authorName: author.name,
      authorRole: 'Faculty',
      courseId: _courseId,
      courseCode: course?.code,
      date: widget.existing?.date ?? DateTime.now(),
      pinned: _pinned,
    );
    Navigator.pop(context, announcement);
  }

  @override
  Widget build(BuildContext context) {
    final myCourses = DummyData.courses.where((c) => MyData.courseIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Announcement' : 'New Announcement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(18),
          children: [
            AppTextField(
              label: 'Title',
              hint: 'e.g. Midterm exam rescheduled',
              icon: Icons.title_rounded,
              controller: _title,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Message',
              hint: 'Write the announcement details...',
              controller: _body,
              maxLines: 6,
              validator: (v) => (v == null || v.trim().length < 10) ? 'Please write at least 10 characters' : null,
            ),
            SizedBox(height: 16),
            Text(
              'Course',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              decoration: InputDecoration(prefixIcon: Icon(Icons.class_rounded, size: 20)),
              items: myCourses
                  .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.code} · ${c.title}')))
                  .toList(),
              onChanged: _isEdit ? null : (v) => setState(() => _courseId = v),
            ),
            SizedBox(height: 12),
            SwitchListTile(
              value: _pinned,
              onChanged: (v) => setState(() => _pinned = v),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text('Pin to top', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Pinned announcements appear first for students'),
            ),
            SizedBox(height: 20),
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Publish Announcement',
              icon: _isEdit ? Icons.save_rounded : Icons.campaign_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
