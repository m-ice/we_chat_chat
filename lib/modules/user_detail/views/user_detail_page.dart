import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../shared/actions/user_actions_sheet.dart';
import '../../shared/report/report_controller.dart';
import '../controllers/user_detail_controller.dart';

class UserDetailPage extends GetView<UserDetailController> {
  const UserDetailPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    controller.profileUser.value;
    controller.seedProfile.value;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppRefreshView(
        onRefresh: controller.reloadProfile,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _ProfileHero(
              controller: controller,
              onMore: controller.isCurrentUser.value ? null : _showMore,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileSummary(controller: controller),
                    const SizedBox(height: 18),
                    _ProfileTag(
                      text: 'user_interests'.trParams({
                        'value': controller.user.hobbies.isEmpty
                            ? 'user_none'.tr
                            : controller.user.hobbies
                                  .map((item) => item.tr)
                                  .join(' / '),
                      }),
                      background: const Color(0x1A4A86F7),
                      foreground: const Color(0xFF4A86F7),
                    ),
                    const SizedBox(height: 8),
                    _ProfileTag(
                      text: 'user_personality'.trParams({
                        'value': controller.generatedPersonalityTags
                            .map((item) => item.tr)
                            .join(' / '),
                      }),
                      background: const Color(0x1AF8A88F),
                      foreground: const Color(0xFFF8A88F),
                    ),
                    const _SectionDivider(),
                    _SectionTitle(title: 'user_basic_profile'.tr),
                    const SizedBox(height: 12),
                    _BasicInfoGrid(items: controller.facts),
                    if (controller.activities.isNotEmpty) ...[
                      const _SectionDivider(),
                      _SectionTitle(title: 'user_published_activities'.tr),
                      const SizedBox(height: 12),
                      for (final item in controller.activities) ...[
                        _ActivityCard(controller: controller, item: item),
                        const SizedBox(height: 12),
                      ],
                    ],
                    if (!controller.isCurrentUser.value) ...[
                      const _SectionDivider(),
                      _SectionTitle(title: 'user_posts'.tr),
                      const SizedBox(height: 12),
                      if (controller.moments.isEmpty)
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
                        for (final item in controller.moments) ...[
                          _MomentCard(
                            item: item,
                            onMore: () => _showMomentMore(item),
                          ),
                          const SizedBox(height: 18),
                        ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // CommonDraggableFloatWidget(
      //   width: 70,
      //   height: 32,
      //   eventStreamController: controller.floatingActionEvents,
      //   borderTop: 0,
      //   borderRight: 12,
      //   borderBottom: 70,
      //   initPositionYInTop: true,
      //   initPositionYMarginBorder: chatButtonTop,
      //   slideInstantly: SlideInstantly.instantly,
      //   onTap: controller.startChat,
      //   listView:
      //   child:
      // ),
    );
  });

  void _showMore() {
    showUserActionsSheet(
      onBlock: controller.block,
      onReport: () => Get.toNamed(Routes.report, arguments: controller.user),
    );
  }

  void _showMomentMore(UserDetailMomentData moment) {
    showUserActionsSheet(
      onBlock: controller.block,
      onReport: () => Get.toNamed(
        Routes.report,
        arguments: ReportArguments(
          target: controller.user,
          targetDynamicId: moment.id,
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.controller, required this.onMore});

  final UserDetailController controller;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final images = [
      controller.heroImagePath,
      ...controller.galleryPreviewPaths.take(3),
    ];

    return SliverAppBar(
      expandedHeight: 440,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      stretch: true,
      leadingWidth: 64,
      leading: _HeroActionButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        assetPath: AppImageString.videoUserProfileBack,
        onTap: Get.back,
      ),
      actions: [
        if (onMore != null)
          _HeroActionButton(
            tooltip: 'common_more'.tr,
            assetPath: AppImageString.videoUserProfileMore,
            onTap: onMore!,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: GestureDetector(
          onTap: () => Get.toNamed(
            Routes.imagePreview,
            arguments: {
              'images': images,
              'index': controller.imageCarouselIndex.value,
            },
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: images.length,
                controller: controller.imageCarouselC,
                onPageChanged: (index) =>
                    controller.imageCarouselIndex.value = index,
                itemBuilder: (context, index) {
                  return AppImage(
                    images[index],
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  );
                },
              ),
              // const DecoratedBox(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [Color(0xB3000000), Colors.transparent],
              //       stops: [0, .24],
              //     ),
              //   ),
              // ),
              if (images.length > 1)
                Positioned(
                  right: 16,
                  bottom: 12,
                  child: Obx(
                    () => _GalleryPreview(
                      paths: images,
                      currentIndex: controller.imageCarouselIndex.value,
                      onTap: controller.selectCarouselImage,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.tooltip,
    required this.assetPath,
    required this.onTap,
  });

  final String tooltip;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    icon: Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(32.w),
      ),
      child: Center(child: AppImage(assetPath, width: 24.w)),
    ),
  );
}

class _GalleryPreview extends StatelessWidget {
  const _GalleryPreview({
    required this.paths,
    required this.currentIndex,
    required this.onTap,
  });

  final ValueChanged<int> onTap;

  final List<String> paths;
  final int currentIndex;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < paths.length; index++)
        Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
          child: GestureDetector(
            key: ValueKey('user-detail-gallery-thumbnail-$index'),
            onTap: () => onTap(index),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: currentIndex != index
                  ? null
                  : BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.w),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
              clipBehavior: currentIndex != index ? Clip.none : Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                clipBehavior: Clip.hardEdge,
                child: AppImage(paths[index], fit: BoxFit.cover),
              ),
            ),
          ),
        ),
    ],
  );
}

class _ChatPill extends StatelessWidget {
  const _ChatPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('user-detail-chat'),
    width: 70,
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 9),
    decoration: BoxDecoration(
      color: AppColors.accentYellow,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppImage(
          AppImageString.videoUserProfileChat,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 5.h),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    if (user.gender.isNotEmpty)
                      Container(
                        height: 20.h,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF4AC3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppImage(
                              AppImageString.videoUserProfileGender,
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${user.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'ID: ${user.displayId}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    // if (user.isSeedData) const SeedContentBadge(compact: true),
                    // Obx(
                    //       () => TextButton(
                    //     key: const ValueKey('user-detail-invite'),
                    //     onPressed: controller.invite,
                    //     style: TextButton.styleFrom(
                    //       minimumSize: const Size(0, 28),
                    //       padding: const EdgeInsets.symmetric(horizontal: 6),
                    //       visualDensity: VisualDensity.compact,
                    //       foregroundColor: AppColors.textPrimary,
                    //     ),
                    //     child: Text(
                    //       controller.invited.value
                    //           ? 'user_invited'.tr
                    //           : 'user_invite'.tr,
                    //       style: const TextStyle(fontSize: 12),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 10.w),
            if (!controller.isCurrentUser.value)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.startChat,
                child: _ChatPill(label: 'user_chat'.tr),
              ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          user.intro.isEmpty ? 'user_default_intro'.tr : user.intro,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 30),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(color: foreground, fontSize: 13, height: 1.35),
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
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 17),
    child: Divider(height: .5, color: AppColors.separator),
  );
}

class _BasicInfoGrid extends StatelessWidget {
  const _BasicInfoGrid({required this.items});

  final List<UserDetailFact> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      mainAxisExtent: 64,
    ),
    itemCount: items.length,
    itemBuilder: (_, index) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            items[index].label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            items[index].value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.controller, required this.item});

  final UserDetailController controller;
  final UserDetailActivityData item;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey('user-detail-activity-${item.post.id}'),
      onTap: () => controller.openActivity(item),
      child: Container(
        height: 198,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF1F1F1)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 128,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppImage(
                      item.coverPath,
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
                          item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        _ActivityLine(
                          prefix: 'user_time_prefix'.tr,
                          value: _formatDateTime(item.date),
                        ),
                        const SizedBox(height: 5),
                        _ActivityLine(
                          prefix: 'user_place_prefix'.tr,
                          value: item.location,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      child: Stack(
                        children: [
                          for (
                            var index = 0;
                            index < item.participantPaths.take(3).length;
                            index++
                          )
                            Positioned(
                              left: index * 16,
                              top: 4,
                              child: ClipOval(
                                child: AppImage(
                                  item.participantPaths[index],
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'user_interested_count'.trParams({
                          'count': '${item.interestedCount}',
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.prefix, required this.value});

  final String prefix;
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    '$prefix$value',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
  );
}

class _MomentCard extends GetView<UserDetailController> {
  const _MomentCard({required this.item, required this.onMore});

  final UserDetailMomentData item;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _formatDate(item.createdAt),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      const SizedBox(height: 8),
      Text(
        item.content,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => Get.toNamed(
          Routes.imagePreview,
          arguments: {
            'images': [item.imagePath],
            'index': 0,
          },
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 343 / 299,
            child: AppImage(item.imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
      const SizedBox(height: 9),
      Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMore,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: AppImage(
                AppImageString.videoUserProfileOverflow,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            key: ValueKey('user-moment-like-${item.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.toggleMomentLike(item),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AppImage(
                controller.isLiked(item)
                    ? AppImageString.videoUserLikeSelected
                    : AppImageString.videoUserProfileLike,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            controller.likeCount(item) > 0
                ? '${controller.likeCount(item)}'
                : 'video_like'.tr,
            style: TextStyle(
              color: controller.isLiked(item)
                  ? const Color(0xFFFF416D)
                  : const Color(0xFFCCCCCC),
              fontSize: 13,
            ),
          ),
        ],
      ),
      const Divider(height: 17, color: AppColors.separator),
    ],
  );
}

String _formatDate(DateTime value) => 'user_date_month_day'.trParams({
  'month': '${value.month}',
  'day': '${value.day}',
});

String _formatDateTime(DateTime value) =>
    '${value.month}/${value.day} ${value.hour.toString().padLeft(2, '0')}:00';
