import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/data_exception.dart';
import '../../domain/entities/user_detail_seed_profile.dart';
import '../../domain/repositories/user_detail_repository.dart';
import '../providers/asset_json_provider.dart';

class UserDetailRepositoryImpl implements UserDetailRepository {
  const UserDetailRepositoryImpl(this._assets, this._preferences);

  static const _assetPath = 'assets/mock/user_detail_seed.json';
  static const engagementStorageKey = 'mt_user_detail_moment_engagement_v1';

  final AssetJsonProvider _assets;
  final SharedPreferences _preferences;

  @override
  Future<UserDetailSeedProfile?> getSeedProfile(int userId) async {
    final values = await _assets.readList(_assetPath);
    final matches = values.where(
      (json) =>
          json['source'] == 'demo' &&
          json['moderationStatus'] == 'approved' &&
          json['userId'] == userId,
    );
    if (matches.isEmpty) return null;
    final json = matches.first;
    return UserDetailSeedProfile(
      userId: json['userId'] as int,
      heroImagePath: json['heroImagePath'] as String? ?? '',
      galleryPreviewPaths: List<String>.from(
        json['galleryPreviewPaths'] as List? ?? const [],
      ),
      personalityTags: List<String>.from(
        json['personalityTags'] as List? ?? const [],
      ),
      facts: _list(json, 'facts')
          .map(
            (item) => UserDetailSeedFact(
              labelKey: item['labelKey'] as String? ?? '',
              value: item['value'] as String? ?? '',
              valueIsTranslationKey:
                  item['valueIsTranslationKey'] as bool? ?? false,
            ),
          )
          .where((item) => item.labelKey.isNotEmpty && item.value.isNotEmpty)
          .toList(growable: false),
      activities: _list(json, 'activities')
          .map(
            (item) => UserDetailSeedActivity(
              id: item['id'] as String? ?? '',
              ownerId: item['ownerId'] as int? ?? 0,
              titleKey: item['titleKey'] as String? ?? '',
              coverPath: item['coverPath'] as String? ?? '',
              locationKey: item['locationKey'] as String? ?? '',
              date: DateTime.parse(item['date'] as String),
              interestedCount: item['interestedCount'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
      moments: _list(json, 'moments')
          .map(
            (item) => UserDetailSeedMoment(
              id: item['id'] as String? ?? '',
              contentKey: item['contentKey'] as String? ?? '',
              imagePath: item['imagePath'] as String? ?? '',
              createdAt: DateTime.parse(item['createdAt'] as String),
              initialLikeCount: item['initialLikeCount'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) =>
      (json[key] as List? ?? const []).cast<Map<String, dynamic>>();

  @override
  UserDetailMomentEngagement getMomentEngagement(
    String momentId, {
    required int initialLikeCount,
  }) {
    final stored = _engagements[momentId];
    return UserDetailMomentEngagement(
      isLiked: stored?['liked'] as bool? ?? false,
      likeCount: stored?['likeCount'] as int? ?? initialLikeCount,
    );
  }

  @override
  Future<void> setMomentLiked(
    String momentId,
    bool liked, {
    required int initialLikeCount,
  }) async {
    final id = momentId.trim();
    if (id.isEmpty) return;
    final values = _engagements;
    final current = getMomentEngagement(id, initialLikeCount: initialLikeCount);
    if (current.isLiked == liked) return;
    values[id] = {
      'liked': liked,
      'likeCount': (current.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 31),
    };
    final saved = await _preferences.setString(
      engagementStorageKey,
      jsonEncode(values),
    );
    if (!saved) {
      throw const DataException('Unable to save profile moment engagement');
    }
  }

  Map<String, Map<String, dynamic>> get _engagements {
    final raw = _preferences.getString(engagementStorageKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map(
        (key, value) => MapEntry(
          key,
          value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
        ),
      );
    } on Object {
      return {};
    }
  }
}
