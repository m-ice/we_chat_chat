import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/user.dart';
import '../controllers/blacklist_controller.dart';
import 'profile_design.dart';

class BlacklistPage extends GetView<BlacklistController> {
  const BlacklistPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_blacklist'.tr,
    body: Obx(() {
      if (controller.isLoading.value && controller.blockedUsers.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        );
      }
      if (controller.hasError.value && controller.blockedUsers.isEmpty) {
        return Center(
          child: TextButton.icon(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('refresh_failed'.tr),
          ),
        );
      }
      return AppRefreshView(
        onRefresh: controller.load,
        child: controller.blockedUsers.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 96),
                  Center(
                    child: Text(
                      'blacklist_empty'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 39, bottom: 32),
                itemCount: controller.blockedUsers.length,
                separatorBuilder: (_, _) => const SizedBox.shrink(),
                itemBuilder: (_, index) => _BlockedUserRow(
                  user: controller.blockedUsers[index],
                  onRemove: () =>
                      controller.remove(controller.blockedUsers[index]),
                ),
              ),
      );
    }),
  );
}

class _BlockedUserRow extends StatelessWidget {
  const _BlockedUserRow({required this.user, required this.onRemove});

  final User user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey('blacklist-user-${user.id}'),
    height: 74,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: AppImage(
              user.avatarPath,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text(
                user.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: SizedBox(
              width: 94,
              height: 34,
              child: OutlinedButton(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF3848C),
                  side: const BorderSide(color: Color(0xFFFFD8DB)),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                child: Text('blacklist_remove'.tr),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
