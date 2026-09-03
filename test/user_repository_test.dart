import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/user_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the curated iOS seed fixtures', () async {
      final repository = UserRepositoryImpl(AssetJsonProvider());

      final users = await repository.getUsers();
      final cityUsers = await repository.getCityUsers();
      final verifiedUsers = await repository.getVerifiedUsers();

      expect(users.map((user) => user.id), [1, 2, 3, 4, 6, 7, 8, 9, 10, 11]);
      expect(cityUsers.map((user) => user.id), [
        101,
        102,
        1,
        2,
        3,
        4,
        6,
        7,
        8,
        9,
        10,
        11,
      ]);
      expect(verifiedUsers.map((user) => user.id), [
        9001,
        9002,
        9003,
        9004,
        9005,
        9006,
        9007,
        9008,
      ]);
      expect(users.firstWhere((user) => user.id == 10).nickname, '阿泽');
      expect(users.firstWhere((user) => user.id == 11).nickname, '狼王');
      expect(users, everyElement(isA<Object>()));
      expect(users.every((user) => user.isSeedData), isTrue);
      expect(cityUsers.every((user) => user.isSeedData), isTrue);
      expect(verifiedUsers.every((user) => user.isSeedData), isTrue);
      expect(cityUsers.every((user) => !user.isRealPersonVerified), isTrue);
      expect(verifiedUsers.every((user) => !user.isRealPersonVerified), isTrue);
      expect(verifiedUsers.every((user) => !user.isOnline), isTrue);
      expect(
        cityUsers.firstWhere((user) => user.id == 101).videoPath,
        'assets/videos/city/user_101.mov',
      );

      final paths = <String>{
        for (final user in users) ...[
          user.avatarPath,
          ...?user.moment?.imagePaths,
          ...?user.teamPost?.imagePaths,
        ],
        for (final user in cityUsers) ...[
          user.avatarPath,
          ...user.galleryImagePaths,
          if (user.videoPath.isNotEmpty) user.videoPath,
        ],
        for (final user in verifiedUsers) ...[
          user.avatarPath,
          ...user.galleryImagePaths,
          if (user.videoPath.isNotEmpty) user.videoPath,
        ],
      };
      for (final path in paths) {
        expect(await rootBundle.load(path), isNotNull, reason: path);
      }
    },
  );
}
