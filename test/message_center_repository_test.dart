import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/message_center_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/message_center_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('message center persists read and relationship states', () async {
    const repository = MessageCenterRepositoryImpl();

    final notices = await repository.getSystemNotices();
    expect(notices, hasLength(1));
    expect(notices.single.isRead, isFalse);

    await repository.markSystemNoticesRead([notices.single.id]);
    expect((await repository.getSystemNotices()).single.isRead, isTrue);

    final relationship = (await repository.getRelationships()).first;
    await repository.setRelationshipState(
      relationship.person.id,
      RelationshipState.removed,
    );
    final reloaded = (await repository.getRelationships()).first;
    expect(reloaded.state, RelationshipState.removed);
  });

  test('demo callbacks are appended to the call history', () async {
    const repository = MessageCenterRepositoryImpl();
    const person = MessageCenterPerson(
      id: 900,
      nickname: '测试用户',
      avatarPath: '',
    );

    final record = await repository.addDemoCallback(person);
    final records = await repository.getCallRecords();

    expect(record.state, CallState.demo);
    expect(record.durationSeconds, 0);
    expect(records.first.id, record.id);
  });
}
