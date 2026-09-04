abstract interface class VideoEngagementRepository {
  Set<int> get likedUserIds;
  Set<int> get favoriteUserIds;

  Future<void> setLiked(int userId, bool value);
  Future<void> setFavorite(int userId, bool value);
}
