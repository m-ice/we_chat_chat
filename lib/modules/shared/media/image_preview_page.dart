import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/core/widgets/figma_back_button.dart';

class ImagePreviewPage extends StatefulWidget {
  const ImagePreviewPage({
    super.key,
    required this.images,
    required this.index,
  });

  final List<String> images;
  final int index;

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController pageController = PageController(
    initialPage: widget.index,
  );

  late int currentIndex = widget.index;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: PhotoViewGallery.builder(
                pageController: pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                itemCount: widget.images.length,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                builder: (context, index) {
                  final image = widget.images[index];

                  return PhotoViewGalleryPageOptions.customChild(
                    child: AppImage(image, fit: BoxFit.contain),
                    tightMode: true,

                    // 初始完整显示
                    initialScale: PhotoViewComputedScale.contained,

                    // 最小缩放
                    minScale: PhotoViewComputedScale.contained,

                    // 最大放大倍数
                    maxScale: PhotoViewComputedScale.covered * 3,

                    heroAttributes: PhotoViewHeroAttributes(tag: image),
                  );
                },
              ),
            ),

            // 顶部返回按钮 + 页码
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (widget.images.length > 1)
                        Center(
                          child: IgnorePointer(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '/${widget.images.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Positioned(
                        left: 0,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FigmaBackButton(iconColor: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
