enum MyWorldReviewStatus { pending, approved }

class MyWorldPost {
  const MyWorldPost({
    required this.id,
    required this.content,
    required this.imageRelativePaths,
    required this.topics,
    required this.createdAt,
    required this.reviewStatus,
    this.reviewAvailableAt,
    this.isLiked = false,
    this.likeCount = 0,
    this.comments = const [],
  });
  final String id;
  final String content;
  final List<String> imageRelativePaths;
  final List<String> topics;
  final DateTime createdAt;
  final MyWorldReviewStatus reviewStatus;

  /// Kept private to the client. It defines when fake moderation can promote
  /// a pending post without revealing a review countdown in the UI.
  final DateTime? reviewAvailableAt;
  final bool isLiked;
  final int likeCount;
  final List<MyWorldComment> comments;

  int get commentCount => comments.length;

  MyWorldPost copyWith({
    MyWorldReviewStatus? reviewStatus,
    DateTime? reviewAvailableAt,
    bool? isLiked,
    int? likeCount,
    List<MyWorldComment>? comments,
  }) => MyWorldPost(
    id: id,
    content: content,
    imageRelativePaths: imageRelativePaths,
    topics: topics,
    createdAt: createdAt,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    reviewAvailableAt: reviewAvailableAt ?? this.reviewAvailableAt,
    isLiked: isLiked ?? this.isLiked,
    likeCount: likeCount ?? this.likeCount,
    comments: comments ?? this.comments,
  );
}

class MyWorldComment {
  const MyWorldComment({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String content;
  final DateTime createdAt;
}
