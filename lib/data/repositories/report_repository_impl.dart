import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/data_exception.dart';
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
    String? targetActivityId,
    String? targetDynamicId,
    required String reason,
    required String details,
  }) async {
    final record = ReportRecord(
      id: 'report_${DateTime.now().microsecondsSinceEpoch}',
      targetUserId: targetUserId,
      targetActivityId: targetActivityId,
      targetDynamicId: targetDynamicId,
      reason: reason.trim(),
      details: details.trim(),
      createdAt: DateTime.now(),
      status: ReportDeliveryStatus.queued,
    );
    final reports = [...queuedReports, record];
    final saved = await _preferences.setString(
      storageKey,
      jsonEncode(reports.map(_toJson).toList(growable: false)),
    );
    if (!saved) throw const DataException('Unable to queue report');
    return record;
  }

  Map<String, Object> _toJson(ReportRecord record) => {
    'id': record.id,
    'targetUserId': record.targetUserId,
    if (record.targetActivityId case final activityId?)
      'targetActivityId': activityId,
    if (record.targetDynamicId case final dynamicId?)
      'targetDynamicId': dynamicId,
    'reason': record.reason,
    'details': record.details,
    'createdAt': record.createdAt.toIso8601String(),
    'status': record.status.name,
  };

  ReportRecord _fromJson(Map<String, dynamic> json) => ReportRecord(
    id: json['id'] as String,
    targetUserId: json['targetUserId'] as int,
    targetActivityId: json['targetActivityId'] as String?,
    targetDynamicId: json['targetDynamicId'] as String?,
    reason: json['reason'] as String,
    details: json['details'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: ReportDeliveryStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => ReportDeliveryStatus.queued,
    ),
  );
}
