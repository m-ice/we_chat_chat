import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/routes.dart';
import '../../../core/widgets/app_image.dart';
import 'team_detail_controller.dart';

class TeamMembersPage extends StatelessWidget {
  const TeamMembersPage({super.key, required this.arguments});

  final TeamMembersArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('team_members'.tr),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: arguments.users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = arguments.users[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            leading: ClipOval(
              child: AppImage(
                user.avatarPath,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(user.nickname),
            subtitle: Text(
              user.intro,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Get.toNamed(
              Routes.userDetail,
              arguments: <String, Object>{'userId': user.id, 'user': user},
            ),
          );
        },
      ),
    );
  }
}
