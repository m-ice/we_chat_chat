import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/my_world_post.dart';
import '../controllers/my_world_controller.dart';
import '../controllers/profile_controller.dart';
import 'profile_design.dart';

class MyWorldPage extends GetView<MyWorldController> {
  const MyWorldPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_world'.tr,
    body: Obx(
      () => AppRefreshView(
        onRefresh: () async => controller.reload(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: controller.posts.isEmpty ? 1 : controller.posts.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: controller.posts.isEmpty
                ? _EmptyWorldState(onPublish: controller.openPublish)
                : _PostCard(post: controller.posts[index]),
          ),
        ),
      ),
    ),
  );
}

class _EmptyWorldState extends StatelessWidget {
  const _EmptyWorldState({required this.onPublish});

  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .58,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '还没有发布动态',
            style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onPublish,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFCE45),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            child: const Text('发布第一条动态'),
          ),
        ],
      ),
    ),
  );
}

class _PostCard extends GetView<MyWorldController> {
  const _PostCard({required this.post});

  final MyWorldPost post;

  @override
  Widget build(BuildContext context) {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;
    final avatar =
        profile?.avatarFilePath.value ??
        profile?.currentUser.value?.avatarPath ??
        ProfileDetailAssets.worldAvatar;
    final nickname = profile?.nickname.value.isNotEmpty == true
        ? profile!.nickname.value
        : 'page_profile'.tr;
    return FutureBuilder<List<String>>(
      future: controller.repository.fullImagePaths(post),
      builder: (context, snapshot) {
        final images = snapshot.data ?? const <String>[];
        return _PostShell(
          avatar: avatar,
          nickname: nickname,
          meta: post.reviewStatus == MyWorldReviewStatus.pending
              ? 'world_pending'.tr
              : post.topics.map((topic) => topic.tr).join('  |  '),
          content: post.content,
          image: images.firstOrNull,
          time: _dateLabel(post.createdAt),
          onImageTap: images.isEmpty ? null : () => controller.preview(post, 0),
          onAction: _showInteractionPending,
          onMore: () => _showMore(context),
        );
      },
    );
  }

  String _dateLabel(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());
    if (!difference.isNegative && difference.inMinutes < 1) return '刚刚发布';
    if (!difference.isNegative && difference.inHours < 1) {
      return '${difference.inMinutes}分钟前发布';
    }
    if (!difference.isNegative && difference.inHours < 24) {
      return '${difference.inHours}小时前发布';
    }
    return '${date.month}月${date.day}日发布';
  }

  // LOGIC_PENDING(profile-world-interactions): the current controller/repository
  // exposes publish, preview and delete only; greeting/like/comment endpoints are
  // intentionally not fabricated in the UI layer.
  void _showInteractionPending() => AppToast.show('互动功能暂未接入');

  Future<void> _showMore(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('world_publish'.tr),
                onTap: () => Navigator.pop(context, 'publish'),
              ),
              ListTile(
                title: Text(
                  'common_delete'.tr,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
              ListTile(
                title: Text('common_cancel'.tr),
                onTap: Navigator.of(context).pop,
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'publish') await controller.openPublish();
    if (action == 'delete') await controller.remove(post);
  }
}

class _PostShell extends StatelessWidget {
  const _PostShell({
    required this.avatar,
    required this.nickname,
    required this.meta,
    required this.content,
    required this.time,
    required this.onAction,
    required this.onMore,
    this.image,
    this.onImageTap,
  });

  final String avatar;
  final String nickname;
  final String meta;
  final String content;
  final String? image;
  final String time;
  final VoidCallback onAction;
  final VoidCallback onMore;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 16, 10, 22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF1F1F1), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: AppImage(avatar, width: 40, height: 40, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBBBBBB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCE45),
                foregroundColor: Colors.black,
                minimumSize: const Size(0, 30),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('打招呼'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Colors.black,
          ),
        ),
        if (image != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                image!,
                width: 178,
                height: 198,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkResponse(
              onTap: onMore,
              radius: 22,
              child: const AppImage(
                ProfileDetailAssets.worldMore,
                width: 24,
                height: 24,
              ),
            ),
            const Spacer(),
            _PostAction(
              icon: ProfileDetailAssets.worldLike,
              label: '点赞',
              onTap: () => AppToast.show('点赞功能暂未接入'),
            ),
            const Spacer(),
            _PostAction(
              icon: ProfileDetailAssets.worldComment,
              label: '评论',
              onTap: () => AppToast.show('评论功能暂未接入'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PostAction extends StatelessWidget {
  const _PostAction({
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
    borderRadius: BorderRadius.circular(16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(icon, width: 24, height: 24),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
        ),
      ],
    ),
  );
}
