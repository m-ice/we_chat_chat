import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/bindings/initial_binding.dart';
import 'package:we_chat_chat/domain/entities/chat_message.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/ai_repository.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/domain/repositories/message_center_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/modules/chat/controllers/chat_thread_controller.dart';
import 'package:we_chat_chat/modules/chat/controllers/conversation_controller.dart';
import 'package:we_chat_chat/modules/profile/controllers/blacklist_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    InitialBinding(preferences).dependencies();
  });

  tearDown(Get.reset);

  test(
    'a persisted message refreshes the conversation list immediately',
    () async {
      final chats = Get.find<ChatRepository>();
      final controller = ConversationController(
        chats,
        Get.find<MessageCenterRepository>(),
        Get.find<SocialStateRepository>(),
      );
      controller.onInit();
      await controller.load();

      const peer = User(
        id: 98001,
        nickname: '即时会话用户',
        age: 25,
        gender: '女',
        hobbies: [],
        avatarPath: 'assets/images/avatar/img_verified_user_01.png',
        intro: '',
        isVerified: false,
      );
      expect(
        controller.conversations.any((item) => item.peer.id == peer.id),
        isFalse,
      );

      final added = Completer<void>();
      final worker = ever(controller.conversations, (items) {
        if (items.any((item) => item.peer.id == peer.id) &&
            !added.isCompleted) {
          added.complete();
        }
      });

      await chats.appendMessage(
        ChatMessage(
          id: 'instant-conversation',
          peerId: peer.id,
          text: '现在就能看见这条会话',
          isFromCurrentUser: true,
          createdAt: DateTime.now(),
        ),
        peer: peer,
      );

      await added.future.timeout(const Duration(seconds: 1));
      expect(
        controller.conversations
            .firstWhere((item) => item.peer.id == peer.id)
            .preview,
        '现在就能看见这条会话',
      );
      worker.dispose();
      controller.onClose();
    },
  );

  test(
    'blocking hides the conversation and chat history for that user',
    () async {
      final users = Get.find<UserRepository>();
      final currentUser = await users.getCurrentUser();
      final peer = (await users.getUsers()).firstWhere(
        (user) => user.id != currentUser.id,
      );
      final chats = Get.find<ChatRepository>();
      final social = Get.find<SocialStateRepository>();
      await chats.appendMessage(
        ChatMessage(
          id: 'blocked-conversation',
          peerId: peer.id,
          text: '这条消息会在拉黑后隐藏',
          isFromCurrentUser: false,
          createdAt: DateTime.now(),
        ),
        peer: peer,
      );

      final conversations = ConversationController(
        chats,
        Get.find<MessageCenterRepository>(),
        social,
      );
      conversations.onInit();
      await conversations.load();
      expect(
        conversations.conversations.any((item) => item.peer.id == peer.id),
        isTrue,
      );

      final removed = Completer<void>();
      final worker = ever(conversations.conversations, (items) {
        if (!items.any((item) => item.peer.id == peer.id) &&
            !removed.isCompleted) {
          removed.complete();
        }
      });
      await social.block(peer.id);
      await removed.future.timeout(const Duration(seconds: 1));

      final thread = ChatThreadController(
        peer,
        chats,
        Get.find<AiRepository>(),
        social,
      );
      thread.onInit();
      await thread.load();
      expect(thread.messages, isEmpty);
      expect(thread.canSend.value, isFalse);

      worker.dispose();
      thread.onClose();
      conversations.onClose();
    },
  );

  test('blacklist tracks persisted removal of a user', () async {
    final users = Get.find<UserRepository>();
    final currentUser = await users.getCurrentUser();
    final peer = (await users.getUsers()).firstWhere(
      (user) => user.id != currentUser.id,
    );
    final social = Get.find<SocialStateRepository>();
    await social.block(peer.id);

    final controller = BlacklistController(users, social);
    controller.onInit();
    await controller.load();
    expect(controller.blockedUsers.map((item) => item.id), contains(peer.id));

    final removed = Completer<void>();
    final worker = ever(controller.blockedUsers, (items) {
      if (!items.any((item) => item.id == peer.id) && !removed.isCompleted) {
        removed.complete();
      }
    });
    await social.unblock(peer.id);
    await removed.future.timeout(const Duration(seconds: 1));
    expect(social.blockedIds, isNot(contains(peer.id)));

    worker.dispose();
    controller.onClose();
  });
}
