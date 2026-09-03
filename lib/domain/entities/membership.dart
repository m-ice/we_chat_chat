class Membership {
  const Membership({required this.productId, required this.expiresAt});

  final String productId;
  final DateTime expiresAt;

  bool isActiveAt(DateTime now) => expiresAt.isAfter(now);
}
