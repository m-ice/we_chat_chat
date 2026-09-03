import 'user.dart';

class SquareFeedItem {
  const SquareFeedItem({
    required this.postId,
    required this.user,
    required this.content,
    required this.imagePaths,
    required this.time,
    required this.usesSandboxImages,
  });
  final String postId;
  final User user;
  final String content;
  final List<String> imagePaths;
  final String time;
  final bool usesSandboxImages;
}

class TopicItem {
  const TopicItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverPath,
    required this.category,
  });
  final String id;
  final String title;
  final String subtitle;
  final String? coverPath;
  final String category;
}
