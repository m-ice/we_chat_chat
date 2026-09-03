import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/social_state_repository.dart';

class SocialStateRepositoryImpl implements SocialStateRepository {
  SocialStateRepositoryImpl(this._preferences);

  static const _followedKey = 'mt_home_followed_user_ids';
  static const _pendingJoinKey = 'mt_home_pending_join_user_ids';
  static const _blockedKey = 'mt_home_blocked_user_ids';
  static const _shieldedKey = 'mt_home_shielded_user_ids';
  static const _invitedKey = 'mt_home_invited_user_ids';

  final SharedPreferences _preferences;

  Set<int> _read(String key) =>
      (_preferences.getStringList(key) ?? const <String>[])
          .map(int.parse)
          .toSet();

  Future<void> _set(String key, int id, bool value) async {
    final values = _read(key);
    value ? values.add(id) : values.remove(id);
    await _preferences.setStringList(
      key,
      (values.toList()..sort()).map((item) => '$item').toList(),
    );
  }

  @override
  Set<int> get followedIds => _read(_followedKey);
  @override
  Set<int> get pendingJoinIds => _read(_pendingJoinKey);
  @override
  Set<int> get blockedIds => _read(_blockedKey);
  @override
  Set<int> get shieldedIds => _read(_shieldedKey);
  @override
  Set<int> get invitedIds => _read(_invitedKey);

  @override
  Future<void> setFollowed(int userId, bool value) =>
      _set(_followedKey, userId, value);
  @override
  Future<void> setPendingJoin(int userId, bool value) =>
      _set(_pendingJoinKey, userId, value);
  @override
  Future<void> block(int userId) => _set(_blockedKey, userId, true);
  @override
  Future<void> shield(int userId) => _set(_shieldedKey, userId, true);
  @override
  Future<void> setInvited(int userId, bool value) =>
      _set(_invitedKey, userId, value);
}
