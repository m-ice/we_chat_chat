import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/album_item.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class AlbumController extends GetxController {
  AlbumController(this.repository, this._users);
  final AlbumRepository repository;
  final UserRepository _users;
  final kind = AlbumMediaKind.photo.obs;
  final items = <AlbumItem>[].obs;
  final editing = false.obs;
  final selectedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    if (kind.value == AlbumMediaKind.photo) {
      final user = await _users.getCurrentUser();
      items.assignAll(
        await repository.profilePhotos(
          userId: user.id,
          seedPhotoPaths: user.galleryImagePaths,
          avatarPath: user.avatarPath,
        ),
      );
    } else {
      items.assignAll(repository.videos);
    }
    selectedIds.clear();
  }

  void selectKind(AlbumMediaKind value) {
    kind.value = value;
    unawaited(reload());
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
      await reload();
      AppToast.show('album_upload_success'.tr);
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;
    final yes = await AppDialog.confirm(
      title: 'album_delete_selected_confirm'.tr,
      message: 'album_selected_count'.trParams({
        'count': '${selectedIds.length}',
      }),
      confirmText: 'common_delete'.tr,
      isDangerous: true,
    );
    if (!yes) return;
    if (kind.value == AlbumMediaKind.photo) {
      final user = await _users.getCurrentUser();
      await repository.removeProfilePhotos(
        userId: user.id,
        ids: Set.of(selectedIds),
      );
    } else {
      await repository.remove(Set.of(selectedIds), kind.value);
    }
    await reload();
    editing.value = false;
    AppToast.show('common_deleted'.tr);
  }
}
