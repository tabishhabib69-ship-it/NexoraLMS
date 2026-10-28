// ===== FILE GUIDE: lib/models/lost_found.dart
// WHAT IT DOES : Data class for a Lost & Found report.
// MANAGES      : Lost/found type, item info, location, category, status (open/returned), contact preference.
// USED BY      : Lost & Found screens.
// ======================================================================

import 'dart:typed_data';

enum LostFoundType { lost, found }

extension LostFoundTypeX on LostFoundType {
  String get label => this == LostFoundType.lost ? 'Lost' : 'Found';
}

enum LostFoundStatus { open, resolved }

/// A lost or found item report.
class LostFoundItem {
  final String id;
  final LostFoundType type;
  final String title;
  final String description;
  final String location;
  final String reporterName;
  final String reporterColor;
  final String category; // e.g. "Electronics"
  final DateTime date;
  LostFoundStatus status;
  final String emoji; // simple visual marker
  final Uint8List? image;
  final String contactPreference; // e.g. "In-app message"

  LostFoundItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.reporterName,
    required this.reporterColor,
    required this.category,
    required this.date,
    required this.emoji,
    this.status = LostFoundStatus.open,
    this.image,
    this.contactPreference = 'In-app message',
  });
}
