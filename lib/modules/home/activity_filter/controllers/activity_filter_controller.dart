import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_activity_join_confirmation.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/team_activity_join_result.dart';
import '../../../../domain/repositories/home_city_repository.dart';
import '../../../../domain/policies/feature_access_gate.dart';
import '../../../../domain/repositories/social_state_repository.dart';
import '../../../../domain/repositories/team_detail_repository.dart';
import '../../../../domain/repositories/user_repository.dart';

class ActivityFilterController extends GetxController {
  ActivityFilterController(
    this._users,
    this._cities,
    this._social,
    this._access,
    this._details,
  );

  final UserRepository _users;
  final HomeCityRepository _cities;
  final SocialStateRepository _social;
  final FeatureAccessGate _access;
  final TeamDetailRepository _details;

  final source = <User>[].obs;
  final results = <User>[].obs;
  final keyword = ''.obs;
  final hasError = false.obs;
  StreamSubscription<void>? _socialChangesSubscription;
  int _loadRevision = 0;

  @override
  void onInit() {
    super.onInit();
    _socialChangesSubscription = _social.changes.listen((_) {
      unawaited(load());
    });
    load();
  }

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    final revision = ++_loadRevision;
    hasError.value = false;
    try {
      final city = _cities.selectedCity;
      final excluded = {..._social.blockedIds, ..._social.shieldedIds};
      final users = await _users.getUsers();
      final current = await _users.getCurrentUser();
      final shieldedActivities = _social.shieldedActivityIds;
      final nextSource = users
          .where((user) {
            final post = user.teamPost;
            return post != null &&
                user.id != current.id &&
                !post.isExpired(DateTime.now()) &&
                !excluded.contains(user.id) &&
                !shieldedActivities.contains(post.id) &&
                (city == '全部' ||
                    post.location.contains(city) ||
                    post.content.contains(city));
          })
          .toList(growable: false);
      if (revision != _loadRevision) return;
      source.assignAll(nextSource);
      search(keyword.value);
    } on Object {
      if (revision != _loadRevision) return;
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
    final post = user.teamPost;
    if (post == null) return;
    if (!await AppActivityJoinConfirmation.show(post.activity)) return;
    if (!await _access.request(FeatureAccess.activityJoin)) return;
    final currentUser = await _users.getCurrentUser();
    final result = await _details.joinActivity(post.id, currentUser.id);
    switch (result) {
      case TeamActivityJoinResult.joined:
        results.refresh();
        AppToast.show('team_joined'.trParams({'name': post.activity}));
        return;
      case TeamActivityJoinResult.alreadyJoined:
        results.refresh();
        return;
      case TeamActivityJoinResult.full:
        AppToast.show('team_join_full'.tr);
        return;
      case TeamActivityJoinResult.unavailable:
        AppToast.show('common_save_failed'.tr);
        return;
    }
  }
}
