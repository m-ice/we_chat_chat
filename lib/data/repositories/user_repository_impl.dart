import '../../core/errors/data_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/entities/city_user.dart';
import '../../domain/repositories/profile_edit_repository.dart';
import '../../domain/repositories/user_identity_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';
import '../models/city_user_dto.dart';
import '../providers/asset_json_provider.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._provider,
    this._profile, [
    UserIdentityRepository? identity,
    AlbumRepository? album,
  ]) : _identity = identity ?? const _LegacyUserIdentityRepository(),
       _album = album;

  final AssetJsonProvider _provider;
  final ProfileEditRepository _profile;
  final UserIdentityRepository _identity;
  final AlbumRepository? _album;

  @override
  Future<List<User>> getUsers() async {
    final users = await _loadUsers();
    final currentUserId = await _resolveCurrentUserId(users);
    if (_hasLocalProfileData) {
      final index = users.indexWhere((user) => user.id == currentUserId);
      if (index >= 0) users[index] = await _withEditableProfile(users[index]);
    }
    return users;
  }

  @override
  Future<User> getCurrentUser() async {
    final users = await getUsers();
    final currentUserId = await _resolveCurrentUserId(users);
    return users.firstWhere(
      (user) => user.id == currentUserId,
      orElse: () => throw const DataException('Current user is missing'),
    );
  }

  @override
  Future<List<CityUser>> getCityUsers() =>
      _getCityUsers('assets/mock/city_users.json');

  @override
  Future<List<CityUser>> getVerifiedUsers() =>
      _getCityUsers('assets/mock/verified_users.json');

  Future<List<CityUser>> _getCityUsers(String path) async {
    final json = await _provider.readList(path);
    final users = json
        .where(_isApprovedSeed)
        .map(CityUserDto.fromJson)
        .map((dto) => dto.toEntity())
        .toList();
    final currentUserId = await _resolveCurrentUserId(await _loadUsers());
    final index = users.indexWhere((user) => user.id == currentUserId);
    if (index >= 0 && _hasLocalProfileData) {
      users[index] = await _withEditableCityProfile(users[index]);
    }
    return users;
  }

  bool _isApprovedSeed(Map<String, dynamic> json) =>
      json['isSeedData'] != true ||
      (json['source'] == 'demo' && json['moderationStatus'] == 'approved');

  Future<List<User>> _loadUsers() async {
    final json = await _provider.readList('assets/mock/users.json');
    return json
        .where(_isApprovedSeed)
        .map(UserDto.fromJson)
        .map((dto) => dto.toEntity())
        .toList();
  }

  Future<int> _resolveCurrentUserId(List<User> users) =>
      _identity.resolveCurrentUserId(users.map((user) => user.id));

  bool get _hasLocalProfileData =>
      _profile.hasSavedProfile || (_album?.hasProfilePhotoOverrides ?? false);

  Future<User> _withEditableProfile(User source) async {
    final editable = _profile.profile;
    final hasSavedProfile = _profile.hasSavedProfile;
    final avatarPath = hasSavedProfile
        ? await _profile.resolveAvatarPath()
        : null;
    final resolvedAvatarPath = avatarPath ?? source.avatarPath;
    final galleryImagePaths = await _galleryImagePaths(
      userId: source.id,
      seedPaths: source.galleryImagePaths,
      avatarPath: resolvedAvatarPath,
    );
    return User(
      id: source.id,
      nickname: hasSavedProfile ? editable.nickname : source.nickname,
      age: source.age,
      gender: source.gender,
      hobbies: hasSavedProfile ? editable.interests : source.hobbies,
      avatarPath: resolvedAvatarPath,
      intro: hasSavedProfile ? editable.bio : source.intro,
      isVerified: source.isVerified,
      moment: source.moment,
      teamPost: source.teamPost,
      galleryImagePaths: galleryImagePaths,
      personalityTags: hasSavedProfile
          ? editable.personalityTags
          : source.personalityTags,
      verificationVideoPath: source.verificationVideoPath,
      isSeedData: source.isSeedData,
    );
  }

  Future<CityUser> _withEditableCityProfile(CityUser source) async {
    final editable = _profile.profile;
    final hasSavedProfile = _profile.hasSavedProfile;
    final avatarPath = hasSavedProfile
        ? await _profile.resolveAvatarPath()
        : null;
    final resolvedAvatarPath = avatarPath ?? source.avatarPath;
    return CityUser(
      id: source.id,
      nickname: hasSavedProfile ? editable.nickname : source.nickname,
      avatarPath: resolvedAvatarPath,
      city: source.city,
      age: source.age,
      intent: source.intent,
      occupation: source.occupation,
      intro: hasSavedProfile ? editable.bio : source.intro,
      hobbies: hasSavedProfile ? editable.interests : source.hobbies,
      galleryImagePaths: await _galleryImagePaths(
        userId: source.id,
        seedPaths: source.galleryImagePaths,
        avatarPath: resolvedAvatarPath,
      ),
      isVideoVerified: source.isVideoVerified,
      isRealPersonVerified: source.isRealPersonVerified,
      videoPath: source.videoPath,
      isOnline: source.isOnline,
      videoCoverPath: source.videoCoverPath,
      videoAvatarPath: source.videoAvatarPath,
      isSeedData: source.isSeedData,
    );
  }

  Future<List<String>> _galleryImagePaths({
    required int userId,
    required List<String> seedPaths,
    required String avatarPath,
  }) async {
    final album = _album;
    if (album == null) {
      return seedPaths
          .where((path) => path.isNotEmpty && path != avatarPath)
          .toSet()
          .toList(growable: false);
    }
    final photos = await album.profilePhotos(
      userId: userId,
      seedPhotoPaths: seedPaths,
      avatarPath: avatarPath,
    );
    return Future.wait(photos.map(album.fullPath));
  }
}

class _LegacyUserIdentityRepository implements UserIdentityRepository {
  const _LegacyUserIdentityRepository();

  @override
  Future<int> resolveCurrentUserId(Iterable<int> eligibleUserIds) async {
    final ids = eligibleUserIds.toSet();
    if (ids.contains(2)) return 2;
    return ids.first;
  }
}
