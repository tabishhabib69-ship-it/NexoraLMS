// ===== FILE GUIDE: lib/screens/admin/courses/add_edit_course_screen.dart
// WHAT IT DOES : Add or edit one course.
// MANAGES      : Course details, instructor, credits, schedule, colour.
// USED BY      : Course Management, admin dashboard (Add Course).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// Add a new course or edit an existing one. Returns the [Course].
class AddEditCourseScreen extends StatefulWidget {
  final Course? existing;
  AddEditCourseScreen({super.key, this.existing});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.existing?.code ?? '');
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _credits = TextEditingController(text: widget.existing?.credits.toString() ?? '3');
  late final _semester = TextEditingController(text: widget.existing?.semester.toString() ?? '1');
  late final _department = TextEditingController(text: widget.existing?.department ?? '');
  late final _schedule = TextEditingController(text: widget.existing?.schedule ?? '');
  late final _room = TextEditingController(text: widget.existing?.room ?? '');

  late String _facultyId = widget.existing?.facultyId ?? DummyData.faculty.id;
  late String _color = widget.existing?.color ?? '#8A4A52';

  bool get _isEdit => widget.existing != null;

  static final _colors = ['#8A4A52', '#B5A57C', '#2E2729', '#E0962A', '#5C8FA3', '#4E9B78'];

  List<AppUser> get _facultyList => DummyData.users.where((u) => u.role == UserRole.faculty).toList();

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _description.dispose();
    _credits.dispose();
    _semester.dispose();
    _department.dispose();
    _schedule.dispose();
    _room.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final faculty = _facultyList.firstWhere((f) => f.id == _facultyId, orElse: () => DummyData.faculty);
    final course = Course(
      id: widget.existing?.id ?? 'c${DateTime.now().microsecondsSinceEpoch}',
      code: _code.text.trim().toUpperCase(),
      title: _title.text.trim(),
      facultyId: faculty.id,
      facultyName: faculty.name,
      description: _description.text.trim(),
      credits: int.tryParse(_credits.text.trim()) ?? 3,
      semester: int.tryParse(_semester.text.trim()) ?? 1,
      department: _department.text.trim(),
      schedule: _schedule.text.trim().isEmpty ? 'TBA' : _schedule.text.trim(),
      room: _room.text.trim().isEmpty ? 'TBA' : _room.text.trim(),
      enrolledCount: widget.existing?.enrolledCount ?? 0,
      color: _color,
    );
    Navigator.pop(context, course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Course' : 'Add Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(18),
          children: [
            AppTextField(
              label: 'Course code',
              hint: 'e.g. CSE-201',
              icon: Icons.tag_rounded,
              controller: _code,
              enabled: !_isEdit,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Course code is required' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Course title',
              icon: Icons.title_rounded,
              controller: _title,
              validator: (v) => (v == null || v.trim().length < 3) ? 'Enter a course title' : null,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              controller: _description,
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Credits',
                    icon: Icons.star_border_rounded,
                    controller: _credits,
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null) ? 'Number' : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Semester',
                    icon: Icons.calendar_month_rounded,
                    controller: _semester,
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null) ? 'Number' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            AppTextField(label: 'Department', icon: Icons.apartment_rounded, controller: _department),
            SizedBox(height: 16),
            AppTextField(
              label: 'Schedule',
              hint: 'e.g. Sun & Tue · 10:00 AM',
              icon: Icons.schedule_rounded,
              controller: _schedule,
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Room',
              hint: 'e.g. AB-204',
              icon: Icons.meeting_room_rounded,
              controller: _room,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 16),
            Text(
              'Assigned faculty',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _facultyList.any((f) => f.id == _facultyId) ? _facultyId : _facultyList.first.id,
              decoration: InputDecoration(prefixIcon: Icon(Icons.person_rounded, size: 20)),
              items: _facultyList
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(f.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _facultyId = v ?? _facultyId),
            ),
            SizedBox(height: 18),
            Text(
              'Card color',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _colors.map((hex) {
                final selected = hex == _color;
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? AppColors.navy : Colors.transparent, width: 3),
                    ),
                    child: selected ? Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 26),
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Create Course',
              icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
