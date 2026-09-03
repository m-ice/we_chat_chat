import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/verification_record.dart';
import '../../domain/repositories/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(this._preferences);
  static const storageKey = 'mt_real_person_verify_record';
  final SharedPreferences _preferences;

  @override
  VerificationRecord? get record {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return VerificationRecord(
        status: json['mtStatus'] == 'mtApproved'
            ? VerificationStatus.approved
            : VerificationStatus.pending,
        realName: json['mtRealName'] as String,
        idNumber: json['mtIdNumber'] as String,
        phone: json['mtPhone'] as String,
        idCardImagePath: json['mtIdCardImagePath'] as String,
        handheldImagePath: json['mtHandheldImagePath'] as String,
        submittedAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['mtSubmittedAt'] as num) * 1000).round(),
        ),
      );
    } on Object {
      return null;
    }
  }

  @override
  bool get isPending => record?.status == VerificationStatus.pending;
  @override
  bool get isVerified => record?.status == VerificationStatus.approved;

  @override
  Future<bool> submit({
    required String realName,
    required String idNumber,
    required String phone,
    required String idCardSourcePath,
    required String handheldSourcePath,
  }) async {
    final fields = [
      realName,
      idNumber,
      phone,
    ].map((value) => value.trim()).toList();
    if (fields.any((value) => value.isEmpty)) return false;
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final documents = await getApplicationDocumentsDirectory();
    final relativeDirectory = 'profile/real_person_verify/$id';
    final directory = Directory('${documents.path}/$relativeDirectory');
    try {
      await directory.create(recursive: true);
      final idCardPath = '$relativeDirectory/id_card.jpg';
      final handheldPath = '$relativeDirectory/handheld.jpg';
      await File(idCardSourcePath).copy('${documents.path}/$idCardPath');
      await File(handheldSourcePath).copy('${documents.path}/$handheldPath');
      return _preferences.setString(
        storageKey,
        jsonEncode({
          'mtStatus': 'mtPending',
          'mtRealName': fields[0],
          'mtIdNumber': fields[1],
          'mtPhone': fields[2],
          'mtIdCardImagePath': idCardPath,
          'mtHandheldImagePath': handheldPath,
          'mtSubmittedAt': DateTime.now().millisecondsSinceEpoch / 1000,
        }),
      );
    } on FileSystemException {
      return false;
    }
  }
}
