import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../domain/entities/square_feed.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';

class TopicDetailController extends GetxController {
  TopicDetailController(this.topic, this._users, this.social, this._wallet);
  final TopicItem topic;
  final UserRepository _users;
  final SocialStateRepository social;
  final MembershipWalletRepository _wallet;
  final users = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    final excluded = {...social.blockedIds, ...social.shieldedIds};
    users.assignAll(
      (await _users.getUsers()).where(
        (user) =>
            user.teamPost?.activity == topic.id && !excluded.contains(user.id),
      ),
    );
  }

  void refreshState() => users.refresh();

  Future<void> join(User user) async {
    if (!_wallet.isVipActive) {
      await Get.dialog<void>(
        AlertDialog(
          title: Text('vip_privilege'.tr),
          content: Text('vip_join_required'.tr),
          actions: [
            TextButton(onPressed: Get.back, child: Text('common_cancel'.tr)),
            TextButton(
              onPressed: () {
                Get.back<void>();
                Get.toNamed(Routes.vip);
              },
              child: Text('vip_open'.tr),
            ),
          ],
        ),
      );
      return;
    }
    await social.setPendingJoin(user.id, true);
    users.refresh();
    Get.snackbar(
      'common_tip'.tr,
      'team_join_requested'.trParams({'name': user.nickname}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
