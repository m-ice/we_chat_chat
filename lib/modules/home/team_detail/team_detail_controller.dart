import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';

class TeamDetailComment {
  const TeamDetailComment({required this.nickname, required this.content});

  final String nickname;
  final String content;
}

class TeamDetailController extends GetxController {
  TeamDetailController(this.user, this._social, this._wallet);
  final User user;
  final SocialStateRepository _social;
  final MembershipWalletRepository _wallet;
  final pending = false.obs;
  final comments = <TeamDetailComment>[
    const TeamDetailComment(nickname: '用户昵称', content: '我要报名，我也想去！！！'),
    const TeamDetailComment(nickname: '用户昵称', content: '我要报名，我也想去！！！'),
    const TeamDetailComment(nickname: '用户昵称', content: '我要报名，我也想去！！！'),
  ].obs;

  TeamPost get post => user.teamPost!;
  bool get expired => post.isExpired(DateTime.now());
  int get participantTotal => 4;
  int get participantCount => pending.value ? 4 : 3;

  @override
  void onInit() {
    super.onInit();
    pending.value = _social.pendingJoinIds.contains(user.id);
  }

  Future<void> join() async {
    if (expired) {
      AppToast.show(_copy('活动已结束', 'This activity has ended'));
      return;
    }
    if (pending.value) {
      AppToast.show(_copy('报名申请正在审核中', 'Your request is pending'));
      return;
    }
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
    pending.value = true;
    AppToast.show('team_join_requested'.trParams({'name': user.nickname}));
  }

  void addComment(String content) {
    final value = content.trim();
    if (value.isEmpty) return;
    comments.insert(
      0,
      TeamDetailComment(nickname: _copy('我', 'Me'), content: value),
    );
    AppToast.show(_copy('评论已发布', 'Comment posted'));
  }

  void openChat() => Get.toNamed(Routes.chat, arguments: user);

  void openOrganizer() => Get.toNamed(Routes.userDetail, arguments: user);

  String _copy(String zh, String en) =>
      Get.locale?.languageCode == 'zh' ? zh : en;
}
