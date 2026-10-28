// ===== FILE GUIDE: lib/screens/student/messages/chat_screen.dart
// WHAT IT DOES : Old chat screen.
// STATUS       : NOT USED anymore — replaced by connect/chat_screen.dart. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/user_avatar.dart';

/// One-to-one chat screen with a message list and send bar.
class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages = List.of(DummyData.messages[widget.conversation.id] ?? <ChatMessage>[]);

  @override
  void initState() {
    super.initState();
    widget.conversation.unread = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'ms${DateTime.now().microsecondsSinceEpoch}',
          senderId: 'me',
          text: text,
          time: DateTime.now(),
          fromMe: true,
        ),
      );
      widget.conversation.lastMessage = text;
      widget.conversation.lastTime = DateTime.now();
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(name: c.peerName, colorHex: c.peerColor, size: 40, fontSize: 14),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(c.peerRole, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            icon: Icon(Icons.call_outlined, color: AppColors.primary),
            onPressed: () =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling feature coming soon'))),
          ),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No messages yet',
                    message: 'Say hello to start the conversation.',
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _bubble(_messages[i]),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: EdgeInsets.fromLTRB(12, 10, 8, 10 + MediaQuery.of(context).viewInsets.bottom * 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Attach file',
                  icon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 6),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: _send,
                  icon: Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage m) {
    final me = m.fromMe;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: me ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(me ? 16 : 4),
            bottomRight: Radius.circular(me ? 4 : 16),
          ),
          border: me ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m.text,
              style: TextStyle(fontSize: 14.5, color: me ? Colors.white : AppColors.textPrimary, height: 1.35),
            ),
            SizedBox(height: 4),
            Text(
              formatClock(m.time),
              style: TextStyle(fontSize: 10.5, color: me ? Colors.white70 : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
