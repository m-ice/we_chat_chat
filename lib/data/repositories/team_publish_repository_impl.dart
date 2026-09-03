import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/published_team_post.dart';
import '../../domain/repositories/team_publish_repository.dart';

class TeamPublishRepositoryImpl implements TeamPublishRepository {
  TeamPublishRepositoryImpl(this._preferences);
  static const storageKey = 'mt_published_team_posts';
  final SharedPreferences _preferences;

  @override
  List<PublishedTeamPost> get posts {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      final values = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final result = values.map(_fromJson).toList();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } on Object {
      return const [];
    }
  }

  @override
  List<PublishedTeamPost> get pendingPosts => posts
      .where((post) => post.reviewStatus == TeamPostReviewStatus.pending)
      .toList();

  @override
  List<PublishedTeamPost> get approvedPosts => posts
      .where((post) => post.reviewStatus == TeamPostReviewStatus.approved)
      .toList();

  @override
  Future<bool> publish({
    required String activity,
    required String location,
    required String date,
    required String content,
    required String contact,
    required List<String> imageSourcePaths,
  }) async {
    final fields = [
      activity,
      location,
      date,
      content,
      contact,
    ].map((value) => value.trim()).toList();
    if (fields.any((value) => value.isEmpty)) return false;
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final imagePaths = <String>[];
    if (imageSourcePaths.isNotEmpty) {
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory('${documents.path}/team/posts/$id');
      await directory.create(recursive: true);
      for (var index = 0; index < imageSourcePaths.length; index++) {
        final relative = 'team/posts/$id/img_$index.jpg';
        await File(imageSourcePaths[index]).copy('${documents.path}/$relative');
        imagePaths.add(relative);
      }
    }
    final current = posts.toList();
    current.insert(
      0,
      PublishedTeamPost(
        id: id,
        activity: fields[0],
        location: fields[1],
        date: fields[2],
        content: fields[3],
        contact: fields[4],
        imageRelativePaths: imagePaths,
        createdAt: DateTime.now(),
        reviewStatus: TeamPostReviewStatus.pending,
      ),
    );
    return _preferences.setString(
      storageKey,
      jsonEncode(current.map(_toJson).toList()),
    );
  }

  PublishedTeamPost _fromJson(Map<String, dynamic> json) => PublishedTeamPost(
    id: json['mtId'] as String,
    activity: json['mtActivity'] as String,
    location: json['mtLocation'] as String,
    date: json['mtDate'] as String,
    content: json['mtContent'] as String,
    contact: json['mtContact'] as String? ?? '',
    imageRelativePaths: (json['mtImageRelativePaths'] as List? ?? const [])
        .cast<String>(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      ((json['mtCreatedAt'] as num) * 1000).round(),
    ),
    reviewStatus: json['mtReviewStatus'] == 'mtApproved'
        ? TeamPostReviewStatus.approved
        : TeamPostReviewStatus.pending,
  );

  Map<String, dynamic> _toJson(PublishedTeamPost post) => {
    'mtId': post.id,
    'mtActivity': post.activity,
    'mtLocation': post.location,
    'mtDate': post.date,
    'mtContent': post.content,
    'mtContact': post.contact,
    'mtImageRelativePaths': post.imageRelativePaths,
    'mtCreatedAt': post.createdAt.millisecondsSinceEpoch / 1000,
    'mtReviewStatus': post.reviewStatus == TeamPostReviewStatus.approved
        ? 'mtApproved'
        : 'mtPending',
  };
}
