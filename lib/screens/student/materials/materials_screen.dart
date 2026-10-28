// ===== FILE GUIDE: lib/screens/student/materials/materials_screen.dart
// WHAT IT DOES : Old materials list.
// STATUS       : NOT USED anymore — replaced by the Materials tab in course_details_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/material_card.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/section_header.dart';
import 'material_details_screen.dart';

/// Student view of all learning materials across enrolled courses.
class MaterialsScreen extends StatefulWidget {
  MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String _query = '';
  String _filterCourse = 'all';

  List get _items => DummyData.materials.where((m) {
    final inCourse = DummyData.studentCourseIds.contains(m.courseId);
    final matchesFilter = _filterCourse == 'all' || m.courseId == _filterCourse;
    final matchesQuery = m.title.toLowerCase().contains(_query.toLowerCase());
    return inCourse && matchesFilter && matchesQuery;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final enrolled = DummyData.courses.where((c) => DummyData.studentCourseIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Learning Materials')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: SearchField(hint: 'Search materials...', onChanged: (v) => setState(() => _query = v)),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18),
              children: [_courseChip('All', 'all'), ...enrolled.map((c) => _courseChip(c.code, c.id))],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No materials found',
                    message: 'Try a different search or course filter.',
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 24),
                    children: [
                      SectionHeader(title: '${items.length} material${items.length == 1 ? '' : 's'}'),
                      ...items.map(
                        (m) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: MaterialCard(
                            material: m,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MaterialDetailsScreen(materialId: m.id)),
                            ),
                            actions: [
                              IconButton(
                                tooltip: 'Download',
                                icon: Icon(Icons.download_rounded, color: AppColors.primary),
                                onPressed: () =>
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text('Downloading "${m.title}"...'))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _courseChip(String label, String id) {
    final selected = _filterCourse == id;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filterCourse = id),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
