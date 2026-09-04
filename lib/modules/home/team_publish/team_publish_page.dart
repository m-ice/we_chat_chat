import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_text_input_dialog.dart';
import 'team_activity_picker_page.dart';
import 'team_flow_assets.dart';
import 'team_publish_controller.dart';

const _publishYellow = Color(0xFFFFCE45);
const _publishBorder = Color(0xFFEDEDED);

class TeamPublishPage extends GetView<TeamPublishController> {
  const TeamPublishPage({super.key});

  Future<void> _chooseActivity(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB3000000),
      builder: (_) =>
          TeamActivityPickerSheet(initialValue: controller.activity.value),
    );
    if (selected != null) controller.activity.value = selected;
  }

  Future<void> _chooseDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initial = controller.date.value ?? now.add(const Duration(days: 1));
    final day = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (day == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time != null) controller.updateDate(day, time);
  }

  Future<void> _editText({
    required String title,
    required String hint,
    required TextEditingController target,
  }) async {
    final value = await AppTextInputDialog.show(
      title: title,
      hint: hint,
      initialValue: target.text,
      maxLines: 2,
    );
    if (value != null) target.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('team_create'.tr),
        toolbarHeight: 48,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 255,
            child: AppImage(
              TeamFlowAssets.publishHeaderDecor,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 60,
              16,
              24,
            ),
            children: [
              _MainContentCard(controller: controller),
              const SizedBox(height: 8),
              SizedBox(
                key: const ValueKey('team-publish-detail-card'),
                height: 170,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _publishBorder),
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => _FormRow(
                          icon: TeamFlowAssets.activityIcon,
                          label: 'team_choose_activity'.tr,
                          value: controller.activity.value ?? 'team_choose'.tr,
                          onTap: () => _chooseActivity(context),
                        ),
                      ),
                      const _InsetDivider(),
                      Obx(
                        () => _FormRow(
                          icon: TeamFlowAssets.timeIcon,
                          label: 'team_activity_time'.tr,
                          value: controller.dateText,
                          onTap: () => _chooseDateTime(context),
                        ),
                      ),
                      const _InsetDivider(),
                      _FormRow(
                        icon: TeamFlowAssets.locationIcon,
                        label: 'team_activity_address'.tr,
                        valueListenable: controller.location,
                        emptyValue: 'team_location_hint'.tr,
                        onTap: () => _editText(
                          title: 'team_location'.tr,
                          hint: 'team_location_hint'.tr,
                          target: controller.location,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Obx(
            () => SizedBox(
              height: 52,
              child: FilledButton(
                key: const ValueKey('team-publish-submit'),
                onPressed: controller.submitting.value
                    ? null
                    : () => controller.submit(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _publishYellow,
                  disabledBackgroundColor: const Color(0xFFFFE69C),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                child: controller.submitting.value
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'common_publish'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainContentCard extends StatelessWidget {
  const _MainContentCard({required this.controller});

  final TeamPublishController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('team-publish-main-card'),
      height: 327,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _publishBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: TextField(
              key: const ValueKey('team-publish-title'),
              controller: controller.title,
              maxLength: 30,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'team_title_hint'.tr,
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4E4E4)),
          Expanded(
            child: TextField(
              key: const ValueKey('team-publish-description'),
              controller: controller.content,
              expands: true,
              maxLines: null,
              maxLength: 240,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'team_short_description_hint'.tr,
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.only(top: 14),
              ),
            ),
          ),
          SizedBox(
            height: 118,
            child: Obx(
              () => _PublishImageStrip(
                imagePaths: controller.imagePaths.toList(),
                onPick: controller.pickImages,
                onRemove: controller.removeImage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishImageStrip extends StatelessWidget {
  const _PublishImageStrip({
    required this.imagePaths,
    required this.onPick,
    required this.onRemove,
  });

  final List<String> imagePaths;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * 2) / 3;
        return Row(
          children: List.generate(3, (index) {
            final isImage = index < imagePaths.length;
            final isAdd = index == 2 && imagePaths.length < 3;
            final showsPreview =
                !isImage &&
                !isAdd &&
                index < TeamPublishController.designPreviewImagePaths.length;
            final child = isImage
                ? _SelectedImage(
                    path: imagePaths[index],
                    onRemove: () => onRemove(index),
                  )
                : showsPreview
                ? _SampleImage(
                    path: TeamPublishController.designPreviewImagePaths[index],
                    onTap: onPick,
                  )
                : _AddImage(onTap: onPick);
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : gap),
              child: SizedBox(width: width, height: 118, child: child),
            );
          }),
        );
      },
    );
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AppImage(path, fit: BoxFit.cover),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Color(0x99000000),
              child: Icon(Icons.close_rounded, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _SampleImage extends StatelessWidget {
  const _SampleImage({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AppImage(
          path,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AddImage extends StatelessWidget {
  const _AddImage({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppImage(TeamFlowAssets.addPhotoIcon, width: 24, height: 24),
            const SizedBox(height: 5),
            Text(
              'team_choose_photo'.tr,
              style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.valueListenable,
    this.emptyValue = '',
  }) : assert(value != null || valueListenable != null);

  final String icon;
  final String label;
  final String? value;
  final TextEditingController? valueListenable;
  final String emptyValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget valueText(String text) => Text(
      text.isEmpty ? emptyValue : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              AppImage(icon, width: 20, height: 20),
              const SizedBox(width: 9),
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 5,
                child: valueListenable == null
                    ? valueText(value!)
                    : ValueListenableBuilder<TextEditingValue>(
                        valueListenable: valueListenable!,
                        builder: (_, current, _) => valueText(current.text),
                      ),
              ),
              const SizedBox(width: 4),
              const RotatedBox(
                quarterTurns: 2,
                child: AppImage(
                  TeamFlowAssets.arrowIcon,
                  width: 16,
                  height: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Divider(height: 1, color: Color(0xFFF1F1F1)),
    );
  }
}
