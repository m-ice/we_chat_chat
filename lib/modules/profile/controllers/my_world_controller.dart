import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/my_world_post.dart';
import '../../../domain/repositories/my_world_repository.dart';

class MyWorldController extends GetxController {
  MyWorldController(this.repository);
  static const topics = ['旅行', '风景', '美食', '音乐', '运动', '日常', '休闲'];
  final MyWorldRepository repository;
  final posts = <MyWorldPost>[].obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() => posts.assignAll(repository.posts);

  Future<void> openPublish() async {
    await Get.toNamed(Routes.myWorldPublish);
    reload();
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
    final yes = await Get.dialog<bool>(
      AlertDialog(
        title: Text('world_delete_post'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
    if (yes == true) {
      await repository.remove(post.id);
      reload();
      AppToast.show('common_delete'.tr);
    }
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

  Future<void> publish() async {
    if (publishing.value) return;
    if (content.text.trim().isEmpty) {
      AppToast.show('world_content_required'.tr);
      return;
    }
    if (!agreed.value) {
      final accepted = await Get.dialog<bool>(
        AlertDialog(
          title: Text('common_tip'.tr),
          content: Text('legal_agreement_required'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('common_cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('common_done'.tr),
            ),
          ],
        ),
      );
      if (accepted != true) return;
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
        AppToast.show('world_content_required'.tr);
        return;
      }
      AppToast.show('world_publish_success'.tr);
      Get.back(result: true);
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
