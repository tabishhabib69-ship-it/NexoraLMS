// ===== FILE GUIDE: lib/widgets/profile_header.dart
// WHAT IT DOES : Older gradient profile header.
// MANAGES      : Avatar, name and subtitle block.
// USED BY      : Faculty student details.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_colors.dart';
import 'user_avatar.dart';

/// Gradient header used at the top of profile screens.
class ProfileHeader extends StatelessWidget {
  final AppUser user;
  final List<String> chips;
  final VoidCallback? onEdit;

  ProfileHeader({super.key, required this.user, this.chips = const [], this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.lavender],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [if (onEdit != null) _circleBtn(Icons.edit_rounded, onEdit!)],
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
            ),
            child: UserAvatar(name: user.name, colorHex: user.avatarColor, size: 84, fontSize: 30),
          ),
          SizedBox(height: 12),
          Text(
            user.name,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            _roleLine(),
            style: TextStyle(fontSize: 13.5, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
          ),
          if (chips.isNotEmpty) ...[
            SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips
                  .map(
                    (c) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _roleLine() {
    switch (user.role) {
      case UserRole.student:
        return [if (user.program != null) user.program!, if (user.studentId != null) user.studentId!].join(' · ');
      case UserRole.faculty:
        return [
          if (user.designation != null) user.designation!,
          if (user.department != null) user.department!,
        ].join(' · ');
      case UserRole.admin:
        return user.designation ?? 'Administration';
    }
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}
