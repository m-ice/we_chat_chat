import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/square_feed.dart';
import '../controllers/square_controller.dart';
import 'video_feed_page.dart';

class SquarePage extends GetView<SquareController> {
  const SquarePage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final tab = controller.tab.value;
    final isVideo = tab == SquareTab.video;
    final content = SafeArea(
      bottom: false,
      child: Column(
        children: [
          _SquareHeader(selected: tab, dark: isVideo),
          Expanded(
            child: isVideo ? const SquareVideoPane() : const _SquareFeed(),
          ),
        ],
      ),
    );
    if (isVideo) {
      return ColoredBox(color: Colors.black, child: content);
    }
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.white)),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 255,
          child: Image.asset(
            'assets/images/content/figma_discover_header_bg.png',
            fit: BoxFit.fill,
          ),
        ),
        content,
      ],
    );
  });
}

class _SquareHeader extends GetView<SquareController> {
  const _SquareHeader({required this.selected, required this.dark});

  final SquareTab selected;
  final bool dark;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      children: [
        const SizedBox(width: 16),
        _SquareTabButton(
          label: 'square_following'.tr,
          selected: selected == SquareTab.following,
          dark: dark,
          onTap: () => controller.selectTab(SquareTab.following),
        ),
        const SizedBox(width: 20),
        _SquareTabButton(
          label: _copy(zh: '发现', en: 'Discover'),
          selected: selected == SquareTab.discover,
          dark: dark,
          onTap: () => controller.selectTab(SquareTab.discover),
        ),
        const SizedBox(width: 20),
        _SquareTabButton(
          label: 'album_video'.tr,
          selected: selected == SquareTab.video,
          dark: dark,
          onTap: () => controller.selectTab(SquareTab.video),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'common_search'.tr,
          onPressed: () => Get.toNamed(Routes.centerSearch),
          icon: Image.asset(
            'assets/images/content/figma_discover_icon_search.png',
            width: 24,
            height: 24,
            color: dark ? Colors.white : null,
          ),
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

class _SquareTabButton extends StatelessWidget {
  const _SquareTabButton({
    required this.label,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? (dark ? Colors.white : AppColors.textPrimary)
                  : (dark ? Colors.white70 : const Color(0xFF666666)),
              fontSize: selected ? 17 : 16,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          SizedBox(
            width: 23,
            height: 8,
            child: selected
                ? Image.asset(
                    'assets/images/content/figma_discover_tab_underline.png',
                    width: 23,
                    height: 8,
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

class _SquareFeed extends GetView<SquareController> {
  const _SquareFeed();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: RefreshIndicator(
          onRefresh: controller.reload,
          child: Obx(() {
            if (controller.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 280,
                    child: Center(
                      child: Text(
                        controller.tab.value == SquareTab.following
                            ? 'square_following_empty'.tr
                            : 'square_empty'.tr,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 76),
              itemCount: controller.items.length,
              itemBuilder: (_, index) =>
                  _SquarePost(item: controller.items[index], index: index),
            );
          }),
        ),
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: GestureDetector(
          key: const ValueKey('square-publish'),
          onTap: controller.publish,
          child: Container(
            width: 92,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              border: Border.all(color: AppColors.textPrimary, width: 2),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              'world_publish'.tr,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _SquarePost extends GetView<SquareController> {
  const _SquarePost({required this.item, required this.index});

  final SquareFeedItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final figmaVisual = item.usesSandboxImages ? null : _visualFor(index);
    final staticPaths = figmaVisual?.imagePaths;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        key: ValueKey('square-post-$index'),
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F1F1), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _openUser,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      figmaVisual?.avatarPath ?? item.user.avatarPath,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _openUser,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.user.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _profileLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: FilledButton(
                    onPressed: _openUser,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      _copy(zh: '打招呼', en: 'Say hi'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.content,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            if (staticPaths != null && staticPaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PostImageGrid(
                paths: staticPaths,
                usesFiles: false,
                onPreview: (imageIndex) =>
                    controller.previewAssets(staticPaths, imageIndex),
              ),
            ] else if (item.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              FutureBuilder<List<String>>(
                future: controller.repository.resolvedImages(item),
                builder: (_, snapshot) => _PostImageGrid(
                  paths: snapshot.data ?? const [],
                  usesFiles: item.usesSandboxImages,
                  onPreview: (imageIndex) =>
                      controller.preview(item, imageIndex),
                ),
              ),
            ],
            const SizedBox(height: 9),
            Text(
              '${_shortTime(item.time)}${_copy(zh: '发布', en: '')}',
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11),
            ),
            const SizedBox(height: 4),
            _PostActionRow(item: item, onComment: _openUser),
          ],
        ),
      ),
    );
  }

  String get _profileLine {
    final fields = <String>['${item.user.age}${_copy(zh: '岁', en: '')}'];
    if (item.user.gender.isNotEmpty) fields.add(item.user.gender.tr);
    if (item.user.hobbies.isNotEmpty) fields.add(item.user.hobbies.first.tr);
    return fields.join('｜');
  }

  void _openUser() => Get.toNamed(Routes.userDetail, arguments: item.user);
}

class _PostImageGrid extends StatelessWidget {
  const _PostImageGrid({
    required this.paths,
    required this.usesFiles,
    required this.onPreview,
  });

  final List<String> paths;
  final bool usesFiles;
  final ValueChanged<int> onPreview;

  @override
  Widget build(BuildContext context) {
    final visible = paths.take(6).toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();
    if (visible.length == 1) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 178,
          height: 198,
          child: _image(visible.first, 0),
        ),
      );
    }
    final columns = visible.length == 2 || visible.length == 4 ? 2 : 3;
    final width = visible.length == 4 ? 260.0 : 320.0;
    final cell = (width - (columns - 1) * 4) / columns;
    final rows = (visible.length / columns).ceil();
    return SizedBox(
      width: width,
      height: cell * rows + (rows - 1) * 4,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: visible.length,
        itemBuilder: (_, imageIndex) => _image(visible[imageIndex], imageIndex),
      ),
    );
  }

  Widget _image(String path, int imageIndex) => Material(
    color: const Color(0xFFF3F3F3),
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onPreview(imageIndex),
      child: usesFiles
          ? Image.file(File(path), fit: BoxFit.cover)
          : Image.asset(path, fit: BoxFit.cover),
    ),
  );
}

class _PostActionRow extends GetView<SquareController> {
  const _PostActionRow({required this.item, required this.onComment});

  final SquareFeedItem item;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _FigmaAction(
        assetPath: 'assets/images/content/figma_discover_icon_more.png',
        rotateQuarterTurns: 1,
        onTap: () => controller.more(item),
      ),
      const Spacer(),
      Obx(() {
        final liked = controller.likedIds.contains(item.postId);
        return _FigmaAction(
          assetPath: 'assets/images/content/figma_discover_icon_like.png',
          label: 'video_like'.tr,
          color: liked ? const Color(0xFFFF3D91) : null,
          onTap: () => controller.toggleLike(item),
        );
      }),
      const SizedBox(width: 28),
      _FigmaAction(
        assetPath: 'assets/images/content/figma_discover_icon_comment.png',
        label: _copy(zh: '评论', en: 'Comment'),
        onTap: onComment,
      ),
    ],
  );
}

class _FigmaAction extends StatelessWidget {
  const _FigmaAction({
    required this.assetPath,
    required this.onTap,
    this.label,
    this.color,
    this.rotateQuarterTurns = 0,
  });

  final String assetPath;
  final VoidCallback onTap;
  final String? label;
  final Color? color;
  final int rotateQuarterTurns;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotatedBox(
            quarterTurns: rotateQuarterTurns,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                color ?? const Color(0xFFCCCCCC),
                BlendMode.srcIn,
              ),
              child: Image.asset(assetPath, width: 24, height: 24),
            ),
          ),
          if (label case final value?) ...[
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color ?? const Color(0xFFCCCCCC),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _FeedVisual {
  const _FeedVisual({required this.avatarPath, required this.imagePaths});

  final String avatarPath;
  final List<String> imagePaths;
}

_FeedVisual _visualFor(int index) =>
    _figmaVisuals[index % _figmaVisuals.length];

const _figmaVisuals = [
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_01.png',
    imagePaths: ['assets/images/content/figma_discover_square_post_01_01.png'],
  ),
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_02.png',
    imagePaths: [
      'assets/images/content/figma_discover_square_post_02_01.png',
      'assets/images/content/figma_discover_square_post_02_02.png',
    ],
  ),
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_03.png',
    imagePaths: [
      'assets/images/content/figma_discover_square_post_02_02.png',
      'assets/images/content/figma_discover_square_post_03_01.png',
      'assets/images/content/figma_discover_square_post_03_02.png',
    ],
  ),
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_04.png',
    imagePaths: [
      'assets/images/content/figma_discover_square_post_04_01.png',
      'assets/images/content/figma_discover_square_post_04_02.png',
      'assets/images/content/figma_discover_square_post_03_01.png',
      'assets/images/content/figma_discover_square_post_04_03.png',
    ],
  ),
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_05.png',
    imagePaths: [
      'assets/images/content/figma_discover_square_post_05_01.png',
      'assets/images/content/figma_discover_square_post_05_02.png',
      'assets/images/content/figma_discover_square_post_05_03.png',
      'assets/images/content/figma_discover_square_post_05_04.png',
      'assets/images/content/figma_discover_square_post_02_01.png',
    ],
  ),
  _FeedVisual(
    avatarPath: 'assets/images/content/figma_discover_square_avatar_06.png',
    imagePaths: [
      'assets/images/content/figma_discover_square_post_06_01.png',
      'assets/images/content/figma_discover_square_post_05_01.png',
      'assets/images/content/figma_discover_square_post_06_02.png',
      'assets/images/content/figma_discover_square_post_05_03.png',
      'assets/images/content/figma_discover_square_post_01_01.png',
      'assets/images/content/figma_discover_square_post_03_02.png',
    ],
  ),
];

String _shortTime(String value) {
  if (value.length >= 10) return value.substring(0, 10);
  return value;
}

String _copy({required String zh, required String en}) =>
    Get.locale?.languageCode == 'en' ? en : zh;
