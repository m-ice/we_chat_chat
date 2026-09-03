import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/report_record.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._preferences);

  static const storageKey = 'wl_report_delivery_queue';
  final SharedPreferences _preferences;

  @override
  List<ReportRecord> get queuedReports {
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
  Future<ReportRecord> submit({
    required int targetUserId,
    required String reason,
    required String details,
  }) async {
    final record = ReportRecord(
      id: 'report_${DateTime.now().microsecondsSinceEpoch}',
      targetUserId: targetUserId,
      reason: reason.trim(),
      details: details.trim(),
      createdAt: DateTime.now(),
      status: ReportDeliveryStatus.queued,
    );
    final reports = [...queuedReports, record];
    await _preferences.setString(
      storageKey,
      jsonEncode(reports.map(_toJson).toList(growable: false)),
    );
    return record;
  }

  Map<String, Object> _toJson(ReportRecord record) => {
    'id': record.id,
    'targetUserId': record.targetUserId,
    'reason': record.reason,
    'details': record.details,
    'createdAt': record.createdAt.toIso8601String(),
    'status': record.status.name,
  };

  ReportRecord _fromJson(Map<String, dynamic> json) => ReportRecord(
    id: json['id'] as String,
    targetUserId: json['targetUserId'] as int,
    reason: json['reason'] as String,
    details: json['details'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: ReportDeliveryStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => ReportDeliveryStatus.queued,
    ),
  );
}
