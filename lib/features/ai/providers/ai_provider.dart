import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/ai/models/chat_message.dart';
import 'package:sagebible/features/ai/services/ai_service.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// AI State
class AIState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const AIState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AIState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// AI Notifier
class AINotifier extends StateNotifier<AIState> {
  final AIService _aiService;

  AINotifier(this._aiService) : super(const AIState());

  Future<void> loadHistory(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final history = await _aiService.fetchChatHistory(userId);
      state = state.copyWith(
        messages: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String userId, String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(text: text, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Save user message
    await _aiService.saveMessage(userId, 'user', text);

    try {
      final response = await _aiService.sendMessage(text);
      
      // Add AI response
      final aiMessage = ChatMessage(text: response, isUser: false);
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      // Save AI message
      await _aiService.saveMessage(userId, 'assistant', response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = const AIState();
  }
}

/// Providers
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});


final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final notifier = AINotifier(aiService);

  // Listen for auth state changes
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (previous?.isAuthenticated == false && next.isAuthenticated && next.user != null) {
      notifier.loadHistory(next.user!.id);
    } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
      notifier.clearChat();
    }
  });

  // Initial load
  final authState = ref.read(authProvider);
  if (authState.isAuthenticated && authState.user != null) {
    Future.microtask(() => notifier.loadHistory(authState.user!.id));
  }

  return notifier;
});
