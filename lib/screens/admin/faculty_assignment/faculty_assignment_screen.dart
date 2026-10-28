// ===== FILE GUIDE: lib/screens/admin/faculty_assignment/faculty_assignment_screen.dart
// WHAT IT DOES : Assign teachers to courses.
// MANAGES      : Pick a course and a faculty member; view current assignments.
// USED BY      : Admin dashboard, admin settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/user_avatar.dart';

/// Admin assigns courses to faculty and reviews existing assignments.
class FacultyAssignmentScreen extends StatefulWidget {
  FacultyAssignmentScreen({super.key});

  @override
  State<FacultyAssignmentScreen> createState() => _FacultyAssignmentScreenState();
}

class _FacultyAssignmentScreenState extends State<FacultyAssignmentScreen> {
  String? _selectedFacultyId;
  String? _selectedCourseId;

  List<AppUser> get _faculty => DummyData.users.where((u) => u.role == UserRole.faculty).toList();

  List<Course> get _courses => DummyData.courses;

  void _assign() {
    if (_selectedFacultyId == null || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select both a faculty member and a course')));
      return;
    }
    final faculty = DummyData.userById(_selectedFacultyId!)!;
    setState(() {
      final index = DummyData.courses.indexWhere((c) => c.id == _selectedCourseId);
      if (index != -1) {
        DummyData.courses[index] = DummyData.courses[index].copyWith(facultyId: faculty.id, facultyName: faculty.name);
      }
      _selectedFacultyId = null;
      _selectedCourseId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course assigned to ${faculty.name}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Faculty Assignment')),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          SectionHeader(title: 'New Assignment'),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select faculty',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFacultyId,
                  hint: Text('Choose a faculty member'),
                  decoration: InputDecoration(prefixIcon: Icon(Icons.person_rounded, size: 20)),
                  items: _faculty
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFacultyId = v),
                ),
                SizedBox(height: 16),
                Text(
                  'Select course',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourseId,
                  hint: Text('Choose a course'),
                  decoration: InputDecoration(prefixIcon: Icon(Icons.menu_book_rounded, size: 20)),
                  items: _courses
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.code} · ${c.title}', overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCourseId = v),
                ),
                SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _assign,
                  icon: Icon(Icons.assignment_ind_rounded),
                  label: Text('Assign Course'),
                  style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Group assigned courses by faculty
          SectionHeader(title: 'Current Assignments'),
          ..._faculty.map((f) {
            final teaching = _courses.where((c) => c.facultyId == f.id).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(name: f.name, colorHex: f.avatarColor, size: 42, fontSize: 15),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                f.designation ?? 'Faculty',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${teaching.length} course${teaching.length == 1 ? '' : 's'}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                    if (teaching.isNotEmpty) ...[
                      SizedBox(height: 12),
                      ...teaching.map(
                        (c) => Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right_rounded, color: AppColors.textMuted),
                              Expanded(
                                child: Text(
                                  '${c.code} · ${c.title}',
                                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
