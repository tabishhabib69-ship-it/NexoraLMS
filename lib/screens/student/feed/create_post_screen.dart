// ===== FILE GUIDE: lib/screens/student/feed/create_post_screen.dart
// WHAT IT DOES : Write a new feed post.
// MANAGES      : Text, category, achievement/certificate highlight, optional photo, validation.
// USED BY      : Feed (+ button), + quick actions.
// ======================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/image_picker_field.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';

/// Compose a feed post (text, category, optional highlight and image).
/// Adds it to the local demo feed and returns it.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _content = TextEditingController();
  final _highlight = TextEditingController();
  final _issuer = TextEditingController();
  PostCategory _category = PostCategory.general;
  Uint8List? _image;

  bool get _hasHighlight => _category == PostCategory.achievement || _category == PostCategory.certificate;

  @override
  void dispose() {
    _content.dispose();
    _highlight.dispose();
    _issuer.dispose();
    super.dispose();
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    final user = SessionService.currentUser ?? DummyData.student;
    final post = Post(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      authorId: user.id,
      authorName: user.name,
      authorRole: user.role.label,
      authorColor: user.avatarColor,
      content: _content.text.trim(),
      date: DateTime.now(),
      category: _category,
      image: _image,
      official: user.role == UserRole.admin,
      highlightTitle: _hasHighlight && _highlight.text.trim().isNotEmpty ? _highlight.text.trim() : null,
      highlightSubtitle: _hasHighlight && _issuer.text.trim().isNotEmpty ? _issuer.text.trim() : null,
    );
    DummyData.posts.insert(0, post);
    Navigator.pop(context, post);
    showSnack(context, 'Posted to the campus feed (stored on this device for the demo)');
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
              AdminPageHeader(eyebrow: 'Share with campus', title: 'New Post'),
              SizedBox(height: 20),
              EyebrowLabel('Category'),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in PostCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: AppColors.border),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _category == c ? Colors.white : AppColors.textSecondary,
                      ),
                      showCheckmark: false,
                    ),
                ],
              ),
              SizedBox(height: 18),
              TextFormField(
                controller: _content,
                minLines: 4,
                maxLines: 8,
                maxLength: 500,
                decoration: InputDecoration(hintText: 'What would you like to share?', alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Write at least a few words' : null,
              ),
              if (_hasHighlight) ...[
                SizedBox(height: 6),
                TextFormField(
                  controller: _highlight,
                  decoration: InputDecoration(
                    labelText: _category == PostCategory.achievement ? 'Award name' : 'Certificate name',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a title for the highlight card' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _issuer,
                  decoration: InputDecoration(
                    labelText: 'Issuer / details (optional)',
                    hintText: 'e.g. Coursera · Sep 2026',
                  ),
                ),
              ],
              SizedBox(height: 16),
              ImagePickerField(
                label: 'Add photo (optional)',
                height: 170,
                onChanged: (b) => setState(() => _image = b),
              ),
              SizedBox(height: 14),
              InfoBanner(
                text: 'Posts are visible to everyone at your university. Avoid sharing personal contact details.',
              ),
              SizedBox(height: 20),
              GradientButton(label: 'Publish', icon: Icons.send_rounded, onPressed: _publish),
            ],
          ),
        ),
      ),
    );
  }
}
