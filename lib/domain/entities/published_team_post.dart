enum TeamPostReviewStatus { pending, approved }

class PublishedTeamPost {
  const PublishedTeamPost({
    required this.id,
    required this.activity,
    required this.location,
    required this.date,
    required this.content,
    required this.contact,
    required this.imageRelativePaths,
    required this.createdAt,
    required this.reviewStatus,
  });
  final String id;
  final String activity;
  final String location;
  final String date;
  final String content;
  final String contact;
  final List<String> imageRelativePaths;
  final DateTime createdAt;
  final TeamPostReviewStatus reviewStatus;
}
