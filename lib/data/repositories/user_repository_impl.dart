import '../../core/errors/data_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/city_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';
import '../models/city_user_dto.dart';
import '../providers/asset_json_provider.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._provider);

  static const _currentUserId = 2;
  final AssetJsonProvider _provider;

  @override
  Future<List<User>> getUsers() async {
    final json = await _provider.readList('assets/mock/users.json');
    return json.map(UserDto.fromJson).map((dto) => dto.toEntity()).toList();
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
    return json.map(CityUserDto.fromJson).map((dto) => dto.toEntity()).toList();
  }
}
