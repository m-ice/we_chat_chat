import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_legal_agreement_confirmation.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_input_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/my_world_post.dart';
import '../../../domain/repositories/my_world_repository.dart';

class MyWorldController extends GetxController {
  MyWorldController(this.repository);
  static const topics = ['旅行', '风景', '美食', '音乐', '运动', '日常', '休闲'];
  final MyWorldRepository repository;
  final posts = <MyWorldPost>[].obs;
  Timer? _reviewTimer;

  @override
  void onInit() {
    super.onInit();
    reload();
    _reviewTimer = Timer.periodic(const Duration(minutes: 1), (_) => reload());
  }

  Future<void> reload() async {
    await repository.refreshReviewStatuses();
    posts.assignAll(repository.posts);
  }

  Future<void> openPublish() async {
    await Get.toNamed(Routes.myWorldPublish);
    await reload();
  }

  Future<void> preview(MyWorldPost post, int index) async {
    final paths = await repository.fullImagePaths(post);
    if (paths.isNotEmpty) {
      await Get.toNamed(
        Routes.imagePreview,
        arguments: {'images': paths, 'index': index},
      );
    }
  }

  Future<void> remove(MyWorldPost post) async {
    final yes = await AppDialog.confirm(
      title: 'world_delete_post'.tr,
      confirmText: 'common_delete'.tr,
      isDangerous: true,
    );
    if (yes) {
      await repository.remove(post.id);
      reload();
      AppToast.show('common_deleted'.tr);
    }
  }

  Future<void> toggleLike(MyWorldPost post) async {
    await repository.setLiked(post.id, !post.isLiked);
    reload();
    AppToast.show(post.isLiked ? 'video_unliked'.tr : 'video_liked'.tr);
  }

  Future<void> comment(MyWorldPost post) async {
    final value = await AppTextInputDialog.show(
      title: 'world_comment_title'.tr,
      hint: 'world_comment_hint'.tr,
      confirmText: 'common_submit'.tr,
      minLines: 2,
      maxLines: 4,
      maxLength: 200,
    );
    final content = value?.trim();
    if (content == null || content.isEmpty) return;
    await repository.addComment(post.id, content);
    reload();
    AppToast.show('world_comment_saved'.tr);
  }

  @override
  void onClose() {
    _reviewTimer?.cancel();
    super.onClose();
  }
}

class MyWorldPublishController extends GetxController {
  MyWorldPublishController(this.repository);
  final MyWorldRepository repository;
  final content = TextEditingController();
  final imagePaths = <String>[].obs;
  final selectedTopics = <String>{}.obs;
  final agreed = false.obs;
  final publishing = false.obs;

  Future<void> pickImages() async {
    final remain = 3 - imagePaths.length;
    if (remain <= 0) {
      AppToast.show('world_max_images'.tr);
      return;
    }
    final files = await ImagePicker().pickMultiImage(limit: remain);
    imagePaths.addAll(files.take(remain).map((file) => file.path));
  }

  void toggleTopic(String topic) {
    final next = Set<String>.from(selectedTopics);
    next.contains(topic) ? next.remove(topic) : next.add(topic);
    selectedTopics.assignAll(next);
  }

  Future<void> publish(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (publishing.value) return;
    if (content.text.trim().isEmpty) {
      AppToast.show('world_content_required'.tr);
      return;
    }
    if (!agreed.value) {
      final accepted = await AppLegalAgreementConfirmation.show();
      if (!accepted) return;
      agreed.value = true;
    }
    publishing.value = true;
    try {
      final ok = await repository.publish(
        content: content.text,
        imageSourcePaths: imagePaths,
        topics: selectedTopics.toList(),
      );
      if (!ok) {
        AppToast.show('team_publish_failed'.tr);
        return;
      }
      AppToast.show('world_publish_success'.tr);
      Get.back(result: true);
    } on Object {
      AppToast.show('team_publish_failed'.tr);
    } finally {
      publishing.value = false;
    }
  }

  @override
  void onClose() {
    content.dispose();
    super.onClose();
  }
}
