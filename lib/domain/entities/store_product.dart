enum StoreProduct {
  weeklyVip('weekly6vip', '周会员', '7天', '¥6', 7, null),
  quarterlyVip('threemonthly60vip', '季会员', '3个月', '¥60', 90, null),
  yearlyVip('yearly200vip', '年会员', '12个月', '¥200', 365, null),
  coin60('weiliao60Coin', '60', '微撩币', '¥6', null, 60),
  coin320('weiliao320Coin', '320', '微撩币', '¥30', null, 320),
  coin820('weiliao820Coin', '820', '微撩币', '¥68', null, 820);

  const StoreProduct(
    this.id,
    this.title,
    this.subtitle,
    this.fallbackPrice,
    this.durationDays,
    this.coinAmount,
  );

  final String id;
  final String title;
  final String subtitle;
  final String fallbackPrice;
  final int? durationDays;
  final int? coinAmount;

  bool get isSubscription => durationDays != null;

  static const subscriptions = [weeklyVip, quarterlyVip, yearlyVip];
  static const coinProducts = [coin60, coin320, coin820];
}
