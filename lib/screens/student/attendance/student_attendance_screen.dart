// ===== FILE GUIDE: lib/screens/student/attendance/student_attendance_screen.dart
// WHAT IT DOES : Performance screen (PDF page 4).
// MANAGES      : Attendance ring and safe/warning/critical zone, subject breakdown, GPA trend chart, attendance maths, AI study tip.
// USED BY      : Dashboard (Attendance), AI insights.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/attendance.dart';
import '../../../services/academic_service.dart';
import '../../../services/attendance_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../ai/uni_ai_screen.dart';
import '../../../services/my_data.dart';

/// Attendance & performance analytics (PDF page 4).
class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = MyData.attendance;
    if (records.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              AdminPageHeader(
                eyebrow: 'Attendance & results',
                title: 'Performance',
                actions: [CircleIconButton(icon: Icons.close_rounded, onTap: () => Navigator.maybePop(context))],
              ),
              SizedBox(height: 40),
              EmptyState(
                icon: Icons.insights_outlined,
                title: 'No records yet',
                message: 'Attendance and marks appear here once your classes start being recorded.',
              ),
            ],
          ),
        ),
      );
    }
    final overall = AttendanceService.aggregate(records);
    final term = DummyData.semesters.firstWhere((s) => s.isActive).name;
    final projected = AcademicService.projectedTermGpa;
    final atRisk = records
        .map((r) => (r, AttendanceService.summarize(r)))
        .where((e) => e.$2.status == AttendanceStatus.critical)
        .toList();
    final lowMarks = AcademicService.studentCourses
        .where((c) => (AcademicService.coursePercent(c.id) ?? 100) < 70)
        .toList();

    final (zoneLabel, zoneFg, zoneBg) = switch (overall.status) {
      AttendanceStatus.good => ('SAFE ZONE', AppColors.sand, AppColors.mintSoft),
      AttendanceStatus.warning => ('WARNING', AppColors.warning, AppColors.warningSoft),
      AttendanceStatus.critical => ('CRITICAL', AppColors.danger, AppColors.dangerSoft),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            AdminPageHeader(
              eyebrow: 'Semester ${MyData.user.semester ?? '-'} · $term',
              title: 'Performance',
              actions: [CircleIconButton(icon: Icons.close_rounded, onTap: () => Navigator.maybePop(context))],
            ),
            SizedBox(height: 20),

            // Attendance overview
            SoftCard(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: EyebrowLabel('Attendance overview')),
                      DemoTag(label: 'SAMPLE'),
                    ],
                  ),
                  SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (_, box) {
                      final ring = (box.maxWidth * 0.46).clamp(120.0, 180.0);
                      return Row(
                        children: [
                          ProgressRing(
                            value: overall.percentage / 100,
                            size: ring,
                            stroke: 16,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${overall.percentage.round()}%',
                                  style: TextStyle(
                                    fontSize: ring * 0.22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text('Attended', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Present', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                Text(
                                  '${overall.attended} / ${overall.totalClasses}',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.sand),
                                ),
                                Divider(height: 22),
                                Text('Absent', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                Text(
                                  '${overall.missed} classes',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: zoneBg, borderRadius: BorderRadius.circular(14)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        zoneLabel,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: zoneFg,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        'Min ${AttendanceService.requiredPercent}% required',
                                        style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Subject breakdown
            SectionTitle('Subject Breakdown'),
            for (final r in records)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _SubjectCard(courseId: r.courseId),
              ),
            SizedBox(height: 14),

            // GPA trend
            SectionTitle('GPA Trend'),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CGPA ${AcademicService.cgpa.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      if (projected != null)
                        StatusPill(
                          label: 'This term ≈ ${projected.toStringAsFixed(2)}',
                          foreground: AppColors.primary,
                          background: AppColors.primarySoft,
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Completed terms (sample records). "This term" is projected from marks so far.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 12),
                  MiniLineChart(
                    values: [for (final t in MyData.termResults) t.gpa],
                    labels: [for (final t in MyData.termResults) t.term],
                    min: 2.5,
                    max: 4.0,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // How the numbers are calculated
            SectionTitle('Attendance math'),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance % = attended ÷ classes held × 100',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 10),
                  for (final r in records) ...[
                    Builder(
                      builder: (_) {
                        final s = AttendanceService.summarize(r);
                        final c = DummyData.courseById(r.courseId);
                        final text = s.status == AttendanceStatus.critical
                            ? 'Attend the next ${s.neededToReach} classes in a row to reach 75% '
                                  '(${s.attended}+${s.neededToReach}) ÷ (${s.totalClasses}+${s.neededToReach}).'
                            : 'Can miss ${s.remainingAllowed} more and stay ≥ 75%.';
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '• ${c?.code}: ${s.attended}/${s.totalClasses} = ${s.percentage.toStringAsFixed(1)}%. $text',
                            style: TextStyle(fontSize: 13.5, height: 1.45, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // AI study tip
            SoftCard(
              color: AppColors.surfaceAlt,
              outlined: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UniAiScreen(initialPrompt: 'Make study plan')),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientIconTile(icon: Icons.layers_outlined),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI STUDY TIP',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.4),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _tip(atRisk, lowMarks.map((c) => c.title).toList()),
                          style: TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap to build a study plan with Uni-AI',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _tip(List<(AttendanceRecord, AttendanceSummary)> atRisk, List<String> lowMarks) {
    final parts = <String>[];
    for (final e in atRisk) {
      final c = DummyData.courseById(e.$1.courseId);
      parts.add(
        'Your ${c?.title} attendance is at risk. Attend the next ${e.$2.neededToReach} lectures to get back above 75%.',
      );
    }
    if (lowMarks.isNotEmpty) {
      parts.add('Marks in ${lowMarks.join(' and ')} are below 70% — review graded feedback first.');
    }
    final exam = AcademicService.upcomingExams.firstOrNull;
    if (exam != null) parts.add('Next exam: ${exam.title} (${AcademicService.countdown(exam.date).toLowerCase()}).');
    return parts.isEmpty ? 'You are on track in every course. Keep your current routine!' : parts.join(' ');
  }
}

class _SubjectCard extends StatelessWidget {
  final String courseId;

  const _SubjectCard({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final c = DummyData.courseById(courseId);
    final rec = MyData.attendance.firstWhere((r) => r.courseId == courseId);
    final s = AttendanceService.summarize(rec);
    final pct = AcademicService.coursePercent(courseId);
    final items = AcademicService.gradesFor(courseId);
    final got = items.fold<double>(0, (a, g) => a + g.obtained);
    final total = items.fold<double>(0, (a, g) => a + g.total);
    final good = s.status == AttendanceStatus.good;
    final color = switch (s.status) {
      AttendanceStatus.good => AppColors.sand,
      AttendanceStatus.warning => AppColors.warning,
      AttendanceStatus.critical => AppColors.primary,
    };
    return SoftCard(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c?.title ?? courseId,
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              if (pct != null)
                Text(
                  '${AcademicService.letterFor(pct)} · ${AcademicService.gradePointFor(pct).toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                ),
            ],
          ),
          SizedBox(height: 10),
          GradientProgress(
            value: s.percentage / 100,
            gradient: good ? AppColors.sandBarGradient : AppColors.progressGradient,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${s.percentage.toStringAsFixed(s.percentage % 1 == 0 ? 0 : 1)}% attendance'
                  '${total > 0 ? ' · ${got.toStringAsFixed(0)}/${total.toStringAsFixed(0)} marks' : ''}',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                ),
              ),
              if (s.status != AttendanceStatus.good)
                StatusPill(
                  label: s.status.label,
                  foreground: s.status == AttendanceStatus.critical ? AppColors.danger : AppColors.warning,
                  background: s.status == AttendanceStatus.critical ? AppColors.dangerSoft : AppColors.warningSoft,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
