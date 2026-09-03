import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';

/// Figma-exported assets owned by the chat/system-message UI task.
///
/// Shared Component Request: move these paths into `AppImageString` after the
/// owner of `lib/core/**` adds the chat-system asset namespace.
abstract final class ChatSystemAssets {
  static const headerBackground =
      'assets/images/chat_system/header_background.svg';
  static const currentUserAvatar =
      'assets/images/chat_system/chat_current_avatar.png';
  static const peerAvatar = 'assets/images/chat_system/chat_peer_avatar.png';
  static const systemAvatar = 'assets/images/chat_system/system_avatar.png';
  static const back = 'assets/icons/chat_system/back.svg';
  static const more = 'assets/icons/chat_system/more.svg';
  static const sendButton = 'assets/icons/chat_system/send_button.svg';
}

class ChatHeaderBackdrop extends StatelessWidget {
  const ChatHeaderBackdrop({super.key, this.height = 255});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: AppImage(
          ChatSystemAssets.headerBackground,
          key: const ValueKey('message-header-artwork'),
          width: double.infinity,
          height: height,
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.assetPath, required this.size});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: AppImage(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: ColoredBox(
          color: const Color(0xFFFFE7A1),
          child: SizedBox.square(
            dimension: size,
            child: const Icon(Icons.person, color: AppColors.iconTint),
          ),
        ),
      ),
    );
  }
}

class ChatPageBar extends StatelessWidget {
  const ChatPageBar({super.key, required this.title, this.onMore});

  final String title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            top: 0,
            width: 48,
            height: 48,
            child: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              child: InkResponse(
                key: const ValueKey('chat-back-button'),
                onTap: Navigator.of(context).maybePop,
                radius: 24,
                child: const Center(
                  child: AppImage(
                    ChatSystemAssets.back,
                    width: 10,
                    height: 18,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 104),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onMore != null)
            Positioned(
              right: 40,
              top: 0,
              width: 48,
              height: 48,
              child: Semantics(
                button: true,
                label: '更多',
                child: InkResponse(
                  key: const ValueKey('chat-more-button'),
                  onTap: onMore,
                  radius: 24,
                  child: const Center(
                    child: AppImage(
                      ChatSystemAssets.more,
                      width: 18,
                      height: 4,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF416D),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, height: 1),
      ),
    );
  }
}
