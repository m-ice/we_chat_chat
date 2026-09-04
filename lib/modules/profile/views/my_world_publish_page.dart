import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_image.dart';
import '../../home/team_publish/team_flow_assets.dart';
import '../controllers/my_world_controller.dart';
import 'profile_design.dart';

class MyWorldPublishPage extends GetView<MyWorldPublishController> {
  const MyWorldPublishPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'world_publish'.tr,
    resizeToAvoidBottomInset: true,
    actions: [
      Obx(
        () => ProfileAppBarAction(
          label: 'common_publish'.tr,
          onPressed: controller.publishing.value ? null : (){
            controller.publish(context);
          },
        ),
      ),
    ],
    body: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ProfilePanel(
          key: const ValueKey('my-world-publish-panel'),
          radius: 20,
          child: SizedBox(
            height: 325,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('my-world-publish-content'),
                      controller: controller.content,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Color(0xFF333333),
                      ),
                      decoration: InputDecoration(
                        hintText: 'world_content_hint'.tr,
                        hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerLeft,
                      child: _ImageStrip(
                        paths: controller.imagePaths.toList(),
                        onPick: controller.pickImages,
                        onRemove: controller.imagePaths.removeAt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ImageStrip extends StatelessWidget {
  const _ImageStrip({
    required this.paths,
    required this.onPick,
    required this.onRemove,
  });

  final List<String> paths;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth - gap * 2) / 3;
        final visiblePaths = paths.take(3).toList(growable: false);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < visiblePaths.length; index++)
              _SelectedImage(
                path: visiblePaths[index],
                size: size,
                onRemove: () => onRemove(index),
              ),
            if (visiblePaths.length < 3) _PickImage(size: size, onTap: onPick),
          ],
        );
      },
    );
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    required this.path,
    required this.size,
    required this.onRemove,
  });

  final String path;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: 118,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AppImage(path, fit: BoxFit.cover),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Material(
              color: const Color(0x99000000),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(Icons.close, size: 15, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _PickImage extends StatelessWidget {
  const _PickImage({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: profileFieldBackground,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: size,
        height: 118,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppImage(TeamFlowAssets.addPhotoIcon, width: 24, height: 24),
            const SizedBox(height: 6),
            Text(
              'team_choose_photo'.tr,
              style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
            ),
          ],
        ),
      ),
    ),
  );
}
