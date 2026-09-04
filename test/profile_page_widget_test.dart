import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('profile page matches the 375 by 812 Figma geometry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 132, bottom: 102);
    tester.view.viewPadding = const FakeViewPadding(top: 132, bottom: 102);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

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

    await tester.tap(find.byKey(const ValueKey('main-tab-4')));
    await tester.pumpAndSettle();

    final header = _asset('figma_profile_header.png');
    final summary = _asset('figma_profile_card.png');
    final coins = _asset('figma_profile_quick_coin.png');
    final membership = _asset('figma_profile_quick_vip.png');
    final album = _asset('figma_profile_quick_album.png');
    final edit = _asset('figma_profile_icon_edit.png');
    final world = _asset('figma_profile_icon_world.png');
    final support = _asset('figma_profile_icon_support.png');
    final privacy = _asset('figma_profile_icon_privacy.png');
    final agreement = _asset('figma_profile_icon_agreement.png');

    expect(tester.getRect(header), const Rect.fromLTWH(0, 0, 375, 255));
    expect(
      tester.getRect(find.byKey(const ValueKey('profile-avatar'))),
      const Rect.fromLTWH(143.5, 80, 88, 88),
    );
    expect(tester.getRect(summary), const Rect.fromLTWH(16, 239, 343, 93));
    expect(tester.getRect(coins), const Rect.fromLTWH(50, 251, 44, 44));
    expect(tester.getRect(membership), const Rect.fromLTWH(164, 251, 44, 44));
    expect(tester.getRect(album), const Rect.fromLTWH(280, 251, 44, 44));
    expect(tester.getRect(edit), const Rect.fromLTWH(20, 356, 28, 28));
    expect(tester.getRect(world), const Rect.fromLTWH(20, 416, 28, 28));
    expect(tester.getRect(support), const Rect.fromLTWH(20, 476, 28, 28));
    expect(tester.getRect(privacy), const Rect.fromLTWH(20, 536, 28, 28));
    expect(tester.getRect(agreement), const Rect.fromLTWH(20, 596, 28, 28));
    expect(find.text('我的动态'), findsOneWidget);
    expect(find.text('真人认证'), findsNothing);
    expect(tester.takeException(), isNull);

    for (final route in [
      (coins, Routes.coins),
      (membership, Routes.vip),
      (album, Routes.album),
    ]) {
      await tester.tap(route.$1);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, route.$2);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });
}

Finder _asset(String filename) => find.byWidgetPredicate(
  (widget) => widget is AppImage && widget.source.endsWith(filename),
);
