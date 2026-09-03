import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/conversation.dart';
import '../controllers/conversation_controller.dart';
import 'message_feature_pages.dart';
import 'widgets/chat_visuals.dart';

class ConversationPage extends GetView<ConversationController> {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          const ChatHeaderBackdrop(height: _MessagePageMetrics.artworkHeight),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MessageHeader(),
                _QuickEntryRow(controller: controller),
                Expanded(child: _ConversationList(controller: controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

abstract final class _MessagePageMetrics {
  static const artworkHeight = 255.0;
  static const headerHeight = 48.0;
  static const titleLeft = 16.0;
  static const titleTop = 12.0;
  static const underlineLeft = 22.0;
  static const underlineTop = 36.0;
  static const underlineWidth = 23.0;
  static const underlineHeight = 8.0;
  static const quickRowHeight = 97.0;
  static const quickIconTop = 10.0;
  static const quickIconSize = 52.0;
  static const quickBadgeTop = -3.0;
  static const quickBadgeRight = -8.0;
  static const conversationRowHeight = 76.0;
  static const avatarSize = 52.0;
  static const conversationBadgeTop = -4.0;
}

abstract final class _MessageAssets {
  static const underline =
      'assets/images/content/figma_chat_title_underline.png';
  static const quickSystem =
      'assets/images/content/figma_chat_quick_system.png';
  static const quickRelationship =
      'assets/images/content/figma_chat_quick_relationship.png';
  static const quickVisitors =
      'assets/images/content/figma_chat_quick_visitors.png';
  static const quickCalls = 'assets/images/content/figma_chat_quick_calls.png';
}

class _MessageHeader extends StatelessWidget {
  const _MessageHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('message-page-header'),
      height: _MessagePageMetrics.headerHeight,
      child: Stack(
        children: [
          const Positioned(
            left: _MessagePageMetrics.titleLeft,
            top: _MessagePageMetrics.titleTop,
            child: Text(
              '聊天',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: _MessagePageMetrics.underlineLeft,
            top: _MessagePageMetrics.underlineTop,
            width: _MessagePageMetrics.underlineWidth,
            height: _MessagePageMetrics.underlineHeight,
            child: const AppImage(
              _MessageAssets.underline,
              width: _MessagePageMetrics.underlineWidth,
              height: _MessagePageMetrics.underlineHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickEntryRow extends StatelessWidget {
  const _QuickEntryRow({required this.controller});

  final ConversationController controller;

  @override
  Widget build(BuildContext context) {
    final entries = [
      _QuickEntryData(
        title: '系统消息',
        assetPath: _MessageAssets.quickSystem,
        onTap: () {
          final assistant = controller.assistant;
          Get.to<void>(
            () => SystemMessagesPage(
              repository: controller.messageCenter,
              assistant: assistant,
              onOpenChat: assistant == null
                  ? null
                  : () => controller.openChat(assistant),
            ),
          );
        },
      ),
      _QuickEntryData(
        title: '亲密关系',
        assetPath: _MessageAssets.quickRelationship,
        onTap: () => _openContacts(
          title: '亲密关系',
          kind: MessageContactPageKind.relationship,
        ),
      ),
      _QuickEntryData(
        title: '谁看过我',
        assetPath: _MessageAssets.quickVisitors,
        onTap: () =>
            _openContacts(title: '谁看过我', kind: MessageContactPageKind.visitors),
      ),
      _QuickEntryData(
        title: '通话记录',
        assetPath: _MessageAssets.quickCalls,
        onTap: () =>
            _openContacts(title: '通话记录', kind: MessageContactPageKind.calls),
      ),
    ];

    return SizedBox(
      key: const ValueKey('message-quick-entry-row'),
      height: _MessagePageMetrics.quickRowHeight,
      child: Row(
        children: entries
            .map(
              (entry) => Expanded(
                child: _QuickEntry(key: ValueKey(entry.title), data: entry),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  void _openContacts({
    required String title,
    required MessageContactPageKind kind,
  }) {
    Get.to<void>(
      () => MessageContactPage(
        title: title,
        kind: kind,
        repository: controller.messageCenter,
        onOpenChat: controller.openChat,
        onCall: kind == MessageContactPageKind.calls
            ? controller.startVoiceCall
            : null,
      ),
    );
  }
}

class _QuickEntryData {
  const _QuickEntryData({
    required this.title,
    required this.assetPath,
    required this.onTap,
  });

  final String title;
  final String assetPath;
  final VoidCallback onTap;
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({super.key, required this.data});

  final _QuickEntryData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(top: _MessagePageMetrics.quickIconTop),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox.square(
                  dimension: _MessagePageMetrics.quickIconSize,
                  child: AppImage(
                    data.assetPath,
                    key: ValueKey(data.assetPath),
                    width: _MessagePageMetrics.quickIconSize,
                    height: _MessagePageMetrics.quickIconSize,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const Positioned(
                  top: _MessagePageMetrics.quickBadgeTop,
                  right: _MessagePageMetrics.quickBadgeRight,
                  child: NotificationBadge(label: '99+'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              data.title,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.controller});

  final ConversationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.conversations.isEmpty) {
        return const SizedBox.shrink();
      }
      if (controller.hasError.value && controller.conversations.isEmpty) {
        return Center(
          child: TextButton.icon(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('chat_load_failed'.tr),
          ),
        );
      }
      if (controller.conversations.isEmpty) {
        return const Center(
          child: Text(
            '还没有聊天，去认识新朋友吧',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        );
      }
      return AppRefreshView(
        onRefresh: controller.load,
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: controller.conversations.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            indent: 80,
            endIndent: 16,
            color: Color(0xFFEFE7D6),
          ),
          itemBuilder: (context, index) => _ConversationRow(
            key: ValueKey(
              'conversation-${controller.conversations[index].peer.id}',
            ),
            conversation: controller.conversations[index],
            avatarAssetPath:
                _figmaAvatarPaths[index % _figmaAvatarPaths.length],
            onTap: () =>
                controller.openChat(controller.conversations[index].peer),
          ),
        ),
      );
    });
  }
}

const _figmaAvatarPaths = [
  'assets/images/content/figma_chat_avatar_2.png',
  'assets/images/content/figma_chat_avatar_1.png',
  'assets/images/content/figma_chat_avatar_3.png',
  'assets/images/content/figma_chat_avatar_4.png',
];

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    super.key,
    required this.conversation,
    required this.avatarAssetPath,
    required this.onTap,
  });

  final Conversation conversation;
  final String avatarAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _MessagePageMetrics.conversationRowHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ChatAvatar(
                    assetPath: avatarAssetPath,
                    size: _MessagePageMetrics.avatarSize,
                  ),
                  const Positioned(
                    top: _MessagePageMetrics.conversationBadgeTop,
                    right: 0,
                    child: NotificationBadge(label: '99+'),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conversation.peer.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _formatTime(conversation.updatedAt),
                  style: const TextStyle(
                    color: Color(0xFFD4D9DD),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
