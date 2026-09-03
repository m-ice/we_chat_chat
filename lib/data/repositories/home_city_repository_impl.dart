import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/home_city_repository.dart';
import '../providers/asset_json_provider.dart';

class HomeCityRepositoryImpl implements HomeCityRepository {
  HomeCityRepositoryImpl(this._assets, this._preferences);

  static const _selectedCityKey = 'mt_home_selected_city';
  static const _defaultCity = '全部';
  static const _citiesAsset = 'assets/mock/home_cities.txt';

  final AssetJsonProvider _assets;
  final SharedPreferences _preferences;

  @override
  String get selectedCity =>
      _preferences.getString(_selectedCityKey) ?? _defaultCity;

  @override
  Future<List<String>> getCities() async => [
    _defaultCity,
    ...await _assets.readCommaSeparated(_citiesAsset),
  ];

  @override
  Future<void> selectCity(String city) async {
    final value = city.trim();
    if (value.isEmpty || value == selectedCity) return;
    await _preferences.setString(_selectedCityKey, value);
  }
}
