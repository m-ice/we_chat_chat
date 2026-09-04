import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/app/routes/routes.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/domain/repositories/team_detail_repository.dart';
import 'package:we_chat_chat/domain/repositories/user_repository.dart';
import 'package:we_chat_chat/main.dart';
import 'package:we_chat_chat/modules/home/team_detail/team_detail_controller.dart';

void main() {
  setUp(Get.reset);
  tearDown(Get.reset);

  testWidgets('joined members open the canonical activity member list', (
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

    final users = await Get.find<UserRepository>().getUsers();
    final currentUser = await Get.find<UserRepository>().getCurrentUser();
    final states = await AssetJsonProvider().readList(
      'assets/mock/team_detail_state.json',
    );
    final state = states.firstWhere((value) {
      final memberIds = List<int>.from(value['participantUserIds'] as List);
      final activityId = value['activityId'] as String;
      final organizer = users.singleWhere(
        (user) => user.teamPost?.id == activityId,
      );
      return !memberIds.contains(currentUser.id) &&
          organizer.id != currentUser.id;
    });
    final activityId = state['activityId'] as String;
    final organizer = users.singleWhere(
      (user) => user.teamPost?.id == activityId,
    );

    Get.toNamed<void>(
      Routes.teamDetail,
      arguments: TeamDetailArguments(
        user: organizer,
        post: organizer.teamPost!,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Get.find<TeamDetailController>().isCurrentUserParticipant.value,
      isFalse,
    );

    await tester.tap(find.byKey(const ValueKey('team-detail-join')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-confirm-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('app-confirm-cancel')));
    await tester.pumpAndSettle();
    expect(
      Get.find<TeamDetailController>().isCurrentUserParticipant.value,
      isFalse,
    );

    await tester.tap(find.byKey(const ValueKey('team-detail-join')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('app-confirm-submit')));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.teamDetail);
    expect(
      Get.find<TeamDetailController>().isCurrentUserParticipant.value,
      isTrue,
    );
    final persisted = await Get.find<TeamDetailRepository>().getSeedState(
      activityId,
    );
    expect(persisted.participantUserIds, contains(currentUser.id));

    await tester.tap(find.byKey(const ValueKey('team-detail-join')));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.teamMembers);
    expect(find.text('活动成员'), findsOneWidget);
    for (final memberId in persisted.participantUserIds) {
      expect(
        find.text(users.singleWhere((user) => user.id == memberId).nickname),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
