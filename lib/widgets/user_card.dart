// ===== FILE GUIDE: lib/widgets/user_card.dart
// WHAT IT DOES : Old user row.
// STATUS       : NOT USED anymore — replaced by the user rows in user_management_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_colors.dart';
import 'user_avatar.dart';

/// Generic user row used in student lists, faculty lists and admin user mgmt.
class UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitleOverride;

  UserCard({super.key, required this.user, this.onTap, this.trailing, this.subtitleOverride});

  String get _subtitle {
    if (subtitleOverride != null) return subtitleOverride!;
    switch (user.role) {
      case UserRole.student:
        final parts = <String>[];
        if (user.studentId != null) parts.add(user.studentId!);
        if (user.semester != null) parts.add('Sem ${user.semester}');
        if (user.department != null) parts.add(user.department!);
        return parts.join(' · ');
      case UserRole.faculty:
        return [
          if (user.designation != null) user.designation!,
          if (user.department != null) user.department!,
        ].join(' · ');
      case UserRole.admin:
        return user.department ?? 'Administration';
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
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              UserAvatar(name: user.name, colorHex: user.avatarColor, size: 46),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: 6),
                        _roleChip(),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip() {
    Color c;
    switch (user.role) {
      case UserRole.student:
        c = AppColors.primary;
        break;
      case UserRole.faculty:
        c = AppColors.lavender;
        break;
      case UserRole.admin:
        c = AppColors.navy;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(
        user.role.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
