// ===== FILE GUIDE: lib/screens/faculty/messages/faculty_messages_screen.dart
// WHAT IT DOES : Faculty messages.
// MANAGES      : Conversation list with students and a link to chat requests.
// USED BY      : faculty_shell.dart (Messages tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/user_avatar.dart';
import '../../student/connect/chat_screen.dart';
import 'chat_requests_screen.dart';
import '../../../services/my_data.dart';

/// Faculty one-to-one messaging with students, plus a link to chat requests.
class FacultyMessagesScreen extends StatefulWidget {
  FacultyMessagesScreen({super.key});

  @override
  State<FacultyMessagesScreen> createState() => _FacultyMessagesScreenState();
}

class _FacultyMessagesScreenState extends State<FacultyMessagesScreen> {
  late final List<Conversation> _conversations = MyData.conversations
      .where((c) => c.status == ConversationStatus.active)
      .toList();
  String _query = '';

  List<Conversation> get _filtered =>
      _conversations.where((c) => c.peerName.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final pending = DummyData.chatRequests.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Messages'),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              backgroundColor: AppColors.danger,
              child: Icon(Icons.person_add_alt_rounded),
            ),
            tooltip: 'Chat requests',
          ),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (pending > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Material(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRequestsScreen()));
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_alt_rounded, color: AppColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$pending pending chat request${pending == 1 ? '' : 's'}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search_rounded, size: 21),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('No conversations yet', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _tile(items[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Conversation c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)));
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                UserAvatar(name: c.peerName, colorHex: c.peerColor, size: 50),
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
                        c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (c.unread > 0)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '${c.unread}',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
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
