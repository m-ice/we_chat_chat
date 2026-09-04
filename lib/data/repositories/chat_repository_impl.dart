import 'dart:async';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/membership_wallet_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/vaules/app_image_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message_dto.dart';
import '../providers/asset_json_provider.dart';
import '../providers/local_chat_storage.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._storage,
    this._assets,
    this._users,
    this._wallet,
    this._preferences,
  );

  static const assistantId = -1;
  static const _giftGrantedKey = 'mt_new_user_coin_gift_granted';
  static const _giftText = '欢迎加入微撩组队！为新用户赠送 100 微撩币，快去结识志同道合的伙伴吧～';
  final LocalChatStorage _storage;
  final AssetJsonProvider _assets;
  final UserRepository _users;
  final MembershipWalletRepository _wallet;
  final SharedPreferences _preferences;
  final _conversationUpdates = StreamController<void>.broadcast();
  Future<void>? _initialization;

  @override
  Stream<void> get conversationUpdates => _conversationUpdates.stream;

  @override
  Future<void> initialize() {
    final pending = _initialization;
    if (pending != null) return pending;
    final operation = _initialize();
    _initialization = operation;
    return operation.whenComplete(() {
      if (identical(_initialization, operation)) _initialization = null;
    });
  }

  Future<void> _initialize() async {
    await _storage.initialize(_assets);
    if (_preferences.getBool(_giftGrantedKey) ?? false) return;
    final now = DateTime.now();
    await _storage.append(
      ChatMessageDto(
        id: 'assistant-coin-gift-${now.microsecondsSinceEpoch}',
        peerId: assistantId,
        text: _giftText,
        isFromCurrentUser: false,
        createdAt: now,
      ),
    );
    await _wallet.addCoins(100);
    await _preferences.setBool(_giftGrantedKey, true);
  }

  @override
  Future<void> appendMessage(ChatMessage message, {User? peer}) async {
    await initialize();
    if (peer != null) {
      await _storage.savePeerSnapshot(
        id: peer.id,
        nickname: peer.nickname,
        avatarPath: peer.avatarPath,
      );
    }
    await _storage.append(ChatMessageDto.fromEntity(message));
    _conversationUpdates.add(null);
  }

  @override
  Future<bool> canSendMessage(int peerId) async {
    final messages = await getMessages(peerId);
    return messages.isEmpty || !messages.last.isFromCurrentUser;
  }

  @override
  Future<List<ChatMessage>> getMessages(int peerId) async {
    await initialize();
    final messages = _storage
        .readMessages()
        .where((message) => message.peerId == peerId)
        .map((message) => message.toEntity())
        .toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  @override
  Future<List<Conversation>> getConversations() async {
    await initialize();
    final messages = _storage.readMessages();
    final users = {for (final user in await _users.getUsers()) user.id: user};
    for (final snapshot in _storage.readPeerSnapshots()) {
      users.putIfAbsent(
        snapshot.id,
        () => User(
          id: snapshot.id,
          nickname: snapshot.nickname,
          age: 0,
          gender: '',
          hobbies: const [],
          avatarPath: snapshot.avatarPath,
          intro: '',
          isVerified: false,
        ),
      );
    }
    users[assistantId] = const User(
      id: assistantId,
      nickname: '微撩助手',
      age: 0,
      gender: '',
      hobbies: [],
      avatarPath: AppImageString.chatAssistantAvatar,
      intro: '',
      isVerified: false,
    );

    final latestByPeer = <int, ChatMessageDto>{};
    for (final message in messages) {
      final latest = latestByPeer[message.peerId];
      if (latest == null || message.createdAt.isAfter(latest.createdAt)) {
        latestByPeer[message.peerId] = message;
      }
    }

    final conversations = latestByPeer.entries
        .where((entry) => users.containsKey(entry.key))
        .map(
          (entry) => Conversation(
            peer: users[entry.key]!,
            preview: entry.value.text,
            updatedAt: entry.value.createdAt,
            isAssistant: entry.key == assistantId,
          ),
        )
        .toList();
    conversations.sort((a, b) {
      if (a.isAssistant != b.isAssistant) return a.isAssistant ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return conversations;
  }
}
