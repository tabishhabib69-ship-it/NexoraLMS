// ===== FILE GUIDE: lib/screens/faculty/students/enrollment_manager_screen.dart
// WHAT IT DOES : Enrollment Manager (PDF page 13).
// MANAGES      : Accept/decline enrollment requests, accept/decline chat requests, class roster.
// USED BY      : faculty_shell.dart (Students tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/course.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../services/attendance_service.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../student/connect/chat_screen.dart';
import '../courses/student_details_screen.dart';
import '../../../services/my_data.dart';

/// Enrollment Manager (PDF page 13) — the faculty Students tab: course
/// requests, chat requests and the class roster.
class EnrollmentManagerScreen extends StatefulWidget {
  const EnrollmentManagerScreen({super.key});

  @override
  State<EnrollmentManagerScreen> createState() => _EnrollmentManagerScreenState();
}

class _EnrollmentManagerScreenState extends State<EnrollmentManagerScreen> {
  int _tab = 0;
  late final List<Course> _courses;
  late Course _course;

  @override
  void initState() {
    super.initState();
    final me = SessionService.currentUser ?? DummyData.faculty;
    _courses = DummyData.courses.where((c) => c.facultyId == me.id).toList();
    _course = _courses.isEmpty ? DummyData.courses.first : _courses.first;
  }

  Future<void> _decide(EnrollmentRequest r, bool accept) async {
    final student = DummyData.userById(r.studentId);
    final ok = await confirmAction(
      context,
      title: accept ? 'Accept request?' : 'Decline request?',
      message: accept
          ? '${student?.name} will be enrolled in ${_course.code}.'
          : '${student?.name} will be told the request was declined.',
      confirmLabel: accept ? 'Accept' : 'Decline',
      destructive: !accept,
    );
    if (!ok || !mounted) return;
    setState(() => r.status = accept ? RequestStatus.accepted : RequestStatus.declined);
    showSnack(context, accept ? '${student?.name} enrolled (demo)' : 'Request declined');
  }

  void _acceptChat(ChatRequest r) {
    final conv = Conversation(
      id: 'cv${DateTime.now().millisecondsSinceEpoch}',
      peerId: r.studentId,
      peerName: r.studentName,
      peerRole: 'Student',
      peerColor: r.studentColor,
      lastMessage: r.message,
      lastTime: r.date,
      ownerId: MyData.id,
    );
    setState(() {
      DummyData.chatRequests.remove(r);
      DummyData.conversations.insert(0, conv);
      DummyData.messages[conv.id] = [
        ChatMessage(id: 'm${conv.id}', senderId: r.studentId, text: r.message, time: r.date, fromMe: false),
      ];
    });
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
  }

  @override
  Widget build(BuildContext context) {
    final requests = DummyData.enrollmentRequests.where((r) => r.courseId == _course.id).toList();
    final pending = requests.where((r) => r.status == RequestStatus.pending).toList();
    final accepted = requests.where((r) => r.status == RequestStatus.accepted).length;
    final chats = DummyData.chatRequests.where((r) => r.courseCode == _course.code).toList();
    final roster = DummyData.rosterFor(_course.id);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          AdminPageHeader(
            eyebrow: '${_course.code} · ${_course.title}',
            title: 'Enrollment Manager',
            actions: [
              if (_courses.length > 1)
                PopupMenuButton<Course>(
                  tooltip: 'Switch course',
                  icon: Icon(Icons.swap_horiz_rounded, color: AppColors.textPrimary),
                  onSelected: (c) => setState(() => _course = c),
                  itemBuilder: (_) => [
                    for (final c in _courses) PopupMenuItem(value: c, child: Text('${c.code} · ${c.title}')),
                  ],
                ),
            ],
          ),
          SizedBox(height: 18),
          SegmentedTabs(
            labels: ['Enrollments', 'Chat Requests · ${chats.length}', 'Roster'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          SizedBox(height: 16),
          if (_tab == 0) ...[
            StatStrip(
              items: [
                (value: '${_course.enrolledCount + accepted}', label: 'Enrolled', color: AppColors.primary),
                (value: '${pending.length}', label: 'Pending', color: AppColors.primary),
                (value: '$accepted', label: 'Accepted', color: AppColors.sand),
              ],
            ),
            SizedBox(height: 20),
            SectionTitle('Pending Applications'),
            if (pending.isEmpty)
              EmptyState(
                icon: Icons.how_to_reg_outlined,
                title: 'No pending requests',
                message: 'New requests will appear here.',
              ),
            for (final r in pending) Padding(padding: EdgeInsets.only(bottom: 14), child: _requestCard(r)),
          ] else if (_tab == 1) ...[
            if (chats.isEmpty)
              EmptyState(
                icon: Icons.mark_chat_read_outlined,
                title: 'No chat requests',
                message: 'Students can request to message you.',
              ),
            for (final r in chats)
              Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AdminAvatar(initials: initialsOf(r.studentName), size: 50),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.studentName,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${r.courseCode} · ${timeAgo(r.date)}',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text('"${r.message}"', style: TextStyle(height: 1.45, color: AppColors.textPrimary)),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              label: 'Accept',
                              gradient: AppColors.sandGradient,
                              onPressed: () => _acceptChat(r),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final ok = await confirmAction(
                                  context,
                                  title: 'Decline chat request?',
                                  message: 'The student will not be able to message you.',
                                  confirmLabel: 'Decline',
                                  destructive: true,
                                );
                                if (ok && mounted) setState(() => DummyData.chatRequests.remove(r));
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(56),
                                backgroundColor: AppColors.surface,
                              ),
                              child: Text('Decline'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            SectionTitle('Class roster · ${roster.length} (sample)'),
            for (final id in roster)
              Builder(
                builder: (_) {
                  final u = DummyData.userById(id);
                  if (u == null) return SizedBox.shrink();
                  final rec = DummyData.courseAttendance[_course.id]!.firstWhere((r) => r.studentId == id);
                  final s = AttendanceService.summarize(rec);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      padding: EdgeInsets.all(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailsScreen(studentId: id, courseId: _course.id),
                        ),
                      ),
                      child: Row(
                        children: [
                          AdminAvatar(
                            initials: initialsOf(u.name),
                            size: 48,
                            gradient: AdminAvatar.gradientFor(UserRole.student),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${u.studentId} · ${s.attended}/${s.totalClasses} classes',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          StatusPill(
                            label: '${s.percentage.round()}%',
                            foreground: s.status == AttendanceStatus.critical ? AppColors.danger : AppColors.sandDeep,
                            background: s.status == AttendanceStatus.critical
                                ? AppColors.dangerSoft
                                : AppColors.mintSoft,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _requestCard(EnrollmentRequest r) {
    final u = DummyData.userById(r.studentId);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminAvatar(initials: initialsOf(u?.name ?? '?'), size: 54),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u?.name ?? r.studentId,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${u?.studentId ?? ''} · GPA ${r.gpa.toStringAsFixed(1)} · Semester ${u?.semester ?? '-'}',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusPill(label: 'Pending', foreground: AppColors.primary, background: AppColors.primarySoft),
            ],
          ),
          SizedBox(height: 12),
          Text('Request: "${r.message}"', style: TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.textPrimary)),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Accept',
                  gradient: AppColors.sandGradient,
                  onPressed: () => _decide(r, true),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _decide(r, false),
                  style: OutlinedButton.styleFrom(minimumSize: Size.fromHeight(56), backgroundColor: AppColors.surface),
                  child: Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
