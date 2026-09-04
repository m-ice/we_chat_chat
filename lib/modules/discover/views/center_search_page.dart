import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../profile/views/profile_design.dart';
import '../controllers/video_feed_controller.dart';

class CenterSearchPage extends GetView<CenterSearchController> {
  const CenterSearchPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'common_search'.tr,
    body: Column(
      children: [
        Container(
          height: 56,
          margin: const EdgeInsets.fromLTRB(16, 13, 16, 12),
          padding: const EdgeInsets.fromLTRB(15, 9, 15, 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              const AppImage(
                AppImageString.profileEditSearch,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const ValueKey('center-search-field'),
                  controller: controller.query,
                  onChanged: controller.search,
                  onSubmitted: controller.search,
                  textInputAction: TextInputAction.search,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: 'center_search_short_hint'.tr,
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFCCCCCC),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 62,
                height: 38,
                child: FilledButton(
                  key: const ValueKey('center-search-submit'),
                  onPressed: () => controller.search(controller.query.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('common_search'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final hasQuery = controller.query.text.trim().isNotEmpty;
            final results = controller.results.toList(growable: false);
            return AppRefreshView(
              onRefresh: () => Future<void>.sync(
                () => controller.search(controller.query.text),
              ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: results.isEmpty && hasQuery ? 1 : results.length,
                itemBuilder: (_, index) {
                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 72),
                      child: Center(
                        child: Text(
                          'common_no_data'.tr,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  final user = results[index];
                  return Container(
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: ClipOval(
                        child: AppImage(
                          user.avatarPath,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        user.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${user.city} · ${'user_age'.trParams({'age': '${user.age}'})} · ${user.intent}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => Get.toNamed(
                        Routes.videoFeed,
                        arguments: {'users': results, 'index': index},
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    ),
  );
}
