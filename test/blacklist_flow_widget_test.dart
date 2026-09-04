import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'settings removes a user from the persisted blacklist after confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        'wl_age_18_confirmed': true,
        'mt_home_blocked_user_ids': ['1'],
      });
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        MiTuApp(preferences: preferences, locale: const Locale('zh', 'CN')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('main-tab-4')));
      await tester.pumpAndSettle();
      final settings = find.text('设置');
      await tester.ensureVisible(settings);
      await tester.tap(settings);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.settings);

      await tester.tap(find.byKey(const ValueKey('settings-blacklist')));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.blacklist);
      expect(find.byKey(const ValueKey('blacklist-user-1')), findsOneWidget);

      await tester.tap(find.text('移除黑名单'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('app-confirm-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app-confirm-submit')));
      await tester.pumpAndSettle();
      expect(find.text('暂无黑名单用户'), findsOneWidget);
      expect(preferences.getStringList('mt_home_blocked_user_ids'), isEmpty);
    },
  );
}
