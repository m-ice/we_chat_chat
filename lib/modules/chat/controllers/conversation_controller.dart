import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/message_center_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'message_center_controller.dart';

class ConversationController extends GetxController {
  ConversationController(this._chats, this.messageCenter, this._social);

  final ChatRepository _chats;
  final MessageCenterRepository messageCenter;
  final SocialStateRepository _social;
  final conversations = <Conversation>[].obs;
  final contacts = <User>[].obs;
  final hasError = false.obs;
  final isLoading = true.obs;
  final quickUnreadCounts = <MessageCenterSection, int>{}.obs;
  StreamSubscription<void>? _chatUpdatesSubscription;
  StreamSubscription<void>? _socialChangesSubscription;

  User? get assistant {
    for (final conversation in conversations) {
      if (conversation.isAssistant) return conversation.peer;
    }
    return null;
  }

  List<User> get featuredContacts => contacts.take(4).toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    _chatUpdatesSubscription = _chats.conversationUpdates.listen((_) => load());
    _socialChangesSubscription = _social.changes.listen((_) => load());
    load();
  }

  @override
  void onClose() {
    _chatUpdatesSubscription?.cancel();
    _socialChangesSubscription?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    hasError.value = false;
    isLoading.value = true;
    try {
      conversations.assignAll(
        (await _chats.getConversations()).where(
          (conversation) =>
              conversation.isAssistant || _allows(conversation.peer.id),
        ),
      );
      await _loadQuickUnreadCounts();
    } on Object {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }

    try {
      final users = Get.find<UserRepository>();
      final currentUser = await users.getCurrentUser();
      contacts.assignAll(
        (await users.getUsers()).where(
          (user) => user.id != currentUser.id && _allows(user.id),
        ),
      );
    } on Object {
      contacts.assignAll(
        conversations
            .where((conversation) => !conversation.isAssistant)
            .map((conversation) => conversation.peer),
      );
    }
  }

  bool _allows(int userId) =>
      !_social.blockedIds.contains(userId) &&
      !_social.shieldedIds.contains(userId);

  Future<void> openChat(User peer) async {
    if (await _isCurrentUser(peer)) return;
    await Get.toNamed(Routes.chat, arguments: peer);
    await load();
  }

  Future<void> startVoiceCall(User peer) async {
    if (await _isCurrentUser(peer)) return;
    await Get.toNamed(Routes.voiceCall, arguments: peer);
  }

  Future<bool> _isCurrentUser(User peer) async {
    try {
      return (await Get.find<UserRepository>().getCurrentUser()).id == peer.id;
    } on Object {
      // Chat and calls stay unavailable until the local identity is known.
      return true;
    }
  }

  Future<void> openFeature(String route) async {
    await Get.toNamed(route);
    await _loadQuickUnreadCounts();
  }

  Future<void> _loadQuickUnreadCounts() async {
    final notices = await messageCenter.getSystemNotices();
    final relationships = await messageCenter.getRelationships();
    final visitors = await messageCenter.getVisitors();
    final calls = await messageCenter.getCallRecords();
    quickUnreadCounts.assignAll({
      MessageCenterSection.system: notices.where((item) => !item.isRead).length,
      MessageCenterSection.relationships: relationships.fold(
        0,
        (sum, item) => sum + item.unreadCount,
      ),
      MessageCenterSection.visitors: visitors
          .where((item) => !item.isRead)
          .length,
      MessageCenterSection.calls: calls.where((item) => !item.isRead).length,
    });
  }
}
