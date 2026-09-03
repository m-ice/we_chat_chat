import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/message_center_item.dart';
import '../../domain/repositories/message_center_repository.dart';

class MessageCenterRepositoryImpl implements MessageCenterRepository {
  const MessageCenterRepositoryImpl();

  static const _assetPath = 'assets/mock/message_center.json';
  static const _readNoticeIdsKey = 'message_center_read_notice_ids_v1';
  static const _relationshipStatesKey = 'message_center_relationships_v1';
  static const _demoCallbacksKey = 'message_center_demo_callbacks_v1';

  @override
  Future<List<SystemNotice>> getSystemNotices() async {
    final source = await _readSource();
    final preferences = await SharedPreferences.getInstance();
    final readIds = preferences.getStringList(_readNoticeIdsKey)?.toSet() ?? {};
    return _list(source, 'systemNotices')
        .map((json) {
          final id = json['id'] as String;
          return SystemNotice(
            id: id,
            content: json['content'] as String,
            avatarPath: json['avatarPath'] as String,
            createdAt: DateTime.parse(json['createdAt'] as String),
            isRead: readIds.contains(id),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> markSystemNoticesRead(Iterable<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    final readIds = preferences.getStringList(_readNoticeIdsKey)?.toSet() ?? {};
    readIds.addAll(ids);
    await preferences.setStringList(
      _readNoticeIdsKey,
      readIds.toList()..sort(),
    );
  }

  @override
  Future<List<IntimateRelationship>> getRelationships() async {
    final source = await _readSource();
    final preferences = await SharedPreferences.getInstance();
    final overrides = _decodeMap(preferences.getString(_relationshipStatesKey));
    return _list(source, 'relationships')
        .map((json) {
          final person = _person(json);
          final stateName = overrides['${person.id}'] ?? json['state'];
          return IntimateRelationship(
            person: person,
            state: RelationshipState.values.byName(stateName as String),
            since: DateTime.parse(json['since'] as String),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> setRelationshipState(
    int personId,
    RelationshipState state,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final overrides = _decodeMap(preferences.getString(_relationshipStatesKey));
    overrides['$personId'] = state.name;
    await preferences.setString(_relationshipStatesKey, jsonEncode(overrides));
  }

  @override
  Future<List<VisitorRecord>> getVisitors() async {
    final source = await _readSource();
    return _list(source, 'visitors')
        .map(
          (json) => VisitorRecord(
            person: _person(json),
            visitedAt: DateTime.parse(json['visitedAt'] as String),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<CallRecord>> getCallRecords() async {
    final source = await _readSource();
    final records = _list(source, 'calls').map(_callRecord).toList();
    final preferences = await SharedPreferences.getInstance();
    final persisted = preferences.getStringList(_demoCallbacksKey) ?? const [];
    for (final value in persisted) {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) records.add(_callRecord(decoded));
    }
    records.sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
    return records;
  }

  @override
  Future<CallRecord> addDemoCallback(MessageCenterPerson person) async {
    final now = DateTime.now();
    final record = CallRecord(
      id: 'demo-${now.microsecondsSinceEpoch}',
      person: person,
      direction: CallDirection.outgoing,
      state: CallState.demo,
      happenedAt: now,
      durationSeconds: 0,
    );
    final preferences = await SharedPreferences.getInstance();
    final persisted = List<String>.from(
      preferences.getStringList(_demoCallbacksKey) ?? const [],
    );
    persisted.add(jsonEncode(_callRecordToJson(record)));
    while (persisted.length > 20) {
      persisted.removeAt(0);
    }
    await preferences.setStringList(_demoCallbacksKey, persisted);
    return record;
  }

  Future<Map<String, dynamic>> _readSource() async {
    final source = await rootBundle.loadString(_assetPath);
    return jsonDecode(source) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> source, String key) =>
      (source[key] as List<dynamic>).cast<Map<String, dynamic>>();

  MessageCenterPerson _person(Map<String, dynamic> json) => MessageCenterPerson(
    id: json['personId'] as int,
    nickname: json['nickname'] as String,
    avatarPath: json['avatarPath'] as String,
  );

  CallRecord _callRecord(Map<String, dynamic> json) => CallRecord(
    id: json['id'] as String,
    person: _person(json),
    direction: CallDirection.values.byName(json['direction'] as String),
    state: CallState.values.byName(json['state'] as String),
    happenedAt: DateTime.parse(json['happenedAt'] as String),
    durationSeconds: json['durationSeconds'] as int,
  );

  Map<String, dynamic> _callRecordToJson(CallRecord record) => {
    'id': record.id,
    'personId': record.person.id,
    'nickname': record.person.nickname,
    'avatarPath': record.person.avatarPath,
    'direction': record.direction.name,
    'state': record.state.name,
    'happenedAt': record.happenedAt.toIso8601String(),
    'durationSeconds': record.durationSeconds,
  };

  Map<String, dynamic> _decodeMap(String? value) {
    if (value == null || value.isEmpty) return {};
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : {};
  }
}
