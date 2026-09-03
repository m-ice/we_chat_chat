import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

abstract final class _ProfileAssets {
  static const header = 'assets/images/content/figma_profile_header.png';
  static const avatar = 'assets/images/content/figma_profile_avatar.png';
  static const summaryBackground =
      'assets/images/content/figma_profile_card.png';
  static const coins = 'assets/images/content/figma_profile_quick_coin.png';
  static const membership = 'assets/images/content/figma_profile_quick_vip.png';
  static const album = 'assets/images/content/figma_profile_quick_album.png';
  static const edit = 'assets/images/content/figma_profile_icon_edit.png';
  static const world = 'assets/images/content/figma_profile_icon_world.png';
  static const support = 'assets/images/content/figma_profile_icon_support.png';
  static const privacy = 'assets/images/content/figma_profile_icon_privacy.png';
  static const agreement =
      'assets/images/content/figma_profile_icon_agreement.png';
  static const arrow = 'assets/images/content/figma_profile_arrow.png';
}

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  bool get _isChinese => Get.locale?.languageCode == 'zh';

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: ColoredBox(color: Colors.white)),
      const _ProfileBackdrop(),
      SafeArea(
        bottom: false,
        child: Obx(() {
          final user = controller.currentUser.value;
          final ImageProvider<Object> avatar;
          if (controller.avatarFilePath.value != null) {
            avatar = FileImage(File(controller.avatarFilePath.value!));
          } else if (user?.avatarPath.isNotEmpty == true) {
            avatar = AssetImage(user!.avatarPath);
          } else {
            avatar = const AssetImage(_ProfileAssets.avatar);
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProfileHeader(
                avatar: avatar,
                nickname: controller.nickname.value,
                userId: user?.id,
              ),
              _SummaryPanel(
                coinsLabel: _isChinese ? '撩币' : 'profile_coins'.tr,
                membershipLabel: 'profile_vip'.tr,
                albumLabel: 'profile_album'.tr,
                onCoinsTap: () async {
                  await Get.toNamed(Routes.coins);
                  controller.refreshWallet();
                },
                onMembershipTap: () async {
                  await Get.toNamed(Routes.vip);
                  controller.refreshWallet();
                },
                onAlbumTap: () => Get.toNamed(Routes.album),
              ),
              const SizedBox(height: 8),
              _MenuRow(
                icon: _ProfileAssets.edit,
                label: 'profile_edit'.tr,
                onTap: () async {
                  await Get.toNamed(Routes.profileEdit);
                  await controller.load();
                },
              ),
              _MenuRow(
                icon: _ProfileAssets.world,
                label: _isChinese ? '我的动态' : 'profile_world'.tr,
                onTap: () => Get.toNamed(Routes.myWorld),
              ),
              _MenuRow(
                icon: _ProfileAssets.support,
                label: 'profile_customer_service'.tr,
                onTap: () => Get.toNamed(Routes.customerService),
              ),
              _MenuRow(
                icon: _ProfileAssets.privacy,
                label: 'legal_privacy'.tr,
                onTap: () => Get.toNamed(
                  Routes.legal,
                  arguments: {
                    'title': 'legal_privacy'.tr,
                    'assetPath': 'assets/legal/privacy_policy.html',
                  },
                ),
              ),
              _MenuRow(
                icon: _ProfileAssets.agreement,
                label: 'legal_user_agreement'.tr,
                onTap: () => Get.toNamed(
                  Routes.legal,
                  arguments: {
                    'title': 'legal_user_agreement'.tr,
                    'assetPath': 'assets/legal/user_agreement.html',
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    ],
  );
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    right: 0,
    height: 255,
    child: Image.asset(
      _ProfileAssets.header,
      width: double.infinity,
      height: 255,
      fit: BoxFit.fill,
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.avatar,
    required this.nickname,
    required this.userId,
  });

  final ImageProvider avatar;
  final String nickname;
  final int? userId;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 195,
    child: Column(
      children: [
        const SizedBox(height: 36),
        Container(
          key: const ValueKey('profile-avatar'),
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image(image: avatar, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 25,
          child: Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          'ID: ${userId ?? '--'}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.coinsLabel,
    required this.membershipLabel,
    required this.albumLabel,
    required this.onCoinsTap,
    required this.onMembershipTap,
    required this.onAlbumTap,
  });

  final String coinsLabel;
  final String membershipLabel;
  final String albumLabel;
  final VoidCallback onCoinsTap;
  final VoidCallback onMembershipTap;
  final VoidCallback onAlbumTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: 93,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _ProfileAssets.summaryBackground,
            width: double.infinity,
            height: 93,
            fit: BoxFit.fill,
          ),
          Row(
            children: [
              SizedBox(
                width: 112,
                child: _SummaryAction(
                  icon: _ProfileAssets.coins,
                  label: coinsLabel,
                  onTap: onCoinsTap,
                ),
              ),
              SizedBox(
                width: 116,
                child: _SummaryAction(
                  icon: _ProfileAssets.membership,
                  label: membershipLabel,
                  onTap: onMembershipTap,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: _SummaryAction(
                    icon: _ProfileAssets.album,
                    label: albumLabel,
                    onTap: onAlbumTap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SummaryAction extends StatelessWidget {
  const _SummaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 13),
      child: Column(
        children: [
          Image.asset(icon, width: 44, height: 44),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              height: 17 / 12,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 15),
        child: Row(
          children: [
            Image.asset(icon, width: 28, height: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            Transform.rotate(
              angle: -math.pi / 2,
              child: Image.asset(_ProfileAssets.arrow, width: 20, height: 20),
            ),
          ],
        ),
      ),
    ),
  );
}
