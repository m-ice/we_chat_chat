abstract interface class SocialStateRepository {
  /// Emits after a persisted social-state change.
  Stream<void> get changes;

  Set<int> get followedIds;
  Set<int> get pendingJoinIds;
  Set<int> get blockedIds;
  Set<int> get shieldedIds;
  Set<String> get shieldedActivityIds;
  Set<int> get invitedIds;

  Future<void> setFollowed(int userId, bool value);
  Future<void> setPendingJoin(int userId, bool value);
  Future<void> block(int userId);
  Future<void> unblock(int userId);
  Future<void> shield(int userId);
  Future<void> shieldActivity(String activityId);
  Future<void> setInvited(int userId, bool value);
}
