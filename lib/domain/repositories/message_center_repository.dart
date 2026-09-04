import '../entities/message_center_item.dart';

abstract interface class MessageCenterRepository {
  Future<List<SystemNotice>> getSystemNotices();

  Future<void> markSystemNoticesRead(Iterable<String> ids);

  Future<List<IntimateRelationship>> getRelationships();

  Future<void> setRelationshipState(int personId, RelationshipState state);
  Future<void> markRelationshipsRead(Iterable<int> personIds);

  Future<List<VisitorRecord>> getVisitors();
  Future<void> markVisitorsRead(Iterable<int> personIds);

  Future<List<CallRecord>> getCallRecords();
  Future<void> markCallRecordsRead(Iterable<String> recordIds);

  Future<CallRecord> addDemoCallback(MessageCenterPerson person);
}
