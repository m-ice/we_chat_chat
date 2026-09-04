abstract interface class UserIdentityRepository {
  /// Resolves one stable local user from the eligible user ids.
  ///
  /// A device receives a random identity only once. Subsequent launches use
  /// the same device-to-user mapping while that device identity is available.
  Future<int> resolveCurrentUserId(Iterable<int> eligibleUserIds);
}
