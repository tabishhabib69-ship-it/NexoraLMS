// ===== FILE GUIDE: lib/screens/faculty/messages/chat_requests_screen.dart
// WHAT IT DOES : Chat requests from students.
// MANAGES      : Accept / reject requests or open the chat.
// USED BY      : faculty_messages_screen.dart.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/user_avatar.dart';
import '../../student/connect/chat_screen.dart';
import '../../../services/my_data.dart';

/// Faculty chat requests: accept / reject, or open the student's chat.
class ChatRequestsScreen extends StatefulWidget {
  ChatRequestsScreen({super.key});

  @override
  State<ChatRequestsScreen> createState() => _ChatRequestsScreenState();
}

class _ChatRequestsScreenState extends State<ChatRequestsScreen> {
  late final List<ChatRequest> _requests = [
    for (final r in DummyData.chatRequests)
      if (MyData.courseIds.any((id) => DummyData.courseById(id)?.code == r.courseCode)) r,
  ];

  void _accept(ChatRequest r) {
    setState(() {
      _requests.removeWhere((x) => x.id == r.id);
      DummyData.chatRequests.removeWhere((x) => x.id == r.id);
      // Create a conversation for the accepted request.
      final exists = MyData.conversations.any((c) => c.peerId == r.studentId);
      if (!exists) {
        DummyData.conversations.add(
          Conversation(
            id: 'cv${DateTime.now().microsecondsSinceEpoch}',
            peerId: r.studentId,
            peerName: r.studentName,
            peerRole: 'Student',
            peerColor: r.studentColor,
            lastMessage: 'Chat connected',
            lastTime: DateTime.now(),
            ownerId: MyData.id,
          ),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chat request from ${r.studentName} accepted')));
  }

  void _reject(ChatRequest r) {
    setState(() {
      _requests.removeWhere((x) => x.id == r.id);
      DummyData.chatRequests.removeWhere((x) => x.id == r.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request from ${r.studentName} declined')));
  }

  void _openChat(ChatRequest r) {
    final convo = Conversation(
      id: 'cv${r.id}',
      peerId: r.studentId,
      peerName: r.studentName,
      peerRole: 'Student',
      peerColor: r.studentColor,
      lastMessage: r.message,
      lastTime: r.date,
      ownerId: MyData.id,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: convo)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Chat Requests')),
      body: _requests.isEmpty
          ? EmptyState(
              icon: Icons.mark_chat_read_rounded,
              title: 'No pending requests',
              message: 'New chat requests from students will appear here.',
            )
          : ListView.separated(
              padding: EdgeInsets.all(18),
              itemCount: _requests.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = _requests[i];
                return Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(name: r.studentName, colorHex: r.studentColor, size: 48),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.studentName,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${r.courseCode} · ${timeAgo(r.date)}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '"${r.message}"',
                          style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: BorderSide(color: AppColors.danger),
                                minimumSize: Size.fromHeight(44),
                              ),
                              onPressed: () => _reject(r),
                              icon: Icon(Icons.close_rounded, size: 18),
                              label: Text('Reject'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                minimumSize: Size.fromHeight(44),
                              ),
                              onPressed: () => _openChat(r),
                              icon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              label: Text('Preview'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                                minimumSize: Size.fromHeight(44),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: () => _accept(r),
                              icon: Icon(Icons.check_rounded, size: 18),
                              label: Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
