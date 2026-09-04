import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class ReportArguments {
  const ReportArguments({
    required this.target,
    this.targetActivityId,
    this.targetDynamicId,
  });

  final User target;
  final String? targetActivityId;
  final String? targetDynamicId;
}

class ReportController extends GetxController {
  ReportController(
    this.target,
    this._repository, {
    required UserRepository users,
    this.targetActivityId,
    this.targetDynamicId,
  }) : _users = users;

  final User target;
  final ReportRepository _repository;
  final UserRepository _users;
  final String? targetActivityId;
  final String? targetDynamicId;
  final details = TextEditingController();
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (await _isCurrentUser()) return;
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
        targetActivityId: targetActivityId,
        targetDynamicId: targetDynamicId,
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

  Future<bool> _isCurrentUser() async {
    try {
      return (await _users.getCurrentUser()).id == target.id;
    } on Object {
      // Reporting is a destructive operation; require a confirmed identity.
      return true;
    }
  }

  @override
  void onClose() {
    details.dispose();
    super.onClose();
  }
}
