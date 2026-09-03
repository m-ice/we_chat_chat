import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../controllers/edit_profile_controller.dart';
import 'profile_design.dart';
import 'profile_text_edit_page.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_edit'.tr,
    body: Obx(() {
      final profile = controller.profile.value;
      final avatar = controller.avatarFilePath.value;
      return AppRefreshView(
        onRefresh: controller.refreshProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _Avatar(
              source: avatar ?? ProfileDetailAssets.editAvatar,
              onTap: controller.pickAvatar,
            ),
            const SizedBox(height: 13),
            Text(
              'profile_basic_details'.tr,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 16),
            ProfilePanel(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  _ValueRow(
                    title: 'profile_nickname'.tr,
                    value: profile.nickname,
                    onTap: () async {
                      await Get.to(
                        () => ProfileTextEditPage(
                          nickname: true,
                          initialValue: profile.nickname,
                        ),
                      );
                      await controller.refreshProfile();
                    },
                  ),
                  _ValueRow(
                    title: 'profile_bio'.tr,
                    value: profile.bio.isEmpty
                        ? 'profile_bio_hint'.tr
                        : profile.bio,
                    muted: profile.bio.isEmpty,
                    onTap: () async {
                      await Get.to(
                        () => ProfileTextEditPage(
                          nickname: false,
                          initialValue: profile.bio,
                        ),
                      );
                      await controller.refreshProfile();
                    },
                  ),
                  _TagRow(
                    title: 'profile_interests'.tr,
                    tags: profile.interests,
                    onTap: () async {
                      await Get.toNamed(Routes.profileInterests);
                      await controller.refreshProfile();
                    },
                  ),
                  _TagRow(
                    title: 'profile_personality'.tr,
                    tags: profile.personalityTags,
                    last: true,
                    onTap: () async {
                      await Get.toNamed(Routes.profilePersonality);
                      await controller.refreshProfile();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.source, required this.onTap});

  final String source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 98,
      height: 114,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipOval(
            child: AppImage(source, width: 98, height: 98, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: 80,
              height: 32,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCE45),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(80, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('profile_change_avatar'.tr),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.title,
    required this.value,
    required this.onTap,
    this.muted = false,
  });

  final String title;
  final String value;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: muted ? const Color(0xFFAAAAAA) : profileMutedText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const AppImage(
                  ProfileDetailAssets.chevronRight,
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
      const Divider(height: 1, indent: 14, endIndent: 14),
    ],
  );
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.title,
    required this.tags,
    required this.onTap,
    this.last = false,
  });

  final String title;
  final List<String> tags;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Column(
            children: [
              SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const AppImage(
                      ProfileDetailAssets.chevronRight,
                      width: 16,
                      height: 16,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 28,
                child: tags.isEmpty
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tags
                                .take(10)
                                .map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ProfileTag(label: tag.tr),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      if (!last) const Divider(height: 1, indent: 14, endIndent: 14),
    ],
  );
}
