// ===== FILE GUIDE: lib/widgets/stat_card.dart
// WHAT IT DOES : Old stat tile.
// STATUS       : NOT USED anymore — replaced by StatStrip / metric cards in ui_kit.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'color_util.dart';

/// Compact statistic tile used on dashboards.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String colorHex;
  final VoidCallback? onTap;

  StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.colorHex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(colorHex);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
