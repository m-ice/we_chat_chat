import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/core/vaules/app_image_string.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/user_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/album_item.dart';
import 'package:we_chat_chat/domain/entities/city_user_mapper.dart';
import 'package:we_chat_chat/domain/entities/editable_profile.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/album_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the curated iOS seed fixtures', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final profile = ProfileEditRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    final repository = UserRepositoryImpl(AssetJsonProvider(), profile);

    final users = await repository.getUsers();
    final cityUsers = await repository.getCityUsers();
    final verifiedUsers = await repository.getVerifiedUsers();

    expect(
      users.map((user) => user.id),
      List.generate(11, (index) => index + 1),
    );
    expect(
      cityUsers.map((user) => user.id),
      List.generate(11, (index) => index + 1),
    );
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
    expect(users.firstWhere((user) => user.id == 11).nickname, '南乔');
    expect(users, everyElement(isA<Object>()));
    expect(users.every((user) => user.isSeedData), isTrue);
    expect(cityUsers.every((user) => user.isSeedData), isTrue);
    expect(verifiedUsers.every((user) => user.isSeedData), isTrue);
    expect(cityUsers.every((user) => !user.isRealPersonVerified), isTrue);
    expect(verifiedUsers.every((user) => !user.isRealPersonVerified), isTrue);
    expect(verifiedUsers.any((user) => user.isOnline), isTrue);
    expect(verifiedUsers.any((user) => !user.isOnline), isTrue);
    expect(cityUsers.any((user) => user.isOnline), isTrue);
    expect(cityUsers.any((user) => !user.isOnline), isTrue);
    expect(
      verifiedUsers.every(
        (user) =>
            user.videoCoverPath == 'assets/images/video_user/video_cover.png' &&
            user.videoAvatarPath == 'assets/images/video_user/video_avatar.png',
      ),
      isTrue,
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
        if (user.videoCoverPath.isNotEmpty) user.videoCoverPath,
        if (user.videoAvatarPath.isNotEmpty) user.videoAvatarPath,
        if (user.videoPath.isNotEmpty) user.videoPath,
      ],
    };
    for (final path in paths) {
      final uri = Uri.tryParse(path);
      if (uri?.scheme == 'https') {
        expect(uri?.host, anyOf('images.unsplash.com', 'plus.unsplash.com'));
      } else {
        expect(await rootBundle.load(path), isNotNull, reason: path);
      }
    }
  });

  test('uses the same public id format on every profile surface', () {
    const user = User(
      id: 2,
      nickname: '沐野',
      age: 24,
      gender: '女',
      hobbies: [],
      avatarPath: '',
      intro: '',
      isVerified: false,
    );

    expect(user.displayId, '1237502');
  });

  test(
    'keeps unique user content, activity ownership, and city identity',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final profile = ProfileEditRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      final repository = UserRepositoryImpl(AssetJsonProvider(), profile);

      final users = await repository.getUsers();
      final cityUsers = await repository.getCityUsers();
      expect(users, hasLength(11));
      expect(users.map((user) => user.id).toSet(), hasLength(11));
      expect(users.map((user) => user.nickname).toSet(), hasLength(11));
      expect(users.map((user) => user.avatarPath).toSet(), hasLength(11));
      expect(
        users.map((user) => user.avatarPath).toSet(),
        AppImageString.demoUserAvatarUrls.values.toSet(),
      );
      expect(
        cityUsers.map((user) => user.avatarPath).toSet(),
        AppImageString.demoUserAvatarUrls.values.toSet(),
      );
      expect(users.map((user) => user.intro).toSet(), hasLength(11));
      expect(users.map((user) => user.moment?.content).toSet(), hasLength(11));
      expect(users.every((user) => user.galleryImagePaths.isNotEmpty), isTrue);

      final activities = users.map((user) => user.teamPost).nonNulls;
      expect(
        activities.map((activity) => activity.id).toSet(),
        hasLength(activities.length),
      );
      for (final user in users.where((user) => user.teamPost != null)) {
        expect(user.teamPost!.id, isNotEmpty);
        expect(user.teamPost!.ownerId, user.id);
      }

      final registeredScenes = AppImageString.demoSceneUrls.toSet();
      final remoteContentPaths = <String>{
        for (final user in users) ...[
          ...user.galleryImagePaths,
          ...?user.moment?.imagePaths,
          ...?user.teamPost?.imagePaths,
        ],
        for (final cityUser in cityUsers) ...cityUser.galleryImagePaths,
      }.where((path) => Uri.tryParse(path)?.scheme == 'https');
      expect(remoteContentPaths, everyElement(isIn(registeredScenes)));

      for (final cityUser in cityUsers) {
        final source = users.singleWhere((user) => user.id == cityUser.id);
        final mapped = cityUser.toUser();
        expect(mapped.id, source.id);
        expect(mapped.nickname, source.nickname);
        expect(mapped.avatarPath, source.avatarPath);
        expect(mapped.intro, source.intro);
        expect(mapped.hobbies, source.hobbies);
        expect(mapped.galleryImagePaths, source.galleryImagePaths);
      }
    },
  );

  test('overlays profile edits on the current user only', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final profile = ProfileEditRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    final repository = UserRepositoryImpl(AssetJsonProvider(), profile);
    final otherBefore = (await repository.getUsers()).firstWhere(
      (user) => user.id == 1,
    );

    await profile.updateNickname('新昵称');
    await profile.updateBio('新简介');

    final users = await repository.getUsers();
    final cityUsers = await repository.getCityUsers();
    final current = users.firstWhere((user) => user.id == 2);
    final currentCityUser = cityUsers.firstWhere((user) => user.id == 2);
    final otherAfter = users.firstWhere((user) => user.id == 1);
    expect(current.nickname, '新昵称');
    expect(current.intro, '新简介');
    expect(currentCityUser.nickname, '新昵称');
    expect(currentCityUser.intro, '新简介');
    expect(otherAfter.nickname, otherBefore.nickname);
    expect(otherAfter.intro, otherBefore.intro);
  });

  test(
    'exposes the edited profile and local album from the canonical current user',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final profile = ProfileEditRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      final repository = UserRepositoryImpl(
        AssetJsonProvider(),
        profile,
        null,
        const _AlbumWithPhoto('/documents/album/photos/uploaded.jpg'),
      );
      final source = await repository.getCurrentUser();
      await profile.initializeIfAbsent(
        EditableProfile.fromUser(source, avatarReference: 'userDefault'),
      );
      await profile.updateNickname('星光旅人');
      await profile.updateBio('把今天收进相册里。');
      await profile.updateInterests(['摄影', '徒步']);
      await profile.updatePersonalityTags(['城市漫游', '行动派']);

      final current = await repository.getCurrentUser();
      final currentCityUser = (await repository.getCityUsers()).singleWhere(
        (user) => user.id == current.id,
      );

      expect(current.nickname, '星光旅人');
      expect(current.intro, '把今天收进相册里。');
      expect(current.hobbies, ['摄影', '徒步']);
      expect(current.personalityTags, ['城市漫游', '行动派']);
      expect(
        current.galleryImagePaths.first,
        '/documents/album/photos/uploaded.jpg',
      );
      expect(
        current.galleryImagePaths,
        contains('/documents/album/photos/uploaded.jpg'),
      );
      expect(
        currentCityUser.galleryImagePaths,
        contains('/documents/album/photos/uploaded.jpg'),
      );
    },
  );
}

class _AlbumWithPhoto implements AlbumRepository {
  const _AlbumWithPhoto(this.photoPath);

  final String photoPath;

  @override
  List<AlbumItem> get photos => [
    AlbumItem(
      id: 'uploaded-photo',
      relativePath: 'album/photos/uploaded.jpg',
      kind: AlbumMediaKind.photo,
      createdAt: DateTime(2026),
    ),
  ];

  @override
  List<AlbumItem> get videos => const [];

  @override
  bool get hasProfilePhotoOverrides => true;

  @override
  Future<List<AlbumItem>> profilePhotos({
    required int userId,
    required List<String> seedPhotoPaths,
    required String avatarPath,
  }) async => photos;

  @override
  Future<String> fullPath(AlbumItem item) async => photoPath;

  @override
  Future<int> importFiles(List<String> sourcePaths, AlbumMediaKind kind) =>
      throw UnsupportedError('Not used by this test');

  @override
  Future<void> remove(Set<String> ids, AlbumMediaKind kind) =>
      throw UnsupportedError('Not used by this test');

  @override
  Future<void> removeProfilePhotos({
    required int userId,
    required Set<String> ids,
  }) => throw UnsupportedError('Not used by this test');
}
