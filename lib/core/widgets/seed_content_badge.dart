import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeedContentBadge extends StatelessWidget {
  const SeedContentBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2CB),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      child: Text(
        'seed_content_badge'.tr,
        style: TextStyle(
          color: const Color(0xFF6A5311),
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
