// ===== FILE GUIDE: lib/widgets/dashboard_widgets.dart
// WHAT IT DOES : Older dashboard pieces.
// MANAGES      : Greeting header, quick action tile, menu row.
// USED BY      : Faculty student details.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'color_util.dart';
import 'user_avatar.dart';

/// Greeting header shown at the top of role dashboards.
class DashboardHeader extends StatelessWidget {
  final String name;
  final String avatarColor;
  final String subtitle;
  final List<Widget>? actions;

  DashboardHeader({
    super.key,
    required this.name,
    required this.avatarColor,
    this.subtitle = 'Welcome back',
    this.actions,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: name, colorHex: avatarColor, size: 48),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting,', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              SizedBox(height: 2),
              Text(
                name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        ...?actions,
      ],
    );
  }
}

/// Square quick-action tile used on dashboards.
class QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final String colorHex;
  final VoidCallback onTap;

  QuickAction({super.key, required this.label, required this.icon, required this.colorHex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(colorHex);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              SizedBox(height: 9),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label/value row used in profile detail sections.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable menu row (settings / management lists).
class MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? trailing;

  MenuRow({super.key, required this.icon, required this.title, this.subtitle, this.onTap, this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
