import '../entities/support_ticket.dart';

abstract interface class SupportRepository {
  List<SupportTicket> get queuedTickets;

  Future<SupportTicket> submit({
    required String title,
    required String description,
    required String contact,
  });
}
