import 'dart:async';

import 'package:get/get.dart';
import 'package:we_chat_chat/main.dart' as app;
import 'package:we_chat_chat/modules/main/controllers/main_controller.dart';

Future<void> main() async {
  await app.main();
  const targetTab = int.fromEnvironment('AUDIT_TAB');
  var attempts = 0;
  Timer.periodic(const Duration(milliseconds: 100), (timer) {
    attempts += 1;
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().selectTab(targetTab);
      timer.cancel();
    } else if (attempts >= 50) {
      timer.cancel();
    }
  });
}
