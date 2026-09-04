import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/store_product.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../controllers/wallet_controller.dart';
import 'profile_design.dart';

class CoinsPage extends GetView<WalletController> {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'coins_recharge_center'.tr,
    actions: [
      IconButton(
        tooltip: 'coins_help_title'.tr,
        onPressed: () => _showHelp(context),
        icon: const AppImage(
          ProfileDetailAssets.rechargeHelp,
          width: 24,
          height: 24,
        ),
      ),
      const SizedBox(width: 6),
    ],
    body: Column(
      children: [
        Expanded(
          child: AppRefreshView(
            onRefresh: () async {
              await controller.store.loadProducts();
              controller.balance.value =
                  Get.find<MembershipWalletRepository>().coinBalance;
            },
            child: ListView(
              clipBehavior: Clip.none,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              children: [
                const _BalanceCard(),
                const SizedBox(height: 16),
                Obx(
                  () => Column(
                    children: StoreProduct.coinProducts
                        .map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProductTile(
                              product: product,
                              price: controller.store.priceFor(product),
                              selected: controller.selected.value == product,
                              onTap: () => controller.selected.value = product,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                Obx(
                  () => ProfilePrimaryButton(
                    label: controller.store.isBusy.value
                        ? 'store_processing'.tr
                        : 'coins_recharge_now'.tr,
                    onPressed: controller.store.isBusy.value
                        ? null
                        : () => controller.purchase(controller.selected.value),
                  ),
                ),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.legal,
                    arguments: {
                      'title': 'legal_recharge_agreement'.tr,
                      'assetPath': 'assets/legal/recharge_agreement.html',
                    },
                  ),
                  child: Text(
                    'coins_recharge_consent'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _showHelp(BuildContext _) => AppDialog.alert(
    title: 'coins_help_title'.tr,
    message: 'coins_help_body'.tr,
  );
}

class _BalanceCard extends GetView<WalletController> {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 110,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Container(
            height: 102,
            padding: const EdgeInsets.fromLTRB(16, 18, 118, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFFDD7E), Color(0xFFFFEEBF)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'coins_balance'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC2971C),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${controller.balance.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.18,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF342600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: -6,
          right: 19,
          child: AppImage(
            ProfileDetailAssets.coin,
            width: 95,
            height: 95,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final StoreProduct product;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(17),
      side: BorderSide(
        color: selected ? AppColors.accentYellow : profilePanelBorder,
        width: selected ? 2 : 1,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            const SizedBox(width: 16),
            const AppImage(ProfileDetailAssets.coin, width: 36, height: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '  (${'coins_product_unit'.tr})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: profileMutedText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    ),
  );
}
