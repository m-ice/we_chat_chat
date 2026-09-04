enum FeatureAccess { activityJoin, activityPublish, directMessage, voiceCall }

abstract interface class FeatureAccessGate {
  Future<bool> request(FeatureAccess feature);
}

/// V1 keeps community interactions free until a server-backed access service is
/// introduced. Controllers depend on this gate rather than payment state.
final class FreeFeatureAccessGate implements FeatureAccessGate {
  const FreeFeatureAccessGate();

  @override
  Future<bool> request(FeatureAccess feature) async => true;
}
