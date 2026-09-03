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
}
