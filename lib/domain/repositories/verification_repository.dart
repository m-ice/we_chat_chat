import '../entities/verification_record.dart';

abstract interface class VerificationRepository {
  VerificationRecord? get record;
  bool get isPending;
  bool get isVerified;
  Future<bool> submit({
    required String realName,
    required String idNumber,
    required String phone,
    required String idCardSourcePath,
    required String handheldSourcePath,
  });
}
