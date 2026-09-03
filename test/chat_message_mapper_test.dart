import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;
import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/data/mappers/chat_message_mapper.dart';
import 'package:we_chat_chat/domain/entities/chat_message.dart';

void main() {
  test('maps the domain text message without adding delivery semantics', () {
    final createdAt = DateTime.parse('2026-09-02T10:30:00+08:00');
    final result = ChatMessageMapper.toChatCore(
      ChatMessage(
        id: 'message-1',
        peerId: 7,
        text: '周末一起吃火锅吗？',
        isFromCurrentUser: true,
        createdAt: createdAt,
      ),
      currentUserId: '2',
    );

    expect(result, isA<chat_core.TextMessage>());
    final text = result as chat_core.TextMessage;
    expect(text.authorId, '2');
    expect(text.text, '周末一起吃火锅吗？');
    expect(text.createdAt, createdAt);
    expect(text.sentAt, isNull);
    expect(text.deliveredAt, isNull);
    expect(text.seenAt, isNull);
  });
}
