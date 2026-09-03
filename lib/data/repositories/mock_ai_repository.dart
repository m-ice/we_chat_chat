import '../../domain/entities/ai_response.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../providers/mock_ai_provider.dart';

class MockAiRepository implements AiRepository {
  const MockAiRepository(this._provider);

  final MockAiProvider _provider;

  @override
  Future<AiResponse> generate(List<ChatMessage> history) async {
    final latest = history.lastWhere((message) => message.isFromCurrentUser);
    return AiResponse(await _provider.generate(latest.text));
  }
}
