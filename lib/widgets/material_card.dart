// ===== FILE GUIDE: lib/widgets/material_card.dart
// WHAT IT DOES : Older material row.
// MANAGES      : Type icon and actions for one material.
// USED BY      : Only the old (unused) materials screens.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/material.dart';
import '../theme/app_colors.dart';
import 'time_util.dart';

/// Learning material row with a type icon and action buttons.
class MaterialCard extends StatelessWidget {
  final LearningMaterial material;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  MaterialCard({super.key, required this.material, this.onTap, this.actions});

  IconData get _icon {
    switch (material.type) {
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

  Color get _accent {
    switch (material.type) {
      case LearningMaterialType.pdf:
        return AppColors.danger;
      case LearningMaterialType.slides:
        return AppColors.warning;
      case LearningMaterialType.video:
        return AppColors.lavender;
      case LearningMaterialType.document:
        return AppColors.primary;
      case LearningMaterialType.link:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_icon, color: _accent, size: 24),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 3),
                    Text(
                      material.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        _meta(material.type.label),
                        SizedBox(width: 10),
                        _meta(material.size),
                        SizedBox(width: 10),
                        _meta('${material.downloads} downloads'),
                      ],
                    ),
                  ],
                ),
              ),
              if (actions != null) ...[SizedBox(width: 8), ...actions!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 4, color: AppColors.textMuted),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

/// Small helper to show when a material was added.
String materialDate(LearningMaterial m) => timeAgo(m.date);
