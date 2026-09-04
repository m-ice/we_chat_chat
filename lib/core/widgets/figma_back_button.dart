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
  Widget build(BuildContext context) => IconButton(
    onPressed: Get.back,
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    icon: Center(
      child: AppImage(
        AppImageString.chatBack,
        width: 10.w,
        color: iconColor,
      ),
    ),
  );
}
