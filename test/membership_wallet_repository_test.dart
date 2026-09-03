import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/membership_wallet_repository_impl.dart';

void main() {
  test('persists the iOS wallet keys and enforces coin spending', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final wallet = MembershipWalletRepositoryImpl(preferences);

    expect(wallet.coinBalance, 0);
    expect(await wallet.spendCoins(1), isFalse);
    await wallet.addCoins(100);
    expect(preferences.getInt('mt_weiliao_coin_balance'), 100);
    expect(await wallet.spendCoins(10), isTrue);
    expect(wallet.coinBalance, 90);
  });

  test(
    'extends an active VIP membership instead of replacing its term',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final wallet = MembershipWalletRepositoryImpl(
        await SharedPreferences.getInstance(),
      );

      await wallet.activateVip(productId: 'weekly6vip', durationDays: 7);
      final firstExpiry = wallet.membership!.expiresAt;
      await wallet.activateVip(productId: 'yearly200vip', durationDays: 365);

      expect(wallet.isVipActive, isTrue);
      expect(wallet.vipStatusText, '年会员');
      expect(wallet.membership!.expiresAt.difference(firstExpiry).inDays, 365);
    },
  );
}
