import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/my_world_post.dart';
import '../../domain/repositories/my_world_repository.dart';

class MyWorldRepositoryImpl implements MyWorldRepository {
  MyWorldRepositoryImpl(this._preferences);
  static const storageKey = 'mt_my_world_posts';
  final SharedPreferences _preferences;

  @override
  List<MyWorldPost> get posts {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      final result = (jsonDecode(raw) as List).map((value) {
        final json = Map<String, dynamic>.from(value as Map);
        final currentPaths = json['mtImageRelativePaths'] as List?;
        final legacyPath = json['mtImageRelativePath'] as String?;
        return MyWorldPost(
          id: json['mtId'] as String,
          content: json['mtContent'] as String,
          imageRelativePaths: currentPaths != null
              ? currentPaths.cast<String>()
              : legacyPath == null
              ? const []
              : [legacyPath],
          topics: (json['mtTopics'] as List? ?? const []).cast<String>(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            ((json['mtCreatedAt'] as num) * 1000).round(),
          ),
          reviewStatus: json['mtReviewStatus'] == 'mtApproved'
              ? MyWorldReviewStatus.approved
              : MyWorldReviewStatus.pending,
        );
      }).toList();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } on Object {
      return const [];
    }
  }

  @override
  Future<bool> publish({
    required String content,
    required List<String> imageSourcePaths,
    required List<String> topics,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return false;
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final paths = <String>[];
    if (imageSourcePaths.isNotEmpty) {
      final documents = await getApplicationDocumentsDirectory();
      for (var index = 0; index < imageSourcePaths.length; index++) {
        final relative = 'world/posts/$id/img_$index.jpg';
        final target = File('${documents.path}/$relative');
        try {
          await target.parent.create(recursive: true);
          await File(imageSourcePaths[index]).copy(target.path);
          paths.add(relative);
        } on FileSystemException {
          continue;
        }
      }
    }
    final current = posts.toList()
      ..insert(
        0,
        MyWorldPost(
          id: id,
          content: text,
          imageRelativePaths: paths,
          topics: topics,
          createdAt: DateTime.now(),
          reviewStatus: MyWorldReviewStatus.pending,
        ),
      );
    return _persist(current);
  }

  @override
  Future<void> remove(String id) async {
    final current = posts.toList();
    final target = current.where((post) => post.id == id).firstOrNull;
    if (target == null) return;
    final documents = await getApplicationDocumentsDirectory();
    for (final path in target.imageRelativePaths) {
      final file = File('${documents.path}/$path');
      if (file.existsSync()) await file.delete();
    }
    current.removeWhere((post) => post.id == id);
    await _persist(current);
  }

  @override
  Future<List<String>> fullImagePaths(MyWorldPost post) async {
    final documents = await getApplicationDocumentsDirectory();
    return post.imageRelativePaths
        .map((path) => '${documents.path}/$path')
        .toList();
  }

  Future<bool> _persist(List<MyWorldPost> values) => _preferences.setString(
    storageKey,
    jsonEncode(
      values
          .map(
            (post) => {
              'mtId': post.id,
              'mtContent': post.content,
              'mtImageRelativePaths': post.imageRelativePaths,
              'mtTopics': post.topics,
              'mtCreatedAt': post.createdAt.millisecondsSinceEpoch / 1000,
              'mtReviewStatus':
                  post.reviewStatus == MyWorldReviewStatus.approved
                  ? 'mtApproved'
                  : 'mtPending',
            },
          )
          .toList(),
    ),
  );
}
