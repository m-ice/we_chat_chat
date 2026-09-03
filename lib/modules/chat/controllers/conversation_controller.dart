import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../data/repositories/message_center_repository_impl.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/message_center_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class ConversationController extends GetxController {
  ConversationController(this._chats, [MessageCenterRepository? messageCenter])
    : messageCenter = messageCenter ?? const MessageCenterRepositoryImpl();

  final ChatRepository _chats;
  final MessageCenterRepository messageCenter;
  final conversations = <Conversation>[].obs;
  final contacts = <User>[].obs;
  final hasError = false.obs;
  final isLoading = true.obs;

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
    load();
  }

  Future<void> load() async {
    hasError.value = false;
    isLoading.value = true;
    try {
      conversations.assignAll(await _chats.getConversations());
    } on Object {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }

    try {
      final users = Get.find<UserRepository>();
      final currentUser = await users.getCurrentUser();
      contacts.assignAll(
        (await users.getUsers()).where((user) => user.id != currentUser.id),
      );
    } on Object {
      contacts.assignAll(
        conversations
            .where((conversation) => !conversation.isAssistant)
            .map((conversation) => conversation.peer),
      );
    }
  }

  Future<void> openChat(User peer) async {
    await Get.toNamed(Routes.chat, arguments: peer);
    await load();
  }

  Future<void> startVoiceCall(User peer) async {
    await Get.toNamed(Routes.voiceCall, arguments: peer);
  }
}
