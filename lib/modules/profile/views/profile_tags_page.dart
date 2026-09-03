import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_toast.dart';
import '../controllers/edit_profile_controller.dart';
import 'profile_design.dart';

class ProfileTagsPage extends StatefulWidget {
  const ProfileTagsPage({super.key, required this.personality});

  final bool personality;

  @override
  State<ProfileTagsPage> createState() => _ProfileTagsPageState();
}

class _ProfileTagsPageState extends State<ProfileTagsPage> {
  late final EditProfileController controller;
  late final Set<String> selected;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find();
    selected = Set.of(
      widget.personality
          ? controller.profile.value.personalityTags
          : controller.profile.value.interests,
    );
  }

  Future<void> save() async {
    if (saving) return;
    setState(() => saving = true);
    await controller.saveTags(
      selected.toList(growable: false),
      personality: widget.personality,
    );
    if (!mounted) return;
    Get.back(result: true);
  }

  void toggle(String tag) {
    if (selected.contains(tag)) {
      setState(() => selected.remove(tag));
      return;
    }
    if (selected.length >= 10) {
      AppToast.show('profile_tag_limit'.trParams({'count': '10'}));
      return;
    }
    setState(() => selected.add(tag));
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.personality
        ? EditProfileController.personalityTags
        : EditProfileController.interests;
    final title = widget.personality
        ? 'profile_personality_title'.tr
        : 'profile_interests'.tr;
    return ProfileDecoratedScaffold(
      title: '$title (${selected.length}/10)',
      actions: [
        ProfileAppBarAction(
          label: 'common_done'.tr,
          onPressed: saving ? null : save,
        ),
      ],
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ProfilePanel(
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: tags
                      .map(
                        (tag) => _TagChoice(
                          label: tag,
                          selected: selected.contains(tag),
                          onTap: () => toggle(tag),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChoice extends StatelessWidget {
  const _TagChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFFFCE45) : const Color(0xFFF4F4F4),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label.tr,
          style: const TextStyle(
            fontSize: 14,
            height: 1.25,
            color: Color(0xFF555555),
          ),
        ),
      ),
    ),
  );
}
