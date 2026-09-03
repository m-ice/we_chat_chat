import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/store_product.dart';
import '../controllers/vip_controller.dart';
import 'profile_design.dart';

class VipPage extends GetView<VipController> {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_vip'.tr,
    actions: [
      TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        onPressed: controller.restore,
        child: Text('vip_restore'.tr),
      ),
    ],
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              ProfilePanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withValues(alpha: .22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        color: Color(0xFFE0A600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '沐野',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Obx(
                            () => Text(
                              controller.status.value.tr,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 166,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: StoreProduct.subscriptions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final product = StoreProduct.subscriptions[index];
                    return Obx(() {
                      final selected = controller.selected.value == product;
                      return Material(
                        color: selected
                            ? AppColors.accentYellow.withValues(alpha: .16)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: selected
                                ? AppColors.accentYellow
                                : profilePanelBorder,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => controller.selected.value = product,
                          child: SizedBox(
                            width: 118,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.subtitle.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    controller.store.priceFor(product),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.title.tr,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              ProfilePanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vip_privilege'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Benefit(text: 'vip_benefit_join'.tr),
                    _Benefit(text: 'vip_benefit_no_ads'.tr),
                    _Benefit(text: 'vip_benefit_badge'.tr),
                    _Benefit(text: 'vip_benefit_assistant'.tr, last: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                Obx(() {
                  final product = controller.selected.value;
                  return ProfilePrimaryButton(
                    label: 'vip_purchase'.trParams({
                      'price': controller.store.priceFor(product),
                    }),
                    onPressed: controller.purchase,
                  );
                }),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.legal,
                    arguments: {
                      'title': 'vip_auto_renew_title'.tr,
                      'assetPath': 'assets/legal/vip_auto_renew.html',
                    },
                  ),
                  child: Text(
                    'vip_auto_renew_prompt'.tr,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text, this.last = false});

  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 18, color: AppColors.accentYellow),
        const SizedBox(width: 8),
        Expanded(child: Text(text.replaceFirst('✓  ', ''))),
      ],
    ),
  );
}
