import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/voice_call_controller.dart';

class VoiceCallPage extends GetView<VoiceCallController> {
  const VoiceCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(controller.peer.avatarPath, fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: const ColoredBox(color: Color(0x40000000)),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: AssetImage(controller.peer.avatarPath),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    controller.peer.nickname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      controller.durationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: FilledButton(
                      onPressed: controller.end,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEB4034),
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.phone_disabled, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
