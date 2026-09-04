import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/bindings/initial_binding.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/entities/city_user.dart';
import 'package:we_chat_chat/domain/entities/editable_profile.dart';
import 'package:we_chat_chat/domain/repositories/ai_repository.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/domain/repositories/home_city_repository.dart';
import 'package:we_chat_chat/domain/repositories/team_detail_repository.dart';
import 'package:we_chat_chat/domain/policies/feature_access_gate.dart';
import 'package:we_chat_chat/domain/repositories/report_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/domain/repositories/profile_edit_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_detail_repository.dart';
import 'package:we_chat_chat/domain/repositories/video_engagement_repository.dart';
import 'package:we_chat_chat/modules/discover/controllers/video_feed_controller.dart';
import 'package:we_chat_chat/modules/chat/controllers/chat_thread_controller.dart';
import 'package:we_chat_chat/modules/home/controllers/home_controller.dart';
import 'package:we_chat_chat/modules/shared/report/report_controller.dart';
import 'package:we_chat_chat/modules/shared/report/report_page.dart';
import 'package:we_chat_chat/modules/user_detail/controllers/user_detail_controller.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    InitialBinding(preferences).dependencies();
  });

  tearDown(Get.reset);

  test('seed video users use committed Figma presentation assets', () async {
    final controller = VideoFeedController(
      Get.find<UserRepository>(),
      Get.find<HomeCityRepository>(),
      Get.find<SocialStateRepository>(),
      Get.find<VideoEngagementRepository>(),
    );

    await controller.reload();

    expect(controller.videoUsers, isNotEmpty);
    expect(
      controller.coverPathFor(controller.videoUsers.first),
      'assets/images/video_user/video_cover.png',
    );
    expect(
      controller.avatarPathFor(controller.videoUsers.first),
      controller.videoUsers.first.avatarPath,
    );
  });

  test('search routes only users with a video into the video feed', () async {
    final controller = VideoFeedController(
      Get.find<UserRepository>(),
      Get.find<HomeCityRepository>(),
      Get.find<SocialStateRepository>(),
      Get.find<VideoEngagementRepository>(),
    );
    await controller.reload();

    final profileOnlyUser = controller.searchableUsers.firstWhere(
      (user) => !VideoFeedController.hasVideo(user),
    );
    final videoUser = controller.searchableUsers.firstWhere(
      VideoFeedController.hasVideo,
    );

    expect(controller.videoFeedArgumentsFor(profileOnlyUser), isNull);

    final arguments = controller.videoFeedArgumentsFor(videoUser);
    expect(arguments, isNotNull);
    expect(arguments!.users, everyElement(VideoFeedController.hasVideo));
    expect(arguments.users[arguments.startIndex].id, videoUser.id);
  });

  test('blocking a user refreshes partner and active search results', () async {
    final social = Get.find<SocialStateRepository>();
    final feed = Get.put(
      VideoFeedController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        social,
        Get.find<VideoEngagementRepository>(),
      ),
    );
    await feed.reload();
    final target = feed.searchableUsers.first;
    final search = Get.put(CenterSearchController(feed, social));
    search.query.text = target.nickname;
    search.search(search.query.text);

    expect(search.results.map((user) => user.id), contains(target.id));

    await social.block(target.id);
    await _waitFor(
      () =>
          !feed.searchableUsers.any((user) => user.id == target.id) &&
          !search.results.any((user) => user.id == target.id),
    );

    feed.onClose();
    search.onClose();
  });

  test('video feed actions do not offer blocking the current user', () async {
    final users = Get.find<UserRepository>();
    final currentUser = await users.getCurrentUser();
    final controller = VideoFeedController(
      users,
      Get.find<HomeCityRepository>(),
      Get.find<SocialStateRepository>(),
      Get.find<VideoEngagementRepository>(),
    );
    final currentCityUser = CityUser(
      id: currentUser.id,
      nickname: currentUser.nickname,
      avatarPath: currentUser.avatarPath,
      city: '',
      age: currentUser.age,
      intent: '',
      occupation: '',
      intro: currentUser.intro,
      hobbies: currentUser.hobbies,
      galleryImagePaths: currentUser.galleryImagePaths,
      isVideoVerified: false,
      isRealPersonVerified: currentUser.isVerified,
      videoPath: '',
      isOnline: true,
    );

    await controller.more(currentCityUser);

    expect(
      Get.find<SocialStateRepository>().blockedIds,
      isNot(contains(currentUser.id)),
    );
  });

  test('chat cannot persist a message addressed to the current user', () async {
    final currentUser = await Get.find<UserRepository>().getCurrentUser();
    final chats = Get.find<ChatRepository>();
    final before = await chats.getMessages(currentUser.id);
    final controller = ChatThreadController(
      currentUser,
      chats,
      Get.find<AiRepository>(),
      Get.find<SocialStateRepository>(),
    );

    await controller.send('这条消息不应发送给自己');
    await controller.startVoiceCall();

    expect(await chats.getMessages(currentUser.id), before);
  });

  test('seed profile content is provided by the controller', () async {
    const user = User(
      id: 9001,
      nickname: 'Seed user',
      age: 24,
      gender: '女',
      hobbies: ['摄影', '旅行'],
      avatarPath: 'assets/images/avatar/img_verified_user_01.png',
      intro: 'Seed introduction',
      isVerified: true,
      isSeedData: true,
      galleryImagePaths: [
        'assets/images/video_user/profile_preview_1.png',
        'assets/images/avatar/img_verified_user_01.png',
        'assets/images/video_user/profile_preview_1.png',
        'assets/images/video_user/profile_preview_2.png',
      ],
    );
    final controller = UserDetailController(
      user,
      Get.find<SocialStateRepository>(),
      Get.find<ChatRepository>(),
      Get.find<FeatureAccessGate>(),
      Get.find<UserRepository>(),
      Get.find<UserDetailRepository>(),
    );

    await controller.reloadProfile();
    expect(controller.heroImagePath, user.avatarPath);
    expect(controller.galleryPreviewPaths, [
      'assets/images/video_user/profile_preview_1.png',
      'assets/images/video_user/profile_preview_2.png',
    ]);
    expect(controller.galleryPreviewPaths, isNot(contains(user.avatarPath)));
    expect(controller.facts, hasLength(2));
    expect(controller.activities, isEmpty);
    expect(controller.moments, hasLength(1));
    expect(() => controller.selectCarouselImage(2), returnsNormally);
    expect(controller.imageCarouselIndex.value, 2);
    final moment = controller.moments.first;
    expect(moment.id, 'user-9001-video-user-9001-moment-001');
    expect(controller.isLiked(moment), isFalse);
    expect(controller.likeCount(moment), 18);
    await Get.find<UserDetailRepository>().setMomentLiked(
      moment.id,
      true,
      initialLikeCount: moment.initialLikeCount,
    );
    expect(controller.isLiked(moment), isTrue);
    expect(controller.likeCount(moment), 19);

    controller.onClose();
  });

  test('user detail refreshes an edited current-user route snapshot', () async {
    final users = Get.find<UserRepository>();
    final staleUser = await users.getCurrentUser();
    final profile = Get.find<ProfileEditRepository>();
    await profile.initializeIfAbsent(
      EditableProfile.fromUser(staleUser, avatarReference: 'userDefault'),
    );
    await profile.updateNickname('晚风漫游者');
    await profile.updateBio('把心事写进每一次出发。');
    await profile.updateInterests(['摄影', '徒步']);
    await profile.updatePersonalityTags(['城市漫游', '行动派']);

    final controller = UserDetailController(
      staleUser,
      Get.find<SocialStateRepository>(),
      Get.find<ChatRepository>(),
      Get.find<FeatureAccessGate>(),
      users,
      Get.find<UserDetailRepository>(),
    );

    await controller.reloadProfile();

    expect(controller.isCurrentUser.value, isTrue);
    expect(controller.user.nickname, '晚风漫游者');
    expect(controller.user.intro, '把心事写进每一次出发。');
    expect(controller.user.hobbies, ['摄影', '徒步']);
    expect(controller.generatedPersonalityTags, ['城市漫游', '行动派']);
    expect(controller.galleryPreviewPaths, staleUser.galleryImagePaths);

    controller.onClose();
  });

  test(
    'profile and nearby interactions preserve user and activity identity',
    () async {
      final users = await Get.find<UserRepository>().getUsers();
      final cityUsers = await Get.find<UserRepository>().getCityUsers();
      final home = HomeController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        Get.find<SocialStateRepository>(),
        Get.find<FeatureAccessGate>(),
        Get.find<TeamDetailRepository>(),
      );
      final selectedActivityIds = <String>{};

      for (final userId in [1, 4, 10]) {
        final user = users.singleWhere((item) => item.id == userId);
        final nearby = cityUsers.singleWhere((item) => item.id == userId);
        final resolved = await home.resolveUser(nearby);
        expect(resolved.id, userId);
        expect(resolved.avatarPath, user.avatarPath);
        expect(resolved.moment?.content, user.moment?.content);
        expect(resolved.teamPost?.id, user.teamPost?.id);

        final controller = UserDetailController(
          user,
          Get.find<SocialStateRepository>(),
          Get.find<ChatRepository>(),
          Get.find<FeatureAccessGate>(),
          Get.find<UserRepository>(),
          Get.find<UserDetailRepository>(),
        );
        await controller.reloadProfile();
        expect(controller.heroImagePath, user.avatarPath);
        expect(controller.galleryPreviewPaths, user.galleryImagePaths);
        expect(
          controller.galleryPreviewPaths,
          isNot(contains(user.avatarPath)),
        );
        final seed = await Get.find<UserDetailRepository>().getSeedProfile(
          userId,
        );
        expect(
          controller.activities.map((item) => item.post.id),
          seed!.activities.map((item) => item.id),
        );
        for (final activity in controller.activities) {
          expect(activity.post.ownerId, userId);
          expect(selectedActivityIds.add(activity.post.id), isTrue);
        }
        controller.onClose();
      }

      expect(selectedActivityIds, hasLength(6));
    },
  );

  test(
    'home activity member avatars resolve from canonical participant ids',
    () async {
      final users = await Get.find<UserRepository>().getUsers();
      final home = HomeController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        Get.find<SocialStateRepository>(),
        Get.find<FeatureAccessGate>(),
        Get.find<TeamDetailRepository>(),
      );

      await home.load();

      expect(home.hasError.value, isFalse);
      for (final owner in home.activityUsers) {
        final post = owner.teamPost!;
        final state = await Get.find<TeamDetailRepository>().getSeedState(
          post.id,
          legacyOwnerId: post.ownerId,
        );
        final expectedAvatarPaths = state.participantUserIds
            .map((id) => users.singleWhere((user) => user.id == id).avatarPath)
            .toList(growable: false);
        final actualAvatarPaths = home.activityParticipantAvatarPaths[post.id]!;
        expect(actualAvatarPaths, expectedAvatarPaths);
        expect(actualAvatarPaths.toSet(), hasLength(actualAvatarPaths.length));
      }
    },
  );

  testWidgets('report page accepts a multiline problem description', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const user = User(
      id: 9001,
      nickname: 'Seed user',
      age: 24,
      gender: '女',
      hobbies: [],
      avatarPath: '',
      intro: '',
      isVerified: true,
      isSeedData: true,
    );
    final controller = ReportController(
      user,
      Get.find<ReportRepository>(),
      users: Get.find<UserRepository>(),
    );
    Get.put(controller);

    await tester.pumpWidget(buildTestApp(const ReportPage()));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('report-details')),
      '需要核实的内容\n第二行补充',
    );

    expect(controller.details.text, contains('第二行'));
    expect(find.byKey(const ValueKey('report-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'report controller does not queue a report about the current user',
    () async {
      final currentUser = await Get.find<UserRepository>().getCurrentUser();
      final controller = ReportController(
        currentUser,
        Get.find<ReportRepository>(),
        users: Get.find<UserRepository>(),
      );
      controller.details.text = '这条举报不应被保存';

      await controller.submit();

      expect(Get.find<ReportRepository>().queuedReports, isEmpty);
      controller.onClose();
    },
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue, reason: 'The reactive update did not complete.');
}
