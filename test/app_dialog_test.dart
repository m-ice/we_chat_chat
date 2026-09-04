import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:we_chat_chat/core/widgets/app_dialog.dart';
import 'package:we_chat_chat/core/widgets/app_text_input_dialog.dart';
import 'package:we_chat_chat/l10n/app_translations.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'confirmation returns explicit choices and stays open on mask tap',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: AppTranslations.fallbackLocale,
          builder: FlutterSmartDialog.init(),
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    key: const ValueKey('open-standard-confirm'),
                    onPressed: () {
                      unawaited(
                        AppDialog.confirm(
                          title: 'Leave this page?',
                          message: 'Your unsaved changes will be lost.',
                        ).then((value) => result = value),
                      );
                    },
                    child: const Text('Open'),
                  ),
                  FilledButton(
                    key: const ValueKey('open-danger-confirm'),
                    onPressed: () {
                      unawaited(
                        AppDialog.confirm(
                          title: 'Delete item?',
                          confirmText: 'Delete',
                          isDangerous: true,
                        ).then((value) => result = value),
                      );
                    },
                    child: const Text('Delete flow'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('open-standard-confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('app-confirm-dialog')), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(result, isNull);

      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      expect(find.byKey(const ValueKey('app-confirm-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app-confirm-cancel')));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      result = null;
      await tester.tap(find.byKey(const ValueKey('open-danger-confirm')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app-confirm-submit')));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    },
  );

  testWidgets('alert uses the shared smart-dialog surface', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: AppTranslations.fallbackLocale,
        builder: FlutterSmartDialog.init(),
        home: Scaffold(
          body: FilledButton(
            onPressed: () => unawaited(
              AppDialog.alert(
                title: 'Recharge help',
                message: 'Choose an amount before continuing.',
              ),
            ),
            child: const Text('Open help'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open help'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-confirm-dialog')), findsOneWidget);
    expect(find.text('Got It'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-confirm-cancel')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('app-confirm-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-confirm-dialog')), findsNothing);
  });

  testWidgets('text input dialog returns input and ignores mask taps', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: AppTranslations.fallbackLocale,
        builder: FlutterSmartDialog.init(),
        home: Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () {
                unawaited(
                  AppTextInputDialog.show(
                    title: 'Write a comment',
                    hint: 'Comment',
                    initialValue: 'Draft',
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 200,
                  ).then((value) => result = value),
                );
              },
              child: const Text('Open input'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open input'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-text-input-dialog')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('app-text-input-field')))
          .controller!
          .text,
      'Draft',
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(find.byKey(const ValueKey('app-text-input-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('app-text-input-field')),
      'Updated comment',
    );
    await tester.tap(find.byKey(const ValueKey('app-text-input-submit')));
    await tester.pumpAndSettle();
    expect(result, 'Updated comment');
    expect(tester.takeException(), isNull);
  });
}
