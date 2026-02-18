import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
        'read': read,
      };

  static ChatMessage fromMap(String id, Map<String, dynamic> map) {
    final sentAt = map['sentAt'];
    DateTime at = DateTime.now();
    if (sentAt is Timestamp) at = sentAt.toDate();
    else if (sentAt is String) at = DateTime.parse(sentAt);
    return ChatMessage(
      id: id,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      text: map['text'] as String,
      sentAt: at,
      read: map['read'] as bool? ?? false,
    );
  }
}

class ChatRoom {
  final String id;
  final List<String> participantIds;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastSenderId;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastSenderId,
  });

  static ChatRoom fromMap(String id, Map<String, dynamic> map) {
    final lastAt = map['lastMessageAt'];
    DateTime? at;
    if (lastAt is Timestamp) at = lastAt.toDate();
    else if (lastAt is String) at = DateTime.tryParse(lastAt);
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      lastMessageText: map['lastMessageText'] as String?,
      lastMessageAt: at,
      lastSenderId: map['lastSenderId'] as String?,
    );
  }
}
