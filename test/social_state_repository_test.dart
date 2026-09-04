import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/social_state_repository_impl.dart';

void main() {
  test('persists social actions and ignores damaged legacy ids', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'mt_home_followed_user_ids': ['7', 'damaged'],
    });
    final repository = SocialStateRepositoryImpl(
      await SharedPreferences.getInstance(),
    );

    expect(repository.followedIds, {7});

    await repository.setFollowed(9, true);
    await repository.setPendingJoin(11, true);
    await repository.setInvited(13, true);
    await repository.block(15);
    await repository.shield(17);

    expect(repository.followedIds, {7, 9});
    expect(repository.pendingJoinIds, {11});
    expect(repository.invitedIds, {13});
    expect(repository.blockedIds, {15});
    expect(repository.shieldedIds, {17});
  });
}
