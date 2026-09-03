enum SupportTicketStatus { queued, delivered, closed }

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.contact,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String contact;
  final DateTime createdAt;
  final SupportTicketStatus status;
}
