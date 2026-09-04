import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:we_chat_chat/l10n/app_translations.dart';

void main() {
  test('Chinese and English expose the same localization keys', () {
    final translations = AppTranslations().keys;
    final chineseKeys = translations['zh_CN']!.keys.toSet();
    final englishKeys = translations['en_US']!.keys.toSet();

    expect(englishKeys.difference(chineseKeys), isEmpty);
    expect(chineseKeys.difference(englishKeys), isEmpty);
  });

  test('canonical persisted values have English display translations', () {
    final english = AppTranslations().keys['en_US']!;

    expect(english['骑行组队'], 'Cycling');
    expect(english['旅行'], 'Travel');
    expect(english['温柔内敛'], 'Gentle');
    expect(english['垃圾广告'], 'Spam or Advertising');
    expect(english['年会员'], 'Annual');
  });

  test('localized copies keep matching interpolation parameters', () {
    final translations = AppTranslations().keys;
    final chinese = translations['zh_CN']!;
    final english = translations['en_US']!;
    final parameter = RegExp(r'@[A-Za-z][A-Za-z0-9_]*');

    for (final key in chinese.keys) {
      final chineseParameters = parameter
          .allMatches(chinese[key]!)
          .map((match) => match.group(0))
          .toSet();
      final englishParameters = parameter
          .allMatches(english[key]!)
          .map((match) => match.group(0))
          .toSet();
      expect(englishParameters, chineseParameters, reason: key);
    }
  });

  test(
    'interaction copy is warm while payment and review copy stays clear',
    () {
      final translations = AppTranslations().keys;
      final chinese = translations['zh_CN']!;
      final english = translations['en_US']!;

      expect(chinese['video_liked'], contains('喜欢'));
      expect(chinese['video_favorited'], contains('心动'));
      expect(chinese['invite_sent'], contains('期待一起出发'));
      expect(chinese['social_followed'], contains('相遇'));
      expect(english['world_comment_saved'], contains('conversation'));

      expect(chinese['world_publish_success'], contains('人工审核'));
      expect(chinese['store_coins_success'], contains('已到账'));
      expect(chinese['report_queued_locally'], contains('尚未提交至服务器'));
      expect(english['verify_submit_success'], contains('manual review'));
      expect(english['store_load_failed'], contains('Check your connection'));
    },
  );

  test('direct AppToast string arguments always resolve an i18n key', () {
    final translations = AppTranslations().keys;
    final chinese = translations['zh_CN']!;
    final english = translations['en_US']!;
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final quote in ["'", '"']) {
        final calls = RegExp(
          'AppToast\\.show\\(\\s*${RegExp.escape(quote)}'
          '([^${RegExp.escape(quote)}]*)${RegExp.escape(quote)}',
        ).allMatches(source);
        for (final call in calls) {
          final key = call.group(1)!;
          final suffix = source.substring(call.end).trimLeft();
          expect(
            suffix.startsWith('.tr'),
            isTrue,
            reason: '${entity.path}:${call.start}',
          );
          expect(
            chinese,
            contains(key),
            reason: '${entity.path}:${call.start}',
          );
          expect(
            english,
            contains(key),
            reason: '${entity.path}:${call.start}',
          );
        }
      }
    }
  });
}
