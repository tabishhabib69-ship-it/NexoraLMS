// ===== FILE GUIDE: lib/screens/settings/settings_screen.dart
// WHAT IT DOES : Settings for students and faculty.
// MANAGES      : Light/Dark/System theme, text size, notification and privacy toggles, edit profile, change password notice, reset demo data, about, logout.
// USED BY      : Student and faculty profile screens.
// ======================================================================

import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/user.dart';
import '../../services/app_settings.dart';
import '../../services/my_data.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/session_actions.dart';
import '../../widgets/ui_kit.dart';
import '../../widgets/uni_widgets.dart';
import '../student/profile/edit_profile_screen.dart';
import 'help_screen.dart';

/// App settings shared by students and faculty: appearance, text size,
/// notifications, privacy, demo data and account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _resetDemo() async {
    final ok = await confirmAction(
      context,
      title: 'Reset demo data?',
      message:
          'All posts, submissions, messages, events and reports you created in this session will be '
          'cleared and the original sample data restored.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (!ok || !mounted) return;
    DummyData.reset();
    setState(() {});
    showSnack(context, 'Demo data restored');
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    String? error;
    final changed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Change password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: current,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Current password'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: next,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'New password (8+ characters)'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: confirm,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm new password'),
                ),
                if (error != null) ...[
                  SizedBox(height: 12),
                  Text(
                    error!,
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: Size(0, 44)),
              onPressed: () {
                if (next.text != confirm.text) {
                  setDialog(() => error = 'New passwords do not match.');
                  return;
                }
                final result = AuthService.changePassword(MyData.user.email, current.text, next.text);
                if (result != null) {
                  setDialog(() => error = result);
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (changed == true && mounted) showSnack(context, 'Password updated');
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.currentUser ?? DummyData.student;
    final student = user.role == UserRole.student;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: user.name, title: 'Settings'),
            SizedBox(height: 22),

            _Section('Appearance', [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppSettings.themeMode,
                  builder: (_, mode, _) => SegmentedTabs(
                    labels: ['Light', 'Dark', 'System'],
                    index: [ThemeMode.light, ThemeMode.dark, ThemeMode.system].indexOf(mode),
                    onChanged: (i) =>
                        AppSettings.themeMode.value = [ThemeMode.light, ThemeMode.dark, ThemeMode.system][i],
                  ),
                ),
              ),
              SizedBox(height: 8),
              ValueListenableBuilder<double>(
                valueListenable: AppSettings.textScale,
                builder: (_, scale, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields_rounded, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(child: Text('Text size', style: _title)),
                        Text(
                          '${(scale * 100).round()}%',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: scale,
                      min: 0.9,
                      max: 1.3,
                      divisions: 4,
                      label: '${(scale * 100).round()}%',
                      activeColor: AppColors.primary,
                      onChanged: (v) => AppSettings.textScale.value = v,
                    ),
                  ],
                ),
              ),
            ]),

            _Section('Notifications', [
              for (final key in AppSettings.notificationPrefs.keys)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: AppSettings.notificationPrefs[key]!,
                  activeThumbColor: AppColors.primary,
                  title: Text(key, style: _title),
                  onChanged: (v) => setState(() => AppSettings.notificationPrefs[key] = v),
                ),
              Text(
                'Demo build: preferences apply to the in-app notification centre only (no push service).',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ]),

            _Section('Privacy', [
              if (student)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: AppSettings.showStudentIdOnProfile,
                  activeThumbColor: AppColors.primary,
                  title: Text('Show student ID to classmates', style: _title),
                  subtitle: Text('Off by default — IDs are never shown on the feed', style: _sub),
                  onChanged: (v) => setState(() => AppSettings.showStudentIdOnProfile = v),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: AppSettings.showEmailOnProfile,
                activeThumbColor: AppColors.primary,
                title: Text('Show university email on profile', style: _title),
                onChanged: (v) => setState(() => AppSettings.showEmailOnProfile = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: AppSettings.allowConnectionRequests,
                activeThumbColor: AppColors.primary,
                title: Text('Allow connection requests', style: _title),
                onChanged: (v) => setState(() => AppSettings.allowConnectionRequests = v),
              ),
            ]),

            _Section('Account', [
              _Tile(Icons.edit_outlined, 'Edit profile', () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                if (mounted) setState(() {});
              }),
              _Tile(Icons.lock_outline_rounded, 'Change password', _changePassword),
              _Tile(
                Icons.help_outline_rounded,
                'Help, FAQ & feedback',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen())),
              ),
              _Tile(Icons.restart_alt_rounded, 'Reset demo data', _resetDemo),
            ]),

            _Section('About', [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(child: Text('Uni-Sphere · version 1.0.0 (demo)', style: _title)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${DummyData.universityName}. All people, courses and records in this build are sample data.',
                style: _sub,
              ),
            ]),

            SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => confirmLogout(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, backgroundColor: AppColors.surface),
              icon: Icon(Icons.logout_rounded),
              label: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _title => TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary);
  TextStyle get _sub => TextStyle(fontSize: 12.5, color: AppColors.textSecondary);
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(title),
          SizedBox(height: 10),
          SoftCard(
            padding: EdgeInsets.fromLTRB(18, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Tile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
