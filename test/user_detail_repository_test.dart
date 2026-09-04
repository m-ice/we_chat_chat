import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/user_detail_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads approved profile content for known seed users', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final repository = UserDetailRepositoryImpl(
      AssetJsonProvider(),
      await SharedPreferences.getInstance(),
    );

    final profile = await repository.getSeedProfile(1);

    expect(profile, isNotNull);
    expect(profile!.userId, 1);
    expect(profile.personalityTags, hasLength(3));
    expect(profile.heroImagePath, contains('unsplash.com'));
    expect(profile.galleryPreviewPaths, hasLength(3));
    expect(profile.facts, hasLength(3));
    expect(profile.activities, hasLength(2));
    expect(profile.activities.first.interestedCount, 16);
    expect(profile.moments, hasLength(1));
    expect(profile.moments.first.id, 'user-001-moment-001');
    expect(await repository.getSeedProfile(404), isNull);
  });

  test(
    'returns distinct detail records with uniquely owned activities',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final repository = UserDetailRepositoryImpl(
        AssetJsonProvider(),
        await SharedPreferences.getInstance(),
      );

      final profiles = await Future.wait(
        List.generate(11, (index) => repository.getSeedProfile(index + 1)),
      );
      expect(profiles, everyElement(isNotNull));
      final values = profiles.nonNulls.toList(growable: false);
      expect(
        values.map((profile) => profile.heroImagePath).toSet(),
        hasLength(11),
      );
      expect(
        values.map((profile) => profile.moments.single.contentKey).toSet(),
        hasLength(11),
      );

      final activityIds = <String>{};
      for (var index = 0; index < values.length; index++) {
        final userId = index + 1;
        expect(values[index].userId, userId);
        expect(values[index].activities.length, inInclusiveRange(0, 2));
        for (final activity in values[index].activities) {
          expect(activity.id, isNotEmpty);
          expect(activity.ownerId, userId);
          expect(activityIds.add(activity.id), isTrue, reason: activity.id);
        }
      }
    },
  );

  test('persists moment likes and derives the count exactly once', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = UserDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
    );
    final moment = (await repository.getSeedProfile(1))!.moments.first;

    expect(
      repository
          .getMomentEngagement(
            moment.id,
            initialLikeCount: moment.initialLikeCount,
          )
          .likeCount,
      18,
    );
    await repository.setMomentLiked(
      moment.id,
      true,
      initialLikeCount: moment.initialLikeCount,
    );
    await repository.setMomentLiked(
      moment.id,
      true,
      initialLikeCount: moment.initialLikeCount,
    );

    final restored = UserDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
    ).getMomentEngagement(moment.id, initialLikeCount: moment.initialLikeCount);
    expect(restored.isLiked, isTrue);
    expect(restored.likeCount, 19);

    await repository.setMomentLiked(
      moment.id,
      false,
      initialLikeCount: moment.initialLikeCount,
    );
    expect(
      repository
          .getMomentEngagement(
            moment.id,
            initialLikeCount: moment.initialLikeCount,
          )
          .likeCount,
      18,
    );
  });
}
