import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/album_item.dart';
import '../../../domain/repositories/album_repository.dart';

class AlbumPreviewPage extends StatefulWidget {
  const AlbumPreviewPage({super.key, required this.item});
  final AlbumItem item;
  @override
  State<AlbumPreviewPage> createState() => _AlbumPreviewPageState();
}

class _AlbumPreviewPageState extends State<AlbumPreviewPage> {
  final repository = Get.find<AlbumRepository>();
  String? path;
  VideoPlayerController? player;
  Object? loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      path = await repository.fullPath(widget.item);
      if (widget.item.kind == AlbumMediaKind.video) {
        player = VideoPlayerController.file(File(path!));
        await player!.initialize();
        await player!.play();
      }
    } on Object catch (error) {
      loadError = error;
    }
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final video = player;
    if (video == null || !video.value.isInitialized) return;
    video.value.isPlaying ? await video.pause() : await video.play();
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final yes = await AppDialog.confirm(
      title: 'album_delete_content'.tr,
      confirmText: 'common_delete'.tr,
      isDangerous: true,
    );
    if (yes) {
      await repository.remove({widget.item.id}, widget.item.kind);
      AppToast.show('common_deleted'.tr);
      Get.back();
    }
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text('common_preview'.tr),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      actions: [
        TextButton(
          onPressed: _delete,
          child: Text(
            'common_delete'.tr,
            style: const TextStyle(color: AppColors.accentYellow),
          ),
        ),
        const SizedBox(width: 6),
      ],
    ),
    backgroundColor: Colors.black,
    body: loadError != null
        ? Center(
            child: Text(
              'common_no_data'.tr,
              style: const TextStyle(color: Colors.white70),
            ),
          )
        : path == null
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.accentYellow),
          )
        : widget.item.kind == AlbumMediaKind.photo
        ? InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: AppImage(
                path!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayback,
            child: Center(
              child: player?.value.isInitialized == true
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: player!.value.aspectRatio,
                          child: VideoPlayer(player!),
                        ),
                        if (player?.value.isPlaying == false)
                          const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 54,
                          ),
                      ],
                    )
                  : const CircularProgressIndicator(
                      color: AppColors.accentYellow,
                    ),
            ),
          ),
  );
}
