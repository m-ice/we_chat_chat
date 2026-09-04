import '../../core/errors/data_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/city_user.dart';
import '../../domain/repositories/profile_edit_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';
import '../models/city_user_dto.dart';
import '../providers/asset_json_provider.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._provider, this._profile);

  static const _currentUserId = 2;
  final AssetJsonProvider _provider;
  final ProfileEditRepository _profile;

  @override
  Future<List<User>> getUsers() async {
    final json = await _provider.readList('assets/mock/users.json');
    final users = json
        .where(_isApprovedSeed)
        .map(UserDto.fromJson)
        .map((dto) => dto.toEntity())
        .toList();
    final index = users.indexWhere((user) => user.id == _currentUserId);
    if (index >= 0) users[index] = await _withEditableProfile(users[index]);
    return users;
  }

  @override
  Future<User> getCurrentUser() async {
    final users = await getUsers();
    return users.firstWhere(
      (user) => user.id == _currentUserId,
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
    final index = users.indexWhere((user) => user.id == _currentUserId);
    if (index >= 0) {
      users[index] = await _withEditableCityProfile(users[index]);
    }
    return users;
  }

  bool _isApprovedSeed(Map<String, dynamic> json) =>
      json['isSeedData'] != true ||
      (json['source'] == 'demo' && json['moderationStatus'] == 'approved');

  Future<User> _withEditableProfile(User source) async {
    final editable = _profile.profile;
    final avatarPath = await _profile.resolveAvatarPath();
    return User(
      id: source.id,
      nickname: editable.nickname,
      age: source.age,
      gender: source.gender,
      hobbies: source.hobbies,
      avatarPath: avatarPath ?? source.avatarPath,
      intro: editable.bio,
      isVerified: source.isVerified,
      moment: source.moment,
      teamPost: source.teamPost,
      galleryImagePaths: source.galleryImagePaths,
      verificationVideoPath: source.verificationVideoPath,
      isSeedData: source.isSeedData,
    );
  }

  Future<CityUser> _withEditableCityProfile(CityUser source) async {
    final editable = _profile.profile;
    final avatarPath = await _profile.resolveAvatarPath();
    return CityUser(
      id: source.id,
      nickname: editable.nickname,
      avatarPath: avatarPath ?? source.avatarPath,
      city: source.city,
      age: source.age,
      intent: source.intent,
      occupation: source.occupation,
      intro: editable.bio,
      hobbies: source.hobbies,
      galleryImagePaths: source.galleryImagePaths,
      isVideoVerified: source.isVideoVerified,
      isRealPersonVerified: source.isRealPersonVerified,
      videoPath: source.videoPath,
      isOnline: source.isOnline,
      videoCoverPath: source.videoCoverPath,
      videoAvatarPath: source.videoAvatarPath,
      isSeedData: source.isSeedData,
    );
  }
}
