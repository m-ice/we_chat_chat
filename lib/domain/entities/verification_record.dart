enum VerificationStatus { pending, approved }

class VerificationRecord {
  const VerificationRecord({
    required this.status,
    required this.realName,
    required this.idNumber,
    required this.phone,
    required this.idCardImagePath,
    required this.handheldImagePath,
    required this.submittedAt,
  });
  final VerificationStatus status;
  final String realName;
  final String idNumber;
  final String phone;
  final String idCardImagePath;
  final String handheldImagePath;
  final DateTime submittedAt;
}
