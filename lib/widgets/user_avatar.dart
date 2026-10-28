// ===== FILE GUIDE: lib/widgets/user_avatar.dart
// WHAT IT DOES : Older circular initials avatar.
// MANAGES      : Initials on a tinted circle.
// USED BY      : Older faculty/admin screens, edit profile.
// ======================================================================

import 'package:flutter/material.dart';

import 'color_util.dart';

/// Circular avatar showing a user's initials over their accent colour.
class UserAvatar extends StatelessWidget {
  final String name;
  final String colorHex;
  final double size;
  final double fontSize;

  UserAvatar({super.key, required this.name, required this.colorHex, this.size = 46, this.fontSize = 16});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(colorHex);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
    );
  }
}
