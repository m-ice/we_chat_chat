abstract interface class SocialStateRepository {
  Set<int> get followedIds;
  Set<int> get pendingJoinIds;
  Set<int> get blockedIds;
  Set<int> get shieldedIds;
  Set<int> get invitedIds;

  Future<void> setFollowed(int userId, bool value);
  Future<void> setPendingJoin(int userId, bool value);
  Future<void> block(int userId);
  Future<void> shield(int userId);
  Future<void> setInvited(int userId, bool value);
}
