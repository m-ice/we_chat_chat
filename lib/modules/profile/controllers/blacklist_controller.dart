import 'dart:async';

import 'package:get/get.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/user_repository.dart';

class BlacklistController extends GetxController {
  BlacklistController(this._users, this._social);

  final UserRepository _users;
  final SocialStateRepository _social;
  final blockedUsers = <User>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  StreamSubscription<void>? _socialChangesSubscription;

  @override
  void onInit() {
    super.onInit();
    _socialChangesSubscription = _social.changes.listen((_) => load());
    load();
  }

  @override
  void onClose() {
    _socialChangesSubscription?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final blockedIds = _social.blockedIds;
      final users = await _users.getUsers();
      blockedUsers.assignAll(
        users.where((user) => blockedIds.contains(user.id)),
      );
    } on Object {
      hasError.value = true;
      blockedUsers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> remove(User user) async {
    if (!_social.blockedIds.contains(user.id)) {
      await load();
      return;
    }
    final confirmed = await AppDialog.confirm(
      title: 'blacklist_remove_title'.tr,
      message: 'blacklist_remove_message'.trParams({'name': user.nickname}),
      confirmText: 'blacklist_remove'.tr,
      isDangerous: true,
    );
    if (!confirmed) return;

    await _social.unblock(user.id);
    await load();
    AppToast.show('blacklist_removed'.trParams({'name': user.nickname}));
  }
}
