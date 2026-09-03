import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/routes.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/home_city_repository.dart';
import '../../../../domain/repositories/membership_wallet_repository.dart';
import '../../../../domain/repositories/social_state_repository.dart';
import '../../../../domain/repositories/user_repository.dart';

class ActivityFilterController extends GetxController {
  ActivityFilterController(
    this._users,
    this._cities,
    this._social,
    this._wallet,
  );

  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository _social;
  final MembershipWalletRepository _wallet;
  Set<int> get pendingJoinIds => _social.pendingJoinIds;

  final source = <User>[].obs;
  final results = <User>[].obs;
  final keyword = ''.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    hasError.value = false;
    try {
      final city = _cities.selectedCity;
      final excluded = {..._social.blockedIds, ..._social.shieldedIds};
      source.assignAll(
        (await _users.getUsers()).where((user) {
          final post = user.teamPost;
          return post != null &&
              !excluded.contains(user.id) &&
              (city == '全部' ||
                  post.location.contains(city) ||
                  post.content.contains(city));
        }),
      );
      search(keyword.value);
    } on Object {
      hasError.value = true;
    }
  }

  void search(String value) {
    final query = value.trim();
    keyword.value = query;
    if (query.isEmpty) {
      results.clear();
      return;
    }
    results.assignAll(
      source.where((user) {
        final post = user.teamPost!;
        return [
          post.activity,
          post.location,
          post.content,
          user.nickname,
          user.hobbies.join(','),
        ].any((text) => text.toLowerCase().contains(query.toLowerCase()));
      }),
    );
  }

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
    await _social.setPendingJoin(user.id, true);
    results.refresh();
    Get.snackbar(
      'common_tip'.tr,
      'team_join_requested'.trParams({'name': user.nickname}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
