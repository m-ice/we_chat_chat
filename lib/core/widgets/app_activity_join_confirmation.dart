import 'package:get/get.dart';

import 'app_dialog.dart';

/// Shared confirmation surface for joining an activity from any entry point.
abstract final class AppActivityJoinConfirmation {
  static Future<bool> show(String activity) => AppDialog.confirm(
    title: 'team_join_confirm_title'.tr,
    message: 'team_join_confirm_message'.trParams({'name': activity}),
    confirmText: 'team_join_confirm_action'.tr,
  );
}
