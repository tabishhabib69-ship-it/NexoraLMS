// ===== FILE GUIDE: lib/widgets/color_util.dart
// WHAT IT DOES : Converts "#RRGGBB" text into a Color.
// MANAGES      : Colour parsing with a wine fallback.
// USED BY      : Older widgets (avatars, cards).
// ======================================================================

import 'package:flutter/material.dart';

/// Parses a "#RRGGBB" string into a [Color]. Falls back to the brand wine.
Color colorFromHex(String hex, {Color fallback = const Color(0xFF8A4A52)}) {
  try {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  } catch (_) {
    return fallback;
  }
}
