import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/home_city_repository.dart';
import '../../../domain/repositories/social_state_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../chat/controllers/conversation_controller.dart';
import '../../../domain/repositories/membership_wallet_repository.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../domain/repositories/profile_edit_repository.dart';
import '../../../domain/repositories/square_repository.dart';
import '../../discover/controllers/square_controller.dart';
import '../../discover/controllers/video_feed_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController(Get.find<SharedPreferences>()));
    Get.lazyPut(
      () => SquareController(
        Get.find<SquareRepository>(),
        Get.find<SocialStateRepository>(),
      ),
    );
    Get.lazyPut(
      () => VideoFeedController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        Get.find<SocialStateRepository>(),
      ),
    );
    Get.lazyPut(() => ConversationController(Get.find<ChatRepository>()));
    Get.lazyPut(
      () => ProfileController(
        Get.find<UserRepository>(),
        Get.find<MembershipWalletRepository>(),
        Get.find<ProfileEditRepository>(),
      ),
    );
    Get.lazyPut(
      () => HomeController(
        Get.find<UserRepository>(),
        Get.find<HomeCityRepository>(),
        Get.find<SocialStateRepository>(),
        Get.find<MembershipWalletRepository>(),
      ),
    );
  }
}
