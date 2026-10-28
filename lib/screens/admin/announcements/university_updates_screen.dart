// ===== FILE GUIDE: lib/screens/admin/announcements/university_updates_screen.dart
// WHAT IT DOES : University-wide announcements.
// MANAGES      : Create, edit, pin and delete notices.
// USED BY      : Admin Reports, admin settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/announcement.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/announcement_card.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state.dart';

/// Admin manages important university-wide announcements and information.
class UniversityUpdatesScreen extends StatefulWidget {
  UniversityUpdatesScreen({super.key});

  @override
  State<UniversityUpdatesScreen> createState() => _UniversityUpdatesScreenState();
}

class _UniversityUpdatesScreenState extends State<UniversityUpdatesScreen> {
  List<Announcement> get _updates => DummyData.announcements.where((a) => a.authorRole == 'Admin').toList();

  void _compose({Announcement? existing}) async {
    final result = await showModalBottomSheet<Announcement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _UpdateForm(existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        final index = DummyData.announcements.indexWhere((a) => a.id == existing.id);
        if (index != -1) DummyData.announcements[index] = result;
      } else {
        DummyData.announcements.insert(0, result);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(existing == null ? 'Update published' : 'Update edited')));
    }
  }

  void _delete(Announcement a) {
    setState(() => DummyData.announcements.removeWhere((x) => x.id == a.id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update removed')));
  }

  @override
  Widget build(BuildContext context) {
    final updates = _updates;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('University Updates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _compose(),
        icon: Icon(Icons.campaign_rounded),
        label: Text('New Update'),
      ),
      body: updates.isEmpty
          ? EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No university updates',
              message: 'Publish important announcements for the whole campus.',
              actionLabel: 'Create Update',
              onAction: () => _compose(),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 90),
              itemCount: updates.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = updates[i];
                return AnnouncementCard(
                  announcement: a,
                  actions: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit',
                      icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                      onPressed: () => _compose(existing: a),
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

class _UpdateForm extends StatefulWidget {
  final Announcement? existing;
  _UpdateForm({this.existing});

  @override
  State<_UpdateForm> createState() => _UpdateFormState();
}

class _UpdateFormState extends State<_UpdateForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');
  late bool _pinned = widget.existing?.pinned ?? false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final update = Announcement(
      id: widget.existing?.id ?? 'an${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      body: _body.text.trim(),
      authorName: 'Registrar Office',
      authorRole: 'Admin',
      date: widget.existing?.date ?? DateTime.now(),
      pinned: _pinned,
    );
    Navigator.pop(context, update);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              SizedBox(height: 18),
              Text(
                widget.existing == null ? 'New University Update' : 'Edit Update',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 18),
              AppTextField(
                label: 'Title',
                icon: Icons.title_rounded,
                controller: _title,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              SizedBox(height: 16),
              AppTextField(
                label: 'Details',
                hint: 'Write the university update...',
                controller: _body,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().length < 10) ? 'Please write at least 10 characters' : null,
              ),
              SwitchListTile(
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: Text('Pin as important', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 12),
              AppButton(label: 'Save', icon: Icons.save_rounded, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
