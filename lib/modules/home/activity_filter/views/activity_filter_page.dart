import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../views/home_page.dart';
import '../controllers/activity_filter_controller.dart';

class ActivityFilterPage extends StatefulWidget {
  const ActivityFilterPage({super.key});

  @override
  State<ActivityFilterPage> createState() => _ActivityFilterPageState();
}

class _ActivityFilterPageState extends State<ActivityFilterPage> {
  final controller = Get.find<ActivityFilterController>();
  final field = TextEditingController();

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        title: Text('activity_filter_title'.tr),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'activity_filter_keyword'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: field,
                    onChanged: controller.search,
                    onSubmitted: (_) => Get.back(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'activity_filter_hint'.tr,
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.hasError.value) {
                  return Center(child: Text('home_load_failed'.tr));
                }
                if (controller.keyword.isNotEmpty &&
                    controller.results.isEmpty) {
                  return Center(child: Text('common_no_data'.tr));
                }
                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: controller.results.length,
                  itemBuilder: (context, index) => ActivityCard(
                    user: controller.results[index],
                    onJoin: () => controller.join(controller.results[index]),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          field.clear();
                          controller.search('');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: Text('common_reset'.tr),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: Get.back,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentYellow,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: Text('common_confirm'.tr),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
