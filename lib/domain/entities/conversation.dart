import 'user.dart';

class Conversation {
  const Conversation({
    required this.peer,
    required this.preview,
    required this.updatedAt,
    required this.isAssistant,
    this.unreadCount = 0,
  });

  final User peer;
  final String preview;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isAssistant;
}
