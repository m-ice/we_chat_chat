import '../entities/team_detail_comment.dart';
import '../entities/team_detail_seed_state.dart';

abstract interface class TeamDetailRepository {
  Future<List<TeamDetailComment>> getComments(int teamOwnerId);

  Future<void> addComment(int teamOwnerId, TeamDetailComment comment);

  Future<TeamDetailSeedState> getSeedState(int teamOwnerId);
}
