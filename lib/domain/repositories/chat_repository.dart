import '../entities/chat_message.dart';
import '../entities/conversation.dart';
import '../entities/user.dart';

abstract interface class ChatRepository {
  /// Emits after a persisted message can change the conversation list.
  Stream<void> get conversationUpdates;

  Future<void> initialize();
  Future<List<Conversation>> getConversations();
  Future<List<ChatMessage>> getMessages(int peerId);
  Future<void> appendMessage(ChatMessage message, {User? peer});
  Future<bool> canSendMessage(int peerId);
}
