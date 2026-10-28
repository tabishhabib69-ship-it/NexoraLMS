// ===== FILE GUIDE: lib/screens/student/connect/chat_screen.dart
// WHAT IT DOES : One chat conversation (direct or study group).
// MANAGES      : Message bubbles, date separators, send text, attach photo (local demo only).
// USED BY      : Connect, course discussion, faculty messages and enrollment manager.
// ======================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/dummy_data.dart';
import '../../../models/message.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/uni_widgets.dart';
import 'study_group_screen.dart';

/// One conversation (direct or study group) with date separators.
/// Messages are stored locally and are not delivered to anyone.
class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  Conversation get c => widget.conversation;
  List<ChatMessage> get _messages => DummyData.messages.putIfAbsent(c.id, () => []);

  @override
  void initState() {
    super.initState();
    c.unread = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom(jump: true));
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom({bool jump = false}) {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    jump ? _scroll.jumpTo(max) : _scroll.animateTo(max, duration: Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _send(String text, {Uint8List? image}) {
    final body = text.trim();
    if (body.isEmpty && image == null) return;
    final me = SessionService.currentUser ?? DummyData.student;
    final preview = image != null && body.isEmpty ? '📷 Photo' : body;
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'm${DateTime.now().microsecondsSinceEpoch}',
          senderId: me.id,
          text: body,
          time: DateTime.now(),
          fromMe: true,
          image: image,
        ),
      );
      c.lastMessage = c.isGroup ? 'You: $preview' : preview;
      c.lastTime = DateTime.now();
    });
    _text.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  Future<void> _attach() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1280);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      // Any text already typed is sent as the photo's caption.
      _send(_text.text, image: bytes);
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open the photo picker on this device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = c.isGroup ? DummyData.studyGroups.where((g) => g.id == c.groupId).firstOrNull : null;
    final msgs = _messages;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  CircleBackButton(),
                  SizedBox(width: 12),
                  group != null
                      ? Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: AppColors.wineGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.groups_outlined, color: Colors.white),
                        )
                      : InitialsCircle(initials: initialsOf(c.peerName), size: 46),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary),
                        ),
                        Text(
                          group != null ? '${group.memberIds.length} members · tap info for details' : c.peerRole,
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (group != null)
                    IconButton(
                      tooltip: 'Group info',
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (_) => StudyGroupScreen(group: group))),
                      icon: Icon(Icons.info_outline_rounded, color: AppColors.textPrimary),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.warningSoft,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Text(
                'Demo chat — messages stay on this device and are not delivered.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.warning),
              ),
            ),
            Expanded(
              child: msgs.isEmpty
                  ? Center(
                      child: Text('No messages yet — say hello!', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: msgs.length,
                      itemBuilder: (_, i) {
                        final m = msgs[i];
                        final showDate = i == 0 || formatDayLabel(msgs[i - 1].time) != formatDayLabel(m.time);
                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatDayLabel(m.time),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            _Bubble(message: m, showSender: group != null && !m.fromMe),
                          ],
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Attach photo',
                        onPressed: _attach,
                        icon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _send,
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _send(_text.text),
                          child: Ink(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: AppColors.wineGradient,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.send_rounded, color: Colors.white, size: 20, semanticLabel: 'Send'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSender;

  const _Bubble({required this.message, required this.showSender});

  /// Full-screen, zoomable view of a chat photo.
  static void _openPhoto(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: InteractiveViewer(child: Center(child: Image.memory(bytes))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    var text = message.text;
    String? sender;
    final sep = text.indexOf(': ');
    if (showSender && sep > 0 && sep < 20) {
      sender = text.substring(0, sep);
      text = text.substring(sep + 2);
    } else if (showSender) {
      sender = DummyData.userById(message.senderId)?.name.split(' ').first;
    }
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
        decoration: BoxDecoration(
          gradient: mine ? AppColors.wineGradient : null,
          color: mine ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 6),
            bottomRight: Radius.circular(mine ? 6 : 20),
          ),
          boxShadow: mine ? null : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (sender != null)
              Text(
                sender,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sand),
              ),
            if (message.image != null)
              Padding(
                padding: EdgeInsets.only(top: 2, bottom: 6),
                child: GestureDetector(
                  onTap: () => _openPhoto(context, message.image!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 260),
                      child: Image.memory(message.image!, fit: BoxFit.cover, semanticLabel: 'Photo'),
                    ),
                  ),
                ),
              ),
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(fontSize: 15, height: 1.35, color: mine ? Colors.white : AppColors.textPrimary),
              ),
            SizedBox(height: 3),
            Text(
              formatClock(message.time),
              style: TextStyle(fontSize: 11, color: mine ? Colors.white.withValues(alpha: 0.7) : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
