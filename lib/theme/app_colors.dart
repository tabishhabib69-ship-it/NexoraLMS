// ===== FILE GUIDE: lib/theme/app_colors.dart
// WHAT IT DOES : The colour palette (PDF wine / sand / cream).
// MANAGES      : All colour tokens for light and dark mode, gradients and card shadow.
// USED BY      : Every screen and widget.
// ======================================================================

import 'package:flutter/material.dart';

/// Central color palette for Uni-Sphere.
///
/// Deep wine / burgundy + warm sand accents on a cream background (light) or a
/// warm charcoal background (dark). Surface and text tokens are getters that
/// follow [isDark], which [ThemeController] flips when the theme changes; brand
/// gradients are identical in both modes and stay compile-time constants.
class AppColors {
  AppColors._();

  /// Whether the dark palette is active. Set only by [ThemeController].
  static bool isDark = false;

  static Color _pick(int light, int dark) => Color(isDark ? dark : light);

  // Backgrounds
  static Color get background => _pick(0xFFF1EEE8, 0xFF171314);
  static Color get surface => _pick(0xFFFFFFFF, 0xFF231E1F);
  static Color get surfaceAlt => _pick(0xFFF6F3EE, 0xFF2B2526);
  static Color get navBar => _pick(0xFFF4F0E8, 0xFF1E1A1B);

  /// Thin highlight edge used on frosted cards (white in light mode).
  static Color get cardEdge => _pick(0xFFFFFFFF, 0xFF3A3334);

  // Primary (wine)
  static Color get primary => _pick(0xFF8A4A52, 0xFFD08A94);
  static Color get primaryDark => _pick(0xFF5E3238, 0xFFE8B4BA);
  static Color get primarySoft => _pick(0xFFF4E9EA, 0xFF3A2629);
  static const Color wineDeep = Color(0xFF2E2729);

  // Accent (sand / gold) — `lavender` kept as an alias for older widgets.
  static Color get lavender => sand;
  static Color get lavenderSoft => sandSoft;
  static Color get sand => _pick(0xFFA8976B, 0xFFCDBD92);
  static Color get sandDeep => _pick(0xFF7A7050, 0xFFB9AC82);
  static Color get sandSoft => _pick(0xFFF1ECE0, 0xFF332E24);
  static Color get mintSoft => _pick(0xFFE3F6F0, 0xFF1F3530);

  // Text
  static Color get navy => _pick(0xFF2A2526, 0xFFEDE6E6);
  static Color get textPrimary => _pick(0xFF242021, 0xFFF2ECEC);
  static Color get textSecondary => _pick(0xFF6E6668, 0xFFB8AEB0);
  static Color get textMuted => _pick(0xFF8A8182, 0xFF887C7E);

  // Status
  static Color get success => _pick(0xFF3F8A68, 0xFF6CC79C);
  static Color get successSoft => _pick(0xFFE3F6EE, 0xFF1E3229);
  static Color get warning => _pick(0xFFC27C17, 0xFFE8A84A);
  static Color get warningSoft => _pick(0xFFFCF1DF, 0xFF3A2E1C);
  static Color get danger => _pick(0xFFC2454F, 0xFFE57C85);
  static Color get dangerSoft => _pick(0xFFF7E6E7, 0xFF3D2226);
  static Color get info => _pick(0xFF4F8296, 0xFF86B7CA);
  static Color get infoSoft => _pick(0xFFE6F1F4, 0xFF1F2F35);

  // Lines
  static Color get border => _pick(0xFFEAE4DA, 0xFF3A3334);
  static Color get divider => _pick(0xFFEFEAE2, 0xFF332D2E);

  // Gradients (same in both modes)
  static const LinearGradient wineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [wineDeep, Color(0xFF8C4A53)],
  );
  static const LinearGradient sandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC2B48E), Color(0xFF8E8562)],
  );
  static const LinearGradient roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB59A7C), Color(0xFF9A5560)],
  );
  static const LinearGradient progressGradient = LinearGradient(colors: [Color(0xFF9A5560), Color(0xFFB5A57C)]);
  static const LinearGradient sandBarGradient = LinearGradient(colors: [Color(0xFFCFC39E), Color(0xFFB5A57C)]);

  /// Dark hero header used on login, course and profile screens.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF262224), Color(0xFF4A2F35), Color(0xFF8C4A53)],
  );

  // Soft warm shadow used by cards.
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: isDark ? const Color(0x40000000) : const Color(0x122A2526),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
