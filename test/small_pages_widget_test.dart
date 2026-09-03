import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('core pages fit a small iPhone in English', (tester) async {
    tester.view.physicalSize = const Size(960, 1704);
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
        locale: const Locale('en', 'US'),
      ),
    );
    await tester.pumpAndSettle();

    final user = (await Get.find<UserRepository>().getUsers()).first;
    await _open(tester, Routes.userDetail, arguments: user);
    expect(find.text('Invite'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _back(tester);
    await _open(tester, Routes.teamDetail, arguments: user);
    expect(find.text('Organizer: 晓风'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _back(tester);
    await _open(tester, Routes.teamPublish);
    expect(find.text('Create a Team'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _back(tester);
    await tester.tap(find.byKey(const ValueKey('main-tab-4')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _open(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  Get.toNamed<void>(route, arguments: arguments);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _back(WidgetTester tester) async {
  Get.back<void>();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
