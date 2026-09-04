import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/my_world_post.dart';
import '../../domain/repositories/my_world_repository.dart';

class MyWorldRepositoryImpl implements MyWorldRepository {
  MyWorldRepositoryImpl(this._preferences, {Duration Function()? reviewDelay})
    : _reviewDelay = reviewDelay ?? _randomReviewDelay;
  static const storageKey = 'mt_my_world_posts';
  final SharedPreferences _preferences;
  final Duration Function() _reviewDelay;

  static Duration _randomReviewDelay() =>
      Duration(minutes: 15 + Random.secure().nextInt(16));

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
          reviewAvailableAt: _readReviewAvailableAt(json),
          isLiked: json['mtIsLiked'] as bool? ?? false,
          likeCount: json['mtLikeCount'] as int? ?? 0,
          comments: (json['mtComments'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (value) => MyWorldComment(
                  id: value['mtId'] as String,
                  content: value['mtContent'] as String,
                  createdAt: DateTime.fromMillisecondsSinceEpoch(
                    (((value['mtCreatedAt'] as num?) ?? 0) * 1000).round(),
                  ),
                ),
              )
              .toList(growable: false),
        );
      }).toList();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } on Object {
      return const [];
    }
  }

  DateTime? _readReviewAvailableAt(Map<String, dynamic> json) {
    final value = json['mtReviewAvailableAt'] as num?;
    if (value != null) {
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).round());
    }
    if (json['mtReviewStatus'] == 'mtApproved') return null;
    final created = json['mtCreatedAt'] as num?;
    return created == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            (created * 1000).round(),
          ).add(const Duration(minutes: 15));
  }

  @override
  Future<void> refreshReviewStatuses() async {
    final now = DateTime.now();
    final current = posts.toList();
    var changed = false;
    for (var index = 0; index < current.length; index++) {
      final post = current[index];
      if (post.reviewStatus != MyWorldReviewStatus.pending ||
          post.reviewAvailableAt == null ||
          now.isBefore(post.reviewAvailableAt!)) {
        continue;
      }
      current[index] = post.copyWith(
        reviewStatus: MyWorldReviewStatus.approved,
      );
      changed = true;
    }
    if (changed) await _persist(current);
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
    final createdAt = DateTime.now();
    final current = posts.toList()
      ..insert(
        0,
        MyWorldPost(
          id: id,
          content: text,
          imageRelativePaths: paths,
          topics: topics,
          createdAt: createdAt,
          reviewStatus: MyWorldReviewStatus.pending,
          reviewAvailableAt: createdAt.add(_reviewDelay()),
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
  Future<void> setLiked(String id, bool liked) async {
    final current = posts.toList();
    final index = current.indexWhere((post) => post.id == id);
    if (index < 0 || current[index].isLiked == liked) return;
    final post = current[index];
    current[index] = post.copyWith(
      isLiked: liked,
      likeCount: (post.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 31),
    );
    await _persist(current);
  }

  @override
  Future<void> addComment(String id, String content) async {
    final text = content.trim();
    if (text.isEmpty) return;
    final current = posts.toList();
    final index = current.indexWhere((post) => post.id == id);
    if (index < 0) return;
    final post = current[index];
    current[index] = post.copyWith(
      comments: [
        ...post.comments,
        MyWorldComment(
          id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
          content: text,
          createdAt: DateTime.now(),
        ),
      ],
    );
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
              if (post.reviewAvailableAt case final reviewAt?)
                'mtReviewAvailableAt': reviewAt.millisecondsSinceEpoch / 1000,
              'mtIsLiked': post.isLiked,
              'mtLikeCount': post.likeCount,
              'mtComments': post.comments
                  .map(
                    (comment) => {
                      'mtId': comment.id,
                      'mtContent': comment.content,
                      'mtCreatedAt':
                          comment.createdAt.millisecondsSinceEpoch / 1000,
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(),
    ),
  );
}
