import '../entities/editable_profile.dart';

abstract interface class ProfileEditRepository {
  EditableProfile get profile;
  Future<String?> resolveAvatarPath();
  Future<bool> updateAvatar(String sourcePath);
  Future<void> updateNickname(String value);
  Future<void> updateBio(String value);
  Future<void> updateInterests(List<String> values);
  Future<void> updatePersonalityTags(List<String> values);
}
