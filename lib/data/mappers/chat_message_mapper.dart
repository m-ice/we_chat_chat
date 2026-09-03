import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;

import '../../domain/entities/chat_message.dart';

abstract final class ChatMessageMapper {
  static chat_core.Message toChatCore(
    ChatMessage message, {
    required String currentUserId,
  }) {
    return chat_core.Message.text(
      id: message.id,
      authorId: message.isFromCurrentUser
          ? currentUserId
          : message.peerId.toString(),
      createdAt: message.createdAt,
      text: message.text,
    );
  }
}
