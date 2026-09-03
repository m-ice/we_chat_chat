import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_page.dart';
import '../controllers/topic_detail_controller.dart';

class TopicDetailPage extends GetView<TopicDetailController> {
  const TopicDetailPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('#${controller.topic.id.tr}')),
    body: Obx(
      () => controller.users.isEmpty
          ? Center(
              child: Text(
                'topic_empty'.tr,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              itemCount: controller.users.length,
              itemBuilder: (_, index) {
                final user = controller.users[index];
                return ActivityCard(
                  user: user,
                  isPendingJoin: controller.social.pendingJoinIds.contains(
                    user.id,
                  ),
                  onJoin: () => controller.join(user),
                  onOpen: () async {
                    await Get.toNamed(Routes.teamDetail, arguments: user);
                    controller.refreshState();
                  },
                );
              },
            ),
    ),
  );
}
