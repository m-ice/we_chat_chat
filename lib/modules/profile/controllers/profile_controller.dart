import 'package:get/get.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._users, this._wallet);

  final UserRepository _users;
  final MembershipWalletRepository _wallet;
  final nickname = ''.obs;
  final avatarFilePath = RxnString();
  final currentUser = Rxn<User>();
  final coinBalance = 0.obs;
  final vipStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final user = await _users.getCurrentUser();
    currentUser.value = user;
    nickname.value = user.nickname;
    avatarFilePath.value = user.avatarPath;
    refreshWallet();
  }

  void refreshWallet() {
    coinBalance.value = _wallet.coinBalance;
    vipStatus.value = _wallet.vipStatusText;
  }
}
