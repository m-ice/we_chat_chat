import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/video_engagement_repository.dart';

class VideoEngagementRepositoryImpl implements VideoEngagementRepository {
  VideoEngagementRepositoryImpl(this._preferences);

  static const _likedKey = 'mt_video_liked_user_ids';
  static const _favoriteKey = 'mt_video_favorite_user_ids';

  final SharedPreferences _preferences;

  Set<int> _read(String key) =>
      (_preferences.getStringList(key) ?? const <String>[])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  Future<void> _set(String key, int userId, bool value) async {
    final ids = _read(key);
    value ? ids.add(userId) : ids.remove(userId);
    await _preferences.setStringList(
      key,
      (ids.toList()..sort()).map((id) => '$id').toList(growable: false),
    );
  }

  @override
  Set<int> get likedUserIds => _read(_likedKey);

  @override
  Set<int> get favoriteUserIds => _read(_favoriteKey);

  @override
  Future<void> setLiked(int userId, bool value) =>
      _set(_likedKey, userId, value);

  @override
  Future<void> setFavorite(int userId, bool value) =>
      _set(_favoriteKey, userId, value);
}
