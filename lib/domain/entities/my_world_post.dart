enum MyWorldReviewStatus { pending, approved }

class MyWorldPost {
  const MyWorldPost({
    required this.id,
    required this.content,
    required this.imageRelativePaths,
    required this.topics,
    required this.createdAt,
    required this.reviewStatus,
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
  final bool isLiked;
  final int likeCount;
  final List<MyWorldComment> comments;

  int get commentCount => comments.length;

  MyWorldPost copyWith({
    bool? isLiked,
    int? likeCount,
    List<MyWorldComment>? comments,
  }) => MyWorldPost(
    id: id,
    content: content,
    imageRelativePaths: imageRelativePaths,
    topics: topics,
    createdAt: createdAt,
    reviewStatus: reviewStatus,
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
