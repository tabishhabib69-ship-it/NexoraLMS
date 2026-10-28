// ===== FILE GUIDE: lib/screens/faculty/grading/grading_queue_screen.dart
// WHAT IT DOES : Grading queue.
// MANAGES      : Assignments with submission counts, rubric grade sheet with validation and feedback, Publish Grades (only after everything is graded, with confirmation).
// USED BY      : Faculty dashboard (Grade All, View All), course hub, profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/notification.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import 'create_assignment_screen.dart';
import 'rubric.dart';

/// Faculty grading queue: submissions per assignment, rubric grading and an
/// explicit publish step (grades are never released silently).
class GradingQueueScreen extends StatefulWidget {
  final String? initialAssignmentId;

  const GradingQueueScreen({super.key, this.initialAssignmentId});

  @override
  State<GradingQueueScreen> createState() => _GradingQueueScreenState();
}

class _GradingQueueScreenState extends State<GradingQueueScreen> {
  late String? _selected = widget.initialAssignmentId;

  List<Assignment> get _tasks {
    final me = SessionService.currentUser ?? DummyData.faculty;
    final mine = DummyData.courses.where((c) => c.facultyId == me.id).map((c) => c.id).toSet();
    return DummyData.assignments.where((a) => mine.contains(a.courseId)).toList()
      ..sort((a, b) => b.due.compareTo(a.due));
  }

  Future<void> _grade(Assignment a, String studentId) async {
    final marks = await showModalBottomSheet<(double, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _GradeSheet(assignment: a, studentId: studentId),
    );
    if (marks != null && mounted) {
      setState(() {
        DummyData.submissions[a.id]![studentId] = marks.$1;
        DummyData.publishedGrades.remove(a.id);
        if (marks.$2.isNotEmpty) DummyData.gradeFeedback['${a.id}:$studentId'] = marks.$2;
      });
      showSnack(context, 'Saved ${marks.$1.toStringAsFixed(1)}/${a.totalMarks} — not yet visible to the student');
    }
  }

  Future<void> _publish(Assignment a) async {
    final subs = DummyData.submissions[a.id] ?? const {};
    if (subs.values.any((v) => v == null)) {
      showSnack(context, 'Grade every submission before publishing.');
      return;
    }
    final ok = await confirmAction(
      context,
      title: 'Publish grades?',
      message:
          '${subs.length} student${subs.length == 1 ? '' : 's'} will see their marks and feedback for "${a.title}".',
      confirmLabel: 'Publish',
    );
    if (!ok || !mounted) return;
    setState(() => DummyData.publishedGrades.add(a.id));
    // The sample student's record lives on the assignment itself.
    final sample = subs[DummyData.student.id];
    if (sample != null) {
      a.status = SubmissionStatus.graded;
      a.obtained = sample;
      a.feedback = DummyData.gradeFeedback['${a.id}:${DummyData.student.id}'] ?? a.feedback;
    }
    // Each student is notified of their own mark only.
    for (final entry in subs.entries) {
      DummyData.notifications.insert(
        0,
        AppNotification(
          id: 'n${DateTime.now().microsecondsSinceEpoch}${entry.key}',
          type: NotificationType.assignment,
          title: 'Grade published',
          body: '${a.title}: ${entry.value!.toStringAsFixed(1)}/${a.totalMarks}',
          date: DateTime.now(),
          recipientId: entry.key,
        ),
      );
    }
    showSnack(context, 'Grades published (demo)');
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    final selected = tasks.where((t) => t.id == _selected).firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAssignmentScreen()));
          if (mounted) setState(() {});
        },
        icon: Icon(Icons.post_add_rounded),
        label: Text('New task', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 14),
            AdminPageHeader(eyebrow: 'Assessment', title: selected == null ? 'Grading Queue' : selected.title),
            SizedBox(height: 18),
            if (selected == null) ...[
              if (tasks.isEmpty)
                EmptyState(icon: Icons.grading_rounded, title: 'No assignments', message: 'Create one with New task.'),
              for (final t in tasks) Padding(padding: EdgeInsets.only(bottom: 12), child: _taskCard(t)),
            ] else
              ..._detail(selected),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(Assignment t) {
    final subs = DummyData.submissions[t.id] ?? const {};
    final ungraded = subs.values.where((v) => v == null).length;
    final published = DummyData.publishedGrades.contains(t.id);
    final course = DummyData.courseById(t.courseId);
    return SoftCard(
      onTap: () => setState(() => _selected = t.id),
      child: Row(
        children: [
          GradientIconTile(icon: t.type == TaskType.quiz ? Icons.quiz_outlined : Icons.assignment_outlined),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course?.code} · ${t.title}',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  '${subs.length} submitted of ${DummyData.rosterFor(t.courseId).length} · due ${formatShortDate(t.due)}',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (ungraded > 0)
            StatusPill(label: '$ungraded ungraded', foreground: AppColors.primary, background: AppColors.primarySoft)
          else if (published)
            StatusPill(label: 'Published', foreground: AppColors.success, background: AppColors.successSoft)
          else if (subs.isNotEmpty)
            StatusPill(label: 'Ready to publish', foreground: AppColors.warning, background: AppColors.warningSoft)
          else
            StatusPill(label: 'No submissions', foreground: AppColors.textSecondary, background: AppColors.surfaceAlt),
        ],
      ),
    );
  }

  List<Widget> _detail(Assignment a) {
    final subs = DummyData.submissions.putIfAbsent(a.id, () => {});
    final roster = DummyData.rosterFor(a.courseId);
    final published = DummyData.publishedGrades.contains(a.id);
    return [
      Row(
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selected = null),
            icon: Icon(Icons.arrow_back_rounded, size: 18),
            label: Text('All assignments'),
          ),
          Spacer(),
          StatusPill(
            label: published ? 'Published' : 'Not published',
            foreground: published ? AppColors.success : AppColors.warning,
            background: published ? AppColors.successSoft : AppColors.warningSoft,
          ),
        ],
      ),
      SizedBox(height: 8),
      for (final id in roster)
        Builder(
          builder: (_) {
            final u = DummyData.userById(id);
            final submitted = subs.containsKey(id);
            final mark = subs[id];
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SoftCard(
                padding: EdgeInsets.all(14),
                onTap: submitted ? () => _grade(a, id) : null,
                child: Row(
                  children: [
                    AdminAvatar(initials: initialsOf(u?.name ?? '?'), size: 46),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u?.name ?? id,
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            !submitted
                                ? 'Not submitted'
                                : (mark == null ? 'Submitted · tap to grade' : 'Graded · tap to edit'),
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (submitted)
                      StatusPill(
                        label: mark == null
                            ? 'Grade'
                            : '${mark.toStringAsFixed(mark % 1 == 0 ? 0 : 1)}/${a.totalMarks}',
                        foreground: mark == null ? AppColors.primary : AppColors.sandDeep,
                        background: mark == null ? AppColors.primarySoft : AppColors.mintSoft,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      SizedBox(height: 10),
      GradientButton(
        label: published ? 'Grades published' : 'Publish Grades',
        icon: Icons.send_rounded,
        onPressed: published || subs.isEmpty ? null : () => _publish(a),
      ),
    ];
  }
}

class _GradeSheet extends StatefulWidget {
  final Assignment assignment;
  final String studentId;

  const _GradeSheet({required this.assignment, required this.studentId});

  @override
  State<_GradeSheet> createState() => _GradeSheetState();
}

class _GradeSheetState extends State<_GradeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _scores;
  final _feedback = TextEditingController();

  double _max(int i) => widget.assignment.totalMarks * gradingRubric[i].$2;

  @override
  void initState() {
    super.initState();
    final existing = DummyData.submissions[widget.assignment.id]?[widget.studentId];
    _scores = [
      for (var i = 0; i < gradingRubric.length; i++)
        TextEditingController(text: existing == null ? '' : (existing * gradingRubric[i].$2).toStringAsFixed(1)),
    ];
  }

  @override
  void dispose() {
    for (final c in _scores) {
      c.dispose();
    }
    _feedback.dispose();
    super.dispose();
  }

  double get _total => _scores.fold<double>(0, (s, c) => s + (double.tryParse(c.text) ?? 0));

  @override
  Widget build(BuildContext context) {
    final u = DummyData.userById(widget.studentId);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, MediaQuery.of(context).viewInsets.bottom + 22),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Grade ${u?.name ?? ''}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '${widget.assignment.title} · rubric out of ${widget.assignment.totalMarks}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              for (var i = 0; i < gradingRubric.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _scores[i],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: gradingRubric[i].$1,
                      suffixText: '/ ${_max(i).toStringAsFixed(_max(i) % 1 == 0 ? 0 : 1)}',
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null) return 'Enter a number';
                      if (n < 0 || n > _max(i)) return 'Must be between 0 and ${_max(i).toStringAsFixed(1)}';
                      return null;
                    },
                  ),
                ),
              TextFormField(
                controller: _feedback,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Feedback for the student (optional)'),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  Spacer(),
                  Text(
                    '${_total.toStringAsFixed(1)} / ${widget.assignment.totalMarks}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GradientButton(
                label: 'Save Grade',
                onPressed: () {
                  if (_formKey.currentState!.validate()) Navigator.pop(context, (_total, _feedback.text.trim()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
