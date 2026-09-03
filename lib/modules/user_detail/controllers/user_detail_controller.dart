import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class UserDetailController extends GetxController {
  UserDetailController(
    this.user,
    this._social,
    this._chats,
    this._wallet,
    this._users,
  );

  final User user;
  final SocialStateRepository _social;
  final ChatRepository _chats;
  final MembershipWalletRepository _wallet;
  final UserRepository _users;
  final invited = false.obs;

  static const personalityTags = [
    '温柔内敛',
    '开朗大方',
    '暖心细腻',
    '理智清醒',
    '慢热专一',
    '自信从容',
    '随性洒脱',
    '人间清醒',
    '随性自由',
    '正直善良',
    '真诚坦率',
  ];

  List<String> get generatedPersonalityTags {
    final base = user.id % personalityTags.length;
    return [
      personalityTags[base],
      personalityTags[(base + 3) % personalityTags.length],
      personalityTags[(base + 6) % personalityTags.length],
    ];
  }

  @override
  void onInit() {
    super.onInit();
    invited.value = _social.invitedIds.contains(user.id);
  }

  Future<void> startChat() async {
    if (!await _chats.canSendMessage(user.id)) {
      Get.snackbar('common_tip'.tr, 'chat_wait_for_reply'.tr);
      return;
    }
    if (!await _wallet.spendCoins(MembershipWalletRepository.chatCost)) {
      await _showInsufficientCoins(MembershipWalletRepository.chatCost);
      return;
    }
    await Get.toNamed(Routes.chat, arguments: user);
  }

  Future<void> invite() async {
    if (invited.value) {
      Get.snackbar('common_tip'.tr, 'user_invited'.tr);
      return;
    }
    if (!await _chats.canSendMessage(user.id)) {
      Get.snackbar('common_tip'.tr, 'invite_wait_for_reply'.tr);
      return;
    }
    final currentUser = await _users.getCurrentUser();
    await _chats.appendMessage(
      ChatMessage(
        id: 'invite-${DateTime.now().microsecondsSinceEpoch}',
        peerId: user.id,
        text: 'invite_message'.trParams({'name': currentUser.nickname}),
        isFromCurrentUser: true,
        createdAt: DateTime.now(),
      ),
      peer: user,
    );
    await _social.setInvited(user.id, true);
    invited.value = true;
    Get.snackbar('common_tip'.tr, 'invite_sent'.tr);
  }

  Future<void> startCall() async {
    final messages = await _chats.getMessages(user.id);
    if (messages.isEmpty || messages.last.isFromCurrentUser) {
      Get.snackbar('common_tip'.tr, 'call_wait_for_reply'.tr);
      return;
    }
    if (_wallet.coinBalance < MembershipWalletRepository.callCostPerMinute) {
      await _showInsufficientCoins(
        MembershipWalletRepository.callCostPerMinute,
      );
      return;
    }
    await Get.toNamed(Routes.voiceCall, arguments: user);
  }

  Future<void> block() async {
    await _social.block(user.id);
    Get.until((route) => route.isFirst);
    Get.snackbar(
      'common_tip'.tr,
      'social_blocked'.trParams({'name': user.nickname}),
    );
  }

  Future<void> shield() async {
    await _social.shield(user.id);
    Get.until((route) => route.isFirst);
    Get.snackbar(
      'common_tip'.tr,
      'social_shielded'.trParams({'name': user.nickname}),
    );
  }

  Future<void> _showInsufficientCoins(int required) async {
    await Get.dialog<void>(
      AlertDialog(
        title: Text('coins_insufficient'.tr),
        content: Text(
          'coins_required'.trParams({
            'required': '$required',
            'balance': '${_wallet.coinBalance}',
          }),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('common_cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back<void>();
              Get.toNamed(Routes.coins);
            },
            child: Text('coins_recharge_action'.tr),
          ),
        ],
      ),
    );
  }
}
