import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/domain/entities/ai_response.dart';
import 'package:we_chat_chat/domain/entities/chat_message.dart';
import 'package:we_chat_chat/domain/entities/city_user.dart';
import 'package:we_chat_chat/domain/entities/conversation.dart';
import 'package:we_chat_chat/domain/entities/message_center_item.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/ai_repository.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/domain/repositories/message_center_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/modules/chat/controllers/chat_thread_controller.dart';
import 'package:we_chat_chat/modules/chat/views/chat_page.dart';
import 'package:we_chat_chat/modules/chat/views/system_messages_page.dart';

import 'helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('chat uses flutter chat UI with Figma bubbles and composer', (
    tester,
  ) async {
    _configurePhoneView(tester);
    const peer = User(
      id: 7,
      nickname: '零度晚风',
      age: 25,
      gender: '女',
      hobbies: [],
      avatarPath: 'assets/images/chat_system/chat_peer_avatar.png',
      intro: '',
      isVerified: false,
    );
    const currentUser = User(
      id: 1,
      nickname: '我',
      age: 25,
      gender: '女',
      hobbies: [],
      avatarPath: 'assets/images/chat_system/chat_current_avatar.png',
      intro: '',
      isVerified: false,
    );
    final repository = _ChatRepository();
    Get.put<UserRepository>(_UserRepository(currentUser));
    Get.put(ChatThreadController(peer, repository, _AiRepository()));

    await tester.pumpWidget(buildTestApp(const ChatPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('flutter-chat-ui')), findsOneWidget);
    expect(find.text('零度晚风'), findsOneWidget);
    expect(find.text('Hello，晚上好！'), findsNWidgets(2));
    expect(find.text('晚上好啊'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-more-button')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chat-message-input')),
      '新的消息',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('chat-send-button')));
    await tester.pumpAndSettle();
    expect(repository.messages.last.text, '新的消息');
  });

  testWidgets('system messages follow the Figma bubble geometry', (
    tester,
  ) async {
    _configurePhoneView(tester);

    await tester.pumpWidget(
      buildTestApp(
        SystemMessagesPage(
          repository: _MessageCenterRepository(),
          assistant: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('系统消息'), findsOneWidget);
    expect(find.text('欢迎来到微撩！'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('message-header-artwork'))),
      const Size(375, 255),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('system-notice-welcome'))).dy,
      closeTo(107, .1),
    );
  });
}

void _configurePhoneView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 144, bottom: 96);
  tester.view.viewPadding = const FakeViewPadding(top: 144, bottom: 96);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
}

class _ChatRepository implements ChatRepository {
  final messages = <ChatMessage>[
    ChatMessage(
      id: '1',
      peerId: 7,
      text: 'Hello，晚上好！',
      isFromCurrentUser: true,
      createdAt: DateTime(2026, 9, 3, 20),
    ),
    ChatMessage(
      id: '2',
      peerId: 7,
      text: '晚上好啊',
      isFromCurrentUser: false,
      createdAt: DateTime(2026, 9, 3, 20, 1),
    ),
    ChatMessage(
      id: '3',
      peerId: 7,
      text: 'Hello，晚上好！',
      isFromCurrentUser: true,
      createdAt: DateTime(2026, 9, 3, 20, 2),
    ),
  ];

  @override
  Future<void> appendMessage(ChatMessage message, {User? peer}) async {
    messages.add(message);
  }

  @override
  Future<bool> canSendMessage(int peerId) async => true;

  @override
  Future<List<Conversation>> getConversations() async => const [];

  @override
  Future<List<ChatMessage>> getMessages(int peerId) async =>
      List.unmodifiable(messages);

  @override
  Future<void> initialize() async {}
}

class _AiRepository implements AiRepository {
  @override
  Future<AiResponse> generate(List<ChatMessage> history) async =>
      const AiResponse('晚上好');
}

class _UserRepository implements UserRepository {
  _UserRepository(this.currentUser);

  final User currentUser;

  @override
  Future<List<CityUser>> getCityUsers() async => const [];

  @override
  Future<User> getCurrentUser() async => currentUser;

  @override
  Future<List<User>> getUsers() async => [currentUser];

  @override
  Future<List<CityUser>> getVerifiedUsers() async => const [];
}

class _MessageCenterRepository implements MessageCenterRepository {
  @override
  Future<List<SystemNotice>> getSystemNotices() async => [
    SystemNotice(
      id: 'welcome',
      content: '欢迎来到微撩！',
      avatarPath: 'assets/images/chat_detail/system_assistant.png',
      createdAt: DateTime(2026, 9, 3),
      isRead: false,
    ),
  ];

  @override
  Future<void> markSystemNoticesRead(Iterable<String> ids) async {}

  @override
  Future<void> markRelationshipsRead(Iterable<int> personIds) async {}

  @override
  Future<List<IntimateRelationship>> getRelationships() async => const [];

  @override
  Future<void> setRelationshipState(
    int personId,
    RelationshipState state,
  ) async {}

  @override
  Future<void> markVisitorsRead(Iterable<int> personIds) async {}

  @override
  Future<List<VisitorRecord>> getVisitors() async => const [];

  @override
  Future<void> markCallRecordsRead(Iterable<String> recordIds) async {}

  @override
  Future<List<CallRecord>> getCallRecords() async => const [];

  @override
  Future<CallRecord> addDemoCallback(MessageCenterPerson person) =>
      throw UnimplementedError();
}
