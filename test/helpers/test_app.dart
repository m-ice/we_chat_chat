import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/l10n/app_translations.dart';

Widget buildTestApp(Widget home, {Locale locale = const Locale('zh', 'CN')}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, _) => GetMaterialApp(
        translations: AppTranslations(),
        locale: locale,
        builder: BotToastInit(),
        home: home,
      ),
    );
