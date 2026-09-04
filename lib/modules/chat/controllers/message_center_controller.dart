import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../domain/entities/message_center_item.dart';
import '../../../domain/repositories/message_center_repository.dart';

enum MessageCenterSection { system, relationships, visitors, calls }

class MessageCenterController extends GetxController {
  MessageCenterController(this.repository, this.section);

  final MessageCenterRepository repository;
  final MessageCenterSection section;

  final systemNotices = <SystemNotice>[].obs;
  final relationships = <IntimateRelationship>[].obs;
  final visitors = <VisitorRecord>[].obs;
  final calls = <CallRecord>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    hasError.value = false;
    isLoading.value = true;
    try {
      switch (section) {
        case MessageCenterSection.system:
          final notices = await repository.getSystemNotices();
          systemNotices.assignAll(notices);
          final unreadIds = notices
              .where((notice) => !notice.isRead)
              .map((notice) => notice.id);
          await repository.markSystemNoticesRead(unreadIds);
          systemNotices.assignAll(
            notices.map((notice) => notice.copyWith(isRead: true)),
          );
        case MessageCenterSection.relationships:
          final values = await repository.getRelationships();
          relationships.assignAll(values);
          await repository.markRelationshipsRead(
            values
                .where((item) => item.unreadCount > 0)
                .map((item) => item.person.id),
          );
          relationships.assignAll(
            values.map((item) => item.copyWith(unreadCount: 0)),
          );
        case MessageCenterSection.visitors:
          final values = await repository.getVisitors();
          visitors.assignAll(values);
          await repository.markVisitorsRead(
            values.where((item) => !item.isRead).map((item) => item.person.id),
          );
          visitors.assignAll(values.map((item) => item.copyWith(isRead: true)));
        case MessageCenterSection.calls:
          final values = await repository.getCallRecords();
          calls.assignAll(values);
          await repository.markCallRecordsRead(
            values.where((item) => !item.isRead).map((item) => item.id),
          );
          calls.assignAll(values.map((item) => item.copyWith(isRead: true)));
      }
    } on Object {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeRelationship(IntimateRelationship relationship) async {
    await repository.setRelationshipState(
      relationship.person.id,
      RelationshipState.removed,
    );
    relationships.removeWhere(
      (item) => item.person.id == relationship.person.id,
    );
    AppToast.show(
      'relationship_removed'.trParams({'name': relationship.person.nickname}),
    );
  }

  Future<CallRecord?> addDemoCallback(MessageCenterPerson person) async {
    try {
      final record = await repository.addDemoCallback(person);
      calls.insert(0, record);
      return record;
    } on Object {
      AppToast.show('call_start_failed'.tr);
      return null;
    }
  }
}
