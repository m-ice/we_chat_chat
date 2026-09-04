import '../entities/user_detail_seed_profile.dart';

abstract interface class UserDetailRepository {
  Future<UserDetailSeedProfile?> getSeedProfile(int userId);

  UserDetailMomentEngagement getMomentEngagement(
    String momentId, {
    required int initialLikeCount,
  });

  Future<void> setMomentLiked(
    String momentId,
    bool liked, {
    required int initialLikeCount,
  });
}
