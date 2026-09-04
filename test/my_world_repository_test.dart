import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/my_world_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/my_world_post.dart';

void main() {
  test('publishes pending text posts with the exact iOS schema', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = MyWorldRepositoryImpl(preferences);

    expect(
      await repository.publish(
        content: '周末去了梧桐山。',
        imageSourcePaths: const [],
        topics: const ['户外'],
      ),
      isTrue,
    );
    final post = repository.posts.single;
    expect(post.reviewStatus, MyWorldReviewStatus.pending);
    expect(post.topics, ['户外']);
    final json =
        (jsonDecode(preferences.getString('mt_my_world_posts')!) as List).single
            as Map<String, dynamic>;
    expect(json['mtReviewStatus'], 'mtPending');
    expect(json['mtImageRelativePaths'], isEmpty);
  });

  test('decodes the legacy single image key used by iOS', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'mt_my_world_posts': jsonEncode([
        {
          'mtId': 'legacy',
          'mtContent': '旧动态',
          'mtImageRelativePath': 'world/posts/legacy/img_0.jpg',
          'mtCreatedAt': 1788364800.0,
        },
      ]),
    });
    final repository = MyWorldRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    expect(repository.posts.single.imageRelativePaths, [
      'world/posts/legacy/img_0.jpg',
    ]);
  });

  test('persists like and comment interactions', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final repository = MyWorldRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    await repository.publish(
      content: '一起去骑行。',
      imageSourcePaths: const [],
      topics: const ['运动'],
    );
    final id = repository.posts.single.id;

    await repository.setLiked(id, true);
    await repository.addComment(id, '下次一起。');

    final post = repository.posts.single;
    expect(post.isLiked, isTrue);
    expect(post.likeCount, 1);
    expect(post.commentCount, 1);
    expect(post.comments.single.content, '下次一起。');
  });
}
