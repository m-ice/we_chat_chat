import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/domain/entities/support_ticket.dart';
import 'package:we_chat_chat/domain/repositories/support_repository.dart';
import 'package:we_chat_chat/modules/profile/views/customer_service_page.dart';

import 'helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('customer service form matches the 375pt Figma layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 96);
    tester.view.viewPadding = const FakeViewPadding(top: 144, bottom: 96);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    final repository = _SupportRepository();
    Get.put<SupportRepository>(repository);
    await tester.pumpWidget(buildTestApp(const CustomerServicePage()));
    await tester.pumpAndSettle();

    expect(find.text('在线客服'), findsOneWidget);
    expect(find.text('问题描述'), findsOneWidget);
    expect(find.text('联系方式'), findsOneWidget);
    final submit = find.byKey(const ValueKey('customer-service-submit'));
    expect(tester.getSize(submit), const Size(343, 52));
    expect(tester.getTopLeft(submit), const Offset(16, 716));

    await tester.enterText(
      find.byKey(const ValueKey('customer-service-description')),
      '消息发送后没有显示',
    );
    await tester.enterText(
      find.byKey(const ValueKey('customer-service-contact')),
      'demo@example.com',
    );
    await tester.tap(submit);
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.queuedTickets, hasLength(1));
    expect(repository.queuedTickets.single.contact, 'demo@example.com');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

class _SupportRepository implements SupportRepository {
  final _tickets = <SupportTicket>[];

  @override
  List<SupportTicket> get queuedTickets => List.unmodifiable(_tickets);

  @override
  Future<SupportTicket> submit({
    required String title,
    required String description,
    required String contact,
  }) async {
    final ticket = SupportTicket(
      id: 'ticket-${_tickets.length + 1}',
      title: title,
      description: description,
      contact: contact,
      createdAt: DateTime(2026, 9, 3),
      status: SupportTicketStatus.queued,
    );
    _tickets.add(ticket);
    return ticket;
  }
}
