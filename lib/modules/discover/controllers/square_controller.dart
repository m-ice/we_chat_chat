import 'dart:async';

import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/square_feed.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/square_repository.dart';

enum SquareTab { following, discover, video }

class SquareController extends GetxController {
  SquareController(this.repository, this.social);
  final SquareRepository repository;
  final SocialStateRepository social;
  final tab = SquareTab.discover.obs;
  final items = <SquareFeedItem>[].obs;
  final likedIds = <String>{}.obs;
  final floatingActionEvents = StreamController<OperateEvent>.broadcast();

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  @override
  void onClose() {
    floatingActionEvents.close();
    super.onClose();
  }

  Future<void> reload() async {
    items.assignAll(
      tab.value == SquareTab.following
          ? await repository.following()
          : await repository.recommended(),
    );
    likedIds.assignAll(repository.likedPostIds);
  }

  Future<void> selectTab(SquareTab value) async {
    tab.value = value;
    if (value != SquareTab.video) await reload();
  }

  Future<void> toggleFollow(SquareFeedItem item) async {
    final value = !social.followedIds.contains(item.user.id);
    await social.setFollowed(item.user.id, value);
    await reload();
    AppToast.show(value ? 'social_followed'.tr : 'social_unfollowed'.tr);
  }

  Future<void> openUser(SquareFeedItem item) async {
    await Get.toNamed(Routes.userDetail, arguments: item.user);
  }

  Future<void> toggleLike(SquareFeedItem item) async {
    final liked = !likedIds.contains(item.postId);
    await repository.setLiked(item.postId, liked);
    likedIds.assignAll(repository.likedPostIds);
    AppToast.show(liked ? 'video_liked'.tr : 'video_unliked'.tr);
  }

  Future<void> preview(SquareFeedItem item, int index) async {
    final images = await repository.resolvedImages(item);
    if (images.isNotEmpty) {
      await Get.toNamed(
        Routes.imagePreview,
        arguments: {'images': images, 'index': index},
      );
    }
  }

  Future<void> previewAssets(List<String> images, int index) async {
    if (images.isEmpty) return;
    await Get.toNamed(
      Routes.imagePreview,
      arguments: {'images': images, 'index': index},
    );
  }

  Future<void> publish() async {
    await Get.toNamed(Routes.myWorldPublish);
    await reload();
  }

  Future<void> more(SquareFeedItem item) async {
    await Get.bottomSheet<void>(
      SafeArea(
        child: Wrap(
          children: [
            if (item.user.id != 2)
              ListTile(
                title: Text(
                  social.followedIds.contains(item.user.id)
                      ? 'home_following'.tr
                      : 'home_follow'.tr,
                ),
                onTap: () async {
                  Get.back<void>();
                  await toggleFollow(item);
                },
              ),
            ListTile(
              title: Text('common_report'.tr),
              onTap: () {
                Get.back<void>();
                Get.toNamed(Routes.report, arguments: item.user);
              },
            ),
            ListTile(
              title: Text('common_block'.tr),
              textColor: Colors.red,
              onTap: () async {
                Get.back<void>();
                await social.block(item.user.id);
                await reload();
                AppToast.show(
                  'social_blocked'.trParams({'name': item.user.nickname}),
                );
              },
            ),
            ListTile(
              title: Text('common_shield'.tr),
              textColor: Colors.red,
              onTap: () async {
                Get.back<void>();
                await social.shield(item.user.id);
                await reload();
                AppToast.show(
                  'social_shielded'.trParams({'name': item.user.nickname}),
                );
              },
            ),
            ListTile(title: Text('common_cancel'.tr), onTap: Get.back),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
