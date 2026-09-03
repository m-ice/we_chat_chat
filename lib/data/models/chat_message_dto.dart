import '../../domain/entities/chat_message.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.peerId,
    required this.text,
    required this.isFromCurrentUser,
    required this.createdAt,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) => ChatMessageDto(
    id: json['id'] as String,
    peerId: json['peerId'] as int,
    text: json['text'] as String,
    isFromCurrentUser: json['isFromCurrentUser'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  factory ChatMessageDto.fromEntity(ChatMessage message) => ChatMessageDto(
    id: message.id,
    peerId: message.peerId,
    text: message.text,
    isFromCurrentUser: message.isFromCurrentUser,
    createdAt: message.createdAt,
  );

  final String id;
  final int peerId;
  final String text;
  final bool isFromCurrentUser;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'peerId': peerId,
    'text': text,
    'isFromCurrentUser': isFromCurrentUser,
    'createdAt': createdAt.toIso8601String(),
  };

  ChatMessage toEntity() => ChatMessage(
    id: id,
    peerId: peerId,
    text: text,
    isFromCurrentUser: isFromCurrentUser,
    createdAt: createdAt,
  );
}
