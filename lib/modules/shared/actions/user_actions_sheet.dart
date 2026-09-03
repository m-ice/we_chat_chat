import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef UserAction = FutureOr<void> Function();

Future<void> showUserActionsSheet({
  required UserAction onBlock,
  required UserAction onReport,
}) {
  Future<void> run(UserAction action) async {
    Get.back<void>();
    await action();
  }

  return Get.bottomSheet<void>(
    Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionRow(label: 'common_block'.tr, onTap: () => run(onBlock)),
            const Divider(height: 1, color: Color(0xFFF1F1F1)),
            _ActionRow(label: 'common_report'.tr, onTap: () => run(onReport)),
            const Divider(height: 1, color: Color(0xFFF1F1F1)),
            _ActionRow(label: 'common_cancel'.tr, onTap: Get.back),
          ],
        ),
      ),
    ),
    barrierColor: const Color(0xB3000000),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.onTap});

  final String label;
  final UserAction onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async => onTap(),
    child: SizedBox(
      height: 54,
      width: double.infinity,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
        ),
      ),
    ),
  );
}
