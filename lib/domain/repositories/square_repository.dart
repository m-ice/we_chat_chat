import '../entities/square_feed.dart';

abstract interface class SquareRepository {
  Future<List<SquareFeedItem>> recommended();
  Future<List<SquareFeedItem>> following();
  Future<List<TopicItem>> topics();
  Set<String> get likedPostIds;
  Future<void> setLiked(String postId, bool value);
  Future<List<String>> resolvedImages(SquareFeedItem item);
}
