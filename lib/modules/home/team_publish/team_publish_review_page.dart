import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamPublishReviewPage extends StatelessWidget {
  const TeamPublishReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('review_pending'.tr),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 70, color: Color(0xFFC8933F)),
              const SizedBox(height: 20),
              Text(
                'review_pending_title'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('review_pending_body'.tr, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Get.until((route) => route.isFirst),
                child: Text('common_done'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
