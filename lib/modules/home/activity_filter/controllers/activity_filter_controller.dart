import 'package:get/get.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_toast.dart';
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
              !post.isExpired(DateTime.now()) &&
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
    if (user.teamPost?.isExpired(DateTime.now()) ?? true) {
      AppToast.show('team_activity_ended'.tr);
      await load();
      return;
    }
    if (!_wallet.isVipActive) {
      final openVip = await AppDialog.confirm(
        title: 'vip_privilege'.tr,
        message: 'vip_join_required'.tr,
        confirmText: 'vip_open'.tr,
      );
      if (openVip) await Get.toNamed<void>(Routes.vip);
      return;
    }
    await _social.setPendingJoin(user.id, true);
    results.refresh();
    AppToast.show('team_join_requested'.trParams({'name': user.nickname}));
  }
}
