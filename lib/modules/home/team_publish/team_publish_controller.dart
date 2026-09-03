import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../../domain/repositories/team_publish_repository.dart';
import 'team_flow_assets.dart';

class TeamPublishController extends GetxController {
  TeamPublishController(this._repository, this._wallet, this._preferences);

  static const activityGroups = <String, List<String>>{
    '娱乐': ['K歌', '电影', '读书', '摄影', '约咖啡', '绘画'],
    '运动': ['羽毛球', '网球', '篮球', '高尔夫', '乒乓球'],
    '户外': ['登山', '徒步', '马拉松', '露营', '骑行'],
  };
  static List<String> get activities =>
      activityGroups.values.expand((items) => items).toList(growable: false);
  static const designPreviewImagePaths = <String>[
    TeamFlowAssets.publishSampleBadminton,
    TeamFlowAssets.publishSampleCourt,
  ];
  static const verificationKey = 'mt_real_person_verify_record';

  final TeamPublishRepository _repository;
  final MembershipWalletRepository _wallet;
  final SharedPreferences _preferences;
  final title = TextEditingController();
  final location = TextEditingController();
  final contact = TextEditingController();
  final content = TextEditingController();
  final activity = RxnString();
  final date = Rxn<DateTime>();
  final agreed = false.obs;
  final imagePaths = <String>[].obs;
  final submitting = false.obs;

  String get dateText {
    final value = date.value;
    if (value == null) return 'team_date_choose'.tr;
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year/$month/$day $hour:$minute';
  }

  void updateDate(DateTime day, TimeOfDay time) {
    date.value = DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  bool get isVerified {
    final raw = _preferences.getString(verificationKey);
    if (raw == null) return false;
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)['mtStatus'] ==
          'mtApproved';
    } on Object {
      return false;
    }
  }

  Future<void> pickImages() async {
    final remaining = 3 - imagePaths.length;
    if (remaining <= 0) return;
    try {
      final selected = await ImagePicker().pickMultiImage(limit: remaining);
      imagePaths.addAll(selected.take(remaining).map((file) => file.path));
    } on Object {
      AppToast.show(_copy('无法读取照片，请检查照片权限', 'Unable to access photos'));
    }
  }

  void removeImage(int index) => imagePaths.removeAt(index);

  Future<void> submit(BuildContext context) async {
    if (!agreed.value) {
      final accepted = await Get.dialog<bool>(
        AlertDialog(
          title: Text('common_tip'.tr),
          content: Text('legal_agreement_required'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('common_cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('common_done'.tr),
            ),
          ],
        ),
      );
      if (accepted != true) return;
      agreed.value = true;
    }
    if (activity.value == null) {
      AppToast.show('team_activity_required'.tr);
      return;
    }
    if (!_wallet.isVipActive) {
      await Get.dialog<void>(
        AlertDialog(
          title: Text('vip_privilege'.tr),
          content: Text('vip_publish_required'.tr),
          actions: [
            TextButton(onPressed: Get.back, child: Text('common_cancel'.tr)),
            TextButton(
              onPressed: () {
                Get.back<void>();
                Get.toNamed(Routes.vip);
              },
              child: Text('vip_open'.tr),
            ),
          ],
        ),
      );
      return;
    }
    if (!isVerified) {
      final proceed = await Get.dialog<bool>(
        AlertDialog(
          content: Text('verification_publish_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('common_no'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('common_yes'.tr),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (title.text.trim().isEmpty) {
      AppToast.show(_copy('请设置活动标题', 'Enter an activity title'));
      return;
    }
    if (content.text.trim().isEmpty) {
      AppToast.show(_copy('请输入活动描述', 'Enter an activity description'));
      return;
    }
    if (date.value == null) {
      AppToast.show(_copy('请选择活动时间', 'Choose the activity time'));
      return;
    }
    if (location.text.trim().isEmpty) {
      AppToast.show(_copy('请输入活动地址', 'Enter the activity location'));
      return;
    }
    submitting.value = true;
    try {
      final ok = await _repository.publish(
        activity: activity.value!,
        location: location.text,
        date: dateText,
        content: '${title.text.trim()}\n${content.text.trim()}',
        contact: contact.text.trim().isEmpty
            ? _copy('站内消息联系', 'Contact via in-app messages')
            : contact.text,
        imageSourcePaths: imagePaths,
      );
      if (ok) {
        AppToast.show('review_pending_title'.tr);
        await Get.offNamed(Routes.teamPublishReview);
      } else {
        AppToast.show(_copy('发布失败，请稍后重试', 'Publishing failed. Try again'));
      }
    } finally {
      submitting.value = false;
    }
  }

  String _copy(String zh, String en) =>
      Get.locale?.languageCode == 'zh' ? zh : en;

  @override
  void onClose() {
    title.dispose();
    location.dispose();
    contact.dispose();
    content.dispose();
    super.onClose();
  }
}
