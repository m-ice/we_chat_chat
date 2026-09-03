import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/mappers/chat_message_mapper.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/ai_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class ChatThreadController extends GetxController {
  ChatThreadController(this.peer, this._chats, this._ai);

  static const currentUserId = 'current-user';
  final User peer;
  final ChatRepository _chats;
  final AiRepository _ai;
  final messages = <ChatMessage>[].obs;
  final awaitingReply = false.obs;
  final canSend = true.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final currentUser = Rxn<User>();
  late chat_core.InMemoryChatController chatController;

  @override
  void onInit() {
    super.onInit();
    chatController = chat_core.InMemoryChatController();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      try {
        currentUser.value = await Get.find<UserRepository>().getCurrentUser();
      } on Object {
        currentUser.value = null;
      }
      messages.assignAll(await _chats.getMessages(peer.id));
      await chatController.setMessages(
        messages
            .map(
              (message) => ChatMessageMapper.toChatCore(
                message,
                currentUserId: currentUserId,
              ),
            )
            .toList(),
        animated: false,
      );
      canSend.value = await _chats.canSendMessage(peer.id);
    } on Object {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || awaitingReply.value || !canSend.value) return;
    final message = ChatMessage(
      id: '${peer.id}-${DateTime.now().microsecondsSinceEpoch}',
      peerId: peer.id,
      text: text,
      isFromCurrentUser: true,
      createdAt: DateTime.now(),
    );
    await _chats.appendMessage(message, peer: peer);
    messages.add(message);
    await chatController.insertMessage(
      ChatMessageMapper.toChatCore(message, currentUserId: currentUserId),
    );
    canSend.value = false;
    if (peer.id == -1) await _replyFromAssistant();
  }

  Future<void> _replyFromAssistant() async {
    awaitingReply.value = true;
    try {
      final response = await _ai.generate(messages);
      final reply = ChatMessage(
        id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
        peerId: peer.id,
        text: response.text,
        isFromCurrentUser: false,
        createdAt: DateTime.now(),
      );
      await _chats.appendMessage(reply);
      messages.add(reply);
      await chatController.insertMessage(
        ChatMessageMapper.toChatCore(reply, currentUserId: currentUserId),
      );
      canSend.value = true;
    } on Object {
      canSend.value = true;
      AppToast.show('消息发送失败，请稍后再试');
    } finally {
      awaitingReply.value = false;
    }
  }

  Future<void> startVoiceCall() async {
    if (peer.id == -1) {
      AppToast.show('微撩助手暂不支持语音通话');
      return;
    }
    if (messages.isEmpty || messages.last.isFromCurrentUser) {
      AppToast.show('call_wait_for_reply'.tr);
      return;
    }
    await Get.toNamed(Routes.voiceCall, arguments: peer);
  }

  Future<chat_core.User?> resolveUser(String id) async {
    final user = id == currentUserId ? currentUser.value : peer;
    return chat_core.User(
      id: id,
      name: user?.nickname,
      imageSource: user?.avatarPath,
    );
  }

  @override
  void onClose() {
    chatController.dispose();
    super.onClose();
  }
}
