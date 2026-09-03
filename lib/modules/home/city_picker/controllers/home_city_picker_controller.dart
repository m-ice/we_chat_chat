import 'package:get/get.dart';

import '../../../../domain/repositories/home_city_repository.dart';

class HomeCityPickerController extends GetxController {
  HomeCityPickerController(this._cities);

  final HomeCityRepository _cities;

  final allCities = <String>[].obs;
  final filteredCities = <String>[].obs;
  final selectedCity = '全部'.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedCity.value = _cities.selectedCity;
    load();
  }

  Future<void> load() async {
    hasError.value = false;
    try {
      final values = await _cities.getCities();
      allCities.assignAll(values);
      filteredCities.assignAll(values);
    } on Object {
      hasError.value = true;
    }
  }

  void search(String text) {
    final keyword = text.trim();
    filteredCities.assignAll(
      keyword.isEmpty
          ? allCities
          : allCities.where((city) => city.contains(keyword)),
    );
  }

  Future<void> select(String city) async {
    await _cities.selectCity(city);
    selectedCity.value = city;
    Get.back(result: city);
  }
}
