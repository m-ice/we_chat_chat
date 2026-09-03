import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/repositories/support_repository.dart';
import '../controllers/customer_service_controller.dart';
import 'profile_design.dart';

class CustomerServicePage extends StatefulWidget {
  const CustomerServicePage({super.key});

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  late final String _controllerTag;
  late final CustomerServiceController controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'figma-customer-service-${identityHashCode(this)}';
    controller = Get.put(
      CustomerServiceController(Get.find<SupportRepository>()),
      tag: _controllerTag,
    );
  }

  Future<void> submit() async {
    final submitted = await controller.submit();
    if (submitted && mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    Get.delete<CustomerServiceController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: '在线客服',
    resizeToAvoidBottomInset: true,
    body: Column(
      children: [
        Expanded(
          child: AppRefreshView(
            onRefresh: controller.refresh,
            child: ListView(
              key: const ValueKey('customer-service-form-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
                      _Field(
                        fieldKey: const ValueKey(
                          'customer-service-description',
                        ),
                        title: 'support_description'.tr,
                        hint: 'support_description_hint'.tr,
                        controller: controller.descriptionController,
                        minHeight: 142,
                        minLines: 5,
                        maxLines: 8,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        fieldKey: const ValueKey('customer-service-contact'),
                        title: 'support_contact'.tr,
                        hint: 'support_contact_hint'.tr,
                        controller: controller.contactController,
                        minHeight: 48,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Obx(
              () => ProfilePrimaryButton(
                key: const ValueKey('customer-service-submit'),
                label: controller.isSubmitting.value
                    ? '正在提交…'
                    : 'support_submit'.tr,
                onPressed: controller.isSubmitting.value ? null : submit,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.fieldKey,
    required this.title,
    required this.hint,
    required this.controller,
    required this.minHeight,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  final Key fieldKey;
  final String title;
  final String hint;
  final TextEditingController controller;
  final double minHeight;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      ),
      const SizedBox(height: 8),
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: TextField(
          key: fieldKey,
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: maxLines == 1
              ? TextInputAction.done
              : TextInputAction.newline,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            height: 1.35,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintMaxLines: maxLines,
            hintStyle: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 16,
              height: 1.35,
            ),
            filled: true,
            fillColor: profileFieldBackground,
            contentPadding: const EdgeInsets.all(12),
            constraints: BoxConstraints(minHeight: minHeight),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFCE45)),
            ),
          ),
        ),
      ),
    ],
  );
}
