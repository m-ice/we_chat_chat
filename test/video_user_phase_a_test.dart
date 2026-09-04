import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/bindings/initial_binding.dart';
import 'package:we_chat_chat/domain/entities/user.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/domain/repositories/home_city_repository.dart';
import 'package:we_chat_chat/domain/repositories/membership_wallet_repository.dart';
import 'package:we_chat_chat/domain/repositories/report_repository.dart';
import 'package:we_chat_chat/domain/repositories/social_state_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_detail_repository.dart';
import 'package:we_chat_chat/domain/repositories/video_engagement_repository.dart';
import 'package:we_chat_chat/modules/discover/controllers/video_feed_controller.dart';
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
      'assets/images/video_user/video_avatar.png',
    );
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
    );
    final controller = UserDetailController(
      user,
      Get.find<SocialStateRepository>(),
      Get.find<ChatRepository>(),
      Get.find<MembershipWalletRepository>(),
      Get.find<UserRepository>(),
      Get.find<UserDetailRepository>(),
    );

    await controller.reloadProfile();
    expect(controller.heroImagePath, contains('video_user/profile_hero.png'));
    expect(controller.galleryPreviewPaths, hasLength(3));
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

  test(
    'profile and nearby interactions preserve user and activity identity',
    () async {
      final users = await Get.find<UserRepository>().getUsers();
      final cityUsers = await Get.find<UserRepository>().getCityUsers();
      final home = HomeController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        Get.find<SocialStateRepository>(),
        Get.find<MembershipWalletRepository>(),
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
          Get.find<MembershipWalletRepository>(),
          Get.find<UserRepository>(),
          Get.find<UserDetailRepository>(),
        );
        await controller.reloadProfile();
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
    final controller = ReportController(user, Get.find<ReportRepository>());
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
}
