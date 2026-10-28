// ===== FILE GUIDE: lib/screens/student/connect/connect_screen.dart
// WHAT IT DOES : Connect & messages (PDF page 7).
// MANAGES      : Search people, connect / message, connection requests, conversation list with unread counts.
// USED BY      : student_shell.dart (Chat tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import 'chat_screen.dart';
import '../../../services/my_data.dart';

/// Connect (PDF page 7): find students & faculty, manage connection
/// requests and open conversations. Local demo data only.
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  String _query = '';

  String get _meId => MyData.id;

  List<AppUser> get _results {
    final q = _query.toLowerCase().trim();
    return DummyData.users.where((u) {
      if (u.id == _meId || u.role == UserRole.admin) return false;
      return u.name.toLowerCase().contains(q) ||
          (u.department ?? '').toLowerCase().contains(q) ||
          (u.studentId ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Opens (or starts) a one-to-one conversation with [u].
  Future<void> openChatWith(AppUser u) async {
    var conv = MyData.conversations.where((c) => c.peerId == u.id).firstOrNull;
    if (conv == null) {
      conv = Conversation(
        id: 'cv${DateTime.now().millisecondsSinceEpoch}',
        peerId: u.id,
        peerName: u.name,
        peerRole: u.role.label,
        peerColor: u.avatarColor,
        lastMessage: 'Say hello 👋',
        lastTime: DateTime.now(),
        ownerId: _meId,
      );
      DummyData.conversations.insert(0, conv);
      DummyData.messages[conv.id] = [];
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv!)));
    if (mounted) setState(() {});
  }

  void _compose() {
    final people = MyData.connections.map(DummyData.userById).whereType<AppUser>().toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            if (people.isEmpty) Padding(padding: EdgeInsets.all(24), child: Text('Connect with someone first.')),
            for (final u in people)
              ListTile(
                leading: InitialsCircle(
                  initials: initialsOf(u.name),
                  size: 42,
                  gradient: u.role == UserRole.faculty ? AppColors.sandGradient : AppColors.wineGradient,
                ),
                title: Text(
                  u.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                subtitle: Text(_subtitle(u), style: TextStyle(color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(sheet);
                  openChatWith(u);
                },
              ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Public preview line: department and semester only (no IDs or emails).
  static String _subtitle(AppUser u) => u.role == UserRole.faculty
      ? '${u.designation ?? 'Faculty'} · ${u.department ?? ''}'
      : '${u.department ?? ''}${u.semester == null ? '' : ' · Semester ${u.semester}'}';

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final convs = [...MyData.conversations]..sort((a, b) => b.lastTime.compareTo(a.lastTime));
    final unread = convs.fold<int>(0, (s, c) => s + c.unread);
    final incoming = MyData.incomingRequests.map(DummyData.userById).whereType<AppUser>().toList();
    final suggested = DummyData.users
        .where(
          (u) =>
              u.id != _meId &&
              u.role == UserRole.student &&
              !MyData.connections.contains(u.id) &&
              !MyData.incomingRequests.contains(u.id),
        )
        .take(2)
        .toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          AdminPageHeader(
            eyebrow: 'Find students & faculty',
            title: 'Connect',
            actions: [
              Semantics(
                button: true,
                label: 'New message',
                child: GestureDetector(
                  onTap: _compose,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.wineGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Color(0x332E2729), blurRadius: 14, offset: Offset(0, 6))],
                    ),
                    child: Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          SearchBox(hint: 'Search by name, ID, or department…', onChanged: (v) => setState(() => _query = v)),
          SizedBox(height: 22),
          if (searching) ...[
            EyebrowLabel('Search results'),
            SizedBox(height: 12),
            if (_results.isEmpty)
              EmptyState(
                icon: Icons.person_search_rounded,
                title: 'No one found',
                message: 'Try another name or department.',
              ),
            for (final u in _results) Padding(padding: EdgeInsets.only(bottom: 12), child: _personCard(u)),
          ] else ...[
            if (incoming.isNotEmpty) ...[
              EyebrowLabel('Connection requests'),
              SizedBox(height: 12),
              for (final u in incoming)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        InitialsCircle(initials: initialsOf(u.name), size: 52),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(_subtitle(u), style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Decline',
                          onPressed: () => setState(() => MyData.declineRequest(u.id)),
                          icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                        ),
                        PillButton(
                          label: 'Accept',
                          onPressed: () {
                            setState(() {
                              MyData.acceptRequest(u.id);
                            });
                            showSnack(context, 'You are now connected with ${u.name.split(' ').first}');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 12),
            ],
            if (suggested.isNotEmpty) ...[
              EyebrowLabel('People you may know'),
              SizedBox(height: 12),
              for (final u in suggested) Padding(padding: EdgeInsets.only(bottom: 12), child: _personCard(u)),
              SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(child: EyebrowLabel('Messages')),
                if (unread > 0)
                  StatusPill(label: '$unread unread', foreground: AppColors.primary, background: AppColors.sandSoft),
              ],
            ),
            SizedBox(height: 12),
            if (convs.isEmpty)
              EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations',
                message: 'Start one with the pencil button.',
              ),
            for (final c in convs) Padding(padding: EdgeInsets.only(bottom: 12), child: _conversationTile(c)),
            SizedBox(height: 4),
            Text(
              'Demo chat: messages stay on this device and are not delivered to other users.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _personCard(AppUser u) {
    final connected = MyData.connections.contains(u.id);
    final requested = MyData.requestedTo(u.id);
    return SoftCard(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          InitialsCircle(
            initials: initialsOf(u.name),
            size: 56,
            gradient: u.role == UserRole.faculty ? AppColors.sandGradient : AppColors.wineGradient,
            statusDot: connected ? AppColors.sand : AppColors.textMuted,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.name,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, color: AppColors.textPrimary),
                ),
                Text(_subtitle(u), style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (connected || u.role == UserRole.faculty)
            PillButton(label: 'Message', filled: false, onPressed: () => openChatWith(u))
          else if (requested)
            PillButton(label: 'Requested', filled: false, onPressed: () => setState(() => MyData.cancelRequest(u.id)))
          else
            PillButton(
              label: 'Connect',
              onPressed: () {
                setState(() => MyData.sendRequest(u.id));
                showSnack(context, 'Request sent to ${u.name.split(' ').first}');
              },
            ),
        ],
      ),
    );
  }

  Widget _conversationTile(Conversation c) {
    final group = c.isGroup;
    return SoftCard(
      color: c.unread > 0 ? AppColors.surface : AppColors.surfaceAlt,
      outlined: true,
      padding: EdgeInsets.all(14),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)));
        if (mounted) setState(() {});
      },
      child: Row(
        children: [
          group
              ? Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(gradient: AppColors.wineGradient, borderRadius: BorderRadius.circular(18)),
                  child: Icon(Icons.groups_outlined, color: Colors.white, size: 28),
                )
              : InitialsCircle(
                  initials: initialsOf(c.peerName),
                  size: 56,
                  gradient: c.peerRole == 'Faculty'
                      ? LinearGradient(colors: [Color(0xFF3A3335), Color(0xFF6E6668)])
                      : AppColors.wineGradient,
                  statusDot: c.unread > 0 ? AppColors.sand : AppColors.textMuted,
                ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.peerName,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, color: AppColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  c.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: c.unread > 0 ? AppColors.textPrimary : AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeAgo(c.lastTime), style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              SizedBox(height: 6),
              if (c.unread > 0)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: AppColors.wineGradient, shape: BoxShape.circle),
                  child: Text(
                    '${c.unread}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                )
              else
                Icon(Icons.done_rounded, size: 20, color: AppColors.sand),
            ],
          ),
        ],
      ),
    );
  }
}
