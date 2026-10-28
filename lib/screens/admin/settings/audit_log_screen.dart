// ===== FILE GUIDE: lib/screens/admin/settings/audit_log_screen.dart
// WHAT IT DOES : Audit history.
// MANAGES      : Searchable list of admin actions (who did what, when).
// USED BY      : Admin dashboard (Activity), admin settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';

/// Admin audit / activity history (newest first), searchable.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final entries = DummyData.auditLog
        .where(
          (e) =>
              e.action.toLowerCase().contains(q) ||
              e.detail.toLowerCase().contains(q) ||
              e.actor.toLowerCase().contains(q),
        )
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 14),
            AdminPageHeader(eyebrow: 'Admin · Security', title: 'Audit History'),
            SizedBox(height: 16),
            SearchBox(hint: 'Search actions, people, courses…', onChanged: (v) => setState(() => _q = v)),
            SizedBox(height: 18),
            if (entries.isEmpty)
              EmptyState(icon: Icons.history_rounded, title: 'No entries', message: 'Nothing matches your search.'),
            SoftCard(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].action,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(entries[i].detail, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                SizedBox(height: 3),
                                Text(
                                  'by ${entries[i].actor} · ${formatDateTime(entries[i].time)}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
