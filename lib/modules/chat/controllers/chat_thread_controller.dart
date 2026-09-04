import 'dart:async';

import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/mappers/chat_message_mapper.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/ai_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class ChatThreadController extends GetxController {
  ChatThreadController(this.peer, this._chats, this._ai, this._social);

  static const currentUserId = 'current-user';
  final User peer;
  final ChatRepository _chats;
  final AiRepository _ai;
  final SocialStateRepository _social;
  final messages = <ChatMessage>[].obs;
  final awaitingReply = false.obs;
  final canSend = true.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final currentUser = Rxn<User>();
  late chat_core.InMemoryChatController chatController;
  StreamSubscription<void>? _socialChangesSubscription;

  @override
  void onInit() {
    super.onInit();
    chatController = chat_core.InMemoryChatController();
    _socialChangesSubscription = _social.changes.listen((_) => load());
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
      if (isBlocked) {
        messages.clear();
        canSend.value = false;
        return;
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
    if (isBlocked) return;
    if (await _isSelfPeer()) return;
    final text = raw.trim();
    if (text.isEmpty || awaitingReply.value || !canSend.value) return;
    canSend.value = false;
    final message = ChatMessage(
      id: '${peer.id}-${DateTime.now().microsecondsSinceEpoch}',
      peerId: peer.id,
      text: text,
      isFromCurrentUser: true,
      createdAt: DateTime.now(),
    );
    try {
      await _chats.appendMessage(message, peer: peer);
      messages.add(message);
      await chatController.insertMessage(
        ChatMessageMapper.toChatCore(message, currentUserId: currentUserId),
      );
      if (peer.id == -1) await _replyFromAssistant();
    } on Object {
      canSend.value = true;
      AppToast.show('chat_send_failed'.tr);
    }
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
      AppToast.show('chat_send_failed'.tr);
    } finally {
      awaitingReply.value = false;
    }
  }

  Future<void> startVoiceCall() async {
    if (isBlocked) return;
    if (await _isSelfPeer()) return;
    if (peer.id == -1) {
      AppToast.show('chat_assistant_no_call'.tr);
      return;
    }
    if (messages.isEmpty || messages.last.isFromCurrentUser) {
      AppToast.show('call_wait_for_reply'.tr);
      return;
    }
    await Get.toNamed(Routes.voiceCall, arguments: peer);
  }

  Future<void> openPeerProfile() async {
    if (!canOpenPeerProfile || await _isSelfPeer()) return;
    await _openUserProfile(peer);
  }

  Future<void> openCurrentUserProfile() async {
    final user = currentUser.value;
    if (user == null) return;
    await _openUserProfile(user);
  }

  bool get isSelfPeer => currentUser.value?.id == peer.id;
  bool get canOpenPeerProfile => peer.id != -1 && !isSelfPeer;
  bool get isBlocked => _social.blockedIds.contains(peer.id);

  Future<bool> _isSelfPeer() async {
    final knownCurrentUser = currentUser.value;
    if (knownCurrentUser != null) return knownCurrentUser.id == peer.id;
    try {
      final loadedCurrentUser = await Get.find<UserRepository>()
          .getCurrentUser();
      currentUser.value = loadedCurrentUser;
      return loadedCurrentUser.id == peer.id;
    } on Object {
      // Sending or starting a call requires a verified local identity.
      return true;
    }
  }

  Future<void> _openUserProfile(User user) async {
    await Get.toNamed<void>(
      Routes.userDetail,
      arguments: <String, Object>{'userId': user.id, 'user': user},
    );
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
    _socialChangesSubscription?.cancel();
    chatController.dispose();
    super.onClose();
  }
}
