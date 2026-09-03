import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../domain/entities/user.dart';
import '../controllers/home_controller.dart';
import '../team_publish/team_flow_assets.dart';
import 'team_detail_controller.dart';

const _detailYellow = Color(0xFFFFCE45);

String _detailCopy(String zh, String en) =>
    Get.locale?.languageCode == 'zh' ? zh : en;

class TeamDetailPage extends GetView<TeamDetailController> {
  const TeamDetailPage({super.key});

  void _openNearby() {
    Get.back<HomeFeedTab>(result: HomeFeedTab.nearby);
  }

  Future<void> _writeComment(BuildContext context) async {
    final input = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_detailCopy('写评论', 'Write a comment')),
        content: TextField(
          controller: input,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _detailCopy('说说你对活动的期待…', 'Share what you think…'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common_cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, input.text.trim()),
            child: Text(_detailCopy('发布', 'Post')),
          ),
        ],
      ),
    );
    input.dispose();
    if (value?.isNotEmpty == true) controller.addComment(value!);
  }

  @override
  Widget build(BuildContext context) {
    final post = controller.post;
    final cover = post.imagePaths.isEmpty
        ? TeamFlowAssets.detailCover
        : post.imagePaths.first;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _RoundTopButton(
                assetPath: TeamFlowAssets.detailBackIcon,
                onTap: Get.back,
              ),
            ),
            actions: [
              _RoundTopButton(
                assetPath: TeamFlowAssets.detailMoreIcon,
                onTap: controller.openOrganizer,
              ),
              const SizedBox(width: 16),
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
                    text: _detailCopy(
                      '地址：${post.location}',
                      'Location: ${post.location}',
                    ),
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
                          _detailCopy('评论', 'Comments'),
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _writeComment(context),
                        icon: const AppImage(
                          TeamFlowAssets.detailEditIcon,
                          width: 16,
                          height: 16,
                        ),
                        label: Text(_detailCopy('评论', 'Comment')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF888888),
                          side: const BorderSide(color: Color(0xFFAAAAAA)),
                          minimumSize: const Size(62, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
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
                          _detailCopy('聊一聊', 'Chat'),
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
    );
  }
}

class _RoundTopButton extends StatelessWidget {
  const _RoundTopButton({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xAA1D1D1D),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 34,
          child: Center(child: AppImage(assetPath, width: 24, height: 24)),
        ),
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
            ? _detailCopy('报名申请审核中', 'Join request pending')
            : _detailCopy('点击报名活动', 'Tap to join this activity'),
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
                    const SizedBox(
                      width: 54,
                      height: 24,
                      child: Stack(
                        children: [
                          _ParticipantAvatar(
                            left: 0,
                            assetPath: TeamFlowAssets.detailParticipant1,
                          ),
                          _ParticipantAvatar(
                            left: 16,
                            assetPath: TeamFlowAssets.detailParticipant2,
                          ),
                          Positioned(
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
                      '${controller.participantCount}/${controller.participantTotal}',
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
                  _detailCopy('寻找更多搭子', 'Find more friends'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF864A00),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _detailCopy(
                    '有颜有趣的人 · 尽在附近搭子',
                    'Interesting people are nearby',
                  ),
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
              _detailCopy('前往寻找', 'Explore'),
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
          OutlinedButton(
            onPressed: onGreeting,
            style: OutlinedButton.styleFrom(
              foregroundColor: _detailYellow,
              side: const BorderSide(color: _detailYellow),
              minimumSize: const Size(54, 28),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              _detailCopy('打招呼', 'Say hi'),
              style: const TextStyle(fontSize: 11),
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
    return _detailCopy('美食', 'Food');
  }
  if (activity.contains('山') ||
      activity.contains('露营') ||
      activity.contains('徒步')) {
    return _detailCopy('户外', 'Outdoor');
  }
  if (activity.contains('骑') ||
      activity.contains('球') ||
      activity.contains('跑')) {
    return _detailCopy('运动', 'Sports');
  }
  return _detailCopy('娱乐', 'Fun');
}

String _detailDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final end = value.add(const Duration(hours: 1));
  final endHour = end.hour.toString().padLeft(2, '0');
  final endMinute = end.minute.toString().padLeft(2, '0');
  return _detailCopy(
    '时间：$month月$day日 $hour:$minute–$endHour:$endMinute',
    'Date: $month/$day $hour:$minute–$endHour:$endMinute',
  );
}
