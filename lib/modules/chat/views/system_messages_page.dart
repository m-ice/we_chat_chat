import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/message_center_item.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/message_center_repository.dart';
import '../controllers/message_center_controller.dart';
import 'widgets/chat_visuals.dart';

/// Figma node 2259:9753.
///
/// The data remains owned by [MessageCenterController]; this page only adapts
/// it to the single-bubble system-message presentation from the design.
class SystemMessagesPage extends StatefulWidget {
  const SystemMessagesPage({
    super.key,
    required this.repository,
    required this.assistant,
    this.onOpenChat,
  });

  final MessageCenterRepository repository;
  final User? assistant;
  final VoidCallback? onOpenChat;

  @override
  State<SystemMessagesPage> createState() => _SystemMessagesPageState();
}

class _SystemMessagesPageState extends State<SystemMessagesPage> {
  late final String _controllerTag;
  late final MessageCenterController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'figma-system-messages-${identityHashCode(this)}';
    _controller = Get.put(
      MessageCenterController(widget.repository, MessageCenterSection.system),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<MessageCenterController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const ChatHeaderBackdrop(),
          SafeArea(
            child: Column(
              children: [
                const ChatPageBar(title: '系统消息'),
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value &&
                        _controller.systemNotices.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentYellow,
                        ),
                      );
                    }
                    if (_controller.hasError.value &&
                        _controller.systemNotices.isEmpty) {
                      return _SystemMessagesError(onRetry: _controller.load);
                    }
                    return AppRefreshView(
                      onRefresh: _controller.load,
                      child: _SystemMessageList(
                        notices: _controller.systemNotices,
                        onOpenChat: widget.assistant == null
                            ? null
                            : widget.onOpenChat,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessageList extends StatelessWidget {
  const _SystemMessageList({required this.notices, this.onOpenChat});

  final List<SystemNotice> notices;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) {
      return ListView(
        key: const ValueKey('system-message-empty'),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .55,
            child: const Center(
              child: Text(
                '暂时没有新消息',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      key: const ValueKey('system-message-list'),
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: notices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final notice = notices[index];
        return Align(
          alignment: Alignment.topLeft,
          child: InkWell(
            key: ValueKey('system-notice-${notice.id}'),
            onTap: onOpenChat,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatAvatar(
                  assetPath: _displayAvatarPath(notice.avatarPath),
                  size: 40,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 223),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notice.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _displayAvatarPath(String source) =>
      source == 'assets/images/chat_detail/system_assistant.png'
      ? ChatSystemAssets.systemAvatar
      : source;
}

class _SystemMessagesError extends StatelessWidget {
  const _SystemMessagesError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('加载失败，点击重试'),
      ),
    );
  }
}
