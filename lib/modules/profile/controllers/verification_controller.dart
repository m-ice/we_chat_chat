import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/repositories/verification_repository.dart';

class VerificationController extends GetxController {
  VerificationController(this._repository);
  final VerificationRepository _repository;
  final name = TextEditingController();
  final idNumber = TextEditingController();
  final phone = TextEditingController();
  final idCardPath = RxnString();
  final handheldPath = RxnString();
  final pending = false.obs;

  @override
  void onInit() {
    super.onInit();
    pending.value = _repository.isPending;
  }

  Future<void> pick({required bool handheld}) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    (handheld ? handheldPath : idCardPath).value = file.path;
  }

  Future<void> submit() async {
    if (name.text.trim().isEmpty) return _message('verify_name_required'.tr);
    if (idNumber.text.trim().isEmpty) return _message('verify_id_required'.tr);
    if (phone.text.trim().isEmpty) return _message('verify_phone_required'.tr);
    if (idCardPath.value == null) {
      return _message('verify_id_photo_required'.tr);
    }
    if (handheldPath.value == null) {
      return _message('verify_handheld_required'.tr);
    }
    final ok = await _repository.submit(
      realName: name.text,
      idNumber: idNumber.text,
      phone: phone.text,
      idCardSourcePath: idCardPath.value!,
      handheldSourcePath: handheldPath.value!,
    );
    if (!ok) return _message('verify_submit_failed'.tr);
    pending.value = true;
    _message('verify_submit_success'.tr);
  }

  void _message(String text) => AppToast.show(text);

  @override
  void onClose() {
    name.dispose();
    idNumber.dispose();
    phone.dispose();
    super.onClose();
  }
}
