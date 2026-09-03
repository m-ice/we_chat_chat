enum MyWorldReviewStatus { pending, approved }

class MyWorldPost {
  const MyWorldPost({
    required this.id,
    required this.content,
    required this.imageRelativePaths,
    required this.topics,
    required this.createdAt,
    required this.reviewStatus,
  });
  final String id;
  final String content;
  final List<String> imageRelativePaths;
  final List<String> topics;
  final DateTime createdAt;
  final MyWorldReviewStatus reviewStatus;
}
