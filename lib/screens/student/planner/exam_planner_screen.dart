// ===== FILE GUIDE: lib/screens/student/planner/exam_planner_screen.dart
// WHAT IT DOES : Exam study planner.
// MANAGES      : Splits each exam's syllabus into daily study tasks with checkboxes and progress.
// USED BY      : Dashboard, timetable exam card, profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../services/academic_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../ai/uni_ai_screen.dart';

/// Exam preparation planner: spreads each exam's syllabus over the days left
/// and lets the student tick off each day's topics.
class ExamPlannerScreen extends StatefulWidget {
  const ExamPlannerScreen({super.key});

  /// Completed plan steps per exam id (kept for the app session).
  static final Map<String, Set<int>> done = {};

  @override
  State<ExamPlannerScreen> createState() => _ExamPlannerScreenState();
}

class _ExamPlannerScreenState extends State<ExamPlannerScreen> {
  /// Splits syllabus topics across the days before the exam (max 7 study days,
  /// with the final day kept for revision).
  List<(DateTime, String)> _plan(Exam e) {
    final topics = DummyData.syllabus[e.courseId] ?? ['Review lecture notes'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(e.date.year, e.date.month, e.date.day);
    var days = examDay.difference(today).inDays;
    if (days < 1) return [(today, 'Light revision of key formulas and past mistakes')];
    days = days.clamp(1, 7);
    final studyDays = days > 1 ? days - 1 : 1;
    final per = (topics.length / studyDays).ceil();
    final plan = <(DateTime, String)>[];
    for (var d = 0; d < studyDays && d * per < topics.length; d++) {
      plan.add((today.add(Duration(days: d)), topics.skip(d * per).take(per).join(' · ')));
    }
    if (days > 1) plan.add((examDay.subtract(Duration(days: 1)), 'Full revision + one timed practice paper'));
    return plan;
  }

  @override
  Widget build(BuildContext context) {
    final exams = AcademicService.upcomingExams;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(
              eyebrow: 'Exam preparation',
              title: 'Study Planner',
              actions: [
                PillButton(
                  label: 'Ask AI',
                  icon: Icons.auto_awesome_rounded,
                  filled: false,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UniAiScreen(initialPrompt: 'Make study plan')),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            if (exams.isEmpty)
              EmptyState(
                icon: Icons.event_available_outlined,
                title: 'No upcoming exams',
                message: 'Nothing to plan for right now.',
              ),
            for (final e in exams) ...[
              _ExamPlanCard(
                exam: e,
                plan: _plan(e),
                done: ExamPlannerScreen.done.putIfAbsent(e.id, () => {}),
                onToggle: (i) => setState(() {
                  final set = ExamPlannerScreen.done[e.id]!;
                  set.contains(i) ? set.remove(i) : set.add(i);
                }),
              ),
              SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExamPlanCard extends StatelessWidget {
  final Exam exam;
  final List<(DateTime, String)> plan;
  final Set<int> done;
  final ValueChanged<int> onToggle;

  const _ExamPlanCard({required this.exam, required this.plan, required this.done, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(exam.courseId);
    final progress = plan.isEmpty ? 0.0 : done.length / plan.length;
    return SoftCard(
      padding: EdgeInsets.fromLTRB(18, 18, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconTile(icon: Icons.event_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${formatDateTime(exam.date)} · ${exam.venue} · ${exam.seat}',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: StatusPill(
                  label: AcademicService.countdown(exam.date),
                  foreground: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(child: GradientProgress(value: progress, height: 7)),
                SizedBox(width: 10),
                Text(
                  '${done.length}/${plan.length} days',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          for (var i = 0; i < plan.length; i++)
            CheckboxListTile(
              value: done.contains(i),
              onChanged: (_) => onToggle(i),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text(
                plan[i].$2,
                style: TextStyle(
                  fontSize: 14,
                  color: done.contains(i) ? AppColors.textMuted : AppColors.textPrimary,
                  decoration: done.contains(i) ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(formatLongDay(plan[i].$1), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          if (course != null)
            Padding(
              padding: EdgeInsets.only(right: 8, top: 4),
              child: Text(
                'Topics from the ${course.code} syllabus.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
