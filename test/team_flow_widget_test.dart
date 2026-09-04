import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/modules/home/team_publish/team_activity_picker_page.dart';

import 'helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('activity picker returns one selected Figma activity', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestApp(const _PickerHost()));

    await tester.tap(find.byKey(const ValueKey('open-activity-picker')));
    await tester.pumpAndSettle();
    expect(find.text('选择类型 0/1'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('team-activity-picker-sheet'))),
      const Size(375, 448),
    );
    expect(find.text('娱乐'), findsOneWidget);
    expect(find.text('运动'), findsOneWidget);
    expect(find.text('户外'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('team-activity-摄影')));
    await tester.pump();
    expect(find.text('选择类型 1/1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('team-activity-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('摄影'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PickerHost extends StatefulWidget {
  const _PickerHost();

  @override
  State<_PickerHost> createState() => _PickerHostState();
}

class _PickerHostState extends State<_PickerHost> {
  String? selected;

  Future<void> openPicker() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeamActivityPickerSheet(initialValue: selected),
    );
    if (value != null) setState(() => selected = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: const ValueKey('open-activity-picker'),
          onPressed: openPicker,
          child: Text(selected ?? '打开'),
        ),
      ),
    );
  }
}
