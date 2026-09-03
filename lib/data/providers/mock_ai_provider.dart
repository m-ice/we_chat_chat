class MockAiProvider {
  Future<String> generate(String latestUserText) async {
    return '已经收到你的问题：“$latestUserText”。可以告诉我活动城市和类型，我会继续帮你整理。';
  }
}
