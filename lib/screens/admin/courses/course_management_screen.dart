// ===== FILE GUIDE: lib/screens/admin/courses/course_management_screen.dart
// WHAT IT DOES : Course Management.
// MANAGES      : Course stats, search, add/edit/delete courses.
// USED BY      : admin_shell.dart (Courses tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import 'add_edit_course_screen.dart';

/// Admin course management ("Admin · Catalog"): add, edit, delete and view courses.
class CourseManagementScreen extends StatefulWidget {
  CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  String _query = '';

  List<Course> get _courses => DummyData.courses.where((c) {
    final q = _query.toLowerCase();
    return c.title.toLowerCase().contains(q) ||
        c.code.toLowerCase().contains(q) ||
        c.facultyName.toLowerCase().contains(q);
  }).toList();

  void _add() async {
    final created = await Navigator.push<Course>(context, MaterialPageRoute(builder: (_) => AddEditCourseScreen()));
    if (created != null) {
      setState(() => DummyData.courses.add(created));
      _snack('Course created');
    }
  }

  void _edit(Course c) async {
    final updated = await Navigator.push<Course>(
      context,
      MaterialPageRoute(builder: (_) => AddEditCourseScreen(existing: c)),
    );
    if (updated != null) {
      setState(() {
        final index = DummyData.courses.indexWhere((x) => x.id == c.id);
        if (index != -1) DummyData.courses[index] = updated;
      });
      _snack('Course updated');
    }
  }

  void _delete(Course c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete course?'),
        content: Text('${c.code} — ${c.title} will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: Size(0, 44)),
            onPressed: () {
              setState(() => DummyData.courses.removeWhere((x) => x.id == c.id));
              Navigator.pop(context);
              _snack('Course deleted');
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final all = DummyData.courses;
    final credits = all.fold<int>(0, (sum, c) => sum + c.credits);
    final enrolled = all.fold<int>(0, (sum, c) => sum + c.enrolledCount);

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        AdminPageHeader(
          eyebrow: 'Admin · Catalog',
          title: 'Course\nManagement',
          actions: [PillButton(label: 'Add Course', icon: Icons.add_rounded, onPressed: _add)],
        ),
        SizedBox(height: 18),
        StatStrip(
          items: [
            (value: '${all.length}', label: 'Courses', color: AppColors.primary),
            (value: '$credits', label: 'Credits', color: AppColors.sand),
            (value: '$enrolled', label: 'Enrolled', color: AppColors.primary),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppColors.softShadow,
          ),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by code, title or faculty...',
              prefixIcon: Icon(Icons.search_rounded, size: 24),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
        SizedBox(height: 18),
        if (courses.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No courses',
              message: 'Add your first course to get started.',
            ),
          )
        else
          for (var i = 0; i < courses.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: _CourseRow(
                course: courses[i],
                gradient: i.isEven ? AppColors.wineGradient : AppColors.sandGradient,
                onEdit: () => _edit(courses[i]),
                onDelete: () => _delete(courses[i]),
              ),
            ),
      ],
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final Gradient gradient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  _CourseRow({required this.course, required this.gradient, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onEdit,
      padding: EdgeInsets.fromLTRB(16, 16, 6, 16),
      child: Row(
        children: [
          GradientIconTile(icon: Icons.layers_outlined, gradient: gradient, size: 52),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.code}: ${course.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  '${course.facultyName} · Sem ${course.semester}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    StatusPill(
                      label: '${course.enrolledCount} students',
                      foreground: AppColors.primary,
                      background: AppColors.primarySoft,
                    ),
                    SizedBox(width: 6),
                    StatusPill(
                      label: '${course.credits} credits',
                      foreground: AppColors.sandDeep,
                      background: AppColors.mintSoft,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            onSelected: (v) => v == 'delete' ? onDelete() : onEdit(),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Edit course')),
              PopupMenuItem(value: 'delete', child: Text('Delete course')),
            ],
          ),
        ],
      ),
    );
  }
}
