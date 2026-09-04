import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/main.dart';
import 'package:we_chat_chat/modules/discover/controllers/square_controller.dart';
import 'package:we_chat_chat/modules/discover/controllers/video_feed_controller.dart';
import 'package:we_chat_chat/modules/user_detail/controllers/user_detail_controller.dart';

void main() {
  setUp(() async => Get.reset());
  tearDown(Get.reset);

  testWidgets('discover pages match the 375pt Figma geometry', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({'wl_age_18_confirmed': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MiTuApp(
        key: UniqueKey(),
        preferences: preferences,
        locale: const Locale('zh', 'CN'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('main-tab-2')));
    await tester.pumpAndSettle();

    expect(find.text('发现'), findsOneWidget);
    expect(find.text('关注'), findsWidgets);
    expect(find.text('视频'), findsOneWidget);
    expect(find.byKey(const ValueKey('square-publish')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('square-post-0'))).width,
      343,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('square-publish'))),
      const Size(92, 36),
    );
    final squareItem = Get.find<SquareController>().items.first;
    final squareAvatar = tester.widget<AppImage>(
      find.descendant(
        of: find.byKey(ValueKey('square-author-${squareItem.postId}')),
        matching: find.byType(AppImage),
      ),
    );
    expect(squareAvatar.source, squareItem.user.avatarPath);

    await tester.tap(find.byKey(const ValueKey('main-tab-1')));
    await tester.pumpAndSettle();

    final partnerUser = Get.find<VideoFeedController>().users.first;
    final first = find.byKey(const ValueKey('partner-tile-0'));
    final second = find.byKey(const ValueKey('partner-tile-1'));
    expect(tester.getSize(first).width, closeTo(175.5, .01));
    expect(tester.getSize(first).height, 238);
    expect(tester.getTopLeft(first).dx, 8);
    expect(tester.getTopLeft(second).dx - tester.getTopLeft(first).dx, 183.5);
    expect(find.text('交谈'), findsWidgets);
    expect(find.text('在线'), findsWidgets);
    final partnerUsers = Get.find<VideoFeedController>().users;
    expect(partnerUsers.any((user) => user.isOnline), isTrue);
    expect(partnerUsers.any((user) => !user.isOnline), isTrue);
    final partnerImages = tester.widgetList<AppImage>(
      find.descendant(of: first, matching: find.byType(AppImage)),
    );
    expect(
      partnerImages.map((image) => image.source),
      contains(partnerUser.avatarPath),
    );

    await tester.tap(first);
    await tester.pumpAndSettle();
    final profile = Get.find<UserDetailController>();
    expect(profile.user.id, partnerUser.id);
    expect(profile.user.avatarPath, partnerUser.avatarPath);
    expect(profile.heroImagePath, partnerUser.avatarPath);
    expect(tester.takeException(), isNull);
  });
}
