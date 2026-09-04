import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/user_identity_repository.dart';
import '../providers/device_identity_provider.dart';

class LocalUserIdentityRepository implements UserIdentityRepository {
  LocalUserIdentityRepository(this._preferences, this._device);

  static const _mappingPrefix = 'wl_user_for_device_v1_';

  final SharedPreferences _preferences;
  final DeviceIdentityProvider _device;

  @override
  Future<int> resolveCurrentUserId(Iterable<int> eligibleUserIds) async {
    final ids = eligibleUserIds.toSet().toList()..sort();
    if (ids.isEmpty) throw StateError('No eligible users available');

    final identity = await _device.getIdentity();
    final key = '$_mappingPrefix${_stableKey(identity)}';
    final saved = _preferences.getInt(key);
    if (saved != null && ids.contains(saved)) return saved;

    final selected = ids[Random.secure().nextInt(ids.length)];
    await _preferences.setInt(key, selected);
    return selected;
  }

  String _stableKey(String value) {
    var hash = 0xcbf29ce484222325;
    for (final codeUnit in value.codeUnits) {
      hash = (hash ^ codeUnit) * 0x100000001b3 & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }
}
