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
          relationships.assignAll(await repository.getRelationships());
        case MessageCenterSection.visitors:
          visitors.assignAll(await repository.getVisitors());
        case MessageCenterSection.calls:
          calls.assignAll(await repository.getCallRecords());
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
    AppToast.show('已解除与${relationship.person.nickname}的亲密关系');
  }

  Future<CallRecord?> addDemoCallback(MessageCenterPerson person) async {
    try {
      final record = await repository.addDemoCallback(person);
      calls.insert(0, record);
      return record;
    } on Object {
      AppToast.show('暂时无法发起呼叫，请稍后再试');
      return null;
    }
  }
}
