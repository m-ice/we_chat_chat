import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/providers/local_chat_storage.dart';
import 'package:we_chat_chat/data/repositories/chat_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/membership_wallet_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/data/repositories/user_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/chat_message.dart';
import 'package:we_chat_chat/domain/entities/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores conversations opened from message-center contacts', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'mt_new_user_coin_gift_granted': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final assets = AssetJsonProvider();
    final repository = ChatRepositoryImpl(
      LocalChatStorage(preferences),
      assets,
      UserRepositoryImpl(assets, ProfileEditRepositoryImpl(preferences)),
      MembershipWalletRepositoryImpl(preferences),
      preferences,
    );
    const visitor = User(
      id: 301,
      nickname: '陆遥',
      age: 0,
      gender: '',
      hobbies: [],
      avatarPath: 'assets/images/chat_detail/visitor_luyao.png',
      intro: '',
      isVerified: false,
    );

    await repository.appendMessage(
      ChatMessage(
        id: 'visitor-message',
        peerId: visitor.id,
        text: '你好',
        isFromCurrentUser: true,
        createdAt: DateTime(2026, 9, 4),
      ),
      peer: visitor,
    );

    final restored = (await repository.getConversations()).firstWhere(
      (item) => item.peer.id == visitor.id,
    );
    expect(restored.peer.nickname, '陆遥');
    expect(restored.peer.avatarPath, visitor.avatarPath);
    expect(restored.preview, '你好');
  });

  test('ignores a damaged peer snapshot store', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'mt_new_user_coin_gift_granted': true,
      'chat_peer_snapshots_v1': '{broken',
    });
    final preferences = await SharedPreferences.getInstance();
    final assets = AssetJsonProvider();
    final repository = ChatRepositoryImpl(
      LocalChatStorage(preferences),
      assets,
      UserRepositoryImpl(assets, ProfileEditRepositoryImpl(preferences)),
      MembershipWalletRepositoryImpl(preferences),
      preferences,
    );

    expect(await repository.getConversations(), isNotEmpty);
  });

  test('concurrent initialization grants the welcome gift once', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final assets = AssetJsonProvider();
    final wallet = MembershipWalletRepositoryImpl(preferences);
    final repository = ChatRepositoryImpl(
      LocalChatStorage(preferences),
      assets,
      UserRepositoryImpl(assets, ProfileEditRepositoryImpl(preferences)),
      wallet,
      preferences,
    );

    await Future.wait([repository.initialize(), repository.initialize()]);

    expect(wallet.coinBalance, 100);
    final gifts = (await repository.getMessages(
      -1,
    )).where((message) => message.id.startsWith('assistant-coin-gift-'));
    expect(gifts, hasLength(1));
  });
}
