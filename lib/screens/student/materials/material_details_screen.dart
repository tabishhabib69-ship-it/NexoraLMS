// ===== FILE GUIDE: lib/screens/student/materials/material_details_screen.dart
// WHAT IT DOES : Old material detail screen.
// STATUS       : NOT USED anymore — replaced by showMaterialPreview() in course_details_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';

/// Detail / preview screen for a single learning material.
class MaterialDetailsScreen extends StatelessWidget {
  final String materialId;
  MaterialDetailsScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    final matches = DummyData.materials.where((m) => m.id == materialId);
    if (matches.isEmpty) {
      return Scaffold(
        body: EmptyState(icon: Icons.error_outline_rounded, title: 'Material not found'),
      );
    }
    final material = matches.first;
    final course = DummyData.courseById(material.courseId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Material Details')),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          // Preview placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lavenderSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_previewIcon(material.type), size: 56, color: AppColors.lavender),
                SizedBox(height: 12),
                Text(
                  'Preview · ${material.type.label}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
                SizedBox(height: 4),
                Text('Preview area (UI placeholder)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            material.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tag(Icons.class_rounded, course?.code ?? 'Course'),
              _tag(Icons.folder_rounded, material.type.label),
              _tag(Icons.sd_storage_rounded, material.size),
              _tag(Icons.calendar_today_rounded, timeAgo(material.date)),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'About this material',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(material.description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          SizedBox(height: 12),
          Text(
            '${material.downloads} students have downloaded this.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  label: 'Open',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () =>
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening preview...'))),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Download',
                  icon: Icons.download_rounded,
                  onPressed: () =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Downloading "${material.title}"...'))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _previewIcon(LearningMaterialType type) {
    switch (type) {
      case LearningMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case LearningMaterialType.slides:
        return Icons.slideshow_rounded;
      case LearningMaterialType.video:
        return Icons.play_circle_fill_rounded;
      case LearningMaterialType.document:
        return Icons.description_rounded;
      case LearningMaterialType.link:
        return Icons.link_rounded;
    }
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
