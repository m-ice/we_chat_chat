import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';

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
      activityUsers.assignAll(
        upcomingActivities.isNotEmpty
            ? upcomingActivities
            : _figmaFeaturedActivities(matchingActivities),
      );
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

  Future<void> toggleFollow(int userId) async {
    final next = Set<int>.from(followedIds);
    next.contains(userId) ? next.remove(userId) : next.add(userId);
    followedIds.assignAll(next);
    await _social.setFollowed(userId, next.contains(userId));
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
    refreshSocialState();
    Get.snackbar(
      'common_tip'.tr,
      'team_join_requested'.trParams({'name': user.nickname}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void refreshSocialState() {
    followedIds.assignAll(_social.followedIds);
    pendingJoinIds.assignAll(_social.pendingJoinIds);
  }

  List<User> _figmaFeaturedActivities(List<User> users) {
    if (users.isEmpty) return const [];
    final now = DateTime.now();
    var activityDate = DateTime(now.year, 12, 12, 12);
    if (activityDate.isBefore(now)) {
      activityDate = DateTime(now.year + 1, 12, 12, 12);
    }
    final primarySeed = users.first;
    final foodSeed = users.firstWhere(
      (user) =>
          user.id != primarySeed.id && user.teamPost!.activity.contains('吃饭'),
      orElse: () => users.length > 1 ? users[1] : primarySeed,
    );
    final runnerSeed = users.firstWhere(
      (user) =>
          user.id != primarySeed.id &&
          user.id != foodSeed.id &&
          user.teamPost!.activity.contains('骑行'),
      orElse: () => users.length > 2 ? users[2] : primarySeed,
    );
    final seeds = [primarySeed, foodSeed, runnerSeed];
    const templates = <_FeaturedActivityTemplate>[
      _FeaturedActivityTemplate(
        activity: '羽毛球',
        title: '羽毛球组局',
        image: 'assets/images/content/figma_home_card_badminton.png',
      ),
      _FeaturedActivityTemplate(
        activity: '美食',
        title: '美食探店',
        image: 'assets/images/content/figma_home_card_food.png',
      ),
      _FeaturedActivityTemplate(
        activity: '夜跑',
        title: '珠江夜跑',
        image: 'assets/images/content/figma_home_card_runner.png',
      ),
    ];
    return List.generate(templates.length, (index) {
      final seed = seeds[index];
      final template = templates[index];
      return User(
        id: seed.id,
        nickname: seed.nickname,
        age: seed.age,
        gender: seed.gender,
        hobbies: seed.hobbies,
        avatarPath: seed.avatarPath,
        intro: seed.intro,
        isVerified: seed.isVerified,
        moment: seed.moment,
        galleryImagePaths: seed.galleryImagePaths,
        verificationVideoPath: seed.verificationVideoPath,
        teamPost: TeamPost(
          imagePaths: [template.image],
          activity: template.activity,
          location: '深圳市｜宝安区',
          date: activityDate,
          content: '${template.title}\n休闲娱乐，放松一下',
        ),
      );
    });
  }
}

class _FeaturedActivityTemplate {
  const _FeaturedActivityTemplate({
    required this.activity,
    required this.title,
    required this.image,
  });

  final String activity;
  final String title;
  final String image;
}
