// ===== FILE GUIDE: lib/screens/admin/users/user_management_screen.dart
// WHAT IT DOES : User Management (PDF page 15).
// MANAGES      : Search, department filter, role tabs, add/edit, suspend/reactivate and remove users (logged to audit).
// USED BY      : admin_shell.dart (Users tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/user.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import 'add_edit_user_screen.dart';

/// Admin user management ("Admin · Directory"): search, filter, add, edit and remove users.
class UserManagementScreen extends StatefulWidget {
  UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  static final _tabs = <(String, UserRole?)>[
    ('All', null),
    ('Students', UserRole.student),
    ('Faculty', UserRole.faculty),
    ('Staff', UserRole.admin),
  ];

  String _query = '';
  int _tab = 0;
  String? _department;

  List<AppUser> get _users => DummyData.users.where((u) {
    final q = _query.toLowerCase();
    final matchesQuery =
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.studentId ?? '').toLowerCase().contains(q) ||
        (u.department ?? '').toLowerCase().contains(q);
    final role = _tabs[_tab].$2;
    final matchesRole = role == null || u.role == role;
    final matchesDept = _department == null || u.department == _department;
    return matchesQuery && matchesRole && matchesDept;
  }).toList();

  void _add() async {
    final created = await Navigator.push<AppUser>(context, MaterialPageRoute(builder: (_) => AddEditUserScreen()));
    if (created != null) {
      setState(() {});
      DummyData.logAction('User added', '${created.name} · ${created.role.label}');
      _snack('User added');
    }
  }

  void _edit(AppUser u) async {
    final updated = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => AddEditUserScreen(existing: u)),
    );
    if (updated != null) {
      setState(() {
        final index = DummyData.users.indexWhere((x) => x.id == u.id);
        if (index != -1) DummyData.users[index] = updated;
      });
      DummyData.logAction('User updated', updated.name);
      _snack('User updated');
    }
  }

  Future<void> _delete(AppUser u) async {
    if (u.id == (SessionService.currentUser ?? DummyData.admin).id) {
      _snack('You cannot remove your own account.');
      return;
    }
    final ok = await confirmAction(
      context,
      title: 'Remove user?',
      message: '${u.name} will be removed from the system. This cannot be undone.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => DummyData.users.removeWhere((x) => x.id == u.id));
    AuthService.forget(u.email);
    DummyData.logAction('User removed', '${u.name} · ${u.email}');
    _snack('User removed');
  }

  Future<void> _toggleSuspend(AppUser u) async {
    if (u.id == (SessionService.currentUser ?? DummyData.admin).id) {
      _snack('You cannot suspend your own account.');
      return;
    }
    final suspended = DummyData.suspendedUserIds.contains(u.id);
    final ok = await confirmAction(
      context,
      title: suspended ? 'Reactivate account?' : 'Suspend account?',
      message: suspended
          ? '${u.name} will be able to sign in again.'
          : '${u.name} will be signed out and blocked from signing in until reactivated.',
      confirmLabel: suspended ? 'Reactivate' : 'Suspend',
      destructive: !suspended,
    );
    if (!ok || !mounted) return;
    setState(() => suspended ? DummyData.suspendedUserIds.remove(u.id) : DummyData.suspendedUserIds.add(u.id));
    DummyData.logAction(suspended ? 'Account reactivated' : 'Account suspended', '${u.name} · ${u.email}');
    _snack(suspended ? '${u.name} reactivated' : '${u.name} suspended');
  }

  void _pickDepartment() {
    final departments = DummyData.users.map((u) => u.department).whereType<String>().toSet().toList()..sort();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EyebrowLabel('Filter by department'),
              SizedBox(height: 8),
              for (final d in <String?>[null, ...departments])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d ?? 'All departments', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: _department == d ? Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _department = d);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final users = _users;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        AdminPageHeader(
          eyebrow: 'Admin · Directory',
          title: 'User\nManagement',
          actions: [PillButton(label: 'Add User', icon: Icons.add_rounded, onPressed: _add)],
        ),
        SizedBox(height: 18),

        // Search + filter
        Container(
          padding: EdgeInsets.only(left: 6, right: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search_rounded, size: 24),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              PillButton(
                label: _department == null ? 'Filter' : 'Filtered',
                icon: Icons.filter_list_rounded,
                filled: false,
                onPressed: _pickDepartment,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SegmentedTabs(labels: [for (final t in _tabs) t.$1], index: _tab, onChanged: (i) => setState(() => _tab = i)),
        SizedBox(height: 18),

        if (users.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: Icons.person_search_rounded,
              title: 'No users found',
              message: 'Adjust your search or filters.',
            ),
          )
        else
          for (final u in users)
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: _UserRow(
                user: u,
                onEdit: () => _edit(u),
                onRemove: () => _delete(u),
                onSuspend: () => _toggleSuspend(u),
              ),
            ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onSuspend;

  const _UserRow({required this.user, required this.onEdit, required this.onRemove, required this.onSuspend});

  String get _subtitle {
    final first = switch (user.role) {
      UserRole.student => user.studentId,
      UserRole.faculty => user.designation,
      UserRole.admin => user.department,
    };
    return [?first, user.email].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final suspended = DummyData.suspendedUserIds.contains(user.id);
    return SoftCard(
      onTap: onEdit,
      padding: EdgeInsets.fromLTRB(16, 16, 6, 16),
      child: Row(
        children: [
          AdminAvatar(initials: user.initials, gradient: AdminAvatar.gradientFor(user.role)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(width: 8),
                    StatusPill.role(user.role),
                  ],
                ),
                if (suspended) ...[
                  SizedBox(height: 4),
                  StatusPill(label: 'SUSPENDED', foreground: AppColors.danger, background: AppColors.dangerSoft),
                ],
                SizedBox(height: 4),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Tooltip(
            message: suspended ? 'Suspended' : 'Active',
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: suspended ? AppColors.textMuted : AppColors.sand,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 6),
          PillButton(label: 'Edit', filled: false, onPressed: onEdit),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            tooltip: 'More actions',
            onSelected: (v) => switch (v) {
              'remove' => onRemove(),
              'suspend' => onSuspend(),
              _ => onEdit(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Edit user')),
              PopupMenuItem(value: 'suspend', child: Text(suspended ? 'Reactivate account' : 'Suspend account')),
              PopupMenuItem(value: 'remove', child: Text('Remove user')),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
