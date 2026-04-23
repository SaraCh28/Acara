import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message_model.dart';
import 'ai_service.dart';

class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;

  AiChatState({this.messages = const [], this.isLoading = false});

  AiChatState copyWith({List<AiMessage>? messages, bool? isLoading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return AiChatState();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AiMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.getAiResponse(text);
      final aiMessage = AiMessage(
        text: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearChat() {
    state = AiChatState();
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(AiChatNotifier.new);
