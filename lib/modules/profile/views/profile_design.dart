import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';

const profilePanelBorder = Color(0xFFEEEEEE);
const profileFieldBackground = Color(0xFFF4F4F4);
const profileMutedText = Color(0xFF999999);

abstract final class ProfileDetailAssets {
  static const headerBackground = 'assets/images/profile_detail/header_bg.svg';
  static const editAvatar = 'assets/images/profile_detail/edit_avatar.jpeg';
  static const coin = 'assets/images/profile_detail/coin.png';
  static const worldAvatar = 'assets/images/profile_detail/world_avatar.png';
  static const worldPost = 'assets/images/profile_detail/world_post.jpeg';
  static const albumPhoto1 = 'assets/images/profile_detail/album_photo_1.png';
  static const albumPhoto2 = 'assets/images/profile_detail/album_photo_2.png';
  static const chevronRight = 'assets/icons/profile_detail/chevron_right.svg';
  static const rechargeHelp = 'assets/icons/profile_detail/recharge_help.svg';
  static const worldMore = 'assets/icons/profile_detail/world_more.svg';
  static const worldLike = 'assets/icons/profile_detail/world_like.svg';
  static const worldComment = 'assets/icons/profile_detail/world_comment.svg';
}

class ProfileDecoratedScaffold extends StatelessWidget {
  const ProfileDecoratedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: ColoredBox(color: Colors.white)),
      const Positioned(
        left: 0,
        top: 0,
        right: 0,
        height: 255,
        child: ProfileHeaderBackdrop(),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 48,
          titleTextStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          leadingWidth: 56,
          iconTheme: const IconThemeData(color: Color(0xFF333333), size: 22),
          actions: actions,
        ),
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    ],
  );
}

class ProfileHeaderBackdrop extends StatelessWidget {
  const ProfileHeaderBackdrop({super.key});

  @override
  Widget build(BuildContext context) => const AppImage(
    ProfileDetailAssets.headerBackground,
    width: double.infinity,
    height: 255,
    fit: BoxFit.cover,
  );
}

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.borderColor = profilePanelBorder,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
    ),
    child: child,
  );
}

class ProfileAppBarAction extends StatelessWidget {
  const ProfileAppBarAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Center(
      child: SizedBox(
        height: 38,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentYellow,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.accentYellow.withValues(
              alpha: .55,
            ),
            disabledForegroundColor: Colors.black54,
            minimumSize: const Size(62, 38),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(label),
        ),
      ),
    ),
  );
}

class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentYellow,
        foregroundColor: const Color(0xFF222222),
        disabledBackgroundColor: AppColors.accentYellow.withValues(alpha: .5),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}

class ProfileTag extends StatelessWidget {
  const ProfileTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.accentYellow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 13, color: Color(0xFF252525)),
    ),
  );
}
