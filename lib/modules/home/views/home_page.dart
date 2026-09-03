import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_chat_chat/core/vaules/app_image_string.dart';
import 'package:we_chat_chat/core/widgets/app_image.dart';
import 'package:we_chat_chat/core/widgets/common_draggable_float.dart';

import '../../../app/routes/routes.dart';
import '../../../domain/entities/city_user.dart';
import '../../../domain/entities/city_user_mapper.dart';
import '../../../domain/entities/user.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/home_controller.dart';

const _figmaYellow = Color(0xFFFFCE45);
const _figmaText = Color(0xFF333333);
const _figmaSecondary = Color(0xFF999999);
const _figmaAssetRoot = 'assets/images/content';
const _figmaAvatars = [
  '$_figmaAssetRoot/figma_home_avatar_1.png',
  '$_figmaAssetRoot/figma_home_avatar_2.jpg',
  '$_figmaAssetRoot/figma_home_avatar_3.png',
  '$_figmaAssetRoot/figma_home_avatar_4.png',
  '$_figmaAssetRoot/figma_home_avatar_5.png',
];

String _copy(String zh, String en) =>
    Get.locale?.languageCode == 'zh' ? zh : en;

void _openPartnerTab() {
  if (Get.isRegistered<MainController>()) {
    Get.find<MainController>().selectTab(1);
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Obx((){
          if (controller.hasError.value) {
            return Center(child: Text('home_load_failed'.tr));
          }
          return Column(
            children: [
              _NearbyHero(users: controller.nearbyUsers),
              Expanded(
                  child: CommonDraggableFloatWidget(
                      eventStreamController: controller.eventStreamController,
                      listView: RefreshIndicator(
                        onRefresh: controller.load,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 84),
                          itemCount: controller.activityUsers.length,
                          itemBuilder: (context, index) {
                            final user = controller.activityUsers[index];
                            return ActivityCard(
                              user: user,
                              isPendingJoin: controller.pendingJoinIds.contains(
                                user.id,
                              ),
                              onJoin: () => controller.join(user),
                              onOpen: () async {
                                final result = await Get.toNamed(
                                  Routes.teamDetail,
                                  arguments: user,
                                );
                                if (result == HomeFeedTab.nearby) _openPartnerTab();
                                controller.refreshSocialState();
                              },
                            );
                          },
                        ),
                      ),
                      child: _CreateActivityButton(
                        onPressed: () async {
                          await Get.toNamed(Routes.teamPublish);
                          controller.refreshSocialState();
                        },
                      )))
            ],
          );
        }),
      ),
    );
  }
}

class _NearbyHero extends StatelessWidget {
  const _NearbyHero({required this.users});

  final List<CityUser> users;

  void _openRecommendation(int index) {
    if (users.isEmpty) {
      _openPartnerTab();
      return;
    }
    final user = users[index % users.length];
    Get.toNamed(Routes.userDetail, arguments: user.toUser());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w,right: 16.w,bottom: 12.h),
      height: 209.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 21.h),
            child: AppImage(
              AppImageString.homeTopNearbyCard,
              key: const ValueKey('home-hero-background'),
              // width: MediaQuery.sizeOf(context).width - 32.w,
              height: 185.h,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          // Positioned(
          //   left: 20,
          //   top: 9,
          //   width: 300,
          //   height: 44,
          //   child: const _HeroHeadline(),
          // ),
          // Positioned(
          //   right: 12,
          //   top: -15,
          //   width: 136,
          //   height: 103,
          //   child: IgnorePointer(
          //     child: Image.asset(
          //       '$_figmaAssetRoot/figma_home_hero_decor.png',
          //       fit: BoxFit.fill,
          //       alignment: Alignment.bottomCenter,
          //       filterQuality: FilterQuality.high,
          //     ),
          //   ),
          // ),
          Positioned(
            left: 12.w,
            right: 12.w,
            top: 59.h,
            bottom: 65.h,
            child: _RecommendationPanel(onAvatarPressed: _openRecommendation),
          ),
          Positioned(
            bottom: 0,
            width: 178.w,
            height: 44.h,
            child: const _HeroExploreButton(),
          ),
        ],
      ),
    );
  }
}



class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.onAvatarPressed});

  final ValueChanged<int> onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            key: const ValueKey('home-recommendation-panel'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white.withValues(alpha: .72)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x36000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 6,
          child: Text(
            _copy('有颜有趣的人·尽在附近搭子', 'Interesting people are nearby'),
            style: const TextStyle(
              color: Color(0xFF5B3900),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 26,
          width: 302,
          height: 57,
          child: Row(
            children: List.generate(_figmaAvatars.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _figmaAvatars.length - 1 ? 0 : 4,
                ),
                child: GestureDetector(
                  key: ValueKey('home-recommendation-$index'),
                  onTap: () => onAvatarPressed(index),
                  child: Container(
                    width: 57,
                    height: 57,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(
                        _figmaAvatars[index],
                        width: 57,
                        height: 57,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          width: 55,
          height: 55,
          child: AppImage(AppImageString.homeTopNearbyTag,width: 56.98.w,),
        ),
      ],
    );
  }
}

// class _HeroHeadline extends StatelessWidget {
//   const _HeroHeadline();
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           left: 0,
//           top: 11,
//           child: IgnorePointer(
//             child: Text(
//               'LOOK FOR FRIENDS NEARBY',
//               style: TextStyle(
//                 color: Colors.white.withValues(alpha: .20),
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           left: 10,
//           top: 25,
//           width: 117,
//           height: 10,
//           child: Image.asset(
//             '$_figmaAssetRoot/figma_home_title_underline.png',
//             fit: BoxFit.fill,
//             filterQuality: FilterQuality.high,
//           ),
//         ),
//         Positioned(
//           left: 16,
//           top: 0,
//           width: 180,
//           height: 34,
//           child: ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               colors: [Color(0xFFFFFDF7), Color(0xFFFFE7A3)],
//             ).createShader(bounds),
//             child: FittedBox(
//               alignment: Alignment.centerLeft,
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 _copy('附近找搭子', 'Friends nearby'),
//                 maxLines: 1,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   shadows: [
//                     Shadow(
//                       color: Color(0x99582300),
//                       blurRadius: 2,
//                       offset: Offset(0, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// class _RecommendationRibbon extends StatelessWidget {
//   const _RecommendationRibbon();
//
//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               '$_figmaAssetRoot/figma_home_recommend_ribbon.png',
//               fit: BoxFit.fill,
//               filterQuality: FilterQuality.high,
//             ),
//           ),
//           Positioned(
//             left: 14,
//             top: 8,
//             child: Transform.rotate(
//               angle: math.pi / 4,
//               child: Text(
//                 _copy('优选推荐', 'PICKS'),
//                 style: const TextStyle(
//                   color: Color(0xFF284634),
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _HeroExploreButton extends StatelessWidget {
  const _HeroExploreButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _copy('前往寻找', 'Explore nearby'),
      child: GestureDetector(
        key: const ValueKey('home-explore-nearby'),
        behavior: HitTestBehavior.opaque,
        onTap: _openPartnerTab,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFFDE4), width: 2),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2B1B00), Color(0xFF9D6100)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40E39944),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                '$_figmaAssetRoot/figma_home_cta_left.png',
                width: 9,
                height: 10,
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 7),
              Text(
                _copy('前往寻找', 'Explore'),
                style: const TextStyle(
                  color: Color(0xFFFFFEC6),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Image.asset(
                '$_figmaAssetRoot/figma_home_cta_right.png',
                width: 9,
                height: 10,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateActivityButton extends StatelessWidget {
  const _CreateActivityButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _copy('创建活动', 'Create activity'),
      child: GestureDetector(
        key: const ValueKey('home-create-activity'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: 114.w,
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: _figmaYellow,
            borderRadius: BorderRadius.circular(65.r),
            border: Border.all(color: _figmaText, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 4.r,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                '$_figmaAssetRoot/figma_home_publish.png',
                width: 19.w,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _copy('创建活动', 'Create'),
                    maxLines: 1,
                    style: TextStyle(
                      color: _figmaText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.user,
    required this.isPendingJoin,
    this.onOpen,
    this.onJoin,
  });

  final User user;
  final bool isPendingJoin;
  final VoidCallback? onOpen;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final post = user.teamPost!;
    final cover = post.imagePaths.isEmpty
        ? user.avatarPath
        : post.imagePaths.first;
    final category = _eventCategory(post.activity);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Semantics(
        button: true,
        label: _eventTitle(post),
        value: isPendingJoin ? 'home_pending_join'.tr : null,
        onLongPress: onJoin,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap:
          onOpen ?? () => Get.toNamed(Routes.teamDetail, arguments: user),
          onLongPress: onJoin,
          child: Container(
            key: const ValueKey('home-activity-card'),
            width: double.infinity,
            height: 139,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDEDED)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 12,
                  right: 106,
                  height: 22,
                  child: Row(
                    children: [
                      _CategoryChip(category: category),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _eventTitle(post),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _figmaText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 38,
                  right: 106,
                  child: Text(
                    _eventDescription(post),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _figmaSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 60,
                  right: 106,
                  child: _MetaRow(
                    asset: '$_figmaAssetRoot/figma_home_clock.png',
                    text: _eventDate(post.date),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 80,
                  right: 106,
                  child: _MetaRow(
                    asset: '$_figmaAssetRoot/figma_home_map.png',
                    text: _copy(
                      '地址：${post.location}',
                      'Place: ${post.location}',
                    ),
                  ),
                ),
                const Positioned(
                  left: 12,
                  top: 104,
                  child: _ParticipantStrip(),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  width: 82,
                  height: 82,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      cover,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final food = category == _copy('美食', 'Food');
    final color = food ? const Color(0xFFF99900) : const Color(0xFF476CFF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(category, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.asset, required this.text});

  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          Image.asset(
            asset,
            width: 16,
            height: 16,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _figmaSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantStrip extends StatelessWidget {
  const _ParticipantStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 22,
      child: Stack(
        children: [
          for (var index = 0; index < 2; index++)
            Positioned(
              left: index * 16,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: ClipOval(
                  child: Image.asset(
                    _figmaAvatars[index],
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 32,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFDCDCDC),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 17,
                  height: 1,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 62,
            top: 3,
            child: Text(
              '3/4',
              style: TextStyle(color: _figmaText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

String _eventTitle(TeamPost post) {
  final firstLine = post.content.trim().split('\n').first.trim();
  if (post.content.contains('\n') && firstLine.isNotEmpty) return firstLine;
  final activity = post.activity.tr.replaceAll('组队', '').trim();
  return activity.isEmpty ? post.activity.tr : activity;
}

String _eventDescription(TeamPost post) {
  final lines = post.content.trim().split('\n');
  if (lines.length > 1) return lines.skip(1).join(' ').trim();
  return post.content;
}

String _eventCategory(String activity) {
  if (activity.contains('吃') ||
      activity.contains('美食') ||
      activity.contains('咖啡')) {
    return _copy('美食', 'Food');
  }
  return _copy('运动', 'Sports');
}

String _eventDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return _copy('时间：$month月$day日 12:00–13:00', 'Time: $month/$day 12:00–13:00');
}
