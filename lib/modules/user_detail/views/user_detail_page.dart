import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../controllers/user_detail_controller.dart';

class UserDetailPage extends GetView<UserDetailController> {
  const UserDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final gallery = user.galleryImagePaths.isEmpty
        ? [user.avatarPath]
        : user.galleryImagePaths;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 440,
                  pinned: false,
                  stretch: true,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'common_more'.tr,
                      onPressed: _showMore,
                      icon: const Icon(Icons.more_horiz),
                    ),
                    const SizedBox(width: 6),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.imagePreview,
                        arguments: {'images': gallery, 'index': 0},
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(gallery.first, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x59000000),
                                  Colors.transparent,
                                  Color(0x33000000),
                                ],
                                stops: [0, .42, 1],
                              ),
                            ),
                          ),
                          if (gallery.length > 1)
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: _GalleryPreview(paths: gallery),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileSummary(controller: controller),
                        const SizedBox(height: 20),
                        _ProfileTag(
                          icon: Icons.camera_alt_outlined,
                          text: 'user_interests'.trParams({
                            'value': user.hobbies.isEmpty
                                ? 'user_none'.tr
                                : user.hobbies
                                      .map((item) => item.tr)
                                      .join(' / '),
                          }),
                          background: const Color(0xFFEAF3FF),
                          foreground: const Color(0xFF4A86F7),
                        ),
                        const SizedBox(height: 8),
                        _ProfileTag(
                          icon: Icons.favorite_border,
                          text: 'user_personality'.trParams({
                            'value': controller.generatedPersonalityTags
                                .map((item) => item.tr)
                                .join(' / '),
                          }),
                          background: const Color(0xFFFFEEE9),
                          foreground: const Color(0xFFF08B70),
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: _copy(zh: '基本资料', en: 'Basic profile'),
                        ),
                        const SizedBox(height: 12),
                        _BasicInfoGrid(user: user),
                        if (user.teamPost case final team?) ...[
                          const _SectionDivider(),
                          _SectionTitle(
                            title: _copy(
                              zh: '发布的活动',
                              en: 'Published activities',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ActivityCard(user: user, team: team),
                        ],
                        const _SectionDivider(),
                        _SectionTitle(
                          title: _copy(
                            zh: '${user.nickname}的动态',
                            en: "${user.nickname}'s posts",
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (user.moment == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(
                                'user_no_posts'.tr,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          _MomentCard(user: user),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.separator)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      if (user.isVerified) ...[
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: controller.startCall,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.textPrimary,
                              ),
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: controller.startChat,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accentYellow,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text('user_chat'.tr),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMore() {
    Get.bottomSheet<void>(
      SafeArea(
        child: ColoredBox(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                title: Text('common_report'.tr),
                onTap: () {
                  Get.back<void>();
                  Get.toNamed(Routes.report, arguments: controller.user);
                },
              ),
              ListTile(
                title: Text(
                  'common_block'.tr,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: controller.block,
              ),
              ListTile(
                title: Text(
                  'common_shield'.tr,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: controller.shield,
              ),
              ListTile(title: Text('common_cancel'.tr), onTap: Get.back),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _GalleryPreview extends StatelessWidget {
  const _GalleryPreview({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < paths.take(3).length; index++)
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: () => Get.toNamed(
              Routes.imagePreview,
              arguments: {'images': paths, 'index': index},
            ),
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(paths[index], fit: BoxFit.cover),
              ),
            ),
          ),
        ),
    ],
  );
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.controller});

  final UserDetailController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      user.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 5),
                    Image.asset(
                      'assets/icons/status/ic_verified.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final invited = controller.invited.value;
              return FilledButton(
                onPressed: controller.invite,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: invited
                      ? const Color(0xFFF3F3F3)
                      : AppColors.accentYellow,
                  foregroundColor: invited
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  invited ? 'user_invited'.tr : 'user_invite'.tr,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (user.gender.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.gender == '女' ? Icons.female : Icons.male,
                      color: const Color(0xFF4A86F7),
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${user.age}',
                      style: const TextStyle(
                        color: Color(0xFF4A86F7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Text(
              '${_copy(zh: '微撩号', en: 'ID')}: ${user.id + 1237500}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          user.intro.isEmpty ? 'user_default_intro'.tr : user.intro,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: foreground),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 22),
    child: Divider(height: 1, color: AppColors.separator),
  );
}

class _BasicInfoGrid extends StatelessWidget {
  const _BasicInfoGrid({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final values = [
      (_copy(zh: '微撩号', en: 'ID'), '${user.id + 1237500}'),
      (
        _copy(zh: '性别', en: 'Gender'),
        user.gender.isEmpty ? 'user_none'.tr : user.gender.tr,
      ),
      (_copy(zh: '年龄', en: 'Age'), 'user_age'.trParams({'age': '${user.age}'})),
      (
        _copy(zh: '兴趣', en: 'Interest'),
        user.hobbies.firstOrNull?.tr ?? 'user_none'.tr,
      ),
      (
        _copy(zh: '真人认证', en: 'Verified'),
        user.isVerified ? 'common_yes'.tr : 'common_no'.tr,
      ),
      (
        _copy(zh: '动态', en: 'Posts'),
        user.moment == null ? 'user_none'.tr : 'common_yes'.tr,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        mainAxisExtent: 56,
      ),
      itemCount: values.length,
      itemBuilder: (_, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              values[index].$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              values[index].$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.user, required this.team});

  final User user;
  final TeamPost team;

  @override
  Widget build(BuildContext context) {
    final cover = team.imagePaths.firstOrNull ?? user.avatarPath;
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.teamDetail, arguments: user),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  cover,
                  width: 118,
                  height: 128,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ActivityLine(
                      icon: Icons.location_on_outlined,
                      value: team.location,
                    ),
                    const SizedBox(height: 6),
                    _ActivityLine(
                      icon: Icons.schedule,
                      value: _formatDate(team.date),
                    ),
                    const SizedBox(height: 6),
                    _ActivityLine(
                      icon: Icons.local_activity_outlined,
                      value: team.activity.tr,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ),
    ],
  );
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final moment = user.moment!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(moment.createdAt),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          moment.content,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        if (moment.imagePaths.isNotEmpty) ...[
          const SizedBox(height: 9),
          GestureDetector(
            onTap: () => Get.toNamed(
              Routes.imagePreview,
              arguments: {'images': moment.imagePaths, 'index': 0},
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1.12,
                child: Image.asset(moment.imagePaths.first, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.more_horiz, color: Color(0xFFCCCCCC), size: 20),
            const Spacer(),
            const Icon(
              Icons.thumb_up_alt_outlined,
              color: Color(0xFFCCCCCC),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'video_like'.tr,
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';

String _copy({required String zh, required String en}) =>
    Get.locale?.languageCode == 'en' ? en : zh;
