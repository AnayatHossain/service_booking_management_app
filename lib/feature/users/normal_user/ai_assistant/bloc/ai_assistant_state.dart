import 'package:equatable/equatable.dart';
import '../model/ai_message_model.dart';

class AIAssistantState extends Equatable {
  final List<AiMessage> messages;
  final bool isLoading;
  final List<AiSessionModel> sessions;
  final String? currentSessionId;
  final String currentSessionTitle;
  final bool isLoadingSessions;
  final List<String> quickPrompts;
  final String? errorMessage;

  const AIAssistantState({
    this.messages = const [],
    this.isLoading = false,
    this.sessions = const [],
    this.currentSessionId,
    this.currentSessionTitle = 'New Chat',
    this.isLoadingSessions = false,
    this.quickPrompts = const [
      'What cleaning services do you have?',
      'How much does AC maintenance cost?',
      'Can you recommend a home repair service?',
      'How do I cancel or reschedule a booking?',
    ],
    this.errorMessage,
  });

  AIAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    List<AiSessionModel>? sessions,
    String? currentSessionId,
    String? currentSessionTitle,
    bool? isLoadingSessions,
    List<String>? quickPrompts,
    String? errorMessage,
  }) {
    return AIAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentSessionTitle: currentSessionTitle ?? this.currentSessionTitle,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      quickPrompts: quickPrompts ?? this.quickPrompts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        sessions,
        currentSessionId,
        currentSessionTitle,
        isLoadingSessions,
        quickPrompts,
        errorMessage,
      ];
}
