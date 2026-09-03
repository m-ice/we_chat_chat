import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

abstract final class AppToast {
  static void show(String text) =>
      BotToast.showText(text: text, align: Alignment.center);
}
