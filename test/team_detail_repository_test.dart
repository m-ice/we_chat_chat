import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/data/providers/asset_json_provider.dart';
import 'package:we_chat_chat/data/repositories/team_detail_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/team_detail_comment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('loads moderated activity-detail comments from the seed JSON', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
    );

    final comments = await repository.getComments(7);

    expect(comments, hasLength(3));
    expect(comments.every((comment) => comment.content.isNotEmpty), isTrue);
    final state = await repository.getSeedState(7);
    expect(state.participantCount, 3);
    expect(state.participantTotal, 4);
    expect(state.participantAvatarPaths, hasLength(2));
  });

  test('persists a new comment for the selected activity', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = TeamDetailRepositoryImpl(
      AssetJsonProvider(),
      preferences,
    );

    await repository.addComment(
      7,
      const TeamDetailComment(nickname: '我', content: '期待参加'),
    );

    final comments = await repository.getComments(7);
    expect(comments.first.content, '期待参加');
    expect(comments, hasLength(4));
  });
}
