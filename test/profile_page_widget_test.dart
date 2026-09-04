import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('profile page exposes its current profile entry points', (
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
    final edit = _asset('figma_profile_icon_edit.png');
    final world = _asset('figma_profile_icon_world.png');
    final album = _asset('my_image.png');
    final support = _asset('figma_profile_icon_support.png');
    final aboutUs = _asset('about_us.png');
    final settings = _asset('my_setting.png');

    expect(tester.getRect(header), const Rect.fromLTWH(0, 0, 375, 255));
    expect(
      tester.getRect(find.byKey(const ValueKey('profile-avatar'))),
      const Rect.fromLTWH(143.5, 80, 88, 88),
    );
    expect(edit, findsOneWidget);
    expect(world, findsOneWidget);
    expect(album, findsOneWidget);
    expect(support, findsOneWidget);
    expect(aboutUs, findsOneWidget);
    expect(settings, findsOneWidget);
    expect(find.text('我的动态'), findsOneWidget);
    expect(find.text('真人认证'), findsNothing);
    expect(tester.takeException(), isNull);

    for (final route in [
      (album, Routes.album),
      (world, Routes.myWorld),
      (aboutUs, Routes.aboutUs),
      (settings, Routes.settings),
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
