// ===== FILE GUIDE: lib/screens/student/courses/course_details_screen.dart
// WHAT IT DOES : Course workspace (PDF page 3).
// MANAGES      : Syllabus, Materials (preview, bookmark, Ask AI), Assignments, Exams and Grades tabs. Also holds shared MaterialTile, AssignmentTile and showMaterialPreview().
// USED BY      : Course list, dashboard, search, recommendations, bookmarks.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/course.dart';
import '../../../models/material.dart';
import '../../../services/academic_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../ai/uni_ai_screen.dart';
import '../assignments/assignment_detail_screen.dart';
import '../connect/chat_screen.dart';
import '../../../services/my_data.dart';

/// Course workspace (PDF page 3): hero header plus Syllabus, Materials,
/// Assignments, Exams and Grades tabs.
class CourseDetailsScreen extends StatefulWidget {
  final Course course;
  final int initialTab;

  const CourseDetailsScreen({super.key, required this.course, this.initialTab = 1});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final enrolled = MyData.courseIds.contains(c.id);
    final progress = DummyData.courseProgress[c.id];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackPill(),
                  SizedBox(height: 20),
                  Text(
                    '${c.code.replaceAll('-', ' · ')} · Semester ${c.semester}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    c.title,
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${c.facultyName} · ${c.schedule}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _HeroChip(enrolled ? 'Active Course' : 'Not enrolled', highlight: enrolled),
                      _HeroChip('${c.credits} Credit Hours'),
                      if (progress != null) _HeroChip('${(progress * 100).round()}% Done'),
                      _HeroChip('Room ${c.room}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeader(
              TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
                tabs: [
                  Tab(text: 'Syllabus'),
                  Tab(text: 'Materials'),
                  Tab(text: 'Assignments'),
                  Tab(text: 'Exams'),
                  Tab(text: 'Grades'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _SyllabusTab(course: c),
            _MaterialsTab(course: c),
            _AssignmentsTab(course: c, onChanged: () => setState(() {})),
            _ExamsTab(course: c),
            _GradesTab(course: c),
          ],
        ),
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: StadiumBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.28))),
      child: InkWell(
        customBorder: StadiumBorder(),
        onTap: () => Navigator.maybePop(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Back',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final bool highlight;

  const _HeroChip(this.label, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? Color(0xFF2EC4A0).withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? Color(0xFF2EC4A0).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? Color(0xFFBDF0E2) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
      ),
    );
  }
}

class _TabHeader extends SliverPersistentHeaderDelegate {
  final TabBar bar;

  _TabHeader(this.bar);

  @override
  double get minExtent => bar.preferredSize.height + 6;
  @override
  double get maxExtent => bar.preferredSize.height + 6;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: AppColors.surface, padding: EdgeInsets.only(top: 6), child: bar);

  @override
  bool shouldRebuild(_TabHeader old) => true;
}

// --------------------------------------------------------------- syllabus --

class _SyllabusTab extends StatelessWidget {
  final Course course;

  const _SyllabusTab({required this.course});

  @override
  Widget build(BuildContext context) {
    final topics = DummyData.syllabus[course.id] ?? const [];
    final progress = DummyData.courseProgress[course.id] ?? 0;
    final covered = (topics.length * progress).floor();
    final news = DummyData.announcements.where((a) => a.courseId == course.id).toList();
    final group = DummyData.studyGroups
        .where((g) => g.courseId == course.id && g.memberIds.contains(MyData.id))
        .firstOrNull;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EyebrowLabel('About this course'),
              SizedBox(height: 8),
              Text(course.description, style: TextStyle(height: 1.5, fontSize: 14.5, color: AppColors.textPrimary)),
            ],
          ),
        ),
        SizedBox(height: 18),
        if (topics.isEmpty)
          EmptyState(icon: Icons.list_alt_rounded, title: 'Syllabus not published', message: 'Check back later.')
        else
          SoftCard(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EyebrowLabel('Weekly outline · $covered of ${topics.length} covered'),
                SizedBox(height: 8),
                for (var i = 0; i < topics.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i < covered ? AppColors.primary : AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: i < covered
                              ? Icon(Icons.check_rounded, size: 17, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Week ${i + 1} · ${topics[i]}',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: i < covered ? AppColors.textSecondary : AppColors.textPrimary,
                              fontWeight: i == covered ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (i == covered)
                          StatusPill(
                            label: 'This week',
                            foreground: AppColors.primary,
                            background: AppColors.primarySoft,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(height: 18),
        SectionTitle('Course updates'),
        if (news.isEmpty)
          Text('No announcements for this course yet.', style: TextStyle(color: AppColors.textSecondary)),
        for (final a in news)
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: InfoBanner(
              icon: a.pinned ? Icons.push_pin_rounded : Icons.campaign_outlined,
              title: '${a.title} · ${timeAgo(a.date)}',
              text: a.body,
            ),
          ),
        if (group != null) ...[
          SizedBox(height: 8),
          SoftCard(
            onTap: () {
              final conv = MyData.conversations.where((c) => c.groupId == group.id).firstOrNull;
              if (conv != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
              }
            },
            child: Row(
              children: [
                GradientIconTile(icon: Icons.forum_outlined),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course discussion',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${group.name} · ${group.memberIds.length} members',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------- materials --

/// File-type badge: label + colours per material type.
(String, Gradient) materialBadge(LearningMaterialType t) => switch (t) {
  LearningMaterialType.pdf => ('PDF', LinearGradient(colors: [Color(0xFFE5484D), Color(0xFFC2343A)])),
  LearningMaterialType.slides => ('PPTX', LinearGradient(colors: [Color(0xFFF07A2B), Color(0xFFD35D12)])),
  LearningMaterialType.video => ('MP4', AppColors.wineGradient),
  LearningMaterialType.document => ('DOCX', LinearGradient(colors: [Color(0xFF4F7BC4), Color(0xFF345EA8)])),
  LearningMaterialType.link => ('LINK', AppColors.sandGradient),
};

class MaterialTile extends StatefulWidget {
  final LearningMaterial material;
  final VoidCallback onPreview;

  const MaterialTile({super.key, required this.material, required this.onPreview});

  @override
  State<MaterialTile> createState() => _MaterialTileState();
}

class _MaterialTileState extends State<MaterialTile> {
  @override
  Widget build(BuildContext context) {
    final m = widget.material;
    final (label, gradient) = materialBadge(m.type);
    final saved = MyData.savedMaterials.contains(m.id);
    return SoftCard(
      onTap: widget.onPreview,
      padding: EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 3),
                Text(
                  [m.size, if (m.week.isNotEmpty) m.week, 'Added ${formatShortDate(m.date)}'].join(' · '),
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: saved ? 'Remove bookmark' : 'Bookmark',
            onPressed: () =>
                setState(() => saved ? MyData.savedMaterials.remove(m.id) : MyData.savedMaterials.add(m.id)),
            icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'Quick preview',
            onPressed: widget.onPreview,
            icon: Icon(
              m.type == LearningMaterialType.video ? Icons.play_arrow_rounded : Icons.visibility_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing a material's summary (demo files have no real content).
void showMaterialPreview(BuildContext context, LearningMaterial m) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Quick Preview',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                Flexible(
                  child: Text(
                    m.title,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(18)),
              child: Text(
                m.summary.isEmpty ? m.description : m.summary,
                style: TextStyle(fontSize: 14.5, height: 1.5, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 12),
            InfoBanner(
              tone: BannerTone.warning,
              text: 'Demo material: no file is attached, so download/open is unavailable. This summary is sample content.',
            ),
            SizedBox(height: 16),
            GradientButton(
              label: 'Ask AI to Summarize',
              icon: Icons.bolt_rounded,
              onPressed: () {
                Navigator.pop(sheet);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UniAiScreen(courseId: m.courseId, initialPrompt: 'Summarize lecture'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _MaterialsTab extends StatelessWidget {
  final Course course;

  const _MaterialsTab({required this.course});

  @override
  Widget build(BuildContext context) {
    final mats = DummyData.materials.where((m) => m.courseId == course.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (mats.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No materials yet',
        message: 'Your instructor has not uploaded files.',
      );
    }
    final first = mats.firstWhere((m) => m.summary.isNotEmpty, orElse: () => mats.first);
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        for (final m in mats)
          Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: MaterialTile(material: m, onPreview: () => showMaterialPreview(context, m)),
          ),
        SizedBox(height: 4),
        SoftCard(
          color: AppColors.surfaceAlt,
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quick Preview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      first.title,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(18)),
                child: Text(
                  first.summary.isEmpty
                      ? first.description
                      : '${first.summary.split('. ').take(2).join('. ')}… '
                            'Tap "Ask AI" to get a full summary.',
                  style: TextStyle(fontSize: 14.5, height: 1.5, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: 14),
              GradientButton(
                label: 'Ask AI to Summarize',
                icon: Icons.bolt_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UniAiScreen(courseId: course.id, initialPrompt: 'Summarize lecture'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ assignments --

class _AssignmentsTab extends StatelessWidget {
  final Course course;
  final VoidCallback onChanged;

  const _AssignmentsTab({required this.course, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tasks = AcademicService.studentTasks.where((a) => a.courseId == course.id).toList();
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: 'No assignments',
        message: 'Nothing has been set yet.',
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        for (final t in tasks)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: AssignmentTile(
              assignment: t,
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: t)));
                onChanged();
              },
            ),
          ),
      ],
    );
  }
}

/// Assignment row shared by the course workspace and the Assignments screen.
class AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;
  final bool showCourse;

  const AssignmentTile({super.key, required this.assignment, required this.onTap, this.showCourse = false});

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    final course = DummyData.courseById(a.courseId);
    final (label, fg, bg) = switch (a.status) {
      SubmissionStatus.graded => (
        '${a.obtained?.toStringAsFixed(0)}/${a.totalMarks}',
        AppColors.success,
        AppColors.successSoft,
      ),
      SubmissionStatus.submitted => ('Submitted', AppColors.info, AppColors.infoSoft),
      SubmissionStatus.pending when a.isOverdue => ('Overdue', AppColors.danger, AppColors.dangerSoft),
      SubmissionStatus.pending => (AcademicService.countdown(a.due), AppColors.primary, AppColors.primarySoft),
    };
    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GradientIconTile(
            icon: a.type == TaskType.quiz ? Icons.quiz_outlined : Icons.assignment_outlined,
            gradient: a.status == SubmissionStatus.pending ? AppColors.wineGradient : AppColors.sandGradient,
            size: 46,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCourse)
                  Text(
                    course?.code ?? '',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.sand),
                  ),
                Text(
                  a.title,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 3),
                Text(
                  '${a.type == TaskType.quiz ? 'Quiz' : 'Due'} ${formatDateTime(a.due)} · ${a.totalMarks} marks',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          StatusPill(label: label, foreground: fg, background: bg),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ exams --

class _ExamsTab extends StatelessWidget {
  final Course course;

  const _ExamsTab({required this.course});

  @override
  Widget build(BuildContext context) {
    final exams = DummyData.exams.where((e) => e.courseId == course.id).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final quizzes = DummyData.assignments.where((a) => a.courseId == course.id && a.type == TaskType.quiz).toList();
    if (exams.isEmpty && quizzes.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No exams scheduled',
        message: 'Exam dates will appear here.',
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        for (final e in exams)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SoftCard(
              color: AppColors.surfaceAlt,
              outlined: true,
              child: Row(
                children: [
                  GradientIconTile(icon: Icons.calendar_month_outlined, size: 54),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '${formatDateTime(e.date)} · ${e.venue} · ${e.seat}',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: AcademicService.countdown(e.date),
                    foreground: AppColors.primary,
                    background: AppColors.primarySoft,
                  ),
                ],
              ),
            ),
          ),
        if (quizzes.isNotEmpty) ...[
          SizedBox(height: 8),
          SectionTitle('Quizzes'),
          for (final q in quizzes)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: AssignmentTile(
                assignment: q,
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: q))),
              ),
            ),
        ],
      ],
    );
  }
}

// ----------------------------------------------------------------- grades --

class _GradesTab extends StatelessWidget {
  final Course course;

  const _GradesTab({required this.course});

  @override
  Widget build(BuildContext context) {
    final items = AcademicService.gradesFor(course.id);
    final pct = AcademicService.coursePercent(course.id);
    if (items.isEmpty || pct == null) {
      return EmptyState(icon: Icons.grading_rounded, title: 'No grades yet', message: 'Graded work will appear here.');
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        SoftCard(
          child: Row(
            children: [
              ProgressRing(
                value: pct / 100,
                size: 84,
                stroke: 8,
                center: Text(
                  '${pct.round()}%',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel('Running grade'),
                    SizedBox(height: 4),
                    Text(
                      '${AcademicService.letterFor(pct)} · ${AcademicService.gradePointFor(pct).toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Text(
                      'From ${items.length} graded items · sample data',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        for (final g in items)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SoftCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.title,
                          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        '${g.obtained.toStringAsFixed(0)} / ${g.total.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GradientProgress(value: g.obtained / g.total, height: 7),
                  if (g.feedback != null) ...[
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote_rounded, size: 18, color: AppColors.sand),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            g.feedback!,
                            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
