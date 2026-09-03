abstract interface class HomeCityRepository {
  String get selectedCity;

  Future<List<String>> getCities();

  Future<void> selectCity(String city);
}
