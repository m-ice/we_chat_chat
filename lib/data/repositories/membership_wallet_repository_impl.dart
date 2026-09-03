import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/membership.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/repositories/membership_wallet_repository.dart';

class MembershipWalletRepositoryImpl implements MembershipWalletRepository {
  MembershipWalletRepositoryImpl(this._preferences);

  static const coinBalanceKey = 'mt_weiliao_coin_balance';
  static const membershipKey = 'mt_membership_record';
  final SharedPreferences _preferences;

  @override
  int get coinBalance => _preferences.getInt(coinBalanceKey) ?? 0;

  @override
  Membership? get membership {
    final raw = _preferences.getString(membershipKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Membership(
        productId: json['mtProductId'] as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['mtExpireAt'] as num) * 1000).round(),
        ),
      );
    } on Object {
      return null;
    }
  }

  @override
  bool get isVipActive => membership?.isActiveAt(DateTime.now()) ?? false;

  @override
  String get vipStatusText {
    final record = membership;
    if (record == null || !record.isActiveAt(DateTime.now())) return '未开通';
    final product = StoreProduct.values
        .where((item) => item.id == record.productId)
        .firstOrNull;
    return product?.title ?? '已开通';
  }

  @override
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0 || coinBalance < amount) return false;
    return _preferences.setInt(coinBalanceKey, coinBalance - amount);
  }

  @override
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _preferences.setInt(coinBalanceKey, coinBalance + amount);
  }

  @override
  Future<void> activateVip({
    required String productId,
    required int durationDays,
  }) async {
    final now = DateTime.now();
    final currentExpiry = membership?.expiresAt;
    final base = currentExpiry != null && currentExpiry.isAfter(now)
        ? currentExpiry
        : now;
    final record = {
      'mtProductId': productId,
      'mtExpireAt':
          base.add(Duration(days: durationDays)).millisecondsSinceEpoch / 1000,
    };
    await _preferences.setString(membershipKey, jsonEncode(record));
  }
}
