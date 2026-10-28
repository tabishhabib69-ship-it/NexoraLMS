// ===== FILE GUIDE: lib/screens/faculty/grading/create_assignment_screen.dart
// WHAT IT DOES : Create an assignment or quiz.
// MANAGES      : Course, title, instructions, marks, deadline; publishing notifies students.
// USED BY      : Faculty dashboard (New task), grading queue, course hub.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/course.dart';
import '../../../models/notification.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';

/// Create an assignment or quiz with instructions, deadline and marks.
class CreateAssignmentScreen extends StatefulWidget {
  final String? courseId;

  const CreateAssignmentScreen({super.key, this.courseId});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _instructions = TextEditingController();
  final _marks = TextEditingController(text: '20');
  late final List<Course> _courses;
  late String _courseId;
  TaskType _type = TaskType.assignment;
  DateTime _due = DateTime.now().add(Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final me = SessionService.currentUser ?? DummyData.faculty;
    _courses = DummyData.courses.where((c) => c.facultyId == me.id).toList();
    _courseId = widget.courseId ?? (_courses.isEmpty ? DummyData.courses.first.id : _courses.first.id);
  }

  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    _marks.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: now,
      lastDate: now.add(Duration(days: 150)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 23, minute: 59));
    if (t == null) return;
    setState(() => _due = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_due.isBefore(DateTime.now())) {
      showSnack(context, 'The deadline must be in the future.');
      return;
    }
    final course = DummyData.courseById(_courseId)!;
    final ok = await confirmAction(
      context,
      title: 'Publish ${_type == TaskType.quiz ? 'quiz' : 'assignment'}?',
      message:
          '"${_title.text.trim()}" will be visible to ${course.enrolledCount} students in ${course.code}, '
          'due ${formatDateTime(_due)}.',
      confirmLabel: 'Publish',
    );
    if (!ok || !mounted) return;
    final a = Assignment(
      id: 'as${DateTime.now().millisecondsSinceEpoch}',
      courseId: _courseId,
      title: _title.text.trim(),
      instructions: _instructions.text.trim(),
      due: _due,
      totalMarks: int.parse(_marks.text.trim()),
      type: _type,
    );
    DummyData.assignments.add(a);
    DummyData.submissions[a.id] = {};
    DummyData.notifications.insert(
      0,
      AppNotification(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.assignment,
        title: 'New ${_type == TaskType.quiz ? 'quiz' : 'assignment'} in ${course.code}',
        body: '${a.title} · due ${formatDateTime(a.due)}',
        date: DateTime.now(),
      ),
    );
    Navigator.pop(context, a);
    showSnack(context, 'Published to ${course.code} (demo)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(children: [CircleBackButton()]),
              SizedBox(height: 14),
              AdminPageHeader(eyebrow: 'Assessment', title: 'New Task'),
              SizedBox(height: 18),
              SegmentedTabs(
                labels: ['Assignment', 'Quiz'],
                index: _type == TaskType.assignment ? 0 : 1,
                onChanged: (i) => setState(() => _type = i == 0 ? TaskType.assignment : TaskType.quiz),
              ),
              SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _courseId,
                decoration: InputDecoration(labelText: 'Course'),
                dropdownColor: AppColors.surface,
                items: [for (final c in _courses) DropdownMenuItem(value: c.id, child: Text('${c.code} · ${c.title}'))],
                onChanged: (v) => setState(() => _courseId = v!),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().length < 4) ? 'Enter a descriptive title' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _instructions,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(labelText: 'Instructions', alignLabelWithHint: true),
                validator: (v) =>
                    (v == null || v.trim().length < 20) ? 'Instructions should be at least 20 characters' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _marks,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total marks'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 100) return 'Enter marks between 1 and 100';
                  return null;
                },
              ),
              SizedBox(height: 12),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.border),
                  ),
                  leading: Icon(Icons.event_outlined, color: AppColors.primary),
                  title: Text(
                    _type == TaskType.quiz ? 'Quiz date & time' : 'Deadline',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  subtitle: Text(
                    formatDateTime(_due),
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  trailing: Icon(Icons.edit_calendar_outlined, color: AppColors.textMuted),
                  onTap: _pickDue,
                ),
              ),
              SizedBox(height: 22),
              GradientButton(label: 'Publish', icon: Icons.send_rounded, onPressed: _publish),
            ],
          ),
        ),
      ),
    );
  }
}
