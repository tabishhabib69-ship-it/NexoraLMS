// ===== FILE GUIDE: lib/models/material.dart
// WHAT IT DOES : Data class for a course material (PDF, slides, video, document).
// MANAGES      : Title, type, size, week and the short summary used by Quick Preview and Uni-AI.
// USED BY      : Course Materials tab, Content Studio, bookmarks, search, Uni-AI.
// ======================================================================

enum LearningMaterialType { pdf, slides, video, document, link }

extension LearningMaterialTypeX on LearningMaterialType {
  String get label {
    switch (this) {
      case LearningMaterialType.pdf:
        return 'PDF';
      case LearningMaterialType.slides:
        return 'Slides';
      case LearningMaterialType.video:
        return 'Video';
      case LearningMaterialType.document:
        return 'Document';
      case LearningMaterialType.link:
        return 'Link';
    }
  }
}

/// A learning material uploaded by faculty for a course.
class LearningMaterial {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final LearningMaterialType type;
  final String size; // e.g. "2.4 MB"
  final DateTime date;
  final int downloads;
  final String week; // e.g. "Week 1–3"
  /// Short study summary used by Quick Preview and Uni-AI (demo content).
  final String summary;

  const LearningMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.size,
    required this.date,
    this.downloads = 0,
    this.week = '',
    this.summary = '',
  });

  LearningMaterial copyWith({
    String? title,
    String? description,
    LearningMaterialType? type,
    String? size,
    DateTime? date,
  }) {
    return LearningMaterial(
      id: id,
      courseId: courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      size: size ?? this.size,
      date: date ?? this.date,
      downloads: downloads,
      week: week,
      summary: summary,
    );
  }
}
