import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/routes/routes.dart';
import '../../../core/config/legal_document_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/vaules/app_image_string.dart';
import '../../../core/widgets/app_image.dart';
import 'profile_design.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: 'profile_about_us'.tr,
    body: ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 68),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: const AppImage(
              AppImageString.aboutUsAppIcon,
              width: 98,
              height: 98,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'about_product_name'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 2),
        const _AboutVersion(),
        const SizedBox(height: 64),
        _AboutLinkRow(
          label: 'legal_user_agreement'.tr,
          onTap: () => Get.toNamed(
            Routes.legal,
            arguments: {
              'title': 'legal_user_agreement'.tr,
              'url': LegalDocumentUrls.userAgreement,
            },
          ),
        ),
        _AboutLinkRow(
          label: 'legal_privacy'.tr,
          onTap: () => Get.toNamed(
            Routes.legal,
            arguments: {
              'title': 'legal_privacy'.tr,
              'url': LegalDocumentUrls.privacyPolicy,
            },
          ),
        ),
      ],
    ),
  );
}

class _AboutVersion extends StatefulWidget {
  const _AboutVersion();

  @override
  State<_AboutVersion> createState() => _AboutVersionState();
}

class _AboutVersionState extends State<_AboutVersion> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: _packageInfo,
    builder: (context, snapshot) {
      final version = snapshot.data?.version.trim();
      final text = version?.isNotEmpty == true
          ? 'about_version'.trParams({'version': version!})
          : 'about_version_unavailable'.tr;
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.4,
        ),
      );
    },
  );
}

class _AboutLinkRow extends StatelessWidget {
  const _AboutLinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ),
            const AppImage(
              ProfileDetailAssets.chevronRight,
              width: 10,
              height: 18,
            ),
          ],
        ),
      ),
    ),
  );
}
