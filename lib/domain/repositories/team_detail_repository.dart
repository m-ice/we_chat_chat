import '../entities/team_detail_comment.dart';
import '../entities/team_activity_join_result.dart';
import '../entities/team_detail_seed_state.dart';

abstract interface class TeamDetailRepository {
  Future<List<TeamDetailComment>> getComments(
    String activityId, {
    int? legacyOwnerId,
  });

  Future<void> addComment(String activityId, TeamDetailComment comment);

  /// Persists membership for a concrete activity and the local user.
  Future<TeamActivityJoinResult> joinActivity(String activityId, int userId);

  Future<TeamDetailSeedState> getSeedState(
    String activityId, {
    int? legacyOwnerId,
  });
}
