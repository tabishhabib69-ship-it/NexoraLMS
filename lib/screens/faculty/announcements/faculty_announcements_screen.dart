// ===== FILE GUIDE: lib/screens/faculty/announcements/faculty_announcements_screen.dart
// WHAT IT DOES : Faculty course announcements.
// MANAGES      : List, create, edit and delete announcements.
// USED BY      : Faculty dashboard, course hub, profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/announcement.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/announcement_card.dart';
import '../../../widgets/empty_state.dart';
import 'create_announcement_screen.dart';

/// Faculty course announcements: create, view, edit and delete.
class FacultyAnnouncementsScreen extends StatefulWidget {
  FacultyAnnouncementsScreen({super.key});

  @override
  State<FacultyAnnouncementsScreen> createState() => _FacultyAnnouncementsScreenState();
}

class _FacultyAnnouncementsScreenState extends State<FacultyAnnouncementsScreen> {
  List<Announcement> get _items => DummyData.announcements.where((a) => a.authorRole == 'Faculty').toList();

  void _create() async {
    final created = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(builder: (_) => CreateAnnouncementScreen()),
    );
    if (created != null) {
      setState(() => DummyData.announcements.insert(0, created));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement published')));
      }
    }
  }

  void _edit(Announcement a) async {
    final updated = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(builder: (_) => CreateAnnouncementScreen(existing: a)),
    );
    if (updated != null) {
      setState(() {
        final index = DummyData.announcements.indexWhere((x) => x.id == a.id);
        if (index != -1) DummyData.announcements[index] = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement updated')));
      }
    }
  }

  void _delete(Announcement a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete announcement?'),
        content: Text('"${a.title}" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() => DummyData.announcements.removeWhere((x) => x.id == a.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement deleted')));
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _togglePin(Announcement a) {
    setState(() {
      final index = DummyData.announcements.indexWhere((x) => x.id == a.id);
      if (index != -1) {
        DummyData.announcements[index] = a.copyWith(pinned: !a.pinned);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(automaticallyImplyLeading: false, title: Text('Announcements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: Icon(Icons.add_rounded),
        label: Text('New'),
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No announcements',
              message: 'Create your first announcement for your courses.',
              actionLabel: 'Create Announcement',
              onAction: _create,
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 90),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = items[i];
                return AnnouncementCard(
                  announcement: a,
                  actions: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: a.pinned ? 'Unpin' : 'Pin',
                      icon: Icon(
                        a.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        size: 20,
                        color: a.pinned ? AppColors.warning : AppColors.textMuted,
                      ),
                      onPressed: () => _togglePin(a),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit',
                      icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                      onPressed: () => _edit(a),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                      onPressed: () => _delete(a),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
