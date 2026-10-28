// ===== FILE GUIDE: lib/screens/faculty/materials/content_studio_screen.dart
// WHAT IT DOES : Content Studio (PDF page 12).
// MANAGES      : Add materials (pick video/image or enter document details), remove materials, grading rubric card, Publish & Notify Students (with confirmation).
// USED BY      : Faculty centre Upload button, dashboard, course hub.
// ======================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/dummy_data.dart';
import '../../../models/announcement.dart';
import '../../../models/course.dart';
import '../../../models/material.dart';
import '../../../models/notification.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../student/courses/course_details_screen.dart' show materialBadge;
import '../grading/rubric.dart';

/// Faculty Content Studio (PDF page 12): add course materials, review the
/// grading rubric and publish updates to students.
///
/// Files picked from the device are referenced locally only — nothing is
/// uploaded to a server in this demo, so no fake upload progress is shown.
class ContentStudioScreen extends StatefulWidget {
  final String? courseId;

  const ContentStudioScreen({super.key, this.courseId});

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen> {
  late List<Course> _courses;
  late Course _course;
  final Set<String> _unpublished = {};

  @override
  void initState() {
    super.initState();
    final me = SessionService.currentUser ?? DummyData.faculty;
    _courses = DummyData.courses.where((c) => c.facultyId == me.id).toList();
    if (_courses.isEmpty) _courses = [DummyData.courses.first];
    _course = _courses.firstWhere((c) => c.id == widget.courseId, orElse: () => _courses.first);
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / 1024).ceil()} KB';
  }

  static LearningMaterialType _typeFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => LearningMaterialType.pdf,
      'ppt' || 'pptx' || 'key' => LearningMaterialType.slides,
      'mp4' || 'mov' || 'webm' || 'mkv' => LearningMaterialType.video,
      _ => LearningMaterialType.document,
    };
  }

  Future<void> _browse() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.perm_media_outlined, color: AppColors.primary),
              title: Text('Pick a video or image from this device'),
              subtitle: Text('Lecture recordings, scanned notes'),
              onTap: () => Navigator.pop(sheet, 'media'),
            ),
            ListTile(
              leading: Icon(Icons.note_add_outlined, color: AppColors.primary),
              title: Text('Add document details'),
              subtitle: Text('PDF / PPTX / DOCX — file picking for documents needs a file-picker plugin'),
              onTap: () => Navigator.pop(sheet, 'details'),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'details') return _details();
    try {
      final file = await ImagePicker().pickMedia();
      if (file == null || !mounted) return;
      final size = await file.length();
      if (!mounted) return;
      await _details(fileName: file.name, size: _formatSize(size), type: _typeFor(file.name));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open the media picker on this device.');
    }
  }

  Future<void> _details({String? fileName, String? size, LearningMaterialType? type}) async {
    final m = await showModalBottomSheet<LearningMaterial>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MaterialForm(courseId: _course.id, fileName: fileName, size: size, type: type),
    );
    if (m != null && mounted) {
      setState(() {
        DummyData.materials.insert(0, m);
        _unpublished.add(m.id);
      });
      showSnack(context, 'Added "${m.title}" — publish to notify students');
    }
  }

  Future<void> _delete(LearningMaterial m) async {
    final ok = await confirmAction(
      context,
      title: 'Remove material?',
      message: '"${m.title}" will no longer be visible to students.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (ok && mounted) {
      setState(() {
        DummyData.materials.removeWhere((x) => x.id == m.id);
        _unpublished.remove(m.id);
      });
    }
  }

  Future<void> _publish() async {
    if (_unpublished.isEmpty) {
      showSnack(context, 'Nothing new to publish for ${_course.code}.');
      return;
    }
    final n = _unpublished.length;
    final ok = await confirmAction(
      context,
      title: 'Publish & notify?',
      message:
          'Post an announcement in ${_course.code} and notify ${_course.enrolledCount} enrolled students about '
          '$n new material${n == 1 ? '' : 's'}?',
      confirmLabel: 'Publish',
    );
    if (!ok || !mounted) return;
    final me = SessionService.currentUser ?? DummyData.faculty;
    setState(() {
      DummyData.announcements.insert(
        0,
        Announcement(
          id: 'an${DateTime.now().millisecondsSinceEpoch}',
          title: '$n new material${n == 1 ? '' : 's'} uploaded',
          body: 'New resources are available in the Materials tab of ${_course.code} ${_course.title}.',
          authorName: me.name,
          authorRole: 'Faculty',
          courseId: _course.id,
          courseCode: _course.code,
          date: DateTime.now(),
        ),
      );
      DummyData.notifications.insert(
        0,
        AppNotification(
          id: 'n${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.faculty,
          title: 'New material in ${_course.code}',
          body: '${me.name} uploaded $n new material${n == 1 ? '' : 's'}.',
          date: DateTime.now(),
        ),
      );
      _unpublished.clear();
    });
    showSnack(context, 'Published — students will see it in their notifications (demo).');
  }

  @override
  Widget build(BuildContext context) {
    final mats = DummyData.materials.where((m) => m.courseId == _course.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final task = DummyData.assignments.where((a) => a.courseId == _course.id).firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 14),
            AdminPageHeader(
              eyebrow: '${_course.code} · ${_course.title}',
              title: 'Content Studio',
              actions: [
                PopupMenuButton<Course>(
                  tooltip: 'Switch course',
                  icon: Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                  onSelected: (c) => setState(() => _course = c),
                  itemBuilder: (_) => [
                    for (final c in _courses) PopupMenuItem(value: c, child: Text('${c.code} · ${c.title}')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 18),
            _DashedCard(
              child: Column(
                children: [
                  GradientIconTile(icon: Icons.cloud_upload_outlined, size: 70),
                  SizedBox(height: 16),
                  Text(
                    'Upload Course Material',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Pick a file or add its details\nPDF, PPTX, MP4, DOCX supported',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  PillButton(label: 'Browse Files', onPressed: _browse),
                ],
              ),
            ),
            SizedBox(height: 22),
            SectionTitle('Uploaded Materials'),
            if (mats.isEmpty)
              EmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No materials yet',
                message: 'Add the first file above.',
              ),
            for (final m in mats)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  padding: EdgeInsets.fromLTRB(16, 14, 6, 14),
                  child: Row(
                    children: [
                      Builder(
                        builder: (_) {
                          final (label, _) = materialBadge(m.type);
                          return Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12.5),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '${m.size} · ${_unpublished.contains(m.id) ? 'Draft — not published' : 'Published ${formatShortDate(m.date)}'}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _unpublished.contains(m.id) ? AppColors.warning : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _unpublished.contains(m.id) ? AppColors.warningSoft : AppColors.mintSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _unpublished.contains(m.id) ? Icons.schedule_rounded : Icons.check_rounded,
                          size: 20,
                          color: _unpublished.contains(m.id) ? AppColors.warning : AppColors.sandDeep,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () => _delete(m),
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 10),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${task?.title ?? 'Assignment'} — Grading Rubric',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 14),
                  for (var i = 0; i < gradingRubric.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gradingRubric[i].$1,
                            style: TextStyle(fontSize: 14.5, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          '${(gradingRubric[i].$2 * 100).round()} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: i == 1 ? AppColors.sand : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    GradientProgress(
                      value: gradingRubric[i].$2 / 0.5,
                      gradient: i == 1 ? AppColors.sandBarGradient : AppColors.progressGradient,
                    ),
                    SizedBox(height: 14),
                  ],
                  GradientButton(
                    label: _unpublished.isEmpty
                        ? 'Publish & Notify Students'
                        : 'Publish ${_unpublished.length} & Notify',
                    onPressed: _publish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCard extends StatelessWidget {
  final Widget child;

  const _DashedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(AppColors.primary.withValues(alpha: 0.35)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(28),
        ),
        child: child,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;

  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(28));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _MaterialForm extends StatefulWidget {
  final String courseId;
  final String? fileName;
  final String? size;
  final LearningMaterialType? type;

  const _MaterialForm({required this.courseId, this.fileName, this.size, this.type});

  @override
  State<_MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends State<_MaterialForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.fileName?.replaceAll(RegExp(r'\.[^.]+$'), '') ?? '');
  final _week = TextEditingController();
  final _description = TextEditingController();
  late LearningMaterialType _type = widget.type ?? LearningMaterialType.pdf;

  @override
  void dispose() {
    _title.dispose();
    _week.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      LearningMaterial(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        courseId: widget.courseId,
        title: _title.text.trim(),
        description: _description.text.trim(),
        type: _type,
        size: widget.size ?? 'No file attached',
        date: DateTime.now(),
        week: _week.text.trim(),
        summary: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                widget.fileName == null ? 'Material details' : 'Selected: ${widget.fileName}',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              if (widget.size != null)
                Text(
                  '${widget.size} · stays on this device in the demo',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              SizedBox(height: 16),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Enter a title' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<LearningMaterialType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: 'Type'),
                dropdownColor: AppColors.surface,
                items: [
                  for (final t in LearningMaterialType.values.where((t) => t != LearningMaterialType.link))
                    DropdownMenuItem(value: t, child: Text('${materialBadge(t).$1} · ${t.label}')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _week,
                decoration: InputDecoration(labelText: 'Week (optional)', hintText: 'e.g. Week 7'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Short summary for students'),
                validator: (v) => (v == null || v.trim().length < 10) ? 'Add a short summary (10+ characters)' : null,
              ),
              SizedBox(height: 18),
              GradientButton(label: 'Add Material', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
