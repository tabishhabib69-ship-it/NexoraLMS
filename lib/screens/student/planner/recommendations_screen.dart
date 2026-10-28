// ===== FILE GUIDE: lib/screens/student/planner/recommendations_screen.dart
// WHAT IT DOES : Courses for You.
// MANAGES      : Adjustable interests, recommended courses with reasons, shortlist (no auto-enroll).
// USED BY      : Dashboard, course list, profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/app_settings.dart';
import '../../../services/recommendation_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../courses/course_details_screen.dart';

/// Personalized course suggestions with the reasons behind each one.
/// Interests are adjustable; nothing is ever enrolled automatically.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  /// Courses the student saved to discuss with their advisor.
  static final Set<String> shortlisted = {};

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  Widget build(BuildContext context) {
    final allTags = DummyData.courseTags.values.expand((t) => t).toSet().toList()..sort();
    final recs = RecommendationService.recommend();
    final top = recs.isEmpty ? 1 : recs.first.score.clamp(1, 100);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: 'Planning next semester', title: 'Courses for You'),
            SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EyebrowLabel('Your interests'),
                  SizedBox(height: 4),
                  Text(
                    'Tap to adjust — the list updates instantly.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in allTags)
                        FilterChip(
                          label: Text(t),
                          selected: AppSettings.interests.contains(t),
                          onSelected: (on) =>
                              setState(() => on ? AppSettings.interests.add(t) : AppSettings.interests.remove(t)),
                          selectedColor: AppColors.primarySoft,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppSettings.interests.contains(t) ? AppColors.primary : AppColors.textSecondary,
                          ),
                          side: BorderSide(color: AppColors.border),
                          backgroundColor: AppColors.surface,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14),
            InfoBanner(
              text:
                  'Suggestions use your interests, prerequisite results and program. They never enroll you — '
                  'shortlist courses and confirm with your advisor during registration.',
            ),
            SizedBox(height: 18),
            for (final r in recs)
              Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: SoftCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: r.course, initialTab: 0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GradientIconTile(
                            icon: Icons.recommend_rounded,
                            gradient: r.prerequisitesMet ? AppColors.wineGradient : AppColors.sandGradient,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.course.code} · ${r.course.credits} cr',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.sand),
                                ),
                                Text(
                                  r.course.title,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusPill(
                            label: r.prerequisitesMet ? 'Eligible' : 'Prereq needed',
                            foreground: r.prerequisitesMet ? AppColors.success : AppColors.warning,
                            background: r.prerequisitesMet ? AppColors.successSoft : AppColors.warningSoft,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Match', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          SizedBox(width: 10),
                          Expanded(child: GradientProgress(value: (r.score / top).clamp(0.05, 1.0), height: 7)),
                        ],
                      ),
                      SizedBox(height: 10),
                      for (final reason in r.reasons)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                reason.startsWith('Needs') || reason.startsWith('Outside')
                                    ? Icons.info_outline_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 16,
                                color: reason.startsWith('Needs') || reason.startsWith('Outside')
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(reason, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PillButton(
                          label: RecommendationsScreen.shortlisted.contains(r.course.id) ? 'Shortlisted' : 'Shortlist',
                          icon: RecommendationsScreen.shortlisted.contains(r.course.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          filled: false,
                          onPressed: () => setState(() {
                            final id = r.course.id;
                            RecommendationsScreen.shortlisted.contains(id)
                                ? RecommendationsScreen.shortlisted.remove(id)
                                : RecommendationsScreen.shortlisted.add(id);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
