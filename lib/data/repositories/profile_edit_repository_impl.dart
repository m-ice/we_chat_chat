import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/editable_profile.dart';
import '../../domain/repositories/profile_edit_repository.dart';

class ProfileEditRepositoryImpl implements ProfileEditRepository {
  ProfileEditRepositoryImpl(this._preferences);

  static const storageKey = 'mt_profile_edit_model';
  final SharedPreferences _preferences;

  @override
  bool get hasSavedProfile => _preferences.containsKey(storageKey);

  @override
  EditableProfile get profile {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return _defaults;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return EditableProfile(
        nickname: json['mtNickname'] as String? ?? '微撩',
        bio: json['mtBio'] as String? ?? '',
        avatarReference: json['mtAvatarAssetName'] as String? ?? 'userDefault',
        interests: (json['mtInterests'] as List? ?? const []).cast<String>(),
        personalityTags: (json['mtPersonalityTags'] as List? ?? const [])
            .cast<String>(),
      );
    } on Object {
      return _defaults;
    }
  }

  static const _defaults = EditableProfile(
    nickname: '微撩',
    bio: '',
    avatarReference: 'userDefault',
    interests: [],
    personalityTags: [],
  );

  @override
  Future<void> initializeIfAbsent(EditableProfile profile) async {
    if (hasSavedProfile) return;
    await _save(profile);
  }

  @override
  Future<String?> resolveAvatarPath() async {
    final reference = profile.avatarReference;
    if (!reference.contains('/')) return null;
    final documents = await getApplicationDocumentsDirectory();
    final file = File('${documents.path}/$reference');
    return file.existsSync() ? file.path : null;
  }

  @override
  Future<bool> updateAvatar(String sourcePath) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/profile/avatars');
    await directory.create(recursive: true);
    final relative =
        'profile/avatars/avatar_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.jpg';
    try {
      await File(sourcePath).copy('${documents.path}/$relative');
      final previous = profile.avatarReference;
      await _save(profile.copyWith(avatarReference: relative));
      if (previous.contains('/') && previous != relative) {
        final old = File('${documents.path}/$previous');
        if (old.existsSync()) await old.delete();
      }
      return true;
    } on FileSystemException {
      return false;
    }
  }

  @override
  Future<void> updateNickname(String value) =>
      _save(profile.copyWith(nickname: value));

  @override
  Future<void> updateBio(String value) => _save(profile.copyWith(bio: value));

  @override
  Future<void> updateInterests(List<String> values) =>
      _save(profile.copyWith(interests: values));

  @override
  Future<void> updatePersonalityTags(List<String> values) =>
      _save(profile.copyWith(personalityTags: values));

  Future<void> _save(EditableProfile value) async {
    await _preferences.setString(
      storageKey,
      jsonEncode({
        'mtNickname': value.nickname,
        'mtBio': value.bio,
        'mtAvatarAssetName': value.avatarReference,
        'mtInterests': value.interests,
        'mtPersonalityTags': value.personalityTags,
      }),
    );
  }
}
