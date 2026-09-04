import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/team_detail_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/user_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/team_activity_join_result.dart';
import 'package:we_chat_chat/domain/entities/team_detail_comment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('loads moderated activity-detail comments from the seed JSON', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
      UserRepositoryImpl(
        AssetJsonProvider(),
        ProfileEditRepositoryImpl(preferences),
      ),
    );

    final comments = await repository.getComments(
      'activity-007',
      legacyOwnerId: 7,
    );

    expect(comments, hasLength(3));
    expect(comments.every((comment) => comment.content.isNotEmpty), isTrue);
    expect(comments.map((comment) => comment.authorId), [1, 5, 10]);
    expect(comments.every((comment) => comment.avatarPath.isNotEmpty), isTrue);
    final state = await repository.getSeedState(
      'activity-007',
      legacyOwnerId: 7,
    );
    expect(state.participantCount, 3);
    expect(state.participantTotal, 4);
    expect(state.participantUserIds, [7, 1, 5]);
  });

  test('persists a new comment for the selected activity', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
      UserRepositoryImpl(
        AssetJsonProvider(),
        ProfileEditRepositoryImpl(preferences),
      ),
    );

    await repository.addComment(
      'activity-007',
      const TeamDetailComment(
        authorId: 2,
        nickname: '沐野',
        avatarPath: '',
        content: '期待参加',
      ),
    );

    final comments = await repository.getComments(
      'activity-007',
      legacyOwnerId: 7,
    );
    expect(comments.first.content, '期待参加');
    expect(comments, hasLength(4));
  });

  test('keeps comments isolated by activity id', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
      UserRepositoryImpl(
        AssetJsonProvider(),
        ProfileEditRepositoryImpl(preferences),
      ),
    );

    await repository.addComment(
      'activity-alpha',
      const TeamDetailComment(
        authorId: 2,
        nickname: '沐野',
        avatarPath: '',
        content: '只在甲活动出现',
      ),
    );
    await repository.addComment(
      'activity-beta',
      const TeamDetailComment(
        authorId: 2,
        nickname: '沐野',
        avatarPath: '',
        content: '只在乙活动出现',
      ),
    );

    final alpha = await repository.getComments('activity-alpha');
    final beta = await repository.getComments('activity-beta');
    expect(alpha.first.content, '只在甲活动出现');
    expect(beta.first.content, '只在乙活动出现');
  });

  test(
    'joins one activity once and restores its persisted member identity',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final first = TeamDetailRepositoryImpl(
        AssetJsonProvider(),
        preferences,
        UserRepositoryImpl(
          AssetJsonProvider(),
          ProfileEditRepositoryImpl(preferences),
        ),
      );

      expect(
        await first.joinActivity('activity-001', 2),
        TeamActivityJoinResult.joined,
      );
      expect(
        await first.joinActivity('activity-001', 2),
        TeamActivityJoinResult.alreadyJoined,
      );
      expect(
        await first.joinActivity('activity-001', 6),
        TeamActivityJoinResult.full,
      );

      final restored = TeamDetailRepositoryImpl(
        AssetJsonProvider(),
        await SharedPreferences.getInstance(),
        UserRepositoryImpl(
          AssetJsonProvider(),
          ProfileEditRepositoryImpl(preferences),
        ),
      );
      final state = await restored.getSeedState('activity-001');
      expect(state.participantUserIds, [1, 3, 4, 2]);
      expect(state.participantCount, 4);
    },
  );

  test(
    'activity detail seed content references canonical user and activity ids',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final assets = AssetJsonProvider();
      final users = UserRepositoryImpl(
        assets,
        ProfileEditRepositoryImpl(preferences),
      );
      final repository = TeamDetailRepositoryImpl(assets, preferences, users);
      final canonicalUsers = await users.getUsers();
      final userIds = canonicalUsers.map((user) => user.id).toSet();
      final activityIds = canonicalUsers
          .map((user) => user.teamPost?.id)
          .whereType<String>()
          .toSet();
      final activityOwnerIds = {
        for (final user in canonicalUsers)
          if (user.teamPost != null) user.teamPost!.id: user.id,
      };
      final stateRows = await assets.readList(
        'assets/mock/team_detail_state.json',
      );
      final commentRows = await assets.readList(
        'assets/mock/team_detail_comments.json',
      );

      expect(stateRows.map((row) => row['activityId']).toSet(), activityIds);
      for (final row in stateRows) {
        final participantIds = List<int>.from(
          row['participantUserIds'] as List,
        );
        expect(participantIds.toSet(), hasLength(participantIds.length));
        expect(participantIds, everyElement(isIn(userIds)));
        expect(participantIds, contains(activityOwnerIds[row['activityId']]));
        expect(row['participantCount'], participantIds.length);
      }

      for (final row in commentRows) {
        expect(activityIds, contains(row['activityId']));
        expect(userIds, contains(row['authorId']));
      }
      for (final activityId in activityIds) {
        final comments = await repository.getComments(activityId);
        expect(comments, isNotEmpty, reason: activityId);
        for (final comment in comments) {
          final author = canonicalUsers.singleWhere(
            (user) => user.id == comment.authorId,
          );
          expect(comment.nickname, author.nickname);
          expect(comment.avatarPath, author.avatarPath);
        }
      }
    },
  );
}
