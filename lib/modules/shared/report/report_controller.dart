import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/report_repository.dart';

class ReportController extends GetxController {
  ReportController(this.target, this._repository);

  final User target;
  final ReportRepository _repository;
  final details = TextEditingController();
  final isSubmitting = false.obs;

  Future<void> submit() async {
    final description = details.text.trim();
    if (description.isEmpty) {
      AppToast.show('report_details_required'.tr);
      return;
    }
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      await _repository.submit(
        targetUserId: target.id,
        reason: '其他',
        details: description,
      );
      AppToast.show('report_queued_locally'.tr);
      Get.back<void>();
    } on Object {
      AppToast.show('support_save_failed'.tr);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    details.dispose();
    super.onClose();
  }
}
