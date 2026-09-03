import '../entities/message_center_item.dart';

abstract interface class MessageCenterRepository {
  Future<List<SystemNotice>> getSystemNotices();

  Future<void> markSystemNoticesRead(Iterable<String> ids);

  Future<List<IntimateRelationship>> getRelationships();

  Future<void> setRelationshipState(int personId, RelationshipState state);

  Future<List<VisitorRecord>> getVisitors();

  Future<List<CallRecord>> getCallRecords();

  Future<CallRecord> addDemoCallback(MessageCenterPerson person);
}
