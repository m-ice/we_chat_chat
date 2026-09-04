import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/home_city_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/social_state_repository_impl.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/main.dart';

void main() {
  setUp(() async => Get.reset());
  tearDown(Get.reset);

  testWidgets('starts on the Figma home and preserves the five-tab order', (
    tester,
  ) async {
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

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('找搭子'), findsOneWidget);
    expect(find.text('广场'), findsOneWidget);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('有颜有趣的人·尽在附近搭子'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-activity-card')), findsWidgets);
    expect(find.text('创建活动'), findsOneWidget);
    final heroBackground = find.byKey(const ValueKey('home-hero-background'));
    expect(tester.getSize(heroBackground), const Size(343, 185));
    expect(tester.getTopLeft(heroBackground), const Offset(16, 1.5));
    expect(
      tester.getSize(find.byKey(const ValueKey('home-recommendation-panel'))),
      const Size(319, 85),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey('home-recommendation-panel')),
      ),
      const Offset(28, 59),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-explore-nearby'))),
      const Size(178, 44),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-explore-nearby'))),
      const Offset(98.5, 165),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-activity-card')).first),
      const Size(343, 139),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-activity-card')).first),
      const Offset(16, 221),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-create-activity'))),
      const Size(114, 42),
    );
    final createButtonTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('home-create-activity')),
    );
    expect(createButtonTopLeft.dx, closeTo(249, 1));
    expect(createButtonTopLeft.dy, closeTo(675, 2));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppImage &&
            widget.source.startsWith('assets/icons/tabbar/'),
      ),
      findsNWidgets(5),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('home-recommendation-0')));
    await tester.pumpAndSettle();
    expect(find.text('交谈'), findsOneWidget);
    Get.back<void>();
    await tester.pumpAndSettle();
    expect(find.text('有颜有趣的人·尽在附近搭子'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home matches the overflow-free 375 by 812 frame in English', (
    tester,
  ) async {
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
        locale: const Locale('en', 'US'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Interesting people are nearby'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-create-activity')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects, filters, and restores the persisted home city', (
    tester,
  ) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({'wl_age_18_confirmed': true});
    final preferences = await SharedPreferences.getInstance();
    final repository = HomeCityRepositoryImpl(AssetJsonProvider(), preferences);
    expect(repository.selectedCity, '全部');

    await tester.pumpWidget(
      MiTuApp(
        key: UniqueKey(),
        preferences: preferences,
        locale: const Locale('zh', 'CN'),
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed<void>(Routes.homeCityPicker);
    await tester.pumpAndSettle();

    expect(find.text('选择城市'), findsOneWidget);
    expect(find.text('阿坝'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), '深圳');
    await tester.pump();
    expect(find.widgetWithText(ListTile, '深圳'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, '深圳'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final restored = HomeCityRepositoryImpl(
      AssetJsonProvider(),
      await SharedPreferences.getInstance(),
    );
    expect(restored.selectedCity, '深圳');
  });

  testWidgets('activity filter searches the iOS fields and resets', (
    tester,
  ) async {
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

    Get.toNamed<void>(Routes.homeActivityFilter);
    await tester.pumpAndSettle();
    expect(find.text('活动筛选'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '骑行');
    await tester.pump();
    expect(find.text('骑行'), findsOneWidget);

    await tester.tap(find.text('重置'));
    await tester.pump();
    expect(find.text('骑行'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('social state is shared and persisted with the iOS keys', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final social = SocialStateRepositoryImpl(preferences);

    await social.setFollowed(7, true);
    await social.setPendingJoin(7, true);
    await social.block(9);
    await social.shield(10);

    final restored = SocialStateRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    expect(restored.followedIds, contains(7));
    expect(restored.pendingJoinIds, contains(7));
    expect(restored.blockedIds, contains(9));
    expect(restored.shieldedIds, contains(10));
  });
}
