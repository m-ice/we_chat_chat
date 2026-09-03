import '../entities/my_world_post.dart';

abstract interface class MyWorldRepository {
  List<MyWorldPost> get posts;
  Future<bool> publish({
    required String content,
    required List<String> imageSourcePaths,
    required List<String> topics,
  });
  Future<void> remove(String id);
  Future<List<String>> fullImagePaths(MyWorldPost post);
}
