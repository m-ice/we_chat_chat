enum ReportDeliveryStatus { queued, delivered, resolved }

class ReportRecord {
  const ReportRecord({
    required this.id,
    required this.targetUserId,
    this.targetActivityId,
    this.targetDynamicId,
    required this.reason,
    required this.details,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final int targetUserId;
  final String? targetActivityId;
  final String? targetDynamicId;
  final String reason;
  final String details;
  final DateTime createdAt;
  final ReportDeliveryStatus status;
}
