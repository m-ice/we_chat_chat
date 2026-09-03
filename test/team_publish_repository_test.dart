import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/team_publish_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/published_team_post.dart';

void main() {
  test('persists a submitted team post with the exact iOS schema', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamPublishRepositoryImpl(preferences);

    final published = await repository.publish(
      activity: '骑行组队',
      location: '深圳湾',
      date: '2026-09-03',
      content: '周末休闲骑行',
      contact: 'wx-test',
      imageSourcePaths: const [],
    );

    expect(published, isTrue);
    expect(repository.posts, hasLength(1));
    expect(
      repository.pendingPosts.single.reviewStatus,
      TeamPostReviewStatus.pending,
    );
    expect(repository.approvedPosts, isEmpty);

    final encoded = preferences.getString('mt_published_team_posts')!;
    final json = (jsonDecode(encoded) as List).single as Map<String, dynamic>;
    expect(json['mtActivity'], '骑行组队');
    expect(json['mtLocation'], '深圳湾');
    expect(json['mtDate'], '2026-09-03');
    expect(json['mtContent'], '周末休闲骑行');
    expect(json['mtContact'], 'wx-test');
    expect(json['mtImageRelativePaths'], isEmpty);
    expect(json['mtReviewStatus'], 'mtPending');
    expect(json.keys, containsAll(<String>['mtId', 'mtCreatedAt']));
  });

  test('rejects incomplete posts without changing local state', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final repository = TeamPublishRepositoryImpl(
      await SharedPreferences.getInstance(),
    );

    expect(
      await repository.publish(
        activity: '露营组队',
        location: '',
        date: '2026-09-03',
        content: '露营',
        contact: '123',
        imageSourcePaths: const [],
      ),
      isFalse,
    );
    expect(repository.posts, isEmpty);
  });
}
