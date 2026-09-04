import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/vaules/app_image_string.dart';
import '../../../../core/widgets/app_image.dart';

abstract final class ChatSystemAssets {
  static const headerBackground = AppImageString.chatHeaderBackground;
  static const currentUserAvatar = AppImageString.chatCurrentUserAvatar;
  static const peerAvatar = AppImageString.chatPeerAvatar;
  static const systemAvatar = AppImageString.chatSystemAvatar;
  static const back = AppImageString.chatBack;
  static const more = AppImageString.chatMore;
  static const sendButton = AppImageString.chatSendButton;
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
      key: const ValueKey('chat-page-bar'),
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
                label: 'common_more'.tr,
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
  const NotificationBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFFF416D),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: count > 99 ? 9 : 11,
          height: 1,
        ),
      ),
    );
  }
}
