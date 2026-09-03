import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/city_user_mapper.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../shared/actions/user_actions_sheet.dart';

enum PartnerTab { recommended, nearby, newcomers }

class VideoFeedController extends GetxController {
  VideoFeedController(this._users, this._cities, this.social);
  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository social;
  final partnerTab = PartnerTab.recommended.obs;
  final users = <CityUser>[].obs;
  final videoUsers = <CityUser>[].obs;
  final currentIndex = 0.obs;
  final likedIds = <int>{}.obs;
  final favoriteIds = <int>{}.obs;
  List<CityUser> _cityUsers = const [];
  List<CityUser> _newcomerUsers = const [];

  List<CityUser> get searchableUsers {
    final unique = <int, CityUser>{};
    for (final user in [..._cityUsers, ..._newcomerUsers]) {
      unique[user.id] = user;
    }
    return unique.values.toList(growable: false);
  }

  String coverPathFor(CityUser user) => user.isSeedData
      ? 'assets/images/video_user/video_cover.png'
      : user.avatarPath;

  String avatarPathFor(CityUser user) => user.isSeedData
      ? 'assets/images/video_user/video_avatar.png'
      : user.avatarPath;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    final excluded = {...social.blockedIds, ...social.shieldedIds};
    final result = await Future.wait([
      _users.getCityUsers(),
      _users.getVerifiedUsers(),
    ]);
    _cityUsers = result[0]
        .where((user) => !excluded.contains(user.id))
        .toList(growable: false);
    _newcomerUsers = result[1]
        .where((user) => !excluded.contains(user.id))
        .toList(growable: false);
    videoUsers.assignAll(
      _newcomerUsers.where((user) => user.videoPath.isNotEmpty),
    );
    _applyPartnerFilter();
    if (currentIndex.value >= videoUsers.length) currentIndex.value = 0;
  }

  void selectPartnerTab(PartnerTab value) {
    partnerTab.value = value;
    _applyPartnerFilter();
  }

  void _applyPartnerFilter() {
    final city = _cities.selectedCity;
    final source = switch (partnerTab.value) {
      PartnerTab.recommended => [
        ..._cityUsers.where((user) => user.isOnline),
        ..._newcomerUsers,
        ..._cityUsers.where((user) => !user.isOnline),
      ],
      PartnerTab.nearby => _cityUsers.where(
        (user) => city == '全部' || user.city == city,
      ),
      PartnerTab.newcomers => _newcomerUsers.where(
        (user) => city == '全部' || user.city == city,
      ),
    };
    users.assignAll(source);
  }

  void setIndex(int value) => currentIndex.value = value;
  void toggleLike(int id) {
    final next = Set<int>.from(likedIds);
    final added = !next.remove(id);
    if (added) next.add(id);
    likedIds.assignAll(next);
    _message(added ? 'video_liked'.tr : 'video_unliked'.tr);
  }

  void toggleFavorite(int id) {
    final next = Set<int>.from(favoriteIds);
    final added = !next.remove(id);
    if (added) next.add(id);
    favoriteIds.assignAll(next);
    _message(added ? 'video_favorited'.tr : 'video_unfavorited'.tr);
  }

  Future<void> more(CityUser cityUser) async {
    final user = cityUser.toUser();
    await showUserActionsSheet(
      onBlock: () async {
        await social.block(user.id);
        _message('social_blocked'.trParams({'name': user.nickname}));
        await reload();
      },
      onReport: () => Get.toNamed(Routes.report, arguments: user),
    );
  }

  void _message(String value) => AppToast.show(value);
}

class CenterSearchController extends GetxController {
  CenterSearchController(this._feed);
  final VideoFeedController _feed;
  final query = TextEditingController();
  final results = <CityUser>[].obs;
  void search(String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      results.clear();
      return;
    }
    results.assignAll(
      _feed.searchableUsers.where(
        (user) => [
          user.nickname,
          user.city,
          user.intent,
          user.occupation,
          user.intro,
          ...user.hobbies,
        ].any((text) => text.contains(keyword)),
      ),
    );
  }

  @override
  void onClose() {
    query.dispose();
    super.onClose();
  }
}
