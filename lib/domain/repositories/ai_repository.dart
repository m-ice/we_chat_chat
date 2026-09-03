import '../entities/ai_response.dart';
import '../entities/chat_message.dart';

abstract interface class AiRepository {
  Future<AiResponse> generate(List<ChatMessage> history);
}
