import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/domain/repositories/chat_repository.dart';
import 'package:we_chat_chat/main.dart';
import 'package:we_chat_chat/modules/chat/views/widgets/chat_visuals.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('opens the assistant conversation with persisted history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 96);
    tester.view.viewPadding = const FakeViewPadding(top: 144, bottom: 96);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'wl_age_18_confirmed': true,
      'chat_seed_initialized_v1': true,
      'chat_messages_v1':
          '[{"id":"assistant-welcome","peerId":-1,"text":"欢迎来到微撩组队","isFromCurrentUser":false,"createdAt":"2026-09-02T09:00:00+08:00"}]',
    });
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MiTuApp(preferences: preferences, locale: const Locale('zh', 'CN')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('main-tab-3')));
    await tester.pumpAndSettle();
    expect(find.text('消息'), findsNWidgets(2));
    expect(tester.getTopLeft(find.text('消息').first), const Offset(16, 60));
    expect(
      tester.getSize(find.byKey(const ValueKey('message-header-artwork'))),
      const Size(375, 255),
    );
    final systemEntry = find.byKey(
      const ValueKey('assets/images/content/figma_chat_quick_system.png'),
    );
    expect(tester.getSize(systemEntry), const Size(52, 52));
    expect(tester.getTopLeft(systemEntry).dx, closeTo(20.875, .1));
    expect(tester.getTopLeft(systemEntry).dy, closeTo(106, .1));
    expect(find.byType(NotificationBadge), findsNWidgets(4));
    expect(find.text('99+'), findsNothing);
    final conversationRow = find.byKey(const ValueKey('conversation--1'));
    expect(tester.getSize(conversationRow).height, 76);
    expect(tester.getTopLeft(conversationRow).dy, closeTo(193, .1));
    expect(find.text('微撩助手'), findsOneWidget);
    expect(preferences.getInt('mt_weiliao_coin_balance'), 100);
    expect(preferences.getBool('mt_new_user_coin_gift_granted'), isTrue);
    await Get.find<ChatRepository>().initialize();
    expect(preferences.getInt('mt_weiliao_coin_balance'), 100);

    await tester.tap(find.text('微撩助手'));
    await tester.pumpAndSettle();
    expect(find.text('微撩助手'), findsOneWidget);
    expect(find.textContaining('欢迎来到微撩组队'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
