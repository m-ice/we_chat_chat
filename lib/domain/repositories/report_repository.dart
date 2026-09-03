import '../entities/report_record.dart';

abstract interface class ReportRepository {
  List<ReportRecord> get queuedReports;

  Future<ReportRecord> submit({
    required int targetUserId,
    required String reason,
    required String details,
  });
}
