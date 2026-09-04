import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../home/views/home_page.dart';
import '../controllers/topic_detail_controller.dart';

class TopicDetailPage extends GetView<TopicDetailController> {
  const TopicDetailPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('#${controller.topic.id.tr}')),
    body: Obx(
      () => AppRefreshView(
        onRefresh: controller.reload,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.users.isEmpty ? 1 : controller.users.length,
          itemBuilder: (_, index) {
            if (controller.users.isEmpty) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height * .62,
                child: Center(
                  child: Text(
                    'topic_empty'.tr,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            final user = controller.users[index];
            return ActivityCard(
              user: user,
              isPendingJoin: controller.social.pendingJoinIds.contains(user.id),
              onJoin: () => controller.join(user),
              onOpen: () async {
                await controller.openActivity(user);
                controller.refreshState();
              },
            );
          },
        ),
      ),
    ),
  );
}
