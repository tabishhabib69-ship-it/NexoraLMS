// ===== FILE GUIDE: lib/screens/student/lost_found/lost_found_screen.dart
// WHAT IT DOES : Lost & Found board (PDF page 9).
// MANAGES      : Category tabs, search, Lost/Found/Returned counts, item grid, Report Item button.
// USED BY      : Dashboard (Lost & Found).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/lost_found.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import 'add_lost_found_screen.dart';
import 'lost_found_details_screen.dart';

/// Icon for a lost & found category.
IconData lostFoundIcon(String category) => switch (category) {
  'Electronics' => Icons.headphones_outlined,
  'Accessories' => Icons.work_outline_rounded,
  'Books' => Icons.menu_book_outlined,
  'ID Cards' => Icons.badge_outlined,
  _ => Icons.category_outlined,
};

/// Status pill colours + label (Lost / Found / Returned).
(String, Color, Color) lostFoundStatus(LostFoundItem i) {
  if (i.status == LostFoundStatus.resolved) return ('RETURNED', AppColors.textSecondary, AppColors.surfaceAlt);
  return i.type == LostFoundType.lost
      ? ('LOST', AppColors.primary, AppColors.primarySoft)
      : ('FOUND', AppColors.sandDeep, AppColors.mintSoft);
}

/// Campus Lost & Found board (PDF page 9).
class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  int _cat = 0;
  String _query = '';

  List<String> get _labels => ['All', ...DummyData.lostFoundCategories];

  List<LostFoundItem> get _items {
    final q = _query.toLowerCase();
    return DummyData.lostFound.where((i) {
      final catOk = _cat == 0 || i.category == _labels[_cat];
      final qOk =
          q.isEmpty ||
          i.title.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _report() async {
    final created = await Navigator.push<LostFoundItem>(
      context,
      MaterialPageRoute(builder: (_) => AddLostFoundScreen()),
    );
    if (created != null && mounted) setState(() => _cat = 0);
  }

  @override
  Widget build(BuildContext context) {
    final all = DummyData.lostFound;
    final lost = all.where((i) => i.type == LostFoundType.lost && i.status == LostFoundStatus.open).length;
    final found = all.where((i) => i.type == LostFoundType.found && i.status == LostFoundStatus.open).length;
    final returned = all.where((i) => i.status == LostFoundStatus.resolved).length;
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _report,
        icon: Icon(Icons.add_rounded),
        label: Text('Report Item', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 100),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(children: [CircleBackButton()]),
                  SizedBox(height: 14),
                  AdminPageHeader(eyebrow: 'Campus Board', title: 'Lost & Found'),
                  SizedBox(height: 18),
                  SearchBox(hint: 'Search lost items…', onChanged: (v) => setState(() => _query = v)),
                ],
              ),
            ),
            SizedBox(height: 14),
            FilterPills(labels: _labels, index: _cat, onChanged: (i) => setState(() => _cat = i)),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: StatStrip(
                items: [
                  (value: '$lost', label: 'Lost', color: AppColors.primary),
                  (value: '$found', label: 'Found', color: AppColors.sand),
                  (value: '$returned', label: 'Returned', color: AppColors.primary),
                ],
              ),
            ),
            SizedBox(height: 18),
            if (items.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No items',
                message: 'Nothing matches this filter.',
                actionLabel: 'Report an item',
                onAction: _report,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (_, box) {
                    final cols = box.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 238,
                      ),
                      itemBuilder: (_, i) => _ItemCard(
                        item: items[i],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LostFoundDetailsScreen(item: items[i])),
                          );
                          if (mounted) setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final LostFoundItem item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = lostFoundStatus(item);
    final returned = item.status == LostFoundStatus.resolved;
    return Opacity(
      opacity: returned ? 0.7 : 1,
      child: SoftCard(
        onTap: onTap,
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: item.type == LostFoundType.found && !returned
                    ? AppColors.mintSoft
                    : AppColors.primarySoft.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.image != null
                  ? Image.memory(item.image!, fit: BoxFit.cover)
                  : Icon(lostFoundIcon(item.category), size: 46, color: returned ? AppColors.sand : fg),
            ),
            SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 2),
            Text(
              '${item.location} · ${formatShortDate(item.date)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            Spacer(),
            StatusPill(label: label, foreground: fg, background: bg),
          ],
        ),
      ),
    );
  }
}
