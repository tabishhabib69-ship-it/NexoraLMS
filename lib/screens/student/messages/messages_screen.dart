// ===== FILE GUIDE: lib/screens/student/messages/messages_screen.dart
// WHAT IT DOES : Old messages list.
// STATUS       : NOT USED anymore — replaced by connect/connect_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/user_avatar.dart';
import 'chat_screen.dart';

/// Student messages: conversation list plus pending chat requests.
class MessagesScreen extends StatefulWidget {
  MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final List<Conversation> _conversations = List.of(DummyData.conversations);
  String _query = '';

  List<Conversation> get _filtered =>
      _conversations.where((c) => c.peerName.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final active = _filtered.where((c) => c.status == ConversationStatus.active).toList();
    final requests = _filtered.where((c) => c.status == ConversationStatus.pending).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(automaticallyImplyLeading: false, title: Text('Messages')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search_rounded, size: 21),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 24),
              children: [
                if (requests.isNotEmpty) ...[
                  _SectionLabel('Chat Requests'),
                  ...requests.map((c) => _tile(context, c, request: true)),
                  SizedBox(height: 14),
                ],
                _SectionLabel('All Messages'),
                ...active.map((c) => _tile(context, c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Conversation c, {bool request = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
            );
            if (updated != null) setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    UserAvatar(name: c.peerName, colorHex: c.peerColor, size: 50),
                    if (c.unread > 0)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 1.5),
                          ),
                          constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${c.unread}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.peerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          Text(timeAgo(c.lastTime), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        request ? 'Chat request · ${c.lastMessage}' : c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: request ? AppColors.warning : AppColors.textSecondary,
                          fontWeight: request ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }
}
