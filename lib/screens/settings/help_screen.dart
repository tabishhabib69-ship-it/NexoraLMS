// ===== FILE GUIDE: lib/screens/settings/help_screen.dart
// WHAT IT DOES : Help & feedback.
// MANAGES      : FAQ list and a feedback form (rating + message, saved locally).
// USED BY      : Settings, student and faculty profiles.
// ======================================================================

import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../../widgets/uni_widgets.dart';

/// Help centre: FAQs and a feedback form.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  String _topic = 'General';
  int _rating = 0;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      showSnack(context, 'Please rate your experience');
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _rating = 0;
      _message.clear();
    });
    showSnack(context, 'Thanks! Feedback saved on this device (demo — not sent to a server).');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: 'We are here to help', title: 'Help & Feedback'),
            SizedBox(height: 20),
            SectionTitle('Frequently asked'),
            SoftCard(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    for (final f in DummyData.faqs)
                      ExpansionTile(
                        iconColor: AppColors.primary,
                        collapsedIconColor: AppColors.textMuted,
                        title: Text(
                          f.question,
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(f.answer, style: TextStyle(height: 1.5, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SectionTitle('Send feedback'),
            SoftCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _topic,
                      decoration: InputDecoration(labelText: 'Topic'),
                      dropdownColor: AppColors.surface,
                      items: [
                        for (final t in ['General', 'Bug report', 'Feature idea', 'Uni-AI answers', 'Account'])
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (v) => setState(() => _topic = v!),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'How is your experience?',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            tooltip: '$i star${i == 1 ? '' : 's'}',
                            onPressed: () => setState(() => _rating = i),
                            icon: Icon(
                              i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.sand,
                              size: 32,
                            ),
                          ),
                      ],
                    ),
                    TextFormField(
                      controller: _message,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(hintText: 'Tell us what worked or what didn\'t…'),
                      validator: (v) =>
                          (v == null || v.trim().length < 10) ? 'Please write at least 10 characters' : null,
                    ),
                    SizedBox(height: 16),
                    GradientButton(label: 'Send Feedback', loading: _sending, onPressed: _send),
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
