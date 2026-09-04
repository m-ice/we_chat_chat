import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Project-wide confirmation dialogs.
///
/// Copy passed to [confirm] should already be localized. Button labels fall
/// back to the shared translation keys when they are not provided.
abstract final class AppDialog {
  static int _sequence = 0;

  static Future<void> alert({
    required String title,
    String? message,
    String? buttonText,
  }) async {
    final tag = 'app-alert-${_sequence++}';
    await SmartDialog.show<void>(
      tag: tag,
      clickMaskDismiss: false,
      maskColor: const Color(0x99000000),
      animationType: SmartAnimationType.scale,
      animationTime: const Duration(milliseconds: 180),
      builder: (_) => _AppConfirmDialog(
        title: title,
        message: message,
        messageWidget: null,
        cancelText: '',
        confirmText: buttonText ?? 'common_got_it'.tr,
        isDangerous: false,
        showCancel: false,
        onCancel: () {},
        onConfirm: () =>
            SmartDialog.dismiss<void>(status: SmartStatus.custom, tag: tag),
      ),
    );
  }

  static Future<bool> confirm({
    required String title,
    String? message,
    Widget? messageWidget,
    String? cancelText,
    String? confirmText,
    bool isDangerous = false,
  }) async {
    assert(message == null || messageWidget == null);
    final tag = 'app-confirm-${_sequence++}';
    final result = await SmartDialog.show<bool>(
      tag: tag,
      clickMaskDismiss: false,
      maskColor: const Color(0x99000000),
      animationType: SmartAnimationType.scale,
      animationTime: const Duration(milliseconds: 180),
      builder: (_) => _AppConfirmDialog(
        title: title,
        message: message,
        messageWidget: messageWidget,
        cancelText: cancelText ?? 'common_cancel'.tr,
        confirmText: confirmText ?? 'common_confirm'.tr,
        isDangerous: isDangerous,
        showCancel: true,
        onCancel: () => SmartDialog.dismiss<bool>(
          status: SmartStatus.custom,
          tag: tag,
          result: false,
        ),
        onConfirm: () => SmartDialog.dismiss<bool>(
          status: SmartStatus.custom,
          tag: tag,
          result: true,
        ),
      ),
    );
    return result ?? false;
  }
}

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.message,
    required this.messageWidget,
    required this.cancelText,
    required this.confirmText,
    required this.isDangerous,
    required this.showCancel,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String? message;
  final Widget? messageWidget;
  final String cancelText;
  final String confirmText;
  final bool isDangerous;
  final bool showCancel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xFFE34D59);
    final confirmColor = isDangerous ? dangerColor : AppColors.accentYellow;
    final trimmedMessage = message?.trim();

    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 336),
        child: Material(
          key: const ValueKey('app-confirm-dialog'),
          color: Colors.white,
          elevation: 16,
          shadowColor: const Color(0x33000000),
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: confirmColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDangerous
                            ? Icons.delete_outline_rounded
                            : Icons.help_outline_rounded,
                        color: isDangerous
                            ? dangerColor
                            : AppColors.textPrimary,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (messageWidget != null) ...[
                  const SizedBox(height: 14),
                  messageWidget!,
                ] else if (trimmedMessage?.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  Text(
                    trimmedMessage!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showCancel) ...[
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey('app-confirm-cancel'),
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: const Color(0xFFF7F7F7),
                            side: const BorderSide(color: AppColors.separator),
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('app-confirm-submit'),
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          foregroundColor: isDangerous
                              ? Colors.white
                              : AppColors.textPrimary,
                          backgroundColor: confirmColor,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
