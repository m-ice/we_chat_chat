import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_controller.dart';
import 'profile_design.dart';

class ProfileTextEditPage extends StatefulWidget {
  const ProfileTextEditPage({
    super.key,
    required this.nickname,
    required this.initialValue,
  });

  final bool nickname;
  final String initialValue;

  @override
  State<ProfileTextEditPage> createState() => _ProfileTextEditPageState();
}

class _ProfileTextEditPageState extends State<ProfileTextEditPage> {
  late final TextEditingController field;
  late final FocusNode focusNode;
  bool saving = false;

  EditProfileController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    field = TextEditingController(text: widget.initialValue);
    focusNode = FocusNode();
  }

  Future<void> save() async {
    if (saving) return;
    setState(() => saving = true);
    final saved = await controller.saveText(
      field.text,
      nickname: widget.nickname,
    );
    if (!mounted) return;
    setState(() => saving = false);
    if (saved) Get.back(result: true);
  }

  @override
  void dispose() {
    field.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileDecoratedScaffold(
    title: widget.nickname ? 'profile_nickname'.tr : 'profile_bio'.tr,
    resizeToAvoidBottomInset: true,
    actions: [
      ProfileAppBarAction(
        label: 'common_done'.tr,
        onPressed: saving ? null : save,
      ),
    ],
    body: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ProfilePanel(
          child: SizedBox(
            height: 325,
            child: TextField(
              controller: field,
              focusNode: focusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              inputFormatters: [
                LengthLimitingTextInputFormatter(widget.nickname ? 16 : 100),
              ],
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: widget.nickname
                    ? 'profile_nickname_input_hint'.tr
                    : 'profile_bio_input_hint'.tr,
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
