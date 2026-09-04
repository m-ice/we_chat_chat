import 'dart:convert';

import '../../domain/entities/team_detail_comment.dart';
import '../../domain/entities/team_activity_join_result.dart';
import '../../domain/entities/team_detail_seed_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/team_detail_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../providers/asset_json_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TeamDetailRepositoryImpl implements TeamDetailRepository {
  const TeamDetailRepositoryImpl(this._assets, this._preferences, this._users);

  static const _assetPath = 'assets/mock/team_detail_comments.json';
  static const _stateAssetPath = 'assets/mock/team_detail_state.json';
  static const _commentsKeyPrefix = 'team_detail_comments_v3_';
  static const _previousCommentsKeyPrefix = 'team_detail_comments_v2_';
  static const _legacyCommentsKeyPrefix = 'team_detail_comments_v1_';
  static const _memberIdsKeyPrefix = 'team_detail_member_ids_v1_';

  final AssetJsonProvider _assets;
  final SharedPreferences _preferences;
  final UserRepository _users;

  @override
  Future<List<TeamDetailComment>> getComments(
    String activityId, {
    int? legacyOwnerId,
  }) async {
    final values = await _assets.readList(_assetPath);
    final usersById = {
      for (final user in await _users.getUsers()) user.id: user,
    };
    final comments = <TeamDetailComment>[];
    for (final json in values.where(
      (json) =>
          json['activityId'] == activityId &&
          json['source'] == 'demo' &&
          json['moderationStatus'] == 'approved',
    )) {
      final comment = _seedCommentFromJson(json, usersById);
      if (comment != null) comments.add(comment);
    }

    final stored =
        _preferences.getStringList('$_commentsKeyPrefix$activityId') ??
        _preferences.getStringList('$_previousCommentsKeyPrefix$activityId');
    final legacy = legacyOwnerId == null
        ? null
        : _preferences.getStringList('$_legacyCommentsKeyPrefix$legacyOwnerId');
    final persisted = stored ?? legacy;
    if (persisted != null) {
      final local = <TeamDetailComment>[];
      for (final value in persisted.reversed) {
        final json = jsonDecode(value) as Map<String, dynamic>;
        final comment = _localCommentFromJson(json, usersById);
        if (comment != null) local.add(comment);
      }
      comments.insertAll(0, local);
    }
    return List.unmodifiable(comments);
  }

  @override
  Future<void> addComment(String activityId, TeamDetailComment comment) async {
    final key = '$_commentsKeyPrefix$activityId';
    final stored = List<String>.from(
      _preferences.getStringList(key) ??
          _preferences.getStringList(
            '$_previousCommentsKeyPrefix$activityId',
          ) ??
          const <String>[],
    );
    stored.add(
      jsonEncode({
        'authorId': comment.authorId,
        'content': comment.content,
        if (comment.authorId == null) 'nickname': comment.nickname,
      }),
    );
    await _preferences.setStringList(key, stored);
  }

  @override
  Future<TeamActivityJoinResult> joinActivity(
    String activityId,
    int userId,
  ) async {
    final id = activityId.trim();
    if (id.isEmpty || userId <= 0) return TeamActivityJoinResult.unavailable;

    final state = await getSeedState(id);
    if (state.participantTotal <= 0) {
      return TeamActivityJoinResult.unavailable;
    }
    if (state.participantUserIds.contains(userId)) {
      return TeamActivityJoinResult.alreadyJoined;
    }
    if (state.participantCount >= state.participantTotal) {
      return TeamActivityJoinResult.full;
    }

    final memberIds = await _storedMemberIds(id);
    memberIds.add(userId);
    await _preferences.setStringList(
      '$_memberIdsKeyPrefix$id',
      memberIds.map((value) => '$value').toList()..sort(),
    );
    return TeamActivityJoinResult.joined;
  }

  @override
  Future<TeamDetailSeedState> getSeedState(
    String activityId, {
    int? legacyOwnerId,
  }) async {
    final values = await _assets.readList(_stateAssetPath);
    final approved = values.where(
      (json) =>
          json['source'] == 'demo' && json['moderationStatus'] == 'approved',
    );
    final matches = approved.where((item) => item['activityId'] == activityId);
    if (matches.isEmpty) {
      return const TeamDetailSeedState(
        participantTotal: 0,
        participantCount: 0,
      );
    }
    final json = matches.first;
    final memberIds = List<int>.from(
      json['participantUserIds'] as List? ?? const [],
    );
    final persistedIds = await _storedMemberIds(activityId);
    for (final userId in persistedIds) {
      if (!memberIds.contains(userId)) memberIds.add(userId);
    }
    return TeamDetailSeedState(
      participantTotal: json['participantTotal'] as int? ?? 0,
      participantCount: memberIds.length,
      participantUserIds: List.unmodifiable(memberIds),
      participantAvatarPaths: List<String>.from(
        json['participantAvatarPaths'] as List? ?? const [],
      ),
    );
  }

  TeamDetailComment? _seedCommentFromJson(
    Map<String, dynamic> json,
    Map<int, User> usersById,
  ) {
    final authorId = json['authorId'];
    if (authorId is! int) return null;
    final author = usersById[authorId];
    final content = (json['content'] as String? ?? '').trim();
    if (author == null || content.isEmpty) return null;
    return TeamDetailComment(
      authorId: author.id,
      nickname: author.nickname,
      avatarPath: author.avatarPath,
      content: content,
    );
  }

  Future<Set<int>> _storedMemberIds(String activityId) async =>
      (_preferences.getStringList('$_memberIdsKeyPrefix$activityId') ??
              const <String>[])
          .map(int.tryParse)
          .whereType<int>()
          .where((id) => id > 0)
          .toSet();

  TeamDetailComment? _localCommentFromJson(
    Map<String, dynamic> json,
    Map<int, User> usersById,
  ) {
    final content = (json['content'] as String? ?? '').trim();
    if (content.isEmpty) return null;
    final authorId = json['authorId'];
    if (authorId is int) {
      final author = usersById[authorId];
      if (author == null) return null;
      return TeamDetailComment(
        authorId: author.id,
        nickname: author.nickname,
        avatarPath: author.avatarPath,
        content: content,
      );
    }

    final nickname = (json['nickname'] as String? ?? '').trim();
    if (nickname.isEmpty) return null;
    return TeamDetailComment(
      authorId: null,
      nickname: nickname,
      avatarPath: '',
      content: content,
    );
  }
}
