import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/report_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/support_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/report_record.dart';
import 'package:we_chat_chat/domain/entities/support_ticket.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('report submission is retained in the delivery queue', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = ReportRepositoryImpl(preferences);

    final submitted = await repository.submit(
      targetUserId: 42,
      targetActivityId: 'activity-42',
      targetDynamicId: 'dynamic-42',
      reason: '其他',
      details: '持续发送不适当内容',
    );

    expect(submitted.status, ReportDeliveryStatus.queued);
    expect(repository.queuedReports, hasLength(1));
    expect(repository.queuedReports.single.targetUserId, 42);
    expect(repository.queuedReports.single.targetActivityId, 'activity-42');
    expect(repository.queuedReports.single.targetDynamicId, 'dynamic-42');
    expect(repository.queuedReports.single.details, '持续发送不适当内容');

    final restored = ReportRepositoryImpl(preferences);
    expect(restored.queuedReports, hasLength(1));
    expect(restored.queuedReports.single.id, submitted.id);
  });

  test('support submission is retained in the delivery queue', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SupportRepositoryImpl(preferences);

    final submitted = await repository.submit(
      title: '相册问题',
      description: '选择图片后没有显示',
      contact: 'demo@example.com',
    );

    expect(submitted.status, SupportTicketStatus.queued);
    expect(repository.queuedTickets, hasLength(1));
    expect(repository.queuedTickets.single.title, '相册问题');
    expect(repository.queuedTickets.single.contact, 'demo@example.com');
  });
}
