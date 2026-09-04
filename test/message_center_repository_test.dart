import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/message_center_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/chat_message.dart';
import 'package:we_chat_chat/domain/entities/conversation.dart';
import 'package:we_chat_chat/domain/entities/message_center_item.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/modules/chat/controllers/conversation_controller.dart';
import 'package:we_chat_chat/modules/chat/controllers/message_center_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'message center persists all read states and relationship state',
    () async {
      const repository = MessageCenterRepositoryImpl();

      final notices = await repository.getSystemNotices();
      expect(notices, hasLength(1));
      expect(notices.single.isRead, isFalse);

      await repository.markSystemNoticesRead([notices.single.id]);
      expect((await repository.getSystemNotices()).single.isRead, isTrue);

      final relationships = await repository.getRelationships();
      expect(
        relationships.map((item) => item.unreadCount),
        containsAll([2, 1]),
      );

      final relationship = relationships.first;
      await repository.markRelationshipsRead([relationship.person.id]);
      final relationshipAfterRead = (await repository.getRelationships()).first;
      expect(relationshipAfterRead.unreadCount, 0);

      await repository.setRelationshipState(
        relationship.person.id,
        RelationshipState.removed,
      );
      final reloaded = (await repository.getRelationships()).first;
      expect(reloaded.state, RelationshipState.removed);

      final visitors = await repository.getVisitors();
      expect(visitors, isNotEmpty);
      expect(visitors.first.isRead, isFalse);
      await repository.markVisitorsRead([visitors.first.person.id]);
      expect((await repository.getVisitors()).first.isRead, isTrue);

      final calls = await repository.getCallRecords();
      expect(calls, isNotEmpty);
      expect(calls.first.isRead, isFalse);
      await repository.markCallRecordsRead([calls.first.id]);
      expect((await repository.getCallRecords()).first.isRead, isTrue);
    },
  );

  test('demo callbacks are appended to the call history', () async {
    const repository = MessageCenterRepositoryImpl();
    const person = MessageCenterPerson(
      id: 900,
      nickname: '测试用户',
      avatarPath: '',
    );

    final record = await repository.addDemoCallback(person);
    final records = await repository.getCallRecords();

    expect(record.state, CallState.demo);
    expect(record.durationSeconds, 0);
    expect(records.first.id, record.id);
  });

  test('damaged local overrides do not hide approved seed records', () async {
    SharedPreferences.setMockInitialValues({
      'message_center_relationships_v1': '{broken',
      'message_center_demo_callbacks_v1': ['not-json'],
    });
    const repository = MessageCenterRepositoryImpl();

    expect(await repository.getRelationships(), hasLength(4));
    expect(await repository.getCallRecords(), hasLength(4));
  });

  test(
    'opening a message-center section clears only its unread badge',
    () async {
      const repository = MessageCenterRepositoryImpl();
      final conversation = ConversationController(
        _EmptyChatRepository(),
        repository,
        _EmptySocialStateRepository(),
      );

      await conversation.load();
      expect(conversation.quickUnreadCounts, {
        MessageCenterSection.system: 1,
        MessageCenterSection.relationships: 3,
        MessageCenterSection.visitors: 4,
        MessageCenterSection.calls: 4,
      });

      final visitors = MessageCenterController(
        repository,
        MessageCenterSection.visitors,
      );
      await visitors.load();
      expect(visitors.visitors.every((item) => item.isRead), isTrue);

      await conversation.load();
      expect(conversation.quickUnreadCounts[MessageCenterSection.visitors], 0);
      expect(conversation.quickUnreadCounts[MessageCenterSection.system], 1);
      expect(
        conversation.quickUnreadCounts[MessageCenterSection.relationships],
        3,
      );
      expect(conversation.quickUnreadCounts[MessageCenterSection.calls], 4);
    },
  );
}

class _EmptyChatRepository implements ChatRepository {
  @override
  Future<void> appendMessage(ChatMessage message, {User? peer}) async {}

  @override
  Future<bool> canSendMessage(int peerId) async => true;

  @override
  Future<List<Conversation>> getConversations() async => const [];

  @override
  Future<List<ChatMessage>> getMessages(int peerId) async => const [];

  @override
  Future<void> initialize() async {}
}

class _EmptySocialStateRepository implements SocialStateRepository {
  @override
  Set<int> get blockedIds => const {};

  @override
  Set<int> get followedIds => const {};

  @override
  Set<int> get invitedIds => const {};

  @override
  Set<int> get pendingJoinIds => const {};

  @override
  Set<int> get shieldedIds => const {};

  @override
  Future<void> block(int userId) async {}

  @override
  Future<void> setFollowed(int userId, bool value) async {}

  @override
  Future<void> setInvited(int userId, bool value) async {}

  @override
  Future<void> setPendingJoin(int userId, bool value) async {}

  @override
  Future<void> shield(int userId) async {}
}
