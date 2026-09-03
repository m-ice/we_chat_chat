import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late final PageController pages = PageController(initialPage: widget.index);
  late int index = widget.index;

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: pages,
            onPageChanged: (value) => setState(() => index = value),
            itemCount: widget.images.length,
            itemBuilder: (_, item) => InteractiveViewer(
              child: Center(
                child: File(widget.images[item]).existsSync()
                    ? Image.file(File(widget.images[item]), fit: BoxFit.contain)
                    : Image.asset(widget.images[item], fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: IconButton.filledTonal(
              onPressed: Get.back,
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            left: 0,
            right: 0,
            child: Text(
              '${index + 1}/${widget.images.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
