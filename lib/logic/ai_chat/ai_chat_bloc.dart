import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/gemini_service.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

/// BLoC quản lý trạng thái chat AI
/// Screen → AiChatBloc → GeminiService → Gemini API
class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final GeminiService geminiService;

  AiChatBloc({required this.geminiService}) : super(const AiChatState()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiChatState> emit,
  ) async {
    // Thêm tin nhắn của user
    final userMessage = ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    ));

    try {
      // Gửi đến Gemini API
      final response = await geminiService.sendMessage(event.message);

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Lỗi: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearChat(ClearChat event, Emitter<AiChatState> emit) {
    geminiService.clearHistory();
    emit(const AiChatState());
  }
}
