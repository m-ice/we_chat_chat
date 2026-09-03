import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/verification_controller.dart';

class VerificationPage extends GetView<VerificationController> {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('profile_verification'.tr)),
    body: Obx(() => controller.pending.value ? const _Pending() : _form()),
  );

  Widget _form() => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field(
                    'verify_real_name'.tr,
                    'verify_real_name_hint'.tr,
                    controller.name,
                  ),
                  _field(
                    'verify_id_number'.tr,
                    'verify_id_number_hint'.tr,
                    controller.idNumber,
                  ),
                  _field(
                    'verify_phone'.tr,
                    'verify_phone_hint'.tr,
                    controller.phone,
                    phone: true,
                  ),
                  Text(
                    'verify_id_photo'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => _Upload(
                      path: controller.idCardPath.value,
                      placeholder: 'verify_id_photo_upload'.tr,
                      onTap: () => controller.pick(handheld: false),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'verify_handheld_photo'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => _Upload(
                      path: controller.handheldPath.value,
                      placeholder: 'verify_handheld_photo_upload'.tr,
                      onTap: () => controller.pick(handheld: true),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: controller.submit,
              child: Text('verify_submit'.tr),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _field(
    String title,
    String hint,
    TextEditingController field, {
    bool phone = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: field,
          keyboardType: phone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
          ),
        ),
      ],
    ),
  );
}

class _Upload extends StatelessWidget {
  const _Upload({
    required this.path,
    required this.placeholder,
    required this.onTap,
  });
  final String? path;
  final String placeholder;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 160,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: path == null
          ? Center(
              child: Text(
                placeholder,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Image.file(File(path!), fit: BoxFit.cover),
    ),
  );
}

class _Pending extends StatelessWidget {
  const _Pending();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 80, 28, 0),
    child: Column(
      children: [
        const Icon(
          Icons.pending_actions,
          size: 88,
          color: AppColors.accentYellow,
        ),
        const SizedBox(height: 28),
        Text(
          'verify_pending_title'.tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'verify_pending_body'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}
