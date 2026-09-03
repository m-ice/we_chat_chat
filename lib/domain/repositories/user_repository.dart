import '../entities/user.dart';
import '../entities/city_user.dart';

abstract interface class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getCurrentUser();
  Future<List<CityUser>> getCityUsers();
  Future<List<CityUser>> getVerifiedUsers();
}
