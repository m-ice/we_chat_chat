import 'package:get/get.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/profile_edit_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._users, this._wallet, this._profileEdit);

  final UserRepository _users;
  final MembershipWalletRepository _wallet;
  final ProfileEditRepository _profileEdit;
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
    currentUser.value = await _users.getCurrentUser();
    nickname.value = _profileEdit.profile.nickname;
    avatarFilePath.value = await _profileEdit.resolveAvatarPath();
    refreshWallet();
  }

  void refreshWallet() {
    coinBalance.value = _wallet.coinBalance;
    vipStatus.value = _wallet.vipStatusText;
  }
}
