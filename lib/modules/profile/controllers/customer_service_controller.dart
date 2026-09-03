import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/repositories/support_repository.dart';

class CustomerServiceController extends GetxController {
  CustomerServiceController(this._repository);

  final SupportRepository _repository;
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final isSubmitting = false.obs;

  Future<void> refresh() async {
    // The current repository exposes a local delivery queue synchronously.
    // Keeping this boundary makes the screen refresh-ready when remote support
    // history becomes available without inventing UI-only records.
    _repository.queuedTickets;
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;
    final description = descriptionController.text.trim();
    final contact = contactController.text.trim();
    if (description.isEmpty) {
      AppToast.show('support_description_required'.tr);
      return false;
    }
    if (contact.isEmpty) {
      AppToast.show('support_contact_required'.tr);
      return false;
    }

    isSubmitting.value = true;
    try {
      await _repository.submit(
        title: '在线客服反馈',
        description: description,
        contact: contact,
      );
      descriptionController.clear();
      contactController.clear();
      AppToast.show('support_submitted'.tr);
      return true;
    } on Object {
      AppToast.show('保存失败，请稍后重试');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    contactController.dispose();
    super.onClose();
  }
}
