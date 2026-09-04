import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_activity_join_confirmation.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/square_feed.dart';
import '../../../domain/entities/team_activity_join_result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/policies/feature_access_gate.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/team_detail_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../home/team_detail/team_detail_controller.dart';

class TopicDetailController extends GetxController {
  TopicDetailController(
    this.topic,
    this._users,
    this.social,
    this._access,
    this._details,
  );
  final TopicItem topic;
  final UserRepository _users;
  final SocialStateRepository social;
  final FeatureAccessGate _access;
  final TeamDetailRepository _details;
  final users = <User>[].obs;
  StreamSubscription<void>? _socialChangesSubscription;
  int _reloadRevision = 0;

  @override
  void onInit() {
    super.onInit();
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
    final current = await _users.getCurrentUser();
    final shieldedActivities = social.shieldedActivityIds;
    final nextUsers = (await _users.getUsers())
        .where(
          (user) =>
              user.teamPost?.activity == topic.id &&
              user.id != current.id &&
              !user.teamPost!.isExpired(DateTime.now()) &&
              !excluded.contains(user.id) &&
              !shieldedActivities.contains(user.teamPost!.id),
        )
        .toList(growable: false);
    if (revision != _reloadRevision) return;
    users.assignAll(nextUsers);
  }

  void refreshState() => users.refresh();

  Future<TeamDetailResult?> openActivity(User user) async {
    final post = user.teamPost;
    if (post == null) return null;
    final result = await Get.toNamed(
      Routes.teamDetail,
      arguments: TeamDetailArguments(user: user, post: post),
    );
    return result is TeamDetailResult ? result : null;
  }

  Future<void> join(User user) async {
    if (user.teamPost?.isExpired(DateTime.now()) ?? true) {
      AppToast.show('team_activity_ended'.tr);
      await reload();
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
        users.refresh();
        AppToast.show('team_joined'.trParams({'name': post.activity}));
        return;
      case TeamActivityJoinResult.alreadyJoined:
        users.refresh();
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
