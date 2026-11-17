import 'package:equatable/equatable.dart';

abstract class AIAssistantEvent extends Equatable {
  const AIAssistantEvent();

  @override
  List<Object?> get props => [];
}

class AISendMessageRequested extends AIAssistantEvent {
  final String message;
  const AISendMessageRequested(this.message);

  @override
  List<Object?> get props => [message];
}

class AIClearChatRequested extends AIAssistantEvent {
  const AIClearChatRequested();
}
