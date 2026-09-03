import '../entities/membership.dart';

abstract interface class MembershipWalletRepository {
  static const chatCost = 1;
  static const callCostPerMinute = 10;

  int get coinBalance;
  Membership? get membership;
  bool get isVipActive;
  String get vipStatusText;

  Future<bool> spendCoins(int amount);
  Future<void> addCoins(int amount);
  Future<void> activateVip({
    required String productId,
    required int durationDays,
  });
}
