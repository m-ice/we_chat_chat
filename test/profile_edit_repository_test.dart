import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_chat/data/repositories/profile_edit_repository_impl.dart';
import 'package:we_chat_chat/domain/entities/editable_profile.dart';

void main() {
  test('persists profile edits with the exact iOS model keys', () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = ProfileEditRepositoryImpl(preferences);

    expect(repository.profile.nickname, '微撩');
    expect(repository.profile.avatarReference, 'userDefault');

    await repository.updateNickname('沐野');
    await repository.updateBio('喜欢山野，也喜欢城市夜景。');
    await repository.updateInterests(['音乐', '户外活动']);
    await repository.updatePersonalityTags(['真诚坦率']);

    final restored = ProfileEditRepositoryImpl(preferences).profile;
    expect(restored.nickname, '沐野');
    expect(restored.bio, '喜欢山野，也喜欢城市夜景。');
    expect(restored.interests, ['音乐', '户外活动']);
    expect(restored.personalityTags, ['真诚坦率']);

    final encoded = preferences.getString('mt_profile_edit_model')!;
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    expect(
      json.keys,
      containsAll([
        'mtNickname',
        'mtBio',
        'mtAvatarAssetName',
        'mtInterests',
        'mtPersonalityTags',
      ]),
    );
  });

  test(
    'keeps the current-user baseline when the first edit is saved',
    () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      final repository = ProfileEditRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      const baseline = EditableProfile(
        nickname: '晓风',
        bio: '喜欢骑行和摄影。',
        avatarReference: 'userDefault',
        interests: ['骑行', '摄影'],
        personalityTags: ['行动派'],
      );

      await repository.initializeIfAbsent(baseline);
      await repository.updateNickname('新的晓风');

      expect(repository.profile.nickname, '新的晓风');
      expect(repository.profile.bio, baseline.bio);
      expect(repository.profile.interests, baseline.interests);
      expect(repository.profile.personalityTags, baseline.personalityTags);
    },
  );
}
