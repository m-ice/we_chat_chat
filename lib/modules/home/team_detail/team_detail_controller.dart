import 'package:get/get.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/team_detail_comment.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/team_detail_repository.dart';
import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';

class TeamDetailArguments {
  const TeamDetailArguments({required this.user, required this.post});

  final User user;
  final TeamPost post;
}

class TeamDetailController extends GetxController {
  TeamDetailController(
    this.user,
    this.post,
    this._social,
    this._wallet,
    this._details,
  );

  final User user;
  final TeamPost post;
  final SocialStateRepository _social;
  final MembershipWalletRepository _wallet;
  final TeamDetailRepository _details;
  final pending = false.obs;
  final comments = <TeamDetailComment>[].obs;
  final participantTotal = 0.obs;
  final baseParticipantCount = 0.obs;
  final participantAvatarPaths = <String>[].obs;

  bool get expired => post.isExpired(DateTime.now());
  int get participantCount =>
      (baseParticipantCount.value + (pending.value ? 1 : 0))
          .clamp(0, participantTotal.value)
          .toInt();

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    pending.value = _social.pendingJoinIds.contains(user.id);
    await Future.wait([_loadComments(), _loadSeedState()]);
  }

  Future<void> _loadComments() async {
    try {
      comments.assignAll(await _details.getComments(_ownerId));
    } on Object {
      comments.clear();
    }
  }

  Future<void> _loadSeedState() async {
    try {
      final state = await _details.getSeedState(_ownerId);
      participantTotal.value = state.participantTotal;
      baseParticipantCount.value = state.participantCount;
      participantAvatarPaths.assignAll(state.participantAvatarPaths);
    } on Object {
      participantTotal.value = 0;
      baseParticipantCount.value = 0;
      participantAvatarPaths.clear();
    }
  }

  Future<void> join() async {
    if (expired) {
      AppToast.show('team_activity_ended'.tr);
      return;
    }
    if (pending.value) {
      AppToast.show('team_request_pending'.tr);
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
    pending.value = true;
    AppToast.show('team_join_requested'.trParams({'name': user.nickname}));
  }

  Future<void> addComment(String content) async {
    final value = content.trim();
    if (value.isEmpty) return;
    final comment = TeamDetailComment(nickname: 'common_me'.tr, content: value);
    await _details.addComment(_ownerId, comment);
    comments.insert(0, comment);
    AppToast.show('team_comment_posted'.tr);
  }

  void openChat() => Get.toNamed(Routes.chat, arguments: user);

  // The 1.0 overflow affordance opens the organizer profile. A future action
  // sheet can replace this route after its product actions are specified.
  void openOrganizer() => Get.toNamed(Routes.userDetail, arguments: user);

  int get _ownerId => post.ownerId == 0 ? user.id : post.ownerId;
}
