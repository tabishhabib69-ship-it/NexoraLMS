// ===== FILE GUIDE: lib/models/message.dart
// WHAT IT DOES : Data classes for chat.
// MANAGES      : ChatMessage, Conversation (direct or study-group) and ChatRequest.
// USED BY      : Connect, chat, faculty messages and enrollment manager screens.
// ======================================================================

import 'dart:typed_data';

/// A single chat message.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  final bool fromMe;

  /// Optional photo picked from the gallery (kept in memory for the demo).
  final Uint8List? image;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    required this.fromMe,
    this.image,
  });
}

/// Status of a conversation.
enum ConversationStatus { active, pending }

/// A conversation shown in the chat list.
class Conversation {
  final String id;
  final String peerId;
  final String peerName;
  final String peerRole;
  final String peerColor;
  String lastMessage;
  DateTime lastTime;
  int unread;
  ConversationStatus status;

  /// Set for study-group chats (links to a [StudyGroup] id).
  final String? groupId;

  /// The user whose inbox this conversation belongs to (private to them).
  final String ownerId;

  Conversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerRole,
    required this.peerColor,
    required this.lastMessage,
    required this.lastTime,
    this.unread = 0,
    this.status = ConversationStatus.active,
    this.groupId,
    required this.ownerId,
  });

  bool get isGroup => groupId != null;
}

/// A pending chat request (mainly for faculty from students).
class ChatRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String studentColor;
  final String courseCode;
  final String message;
  final DateTime date;

  const ChatRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentColor,
    required this.courseCode,
    required this.message,
    required this.date,
  });
}
