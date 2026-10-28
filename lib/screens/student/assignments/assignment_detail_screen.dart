// ===== FILE GUIDE: lib/screens/student/assignments/assignment_detail_screen.dart
// WHAT IT DOES : One assignment.
// MANAGES      : Instructions, deadline countdown, attach work, submit (with confirmation), result and feedback.
// USED BY      : Assignments list, dashboard, course workspace.
// ======================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../services/academic_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../../services/my_data.dart';

/// Assignment instructions, deadline countdown, attachment and submission.
///
/// Submissions are stored in the local demo data only — nothing is uploaded.
class AssignmentDetailScreen extends StatefulWidget {
  final Assignment assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  String? _attachment;
  bool _submitting = false;

  Assignment get a => widget.assignment;

  Future<void> _pickAttachment() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file != null) setState(() => _attachment = file.name);
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open the photo picker on this device.');
    }
  }

  Future<void> _submit() async {
    if (_attachment == null) {
      showSnack(context, 'Attach your work before submitting.');
      return;
    }
    final ok = await confirmAction(
      context,
      title: 'Submit assignment?',
      message: 'Submit "$_attachment" for ${a.title}? You can resubmit until the deadline.',
      confirmLabel: 'Submit',
    );
    if (!ok || !mounted) return;
    setState(() => _submitting = true);
    await Future.delayed(Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      MyData.submit(a, _attachment!);
    });
    showSnack(context, 'Submission saved (demo — stored on this device only).');
  }

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(a.courseId);
    final canSubmit =
        a.type == TaskType.assignment && a.status != SubmissionStatus.graded && !a.due.isBefore(DateTime.now());
    final (statusLabel, fg, bg) = switch (a.status) {
      SubmissionStatus.graded => ('Graded', AppColors.success, AppColors.successSoft),
      SubmissionStatus.submitted => ('Submitted', AppColors.info, AppColors.infoSoft),
      SubmissionStatus.pending when a.isOverdue => ('Overdue', AppColors.danger, AppColors.dangerSoft),
      SubmissionStatus.pending => ('Pending', AppColors.warning, AppColors.warningSoft),
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: '${course?.code} · ${course?.title}', title: a.title),
            SizedBox(height: 18),
            SoftCard(
              gradient: AppColors.wineGradient,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EyebrowLabel(a.type == TaskType.quiz ? 'Quiz time' : 'Deadline', color: Color(0xFFD9CFCF)),
                        SizedBox(height: 6),
                        Text(
                          formatDateTime(a.due),
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text('${a.totalMarks} marks', style: TextStyle(color: Color(0xFFCFC39E), fontSize: 13.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AcademicService.countdown(a.due),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: EyebrowLabel('Instructions')),
                      StatusPill(label: statusLabel, foreground: fg, background: bg),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(a.instructions, style: TextStyle(fontSize: 15, height: 1.55, color: AppColors.textPrimary)),
                ],
              ),
            ),
            SizedBox(height: 16),

            if (a.status == SubmissionStatus.graded) ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel('Result'),
                    SizedBox(height: 8),
                    Text(
                      '${a.obtained?.toStringAsFixed(0)} / ${a.totalMarks}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    SizedBox(height: 8),
                    GradientProgress(value: (a.obtained ?? 0) / a.totalMarks),
                    if (a.feedback != null) ...[
                      SizedBox(height: 14),
                      InfoBanner(icon: Icons.rate_review_outlined, title: 'Instructor feedback', text: a.feedback!),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            if (a.submittedAt != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: InfoBanner(
                  tone: BannerTone.success,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Submitted ${formatDateTime(a.submittedAt!)}',
                  text: a.attachmentName ?? 'Attachment',
                ),
              ),

            if (a.type == TaskType.quiz)
              InfoBanner(text: 'This quiz is taken in class. Your score will appear here once graded.')
            else if (canSubmit) ...[
              SoftCard(
                onTap: _pickAttachment,
                color: AppColors.surfaceAlt,
                outlined: true,
                child: Row(
                  children: [
                    GradientIconTile(
                      icon: _attachment == null ? Icons.attach_file_rounded : Icons.insert_drive_file_outlined,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _attachment ?? 'Attach your work',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          Text(
                            _attachment == null ? 'Photo or scan of your solution' : 'Tap to change',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (_attachment != null)
                      IconButton(
                        tooltip: 'Remove attachment',
                        onPressed: () => setState(() => _attachment = null),
                        icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              GradientButton(
                label: a.status == SubmissionStatus.submitted ? 'Resubmit' : 'Submit Assignment',
                icon: Icons.upload_rounded,
                loading: _submitting,
                onPressed: _submit,
              ),
              SizedBox(height: 10),
              Text(
                'Demo: the file stays on this device; nothing is uploaded to a server.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ] else if (a.isOverdue)
              InfoBanner(
                tone: BannerTone.danger,
                text:
                    'The deadline has passed. Contact ${course?.facultyName ?? 'your instructor'} about late submission.',
              ),
          ],
        ),
      ),
    );
  }
}
