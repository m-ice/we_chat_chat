import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:we_chat_chat/domain/entities/editable_profile.dart';
import 'package:we_chat_chat/domain/repositories/profile_edit_repository.dart';
import 'package:we_chat_chat/modules/profile/controllers/edit_profile_controller.dart';
import 'package:we_chat_chat/modules/profile/views/profile_tags_page.dart';
import 'package:we_chat_chat/modules/profile/views/profile_text_edit_page.dart';

import 'helpers/test_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('profile text field stays fluid and enforces its UI limit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.put(EditProfileController(_FakeProfileEditRepository()));
    await tester.pumpWidget(
      buildTestApp(const ProfileTextEditPage(nickname: true, initialValue: '')),
    );
    await tester.pumpAndSettle();

    final input = find.byType(TextField);
    expect(tester.getSize(input).width, closeTo(341, 0.1));
    expect(tester.getSize(input).height, 325);

    await tester.enterText(input, '12345678901234567890');
    await tester.pump();
    expect(find.text('1234567890123456'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('interest count follows selection without fixed positioning', (
    tester,
  ) async {
    Get.put(EditProfileController(_FakeProfileEditRepository()));
    await tester.pumpWidget(
      buildTestApp(const ProfileTagsPage(personality: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('兴趣 (0/10)'), findsOneWidget);
    await tester.tap(find.text('羽毛球'));
    await tester.pump();
    expect(find.text('兴趣 (1/10)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeProfileEditRepository implements ProfileEditRepository {
  EditableProfile _profile = const EditableProfile(
    nickname: '微撩',
    bio: '',
    avatarReference: 'userDefault',
    interests: [],
    personalityTags: [],
  );

  @override
  EditableProfile get profile => _profile;

  @override
  Future<String?> resolveAvatarPath() async => null;

  @override
  Future<bool> updateAvatar(String sourcePath) async => true;

  @override
  Future<void> updateBio(String value) async {
    _profile = _profile.copyWith(bio: value);
  }

  @override
  Future<void> updateInterests(List<String> values) async {
    _profile = _profile.copyWith(interests: values);
  }

  @override
  Future<void> updateNickname(String value) async {
    _profile = _profile.copyWith(nickname: value);
  }

  @override
  Future<void> updatePersonalityTags(List<String> values) async {
    _profile = _profile.copyWith(personalityTags: values);
  }
}
