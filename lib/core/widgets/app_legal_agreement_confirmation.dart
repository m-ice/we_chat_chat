import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/routes.dart';
import '../config/legal_document_urls.dart';
import '../theme/app_colors.dart';
import 'app_dialog.dart';

/// Shared consent prompt for flows that publish user-created content.
///
/// The legal documents remain available before the user confirms, so a publish
/// action never treats a generic acknowledgement as informed consent.
abstract final class AppLegalAgreementConfirmation {
  static Future<bool> show() => AppDialog.confirm(
    title: 'common_tip'.tr,
    messageWidget: const _AgreementMessage(),
    confirmText: 'common_done'.tr,
  );
}

class _AgreementMessage extends StatelessWidget {
  const _AgreementMessage();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'legal_agreement_required'.tr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          _LegalDocumentLink(
            key: const ValueKey('legal-confirm-user-agreement'),
            label: 'legal_user_agreement_bracketed'.tr,
            url: LegalDocumentUrls.userAgreement,
          ),
          Text(
            'legal_and'.tr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          _LegalDocumentLink(
            key: const ValueKey('legal-confirm-privacy-policy'),
            label: 'legal_privacy_bracketed'.tr,
            url: LegalDocumentUrls.privacyPolicy,
          ),
        ],
      ),
    ],
  );
}

class _LegalDocumentLink extends StatelessWidget {
  const _LegalDocumentLink({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () =>
        Get.toNamed(Routes.legal, arguments: {'title': label, 'url': url}),
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFF7097),
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    child: Text(label),
  );
}
