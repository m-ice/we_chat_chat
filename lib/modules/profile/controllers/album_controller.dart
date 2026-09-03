import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/album_item.dart';
import '../../../domain/repositories/album_repository.dart';

class AlbumController extends GetxController {
  AlbumController(this.repository);
  final AlbumRepository repository;
  final kind = AlbumMediaKind.photo.obs;
  final items = <AlbumItem>[].obs;
  final editing = false.obs;
  final selectedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    items.assignAll(
      kind.value == AlbumMediaKind.photo
          ? repository.photos
          : repository.videos,
    );
    selectedIds.clear();
  }

  void selectKind(AlbumMediaKind value) {
    kind.value = value;
    reload();
  }

  void toggleEditing() {
    editing.toggle();
    selectedIds.clear();
  }

  void toggle(String id) {
    final next = Set<String>.from(selectedIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    selectedIds.assignAll(next);
  }

  Future<void> importMedia() async {
    final picker = ImagePicker();
    final files = kind.value == AlbumMediaKind.photo
        ? await picker.pickMultiImage()
        : await picker.pickMultipleMedia();
    final selected = kind.value == AlbumMediaKind.video
        ? files
              .where(
                (file) =>
                    file.mimeType?.startsWith('video/') ??
                    file.path.toLowerCase().endsWith('.mp4'),
              )
              .toList()
        : files;
    final count = await repository.importFiles(
      selected.map((file) => file.path).toList(),
      kind.value,
    );
    if (count > 0) {
      reload();
      AppToast.show('album_upload_success'.tr);
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;
    final yes = await Get.dialog<bool>(
      AlertDialog(
        title: Text('album_delete_selected_confirm'.tr),
        content: Text(
          'album_selected_count'.trParams({'count': '${selectedIds.length}'}),
        ),
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
    if (yes != true) return;
    await repository.remove(Set.of(selectedIds), kind.value);
    reload();
    editing.value = false;
    AppToast.show('common_delete'.tr);
  }
}
