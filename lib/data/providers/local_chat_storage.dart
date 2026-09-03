import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/data_exception.dart';
import '../models/chat_message_dto.dart';
import 'asset_json_provider.dart';

class LocalChatStorage {
  LocalChatStorage(this._preferences);

  static const _initializedKey = 'chat_seed_initialized_v1';
  static const _messagesKey = 'chat_messages_v1';
  static const _peerSnapshotsKey = 'chat_peer_snapshots_v1';

  final SharedPreferences _preferences;

  Future<void> initialize(AssetJsonProvider assets) async {
    if ((_preferences.getBool(_initializedKey) ?? false) &&
        _preferences.getString(_messagesKey) != null) {
      return;
    }
    final seed = await assets.readList('assets/mock/chat_messages.json');
    await _preferences.setString(_messagesKey, jsonEncode(seed));
    await _preferences.setBool(_initializedKey, true);
  }

  List<ChatMessageDto> readMessages() {
    final source = _preferences.getString(_messagesKey);
    if (source == null) return const [];
    try {
      final json = jsonDecode(source) as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(ChatMessageDto.fromJson)
          .toList();
    } on Object catch (error) {
      throw DataException('Stored chat data is invalid', error);
    }
  }

  Future<void> append(ChatMessageDto message) async {
    final messages = readMessages()..add(message);
    final json = messages.map((item) => item.toJson()).toList();
    if (!await _preferences.setString(_messagesKey, jsonEncode(json))) {
      throw const DataException('Unable to save chat message');
    }
  }

  Future<void> savePeerSnapshot({
    required int id,
    required String nickname,
    required String avatarPath,
  }) async {
    final source = _preferences.getString(_peerSnapshotsKey);
    final snapshots = source == null
        ? <String, dynamic>{}
        : jsonDecode(source) as Map<String, dynamic>;
    snapshots['$id'] = {
      'id': id,
      'nickname': nickname,
      'avatarPath': avatarPath,
    };
    if (!await _preferences.setString(
      _peerSnapshotsKey,
      jsonEncode(snapshots),
    )) {
      throw const DataException('Unable to save chat peer');
    }
  }
}
