import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_legal_agreement_confirmation.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/policies/feature_access_gate.dart';
import '../../../domain/repositories/team_publish_repository.dart';

class TeamPublishController extends GetxController {
  TeamPublishController(this._repository, this._access, this._preferences);

  static const activityGroups = <String, List<String>>{
    '娱乐': ['K歌', '电影', '读书', '摄影', '约咖啡', '绘画'],
    '运动': ['羽毛球', '网球', '篮球', '高尔夫', '乒乓球'],
    '户外': ['登山', '徒步', '马拉松', '露营', '骑行'],
  };
  static List<String> get activities =>
      activityGroups.values.expand((items) => items).toList(growable: false);
  static const verificationKey = 'mt_real_person_verify_record';

  final TeamPublishRepository _repository;
  final FeatureAccessGate _access;
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
      AppToast.show('photo_access_failed'.tr);
    }
  }

  void removeImage(int index) => imagePaths.removeAt(index);

  Future<void> submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!agreed.value) {
      final accepted = await AppLegalAgreementConfirmation.show();
      if (!accepted) return;
      agreed.value = true;
    }
    if (activity.value == null) {
      AppToast.show('team_activity_required'.tr);
      return;
    }
    if (!await _access.request(FeatureAccess.activityPublish)) return;
    if (!isVerified) {
      final proceed = await AppDialog.confirm(
        title: 'common_tip'.tr,
        message: 'verification_publish_confirm'.tr,
        cancelText: 'common_no'.tr,
        confirmText: 'common_yes'.tr,
      );
      if (!proceed) return;
    }
    if (title.text.trim().isEmpty) {
      AppToast.show('team_title_required'.tr);
      return;
    }
    if (content.text.trim().isEmpty) {
      AppToast.show('team_description_required'.tr);
      return;
    }
    if (date.value == null) {
      AppToast.show('team_time_required'.tr);
      return;
    }
    if (location.text.trim().isEmpty) {
      AppToast.show('team_location_required'.tr);
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
            ? 'team_contact_in_app'.tr
            : contact.text,
        imageSourcePaths: imagePaths,
      );
      if (ok) {
        AppToast.show('review_pending_title'.tr);
        await Get.offNamed(Routes.teamPublishReview);
      } else {
        AppToast.show('team_publish_failed'.tr);
      }
    } on Object {
      AppToast.show('team_publish_failed'.tr);
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    title.dispose();
    location.dispose();
    contact.dispose();
    content.dispose();
    super.onClose();
  }
}
