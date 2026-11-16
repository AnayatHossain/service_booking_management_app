import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import '../model/ai_message_model.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  AIAssistantBloc()
      : super(AIAssistantState(
          messages: [
            AiMessage(
              role: 'assistant',
              text: "Hello! I'm your AI Service Booking Assistant. How can I help you today? Ask me about available services, pricing, recommendations, or booking instructions!",
              timestamp: DateTime.now(),
              suggestedQuestions: const [
                'What cleaning services do you have?',
                'How much is AC servicing?',
                'I need a plumber right now',
              ],
            ),
          ],
        )) {
    on<AISendMessageRequested>(_onSendMessage);
    on<AIClearChatRequested>(_onClearChat);
  }

  Future<void> _onSendMessage(
      AISendMessageRequested event, Emitter<AIAssistantState> emit) async {
    final text = event.message.trim();
    if (text.isEmpty) return;

    final userMessage = AiMessage(
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<AiMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(messages: updatedMessages, isLoading: true, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiChat,
        apiType: ApiType.post,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({
          'message': text,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        final aiText = data['response'] ?? 'I could not process your request at this moment.';
        final rawServices = data['recommended_services'] as List<dynamic>? ?? [];
        final rawQuestions = data['suggested_questions'] as List<dynamic>? ?? [];

        final services = rawServices
            .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
            .toList();
        final questions = rawQuestions.map((q) => q.toString()).toList();

        final botMessage = AiMessage(
          role: 'assistant',
          text: aiText,
          timestamp: DateTime.now(),
          suggestedServices: services,
          suggestedQuestions: questions,
        );

        emit(state.copyWith(
          messages: List<AiMessage>.from(state.messages)..add(botMessage),
          isLoading: false,
        ));
      } else {
        final botMessage = AiMessage(
          role: 'assistant',
          text: response.errorMessage ?? "I'm having trouble connecting right now. Please try again in a moment.",
          timestamp: DateTime.now(),
        );
        emit(state.copyWith(
          messages: List<AiMessage>.from(state.messages)..add(botMessage),
          isLoading: false,
        ));
      }
    } catch (e) {
      final botMessage = AiMessage(
        role: 'assistant',
        text: "Connection error: $e",
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: List<AiMessage>.from(state.messages)..add(botMessage),
        isLoading: false,
      ));
    }
  }

  void _onClearChat(AIClearChatRequested event, Emitter<AIAssistantState> emit) {
    emit(AIAssistantState(
      messages: [
        AiMessage(
          role: 'assistant',
          text: "Chat cleared! How can I assist you with your booking today?",
          timestamp: DateTime.now(),
          suggestedQuestions: const [
            'What cleaning services do you have?',
            'How much is AC servicing?',
            'I need a plumber right now',
          ],
        ),
      ],
    ));
  }
}
