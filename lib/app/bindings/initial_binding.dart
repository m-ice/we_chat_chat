import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/providers/asset_json_provider.dart';
import '../../data/providers/local_chat_storage.dart';
import '../../data/providers/mock_ai_provider.dart';
import '../../data/providers/store_purchase_service.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/home_city_repository_impl.dart';
import '../../data/repositories/mock_ai_repository.dart';
import '../../data/repositories/membership_wallet_repository_impl.dart';
import '../../data/repositories/social_state_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/team_publish_repository_impl.dart';
import '../../data/repositories/profile_edit_repository_impl.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../data/repositories/album_repository_impl.dart';
import '../../data/repositories/my_world_repository_impl.dart';
import '../../data/repositories/square_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/home_city_repository.dart';
import '../../domain/repositories/membership_wallet_repository.dart';
import '../../domain/repositories/social_state_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/team_publish_repository.dart';
import '../../domain/repositories/profile_edit_repository.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/repositories/album_repository.dart';
import '../../domain/repositories/my_world_repository.dart';
import '../../domain/repositories/square_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/support_repository.dart';

class InitialBinding extends Bindings {
  InitialBinding(this._preferences);

  final SharedPreferences _preferences;

  @override
  void dependencies() {
    Get.put(_preferences, permanent: true);
    Get.lazyPut<AssetJsonProvider>(AssetJsonProvider.new, fenix: true);
    Get.put(LocalChatStorage(_preferences), permanent: true);
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HomeCityRepository>(
      () => HomeCityRepositoryImpl(Get.find(), _preferences),
      fenix: true,
    );
    Get.put<SocialStateRepository>(
      SocialStateRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<MembershipWalletRepository>(
      MembershipWalletRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.lazyPut(
      () => StorePurchaseService(
        Get.find<MembershipWalletRepository>(),
        _preferences,
      ),
      fenix: true,
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        _preferences,
      ),
      fenix: true,
    );
    Get.lazyPut<MockAiProvider>(MockAiProvider.new, fenix: true);
    Get.lazyPut<AiRepository>(() => MockAiRepository(Get.find()), fenix: true);
    Get.put<TeamPublishRepository>(
      TeamPublishRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<ProfileEditRepository>(
      ProfileEditRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<VerificationRepository>(
      VerificationRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<AlbumRepository>(
      AlbumRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<MyWorldRepository>(
      MyWorldRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<ReportRepository>(
      ReportRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<SupportRepository>(
      SupportRepositoryImpl(_preferences),
      permanent: true,
    );
    Get.put<SquareRepository>(
      SquareRepositoryImpl(
        Get.find<UserRepository>(),
        Get.find<MyWorldRepository>(),
        Get.find<SocialStateRepository>(),
        _preferences,
      ),
      permanent: true,
    );
  }
}
