import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/city_user_mapper.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/video_engagement_repository.dart';
import '../../shared/actions/user_actions_sheet.dart';

enum PartnerTab { recommended, nearby, newcomers }

/// Typed navigation input for a standalone, vertically paged video feed.
///
/// Search owns the choice of the selected user; the feed only receives users
/// which have a playable video and the selected user's position in that list.
class VideoFeedArguments {
  VideoFeedArguments({required List<CityUser> users, required this.startIndex})
    : assert(users.isNotEmpty),
      assert(startIndex >= 0 && startIndex < users.length),
      assert(users.every(VideoFeedController.hasVideo)),
      users = List.unmodifiable(users);

  final List<CityUser> users;
  final int startIndex;
}

class VideoFeedController extends GetxController {
  VideoFeedController(this._users, this._cities, this.social, this._engagement);
  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository social;
  final VideoEngagementRepository _engagement;
  final partnerTab = PartnerTab.recommended.obs;
  final users = <CityUser>[].obs;
  final videoUsers = <CityUser>[].obs;
  final currentIndex = 0.obs;
  final likedIds = <int>{}.obs;
  final favoriteIds = <int>{}.obs;
  List<CityUser> _cityUsers = const [];
  List<CityUser> _newcomerUsers = const [];
  StreamSubscription<void>? _socialChangesSubscription;
  int _reloadRevision = 0;

  List<CityUser> get searchableUsers {
    final unique = <int, CityUser>{};
    for (final user in [..._cityUsers, ..._newcomerUsers]) {
      unique[user.id] = user;
    }
    return unique.values.toList(growable: false);
  }

  static bool hasVideo(CityUser user) => user.videoPath.trim().isNotEmpty;

  String coverPathFor(CityUser user) =>
      user.videoCoverPath.isNotEmpty ? user.videoCoverPath : user.avatarPath;

  String avatarPathFor(CityUser user) => user.avatarPath;

  @override
  void onInit() {
    super.onInit();
    likedIds.assignAll(_engagement.likedUserIds);
    favoriteIds.assignAll(_engagement.favoriteUserIds);
    _socialChangesSubscription = social.changes.listen((_) {
      unawaited(reload());
    });
    reload();
  }

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    super.onClose();
  }

  Future<void> reload() async {
    final revision = ++_reloadRevision;
    final excluded = {...social.blockedIds, ...social.shieldedIds};
    final result = await Future.wait([
      _users.getCityUsers(),
      _users.getVerifiedUsers(),
      _users.getCurrentUser(),
    ]);
    if (revision != _reloadRevision) return;
    final currentUserId = (result[2] as User).id;
    _cityUsers = (result[0] as List<CityUser>)
        .where(
          (user) => !excluded.contains(user.id) && user.id != currentUserId,
        )
        .toList(growable: false);
    _newcomerUsers = (result[1] as List<CityUser>)
        .where(
          (user) => !excluded.contains(user.id) && user.id != currentUserId,
        )
        .toList(growable: false);
    videoUsers.assignAll(_newcomerUsers.where(hasVideo));
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

  Future<User> resolveUser(CityUser cityUser) async {
    final users = await _users.getUsers();
    final matches = users.where((user) => user.id == cityUser.id);
    return matches.isEmpty ? cityUser.toUser() : matches.first;
  }

  Future<void> openUser(CityUser cityUser) async {
    final user = await resolveUser(cityUser);
    await Get.toNamed(
      Routes.userDetail,
      arguments: <String, Object>{'userId': user.id, 'user': user},
    );
  }

  Future<void> openSearchResult(CityUser selectedUser) async {
    final arguments = videoFeedArgumentsFor(selectedUser);
    if (arguments == null) {
      await openUser(selectedUser);
      return;
    }

    await Get.toNamed(Routes.videoFeed, arguments: arguments);
  }

  VideoFeedArguments? videoFeedArgumentsFor(CityUser selectedUser) {
    if (!hasVideo(selectedUser)) return null;

    final playableUsers = searchableUsers
        .where(hasVideo)
        .toList(growable: false);
    final startIndex = playableUsers.indexWhere(
      (user) => user.id == selectedUser.id,
    );
    if (startIndex < 0) return null;
    return VideoFeedArguments(users: playableUsers, startIndex: startIndex);
  }

  Future<void> toggleLike(int id) async {
    final next = Set<int>.from(likedIds);
    final added = !next.remove(id);
    if (added) next.add(id);
    likedIds.assignAll(next);
    await _engagement.setLiked(id, added);
    _message(added ? 'video_liked'.tr : 'video_unliked'.tr);
  }

  Future<void> toggleFavorite(int id) async {
    final next = Set<int>.from(favoriteIds);
    final added = !next.remove(id);
    if (added) next.add(id);
    favoriteIds.assignAll(next);
    await _engagement.setFavorite(id, added);
    _message(added ? 'video_favorited'.tr : 'video_unfavorited'.tr);
  }

  Future<void> more(CityUser cityUser) async {
    final user = await resolveUser(cityUser);
    if (await _isCurrentUser(user.id)) return;
    await showUserActionsSheet(
      onBlock: () async {
        await social.block(user.id);
        _message('social_blocked'.trParams({'name': user.nickname}));
        await reload();
      },
      onReport: () => Get.toNamed(Routes.report, arguments: user),
    );
  }

  Future<bool> _isCurrentUser(int userId) async {
    try {
      return (await _users.getCurrentUser()).id == userId;
    } on Object {
      // Without a confirmed identity, destructive social actions stay closed.
      return true;
    }
  }

  void _message(String value) => AppToast.show(value);
}

class CenterSearchController extends GetxController {
  CenterSearchController(this._feed, this._social);
  final VideoFeedController _feed;
  final SocialStateRepository _social;
  final query = TextEditingController();
  final results = <CityUser>[].obs;
  StreamSubscription<void>? _socialChangesSubscription;

  @override
  void onInit() {
    super.onInit();
    _socialChangesSubscription = _social.changes.listen((_) {
      unawaited(_refreshAfterSocialChange());
    });
  }

  Future<void> _refreshAfterSocialChange() async {
    await _feed.reload();
    if (query.text.trim().isNotEmpty) search(query.text);
  }

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

  Future<void> openSearchResult(CityUser user) => _feed.openSearchResult(user);

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    query.dispose();
    super.onClose();
  }
}
