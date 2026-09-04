import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../core/widgets/seed_content_badge.dart';
import '../../../domain/entities/city_user.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/video_feed_controller.dart';

/// The partner tab in the main navigation.
///
/// The vertical verified-video feed now lives under the Square page's Video
/// switch, matching the information architecture in the redesign.
class VideoFeedPage extends GetView<VideoFeedController> {
  const VideoFeedPage({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: ColoredBox(color: Colors.white)),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: 255,
        child: const AppImage(
          AppImageString.discoverHeaderBackground,
          fit: BoxFit.fill,
        ),
      ),
      SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PartnerHeader(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.users.isEmpty) {
                  return Center(
                    child: Text(
                      'common_no_data'.tr,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return AppRefreshView(
                  onRefresh: controller.reload,
                  child: GridView.builder(
                    key: ValueKey(controller.partnerTab.value),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 238,
                        ),
                    itemCount: controller.users.length,
                    itemBuilder: (_, index) => _PartnerTile(
                      key: ValueKey('partner-tile-$index'),
                      user: controller.users[index],
                      coverPath: _partnerCover(index),
                      onOpen: () =>
                          controller.openUser(controller.users[index]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ],
  );
}

class _PartnerHeader extends StatelessWidget {
  const _PartnerHeader({required this.controller});

  final VideoFeedController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      children: [
        const SizedBox(width: 16),
        _PartnerTabButton(
          tab: PartnerTab.recommended,
          label: 'square_recommended'.tr,
          controller: controller,
        ),
        const SizedBox(width: 20),
        _PartnerTabButton(
          tab: PartnerTab.nearby,
          label: 'home_nearby'.tr,
          controller: controller,
        ),
        const SizedBox(width: 20),
        _PartnerTabButton(
          tab: PartnerTab.newcomers,
          label: 'home_newcomers'.tr,
          controller: controller,
        ),
        const Spacer(),
        IconButton(
          tooltip: 'common_search'.tr,
          onPressed: () => Get.toNamed(Routes.centerSearch),
          icon: const AppImage(
            AppImageString.discoverSearch,
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

class _PartnerTabButton extends StatelessWidget {
  const _PartnerTabButton({
    required this.tab,
    required this.label,
    required this.controller,
  });

  final PartnerTab tab;
  final String label;
  final VideoFeedController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = controller.partnerTab.value == tab;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => controller.selectPartnerTab(tab),
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.textPrimary
                    : const Color(0xFF666666),
                fontSize: selected ? 17 : 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            SizedBox(
              width: 23,
              height: 8,
              child: selected
                  ? const AppImage(
                      AppImageString.discoverTabUnderline,
                      width: 23,
                      height: 8,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  });
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({
    super.key,
    required this.user,
    required this.coverPath,
    required this.onOpen,
  });

  final CityUser user;
  final String coverPath;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(coverPath, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xA6000000)],
                stops: [.48, 1],
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: user.isOnline
                          ? const Color(0xFF35DEA5)
                          : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    user.isOnline ? 'video_online'.tr : 'video_offline'.tr,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const AppImage(
                            AppImageString.discoverLocation,
                            width: 16,
                            height: 16,
                          ),
                          Flexible(
                            child: Text(
                              user.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xD9FFFFFF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 46),
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'user_chat'.tr,
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
          ),
        ],
      ),
    ),
  );
}

String _partnerCover(int index) => AppImageString.discoverPartnerCover(index);

/// Immersive video content embedded below the Square page's shared tab strip.
class SquareVideoPane extends GetView<VideoFeedController> {
  const SquareVideoPane({super.key});

  @override
  Widget build(BuildContext context) {
    final main = Get.find<MainController>();
    return ColoredBox(
      color: Colors.black,
      child: Obx(() {
        if (controller.videoUsers.isEmpty) {
          return Center(
            child: Text(
              'common_no_data'.tr,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }
        return Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                key: const ValueKey('square-video-feed'),
                scrollDirection: Axis.vertical,
                itemCount: controller.videoUsers.length,
                onPageChanged: controller.setIndex,
                itemBuilder: (_, index) => Obx(
                  () => _VideoItem(
                    user: controller.videoUsers[index],
                    active:
                        main.selectedIndex.value == 2 &&
                        controller.currentIndex.value == index,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class StandaloneVideoFeedPage extends StatefulWidget {
  const StandaloneVideoFeedPage({
    super.key,
    required this.users,
    required this.startIndex,
  });

  final List<CityUser> users;
  final int startIndex;

  @override
  State<StandaloneVideoFeedPage> createState() =>
      _StandaloneVideoFeedPageState();
}

class _StandaloneVideoFeedPageState extends State<StandaloneVideoFeedPage> {
  late final PageController pages = PageController(
    initialPage: widget.startIndex,
  );
  late int index = widget.startIndex;

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: pages,
            scrollDirection: Axis.vertical,
            itemCount: widget.users.length,
            onPageChanged: (value) => setState(() => index = value),
            itemBuilder: (_, item) =>
                _VideoItem(user: widget.users[item], active: index == item),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 16,
          child: IconButton.filledTonal(
            onPressed: Get.back,
            icon: const Icon(Icons.chevron_left),
          ),
        ),
      ],
    ),
  );
}

class _VideoItem extends StatefulWidget {
  const _VideoItem({required this.user, required this.active});

  final CityUser user;
  final bool active;

  @override
  State<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<_VideoItem> {
  VideoPlayerController? player;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.user.videoPath.isEmpty) {
      failed = true;
      return;
    }
    final value = VideoPlayerController.asset(widget.user.videoPath)
      ..setLooping(true);
    player = value;
    try {
      await value.initialize();
      if (widget.active) await value.play();
    } on Object {
      failed = true;
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active &&
        player?.value.isInitialized == true) {
      widget.active ? player!.play() : player!.pause();
    }
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (player?.value.isInitialized != true) return;
    player!.value.isPlaying ? player!.pause() : player!.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoFeedController>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!failed && player?.value.isInitialized == true)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: player!.value.size.width,
                height: player!.value.size.height,
                child: VideoPlayer(player!),
              ),
            )
          else
            AppImage(
              controller.coverPathFor(widget.user),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black12, Colors.transparent, Colors.black87],
                stops: [0, .48, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 72,
            bottom: 28,
            child: GestureDetector(
              onTap: () => controller.openUser(widget.user),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: AppImage(
                        controller.avatarPathFor(widget.user),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.user.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (widget.user.isSeedData) ...[
                              const SizedBox(width: 6),
                              const SeedContentBadge(compact: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.isRealPersonVerified
                              ? 'video_verified_intro'.trParams({
                                  'intro': widget.user.intro,
                                })
                              : widget.user.intro,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 82,
            child: Obx(
              () => Column(
                children: [
                  _Action(
                    assetPath: controller.likedIds.contains(widget.user.id)
                        ? AppImageString.videoUserLikeSelected
                        : AppImageString.videoUserLikeUnselected,
                    label: 'video_like'.tr,
                    onTap: () => controller.toggleLike(widget.user.id),
                  ),
                  _Action(
                    assetPath: controller.favoriteIds.contains(widget.user.id)
                        ? AppImageString.videoUserFavoriteSelected
                        : AppImageString.videoUserFavoriteUnselected,
                    label: 'video_favorite'.tr,
                    onTap: () => controller.toggleFavorite(widget.user.id),
                  ),
                  _Action(
                    assetPath: AppImageString.videoUserMore,
                    label: 'common_more'.tr,
                    onTap: () => controller.more(widget.user),
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

class _Action extends StatelessWidget {
  const _Action({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            AppImage(assetPath, width: 36, height: 36),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
