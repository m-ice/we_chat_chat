import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import 'report_controller.dart';

class ReportPage extends GetView<ReportController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppImage(
              AppImageString.videoUserReportHeader,
              height: 255,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          iconSize: 20,
                        ),
                      ),
                      Text(
                        'common_report'.tr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF1F1F1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'report_problem_description'.tr,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 142,
                              child: TextField(
                                key: const ValueKey('report-details'),
                                controller: controller.details,
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                maxLength: 300,
                                textAlignVertical: TextAlignVertical.top,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  hintText: 'report_details_hint'.tr,
                                  hintMaxLines: 3,
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFFF4F4F4),
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        key: const ValueKey('report-submit'),
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentYellow,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'report_submit_feedback'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
