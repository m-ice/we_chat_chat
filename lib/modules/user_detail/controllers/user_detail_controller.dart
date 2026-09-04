import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_detail_seed_profile.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/user_detail_repository.dart';
import '../../home/team_detail/team_detail_controller.dart';

class UserDetailController extends GetxController {
  UserDetailController(
    this.user,
    this._social,
    this._chats,
    this._wallet,
    this._users,
    this._details,
  );

  final User user;
  final SocialStateRepository _social;
  final ChatRepository _chats;
  final MembershipWalletRepository _wallet;
  final UserRepository _users;
  final UserDetailRepository _details;
  final invited = false.obs;
  final seedProfile = Rxn<UserDetailSeedProfile>();
  final floatingActionEvents = StreamController<OperateEvent>.broadcast();
  final _momentRevision = 0.obs;

  final imageCarouselIndex = 0.obs;
  final imageCarouselC = PageController();

  void selectCarouselImage(int index) {
    if (imageCarouselIndex.value == index) return;
    imageCarouselIndex.value = index;
    if (imageCarouselC.hasClients) imageCarouselC.jumpToPage(index);
  }

  List<String> get generatedPersonalityTags =>
      seedProfile.value?.personalityTags ?? const [];

  String get heroImagePath {
    final seedPath = seedProfile.value?.heroImagePath ?? '';
    if (user.isSeedData && seedPath.isNotEmpty) return seedPath;
    return user.galleryImagePaths.firstOrNull ?? user.avatarPath;
  }

  List<String> get galleryPreviewPaths {
    final seedPaths = seedProfile.value?.galleryPreviewPaths ?? const [];
    if (user.isSeedData && seedPaths.isNotEmpty) return seedPaths;
    return user.galleryImagePaths.isEmpty
        ? [user.avatarPath]
        : user.galleryImagePaths;
  }

  List<UserDetailFact> get facts {
    final profile = seedProfile.value;
    return [
      UserDetailFact('user_id_label'.tr, '${user.id + 1237500}'),
      ...?profile?.facts.map(
        (item) => UserDetailFact(
          item.labelKey.tr,
          item.valueIsTranslationKey ? item.value.tr : item.value,
        ),
      ),
    ];
  }

  List<UserDetailActivityData> get activities {
    final seededActivities = seedProfile.value?.activities ?? const [];
    if (user.isSeedData && seededActivities.isNotEmpty) {
      return seededActivities
          .map((activity) {
            final title = activity.titleKey.tr;
            final location = activity.locationKey.tr;
            return UserDetailActivityData(
              post: TeamPost(
                id: activity.id,
                ownerId: activity.ownerId,
                imagePaths: activity.coverPath.isEmpty
                    ? const []
                    : [activity.coverPath],
                activity: title,
                location: location,
                date: activity.date,
                content: title,
              ),
              title: title,
              coverPath: activity.coverPath,
              location: location,
              date: activity.date,
              participantPaths: galleryPreviewPaths,
              interestedCount: activity.interestedCount,
            );
          })
          .toList(growable: false);
    }

    final team = user.teamPost;
    if (team != null) {
      return [
        UserDetailActivityData(
          post: team,
          title: team.content,
          coverPath: team.imagePaths.firstOrNull ?? heroImagePath,
          location: team.location,
          date: team.date,
          participantPaths: galleryPreviewPaths,
          interestedCount: galleryPreviewPaths.length,
        ),
      ];
    }
    return const [];
  }

  List<UserDetailMomentData> get moments {
    _momentRevision.value;
    final moment = user.moment;
    if (moment != null) {
      return List.generate(
        moment.imagePaths.length,
        (index) => UserDetailMomentData(
          id: 'user-${user.id}-moment-$index',
          content: moment.content,
          imagePath: moment.imagePaths[index],
          createdAt: moment.createdAt,
          initialLikeCount: 0,
        ),
        growable: false,
      );
    }
    final seedMoments = seedProfile.value?.moments ?? const [];
    return List.generate(seedMoments.length, (index) {
      final moment = seedMoments[index];
      return UserDetailMomentData(
        id: moment.id.isEmpty
            ? 'seed-${user.id}-moment-$index'
            : 'user-${user.id}-${moment.id}',
        content: user.intro.isEmpty ? moment.contentKey.tr : user.intro,
        imagePath: moment.imagePath,
        createdAt: moment.createdAt,
        initialLikeCount: moment.initialLikeCount,
      );
    }, growable: false);
  }

  bool isLiked(UserDetailMomentData moment) => _details
      .getMomentEngagement(moment.id, initialLikeCount: moment.initialLikeCount)
      .isLiked;

  int likeCount(UserDetailMomentData moment) => _details
      .getMomentEngagement(moment.id, initialLikeCount: moment.initialLikeCount)
      .likeCount;

  Future<void> toggleMomentLike(UserDetailMomentData moment) async {
    final liked = !isLiked(moment);
    try {
      await _details.setMomentLiked(
        moment.id,
        liked,
        initialLikeCount: moment.initialLikeCount,
      );
      _momentRevision.value++;
      AppToast.show(liked ? 'video_liked'.tr : 'video_unliked'.tr);
    } on Object {
      AppToast.show('common_save_failed'.tr);
    }
  }

  Future<void> reloadProfile() => _loadProfile();

  Future<void> openActivity(UserDetailActivityData activity) async {
    await Get.toNamed(
      Routes.teamDetail,
      arguments: TeamDetailArguments(user: user, post: activity.post),
    );
  }

  @override
  void onInit() {
    super.onInit();
    invited.value = _social.invitedIds.contains(user.id);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!user.isSeedData) {
      seedProfile.value = null;
      return;
    }
    try {
      seedProfile.value = await _details.getSeedProfile(user.id);
    } on Object {
      seedProfile.value = null;
    }
  }

  Future<void> startChat() async {
    if (!await _chats.canSendMessage(user.id)) {
      AppToast.show('chat_wait_for_reply'.tr);
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
      AppToast.show('user_invited'.tr);
      return;
    }
    if (!await _chats.canSendMessage(user.id)) {
      AppToast.show('invite_wait_for_reply'.tr);
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
    AppToast.show('invite_sent'.tr);
  }

  Future<void> startCall() async {
    final messages = await _chats.getMessages(user.id);
    if (messages.isEmpty || messages.last.isFromCurrentUser) {
      AppToast.show('call_wait_for_reply'.tr);
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
    AppToast.show('social_blocked'.trParams({'name': user.nickname}));
  }

  Future<void> shield() async {
    await _social.shield(user.id);
    Get.until((route) => route.isFirst);
    AppToast.show('social_shielded'.trParams({'name': user.nickname}));
  }

  Future<void> _showInsufficientCoins(int required) async {
    final recharge = await AppDialog.confirm(
      title: 'coins_insufficient'.tr,
      message: 'coins_required'.trParams({
        'required': '$required',
        'balance': '${_wallet.coinBalance}',
      }),
      confirmText: 'coins_recharge_action'.tr,
    );
    if (recharge) await Get.toNamed<void>(Routes.coins);
  }

  @override
  void onClose() {
    imageCarouselC.dispose();
    floatingActionEvents.close();
    super.onClose();
  }
}

class UserDetailFact {
  const UserDetailFact(this.label, this.value);

  final String label;
  final String value;
}

class UserDetailActivityData {
  const UserDetailActivityData({
    required this.post,
    required this.title,
    required this.coverPath,
    required this.location,
    required this.date,
    required this.participantPaths,
    required this.interestedCount,
  });

  final TeamPost post;
  final String title;
  final String coverPath;
  final String location;
  final DateTime date;
  final List<String> participantPaths;
  final int interestedCount;
}

class UserDetailMomentData {
  const UserDetailMomentData({
    required this.id,
    required this.content,
    required this.imagePath,
    required this.createdAt,
    required this.initialLikeCount,
  });

  final String id;
  final String content;
  final String imagePath;
  final DateTime createdAt;
  final int initialLikeCount;
}
