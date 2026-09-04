import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_page.dart';
import '../../chat/views/conversation_page.dart';
import '../../profile/views/profile_page.dart';
import '../../discover/views/square_page.dart';
import '../../discover/views/video_feed_page.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  static const _normalIcons = AppImageString.tabBarIcons;
  static const _selectedIcons = AppImageString.tabBarSelectedIcons;
  static const _labels = [
    'tab_home',
    'tab_partner',
    'tab_square',
    'tab_messages',
    'tab_profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.ageConfirmed.value) {
        return _AgeGate(onConfirm: controller.confirmAdult);
      }
      final index = controller.selectedIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            HomePage(),
            VideoFeedPage(),
            SquarePage(),
            ConversationPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: ColoredBox(
          color: AppColors.cardBackground,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: List.generate(5, (tabIndex) {
                  final selected = tabIndex == index;
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      child: InkWell(
                        key: ValueKey('main-tab-$tabIndex'),
                        onTap: () => controller.selectTab(tabIndex),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7, bottom: 3),
                          child: Column(
                            children: [
                              AppImage(
                                selected
                                    ? _selectedIcons[tabIndex]
                                    : _normalIcons[tabIndex],
                                width: 28,
                                height: 28,
                                filterQuality: FilterQuality.high,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labels[tabIndex].tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _AgeGate extends StatelessWidget {
  const _AgeGate({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFAEB),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.accentYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '18+',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'age_gate_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'age_gate_description'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed(
                      Routes.legal,
                      arguments: {
                        'title': 'legal_user_agreement'.tr,
                        'assetPath': 'assets/legal/user_agreement.html',
                      },
                    ),
                    child: Text('legal_user_agreement'.tr),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(
                      Routes.legal,
                      arguments: {
                        'title': 'legal_privacy'.tr,
                        'assetPath': 'assets/legal/privacy_policy.html',
                      },
                    ),
                    child: Text('legal_privacy'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: AppColors.textPrimary,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'age_gate_confirm'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
