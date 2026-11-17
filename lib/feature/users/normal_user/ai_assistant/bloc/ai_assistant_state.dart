import 'package:equatable/equatable.dart';
import '../model/ai_message_model.dart';

class AIAssistantState extends Equatable {
  final List<AiMessage> messages;
  final bool isLoading;
  final List<String> quickPrompts;
  final String? errorMessage;

  const AIAssistantState({
    this.messages = const [],
    this.isLoading = false,
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
    List<String>? quickPrompts,
    String? errorMessage,
  }) {
    return AIAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      quickPrompts: quickPrompts ?? this.quickPrompts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, quickPrompts, errorMessage];
}
