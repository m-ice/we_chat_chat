import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle()
      .copyWith(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final preferences = await SharedPreferences.getInstance();
  runApp(MiTuApp(preferences: preferences));
}

class MiTuApp extends StatelessWidget {
  const MiTuApp({super.key, required this.preferences, this.locale});

  final SharedPreferences preferences;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) => GetMaterialApp(
          title: 'app_name'.tr,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          translations: AppTranslations(),
          locale: locale ?? Get.deviceLocale,
          fallbackLocale: AppTranslations.fallbackLocale,
          supportedLocales: AppTranslations.supportedLocales,
          builder: FlutterSmartDialog.init(builder: BotToastInit()),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialBinding: InitialBinding(preferences),
          initialRoute: Routes.root,
          getPages: AppPages.pages,
        ),
      ),
    );
  }
}
