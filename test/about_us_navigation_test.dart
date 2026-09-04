import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('profile opens the about us route with legal links', (
    tester,
  ) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({'wl_age_18_confirmed': true});
    PackageInfo.setMockInitialValues(
      appName: '微撩',
      packageName: 'com.example.wechat',
      version: '9.8.7',
      buildNumber: '42',
      buildSignature: '',
    );
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MiTuApp(preferences: preferences, locale: const Locale('zh', 'CN')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('main-tab-4')));
    await tester.pumpAndSettle();
    final aboutUs = find.text('关于我们');
    await tester.ensureVisible(aboutUs);
    await tester.tap(aboutUs);
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.aboutUs);
    expect(find.text('微撩'), findsOneWidget);
    expect(find.text('Version–9.8.7'), findsOneWidget);
    expect(find.text('用户协议'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
  });
}
