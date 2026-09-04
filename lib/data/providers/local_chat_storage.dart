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
    final approved = seed.where(
      (item) =>
          item['source'] == 'demo' && item['moderationStatus'] == 'approved',
    );
    await _preferences.setString(_messagesKey, jsonEncode(approved.toList()));
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
    final snapshots = _decodePeerSnapshots(source);
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

  List<LocalChatPeerSnapshot> readPeerSnapshots() {
    final snapshots = _decodePeerSnapshots(
      _preferences.getString(_peerSnapshotsKey),
    );
    return snapshots.values
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .map(LocalChatPeerSnapshot.fromJson)
        .where((value) => value.id != 0 && value.nickname.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic> _decodePeerSnapshots(String? source) {
    if (source == null || source.isEmpty) return <String, dynamic>{};
    try {
      final value = jsonDecode(source);
      return value is Map<String, dynamic> ? value : <String, dynamic>{};
    } on Object {
      return <String, dynamic>{};
    }
  }
}

class LocalChatPeerSnapshot {
  const LocalChatPeerSnapshot({
    required this.id,
    required this.nickname,
    required this.avatarPath,
  });

  factory LocalChatPeerSnapshot.fromJson(Map<String, dynamic> json) =>
      LocalChatPeerSnapshot(
        id: json['id'] as int? ?? 0,
        nickname: json['nickname'] as String? ?? '',
        avatarPath: json['avatarPath'] as String? ?? '',
      );

  final int id;
  final String nickname;
  final String avatarPath;
}
