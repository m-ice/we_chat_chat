class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.peerId,
    required this.text,
    required this.isFromCurrentUser,
    required this.createdAt,
  });

  final String id;
  final int peerId;
  final String text;
  final bool isFromCurrentUser;
  final DateTime createdAt;
}
