import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/core/vaules/app_image_string.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';

/// Shared Figma-exported navigation affordance for Phase 2 routes.
class FigmaBackButton extends StatelessWidget {
  final Color? iconColor;
  const FigmaBackButton({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '返回',
    child: InkResponse(
      onTap: Get.back,
      radius: 24.r,
      child: SizedBox(
        width: 48.w,
        height: 48.w,
        child: Center(
          child: AppImage(
            AppImageString.chatBack,
            height: 24.w,
            color: iconColor,
          ),
        ),
      ),
    ),
  );
}
