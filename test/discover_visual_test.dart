import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/main.dart';

void main() {
  setUp(() async => Get.reset());
  tearDown(Get.reset);

  testWidgets('discover pages match the 375pt Figma geometry', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
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

    await tester.tap(find.byKey(const ValueKey('main-tab-1')));
    await tester.pumpAndSettle();

    final first = find.byKey(const ValueKey('partner-tile-0'));
    final second = find.byKey(const ValueKey('partner-tile-1'));
    expect(tester.getSize(first).width, closeTo(175.5, .01));
    expect(tester.getSize(first).height, 238);
    expect(tester.getTopLeft(first).dx, 8);
    expect(tester.getTopLeft(second).dx - tester.getTopLeft(first).dx, 183.5);
    expect(find.text('交谈'), findsWidgets);
    expect(find.text('在线'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
