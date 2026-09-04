import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

abstract final class AppTextInputDialog {
  static int _sequence = 0;

  static Future<String?> show({
    required String title,
    required String hint,
    String initialValue = '',
    String? cancelText,
    String? confirmText,
    int minLines = 1,
    int maxLines = 2,
    int? maxLength,
  }) {
    assert(minLines > 0);
    assert(maxLines >= minLines);
    final tag = 'app-text-input-${_sequence++}';
    return SmartDialog.show<String>(
      tag: tag,
      clickMaskDismiss: false,
      maskColor: const Color(0x99000000),
      animationType: SmartAnimationType.scale,
      animationTime: const Duration(milliseconds: 180),
      builder: (_) => _AppTextInputCard(
        tag: tag,
        title: title,
        hint: hint,
        initialValue: initialValue,
        cancelText: cancelText ?? 'common_cancel'.tr,
        confirmText: confirmText ?? 'common_confirm'.tr,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }
}

class _AppTextInputCard extends StatefulWidget {
  const _AppTextInputCard({
    required this.tag,
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.cancelText,
    required this.confirmText,
    required this.minLines,
    required this.maxLines,
    required this.maxLength,
  });

  final String tag;
  final String title;
  final String hint;
  final String initialValue;
  final String cancelText;
  final String confirmText;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  State<_AppTextInputCard> createState() => _AppTextInputCardState();
}

class _AppTextInputCardState extends State<_AppTextInputCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.selection = TextSelection.collapsed(
      offset: widget.initialValue.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss([String? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.dismiss<String>(
      status: SmartStatus.custom,
      tag: widget.tag,
      result: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardInset),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 336),
            child: Material(
              key: const ValueKey('app-text-input-dialog'),
              color: Colors.white,
              elevation: 16,
              shadowColor: const Color(0x33000000),
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0x24FFCE45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.textPrimary,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      key: const ValueKey('app-text-input-field'),
                      controller: _controller,
                      autofocus: true,
                      minLines: widget.minLines,
                      maxLines: widget.maxLines,
                      maxLength: widget.maxLength,
                      textInputAction: widget.maxLines == 1
                          ? TextInputAction.done
                          : TextInputAction.newline,
                      onSubmitted: widget.maxLines == 1
                          ? (_) => _dismiss(_controller.text)
                          : null,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.separator,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.accentYellow,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const ValueKey('app-text-input-cancel'),
                            onPressed: _dismiss,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: const Color(0xFFF7F7F7),
                              side: const BorderSide(
                                color: AppColors.separator,
                              ),
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(widget.cancelText),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            key: const ValueKey('app-text-input-submit'),
                            onPressed: () => _dismiss(_controller.text),
                            style: FilledButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: AppColors.accentYellow,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(widget.confirmText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
