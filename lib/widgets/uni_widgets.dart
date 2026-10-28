// ===== FILE GUIDE: lib/widgets/uni_widgets.dart
// WHAT IT DOES : More shared design pieces.
// MANAGES      : Bottom nav with centre button, back button, search box, filter pills, section title, demo tag, info banner, progress ring, line chart, week strip, initials avatar, gradient button, confirmAction() dialog and showSnack().
// USED BY      : Almost every screen.
// ======================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Shared Uni-Sphere components used across the student, faculty and admin
/// experiences (see also ui_kit.dart).

// ------------------------------------------------------------ navigation --

class UniNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const UniNavItem(this.icon, this.activeIcon, this.label);
}

/// Cream bottom bar with labelled items and an optional raised centre action.
class UniBottomNav extends StatelessWidget {
  final List<UniNavItem> items;
  final int index;
  final ValueChanged<int> onTap;
  final IconData? centerIcon;
  final String? centerLabel;
  final VoidCallback? onCenter;

  const UniBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
    this.centerIcon,
    this.centerLabel,
    this.onCenter,
  });

  Widget _item(int i) {
    final selected = i == index;
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: items[i].label,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => onTap(i),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? items[i].activeIcon : items[i].icon, size: 26, color: color),
              SizedBox(height: 4),
              Text(
                items[i].label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final half = items.length ~/ 2;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.cardEdge, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (centerIcon != null && i == half)
                  Expanded(
                    child: Center(
                      child: Semantics(
                        button: true,
                        label: centerLabel ?? 'Quick actions',
                        child: GestureDetector(
                          onTap: onCenter,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: AppColors.wineGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Color(0x402E2729), blurRadius: 16, offset: Offset(0, 6))],
                            ),
                            child: Icon(centerIcon, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                _item(i),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Round back button used on pushed screens with custom headers.
class CircleBackButton extends StatelessWidget {
  final bool onDark;

  const CircleBackButton({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onDark ? Colors.white.withValues(alpha: 0.14) : AppColors.surface,
      shape: CircleBorder(side: BorderSide(color: onDark ? Colors.white.withValues(alpha: 0.25) : AppColors.border)),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () => Navigator.maybePop(context),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: onDark ? Colors.white : AppColors.textPrimary,
            semanticLabel: 'Back',
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- inputs --

/// White rounded search box with the soft shadow.
class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? trailing;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchBox({
    super.key,
    required this.hint,
    required this.onChanged,
    this.trailing,
    this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: trailing == null ? 4 : 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(Icons.search_rounded, size: 24, color: AppColors.sand),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Horizontal scrolling filter chips; the selected chip uses the wine gradient.
class FilterPills extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final EdgeInsets padding;

  const FilterPills({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = i == index;
          return Semantics(
            selected: selected,
            button: true,
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.wineGradient : null,
                  color: selected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(23),
                  border: selected ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------- display --

/// Section title row with an optional action link ("See all").
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionTitle(this.title, {super.key, this.action, this.onAction, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          ?trailing,
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary, minimumSize: Size(48, 40)),
              child: Text(action!, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// Small "DEMO DATA" marker for sample metrics.
class DemoTag extends StatelessWidget {
  final String label;

  const DemoTag({super.key, this.label = 'DEMO DATA'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, letterSpacing: 0.6, fontWeight: FontWeight.w800, color: AppColors.warning),
      ),
    );
  }
}

enum BannerTone { info, success, warning, danger }

/// Rounded inline message with an icon (tips, demo notices, warnings).
class InfoBanner extends StatelessWidget {
  final String text;
  final String? title;
  final IconData icon;
  final BannerTone tone;

  const InfoBanner({
    super.key,
    required this.text,
    this.title,
    this.icon = Icons.info_outline_rounded,
    this.tone = BannerTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (tone) {
      BannerTone.info => (AppColors.info, AppColors.infoSoft),
      BannerTone.success => (AppColors.success, AppColors.successSoft),
      BannerTone.warning => (AppColors.warning, AppColors.warningSoft),
      BannerTone.danger => (AppColors.danger, AppColors.dangerSoft),
    };
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      title!,
                      style: TextStyle(fontWeight: FontWeight.w800, color: fg, fontSize: 13.5),
                    ),
                  ),
                Text(text, style: TextStyle(fontSize: 13, height: 1.35, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular progress ring with the wine → sand gradient and a centre label.
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final Widget? center;
  final Color? trackColor;

  const ProgressRing({super.key, required this.value, this.size = 56, this.stroke = 6, this.center, this.trackColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0.0, 1.0), stroke, trackColor ?? AppColors.divider),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color track;

  _RingPainter(this.value, this.stroke, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (value <= 0) return;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [Color(0xFF9A5560), Color(0xFFC2B48E), Color(0xFF9A5560)],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.track != track;
}

/// Simple line chart (e.g. GPA per term) with dots and value labels.
class MiniLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double min;
  final double max;
  final double height;

  const MiniLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.min,
    required this.max,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Chart: ${[for (var i = 0; i < values.length; i++) '${labels[i]} ${values[i].toStringAsFixed(2)}'].join(', ')}',
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LinePainter(
            values,
            labels,
            min,
            max,
            AppColors.primary,
            AppColors.textSecondary,
            AppColors.divider,
            AppColors.surface,
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double min;
  final double max;
  final Color line;
  final Color text;
  final Color grid;
  final Color dotFill;

  _LinePainter(this.values, this.labels, this.min, this.max, this.line, this.text, this.grid, this.dotFill);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const top = 22.0, bottom = 24.0, side = 18.0;
    final h = size.height - top - bottom;
    final w = size.width - side * 2;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = top + h * i / 2;
      canvas.drawLine(Offset(side, y), Offset(size.width - side, y), gridPaint);
    }
    Offset pointAt(int i) {
      final x = values.length == 1 ? side + w / 2 : side + w * i / (values.length - 1);
      final y = top + h * (1 - (values[i] - min) / (max - min));
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    final area = Path.from(path)
      ..lineTo(pointAt(values.length - 1).dx, top + h)
      ..lineTo(pointAt(0).dx, top + h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.22), line.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, top, size.width, h)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < values.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 5.5, Paint()..color = dotFill);
      canvas.drawCircle(
        p,
        5.5,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      _text(canvas, values[i].toStringAsFixed(2), Offset(p.dx, p.dy - 18), FontWeight.w800, line);
      _text(canvas, labels[i], Offset(p.dx, size.height - 16), FontWeight.w600, text);
    }
  }

  void _text(Canvas canvas, String s, Offset center, FontWeight weight, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontSize: 11.5, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values || old.line != line;
}

/// Mon–Sun week strip with the selected day highlighted (dashboard, timetable).
class WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final bool showWeekdayLabels;

  const WeekStrip({super.key, required this.selected, required this.onSelect, this.showWeekdayLabels = true});

  static const _letters = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(selected.year, selected.month, selected.day).subtract(Duration(days: selected.weekday - 1));
    final now = DateTime.now();
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Builder(
            builder: (_) {
              final day = monday.add(Duration(days: i));
              final isSel = day.day == selected.day && day.month == selected.month;
              final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
              final weekend = i >= 5;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSel,
                  label: '${_letters[i]} ${day.day}${isToday ? ', today' : ''}',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => onSelect(day),
                    child: Column(
                      children: [
                        if (showWeekdayLabels)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              _letters[i],
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isSel ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 180),
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: isSel ? AppColors.wineGradient : null,
                            color: isSel ? null : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: isToday && !isSel ? Border.all(color: AppColors.primary, width: 1.4) : null,
                            boxShadow: isSel
                                ? [BoxShadow(color: Color(0x332E2729), blurRadius: 12, offset: Offset(0, 5))]
                                : null,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? Colors.white
                                  : weekend
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Circular gradient avatar with initials (feed, chat).
class InitialsCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Gradient gradient;
  final Color? statusDot;

  const InitialsCircle({
    super.key,
    required this.initials,
    this.size = 50,
    this.gradient = AppColors.wineGradient,
    this.statusDot,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
            child: Text(
              initials,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.34),
            ),
          ),
          if (statusDot != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: statusDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Initials of a display name ("Dr. Sarah Khan" → "SK").
String initialsOf(String name) {
  final parts = name.replaceAll(RegExp(r'^(Dr|Prof|Mr|Ms|Mrs)\.?\s+'), '').trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

// ---------------------------------------------------------------- dialogs --

/// Confirmation dialog for sensitive actions; resolves to true on confirm.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? AppColors.danger : AppTheme.buttonColor,
            minimumSize: Size(0, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Full-width wine gradient call-to-action button.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.gradient = AppColors.wineGradient,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Color(0x332E2729), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), SizedBox(width: 8)],
                        Text(
                          label,
                          style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
