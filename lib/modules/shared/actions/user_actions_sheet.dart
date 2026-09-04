import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';

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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionRow(
              label: 'common_block'.tr,
              onTap: () => run(onBlock),
              backgroundAsset: AppImageString.videoUserMoreSheet,
            ),
            _ActionRow(label: 'common_report'.tr, onTap: () => run(onReport)),
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
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.backgroundAsset,
  });

  final String label;
  final UserAction onTap;
  final String? backgroundAsset;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async => onTap(),
    child: SizedBox(
      height: 54,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundAsset case final asset?)
            AppImage(asset, fit: BoxFit.fill),
          Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
