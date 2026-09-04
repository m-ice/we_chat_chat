import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/providers/device_identity_provider.dart';
import 'package:we_chat_chat/data/repositories/local_user_identity_repository.dart';

void main() {
  test('assigns one random user once for the same device identity', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const device = _FixedDeviceIdentity('ios-test-device');

    final first = LocalUserIdentityRepository(preferences, device);
    final selected = await first.resolveCurrentUserId([1, 2, 3]);
    final restored = LocalUserIdentityRepository(preferences, device);

    expect(selected, isIn([1, 2, 3]));
    expect(await restored.resolveCurrentUserId([1, 2, 3]), selected);
  });
}

class _FixedDeviceIdentity implements DeviceIdentityProvider {
  const _FixedDeviceIdentity(this.value);

  final String value;

  @override
  Future<String> getIdentity() async => value;
}
