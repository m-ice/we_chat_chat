import '../entities/published_team_post.dart';

abstract interface class TeamPublishRepository {
  List<PublishedTeamPost> get posts;
  List<PublishedTeamPost> get pendingPosts;
  List<PublishedTeamPost> get approvedPosts;

  Future<bool> publish({
    required String activity,
    required String location,
    required String date,
    required String content,
    required String contact,
    required List<String> imageSourcePaths,
  });
}
