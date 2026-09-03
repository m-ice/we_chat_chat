import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  MainController(this._preferences);

  static const _ageConfirmedKey = 'wl_age_18_confirmed';
  final SharedPreferences _preferences;
  final selectedIndex = 0.obs;
  final ageConfirmed = false.obs;

  @override
  void onInit() {
    super.onInit();
    ageConfirmed.value = _preferences.getBool(_ageConfirmedKey) ?? false;
  }

  void selectTab(int index) => selectedIndex.value = index;

  Future<void> confirmAdult() async {
    await _preferences.setBool(_ageConfirmedKey, true);
    ageConfirmed.value = true;
  }
}
