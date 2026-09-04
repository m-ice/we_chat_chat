import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/data_exception.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._preferences);

  static const storageKey = 'wl_support_delivery_queue';
  final SharedPreferences _preferences;

  @override
  List<SupportTicket> get queuedTickets {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      final values = jsonDecode(raw) as List<dynamic>;
      return values
          .map((item) => _fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<SupportTicket> submit({
    required String title,
    required String description,
    required String contact,
  }) async {
    final ticket = SupportTicket(
      id: 'ticket_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      contact: contact.trim(),
      createdAt: DateTime.now(),
      status: SupportTicketStatus.queued,
    );
    final tickets = [...queuedTickets, ticket];
    final saved = await _preferences.setString(
      storageKey,
      jsonEncode(tickets.map(_toJson).toList(growable: false)),
    );
    if (!saved) throw const DataException('Unable to queue support ticket');
    return ticket;
  }

  Map<String, Object> _toJson(SupportTicket ticket) => {
    'id': ticket.id,
    'title': ticket.title,
    'description': ticket.description,
    'contact': ticket.contact,
    'createdAt': ticket.createdAt.toIso8601String(),
    'status': ticket.status.name,
  };

  SupportTicket _fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    contact: json['contact'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: SupportTicketStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => SupportTicketStatus.queued,
    ),
  );
}
