import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/store_product.dart';
import '../../domain/repositories/membership_wallet_repository.dart';

class StorePurchaseService extends GetxService {
  StorePurchaseService(this._wallet, this._preferences);

  static const _deliveredPurchasesKey = 'mt_flutter_delivered_purchase_ids';
  final MembershipWalletRepository _wallet;
  final SharedPreferences _preferences;
  final _store = InAppPurchase.instance;
  final products = <String, ProductDetails>{}.obs;
  final isAvailable = false.obs;
  final isBusy = false.obs;
  final errorMessage = RxnString();
  final lastSuccessMessage = RxnString();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object _) {
        isBusy.value = false;
        errorMessage.value = 'store_purchase_failed'.tr;
      },
    );
    loadProducts();
  }

  Future<void> loadProducts() async {
    errorMessage.value = null;
    try {
      isAvailable.value = await _store.isAvailable();
      if (!isAvailable.value) {
        errorMessage.value = 'store_unavailable'.tr;
        return;
      }
      final response = await _store.queryProductDetails(
        StoreProduct.values.map((product) => product.id).toSet(),
      );
      products.assignAll({
        for (final product in response.productDetails) product.id: product,
      });
      if (response.error != null) {
        errorMessage.value = 'store_load_failed'.tr;
      } else if (response.notFoundIDs.isNotEmpty) {
        errorMessage.value = 'store_products_missing'.trParams({
          'ids': response.notFoundIDs.join(', '),
        });
      }
    } on Object {
      errorMessage.value = 'store_load_failed'.tr;
    }
  }

  String priceFor(StoreProduct product) =>
      products[product.id]?.price ?? product.fallbackPrice;

  Future<void> purchase(StoreProduct product) async {
    if (isBusy.value) return;
    final details = products[product.id];
    if (details == null) {
      errorMessage.value = 'store_products_unavailable'.tr;
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final parameter = PurchaseParam(productDetails: details);
      final launched = product.coinAmount != null
          ? await _store.buyConsumable(purchaseParam: parameter)
          : await _store.buyNonConsumable(purchaseParam: parameter);
      if (launched) return;
      isBusy.value = false;
      errorMessage.value = 'store_purchase_not_started'.tr;
    } on Object {
      isBusy.value = false;
      errorMessage.value = 'store_purchase_failed'.tr;
    }
  }

  Future<void> restore() async {
    if (isBusy.value) return;
    isBusy.value = true;
    errorMessage.value = null;
    try {
      await _store.restorePurchases();
    } on Object {
      isBusy.value = false;
      errorMessage.value = 'store_restore_failed'.tr;
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty) {
      isBusy.value = false;
      lastSuccessMessage.value = 'store_nothing_to_restore'.tr;
      return;
    }
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isBusy.value = true;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _deliver(purchase);
        case PurchaseStatus.error:
          errorMessage.value = 'store_purchase_failed'.tr;
        case PurchaseStatus.canceled:
          errorMessage.value = 'store_purchase_canceled'.tr;
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
    isBusy.value = false;
  }

  Future<void> _deliver(PurchaseDetails purchase) async {
    final product = StoreProduct.values
        .where((item) => item.id == purchase.productID)
        .firstOrNull;
    if (product == null) return;
    final purchaseId = purchase.purchaseID;
    final delivered =
        _preferences.getStringList(_deliveredPurchasesKey)?.toSet() ??
        <String>{};
    if (purchaseId != null && delivered.contains(purchaseId)) return;

    if (product.coinAmount case final amount?) {
      await _wallet.addCoins(amount);
      lastSuccessMessage.value = 'store_coins_success'.tr;
    } else if (product.durationDays case final days?) {
      await _wallet.activateVip(productId: product.id, durationDays: days);
      lastSuccessMessage.value = purchase.status == PurchaseStatus.restored
          ? 'store_purchase_restored'.tr
          : 'store_vip_success'.tr;
    }
    if (purchaseId != null) {
      delivered.add(purchaseId);
      await _preferences.setStringList(
        _deliveredPurchasesKey,
        delivered.toList(),
      );
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
