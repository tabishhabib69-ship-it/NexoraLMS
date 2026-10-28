// ===== FILE GUIDE: lib/screens/student/lost_found/lost_found_details_screen.dart
// WHAT IT DOES : One Lost & Found item.
// MANAGES      : Details, claim / contact info, and Mark as Returned (with confirmation).
// USED BY      : Lost & Found board.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/lost_found.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import 'lost_found_screen.dart';

/// Item details with claim / contact and the mark-as-returned flow.
class LostFoundDetailsScreen extends StatefulWidget {
  final LostFoundItem item;

  const LostFoundDetailsScreen({super.key, required this.item});

  @override
  State<LostFoundDetailsScreen> createState() => _LostFoundDetailsScreenState();
}

class _LostFoundDetailsScreenState extends State<LostFoundDetailsScreen> {
  LostFoundItem get i => widget.item;

  bool get _mine => i.reporterName == (SessionService.currentUser ?? DummyData.student).name;

  Future<void> _markReturned() async {
    final ok = await confirmAction(
      context,
      title: 'Mark as returned?',
      message: '"${i.title}" will be moved to Returned and closed for new claims.',
      confirmLabel: 'Mark returned',
    );
    if (ok && mounted) {
      setState(() => i.status = LostFoundStatus.resolved);
      showSnack(context, 'Marked as returned');
    }
  }

  void _contact() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i.type == LostFoundType.found ? 'Claim this item' : 'I found this item'),
        content: Text(
          i.contactPreference == 'Campus security desk'
              ? 'Visit the campus security desk (Admin Block, ground floor) with your student ID to '
                    '${i.type == LostFoundType.found ? 'claim' : 'hand over'} this item.'
              : 'The reporter prefers in-app messages. In this demo build no message is actually sent — '
                    'in the full app a private chat would open with ${i.reporterName.split(' ').first}.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = lostFoundStatus(i);
    final open = i.status == LostFoundStatus.open;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: i.type == LostFoundType.found ? AppColors.mintSoft : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: i.image != null
                  ? Image.memory(i.image!, fit: BoxFit.cover)
                  : Icon(lostFoundIcon(i.category), size: 84, color: fg),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                StatusPill(label: label, foreground: fg, background: bg),
                SizedBox(width: 8),
                StatusPill(
                  label: i.category.toUpperCase(),
                  foreground: AppColors.textSecondary,
                  background: AppColors.surfaceAlt,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              i.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  _row(Icons.place_outlined, 'Location', i.location),
                  Divider(height: 22),
                  _row(Icons.event_outlined, 'Date', formatLongDay(i.date)),
                  Divider(height: 22),
                  _row(Icons.person_outline_rounded, 'Reported by', i.reporterName),
                  Divider(height: 22),
                  _row(Icons.forum_outlined, 'Contact via', i.contactPreference),
                ],
              ),
            ),
            SizedBox(height: 14),
            SoftCard(
              child: Text(i.description, style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary)),
            ),
            SizedBox(height: 22),
            if (open && !_mine)
              GradientButton(
                label: i.type == LostFoundType.found ? 'This is mine — claim it' : 'I found this item',
                icon: Icons.handshake_outlined,
                onPressed: _contact,
              ),
            if (open && _mine)
              GradientButton(label: 'Mark as Returned', icon: Icons.task_alt_rounded, onPressed: _markReturned),
            if (!open)
              InfoBanner(
                tone: BannerTone.success,
                icon: Icons.task_alt_rounded,
                text: 'This item has been returned to its owner.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
