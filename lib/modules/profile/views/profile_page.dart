import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../controllers/profile_controller.dart';

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
          final String avatar;
          if (controller.avatarFilePath.value != null) {
            avatar = controller.avatarFilePath.value!;
          } else if (user?.avatarPath.isNotEmpty == true) {
            avatar = user!.avatarPath;
          } else {
            avatar = AppImageString.profileFigmaAvatar;
          }
          return AppRefreshView(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _ProfileHeader(
                  avatar: avatar,
                  nickname: controller.nickname.value,
                  displayId: user?.displayId,
                ),
                // _SummaryPanel(
                //   coinsLabel: _isChinese ? '撩币' : 'profile_coins'.tr,
                //   membershipLabel: 'profile_vip'.tr,
                //   albumLabel: 'profile_album'.tr,
                //   onCoinsTap: () async {
                //     await Get.toNamed(Routes.coins);
                //     controller.refreshWallet();
                //   },
                //   onMembershipTap: () async {
                //     await Get.toNamed(Routes.vip);
                //     controller.refreshWallet();
                //   },
                //   onAlbumTap: () => Get.toNamed(Routes.album),
                // ),
                // const SizedBox(height: 8),
                _MenuRow(
                  icon: AppImageString.profileFigmaEdit,
                  label: 'profile_edit'.tr,
                  onTap: () async {
                    await Get.toNamed(Routes.profileEdit);
                    await controller.load();
                  },
                ),
                // _MenuRow(
                //   icon: AppImageString.liveVerification,
                //   label: _isChinese ? '真人认证' : 'live_verification'.tr,
                //   onTap: () => Get.toNamed(Routes.myWorld),
                // ),
                _MenuRow(
                  icon: AppImageString.profileFigmaWorld,
                  label: _isChinese ? '我的动态' : 'profile_world'.tr,
                  onTap: () => Get.toNamed(Routes.myWorld),
                ),

                _MenuRow(
                  icon: AppImageString.myImage,
                  label: _isChinese ? '我的相册' : 'profile_album'.tr,
                  onTap: () => Get.toNamed(Routes.album),
                ),
                _MenuRow(
                  icon: AppImageString.profileFigmaSupport,
                  label: 'profile_customer_service'.tr,
                  onTap: () => Get.toNamed(Routes.customerService),
                ),

                _MenuRow(
                  icon: AppImageString.aboutUs,
                  label: 'profile_about_us'.tr,
                  onTap: () => Get.toNamed(Routes.aboutUs),
                ),
                // _MenuRow(
                //   icon: AppImageString.profileFigmaPrivacy,
                //   label: 'legal_privacy'.tr,
                //   onTap: () => Get.toNamed(
                //     Routes.legal,
                //     arguments: {
                //       'title': 'legal_privacy'.tr,
                //       'assetPath': 'assets/legal/privacy_policy.html',
                //     },
                //   ),
                // ),
                // _MenuRow(
                //   icon: AppImageString.profileFigmaAgreement,
                //   label: 'legal_user_agreement'.tr,
                //   onTap: () => Get.toNamed(
                //     Routes.legal,
                //     arguments: {
                //       'title': 'legal_user_agreement'.tr,
                //       'assetPath': 'assets/legal/user_agreement.html',
                //     },
                //   ),
                // ),
                _MenuRow(
                  icon: AppImageString.mySetting,
                  label: 'profile_settings'.tr,
                  onTap: () => Get.toNamed(Routes.settings),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
    child: AppImage(
      AppImageString.profileFigmaHeader,
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
    required this.displayId,
  });

  final String avatar;
  final String nickname;
  final String? displayId;

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
          child: ClipOval(child: AppImage(avatar, fit: BoxFit.cover)),
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
          'ID: ${displayId ?? '--'}',
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
          const AppImage(
            AppImageString.profileFigmaCard,
            width: double.infinity,
            height: 93,
            fit: BoxFit.fill,
          ),
          Row(
            children: [
              SizedBox(
                width: 112,
                child: _SummaryAction(
                  icon: AppImageString.profileFigmaQuickCoin,
                  label: coinsLabel,
                  onTap: onCoinsTap,
                ),
              ),
              SizedBox(
                width: 116,
                child: _SummaryAction(
                  icon: AppImageString.profileFigmaQuickVip,
                  label: membershipLabel,
                  onTap: onMembershipTap,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: _SummaryAction(
                    icon: AppImageString.profileFigmaQuickAlbum,
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
          AppImage(icon, width: 44, height: 44),
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
    this.icon,
    this.materialIcon,
    required this.label,
    required this.onTap,
  }) : assert(icon != null || materialIcon != null);

  final String? icon;
  final IconData? materialIcon;
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
            if (materialIcon case final iconData?)
              Icon(iconData, size: 28, color: AppColors.textPrimary)
            else
              AppImage(icon!, width: 28, height: 28),
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
              child: const AppImage(
                AppImageString.profileFigmaArrow,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
