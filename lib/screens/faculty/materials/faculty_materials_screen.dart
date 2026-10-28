// ===== FILE GUIDE: lib/screens/faculty/materials/faculty_materials_screen.dart
// WHAT IT DOES : Old materials manager.
// STATUS       : NOT USED anymore — replaced by materials/content_studio_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/material_card.dart';
import '../../../widgets/section_header.dart';
import 'upload_material_screen.dart';

/// Faculty management of learning materials: upload, view, edit, delete.
class FacultyMaterialsScreen extends StatefulWidget {
  FacultyMaterialsScreen({super.key});

  @override
  State<FacultyMaterialsScreen> createState() => _FacultyMaterialsScreenState();
}

class _FacultyMaterialsScreenState extends State<FacultyMaterialsScreen> {
  String _courseFilter = 'all';

  List<LearningMaterial> get _items => DummyData.materials
      .where((m) => DummyData.facultyCourseIds.contains(m.courseId))
      .where((m) => _courseFilter == 'all' || m.courseId == _courseFilter)
      .toList();

  void _upload() async {
    final created = await Navigator.push<LearningMaterial>(
      context,
      MaterialPageRoute(builder: (_) => UploadMaterialScreen()),
    );
    if (created != null) {
      setState(() => DummyData.materials.insert(0, created));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${created.title}" uploaded')));
      }
    }
  }

  void _edit(LearningMaterial m) async {
    final updated = await Navigator.push<LearningMaterial>(
      context,
      MaterialPageRoute(builder: (_) => UploadMaterialScreen(existing: m)),
    );
    if (updated != null) {
      setState(() {
        final index = DummyData.materials.indexWhere((x) => x.id == m.id);
        if (index != -1) DummyData.materials[index] = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Material updated')));
      }
    }
  }

  void _delete(LearningMaterial m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete material?'),
        content: Text('"${m.title}" will be removed for all students.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() => DummyData.materials.removeWhere((x) => x.id == m.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Material deleted')));
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final myCourses = DummyData.courses.where((c) => DummyData.facultyCourseIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(automaticallyImplyLeading: false, title: Text('Learning Materials')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _upload,
        icon: Icon(Icons.upload_file_rounded),
        label: Text('Upload'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18),
              children: [_chip('All', 'all'), ...myCourses.map((c) => _chip(c.code, c.id))],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.folder_off_rounded,
                    title: 'No materials yet',
                    message: 'Tap Upload to add your first learning material.',
                    actionLabel: 'Upload Material',
                    onAction: _upload,
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 90),
                    children: [
                      SectionHeader(title: '${items.length} material${items.length == 1 ? '' : 's'}'),
                      ...items.map(
                        (m) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: MaterialCard(
                            material: m,
                            onTap: () => _edit(m),
                            actions: [
                              IconButton(
                                tooltip: 'Edit',
                                icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                onPressed: () => _edit(m),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                                onPressed: () => _delete(m),
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

  Widget _chip(String label, String id) {
    final selected = _courseFilter == id;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _courseFilter = id),
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
