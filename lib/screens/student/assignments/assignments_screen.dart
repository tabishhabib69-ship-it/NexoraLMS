// ===== FILE GUIDE: lib/screens/student/assignments/assignments_screen.dart
// WHAT IT DOES : All assignments and quizzes.
// MANAGES      : Upcoming / Overdue / Submitted / Graded filters and counts.
// USED BY      : Dashboard, + quick actions.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../models/academics.dart';
import '../../../services/academic_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../courses/course_details_screen.dart';
import 'assignment_detail_screen.dart';

/// All assignments and quizzes across courses, with submission tracking.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _filter = 0;
  static const _labels = ['Upcoming', 'Overdue', 'Submitted', 'Graded'];

  List<Assignment> get _items {
    final all = AcademicService.studentTasks;
    return switch (_filter) {
      1 => all.where((a) => a.isOverdue).toList(),
      2 => all.where((a) => a.status == SubmissionStatus.submitted).toList(),
      3 => all.where((a) => a.status == SubmissionStatus.graded).toList(),
      _ => all.where((a) => a.status == SubmissionStatus.pending && !a.isOverdue).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final all = AcademicService.studentTasks;
    final pending = all.where((a) => a.status == SubmissionStatus.pending && !a.isOverdue).length;
    final overdue = all.where((a) => a.isOverdue).length;
    final done = all.where((a) => a.status != SubmissionStatus.pending).length;
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: 'Submission tracker', title: 'Assignments'),
            SizedBox(height: 18),
            StatStrip(
              items: [
                (value: '$pending', label: 'Due', color: AppColors.primary),
                (value: '$overdue', label: 'Overdue', color: AppColors.danger),
                (value: '$done', label: 'Done', color: AppColors.sand),
              ],
            ),
            SizedBox(height: 16),
            FilterPills(
              labels: _labels,
              index: _filter,
              padding: EdgeInsets.zero,
              onChanged: (i) => setState(() => _filter = i),
            ),
            SizedBox(height: 16),
            if (items.isEmpty)
              EmptyState(
                icon: Icons.task_alt_rounded,
                title: 'Nothing here',
                message: _filter == 1 ? 'No overdue work — great job.' : 'No ${_labels[_filter].toLowerCase()} items.',
              ),
            for (final a in items)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: AssignmentTile(
                  assignment: a,
                  showCourse: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: a)),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
