import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/domain/policies/feature_access_gate.dart';

void main() {
  test(
    'v1 feature access gate keeps all community interactions free',
    () async {
      const gate = FreeFeatureAccessGate();

      final decisions = await Future.wait(
        FeatureAccess.values.map(gate.request),
      );

      expect(decisions, everyElement(isTrue));
    },
  );
}
