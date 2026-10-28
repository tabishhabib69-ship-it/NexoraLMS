// ===== FILE GUIDE: lib/screens/student/notifications/notifications_screen.dart
// WHAT IT DOES : Notification centre.
// MANAGES      : Category filters, unread-only switch, mark read/unread, mark all read, swipe to remove.
// USED BY      : Dashboard and feed bell icons.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/notification.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../../services/my_data.dart';

/// Notification centre with category filters and read/unread state.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;
  bool _unreadOnly = false;

  static const _groups = <String, List<NotificationType>>{
    'All': NotificationType.values,
    'Academic': [NotificationType.assignment, NotificationType.exam, NotificationType.attendance],
    'Courses': [NotificationType.announcement, NotificationType.faculty],
    'Messages': [NotificationType.message],
    'Campus': [NotificationType.university],
  };

  static IconData iconFor(NotificationType t) => switch (t) {
    NotificationType.assignment => Icons.assignment_outlined,
    NotificationType.exam => Icons.event_outlined,
    NotificationType.attendance => Icons.fact_check_outlined,
    NotificationType.announcement => Icons.campaign_outlined,
    NotificationType.faculty => Icons.upload_file_outlined,
    NotificationType.message => Icons.chat_bubble_outline_rounded,
    NotificationType.university => Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final types = _groups.values.elementAt(_filter);
    final items = MyData.notifications.where((n) => types.contains(n.type) && (!_unreadOnly || !n.read)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final unread = MyData.notifications.where((n) => !n.read).length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 28),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(children: [CircleBackButton()]),
                  SizedBox(height: 14),
                  AdminPageHeader(
                    eyebrow: unread == 0 ? 'You are all caught up' : '$unread unread',
                    title: 'Notifications',
                    actions: [
                      if (unread > 0)
                        PillButton(
                          label: 'Mark all read',
                          filled: false,
                          onPressed: () => setState(() {
                            for (final n in MyData.notifications) {
                              n.read = true;
                            }
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            FilterPills(labels: _groups.keys.toList(), index: _filter, onChanged: (i) => setState(() => _filter = i)),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 20, 4),
              child: SwitchListTile(
                value: _unreadOnly,
                onChanged: (v) => setState(() => _unreadOnly = v),
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Unread only',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ),
            if (items.isEmpty)
              EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                message: 'Nothing in this category.',
              ),
            for (final n in items)
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                  onDismissed: (_) {
                    setState(() => DummyData.notifications.remove(n));
                    showSnack(context, 'Notification removed');
                  },
                  child: SoftCard(
                    color: n.read ? AppColors.surfaceAlt : AppColors.surface,
                    outlined: n.read,
                    padding: EdgeInsets.all(16),
                    onTap: () => setState(() => n.read = !n.read),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GradientIconTile(
                          icon: iconFor(n.type),
                          size: 44,
                          gradient: n.read ? AppColors.sandGradient : AppColors.wineGradient,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!n.read)
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              SizedBox(height: 3),
                              Text(
                                n.body,
                                style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${n.type.label} · ${timeAgo(n.date)} · tap to mark ${n.read ? 'unread' : 'read'}',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
