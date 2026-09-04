import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../domain/repositories/profile_edit_repository.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._repository);

  static const interests = [
    '羽毛球',
    '网球',
    '篮球',
    '高尔夫',
    '乒乓球',
    'K歌',
    '电影',
    '读书',
    '摄影',
    '约咖啡',
    '绘画',
    '登山',
    '徒步',
    '马拉松',
    '露营',
    '骑行',
  ];
  static const personalityTags = [
    '自习搭子',
    '城市漫游',
    '半E半I',
    '行动派',
    '话痨选手',
    '爽快不墨迹',
    '特种兵旅游',
    '逛公园达人',
    '台球选手',
    '慢游躺平党',
  ];

  final ProfileEditRepository _repository;
  late final profile = _repository.profile.obs;
  final avatarFilePath = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<void> refreshProfile() async {
    profile.value = _repository.profile;
    avatarFilePath.value = await _repository.resolveAvatarPath();
  }

  Future<void> pickAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final save = await AppDialog.confirm(
      title: 'profile_save_avatar'.tr,
      confirmText: 'common_save'.tr,
    );
    if (!save) return;
    if (await _repository.updateAvatar(file.path)) {
      await refreshProfile();
      AppToast.show('profile_avatar_saved'.tr);
    } else {
      AppToast.show('profile_avatar_save_failed'.tr);
    }
  }

  Future<bool> saveText(String value, {required bool nickname}) async {
    final text = value.trim();
    if (text.isEmpty) {
      AppToast.show('common_content_required'.tr);
      return false;
    }
    if (nickname && text.characters.length > 16) {
      AppToast.show('profile_nickname_limit'.trParams({'count': '16'}));
      return false;
    }
    if (!nickname && text.characters.length > 100) {
      AppToast.show('profile_bio_limit'.trParams({'count': '100'}));
      return false;
    }
    nickname
        ? await _repository.updateNickname(text)
        : await _repository.updateBio(text);
    await refreshProfile();
    AppToast.show('common_saved'.tr);
    return true;
  }

  Future<void> saveTags(
    List<String> values, {
    required bool personality,
  }) async {
    personality
        ? await _repository.updatePersonalityTags(values)
        : await _repository.updateInterests(values);
    await refreshProfile();
    AppToast.show('common_saved'.tr);
  }
}
