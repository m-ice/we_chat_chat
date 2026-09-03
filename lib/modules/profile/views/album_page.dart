import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/album_item.dart';
import '../controllers/album_controller.dart';
import 'profile_design.dart';

class AlbumPage extends GetView<AlbumController> {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => ProfileDecoratedScaffold(
      title: 'profile_album'.tr,
      actions: controller.editing.value
          ? [
              ProfileAppBarAction(
                label: 'common_done'.tr,
                onPressed: controller.toggleEditing,
              ),
            ]
          : null,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ProfilePanel(
                  child: AppRefreshView(
                    onRefresh: () async => controller.reload(),
                    child: _AlbumGrid(
                      items: controller.items.toList(growable: false),
                      editing: controller.editing.value,
                      selectedIds: controller.selectedIds,
                      onImport: controller.importMedia,
                      onLongPress: controller.toggleEditing,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (controller.editing.value)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ProfilePrimaryButton(
                  label: controller.selectedIds.isEmpty
                      ? 'common_delete'.tr
                      : 'album_delete_selected'.trParams({
                          'count': '${controller.selectedIds.length}',
                        }),
                  onPressed: controller.selectedIds.isEmpty
                      ? null
                      : controller.deleteSelected,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _AlbumGrid extends GetView<AlbumController> {
  const _AlbumGrid({
    required this.items,
    required this.editing,
    required this.selectedIds,
    required this.onImport,
    required this.onLongPress,
  });

  final List<AlbumItem> items;
  final bool editing;
  final Set<String> selectedIds;
  final VoidCallback onImport;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 98 / 119,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _Upload(
            label: controller.kind.value == AlbumMediaKind.photo
                ? 'album_select_photo'.tr
                : 'album_select_video'.tr,
            onTap: editing ? null : onImport,
          );
        }
        final item = items[index];
        return FutureBuilder<String>(
          future: controller.repository.fullPath(item),
          builder: (context, snapshot) => _AlbumPhoto(
            source: snapshot.data,
            video: item.kind == AlbumMediaKind.video,
            selected: selectedIds.contains(item.id),
            editing: editing,
            onLongPress: onLongPress,
            onTap: () async {
              if (editing) {
                controller.toggle(item.id);
                return;
              }
              await Get.toNamed(Routes.albumPreview, arguments: item);
              controller.reload();
            },
          ),
        );
      },
    );
  }
}

class _AlbumPhoto extends StatelessWidget {
  const _AlbumPhoto({
    required this.source,
    required this.onTap,
    required this.onLongPress,
    this.video = false,
    this.editing = false,
    this.selected = false,
  });

  final String? source;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool video;
  final bool editing;
  final bool selected;

  @override
  Widget build(BuildContext context) => Material(
    color: profileFieldBackground,
    borderRadius: BorderRadius.circular(15),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (source == null)
            const Center(child: CircularProgressIndicator())
          else if (video)
            const ColoredBox(
              color: Colors.black87,
              child: Icon(Icons.play_circle, color: Colors.white, size: 38),
            )
          else
            AppImage(source!, fit: BoxFit.cover),
          if (editing)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? const Color(0xFFFFCE45) : Colors.white,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Upload extends StatelessWidget {
  const _Upload({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: profileFieldBackground,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: onTap == null ? .45 : 1,
            child: const AppImage(
              'assets/icons/profile_edit/album_add.svg',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    ),
  );
}
