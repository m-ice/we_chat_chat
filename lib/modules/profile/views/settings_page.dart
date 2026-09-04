import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import 'profile_design.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_settings'.tr,
    body: ListView(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      children: [
        InkWell(
          key: const ValueKey('settings-blacklist'),
          onTap: () => Get.toNamed(Routes.blacklist),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'profile_blacklist'.tr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const AppImage(
                    ProfileDetailAssets.chevronRight,
                    width: 10,
                    height: 18,
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
