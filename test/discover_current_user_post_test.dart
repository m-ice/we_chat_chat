import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:we_chat_chat/core/vaules/app_image_string.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/domain/entities/square_feed.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/main.dart';
import 'package:we_chat_chat/modules/discover/controllers/square_controller.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('square hides the more action for a current-user post', (
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

    await tester.tap(find.byKey(const ValueKey('main-tab-2')));
    await tester.pumpAndSettle();

    final controller = Get.find<SquareController>();
    final currentUser = await Get.find<UserRepository>().getCurrentUser();
    controller.items.insert(
      0,
      SquareFeedItem(
        postId: 'current-user-post',
        user: currentUser,
        content: '我的动态',
        imagePaths: const [],
        time: '2026-09-04 09:41',
        usesSandboxImages: false,
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('square-post-0')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AppImage &&
              widget.source == AppImageString.discoverMore,
        ),
      ),
      findsNothing,
    );
  });
}
