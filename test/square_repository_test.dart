import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/my_world_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/social_state_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/square_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/user_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'does not put the active user or their reviewed post in the square',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final users = UserRepositoryImpl(
        AssetJsonProvider(),
        ProfileEditRepositoryImpl(preferences),
      );
      final world = MyWorldRepositoryImpl(
        preferences,
        reviewDelay: () => Duration.zero,
      );
      final social = SocialStateRepositoryImpl(preferences);
      final repository = SquareRepositoryImpl(
        users,
        world,
        social,
        preferences,
      );

      await world.publish(
        content: '只在我的动态里保留。',
        imageSourcePaths: const [],
        topics: const ['日常'],
      );
      await world.refreshReviewStatuses();
      final activeUser = await users.getCurrentUser();
      final feed = await repository.recommended();

      expect(feed.every((item) => item.user.id != activeUser.id), isTrue);
      expect(feed.any((item) => item.postId == world.posts.single.id), isFalse);
    },
  );
}
