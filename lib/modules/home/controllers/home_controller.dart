import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/city_user_mapper.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../team_detail/team_detail_controller.dart';

enum HomeFeedTab { nearby }

class HomeController extends GetxController {
  HomeController(this._users, this._cities, this._social, this._wallet);

  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository _social;
  final MembershipWalletRepository _wallet;

  final selectedCity = '全部'.obs;
  final activityUsers = <User>[].obs;
  final nearbyUsers = <CityUser>[].obs;
  final newcomerUsers = <CityUser>[].obs;
  final followedIds = <int>{}.obs;
  final pendingJoinIds = <int>{}.obs;
  final hasError = false.obs;

  late StreamController<OperateEvent> eventStreamController;

  @override
  void onInit() {
    super.onInit();
    eventStreamController = StreamController.broadcast();
    selectedCity.value = _cities.selectedCity;
    followedIds.assignAll(_social.followedIds);
    pendingJoinIds.assignAll(_social.pendingJoinIds);
    load();
  }

  @override
  void onClose() {
    eventStreamController.close();
    super.onClose();
  }

  Future<void> load() async {
    hasError.value = false;
    try {
      final results = await Future.wait([
        _users.getUsers(),
        _users.getCityUsers(),
        _users.getVerifiedUsers(),
      ]);
      final city = selectedCity.value;
      final allRegions = city == '全部';
      final excluded = {..._social.blockedIds, ..._social.shieldedIds};
      final matchingActivities = (results[0] as List<User>)
          .where(
            (user) =>
                !excluded.contains(user.id) &&
                user.teamPost != null &&
                (allRegions ||
                    user.teamPost!.location.contains(city) ||
                    user.teamPost!.content.contains(city)),
          )
          .toList();
      final upcomingActivities = matchingActivities
          .where((user) => !user.teamPost!.isExpired(DateTime.now()))
          .toList();
      activityUsers.assignAll(upcomingActivities);
      nearbyUsers.assignAll(
        (results[1] as List<CityUser>).where(
          (user) =>
              !excluded.contains(user.id) && (allRegions || user.city == city),
        ),
      );
      newcomerUsers.assignAll(
        (results[2] as List<CityUser>).where(
          (user) =>
              !excluded.contains(user.id) && (allRegions || user.city == city),
        ),
      );
    } on Object {
      hasError.value = true;
    }
  }

  Future<void> applySelectedCity(String city) async {
    selectedCity.value = city;
    await load();
  }

  Future<User> resolveUser(CityUser cityUser) async {
    final cached = activityUsers.where((user) => user.id == cityUser.id);
    if (cached.isNotEmpty) return cached.first;
    final users = await _users.getUsers();
    final matches = users.where((user) => user.id == cityUser.id);
    return matches.isEmpty ? cityUser.toUser() : matches.first;
  }

  Future<void> openUser(CityUser cityUser) async {
    final user = await resolveUser(cityUser);
    await Get.toNamed(Routes.userDetail, arguments: user);
  }

  Future<HomeFeedTab?> openActivity(User user) async {
    final post = user.teamPost;
    if (post == null) return null;
    return Get.toNamed<HomeFeedTab>(
      Routes.teamDetail,
      arguments: TeamDetailArguments(user: user, post: post),
    );
  }

  Future<void> toggleFollow(int userId) async {
    final next = Set<int>.from(followedIds);
    next.contains(userId) ? next.remove(userId) : next.add(userId);
    followedIds.assignAll(next);
    final followed = next.contains(userId);
    await _social.setFollowed(userId, followed);
    AppToast.show(followed ? 'social_followed'.tr : 'social_unfollowed'.tr);
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
    refreshSocialState();
    AppToast.show('team_join_requested'.trParams({'name': user.nickname}));
  }

  void refreshSocialState() {
    followedIds.assignAll(_social.followedIds);
    pendingJoinIds.assignAll(_social.pendingJoinIds);
  }
}
