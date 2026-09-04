import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/city_user.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/modules/profile/controllers/edit_profile_controller.dart';

void main() {
  test(
    'initializes the edit draft from the current user, not placeholders',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final repository = ProfileEditRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      const user = User(
        id: 7,
        nickname: '南乔',
        age: 27,
        gender: '女',
        hobbies: ['徒步', '摄影'],
        avatarPath: 'assets/images/avatar/avatar_07.png',
        intro: '喜欢在周末看山和看云。',
        isVerified: false,
      );
      final controller = EditProfileController(repository, _CurrentUser(user));

      await controller.refreshProfile();

      expect(controller.profile.value.nickname, user.nickname);
      expect(controller.profile.value.bio, user.intro);
      expect(controller.profile.value.interests, user.hobbies);
      expect(controller.avatarFilePath.value, user.avatarPath);
    },
  );
}

class _CurrentUser implements UserRepository {
  const _CurrentUser(this.user);

  final User user;

  @override
  Future<User> getCurrentUser() async => user;

  @override
  Future<List<CityUser>> getCityUsers() async => const [];

  @override
  Future<List<User>> getUsers() async => [user];

  @override
  Future<List<CityUser>> getVerifiedUsers() async => const [];
}
