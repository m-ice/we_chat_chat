import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/video_engagement_repository_impl.dart';

void main() {
  test('persists video likes and favorites', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final repository = VideoEngagementRepositoryImpl(
      await SharedPreferences.getInstance(),
    );

    await repository.setLiked(7, true);
    await repository.setFavorite(9, true);

    expect(repository.likedUserIds, {7});
    expect(repository.favoriteUserIds, {9});

    await repository.setLiked(7, false);
    expect(repository.likedUserIds, isEmpty);
  });
}
