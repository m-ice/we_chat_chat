import '../../domain/entities/team_detail_comment.dart';
import '../../domain/entities/team_detail_seed_state.dart';
import '../../domain/repositories/team_detail_repository.dart';
import '../providers/asset_json_provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TeamDetailRepositoryImpl implements TeamDetailRepository {
  const TeamDetailRepositoryImpl(this._assets, this._preferences);

  static const _assetPath = 'assets/mock/team_detail_comments.json';
  static const _stateAssetPath = 'assets/mock/team_detail_state.json';
  static const _commentsKeyPrefix = 'team_detail_comments_v1_';

  final AssetJsonProvider _assets;
  final SharedPreferences _preferences;

  @override
  Future<List<TeamDetailComment>> getComments(int teamOwnerId) async {
    final values = await _assets.readList(_assetPath);
    final comments = values
        .where(
          (json) =>
              json['source'] == 'demo' &&
              json['moderationStatus'] == 'approved',
        )
        .map(
          (json) => TeamDetailComment(
            nickname: json['nickname'] as String? ?? '',
            content: json['content'] as String? ?? '',
          ),
        )
        .where((comment) => comment.content.trim().isNotEmpty)
        .toList();
    final stored = _preferences.getStringList(
      '$_commentsKeyPrefix$teamOwnerId',
    );
    if (stored != null) {
      comments.insertAll(
        0,
        stored.reversed.map((value) {
          final json = jsonDecode(value) as Map<String, dynamic>;
          return TeamDetailComment(
            nickname: json['nickname'] as String? ?? '',
            content: json['content'] as String? ?? '',
          );
        }),
      );
    }
    return List.unmodifiable(comments);
  }

  @override
  Future<void> addComment(int teamOwnerId, TeamDetailComment comment) async {
    final key = '$_commentsKeyPrefix$teamOwnerId';
    final stored = List<String>.from(
      _preferences.getStringList(key) ?? const <String>[],
    );
    stored.add(
      jsonEncode({'nickname': comment.nickname, 'content': comment.content}),
    );
    await _preferences.setStringList(key, stored);
  }

  @override
  Future<TeamDetailSeedState> getSeedState(int teamOwnerId) async {
    final values = await _assets.readList(_stateAssetPath);
    final approved = values.where(
      (json) =>
          json['source'] == 'demo' && json['moderationStatus'] == 'approved',
    );
    final json = approved.firstWhere(
      (item) => item['teamOwnerId'] == teamOwnerId,
      orElse: () => approved.firstWhere((item) => item['teamOwnerId'] == 0),
    );
    return TeamDetailSeedState(
      participantTotal: json['participantTotal'] as int? ?? 0,
      participantCount: json['participantCount'] as int? ?? 0,
      participantAvatarPaths: List<String>.from(
        json['participantAvatarPaths'] as List? ?? const [],
      ),
    );
  }
}
