// ===== FILE GUIDE: lib/widgets/ui_kit.dart
// WHAT IT DOES : Shared design pieces (first made for the admin panel, now used everywhere).
// MANAGES      : Page header, SoftCard, gradient icon tile, avatar, status pill, pill button, circle icon button, segmented tabs, stat strip, progress bar, eyebrow label, nav tile, admin bottom nav.
// USED BY      : Almost every screen.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_colors.dart';

/// Building blocks for the Uni-Sphere styled admin panel.

/// Page header: small eyebrow line, big bold title and optional trailing actions.
class AdminPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<Widget> actions;

  AdminPageHeader({super.key, required this.eyebrow, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        for (final a in actions) ...[SizedBox(width: 10), a],
      ],
    );
  }
}

/// White rounded card with the soft warm shadow from the design.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final bool outlined;

  SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.gradient,
    this.color,
    this.radius = 24,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: AppColors.softShadow,
        border: outlined ? Border.all(color: AppColors.cardEdge, width: 1.4) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Rounded-square tile with a gradient fill and a white icon.
class GradientIconTile extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;

  GradientIconTile({super.key, required this.icon, this.gradient = AppColors.wineGradient, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [BoxShadow(color: Color(0x1F2E2729), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }
}

/// Rounded-square avatar with initials over a gradient (wine or sand).
class AdminAvatar extends StatelessWidget {
  final String initials;
  final Gradient gradient;
  final double size;

  AdminAvatar({super.key, required this.initials, this.gradient = AppColors.wineGradient, this.size = 52});

  /// Picks the avatar gradient for a user role, matching the design.
  static Gradient gradientFor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.wineGradient;
      case UserRole.faculty:
        return AppColors.sandGradient;
      case UserRole.admin:
        return AppColors.roseGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(size * 0.32)),
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36),
      ),
    );
  }
}

/// Small rounded status label such as STUDENT / FACULTY / Pending.
class StatusPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  StatusPill({super.key, required this.label, required this.foreground, required this.background});

  factory StatusPill.role(UserRole role) {
    switch (role) {
      case UserRole.student:
        return StatusPill(label: 'STUDENT', foreground: AppColors.primary, background: AppColors.sandSoft);
      case UserRole.faculty:
        return StatusPill(label: 'FACULTY', foreground: AppColors.sand, background: AppColors.mintSoft);
      case UserRole.admin:
        return StatusPill(label: 'STAFF', foreground: AppColors.textSecondary, background: AppColors.surfaceAlt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, letterSpacing: 0.3, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }
}

/// Pill button: filled wine gradient (primary) or soft cream (secondary).
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;

  PillButton({super.key, required this.label, required this.onPressed, this.icon, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: filled ? AppColors.wineGradient : null,
        color: filled ? null : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
        boxShadow: filled ? [BoxShadow(color: Color(0x332E2729), blurRadius: 14, offset: Offset(0, 6))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: filled ? 18 : 14, vertical: filled ? 12 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 17, color: fg), SizedBox(width: 6)],
                Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round white icon button with an optional notification dot.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  CircleIconButton({super.key, required this.icon, required this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              if (showDot)
                Positioned(
                  top: 13,
                  right: 14,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented tab bar: white track with a wine-gradient selected pill.
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  SegmentedTabs({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: i == index ? AppColors.wineGradient : null,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: i == index ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cream strip with up to four numeric stats separated by thin dividers.
class StatStrip extends StatelessWidget {
  final List<({String value, String label, Color color})> items;

  StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardEdge, width: 1.4),
        boxShadow: AppColors.softShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, color: AppColors.border),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      items[i].value,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: items[i].color),
                    ),
                    SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin rounded progress bar with the wine → sand gradient.
class GradientProgress extends StatelessWidget {
  final double value; // 0..1
  final Gradient gradient;
  final double height;

  GradientProgress({super.key, required this.value, this.gradient = AppColors.progressGradient, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.divider,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(decoration: BoxDecoration(gradient: gradient)),
        ),
      ),
    );
  }
}

/// Small uppercase label used above sections ("SYSTEM HEALTH").
class EyebrowLabel extends StatelessWidget {
  final String text;
  final Color? color;

  EyebrowLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textSecondary,
      ),
    );
  }
}

/// Navigation row inside a [SoftCard]: gradient icon, title, subtitle, chevron.
class AdminNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Gradient gradient;

  AdminNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gradient = AppColors.wineGradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            GradientIconTile(icon: icon, gradient: gradient, size: 44),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation bar from the design: cream bar, wine selected item.
class AdminBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  AdminBottomNav({super.key, required this.index, required this.onTap});

  static final _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Dashboard'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'Users'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Courses'),
    (Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Reports'),
    (Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.cardEdge, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == index ? _items[i].$2 : _items[i].$1,
                          size: 27,
                          color: i == index ? AppColors.primary : AppColors.textMuted,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _items[i].$3,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: i == index ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
