import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../controllers/chat_thread_controller.dart';
import 'widgets/chat_visuals.dart';

class ChatPage extends GetView<ChatThreadController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const ChatHeaderBackdrop(),
          SafeArea(
            child: Column(
              children: [
                ChatPageBar(
                  title: controller.peer.nickname,
                  onMore: () => _showMore(context),
                ),
                Expanded(child: _MessageList(controller: controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMore(BuildContext context) {
    Get.bottomSheet<void>(
      SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ChatAvatar(
                    assetPath: controller.peer.avatarPath,
                    size: 48,
                    onTap: controller.canOpenPeerProfile
                        ? () async {
                            Get.back<void>();
                            await controller.openPeerProfile();
                          }
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.peer.nickname,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.peer.id == -1
                              ? 'chat_assistant'.tr
                              : 'chat_friend'.tr,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.peer.id != -1 && !controller.isSelfPeer) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined),
                  title: Text('chat_voice_call'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.back<void>();
                    controller.startVoiceCall();
                  },
                ),
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: Get.back,
                  child: Text('common_close'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.controller});

  final ChatThreadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        );
      }
      if (controller.hasError.value && controller.messages.isEmpty) {
        return Center(
          child: TextButton.icon(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('chat_load_failed'.tr),
          ),
        );
      }

      return chat_ui.Chat(
        key: const ValueKey('flutter-chat-ui'),
        currentUserId: ChatThreadController.currentUserId,
        resolveUser: controller.resolveUser,
        chatController: controller.chatController,
        onMessageSend: controller.send,
        backgroundColor: Colors.transparent,
        theme: const chat_core.ChatTheme(
          colors: chat_core.ChatColors(
            primary: Color(0xFFFFD357),
            onPrimary: AppColors.textPrimary,
            surface: Colors.transparent,
            onSurface: AppColors.textPrimary,
            surfaceContainer: AppColors.textPrimary,
            surfaceContainerLow: Colors.white,
            surfaceContainerHigh: Color(0xFFF4F4F4),
          ),
          typography: chat_core.ChatTypography(
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 15, height: 1.35),
            bodySmall: TextStyle(fontSize: 12),
            labelLarge: TextStyle(fontSize: 14),
            labelMedium: TextStyle(fontSize: 12),
            labelSmall: TextStyle(fontSize: 10),
          ),
          shape: BorderRadius.all(Radius.circular(12)),
        ),
        builders: chat_core.Builders(
          textMessageBuilder:
              (context, message, index, {required isSentByMe, groupStatus}) {
                return chat_ui.SimpleTextMessage(
                  message: message,
                  index: index,
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 223),
                  sentBackgroundColor: const Color(0xFFFFD357),
                  receivedBackgroundColor: AppColors.textPrimary,
                  sentTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.35,
                  ),
                  receivedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                  ),
                  showTime: false,
                  showStatus: false,
                );
              },
          chatMessageBuilder:
              (
                context,
                message,
                index,
                animation,
                child, {
                isRemoved,
                required isSentByMe,
                groupStatus,
              }) {
                final avatarPath = isSentByMe
                    ? controller.currentUser.value?.avatarPath ??
                          ChatSystemAssets.currentUserAvatar
                    : controller.peer.avatarPath;
                final canOpenPeerProfile = controller.canOpenPeerProfile;
                return chat_ui.ChatMessage(
                  message: message,
                  index: index,
                  animation: animation,
                  isRemoved: isRemoved,
                  groupStatus: groupStatus,
                  leadingWidget: isSentByMe
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChatAvatar(
                            key: ValueKey('chat-peer-avatar-${message.id}'),
                            assetPath: avatarPath,
                            size: 40,
                            onTap: canOpenPeerProfile
                                ? controller.openPeerProfile
                                : null,
                          ),
                        ),
                  trailingWidget: isSentByMe
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: ChatAvatar(
                            key: ValueKey(
                              'chat-current-user-avatar-${message.id}',
                            ),
                            assetPath: avatarPath,
                            size: 40,
                            onTap: controller.currentUser.value == null
                                ? null
                                : controller.openCurrentUserProfile,
                          ),
                        )
                      : null,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sentMessageRowAlignment: CrossAxisAlignment.start,
                  receivedMessageRowAlignment: CrossAxisAlignment.start,
                  paddingChangeAnimationDuration: null,
                  child: child,
                );
              },
          composerBuilder: (_) => _MessageComposer(controller: controller),
          chatAnimatedListBuilder: (_, itemBuilder) => Obx(
            () => chat_ui.ChatAnimatedList(
              itemBuilder: itemBuilder,
              topPadding: 0,
              bottomPadding: 68,
              handleSafeArea: false,
              initialScrollToEndMode: chat_ui.InitialScrollToEndMode.none,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              bottomSliver: controller.awaitingReply.value
                  ? SliverToBoxAdapter(
                      child: _TypingBubble(
                        avatarPath: controller.peer.avatarPath,
                        onAvatarTap: controller.canOpenPeerProfile
                            ? controller.openPeerProfile
                            : null,
                      ),
                    )
                  : null,
            ),
          ),
          emptyChatListBuilder: (_) => const SizedBox.shrink(),
        ),
      );
    });
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.avatarPath, this.onAvatarTap});

  final String avatarPath;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BubbleAvatar(assetPath: avatarPath, onTap: onAvatarTap),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'chat_typing'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleAvatar extends StatelessWidget {
  const _BubbleAvatar({required this.assetPath, this.onTap});

  final String? assetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      ChatAvatar(assetPath: assetPath ?? '', size: 40, onTap: onTap);
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.controller});

  final ChatThreadController controller;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (_hasText == hasText) return;
    setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_handleTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = widget.controller;
      final canSend =
          controller.canSend.value && !controller.awaitingReply.value;
      final hint = controller.awaitingReply.value
          ? 'chat_peer_replying'.tr
          : controller.canSend.value
          ? 'chat_input_hint'.tr
          : 'chat_wait_input'.tr;
      return Positioned(
        left: 16,
        right: 16,
        bottom: 8,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('chat-message-input'),
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: canSend,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  width: 62,
                  height: 36,
                  child: Opacity(
                    opacity: canSend ? 1 : .48,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const AppImage(
                          ChatSystemAssets.sendButton,
                          width: 62,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                        TextButton(
                          key: const ValueKey('chat-send-button'),
                          onPressed: canSend && _hasText ? _submit : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.black,
                            disabledForegroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'chat_send'.tr,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty || !widget.controller.canSend.value) return;
    _textController.clear();
    await widget.controller.send(text);
    if (mounted && widget.controller.canSend.value) {
      _focusNode.requestFocus();
    }
  }
}
