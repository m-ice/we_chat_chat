import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../domain/entities/square_feed.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../home/team_detail/team_detail_controller.dart';

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
            user.teamPost?.activity == topic.id &&
            !user.teamPost!.isExpired(DateTime.now()) &&
            !excluded.contains(user.id),
      ),
    );
  }

  void refreshState() => users.refresh();

  Future<void> openActivity(User user) async {
    final post = user.teamPost;
    if (post == null) return;
    await Get.toNamed(
      Routes.teamDetail,
      arguments: TeamDetailArguments(user: user, post: post),
    );
  }

  Future<void> join(User user) async {
    if (user.teamPost?.isExpired(DateTime.now()) ?? true) {
      AppToast.show('team_activity_ended'.tr);
      await reload();
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
    await social.setPendingJoin(user.id, true);
    users.refresh();
    AppToast.show('team_join_requested'.trParams({'name': user.nickname}));
  }
}
