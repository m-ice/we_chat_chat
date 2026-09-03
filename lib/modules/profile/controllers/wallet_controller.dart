import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../data/providers/store_purchase_service.dart';
import '../../../domain/entities/store_product.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';

class WalletController extends GetxController {
  WalletController(this._wallet, this.store);

  final MembershipWalletRepository _wallet;
  final StorePurchaseService store;
  final balance = 0.obs;
  final selected = StoreProduct.coinProducts.first.obs;

  @override
  void onInit() {
    super.onInit();
    balance.value = _wallet.coinBalance;
    ever(store.lastSuccessMessage, (message) {
      if (message == null) return;
      balance.value = _wallet.coinBalance;
      AppToast.show(message);
      store.lastSuccessMessage.value = null;
    });
    ever(store.errorMessage, (message) {
      if (message != null) AppToast.show(message);
    });
  }

  Future<void> purchase(StoreProduct product) async {
    if (store.isBusy.value) return;
    selected.value = product;
    await store.purchase(product);
  }
}
