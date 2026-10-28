// ===== FILE GUIDE: lib/screens/student/lost_found/add_lost_found_screen.dart
// WHAT IT DOES : Report a lost or found item.
// MANAGES      : Form with validation, category, location, date, contact preference, optional photo.
// USED BY      : Lost & Found board, + quick actions.
// ======================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/lost_found.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/image_picker_field.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';

/// Report a lost or found item. Adds it to the local demo board.
class AddLostFoundScreen extends StatefulWidget {
  const AddLostFoundScreen({super.key});

  @override
  State<AddLostFoundScreen> createState() => _AddLostFoundScreenState();
}

class _AddLostFoundScreenState extends State<AddLostFoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  LostFoundType _type = LostFoundType.lost;
  String? _category;
  String _contact = 'In-app message';
  DateTime _date = DateTime.now();
  Uint8List? _image;

  static const _contactOptions = ['In-app message', 'Campus security desk'];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(Duration(days: 60)),
      lastDate: now,
    );
    if (d != null) setState(() => _date = d);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final me = SessionService.currentUser ?? DummyData.student;
    final item = LostFoundItem(
      id: 'lf${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      title: _title.text.trim(),
      description: _description.text.trim(),
      location: _location.text.trim(),
      reporterName: me.name,
      reporterColor: me.avatarColor,
      category: _category!,
      date: _date,
      emoji: '',
      image: _image,
      contactPreference: _contact,
    );
    DummyData.lostFound.insert(0, item);
    Navigator.pop(context, item);
    showSnack(context, '${_type.label} report posted to the campus board (demo)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(children: [CircleBackButton()]),
              SizedBox(height: 16),
              AdminPageHeader(eyebrow: 'Campus Board', title: 'Report Item'),
              SizedBox(height: 18),
              SegmentedTabs(
                labels: ['I lost something', 'I found something'],
                index: _type == LostFoundType.lost ? 0 : 1,
                onChanged: (i) => setState(() => _type = i == 0 ? LostFoundType.lost : LostFoundType.found),
              ),
              SizedBox(height: 18),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Item name', hintText: 'e.g. Black HP laptop bag'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Describe the item in a few words' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                dropdownColor: AppColors.surface,
                items: [for (final c in DummyData.lostFoundCategories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Pick a category' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: InputDecoration(labelText: 'Location', hintText: 'e.g. CS Block, 2nd floor'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Where was it lost or found?' : null,
              ),
              SizedBox(height: 12),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.border),
                  ),
                  leading: Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                  title: Text('Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  subtitle: Text(
                    formatLongDay(_date),
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  onTap: _pickDate,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Colour, brand, distinguishing marks…',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 10) ? 'Add a short description (10+ characters)' : null,
              ),
              SizedBox(height: 16),
              EyebrowLabel('Contact preference'),
              SizedBox(height: 4),
              RadioGroup<String>(
                groupValue: _contact,
                onChanged: (v) => setState(() => _contact = v!),
                child: Column(
                  children: [
                    for (final o in _contactOptions)
                      RadioListTile<String>(
                        value: o,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                        title: Text(o, style: TextStyle(color: AppColors.textPrimary)),
                      ),
                  ],
                ),
              ),
              ImagePickerField(
                label: 'Add photo (optional)',
                height: 160,
                onChanged: (b) => setState(() => _image = b),
              ),
              SizedBox(height: 14),
              InfoBanner(
                icon: Icons.privacy_tip_outlined,
                text:
                    'Your phone number and email are never shown on the board. Claims are handled via in-app '
                    'message or the campus security desk.',
              ),
              SizedBox(height: 20),
              GradientButton(label: 'Post Report', icon: Icons.campaign_outlined, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
