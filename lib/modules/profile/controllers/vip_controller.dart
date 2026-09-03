import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../data/providers/store_purchase_service.dart';
import '../../../domain/entities/store_product.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';

class VipController extends GetxController {
  VipController(this._wallet, this.store);

  final MembershipWalletRepository _wallet;
  final StorePurchaseService store;
  final selected = StoreProduct.yearlyVip.obs;
  final status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    status.value = _wallet.vipStatusText;
    ever(store.lastSuccessMessage, (message) {
      if (message == null) return;
      status.value = _wallet.vipStatusText;
      AppToast.show(message);
      store.lastSuccessMessage.value = null;
    });
    ever(store.errorMessage, (message) {
      if (message != null) AppToast.show(message);
    });
  }

  Future<void> purchase() => store.purchase(selected.value);

  Future<void> restore() => store.restore();
}
