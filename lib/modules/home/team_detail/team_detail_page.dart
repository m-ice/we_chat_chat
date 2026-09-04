import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../core/widgets/app_text_input_dialog.dart';
import '../../../domain/entities/team_detail_comment.dart';
import '../../../domain/entities/user.dart';
import '../controllers/home_controller.dart';
import '../team_publish/team_flow_assets.dart';
import 'team_detail_controller.dart';

const _detailYellow = Color(0xFFFFCE45);

class TeamDetailPage extends GetView<TeamDetailController> {
  const TeamDetailPage({super.key});

  void _openNearby() {
    Get.back<HomeFeedTab>(result: HomeFeedTab.nearby);
  }

  Future<void> _writeComment() async {
    final value = await AppTextInputDialog.show(
      title: 'team_comment_write'.tr,
      hint: 'team_comment_hint'.tr,
      confirmText: 'team_comment_post'.tr,
      minLines: 2,
      maxLines: 4,
      maxLength: 200,
    );
    final content = value?.trim();
    if (content?.isNotEmpty == true) await controller.addComment(content!);
  }

  @override
  Widget build(BuildContext context) {
    final post = controller.post;
    final cover = post.imagePaths.isEmpty
        ? TeamFlowAssets.detailCover
        : post.imagePaths.first;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppRefreshView(
        onRefresh: controller.reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 368,
              pinned: false,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.imagePreview,
                    arguments: {
                      'images': post.imagePaths.isEmpty
                          ? [cover]
                          : post.imagePaths,
                      'index': 0,
                    },
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(cover, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Color(0x99000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: _RoundTopButton(
                assetPath: TeamFlowAssets.detailBackIcon,
                onTap: Get.back,
              ),
              actions: [
                _RoundTopButton(
                  assetPath: TeamFlowAssets.detailMoreIcon,
                  onTap: controller.openOrganizer,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  MediaQuery.paddingOf(context).bottom + 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _detailTitle(post),
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _DetailCategoryChip(
                          label: _detailCategory(post.activity),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _detailDescription(post),
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailMeta(
                      assetPath: TeamFlowAssets.detailTimeIcon,
                      text: _detailDate(post.date),
                    ),
                    const SizedBox(height: 6),
                    _DetailMeta(
                      assetPath: TeamFlowAssets.detailLocationIcon,
                      text: 'team_location_value'.trParams({
                        'location': post.location,
                      }),
                    ),
                    const SizedBox(height: 14),
                    _ParticipantBar(controller: controller),
                    const SizedBox(height: 12),
                    _NearbyBanner(onExplore: _openNearby),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFF0E9D7)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'team_comments'.tr,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: _writeComment,
                          child: Container(
                            height: 27.h,
                            constraints: BoxConstraints(minWidth: 62.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(26.r),
                              border: Border.all(
                                color: Color(0xFF999999),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppImage(
                                  TeamFlowAssets.detailEditIcon,
                                  width: 16.w,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'team_comments'.tr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // OutlinedButton.icon(
                        //   onPressed: () => _writeComment(context),
                        //   icon: const AppImage(
                        //     TeamFlowAssets.detailEditIcon,
                        //     width: 16,
                        //     height: 16,
                        //   ),
                        //   label: Text('team_comments'.tr),
                        //   style: OutlinedButton.styleFrom(
                        //     foregroundColor: const Color(0xFF888888),
                        //     side: const BorderSide(color: Color(0xFFAAAAAA)),
                        //     minimumSize: const Size(62, 30),
                        //     // padding: const EdgeInsets.symmetric(horizontal: 9),
                        //     visualDensity: VisualDensity.compact,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Obx(
                      () => Column(
                        children: controller.comments
                            .map(
                              (comment) => _CommentRow(
                                comment: comment,
                                onGreeting: controller.openChat,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 52,
                        child: FilledButton(
                          key: const ValueKey('team-detail-chat'),
                          onPressed: controller.openChat,
                          style: FilledButton.styleFrom(
                            backgroundColor: _detailYellow,
                            foregroundColor: Colors.black,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'team_chat'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundTopButton extends StatelessWidget {
  const _RoundTopButton({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xAA1D1D1D),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(child: AppImage(assetPath, width: 24)),
      ),
    );
  }
}

class _DetailCategoryChip extends StatelessWidget {
  const _DetailCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFF99900), fontSize: 12),
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  const _DetailMeta({required this.assetPath, required this.text});

  final String assetPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppImage(assetPath, width: 16, height: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _ParticipantBar extends StatelessWidget {
  const _ParticipantBar({required this.controller});

  final TeamDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Semantics(
        button: true,
        label: controller.pending.value
            ? 'team_join_pending_semantics'.tr
            : 'team_join_tap_semantics'.tr,
        child: Material(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const ValueKey('team-detail-join'),
            onTap: controller.join,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 42,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      height: 24,
                      child: Stack(
                        children: [
                          for (
                            var index = 0;
                            index <
                                controller.participantAvatarPaths
                                    .take(2)
                                    .length;
                            index++
                          )
                            _ParticipantAvatar(
                              left: index * 16,
                              assetPath:
                                  controller.participantAvatarPaths[index],
                            ),
                          const Positioned(
                            left: 32,
                            child: AppImage(
                              TeamFlowAssets.detailParticipantAdd,
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${controller.participantCount}/${controller.participantTotal.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.left, required this.assetPath});

  final double left;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
        clipBehavior: Clip.antiAlias,
        child: AppImage(assetPath, fit: BoxFit.cover),
      ),
    );
  }
}

class _NearbyBanner extends StatelessWidget {
  const _NearbyBanner({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE9AC), Color(0xFFFFDD7E)],
        ),
      ),
      child: Row(
        children: [
          const _NearbyAvatarGrid(),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'team_nearby_title'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF864A00),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'team_nearby_subtitle'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6F4E19),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onExplore,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9A5B00),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              'team_nearby_action'.tr,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyAvatarGrid extends StatelessWidget {
  const _NearbyAvatarGrid();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 44,
      height: 46,
      child: Stack(
        children: [
          _BannerAvatar(left: 0, top: 0, path: TeamFlowAssets.detailBanner1),
          _BannerAvatar(left: 22, top: 0, path: TeamFlowAssets.detailBanner2),
          _BannerAvatar(left: 0, top: 22, path: TeamFlowAssets.detailBanner3),
          _BannerAvatar(left: 22, top: 22, path: TeamFlowAssets.detailBanner4),
          Positioned(
            left: 12,
            top: 12,
            child: AppImage(
              TeamFlowAssets.detailBannerCenter,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerAvatar extends StatelessWidget {
  const _BannerAvatar({
    required this.left,
    required this.top,
    required this.path,
  });

  final double left;
  final double top;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: AppImage(path, fit: BoxFit.cover),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment, required this.onGreeting});

  final TeamDetailComment comment;
  final VoidCallback onGreeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClipOval(
            child: AppImage(
              TeamFlowAssets.detailCommentAvatar,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.nickname,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onGreeting,
            child: Container(
              width: 54.w,
              height: 27.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(color: Color(0xFFFFCE45), width: 1.w),
              ),
              child: Text(
                'team_greet'.tr,
                style: TextStyle(fontSize: 11.sp, color: Color(0xFFFFCE45)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _detailTitle(TeamPost post) {
  final firstLine = post.content.trim().split('\n').first.trim();
  if (post.content.contains('\n') && firstLine.isNotEmpty) return firstLine;
  final activity = post.activity.tr.replaceAll('组队', '').trim();
  return activity.isEmpty ? post.activity.tr : activity;
}

String _detailDescription(TeamPost post) {
  final lines = post.content.trim().split('\n');
  if (lines.length > 1) return lines.skip(1).join('\n').trim();
  return post.content;
}

String _detailCategory(String activity) {
  if (activity.contains('吃') ||
      activity.contains('美食') ||
      activity.contains('咖啡')) {
    return 'team_category_food'.tr;
  }
  if (activity.contains('山') ||
      activity.contains('露营') ||
      activity.contains('徒步')) {
    return 'team_category_outdoor'.tr;
  }
  if (activity.contains('骑') ||
      activity.contains('球') ||
      activity.contains('跑')) {
    return 'team_category_sports'.tr;
  }
  return 'team_category_fun'.tr;
}

String _detailDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final end = value.add(const Duration(hours: 1));
  final endHour = end.hour.toString().padLeft(2, '0');
  final endMinute = end.minute.toString().padLeft(2, '0');
  return 'team_time_range'.trParams({
    'month': month,
    'day': day,
    'start': '$hour:$minute',
    'end': '$endHour:$endMinute',
  });
}
