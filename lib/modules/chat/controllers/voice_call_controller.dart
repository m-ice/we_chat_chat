import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';

class VoiceCallController extends GetxController {
  VoiceCallController(this.peer, this._users);

  final User peer;
  final UserRepository _users;
  final elapsedSeconds = 0.obs;
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;

  String get durationText {
    final minutes = elapsedSeconds.value ~/ 60;
    final seconds = elapsedSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onReady() {
    super.onReady();
    _start();
  }

  Future<void> _start() async {
    if (await _isCurrentUser()) {
      Get.back<void>();
      return;
    }
    AppToast.show('call_demo_no_charge'.tr);
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/call/mitu_call.mp3'));
    } on Object {
      AppToast.show('call_audio_failed'.tr);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
      if (elapsedSeconds.value >= 30) end(showToast: true);
    });
  }

  Future<bool> _isCurrentUser() async {
    try {
      return (await _users.getCurrentUser()).id == peer.id;
    } on Object {
      // A call is not started when the local identity cannot be verified.
      return true;
    }
  }

  void end({bool showToast = false}) {
    _timer?.cancel();
    _player.stop();
    Get.back<void>();
    if (showToast) AppToast.show('call_ended'.tr);
  }

  @override
  void onClose() {
    _timer?.cancel();
    _player.dispose();
    super.onClose();
  }
}
