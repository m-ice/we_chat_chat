import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DeviceIdentityProvider {
  Future<String> getIdentity();
}

/// Supplies a stable device-scoped identifier without exposing it to the UI.
///
/// iOS provides an identifierForVendor value. Other platforms, and the rare
/// iOS null case, use an installation identifier persisted locally.
class LocalDeviceIdentityProvider implements DeviceIdentityProvider {
  LocalDeviceIdentityProvider(this._preferences, {DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  static const _fallbackKey = 'wl_installation_identity_v1';

  final SharedPreferences _preferences;
  final DeviceInfoPlugin _deviceInfo;
  Future<String>? _pending;

  @override
  Future<String> getIdentity() {
    final pending = _pending;
    if (pending != null) return pending;
    final operation = _resolve();
    _pending = operation;
    return operation;
  }

  Future<String> _resolve() async {
    try {
      if (Platform.isIOS) {
        final identifier = (await _deviceInfo.iosInfo).identifierForVendor;
        if (identifier != null && identifier.trim().isNotEmpty) {
          return 'ios:${identifier.trim()}';
        }
      }
    } on Object {
      // Platform channels are intentionally unavailable in unit tests and may
      // fail before native initialization. A local installation id is enough
      // to keep the selected account stable in either case.
    }

    final saved = _preferences.getString(_fallbackKey);
    if (saved != null && saved.isNotEmpty) return saved;
    final value =
        'install-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    await _preferences.setString(_fallbackKey, value);
    return value;
  }
}
